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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `content`   
  ADD COLUMN `content_grid_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `content_child_disable_links`")){
		return false;
	}      
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `content_version`   
  ADD COLUMN `content_grid_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `content_child_disable_links`")){
		return false;
	}      
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog`   
  ADD COLUMN `blog_grid_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `section_id`")){
		return false;
	}      
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_version`   
  ADD COLUMN `blog_grid_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `section_id`")){
		return false;
	}      
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_x_option_group_set`   
  ADD COLUMN `site_x_option_group_set_grid_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `site_x_option_group_set_user`")){
		return false;
	}      
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event`   
  ADD COLUMN `event_grid_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `event_suggested_by_phone`")){
		return false;
	}      
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `grid_box`   
  ADD COLUMN `grid_box_image_intermediate` VARCHAR(255) NOT NULL AFTER `grid_box_deleted`")){
		return false;
	}      
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>