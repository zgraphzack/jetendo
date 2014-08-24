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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#site`   
  ADD COLUMN `site_nginx_config` TEXT NOT NULL AFTER `company_id`,
  ADD COLUMN `site_nginx_disable_jetendo` CHAR(1) DEFAULT '0'   NOT NULL AFTER `site_nginx_config`")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#ssl`(
  `ssl_id` INT(11) NOT NULL,
  `ssl_updated_datetime` DATETIME NOT NULL,
  `ssl_deleted` INT(11) NOT NULL,
  `ssl_active` CHAR(1) NOT NULL DEFAULT '0',
  `ssl_display_name` VARCHAR(255) NOT NULL,
  `ssl_hash` VARCHAR(64) NOT NULL,
  `ssl_country` CHAR(2) NOT NULL,
  `ssl_state` VARCHAR(50) NOT NULL,
  `ssl_city` VARCHAR(100) NOT NULL,
  `ssl_organization` VARCHAR(255) NOT NULL,
  `ssl_organization_unit` VARCHAR(100) NOT NULL,
  `ssl_common_name` VARCHAR(100) NOT NULL,
  `ssl_created_datetime` DATETIME NOT NULL,
  `ssl_key_size` INT(11) NOT NULL DEFAULT 0,
  `site_id` INT(11) NOT NULL DEFAULT 0,
  `ssl_wildcard` CHAR(1) DEFAULT '0'   NOT NULL,
  `ssl_expiration_datetime` DATETIME NOT NULL,
  `ssl_public_key` TEXT NOT NULL,
  `ssl_intermediate_certificate` TEXT NOT NULL,
  `ssl_ca_certificate` TEXT NOT NULL,
  `ssl_email` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`site_id`, `ssl_id`),
  UNIQUE INDEX `NewIndex1` (`ssl_common_name`, `ssl_hash`, `ssl_deleted`, `ssl_active`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	} 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>