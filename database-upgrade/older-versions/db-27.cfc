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
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "CREATE TABLE `#request.zos.zcoredatasourceprefix#dns_health`(  
	  `dns_health_id` INT(11) NOT NULL AUTO_INCREMENT,
	  `dns_health_url` VARCHAR(255) NOT NULL,
	  `dns_health_failed` CHAR(1) NOT NULL DEFAULT '0',
	  `dns_health_match_text` TEXT NOT NULL,
	  `dns_health_updated_datetime` DATETIME NOT NULL,
	  `dns_health_deleted` CHAR(1) NOT NULL DEFAULT '0',
	  PRIMARY KEY (`dns_health_id`),
	  UNIQUE INDEX `newindex1` (`dns_health_url`)
	) ENGINE=InnoDB, CHARSET=utf8, COLLATE=utf8_general_ci")){
		return false;
	}
	
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "CREATE TABLE `#request.zos.zcoredatasourceprefix#dns_ip`(  
	  `dns_ip_id` INT(11) NOT NULL AUTO_INCREMENT,
	  `dns_ip_address` VARCHAR(45) NOT NULL,
	  `dns_ip_comment` TEXT NOT NULL,
	  `dns_ip_parent_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `dns_ip_sharable` CHAR(1) NOT NULL DEFAULT '0',
	  `dns_health_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `dns_ip_updated_datetime` DATETIME NOT NULL,
	  `dns_ip_deleted` CHAR(1) NOT NULL DEFAULT '0',
	  PRIMARY KEY (`dns_ip_id`),
	  UNIQUE INDEX `newindex1` (`dns_ip_address`)
	) ENGINE=InnoDB, CHARSET=utf8, COLLATE=utf8_general_ci")){
		return false;
	}


	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "CREATE TABLE `#request.zos.zcoredatasourceprefix#dns_zone`(  
	  `dns_zone_id` INT(11) NOT NULL AUTO_INCREMENT,
	  `dns_zone_name` VARCHAR(255) NOT NULL,
	  `dns_zone_updated_datetime` DATETIME NOT NULL,
	  `dns_zone_deleted` CHAR(1) NOT NULL DEFAULT '0',
	  `dns_zone_serial` VARCHAR(10) NOT NULL,
	  `dns_group_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `dns_zone_ttl` INT(11) UNSIGNED NOT NULL,
	  `dns_zone_primary_nameserver` VARCHAR(255) NOT NULL,
	  `dns_zone_expires` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `dns_zone_refresh` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `dns_zone_minimum` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `dns_zone_email` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `dns_zone_soa_ttl` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `dns_zone_custom_ns` CHAR(1) NOT NULL,
	  `dns_zone_custom_cname` CHAR(1) NOT NULL,
	  `dns_zone_custom_a` CHAR(1) NOT NULL,
	  `dns_zone_custom_aaaa` CHAR(1) NOT NULL,
	  `dns_zone_custom_mx` CHAR(1) NOT NULL,
	  `dns_zone_custom_srv` CHAR(1) NOT NULL,
	  `dns_zone_custom_txt` CHAR(1) NOT NULL,
	  `dns_zone_comment` TEXT NOT NULL,
	  PRIMARY KEY (`dns_zone_id`),
	  INDEX `newindex1` (`dns_group_id`),
	  UNIQUE INDEX `newindex2` (`dns_group_id`, `dns_zone_name`),
	  INDEX `newindex3` (`dns_zone_name`)
	) ENGINE=InnoDB, CHARSET=utf8, COLLATE=utf8_general_ci")){
		return false;
	}


	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "CREATE TABLE `#request.zos.zcoredatasourceprefix#dns_record`(  
	  `dns_record_id` INT(11) NOT NULL AUTO_INCREMENT,
	  `dns_record_type` VARCHAR(10) NOT NULL,
	  `dns_zone_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `dns_ip_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `dns_record_updated_datetime` DATETIME NOT NULL,
	  `dns_record_deleted` CHAR(1) NOT NULL DEFAULT '0',
	  `dns_record_host` VARCHAR(255) NOT NULL,
	  `dns_record_ttl` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `dns_record_value` TEXT NOT NULL,
		`dns_record_comment` text NOT NULL,
	  PRIMARY KEY (`dns_record_id`),
	  INDEX `newindex1` (`dns_zone_id`)
	) ENGINE=InnoDB, CHARSET=utf8, COLLATE=utf8_general_ci")){
		return false;
	}


if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "CREATE TABLE `#request.zos.zcoredatasourceprefix#dns_group`(  
	  `dns_group_id` INT(11) NOT NULL AUTO_INCREMENT,
	  `dns_group_name` VARCHAR(255) NOT NULL,
	  `dns_group_comment` TEXT NOT NULL,
	  `dns_group_notify_ip_list` TEXT NOT NULL,
	  `dns_group_default_ttl` INT(11) NOT NULL DEFAULT 0,
	  `dns_group_default_retry` INT(11) NOT NULL DEFAULT 0,
	  `dns_group_default_expires` INT(11) NOT NULL DEFAULT 0,
	  `dns_group_default_refresh` INT(11) NOT NULL DEFAULT 0,
	  `dns_group_default_minimum` INT(11) NOT NULL DEFAULT 0,
	  `dns_group_default_soa_ttl` INT(11) NOT NULL DEFAULT 0,
	  `dns_group_default_email` VARCHAR(100) NOT NULL,
	  `dns_group_updated_datetime` DATETIME NOT NULL,
	  `dns_group_deleted` CHAR(1) NOT NULL DEFAULT '0',
	  PRIMARY KEY (`dns_group_id`),
	  UNIQUE INDEX `newindex1` (`dns_group_name`)
	) ENGINE=InnoDB, CHARSET=utf8, COLLATE=utf8_general_ci")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>