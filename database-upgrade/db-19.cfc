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
	request.zos.disabeVerifyTablesVerify=true;
	verifyCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.verify-tables");
	verifyCom.index(false);

  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>