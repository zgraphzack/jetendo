<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: this.datasource, table: 'mls_option'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, 
		"ALTER TABLE `mls_option`   
		ADD COLUMN `mls_option_listing_title_format` VARCHAR(255) NOT NULL AFTER `mls_option_search_template_forced` ")){
		return false;
	}

	qS=arguments.dbUpgradeCom.executeQuery(this.datasource, "select * from `mls_option` ");
	arrK=listToArray("city,remarks,address,subdivision,bedrooms,bathrooms,type,subtype,style,view,frontage,pool,condo");
	for(row in qS){
		arrK=application.zcore.functions.zRandomizeArray(arrK);
		mls_option_listing_title_format=arrayToList(arrK, ",");
		arguments.dbUpgradeCom.executeQuery(this.datasource, "update `mls_option` SET
		mls_option_listing_title_format='#application.zcore.functions.zescape(mls_option_listing_title_format)#' WHERE 
		site_id = '#application.zcore.functions.zescape(row.site_id)#' and 
		mls_option_id = '#application.zcore.functions.zescape(row.mls_option_id)#' ");
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, 
		"DROP TABLE IF EXISTS `listing_x_site` ")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>