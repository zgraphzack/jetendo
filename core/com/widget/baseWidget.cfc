<cfcomponent>
<cffunction name="initBase" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	ds=arguments.dataStruct;
	variables.arrStylesheet=[];
	init(ds);
	if(not structkeyexists(variables, 'widget_id')){
		c=GetMetaData(this);
		throw("variables.widget_id was not defined for the widget component: #c.name#");
	}
	if(not structkeyexists(variables, 'widget_version')){
		c=GetMetaData(this);
		throw("variables.widget_version was not defined for the widget component: #c.name#");
	}
	if(not structkeyexists(variables, 'widget_name')){
		c=GetMetaData(this);
		throw("variables.widget_name was not defined for the widget component: #c.name#");
	}
	variables.widget_code_name=application.zcore.functions.zURLEncode(variables.widget_name, "-"); 
	variables.dataStruct=ds; 
	variables.configStruct=variables.getConfig();
	</cfscript>	
</cffunction>

<cffunction name="getWidgetId" localmode="modern" access="public">
	<cfscript>
	return variables.widget_id;	
	</cfscript>
</cffunction>

<cffunction name="render" localmode="modern" access="remote">
	<cfargument name="htmlData" type="struct" required="yes">
	<cfscript>
	if(not request.zos.isTestServer){
		application.zcore.functions.z404("Only works on test server");
	}  
	arguments.htmlData.widgetContainer="widgetInstance#variables.dataStruct.widget_instance_id#";

	version=getVersion();  
	htmlOut='<div id="widgetInstance#variables.dataStruct.widget_instance_id#" class="zWidgetContainer">'&getHTML(arguments.htmlData)&'</div>';//variables.configStruct, dataStruct);

	jsOut=getJS(arguments.htmlData);

	a=variables.arrStylesheet;
	for(i=1;i<=arraylen(a);i++){
		application.zcore.skin.includeCSS(a[i]);
	}

	stylesheetCompiled="/zupload/#variables.widget_code_name#-#variables.dataStruct.widget_instance_id#.css?zv=#version#";
	application.zcore.template.appendTag("stylesheets", '<link rel="stylesheet" href="#stylesheetCompiled#" type="text/css" />');
	//application.zcore.skin.includeCSS(stylesheetCompiled);

	echo(htmlOut);

	// TODO: later I might want to compile these to single file / minify
	application.zcore.template.appendTag('scripts', '<script type="text/javascript">'&jsOut&'</script>');
	</cfscript>

</cffunction>

<cffunction name="getVersion" localmode="modern" access="remote">
	<cfscript> 
	if(not structkeyexists(application.zcore, 'widgetVersionStruct')){
		application.zcore.widgetVersionStruct={};
	}
	if(not structkeyexists(application.zcore.widgetVersionStruct, variables.widget_id)){ 
		application.zcore.widgetVersionStruct[variables.widget_id]={
			version:variables.widget_version,
			instanceStruct={}
		}
	}
	forceCompile=false;
	if(application.zcore.widgetVersionStruct[variables.widget_id].version NEQ variables.widget_version){
		application.zcore.widgetVersionStruct[variables.widget_id].version=variables.widget_version;
		forceCompile=true;
	}
	if(request.zos.isTestServer){
		forceCompile=true;
	} 
	version="";
	if(not structkeyexists(application.zcore.widgetVersionStruct[variables.widget_id].instanceStruct, variables.dataStruct.widget_instance_id)){
		version=application.zcore.functions.zReadFile(request.zos.globals.privateHomeDir&"zupload/#variables.widget_code_name#-#variables.dataStruct.widget_instance_id#.version"); 
		if(version EQ false){
			forceCompile=true;
		}
	}else{
		version=application.zcore.widgetVersionStruct[variables.widget_id].instanceStruct[variables.dataStruct.widget_instance_id];
	}

	if(forceCompile){
		cs=variables.dataStruct.cssData;
		cs.widgetContainer="##widgetInstance#variables.dataStruct.widget_instance_id#";
		cssOut=getCSS(cs);
		hashCSS=hash(cssOut);
		application.zcore.widgetVersionStruct[variables.widget_id].instanceStruct[variables.dataStruct.widget_instance_id]=hashCSS;

		if(compare(hashCSS, version) NEQ 0){
			application.zcore.functions.zWriteFile(request.zos.globals.privateHomeDir&"zupload/#variables.widget_code_name#-#variables.dataStruct.widget_instance_id#.version", hashCSS); 
			application.zcore.functions.zWriteFile(request.zos.globals.privateHomeDir&"zupload/#variables.widget_code_name#-#variables.dataStruct.widget_instance_id#.css", cssOut);
		}
		version=hashCSS;
	}
	return version;
	</cfscript>
</cffunction>


<cffunction name="getConfig" localmode="modern" access="public" output="no">
	<cfscript>
	return {};
	</cfscript>
</cffunction>
	
<!--- 
widget_instance_id
widget_instance_name
widget_instance_version
widget_instance_updated_datetime
widget_instance_deleted
widget_instance_json_data LONGTEXT
widget_id
site_id

 --->
<cffunction name="baseUpgrade" localmode="modern" access="public" output="no">
	<cfscript> 
	initBase({});
	db=request.zos.queryObject;

	offset=0;
	while(true){
		// if the version change breaks compatible, write a script to upgrade the stored data of previous versions
		db.sql="select * from #db.table("widget_instance", request.zos.zcoreDatasource)# WHERE 
		site_id <> #db.param(-1)# and 
		widget_instance_deleted=#db.param(0)# and 
		widget_instance_version<#db.param(variables.widget_version)# 
		LIMIT #db.param(offset)#, #db.param(20)#";
		offset+=20;
		qInstance=db.execute("qInstance");
		if(qInstance.recordcount EQ 0){
			break;
		}
		for(dataStruct in qInstance){
			jsonStruct=deserializeJson(dataStruct.widget_instance_json_data); 
			rs=upgrade(dataStruct, jsonStruct);
			ts={
				table:"widget_instance",
				datasource:request.zos.zcoreDatasource,
				struct:rs.dataStruct
			};
			ts.struct.widget_instance_version=variables.widget_version;
			ts.struct.widget_instance_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
			ts.struct.widget_instance_json_data=serializeJson(rs.jsonStruct);
			application.zcore.functions.zUpdate(ts);
		}
	}
	return true;
	</cfscript>
</cffunction>
</cfcomponent>