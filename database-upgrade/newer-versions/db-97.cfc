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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `authorize_net_relay_log`(  
  `authorize_net_relay_log_id` INT NOT NULL,
  `site_id` INT NOT NULL,
  `authorize_net_relay_log_datetime` DATETIME NOT NULL,
  `authorize_net_relay_log_updated_datetime` DATETIME NOT NULL,
  `authorize_net_relay_log_data` TEXT NOT NULL,
  `authorize_net_relay_log_verified` CHAR(1) NOT NULL DEFAULT '0',
  `authorize_net_relay_log_invoice` VARCHAR(100) NOT NULL,
  `authorize_net_relay_log_deleted` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`, `authorize_net_relay_log_id`),
  UNIQUE INDEX `NewIndex1` (`site_id`)
)")){
		return false;
	}  
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "authorize_net_relay_log", "authorize_net_relay_log_id");
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>