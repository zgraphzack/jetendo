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
	arrSQL=[];
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
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, 
		"ALTER TABLE `#request.zos.zcoreDatasource#`.`#request.zos.zcoredatasourceprefix#test2` 
		ADD COLUMN `test_new` CHAR(1) DEFAULT '0' NOT NULL AFTER `test_name` ")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, 
		"ALTER TABLE `#request.zos.zcoreDatasource#`.`#request.zos.zcoredatasourceprefix#test2` 
		CHANGE `test_new` `test_new2` CHAR(1) CHARSET utf8 COLLATE utf8_general_ci DEFAULT '0' NOT NULL")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, 
		"ALTER TABLE `#request.zos.zcoreDatasource#`.`#request.zos.zcoredatasourceprefix#test2` DROP INDEX `NewIndex1`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, 
		"DROP TABLE `#request.zos.zcoreDatasource#`.`#request.zos.zcoredatasourceprefix#test2`")){
		return false;
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>