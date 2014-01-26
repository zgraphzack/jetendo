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
	<cfscript>
	var allowDelete=true;
	if(arguments.row.site_option_required EQ 1){
		allowDelete=false;
	}
	return { label: true, hidden: false, value:application.zcore.functions.zInputImage(arguments.prefixString&arguments.row.site_option_id, application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/site-options/', application.zcore.functions.zvar('domain',request.zos.globals.id)&'/zupload/site-options/',250, allowDelete)&'<br /><br />
	Note: The image will be resized to fit inside these pixel dimensions: '&
	application.zcore.functions.zso(arguments.optionStruct, 'imagewidth',false,'1000')&' x '&
	application.zcore.functions.zso(arguments.optionStruct, 'imageheight',false,'1000')&'<br />'};  
	</cfscript>
</cffunction>

<cffunction name="getListValue" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	if(arguments.value NEQ "" and fileexists(request.zos.globals.privatehomedir&'zupload/site-options/#arguments.value#')){
		return ('<img src="/zupload/site-options/#arguments.value#" alt="Uploaded Image" width="70" />');
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
	var nv="";
	var nvd=0;
	var arrList=0;
	var oldnv=0;
	var photoresize=0;
	form[arguments.prefixString&arguments.row.site_option_id]=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id);
	nv=form[arguments.prefixString&arguments.row.site_option_id];
	if(nv NEQ ""){
		var tempDir=getTempDirectory();
		if((len(nv) LTE len(tempDir) or left(nv, len(tempDir)) NEQ tempDir or not fileexists(nv))){
			if((len(nv) LTE len(request.zos.installPath) or left(nv, len(request.zos.installPath)) NEQ request.zos.installPath or not fileexists(nv))){
				return { success: true, value: replace(nv, '/zupload/site-options/', ''), dateValue: "" };
			}
		}
		photoresize=application.zcore.functions.zso(arguments.optionStruct, 'imagewidth',false,'1000')&"x"&application.zcore.functions.zso(arguments.optionStruct, 'imageHeight',false,'1000');
		nvd=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id&'_delete');
		arguments.dataStruct.site_x_option_group_id=arguments.row.site_x_option_group_id;
		arguments.dataStruct.site_x_option_group_value=nv; 
		if(application.zcore.functions.zso(arguments.optionStruct, 'imagecrop') EQ '1'){
			arrList = application.zcore.functions.zUploadResizedImagesToDb(arguments.prefixString&arguments.row.site_option_id, application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/site-options/', photoresize,'','','',request.zos.globals.datasource,'1');
		}else{
			arrList = application.zcore.functions.zUploadResizedImagesToDb(arguments.prefixString&arguments.row.site_option_id, application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/site-options/', photoresize);
		}
		if(isarray(arrList) EQ false){
			return {success:false, message: '<strong>PHOTO ERROR:</strong> invalid format or corrupted.  Please upload a jpeg, png or gif file.' };
			
			nv=oldnv;
		}else if(ArrayLen(arrList) NEQ 0){
			if(nvd EQ 1){
				application.zcore.functions.zdeletefile(application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/site-options/'&arguments.row.site_x_option_group_value);	
				oldnv='';
			}else{
				oldnv=arguments.row.site_x_option_group_value;
			}
			nv=arguments.dataStruct.site_x_option_group_value;
			nv=arrList[1];
			local.tempPath9=application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/site-options/'; 
			arguments.optionStruct.imagemaskpath=application.zcore.functions.zso(arguments.optionStruct, 'imagemaskpath');
			if(arguments.optionStruct.imagemaskpath NEQ ""){
				local.absImageMaskPath=request.zos.globals.homedir&removechars(arguments.optionStruct.imagemaskpath, 1, 1);
				
				var ts=structnew();
				ts.absImageMaskPath=local.absImageMaskPath;
				ts.absImageInputPath=local.tempPath9&nv;
				local.tempFileName=application.zcore.functions.zgetFileName(nv);
				local.tempIndex=1;
				while(true){
					if(not fileexists(local.tempPath9&local.tempFileName&local.tempIndex&".png")){
						break;
					}
					local.tempIndex++;
					if(local.tempIndex GTE 500){
						throw("Infinite loop when applying image mask", "custom");
					}
				}
				ts.absImageOutputPath=local.tempPath9&local.tempFileName&local.tempIndex&".png"; 
				var result=application.zcore.functions.zApplyMaskToImage(ts); 
				if(result){
					nv=local.tempFileName&local.tempIndex&".png";
				}else{
					nv=oldnv;
					application.zcore.status.setStatus(request.zsid, 'Failed to apply mask to image.  Verify mask file is valid and still exists.');	
				}
				if(ts.absImageInputPath NEQ ts.absImageOutputPath){
					application.zcore.functions.zdeleteFile(ts.absImageInputPath);	
				}
			}
			if(oldnv NEQ "" and nv NEQ oldnv){
				application.zcore.functions.zdeletefile(local.tempPath9&oldnv);	
			}
		}else{
			nv=oldnv;
		}
	}else{
		nv=arguments.row.site_x_option_group_value;	
		structdelete(form, arguments.prefixString&arguments.row.site_option_id);
		nvd=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row.site_option_id&'_delete');
		if(nvd EQ 1){
			application.zcore.functions.zdeletefile(application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/site-options/'&arguments.row.site_x_option_group_value);
			nv='';	
		}
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
	return 'Image';
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
		imagewidth:application.zcore.functions.zso(arguments.dataStruct, 'imagewidth'),
		imageheight:application.zcore.functions.zso(arguments.dataStruct, 'imageheight'),
		imagecrop:application.zcore.functions.zso(arguments.dataStruct, 'imagecrop'),
		imagemaskpath:application.zcore.functions.zso(arguments.dataStruct, 'imagemaskpath')
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
	<input type="radio" name="site_option_type_id" value="3" onClick="setType(3);" <cfif value EQ 3>checked="checked"</cfif>/>
	Image<br />
	<div id="typeOptions3" style="display:none;padding-left:30px;"> Image Max Width:
		<input type="text" name="imagewidth" value="#htmleditformat(application.zcore.functions.zso(arguments.optionStruct, 'imagewidth'))#" />
		Image Max Height:
		<input type="text" name="imageheight" value="#htmleditformat(application.zcore.functions.zso(arguments.optionStruct, 'imageheight'))#" />
		Crop:
		<input type="radio" name="imagecrop" value="1" <cfif application.zcore.functions.zso(arguments.optionStruct, 'imagecrop') EQ 1 and application.zcore.functions.zso(arguments.optionStruct, 'imagecrop') NEQ "">checked="checked"</cfif>/>
		Yes
		<input type="radio" name="imagecrop" value="0" <cfif application.zcore.functions.zso(arguments.optionStruct, 'imagecrop') EQ "" or application.zcore.functions.zso(arguments.optionStruct, 'imagecrop') EQ 0>checked="checked"</cfif>/>
		No<br />
		Image Mask URL: 
		<input type="text" name="imagemaskpath" value="#htmleditformat(application.zcore.functions.zso(arguments.optionStruct, 'imagemaskpath'))#" />
	</div>
							
	</cfsavecontent>
	<cfreturn output>
</cffunction> 
</cfoutput>
</cfcomponent>