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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event`   
  CHANGE `event_calendar_id` `event_calendar_id` VARCHAR(100) NOT NULL, 
  ADD  INDEX `NewIndex3` (`site_id`, `event_calendar_id`, `event_start_datetime`, `event_end_datetime`)")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "UPDATE `event` set event_calendar_id='' ")){
		return false;
	}  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event`   
  ADD COLUMN `event_image_library_layout` CHAR(1) DEFAULT '0'  NOT NULL AFTER `event_image_library_id`")){
		return false;
	}  

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>