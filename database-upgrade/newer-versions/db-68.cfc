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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event_category`   
  ADD COLUMN `event_calendar_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `event_category_deleted`,
  ADD COLUMN `event_category_unique_url` VARCHAR(255) NOT NULL AFTER `event_calendar_id`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event`   
  ADD COLUMN `event_calendar_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `site_option_app_id`,
  ADD COLUMN `event_unique_url` VARCHAR(255) NOT NULL AFTER `event_calendar_id`,
  ADD COLUMN `event_address` VARCHAR(100) NOT NULL AFTER `event_unique_url`,
  ADD COLUMN `event_address2` VARCHAR(100) NOT NULL AFTER `event_address`,
  ADD COLUMN `event_city` VARCHAR(100) NOT NULL AFTER `event_address2`,
  ADD COLUMN `event_state` VARCHAR(2) NOT NULL AFTER `event_city`,
  ADD COLUMN `event_country` VARCHAR(2) NOT NULL AFTER `event_state`,
  ADD COLUMN `event_zip` VARCHAR(10) NOT NULL AFTER `event_country`,
  ADD COLUMN `event_allday` VARCHAR(10) NOT NULL AFTER `event_zip`,
  ADD COLUMN `event_category_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `event_allday`,
  ADD COLUMN `event_website` VARCHAR(255) NOT NULL AFTER `event_category_id`,
  ADD COLUMN `event_file1` VARCHAR(255) NOT NULL AFTER `event_website`,
  ADD COLUMN `event_file1label`VARCHAR(255) NOT NULL AFTER `event_file1`,
  ADD COLUMN `event_file2` VARCHAR(255) NOT NULL AFTER `event_file1label`,
  ADD COLUMN `event_file2label` VARCHAR(255) NOT NULL AFTER `event_file2`,
  ADD COLUMN `event_featured` CHAR(1) DEFAULT 0 NOT NULL AFTER `event_file2label`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `event_calendar`(  
  `event_calendar_id` INT(11) UNSIGNED NOT NULL,
  `event_calendar_name` VARCHAR(200) NOT NULL,
  `event_calendar_unique_url` VARCHAR(200) NOT NULL,
  `event_calendar_updated_datetime` DATETIME NOT NULL,
  `event_calendar_deleted` CHAR(1) NOT NULL DEFAULT '0',
  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`event_calendar_id`,`site_id`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event_config`   
  ADD COLUMN `event_config_event_url_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `site_id`,
  ADD COLUMN `event_config_calendar_url_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `event_config_event_url_id`,
  ADD COLUMN `event_config_category_url_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `event_config_calendar_url_id`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event_x_category`   
  ADD COLUMN `event_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `event_x_category_deleted`, 
  DROP INDEX `NewIndex1`,
  ADD  UNIQUE INDEX `NewIndex1` (`site_id`, `event_category_id`, `event_id`, `event_x_category_deleted`),
  ADD  INDEX `NewIndex2` (`site_id`, `event_category_id`),
  ADD  INDEX `NewIndex3` (`site_id`, `event_id`)")){
		return false;
	}
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "event_calendar", "event_calendar_id");
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>