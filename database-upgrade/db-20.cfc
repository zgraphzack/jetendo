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
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "CREATE TABLE `#request.zos.zcoredatasourceprefix#version`(  
	  `version_id` INT(11) UNSIGNED NOT NULL,
	  `site_id` INT(11) UNSIGNED NOT NULL,
	  `version_datetime` DATETIME NOT NULL,
	  `version_json_data` LONGTEXT NOT NULL,
	  `server_id` INT(11) NOT NULL DEFAULT 0,
	  `version_uuid` VARCHAR(35) NOT NULL,
	  `version_preview_title` VARCHAR(255) NOT NULL,
	  `version_preview_html` LONGTEXT NOT NULL,
	  `version_schema` VARCHAR(50) NOT NULL,
	  `version_table` VARCHAR(50) NOT NULL,
	  PRIMARY KEY (`version_id`, `site_id`),
	  INDEX `newindex1` (`server_id`, `version_datetime`)
	) ENGINE=InnoDB, CHARSET=utf8, COLLATE=utf8_general_ci")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "CREATE TABLE `#request.zos.zcoredatasourceprefix#sync`(  
	  `sync_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	  `sync_start_datetime` DATETIME NOT NULL,
	  `server_id` INT(11) NOT NULL,
	  `sync_type` VARCHAR(50) NOT NULL,
	  PRIMARY KEY (`sync_id`),
	  INDEX `newindex1` (`server_id`, `sync_type`)
	) ENGINE=InnoDB, CHARSET=utf8, COLLATE=utf8_general_ci")){
		return false;
	}
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>