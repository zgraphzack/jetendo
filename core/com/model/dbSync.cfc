<cfcomponent>
<!--- 
TODO: this is meant to be the scheduled task for multiple master replication
executeClearCache() is not fully implemented
this code hasn't been executed yet at all.
needs to be integrated with component cache, onApplicationStart, and code cache clearing
versionSyncTableStruct is incomplete and the fileFieldStruct functions are not using real code to generate the file path yet.
 --->
<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	/*
	
	*/
	</cfscript>
</cffunction>


<!--- onApplicationStart new code --->
<cffunction name="onApplicationStart" localmode="modern">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db2=request.zos.noVerifyQueryObject;
	db2.sql="SELECT @@server_id AS id, @@auto_increment_offset as offset, @@auto_increment_increment as increment";
	qServer=db2.execute("qServer");

	arguments.sharedStruct.currentServerID=qServer.id;
	arguments.sharedStruct.currentServerStruct=request.zos.serverStruct[arguments.sharedStruct.currentServerID];
	arguments.sharedStruct.databaseIncrementOffset=qServer.offset;
	arguments.sharedStruct.databaseIncrementIncrement=qServer.increment;



	defaultServerStruct={
        apiURL:"",
        serverId:"",
        datasource:"",
        databaseIncrementOffset:""
	};
	for(i in request.zos.serverStruct){
		c=request.zos.serverStruct[i];
		structappend(c, defaultServerStruct, false);
	}
	for(i in request.zos.serverStruct){
		c=request.zos.serverStruct[i];
		for(n in request.zos.serverStruct){
			g=request.zos.serverStruct[n];
			if(n EQ i){
				continue;
			}
			for(f in g){
				if(g[f] EQ c[f]){
					throw("#f# is set to ""#g[f]#"" on more then one server record. Each server record in request.zos.serverStruct must have a unique value from the other servers.");
				}
			}
		}
	}
	if(structcount(request.zos.serverStruct) NEQ qServer.increment){
		throw('Database variable, auto_increment_increment (#qServer.increment#), doesn''t equal the number of servers in request.zos.serverStruct (#structcount(request.zos.serverStruct)#). You must correct this.');
	}
	if(arguments.sharedStruct.currentServerStruct.databaseIncrementOffset NEQ qServer.offset){
		throw('Database variable, auto_increment_offset (#qServer.offset#), doesn''t equal the value for the current server in request.zos.serverStruct (#arguments.sharedStruct.currentServerStruct.databaseIncrementOffset#).  You must correct this.');

	}

	versionSyncTableStruct={
		"jetendo":{
			"content":{
				primaryKey:"content_id",
				dateField:"content_updated_datetime",
				hasSiteId: true
			},
			"blog":{
				primaryKey:"blog_id",
				dateField:"blog_updated_datetime",
				hasSiteId: true
			},
			"image":{
				primaryKey:"image_id",
				dateField:"image_datetime",
				hasSiteId: true,
				fileFieldStruct:{
					"image_file":function(row){
						return "/path/to/"&arguments.row.image_file;
					},
					"image_intermediate_file":function(row){
						return "/path/to/"&arguments.row.image_file;
					}
				}
			}
			/*
			need to have all tables here, so I can manually handle mysql replication
			*/
		}
	};
	idGenerationStruct={};
	for(schema in versionSyncTableStruct){
		tableStruct=versionSyncTableStruct[schema];
		idGenerationStruct[schema]={};
		for(table in tableStruct){
			idGenerationStruct[schema][table]={};
			c=tableStruct[table];
			if(c.hasSiteId){
				db.sql="select max(a.`#application.zcore.functions.zescape(c.primaryKey)#`) maxId, a.site_id
				from #db.table(table, schema)# a 
				group by a.site_id ";
			}else{
				db.sql="select max(a.#c.primaryKey#) maxId 
				from #db.table(table, schema)# ";
			}
			qId=db.execute("qId");
			for(row in qId){
				nextId=(row.maxId - (row.maxId MOD arguments.sharedStruct.databaseIncrementIncrement))+arguments.sharedStruct.databaseIncrementIncrement+(arguments.sharedStruct.databaseIncrementOffset-1);
				if(c.hasSiteId){
					idGenerationStruct[schema][table][row.site_id]=nextId;
				}else{
					idGenerationStruct[schema][table]=nextId;
				}
			}
		}
	}

	arguments.sharedStruct.serverStruct=serverStruct;
	arguments.sharedStruct.versionSyncTableStruct=versionSyncTableStruct;
	arguments.sharedStruct.idGenerationStruct=idGenerationStruct;
	</cfscript>
</cffunction>

<cffunction name="executeInsert" access="private" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="fieldStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	n=arguments.struct;
	savecontent variable="db.sql"{
		echo("INSERT INTO #db.table(n.table, n.schema)# SET ");
		first=true;
		for(i in arguments.fieldStruct){
			if(!first){
				first=false;
				echo(", "&chr(10));
			}
			echo('`#application.zcore.functions.escape(i)#`=#db.param(n.struct[i])# ');
		}
	}
	qInsert=db.execute("qInsert");
	</cfscript>
</cffunction>


<cffunction name="executeReplace" access="private" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="fieldStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	n=arguments.struct;
	savecontent variable="db.sql"{
		echo("REPLACE INTO #db.table(n.table, n.schema)# SET ");
		first=true;
		for(i in arguments.fieldStruct){
			if(!first){
				first=false;
				echo(", "&chr(10));
			}
			echo('`#application.zcore.functions.escape(i)#`=#db.param(n.struct[i])# ');
		}
	}
	qReplace=db.execute("qReplace");
	</cfscript>
</cffunction>

<cffunction name="executeUpdate" access="private" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="fieldStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	n=arguments.struct;
	savecontent variable="db.sql"{
		echo("UPDATE #db.table(n.table, n.schema)# SET ");
		first=true;
		for(i in arguments.fieldStruct){
			if(structkeyexists(n.whereStruct, i)){
				continue;
			}
			if(!first){
				first=false;
				echo(", "&chr(10));
			}
			echo('`#application.zcore.functions.escape(i)#`=#db.param(n.struct[i])# ');
		}
		echo("WHERE ");
		first=true;
		for(i in n.whereStruct){
			if(!first){
				first=false;
				echo(" and "&chr(10));
			}
			echo('`#application.zcore.functions.escape(i)#`=#db.param(n.whereStruct[i])# ');
		}
	}
	qUpdate=db.execute("qUpdate");
	</cfscript>
</cffunction>

<cffunction name="executeDelete" access="private" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	n=arguments.struct;
	savecontent variable="db.sql"{
		echo("DELETE FROM #db.table(n.table, n.schema)# WHERE ");
		first=true;
		for(i in n.whereStruct){
			if(!first){
				first=false;
				echo(" and "&chr(10));
			}
			echo('`#application.zcore.functions.escape(i)#`=#db.param(n.whereStruct[i])# ');
		}
	}
	qDelete=db.execute("qDelete");
	</cfscript>
</cffunction>


<cffunction name="executeClearCache" localmode="modern" access="private">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	if(arguments.struct.type EQ "site"){
		// republish site globals
		// run onSiteStart()
	}else if(arguments.struct.type EQ "app"){
		// run onApplicationStart()
	}
	</cfscript>
</cffunction>

<cffunction name="sync" localmode="modern" access="public">
	<cfscript>
	db.sql="select * from #db.table("sync", request.zos.zcoreDatasource)# 
	where sync_type = #db.param('version')# and 
	server_id = #db.param(request.zos.server_id)# ";
	qService=db.execute("qService");
	syncMysqlDate=dateformat(qService.sync_start_datetime, 'yyyy-mm-dd')&' '&timeformat(qService.sync_start_datetime, 'HH:mm:ss');
	stopSync=false;
	arrFileDownloaded=[];
	arrFileDeleted=[];
	fileRenameStruct={};
	newFileStruct={};

	// need to merge and sort the version records BEFORE running them.
	rowStruct={};
	rowLimit=5; 
	for(i in request.zos.serverStruct){
		currentServer=request.zos.serverStruct[i];
		if(i EQ application.zcore.currentServerID){
			continue;
		}
		if(currentServer.notAvailable){
			continue;
		}
		db.sql="select * from #db.table("version", currentServer.datasource)# where 
		version_datetime >= #db.param(syncMysqlDate)# and 
		server_id <> #db.param(application.zcore.currentServerID)# 
		order by version_datetime asc 
		LIMIT #db.param(0)#, #db.param(rowLimit)#";
		qVersion=db.execute("qVersion");
		for(row in qVersion){
			rowStruct[row.version_id]={
				datetime:dateformat(row.version_datetime,"yyyymmdd")&timeformat(row.version_datetime, "HHmmss"),
				data: row 
			};
		}
	}
	arrRow=structsort(rowStruct, "numeric", "asc", "datetime");
	// we can only do up to rowLimit records at once because one of the servers may be further behind then the others, and we want to guarantee only newer records are inserted.
	limit=min(arrayLen(arrRow), rowLimit);
	for(i=1;limit;i++){
		try{
			row=rowStruct[arrRow[i]];
			ss=deserializeJSON(row.version_json_data);
			for(i=1;i<=arraylen(ss.arrFileArchive);i++){
				currentFile=ss.arrFileArchive[i];
				if(fileexists(currentFile.originalPath)){
					variables.fileRenameStruct[currentFile]=newPath;
					application.zcore.functions.zRenameFile(currentFile.originalPath, currentFile.newPath);
				}
			}
			for(i=1;i<=arraylen(ss.arrFileChange);i++){
				result=pullFile(currentServer.server_id, ss.arrFileChange[i]);
				if(result){
					newFileStruct[ss.arrFileChange[i]]=true;
				}
			}
			try{
				transaction action="begin"{
					for(i=1;i<=arraylen(ss.arrChange);i++){
						n=ss.arrChange[i];
						/*
						// we could choose to ignore updates that are for an older datetime maybe in the future
						if((n.type EQ "update" or n.type EQ "replace") and structkeyexists(tableStruct, 'dateField')){
							tableStruct=application.zcore.versionSyncTableStruct[n.data.struct.schema][n.data.struct.table];
							if(tableStruct.hasSiteId){
								if(arguments.type EQ "delete" or arguments.type EQ "update"){
									sid=n.data.whereStruct["site_id"];
								}else{
									sid=n.data.struct["site_id"];
								}
							}else{
								sid="";
							}
							originalData=application.zcore.functions.zGetDataById(n.type, n.data.struct.schema, n.data.struct.table, tableStruct.primaryKey, n.data.struct[tableStruct.primaryKey], sid);
							if(n.data.struct[tableStruct.dateField] LTE originalData[tableStruct.dateField]){
								// skip this update, because a newer update has already executed on the same record.
								continue;
							}
						}*/
						fieldStruct=application.zcore.tableColumns[n.data.struct.schema&"."&n.data.struct.table];
						if(n.type EQ "insert"){
							executeInsert(n.data, fieldStruct);
						}else if(n.type EQ "update"){
							executeUpdate(n.data, fieldStruct);
						}else if(n.type EQ "replace"){
							executeReplace(n.data, fieldStruct);
						}else if(n.type EQ "delete"){
							executeDelete(n.data);
						}
					}
					transaction action="commit";
				}
			}catch(Any e2){
				// transaction failed.
				try{
					transaction action="rollback";
				}catch(Any e3){
					// ignore rollback failures
				}
				rethrow;
			}
			for(i=1;i<=arraylen(ss.arrClearCache);i++){
				executeClearCache(ss.arrClearCache[i]);
			}
			syncMysqlDate=dateformat(row.version_datetime, 'yyyy-mm-dd')&' '&timeformat(row.version_datetime, 'HH:mm:ss');
			db.sql="update #db.table("sync", request.zos.zcoreDatasource)# set
			sync_start_datetime=#db.param(syncMysqlDate)# 
			where sync_id = #db.param(qService.sync_id)# and
			server_id = #db.param(request.zos.server_id)#";
			db.execute("qUpdate");
		}catch(Any e){
			stopSync=true;
			for(i in newFileStruct){
				application.zcore.functions.zDeleteFile(i);
			}
			for(i in fileRenameStruct){
				application.zcore.functions.zRenameFile(fileRenameStruct[i], i);
			}
			rethrow;
		}
	}
	</cfscript>
</cffunction>

<cffunction name="pullFile" localmode="modern" access="private" returntype="boolean">
	<cfargument name="server_id" type="numeric" required="yes">
	<cfargument name="absoluteFilePath" type="numeric" required="yes">
	<cfscript>
	link=request.zos.serverStruct[arguments.serverId].apiURL&"sync/downloadFile?path="&urlencodedformat(arguments.absoluteFilePath);
	result=application.zcore.functions.zHTTPToFile(link, arguments.absoluteFilePath);
	if(not result){
		throw('pullFile(#arguments.server_id#, "#arguments.absoluteFilePath#") failed.');
	}
	return true;
	</cfscript>
</cffunction>


<!--- 


TODO: multiple master - still requires MLS data to be downloaded on just 1 server at a time.

If sync fails, the server must remove itself from the live cluster until corrected.
			If the cluster has only 1 server left, it can't remove itself.

Each server would check each other to see who is in control of the MLS data (or some other singleton state) and if none are actively doing it, it would register itself.
Then it would check again that the other servers agree with the change.

when a server starts, before it can process live requests, it would need to check the other servers that its state is still valid and update itself before running all the requests.
	i.e. If the server previously ran the MLS update VM, and a new server is now running it, then it would need to not start it's VM.
	the other servers could be queried to determine if the site configuration had changed (not just the data)
		if it changed, then it must wait until mysql replication catches up and the change is now in effect.
		the server would just need to wait in this case.

		
	code to run a mysql transaction on a datasource conneciton manually without cftransaction
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
			
	adding a new server to the cluster
		the mysql triggers and auto_increment offset would have to be changed all at once.   
			must be verified that all servers are updated before insert new records

		run all insert/update/delete queries in a transaction if possible
		use XA replication for multiple database transaction

		table with site_id triggers, need the new complex version of auto_increment_offset code instead of +1 for this to work as expected.

 
	multiple mysql instance on production linux: http://opensourcedbms.com/dbms/running-multiple-mysql-5-6-instances-on-one-server-in-centos-6rhel-6fedora/
		used for making some sites NOT run in sync cluster - hotstays.com, etc.

		  --->
</cfcomponent>