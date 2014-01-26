<cfcomponent>
<cffunction name="executeCacheReset" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	// this function is here as a placeholder for a "executeCacheReset" function that is exactly executed in onRequestStart.
	</cfscript>
</cffunction>

<cffunction name="getConfig" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var ts={
		installPath: request.zos.installPath,
		arrSite:[],
		success:true
	};
	db=request.zos.queryObject;
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active = #db.param(1)# and 
	site_id <> #db.param(-1)# 
	ORDER BY site_short_domain ASC ";
	qSite=db.execute("qSite");
	for(row in qSite){
		ss={
			id:row.site_id,
			shortDomain:row.site_short_domain,
			installPath: application.zcore.functions.zGetDomainInstallPath(row.site_short_domain)
		}
		arrayAppend(ts.arrSite, ss);
	}
	
	application.zcore.functions.zReturnJson(ts);
	</cfscript>
</cffunction>
</cfcomponent>