<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: this.datasource, table: 'test'  });
	arrayAppend(arr1, { schema: this.datasource, table: 'test2'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, 
		"CREATE TABLE `#this.datasource#`.`#request.zos.zcoreDatasourcePrefix#test`
		( `test_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT, `test_name` VARCHAR(10) NOT NULL, PRIMARY KEY (`test_id`) ) ")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, 
		"RENAME TABLE `#this.datasource#`.`#request.zos.zcoreDatasourcePrefix#test` TO `#this.datasource#`.`test2` ")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, 
		"ALTER TABLE `#this.datasource#`.`#request.zos.zcoreDatasourcePrefix#test2` ADD UNIQUE INDEX `NewIndex1` (`test_name`) ")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>