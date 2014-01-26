<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var s=0;
	setting requesttimeout="350";
	// lock all requests so that the object dumps are consistent
	lock type="exclusive" timeout="300" throwontimeout="no" name="#request.zos.installPath#-zDeployExclusiveLock"{
		local.coreDumpFile=request.zos.zcoreRootCachePath&"scripts/memory-dump/"&server.railo.version&"-zcore.bin";
		local.tempCoreDumpFile=local.coreDumpFile&"."&gettickcount();
		objectsave(application.zcore, local.tempCoreDumpFile);
		application.zcore.functions.zdeletefile(local.coreDumpFile);
		application.zcore.functions.zRenameFile(local.tempCoreDumpFile, local.coreDumpFile);
		local.coreDumpFile=request.zos.zcoreRootCachePath&"scripts/memory-dump/"&server.railo.version&"-sitestruct.bin";
		local.tempCoreDumpFile=local.coreDumpFile&"."&gettickcount();
		objectsave(application.sitestruct, local.tempCoreDumpFile);
		application.zcore.functions.zdeletefile(local.coreDumpFile);
		application.zcore.functions.zRenameFile(local.tempCoreDumpFile, local.coreDumpFile);
		
		if(request.zos.isJavaEnabled){
			local.d=getpagecontext().getCFMLFactory().getScopeContext().getAllSessionScopes(getpagecontext());
			if(structkeyexists(application,'sessionstruct')){
				structappend(local.d, application.sessionstruct, false);
			}
			local.coreDumpFile=request.zos.zcoreRootCachePath&"scripts/memory-dump/"&server.railo.version&"-sessions.bin";
			local.tempCoreDumpFile=local.coreDumpFile&"."&gettickcount();
			objectsave(local.d, local.tempCoreDumpFile);
			application.zcore.functions.zdeletefile(local.coreDumpFile);
			application.zcore.functions.zRenameFile(local.tempCoreDumpFile, local.coreDumpFile);
		}
	};
	writeoutput('dump complete');
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>