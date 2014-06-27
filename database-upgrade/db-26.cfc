<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	arrayAppend(arr1, { schema: request.zos.zcoreDatasource, table: 'mls'  });
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>
	if(!arguments.dbUpgradeCom.executeQuery(request.zos.zcoreDatasource, "INSERT INTO `#request.zos.zcoredatasourceprefix#mls` (`mls_id`, `mls_name`, `mls_disclaimer_name`, `mls_mls_id`, `mls_offset`, `mls_status`, `mls_update_date`, `mls_download_date`, `mls_frequency`, `mls_com`, `mls_delimiter`, `mls_csvquote`, `mls_first_line_columns`, `mls_file`, `mls_current_file_path`, `mls_primary_city_id`, `mls_login_url`, `mls_cleaned_date`, `mls_provider`, `mls_filelist`, `mls_updated_datetime`) VALUES ('25', 'MFR Matrix', 'My Florida Regional MLS', 'mfr', '0', '1', '2014-06-01 00:00:00', '0000-00-00 00:00:00', 'hourly', 'rets25', '\t', '', '1', '', '', '616', 'http://mfr.mlxchange.com/', '2014-06-01', 'rets25', '', '0000-00-00 00:00:00')")){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>