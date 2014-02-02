<cfcomponent>
<cfoutput>

<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	variables.siteBackupCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.site-backup");
	variables.outfileOptions="FIELDS TERMINATED BY '\t' ENCLOSED BY '""' ESCAPED BY '\\' LINES TERMINATED BY '\n' ";
	variables.curBackupDate=dateformat(now(), 'yyyymmdd')&timeformat(now(),'HHmmss');
	variables.databaseBackupPath="#request.zos.backupDirectory#upgrade/databaseBackup#variables.curBackupDate#/";
	variables.mysqlDatabaseBackupPath="#request.zos.mysqlBackupDirectory#upgrade/databaseBackup#variables.curBackupDate#/";
	variables.tableVersionStruct=getTableVersionStruct();
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
	if(qCheck.recordcount NEQ 0){
		query name="qVersion" datasource="#request.zos.zcoreDatasource#"{
			echo("SELECT * FROM jetendo_setup LIMIT 0,1");
		}
		if(qVersion.recordcount EQ 0){
			query name="qInsert" datasource="#request.zos.zcoreDatasource#"{
				echo("INSERT INTO jetendo_setup SET jetendo_setup_database_version = '#request.zos.databaseVersion#' ");
			}
			return true;
		}else{
			if(qVersion.jetendo_setup_database_version EQ request.zos.databaseVersion){
				return true;
			}else if(qVersion.jetendo_setup_database_version GT request.zos.databaseVersion){
				throw("Jetendo database is a newer version then request.zos.databaseVersion.  Please check that source code version is the same or newer then database.");
			}
		}
	}

	// verify the rest of the config.cfc values before installing database & application.


	// install database
	if(qCheck.recordcount EQ 0){
		installInitialDatabase();

		query name="qInsert" datasource="#request.zos.zcoreDatasource#"{
			echo("INSERT INTO jetendo_setup SET jetendo_setup_database_version = '#request.zos.databaseVersion#' ");
		}
		application[request.zos.installPath&":displaySetupScreen"]=true;
	}else{
		echo("upgrade");abort;
		// upgrade database
		index();

		query name="qUpdate" datasource="#request.zos.zcoreDatasource#"{
			echo("UPDATE jetendo_setup SET jetendo_setup_database_version = '#request.zos.databaseVersion#' ");
		}
	}
	// verify tables
	verifyTablesCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.verify-tables");
	arrLog=verifyTablesCom.index(true);
	/*if(arrayLen(arrLog)){
		savecontent variable="output"{
			echo("<h2>verify-tables failed.</h2>");
			writedump(arrLog);

		}
		throw(output);
	}*/
	</cfscript>
</cffunction>

<cffunction name="getTableVersionStruct" localmode="modern" returntype="struct" access="public">
	<cfscript>
	// this file must be manually updated when you want change which tables are being tracked for versioning
	
	// later implement hooks so rental and listing apps register their tables with this component in a different CFC.
	var tableVersionStruct={
		zcoreDatasource: {
			app: true,
			app_db_offset: true,
			app_reserve: true,
			app_x_site: true,
			blog: true,
			blog_category: true,
			blog_category_version: true,
			blog_comment: true,
			blog_config: true,
			blog_tag: true,
			blog_tag_version: true,
			blog_version: true,
			blog_x_category: true,
			blog_x_tag: true,
			cf_data_type: true,
			content: true,
			content_config: true,
			content_permissions: true,
			content_property_type: true,
			content_version: true,
			country: true,
			event: true,
			event_recur: true,
			field_map: true,
			file: true,
			image: true,
			image_arrangement: true,
			image_cache: true,
			image_library: true,
			inquiries: true,
			inquiries_feedback: true,
			inquiries_lead_template: true,
			inquiries_lead_template_x_site: true,
			inquiries_log: true,
			inquiries_routing: true,
			inquiries_status: true,
			inquiries_type: true,
			ip_block: true,
			lang_culture: true,
			lang_script_global: true,
			lang_script_site: true,
			lang_table_global: true,
			lang_table_site: true,
			link_hardcoded: true,
			link_verify_link: true,
			link_verify_status: true,
			log: true,
			log404: true,
			login_log: true,
			mail_user: true,
			menu: true,
			menu_button: true,
			menu_button_link: true,
			office: true,
			page: true,
			queue: true,
			rewrite_rule: true,
			robots: true,
			robots_global: true,
			search: true,
			search_keyword_log: true,
			sentence: true,
			sentence_type: true,
			sentence_word: true,
			site: true,
			site_option: true,
			site_option_app: true,
			site_option_group: true,
			site_option_group_map: true,
			site_x_option: true,
			site_x_option_group: true,
			site_x_option_group_set: true,
			slideshow: true,
			slideshow_image: true,
			slideshow_tab: true,
			state: true,
			tooltip: true,
			tooltip_section: true,
			track_convert: true,
			track_page: true,
			track_user: true,
			track_user_x_convert: true,
			user: true,
			user_group: true,
			user_group_x_group: true,
			user_token: true,
			video: true,
			zemail: true,
			zemail_account: true,
			zemail_campaign: true,
			zemail_campaign_click: true,
			zemail_campaign_x_user: true,
			zemail_data: true,
			zemail_folder: true,
			zemail_list: true,
			zemail_list_x_campaign: true,
			zemail_list_x_user: true,
			zemail_signature: true,
			zemail_template: true,
			zemail_template_type: true,
			zipcode: true,
			app_x_mls: true,
			city: true,
			city_distance: true,
			city_distance_safe_update: true,
			city_rename: true,
			city_x_mls: true,
			county: true,
			listing: true,
			listing_data: true,
			listing_latlong: true,
			listing_latlong_original: true,
			listing_lookup: true,
			listing_track: true,
			listing_type: true,
			listing_x_site: true,
			manual_listing: true,
			mls: true,
			mls_dir: true,
			mls_filter: true,
			mls_image_hash: true,
			mls_option: true,
			mls_saved_search: true,
			saved_listing: true,
			search_count: true,
			'zram##city': true,
			'zram##city_distance': true,
			'zram##listing': true,
			availability: true,
			availability_type: true,
			availability_type_calendar: true,
			rental: true,
			rental_amenity: true,
			rental_category: true,
			rental_config: true,
			rental_x_amenity: true,
			rental_x_category: true,
			special_rate: true,
			far_feature: true
		}
	};
	return tableVersionStruct;
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
		echo(preserveSingleQuotes("LOAD DATA INFILE '#application.zcore.functions.zescape(arguments.filePath)#' 
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
	INTO OUTFILE '#application.zcore.functions.zescape(arguments.filePath)#' 
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
		},
		"tooltip": {
			columnList: "tooltip_id,tooltip_html,tooltip_name,tooltip_section_id,tooltip_label"
		},
		"tooltip_section": {
			columnList: "tooltip_section_id,tooltip_section_name"
		}
	};
	return dataTables;
	</cfscript>
</cffunction>

<cffunction name="dumpInitialDatabase" localmode="modern" access="remote">
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
	echo("Initial database dumped");
	abort;
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

<cffunction name="installInitialDatabase" localmode="modern" access="remote">
	<cfscript>
	// load schema in json format
	tempFile=request.zos.installPath&"share/database/jetendo-schema.json";
	dsStruct=deserializeJson(application.zcore.functions.zreadfile(tempFile));

	getCreateTableSQL(dsStruct);

	restoreDataDumps();

	// list of tables with global data:


	//	mls table - needs rewrite so that the app creates the initial records instead of relying on manual entry.
		
		/*

		maybe manually create these for first user, first site
		user_group
		site
		user_group_x_group
		user (initial server admin)
	*/

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
			local.column&=" DEFAULT '"&application.zcore.functions.zescape(arguments.columnStruct.default)&"'";
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