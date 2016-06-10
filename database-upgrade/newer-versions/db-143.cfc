<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	qLibrary=arguments.dbUpgradeCom.executeQuery(this.datasource, "SELECT * from `image_library` WHERE 
	`image_library_hash` = '' and site_id <> '-1' ");
	for(row in qLibrary){
		key=hash(application.zcore.functions.zGenerateStrongPassword(80,200), 'sha-256'); 
		if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "UPDATE `image_library` SET image_library_hash='#key#' WHERE `image_library_id` = '#row.image_library_id#' and site_id ='#row.site_id#' ")){
			return false;
		}      
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>