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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `dns_zone`   
	  ADD COLUMN `dns_zone_retry` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `dns_zone_comment`	")){
		return false;
	}
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>