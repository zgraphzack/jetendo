<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var selectStruct=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8.1.3");
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	
	<form action="/z/server-manager/admin/global-import/process" method="post" enctype="multipart/form-data">
		<table style="width:100%; border-spacing:0px;" class="table-white">
			<tr>
				<td colspan="2" style="padding:10px; padding-bottom:0px;"><span class="large"><h2>Global Database Import</h2></span>
				</td>
			</tr>
			<tr>
				<td colspan="2" style="padding-left:10px;">
				<p><strong>WARNING: All existing global data will be deleted and replaced with the contents of the uploaded file.</strong> </p><p>Make sure you have made a backup of the entire Jetendo CMS database for all sites in case something goes wrong.</p></td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:140px;">Global Database Tar File:</td>
				<td class="table-white"><input type="file" name="tarFile" /> (Required | This file must be generated by a Site Backup task in the Jetendo Server Manager).
				</td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:140px;">Ignore Database Structure Errors?</td>
				<td class="table-white"><input type="checkbox" name="ignoreDBErrors" value="1" />
				</td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:140px;">&nbsp;</td>
				<td class="table-white">
				<input type="submit" name="submit1" value="Import" />
				</td>
			</tr>
		</table>
		
	</form>
</cffunction>
	
<cffunction name="process" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var dbNoVerify=request.zos.noVerifyQueryObject;
	var i=0;
	var n=0;
	var f=0;
	var cfcatch=0;
	var g=0;
	var row=0;
	var debug=false;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	setting requesttimeout="3600";
	throw("This feature is disabled until it is updated to work again.");
	
	form.ignoreDBErrors=application.zcore.functions.zso(form,'ignoreDBErrors', false, false);
	
	application.zcore.functions.zCreateDirectory(request.zos.backupDirectory&"import/");
	local.curDate=dateformat(now(), "yyyymmdd")&"-"&timeformat(now(),"HHmmss");
	local.curImportPath=request.zos.backupDirectory&"import/"&local.curDate&"/";
	local.curMYSQLImportPath=request.zos.mysqlBackupDirectory&"import/"&local.curDate&"/";
	
	// create new directories
	application.zcore.functions.zCreateDirectory(local.curImportPath);
	application.zcore.functions.zCreateDirectory(local.curImportPath&"upload/");
	application.zcore.functions.zCreateDirectory(local.curImportPath&"temp/");
	
	local.filePath=application.zcore.functions.zUploadFile("tarFile", "#local.curImportPath#upload/");
	if(local.filePath EQ false){
		application.zcore.status.setStatus(request.zsid, "The file failed to upload. Please try again", form, true);
		application.zcore.functions.zdeletedirectory(local.curImportPath);
application.zcore.functions.zRedirect("/z/server-manager/admin/global-import/index?zsid=#request.zsid#");
	}
	local.filePath="#local.curImportPath#upload/"&local.filePath;
	
	if(right(local.filePath, 7) NEQ ".tar.gz"){
		application.zcore.status.setStatus(request.zsid, "The file must end with .tar.  Only files generated by the site backup task are compatible with site import.  Don't try to package your own backup file.", form, true);
		application.zcore.functions.zdeletedirectory(local.curImportPath);
		application.zcore.functions.zRedirect("/z/server-manager/admin/global-import/index?zsid=#request.zsid#");
	}
	// isTarred=application.zcore.functions.zTarZipFilePath("myTarball.tar.gz", "/var/jetendo-server/jetendo/sites/", "/var/jetendo-server/jetendo/sites/basicdemo_farbeyondcode_com/", 20);
	//('/bin/bash', " -c 'cd #local.curImportPath#temp/; /bin/tar xvfz #local.filePath#' ", 3600);
	
	
	// process database restore
	local.restoreData=application.zcore.functions.zreadfile(local.curImportPath&"temp/restore-global-database.sql");
	local.arrRestore=listToArray(replace(local.restoreData, "/ZIMPORTPATH/", local.curMYSQLImportPath&"temp/", "ALL"), chr(10));
	// verify column list is compatible with current database structure before deleting
	directory action="list" directory="#local.curImportPath#temp/database-schema/" name="local.qDir" recurse="yes";
	local.arrError=[];
	
	local.skipDBStruct={};
	local.fixDBStruct={};
	
	local.dsStruct={};
	for(row in local.qDir){
		if(right(row.name, 5) EQ ".json"){
			local.dsStruct[left(row.name, len(row.name)-5)]=[];
			local.curStructure=deserializeJson(application.zcore.functions.zreadfile(row.directory&"/"&row.name));
			for(n in local.curStructure.fieldStruct){
				local.arrTable=listtoarray(replace(n, "`","", "all"), ".");
				if(form.ignoreDBErrors){
					// determine which columns be removed from the query and insert them into a struct
					dbNoVerify.sql="show fields from #dbNoVerify.table(local.arrTable[2], local.arrTable[1])#";
					try{
						local.qFields=dbNoVerify.execute("qFields");
					}catch(Any local.e){
						local.skipDBStruct[n]=true;
						continue;
					}
					local.fixDBStruct[n]={};
					for(local.row2 in local.qFields){
						local.found=false;
						for(g in local.curStructure.fieldStruct[n]){
							if(local.row2.field EQ g){
								local.found=true;
							}
						}
						if(not local.found){
							local.fixDBStruct[n]["`"&g&"`"]="@dummy";
						}
					}
					// loop the new struct when running the load data infile statements.  Will have to match the `db`.`table` first, then replace `#field#` with @dummy
				}else{
					local.columnList="`"&structkeylist(local.curStructure.fieldStruct[n], "`, `")&"`";
					db.sql="select #local.columnList# from #db.table(local.arrTable[2], local.arrTable[1])# ";
					if(structkeyexists(local.curStructure.fieldStruct[n], "site_id")){
						db.sql&=" where site_id = #db.param(-1)#";
					}
					db.sql&=" LIMIT #db.param(0)#, #db.param(1)#";
					try{
						db.execute("qCheck");
					}catch(Any local.e){
						arrayAppend(local.arrError, "Database structure exception when verifying #n#: "&local.e.message);
					}
				}
			}
		}
	}
	if(arraylen(local.arrError)){
		application.zcore.status.setStatus(request.zsid, arrayToList(local.arrError, "<br />")&"<br /><br />There are a few ways to correct these errors and re-import:<br />A) Create the missing column(s) or table(s) in the database.<br />B) Import again with ""ignore database structure errors"" and the missing column data will not be imported.<br />C) Manually update the restore-global-database.sql file in the tar file, re-tar and re-import the file.", form, true);
		application.zcore.functions.zdeletedirectory(local.curImportPath);
		application.zcore.functions.zRedirect("/z/server-manager/admin/global-import/index?zsid=#request.zsid#");
	}
	for(i=1;i LTE arrayLen(local.arrRestore);i++){
		local.skipTable=false;
		for(f in local.skipDBStruct){
			n="`"&replace(replace(f, "`","", "all"), ".", "`.`")&"`";
			if(local.arrRestore[i] CONTAINS n){
				local.skipTable=true;
				break;
			}
		}
		if(local.skipTable){
			continue;
		}
		for(f in local.fixDBStruct){
			n="`"&replace(replace(f, "`","", "all"), ".", "`.`")&"`";
			if(local.arrRestore[i] CONTAINS n){
				for(g IN local.fixDBStruct[f]){
					local.arrRestore[i]=replace(local.arrRestore[i], g, "@dummy");
				}
				break;
			}
		}
		local.curDatasource="";
		for(n in local.dsStruct){
			if(local.arrRestore[i] CONTAINS "`"&n&"`."){
				local.curDatasource=n;
				break;
			}
		}
		if(local.curDatasource EQ ""){
			application.zcore.status.setStatus(request.zsid, "Datasource in query didn't match a datasource on this installation.  You must create a matching datasource name or manually update the restore-site-database.sql file in the tar file and re-tar and re-import the file. - SQL: #local.arrRestore[i]#", form, true);
			application.zcore.functions.zdeletedirectory(local.curImportPath);
			application.zcore.functions.zRedirect("/z/server-manager/admin/global-import/index?zsid=#request.zsid#");
		}
		arrayAppend(local.dsStruct[local.curDatasource], local.arrRestore[i]);
	}
	// all validation is done, do the actual changes now
	for(n in local.dsStruct){
		// manually set datasource because the set variable queries don't use tables
		local.c=application.zcore.db.getConfig();
		local.c.autoReset=false;
		local.c.datasource=n;
		local.c.verifyQueriesEnabled=false;
		dbNoVerify=application.zcore.db.newQuery(local.c);
		dbNoVerify.sql="set @zDisableTriggers=1";
		dbNoVerify.execute("qDisableTrigger");
		for(i=1;i LTE arrayLen(local.dsStruct[n]);i++){
			dbNoVerify.sql=local.dsStruct[n][i];
			if(debug) writeoutput(dbNoVerify.sql&"<br />");
			dbNoVerify.execute("qLoad");
		}
		dbNoVerify.sql="set @zDisableTriggers=NULL";
		dbNoVerify.execute("qEnableTrigger");
	}
	
	application.zcore.functions.zdeletedirectory(local.curImportPath);
	
	if(debug){
		writeoutput('Global import complete.  You should run "zreset=all" to clear out the cache for all sites now.');
	}else{
		application.zcore.status.setStatus(request.zsid, 'Global import complete.  You should run "zreset=all" to clear out the cache for all sites now.');
		application.zcore.functions.zRedirect("/z/server-manager/admin/global-import/index?zsid=#request.zsid#");
	}
	 </cfscript>
</cffunction>
</cfoutput>
	<!--- 
site-backup.cfm notes:
	// all existing table relationships in the exact order they should be exported.
	a1=arraynew(1);
	arrayappend(a1, {source="database.table.table_id", destination:"database2.table2.table_id"});
	/backup-database-test.cfm
	
	import new id for all rows so that all primary keys are available.   then go back and update the foreign keys within the table.
	all the tables with multi-field primary key must be inserted after the others are done.
	
	must retain compatibility with old export versions.   If it was stored as insert statement, it would be harder to modify.  I need to be using array objects that can be filtered later by a script that will upgrade them to the new version.
		i.e.
		fs["database.table"]=["field1","field2","etc"];
		// put all table structures in a single the export file name table-index.tsv
		#table-export-id	datasource-variable-name	table-name	field-name	field-name2	etc
		1	"zcoreDatasource"	"table"	"field1"	"field2"	"etc"
		
		// put each table in a separate table-name.tsv
		"data1"	"data2"	"etc"
		
		
	TODO: more thorough db structure verification and ALTER SQL generation
		
	show databases
	
	SHOW TABLES IN `zcore`
	
	SHOW TABLE STATUS FROM `zcore` WHERE ENGINE IS NOT NULL; 
	SELECT CCSA.character_set_name FROM information_schema.`TABLES` T, information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` CCSA WHERE CCSA.collation_name = T.table_collation  AND T.table_schema = "zcore"  AND T.table_name = "site";
	#table struct
	tableStruct=structnew();
	tableStruct["zcoreDatasource"]=structnew();
	tableStruct["zcoreDatasource"]["tablename"]={engine="",version="",create_options="",collation="",charset=""};
	
	
	show FIELDS from #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# 
	#table field struct:
	fieldStruct["zcoreDatasource.name"]=structnew();
	fieldStruct["zcoreDatasource.name"]["fieldname"]={type="",null="",key="", default="",extra=""};
	
	show KEYS from #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site
	#keys struct
	keyStruct["zcoreDatasource.name"]=structnew();
	keyStruct["zcoreDatasource.name"]["keyname"]={non_unique="",key_name="",seq_in_index="",column_name="",index_type=""};
	
	non_unique=1 is NOT UNIQUE
	non_unique=0 is UNIQUE
	
	uniqueStruct=structnew();
	// tableStruct2 is the NEW structure
	for(i in tableStruct){
		for(n in tableStruct[i]){
			if(structkeyexists(tableStruct2, n) and structkeyexists(tableStruct2, i)){
				uniqueStruct[n&"."&i]=true;
				if(tableStruct[i][n].engine NEQ tableStruct2[i][n].engine){
					// add alter engine sql
				}
				if(tableStruct[i][n].version NEQ tableStruct2[i][n].version){
					// not sure about this one
				}
				if(tableStruct[i][n].create_options NEQ tableStruct2[i][n].create_options){
					// can this be altered?
				}
				if(tableStruct[i][n].collation NEQ tableStruct2[i][n].collation){
					// add alter collation sql
					// CONVERT TO CHARACTER SET `#tableStruct2[i][n].charset#` COLLATE `#tableStruct2[i][n].collation#
				}
			}
		}
	}
	for(i in tableStruct2){
		for(n in tableStruct2[i]){
			if(structkeyexists(uniqueStruct, n&"."&i) EQ false){
				// must create table from scratch
				tableStruct2[i][n];
			}
		}
	}
	
	SHOW CREATE TABLE #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site;
 --->
 </cfcomponent>