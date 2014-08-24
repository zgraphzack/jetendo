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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#ssl` (
  `ssl_id` int(11) NOT NULL,
  `ssl_updated_datetime` datetime NOT NULL,
  `ssl_deleted` int(11) NOT NULL,
  `ssl_active` char(1) COLLATE utf8_bin NOT NULL DEFAULT '0',
  `ssl_display_name` varchar(255) COLLATE utf8_bin NOT NULL,
  `ssl_hash` varchar(64) COLLATE utf8_bin NOT NULL,
  `ssl_country` char(2) COLLATE utf8_bin NOT NULL,
  `ssl_state` varchar(50) COLLATE utf8_bin NOT NULL,
  `ssl_city` varchar(100) COLLATE utf8_bin NOT NULL,
  `ssl_organization` varchar(255) COLLATE utf8_bin NOT NULL,
  `ssl_organization_unit` varchar(100) COLLATE utf8_bin NOT NULL,
  `ssl_common_name` varchar(100) COLLATE utf8_bin NOT NULL,
  `ssl_created_datetime` datetime NOT NULL,
  `ssl_key_size` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  `ssl_wildcard` char(1) COLLATE utf8_bin NOT NULL DEFAULT '0',
  `ssl_expiration_datetime` datetime NOT NULL,
  `ssl_public_key` text COLLATE utf8_bin NOT NULL,
  `ssl_intermediate_certificate` text COLLATE utf8_bin NOT NULL,
  `ssl_ca_certificate` text COLLATE utf8_bin NOT NULL,
  `ssl_email` varchar(100) COLLATE utf8_bin NOT NULL,
  `ssl_csr` text COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`site_id`,`ssl_id`),
  UNIQUE KEY `NewIndex1` (`ssl_active`,`ssl_hash`,`ssl_common_name`,`site_id`,`ssl_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	} 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>