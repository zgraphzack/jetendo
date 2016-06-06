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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `content`   
  DROP COLUMN `content_hide_global`")){
		return false;
	}     
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `content_version`   
  DROP COLUMN `content_hide_global`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event`   
  DROP COLUMN `site_option_app_id`")){
		return false;
	}      
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>