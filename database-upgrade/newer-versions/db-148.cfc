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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `grid_box`   
  ADD COLUMN `grid_box_heading2` VARCHAR(255) NOT NULL AFTER `grid_box_image_intermediate`")){
		return false;
	}      
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "UPDATE `app` SET `app_built_in`= '0' WHERE `app_id` = '17'")){
		return false;
	}   
	
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>