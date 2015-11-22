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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `paypal_ipn_log` (
  `paypal_ipn_log_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL DEFAULT '0',
  `paypal_ipn_log_invoice` varchar(100) NOT NULL,
  `paypal_ipn_log_data` text NOT NULL,
  `paypal_ipn_log_datetime` datetime NOT NULL,
  `paypal_ipn_log_verified` char(1) NOT NULL DEFAULT '0',
  `paypal_ipn_log_updated_datetime` datetime NOT NULL,
  `paypal_ipn_log_deleted` char(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`paypal_ipn_log_id`),
  KEY `NewIndex1` (`paypal_ipn_log_invoice`),
  KEY `NewIndex2` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){
		return false;
	} 
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "paypal_ipn_log", "paypal_ipn_log_id");
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>