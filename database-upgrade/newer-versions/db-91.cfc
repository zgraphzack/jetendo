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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `layout_row_x_breakpoint`   
  CHANGE `layout_row_x_breakpoint_value` `layout_breakpoint_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `layout_row_x_breakpoint`   
  ADD  INDEX `NewIndex1` (`site_id`),
  ADD  INDEX `NewIndex2` (`site_id`, `layout_breakpoint_id`, `layout_row_id`)")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `layout_page`   
  ADD  INDEX `NewIndex2` (`site_id`)")){
		return false;
	} 

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `layout_row`   
  ADD COLUMN `layout_row_sort` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `layout_row_deleted`,
    ADD  INDEX `NewIndex1` (`site_id`, `layout_page_id`);")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `layout_column_x_breakpoint`   
  CHANGE `layout_column_x_breakpoint_value` `layout_breakpoint_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `layout_column_x_breakpoint`   
  ADD  INDEX `NewIndex1` (`site_id`, `layout_breakpoint_id`, `layout_column_id`),
  ADD  INDEX `NewIndex2` (`site_id`)")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `layout_column_x_widget_x_breakpoint`   
  CHANGE `layout_column_x_widget_x_breakpoint_value` `layout_breakpoint_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `layout_column_x_widget_x_breakpoint`   
  ADD  INDEX `NewIndex1` (`site_id`),
  ADD  INDEX `NewIndex2` (`site_id`, `layout_breakpoint_id`, `layout_column_id`)")){
		return false;
	} 

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `landing_page_x_widget`   
  ADD  INDEX `NewIndex2` (`site_id`)")){
		return false;
	} 

  if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `landing_page`   
  ADD  INDEX `NewIndex2` (`site_id`)")){
		return false;
	} 

  if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `layout_preset`   
  ADD  INDEX `NewIndex2` (`site_id`)")){
		return false;
	} 
  
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `layout_row`    
  ADD  INDEX `NewIndex2` (`site_id`)")){
		return false;
	}   
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `layout_breakpoint`(  
  `layout_breakpoint_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `layout_breakpoint_value` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `layout_breakpoint_updated_datetime` DATETIME NOT NULL,
  `layout_breakpoint_deleted` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`layout_breakpoint_id`, `site_id`, `layout_breakpoint_deleted`),
  INDEX `NewIndex1` (`site_id`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	} 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>