<cfcomponent implements="zcorerootmapping.interface.optionType">
<cfoutput>
<cffunction name="init" localmode="modern" access="public" output="no">
	<cfargument name="type" type="string" required="yes">
	<cfargument name="siteType" type="string" required="yes">
	<cfscript>
	variables.type=arguments.type;
	variables.siteType=arguments.siteType;
	</cfscript>
</cffunction>

<cffunction name="getDebugValue" localmode="modern" access="public" returntype="string" output="no">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	return dateformat(now(), "m/d/yyyy");
	</cfscript>
</cffunction>

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
	return "s"&arguments.fieldIndex&".#variables.siteType#_x_option_group_date_value "&arguments.sortDirection;
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
		return arguments.setTableName&".#variables.siteType#_x_option_group_set_start_date";
	}else if(searchType EQ 2){
		// end date
		request.zos.siteOptionSearchDateRangeSortEnabled=true;
		return arguments.setTableName&".#variables.siteType#_x_option_group_set_end_date";
	}else{
		return arguments.groupTableName&".#variables.siteType#_x_option_group_value";
	}
	</cfscript>
</cffunction>

<cffunction name="isCopyable" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return true;
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
		echo(' $( "###arguments.prefixString&arguments.row["#variables.type#_option_id"]#" ).datepicker();');
	}
	if(structkeyexists(form, 'x_ajax_id')){
		js='<script type="text/javascript">/* <![CDATA[ */'&js&'/* ]]> */</script>';
	}else{
		application.zcore.skin.addDeferredScript(js);
		js='';
	}
	return '<input type="text" name="#arguments.prefixString##arguments.row["#variables.type#_option_id"]#" onchange="#arguments.onChangeJavascript#" onkeyup="#arguments.onChangeJavascript#" onpaste="#arguments.onChangeJavascript#" id="#arguments.prefixString##arguments.row["#variables.type#_option_id"]#" value="#htmleditformat(dateformat(arguments.value, 'mm/dd/yyyy'))#" size="9" style="width:60px; min-width:60px;" />'&js;
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
	if(structkeyexists(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]&'_date')){
		local.tempDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]&'_date');
		arguments.searchStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]&"_date"]=local.tempDate;
	}else{
		local.tempDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]);
		arguments.searchStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]]=local.tempDate;
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
		if(arguments.row["#variables.type#_option_admin_search_default"] NEQ "" and isnumeric(arguments.row["#variables.type#_option_admin_search_default"])){
			finalDate=dateadd("d", arguments.row["#variables.type#_option_admin_search_default"], now());
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
		field: arguments.row["#variables.type#_option_name"],
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
	return db.trustedSQL(' 1 = 1 ');
	</cfscript>
</cffunction>

<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfscript>
	var cfcatch=0;
	var excpt=0;
	var curDate="";
	try{
		if(application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]&'_date') NEQ ""){
			curDate=dateformat(arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]&'_date'], "mm/dd/yyyy");
		}else if(application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]) NEQ ""){
			curDate=dateformat(arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]], "mm/dd/yyyy");
		} 
	}catch(Any excpt){
		curDate="";
	}
	application.zcore.functions.zRequireJqueryUI();
	application.zcore.skin.addDeferredScript('$( "###arguments.prefixString##arguments.row["#variables.type#_option_id"]#_date" ).datepicker();');
	return { label: true, hidden: false, value:'<input type="text" name="#arguments.prefixString&arguments.row["#variables.type#_option_id"]#_date" id="#arguments.prefixString&arguments.row["#variables.type#_option_id"]#_date" value="#curDate#" size="9" />'};
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
	var curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]&'_date');
	if(curDate EQ ""){
		curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]);
		if(curDate EQ ""){
			return { success: true, value: "", dateValue: "" };
		}
	}
	try{
		var nvdate=dateformat(curDate, "yyyy-mm-dd")&" 00:00:00";
		var nv=dateformat(curDate, "m/d/yyyy");
	}catch(Any excpt){
		application.zcore.status.setStatus(request.zsid, arguments.row["#variables.type#_option_name"]&" must be a valid date.", form, true);
		return { success: false, message: arguments.row["#variables.type#_option_name"]&" must be a valid date.", value: "", dateValue: "" };
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
	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="onInvalidFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>  
	</cfscript>
</cffunction>


<cffunction name="getFormValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	if(structkeyexists(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]&'_date')){
		curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]&'_date');
		if(isDate(curDate)){
			return dateformat(curDate, "yyyy-mm-dd");
		}else{
			return "";
		}
	}else{
		curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]);
		if(isDate(curDate)){
			return dateformat(curDate, "yyyy-mm-dd");
		}else{
			return "";
		}
	}
	</cfscript>
</cffunction>

<cffunction name="getTypeName" output="no" localmode="modern" access="public">
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
	arguments.dataStruct["#variables.type#_option_type_json"]=serializeJson(ts);
	return { success:true, optionStruct: ts};
	</cfscript>
</cffunction>
		
<cffunction name="getOptionFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
		datetime_range_search_type:"0"
	};
	return ts;
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
	<input type="radio" name="#variables.type#_option_type_id" value="5" onClick="setType(5);" <cfif value EQ 5>checked="checked"</cfif>/>
	Date<br />
	<div id="typeOptions5" style="display:none;padding-left:30px;"> </div>	
	</cfsavecontent>
	<cfreturn output>
</cffunction>

<cffunction name="getCreateTableColumnSQL" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return "`#arguments.fieldName#` date NOT NULL DEFAULT '0000-00-00'";
	</cfscript>
</cffunction> 
</cfoutput>
</cfcomponent>