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
  ADD COLUMN `site_enable_manage_menu` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_enable_css_framework`,
  ADD COLUMN `site_enable_manage_slideshow` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_enable_manage_menu`,
  ADD COLUMN `site_enable_problem_link_report` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_enable_manage_slideshow`")){
		return false;
	}     
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_config`   
  ADD COLUMN `blog_config_disable_author` CHAR(1) DEFAULT '0'  NOT NULL AFTER `blog_config_email_full_article`")){
		return false;
	}     


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>