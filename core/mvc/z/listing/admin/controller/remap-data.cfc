<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>
	var i=0;
	var db=request.zos.queryObject;
	variables.searchCriteriaList="search_frontage,search_view,search_county,search_style,search_status,search_listing_type_id," &
	"search_listing_sub_type_id,search_parking,search_tenure,search_condition,search_liststatus"
	local.arrSearch=listToArray(variables.searchCriteriaList, ",");
	variables.searchCriteriaStruct={};
	variables.searchCriteriaSQLStruct={};
	for(i=1;i LTE arraylen(local.arrSearch);i++){
		variables.searchCriteriaStruct[local.arrSearch[i]]=true;
		variables.searchCriteriaSQLStruct[local.arrSearch[i]]=replace(local.arrSearch[i], 'search_', '');
	}
	variables.searchCriteriaSQLStruct["search_listing_type_id"]="listing_type";
	variables.searchCriteriaSQLStruct["search_listing_sub_type_id"]="listing_sub_type";
	form.mls_id1=application.zcore.functions.zso(form, 'mls_id1');
	form.mls_id2=application.zcore.functions.zso(form, 'mls_id2');
	form.searchCriteria=application.zcore.functions.zso(form, 'searchCriteria');
	form.searchCriteria2=application.zcore.functions.zso(form, 'searchCriteria2');
	if(form.method NEQ "index"){
		if(not structkeyexists(variables.searchCriteriaStruct, form.searchCriteria) or not structkeyexists(variables.searchCriteriaStruct, form.searchCriteria2)){
			application.zcore.status.setStatus(request.zsid, "Search criteria must be selected.", form, true);
			application.zcore.functions.zRedirect("/z/listing/admin/remap-data/index?zsid=#request.zsid#");
		}
		db.sql="select mls_provider FROM #db.table("mls", request.zos.zcoreDatasource)# 
		where mls_id = #db.param(form.mls_id1)# ";
		variables.qM=db.execute("qM");
		db.sql="select mls_provider FROM #db.table("mls", request.zos.zcoreDatasource)# 
		where mls_id = #db.param(form.mls_id2)# ";
		variables.qM2=db.execute("qM");
		if(variables.qM.recordcount EQ 0 or variables.qM2.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid MLS Provider.", form, true);
			application.zcore.functions.zRedirect("/z/listing/admin/remap-data/index?zsid=#request.zsid#");
		}
	}
	variables.backURL="/z/listing/admin/remap-data/index?mls_id1=#form.mls_id1#&mls_id2=#form.mls_id2#&searchCriteria=#form.searchCriteria#&searchCriteria2=#form.searchCriteria2#";
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var selectStruct=0;
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zStatusHandler(request.zsid, true);
	/*db.sql="SELECT * FROM app_x_mls, mls_saved_search 
	WHERE mls_id='11' AND 
	mls_saved_search.site_id = app_x_mls.site_id";
	select mls_id 1 and mls_id 2 and 1 search_field that has ids, then submit
	show all USED values for each mls, map left to right, then submit.
		query for used values
	*/
	db.sql="select * from #db.table("mls", request.zos.zcoreDatasource)# 
	WHERE mls_deleted = #db.param(0)# ";
	local.qMLS=db.execute("qMLS");
	
	writeoutput('<form action="/z/listing/admin/remap-data/select" method="get">
	<table style="border-spacing:0px; width:100%;" class="small">
		<tr>
			<td class="table-shadow"><span class="medium">Remap Real Estate Saved Search Data</span></td>
		</tr>
	</table>
	<p>This form is not safe to use when a single site is using more the one MLS association.</cfscript>
	<table style="border-spacing:0px; " class="small"><tr><th>MLS From: </th><td class="table-white">');
	// build 2 select menus
	selectStruct = StructNew();
	selectStruct.name = "mls_id1";
	selectStruct.query = local.qMLS;
	selectStruct.queryParseLabelVars=true;
	selectStruct.queryLabelField = "##mls_id## | ##mls_name##";
	selectStruct.queryValueField = "mls_id";
	application.zcore.functions.zInputSelectBox(selectStruct);
	
	writeoutput('</td></tr><th>MLS To: </th><td class="table-white">');
	selectStruct = StructNew();
	selectStruct.name = "mls_id2";
	selectStruct.query = local.qMLS;
	selectStruct.queryParseLabelVars=true;
	selectStruct.queryLabelField = "##mls_id## | ##mls_name##";
	selectStruct.queryValueField = "mls_id";
	application.zcore.functions.zInputSelectBox(selectStruct);
	writeoutput('</td></tr><tr><th>Search criteria from: </th><td class="table-white">');
	
	selectStruct = StructNew();
	selectStruct.name = "searchCriteria";
	selectStruct.listValues = variables.searchCriteriaList;
	selectStruct.listLabels = replace(selectStruct.listValues, 'search_', '', 'all');
	selectStruct.listLabelsDelimiter = ",";
	selectStruct.listValuesDelimiter = ",";
	application.zcore.functions.zInputSelectBox(selectStruct);
	writeoutput('</td></tr><tr><th>Search criteria to: </th><td class="table-white">');
	
	selectStruct = StructNew();
	selectStruct.name = "searchCriteria2";
	selectStruct.listValues = variables.searchCriteriaList;
	selectStruct.listLabels = replace(selectStruct.listValues, 'search_', '', 'all');
	selectStruct.listLabelsDelimiter = ",";
	selectStruct.listValuesDelimiter = ",";
	application.zcore.functions.zInputSelectBox(selectStruct);
	
	writeoutput('</td></tr><tr><th>&nbsp;</th><td class="table-white"><input type="submit" name="submit1" value="Submit" /></td></tr></table>
	</form>');
	</cfscript>
</cffunction>

<cffunction name="select" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var selectStruct=0;
	var i=0;
	var row=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	// on submit
	/*
	db.sql="SELECT GROUP_CONCAT(DISTINCT `#form.searchCriteria#` SEPARATOR #db.param(",")#) idlist 
	FROM #db.table("app_x_mls", request.zos.zcoreDatasource)#, 
	#db.table("mls_saved_search", request.zos.zcoreDatasource)# 
	WHERE app_x_mls.mls_id=#db.param(form.mls_id1)# AND 
	mls_saved_search.site_id = app_x_mls.site_id and
	app_x_mls_deleted = #db.param(0)# and 
	mls_saved_search_deleted = #db.param(0)# 
	and `#form.searchCriteria#` <> '' ";
	local.qId=db.execute("qId"); 
	
	local.uniqueStruct={};
	for(row in local.qId){
		local.arrID=listToArray(row.idlist, ',', false); 
		for(i=1;i LTE arraylen(local.arrID);i++){
			local.uniqueStruct[local.arrID[i]]=true;
		}
	} 
	if(structcount(local.uniqueStruct) EQ 0){
		application.zcore.status.setStatus(request.zsid, "No data left to map for this field.");
		application.zcore.functions.zRedirect("#variables.backURL#&zsid=#request.zsid#");
	}
	db.sql="select listing_lookup.* from 
	#db.table("listing_lookup", request.zos.zcoreDatasource)# listing_lookup 
	where listing_lookup_id in ("&db.trustedSQL("'"&structkeylist(local.uniqueStruct, "','")&"'")&") and
	listing_lookup_deleted = #db.param(0)# and
	(listing_lookup.listing_lookup_type =#db.param(variables.searchCriteriaSQLStruct[form.searchCriteria])# "; 
	local.qLookup=db.execute("qLookup"); //
	*/
	db.sql="select listing_lookup.* from 
	#db.table("listing_lookup", request.zos.zcoreDatasource)# listing_lookup 
	where 
	listing_lookup_deleted = #db.param(0)# and
	(listing_lookup.listing_lookup_type =#db.param(variables.searchCriteriaSQLStruct[form.searchCriteria])# or
	listing_lookup.listing_lookup_type =#db.param(variables.searchCriteriaSQLStruct[form.searchCriteria2])#) AND 
	(listing_lookup_mls_provider= #db.param(variables.qM.mls_provider)# or listing_lookup_mls_provider= #db.param(variables.qM2.mls_provider)# )  "; 
	local.qLookup=db.execute("qLookup"); 
	
	if(local.qLookup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "No data left to map for this field.");
		application.zcore.functions.zRedirect("#variables.backURL#&zsid=#request.zsid#");
	}
	 
	db.sql="select group_concat(listing_lookup.listing_lookup_id SEPARATOR #db.param(",")#) idlist, listing_lookup.listing_lookup_value from 
	#db.table("listing_lookup", request.zos.zcoreDatasource)# listing_lookup
	where
	lisitng_lookup_deleted = #db.param(0)# and
	listing_lookup_mls_provider = #db.param(variables.qM2.mls_provider)#
	and listing_lookup.listing_lookup_type = #db.param(variables.searchCriteriaSQLStruct[form.searchCriteria2])# 
	GROUP BY listing_lookup.listing_lookup_value";
	local.qLookup2=db.execute("qLookup");  
	
	writeoutput('<form action="/z/listing/admin/remap-data/map" method="post">
	<input type="hidden" name="mls_id1" value="#form.mls_id1#" />
	<input type="hidden" name="mls_id2" value="#form.mls_id2#" />
	<input type="hidden" name="searchCriteria" value="#htmleditformat(form.searchCriteria)#" />
	<input type="hidden" name="searchCriteria2" value="#htmleditformat(form.searchCriteria2)#" />
	<h2>Map Search Criteria: #replace(form.searchCriteria, 'search_', '')# to #replace(form.searchCriteria2, 'search_', '')#</h2>
	<p>Select the option to remap the data for each of the existing used options. If no option is selected, the option will be removed from the saved search</p>
	<table style="border-spacing:0px; " class="small">
	<tr><th>From</th><th>To</th></tr>');
	local.rowIndex=1; 
	for(row in local.qLookup){
		writeoutput('<tr><td class="table-white"><input type="hidden" name="listing_lookup_id_old#local.rowIndex#" value="'&row.listing_lookup_id&'" />'&htmleditformat(row.listing_lookup_value)&'</td><td class="table-white">'); 
		selectStruct = StructNew();
		selectStruct.name = "listing_lookup_id_new#local.rowIndex#";
		selectStruct.listLabels = "-- Delete Option --";
		selectStruct.listValues ="0";
		selectStruct.listLabelsDelimiter = ",";
		selectStruct.listValuesDelimiter = ",";
		selectStruct.query = local.qLookup2;
		selectStruct.queryLabelField = "listing_lookup_value";
		selectStruct.queryValueField = "idlist";
		application.zcore.functions.zInputSelectBox(selectStruct);
		writeoutput('</td></tr>');
		local.rowIndex++;
	}
	writeoutput('</table>');
	writeoutput('<br /><br />
	<input type="hidden" name="rowIndex" value="#local.rowIndex-1#" />
	<input type="submit" name="submit1" value="submit" /> 
	<input type="button" onclick="window.location.href=''/z/listing/admin/remap-data/index'';" name="cancel1" value="cancel" /></p></form>');
	</cfscript>
</cffunction>

<cffunction name="map" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var i=0;
	var row=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	form.rowIndex=application.zcore.functions.zso(form, 'rowIndex');
	local.mapStruct={};
	for(i=1;i LTE form.rowIndex;i++){
		local.oldId=application.zcore.functions.zso(form, 'listing_lookup_id_old#i#');
		local.newId=application.zcore.functions.zso(form, 'listing_lookup_id_new#i#');
		if(local.newId NEQ ""){
			local.mapStruct[local.oldId]=local.newId;
		}
	}  
	db.sql="SELECT group_concat(mls_saved_search_id separator #db.param("','")#) idlist, `#form.searchCriteria#` field, `#form.searchCriteria2#` field2, mls_saved_search.site_id 
	FROM #db.table("app_x_mls", request.zos.zcoreDatasource)#, 
	#db.table("mls_saved_search", request.zos.zcoreDatasource)# 
	WHERE app_x_mls.mls_id IN (#db.trustedSQL("'"&form.mls_id1&"','"&form.mls_id2&"'")#) AND 
	mls_saved_search.site_id = app_x_mls.site_id and 
	mls_saved_search_deleted = #db.param(0)# and 
	app_x_mls_deleted = #db.param(0)# 
	and (`#form.searchCriteria#` <> '' or `#form.searchCriteria2#` <> '' ) 
	GROUP BY mls_saved_search.site_id, `#form.searchCriteria#`, `#form.searchCriteria2#`  ";
	local.qId=db.execute("qId");  
	for(row in local.qId){
		local.changed=false;
		local.arrData1=listToArray(row.field, ",", false);
		local.arrData2=listToArray(row.field2, ",", false);
		
		local.uniqueStruct1={};
		local.uniqueStruct2={};
		for(i=1;i LTE arraylen(local.arrData1);i++){
			if(structkeyexists(mapStruct, local.arrData1[i])){
				local.changed=true;
				if(mapStruct[local.arrData2[i]] NEQ "0"){
					//local.uniqueStruct1[mapStruct[local.arrData1[i]]]=true;
				}
			}else{
				local.uniqueStruct1[local.arrData1[i]]=true;
			}
		}
		for(i=1;i LTE arraylen(local.arrData2);i++){
			if(structkeyexists(mapStruct, local.arrData2[i])){
				local.changed=true;
				if(mapStruct[local.arrData2[i]] NEQ "0"){
					local.uniqueStruct2[mapStruct[local.arrData2[i]]]=true;
				}
			}else{
				local.uniqueStruct2[local.arrData2[i]]=true;
			}
		}
		if( local.changed){  
			local.result1=structkeylist(local.uniqueStruct1, ",");
			local.result2=structkeylist(local.uniqueStruct2, ",");
			/*writeoutput("UPDATE mls_saved_search
			SET
			`#form.searchCriteria#` = '#application.zcore.functions.zescape(local.result1)#', 
			 `#form.searchCriteria2#` = '#application.zcore.functions.zescape(local.result2)#' 
			WHERE mls_saved_search_id IN ("&("'"&row.idlist&"'")&") and site_id=#row.site_id# <br /><br />"); 
			*/
			db.sql="UPDATE #db.table("mls_saved_search", request.zos.zcoreDatasource)# 
			SET `#form.searchCriteria#` = '#application.zcore.functions.zescape(local.result1)#',
			mls_saved_search_updated_datetime=#db.param(request.zos.mysqlnow)# ,
			 `#form.searchCriteria2#` = #db.param(local.result2)# 
			WHERE mls_saved_search_id IN ("&db.trustedSQL("'"&row.idlist&"'")&")  and 
			site_id=#db.param(row.site_id)#";
			db.execute("qUpdate"); 
		}
	}
	// application.zcore.functions.zabort();
	application.zcore.status.setStatus(request.zsid, "Data mapped successfully.");
	application.zcore.functions.zRedirect("#variables.backURL#&zsid=#request.zsid#");
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>