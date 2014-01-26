<cfcomponent>
<cfoutput>
   
<cffunction name="getSearchIndexStruct" localmode="modern" access="public">
	<cfscript>
	return {
		search_title:"",
		search_summary:"",
		search_fulltext:"",
		search_url:"",
		search_image:"",
		search_table_id:"",
		search_updated_datetime:request.zos.mysqlnow,
		search_content_datetime:request.zos.mysqlnow
	};
	</cfscript>
</cffunction>

<cffunction name="saveSearchIndex" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	ds=arguments.struct;
	if(not structkeyexists(ds, 'site_id')){
		throw("arguments.struct.site_id is required");
	}
	if(not structkeyexists(ds, 'app_id')){
		throw("arguments.struct.app_id is required");
	}
	ds.search_summary=trim(application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(ds.search_summary), 200));
	ds.search_fulltext=trim(application.zcore.functions.zRemoveHTMLForSearchIndexer(ds.search_fulltext));
	ds.search_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
	if(ds.search_content_datetime EQ "" or not isdate(ds.search_content_datetime)){
		ds.search_content_datetime=now();
	}	
	ds.search_content_datetime=dateformat(ds.search_content_datetime, "yyyy-mm-dd")&" "&timeformat(ds.search_content_datetime, "HH:mm:ss");
	ts=structnew();
	ts.struct=ds;
	ts.datasource=request.zos.zcoredatasource;
	ts.table="search";
	ts.enableReplace=true; 
	result=application.zcore.functions.zInsert(ts); 
	</cfscript>
</cffunction>


</cfoutput>
</cfcomponent>