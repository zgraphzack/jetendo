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
  ADD COLUMN `site_x_option_group_set_master_set_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `site_x_option_group_set_metadesc`,
  ADD COLUMN `site_x_option_group_set_version_status` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_x_option_group_set_master_set_id`, 
  DROP INDEX `NewIndex3`,
  ADD  INDEX `NewIndex3` (`site_id`, `site_option_group_id`),
  DROP INDEX `NewIndex4`,
  ADD  INDEX `NewIndex4` (`site_id`, `site_option_group_id`, `site_x_option_group_set_start_date`, `site_x_option_group_set_end_date`),
  ADD  INDEX `NewIndex5` (`site_id`, `site_x_option_group_set_parent_id`, `site_x_option_group_set_master_set_id`);
")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_option_group`   
  ADD COLUMN `site_option_group_enable_versioning` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_option_group_enable_list_recurse`,
  ADD COLUMN `site_option_group_version_limit` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `site_option_group_enable_versioning`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_option`    ADD  INDEX `NewIndex4` (`site_id`, `site_option_group_id`)")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>