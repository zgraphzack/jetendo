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

<cffunction name="clearCache" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	if(not structkeyexists(form, 'type')){
		throw('form.type is required and must be "site" or "app".');
	}
	if(form.type EQ "site" and not structkeyexists(form, 'sid')){
		throw('form.sid is required when form.type equals "site".');
	}
	</cfscript>
</cffunction>

</cfcomponent>