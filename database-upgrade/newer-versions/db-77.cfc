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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event_category`   
  ADD COLUMN `event_category_list_views` VARCHAR(50) NOT NULL AFTER `event_category_unique_url`,
  ADD COLUMN `event_category_list_default_view` VARCHAR(20) NOT NULL AFTER `event_category_list_views`,
  ADD COLUMN `event_category_list_perpage` INT(11) NOT NULL AFTER `event_category_list_default_view`")){
		return false;
	}  

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>