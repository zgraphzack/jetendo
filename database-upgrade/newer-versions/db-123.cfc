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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `spf_domain`(  
  `spf_domain_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `spf_domain_name` VARCHAR(255) NOT NULL,
  `spf_domain_updated_datetime` DATETIME NOT NULL,
  `spf_domain_deleted` CHAR(1) NOT NULL DEFAULT '0',
  `spf_domain_vendor_list` VARCHAR(500) NOT NULL DEFAULT '',
  `spf_domain_valid` CHAR(1) NOT NULL,
  PRIMARY KEY (`spf_domain_id`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	}     
	

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>