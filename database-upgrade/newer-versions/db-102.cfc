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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `widget_instance`(  
  `widget_instance_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL,
  `widget_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `widget_instance_name` VARCHAR(255) NOT NULL,
  `widget_instance_version` INT UNSIGNED NOT NULL,
  `widget_instance_updated_datetime` DATETIME NOT NULL,
  `widget_instance_deleted` CHAR(1) NOT NULL DEFAULT '0',
  `widget_instance_json_data` LONGTEXT NOT NULL,
  PRIMARY KEY (`site_id`, `widget_instance_id`),
  INDEX `NewIndex1` (`widget_id`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	}  
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "widget_instance", "widget_instance_id");
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>