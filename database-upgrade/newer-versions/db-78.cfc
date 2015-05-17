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
  ADD COLUMN `event_category_searchable` CHAR(1) DEFAULT '0'  NOT NULL AFTER `event_category_list_perpage`")){
		return false;
	}  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event_calendar`   
  ADD COLUMN `event_calendar_searchable` CHAR(1) DEFAULT '0'  NOT NULL AFTER `event_calendar_list_perpage`")){
		return false;
	}  

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>