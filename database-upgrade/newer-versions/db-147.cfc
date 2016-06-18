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
  CHANGE `grid_box_image` `grid_box_image` VARCHAR(255) CHARSET utf8 COLLATE utf8_bin NOT NULL")){
		return false;
	}      
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>