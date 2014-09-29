<cfcomponent>
<cfoutput>
<!--- <cffunction name="get" localmode="modern" access="public">
	<cfargument name="menu_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;

	</cfscript>
</cffunction>


<cffunction name="get" localmode="modern" access="public">
	<cfargument name="menu_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;

	</cfscript>
</cffunction>


<cffunction name="get" localmode="modern" access="public">
	<cfargument name="menu_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;

	</cfscript>
</cffunction>




 --->
<cffunction name="getMenuButtonLinksByButtonId" localmode="modern" access="public">
	<cfargument name="menu_button_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("menu_button_link", request.zos.zcoreDatasource)# menu_button_link WHERE 
	menu_button_id = #db.param(arguments.menu_button_id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	menu_button_link_deleted = #db.param(0)# ";
	return db.execute("qMenuButtonLinks");
	</cfscript>
</cffunction>


<cffunction name="insertMenuButtonLinkWithArray" localmode="modern" access="public">
	<cfargument name="arrI" type="array" required="yes">
	<cfargument name="newMenuId" type="string" required="yes">
	<cfargument name="newMenuButtonId" type="string" required="yes">
	<cfargument name="newSiteId" type="string" required="yes">
	<cfargument name="menuButtonLinkStruct" type="struct" required="yes">
	<cfscript>
	arrI=arguments.arrI;
	db=request.zos.queryObject;
	db.sql="INSERT	INTO #db.table("menu_button_link", request.zos.zcoreDatasource)#  SET ";
	arrF=arraynew(1);
	for(i=1;i LTE arraylen(arrI);i++){
		if(arrI[i] EQ "menu_button_link_id"){
		}else if(arrI[i] EQ "menu_id"){
			arrayappend(arrF, arrI[i]&"="&db.param(arguments.newmenuid));
		}else if(arrI[i] EQ "menu_button_id"){
			arrayappend(arrF, arrI[i]&"="&db.param(arguments.newmenubuttonid));
		}else if(arrI[i] EQ "site_id"){
			arrayappend(arrF, arrI[i]&"="&db.param(arguments.newsiteid));
		}else if(arrI[i] EQ "menu_button_link_updated_datetime"){
			arrayappend(arrF, arrI[i]&"="&db.param(request.zos.mysqlnow));
		}else{
			arrayappend(arrF, arrI[i]&"="&db.param(arguments.menuButtonLinkStruct[arrI[i]]));
		}
	}
	db.sql&=arraytolist(arrF,", ");
	db.execute("qC");
	</cfscript>
</cffunction>

<cffunction name="insertMenuButtonWithArray" localmode="modern" access="public">
	<cfargument name="arrT" type="array" required="yes">
	<cfargument name="newMenuId" type="string" required="yes">
	<cfargument name="newSiteId" type="string" required="yes">
	<cfargument name="menuButtonStruct" type="struct" required="yes">
	<cfscript>
	arrT=arguments.arrT;
	db=request.zos.queryObject;
	sql="INSERT	INTO #db.table("menu_button", request.zos.zcoreDatasource)#  SET ";
	arrF=arraynew(1);
	for(i=1;i LTE arraylen(arrT);i++){
		if(arrT[i] EQ "menu_button_id"){
		}else if(arrT[i] EQ "menu_id"){
			arrayappend(arrF, arrT[i]&"="&db.param(arguments.newmenuid));
		}else if(arrT[i] EQ "menu_button_type_tid"){
			arrayappend(arrF, arrT[i]&"="&db.param(0));
		}else if(arrT[i] EQ "menu_button_type_id"){
			arrayappend(arrF, arrT[i]&"="&db.param(0));
		
		}else if(arrT[i] EQ "site_id"){
			arrayappend(arrF, arrT[i]&"="&db.param(arguments.newsiteid));
		}else if(arrT[i] EQ "menu_button_updated_datetime"){
			arrayappend(arrF, arrT[i]&"="&db.param(request.zos.mysqlnow));
		}else{
			if(application.zcore.functions.zso(form, 'removelinks', true, 0) EQ 1 and arrT[i] EQ "menu_button_link"){
				arrayappend(arrF, arrT[i]&"=#db.param('##')#");
			}else{
				arrayappend(arrF, arrT[i]&"="&db.param(arguments.menuButtonStruct[arrT[i]]));
			}
		}
	}
	sql&=arraytolist(arrF,", ");
	db.sql=sql;
	return db.insert("qInsertMenuButton", request.zOS.insertIDColumnForSiteIDTable);
	</cfscript>
</cffunction>

<cffunction name="insertMenuWithArray" localmode="modern" access="public">
	<cfargument name="arrS" type="array" required="yes">
	<cfargument name="menu_name" type="string" required="yes">
	<cfargument name="newSiteId" type="string" required="yes">
	<cfargument name="menuStruct" type="struct" required="yes">
	<cfscript>
	arrS=arguments.arrS;
	db=request.zos.queryObject;
	sql="INSERT	INTO #db.table("menu", request.zos.zcoreDatasource)#  SET ";
	arrF=arraynew(1);
	for(i=1;i LTE arraylen(arrS);i++){
		if(arrS[i] EQ "menu_id"){ 
		}else if(arrS[i] EQ "menu_name"){
			arrayappend(arrF, arrS[i]&"="&db.param(arguments.menu_name));
		}else if(arrS[i] EQ "menu_codename"){
			arrayappend(arrF, arrS[i]&"="&db.param(arguments.menu_name));
		}else if(arrS[i] EQ "site_id"){
			arrayappend(arrF, arrS[i]&"="&db.param(arguments.newsiteid));
		}else if(arrS[i] EQ "menu_updated_datetime"){
			arrayappend(arrF, arrS[i]&"="&db.param(request.zos.mysqlnow));
		}else{
			arrayappend(arrF, arrS[i]&"="&db.param(arguments.menuStruct[arrS[i]]));
		}
	}
	sql&=arraytolist(arrF,", ");
	db.sql=sql; 
	return db.insert("qInsertMenu", request.zOS.insertIDColumnForSiteIDTable);
	</cfscript>
</cffunction>

<cffunction name="copyUpdateMenuName" localmode="modern" access="public">
	<cfargument name="menu_id" type="string" required="yes">
	<cfargument name="menu_name" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="update #db.table("menu", request.zos.zcoreDatasource)# menu 
	set menu_locked = #db.param('0')#, 
	menu_name =#db.param(arguments.menu_name)#, 
	menu_codename=#db.param(arguments.menu_name)#,
	menu_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE menu_id = #db.param(arguments.menu_id)#  and 
	menu_deleted = #db.param(0)# and
	site_id =#db.param(arguments.site_id)#";
	db.execute("qC");
	</cfscript>
</cffunction>

<cffunction name="getAllMenus" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("menu", request.zos.zcoreDatasource)# menu 
	WHERE  site_id = #db.param(request.zos.globals.id)# and 
	menu_deleted = #db.param(0)# ";
	return db.execute("qSite");
	</cfscript>
</cffunction>

<cffunction name="getMenuByNameAndSiteId" localmode="modern" access="public">
	<cfargument name="newName" type="string" required="yes">
	<cfargument name="newSiteId" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("menu", request.zos.zcoreDatasource)# menu WHERE 
	menu_name = #db.param(arguments.newname)# and 
	menu_deleted = #db.param(0)# and 
	site_id = #db.param(arguments.newSiteId)#";
	return db.execute("qS2");
	</cfscript>
</cffunction>

<cffunction name="getMenuButtons" localmode="modern" access="public">
	<cfargument name="menu_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("menu_button", request.zos.zcoreDatasource)# menu_button WHERE 
		menu_id = #db.param(arguments.menu_id)# and 
		menu_button_deleted = #db.param(0)# and 
		site_id =#db.param(request.zos.globals.id)#";
	return db.execute("qT");
	</cfscript>
</cffunction>
	
<cffunction name="deleteById" localmode="modern" access="public">
	<cfargument name="menu_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="delete from #db.table("menu", request.zos.zcoreDatasource)# 
	WHERE menu_id = #db.param(arguments.menu_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	menu_deleted = #db.param(0)# ";
	db.execute("qDelete");
	return true;
	</cfscript>
</cffunction>

<cffunction name="getSection" localmode="modern" access="public">
	<cfargument name="section_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("menu", request.zos.zcoreDatasource)# 
	WHERE section_id = #db.param(arguments.section_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	menu_deleted = #db.param(0)# 
	ORDER BY menu_name ASC ";
	return db.execute("qSection");
	</cfscript>
</cffunction>

<cffunction name="getById" localmode="modern" access="public">
	<cfargument name="menu_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("menu", request.zos.zcoreDatasource)# menu 
	WHERE menu_id = #db.param(arguments.menu_id)# and 
	menu_deleted = #db.param(0)# and 
	site_id =#db.param(request.zos.globals.id)#";
	return db.execute("qMenu");
	</cfscript>
</cffunction>


<cffunction name="getByName" localmode="modern" access="public">
	<cfargument name="menu_codename" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("menu", request.zos.zcoreDatasource)# menu 
	WHERE menu_codename = #db.param(arguments.menu_codename)# and 
	menu_deleted = #db.param(0)# and 
	site_id =#db.param(request.zos.globals.id)#";
	return db.execute("qMenu");
	</cfscript>
</cffunction>
	
</cfoutput>
</cfcomponent>