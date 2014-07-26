<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" access="package"localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, 
		"DROP TABLE `#request.zos.zcoreDatasourcePrefix#listing_latlong` ")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, 
		"DROP TABLE `#request.zos.zcoreDatasourcePrefix#listing_latlong_original` ")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>