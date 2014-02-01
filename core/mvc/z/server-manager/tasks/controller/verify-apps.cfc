<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	db=request.zos.queryObject;
	db.sql="select * from #db.table("app_x_mls", request.zos.zcoreDatasource)# app_x_mls, 
	#db.table("site", request.zos.zcoreDatasource)# site WHERE 
	site.site_id = app_x_mls.site_id 
	LIMIT #db.param(0)#, #db.param(1)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount NEQ 0){
		application.zcore.listingCom.checkRamTables();
	}
	echo('Done');abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>