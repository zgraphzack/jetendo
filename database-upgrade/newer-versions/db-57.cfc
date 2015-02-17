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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site`   
		ADD COLUMN `site_calltrackingmetrics_cfc_path` VARCHAR(255) NOT NULL AFTER `site_nginx_ssl_config`,
		ADD COLUMN `site_calltrackingmetrics_cfc_method` VARCHAR(100) NOT NULL AFTER `site_calltrackingmetrics_cfc_path`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site`   
	  ADD COLUMN `site_calltrackingmetrics_import_datetime` DATETIME NOT NULL AFTER `site_calltrackingmetrics_cfc_method`,
	  ADD COLUMN `site_calltrackingmetrics_account_id` VARCHAR(30) NOT NULL AFTER `site_calltrackingmetrics_import_datetime`,
	  ADD COLUMN `site_calltrackingmetrics_access_key` VARCHAR(255) NOT NULL AFTER `site_calltrackingmetrics_account_id`,
	  ADD COLUMN `site_calltrackingmetrics_secret_key` VARCHAR(255) NOT NULL AFTER `site_calltrackingmetrics_access_key`,
	  ADD COLUMN `site_calltrackingmetrics_enable_import` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_calltrackingmetrics_secret_key`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries`   
	ADD COLUMN `inquiries_readonly` CHAR(1) DEFAULT '0'  NOT NULL AFTER `inquiries_external_id`")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>