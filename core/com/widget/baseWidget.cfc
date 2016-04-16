<cfcomponent>
<cffunction name="init" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript> 
	getBaseConfig(); 
	variables.dataStruct=arguments.dataStruct; 
	</cfscript>	
</cffunction>

<cffunction name="getBaseConfig" localmode="modern" access="public" output="no">
	<cfscript>
	cs=getConfig();
	if(not structkeyexists(cs, 'arrStylesheet')){
		cs.arrStylesheet=[];
	}
	if(not structkeyexists(cs, 'id') or not structkeyexists(cs, 'version') or not structkeyexists(cs, 'name') or not structkeyexists(cs, 'codeName') or not structkeyexists(cs, 'layoutFields')  or not structkeyexists(cs, 'dataFields')){
		c=GetMetaData(this);
		throw('#c.name# -> getConfig() must return struct with the following keys: id, version, name, codeName, layoutFields, dataFields.');
	}
	/*variables.widget_id=cs.id;
	variables.widget_version=cs.version;
	variables.widget_name=cs.name;
	variables.widget_code_name=cs.codeName; */
	variables.configStruct=cs;
	return duplicate(cs);
	</cfscript>
</cffunction>

<cffunction name="getWidgetId" localmode="modern" access="public">
	<cfscript>
	return variables.configStruct.id;	
	</cfscript>
</cffunction>

<cffunction name="getWidgetVersion" localmode="modern" access="public">
	<cfscript>
	return variables.configStruct.version;	
	</cfscript>
</cffunction>

<cffunction name="getWidgetName" localmode="modern" access="public">
	<cfscript>
	return variables.configStruct.name;	
	</cfscript>
</cffunction>

<cffunction name="render" localmode="modern" access="public">
	<cfargument name="dataFields" type="struct" required="yes">
	<cfscript>
	cs=variables.configStruct;
	if(not request.zos.isTestServer){
		application.zcore.functions.z404("Only works on test server");
	}  
	arguments.dataFields.widgetContainer="widgetInstance#variables.dataStruct.widget_instance_id#";

	version=getVersion();  
	htmlOut='<div id="widgetInstance#variables.dataStruct.widget_instance_id#" class="zWidgetContainer">'&getHTML(arguments.dataFields)&'</div>';//variables.configStruct, dataStruct);

	jsOut=getJS(arguments.dataFields);

	a=cs.arrStylesheet;
	for(i=1;i<=arraylen(a);i++){
		application.zcore.skin.includeCSS(a[i]);
	}

	stylesheetCompiled="/zupload/#cs.codeName#-#variables.dataStruct.widget_instance_id#.css?zv=#version#";
	application.zcore.template.appendTag("stylesheets", '<link rel="stylesheet" href="#stylesheetCompiled#" type="text/css" />');
	//application.zcore.skin.includeCSS(stylesheetCompiled);

	echo(htmlOut);

	// TODO: later I might want to compile these to single file / minify
	application.zcore.template.appendTag('scripts', '<script type="text/javascript">'&jsOut&'</script>');
	</cfscript>

</cffunction>

<cffunction name="getVersion" localmode="modern" access="public">
	<cfscript> 
	cs=variables.configStruct;
	if(not structkeyexists(application.zcore, 'widgetVersionStruct')){
		application.zcore.widgetVersionStruct={};
	}
	if(not structkeyexists(application.zcore.widgetVersionStruct, cs.id)){ 
		application.zcore.widgetVersionStruct[cs.id]={
			version:cs.version,
			instanceStruct={}
		}
	}
	forceCompile=false;
	if(application.zcore.widgetVersionStruct[cs.id].version NEQ cs.version){
		application.zcore.widgetVersionStruct[cs.id].version=cs.version;
		forceCompile=true;
	}
	if(request.zos.isTestServer){
		forceCompile=true;
	} 
	version="";
	if(not structkeyexists(application.zcore.widgetVersionStruct[cs.id].instanceStruct, variables.dataStruct.widget_instance_id)){
		version=application.zcore.functions.zReadFile(request.zos.globals.privateHomeDir&"zupload/#cs.codeName#-#variables.dataStruct.widget_instance_id#.version"); 
		if(version EQ false){
			forceCompile=true;
		}
	}else{
		version=application.zcore.widgetVersionStruct[cs.id].instanceStruct[variables.dataStruct.widget_instance_id];
	}

	if(forceCompile){
		cd=variables.dataStruct.layoutFields;
		cd.widgetContainer="##widgetInstance#variables.dataStruct.widget_instance_id#";
		cssOut=getCSS(cd);
		hashCSS=hash(cssOut);
		application.zcore.widgetVersionStruct[cs.id].instanceStruct[variables.dataStruct.widget_instance_id]=hashCSS;

		if(compare(hashCSS, version) NEQ 0){
			application.zcore.functions.zWriteFile(request.zos.globals.privateHomeDir&"zupload/#cs.codeName#-#variables.dataStruct.widget_instance_id#.version", hashCSS); 
			application.zcore.functions.zWriteFile(request.zos.globals.privateHomeDir&"zupload/#cs.codeName#-#variables.dataStruct.widget_instance_id#.css", cssOut);
		}
		version=hashCSS;
	}
	return version;
	</cfscript>
</cffunction>

	
<cffunction name="baseUpgrade" localmode="modern" access="public" output="no">
	<cfscript> 
	init({});
	db=request.zos.queryObject;

	cs=variables.configStruct;
	offset=0;
	while(true){
		// if the version change breaks compatible, write a script to upgrade the stored data of previous versions
		db.sql="select * from #db.table("widget_instance", request.zos.zcoreDatasource)# WHERE 
		site_id <> #db.param(-1)# and 
		widget_instance_deleted=#db.param(0)# and 
		widget_instance_version<#db.param(cs.version)# 
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
			ts.struct.widget_instance_version=cs.version;
			ts.struct.widget_instance_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
			ts.struct.widget_instance_json_data=serializeJson(rs.jsonStruct);
			application.zcore.functions.zUpdate(ts);
		}
	}
	return true;
	</cfscript>
</cffunction>
</cfcomponent>