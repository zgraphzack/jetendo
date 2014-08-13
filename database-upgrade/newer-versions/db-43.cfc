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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#event_category`(  
  `event_category_id` INT(11) UNSIGNED NOT NULL,
  `event_category_name` VARCHAR(255) NOT NULL,
  `event_category_description` LONGTEXT NOT NULL,
  `site_id` INT(11) NOT NULL,
  `event_category_updated_datetime` DATETIME NOT NULL,
  `event_category_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`event_category_id`, `site_id`),
  UNIQUE INDEX `NewIndex1` (`site_id`, `event_category_name`, `event_category_deleted`)
) ENGINE=InnoDB, CHARSET=utf8, COLLATE=utf8_general_ci")){
		return false;
	} 
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#event_x_category`(  
  `event_x_category_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `event_category_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `event_x_category_updated_datetime` DATETIME NOT NULL,
  `event_x_category_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `event_x_category_id`),
  UNIQUE INDEX `NewIndex1` (`site_id`, `event_category_id`, `event_x_category_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	} 
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#event_config`(  
	  `event_config_id` INT(11) UNSIGNED NOT NULL,
	  `event_config_schedule_ical_import` CHAR(1) NOT NULL DEFAULT '0',
	  `event_config_ical_url_list` TEXT NOT NULL,
	  `event_config_project_recurrence_days` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `event_config_updated_datetime` DATETIME NOT NULL,
	  `event_config_deleted` CHAR(1) NOT NULL DEFAULT '0',
	  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  PRIMARY KEY (`site_id`, `event_config_id`),
	  UNIQUE INDEX `NewIndex1` (`site_id`, `event_config_deleted`)
	) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	} 
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#reservation_allowed_hours`(  
	  `reservation_allowed_hours_id` INT(11) UNSIGNED NOT NULL,
	  `reservation_allowed_hours_day_of_week` VARCHAR(10) NOT NULL,
	  `reservation_allowed_hours_start_time` TIME NOT NULL,
	  `reservation_allowed_hours_end_time` TIME NOT NULL,
	  `reservation_allowed_hours_all_day` CHAR(1) NOT NULL DEFAULT '0',
	  `reservation_allowed_hours_updated_datetime` DATETIME NOT NULL,
	  `reservation_allowed_hours_deleted` INT(11) NOT NULL,
	  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  PRIMARY KEY (`site_id`, `reservation_allowed_hours_id`)
	) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	} 
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#reservation_excluded_hours`(  
	  `reservation_excluded_hours_id` INT(11) UNSIGNED NOT NULL,
	  `reservation_excluded_hours_date` DATE NOT NULL,
	  `reservation_excluded_hours_start_time` TIME NOT NULL,
	  `reservation_excluded_hours_end_time` TIME NOT NULL,
	  `reservation_excluded_hours_all_day` CHAR(1) NOT NULL DEFAULT '0',
	  `reservation_excluded_hours_updated_datetime` DATETIME NOT NULL,
	  `reservation_excluded_hours_deleted` INT(11) NOT NULL DEFAULT 0,
	  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  PRIMARY KEY (`site_id`, `reservation_excluded_hours_id`)
	) ENGINE=InnoDB, CHARSET=utf8, COLLATE=utf8_general_ci")){
		return false;
	} 
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#reservation_payment_type`(  
	  `reservation_payment_type_id` INT(11) NOT NULL,
	  `reservation_type_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `reservation_payment_type_amount` DECIMAL(11,2) NOT NULL,
	  `reservation_payment_type_title` VARCHAR(255) NOT NULL,	
	  `reservation_payment_type_description` TEXT NOT NULL,
	  `reservation_payment_type_updated_datetime` DATETIME NOT NULL,
	  `reservation_payment_type_deleted` CHAR(1) NOT NULL DEFAULT '0',
	  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  PRIMARY KEY (`site_id`, `reservation_payment_type_id`)
	) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	} 
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#reservation_type`(  
	  `reservation_type_id` INT UNSIGNED NOT NULL,
	  `reservation_type_name` VARCHAR(255) NOT NULL,
	  `reservation_type_period` VARCHAR(10) NOT NULL,
	  `reservation_type_start_datetime` DATETIME NOT NULL,
	  `reservation_type_end_datetime` DATETIME NOT NULL,
	  `reservation_type_forever` CHAR(1) NOT NULL DEFAULT '0',
	  `reservation_type_contract_enabled` CHAR(1) NOT NULL DEFAULT '0',
	  `reservation_type_payment_enabled` CHAR(1) NOT NULL DEFAULT '0',
	  `reservation_type_payment_required` CHAR(1) NOT NULL DEFAULT '0',
	  `reservation_type_payment_type_list` CHAR(1) NOT NULL DEFAULT '0',
	  `reservation_type_new_reservation_status` INT(11) UNSIGNED NOT NULL DEFAULT 1,
	  `reservation_type_minimum_length` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `reservation_type_maximum_length` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `reservation_type_minimum_hours_before_reservation` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `reservation_type_validator_cfc_path` VARCHAR(255) NOT NULL,
	  `reservation_type_validator_cfc_method` VARCHAR(100) NOT NULL,
	  `reservation_type_view_cfc_path` VARCHAR(255) NOT NULL,
	  `reservation_type_view_cfc_method` VARCHAR(100) NOT NULL,
	  `reservation_type_list_cfc_path` VARCHAR(255) NOT NULL,
	  `reservation_type_list_cfc_method` VARCHAR(100) NOT NULL,
	  `reservation_type_status` CHAR(1) NOT NULL DEFAULT '0',
	  `reservation_type_updated_datetime` DATETIME NOT NULL,
	  `reservation_type_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `site_id` INT(11) NOT NULL,
	  PRIMARY KEY (`site_id`, `reservation_type_id`)
	) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	} 
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#reservation_config`(  
	  `reservation_config_id` INT(11) UNSIGNED NOT NULL,
	  `reservation_config_order_confirmation_email_list` VARCHAR(100) NOT NULL,
	  `reservation_config_order_change_email_list` VARCHAR(100) NOT NULL,
	  `reservation_config_payment_failure_email_list` VARCHAR(100) NOT NULL,
	  `reservation_config_destination_on_email` CHAR(1) NOT NULL DEFAULT '0',
	  `reservation_config_email_reminder_subject` VARCHAR(255) NOT NULL,
	  `reservation_config_email_reminder_header` TEXT NOT NULL,
	  `reservation_config_email_creation_subject` VARCHAR(255) NOT NULL,
	  `reservation_config_email_creation_header` TEXT NOT NULL,
	  `reservation_config_email_change_subject` VARCHAR(255) NOT NULL,
	  `reservation_config_email_change_header` TEXT NOT NULL,
	  `reservation_config_email_cancelled_subject` VARCHAR(255) NOT NULL,
	  `reservation_config_email_cancelled_header` TEXT NOT NULL,
	  `reservation_config_reminder_days_list` VARCHAR(30) NOT NULL,
	  `reservation_config_soonest_reservation_days` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `reservation_config_furthest_reservation_days` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `reservation_config_updated_datetime` DATETIME NOT NULL,
	  `reservation_config_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  PRIMARY KEY (`site_id`, `reservation_config_id`),
	  UNIQUE INDEX `NewIndex1` (`site_id`, `reservation_config_deleted`)
	) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	} 
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#reservation`(  
  `reservation_id` INT(11) UNSIGNED NOT NULL,
  `reservation_period` VARCHAR(10) NOT NULL,
  `event_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `payment_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `reservation_type_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `reservation_record_table` VARCHAR(100) NOT NULL,
  `reservation_record_where_json` TEXT NOT NULL,
  `reservation_first_name` VARCHAR(50) NOT NULL,
  `reservation_last_name` VARCHAR(50) NOT NULL,
  `reservation_company` VARCHAR(100) NOT NULL,
  `reservation_phone` VARCHAR(30) NOT NULL,
  `reservation_email` VARCHAR(100) NOT NULL,
  `reservation_comments` TEXT NOT NULL,
  `reservation_destination_title` VARCHAR(255) NOT NULL,
  `reservation_destination_url` VARCHAR(500) NOT NULL,
  `reservation_destination_address` VARCHAR(100) NOT NULL,
  `reservation_destination_address2` VARCHAR(100) NOT NULL,
  `reservation_destination_city` VARCHAR(100) NOT NULL,
  `reservation_destination_state` VARCHAR(10) NOT NULL,
  `reservation_destination_zip` VARCHAR(10) NOT NULL,
  `reservation_destination_country` VARCHAR(50) NOT NULL,
  `reservation_start_datetime` DATETIME NOT NULL,
  `reservation_end_datetime` DATETIME NOT NULL,
  `reservation_reminder_datetime` DATETIME NOT NULL,
  `reservation_created_datetime` DATETIME NOT NULL,
  `reservation_updated_datetime` DATETIME NOT NULL,
  `reservation_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `reservation_status` INT(11) UNSIGNED NOT NULL DEFAULT 1,
  `site_option_app_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`reservation_id`, `site_id`),
  INDEX `NewIndex1` (`site_id`, `reservation_start_datetime`, `reservation_end_datetime`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#event`   
  ADD COLUMN `event_reservation_enabled` CHAR(1) DEFAULT '0'   NOT NULL AFTER `event_deleted`,
  ADD COLUMN `event_status` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `event_reservation_enabled`,
  ADD COLUMN `site_option_app_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `event_status`, 
  DROP PRIMARY KEY,
  ADD PRIMARY KEY (`event_id`, `site_id`)")){
		return false;
	} 
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#site_option`   
	ADD COLUMN `site_option_reservation_type_id_list` VARCHAR(255) NOT NULL AFTER `site_option_deleted`")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#site_option_group`   
	ADD COLUMN `site_option_group_reservation_type_id_list` VARCHAR(255) NOT NULL AFTER `site_option_group_deleted`")){
		return false;
	} 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>