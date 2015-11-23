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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `authorize_net_relay_log`   
  CHANGE `authorize_net_relay_log_id` `authorize_net_relay_log_id` INT(11) UNSIGNED NOT NULL,
  CHANGE `site_id` `site_id` INT(11) UNSIGNED NOT NULL")){
		return false;
	}  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>