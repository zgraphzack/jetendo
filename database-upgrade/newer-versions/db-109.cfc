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
  ADD COLUMN `site_option_group_enable_user_dashboard_admin` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_option_group_change_cfc_sort_method`,
  ADD COLUMN `site_option_group_user_child_limit` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `site_option_group_enable_user_dashboard_admin`,
  ADD COLUMN `site_option_group_user_id_field` VARCHAR(50) NOT NULL AFTER `site_option_group_user_child_limit`,
  ADD COLUMN `site_option_group_allow_delete_usergrouplist` VARCHAR(255) NOT NULL AFTER `site_option_group_user_id_field`,
  ADD COLUMN `site_option_group_subgroup_alternate_admin` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_option_group_allow_delete_usergrouplist`")){
		return false;
	}   
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>