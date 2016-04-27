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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `user`   
  ADD COLUMN `user_reset_key` VARCHAR(64) NOT NULL AFTER `user_site_option_group_id_list_limit`,
  ADD COLUMN `user_reset_datetime` DATETIME NOT NULL AFTER `user_reset_key`")){
		return false;
	}     
	

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>