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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `content`   
  ADD COLUMN `content_hide_edit` CHAR(1) DEFAULT '0'  NOT NULL AFTER `section_id`")){
		return false;
	}     
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `content_version`   
  ADD COLUMN `content_hide_edit` CHAR(1) DEFAULT '0'  NOT NULL AFTER `section_id`")){
		return false;
	}     


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>