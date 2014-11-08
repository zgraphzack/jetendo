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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_x_option`   
  ADD COLUMN `site_x_option_original` VARCHAR(255) NOT NULL AFTER `site_x_option_deleted`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_x_option_group`   
  ADD COLUMN `site_x_option_original` VARCHAR(255) NOT NULL AFTER `site_x_option_group_deleted`")){
		return false;
	}

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>