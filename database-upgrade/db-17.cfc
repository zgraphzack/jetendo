<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'blog'  });
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'blog_version'  });
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'content'  });
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'content_version'  });
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'menu'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "ALTER TABLE `#request.zos.zcoredatasourceprefix#blog`   
	ADD COLUMN `site_x_option_group_set_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `office_id`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "ALTER TABLE `#request.zos.zcoredatasourceprefix#blog_version`   
	ADD COLUMN `site_x_option_group_set_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `office_id`")){
		return false;
	}

	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "ALTER TABLE `#request.zos.zcoredatasourceprefix#content`   
	ADD COLUMN `site_x_option_group_set_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `content_thumbnail_crop`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "ALTER TABLE `#request.zos.zcoredatasourceprefix#content_version`   
	ADD COLUMN `site_x_option_group_set_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `content_thumbnail_crop`")){
		return false;
	}

	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "ALTER TABLE `#request.zos.zcoredatasourceprefix#menu`   
	ADD COLUMN `site_x_option_group_set_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `menu_selected_background_image`")){
		return false;
	}
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>