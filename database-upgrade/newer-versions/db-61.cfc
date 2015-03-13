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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_x_option_group_set`   
  ADD COLUMN `site_x_option_group_set_metatitle` VARCHAR(255) NOT NULL AFTER `site_x_option_group_set_deleted`,
  ADD COLUMN `site_x_option_group_set_metakey` VARCHAR(255) NOT NULL AFTER `site_x_option_group_set_metatitle`,
  ADD COLUMN `site_x_option_group_set_metadesc` VARCHAR(255) NOT NULL AFTER `site_x_option_group_set_metakey`	")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_option_group`   
  ADD COLUMN `site_option_group_enable_meta` CHAR(1) DEFAULT '0'  NOT NULL AFTER `section_id`	")){
		return false;
	}

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>