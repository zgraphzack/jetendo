<cfcomponent implements="zcorerootmapping.interface.siteOptionType">
<cfoutput>
<cffunction name="getSearchFieldName" localmode="modern" access="public" returntype="string" output="no">
	<cfargument name="setTableName" type="string" required="yes">
	<cfargument name="groupTableName" type="string" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	return arguments.groupTableName&".site_x_option_group_value";
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
		field: arguments.row.site_option_name,
		arrValue:[]
	};
	if(arguments.value NEQ ""){
		arrayAppend(ts.arrValue, '%'&arguments.dataStruct[arguments.prefixString&arguments.row.site_option_id]&'%');
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
		return arguments.databaseField&' like '&db.trustedSQL("'%"&application.zcore.functions.zescape(arguments.dataStruct[arguments.prefixString&arguments.row.site_option_id])&"%'");
	}
	return '';
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

<cffunction name="hasCustomDelete" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return true;
	</cfscript>
</cffunction>

<cffunction name="onDelete" localmode="modern" access="public" output="no">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	if(structkeyexists(arguments.row, 'site_x_option_group_value')){
		if(fileexists(application.zcore.functions.zvar('privatehomedir',arguments.row.site_id)&'zupload/site-options/'&arguments.row.site_x_option_group_value)){
			application.zcore.functions.zdeletefile(application.zcore.functions.zvar('privatehomedir',arguments.row.site_id)&'zupload/site-options/'&arguments.row.site_x_option_group_value);
		}
	}else{
		if(fileexists(application.zcore.functions.zvar('privatehomedir',arguments.row.site_id)&'zupload/site-options/'&arguments.row.site_x_option_value)){
			application.zcore.functions.zdeletefile(application.zcore.functions.zvar('privatehomedir',arguments.row.site_id)&'zupload/site-options/'&arguments.row.site_x_option_value);
		}
	}
	</cfscript>
</cffunction> 

<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfargument name="labelStruct" type="struct" required="yes"> 
	<cfsavecontent variable="local.output">
		<cfscript>
		var allowDelete=true;
		if(arguments.row.site_option_required EQ 1){
			allowDelete=false;
		}
		if(arguments.dataStruct[arguments.prefixString&arguments.row.site_option_id] NEQ ""){
			writeoutput('<p><a href="/zupload/site-options/#arguments.dataStruct[arguments.prefixString&arguments.row.site_option_id]#" target="_blank" title="#htmleditformat(arguments.dataStruct[arguments.prefixString&arguments.row.site_option_id])#">Download File</a></p>');
		}
		var ts3=StructNew();
		ts3.name=arguments.prefixString&arguments.row.site_option_id;
		ts3.allowDelete=allowDelete;
		application.zcore.functions.zInput_file(ts3);
		</cfscript>
	</cfsavecontent>
	<cfscript>
	return { label: true, hidden: false, value:local.output};  
	</cfscript> 
</cffunction>

<cffunction name="getListValue" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	if(arguments.value NEQ ""){
		return ('<a href="/zupload/site-options/#arguments.value#" target="_blank">Download File</a>');
	}else{
		return ('N/A');
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
	var nv=0;
	arguments.dataStruct.site_x_option_group_id=arguments.row.site_x_option_group_id;
	form[arguments.prefixString&arguments.row.site_option_id]=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id);
	nv=form[arguments.prefixString&arguments.row.site_option_id];
	var tempDir=getTempDirectory();
	if(nv NEQ ""){
		if((len(nv) LTE len(tempDir) or left(nv, len(tempDir)) NEQ tempDir or not fileexists(nv))){
			if(len(nv) LTE len(request.zos.installPath) or left(nv, len(request.zos.installPath)) NEQ request.zos.installPath or not fileexists(nv)){
				return {success:true, value:replace(nv, '/zupload/site-options/', ''), dateValue:""};
			}
		}
	}
	var fileName=application.zcore.functions.zUploadFileToDb(arguments.prefixString&arguments.row.site_option_id, application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/site-options/', 'site_x_option_group', 'site_x_option_group_id', arguments.prefixString&arguments.row.site_option_id&'_delete', request.zos.zcoredatasource, 'site_x_option_group_value');	
	if(isNull(fileName)){
		arguments.dataStruct[arguments.prefixString&arguments.row.site_option_id]=arguments.row.site_x_option_group_value;
		nv=arguments.row.site_x_option_group_value;
	}else{
		arguments.dataStruct[arguments.prefixString&arguments.row.site_option_id]=fileName;
		nv=local.fileName;
	}
	return { success: true, value: nv, dateValue: "" };
	</cfscript>
</cffunction>

<cffunction name="getFormValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id);
	if(nv EQ ""){
		if(structkeyexists(arguments.row,'site_x_option_group_value')){
			return arguments.row.site_x_option_group_value;
		}else{
			return arguments.row.site_x_option_value;
		}
	}
	return nv;
	</cfscript>
</cffunction>

<cffunction name="getTypeName" localmode="modern" access="public">
	<cfscript>
	return 'File';
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
	arguments.dataStruct.site_option_type_json="{}";
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
	<input type="radio" name="site_option_type_id" value="9" onClick="setType(9);" <cfif value EQ 9>checked="checked"</cfif>/>
	File<br />
	<div id="typeOptions9" style="display:none;padding-left:30px;">
	</div>
	</cfsavecontent>
	<cfreturn output>
</cffunction> 
</cfoutput>
</cfcomponent>