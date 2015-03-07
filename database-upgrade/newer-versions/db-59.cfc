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
	  ADD COLUMN `content_config_detail_cfc_path` VARCHAR(255) NOT NULL AFTER `content_config_section_title_affix`,
	  ADD COLUMN `content_config_detail_cfc_method` VARCHAR(100) NOT NULL AFTER `content_config_detail_cfc_path`
	")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>