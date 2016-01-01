<cfcomponent extends="zcorerootmapping.com.zos.controller"> 
<cfoutput>
<!--- 
/z/admin/layout-widget/index
/z/admin/layout-widget/addWidgetInstanceLayout?widget_id=1&widget_instance_id=
/z/admin/layout-widget/loadWidgets
 --->
<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	widgetCom=createobject("component", "zcorerootmapping.com.widget.widget-example");

	widgetCom.baseUpgrade();

	ds={
		widget_instance_id=1,
		cssData:{
			"Font Scale":1,
			"Container Padding":1,
			"Left Column Size":0.4,
			"Column Gap":20
		}
	};
	widgetCom.init(ds); 


	htmlData={
		"Heading":"Heading",
		"Body Text":"Body Text",
		"Image":"/z/a/images/broker_reciprocity.jpg"
	};
	widgetCom.render(htmlData);

	ds={
		widget_instance_id=2,
		cssData:{
			"Font Scale":.5,
			"Container Padding":.5,
			"Left Column Size":0.6,
			"Column Gap":100
		}
	};
	widgetCom.init(ds); 

	htmlData={
		"Heading":"Example 2",
		"Body Text":"Example Text 2",
		"Image":"/z/a/images/redarrow.jpg"
	};
	widgetCom.render(htmlData);


	</cfscript>
</cffunction>



<cffunction name="addWidgetInstanceData" localmode="modern" access="remote" roles="member">
	<cfscript> 
	displayWidgetForm("data");
	</cfscript>
</cffunction>

<cffunction name="editWidgetInstanceData" localmode="modern" access="remote" roles="member">
	<cfscript> 
	displayWidgetForm("data");
	</cfscript>
</cffunction>

<cffunction name="addWidgetInstanceLayout" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	displayWidgetForm("layout");
	</cfscript>
</cffunction>

<cffunction name="editWidgetInstanceLayout" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	displayWidgetForm("layout");
	</cfscript>
</cffunction>
	
<cffunction name="validateWidgetConfig" localmode="modern" access="public">
	<cfargument name="comPath" type="string" required="yes">
	<cfargument name="configStruct" type="struct" required="yes">
	<cfscript> 
	comPath=arguments.comPath;
	configStruct=arguments.configStruct;
	typeStruct={}; 
	typeCFCStruct=application.zcore.siteOptionCom.getTypeCFCStruct();
	for(i in typeCFCStruct){ 
		typeCFC=application.zcore.siteOptionCom.getTypeCFC(i);
		options=typeCFC.getOptionFieldStruct();
		typeStruct[typeCFCStruct[i].getTypeName()]={id:i, typeCFC: typeCFC, options:options };		
	}

	//writedump(structkeyarray(typeStruct));abort;
	fail=false;
	arrValidate=["layoutFields", "dataFields"];
	for(n=1;n<=arraylen(arrValidate);n++){
		key=arrValidate[n];
		for(i3=1;i3<=arraylen(configStruct[key]);i3++){ 
			field=configStruct[key][i3];
			if(not structkeyexists(field, 'label')){
				application.zcore.status.setStatus(request.zsid, "#key# | field ###i# is missing a label key in #comPath# -> getConfig().", form, true); 
				fail=true;
				continue;
			}
			if(not structkeyexists(typeStruct, application.zcore.functions.zso(field, 'type'))){
				application.zcore.status.setStatus(request.zsid, "#key# | """&field.label&""" with type: ""#field.type#"" in #comPath# -> getConfig() is not a valid optionType name.", form, true); 
				fail=true;
				continue;
			}
			typeStruct2=typeStruct[field.type]; 
			for(i2 in typeStruct2.options){
				if(not structkeyexists(field.options, i2)){
					application.zcore.status.setStatus(request.zsid, "#key# | The options for field: """&field.label&""" in #comPath# -> getConfig() is missing this option: #i2#.", form, true); 
					fail=true;
					continue;
				}
			}
			if(fail){
				continue;
			}
			try{
				rs=typeStruct2.typeCFC.onUpdate(field.options);
			}catch(Any e){ 
				application.zcore.status.setStatus(request.zsid, "#key# | """&field.label&""" with type: ""#field.type#"" in #comPath# -> onUpdate() failed with this error:<br />"&e.message, form, true); 
				continue;
			}
			if(not rs.success){
				fail=true;
				continue;
			}
			field.value=""; 
			field.options=rs.optionStruct;
			field.typeId=typeStruct2.id;
			defaultStruct={
				readonly:0,
				smallWidth:0,
				hideLabel:0,
				required:0,
				defaultValue:''
			};
			structappend(field, defaultStruct, false);
			field.site_option_id=field.id;


		}
	}
	if(fail){
		arrError=application.zcore.status.getErrors(request.zsid);
		throw(arrayToList(arrError, "<hr />"));
	}

	</cfscript>
</cffunction>
 
 
<cffunction name="getWidgetCFC" localmode="modern" access="public">
	<cfargument name="widget_id" type="string" required="yes">
	<cfscript> 
	if(not structkeyexists(application.zcore, 'widgetIndexStruct')){
		indexCom=createObject("component", "zcorerootmapping.com.widget.widget-index");
		indexCom.loadIndex();
	} 
	if(structkeyexists(application.zcore.widgetIndexStruct, arguments.widget_id)){ 
		return {success:true, comPath: application.zcore.widgetIndexStruct[arguments.widget_id], cfc:createObject("component", application.zcore.widgetIndexStruct[arguments.widget_id])};
	}else{
		return {success:false, errorMessage:"Widget doesn't exist."};
	}
	</cfscript>
</cffunction>

<cffunction name="displayWidgetForm" localmode="modern" access="public">
	<cfargument name="type" type="string" required="yes" hint="layout or data are valid values"> 
	<cfscript>
	form.widget_instance_id=application.zcore.functions.zso(form, 'widget_instance_id');
	form.widget_id=application.zcore.functions.zso(form, 'widget_id');

	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', true);
	methodbackup=form.method;

	rs=getWidgetCFC(form.widget_id);
	if(not rs.success){
		application.zcore.status.setStatus(request.zsid, "Invalid widget id", form, true);
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	widgetCom=rs.cfc;
	comPath=rs.comPath;
	arrEnd=[];
	db=request.zos.queryObject; 


	ds={
		widget_instance_id:form.widget_instance_id,
		cssData:{}
	};
	widgetCom.init(ds);
	configStruct=widgetCom.getBaseConfig();
	fields=configStruct[arguments.type&"Fields"];

	if(methodbackup EQ "editWidgetInstanceLayout" or methodbackup EQ "editWidgetInstanceData"){
		db.sql="select * from #db.table("widget_instance", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		widget_instance_deleted=#db.param(0)# and 
		widget_id =#db.param(form.widget_id)# and 
		widget_instance_id=#db.param(form.widget_instance_id)#";
		qWidget=db.execute("qWidget");
		if(qWidget.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid widget instance id", form, true);
			application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
		}
		jsonStruct=deserializeJson(qWidget.widget_instance_json_data);
		jsonFields=application.zcore.functions.zso(jsonStruct, arguments.type&'Fields', false, {});
		for(i in fields){
			if(structkeyexists(jsonFields, fields[i].label)){
				fields[i].value=jsonFields[fields[i].label];
			}
		}
		form.widget_instance_name=qWidget.widget_instance_name;
	}else{
		form.widget_instance_name=application.zcore.functions.zso(form, 'widget_instance_name');
	} 
	currentRowIndex=0;
	optionStruct={};
	dataStruct={};
	labelStruct={};
	posted=false;

	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}


	echo('<form id="siteOptionGroupForm" action="'); 
	echo('/z/admin/layout-widget/');
	if(methodbackup EQ "addWidgetInstanceLayout"){
		echo('insertWidgetInstanceLayout');
	}else if(methodbackup EQ "editWidgetInstanceLayout"){
		echo('updateWidgetInstanceLayout');
	}else if(methodbackup EQ "addWidgetInstanceData"){
		echo('insertWidgetInstanceData');
	}else if(methodbackup EQ "editWidgetInstanceData"){
		echo('updateWidgetInstanceData');
	} 
	echo('" method="post" enctype="multipart/form-data" >');
	</cfscript>
	 
	<input type="hidden" name="widget_id" value="#htmleditformat(form.widget_id)#" />
	<input type="hidden" name="widget_instance_id" value="#htmleditformat(form.widget_instance_id)#" /> 
	<table style="border-spacing:0px;" class="table-list">
 
		<tr><td>&nbsp;</td><td>
		<button type="submit" name="submitForm">Save</button>
			&nbsp;
			<cfif form.modalpopforced EQ 1>
				<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button>
			<cfelse>
				<cfscript>
				cancelLink="/member/";
				</cfscript>
				<button type="button" name="cancel" onclick="window.location.href='#cancelLink#';">Cancel</button>
			</cfif>
		</td></tr> 
		<tr>
			<th>Instance Name</th>
			<td><input type="text" name="widget_instance_name" value="#htmleditformat(form.widget_instance_name)#">
			</td>
		</tr>
	<cfscript>
	/*typeStruct={}; 
	typeCFCStruct=application.zcore.siteOptionCom.getTypeCFCStruct();
	for(i in typeCFCStruct){ 
		typeCFC=application.zcore.siteOptionCom.getTypeCFC(i);
		options=typeCFC.getOptionFieldStruct();
		typeStruct[typeCFCStruct[i].getTypeName()]={id:i, typeCFC: typeCFC, options:options };		
	}*/
	validateWidgetConfig(comPath, configStruct);
	for(i=1;i<=arraylen(fields);i++){
		currentRowIndex++; 
		field=fields[i];
		id=fields[i].id;
		if(not structkeyexists(form, "newvalue"&id)){
			if(structkeyexists(form, field.label)){
				posted=true;
				form["newvalue"&id]=form[field.label];
			}else{
				if(structkeyexists(field,'value') and field.value NEQ ""){
					form["newvalue"&id]=field.value;
				}else{
					form["newvalue"&id]=field.defaultValue;
				}
			}
		}else{
			posted=true;
		}
		form[field.label]=form["newvalue"&id];    
		typeCFC=application.zcore.siteOptionCom.getTypeCFC(field.typeId);
		dataStruct=typeCFC.onBeforeListView(field, field.options, form);
		if((methodBackup EQ "addWidgetInstanceLayout" or methodBackup EQ "addWidgetInstanceData") and not posted and not typeCFC.isCopyable()){
			form["newvalue"&id]='';
		}
		value=typeCFC.getListValue(dataStruct, field.options, form["newvalue"&id]);
		if(value EQ ""){
			value=field.defaultValue;
		}
		labelStruct[field.label]=value;
	}
	currentRowIndex=0;
	for(i=1;i<=arraylen(fields);i++){
		currentRowIndex++; 
		field=fields[i];
		id=fields[i].id;
	 
		typeCFC=application.zcore.siteOptionCom.getTypeCFC(field.typeId);
		field.site_option_id=id;
		rs=typeCFC.getFormField(field, field.options, 'newvalue', form);
		if(rs.hidden){
			arrayAppend(arrEnd, '<input type="hidden" name="site_option_id" value="'&id&'" />');
			arrayAppend(arrEnd, rs.value);
		}else{
			writeoutput('<tr class="siteOptionFormField#id# ');
			if(currentRowIndex MOD 2 EQ 0){
				writeoutput('row1');
			}else{
				writeoutput('row2');
			}
			writeoutput('">');
			if(rs.label and field.hideLabel EQ 0){
				tdOutput="";
				if(field.smallWidth EQ 1){
					tdOutput=' width:1%; white-space:nowrap; ';
				}
				writeoutput('<th style="vertical-align:top;#tdOutput#"><div style="padding-bottom:0px;float:left;">'&field.label&'<a id="soid_#id#" style="display:block; float:left;"></a>
				</div></th>
				<td style="vertical-align:top;white-space: nowrap;"><input type="hidden" name="site_option_id" value="#htmleditformat(id)#" />');
			}else{
				if(field.type EQ "HTML Separator"){
					writeoutput('<td style="vertical-align:top; padding-top:15px; padding-bottom:0px;" colspan="2">');
				}else{
					writeoutput('<td style="vertical-align:top; padding-top:5px;" colspan="2">');
				}
				if(rs.label){
					writeoutput('<input type="hidden" name="site_option_id" value="#htmleditformat(id)#" />');
				}
			} 
			if(field.readonly EQ 1 and labelStruct[field.label] NEQ ""){
				echo('<div class="zHideReadOnlyField" id="zHideReadOnlyField#currentRowIndex#">'&rs.value);
			}else{
				echo(rs.value);
			}
		}
		if(field.required){
			writeoutput(' * ');
		} 

		if(field.readonly EQ 1 and labelStruct[field.label] NEQ ""){
			echo('</div>');
			echo('<div id="zReadOnlyButton#currentRowIndex#" class="zReadOnlyButton">#labelStruct[field.label]#');
			if(labelStruct[field.label] NEQ ""){
				echo('<hr />');
			}
			echo('<strong>Read only value</strong> | <a href="##" class="zEditReadOnly" data-readonlyid="zReadOnlyButton#currentRowIndex#" data-fieldid="zHideReadOnlyField#currentRowIndex#">Edit Anyway</a></div> ')
		}
		if(rs.label){
			writeoutput('</td>');	
			writeoutput('</tr>');
		}
	}
	</cfscript>
			<tr>
				<th>&nbsp;</th>
				<td>
					#arraytolist(arrEnd, '')# 
					<button type="submit" name="submitForm">Save</button>
					&nbsp;
					<cfif form.modalpopforced EQ 1>
						<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button>
					<cfelse>
						<button type="button" name="cancel" onclick="window.location.href='#cancelLink#';">Cancel</button>
					</cfif> 
				</td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="deleteWidgetInstance" localmode="modern" access="remote" roles="member">
	<cfscript>
	echo('delete');abort;
	</cfscript>
</cffunction>

<cffunction name="saved" localmode="modern" access="remote" roles="member">
	<cfscript>
	</cfscript>
	Close modal now.
</cffunction>

<cffunction name="insertWidgetInstanceLayout" localmode="modern" access="remote" roles="member">
	<cfscript>
	saveWidgetInstance();
	</cfscript>
</cffunction>
 
<cffunction name="updateWidgetInstanceLayout" localmode="modern" access="remote" roles="member">
	<cfscript> 
	saveWidgetInstance();
	</cfscript>
</cffunction>

<cffunction name="insertWidgetInstanceData" localmode="modern" access="remote" roles="member">
	<cfscript>
	saveWidgetInstance();
	</cfscript>
</cffunction>


<cffunction name="updateWidgetInstanceData" localmode="modern" access="remote" roles="member">
	<cfscript>
	saveWidgetInstance();
	</cfscript>
</cffunction>

<cffunction name="saveWidgetInstance" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject; 
	writedump(form); 

	widgetCom=createobject("component", "zcorerootmapping.com.widget.widget-example");

	ts={
		table:"widget_instance",
		datasource:request.zos.zcoreDatasource,
		struct:{}
	};
	if(form.method EQ "insertWidgetInstanceLayout" or form.method EQ "updateWidgetInstanceLayout"){
		if(not application.zcore.user.checkServerAccess()){
			application.zcore.status.setStatus(request.zsid, "Access denied - must be server administrator", form, true);
			application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
		}
	}
	if(form.method EQ "insertWidgetInstanceLayout"){
		failMethod="addWidgetInstanceLayout";
		type="layout";
	}else if(form.method EQ "updateWidgetInstanceLayout"){
		failMethod="editWidgetInstanceLayout";
		type="layout";
	}else if(form.method EQ "insertWidgetInstanceData"){
		failMethod="addWidgetInstanceData";
		type="data";
	}else if(form.method EQ "updateWidgetInstanceData"){
		failMethod="editWidgetInstanceData";
		type="data";
	}
	t9={};

	// TODO: load widget and configstruct here

	rs=getWidgetCFC(form.widget_id);
	if(not rs.success){
		application.zcore.status.setStatus(request.zsid, "Invalid widget id", form, true);
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	widgetCom=rs.cfc;
	comPath=rs.comPath; 
	ds={
		widget_instance_id:form.widget_instance_id,
		cssData:{}
	};
	widgetCom.init(ds);
	configStruct=widgetCom.getBaseConfig();
	fields=configStruct[type&"Fields"];

	for(i=1;i<=arraylen(configStruct["#type#Fields"]);i++){
		field=configStruct["#type#Fields"][i]; 
		if(structkeyexists(form, 'newvalue'&field.id)){
			t9[field.label]=form['newvalue'&field.id];
		}
	}
	
	ts.struct.widget_instance_deleted=0;
	ts.struct.widget_instance_json_data=serializeJson(t9);
	ts.struct.widget_instance_updated_datetime=request.zos.mysqlnow;
	ts.struct.site_id=request.zos.globals.id;
	ts.struct.widget_id=form.widget_id;
	ts.struct.widget_instance_version=widgetCom.getWidgetVersion();
	writedump(ts);
	abort;
	if(form.method EQ "insertWidgetInstanceLayout" or form.method EQ "insertWidgetInstanceData"){
		form.widget_instance_id=application.zcore.functions.zInsert(ts);
		if(form.widget_instance_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to save widget instance", form, true);
			application.zcore.functions.zRedirect("/z/admin/layout-widget/#failMethod#?zsid=#request.zsid#");
		}
	}else{
		ts.struct.widget_instance_id=form.widget_instance_id;
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to save widget instance", form, true);
			application.zcore.functions.zRedirect("/z/admin/layout-widget/#failMethod#?zsid=#request.zsid#");
		}
	}

	application.zcore.status.setStatus(request.zsid, "Saved");
	application.zcore.functions.zRedirect("/z/admin/layout-widget/saved?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="compileAllWidgets" localmode="modern" access="remote">
	<cfscript>
	// force compile all widget instances (has to be done on live server only because the data is site specific and editable by user)
	</cfscript>
</cffunction>



<cffunction name="loadWidgets" localmode="modern" access="remote">
	<cfscript>
	// load all widgets in the widgets directory
	// getWidgetId() to get their id.

	ts={};
	indexCom=createObject("component", "zcorerootmapping.com.widget.widget-index");
	indexCom.loadIndex();

	for(id in application.zcore.widgetIndexStruct){ 
		comPath=application.zcore.widgetIndexStruct[id];
		widgetCom=createObject("component", comPath);
		widgetCom.init({});
		configStruct=widgetCom.getBaseConfig();
		validateWidgetConfig(comPath, configStruct);
		ts[configStruct.id]=configStruct;
	}

	/*
	maybe use this for site specific widgets someday
	arrWidget=directoryList("#request.zos.installPath#core/com/widget/", true, 'path');
	for(i=1;i<=arrayLen(arrWidget);i++){
		comPath=arrWidget[i];
		if(right(comPath, 4) NEQ ".cfc" or right(comPath, 14) EQ "baseWidget.cfc"){
			continue;
		}
		comPath=replace(replace(comPath, '#request.zos.installPath#core/', 'zcorerootmapping/'), '/', '.', 'all');
		comPath=left(comPath, len(comPath)-4); 
		widgetCom=createObject("component", comPath); 
		widgetCom.init({});
		configStruct=widgetCom.getBaseConfig();
		validateWidgetConfig(comPath, configStruct);
		ts[configStruct.id]=configStruct;

		writedump(ts);abort;
	}
	*/
	application.zcore.widgetDataCache=ts;
	echo('done');
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>