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
	/*
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_option_group`   
	ADD COLUMN `site_option_group_ajax_enabled` CHAR(1) DEFAULT '0'   NOT NULL AFTER `site_option_group_reservation_type_id_list`")){
		return false;
	} */
	/*
ALTER TABLE `blog`   
  ADD COLUMN `section_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `blog_show_all_sections`, 
  ADD  INDEX `NewIndex2` (`section_id`, `blog_deleted`);

CREATE TABLE `layout_config`(  
  `layout_config_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL,
  `layout_config_section_url_id` INT(11) UNSIGNED NOT NULL,
  `layout_config_landing_page_url_id` INT(11) UNSIGNED NOT NULL,
  `layout_config_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
  `layout_config_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `layout_config_id`, `layout_config_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `section`(  
  `section_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL,
  `section_uuid` CHAR(35) NOT NULL DEFAULT '',
  `section_parent_id` INT(11) UNSIGNED NOT NULL,
  `section_name` VARCHAR(255) NOT NULL,
  `section_unique_url` VARCHAR(255) NOT NULL,
  `section_child_layout_page_id` INT UNSIGNED NOT NULL,
  `section_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
  `section_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `section_id`, `section_deleted`),
  UNIQUE INDEX `NewIndex1` (`site_id`, `section_parent_id`, `section_name`, `section_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `section_content_type`(  
  `section_content_type_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `section_content_type_name` VARCHAR(100) NOT NULL,
  `section_content_type_cfc_path` VARCHAR(255) NOT NULL,
  `section_content_type_cfc_method` VARCHAR(100) NOT NULL,
  `section_content_type_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
  `section_content_type_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`section_content_type_id`),
  UNIQUE INDEX `NewIndex1` (`section_content_type_name`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `layout_preset`( 
	`layout_preset_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_preset_uuid` CHAR(35) NOT NULL DEFAULT '',
	`layout_page_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_preset_name`
	`layout_preset_active` CHAR(1) NOT NULL DEFAULT 0,
	`layout_preset_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
	`layout_preset_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `layout_preset_id`, `layout_preset_deleted`),
  UNIQUE KEY `NewIndex1` (`site_id`, `layout_preset_name`, `layout_preset_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `layout_page`( 
	layout_page_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	layout_page_uuid` CHAR(35) NOT NULL DEFAULT '',
	layout_page_name - unique index for this + site_id
	layout_preset_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	layout_preset_name` VARCHAR(255) NOT NULL,
	layout_preset_modified` CHAR(1) NOT NULL DEFAULT 0,
	site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	layout_page_active` CHAR(1) NOT NULL DEFAULT 0,
	layout_page_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
	layout_page_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `layout_page_id`, `layout_page_deleted`),
  UNIQUE INDEX `NewIndex1` (`site_id`, `layout_page_name`, `layout_page_name`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `landing_page`( 
	`landing_page_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`landing_page_uuid` CHAR(35) NOT NULL DEFAULT '',
	`landing_page_parent_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`landing_page_meta_title
	`layout_page_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`user_group_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`landing_page_unique_url` VARCHAR(255) NOT NULL DEFAULT '',
	`landing_page_metakey` TEXT NOT NULL,
	`landing_page_metadesc` TEXT NOT NULL,
	`landing_page_sort` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`section_content_type_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`section_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`landing_page_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
	`landing_page_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `landing_page_id`, `landing_page_deleted`),
  UNIQUE INDEX `NewIndex1` (`site_id`, `landing_page_unique_url`, `landing_page_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `landing_page_x_widget`( 
	`landing_page_x_widget_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`landing_page_x_widget_uuid` CHAR(35) NOT NULL DEFAULT '',
	`landing_page_x_widget_sort` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`widget_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`section_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`landing_page_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`site_x_option_group_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`landing_page_x_widget_json_data LONGTEXT,
	`landing_page_x_widget_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
	`landing_page_x_widget_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `landing_page_x_widget_id`, `landing_page_x_widget_deleted`),
  KEY `NewIndex1` (`site_id`, `widget_id`, `landing_page_id`, `landing_page_x_widget_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `layout_row`( 
	`layout_row_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_page_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_row_uuid` CHAR(35) NOT NULL DEFAULT '',
	`layout_row_active` CHAR(1) NOT NULL DEFAULT 0,
	`site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_row_updated_datetime` DATETIME UNSIGNED NOT NULL DEFAULT '0000-00-00 00:00:00',
	`layout_row_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `layout_row_id`, `layout_row_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `layout_column`( 
	`layout_row_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_uuid` CHAR(35) NOT NULL DEFAULT '',
	`layout_page_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_updated_datetime` DATETIME NOT NULL '0000-00-00 00:00:00',
	`layout_column_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `layout_column_id`, `layout_column_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `layout_column_x_widget`( 
	`layout_column_x_widget_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_widget_uuid` CHAR(35) NOT NULL DEFAULT '',
	`layout_column_x_widget_sort` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_widget_repeat_limit` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`widget_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_widget_updated_datetime DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
	`layout_column_x_widget_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `layout_column_x_widget_id`, `layout_column_x_widget_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `layout_row_x_breakpoint`( 
	`layout_row_x_breakpoint_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_row_x_breakpoint_uuid` CHAR(35) NOT NULL DEFAULT '',
	`layout_row_x_breakpoint_value` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_row_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_row_x_breakpoint_visible` CHAR(1) NOT NULL DEFAULT 0,
	`layout_row_x_breakpoint_sort` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_row_x_breakpoint_gutter_size` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_row_x_breakpoint_margin` varchar(30) NOT NULL DEFAULT '',
	`layout_row_x_breakpoint_padding` varchar(30) NOT NULL DEFAULT '',
	`layout_row_x_breakpoint_border` varchar(30) NOT NULL DEFAULT '',
	`layout_row_x_breakpoint_border_radius` varchar(30) NOT NULL DEFAULT '',
	`layout_row_x_breakpoint_background` TEXT NOT NULL,
	`site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_row_x_breakpoint_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
	`layout_row_x_breakpoint_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `layout_row_x_breakpoint_id`, `layout_row_x_breakpoint_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `layout_column_x_breakpoint`( 
	`layout_column_x_breakpoint_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_breakpoint_uuid` CHAR(35) NOT NULL DEFAULT '',
	`layout_column_x_breakpoint_value` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_breakpoint_visible` CHAR(1) NOT NULL DEFAULT 0,
	`layout_column_x_breakpoint_sort` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_breakpoint_margin` varchar(30) NOT NULL DEFAULT '',
	`layout_column_x_breakpoint_padding` varchar(30) NOT NULL DEFAULT '',
	`layout_column_x_breakpoint_border` varchar(30) NOT NULL DEFAULT '',
	`layout_column_x_breakpoint_border_radius` varchar(30) NOT NULL DEFAULT '',
	`layout_column_x_breakpoint_width` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_breakpoint_height` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_breakpoint_background TEXT NOT NULL,
	`site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_breakpoint_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
	`layout_column_x_breakpoint_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `layout_column_x_breakpoint_id`, `layout_column_x_breakpoint_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `layout_column_x_widget_x_breakpoint`( 
	`layout_column_x_widget_x_breakpoint_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_widget_x_breakpoint_uuid` CHAR(35) NOT NULL DEFAULT '',
	`layout_column_x_widget_x_breakpoint_value int(11) unsigned not null default 0,
	`layout_column_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`widget_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_widget_x_breakpoint_visible` char(1) NOT NULL DEFAULT 0,
	`layout_column_x_widget_x_breakpoint_sort` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_widget_x_breakpoint_margin` varchar(30) NOT NULL DEFAULT '',
	`layout_column_x_widget_x_breakpoint_padding` varchar(30) NOT NULL DEFAULT '',
	`layout_column_x_widget_x_breakpoint_border` varchar(30) NOT NULL DEFAULT '',
	`layout_column_x_widget_x_breakpoint_border_radius` varchar(30) NOT NULL DEFAULT '',
	`layout_column_x_widget_x_breakpoint_column_gutter_size` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_widget_x_breakpoint_background TEXT NOT NULL,
	`site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`layout_column_x_widget_x_breakpoint_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
	`layout_column_x_widget_x_breakpoint_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `layout_column_x_widget_x_breakpoint_id`, `layout_column_x_widget_x_breakpoint_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `widget`
	`widget_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`widget_name` VARCHAR(100) NOT NULL DEFAULT '',
	`widget_display_name` VARCHAR(100) NOT NULL DEFAULT '',
	`widget_concurrent_server_loading_enabled` CHAR(1) NOT NULL DEFAULT 0,
	`widget_has_preview` CHAR(1) NOT NULL DEFAULT 0,
	`widget_options_type` CHAR(1) NOT NULL DEFAULT 0,
	`site_x_option_group_set_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`widget_options_cfc_path VARCHAR(255) NOT NULL DEFAULT '',
	`widget_site_singleton` CHAR(1) NOT NULL DEFAULT 0,
	`widget_page_singleton` CHAR(1) NOT NULL DEFAULT 0,
	`widget_repeat_limit` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`widget_column_count` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`widget_margin` varchar(30) NOT NULL DEFAULT '',
	`widget_padding` varchar(30) NOT NULL DEFAULT '',
	`widget_border` varchar(30) NOT NULL DEFAULT '',
	`widget_border_radius` varchar(30) NOT NULL DEFAULT '',
	`widget_column_gutter_size` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`widget_width` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`widget_height` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`widget_minimum_height` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`widget_maximum_width` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`widget_login_required` CHAR(1) NOT NULL DEFAULT 0,
	`widget_custom_json` TEXT NOT NULL,
	`user_group_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	`widget_updated_datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
	`widget_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `widget_id`, `widget_deleted`),
  UNIQUE INDEX `NewIndex1` (`site_id`, `widget_name`, `widget_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;



	*/
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>