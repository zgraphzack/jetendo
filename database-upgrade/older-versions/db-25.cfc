<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'content_config'  });
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'blog_config'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "ALTER TABLE `#request.zos.zcoredatasourceprefix#content_config`   
	ADD COLUMN `content_config_section_title_affix` VARCHAR(50) DEFAULT ''   NOT NULL")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "ALTER TABLE `#request.zos.zcoredatasourceprefix#blog_config`   
	ADD COLUMN `blog_config_section_title_affix` VARCHAR(50) DEFAULT ''   NOT NULL")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>