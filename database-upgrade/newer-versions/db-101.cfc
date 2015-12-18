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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_option_group`   
  ADD COLUMN `site_option_group_change_cfc_path` VARCHAR(100) NOT NULL AFTER `site_option_group_list_description`,
  ADD COLUMN `site_option_group_change_cfc_update_method` VARCHAR(50) NOT NULL AFTER `site_option_group_change_cfc_path`,
  ADD COLUMN `site_option_group_change_cfc_delete_method` VARCHAR(50) NOT NULL AFTER `site_option_group_change_cfc_update_method`,
  ADD COLUMN `site_option_group_change_cfc_sort_method` VARCHAR(50) NOT NULL AFTER `site_option_group_change_cfc_delete_method`")){
		return false;
	}  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>