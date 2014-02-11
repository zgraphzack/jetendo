<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'test'  });
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'test2'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, 
		"CREATE TABLE `#request.zos.zcoreDatasource#`.`#request.zos.zcoredatasourceprefix#test`
		( `test_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT, `test_name` VARCHAR(10) NOT NULL, PRIMARY KEY (`test_id`) ) ")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, 
		"RENAME TABLE `#request.zos.zcoreDatasource#`.`#request.zos.zcoredatasourceprefix#test` TO `#request.zos.zcoreDatasource#`.`test2` ")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, 
		"ALTER TABLE `#request.zos.zcoreDatasource#`.`#request.zos.zcoredatasourceprefix#test2` ADD UNIQUE INDEX `NewIndex1` (`test_name`) ")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>