<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>
	if(structkeyexists(form, 'return') and structkeyexists(form, 'tooltip_id')){
		StructInsert(session, "tooltip_return"&form.tooltip_id, request.zos.cgi.http_referer, true);		
	}
	application.zcore.functions.zstatushandler(request.zsid);
	</cfscript>
	<table style="border-spacing:0px; width:100%;" class="small" >
		<tr class="table-white">
			<td><span class="large">Tooltips</span></td>
		</tr>
		<tr>
			<td class="table-list"><span class="small"><a href="/z/server-manager/admin/tooltip/index">Manage Tooltip Sections</a> | 
			<a href="/z/server-manager/admin/tooltip/addSection">Add Tooltip Section</a></span></td>
		</tr>
	</table>
</cffunction>

<cffunction name="list" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qPropS=0;
	var qProp=0;
	variables.init();
	db.sql="SELECT *  FROM #db.table("tooltip_section", request.zos.zcoreDatasource)# tooltip_section 
	WHERE tooltip_section.tooltip_section_id=#db.param(form.tooltip_section_id)# ";
	qPropS=db.execute("qPropS");
	if(qPropS.recordcount EQ 0){
		application.zcore.functions.z301redirect("/z/server-manager/admin/tooltip/index");	
	}
	db.sql="SELECT *  FROM #db.table("tooltip", request.zos.zcoreDatasource)# tooltip, 
	#db.table("tooltip_section", request.zos.zcoreDatasource)# tooltip_section 
	where tooltip_section.tooltip_section_id = tooltip.tooltip_section_id and 
	tooltip_section.tooltip_section_id=#db.param(form.tooltip_section_id)#
	 order by tooltip.tooltip_name ASC";
	qProp=db.execute("qProp");
	</cfscript>
	<h2>Manage Tooltip Section: #qPropS.tooltip_section_name#</h2>
	<p><a href="/z/server-manager/admin/tooltip/add?tooltip_section_id=#form.tooltip_section_id#">Add Tooltip</a></p>
	<table style="border-spacing:0px;" class="table-list" >
		<tr>
			<th>Label</th>
			<th>Code Name</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qProp">
			<tr style="<cfif qProp.currentrow MOD 2 EQ 0>background-color:##EFEFEF;<cfelse>background-color:##E2E2E2;</cfif>">
				<td>#qProp.tooltip_label#</td>
				<td>#qProp.tooltip_name#</td>
				<td>
					<a href="/z/server-manager/admin/tooltip/edit?tooltip_id=#qProp.tooltip_id#&amp;tooltip_section_id=#qProp.tooltip_section_id#&amp;return=1">Edit</a> | <a href="/z/server-manager/admin/tooltip/delete?tooltip_id=#qProp.tooltip_id#&tooltip_section_id=#qProp.tooltip_section_id#&amp;return=1">Delete</a></td>
			</tr>
		</cfloop>
	</table>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var result=0;
	var tempLink=0;
	variables.init();
	form.tooltip_id=application.zcore.functions.zso(form, 'tooltip_id');
	db.sql="SELECT * FROM #db.table("tooltip", request.zos.zcoreDatasource)# tooltip 
	WHERE tooltip_id = #db.param(form.tooltip_id)# ";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Tooltip is missing");
		application.zcore.functions.zRedirect("/z/server-manager/admin/tooltip/index?zsid="&request.zsid);
	}
 	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
        	db.sql="DELETE FROM #db.table("tooltip", request.zos.zcoreDatasource)#  
		WHERE  tooltip_id=#db.param(form.tooltip_id)# ";
		result = db.execute("result"); 
		//	queueSortCom.sortAll();
        	application.zcore.status.setStatus(request.zsid, "Tooltip deleted successfully.");
		if(structkeyexists(session, "tooltip_return"&form.tooltip_id)){
			tempLink=session["tooltip_return"&form.tooltip_id];
			structdelete(session,"tooltip_return"&form.tooltip_id);
			application.zcore.functions.z301Redirect(tempLink);
		}else{
			application.zcore.functions.zRedirect("/z/server-manager/admin/tooltip/list?tooltip_section_id=#form.tooltip_section_id#&zsid="&request.zsid);
		}
        	</cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this tooltip?<br />
			<br />
			Tooltip: #qcheck.tooltip_name#<br />
			<br />
			<a href="/z/server-manager/admin/tooltip/delete?tooltip_section_id=#form.tooltip_section_id#&amp;confirm=1&amp;tooltip_id=#form.tooltip_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/server-manager/admin/tooltip/list?tooltip_section_id=#form.tooltip_section_id#">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var uniqueChanged=false;
	var myForm=structnew();
	var tempurl=0;
	var redirecturl=0;
	var tempLink=0;
	var errors=0;
	var ts=0;
	
	variables.init();
	if(form.method EQ 'insert' and application.zcore.functions.zso(form,'tooltip_url') NEQ ""){
		uniqueChanged=true;
	}
	myForm.tooltip_name.required=true;
	myForm.tooltip_name.required=true;
	myForm.tooltip_name.friendlyName="Name";
	errors=application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	 
	if(errors){
		if(form.method EQ 'insert'){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/tooltip/add?tooltip_section_id=#form.tooltip_section_id#&zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/tooltip/edit?tooltip_section_id=#form.tooltip_section_id#&tooltip_id=#form.tooltip_id#&zsid=#request.zsid#");
		}
	} 
	form.tooltip_name=replace(replace(form.tooltip_name," ","_","all"),chr(9),"_","all");
	form.site_id=request.zos.globals.id;
	 
	ts=StructNew();
	ts.struct=form;
	ts.table="tooltip";
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ "insert"){
		form.tooltip_id = application.zcore.functions.zInsert(ts);
		if(form.tooltip_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Tooltip couldn't be added at this time.",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/tooltip/add?tooltip_section_id=#form.tooltip_section_id#&zsid="&request.zsid);
		}else{ 
			application.zcore.status.setStatus(request.zsid, "Tooltip added successfully.");
			redirecturl=("/z/server-manager/admin/tooltip/list?tooltip_section_id=#form.tooltip_section_id#&zsid="&request.zsid);
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Tooltip failed to update.",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/tooltip/edit?tooltip_section_id=#form.tooltip_section_id#&tooltip_id=#form.tooltip_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Tooltip updated successfully.");
			redirecturl=("/z/server-manager/admin/tooltip/list?tooltip_section_id=#form.tooltip_section_id#&zsid="&request.zsid);
		}
	}
	application.zcore.functions.zPublishHelp();
	
	if(structkeyexists(session, "tooltip_return"&form.tooltip_id)){
		tempLink=session["tooltip_return"&form.tooltip_id];
		if(tempLink NEQ ""){
			structdelete(session,"tooltip_return"&form.tooltip_id);
			application.zcore.functions.z301Redirect(tempLink);
		}else{
			application.zcore.functions.zRedirect(redirecturl);
		}
	}else{
		application.zcore.functions.zRedirect(redirecturl);
	}
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var htmlEditor=0;
	var currentMethod=form.method;
	var qPropS=0;
	var qRate=0;
	variables.init();
	form.tooltip_id=application.zcore.functions.zso(form, 'tooltip_id',true);
	db.sql="SELECT *  FROM #db.table("tooltip_section", request.zos.zcoreDatasource)# tooltip_section 
	WHERE tooltip_section_id=#db.param(form.tooltip_section_id)# ";
	qPropS=db.execute("qPropS");

	if(qPropS.recordcount EQ 0){
		application.zcore.functions.z301redirect("/z/server-manager/admin/tooltip/index");	
	}
	</cfscript>
	<h2>
		<cfif currentMethod EQ "edit">
			Edit
		<cfelse>
			Add
		</cfif>
		Tooltip to Section: #qPropS.tooltip_section_name#</h2>
	<cfscript>
	db.sql="SELECT * FROM #db.table("tooltip", request.zos.zcoreDatasource)# tooltip 
	WHERE tooltip_id = #db.param(form.tooltip_id)# ";
	qRate=db.execute("qRate");

	application.zcore.functions.zQueryToStruct(qRate,form,'tooltip_id,tooltip_section_id'); 
	application.zcore.functions.zStatusHandler(request.zsid, true,true);
	</cfscript>
	<form name="myForm" id="myForm" action="/z/server-manager/admin/tooltip/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?tooltip_id=#form.tooltip_id#&amp;tooltip_section_id=#form.tooltip_section_id#" method="post">
		<table style="border-spacing:0px;" class="table-list">
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Name</th>
				<td class="table-white"><input name="tooltip_name" size="50" type="text" value="#htmleditformat(form.tooltip_name)#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Label</th>
				<td class="table-white"><textarea name="tooltip_label" cols="50" rows="4">#htmleditformat(form.tooltip_label)#</textarea></td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Tooltip HTML</th>
				<td class="table-white"><cfscript>
					
								htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
								htmlEditor.instanceName	= "tooltip_html";
								htmlEditor.value			= form.tooltip_html;
								htmlEditor.basePath		= '/';
								htmlEditor.width			= "100%";
								htmlEditor.height		= 300;
								htmlEditor.create();
								</cfscript></td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">&nbsp;</th>
				<td class="table-white"><button type="submit" class="table-shadow" value="submitForm">Save</button>
					<button type="button" class="table-shadow" name="cancel" value="Cancel" onclick="document.location = '/z/server-manager/admin/tooltip/index';">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qProp=0;
	variables.init();
	db.sql="SELECT *, count(tooltip.tooltip_id) childCount  
	FROM #db.table("tooltip_section", request.zos.zcoreDatasource)# tooltip_section 
	LEFT JOIN #db.table("tooltip", request.zos.zcoreDatasource)# tooltip ON 
	tooltip_section.tooltip_section_id = tooltip.tooltip_section_id 
	GROUP BY tooltip_section.tooltip_section_id  
	order by tooltip_section_name ASC ";
	qProp=db.execute("qProp");
	</cfscript>
	<table style="border-spacing:0px;" class="table-list" >
		<tr>
			<th>Tooltip Section Name</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qProp">
		<tr style="<cfif qProp.currentrow MOD 2 EQ 0>background-color:##EFEFEF;<cfelse>background-color:##E2E2E2;</cfif>">
			<td>#qProp.tooltip_section_name#</td>
			<td><a href="/z/server-manager/admin/tooltip/list?tooltip_section_id=#qProp.tooltip_section_id#&amp;return=1">Manage</a> | <a href="/z/server-manager/admin/tooltip/editSection?tooltip_section_id=#qProp.tooltip_section_id#&amp;return=1">Edit</a>
				<cfif qProp.childCount NEQ 0>
					| Delete Disabled
				<cfelse>
					| <a href="/z/server-manager/admin/tooltip/deleteSection?tooltip_section_id=#qProp.tooltip_section_id#&amp;return=1">Delete</a>
				</cfif></td>
		</tr>
		</cfloop>
	</table>
</cffunction>

<cffunction name="deleteSection" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var result=0;
	var tempLink=0;
	variables.init();
	form.tooltip_section_id=application.zcore.functions.zso(form, 'tooltip_section_id');
	db.sql="SELECT * FROM #db.table("tooltip", request.zos.zcoreDatasource)# tooltip 
	WHERE tooltip_section_id = #db.param(form.tooltip_section_id)# ";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount NEQ 0){
		application.zcore.status.setStatus(request.zsid, "Tooltip section must be empty before deleting it.");
		application.zcore.functions.zRedirect("/z/server-manager/admin/tooltip/listSection?zsid="&request.zsid);
	}
	db.sql="SELECT * FROM #db.table("tooltip_section", request.zos.zcoreDatasource)# tooltip_section 
	WHERE tooltip_section_id = #db.param(form.tooltip_section_id)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Tooltip section is missing");
		application.zcore.functions.zRedirect("/z/server-manager/admin/tooltip/index?zsid="&request.zsid);
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		db.sql="DELETE FROM #db.table("tooltip_section", request.zos.zcoreDatasource)#  
		WHERE  tooltip_section_id=#db.param(form.tooltip_section_id)#  ";
		result = db.execute("result"); 
		//	queueSortCom.sortAll();
		application.zcore.status.setStatus(request.zsid, "Tooltip section deleted successfully.");
		if(structkeyexists(session, "tooltip_return"&form.tooltip_section_id)){
			tempLink=session["tooltip_return"&form.tooltip_section_id];
			structdelete(session,"tooltip_return"&form.tooltip_section_id);
			application.zcore.functions.z301Redirect(tempLink);
		}else{
			application.zcore.functions.zRedirect("/z/server-manager/admin/tooltip/index?zsid="&request.zsid);
		}
		</cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this tooltip section?<br />
			<br />
			Tooltip: #qcheck.tooltip_section_name#<br />
			<br />
			<a href="/z/server-manager/admin/tooltip/deleteSection?confirm=1&amp;tooltip_section_id=#form.tooltip_section_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/server-manager/admin/tooltip/index">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="insertSection" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.updateSection();
	</cfscript>
</cffunction>

<cffunction name="updateSection" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var tempLink=0;
	var ts=0;
	var errors=0;
	var redirecturl=0;
	var myForm=structnew();
	variables.init();
	myForm.tooltip_section_name.required=true;
	myForm.tooltip_section_name.required=true;
	myForm.tooltip_section_name.friendlyName="Name";
	form.tooltip_section_name=replace(replace(form.tooltip_section_name," ","_","all"),chr(9),"_","all");
	errors=application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	 
	if(errors){
		if(form.method EQ 'insert'){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/tooltip/addSection?zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/tooltip/editSection?tooltip_section_id=#tooltip_section_id#&zsid=#request.zsid#");
		}
	} 
	 
	 
	ts=StructNew();
	ts.table="tooltip_section";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ "insertSection"){
		form.tooltip_section_id = application.zcore.functions.zInsert(ts);
		if(form.tooltip_section_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Tooltip section couldn't be added at this time.",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/tooltip/addSection?zsid="&request.zsid);
		}else{ 
			application.zcore.status.setStatus(request.zsid, "Tooltip section added successfully.");
			redirecturl=("/z/server-manager/admin/tooltip/index?zsid="&request.zsid);
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Tooltip section failed to update.",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/tooltip/editSection?tooltip_section_id=#form.tooltip_section_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Tooltip section updated successfully.");
			redirecturl=("/z/server-manager/admin/tooltip/index?zsid="&request.zsid);
		}
	}
	
	if(structkeyexists(session, "tooltip_return"&form.tooltip_section_id)){
		tempLink=session["tooltip_return"&form.tooltip_section_id];
		structdelete(session,"tooltip_return"&form.tooltip_section_id);
		application.zcore.functions.z301Redirect(tempLink);
	}else{
		application.zcore.functions.zRedirect(redirecturl);
	}
	</cfscript>
</cffunction>

<cffunction name="addSection" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.editSection();
	</cfscript>
</cffunction>

<cffunction name="editSection" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qRate=0;
	var currentMethod=form.method;
	variables.init();
	form.tooltip_section_id=application.zcore.functions.zso(form,'tooltip_section_id',true);
	db.sql="SELECT * FROM #db.table("tooltip_section", request.zos.zcoreDatasource)# tooltip_section 
	WHERE tooltip_section_id = #db.param(form.tooltip_section_id)# ";
	qRate=db.execute("qRate");
	application.zcore.functions.zQueryToStruct(qRate,form,'tooltip_section_id'); 
	application.zcore.functions.zStatusHandler(request.zsid, true,true);
	</cfscript>
	<h2>
		<cfif currentMethod EQ "editSection">
			Edit
		<cfelse>
			Add
		</cfif>
		Tooltip</h2>
	<form name="myForm" id="myForm" action="/z/server-manager/admin/tooltip/<cfif currentMethod EQ "editSection">updateSection<cfelse>insertSection</cfif>?tooltip_section_id=#form.tooltip_section_id#" method="post">
		<cfif currentMethod EQ "editSection">
			<p>WARNING: DON'T USE THIS FORM UNLESS YOUR KNOW WHAT YOU ARE DOING</p>
		</cfif>
		<table style="border-spacing:0px;" class="table-list">
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Name</th>
				<td class="table-white"><input name="tooltip_section_name" size="50" type="text" value="#htmleditformat(form.tooltip_section_name)#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">&nbsp;</th>
				<td class="table-white"><button type="submit" class="table-shadow" value="submitForm">Save</button>
					<button type="button" class="table-shadow" name="cancel" value="Cancel" onclick="document.location = '/z/server-manager/admin/tooltip/index';">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>
</cfoutput>
</cfcomponent>
