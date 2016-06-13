<cfcomponent extends="zcorerootmapping.com.zos.controller">
	<cfproperty name="sectionModel" type="zcorerootmapping.mvc.z.admin.model.sectionModel">
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	
	application.zcore.adminSecurityFilter.requireFeatureAccess("Sections");	
	var queueSortStruct = StructNew();
	/*variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	queueSortStruct.tableName = "section";
	queueSortStruct.datasource="#request.zos.zcoreDatasource#";
	queueSortStruct.sortFieldName = "section_sort";
	queueSortStruct.primaryKeyName = "section_id";
	queueSortStruct.where="site_id = '#request.zos.globals.id#' and section_deleted='0' ";
	queueSortStruct.ajaxURL="/z/admin/section/index";
	queueSortStruct.ajaxTableId="sortRowTable";
	variables.queueSortCom.init(queueSortStruct);
	variables.queueSortCom.returnJson();*/
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Sections", true);	  
	db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("section", request.zos.zcoreDatasource)# section
	WHERE section_id= #db.param(application.zcore.functions.zso(form,'section_id'))# and 
	section_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	
	form.returnJson=application.zcore.functions.zso(form, 'returnJson', true, 0);
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'section no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/admin/section/index?zsid=#request.zsid#');
	}
	if(structkeyexists(form,'confirm')){
		//application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.section_image_library_id);
		db.sql="DELETE FROM #db.table("section", request.zos.zcoreDatasource)#  
		WHERE section_id= #db.param(application.zcore.functions.zso(form, 'section_id'))# and 
		section_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");
		//variables.queueSortCom.sortAll();
		if(form.returnJson EQ 1){
			application.zcore.functions.zReturnJson({success:true});
		}else{
			application.zcore.status.setStatus(Request.zsid, 'Section deleted');
			application.zcore.functions.zRedirect('/z/admin/section/index?zsid=#request.zsid#');
		} 
	}else{
		echo('<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this section?<br />
			<br />
			#qCheck.section_name#<br />
			<br />
			<a href="/z/admin/section/delete?confirm=1&amp;section_id=#form.section_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/admin/section/index">No</a> 
		</div>');
	}
	</cfscript>
	
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>  
	init();
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	application.zcore.adminSecurityFilter.requireFeatureAccess("Sections", true);	
	form.site_id = request.zos.globals.id;
	ts.section_name.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/admin/section/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/admin/section/edit?section_id=#form.section_id#&zsid=#request.zsid#');
		}
	}
	ts=StructNew();
	ts.table='section';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.section_id = application.zcore.functions.zInsert(ts);
		if(form.section_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save section.',form,true);
			application.zcore.functions.zRedirect('/z/admin/section/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Section saved.');
			//variables.queueSortCom.sortAll();
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save section.',form,true);
			application.zcore.functions.zRedirect('/z/admin/section/edit?section_id=#form.section_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Section updated.');
		}
		
	}
	//application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'section_image_library_id'));
	if(form.modalpopforced EQ 1){
		application.zcore.functions.zRedirect('/z/admin/section/getReturnSectionRowHTML?section_id=#form.section_id#');
	}else{
		application.zcore.functions.zRedirect('/z/admin/section/index?zsid=#request.zsid#');
	}
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	
	<cfscript> 
	db=request.zos.queryObject; 
	currentMethod=form.method; 
	//application.zcore.functions.zSetPageHelpId("5.5");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Sections");	
	if(application.zcore.functions.zso(form,'section_id') EQ ''){
		form.section_id = -1;
	}
	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "section_return"&form.section_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}
	db.sql="SELECT * FROM #db.table("section", request.zos.zcoreDatasource)# section 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	section_deleted = #db.param(0)# and 
	section_id=#db.param(form.section_id)#";
	qRoute=db.execute("qRoute");
	application.zcore.functions.zQueryToStruct(qRoute);
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
		</cfif>
		Section</h2>
	<form action="/z/admin/section/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?section_id=#form.section_id#" method="post">
		<input type="hidden" name="modalpopforced" value="#form.modalpopforced#" />
		<table style="width:100%;" class="table-list">
			<tr>
				<th>Name</th>
				<td><input type="text" name="section_name" value="#htmleditformat(form.section_name)#" /></td>
			</tr>
			<!--- <tr>
				<th style="width:1%; white-space:nowrap;" class="table-white">Photos:</th>
				<td colspan="2" class="table-white"><cfscript>
				ts=structnew();
				ts.name="section_image_library_id";
				ts.value=form.section_image_library_id;
				application.zcore.imageLibraryCom.getLibraryForm(ts);
				</cfscript></td>
			</tr>  --->
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save Section</button>
					<cfif form.modalpopforced EQ 1>
						<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button>
					<cfelse>
						<button type="button" name="cancel" onclick="window.location.href = '/z/admin/section/index';">Cancel</button>
					</cfif>
				</td>
			</tr>
		</table>
	</form>
</cffunction>


<cffunction name="getReturnSectionRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("section", request.zos.zcoreDatasource)# event 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	section_deleted = #db.param(0)# and 
	section_id=#db.param(form.section_id)#";
	qSection=db.execute("qSection"); 
	 
	savecontent variable="rowOut"{
		for(row in qSection){
			getSectionRowHTML(row);
		}
	}

	echo('done.<script type="text/javascript">
	window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
	window.parent.zCloseModal();
	</script>');
	abort;
	</cfscript>
</cffunction>


<cffunction name="getSectionRowHTML" localmode="modern" access="public" roles="member">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	echo('<td>#row.section_id#</td> 
	<td>#row.section_name#</td>  
	<td> 
	<a href="/z/admin/section/edit?section_id=#row.section_id#&amp;modalpopforced=1" onclick="zTableRecordEdit(this);  return false;">Edit</a> | 
	<a href="/z/admin/landing-page/index?section_id=#row.section_id#&landing_page_parent_id=0">Manage Content</a> | 
	<a href="##" onclick="zDeleteTableRecordRow(this, ''/z/admin/section/delete?section_id=#row.section_id#&amp;returnJson=1&amp;confirm=1''); return false;">Delete</a></td>');
	</cfscript>
</cffunction>

<cffunction name="nav" localmode="modern" access="public" roles="member"> 
	<p> 
		<a href="/z/admin/layout-breakpoint/index">Breakpoints</a> | 
		<a href="/z/admin/layout-global/index">Global Layout Settings</a> | 
		<a href="/z/admin/layout-global/instanceList">Manage Settings Instances</a> | 
		<a href="/z/admin/layout-page/index">Manage Layouts</a>  | 
		<a href="/z/admin/layout-page/index">Manage Sections</a>  | 
		<a href="/z/admin/landing-page/index">Manage Custom Landing Pages</a> | 
		<a href="/z/admin/widget/index">Manage Widgets</a> |
		<a href="https://www.jetendo.com/layout-editor/row-editor" target="_blank">Row Editor</a> |
		<a href="https://www.jetendo.com/layout-editor/index" target="_blank">Editor Notes</a>
		<!--- <a href="/z/admin/layout-preset/index">Landing Presets</a> |  --->
	</p>

</cffunction>
	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	init();
	//application.zcore.functions.zSetPageHelpId("5.4");
	form.section_parent_id=application.zcore.functions.zso(form, 'section_parent_id', true, 0);

	//viewData={};
	//viewData.qSection=variables.sectionModel.getChildren(form.section_parent_id);
	//writedump(viewData);

	db.sql="select * from #db.table("section", request.zos.zcoreDatasource)# 
	WHERE section_parent_id = #db.param(form.section_parent_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	section_deleted = #db.param(0)# 
	ORDER BY section_name ASC ";
	qSection=db.execute("qSection");  
	application.zcore.functions.zStatusHandler(request.zsid); 

	nav();
	</cfscript>
	<h2>Manage Sections</h2>
	<p><a href="/z/admin/section/add">Add Section</a></p>
	<cfif qSection.recordcount EQ 0>
		<p>No sections have been added.</p>
	<cfelse>
		<table id="sortRowTable" class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Name</th> 
				<!--- <th>Sort</th> --->
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfscript>
				for(row in qSection){
					echo('<tr>');
					getSectionRowHTML(row);
					echo('</tr>');
				}
				</cfscript>
				<!--- <cfloop query="qSection">
				<tr> #variables.queueSortCom.getRowHTML(qSection.section_id)# <cfif qSection.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
					
				</tr>
				</cfloop> --->
			</tbody>
		</table>
	</cfif>
</cffunction>
	
</cfoutput>
</cfcomponent>