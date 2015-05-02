<cfcomponent>
<cfoutput>


<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Manage Event Categories", true);	
	db.sql="SELECT * FROM #db.table("event_category", request.zos.zcoreDatasource)# event_category
	WHERE event_category_id= #db.param(application.zcore.functions.zso(form,'event_category_id'))# and 
	event_category_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Event category no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/event/admin/manage-event-category/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript> 
		application.zcore.functions.zDeleteUniqueRewriteRule(qCheck.event_category_unique_url);

		db.sql="DELETE FROM #db.table("event_category", request.zos.zcoreDatasource)#  
		WHERE event_category_id= #db.param(application.zcore.functions.zso(form, 'event_category_id'))# and 
		event_category_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");

		db.sql="DELETE FROM #db.table("event_x_category", request.zos.zcoreDatasource)#  
		WHERE event_category_id= #db.param(application.zcore.functions.zso(form, 'event_category_id'))# and 
		event_x_category_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");

		application.zcore.status.setStatus(Request.zsid, 'Event category deleted');
		application.zcore.functions.zRedirect('/z/event/admin/manage-event-category/index?zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this event category?<br />
			<br />
			#qCheck.event_category_name#<br />
			<br />
			<a href="/z/event/admin/manage-event-category/delete?confirm=1&amp;event_category_id=#form.event_category_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/event/admin/manage-event-category/index">No</a> 
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var ts={};
	db=request.zos.queryObject;
	var result=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Manage Event Categories", true);	
	form.site_id = request.zos.globals.id;
	ts.event_category_name.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/event/admin/manage-event-category/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/event/admin/manage-event-category/edit?event_category_id=#form.event_category_id#&zsid=#request.zsid#');
		}
	}


	uniqueChanged=false;
	oldURL='';
	if(form.method EQ 'insert' and application.zcore.functions.zso(form, 'event_category_unique_url') NEQ ""){
		uniqueChanged=true;
	}
	if(form.method EQ 'update'){
		db.sql="SELECT * FROM #db.table("event_category", request.zos.zcoreDatasource)# 
		WHERE event_category_id = #db.param(form.event_category_id)# and 
		event_category_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this event category.',form,true);
			application.zcore.functions.zRedirect('/z/event/admin/manage-event-category/index?zsid=#request.zsid#');
		}
		oldURL=qCheck.event_category_unique_url;
		if(structkeyexists(form, 'event_category_unique_url') and qcheck.event_category_unique_url NEQ form.event_category_unique_url){
			uniqueChanged=true;	
		}
	}

	ts=StructNew();
	ts.table='event_category';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.event_category_id = application.zcore.functions.zInsert(ts);
		if(form.event_category_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save event category.',form,true);
			application.zcore.functions.zRedirect('/z/event/admin/manage-event-category/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Event category saved.');
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save event category.',form,true);
			application.zcore.functions.zRedirect('/z/event/admin/manage-event-category/edit?event_category_id=#form.event_category_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Event category updated.');
		}
		
	} 
	if(uniqueChanged){
		application.zcore.app.getAppCFC("event").updateRewriteRuleCategory(form.event_category_id, oldURL);	
	}
	application.zcore.app.getAppCFC("event").searchReindexCategory(form.event_category_id, false);

	application.zcore.functions.zRedirect('/z/event/admin/manage-event-category/index?zsid=#request.zsid#');
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript> 
	var db=request.zos.queryObject; 
	var currentMethod=form.method;
	var htmlEditor=0;
	application.zcore.functions.zSetPageHelpId("10.6");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Manage Event Categories");	
	if(application.zcore.functions.zso(form,'event_category_id') EQ ''){
		form.event_category_id = -1;
	}
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}
	db.sql="SELECT * FROM #db.table("event_category", request.zos.zcoreDatasource)# event_category 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	event_category_deleted = #db.param(0)# and 
	event_category_id=#db.param(form.event_category_id)#";
	qEvent=db.execute("qEvent");
	application.zcore.functions.zQueryToStruct(qEvent);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	<h2>
		<cfif currentMethod EQ "add">
			Add
			<cfscript>
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
			</cfscript>
		<cfelse>
			Edit
		</cfif> Event Category</h2>
	<form action="/z/event/admin/manage-event-category/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?event_category_id=#form.event_category_id#" method="post">
		<table style="width:100%;" class="table-list">
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button></td>
			</tr>
			<tr>
				<th>Name</th>
				<td><input type="text" name="event_category_name" value="#htmleditformat(form.event_category_name)#" /></td>
			</tr> 
			<tr>
				<th>Description</th>
				<td>
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "event_category_description";
					htmlEditor.value			= form.event_category_description;
					htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
					htmlEditor.height		= 350;
					htmlEditor.create();
					</cfscript>   
				</td>
			</tr> 
			<tr>
				<th>Unique URL</th>
				<td><input type="text" name="event_category_unique_url" value="#htmleditformat(form.event_category_unique_url)#" /></td>
			</tr> 
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Manage Event Categories");	
	application.zcore.functions.zSetPageHelpId("10.5");
	db.sql="select * from #db.table("event_category", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	event_category_deleted=#db.param(0)# ";
	qList=db.execute("qList");

	eventCom=application.zcore.app.getAppCFC("event");
	eventCom.getAdminNavMenu();
	</cfscript>
	<h2>Manage Event Categories</h2>

	<p><a href="/z/event/admin/manage-event-category/add">Add Event Category</a></p>

	<table class="table-list">
		<tr>
			<th>Name</th>
			<th>Admin</th>
		</tr>
		<cfscript>
		for(row in qList){
			echo('<tr>
				<td>#row.event_category_name#</td>
				<td>
					<a href="#eventCom.getCategoryURL(row)#" target="_blank">View</a> | 
					<a href="/z/event/admin/manage-event-category/edit?event_category_id=#row.event_category_id#&amp;modalpopforced=1"  onclick="zTableRecordEdit(this);  return false;">Edit</a> | 
					<a href="##" onclick="zDeleteTableRecordRow(this, ''/z/event/admin/manage-event-category/delete?event_category_id=#row.event_category_id#&amp;returnJson=1&amp;confirm=1''); return false;">Delete</a>
				</td>
			</tr>');

		}
		</cfscript>  
	</table>
</cffunction>
</cfoutput>
</cfcomponent>