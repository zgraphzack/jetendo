<cfcomponent implements="zcorerootmapping.interface.siteOptionType">
<cfoutput>
<cffunction name="onBeforeImport" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	return { mapData: false, struct: {} };
	</cfscript>
</cffunction>

<cffunction name="getSortSQL" localmode="modern" access="public" returntype="string" output="no">
	<cfargument name="fieldIndex" type="string" required="yes">
	<cfargument name="sortDirection" type="string" required="yes">
	<cfscript>
	return "s"&arguments.fieldIndex&".site_x_option_group_date_value "&arguments.sortDirection;
	</cfscript>
</cffunction>

<cffunction name="getSearchFieldName" localmode="modern" access="public" returntype="string" output="no">
	<cfargument name="setTableName" type="string" required="yes">
	<cfargument name="groupTableName" type="string" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	searchType=application.zcore.functions.zso(arguments.optionStruct, 'datetime_range_search_type', true, 0);
	if(searchType EQ 1){
		// start date
		request.zos.siteOptionSearchDateRangeSortEnabled=true;
		return arguments.setTableName&".site_x_option_group_set_start_date";
	}else if(searchType EQ 2){
		// end date
		request.zos.siteOptionSearchDateRangeSortEnabled=true;
		return arguments.setTableName&".site_x_option_group_set_end_date";
	}else{
		return arguments.groupTableName&".site_x_option_group_value";
	}
	</cfscript>
</cffunction>

<cffunction name="isSearchable" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return true;
	</cfscript>
</cffunction>

<cffunction name="getSearchFormField" localmode="modern" access="public"> 
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfargument name="value" type="string" required="yes">
	<cfargument name="onChangeJavascript" type="string" required="yes">
	<cfscript>
	application.zcore.functions.zRequireJqueryUI();
	savecontent variable="js"{
		echo(' $( "###arguments.prefixString&arguments.row.site_option_id#" ).datepicker();');
	}
	if(structkeyexists(form, 'x_ajax_id')){
		js='<script type="text/javascript">/* <![CDATA[ */'&js&'/* ]]> */</script>';
	}else{
		application.zcore.skin.addDeferredScript(js);
		js='';
	}
	return '<input type="text" name="#arguments.prefixString##arguments.row.site_option_id#" onchange="#arguments.onChangeJavascript#" onkeyup="#arguments.onChangeJavascript#" onpaste="#arguments.onChangeJavascript#" id="#arguments.prefixString##arguments.row.site_option_id#" value="#htmleditformat(dateformat(arguments.value, 'mm/dd/yyyy'))#" size="9" />'&js;
	</cfscript>
</cffunction>


<cffunction name="getSearchValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfscript>
	local.curDate="";
	if(structkeyexists(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id&'_date')){
		local.tempDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id&'_date');
		arguments.searchStruct[arguments.prefixString&arguments.row.site_option_id&"_date"]=local.tempDate;
	}else{
		local.tempDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id);
		arguments.searchStruct[arguments.prefixString&arguments.row.site_option_id]=local.tempDate;
	}
	if(local.tempDate NEQ "" and isdate(local.tempDate)){
		try{
			local.curDate=dateformat(local.tempDate, "yyyy-mm-dd");
		}catch(Any local.e){
			// ignore
		}
	}
	var finalDate=0;
	if(local.curDate EQ ""){
		if(arguments.row.site_option_admin_search_default NEQ "" and isnumeric(arguments.row.site_option_admin_search_default)){
			finalDate=dateadd("d", arguments.row.site_option_admin_search_default, now());
		}else{
			finalDate="";	
		}
	}else{
		finalDate=parsedatetime(local.curDate&" 00:00:00");
	}
	return finalDate;
	</cfscript>
</cffunction>



<cffunction name="getSearchSQLStruct" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	ts={
		type="=",
		field: arguments.row.site_option_name,
		arrValue:[]
	};
	if(arguments.value NEQ ""){
		if(structkeyexists(arguments.optionStruct, 'datetime_range_search_type') and arguments.optionStruct.datetime_range_search_type EQ 1){
			// start date
			ts.type=">=";
			arrayAppend(ts.arrValue, dateformat(arguments.value, 'yyyy-mm-dd')&' 00:00:00');
		}else if(structkeyexists(arguments.optionStruct, 'datetime_range_search_type') and arguments.optionStruct.datetime_range_search_type EQ 2){
			// end date
			ts.type="<=";
			arrayAppend(ts.arrValue, dateformat(arguments.value, 'yyyy-mm-dd')&' 23:59:59');
		}else{
			arrayAppend(ts.arrValue, dateformat(arguments.value, 'yyyy-mm-dd')&' 00:00:00');
		}
	}
	return ts;
	</cfscript>
</cffunction>

<cffunction name="getSearchSQL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="databaseField" type="string" required="yes">
	<cfargument name="databaseDateField" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	if(arguments.value NEQ ""){
		if(structkeyexists(arguments.optionStruct, 'datetime_range_search_type') and arguments.optionStruct.datetime_range_search_type EQ 1){
			// start date
			return arguments.databaseDateField&' >= '&db.trustedSQL("'"&application.zcore.functions.zescape(dateformat(arguments.value, 'yyyy-mm-dd')&' 00:00:00')&"'");
		}else if(structkeyexists(arguments.optionStruct, 'datetime_range_search_type') and arguments.optionStruct.datetime_range_search_type EQ 2){
			// end date
			return arguments.databaseDateField&' <= '&db.trustedSQL("'"&application.zcore.functions.zescape(dateformat(arguments.value, 'yyyy-mm-dd')&' 23:59:59')&"'");
		}else{
			return arguments.databaseDateField&' = '&db.trustedSQL("'"&application.zcore.functions.zescape(dateformat(arguments.value, 'yyyy-mm-dd')&' 00:00:00')&"'");
		}
	}
	return ' 1 = 1 ';
	</cfscript>
</cffunction>

<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="labelStruct" type="struct" required="yes"> 
	<cfscript>
	var cfcatch=0;
	var excpt=0;
	var curDate="";
	try{
		if(application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id&'_date') NEQ ""){
			curDate=dateformat(arguments.dataStruct[arguments.prefixString&arguments.row.site_option_id&'_date'], "mm/dd/yyyy");
		}else if(application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id) NEQ ""){
			curDate=dateformat(arguments.dataStruct[arguments.prefixString&arguments.row.site_option_id], "mm/dd/yyyy");
		} 
	}catch(Any excpt){
		curDate="";
	}
	application.zcore.functions.zRequireJqueryUI();
	application.zcore.skin.addDeferredScript('$( "###arguments.prefixString##arguments.row.site_option_id#_date" ).datepicker();');
	return { label: true, hidden: false, value:'<input type="text" name="#arguments.prefixString&arguments.row.site_option_id#_date" id="#arguments.prefixString&arguments.row.site_option_id#_date" value="#curDate#" size="9" />'};
	</cfscript>
</cffunction>

<cffunction name="getListValue" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	if(structkeyexists(arguments.dataStruct, arguments.value)){
		return arguments.dataStruct[arguments.value];
	}else{
		return arguments.value; 
	}
	</cfscript>
</cffunction>

<cffunction name="onBeforeListView" localmode="modern" access="public" returntype="struct">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	return {};
	</cfscript>
</cffunction>

<cffunction name="onBeforeUpdate" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfscript>	
	var cfcatch=0;
	var excpt=0; 
	var curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id&'_date');
	if(curDate EQ ""){
		curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id);
		if(curDate EQ ""){
			return { success: true, value: "", dateValue: "" };
		}
	}
	try{
		var nvdate=dateformat(curDate, "yyyy-mm-dd")&" 00:00:00";
		var nv=dateformat(curDate, "m/d/yyyy");
	}catch(Any excpt){
		application.zcore.status.setStatus(request.zsid, arguments.row.site_option_name&" must be a valid date.", form, true);
		return { success: false, value: "", dateValue: "" };
	}
	return { success: true, value: nv, dateValue: nvdate };
	</cfscript>
</cffunction>

<cffunction name="validateFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	/*
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id);
	if(nv NEQ "" and doValidation...){
		return { success:false, message: arguments.row.site_option_display_name&" must ..." };
	}
	*/
	return {success:true};
	</cfscript>
</cffunction>


<cffunction name="getFormValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	if(structkeyexists(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id&'_date')){
		curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id&'_date');
		if(isDate(curDate)){
			return dateformat(curDate, "yyyy-mm-dd");
		}else{
			return "";
		}
	}else{
		curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id);
		if(isDate(curDate)){
			return dateformat(curDate, "yyyy-mm-dd");
		}else{
			return "";
		}
	}
	</cfscript>
</cffunction>

<cffunction name="getTypeName" localmode="modern" access="public">
	<cfscript>
	return 'Date';
	</cfscript>
</cffunction>

<cffunction name="hasCustomDelete" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return false;
	</cfscript>
</cffunction>

<cffunction name="onDelete" localmode="modern" access="public" output="no">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	</cfscript>
</cffunction>


<cffunction name="onUpdate" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	var error=false;
	if(false){
		application.zcore.status.setStatus(request.zsid, "Message");
		error=true;
	}
	if(error){
		application.zcore.status.setStatus(Request.zsid, false,arguments.dataStruct,true);
		return { success:false};
	}
	ts={
		datetime_range_search_type:application.zcore.functions.zso(arguments.dataStruct, 'datetime_range_search_type')	
	};
	arguments.dataStruct.site_option_type_json=serializeJson(ts);
	return { success:true};
	</cfscript>
</cffunction>
		

<cffunction name="getTypeForm" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var output="";
	var value=application.zcore.functions.zso(arguments.dataStruct, arguments.fieldName);
	</cfscript>
	<cfsavecontent variable="output">
	<input type="radio" name="site_option_type_id" value="5" onClick="setType(5);" <cfif value EQ 5>checked="checked"</cfif>/>
	Date<br />
	<div id="typeOptions5" style="display:none;padding-left:30px;"> </div>	
	</cfsavecontent>
	<cfreturn output>
</cffunction> 
</cfoutput>
</cfcomponent>