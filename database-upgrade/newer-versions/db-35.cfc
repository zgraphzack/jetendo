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
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "UPDATE `#request.zos.zcoredatasourceprefix#site_x_option_group_set` SET site_x_option_group_set_updated_datetime = site_x_option_group_set_datetime WHERE site_x_option_group_set_updated_datetime='0000-00-00 00:00:00'")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "ALTER TABLE `#request.zos.zcoredatasourceprefix#site_x_option_group_set`   
	CHANGE `site_x_option_group_set_datetime` `site_x_option_group_set_created_datetime` DATETIME NOT NULL;")){
		return false;
	}
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>