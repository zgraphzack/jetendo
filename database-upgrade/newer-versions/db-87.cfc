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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `listing`   
  ADD COLUMN `listing_office_name` VARCHAR(100) NOT NULL AFTER `listing_images_verified_datetime`")){
		return false;
	}

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `listing_memory`   
  ADD COLUMN `listing_office_name` VARCHAR(100) NOT NULL AFTER `listing_images_verified_datetime`;
")){
		return false;
	}  
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `saved_listing`   
  DROP COLUMN `saved_content_count`, 
  DROP COLUMN `saved_content_idlist`")){
		return false;
	}  
	


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>