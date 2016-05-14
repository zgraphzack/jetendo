<cfcomponent>
<cfoutput>
<cffunction name="getWidgetIdByName" localmode="modern" access="public">
	<cfargument name="widgetCodeName" type="string" required="yes">
	<cfscript>
	if(structkeyexists(application.zcore.widgetNameStruct, arguments.widgetCodeName)){
		return application.zcore.widgetNameStruct[arguments.widgetCodeName];
	}else{
		throw('"#arguments.widgetCodeName#" is not a valid widget code name or the app cache must be reset.');
	}
	</cfscript>
</cffunction>
  
<!--- 

	ts={};
	// ts.arrData and ts.layoutFields won't support complex types for key values. (cfc, function, array and struct are complex types)
	ts.widget_instance_id=0;
	"image-heading-summary-subpage-thumbnail"
	ts.layoutFields={};
	// the fields edited by developer / advanced user
	ts.layoutFields["default"]={
		"Show Button": "Yes",
		"Use Mobile Image": false,
		"Thumbnail Width": "300",
		"Thumbnail Height": "150",
		"Thumbnail Crop": "Yes"
	}
	// optionally specify different values at different breakpoints
	ts.layoutFields["1200"]={ 
		"Thumbnail Width": "250",
		"Thumbnail Height": "130",
	};
	ts.layoutFields["980"]={ 
	};
	ts.layoutFields["768"]={ 
		"Use Mobile Image": true,
		"Thumbnail Width": "200",
		"Thumbnail Height": "100",
	};
	ts.layoutFields["480"]={ 
	}; 
	widget=application.zcore.widget.getWidget(ts);
	// the fields edited by client/user.  arrData is an array of dataFields structures.
	// getHTML will be called once per item in the arrData array
	ts={
		image: person.image,
		mobileImage: person["Mobile Image"],
		heading: person["first name"]&" "&person["last name"],
		summary: person.title,
		url: person.__url
	};
	echo(widget.renderHTML(ts));
 --->
<cffunction name="getWidget" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfscript>
	ds=arguments.dataStruct;
	if(not structkeyexists(application.zcore, 'widgetIndexStruct')){
		indexCom=createObject("component", "zcorerootmapping.com.widget.widget-index");
		indexCom.loadIndex();
	} 
	//id=getWidgetIdByName(arguments.widgetName);
	if(structkeyexists(application.zcore.widgetNameStruct, arguments.dataStruct.widgetCodeName)){
		id=application.zcore.widgetNameStruct[arguments.dataStruct.widgetCodeName];
	}else{
		throw('"#arguments.dataStruct.widgetCodeName#" is not a valid widget code name or the app cache must be reset.');
	} 
	comPath=application.zcore.widgetIndexStruct[id];
	if(request.zos.isTestServer){
		widgetCom=createObject("component", comPath);
		widgetCom.init({widget_instance_id:ds.manualInstanceId, layoutFields:arguments.dataStruct.layoutFields}); 
		configStruct=widgetCom.getConfig();
		layoutWidgetCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.layout-widget");
		layoutWidgetCom.validateWidgetConfig(comPath, configStruct);
	}else{
		widgetCom=application.zcore.functions.zCreateObject("component", comPath);
		widgetCom.init({widget_instance_id:ds.manualInstanceId, layoutFields:arguments.dataStruct.layoutFields}); 
		configStruct=widgetCom.getConfig();
	}
 	return widgetCom;
 	/*
	ds={
		widget_instance_id:0,
		layoutFields:arguments.dataStruct.layoutFields
	};
	widgetCom.init(ds); 
 
	widgetCom.render(arguments.dataStruct.arrData);
 	*/
	</cfscript>
</cffunction>
<!--- 
<cffunction name="renderWidget" localmode="modern" access="public">
	<cfargument name="widgetName" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	if(not structkeyexists(application.zcore, 'widgetIndexStruct')){
		indexCom=createObject("component", "zcorerootmapping.com.widget.widget-index");
		indexCom.loadIndex();
	} 
	id=getWidgetIdByName(arguments.widgetName);
	
	if(not structkeyexists(application.zcore.widgetIndexStruct, id)){
		application.zcore.functions.z404("Invalid widget id");
	} 
	comPath=application.zcore.widgetIndexStruct[id];
	if(request.zos.isTestServer){
		widgetCom=createObject("component", comPath);
		widgetCom.init({widget_instance_id:}); 
		configStruct=widgetCom.getConfig();
		layoutWidgetCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.layout-widget");
		layoutWidgetCom.validateWidgetConfig(comPath, configStruct);
	}else{
		widgetCom=application.zcore.functions.zCreateObject("component", comPath);
		widgetCom.init({});
		configStruct=widgetCom.getConfig();
	}
 
	ds={
		widget_instance_id:0,
		layoutFields:arguments.dataStruct.layoutFields
	};
	widgetCom.init(ds); 
 
	widgetCom.render(arguments.dataStruct.arrData);
 
	</cfscript>	
</cffunction> --->

<cffunction name="getWidgetInstance" localmode="modern" access="public">
	<cfargument name="widgetInstanceName" type="string" required="yes">
	<cfscript>
	if(structkeyexists(application.widgetInstanceStruct, arguments.widgetInstanceName)){
		return application.widgetInstanceStruct[arguments.widgetInstanceName];
	}else{
		throw('"#arguments.widgetInstanceName#" is not a valid widget instance name. You may need to reset the site cache or add the widget instance to zCoreCustomFunctions onSiteRequestStart()');
	}
	</cfscript>
</cffunction>
	
</cfoutput>
</cfcomponent>