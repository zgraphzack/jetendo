<cfcomponent>
<cfoutput>
<cffunction name="updateApplicationCFCFunctions" access="private" localmode="modern">

	<!--- <cfinclude template="/#request.zos.zcoremapping#/init/onServerStart.cfm"> --->
	<cfinclude template="/#request.zos.zcoremapping#/init/onCFCRequest.cfm">
	<cfinclude template="/#request.zos.zcoremapping#/init/onApplicationStart.cfm">
	<!--- <cfinclude template="/#request.zos.zcoremapping#/init/onApplicationEnd.cfm"> --->
	<cfinclude template="/#request.zos.zcoremapping#/init/onRequestStart.cfm">
	<cfinclude template="/#request.zos.zcoremapping#/init/onRequestEnd.cfm">
	<cfinclude template="/#request.zos.zcoremapping#/init/onError.cfm">
	<cfinclude template="/#request.zos.zcoremapping#/init/onMissingTemplate.cfm">
	<!--- don't waste memory if we don't need to --->
	<!--- <cfinclude template="/#request.zos.zcoremapping#/init/onSessionStart.cfm">
	<cfinclude template="/#request.zos.zcoremapping#/init/onSessionEnd.cfm"> --->
	<cfinclude template="/#request.zos.zcoremapping#/init/onRequest.cfm">
	<cfscript>
	tfunctions=structnew();
	//tFunctions.onServerStart=onServerStart;
	//tFunctions.onApplicationEnd=onApplicationEnd;
	//tFunctions.onSessionStart=onSessionStart;
	//tFunctions.onSessionEnd=onSessionEnd;
	tFunctions.onApplicationStart=onApplicationStart;
	tFunctions.onRequestStart=onRequestStart;
	tFunctions.onRequestStart1=onRequestStart1;
	tFunctions.onRequestStart12=onRequestStart12;
	tFunctions.onRequestStart2=onRequestStart2;
	tFunctions.onRequestStart3=onRequestStart3;
	tFunctions.onRequestStart4=onRequestStart4;
	tFunctions.onExecuteCacheReset=onExecuteCacheReset;
	tFunctions.onCodeDeploy=onCodeDeploy;
	tFunctions.onRequestEnd=onRequestEnd;
	tFunctions.onRequest=onRequest;
	tFunctions.onError=onError;
	tFunctions._zTempEscape=_zTempEscape;
	tFunctions._zTempErrorHandlerDump=_zTempErrorHandlerDump;
	tFunctions._handleError=_handleError;
	
	tFunctions.onMissingTemplate=onMissingTemplate;
	
	tFunctions.setupAppGlobals1=setupAppGlobals1;
	tFunctions.setupAppGlobals2=setupAppGlobals2;
	server["zcore_"&request.zos.installPath&"_functionscache"]=tFunctions;
	</cfscript>
</cffunction>

<cffunction name="onCodeDeploy" access="public" localmode="modern">
	<cfscript>
	
	structclear(application.zcore.allcomponentcache);
	if(structkeyexists(application.zcore, 'templateCFCCache')){
		for(i in application.zcore.templateCFCCache){
			structclear(application.zcore.templateCFCCache[i]);
		}
	}

	configCom=createobject("component", "zcorerootmapping.config");
	ts=configCom.getConfig(request.zos.cgi);
	structappend(request.zos, ts.zos, true);
    


	variables.updateApplicationCFCFunctions();
	
	tempVar=createobject("component","zcorerootmapping.functionInclude");
	functions=tempVar.init();
	request.zos.functions=functions;
	application.zcore.functions=functions; 
	
	siteOptionTypeStruct={
		"0": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.textSiteOptionType"),
		"1": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.textareaSiteOptionType"),
		"2": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.htmlEditorSiteOptionType"),
		"3": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.imageSiteOptionType"),
		"4": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.dateTimeSiteOptionType"),
		"5": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.dateSiteOptionType"),
		"6": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.timeSiteOptionType"),
		"7": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.selectMenuSiteOptionType"),
		"8": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.checkboxSiteOptionType"),
		"9": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.fileSiteOptionType"),
		"10": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.emailSiteOptionType"),
		"11": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.htmlSeparatorSiteOptionType"),
		"12": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.hiddenSiteOptionType"),
		"13": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.mapPickerSiteOptionType"),
		"14": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.radioSiteOptionType"),
		"15": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.urlSiteOptionType"),
		"16": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.userPickerSiteOptionType"),
		"17": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.numberSiteOptionType"),
		"18": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.colorSiteOptionType"),
		"19": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.stateSiteOptionType"),
		"20": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.countrySiteOptionType"),
		"21": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.listingSavedSearchSiteOptionType")
	};
	application.zcore.siteOptionTypeStruct=siteOptionTypeStruct;
	
	componentObjectCache=structnew();
	componentObjectCache.cache=CreateObject("component","zcorerootmapping.com.zos.cache");
	componentObjectCache.session=CreateObject("component","zcorerootmapping.com.zos.session");
	componentObjectCache.tracking=CreateObject("component","zcorerootmapping.com.app.tracking");
	componentObjectCache.template=CreateObject("component","zcorerootmapping.com.zos.template");
	componentObjectCache.routing=CreateObject("component", "zcorerootmapping.com.zos.routing");
	componentObjectCache.debugger=CreateObject("component","zcorerootmapping.com.zos.debugger");
	componentObjectCache.user=CreateObject("component","zcorerootmapping.com.user.user");
	componentObjectCache.skin=CreateObject("component","zcorerootmapping.com.display.skin");
	componentObjectCache.status=CreateObject("component","zcorerootmapping.com.zos.status");
	componentObjectCache.email=CreateObject("component","zcorerootmapping.com.app.email");
	componentObjectCache.siteOptionCom=CreateObject("component","zcorerootmapping.com.app.site-option");
	componentObjectCache.imageLibraryCom=CreateObject("component","zcorerootmapping.com.app.image-library");
	componentObjectCache.hook=CreateObject("component","zcorerootmapping.com.zos.hook");
	componentObjectCache.app=CreateObject("component","zcorerootmapping.com.zos.app");
	componentObjectCache.db=createobject("component","zcorerootmapping.com.model.db");
	componentObjectCache.adminSecurityFilter=createobject("component","zcorerootmapping.com.app.adminSecurityFilter");
	if(request.zos.isdeveloper and structkeyexists(request.zsession, 'verifyQueries') and request.zsession.verifyQueries){
		local.verifyQueriesEnabled=true;
	}else{
		local.verifyQueriesEnabled=false;
	}
	dbInitConfigStruct={
		insertIdSQL:"select @zLastInsertId id2, last_insert_id() id",
		datasource:request.zos.globals.serverdatasource,
		tablePrefix:request.zos.zcoreDatasourcePrefix,
		parseSQLFunctionStruct:{checkSiteId:application.zcore.functions.zVerifySiteIdsInDBCFCQuery},
		verifyQueriesEnabled:local.verifyQueriesEnabled,
		cacheStructKey:'application.zcore.queryCache'
	}
	componentObjectCache.db.init(dbInitConfigStruct);
	
	application.zcore.componentObjectCache=componentObjectCache;
	structappend(application.zcore, application.zcore.componentObjectCache);
	if(request.zos.allowRequestCFC){
		structappend(request.zos, application.zcore.componentObjectCache, true);
	}
	
	
	
	application.zcore.skin.onCodeDeploy(application.zcore.skinObj);
	application.zcore.listingCom=createobject("component","zcorerootmapping.mvc.z.listing.controller.listing");
	application.zcore.listingStruct.configCom=application.zcore.listingCom;
	// loop all app CFCs
	for(i in application.zcore.appComPathStruct){
		currentCom=createobject("component", application.zcore.appComPathStruct[i].cfcPath);
		if(structkeyexists(currentCom, 'onCodeDeploy')){
			currentCom.onCodeDeploy(application.zcore);
		}
	}
	
	request.zos.functions.zUpdateGlobalMVCData(application.zcore);
	
	backupStruct={
		zRootPath:request.zRootPath,
		zRootDomain:request.zRootDomain,
		zRootCFCPath:request.zRootCFCPath,
		zRootSecureCfcPath:request.zRootSecureCfcPath, 
	};
	// loop all sitestruct
	for(n in application.siteStruct){
		application.sitestruct[n].comCache={};
		application.sitestruct[n].fileExistsCache={};
		request.zRootDomain=replace(replace(application.sitestruct[n].globals.shortDomain,'www.',''),"."&request.zos.testDomain,"");
		request.zRootPath="/"&replace(request.zRootDomain, ".","_","all")&"/"; 
		request.zRootSecureCfcPath="jetendo-sites.writable."&replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";
		request.zRootCfcPath=replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";
	
		application.zcore.functions.zUpdateSiteMVCData(application.sitestruct[n]);
			if(structkeyexists(application.sitestruct[n], 'app')){
			for(i in application.sitestruct[n].app.appCache){
				currentCom=createObject("component", application.zcore.appComPathStruct[i].cfcPath);
				if(i NEQ 11 and i NEQ 13){ // rental and listing apps are not thread-safe yet due to cfinclude and var scoping
					currentCom=createObject("component", application.zcore.appComPathStruct[i].cfcPath);
					application.sitestruct[n].app.appCache[i].cfcCached=currentCom;
				}
				currentCom.site_id=request.zos.globals.id;
				if(structkeyexists(currentCom, 'onSiteCodeDeploy')){
					currentCom.onSiteCodeDeploy(application.sitestruct[n].app.appCache[i]);
				}
			}	
		}
		application.siteStruct[n].dbComponents=application.zcore.functions.getSiteDBObjects(application.sitestruct[n].globals);
		
		customExists=fileexists(application.sitestruct[n].globals.homedir&"zCoreCustomFunctions.cfc");
		if(fileexists(application.sitestruct[n].globals.homedir&"zrewriterules.cfc")){
			application.siteStruct[n].siteRewriteRuleCom=createobject("component", request.zRootCFCPath&"zrewriterules");
		}else if(customExists){
			application.siteStruct[n].siteRewriteRuleCom=createobject("component", request.zRootCFCPath&"zCoreCustomFunctions");
		}else{
			structdelete(application.siteStruct[n], 'siteRewriteRuleCom');
		}
		application.zcore.functions.zUpdateCustomSiteFunctions(application.siteStruct[n]);
	} 
	structappend(request, backupStruct, true);

	versionCom=createobject("component", "zcorerootmapping.version");
    ts2=versionCom.getVersion();


	runDatabaseUpgrade=false;
    if(not structkeyexists(application.zcore, 'databaseVersion') or application.zcore.databaseVersion NEQ ts2.databaseVersion){
    	// do database upgrade
    	runDatabaseUpgrade=true;
	}else{
		db=request.zos.queryObject;
		db.sql="select * from #db.table("jetendo_setup", request.zos.zcoreDatasource)# 
		WHERE jetendo_setup_deleted = #db.param(0)# 
		LIMIT #db.param(0)#, #db.param(1)#";
		qSetup=db.execute("qSetup");
	}
    application.zcore.databaseVersion=ts2.databaseVersion;
    application.zcore.sourceVersion=ts2.sourceVersion;
	if(runDatabaseUpgrade or qSetup.recordcount EQ 0 or qSetup.jetendo_setup_database_version NEQ application.zcore.databaseVersion){
		dbUpgradeCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.db-upgrade");
		if(not dbUpgradeCom.checkVersion()){
			if(request.zos.isTestServer or request.zos.isDeveloper){
				echo('Database upgrade failed');
				abort;
			}
		}
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>