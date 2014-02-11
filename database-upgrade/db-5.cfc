<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'site_option_group'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, 
		"ALTER TABLE `#request.zos.zcoreDatasource#`.`#request.zos.zcoredatasourceprefix#site_option_group`   
		ADD COLUMN `site_option_group_admin_app_only` CHAR(1) DEFAULT '0'   NOT NULL AFTER `site_option_group_display_name`")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>