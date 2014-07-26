<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: this.datasource, table: 'test2'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, 
		"ALTER TABLE `#this.datasource#`.`#request.zos.zcoreDatasourcePrefix#test2` 
		ADD COLUMN `test_new` CHAR(1) DEFAULT '0' NOT NULL AFTER `test_name` ")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, 
		"ALTER TABLE `#this.datasource#`.`#request.zos.zcoreDatasourcePrefix#test2` 
		CHANGE `test_new` `test_new2` CHAR(1) CHARSET utf8 COLLATE utf8_general_ci DEFAULT '0' NOT NULL")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, 
		"ALTER TABLE `#this.datasource#`.`#request.zos.zcoreDatasourcePrefix#test2` DROP INDEX `NewIndex1`")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>