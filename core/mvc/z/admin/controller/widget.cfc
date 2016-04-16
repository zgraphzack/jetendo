<cfcomponent output="no">
<cfoutput> 
<cffunction name="index" localmode="modern" roles="administrator" access="remote">
	<cfscript> 
	db=request.zos.queryObject;  
	ts={};
	application.zcore.functions.zStatusHandler(request.zsid);

	indexCom=createObject("component", "zcorerootmapping.com.widget.widget-index");
	indexCom.loadIndex();

	for(id in application.zcore.widgetIndexStruct){ 
		comPath=application.zcore.widgetIndexStruct[id];
		widgetCom=createObject("component", comPath);
		widgetCom.init({});
		configStruct=widgetCom.getConfig();

		ts[id]={
			id:configStruct.id,
			name:configStruct.name,
			version:configStruct.version,
		}
	}
	arrKey=structsort(ts, "text", "asc", "name"); 
 	echo('<p><a href="/z/admin/layout-page/index">Manage Layouts</a> /</p>');
	echo('<h2>Manage Widgets</h2>');
	echo('<table class="table-list">
		<tr>
			<th>ID</th>
			<th>Name</th>
			<th>Version</th>
			<th>Admin</th>
		</tr>');
	for(i=1;i<=arraylen(arrKey);i++){
		row=ts[arrKey[i]];
		echo('<tr>
			<td>#row.id#</td>
			<td>#row.name#</td>
			<td>#row.version#</td>
			<td>
			<a href="/z/admin/widget/previewWidget?widget_id=#row.id#">Preview</a> | 
			<a href="/z/admin/widget/upgradeWidget?widget_id=#row.id#">Upgrade Instances</a> | 
			<a href="/z/admin/widget/listWidgetInstances?widget_id=#row.id#">Manage Instances</a></td>
		</tr>');
	}
	echo('</table>');
	</cfscript>
	
</cffunction>

<cffunction name="upgradeWidget" localmode="modern" roles="administrator" access="remote">
	<cfscript>
	id=application.zcore.functions.zso(form, 'widget_id', true);
	if(not structkeyexists(application.zcore.widgetIndexStruct, id)){
		application.zcore.functions.z404("Invalid widget id");
	}
	comPath=application.zcore.widgetIndexStruct[id];
	widgetCom=createObject("component", comPath);
	widgetCom.init({});
	configStruct=widgetCom.getConfig();

	
	layoutWidgetCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.layout-widget");
	layoutWidgetCom.validateWidgetConfig(comPath, configStruct);

	widgetCom.baseUpgrade(); 
	v=widgetCom.getWidgetVersion();

	application.zcore.status.setStatus(request.zsid, "All widget instances upgraded to version: #v#");
	application.zcore.functions.zRedirect("/z/admin/widget/index?zsid=#request.zsid#");
	</cfscript>
	
</cffunction>

<cffunction name="previewWidget" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	if(not structkeyexists(application.zcore, 'widgetIndexStruct')){
		indexCom=createObject("component", "zcorerootmapping.com.widget.widget-index");
		indexCom.loadIndex();
	} 
	id=application.zcore.functions.zso(form, 'widget_id', true);
	if(not structkeyexists(application.zcore.widgetIndexStruct, id)){
		application.zcore.functions.z404("Invalid widget id");
	}
	application.zcore.template.setPlainTemplate();
	comPath=application.zcore.widgetIndexStruct[id];
	widgetCom=createObject("component", comPath);
	widgetCom.init({});
	configStruct=widgetCom.getConfig();

	layoutWidgetCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.layout-widget");
	layoutWidgetCom.validateWidgetConfig(comPath, configStruct);
 	//echo('<p><a href="/z/admin/layout-page/index">Manage Layouts</a> / <a href="/z/admin/widget/index">Manage Widgets</a> /</p>');
	//echo('<h2>Previewing Widget: '&configStruct.name&'</h2>');


	ds={
		widget_instance_id:0,
		layoutFields:{}
	};
	dataFields={};
	for(i=1;i<=arrayLen(configStruct.layoutFields);i++){
		f=configStruct.layoutFields[i];
		ds.layoutFields[f.label]=f.previewValue;
	}
	for(i=1;i<=arrayLen(configStruct.dataFields);i++){
		f=configStruct.dataFields[i];
		dataFields[f.label]=f.previewValue;
	}
	widgetCom.init(ds); 

	widgetCom.render(dataFields);
 
	</cfscript>	
</cffunction>


<cffunction name="listWidgetInstances" localmode="modern" access="remote" roles="member">
	<cfscript> 
	db=request.zos.queryObject;  
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	// layout_column_x_widget_id
	// layout_column_x_widget_instance_id
	// landing_page_x_widget_instance_id
	// landing_page_x_widget_id

	form.widget_id=application.zcore.functions.zso(form, 'widget_id');
	form.layout_column_id=application.zcore.functions.zso(form, 'layout_column_id');

	layoutWidgetCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.layout-widget");
	rs=layoutWidgetCom.getWidgetCFC(form.widget_id);
	if(not rs.success){
		application.zcore.status.setStatus(request.zsid, "Invalid widget id", form, true);
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	widgetCom=rs.cfc;
	comPath=rs.comPath; 
	configStruct=widgetCom.getConfig(); 

	// TODO: show breadcrumb for the layout column instead of this
	echo('<p><a href="/z/admin/widget/index">Manage Widgets</a> /</p>'); 
	echo('<h2>Widget Instances Of "#configStruct.name#"</h2>'); 

	db.sql="select * from 
	#db.table("widget_instance", request.zos.zcoreDatasource)#  
	WHERE  
	widget_instance_deleted=#db.param(0)# and 
	widget_instance_standalone=#db.param(1)# and 
	site_id = #db.param(request.zos.globals.id)# 
	ORDER BY widget_instance_name ASC ";
	qWidget=db.execute("qWidget");

	application.zcore.functions.zStatusHandler(request.zsid);
	echo('<p>Note: file/image/sub-records are not deleted in current implementation which must be fixed.</p>');

	echo('<p><a href="/z/admin/layout-widget/addWidgetInstanceLayout?widget_instance_standalone=1&amp;widget_id=#form.widget_id#">Add Widget Instance</a></p>');
	echo('<table class="table-list">
		<tr>
			<th>ID</th>
			<th>Name</th> 
			<th>Admin</th>
		</tr>');
	for(row in qWidget){
		echo('<tr>
			<td>#row.widget_instance_id#</td>
			<td>#row.widget_instance_name#</td> 
			<td><a href="/z/admin/layout-widget/editWidgetInstanceData?widget_id=#row.widget_id#&amp;widget_instance_id=#row.widget_instance_id#">Edit Data</a> | 
			<a href="/z/admin/layout-widget/editWidgetInstanceLayout?widget_id=#row.widget_id#&amp;widget_instance_id=#row.widget_instance_id#">Edit Layout</a> | 
			<a href="##" onclick="zDeleteTableRecordRow(this, ''/z/admin/layout-widget/deleteWidgetInstance?widget_id=#row.widget_id#&amp;widget_instance_id=#row.widget_instance_id#&amp;returnJson=1&amp;confirm=1''); return false;">Delete</a></td>
		</tr>');
	}
	echo('</table>');
	if(qWidget.recordcount EQ 0){
		echo('<p>No instances found.</p>');
	}
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>