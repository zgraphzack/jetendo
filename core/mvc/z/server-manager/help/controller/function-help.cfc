<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
<cfscript>
var db=request.zos.queryObject;
var com=0;
form.action=application.zcore.functions.zso(form, 'action',false,'list');
com=createobject("component", "zcorerootmapping.mvc.z.server-manager.help.controller.help-home");
com.index();
</cfscript>
<table style="width:100%; border-spacing:0px;" class="small">
<form action="#request.cgi_script_name#?action=search" method="post">
<tr class="table-white">
<td><span class="large">Function Reference</span> | <a href="/z/server-manager/help/function-help-edit/index">Edit</a> | <a href="#request.cgi_script_name#?action=listDeprecated">View Deprecated Functions</a></td>
<td style="text-align:right"><input type="text" name="function_name" value="#application.zcore.functions.zso(form, 'function_name')#" size="30"> <input type="submit" name="Search" value="Search"></td>
</tr>
</form>
</table>

<cfif form.action EQ "search">
	<cfsavecontent variable="db.sql">
	SELECT function_id, function_name FROM #db.table("function", request.zos.zcoreDatasource)# function 
WHERE function_name LIKE  #db.param('%#application.zcore.functions.zso(form, 'function_name')#%')# 
	ORDER BY function_name ASC
	</cfsavecontent><cfscript>qSearch=db.execute("qSearch");</cfscript>
	
	
	
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function_group", request.zos.zcoreDatasource)# function_group 
	ORDER BY function_group_name ASC
	</cfsavecontent><cfscript>qGroups=db.execute("qGroups");</cfscript>
	
	
	
	<table style="width:100%; border-spacing:0px;">
	<td style="vertical-align:top; width:150px;">
	
	<!--- list group --->
	<table style="width:100%; border-spacing:0px;">
	
	<cfscript>
	// create input structure
	inputStruct = StructNew();
	// required
	inputStruct.currentRow = 0;
	inputStruct.style = "table-bright";
	inputStruct.style2 = "table-white";
	//inputStruct.styleOver = "table-white";
	inputStruct.output = false;
	inputStruct.name = "function_sidebar";
	
	inputStruct.currentRow = inputStruct.currentRow+1;
	rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
	</cfscript>
		<tr #rollOverCode# onClick="window.location.href = '#request.cgi_script_name#?action=list';">
	<td class="tiny-bold">Groups ^^</td>
	</tr>
	
	<!--- list functions --->
	<cfloop query="qGroups">
	<cfscript>
	inputStruct.currentRow = inputStruct.currentRow+1;
	rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
	</cfscript>
		<tr #rollOverCode# onClick="window.location.href = '#request.cgi_script_name#?action=listGroup&function_group_id=#function_group_id#';">
	<td class="tiny">#function_group_name#</td>
	</tr>
	
	</cfloop>
	</table>
	
	
	
	
	
	
	
	</td><td style="vertical-align:top;">
	
	
	
	<table style="width:100%; border-spacing:0px;">
	<tr class="table-bright">
	<td class="medium" colspan="3">
	<cfif qSearch.recordcount EQ 0>
		No Functions matched your search.
	<cfelseif qSearch.recordcount EQ 1>
		<cfscript>
		application.zcore.functions.zRedirect(request.cgi_script_name&"?action=listFunction&function_id="&qSearch.function_id);
		</cfscript>
	<cfelse>
	The following functions matched your search.
	</td></tr>
	</table>
	<table style="width:100%; border-spacing:0px;">
	<cfscript>	
	inputStruct = StructNew();
	inputStruct.colspan = 3;
	inputStruct.rowspan = qSearch.recordcount;
	inputStruct.vertical = true;
	myColumnOutput = CreateObject("component", "zcorerootmapping.com.display.loopOutput");
	myColumnOutput.init(inputStruct);
	</cfscript>
	<cfloop query="qSearch">
		#myColumnOutput.check(currentRow)#
	  <cfscript>
		// create input structure
		inputStruct = StructNew();
		// required
		inputStruct.currentRow = currentRow;
		inputStruct.style = "table-bright";
		inputStruct.style2 = "table-bright";
		inputStruct.styleOver = "table-white";
		inputStruct.output = false;
		inputStruct.name = "function_search"; // must follow variable naming conventions
		// run function
		rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
		</cfscript>
		<table style="width:100%; border-spacing:0px;">
		<tr #rollOverCode#>
		<td><a href="#request.cgi_script_name&"?action=listFunction&function_id="&function_id#">#function_name#</a></td>
		</tr>
		</table>
		#myColumnOutput.ifLastRow(currentRow)#
	</cfloop>
	</table>
	</cfif>
	</td>
	</tr>
	</table>
</cfif>

<cfif form.action EQ "listFunction">
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function", request.zos.zcoreDatasource)# function 
	LEFT JOIN #db.table("cf_data_type", request.zos.zcoreDatasource)# cf_data_type USING(cf_data_type_id)	
	WHERE function_id = #db.param(application.zcore.functions.zso(form, 'function_id'))# 
	</cfsavecontent><cfscript>qFunction=db.execute("qFunction");</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function_param", request.zos.zcoreDatasource)# function_param 
	LEFT JOIN #db.table("cf_data_type", request.zos.zcoreDatasource)# cf_data_type USING(cf_data_type_id)	
	WHERE function_id = #db.param(application.zcore.functions.zso(form, 'function_id'))# 
	ORDER BY function_param_sort ASC
	</cfsavecontent><cfscript>qParam=db.execute("qParam");</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function_param", request.zos.zcoreDatasource)# function_param, 
	#db.table("function_struct_key", request.zos.zcoreDatasource)#,
	 function_struct_key, #db.table("cf_data_type", request.zos.zcoreDatasource)# cf_data_type
	WHERE function_param.function_id = #db.param(application.zcore.functions.zso(form, 'function_id'))# and 
	function_param.function_param_id
	and function_param.function_param_id = function_struct_key.function_param_id
	and (function_struct_key.cf_data_type_id = cf_data_type.cf_data_type_id)
	ORDER BY function_param_sort ASC, function_struct_key_required DESC, function_struct_key_name ASC
	</cfsavecontent><cfscript>qStruct=db.execute("qStruct");
	if(qFunction.recordcount EQ 0){		
		application.zcore.status.setStatus(Request.zsid, "Function no longer exists.",false,true);
		application.zcore.functions.zRedirect(request.cgi_script_name&"?Request.zsid=#Request.zsid#");
	}
	application.zcore.functions.zQueryToStruct(qFunction);
	</cfscript>
	
	
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function", request.zos.zcoreDatasource)# function 
	WHERE function_group_id = #db.param(application.zcore.functions.zso(form, 'function_group_id'))# and 
	function_deprecated = #db.param('0')#
	ORDER BY function_name ASC
	</cfsavecontent><cfscript>qFunctions=db.execute("qFunctions");</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function_group", request.zos.zcoreDatasource)# 
	WHERE function_group_id = #db.param(application.zcore.functions.zso(form, 'function_group_id'))#
	</cfsavecontent><cfscript>qGroup=db.execute("qGroup");</cfscript>
	
	<table style="width:100%; border-spacing:0px;">
	<td style="vertical-align:top; width:150px;">
	
	<!--- list group --->
	<table style="width:100%; border-spacing:0px;">
	<cfscript>
	// create input structure
	inputStruct = StructNew();
	// required
	inputStruct.currentRow = 0;
	inputStruct.style = "table-bright";
	inputStruct.style2 = "table-white";
	//inputStruct.styleOver = "table-white";
	inputStruct.output = false;
	inputStruct.name = "function_sidebar";
	
	inputStruct.currentRow = inputStruct.currentRow+1;
	rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
	</cfscript>
		<tr #rollOverCode# onClick="window.location.href='#request.cgi_script_name#?action=list';">
	<td class="tiny-bold">Groups ^^</td>
	</tr>
	<cfscript>
	inputStruct.currentRow = inputStruct.currentRow+1;
	rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
	</cfscript>
		<tr #rollOverCode# onClick="window.location.href='#request.cgi_script_name#?action=listGroup&function_group_id=#qGroup.function_group_id#';">
	<td class="tiny-bold">#qGroup.function_group_name# ^</td>
	</tr>
	
	<!--- list functions --->
	<cfloop query="qFunctions">
		<cfif qFunction.function_id EQ function_id>
			<tr class="table-white"><td class="tiny">#function_name#</td>
		<cfelse>
			<cfscript>
			inputStruct.currentRow = inputStruct.currentRow+1;
			rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
			</cfscript>
				<tr #rollOverCode# onClick="window.location.href='#request.cgi_script_name#?action=listFunction&function_id=#function_id#';">
				<td class="tiny">#function_name#</td>
			</tr>
		</cfif>
	
	</cfloop>
	</table>
	
	
	
	
	
	
	
	</td>
	<td style="vertical-align:top;">
		
		
	<!--- list function --->	
		
		<table style="width:100%; border-spacing:0px;">
			<tr class="table-bright">
			<td class="medium">#function_name# <cfif function_deprecated EQ 1><span class="highlight">(Deprecated)</span></cfif></td>
			</tr>
			<cfif function_description NEQ ''>
			<tr class="table-white">
			<td>#function_description#</td>
			</tr>
			</cfif>
			<tr class="table-bright">
			<td>Prototype</td>
			</tr>
			<tr class="table-white">
			<td><cfset tempStruct = ""><span class="help-monospace">
			<cfloop query="qStruct">
			<cfif tempStruct NEQ function_param_name>
				<cfset tempStruct = function_param_name>
				<br />#function_param_name# = StructNew();
			</cfif>
			<br />#function_param_name#.#function_struct_key_name# = <span class="help-datatype">#cf_data_type_name#</span> #function_struct_key_default#; 
			<span class="help-comment"><cfif function_struct_key_required EQ 1>// Required</cfif><cfif function_struct_key_comment NEQ ""><cfif function_struct_key_required EQ 1>: <cfelse>// </cfif>#function_struct_key_comment#</cfif></span></cfloop></span>
			<cfif qStruct.recordcount NEQ 0><br /><br /></cfif>
			
			<span class="help-monospace"><span class="help-datatype">#cf_data_type_name#</span> #function_name#(<cfloop query="qParam"><cfif function_param_required EQ 0>[</cfif><cfif currentRow NEQ 1>,</cfif><span class="help-datatype">#cf_data_type_name#</span> #function_param_name#<cfif function_param_required EQ 0>]</cfif> </cfloop>);</span>
			</td>
			</tr>
			<tr class="table-bright">
			<td>Usage</td>
			</tr>
			<tr class="table-white">
			<td>
			
			<textarea name="usage" style="width:100%; height:130; "><cfset tempStruct = ""><cfloop query="qStruct"><cfif tempStruct NEQ function_param_name><cfset tempStruct = function_param_name>#function_param_name# = StructNew();#chr(10)#</cfif>#function_param_name#.#function_struct_key_name# = #function_struct_key_default#;<cfif function_struct_key_required EQ 1>// Required</cfif><cfif function_struct_key_comment NEQ ""><cfif function_struct_key_required EQ 1>: <cfelse>// </cfif>#function_struct_key_comment#</cfif>#chr(10)#</cfloop><cfif qStruct.recordcount NEQ 0>#chr(10)#</cfif>#function_name#(<cfloop query="qParam"><cfif currentRow NEQ 1>, </cfif>#function_param_name#</cfloop>);</textarea>
			</td>
			</tr>
			<tr class="table-white">
			<td>
			<table style="width:100%; border-spacing:0px;">
			<tr class="table-bright">
			<td>Parameter</td>
			<td>Type</td>
			<td>Required</td>
			<td>Default</td>
			<td>Description</td>
			</tr>
			<cfloop query="qParam">
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
			<td>#function_param_name#</td>
			<td>#cf_data_type_name#</td>
			<td><cfif function_param_required EQ 1>Yes<cfelse>No</cfif></td>
			<td>#function_param_default#</td>
			<td>#function_param_description#</td>
			</tr>
			</cfloop>
			</table>
			</td>
			</tr>
			<cfif function_returns NEQ ''>
			<tr class="table-bright">
			<td>Returns</td>
			</tr>
			</tr>
			<tr class="table-white">
			<td>#function_returns#</td>
			</tr>
			</cfif>
			<cfif function_example NEQ ''>
			<tr class="table-bright">
			<td>Examples</td>
			</tr>
			<tr class="table-white">
			<td><span class="help-monospace">#replace(function_example,chr(9),"&nbsp;&nbsp;&nbsp;","ALL")#</span></td>
			</tr>
			</cfif>
		</table>
		</td></tr><tr>
		<td>&nbsp;</td>
		<td class="tiny" colspan="3">
		Legend: <span class="help-comment">comment</span>, <span class="help-datatype">data type</span>, [ ] = optional parameter.
		
		
		</td>
	</tr>
	</table>
</cfif>

<cfif form.action EQ "listGroup">
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("function", request.zos.zcoreDatasource)# function 
	WHERE function_group_id = #db.param(application.zcore.functions.zso(form, 'function_group_id'))# and function_deprecated = #db.param('0')#
	ORDER BY function_name ASC
	</cfsavecontent><cfscript>qFunctions=db.execute("qFunctions");</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM function_group 
	WHERE function_group_id = #db.param(application.zcore.functions.zso(form, 'function_group_id'))#
	</cfsavecontent><cfscript>qGroup=db.execute("Groups");
	if(qGroup.recordcount EQ 0){		
		application.zcore.status.setStatus(Request.zsid, "Group no longer exists.",false,true);
		application.zcore.functions.zRedirect(request.cgi_script_name&"?Request.zsid=#Request.zsid#");
	}
	</cfscript>
	
	
	
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table(function_group, request.zos.zcoreDatasource)# 
	ORDER BY function_group_name ASC
	</cfsavecontent><cfscript>qGroups=db.execute("qGroups");</cfscript>
	
	
	
	<table style="width:100%; border-spacing:0px;">
	<td style="vertical-align:top; width:150px;">
	
	<!--- list group --->
	<table style="width:100%; border-spacing:0px;">
	
	<cfscript>
	// create input structure
	inputStruct = StructNew();
	// required
	inputStruct.currentRow = 0;
	inputStruct.style = "table-bright";
	inputStruct.style2 = "table-white";
	//inputStruct.styleOver = "table-white";
	inputStruct.output = false;
	inputStruct.name = "function_sidebar";
	
	inputStruct.currentRow = inputStruct.currentRow+1;
	rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
	</cfscript>
		<tr #rollOverCode# onClick="window.location.href='#request.cgi_script_name#?action=list';">
	<td class="tiny-bold">Groups ^^</td>
	</tr>
	
	<!--- list functions --->
	<cfloop query="qGroups">
		<cfif qGroup.function_group_id EQ function_group_id>
			<tr class="table-white"><td class="tiny">#function_group_name#</td>
		<cfelse>
			<cfscript>
			inputStruct.currentRow = inputStruct.currentRow+1;
			rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
			</cfscript>
				<tr #rollOverCode# onClick="window.location.href='#request.cgi_script_name#?action=listGroup&function_group_id=#function_group_id#';">
			<td class="tiny">#function_group_name#</td>
			</tr>
		</cfif>
	
	</cfloop>
	</table>
	
	
	
	
	
	
	
	</td>
	<td style="vertical-align:top;">
		
		
	<!--- list function --->		
		<table style="width:100%; border-spacing:0px;">
			<tr class="table-bright">
			<td colspan="2" class="medium">#qGroup.function_group_name# Functions</td>
			</tr>
			<cfif qGroup.function_group_description NEQ ''>
			<tr class="table-white">
			<td colspan="2">#qGroup.function_group_description#</td>
			</tr>
			</cfif>
			<tr class="table-bright">
			<td colspan="2">Functions</td>
			</tr>
	
	
	
	
	
	
	
	
	
	
	<cfif qFunctions.recordcount EQ 0>
	<tr class="table-bright"><td colspan="2">No function exist in this group.</td></tr>
	</cfif>
	<cfloop query="qFunctions">
		  <cfscript>
		// create input structure
		inputStruct = StructNew();
		// required
		inputStruct.currentRow = qFunctions.currentRow;
		inputStruct.style = "table-bright";
		inputStruct.style2 = "table-bright";
		inputStruct.styleOver = "table-white";
		inputStruct.output = false;
		inputStruct.name = "function_list"; // must follow variable naming conventions
		// run function
		rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
		</cfscript>
		<tr #rollOverCode#>
	<td><a href="#request.cgi_script_name#?action=listFunction&function_id=#function_id#">#function_name#</a></td>
	<td style="white-space:nowrap;">#function_short_description#</td>
	</tr>	
	</cfloop>
	</table>
	
	</td></tr></table>
</cfif>












<cfif form.action EQ "listDeprecated">
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table(function, request.zos.zcoreDatasource)# 
	WHERE function_deprecated = #db.param('1')#
	ORDER BY function_name ASC
	</cfsavecontent><cfscript>qFunctions=db.execute("qFunctions");</cfscript>
	
	
	
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table(function_group, request.zos.zcoreDatasource)# 
	ORDER BY function_group_name ASC
	</cfsavecontent><cfscript>qGroups=db.execute("qGroups");</cfscript>
	
	
	
	<table style="width:100%; border-spacing:0px;">
	<td style="vertical-align:top; width:150px;">
	
	<!--- list group --->
	<table style="width:100%; border-spacing:0px;">
	
	<cfscript>
	// create input structure
	inputStruct = StructNew();
	// required
	inputStruct.currentRow = 0;
	inputStruct.style = "table-bright";
	inputStruct.style2 = "table-white";
	//inputStruct.styleOver = "table-white";
	inputStruct.output = false;
	inputStruct.name = "function_sidebar";
	
	inputStruct.currentRow = inputStruct.currentRow+1;
	rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
	</cfscript>
		<tr #rollOverCode# onClick="window.location.href='#request.cgi_script_name#?action=list';">
	<td class="tiny-bold">Groups ^^</td>
	</tr>
	
	<!--- list functions --->
	<cfloop query="qGroups">
	<cfscript>
	inputStruct.currentRow = inputStruct.currentRow+1;
	rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
	</cfscript>
		<tr #rollOverCode# onClick="window.location.href='#request.cgi_script_name#?action=listGroup&function_group_id=#function_group_id#';">
	<td class="tiny">#function_group_name#</td>
	</tr>
	
	</cfloop>
	</table>
	
	
	
	
	
	
	
	</td>
	<td style="vertical-align:top;">
		
		
	<!--- list function --->
		
		<table style="width:100%; border-spacing:0px;">
			<tr class="table-bright">
			<td colspan="3" class="medium">Deprecated Functions</td>
			</tr>
			<tr class="table-white">
			<td colspan="3">The following functions have been replaced or should not be used when developing new scripts.  Check the related function groups for the newest functions.</td>
			</tr>
	
			<tr class="table-bright">
			<td colspan="3">Functions</td>
			</tr>
	
	
	
	
	
	
	
	
	
	
	<cfif qFunctions.recordcount EQ 0>
	<tr class="table-bright"><td colspan="3">No function exist in this group.</td></tr>
	</cfif>
	<cfloop query="qFunctions">
		  <cfscript>
		// create input structure
		inputStruct = StructNew();
		// required
		inputStruct.currentRow = qFunctions.currentRow;
		inputStruct.style = "table-bright";
		inputStruct.style2 = "table-bright";
		inputStruct.styleOver = "table-white";
		inputStruct.output = false;
		inputStruct.name = "function_list"; // must follow variable naming conventions
		// run function
		rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
		</cfscript>
		<tr #rollOverCode#>
	<td><a href="#request.cgi_script_name#?action=listFunction&function_id=#function_id#">#function_name#</a></td>
	<td style="white-space:nowrap;">#function_short_description#</td>
	<td style="white-space:nowrap;"><!--- <a href="#request.cgi_script_name#?action=editFunction&function_id=#function_id#">Edit</a> | <a href="#request.cgi_script_name#?action=deleteFunction&function_id=#function_id#">Delete</a> --->&nbsp;</td>
	</tr>	
	</cfloop>
	</table>
	
	</td></tr></table>
</cfif>


















<cfif form.action EQ "list">
	<cfsavecontent variable="db.sql">
	SELECT * FROM function_group 
	ORDER BY function_group_name ASC
	</cfsavecontent><cfscript>qGroup=db.execute("qGroup");
	application.zcore.functions.zStatusHandler(Request.zsid);
	</cfscript>
	
	
	
	
	
	<table style="width:100%; border-spacing:0px;">
	<td style="vertical-align:top; width:150px;">
	
	<!--- list group --->
	<table style="width:100%; border-spacing:0px;">
	<tr class="table-bright">
	<td class="tiny-bold">Groups</td>
	</tr>
	</table>
	
	
	
	
	
	
	
	</td>
	<td style="vertical-align:top;">
		
		
	<!--- list function --->
		
		<table style="width:100%; border-spacing:0px;">	
			<tr class="table-bright">
			<td colspan="3" class="medium">Groups</td>
			</tr>
	
		<cfif qGroup.recordcount EQ 0>
		<tr class="table-bright"><td colspan="3">No function groups exist.</td></tr>
		</cfif>
		<cfloop query="qGroup">
              <cfscript>
			// create input structure
			inputStruct = StructNew();
			// required
			inputStruct.currentRow = qGroup.currentRow;
			inputStruct.style = "table-bright";
			inputStruct.style2 = "table-white";
			//inputStruct.styleOver = "table-error";
			inputStruct.output = false;
			inputStruct.name = "function_list"; // must follow variable naming conventions
			// run function
			rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
			</cfscript>
		<tr #rollOverCode#>
		<td style="white-space:nowrap;"><a href="#request.cgi_script_name#?action=listGroup&function_group_id=#function_group_id#">#function_group_name#</a></td>
		<td style="white-space:nowrap;">#function_group_short_description#</td>
		<td style="white-space:nowrap;"><!--- <a href="#request.cgi_script_name#?action=edit&function_group_id=#function_group_id#">Edit</a> | <a href="#request.cgi_script_name#?action=delete&function_group_id=#function_group_id#">Delete</a> ---></td>
		</tr>	
		</cfloop>
		</table>
	</td>
	</tr>
	</table>
</cfif>
</cffunction>
</cfoutput>
</cfcomponent>