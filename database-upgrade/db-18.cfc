<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'site_option_group'  });
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'inquiries'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "ALTER TABLE `#request.zos.zcoredatasourceprefix#site_option_group`   
  		ADD COLUMN `site_option_group_enable_section` CHAR(1) DEFAULT '0'   NOT NULL AFTER `site_option_group_disable_site_map`")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "ALTER TABLE `#request.zos.zcoredatasourceprefix#inquiries`   
	  DROP COLUMN `inquiries_kaylor_comment`, 
	  DROP COLUMN `inquiries_glacier_type`, 
	  DROP COLUMN `inquiries_glacier_type_sub`, 
	  DROP COLUMN `inquiries_glacier_size`, 
	  DROP COLUMN `inquiries_glacier_quantity`")){
		return false;
	}

  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>