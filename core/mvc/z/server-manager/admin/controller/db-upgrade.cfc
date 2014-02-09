<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	variables.siteBackupCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.site-backup");
	variables.outfileOptions="FIELDS TERMINATED BY '\t' ENCLOSED BY '""' ESCAPED BY '\\' LINES TERMINATED BY '\n' ";
	variables.curBackupDate=dateformat(now(), 'yyyymmdd')&timeformat(now(),'HHmmss');
	variables.databaseBackupPath="#request.zos.backupDirectory#upgrade/databaseBackup#variables.curBackupDate#/";
	variables.mysqlDatabaseBackupPath="#request.zos.mysqlBackupDirectory#upgrade/databaseBackup#variables.curBackupDate#/";
	//variables.tableVersionStruct=getTableVersionStruct();
	</cfscript>
</cffunction>


<cffunction name="checkVersion" localmode="modern" access="public">
	<cfscript>
	try{
		query name="qCheck" datasource="#request.zos.zcoreDatasource#"{
			echo("SHOW TABLES IN `#request.zos.zcoreDatasource#` LIKE 'jetendo_setup'");
		}
	}catch(Any e){
		throw("request.zos.zcoreDatasource, ""#request.zos.zcoreDatasource#"", must be a valid datasource.");
	}
	tempFile=request.zos.sharedPath&"database/jetendo-schema.json";
	tempFile2=request.zos.sharedPath&"database/jetendo-schema-current.json";
	if(not fileexists(tempFile2)){
		application.zcore.functions.zcopyfile(tempFile, tempFile2, true);
	}
	currentVersion=0;
	if(qCheck.recordcount NEQ 0){
		query name="qVersion" datasource="#request.zos.zcoreDatasource#"{
			echo("SELECT * FROM jetendo_setup LIMIT 0,1");
		}
		if(qVersion.recordcount EQ 0){
			query name="qInsert" datasource="#request.zos.zcoreDatasource#"{
				echo("INSERT INTO jetendo_setup SET jetendo_setup_database_version = '#request.zos.databaseVersion#' ");
			}
			currentVersion=request.zos.databaseVersion;
			if(not structkeyexists(application, request.zos.installPath&":dbUpgradeCheckVersion")){
				return true;
			}
		}else{
			if(qVersion.jetendo_setup_database_version EQ request.zos.databaseVersion){
				if(not structkeyexists(application, request.zos.installPath&":dbUpgradeCheckVersion")){
					return true;
				}
			}else if(qVersion.jetendo_setup_database_version GT request.zos.databaseVersion){
				throw("Jetendo database is a newer version then request.zos.databaseVersion.  Please check that source code version is the same or newer then database.");
			}
			currentVersion=qVersion.jetendo_setup_database_version;
		}
	}
	setting requesttimeout="500";
	application[request.zos.installPath&":dbUpgradeCheckVersion"]=true;

	// verify the rest of the config.cfc values before installing database & application.
	renameStruct={};
	if(currentVersion EQ 0){
		installInitialDatabase();
		application.zcore.functions.zcopyfile(tempFile, tempFile2, true);
		query name="qInsert" datasource="#request.zos.zcoreDatasource#"{
			echo("INSERT INTO jetendo_setup SET jetendo_setup_database_version = '#request.zos.databaseVersion#' ");
		}
		application[request.zos.installPath&":displaySetupScreen"]=true;
	}else{
		if(not request.zos.isTestServer){
			return true; // ignore upgrades for now.
		}
		init();
		curDSStruct={};
		// verify integrity of currentVersion to ensure upgrade will be successfull
		curDSStruct=application.zcore.functions.zGetDatabaseStructure(request.zos.zcoreDatasource, curDSStruct);
		schemaStruct=variables.siteBackupCom.generateSchemaBackup(request.zos.zcoreDatasource, curDSStruct); 
		newDsStruct=deserializeJson(application.zcore.functions.zreadfile(tempFile2));
		
		existingDsStruct=schemaStruct.struct; 
		verifyStruct=runDatabaseUpgrade(request.zos.zcoreDatasource, renameStruct, existingDsStruct, newDsStruct, true);
		if(not verifyStruct.success){
			writeoutput('Upgrade aborted. The current database schema doesn''t match the installed version defined in #tempFile2#. 
				The following differences were detected and 
				they must be manually fixed before running the upgrade process again.');
			writedump(verifyStruct.arrDiff);
			return false;
		}
		backupStruct=backupAffectedTablesInVersionRange(currentVersion+1, request.zos.databaseVersion);

		for(i=currentVersion+1;i LTE request.zos.databaseVersion;i++){
			if(not fileexists(request.zos.installPath&"core/com/model/upgrade/db-"&i&".cfc")){
				throw("No database upgrade CFC exists for version, #i#, in "&request.zos.installPath&"core/com/model/upgrade/");
			} 
			upgradeCom=createobject("component", "zcorerootmapping.com.model.upgrade.db-"&i);
			result=upgradeCom.executeUpgrade(this);
			if(not result){
				echo("Upgrade aborted.");
				restoreTables(backupStruct);
				return false;
			}else{
				echo('Upgrade scripts completed successfully for version: #i#.<br />');
			}
		}
		curDSStruct=application.zcore.functions.zGetDatabaseStructure(request.zos.zcoreDatasource, curDSStruct);
		schemaStruct=variables.siteBackupCom.generateSchemaBackup(request.zos.zcoreDatasource, curDSStruct); 
		tempFile=request.zos.sharedPath&"database/jetendo-schema.json";
		newDsStruct=deserializeJson(application.zcore.functions.zreadfile(tempFile));
		existingDsStruct=schemaStruct.struct; 
		verifyStruct=runDatabaseUpgrade(request.zos.zcoreDatasource, renameStruct, existingDsStruct, newDsStruct, true);
		if(not verifyStruct.success){
			writeoutput('Database schema validation failed post-upgrade. The upgrade scripts may be broken. 
				The following differences were detected:<br />');
			writedump(verifyStruct.arrDiff);
			restoreTables(backupStruct);
			return false;
		}

		writeoutput('Database upgraded successfully');

		query name="qUpdate" datasource="#request.zos.zcoreDatasource#"{
			echo("UPDATE jetendo_setup SET jetendo_setup_database_version = '#arguments.version#' ");
		}
		application.zcore.functions.zcopyfile(tempFile, tempFile2, true);
		echo("Upgrade complete.");
		application.zcore.functions.zabort();
	}
	</cfscript>
</cffunction>


<cffunction name="executeQuery" localmode="modern" access="public" returntype="boolean">
	<cfargument name="sql" type="string" required="yes">
	<cfargument name="datasource" type="string" required="yes">
	<cfscript>
	db=request.zos.noVerifyQueryObject;
	db.sql=arguments.sql;
	try{
		result=db.execute("qExecute", arguments.datasource);
	}catch(Any e){
		echo("Failed to execute query against datasource: "&arguments.datasource&"<br />sql;<br />"&arguments.sql&";<br /><br />");
		writedump(e);
		result=false;
	}
	if(not result){
		return false;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="tableExistsInDatabase" localmode="modern" access="public" returntype="boolean">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfscript>
	db=request.zos.noVerifyQueryObject;
	db.sql="SHOW TABLES IN `#arguments.schema#` LIKE '#arguments.table#'";
	qTable=db.execute("qTable", arguments.schema);
	if(qTable.recordcount EQ 0){
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<cffunction name="backupAffectedTablesInVersionRange" localmode="modern" access="public" returntype="struct">
	<cfargument name="startVersion" type="numeric" required="yes">
	<cfargument name="endVersion" type="numeric" required="yes">
	<cfscript>
	i=0; 
	backupStruct={};

	for(n=arguments.startVersion;n LTE arguments.endVersion;n++){
		if(not fileexists(request.zos.installPath&"core/com/model/upgrade/db-"&n&".cfc")){
			throw("No database upgrade CFC exists for version, #n#, in "&request.zos.installPath&"core/com/model/upgrade/");
		}
		upgradeCom=createobject("component", "zcorerootmapping.com.model.upgrade.db-"&n);
		arrChanged=upgradeCom.getChangedTableArray();

		for(i=1;i LTE arrayLen(arrChanged);i++){
			if(not structkeyexists(backupStruct, arrChanged[i].schema)){
				backupStruct[arrChanged[i].schema]={};
			}
			if(tableExistsInDatabase(arrChanged[i].schema, arrChanged[i].table)){
				backupTable(arrChanged[i].schema, arrChanged[i].table);
				backupStruct[arrChanged[i].schema][arrChanged[i].table]=true;
			}else{
				backupStruct[arrChanged[i].schema][arrChanged[i].table]=false;
			}
		}
	}
	return backupStruct;
	</cfscript>
</cffunction>


<cffunction name="backupTable" localmode="modern" access="public" returntype="boolean">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfscript>
	echo('Backing up table: #arguments.schema#.#arguments.table#<br />');
	backupPath=request.zos.sharedPath&"database/backup/";
	application.zcore.functions.zcreatedirectory(backupPath);
	try{
		result=application.zcore.functions.zSecureCommand("mysqlDumpTable#chr(9)##arguments.schema##chr(9)##arguments.table#", 200);
	}catch(Any e){
		savecontent variable="output"{
			echo('Failed to backup table: #arguments.schema#.#arguments.table# | 
				zSecureCommand timed out or failed: mysqlDumpTable#chr(9)##arguments.schema##chr(9)##arguments.table#<br />');
			writedump(e);
		}
		throw(output); // prevent further execution
	}
	if(result NEQ "1"){
		throw('Failed to backup table: #arguments.schema#.#arguments.table# | 
			zSecureCommand failed: mysqlDumpTable#chr(9)##arguments.schema##chr(9)##arguments.table#<br />');
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="restoreTable" localmode="modern" access="public" returntype="boolean">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfscript>
	echo('Restoring table: #arguments.schema#.#arguments.table#<br />');
	try{
		result=application.zcore.functions.zSecureCommand("mysqlRestoreTable#chr(9)##arguments.schema##chr(9)##arguments.table#", 200);
	}catch(Any e){
		echo('Failed to restore table: #arguments.schema#.#arguments.table# | 
			zSecureCommand timed out or failed: mysqlRestoreTable#chr(9)##arguments.schema##chr(9)##arguments.table#<br />');
		writedump(e);
		return false;
	}
	if(result EQ "0"){
		echo('Failed to restore table: #arguments.schema#.#arguments.table# | 
			zSecureCommand failed: mysqlRestoreTable#chr(9)##arguments.schema##chr(9)##arguments.table#<br />');
		return false;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="restoreTables" localmode="modern" access="public" returntype="boolean">
	<cfargument name="backupStruct" type="struct" required="yes">
	<cfscript>
	success=true;
	for(schema in arguments.backupStruct){
		for(table in arguments.backupStruct[schema]){
			tableExists=arguments.backupStruct[schema][table];
			if(tableExists){
				try{
					result=restoreTable(schema, table);
				}catch(Any e){
					result=false;
					echo('Failed to restore: #arguments.schema#.#arguments.table#<br />');
					writedump(e);
				}
				if(not result){
					success=false;
				}else{
					echo('Restored: #arguments.schema#.#arguments.table#<br />');
				}
			}else{
				db=request.zos.noVerifyQueryObject;
				db.sql="DROP TABLE #db.table(arguments.table, arguments.schema)# ";
				db.execute("qDrop", arguments.schema);
				echo('Restoration dropped table that didn''t exist previously: #arguments.schema#.#arguments.table#<br />');
			}
		}
	}
	if(success){
		echo('<h3>Database restored successfully.</h3>');
	}
	return success;
	</cfscript>
</cffunction>




<cffunction name="importTableData" localmode="modern">
	<cfargument name="filePath" type="string" required="yes">
	<cfargument name="datasource" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfargument name="columnList" type="string" required="yes">
	<cfargument name="hasSiteId" type="boolean" required="yes">
	<cfscript>
	if(not fileexists(arguments.filePath)){
		throw("importTableData failed because arguments.filePath, ""#arguments.filePath#"", doesn't exist.");
	}
	if(arguments.hasSiteId){
		query name="qDelete" datasource="#arguments.datasource#"{
			echo(preserveSingleQuotes("delete from `#arguments.datasource#`.`#request.zos.zcoredatasourceprefix##arguments.table#` 
			where site_id = 0"));
		}
		query name="qDisableTrigger" datasource="#arguments.datasource#"{
			echo(preserveSingleQuotes("set @zDisableTriggers=1"));
		}
	}else{
		query name="qTruncate" datasource="#arguments.datasource#"{
			echo("truncate table `#arguments.datasource#`.`#request.zos.zcoredatasourceprefix##arguments.table#`");
		}
	}

	query name="qLoadData" datasource="#arguments.datasource#"{
		echo(preserveSingleQuotes("LOAD DATA INFILE '#escape(arguments.filePath)#' 
		REPLACE INTO TABLE `#arguments.datasource#`.`#request.zos.zcoredatasourceprefix##arguments.table#` 
		FIELDS TERMINATED BY ',' ENCLOSED BY '""' 
	 	ESCAPED BY '\\' LINES TERMINATED BY '\n' STARTING BY ''
		IGNORE 1 LINES (#arguments.columnList#)"));
	}
	if(arguments.hasSiteId){
		query name="qEnableTrigger" datasource="#arguments.datasource#"{
			echo(preserveSingleQuotes("set @zDisableTriggers=NULL"));
		}
	}
	</cfscript>
	
</cffunction>


<cffunction name="escape" localmode="modern" returntype="any" output="false">
	<cfargument name="string" type="string" required="yes">
	<cfreturn replace(replace(arguments.string, "\", "\\", "ALL"), "'", "''", "ALL")>
</cffunction>

<cffunction name="dumpTableData" localmode="modern" access="private">
	<cfargument name="filePath" type="string" required="yes">
	<cfargument name="datasource" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfargument name="columnList" type="string" required="yes">
	<cfscript>
	db=request.zos.noVerifyQueryObject;
	application.zcore.functions.zdeletefile(arguments.filePath);
	arrC=listToArray(arguments.columnList);
	for(i=1;i LTE arrayLen(arrC);i++){
		arrC[i]="'"&trim(arrC[i])&"'";
	}
	db.sql="SELECT "&arrayToList(arrC, ", ")&"
	UNION ALL
	SELECT #arguments.columnList#
	INTO OUTFILE '#escape(arguments.filePath)#' 
	FIELDS TERMINATED BY ',' ENCLOSED BY '""' 
 	ESCAPED BY '\\' LINES TERMINATED BY '\n' STARTING BY ''  
 	FROM `#arguments.datasource#`.`#request.zos.zcoreDatasourcePrefix##arguments.table#` ";
	if(structkeyexists(application.zcore.tablesWithSiteIdStruct, arguments.datasource&"."&arguments.table)){
		db.sql&=" WHERE site_id = '0' ";
	}
	d=db.execute("qSelect");
	writedump(d);
	</cfscript>
	
</cffunction>


<cffunction name="getCreateTableSQL" localmode="modern" access="private">
	<cfargument name="dsStruct" type="struct" required="yes">
	<cfscript>
	arrTableSQL=[];
	datasourceStruct={};
	for(i in arguments.dsStruct.tableStruct){
		arrTemp=listToArray(i, ".");
		if(arrTemp[1] EQ "zcore"){
			arrTemp[1]=request.zos.zcoreDatasource;
		}
		query name="qTables" datasource="#arrTemp[1]#"{
			echo("SHOW TABLES IN `"&arrTemp[1]&"`");
		}
		datasourceStruct[arrTemp[1]]={};
		for(row in qTables){
			table=row["Tables_in_"&arrTemp[1]];
			datasourceStruct[arrTemp[1]][table]=true;
		}
	} 

	for(i in arguments.dsStruct.tableStruct){
		arrTemp=listToArray(i, ".");
		if(arrTemp[1] EQ "zcore"){
			arrTemp[1]=request.zos.zcoreDatasource;
		}
		currentTable=arrTemp[2];
		if(not structkeyexists(datasourceStruct, arrTemp[1]) or structkeyexists(datasourceStruct[arrTemp[1]], arrTemp[2])){
			continue;
		}
		arrSQL=["CREATE TABLE `#arrTemp[1]#`.`#arrTemp[2]#` ("];
		fs=arguments.dsStruct.fieldStruct[i];
		arrKeys=structsort(fs, "numeric", "asc", "columnIndex");
		orderStruct={};
		for(n=1;n LTE arrayLen(arrKeys);n++){
			orderStruct[n]=arrKeys[n];
		}
		for(n=1;n LTE arrayLen(arrKeys);n++){
			field=arrKeys[n];
			if(n NEQ 1){
				arrayAppend(arrSQL, ", ");
			}
			arrayAppend(arrSQL,  "`#field#` "&createColumnSQL(fs[field], orderStruct, false));	
		}
		// build indices here
		for(n in arguments.dsStruct.keyStruct[i]){
			index=", ";
			if(arguments.dsStruct.keyStruct[i][n][1].index_type EQ "FULLTEXT"){
				index&="FULLTEXT KEY `#n#` (";
			}else if(n EQ "PRIMARY"){
				index&="PRIMARY KEY (";
			}else if(arguments.dsStruct.keyStruct[i][n][1].non_unique EQ "0"){
				index&="UNIQUE INDEX `#n#` (";
			}else{
				index&="INDEX `#n#` (";
			}
			for(g=1;g LTE arraylen(arguments.dsStruct.keyStruct[i][n]);g++){
				if(g NEQ 1){
					index&=", ";
				}
				index&="`"&arguments.dsStruct.keyStruct[i][n][g].column_name&"`";
			}
			arrayAppend(arrSQL, index&")");
		}
		
		arrayAppend(arrSQL, ") "&variables.createTableSQL(arguments.dsStruct.tableStruct[i])); 

		tableSQL=arrayToList(arrSQL, " ");
		query name="qCreateTable" datasource="#arrTemp[1]#"{
			echo(preserveSingleQuotes(tableSQL));
		}
	}
	</cfscript>
</cffunction>
	
<cffunction name="getDataTables" localmode="modern" access="private">
	<cfscript>
	dataTables={};
	dataTables["zcoreDatasource"]={
		"zemail_template_type": {
			columnList: "zemail_template_type_id,zemail_template_type_name,site_id"
		},
		"zipcode": {
			columnList: "city_name,city_type,state_abbr,country_code,zipcode_type,zipcode_zip,zipcode_latitude,zipcode_longitude"
		},
		"mls": {
			columnList: "mls_id,mls_name,mls_disclaimer_name,mls_mls_id,mls_offset,mls_status,mls_update_date,
			mls_download_date,mls_downloading,mls_frequency,mls_com,mls_skip_bytes,mls_delimiter,mls_csvquote,
			mls_first_line_columns,mls_file,mls_current_file_path,mls_primary_city_id,
			mls_login_url,mls_cleaned_date,mls_error_sent,mls_provider,mls_filelist"
		},
		"zemail_template": {
			columnList: "zemail_template_id, zemail_template_html,zemail_template_text,zemail_template_script, 
			zemail_template_subject,zemail_template_created_datetime,
			zemail_template_type_id,zemail_template_default,zemail_campaign_id,
			zemail_template_active,zemail_template_complete,site_id"
		},
		 "zemail_list": {
			columnList: "zemail_list_id,zemail_list_name,site_id"
		},
		"zemail_folder": {
			columnList: "zemail_folder_id,zemail_folder_name,site_id,user_id"
		},
		"track_convert": {
			columnList: "track_convert_id,track_convert_name,track_convert_display_name"
		},
		"state": {
			columnList: "state_code,state_state"
		
		},
		"inquiries_type": {
			columnList: "inquiries_type_id,inquiries_type_name,inquiries_type_sort,
			inquiries_type_manual,inquiries_type_locked,inquiries_type_realestate,inquiries_type_rentals,site_id"
		},
		"inquiries_status": {
			columnList: "inquiries_status_id,inquiries_status_name"
		},
		"inquiries_lead_template": {
			columnList: "inquiries_lead_template_id,inquiries_lead_template_name,
			inquiries_lead_template_subject,inquiries_lead_template_message,inquiries_lead_template_sort,
			inquiries_lead_template_type,inquiries_lead_template_realestate,site_id"
		},
		"far_feature": {
			columnList: "far_feature_code,far_feature_type,far_feature_description"
		},
		"country": {
			columnList: "country_name,country_code"
		},
		"content_property_type": {
			columnList: "content_property_type_id, content_property_type_name"
		},
		"city_distance": {
			columnList: "city_parent_id,city_id,city_distance"
		},
		"city": {
			columnList: "city_id,city_mls_id,city_name,state_abbr,country_code,city_county,
			city_has_listings,city_region_id,city_destination_id,city_user_created,city_latitude,city_longitude"
		},
		"app": {
			columnList: "app_id,app_name,app_built_in"
		}
	};
	return dataTables;
	</cfscript>
</cffunction>

<cffunction name="dumpInitialDatabase" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	// dump json file or create sql
	application.zcore.functions.zcreatedirectory(request.zos.sharedPath&"database");
	application.zcore.functions.zcreatedirectory(request.zos.sharedPath&"database/data/");
	curDSStruct={};
	
	curDSStruct=application.zcore.functions.zGetDatabaseStructure(request.zos.zcoreDatasource, curDSStruct);
	siteBackupCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.site-backup");
	schemaStruct=siteBackupCom.generateSchemaBackup(request.zos.zcoreDatasource, curDSStruct);
	application.zcore.functions.zwritefile(request.zos.sharedPath&"database/jetendo-schema.json", serializeJson(schemaStruct.struct)); 
	// these tables need a key that allows the infile to replace on unique values easily.

	dataTables=getDataTables();
	for(i in dataTables){
		datasource=i;
		datasource2=i;
		if(i EQ "zcoreDatasource"){
			datasource2="zcoreDatasource";
			datasource=request.zos.zcoreDatasource;
		}
		for(n in dataTables[i]){
			filePath=request.zos.sharedPath&"database/data/"&datasource2&"."&n&".csv";
			dumpTableData(filePath, datasource, n, dataTables[datasource2][n].columnList);
		}
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="restoreDataDumps" localmode="modern" access="private">
	<cfscript>
	tablesWithSiteIdStruct={};
	query name="qD" datasource="#request.zos.zcoredatasource#"{
		writeoutput("SELECT concat(TABLE_SCHEMA, '.', TABLE_NAME) `table` 
		FROM information_schema.COLUMNS 
		WHERE COLUMN_NAME = 'site_id' AND 
		TABLE_SCHEMA IN ('#preserveSingleQuotes(request.zos.zcoreDatasource)#') ");
	}
	for(row in qD){
		tablesWithSiteIdStruct[row.table]=true;
	}
	dataTables=getDataTables();
	for(i in dataTables){
		datasource=i;
		datasource2=i;
		if(i EQ "zcoreDatasource"){
			datasource2="zcoreDatasource";
			datasource=request.zos.zcoreDatasource;
		}
		for(n in dataTables[i]){
			filePath=request.zos.sharedPath&"database/data/"&datasource2&"."&n&".csv";
			hasSiteId=structkeyexists(tablesWithSiteIdStruct, datasource&"."&n);
			importTableData(filePath, datasource, n, dataTables[datasource2][n].columnList, hasSiteId);
		}
	}

	</cfscript>
	
</cffunction>

<cffunction name="installInitialDatabase" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	tempFile=request.zos.installPath&"share/database/jetendo-schema.json";
	file charset="utf-8" action="read" file="#tempFile#" variable="contents";
	dsStruct=deserializeJson(contents);
	getCreateTableSQL(dsStruct);
	restoreDataDumps();
	</cfscript>
</cffunction>

<!--- it would be more efficient to track the tables in schema that will be changed, and then only dump/restore those. --->
<cffunction name="dumpTables" localmode="modern" access="public">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="arrTable" type="array" required="yes">
	<cfargument name="arrDropTable" type="array" required="yes">
	<cfscript>
	var db=this.getDbObject(arguments.schema);
	var i=0;
	var table=0;
	var row=0;
	local.arrSQL=[]; 
	application.zcore.functions.zcreatedirectory("#request.zos.backupDirectory#upgrade");
	application.zcore.functions.zdeletedirectory(variables.databaseBackupPath);
	application.zcore.functions.zcreatedirectory(variables.databaseBackupPath);
	
	db.sql="SHOW TABLES IN `#arguments.schema#`";
	local.qTables=db.execute("qTables");
	local.tableExistsStruct={};
	for(row in local.qTables){
		local.tableExistsStruct[row["Tables_in_#arguments.schema#"]]=true;
	}
	for(i=1;i LTE arraylen(arguments.arrDropTable);i++){
	 	table=arguments.arrDropTable[i];
		arrayAppend(local.arrSQL, 'DROP TABLE IF EXISTS `#table#`');
	}
	for(i=1;i LTE arraylen(arguments.arrTable);i++){
	 	table=arguments.arrTable[i];
		if(structkeyexists(local.tableExistsStruct, table)){
			db.sql="SHOW CREATE TABLE `#arguments.schema#`.`#table#`";
			local.qCreate=db.execute("qCreate");
			arrayAppend(local.arrSQL, 'DROP TABLE IF EXISTS `#table#`');
			for(row in local.qCreate){
				arrayAppend(local.arrSQL, replace(replace(row['Create Table'], chr(10), ' ', 'all'), chr(13), '', 'all'));
			}
			db.sql="SHOW TRIGGERS FROM `#arguments.schema#`";
			local.qTrigger=db.execute("qTrigger");
			for(row in local.qTrigger){
				if(row.table EQ table){
					local.curTrigger=variables.siteBackupCom.getCreateTriggerSQLFromStruct(arguments.schema, row);
					arrayAppend(local.arrSQL, replace(replace(local.curTrigger.dropTriggerSQL, chr(10), ' ', 'all'), chr(13), '', 'all'));
					arrayAppend(local.arrSQL, replace(replace(local.curTrigger.createTriggerSQL, chr(10), ' ', 'all'), chr(13), '', 'all'));  
				}
			} 
			local.mysqlTsvPath="#variables.mysqlDatabaseBackupPath##arguments.schema#-#application.zcore.functions.zURLEncode(table,"-")#-data-backup.tsv";
			local.tsvPath="#variables.databaseBackupPath##arguments.schema#-#application.zcore.functions.zURLEncode(table,"-")#-data-backup.tsv";
			db.sql="select * from `#table#` 
			INTO OUTFILE '#local.mysqlTsvPath#'
			#variables.outfileOptions#";
			local.result=db.execute("qOutfile");
			if(not fileexists(local.tsvPath)){
				throw("Failed to backup `#arguments.schema#`.`#table#`", "Exception");
			}
			arrayAppend(local.arrSQL, replace(replace("LOAD DATA INFILE '#local.mysqlTsvPath#' 
			REPLACE INTO TABLE `#arguments.schema#`.`#table#` 
			#variables.outfileOptions#", chr(10), ' ', 'all'), chr(13), '', 'all'));
		}
	}
	application.zcore.functions.zwritefile("#variables.databaseBackupPath##arguments.schema#-schema-backup.sql", arrayToList(local.arrSQL, chr(10)));  
	</cfscript>
</cffunction>

<cffunction name="getDbObject" localmode="modern" access="public">
	<cfargument name="schema" type="string" required="yes">
	<cfscript>
	var dbInitConfigStruct={ 
		datasource:arguments.schema,
		verifyQueriesEnabled:false,
		autoReset:false, 
		cacheEnabled:false
	}
	return application.zcore.db.newQuery(dbInitConfigStruct); 
	</cfscript>
</cffunction>

	
<cffunction name="runDatabaseUpgrade" localmode="modern" access="public">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="renameStruct" type="struct" required="yes">
	<cfargument name="existingDsStruct" type="struct" required="yes">
	<cfargument name="newDsStruct" type="struct" required="yes">
	<cfargument name="verifyStructureOnly" type="boolean" required="yes">
	<cfscript> 
	var i=0;
	var db=request.zos.noVerifyQueryObject;
	local.changedTableStruct={};
	local.newTableStruct={};
	local.arrDiff=this.getDatabaseDiffAsSQLArray(arguments.schema, local.changedTableStruct, local.newTableStruct, arguments.renameStruct, arguments.existingDsStruct, arguments.newDsStruct, arguments.verifyStructureOnly);
	if(arguments.verifyStructureOnly){
		writeoutput('Structure comparison ran successfully.');
		if(arrayLen(local.arrDiff)){
			local.success=false;
			writeoutput('The follow SQL changes were generated.');
			writedump(local.arrDiff);
		}else{
			local.success=true;
			writeoutput('No database changes were detected.');
		}
		return {success:local.success, arrDiff:local.arrDiff};
	}
	if(arraylen(local.arrDiff)){
		// backup tables
		this.dumpTables(arguments.schema, structKeyArray(local.changedTableStruct), structKeyArray(local.newTableStruct));
	}
	return {success:true, arrDiff:local.arrDiff, changedTableStruct: local.changedTableStruct};
	</cfscript>
</cffunction>

<cffunction name="getDatabaseDiffAsSQLArray" localmode="modern" access="public">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="changedTableStruct" type="struct" required="yes">
	<cfargument name="newTableStruct" type="struct" required="yes">
	<cfargument name="renameStruct" type="struct" required="yes">
	<cfargument name="existingDsStruct" type="struct" required="yes">
	<cfargument name="newDsStruct" type="struct" required="yes">
	<cfargument name="verifyStructureOnly" type="boolean" required="yes">
	<cfscript>
	var i=0;
	var n=0;
	var g=0;
	local.rs={}; 
	local.rs.arrSQL=[];
	local.rs.arrSQL=this.generateRenameSQL(arguments.schema, arguments.changedTableStruct, arguments.newTableStruct, local.rs.arrSQL, arguments.existingDsStruct, arguments.newDsStruct, arguments.renameStruct, arguments.verifyStructureOnly);  
	 
	for(i in arguments.existingDsStruct.tableStruct){
		if(not structkeyexists(arguments.newDsStruct.tableStruct, i)){
			local.arrTemp=listToArray(i, ".");
			local.currentTable=local.arrTemp[2];
			arguments.changedTableStruct[local.currentTable]=true;
			arrayAppend(local.rs.arrSQL, "DROP TABLE `#replace(i, ".", "`.`")#`");
		}
	}
	for(i in arguments.newDsStruct.tableStruct){
		local.arrTemp=listToArray(i, ".");
		local.currentTable=local.arrTemp[2];
		if(not structkeyexists(arguments.existingDsStruct.tableStruct, i)){
			local.arrSQL=["CREATE TABLE `#replace(i, ".", "`.`")#` ("];
			local.fs=arguments.newDsStruct.fieldStruct[i];
			local.arrKeys=structsort(local.fs, "numeric", "asc", "columnIndex");
			local.orderStruct={};
			for(n=1;n LTE arrayLen(local.arrKeys);n++){
				local.orderStruct[n]=local.arrKeys[n];
			}
			for(n=1;n LTE arrayLen(local.arrKeys);n++){
				local.field=local.arrKeys[n];
				if(n NEQ 1){
					arrayAppend(local.arrSQL, ", ");
				}
				arrayAppend(local.arrSQL,  "`#local.field#` "&createColumnSQL(local.fs[local.field], local.orderStruct, false));	
			}
			// build indices here
			for(n in arguments.newDsStruct.keyStruct[i]){
				local.index=", ";
				if(n EQ "PRIMARY"){
					local.index&="PRIMARY KEY (";
				}else if(arguments.newDsStruct.keyStruct[i][n][1].non_unique EQ "0"){
					local.index&="UNIQUE INDEX `#n#` (";
				}else{
					local.index&="INDEX `#n#` (";
				}
				for(g=1;g LTE arraylen(arguments.newDsStruct.keyStruct[i][n]);g++){
					if(g NEQ 1){
						local.index&=", ";
					}
					local.index&="`"&arguments.newDsStruct.keyStruct[i][n][g].column_name&"`";
				}
				arrayAppend(local.arrSQL, local.index&")");
			}
			
			arrayAppend(local.arrSQL, ") "&variables.createTableSQL(arguments.newDsStruct.tableStruct[i])); 
			arrayAppend(local.rs.arrSQL, arrayToList(local.arrSQL, " ")); 
		}else{
			// check if I should alter table
			local.alterEnabled=false;
			local.arrAlterColumns=getTableDiffAsSQL(arguments.existingDsStruct.fieldStruct[i], arguments.newDsStruct.fieldStruct[i]);
			if(arrayLen(local.arrAlterColumns)){
				local.alterEnabled=true;
			}
			for(n in arguments.newDsStruct.tableStruct[i]){
				if(arguments.existingDsStruct.tableStruct[i][n] NEQ arguments.newDsStruct.tableStruct[i][n]){ 
					local.alterEnabled=true;
					break;
				}
			}
			if(local.alterEnabled){
				arguments.changedTableStruct[local.currentTable]=true;
				arrayAppend(local.rs.arrSQL, "ALTER TABLE `#replace(i, ".", "`.`")#` "&arrayToList(local.arrAlterColumns, ", ")&" "&variables.createTableSQL(arguments.newDsStruct.tableStruct[i]));
			}
		}
	} 
	return local.rs.arrSQL;
	</cfscript>
</cffunction>
 


<cffunction name="createColumnSQL" localmode="modern" access="private">
	<cfargument name="columnStruct" type="struct" required="yes">
	<cfargument name="orderStruct" type="struct" required="yes">
	<cfargument name="enableAfter" type="boolean" required="no" default="#true#">
	<cfscript>
	local.column=arguments.columnStruct.type;
	if(arguments.columnStruct.null EQ "NO"){
		local.column&=" NOT NULL";
	}else{
		local.column&=" NULL";
	}
	if(arguments.columnStruct.default NEQ ""){
		if(isNumeric(arguments.columnStruct.default)){
			local.column&=" DEFAULT "&arguments.columnStruct.default;
		}else{
			local.column&=" DEFAULT '"&escape(arguments.columnStruct.default)&"'";
		}
	}
	if(arguments.columnStruct.extra NEQ ""){
		local.column&=" "&arguments.columnStruct.extra;
	}
	if(arguments.enableAfter){
		if(arguments.columnStruct.columnIndex-1 LT 1){
			local.column&=" FIRST";
		}else{ 
			local.column&=" AFTER `"&arguments.orderStruct[arguments.columnStruct.columnIndex-1]&"`";
		}
	}
	return local.column;
	</cfscript>
</cffunction>

<cffunction name="getTableDiffAsSQL" localmode="modern" access="private" returntype="array">
	<cfargument name="oldTable" type="struct" required="yes">
	<cfargument name="newTable" type="struct" required="yes">
	<cfscript>
	var n=0;
	var i=0;
	var arrSQL=[];
	local.newOrderStruct={};
	for(i in arguments.newTable){
		local.newOrderStruct[arguments.newTable[i].columnIndex]=i;
	}
	for(i in arguments.newTable){
		// find columns missing in new table, that exist in old table
		if(not structkeyexists(arguments.oldTable, i)){
			arrayAppend(arrSQL, "ADD COLUMN `#i#` "&variables.createColumnSQL(arguments.newTable[i], local.newOrderStruct));
		}
	}
	for(i in arguments.oldTable){
		// find columns missing in new table, that exist in old table
		if(not structkeyexists(arguments.newTable, i)){
			arrayAppend(arrSQL, "DROP COLUMN `#i#`");
			continue;
		}
		// detect columns that have changed
		for(n in arguments.oldTable[i]){
			if(arguments.oldTable[i][n] NEQ arguments.newTable[i][n]){
				local.changeOrder=false;
				writeoutput(i&":"&arguments.oldTable[i].columnIndex&" NEQ "&arguments.newTable[i].columnIndex&"<br>");
				if(arguments.oldTable[i].columnIndex NEQ arguments.newTable[i].columnIndex){
					local.changeOrder=true;
				}
				arrayAppend(arrSQL, "CHANGE COLUMN `#i#` `#i#` "&variables.createColumnSQL(arguments.newTable[i], local.newOrderStruct, local.changeOrder));
				break;
			}
		} 
	}
	return arrSQL;
	</cfscript>
</cffunction>


	
<cffunction name="generateRenameSQL" localmode="modern" access="public" returntype="array">  
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="changedTableStruct" type="struct" required="yes">
	<cfargument name="newTableStruct" type="struct" required="yes">
	<cfargument name="arrSQL" type="array" required="yes">
	<cfargument name="existingTableStruct" type="struct" required="yes">
	<cfargument name="newTableStruct" type="struct" required="yes">
	<cfargument name="renameStruct" type="struct" required="yes"> 
	<cfscript>
	var schema=0;
	var table=0;
	var column=0;
	var i=0;
	var arrAlter=0;
	var newColumnName=0; 
	var columnDefinition=0;  
	var arrKey=structkeyarray(arguments.existingTableStruct);
	if(structkeyexists(arguments.renameStruct, arguments.schema)){
		for(table in arguments.renameStruct[arguments.schema]){
			if(structkeyexists(arguments.renameStruct[arguments.schema][table], 'renameColumnStruct') and structcount(arguments.renameStruct[arguments.schema][table].renameColumnStruct)){
				arrAlter=[];
				local.c=arguments.renameStruct[arguments.schema][table].renameColumnStruct;
				for(column in local.c){
					newColumnName=local.c[column];
					local.newTableName=table;
					if(structkeyexists(arguments.renameStruct[arguments.schema][table], 'renameTable')){
						// take on the new table's column structure during the rename field operation to reduce redundant work
						local.newTableName=arguments.renameStruct[arguments.schema][table].renameTable;
					}
					columnDefinition=this.createColumnSQL(arguments.newTableStruct.fieldStruct[arguments.schema&"."&local.newTableName][newColumnName], {}, false);
					
					// rename column in the tableStruct so verifyStructure operates on the renamed data
					
					arguments.existingTableStruct.fieldStruct[arguments.schema&"."&table][newColumnName]=arguments.newTableStruct.fieldStruct[arguments.schema&"."&local.newTableName][newColumnName];
					structdelete(arguments.existingTableStruct.fieldStruct[arguments.schema&"."&table], column);
					
					
					arrayAppend(arrAlter, 'CHANGE `#column#` `#newColumnName#`  #columnDefinition#');
				}
				arguments.changedTableStruct[table]=true;
				arrayAppend(arguments.arrSQL, 'ALTER TABLE `#arguments.schema#`.`#table#` '&arrayToList(arrAlter, ', '));
			}
			if(structkeyexists(arguments.renameStruct[arguments.schema][table], 'renameTable')){
				arrayAppend(arguments.arrSQL, 'rename table `#arguments.schema#`.`#table#` to `#arguments.schema#`.`#arguments.renameStruct[arguments.schema][table].renameTable#` '); 
				
				arguments.newTableStruct[arguments.renameStruct[arguments.schema][table].renameTable]=true;
				// rename table in the tableStruct so verifyStructure operates on the renamed data
				local.newSchemaTableName=arguments.schema&"."&arguments.renameStruct[arguments.schema][table].renameTable;
				for(i=1;i LTE arraylen(arrKey);i++){
					if(structkeyexists(arguments.existingTableStruct[arrKey[i]], arguments.schema&"."&table)){
						arguments.existingTableStruct[arrKey[i]][local.newSchemaTableName]=arguments.existingTableStruct[arrKey[i]][arguments.schema&"."&table]; 
						structdelete(arguments.existingTableStruct[arrKey[i]], arguments.schema&"."&table); 
					}
				}  
			}
		}
	}  
	return arguments.arrSQL;
	</cfscript>
</cffunction>		


<cffunction name="createTableSQL" localmode="modern" access="private">
	<cfargument name="tableStruct" type="struct" required="yes">
	<cfscript>
	local.tableSQL="ENGINE=#arguments.tableStruct.engine#, CHARSET=#arguments.tableStruct.charset#, COLLATE=#arguments.tableStruct.collation#";
	if(arguments.tableStruct.create_options NEQ ""){
		local.tableSQL&=", "&arguments.tableStruct.create_options;
	}
	return local.tableSQL;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>