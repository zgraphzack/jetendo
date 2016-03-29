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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `queue_http`(  
  `queue_http_id` INT(11) NOT NULL,
  `site_id` INT NOT NULL,
  `queue_http_url` TEXT NOT NULL,
  `queue_http_created_datetime` DATETIME NOT NULL,
  `queue_http_updated_datetime` DATETIME NOT NULL,
  `queue_http_last_run_datetime` DATETIME NOT NULL,
  `queue_http_header_data` LONGTEXT NOT NULL,
  `queue_http_form_data` LONGTEXT NOT NULL,
  `queue_http_fail_count` INT NOT NULL,
  `queue_http_response` INT NOT NULL,
  `queue_http_timeout` INT NOT NULL,
  `queue_http_retry_interval` INT NOT NULL,
  `queue_http_deleted` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`, `queue_http_id`)
);
")){
		return false;
	}   
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "queue_http", "queue_http_id");
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>