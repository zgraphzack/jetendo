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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `saved_listing`   
  DROP INDEX `NewIndex1`,
  ADD  UNIQUE INDEX `NewIndex1` (`site_id`, `user_id`, `user_id_siteIDType`, `saved_listing_deleted`)")){
		return false;
	}     


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>