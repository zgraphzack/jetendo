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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#listing_track`   
	ADD COLUMN `listing_track_inactive` CHAR(1) DEFAULT '0'   NOT NULL AFTER `listing_track_processed_datetime`,
	DROP INDEX `NewIndex1`,
	ADD  UNIQUE INDEX `NewIndex1` (`listing_id`, `listing_track_inactive`, `listing_track_deleted`")){
		return false;
	} 

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>