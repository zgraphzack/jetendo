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
	return "Use listing saved search example code";
	</cfscript>
</cffunction>

<cffunction name="getSearchFieldName" localmode="modern" access="public" returntype="string" output="no">
	<cfargument name="setTableName" type="string" required="yes">
	<cfargument name="groupTableName" type="string" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	return arguments.groupTableName&".#variables.siteType#_x_option_group_value";
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
	return "";
	</cfscript>
</cffunction>

<cffunction name="hasCustomDelete" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return true;
	</cfscript>
</cffunction>

<cffunction name="isCopyable" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return true;
	</cfscript>
</cffunction>

<cffunction name="onDelete" localmode="modern" access="public" output="no">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	// delete from the mls_saved_search table using the function from blog
        request.zos.listing.functions.zMLSSearchOptionsUpdate('delete', arguments.row["#variables.siteType#_x_option_group_value"]);
	</cfscript>
</cffunction>

<cffunction name="isSearchable" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return false;
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
	return '';
	</cfscript>
</cffunction>


<cffunction name="getSearchValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfscript>
	return '';
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
		type="LIKE",
		field: arguments.row["#variables.type#_option_name"],
		arrValue:[]
	};
	if(arguments.value NEQ ""){
		arrayAppend(ts.arrValue, '%'&arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]]&'%');
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
		return arguments.databaseField&' like '&db.trustedSQL("'%"&application.zcore.functions.zescape(arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]])&"%'");
	}
	return '';
	</cfscript>
</cffunction>

<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">  
	<cfsavecontent variable="local.output"> 
		<!--- map picker needs to have ajax javascript in the getFormField that runs on the live data fields instead of requiring you to click on verify link. --->
		<cfscript>
		db=request.zos.queryObject;
		db.sql="select * from #db.table("mls_saved_search", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		mls_saved_search_deleted = #db.param(0)# and
		mls_saved_search_id = #db.param(arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]])# ";
		qSearch=db.execute("qSearch");
		
		echo('<div id="searchAsStringDiv#arguments.row["#variables.type#_option_id"]#" style="">');
		for(row in qSearch){
			echo(arrayToList(request.zos.listing.functions.getSearchCriteriaDisplay(row), ", "));
		}
		echo('</div>');
		</cfscript>
		<input type="hidden" name="#arguments.prefixString##arguments.row["#variables.type#_option_id"]#" id="savedSearchParentId#arguments.row["#variables.type#_option_id"]#" value="#htmleditformat(arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]])#" /> <a href="##" onclick=" zShowModalStandard('/z/listing/advanced-search/modalEditSearchForm?callback=savedSearchCallback#arguments.row["#variables.type#_option_id"]#&amp;mls_saved_search_id='+encodeURIComponent($('##savedSearchParentId#arguments.row["#variables.type#_option_id"]#').val()), zWindowSize.width-100, zWindowSize.height-100);return false;" rel="nofollow">Edit Saved Search</a>
	</cfsavecontent>
	<cfscript>
	application.zcore.skin.addDeferredScript('
		function savedSearchCallback#arguments.row["#variables.type#_option_id"]#(obj){ 
			$("##savedSearchParentId#arguments.row["#variables.type#_option_id"]#").val(obj.mls_saved_search_id);
			$("##searchAsStringDiv#arguments.row["#variables.type#_option_id"]#").html(obj.searchAsString);
		}
		window.savedSearchCallback#arguments.row["#variables.type#_option_id"]#=savedSearchCallback#arguments.row["#variables.type#_option_id"]#;
	');
	return { label: true, hidden: false, value: local.output};  
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


<cffunction name="getListValue" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("mls_saved_search", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	mls_saved_search_deleted = #db.param(0)# and
	mls_saved_search_id = #db.param(arguments.value)# ";
	qSearch=db.execute("qSearch");
	
	for(row in qSearch){
		return arrayToList(request.zos.listing.functions.getSearchCriteriaDisplay(row), ", ");
	}
	return "";
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
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]);
	return { success: true, value: nv, dateValue: "" };
	</cfscript>
</cffunction>

<cffunction name="getFormValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	return application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]);
	</cfscript>
</cffunction>

<cffunction name="getTypeName" output="no" localmode="modern" access="public">
	<cfscript>
	return 'Listing Saved Search';
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
	arguments.dataStruct["#variables.type#_option_type_json"]="{}";
	return { success:true, optionStruct: {}};
	</cfscript>
</cffunction>
		
<cffunction name="getOptionFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={ 
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
	if(not application.zcore.app.siteHasApp("listing")){
		return "";
	}
	</cfscript>
	<cfsavecontent variable="output">
	<input type="radio" name="#variables.type#_option_type_id" value="21" onClick="setType(21);" <cfif value EQ 21>checked="checked"</cfif>/>
	#this.getTypeName()#<br />
	<div id="typeOptions21" style="display:none;padding-left:30px;">  
	</div>
	</cfsavecontent>
	<cfreturn output>
</cffunction> 


<cffunction name="getCreateTableColumnSQL" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return "`#arguments.fieldName#` int(11) NOT NULL DEFAULT '0' ";
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>