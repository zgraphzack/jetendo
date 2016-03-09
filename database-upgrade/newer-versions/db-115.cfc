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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `whitelabel`   
  ADD COLUMN `whitelabel_dashboard_header_raw_html` LONGTEXT NOT NULL AFTER `whitelabel_css`,
  ADD COLUMN `whitelabel_dashboard_footer_raw_html` LONGTEXT NOT NULL AFTER `whitelabel_dashboard_header_raw_html`")){
		return false;
	}   
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>