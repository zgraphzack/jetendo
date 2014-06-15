<cfcomponent>
<cffunction name="downloadFile" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	if(not structkeyexists(form, 'path')){
		throw("form.path is required and must be an absolute path that the application server has read access to.");
	}
	if(not fileexists(form.path)){
		throw("form.path file is missing or the application server can't read it.");
	}
	if(left(form.path, len(request.zos.sitesWritablePath)) NEQ request.zos.siteWritablePath){
		throw("form.path must be within this directory: "&request.zos.sitesWritablePath);
	}
	content file="#form.path#";
	abort;
	</cfscript>
</cffunction>

<cffunction name="downloadNewerSessions" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	if(not structkeyexists(form, 'newerThenDate')){
		throw("form.newerThenDate is required.");
	}
	syncStruct=application.zcore.session.getSessionsNewerThen(parsedatetime(form.newerThenDate));
	echo(serialize(syncStruct));
	abort;
	</cfscript>
</cffunction>

</cfcomponent>