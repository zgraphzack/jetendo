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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `layout_global` (
  `layout_global_id` INT(11) UNSIGNED NOT NULL DEFAULT '0', 
  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `layout_global_json_data` LONGTEXT COLLATE utf8_bin NOT NULL,
  `layout_global_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
  `layout_global_deleted` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`layout_global_id`,`layout_global_deleted`), 
  KEY `NewIndex2` (`site_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	}   
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "layout_global", "layout_global_id");

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>