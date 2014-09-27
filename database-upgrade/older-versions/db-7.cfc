<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: this.datasource, table: 'tooltip'  });
	arrayAppend(arr1, { schema: this.datasource, table: 'tooltip_section'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, 
		"DROP TABLE `#this.datasource#`.`tooltip`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, 
		"DROP TABLE `#this.datasource#`.`tooltip_section`")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>