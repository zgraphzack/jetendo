<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: this.datasource, table: 'blog'  });
	arrayAppend(arr1, { schema: this.datasource, table: 'blog_version'  });
	arrayAppend(arr1, { schema: this.datasource, table: 'blog_config'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_config`   
	ADD COLUMN `blog_config_always_show_section_articles` CHAR(1) DEFAULT '1'   NOT NULL AFTER `blog_config_deleted`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog`   
	ADD COLUMN `blog_show_all_sections` CHAR(1) DEFAULT '0'   NOT NULL AFTER `blog_deleted`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_version`   
	ADD COLUMN `blog_updated_datetime` CHAR(1) DEFAULT '0'   NOT NULL AFTER `blog_image_library_id`, 
	ADD COLUMN `blog_deleted` CHAR(1) DEFAULT '0'   NOT NULL AFTER `blog_updated_datetime`,
	ADD COLUMN `blog_show_all_sections` CHAR(1) DEFAULT '0'   NOT NULL AFTER `blog_deleted`")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>