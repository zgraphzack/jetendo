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
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "ALTER TABLE `#request.zos.zcoredatasourceprefix#site`   
	  ADD COLUMN `company_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `site_deleted`, 
	  ADD  INDEX `newindex1` (`company_id`)")){
		return false;
	}

	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "ALTER TABLE `#request.zos.zcoredatasourceprefix#user`   
	  ADD COLUMN `company_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `user_deleted`, 
	  ADD  INDEX `newindex1` (`company_id`)")){
		return false;
	}

	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "CREATE TABLE `#request.zos.zcoredatasourceprefix#company`(  
	  `company_id` INT(11) NOT NULL AUTO_INCREMENT,
	  `company_name` VARCHAR(255) NOT NULL,
	  PRIMARY KEY (`company_id`),
	  UNIQUE INDEX `newindex1` (`company_name`)
	) ENGINE=InnoDB, CHARSET=utf8, COLLATE=utf8_general_ci")){
		return false;
	}

	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "CREATE TABLE `#request.zos.zcoredatasourceprefix#audit`(  
	  `audit_id` INT(11) NOT NULL AUTO_INCREMENT,
	  `audit_description` VARCHAR(500) NOT NULL,
	  `user_id` INT(11) UNSIGNED NOT NULL,
	  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `audit_url` TEXT NOT NULL,
	  `audit_updated_datetime` DATETIME NOT NULL,
	  `audit_deleted` CHAR(1) NOT NULL DEFAULT '0',
	  `audit_security_feature` VARCHAR(100) NOT NULL,
	  `audit_security_action_write` CHAR(1) NOT NULL DEFAULT '0',
	  PRIMARY KEY (`audit_id`),
	  INDEX `newindex1` (`user_id`, `audit_updated_datetime`),
	  INDEX `newindex2` (`site_id`, `audit_updated_datetime`)
	) ENGINE=InnoDB, CHARSET=utf8, COLLATE=utf8_general_ci")){
		return false;
	}
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>