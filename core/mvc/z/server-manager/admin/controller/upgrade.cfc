<cfcomponent>


<cffunction name="zMd5HashForAllFilesInDirectory" localmode="modern" output="no" returntype="struct" roles="serveradministrator">
	<cfargument name="path" type="string" required="yes">
	<cfargument name="rootPath" type="string" required="yes">
	<cfargument name="rootPathReplace" type="string" required="yes">
	<cfscript> 
	var ts={};
	var i=0;
	var qDir=0;
	var row=0;
	var path=0;
	directory action="list" directory=arguments.path recurse=true listinfo="path" type="file" name="qDir";
	for(row in qDir){
		result=application.zcore.functions.zMd5HashFile(row.directory&"/"&row.name);
		path=replace(row.directory&"/"&row.name, arguments.rootPath, arguments.rootPathReplace);
		if(result.success){
			ts[path]=result.hash;
		}else{
			ts[path]='hash failed';
		}
	}
	return ts;
	</cfscript>
</cffunction>


<cffunction name="zCompareMd5HashStruct" localmode="modern" output="no" returntype="struct" roles="serveradministrator">
	<cfargument name="originalMd5Struct" type="struct" required="yes">
	<cfargument name="newMd5Struct" type="struct" required="yes">
	<cfscript>
	var i=0;
	var rs={
		deleted:{},
		changed:{},
		added:{},
		changesDetected:false
	};
	for(i in arguments.newMd5Struct){
		if(not structkeyexists(arguments.originalMD5Struct, i)){
			rs.added[i]=true;
			rs.changesDetected=true;
		}
	}
	for(i in arguments.originalMD5Struct){
		if(structkeyexists(arguments.newMd5Struct, i)){
			if(compare(arguments.originalMD5Struct[i], arguments.newMd5Struct[i]) NEQ 0){
				rs.changed[i]=true;	
			rs.changesDetected=true;
			}
		}else{
			rs.deleted[i]=true;	
			rs.changesDetected=true;
		}
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getChangeStruct" localmode="modern" output="no" access="private" roles="serveradministrator">
	<cfargument name="md5StructJsonPath" type="string" required="yes">
	<cfscript>
	 var md5StructForCurrentInstall=this.zMd5HashForAllFilesInDirectory(request.zos.globals.serverhomedir&"mvc/z/server-manager/admin/", request.zos.globals.serverHomedir, '/');
	 writedump(serializeJson(md5StructForCurrentInstall));
	application.zcore.functions.zWriteFile(arguments.md5StructJsonPath, serializeJson(md5StructForCurrentInstall));
	
	// verify hashes match the current version's json file
	writedump(application.zcore.functions.zReadFile(arguments.md5StructJsonPath));
	var md5StructOriginalInstall=deserializeJson(application.zcore.functions.zReadFile(arguments.md5StructJsonPath));
	writedump(md5StructOriginalInstall); 
	// list the files that changed
	var rs=this.zCompareMd5HashStruct(md5StructOriginalInstall, md5StructForCurrentInstall);
	writedump(rs);
	abort;
	return rs;
	</cfscript>
</cffunction>


<cffunction name="confirm" localmode="modern" output="yes" access="remote" roles="serveradministrator">
	<cfscript>
	this.index();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var r=0;
	var md5Struct=0;
	var db=request.zos.queryObject;  
	
	// check server for new version, download upgrade scripts into temp directory
	// optional right now
	
	// build list of md5 hash and root relative file paths of current installation
	var changeStruct=this.getChangeStruct(request.zos.globals.serverprivatehomedir&"_cache/scripts/md5struct.json");
	
	// verify database schema matches previous version before upgrade
	
	var backupZipFilePath=request.zos.backupPath&"upgrade/changedAndDeletedFiles.zip";
	var upgradeZipFilePath=request.zos.backupPath&"upgrade/newFiles.zip";
	
	// if user proceeds with upgrade
	if(form.method EQ 'index'){
		this.showConfirmUpgradeMessage(rs, backupZipFilePath);
		application.zcore.functions.zabort();
	}
	
	// upgrade confirmed
	variables.enableMaintenanceMode();
	
	// to make rollback cleaner, we should backup entire installation into a zip, rather then only the changed files
	local.result=this.createZipFromPath(backupZipFilePath, request.zos.globals.serverhomedir);
	if(not local.result){
		throw("Failed to backup changed and deleted files");
	}
	
	for(i in changeStruct.added){
		//application.zcore.functions.zDeleteFile(i);
	}
	this.unzipToPath(newZipFilePath, request.zos.globals.serverhomedir);
	
	changeStruct=this.getChangeStruct(request.zos.backupPath&"upgrade/md5struct.json");
	
	if(changeStruct.changesDetected){
		this.restoreSourceCode();
		this.cancel();
	}else{
		writeoutput("Source code was completed and verified.");
	}
	
	// upgrade database
	rs=this.upgradeDatabase();
	if(not rs.success){
		this.restoreDatabaseAndSourceCode(); 
		this.cancel();
	}
	
	// verify database schema matches new version
	
	if(schemaChangeStruct.changesDetected){
		this.restoreDatabaseAndSourceCode();
		this.cancel();
	}
	
	
	/*
	before upgrade, 
	verify actual schema matches current version of schema
		if not matching, require user to manually correct the differences before proceeding with the upgrade.
	
	create a backup of only the tables that have changed as sql dump by using the list that is stored in the difference scripts.
			
	#rename column sql:
	RENAME TABLE table to newTableName
	ALTER TABLE `zdead`.`content2` CHANGE `content_summary` `content_summar2y` TEXT CHARSET utf8 COLLATE utf8_general_ci NOT NULL; 
	if matching version is detected:
		run all the rename operations that were manually programmed
			renameStruct={
				"schema": {
					"table": {
						renameTable: "newTableName",
						renameColumns: {
							// column order is not important
							
						}
					}
				}
			}
	
	run the automated difference based upgrade script
	
	verify schema matches new version
		if doesn't match, drop the modified tables and restore them and cancel source code upgrade.
		if valid, continue with source code upgrade
	
	*/ 
	variables.disableMaintenanceMode();
	</cfscript>
</cffunction>

<cffunction name="enableMaintenanceMode" localmode="modern" access="private" output="no" roles="serveradministrator">
	<cfscript></cfscript>
</cffunction>

<cffunction name="disableMaintenanceMode" localmode="modern" access="private" output="no" roles="serveradministrator">
	<cfscript></cfscript>
</cffunction>

<cffunction name="upgradeDatabase" localmode="modern" access="private" output="no" roles="serveradministrator">

</cffunction>

<cffunction name="restoreDatabaseAndSourceCode" localmode="modern" access="private" output="no" roles="serveradministrator">
	<cfscript>
	// restore the database from backup
	
	// restore the source code from backup
	variables.restoreSourceCode();
	</cfscript>
</cffunction>


<cffunction name="restoreSourceCode" localmode="modern" access="private" output="no" roles="serveradministrator">
	<cfscript>
	writeoutput("Source code was upgraded, but the installation failed to be verified due to the following differences.");
	writedump(changeStruct);
	
	// might want to rollback filesystem changes here
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="cancel" localmode="modern" output="yes" access="remote" roles="serveradministrator">
	<cfscript>
	</cfscript>
	<h2>Upgrade cancelled</h2>
	<p>No data was modified.</p>
</cffunction>

<cffunction name="unzipToPath" localmode="modern" access="public" roles="serveradministrator">
	<cfargument name="zipFilePath" type="string" required="yes">
	<cfargument name="destinationPath" type="string" required="yes">
	<cfzip action = "unzip" destination = "#arguments.destinationPath#" file = "#arguments.zipFilePath#"	overwrite = "yes">
	</cfzip>
</cffunction>
	
<cffunction name="showConfirmUpgradeMessage" localmode="modern" output="no" access="public" roles="serveradministrator">
	<cfargument name="changeStruct" type="struct" required="yes">
	<cfargument name="zipFilePath" type="string" required="yes">
	<cfscript>
	var arrFile=0;
	if(arguments.changeStruct.changesDetected){
		writeoutput("<p>Some files have been added, deleted or changed in the current installation which will be overwritten or deleted if you proceed  with the upgrade.  The changed and additional files will be backed up into a zip file in the upgrade directory. If you need to reapply your changes later, the zip file will located here: #arguments.zipFilePath#</p>");
		arrFile=structkeyarray(arguments.changeStruct);
		if(arrayLen(arrFile)){
			arraySort(arrFile, "text", "asc");
			writeoutput('<p>Changed Files<br /><textarea name="changedTextarea" cols="100" rows="5">'&arrFile&'</textarea></p>');
		}
		arrFile=structkeyarray(arguments.addedStruct);
		if(arrayLen(arrFile)){
			arraySort(arrFile, "text", "asc");
			writeoutput('<p>Added Files<br /><textarea name="addedTextarea" cols="100" rows="5">'&arrFile&'</textarea></p>');
		}
		arrFile=structkeyarray(arguments.deletedStruct);
		if(arrayLen(arrFile)){
			arraySort(arrFile, "text", "asc");
			writeoutput('<p>Added Files<br /><textarea name="deletededTextarea" cols="100" rows="5">'&arrFile&'</textarea></p>');
		}
	}else{
		writeoutput("<p>The current source code was verified and found to be unmodified.</p>");
	}
	writeoutput("<h2>Do you want to continue to upgrade?</h2>");
	writeoutput('<p><a href="/z/server-manager/admin/upgrade/confirm">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/server-manager/admin/upgrade/cancel">No</a></p>
	<p>CAUTION: Make sure you backup your source code and database before proceeding in case the upgrade process fails.</p>');
	
	</cfscript>
</cffunction>

<!--- 
<cfzip 
	required 
	action = "unzip" 
	destination = "destination directory" 
	file = "absolute pathname" 
	optional 
	entrypath = "full pathname" 
	filter = "file filter" 
	overwrite = "yes|no" 
	recurse = "yes|no" 
	storePath = "yes|no">  --->


<cffunction name="createZipFromPath" localmode="modern" output="no" access="public" roles="serveradministrator">
	<cfargument name="zipFilePath" type="struct" required="yes">
	<cfargument name="sourcePath" type="string" required="yes"> 
	<cfscript>
	var i=0;
	var relativePath=0;
	zip file="#arguments.zipFilePath#" action="zip"{ 
		zipparam recurse="yes" source="#arguments.sourcePath#";
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="createZipFromFileArray" localmode="modern" output="no" access="public" roles="serveradministrator">
	<cfargument name="zipFilePath" type="struct" required="yes">
	<cfargument name="rootPath" type="string" required="yes">
	<cfargument name="arrFile" type="array" required="yes">
	<cfscript>
	var i=0;
	var relativePath=0;
	zip file="#arguments.zipFilePath#" action="zip"{ 
		for(i=1;i LTE arrayLen(arguments.arrFile);i++){ 
			relativePath=replace(arguments.arrFile[i], arguments.rootPath, '');
			zipparam source="#arguments.arrFile[i]#" prefix="#relativePath#";
		}
	}
	return true;
	</cfscript>
</cffunction> 
</cfcomponent>