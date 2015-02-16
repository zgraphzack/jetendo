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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries`   
	ADD COLUMN `inquiries_external_id` VARCHAR(22) NOT NULL AFTER `inquiries_deleted`, 
	ADD  INDEX `inquiries_external_id` (`site_id`, `inquiries_external_id`)")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO `inquiries_type` SET inquiries_type_id='15', inquiries_type_locked='1', site_id='0', inquiries_type_name = 'Phone Call' ")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>