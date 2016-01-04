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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `landing_page_x_widget_instance`   
  ADD COLUMN `landing_column_x_widget_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `landing_page_x_widget_instance_deleted`, 
  ADD  INDEX `NewIndex4` (`site_id`, `landing_column_x_widget_id`, `widget_instance_id`)")){
		return false;
	}   
 

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>