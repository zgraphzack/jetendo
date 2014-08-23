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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#mls_option`   
  DROP COLUMN `mls_option_detail_template`,
  ADD COLUMN `mls_option_detail_cfc` VARCHAR(255) NOT NULL AFTER `mls_option_deleted`,
  ADD COLUMN `mls_option_detail_method` VARCHAR(255) NOT NULL AFTER `mls_option_detail_cfc`")){
		return false;
	} 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>