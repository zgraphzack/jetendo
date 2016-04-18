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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `widget_instance`   
  ADD COLUMN `widget_instance_standalone` CHAR(1) DEFAULT '0'  NOT NULL AFTER `widget_instance_json_data`")){
		return false;
	}     
	

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>