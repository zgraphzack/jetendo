<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'site'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, 
		"ALTER TABLE `#request.zos.zcoreDatasource#`.`#request.zos.zcoredatasourceprefix#site`
  		CHANGE `site_fontlist` `site_fontlist` TEXT CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  		CHANGE `site_editor_fonts` `site_editor_fonts` TEXT CHARSET utf8 COLLATE utf8_general_ci NOT NULL")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>