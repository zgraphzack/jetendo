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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `user`   
  ADD COLUMN `user_instagram_url` VARCHAR(255) NOT NULL AFTER `user_autoassign_listing_inquiry`,
  ADD COLUMN `user_linkedin_url` VARCHAR(255) NOT NULL AFTER `user_instagram_url`;

	")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `mls_option`   
  ADD COLUMN `mls_option_search_cfc_path` VARCHAR(255) NOT NULL AFTER `mls_option_detail_method`,
  ADD COLUMN `mls_option_search_cfc_method` VARCHAR(100) NOT NULL AFTER `mls_option_search_cfc_path`	")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>