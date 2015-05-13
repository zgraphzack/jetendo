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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event`   
  ADD COLUMN `event_date_description` VARCHAR(255) NOT NULL AFTER `event_image_library_layout`,
  ADD COLUMN `event_summary` TEXT NOT NULL AFTER `event_date_description`")){
		return false;
	}  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event_calendar`   
  ADD COLUMN `event_calendar_list_default_view` VARCHAR(20) NOT NULL AFTER `event_calendar_user_group_idlist`,
  ADD COLUMN `event_calendar_list_views` VARCHAR(50) NOT NULL AFTER `event_calendar_list_default_view`,
  ADD COLUMN `event_calendar_list_perpage` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `event_calendar_list_views`")){
		return false;
	}  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event_config`   
  ADD COLUMN `event_config_event_recur_url_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `event_config_category_url_id`,
  ADD COLUMN `event_config_disable_recur_indexing` CHAR(1) DEFAULT '0'  NOT NULL AFTER `event_config_event_recur_url_id`")){
		return false;
	}  

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>