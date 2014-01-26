<cfcomponent>
<cfoutput>
<!--- 

multiple master - still requires MLS data to be downloaded on just 1 server at a time.
If failover is used, the other servers could run the MLS process in their own virtual machine.
Each server would check each other to see who is in control of the MLS data (or some other singleton state) and if none are actively doing it, it would register itself.
Then it would check again that the other servers agree with the change.

when a server starts, before it can process live requests, it would need to check the other servers that its state is still valid and update itself before running all the requests.
	i.e. If the server previously ran the MLS update VM, and a new server is now running it, then it would need to not start it's VM.
	the other servers could be queried to determine if the site configuration had changed (not just the data)
		if it changed, then it must wait until mysql replication catches up and the change is now in effect.
		the server would just need to wait in this case.
	each server needs to maintain a log of which files have been synced to it.   This log could be replicated to all the other servers if it is stored in mysql.
		file_queue_id
		server_id (where the original file is located)
		file_queue_path (absolute path to a COPY of the file - copy ensures it is not altered before being synced)
		file_queue_status (0 = incomplete, 1 = complete)
		file_queue_change_type (1 = insert, 2 replace, 3 delete)
		file_queue_datetime (date of the change, index on this)
		file_queue_cache_flush_callback (need a way to telling the app to clear it's cache, like menu table caches, or slideshow, etc.  so the front-end updates immediately after queue - serialized callback function or what? a bunch of cache label names?).
		file_queue_longblob
			getfileinfo to check size before inserting a blob - only insert  blobs less then Xmb.
			
			disable statement replication for mysql session:  SET sql_log_bin = {0|1}
			
		file_queue_x_server_id
			file_queue_id
			server_id (current server id
			file_queue_x_server_datetime (date of when the file was synced)
		
		file_queue_status_id (keep track of the sync status of each server)
			file_queue_status_last_update_datetime # store the date at the BEGINNING of the last query to other servers.
			file_queue_status_state = 0 out of sync, 1 = in sync
			server_id (current server's id)
		
		querying a server for new queue items on the local machine
			select * from file_queue where server_id <> #db.param(form.server_id)# and 
			file_queue_datetime >= #db.param(#form.file_queue_status_last_update_datetime#
			order by file_queue_datetime asc  LIMIT 0,30
				send list back to server
				rsync each file and verify it completes (insert / update)
				for delete, just delete file and verify it is deleted.
		
		If sync fails, the server must remove itself from the live cluster until corrected.
			If the cluster has only 1 server left, it can't remove itself.

			
			
		when displaying data with file associated, the query must be able to identify if the current server has a synced version available.
		ways to do this:
			all tables that have files associated must be versioned - they only need 1 new field called version_active to do this.
				start transaction
					create version of content record
						newVersionId=insert INTO content ... all the same data... except version_active='0'
						ds={
							datasource: "datasource",
							tableName: "content",
							primaryKeyField: "content_id",
							oldId: qS.content_id,
							newId: newVersionId,
							site_id: qS.site_id
						};
				commit		
				then with "set log_bin = 0"
					we run the transaction sql
					// loop arrSQL
				then run "set log_bin=1" again on the current server.
				file_queue_transaction_sql= serializeJson();
				
				all other servers get the new version with mysql replication instantly, but none of the queries on front of site display it yet because it's not active until:
					the associated file is rsynced and its callback is executed.
					the callback does "set log_bin=0" and updates version_active=1 and then runs set log_bin=1 again on same datasource and clears/updates any related caches  some kind of applyVersion() system that all app would have to support
				a table that is versioned isn't active on all servers 
				
				How to avoid versioning all child records:
					when applying the new version on each server:
						if(file_queue_type EQ "delete"){
							delete local copy
							zdeletefile(file_queue_path);
						}else{
							// pull the file with rsync.
							// if rsync failed, log it and retry later
							
							if file matches / exists, then process the file_queue_transaction_sql
						}
						try{
							ds.sql="SET log_bin=0";
							db.execute("qSet", ds.datasource);
							ds.sql="start transaction";
							db.execute("qTransaction", ds.datasource);
							ds=unserializeJson(qS.file_queue_transaction_sql);
								newId: 
							ds.sql="delete from #db.table(ds.tableName, ds.datasource)# where 
							`#db.primaryKeyField# = '#qS.oldId#' ";
							if(structkeyexists(db, 'site_id')){
								db.sql&=" and site_id = '#ds.site_id#' ", 
							}
							db.execute("qDelete");
							db.sql="update #db.table(ds.tableName, ds.datasource)# set  
							`#db.primaryKeyField#` = '#qS.oldId#' ";
							version_active = #db.param(1)# 
							where `#db.primaryKeyField#` =#db.param(newVersionId)# ";
							if(structkeyexists(db, 'site_id')){
								db.sql&=" and site_id = '#ds.site_id#' ", 
							}
							db.execute("qUpdate");
							ds.sql="commit";
							db.execute("qCommit", ds.datasource);
							ds.sql="SET log_bin=1";
							db.execute("qSet", ds.datasource);
						}catch(Any excpt){
							rollback;
						}
						
			
			
	If each server has its own directory for data files on all other servers, then you would never have a conflicting filename during synchronization.
		i.e. /zupload/serverId/library/libraryId/imageName.jpg
			this would allow:
			/zupload/1/library/1/path.jpg
			/zupload/2/library/1/path.jpg
			
			storeFile
			
	adding a new server to the cluster
		the mysql triggers and auto_increment offset would have to be changed all at once.   
			must be verified that all servers are updated before insert new records
			
			
	API for cache clearing:
				
			
			
	
		
	passing a queue record to the second server means passing the associated files too.  All self contained in a directory (copy).
	
		cronjob interval
		manually running deploy url that compares or rsyncs the changes
		use ftp log to replay the ftp to the second server.
		write test server script to check for new local files, and then deploy them to deploy url (use multiple threads for best performance)
			dangerous since work in progress or copies get uploaded, which shouldn't.
			if all ftp files are uploaded to "deploy" folder, then the deploy url would manage replicating them to the cluster.
			this makes ftp + deploy url required instead of just ftp to see changes take effect.
				Yes, this is great
	NO - RELY ON LOCAL INSTANCE MARKING EACH RECORD INSTEAD: make sure all servers in cluster have date synchronized prior to running queue.  All the local and remote queue entries must be sorted by date.  So this allows multiple master replication, and safe crash recovery.
		run all insert/update/delete queries in a transaction if possible
		use XA replication for multiple database transaction
	queues require knowing the insert ID in advance sometimes.  We must assign it based on server id like the uuid_short to have multiple master replication.
		ah, mysql has these options to help with this:
			server-id=1
			auto-increment-offset = 1
			auto-increment-increment = 4
				This breaks when I added more instances to the cluster if I forget to update the increment option on all servers
				my trigger auto-increment emulation to allow sites to be portable between different installations doesn't have the ability to use this variable, so I need to update all the triggers to have +@@auto_increment_offset instead of +1 for this to work as expected.
				triggers are disabled on slaves when row replication is enabled, so i don't have to worry about that.
				
		one way to force all writers to be on same server is to pass that traffic through the shared domain (i.e. clientdomain.com.devsecure.com)
			any script that writes, just needs to call that url, which is bound to only 1 ip instead of the failover cluster.
			when it is down, we can mark it to failover to a friendly error page and ping it until its back up.
		
	
	$233 - 16gb 480 samsung 840 series plus 1000gb sata3
	https://portal.securedservers.com/wap-jpost3/E31230-0113-A?execution=e3s1
	
	calihop $160/month for 5 ips, 500gb (4xsamsung 840 256gb) 16gb ram - no backup drive (using raid 10 instead)
	http://www.webhostingtalk.com/showthread.php?t=1241350
	
 
	creating the second mysql instance on production linux: http://opensourcedbms.com/dbms/running-multiple-mysql-5-6-instances-on-one-server-in-centos-6rhel-6fedora/
	
Jetendo CMS: how to have one writer with multiple slaves that publish the content for reading?
	if datacenters are not in same facility, the added latency must be compensated for.
	add queue system to all database and memory changes - writer commits the change.  Reader consumes committed changes in sequence - i.e. download files before running the database changes.
		Replacing a file that already exists:
			download new files to temporary location. 
			
		if slave hasn't replicated new files and master updates/deletes one of the files, the slave won't be able to sync the file.  If it ignores the file and continues processing, it will also fail to delete the file and may only have the most recent file.  during this time, links to those files may throw 404 or 500.  It seems like replication must be operating on copies of files and not the original.  A changeset must be a separate copy from the original commited file.  The files can be given unique ids, and when the command to save them runs, it gives them the final path and name instead of the id.  This will ensure the queue can always be successful no matter how many items are queued.   A commit requires that all the data is saved to disk, then copied to a changeset and added to the queue.
		
		should there be exceptions for the mls listing table and mls_data tables?  Should these process independently on each server instead of using queue?
		we should allow some sites to not be distributed across servers - like hotstays where I can't afford to rewrite them.
		
		by relying on web service api and authentication for syncronizing data.
		commits should not be run if existing data is newer.  there should however be a log of data that wasn't accepted and a way to force it to run perhaps.
		
		writer must copy files before committing them.
	
	writer must execute the same changeset itself before returning successful update to the user.  if this is done with ajax, the wait may appear to be less.
	writer api:
		setURL
		setXML
		in the xml:
			attachFile (file with uuid on disk in commit folder)
			deleteFile
		
		
	how to update application memory for all features when they change?
	
	i could create a public web service API that is called for all updates.
	replaying api calls is fairly simple if they are always in the same format.  XML or json perhaps.
		find a reason this will not work: 
	if all data is distributed via API, then wordpress plugin is easier maybe.
		 

 --->
<cffunction name="index" access="public" localmode="modern">
	<cfscript> 
	</cfscript>
</cffunction> 
</cfoutput>
</cfcomponent>