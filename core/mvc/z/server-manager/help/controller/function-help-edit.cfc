<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
<cfscript>
var db=request.zos.queryObject;
if(structkeyexists(form, 'zPageId') EQ false){
	form.zPageId = application.zcore.status.getNewId();
}
if(structkeyexists(form, 'zIndex')){
	 application.zcore.status.getField(form.zPageId, "zIndex", form.zIndex);
}else{
	form.zIndex = application.zcore.status.getField(form.zPageId, "zIndex", 1, true);
}
Request.zScriptName = request.cgi_script_name&"?zPageId=#form.zPageId#";
</cfscript>

<cfif form.action NEQ "autoParse">
<cfscript>
com=createobject("component", "zcorerootmapping.mvc.z.server-manager.help.controller.help-home");
com.index();
</cfscript>
<table style="width:100%; border-spacing:0px;">
<tr class="table-white">
<td><span class="large">Edit Function Reference</span></td>
</tr>
<tr class="table-list">
<td class="tiny-bold">
<a href="#Request.zScriptName#&action=list">Manage Functions</a> | <a href="#Request.zScriptName#&action=addGroup">Add Group</a> | <a href="#Request.zScriptName#&action=add">Add Function</a> | 
<a href="#Request.zScriptName#&action=autoParse">Auto Import</a></td>
</tr>
</table>
</cfif>
<cfif form.action EQ "autoParse">
	<!--- <cfscript>

		var db=request.zos.queryObject;
		</cfscript>
	Now using Coldfusion MX's introspection function getMetaData() to retieve all function parameters and attributes.
	<br /><br />
	This script checks if there is existing data and updates it.  Deletions must be done manually when function naming changes or when they are deleted.
	<br />
	<br />
	<cfoutput>
	<cfset Request.vars = Variables>
	<cfscript>
	StructClear(variables);
	</cfscript>
	<cfdirectory name="request.qDir" directory="#request.zos.globals.serverHomedir#functions/" action="list">
	<cfloop query="request.qDir">
		<cfif type EQ 'file' and name NEQ 'Application.cfm'>
			<cfsavecontent variable="db.sql">
			SELECT * FROM function_group WHERE function_group_filename = #db.param(name)#
			</cfsavecontent><cfscript>qGroup=db.execute("");</cfscript>
			<cfif qGroup.recordcount EQ 0>
				Error: You must add a function group for the file, `#name#`.  This file was not imported.<br />
			<cfelse>
				`#name#` imported.<br />
			<cfinclude template="/zcorerootmapping/functions/#name#">
			<cfscript>
			function_group_id = qGroup.function_group_id;
			request.arrFunctions = ArrayNew(1);
			for(n in variables){
				if(isCustomFunction(variables[n])){
					ArrayAppend(request.arrFunctions, variables[n]);
				}
			}
			arrFunctions = request.arrFunctions;
			function_help_datetime = dateformat(now(),'yyyy-mm-dd')&" "&timeformat(now(),'HH:mm:ss');
			</cfscript>
			<cfsavecontent variable="db.sql">
			UPDATE function_group SET function_group_file_datetime = #db.param(dateFormat(dateLastModified,'yyyy-mm-dd')&" "&timeformat(dateLastModified, 'HH:mm:ss'))# WHERE function_group_id= #db.param(function_group_id)#
			</cfsavecontent><cfscript>qGroup=db.execute("");</cfscript>
			<cfloop from="1" to="#ArrayLen(arrFunctions)#" index="i">
			<cfset funcData = getMetaData(arrFunctions[i])>
			<cfsavecontent variable="db.sql">
			SELECT * from cf_data_type WHERE cf_data_type_name = <cfif isDefined('funcData.returntype')>#db.param(funcData.returntype)#<cfelse>'1'</cfif>
			</cfsavecontent><cfscript>Request.qType=db.execute("");</cfscript>
			<cfsavecontent variable="db.sql">
			SELECT function_id FROM function WHERE function_name LIKE #db.param(funcData.name)#
			</cfsavecontent><cfscript>Request.qCheck=db.execute("");</cfscript>
			<!--- <br />
			<pre> --->
			<cfsavecontent variable="db.sql">
			<cfif Request.qCheck.recordcount NEQ 0>
			UPDATE function SET 
			<cfelse>
			INSERT INTO function SET 
			</cfif>
			function_name   = #db.param(funcData.name)#, 
			<cfif isDefined('funcData.displayName')>
			function_short_description   = #db.param(funcData.displayName)#, 
			</cfif>
			<cfif isDefined('funcData.hint')>
			function_description = #db.param(funcData.hint)#,
			</cfif>        
			function_group_id   =#db.param(function_group_id)#,      
			function_help_datetime   =#db.param(function_help_datetime)#,
			cf_data_type_id = #db.param(Request.qType.cf_data_type_id)#,
			zsites_id ='3'
			<cfif Request.qCheck.recordcount NEQ 0> 
			 where function_id = #db.param(Request.qCheck.function_id)#
			</cfif>
			</cfsavecontent><cfscript>Request.qFunction=db.execute("");</cfscript>
			<cfsavecontent variable="db.sql">
			SELECT function_id FROM function WHERE function_name = #db.param(funcData.name)#
			</cfsavecontent><cfscript>Request.qCheck=db.execute("");</cfscript>
			<cfif Request.qCheck.recordcount NEQ 0>
			<cfelse>
			<cfset function_id = '0'>
			</cfif>
			<cfset function_id = Request.qCheck.function_id>
			<!--- </pre><br /><br /> --->
					<cfloop from="1" to="#ArrayLen(funcData.parameters)#" index="t">
					<cfset cur = funcData.parameters[t]>
					<cfsavecontent variable="db.sql">
					SELECT function_param_id FROM function_param WHERE function_param_name = #db.param(cur.name)# and 
	function_id = #db.param(function_id)#
					</cfsavecontent><cfscript>Request.qCheckParam=db.execute("");</cfscript>
					<cfsavecontent variable="db.sql">
					SELECT * from cf_data_type WHERE cf_data_type_name = <cfif isDefined('cur.type')>#db.param(cur.type)#<cfelse>'1'</cfif>
					</cfsavecontent><cfscript>Request.qParamType=db.execute("");</cfscript>
					<cfsavecontent variable="db.sql">
						<cfif Request.qCheckParam.recordcount NEQ 0>
						UPDATE function_param SET 
						<cfelse>
						INSERT INTO function_param SET 
						</cfif>
						function_id = #db.param(function_id)#, 
						function_param_name = #db.param(cur.name)# , 
						<cfif isDefined('cur.hint')>
						function_param_description = #db.param(cur.hint)#,
						</cfif>
						 cf_data_type_id = #db.param(Request.qParamType.cf_data_type_id)#,
						<cfif cur.required EQ 'yes'>
						function_param_required = '1', 
						<cfelse>
						function_param_required = '0', 
						</cfif>
						function_param_sort = #db.param(t)#
								
						<cfif Request.qCheckParam.recordcount NEQ 0> 
						where function_param_id = #db.param(Request.qCheckParam.function_param_id)#
						</cfif>
					</cfsavecontent><cfscript>Request.qParam=db.execute("");</cfscript> 
				</cfloop>
			</cfloop>
			</cfif>
			<cfscript>
			StructClear(variables);
			</cfscript>
		</cfif>
	</cfloop>    
	  <br />Import complete, <a href="#Request.zScriptName#&action=list">Return to function reference</a>
	<cfscript>application.zcore.functions.zabort();</cfscript>
	 </cfoutput> --->
</cfif>



<cfif form.action EQ "delete">
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function", request.zos.zcoreDatasource)# function 
	WHERE function_id = #db.param(application.zcore.functions.zso(form,'function_id'))#
	</cfsavecontent><cfscript>qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "This Function no longer exists.",false,true);
		zoa = application.zcore.status.getField(form.zPageId, "zoa");
		if(zoa NEQ ""){
			application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
		}else{		
			application.zcore.functions.zRedirect(Request.zScriptName&"&zsid=#request.zsid#");
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		if(application.zcore.functions.zDeleteRecord("function", "function_id", "#request.zos.zcoreDatasource#") EQ false){		
			application.zcore.status.setStatus(request.zsid, "Failed to delete Function",false,true);
		}else{
			 db.sql="SELECT function_param_id FROM #db.table("function_param", request.zos.zcoreDatasource)# function_param 
			WHERE function_id = #db.param(function_id)#";
			qParams=db.execute("qParams");
			for(i=1;i LTE qParams.recordcount;i=i+1){
				form.function_param_id = qParams["function_param_id"][i];
				application.zcore.functions.zDeleteRecord("function_struct_key", "function_param_id", "#request.zos.zcoreDatasource#");
			}
			application.zcore.functions.zDeleteRecord("function_param", "function_id", "#request.zos.zcoreDatasource#");
			application.zcore.status.setStatus(request.zsid, "Function deleted");
		}
		zoa = application.zcore.status.getField(form.zPageId, "zoa");
		if(zoa NEQ ""){
			application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
		}else{		
			application.zcore.functions.zRedirect(Request.zScriptName&"&zsid=#request.zsid#");
		}
		</cfscript>
	<cfelse>
		<div style="text-align:center;"><span class="medium">
		Are you sure you want to delete this Function?<br /><br />
		#qCheck.function_name#
		<br /><br />
		<a href="#Request.zScriptName#&action=delete&confirm=1&function_id=#function_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="<cfif application.zcore.status.getField(form.zPageId, "zoa") NEQ "">#application.zcore.status.getField(form.zPageId, "zoa")#&zoaOff=1<cfelse>#Request.zScriptName#&action=list</cfif>">No</a></span></div>
	</cfif>









<cfelseif form.action EQ "deleteStructKey">
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function_struct_key", request.zos.zcoreDatasource)# function_struct_key 
	WHERE function_struct_key_id = #db.param(application.zcore.functions.zso(form, 'function_struct_key_id'))#
	</cfsavecontent><cfscript>qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "This StructKey no longer exists.",false,true);
		zoa = application.zcore.status.getField(form.zPageId, "zoa");
		if(zoa NEQ ""){
			application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
		}else{		
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=edit&function_id=#function_id#&zsid=#request.zsid#");
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		if(application.zcore.functions.zDeleteRecord("function_struct_key", "function_struct_key_id", "#request.zos.zcoreDatasource#") EQ false){		
			application.zcore.status.setStatus(request.zsid, "Failed to delete StructKey",false,true);
		}else{
			application.zcore.status.setStatus(request.zsid, "StructKey deleted");
		}
		zoa = application.zcore.status.getField(form.zPageId, "zoa");
		if(zoa NEQ ""){
			application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
		}else{		
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=edit&function_id=#function_id#&zsid=#request.zsid#");
		}
		</cfscript>
	<cfelse>
		<div style="text-align:center;"><span class="medium">
		Are you sure you want to delete this StructKey?<br /><br />
		#qCheck.function_struct_key_name#
		<br /><br />
		<a href="#Request.zScriptName#&action=deleteStructKey&confirm=1&function_struct_key_id=#function_struct_key_id#&function_id=#function_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="<cfif application.zcore.status.getField(form.zPageId, "zoa") NEQ "">#application.zcore.status.getField(form.zPageId, "zoa")#&zoaOff=1<cfelse>#Request.zScriptName#&function_id=#function_id#&action=edit</cfif>">No</a></span></div>
	</cfif>
	
	
	
	
	





<cfelseif form.action EQ "deleteGroup">
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function_group", request.zos.zcoreDatasource)# function_group 
WHERE function_group_id = #db.param(application.zcore.functions.zso(form, 'function_group_id'))#
	</cfsavecontent><cfscript>qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "This Group no longer exists.",false,true);
		zoa = application.zcore.status.getField(form.zPageId, "zoa");
		if(zoa NEQ ""){
			application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
		}else{		
			application.zcore.functions.zRedirect(Request.zScriptName&"&zsid=#request.zsid#");
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		if(application.zcore.functions.zDeleteRecord("function_group", "function_group_id", "#request.zos.zcoreDatasource#") EQ false){		
			application.zcore.status.setStatus(request.zsid, "Failed to delete Group",false,true);
		}else{
			 db.sql="SELECT function_id FROM #db.table("function", request.zos.zcoreDatasource)# function 
			WHERE function_group_id = #db.param(function_group_id)#";
			qFunctions=db.execute("qFunctions");
			for(i=1;i LTE qFunctions.recordcount;i=i+1){
				form.function_id = qFunctions["function_id"][i];
				application.zcore.functions.zDeleteRecord("function", "function_id", "#request.zos.zcoreDatasource#");
				 db.sql="SELECT function_param_id FROM #db.table("function_param", request.zos.zcoreDatasource)# function_param 
				WHERE function_id = #db.param(form.function_id)#";
				qParams=db.execute("qParams");
				for(n=1;n LTE qParams.recordcount;n=n+1){
					form.function_param_id = qParams["function_param_id"][n];
					application.zcore.functions.zDeleteRecord("function_struct_key", "function_param_id", "#request.zos.zcoreDatasource#");
				}
				application.zcore.functions.zDeleteRecord("function_param", "function_id", "#request.zos.zcoreDatasource#");
				
			}
			application.zcore.status.setStatus(request.zsid, "Group deleted");
		}
		zoa = application.zcore.status.getField(form.zPageId, "zoa");
		if(zoa NEQ ""){
			application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
		}else{		
			application.zcore.functions.zRedirect(Request.zScriptName&"&zsid=#request.zsid#");
		}
		</cfscript>
	<cfelse>
		<div style="text-align:center;"><span class="medium">
		Are you sure you want to delete this Group?<br /><br />
		#qCheck.function_group_name#
		<br /><br />
		<a href="#Request.zScriptName#&action=deleteGroup&confirm=1&function_group_id=#function_group_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="<cfif application.zcore.status.getField(form.zPageId, "zoa") NEQ "">#application.zcore.status.getField(form.zPageId, "zoa")#&zoaOff=1<cfelse>#Request.zScriptName#</cfif>">No</a></span></div>
	</cfif>
	
	
	
	


<cfelseif form.action EQ "insertGroup" or form.action EQ "updateGroup">
	<cfscript>
	myForm.function_group_name.required = true;
	myForm.function_group_filename.required = true;
	errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid,true);
	if(errors){
		if(form.action EQ "insertGroup"){
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=addGroup&zsid=#request.zsid#");
		}else{
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=editGroup&function_group_id=#function_group_id#&zsid=#request.zsid#");
		}
	}
	</cfscript>
	<!--- get date of last file modification --->
	<cfdirectory action="list" directory="#request.zos.globals.serverHomeDir#functions/" filter="#function_group_filename#" name="qFile">
	<cfscript>
	if(qFile.recordcount EQ 0){	
		application.zcore.status.setStatus(request.zsid, "Function file is missing.",false,true);
		if(form.action EQ "insert"){
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=add&zsid=#request.zsid#");
		}else{
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=edit&function_id=#function_id#&zsid=#request.zsid#");
		}
	}
	function_group_file_datetime = DateFormat(qFile.dateLastModified, "yyyy-mm-dd")&" "&TimeFormat(qFile.dateLastModified,"HH:mm:ss");
	if(form.action EQ "insertGroup"){
		ts = StructNew();
		ts.table = "function_group";
		ts.datasource="#request.zos.zcoreDatasource#";
		function_group_id = application.zcore.functions.zInsert(ts);
		if(function_group_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Sorry, but the Group name, """ & function_group_name & """, is already used. Please type a different Group name.",form,true);
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=addGroup&zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, "Group, """ & function_group_name & """, Added Successfully.");
			zoa = application.zcore.status.getField(form.zPageId, "zoa");
			if(zoa NEQ ""){
				application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
			}else{		
				application.zcore.functions.zRedirect(Request.zScriptName&"&zsid=#request.zsid#");
			}
		}
	}else{
		ts = StructNew();
		ts.table = "function_group";
		ts.datasource="#request.zos.zcoreDatasource#";
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Sorry, but the Group name, """ & function_group_name & """, is already used. Please type a different Group name.",form,true);
			application.zcore.functions.zRedirect(Request.zScriptName&"&zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, "Group, """ & function_group_name & """, Updated Successfully.");
			
			zoa = application.zcore.status.getField(form.zPageId, "zoa");
			if(zoa NEQ ""){
				application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
			}else{		
				application.zcore.functions.zRedirect(Request.zScriptName&"&zsid=#request.zsid#");
			}
		}
	}
	</cfscript>	








<cfelseif form.action EQ "deleteParameter">
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function_param", request.zos.zcoreDatasource)# function_param 
	WHERE function_param_id = #db.param(application.zcore.functions.zso(form, 'function_param_id'))#
	</cfsavecontent><cfscript>qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "This Parameter no longer exists.",false,true);
		zoa = application.zcore.status.getField(form.zPageId, "zoa");
		if(zoa NEQ ""){
			application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
		}else{		
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=edit&function_id=#form.function_id#&zsid=#request.zsid#");
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		if(application.zcore.functions.zDeleteRecord("function_param", "function_param_id", "#request.zos.zcoreDatasource#") EQ false){		
			application.zcore.status.setStatus(request.zsid, "Failed to delete Parameter",false,true);
		}else{
			application.zcore.functions.zDeleteRecord("function_struct_key","function_param_id", "#request.zos.zcoreDatasource#");
			application.zcore.status.setStatus(request.zsid, "Parameter deleted");
		}
		zoa = application.zcore.status.getField(form.zPageId, "zoa");
		if(zoa NEQ ""){
			application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
		}else{		
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=edit&function_id=#form.function_id#&zsid=#request.zsid#");
		}
		</cfscript>
	<cfelse>
		<div style="text-align:center;"><span class="medium">
		Are you sure you want to delete this Parameter?<br /><br />
		#qCheck.function_param_name#
		<br /><br />
		<a href="#Request.zScriptName#&action=deleteParameter&confirm=1&function_param_id=#function_param_id#&function_id=#function_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="<cfif application.zcore.status.getField(form.zPageId, "zoa") NEQ "">#application.zcore.status.getField(form.zPageId, "zoa")#&zoaOff=1<cfelse>#Request.zScriptName#&function_id=#function_id#&action=edit</cfif>">No</a></span></div>
	</cfif>
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

<cfelseif form.action EQ "insertStructKey" or form.action EQ "updateStructKey">
	<cfscript>
	myForm.function_struct_key_name.required = true;
	myForm.function_param_id.required = true;
	myForm.cf_data_type_id.required = true;
	errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid,true);
	if(errors){
		if(form.action EQ "insertStructKey"){
			application.zcore.functions.zRedirect(Request.zScriptName&"&function_id=#function_id#&action=addStructKey&zsid=#request.zsid#");
		}else{
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=editStructKey&function_id=#function_id#&function_param_id=#function_param_id#&zsid=#request.zsid#");
		}
	}
	if(form.action EQ "insertStructKey"){
		ts = structNew();
		ts.table = "function_struct_key";
		ts.datasource="#request.zos.zcoreDatasource#";
		function_struct_key_id = application.zcore.functions.zInsert(ts);
		if(function_struct_key_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Sorry, but the StructKey name, """ & function_struct_key_name & """, is already used. Please type a different StructKey name.",form,true);
			application.zcore.functions.zRedirect(Request.zScriptName&"&function_id=#function_id#&function_param_id=#function_param_id#&action=addStructKey&zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, "StructKey, """ & function_struct_key_name & """, Added Successfully.");
			zoa = application.zcore.status.getField(form.zPageId, "zoa");
			if(zoa NEQ ""){
				application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
			}else{		
				application.zcore.functions.zRedirect(Request.zScriptName&"&action=addStructKey&function_id=#function_id#&function_param_id=#function_param_id#&zsid=#request.zsid#");
			}
		}
	}else{
		ts = StructNew();
		ts.table = "function_struct_key";
		ts.datasource="#request.zos.zcoreDatasource#";
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Sorry, but the StructKey name, """ & function_struct_key_name & """, is already used. Please type a different StructKey name.",form,true);
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=editStructKey&function_id=#function_id#&function_param_id=#function_param_id#&zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, "StructKey, """ & function_struct_key_name & """, Updated Successfully.");
			
			zoa = application.zcore.status.getField(form.zPageId, "zoa");
			if(zoa NEQ ""){
				application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
			}else{		
				application.zcore.functions.zRedirect(Request.zScriptName&"&action=edit&function_id=#function_id#&zsid=#request.zsid#");
			}
		}
	}
	</cfscript>	








<cfelseif form.action EQ "editStructKey" or form.action EQ "addStructKey">
	<cfscript>
	var currentMethod=form.action;
	function_struct_key_id = application.zcore.functions.zso(form, 'function_struct_key_id',true,-1);
	if(application.zcore.functions.zo('function_param_id') EQ ""){	
		application.zcore.status.setStatus(request.zsid, "Missing Function Param ID",false,true);
		application.zcore.functions.zRedirect(Request.zScriptName&"&zsid=#request.zsid#");
	}
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function", request.zos.zcoreDatasource)# function 
	WHERE function_id = #db.param(function_id)#
	</cfsavecontent><cfscript>qFunction=db.execute("qFunction");</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function_param", request.zos.zcoreDatasource)# function_param 
	WHERE function_param_id = #db.param(function_param_id)#
	</cfsavecontent><cfscript>qParam=db.execute("qParam");</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function_struct_key", request.zos.zcoreDatasource)# function_struct_key 
	WHERE function_struct_key_id = #db.param(function_struct_key_id)# 
	</cfsavecontent><cfscript>qStructKey=db.execute("qStructKey");
	application.zcore.functions.zQueryToStruct(qStructKey, variables,"function_param_id");
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	
	
	<table style="border-spacing:0px; width:100%;" class="table-list">
	<tr>
	<td><cfif currentMethod EQ "editStructKey">Edit<cfelse>Add</cfif> StructKey<br />
		<span class="small">Parameter "#qParam.function_param_name#" of "#qFunction.function_name#" Function</span></td>
	</tr>
	</table>
	
	<table style="border-spacing:0px;" class="table-list">
	<form action="#Request.zScriptName#&action=<cfif currentMethod EQ "editStructKey">update<cfelse>insert</cfif>StructKey&function_param_id=#function_param_id#&function_id=#function_id#" method="post">
	<input type="hidden" name="function_struct_key_id" value="#function_struct_key_id#">
	<tr>
		<td class="table-list" style="vertical-align:top;">Name:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_struct_key_name", "table-error","table-white")#><input name="function_struct_key_name" type="text" size="100" maxlength="255" value="#function_struct_key_name#"></td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top;">Data Type:</td>
		<td #application.zcore.status.getErrorStyle(request.zsid, "cf_data_type_id", "table-error","table-white")# >
			<cfsavecontent variable="db.sql">
			select * from #db.table("cf_data_type", request.zos.zcoreDatasource)# cf_data_type ORDER BY cf_data_type_name ASC
			</cfsavecontent><cfscript>qTypes=db.execute("qTypes");
			selectStruct = StructNew();
			selectStruct.name = "cf_data_type_id";
			// options for query data
			selectStruct.query = qTypes;
			selectStruct.queryLabelField = "cf_data_type_name";
			selectStruct.queryValueField = "cf_data_type_id";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
		</td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top;">Default:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_struct_key_default", "table-error","table-white")#><input name="function_struct_key_default" type="text" size="100" maxlength="255" value="#function_struct_key_default#"></td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top; width:120px;">Comment:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_struct_key_comment", "table-error","table-white")#>
		<input name="function_struct_key_comment" type="text" size="100" maxlength="255" value="#function_struct_key_comment#"></td>
	</tr><!--- 
	<tr>
		<td class="table-list" style="vertical-align:top;">Sort:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_struct_key_sort", "table-error","table-white")#><input name="function_struct_key_sort" type="text" size="10" maxlength="255" value="#function_struct_key_sort#"></td>
	</tr> --->
	<tr>
		<td class="table-list" style="vertical-align:top;">Required:</td>
		<td #application.zcore.status.getErrorStyle(request.zsid, "function_struct_key_required", "table-error","table-white")#>Yes <input type="radio" name="function_struct_key_required"   value="1"> No <input type="radio" name="function_struct_key_required" value="0" <cfif application.zcore.functions.zo('function_struct_key_required',true) EQ 0>checked="checked"</cfif>></td>
	</tr>
	<tr>
		<td class="table-list">&nbsp;</td>
		<td class="table-white"><input type="submit" name="submit" value="<cfif currentMethod EQ "editStructKey">Update<cfelse>Add</cfif> StructKey"> <input type="button" name="cancel" value="Cancel" onClick="document.location = '<cfif application.zcore.status.getField(form.zPageId, "zoa") NEQ "">#application.zcore.status.getField(form.zPageId, "zoa")#&zoaOff=1<cfelse>#Request.zScriptName#&action=edit&function_id=#function_id#</cfif>';"></td>
	</tr>
	</form>
	</table>		
	
	
	










<cfelseif form.action EQ "insertParameter" or form.action EQ "updateParameter">
	<cfscript>
	myForm.function_param_name.required = true;
	myForm.function_id.required = true;
	myForm.cf_data_type_id.required = true;
	errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	if(errors){
		if(form.action EQ "insertParameter"){
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=addParameter&zsid=#request.zsid#");
		}else{
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=editParameter&function_id=#function_id#&zsid=#request.zsid#");
		}
	}
	if(form.action EQ "insertParameter"){
		ts = structNew();
		ts.table = "function_param";
		ts.datasource="#request.zos.zcoreDatasource#";
		function_param_id = application.zcore.functions.zInsert(ts);
		if(function_param_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Sorry, but the Parameter name, """ & function_param_name & """, is already used. Please type a different Parameter name.",form,true);
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=addParameter&zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, "Parameter, """ & function_param_name & """, Added Successfully.");
			zoa = application.zcore.status.getField(form.zPageId, "zoa");
			if(zoa NEQ ""){
				application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
			}else{		
				application.zcore.functions.zRedirect(Request.zScriptName&"&action=addParameter&function_id=#function_id#&zsid=#request.zsid#");
			}
		}
	}else{
		ts = StructNew();
		ts.table = "function_param";
		ts.datasource="#request.zos.zcoreDatasource#";
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Sorry, but the Parameter name, """ & function_param_name & """, is already used. Please type a different Parameter name.",form,true);
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=editParameter&function_id=#function_id#&zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, "Parameter, """ & function_param_name & """, Updated Successfully.");
			
			zoa = application.zcore.status.getField(form.zPageId, "zoa");
			if(zoa NEQ ""){
				application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
			}else{		
				application.zcore.functions.zRedirect(Request.zScriptName&"&action=edit&function_id=#function_id#&zsid=#request.zsid#");
			}
		}
	}
	</cfscript>	












<cfelseif form.action EQ "insert" or form.action EQ "update">
	<cfscript>
	myForm.function_name.required = true;
	myForm.function_short_description.required = true;
	myForm.function_short_description.html = false;
	myForm.function_group_id.required = true;
	myForm.cf_data_type_id.required = true;
	myForm.function_help_datetime.createDateTime = true;
	errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid,true);
	if(errors){
		application.zcore.status.setStatus(request.zsid, false,form,true);
		if(form.action EQ "insert"){
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=add&zsid=#request.zsid#");
		}else{
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=edit&function_id=#function_id#&zsid=#request.zsid#");
		}
	}
	
	
	if(form.action EQ "insert"){
		ts = StructNew();
		ts.table = "function";
		ts.datasource="#request.zos.zcoreDatasource#";
		function_id = application.zcore.functions.zInsert(ts);
		if(function_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Sorry, but the Function name, """ & function_name & """, is already used. Please type a different Function name.",form,true);
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=add&zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, "Function, """ & function_name & """, Added Successfully.");
			zoa = application.zcore.status.getField(form.zPageId, "zoa");
			if(zoa NEQ ""){
				application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
			}else{		
				application.zcore.functions.zRedirect(Request.zScriptName&"&zsid=#request.zsid#");
			}
		}
	}else{
		ts = StructNew();
		ts.table = "function";
		ts.datasource="#request.zos.zcoreDatasource#";
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Sorry, but the Function name, """ & function_name & """, is already used. Please type a different Function name.",form,true);
			application.zcore.functions.zRedirect(Request.zScriptName&"&action=edit&function_id=#function_id#&zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, "Function, """ & function_name & """, Updated Successfully.");
			
			zoa = application.zcore.status.getField(form.zPageId, "zoa");
			if(zoa NEQ ""){
				application.zcore.functions.zRedirect(zoa&"&zsid=#request.zsid#&zoaOff=1");
			}else{		
				application.zcore.functions.zRedirect(Request.zScriptName&"&zsid=#request.zsid#");
			}
		}
	}
	</cfscript>	
	








<cfelseif form.action EQ "editGroup" or form.action EQ "addGroup">
	<cfscript>
	var currentMethod=form.action;
	function_group_id = application.zcore.functions.zo('function_group_id',true,-1);
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function_param", request.zos.zcoreDatasource)# function_group 
WHERE function_group_id = #db.param(function_group_id)# 
	</cfsavecontent><cfscript>qGroup=db.execute("qGroup");
	application.zcore.functions.zQueryToStruct(qGroup);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	
	
	<table style="border-spacing:0px;width:100%;" class="table-list">
<tr>
<td><cfif form.action EQ "editGroup">Edit<cfelse>Add</cfif> Group</td>
</tr>
</table>
	<table style="border-spacing:0px;" class="table-list">
	<form action="#Request.zScriptName#&action=<cfif currentMethod EQ "editGroup">update<cfelse>insert</cfif>Group" method="post">
	<input type="hidden" name="function_group_id" value="#function_group_id#">
	<tr>
		<td class="table-list" style="vertical-align:top;">Name:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_group_name", "table-error","table-white")#><input name="function_group_name" type="text" size="100" maxlength="255" value="#function_group_name#"></td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top;">File:</td>
		<td #application.zcore.status.getErrorStyle(request.zsid, "function_group_filename", "table-error","table-white")# >
			<cfdirectory action="list" directory="#request.zos.globals.serverHomedir#functions/" filter="*.cfm" name="qFiles" sort="ASC">
			<cfscript>
			selectStruct = StructNew();
			selectStruct.name = "function_group_filename";
			// options for query data
			selectStruct.query = qFiles;
			selectStruct.queryLabelField = "name";
			selectStruct.queryValueField = "name";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
		</td>
	</tr>
	<tr>
		<td class="table-list">&nbsp;</td>
		<td class="table-white"><input type="submit" name="submit" value="<cfif currentMethod EQ "editGroup">Update<cfelse>Add</cfif> Group"> <input type="button" name="cancel" value="Cancel" onClick="document.location = '<cfif application.zcore.status.getField(form.zPageId, "zoa") NEQ "">#application.zcore.status.getField(form.zPageId, "zoa")#&zoaOff=1<cfelse>#Request.zScriptName#</cfif>';"></td>
	</tr>
	</form>
	</table>		












<cfelseif form.action EQ "editParameter" or form.action EQ "addParameter">
	<cfscript>
	var currentMethod=form.action;
	function_param_id = application.zcore.functions.zso(form, 'function_param_id',true,-1);
	if(application.zcore.functions.zo('function_id') EQ ""){	
		application.zcore.status.setStatus(request.zsid, "Missing Function ID",false,true);
		application.zcore.functions.zRedirect(Request.zScriptName&"&zsid=#request.zsid#");
	}
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function", request.zos.zcoreDatasource)# function 
WHERE function_id = #db.param(function_id)#
	</cfsavecontent><cfscript>qFunction=db.execute("qFunction");</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function_param", request.zos.zcoreDatasource)# function_param 
WHERE function_param_id = #db.param(function_param_id)# 
	</cfsavecontent><cfscript>qParameter=db.execute("qParameter");
	application.zcore.functions.zQueryToStruct(qParameter, variables,"function_id");
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	
	
	<table style="width:100%; border-spacing:0px;" class="table-list">
	<tr>
	<td><cfif currentMethod EQ "editParameter">Edit<cfelse>Add</cfif> Parameter<br />
		<span class="small">#qFunction.function_name# Function</span></td>
	</tr>
	</table>
	<table style="border-spacing:0px;" class="table-list">
	<form action="#Request.zScriptName#&action=<cfif currentMethod EQ "editParameter">update<cfelse>insert</cfif>Parameter&function_id=#function_id#" method="post">
	<input type="hidden" name="function_param_id" value="#function_param_id#">
	<tr>
		<td class="table-list" style="vertical-align:top;">Name:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_param_name", "table-error","table-white")#><input name="function_param_name" type="text" size="100" maxlength="255" value="#function_param_name#"></td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top;">Data Type:</td>
		<td #application.zcore.status.getErrorStyle(request.zsid, "cf_data_type_id", "table-error","table-white")# >
			<cfsavecontent variable="db.sql">
			select * from #db.table("cf_data_type", request.zos.zcoreDatasource)# cf_data_type ORDER BY cf_data_type_name ASC
			</cfsavecontent><cfscript>qTypes=db.execute("qTypes");
			selectStruct = StructNew();
			selectStruct.name = "cf_data_type_id";
			// options for query data
			selectStruct.query = qTypes;
			selectStruct.queryLabelField = "cf_data_type_name";
			selectStruct.queryValueField = "cf_data_type_id";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
		</td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top;">Default:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_param_default", "table-error","table-white")#><input name="function_param_default" type="text" size="100" maxlength="255" value="#function_param_default#"></td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top; width:120px;">Description:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_param_description", "table-error","table-white")#>
		<cfscript>
		configStruct = structNew();
		configStruct.name = "function_param_description";
		configStruct.width = "100%";
		configStruct.height = "100";
		configStruct.scriptURL = request.zos.globals.serverDomain&"/javascript/";
		configStruct.stylesheet = request.zos.globals.serverDomain&"/stylesheets/manager.css";
		application.zcore.functions.zInput_HTMLEditor(configStruct);
		</cfscript></td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top;">Sort:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_param_sort", "table-error","table-white")#><input name="function_param_sort" type="text" size="10" maxlength="255" value="#function_param_sort#"></td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top;">Required:</td>
		<td #application.zcore.status.getErrorStyle(request.zsid, "function_param_required", "table-error","table-white")#>Yes <input type="radio" name="function_param_required"   value="1"> No <input type="radio" name="function_param_required" value="0" <cfif application.zcore.functions.zo('function_param_required',true) EQ 0>checked="checked"</cfif>></td>
	</tr>
	<tr>
		<td class="table-list">&nbsp;</td>
		<td class="table-white"><input type="submit" name="submit" value="<cfif currentMethod EQ "editParameter">Update<cfelse>Add</cfif> Parameter"> <input type="button" name="cancel" value="Cancel" onClick="document.location = '<cfif application.zcore.status.getField(form.zPageId, "zoa") NEQ "">#application.zcore.status.getField(form.zPageId, "zoa")#&zoaOff=1<cfelse>#Request.zScriptName#&action=edit&function_id=#function_id#</cfif>';"></td>
	</tr>
	</form>
	</table>		













<cfelseif form.action EQ "edit" or form.action EQ "add">
	<cfscript>
	var currentMethod=form.action;
	function_id = application.zcore.functions.zo('function_id',true,-1);
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function", request.zos.zcoreDatasource)# 
WHERE function_id = #db.param(function_id)#
	</cfsavecontent><cfscript>qFunction=db.execute("qFunction");</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function_param", request.zos.zcoreDatasource)# function_param, 
	#db.table("cf_data_type", request.zos.zcoreDatasource)# cf_data_type 
WHERE function_id = #db.param(function_id)# 
	and cf_data_type.cf_data_type_id = function_param.cf_data_type_id
	ORDER BY function_param_sort ASC
	</cfsavecontent><cfscript>qParameters=db.execute("qParameters");
	application.zcore.functions.zQueryToStruct(qFunction);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
		
	<table style="width:100%; border-spacing:0px;" class="table-shadow">
	<tr>
	<td><cfif currentMethod EQ "edit">Edit<cfelse>Add</cfif> Function</td>
	</tr>
	</table>
	
	<table style="width:100%; border-spacing:0px;" class="table-list">
	<form action="#Request.zScriptName#&action=<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>" method="post">
	<input type="hidden" name="function_id" value="#function_id#">
	<tr>
		<td class="table-list" style="vertical-align:top;">Name:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_name", "table-error","table-white")#><input name="function_name" type="text" size="70" maxlength="255" value="#function_name#"></td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top;">Group:</td>
		<td #application.zcore.status.getErrorStyle(request.zsid, "function_group_id", "table-error","table-white")# >
			<cfsavecontent variable="db.sql">
			select * from #db.table("function_group", request.zos.zcoreDatasource)#  ORDER BY function_group_name ASC
			</cfsavecontent><cfscript>qGroups=db.execute("qGroups");
			selectStruct = StructNew();
			selectStruct.name = "function_group_id";
			// options for query data
			selectStruct.query = qGroups;
			selectStruct.queryLabelField = "function_group_name";
			selectStruct.queryValueField = "function_group_id";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
		</td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top;">Data Type:</td>
		<td #application.zcore.status.getErrorStyle(request.zsid, "cf_data_type_id", "table-error","table-white")# >
			<cfsavecontent variable="db.sql">
			select * from #db.table("cf_data_type", request.zos.zcoreDatasource)# 
			ORDER BY cf_data_type_name ASC
			</cfsavecontent><cfscript>qTypes=db.execute("qTypes");
			selectStruct = StructNew();
			selectStruct.name = "cf_data_type_id";
			// options for query data
			selectStruct.query = qTypes;
			selectStruct.queryLabelField = "cf_data_type_name";
			selectStruct.queryValueField = "cf_data_type_id";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
		</td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top; width:120px;">Short Description:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_short_description", "table-error","table-white")#><input name="function_short_description" type="text" size="120" maxlength="255" value="#function_short_description#"></td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top;">Description:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_name", "table-error","table-white")#>
		<cfscript>
		configStruct = structNew();
		configStruct.name = "function_description";
		configStruct.width = "100%";
		configStruct.height = "200";
		configStruct.scriptURL = request.zos.globals.serverDomain&"/javascript/";
		configStruct.stylesheet = request.zos.globals.serverDomain&"/stylesheets/manager.css";
		application.zcore.functions.zInput_HTMLEditor(configStruct);
		</cfscript></td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top;">Returns:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_returns", "table-error","table-white")#>
		<cfscript>
		configStruct = structNew();
		configStruct.name = "function_returns";
		configStruct.width = "100%";
		configStruct.height = "100";
		configStruct.scriptURL = request.zos.globals.serverDomain&"/javascript/";
		configStruct.stylesheet = request.zos.globals.serverDomain&"/stylesheets/manager.css";
		application.zcore.functions.zInput_HTMLEditor(configStruct);
		</cfscript></td>
	</tr>
	<tr>
		<td class="table-list" style="vertical-align:top;">Example:</td>
		<td  #application.zcore.status.getErrorStyle(request.zsid, "function_example", "table-error","table-white")#>
		<cfscript>
		configStruct = structNew();
		configStruct.name = "function_example";
		configStruct.width = "100%";
		configStruct.height = "200";
		configStruct.scriptURL = request.zos.globals.serverDomain&"/javascript/";
		configStruct.stylesheet = request.zos.globals.serverDomain&"/stylesheets/manager.css";
		application.zcore.functions.zInput_HTMLEditor(configStruct);
		</cfscript></td>
	</tr>

	<cfif currentMethod EQ "edit">
	<tr><td class="table-list">Parameters&nbsp;</td>
	<td class="table-white">
	<table style="border-spacing:0px;width:100%;" class="table-list">
	<tr>
	<td>Name</td>
	<td>Data Type</td>
	<td><a href="#Request.zScriptName#&action=addParameter&function_id=#function_id#" class="table-list">Add Parameter</a></td>
	</tr>
	<cfloop query="qParameters">
		<cfscript>
		// create input structure
		inputStruct = StructNew();
		// required
		inputStruct.currentRow = currentRow;
		inputStruct.style = "table-bright";
		inputStruct.style2 = "table-bright";
		inputStruct.styleOver = "table-white";
		inputStruct.output = false;
		inputStruct.name = "param_list";
		rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
		</cfscript>
			<tr #rollOverCode#>
		<td>#function_param_name#&nbsp;</td>	
		<td>#cf_data_type_name#</td>	
		<td><a href="#Request.zScriptName#&action=editParameter&function_id=#function_id#&function_param_id=#function_param_id#">Edit</a>  | <a href="#Request.zScriptName#&action=deleteParameter&function_id=#function_id#&function_param_id=#function_param_id#">Delete</a>&nbsp;</td>	
		</tr>
		<cfif cf_data_type_name EQ "Struct">
			<tr><td colspan="3" class="table-white">
			<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr class="table-list">
			<td>Struct Key Name</td>
			<td>Data Type</td>
			<td><a href="#Request.zScriptName#&action=addStructKey&function_param_id=#function_param_id#&function_id=#function_id#" class="table-list">Add Struct Key</a></td>
			</tr>
			<cfsavecontent variable="db.sql">
			SELECT * FROM #db.table("function_struct_key", request.zos.zcoreDatasource)# function_struct_key, #db.table("cf_data_type", request.zos.zcoreDatasource)# cf_data_type
			WHERE function_param_id = #db.param(function_param_id)#
			 and cf_data_type.cf_data_type_id = function_struct_key.cf_data_type_id
			</cfsavecontent><cfscript>qStruct=db.execute("qStruct");</cfscript>
			<cfloop query="qStruct">
				<cfscript>
				// create input structure
				inputStruct = StructNew();
				// required
				inputStruct.currentRow = currentRow;
				inputStruct.style = "table-bright";
				inputStruct.style2 = "table-bright";
				inputStruct.styleOver = "table-white";
				inputStruct.output = false;
				inputStruct.name = "struct_key_list";
				rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
				</cfscript>
					<tr #rollOverCode#>
				<td>#function_struct_key_name#&nbsp;</td>	
				<td>#cf_data_type_name#</td>	
				<td><a href="#Request.zScriptName#&action=editStructKey&function_id=#function_id#&function_param_id=#function_param_id#&function_struct_key_id=#function_struct_key_id#">Edit</a>  | <a href="#Request.zScriptName#&action=deleteStructKey&function_id=#function_id#&function_param_id=#function_param_id#&function_struct_key_id=#function_struct_key_id#">Delete</a>&nbsp;</td>	
				</tr>
			</cfloop>	
			</table>
			</td></tr>
		</cfif>
	</cfloop>	
	</table>
	&nbsp;</td>
	</tr></cfif>
	<tr>
		<td class="table-list">Deprecate:&nbsp;</td>
		<td class="table-white"><input type="radio" name="function_deprecated" value="1" <cfif function_deprecated EQ 1>checked="checked"</cfif>> Yes <input type="radio" name="function_deprecated" value="0" <cfif function_deprecated EQ 0>checked="checked"</cfif>> No</td>
	</tr>
	<tr>
		<td class="table-list">&nbsp;</td>
		<td class="table-white"><input type="submit" name="submit" value="<cfif currentMethod EQ "edit">Update<cfelse>Add</cfif> Function"> <input type="button" name="cancel" value="Cancel" onClick="document.location = '<cfif application.zcore.status.getField(form.zPageId, "zoa") NEQ "">#application.zcore.status.getField(form.zPageId, "zoa")#&zoaOff=1<cfelse>#Request.zScriptName#&action=list</cfif>';"></td>
	</tr>
	</form>
	</table>		














<cfelseif form.action EQ "list">
	<cfsavecontent variable="db.sql">
	SELECT count(function_id) as count FROM #db.table("function", request.zos.zcoreDatasource)# 
	</cfsavecontent><cfscript>qCount=db.execute("qCount");
	perpage = 30;
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function_group", request.zos.zcoreDatasource)# function_group
	LEFT JOIN #db.table("function", request.zos.zcoreDatasource)# function ON 
	function.function_group_id = function_group.function_group_id 
	ORDER BY function_group_name ASC, function_name ASC
	LIMIT #db.param((form.zIndex-1)*perpage)#, #db.param(perpage)#
	</cfsavecontent><cfscript>qFunctions=db.execute("qFunctions");
	application.zcore.functions.zStatusHandler(request.zsid);
	
	// required
	searchStruct = StructNew();
	searchStruct.count = qCount.count;
	searchStruct.index = form.zIndex;
	searchStruct.url = Request.zScriptName;
	searchStruct.buttons = 5;
	searchStruct.perpage = perpage;
	
	// stylesheet overriding
	searchStruct.tableStyle = "table-white";
	searchStruct.linkStyle = "tiny";
	searchStruct.textStyle = "tiny";
	searchStruct.highlightStyle = "highlight tiny";
	
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	writeoutput(searchNav);
	</cfscript>
	<table style="border-spacing:0px; width:100%;" class="small">
	<form action="#Request.zScriptName#" name="zListForm" id="zListForm" method="post">
			<tr class="table-list">	
			<!--- <td style="width:30px;">&nbsp;</td> --->
			<td style="white-space:nowrap;">Name</td>	
			<td style="white-space:nowrap; width:120px;">Admin</td>	
			<td style="width:90%;">&nbsp;</td>
			</tr>	
			<cfset group = "">
	<cfloop query="qFunctions">
			<cfif group NEQ function_group_name>
				<tr class="table-list">
				<td style="white-space:nowrap;">#function_group_name# Functions&nbsp;</td>
				<td style="white-space:nowrap;"><a href="#Request.zScriptName#&action=editGroup&function_group_id=#function_group_id#">Edit</a>  | <a href="#Request.zScriptName#&action=deleteGroup&function_group_id=#function_group_id#">Delete</a></td>
				<td style="width:90%;">&nbsp;</td>
				</tr>		
				<cfset group = function_group_name>
			</cfif>
			<cfif application.zcore.functions.zo('function_id',true) NEQ 0>
				<cfscript>
				// create input structure
				inputStruct = StructNew();
				// required
				inputStruct.currentRow = currentRow;
				inputStruct.style = "table-bright";
				inputStruct.style2 = "table-bright";
				inputStruct.styleOver = "table-white";
				inputStruct.output = false;
				inputStruct.name = "functions";
				rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
				</cfscript>
			<tr #rollOverCode#>	
			<!--- <td><input type="checkbox" name="function_id" id="function_id" value="#function_id#" class="<cfif currentRow MOD 2 EQ 0>table-bright<cfelse>table-highlight</cfif>"></td> --->
			<td style="white-space:nowrap;">#function_name#&nbsp;</td>	
			<td style="white-space:nowrap;"><a href="#Request.zScriptName#&action=edit&function_id=#function_id#">Edit</a>  | <a href="#Request.zScriptName#&action=delete&function_id=#function_id#">Delete</a>&nbsp;</td>
			<td style="width:90%;">&nbsp;</td>
			</tr>
			</cfif>
	</cfloop>
	</form>
	</table>
	<cfscript>
	writeoutput(searchNav);
	</cfscript>
	

</cfif>
</cffunction>
</cfoutput>
</cfcomponent>