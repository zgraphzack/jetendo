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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `content_config`   
  ADD COLUMN `content_config_child_display_limit` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `content_config_detail_cfc_method`")){
		return false;
	}     
	

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>