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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event_calendar`   
  ADD COLUMN `event_calendar_user_group_idlist` VARCHAR(255) NOT NULL AFTER `event_calendar_description`")){
		return false;
	}  

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>