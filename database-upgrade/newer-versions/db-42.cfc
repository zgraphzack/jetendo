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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#rets_download_log`(  
	  `rets_download_log_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	  `rets_download_log_text` TEXT NOT NULL,
	  `rets_download_log_error_text` TEXT NOT NULL,
	  `rets_download_log_updated_datetime` DATETIME NOT NULL,
	  `rets_download_log_deleted` CHAR(1) NOT NULL DEFAULT '0',
	  PRIMARY KEY (`rets_download_log_id`),
	INDEX `NewIndex1` (`rets_download_log_updated_datetime`)
	) ENGINE=INNODB, CHARSET=utf8, COLLATE=utf8_general_ci")){
		return false;
	} 
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#ecommerce_config` (
	  `ecommerce_config_id` int(11) NOT NULL,
	  `ecommerce_config_paypal_merchant_id` varchar(100) NOT NULL DEFAULT '',
	  `ecommerce_config_sandbox_enabled` char(1) NOT NULL DEFAULT '0',
	  `ecommerce_config_order_confirmation_email_list` text NOT NULL,
	  `ecommerce_config_order_change_email_list` text NOT NULL,
	  `ecommerce_config_paypal_ipn_failure_email_list` text NOT NULL,
	  `ecommerce_config_updated_datetime` datetime NOT NULL,
	  `ecommerce_config_deleted` int(11) unsigned NOT NULL DEFAULT '0',
	  `site_id` int(11) NOT NULL DEFAULT '0',
	  PRIMARY KEY (`ecommerce_config_id`,`site_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC")){
		return false;
	} 
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO  `#request.zos.zcoreDatasourcePrefix#app` SET 
	app_id='15', 
	app_name = 'Ecommerce', 
	app_built_in = '0', 
	app_updated_datetime = '2014-08-10 00:00:00'")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#ecommerce_config`   
  ADD  UNIQUE INDEX `NewIndex1` (`site_id`, `ecommerce_config_deleted`)")){
		return false;
	} 
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#content_config`   
  ADD  UNIQUE INDEX `NewIndex1` (`site_id`, `content_config_deleted`)")){
		return false;
	} 
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#rental_config`   
  ADD  UNIQUE INDEX `NewIndex1` (`site_id`, `rental_config_deleted`)")){
		return false;
	} 
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#mls_option`   
  ADD  UNIQUE INDEX `NewIndex2` (`site_id`, `mls_option_deleted`)")){
		return false;
	} 
  
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#blog_config`   
  ADD  UNIQUE INDEX `NewIndex3` (`site_id`, `blog_config_deleted`)")){
		return false;
	} 
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>