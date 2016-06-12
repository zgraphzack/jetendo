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
ADD COLUMN `site_option_group_enable_new_button` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_option_group_is_home_page`")){
		return false;
	}       
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `grid_group`(  
  `grid_group_id` INT UNSIGNED NOT NULL,
  `site_id` INT UNSIGNED NOT NULL,
  `grid_id` INT(11) UNSIGNED NOT NULL,
  `grid_group_heading` VARCHAR(255) NOT NULL,
  `grid_group_heading2` VARCHAR(255) NOT NULL,
  `grid_group_sort` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `grid_group_section_center` CHAR(1) NOT NULL DEFAULT '0',
  `grid_group_children_center` CHAR(1) NOT NULL DEFAULT '0',
  `grid_group_column_count` INT(11) NOT NULL,
  `grid_group_padding` VARCHAR(30) NOT NULL,
  `grid_group_box_layout` INT(11) NOT NULL DEFAULT 0,
  `grid_group_box_border` VARCHAR(30) NOT NULL,
  `grid_group_box_border_radius` INT(11) NOT NULL DEFAULT 0,
  `grid_group_box_background_type` INT(11) NOT NULL,
  `grid_group_box_background_value` TEXT NOT NULL,
  `grid_group_background_type` INT(11) NOT NULL DEFAULT 0,
  `grid_group_background_value` TEXT NOT NULL,
  `grid_group_visible` CHAR(1) NOT NULL DEFAULT '1',
  `grid_group_text` LONGTEXT NOT NULL,
  `grid_group_updated_datetime` DATETIME NOT NULL,
  `grid_group_deleted` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`grid_group_id`, `site_id`),
  INDEX `NewIndex1` (`site_id`),
  INDEX `NewIndex2` (`site_id`, `grid_id`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	}      
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `grid`(  
  `grid_id` INT UNSIGNED NOT NULL,
  `site_id` INT UNSIGNED NOT NULL,
  `grid_active` CHAR(1) NOT NULL DEFAULT '0',
  `grid_visible` CHAR(1) NOT NULL DEFAULT '1',
  `grid_updated_datetime` DATETIME NOT NULL,
  `grid_deleted` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`grid_id`, `site_id`),
  INDEX `NewIndex1` (`site_id`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	}      
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `grid_box`(  
  `grid_box_id` INT UNSIGNED NOT NULL,
  `site_id` INT UNSIGNED NOT NULL,
  `grid_id` INT(11) UNSIGNED NOT NULL,
  `grid_group_id` INT(11) UNSIGNED NOT NULL,
  `grid_box_sort` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `grid_box_heading` VARCHAR(255) NOT NULL, 
  `grid_box_column_size` INT(11) NOT NULL, 
  `grid_box_image` VARCHAR(255) NOT NULL DEFAULT 0,
  `grid_box_button_text` VARCHAR(100) NOT NULL,
  `grid_box_button_url` VARCHAR(255) NOT NULL, 
  `grid_box_visible` CHAR(1) NOT NULL DEFAULT '1',
  `grid_box_summary` TEXT NOT NULL,
  `grid_box_updated_datetime` DATETIME NOT NULL,
  `grid_box_deleted` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`grid_box_id`, `site_id`),
  INDEX `NewIndex1` (`site_id`),
  INDEX `NewIndex2` (`site_id`, `grid_id`),
  INDEX `NewIndex3` (`site_id`, `grid_id`, `grid_group_id`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	}      
	 
	
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "grid", "grid_id");
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "grid_group", "grid_group_id");
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "grid_box", "grid_box_id");
	

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>