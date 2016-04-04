<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Templates");
	var hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	hCom.displayHeader();
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qTypes=0;
	var qImages=0;
	variables.init();
	form.sid=application.zcore.functions.zGetSiteIdFromSiteIdType(form.siteIdType);
	db.sql="SELECT * from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# inquiries_lead_template 
	WHERE inquiries_lead_template.inquiries_lead_template_id = #db.param(form.inquiries_lead_template_id)# and 
	site_id =#db.param(form.sid)#";
	if(application.zcore.user.checkServerAccess() EQ false){
		db.sql&=" and site_id=#db.param(request.zos.globals.id)#";
	}
	qTypes=db.execute("qTypes");
	if(qTypes.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, 'Template doesn''t exist.',false,true);
		application.zcore.functions.zRedirect('/z/inquiries/admin/lead-template/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		db.sql="DELETE from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# 
		WHERE inquiries_lead_template_id = #db.param(form.inquiries_lead_template_id)# and 
		site_id =#db.param(form.sid)# ";
		qImages=db.execute("qImages");
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Template deleted.");
		application.zcore.functions.zRedirect("/z/inquiries/admin/lead-template/index?zsid="&request.zsid);
		</cfscript>
	<cfelse>
		<div style="text-align:center;">
			<h2>Are you sure you want to delete this template?<br />
				<br />
				#qTypes.inquiries_lead_template_name#<br />
				<br />
				<a href="/z/inquiries/admin/lead-template/delete?confirm=1&amp;inquiries_lead_template_id=#form.inquiries_lead_template_id#&amp;siteIDType=#form.siteIdType#">Yes</a>&nbsp;&nbsp;&nbsp;
				<a href="/z/inquiries/admin/lead-template/index">No</a></h2>
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var myForm={};
	var result=0;
	var qCheck=0;
	var inputStruct=0;
	variables.init();
	form.site_id=application.zcore.functions.zGetSiteIdFromSiteIdType(form.siteIdType);
	if(form.method EQ 'update'){
		db.sql="SELECT * from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# inquiries_lead_template 
		WHERE inquiries_lead_template_id = #db.param(application.zcore.functions.zso(form,'inquiries_lead_template_id'))# and 
		site_id =#db.param(form.site_id)#";
		if(application.zcore.user.checkServerAccess() EQ false){
			db.sql&=" and site_id=#db.param(request.zos.globals.id)#";
		}
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount NEQ 0){
			form.site_id=qcheck.site_id;	
		}
	}
	if(application.zcore.user.checkServerAccess(request.zos.globals.id)){
		if(application.zcore.functions.zso(form,'force_global') EQ 1){
			form.site_id=0;	
		}else if(application.zcore.functions.zso(form,'force_global') EQ 0){
			form.site_id=request.zos.globals.id;	
		}
	}
	myForm.inquiries_lead_template_type.required = true;
	myForm.inquiries_lead_template_type.friendlyName = "Type";
	myForm.inquiries_lead_template_name.required = true;
	myForm.inquiries_lead_template_name.friendlyName = "Template Name";
	result = application.zcore.functions.zValidateStruct(form, myForm, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect("/z/inquiries/admin/lead-template/add?zsid=#Request.zsid#");
		}else{
			application.zcore.functions.zRedirect("/z/inquiries/admin/lead-template/edit?zsid=#Request.zsid#&inquiries_lead_template_id=#form.inquiries_lead_template_id#");
		}
	}
	
	inputStruct = StructNew();
	inputStruct.table = "inquiries_lead_template";
	inputStruct.datasource=request.zos.zcoreDatasource;
	inputStruct.struct=form;
	if(form.method EQ 'insert'){
		form.inquiries_id = application.zcore.functions.zInsert(inputStruct); 
		if(form.inquiries_id EQ false){
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Template name must be unique.", false,true);
			application.zcore.functions.zRedirect("/z/inquiries/admin/lead-template/add?zsid="&request.zsid);
		}else{
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Template Added.");
		}
	}else{
		if(application.zcore.functions.zUpdate(inputStruct) EQ false){
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Template name must be unique.", false,true);
			application.zcore.functions.zRedirect("/z/inquiries/admin/lead-template/edit?zsid=#Request.zsid#&inquiries_lead_template_id=#form.inquiries_lead_template_id#");
		}else{
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Template updated.");
		}
	}
	application.zcore.functions.zRedirect('/z/inquiries/admin/lead-template/index?zsid='&request.zsid);
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qTypes=0;
	var currentMethod=form.method;
	variables.init();
	application.zcore.functions.zSetPageHelpId("4.6");
	form.sid=application.zcore.functions.zGetSiteIdFromSiteIdType(application.zcore.functions.zso(form, 'siteIdType',false,1));
	</cfscript>
	<cfsavecontent variable="db.sql"> SELECT * from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# inquiries_lead_template 
	WHERE inquiries_lead_template_id = #db.param(application.zcore.functions.zso(form, 'inquiries_lead_template_id'))# and 
	site_id =#db.param(form.sid)#
	<cfif application.zcore.user.checkServerAccess() EQ false>
		and site_id=#db.param(request.zos.globals.id)#
	</cfif>
	</cfsavecontent>
	<cfscript>
	qTypes=db.execute("qTypes");
	if(qTypes.recordcount EQ 0 and currentMethod EQ 'edit'){
		application.zcore.status.setStatus(request.zsid, 'Lead template doesn''t exist or you don''t have permission to edit it.',false,true);
		application.zcore.functions.zRedirect('/z/inquiries/admin/lead-template/index?zsid=#request.zsid#');
	}
	application.zcore.functions.zQueryToStruct(qTypes, form);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	if(form.inquiries_lead_template_type EQ ''){
		form.inquiries_lead_template_type=application.zcore.functions.zso(form, 'inquiries_lead_template_type');
	}
	</cfscript>
	<h2>
		<cfif currentMethod EQ 'add'>
			Add
		<cfelse>
			Edit
		</cfif>
		Template</h2>
	Please enter a unique template name.  You can insert &quot;{agent name}&quot; or &quot;{agent's company}&quot; without the quotes to have the system automatically insert those variables into the text based on the agent that is logged in. All templates are shared between all agents.<br />
	<br />
	<table style="width:600px; border-spacing:0px;" class="table-list">
		<form action="/z/inquiries/admin/lead-template/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?inquiries_lead_template_id=#form.inquiries_lead_template_id#&amp;siteIdType=#form.siteIdType#" method="post">
			<tr>
				<th>Type:</th>
				<td><input type="radio" name="inquiries_lead_template_type" value="1" <cfif application.zcore.functions.zso(form, 'inquiries_lead_template_type',true) EQ 1 or application.zcore.functions.zso(form, 'inquiries_lead_template_type',true) EQ 0>checked="checked"</cfif> style="border:none; background:none;" />
					Note
					<input type="radio" name="inquiries_lead_template_type" value="2" <cfif application.zcore.functions.zso(form, 'inquiries_lead_template_type',true) EQ 2>checked="checked"</cfif> style="border:none; background:none;" />
					Email </td>
			</tr>
			<tr>
				<th>Template Name:</th>
				<td><input type="text" name="inquiries_lead_template_name" value="#form.inquiries_lead_template_name#" /></td>
			</tr>
			<tr>
				<th>Subject:</th>
				<td><input name="inquiries_lead_template_subject" id="inquiries_lead_template_subject" type="text" size="50" maxlength="50" value="#form.inquiries_lead_template_subject#" /></td>
			</tr>
			<tr>
				<th>Message:</th>
				<td><textarea name="inquiries_lead_template_message" id="inquiries_lead_template_message" style="width:100%; height:250px; ">#form.inquiries_lead_template_message#</textarea></td>
			</tr>
			<cfif application.zcore.user.checkServerAccess(request.zos.globals.id)>
				<tr>
					<th>Real Estate:</th>
					<td><input type="radio" name="inquiries_lead_template_realestate" value="1" <cfif form.inquiries_lead_template_realestate EQ 1>checked="checked"</cfif> style="border:none; background:none;" />
						Yes
						<input type="radio" name="inquiries_lead_template_realestate" value="0" <cfif application.zcore.functions.zso(form, 'inquiries_lead_template_realestate',true) EQ 0>checked="checked"</cfif> style="border:none; background:none;" />
						No (This will hide it on web sites without request.zos.listing defined.) </td>
				</tr>
				<tr>
					<th>Global:</th>
					<td><input type="radio" name="force_global" value="1" <cfif form.site_id EQ 0 or application.zcore.functions.zso(form, 'force_global',true) EQ 1>checked="checked"</cfif> style="border:none; background:none;" />
						Yes
						<input type="radio" name="force_global" value="0" <cfif form.site_id NEQ 0 and application.zcore.functions.zso(form, 'force_global',true) EQ 0>checked="checked"</cfif> style="border:none; background:none;" />
						No (Only server administrator can set this.) </td>
				</tr>
			</cfif>
			<tr>
				<th>&nbsp;</th>
				<td><button type="submit" name="submitForm">
					<cfif currentMethod EQ 'add'>
						Add
					<cfelse>
						Update
					</cfif>
					Template</button>
					<button type="button" name="cancel" onclick="window.location.href = '/z/inquiries/admin/lead-template/index';">Cancel</button></td>
			</tr>
		</form>
	</table>
</cffunction>

<cffunction name="hide" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.show();
	</cfscript>
</cffunction>

<cffunction name="show" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var r=0;
	init();
	form.sid=application.zcore.functions.zGetSiteIdFromSiteIdType(form.siteIdType);
	if(form.method EQ 'hide'){
		db.sql="REPLACE INTO #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)#  
		SET inquiries_lead_template_id=#db.param(form.inquiries_lead_template_id)#, 
		inquiries_lead_template_x_site_deleted = #db.param(0)#,
		inquiries_lead_template_x_site_updated_datetime=#db.param(request.zos.mysqlnow)#,
		site_id = #db.param(form.sid)# ";
		r=db.execute("r");
		application.zcore.status.setStatus(request.zsid,"Lead template is now hidden");
	}else{
		db.sql="DELETE from #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)#  
		WHERE inquiries_lead_template_id=#db.param(form.inquiries_lead_template_id)# and 
		site_id = #db.param(form.sid)# ";
		r=db.execute("r");
		application.zcore.status.setStatus(request.zsid,"Lead template is now visible");
	}
	application.zcore.functions.zRedirect("/z/inquiries/admin/lead-template/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qTypes=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("4.5");
	</cfscript>
	<cfsavecontent variable="db.sql"> 
	SELECT *, if(inquiries_lead_template_x_site.site_id IS NULL,#db.param(0)#,#db.param(1)#) hideTemplate 
	from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# inquiries_lead_template
	LEFT JOIN #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)# inquiries_lead_template_x_site ON 
	inquiries_lead_template_x_site.inquiries_lead_template_id = inquiries_lead_template.inquiries_lead_template_id and 
	inquiries_lead_template_x_site.site_id = #db.param(request.zos.globals.id)# and 
	inquiries_lead_template_x_site_deleted = #db.param(0)#
	WHERE inquiries_lead_template.site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
	inquiries_lead_template_deleted = #db.param(0)# 
	<cfif application.zcore.app.siteHasApp("listing") EQ false>
		and inquiries_lead_template_realestate = #db.param(0)#
	</cfif>
	ORDER BY inquiries_lead_template_name ASC </cfsavecontent>
	<cfscript>
	qTypes=db.execute("qTypes");
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2 style="display:inline; ">Lead Templates | </h2>
	<a href="/z/inquiries/admin/lead-template/add?siteIDType=1">Add Template</a> | 
	<a href="/z/inquiries/admin/manage-inquiries/index">Back to Leads</a> <br />
	<br />
	All templates are shared between all agents.<br />
	<br />
	<table style="border-spacing:0px;" class="table-list">
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qTypes">
			<cfscript>
			form.siteIdType=application.zcore.functions.zGetSiteIDType(qTypes.site_id);
			</cfscript>
			<tr <cfif qTypes.currentRow mod 2 EQ 0>style="background-color:##EEEEEE;"</cfif>>
				<td>#qTypes.inquiries_lead_template_name#</td>
				<td><cfif qTypes.inquiries_lead_template_type EQ 1>
						Note
					<cfelse>
						Email
					</cfif></td>
				<td><cfif qTypes.hideTemplate EQ 0>
						<a href="/z/inquiries/admin/lead-template/hide?inquiries_lead_template_id=#qTypes.inquiries_lead_template_id#&amp;siteIDType=#form.siteIdType#">Hide</a> |
					<cfelse>
						<a href="/z/inquiries/admin/lead-template/show?inquiries_lead_template_id=#qTypes.inquiries_lead_template_id#&amp;siteIDType=#form.siteIdType#">Show</a> |
					</cfif>
					<cfif qTypes.site_id NEQ 0 or application.zcore.user.checkServerAccess(request.zos.globals.id)>
						<a href="/z/inquiries/admin/lead-template/edit?inquiries_lead_template_id=#qTypes.inquiries_lead_template_id#&amp;siteIDType=#form.siteIdType#">Edit</a> | 
						<a href="/z/inquiries/admin/lead-template/delete?inquiries_lead_template_id=#qTypes.inquiries_lead_template_id#&amp;siteIDType=#form.siteIdType#">Delete</a>
					<cfelse>
						Locked
					</cfif></td>
			</tr>
		</cfloop>
	</table>
</cffunction>
</cfoutput>
</cfcomponent>
