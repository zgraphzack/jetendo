<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: this.datasource, table: 'listing_coordinates'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(this.Datasource, 
		"CREATE TABLE `#request.zos.zcoreDatasourcePrefix#listing_coordinates` (
		`listing_coordinates_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`listing_coordinates_latitude` varchar(21) NOT NULL,
		`listing_coordinates_longitude` varchar(21) NOT NULL,
		`listing_id` varchar(15) NOT NULL,
		`listing_coordinates_address` varchar(100) NOT NULL,
		`listing_coordinates_zip` varchar(10) NOT NULL,
		`listing_coordinates_status` varchar(20) NOT NULL,
		`listing_coordinates_accuracy` varchar(20) NOT NULL,
		PRIMARY KEY (`listing_coordinates_id`),
		UNIQUE KEY `NewIndex1` (`listing_id`),
		KEY `NewIndex2` (`listing_coordinates_status`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>