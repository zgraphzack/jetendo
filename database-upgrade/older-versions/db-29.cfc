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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `audit`   
	  ADD COLUMN `audit_ip` VARCHAR(45) NOT NULL AFTER `audit_security_action_write`,
	  ADD COLUMN `audit_user_agent` VARCHAR(255) NOT NULL AFTER `audit_ip`;
	")){
		return false;
	}
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>