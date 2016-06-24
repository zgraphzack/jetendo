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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `grid_group`   
  ADD COLUMN `grid_group_box_image_width` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `grid_group_deleted`,
  ADD COLUMN `grid_group_box_image_height` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `grid_group_box_image_width`,
  ADD COLUMN `grid_group_box_image_crop` CHAR(1) DEFAULT '0'  NOT NULL AFTER `grid_group_box_image_height`")){
		return false;
	}   
	
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>