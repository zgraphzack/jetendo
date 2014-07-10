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
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "ALTER TABLE `#request.zos.zcoredatasourceprefix#blog_config`   
	  ADD COLUMN `blog_config_email_alerts_enabled` CHAR(1) DEFAULT '0'   NOT NULL AFTER `blog_config_section_title_affix`,
	  ADD COLUMN `blog_config_email_alert_subject` VARCHAR(255) NOT NULL AFTER `blog_config_email_alerts_enabled`,
	  ADD COLUMN `blog_config_email_full_article` CHAR(1) DEFAULT '0'   NOT NULL AFTER `blog_config_email_alert_subject`")){
		return false;
	}
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>