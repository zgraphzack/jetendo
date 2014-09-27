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
CREATE TABLE `layout_config`(  
  `layout_config_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL,
  `layout_config_section_url_id` INT(11) UNSIGNED NOT NULL,
  `layout_config_landing_page_url_id` INT(11) UNSIGNED NOT NULL,
  `layout_config_updated_datetime` DATETIME NOT NULL,
  `layout_config_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `layout_config_id`, `layout_config_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `section`(  
  `section_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL,
  `section_uuid` VARCHAR(35) NOT NULL,
  `section_parent_id` INT(11) UNSIGNED NOT NULL,
  `section_name` VARCHAR(255) NOT NULL,
  `section_unique_url` VARCHAR(255) NOT NULL,
  `section_child_layout_page_id` INT UNSIGNED NOT NULL,
  `section_updated_datetime` DATETIME NOT NULL,
  `section_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `section_id`, `section_deleted`),
  UNIQUE INDEX `NewIndex1` (`site_id`, `section_parent_id`, `section_name`, `section_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin;



	section_content_type
		section_content_type_id
		section_content_type_name
		section_content_type_cfc_path
		section_content_type_cfc_method

		this cfc might need to follow the "section" interface functions instead of having a method field.

		the cfc is meant to be an adapter to fit the blog/page/rental/event/listing/etc to a single section manager interface.

	layout_preset
		layout_preset_id
		layout_preset_uuid
		layout_page_id
		site_id = 0 is global
		layout_preset_name
		layout_preset_active 0 / 1

	layout_page
		layout_page_id
		layout_page_uuid
		layout_page_name - unique index for this + site_id
		layout_preset_id
		layout_preset_name
		layout_preset_modified 0 / 1 - if any row, widget, widget, page setting is modified, then the preset is "unlinked" from the current layout_page_id.
		site_id
		layout_page_active 0 / 1

	landing_page
		landing_page_id
		landing_page_uuid
		landing_page_parent_id
		landing_page_meta_title
		layout_page_id
		user_group_id
		landing_page_unique_url
		landing_page_metakey
		landing_page_metadesc
		landing_page_sort
		section_content_type_id
		section_id
		site_id

	landing_page_x_widget - This table is a single "instance" of a widget and stores a reference to the widget options or the full json if this widget uses a custom CFC.
		landing_page_x_widget_id
		landing_page_x_widget_uuid
		landing_page_x_widget_sort
		site_id
		widget_id
		section_id
		landing_page_id
		site_x_option_group_id
		landing_page_x_widget_json_data LONGTEXT

	some widgets allow themselves to be repeated, so the landing page editor will allow Editing the first one, and then adding another afterwards if desired.

	layout_row
		layout_page_id
		layout_row_uuid
		layout_row_active 0 / 1
		site_id

	layout_column
		layout_row_id
		layout_column_uuid
		layout_page_id
		site_id

	layout_column_x_widget - a single instance of a widget attached to a layout.
		layout_column_x_widget_id
		layout_column_x_widget_uuid
		layout_column_x_widget_sort
		layout_column_x_widget_repeat_limit = 0, 1, X or 10000 for unlimited
		layout_column_id
		widget_id
		site_id

	layout_row_x_breakpoint
		layout_row_x_breakpoint_id
		layout_row_x_breakpoint_uuid
		layout_row_x_breakpoint_value (320, 640, 960, etc)
		layout_row_id
		layout_row_x_breakpoint_visible 0 / 1 - display css toggle for the current breakpoint
		layout_row_x_breakpoint_sort
		layout_row_x_breakpoint_gutter_size int 0 to X - ensure equal separation in between all columns in row with no margin on the left or right most column
		layout_row_x_breakpoint_margin varchar(30) 0px 0px 0px 0px format
		layout_row_x_breakpoint_padding varchar(30) 0px 0px 0px 0px format
		layout_row_x_breakpoint_border varchar(30) 0px 0px 0px 0px format
		layout_row_x_breakpoint_border_radius varchar(30) 0px 0px 0px 0px format
		layout_row_x_breakpoint_background (css background configuration - allow multiple layers of backgrounds)
		site_id

	layout_column_x_breakpoint
		layout_column_x_breakpoint_id
		layout_column_x_breakpoint_uuid
		layout_column_x_breakpoint_value (320, 640, 960, etc)
		layout_column_id
		layout_column_x_breakpoint_visible 0 / 1 - display css toggle for the current breakpoint
		layout_column_x_breakpoint_sort (overrides layout_column_sort)
		layout_column_x_breakpoint_margin varchar(30) 0px 0px 0px 0px format
		layout_column_x_breakpoint_padding varchar(30) 0px 0px 0px 0px format
		layout_column_x_breakpoint_border varchar(30) 0px 0px 0px 0px format
		layout_column_x_breakpoint_border_radius varchar(30) 0px 0px 0px 0px format
		layout_column_x_breakpoint_width = int 0 to X - 0 is auto
		layout_column_x_breakpoint_height = int 0 to X - 0 is auto
		layout_column_x_breakpoint_background (css background configuration - allow multiple layers of backgrounds)
		site_id

	layout_column_x_widget_x_breakpoint
		layout_column_x_widget_x_breakpoint_id
		layout_column_x_widget_x_breakpoint_uuid
		layout_column_x_widget_x_breakpoint_value (320, 640, 960, etc)
		layout_column_id
		widget_id
		layout_column_x_widget_x_breakpoint_visible 0 / 1 - display css toggle for the current breakpoint
		layout_column_x_widget_x_breakpoint_sort (overrides layout_column_sort)
		// the spacing options are inherited from the "widget" record
		layout_column_x_widget_x_breakpoint_margin varchar(30) 0px 0px 0px 0px format
		layout_column_x_widget_x_breakpoint_padding varchar(30) 0px 0px 0px 0px format
		layout_column_x_widget_x_breakpoint_border varchar(30) 0px 0px 0px 0px format
		layout_column_x_widget_x_breakpoint_border_radius varchar(30) 0px 0px 0px 0px format
		layout_column_x_widget_x_breakpoint_column_gutter_size int 0 to X - ensure equal separation in between repeated widget, but not on sides instead of using individual margin/padding
		layout_column_x_widget_x_breakpoint_background
		site_id


	widget (for search / filtering)
		widget_id
		widget_name (can't be edited after first insert)
		widget_display_name
		widget_concurrent_server_loading_enabled (0 / 1 - determines if parallel loading is possible)
		widget_has_preview 0 / 1 - if widget doesn't implement preview function, then it will look more generic in the layout editor
		widget_options_type (0 is Site Option system, 1 is Custom CFC)
		site_x_option_group_set_id
		widget_options_cfc_path
		widget_site_singleton 0 / 1 - some widgets must be globally unique, others can be inserted many times with different settings.
		widget_page_singleton 0 / 1 - some widgets will only work when embedded once on a single page.
		widget_repeat_limit int 1 to X
		widget_column_count int 1 to X // this force repetition in preview mode, and adjusts the width calculation
		widget_margin varchar(30) 0px 0px 0px 0px format
		widget_padding varchar(30) 0px 0px 0px 0px format
		widget_border varchar(30) 0px 0px 0px 0px format
		widget_border_radius varchar(30) 0px 0px 0px 0px format
		widget_column_gutter_size int 0 to X - ensure equal separation in between repeated widget, but not on sides instead of using individual margin/padding
		widget_width = int 0 to X - 0 is auto
		widget_height = int 0 to X - 0 is auto
		widget_minimum_height = 0 or X
		widget_maximum_width = 0 or X
		widget_login_required
		widget_custom_json - only used for the custom widget type, which gives the user a freeform multi-layer mock up editor.
		user_group_id int (a login for the selected user group is required for widget)
		site_id - 0 is global
		(site_id + widget_name unique index)



	*/
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>