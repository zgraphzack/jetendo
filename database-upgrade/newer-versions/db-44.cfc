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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `reservation`   
	CHANGE `reservation_reminder_datetime` `reservation_reminder_email_sent_x_days` INT(11) UNSIGNED DEFAULT 0  NOT NULL
  ADD COLUMN `reservation_search` LONGTEXT NOT NULL AFTER `site_id`,
  ADD COLUMN `site_x_option_group_set_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `reservation_search`,
  ADD COLUMN `reservation_guests` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `site_x_option_group_set_id`,
  ADD COLUMN `reservation_custom_json` LONGTEXT NOT NULL AFTER `reservation_guests`,
  ADD COLUMN `reservation_key` VARCHAR(40) NOT NULL AFTER `reservation_custom_json`")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `reservation_allowed_hours`   
  ADD COLUMN `reservation_type_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `reservation_allowed_hours_id`")){
		return false;
	} 
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `reservation_excluded_hours`   
  ADD COLUMN `reservation_type_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `reservation_excluded_hours_id`")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `reservation_type`   
  ADD COLUMN `reservation_type_max_guests` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `site_id`,
  ADD COLUMN `reservation_type_max_reservations` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `reservation_type_max_guests`,
  ADD  UNIQUE INDEX `NewIndex1` (`site_id`, `reservation_type_name`, `reservation_type_deleted`)")){
		return false;
	} 
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `reservation_config`   
  ADD COLUMN `reservation_config_availability_in_memory` CHAR(1) DEFAULT '0'   NOT NULL AFTER `site_id`,
  ADD COLUMN `reservation_config_new_reservation_status` INT(11) UNSIGNED DEFAULT 1  NOT NULL AFTER `reservation_config_availability_in_memory` ")){
		return false;
	} 


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>