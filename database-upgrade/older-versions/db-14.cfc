<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: this.datasource, table: 'listing_delete'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#listing_delete` (
	`listing_delete_id` int(11) NOT NULL AUTO_INCREMENT,
	`listing_id` int(11) unsigned NOT NULL,
	PRIMARY KEY (`listing_delete_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>