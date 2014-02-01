<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	setting requesttimeout="4000";
	var db=request.zos.queryObject;
	
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	db.sql="SELECT menu.menu_id, menu.site_id 
	FROM #db.table("menu", request.zos.zcoreDatasource)# menu,
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE
	site.site_id = menu.site_id and 
	site.site_active=#db.param(1)#";
	local.q=db.execute("q");
	menuFunctionsCom=createobject("component", "zcorerootmapping.com.app.menuFunctions");
	for(local.row in local.q){
		menuFunctionsCom.publishMenu(local.row.menu_id, local.row.site_id);
	}
	
	db.sql="UPDATE #db.table("slideshow", request.zos.zcoreDatasource)# slideshow
	SET	slideshow_hash=#db.param('')# 
	WHERE
	site_id <> #db.param(-1)#";
	local.q=db.execute("q");
	
	for(i in application.sitestruct){
		if(structkeyexists(application.sitestruct[i], 'slideshowNameCacheStruct')){
			structclear(application.sitestruct[i].slideshowNameCacheStruct);
		}
		if(structkeyexists(application.sitestruct[i], 'slideshowIdCacheStruct')){
			structclear(application.sitestruct[i].slideshowIdCacheStruct);
		}
	}
	writeoutput('Done');
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>