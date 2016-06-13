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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `image_library`   
  ADD COLUMN `image_library_hash` VARCHAR(64) NOT NULL AFTER `image_library_deleted`")){
		return false;
	}      
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>