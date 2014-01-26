<cfcomponent>
<cfoutput>

<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	variables.siteBackupCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.site-backup");
	variables.outfileOptions="FIELDS TERMINATED BY '\t' ENCLOSED BY '""' ESCAPED BY '\\' LINES TERMINATED BY '\n' ";
	variables.curBackupDate=dateformat(now(), 'yyyymmdd')&timeformat(now(),'HHmmss');
	variables.databaseBackupPath="#request.zos.backupDirectory#upgrade/databaseBackup#variables.curBackupDate#/";
	variables.mysqlDatabaseBackupPath="#request.zos.mysqlBackupDirectory#upgrade/databaseBackup#variables.curBackupDate#/";
	
	variables.databaseVersionCom=createobject("component", "zcorerootmapping.databaseVersion");
	variables.tableVersionStruct=variables.databaseVersionCom.getTableVersionStruct();
	</cfscript>
</cffunction>

<cffunction name="changeSchemaForDebugging" localmode="modern" access="public"> 
	<cfargument name="existingDsStruct" type="struct" required="yes">
	<cfargument name="newDsStruct" type="struct" required="yes">
	<cfscript>	
	var i=0;
	local.ds="zcore";
	local.table="app";
	
	if(not request.zos.isTestServer){
		throw("This shouldn't run in production environment.", "Exception");	
	}
	// force some changes for debugging the upgrade process
	local.tt=duplicate(arguments.existingDsStruct.fieldStruct["#local.ds#.#local.table#"]);
	local.tt.app2_id=local.tt.app_id;
	local.tt.app2_name=local.tt.app_name;
	//structdelete(local.tt, 'app_id');
	structdelete(local.tt, 'app_name');
	arguments.existingDsStruct.fieldStruct["#local.ds#.app2"]=local.tt;
	
	local.table1=(arguments.existingDsStruct.fieldStruct["#local.ds#.#local.table#"]);
	local.table2=(arguments.newDsStruct.fieldStruct["#local.ds#.#local.table#"]);
	local.table2.app_name.type="varchar(55)";
	local.table1.app_deprecated_column={
		columnIndex:structcount(local.table1)+1,
		default:"",
		extra:"",
		key:"",
		null:"NO",
		type:"char(1)"
	};
	//structdelete(local.table2, 'app_id');
	for(i in local.table2){
		local.table2[i].columnIndex++;
	}
	local.table2.app_new_column={
		columnIndex:1,
		default:"default",
		extra:"",
		key:"",
		null:"YES",
		type:"varchar(10)"
	}; 
	local.table2.app_new_column_end={
		columnIndex:structcount(local.table2)+1,
		default:"default",
		extra:"",
		key:"",
		null:"YES",
		type:"varchar(1)"
	};  
	// detect new tables 
	arguments.newDsStruct.tableStruct["#local.ds#.drop_app_table"]=duplicate(arguments.newDsStruct.tableStruct["#local.ds#.app"]); 
	arguments.newDsStruct.keyStruct["#local.ds#.drop_app_table"]=duplicate(arguments.newDsStruct.keyStruct["#local.ds#.app"]); 
	arguments.newDsStruct.fieldStruct["#local.ds#.drop_app_table"]=duplicate(arguments.newDsStruct.fieldStruct["#local.ds#.app"]);
	structdelete(arguments.newDsStruct.tableStruct, "#local.ds#.app_x_site");
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var i=0; 
	var curDSStruct={};
	var backupDatabaseStruct=structnew();
	this.init();
	if(not request.zos.isTestServer){
		throw("This is not ready for the production environment yet.", "Exception");	
	}
	for(i=1;i LTE arraylen(application.zcore.arrGlobalDatasources);i++){
		backupDatabaseStruct[application.zcore.arrGlobalDatasources[i]]=0; 
	}
	local.ds="zcore";
	
	// only backup tables that exist in the version struct for current installation
	writedump(variables.tableVersionStruct);
	abort;
	
	local.verifyStructureOnly=false;
	 // generate dsStruct for current datasource
	curDSStruct=application.zcore.functions.zGetDatabaseStructure(local.ds, curDSStruct);
	local.schemaStruct=variables.siteBackupCom.generateSchemaBackup(local.ds, curDSStruct); 
	
	local.tempFile=request.zos.backupDirectory&"database-schema/#local.ds#.json";
	local.newDsStruct=deserializeJson(application.zcore.functions.zreadfile(local.tempFile));
	
	local.existingDsStruct=local.schemaStruct.struct; 
	
	// version storage format
	// 88kb zip of json schema files
	/*
	 
	
	store a separate json files that has
	upgradeStruct={
		version:"0.1.001",
		renameStruct:{
			schema: {
				table: {
					renameTable: "table2",
					renameColumnStruct: {
						"app2_id": "app_id",
						"app2_name":"app_name"
					}
				}
			}
		},
		upgradeCFC: 'db-0-01-001.cfc',
		preProcessMethod: 'preProcess',
		postProcessMethod: 'postProcess'
	}
	*/
	// determine current version by the json file installed in jetendo root directory.
	application.zcore.functions.zreadfile(request.zos.installPath&"version.json");
	
	
	// determine new version
	
	// execute upgrades incrementally 1 version at a time until reaching the latest.
	local.renameStruct={
		"zcore": {
			"app2": {
				renameTable: "app",
				renameColumnStruct: {
					"app2_id": "app_id",
					"app2_name":"app_name"
				}
			}
		}
	} 
	
	// uncomment to force db changes for testing purposes
	//this.changeSchemaForDebugging(local.existingDsStruct, local.newDsStruct);
	
	local.rs=this.runDatabaseUpgrade(local.ds, local.renameStruct, local.existingDsStruct, local.newDsStruct, local.verifyStructureOnly);
	if(local.verifyStructureOnly){
		if(local.rs.success){
			writeoutput('Database structure is valid.');
		}else{
			writeoutput('Database structure is not valid and had the following differences:');
			writedump(local.rs.arrDiff); 
		}
	}else{
		if(local.rs.success){
			// run again with verifyStructureOnly forced to true
			local.rs2=this.runDatabaseUpgrade(local.ds, local.renameStruct, local.existingDsStruct, local.newDsStruct, true);
			if(local.rs2.success){
				writeoutput('Database upgraded successfully');
			}else{
				writeoutput('Database upgrade couldn''t be verified. The following differences were detected:');
				writedump(local.rs2.arrDiff);
			}
		}
	}
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
	// this may be efficient, but it's insecure to allow CFML to access mysqldump
	// mysqldump --user= --password= --host=  --port= #arguments.schema# #arrayToList(arrTable, ' ')# > /path/to/#arguments.schema#-dump.sql
	
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

<cffunction name="restoreTables" localmode="modern" access="public">
	<cfargument name="schema" type="string" required="yes">
	<cfscript>
	var db=this.getDbObject(arguments.schema);
	var i=0;
	// drop tables in database
	var arrSql=listToArray(application.zcore.functions.zreadfile("#variables.databaseBackupPath##arguments.schema#-schema-backup.sql"), chr(10), false);
	//writedump(arrSql);
	for(i=1;i LTE arrayLen(arrSQL);i++){
		db.sql=arrSQL[i];
		local.result=db.execute("qRestore");
		writeoutput(i&":"&local.result&"<br>");
	}
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
		
		// run upgrade queries	
		/*	
		// disabled until I'm sure I want it to run
		for(i=1;i LTE arraylen(local.arrDiff);i++){
			db.sql=local.arrDiff[i].sql;
			local.queryFailed=true;
			local.currentError="";
			try{
				local.result=db.execute("q#i#");
				local.queryFailed=false;
			}catch(Any local.excpt){
				local.currentError=local.excpt;
			}
			if(local.queryFailed){
				writeoutput("Query failed:"&local.arrDiff[i]);
				writedump(local.currentError);
				
				writeoutput('Reverting to previous database backup.');
				this.restoreTables(arguments.schema);
				writeoutput('Database upgrade cancelled and reverted successfully.');
				return {success:false, arrDiff:local.arrDiff};
			}
		}*/
	}
	//writedump(local.existingDsStruct.fieldStruct);	abort;
	return {success:true, arrDiff:local.arrDiff};
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
				arrayAppend(local.arrSQL,  "`#local.field#` "&variables.createColumnSQL(local.fs[local.field], local.orderStruct, false));	
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
			/*if(i EQ 'zcore.app'){
				writeoutput('test');
				writedump(arguments.existingDsStruct.fieldStruct[i]);
				writedump(local.newDsStruct.fieldStruct[i]);
				writedump(local.arrAlterColumns);
			}*/
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
			local.column&=" DEFAULT '"&arguments.columnStruct.default&"'";
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