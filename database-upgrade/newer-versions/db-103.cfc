<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript> 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `layout_column_x_widget_instance` (
  `layout_column_x_widget_instance_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `layout_column_x_widget_instance_uuid` CHAR(35) COLLATE utf8_bin NOT NULL DEFAULT '',
  `layout_column_x_widget_instance_sort` INT(11) UNSIGNED NOT NULL DEFAULT '0', 
  `layout_column_x_widget_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `layout_column_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `widget_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `widget_instance_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `layout_column_x_widget_instance_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
  `layout_column_x_widget_instance_deleted` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`layout_column_x_widget_instance_id`,`layout_column_x_widget_instance_deleted`),
  KEY `NewIndex1` (`site_id`,`widget_id`,`layout_column_id`,`layout_column_x_widget_instance_deleted`), 
  KEY `NewIndex2` (`site_id`),
  KEY `NewIndex3` (`site_id`,`widget_instance_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	}  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `landing_page_x_widget_instance` (
  `landing_page_x_widget_instance_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `landing_page_x_widget_instance_uuid` CHAR(35) COLLATE utf8_bin NOT NULL DEFAULT '',
  `landing_page_x_widget_instance_sort` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `widget_instance_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `landing_page_x_widget_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT '0', 
  `widget_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `section_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `landing_page_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `landing_page_x_widget_instance_json_data` LONGTEXT COLLATE utf8_bin NOT NULL,
  `landing_page_x_widget_instance_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
  `landing_page_x_widget_instance_deleted` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`landing_page_x_widget_instance_id`,`landing_page_x_widget_instance_deleted`),
  KEY `NewIndex1` (`site_id`,`widget_id`,`landing_page_id`,`landing_page_x_widget_instance_deleted`),
  KEY `NewIndex2` (`site_id`),
  KEY `NewIndex3` (`site_id`,`widget_instance_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	}  
 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `landing_page_x_widget`    
  DROP COLUMN `site_x_option_group_id`")){
		return false;
	}   
 
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "layout_column_x_widget_instance", "layout_column_x_widget_instance_id");
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "landing_page_x_widget_instance", "landing_page_x_widget_instance_id");

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>