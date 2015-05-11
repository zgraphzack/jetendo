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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event_recur`   
  ADD COLUMN `event_recur_start_datetime` DATETIME NOT NULL AFTER `event_recur_deleted`,
  ADD COLUMN `event_recur_end_datetime` DATETIME NOT NULL AFTER `event_recur_start_datetime`, 
  ADD  INDEX `NewIndex3` (`site_id`, `event_recur_start_datetime`, `event_recur_end_datetime`),
  ADD  INDEX `NewIndex4` (`site_id`, `event_id`) ")){
		return false;
	}  

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>