<cfcomponent hint="Wait for an estimated amount of available heap memory before continuing with request.">
<!--- run during onApplicationStart() on a cached instance of this CFC. --->
<cffunction name="setApplicationMemoryLimit" localmode="modern" access="public" returntype="string">
	<cfargument name="memoryInMegabytes" type="numeric" required="yes">
	<cfargument name="timeoutInMilliseconds" type="numeric" required="yes">
	<cfscript>
	if(not structkeyexists(application, 'memoryLimit')){
		application['memoryLimit']={};
	}
	application.memoryLimit.memoryInMegabytes=arguments.memoryInMegabytes;
	application.memoryLimit.currentMemoryUsage=0;
	application.memoryLimit.requestStruct=structnew("linked");
	</cfscript>
</cffunction>

<!--- Run on each request one or more times if you wish to limit memory usage. --->
<cffunction name="setRequestMemoryLimit" localmode="modern" access="public" returntype="string">
	<cfargument name="requestId" type="numeric" required="yes">
	<cfargument name="memoryInMegabytes" type="numeric" required="yes">
	<cfargument name="timeoutInMilliseconds" type="numeric" required="yes">
	<cfscript>
	if(structkeyexists(application.memoryLimit.requestStruct, arguments.requestId)){
		if(application.memoryLimit.requestStruct[arguments.requestId] LT arguments.memoryInMegabytes){
			application.memoryLimit.requestStruct[arguments.requestId]=arguments.memoryInMegabytes;
		}
	}else{
		application.memoryLimit.requestStruct[arguments.requestId]=arguments.memoryInMegabytes;
	}
	var startTime=gettickcount();
	while(gettickcount()-startTime LT arguments.timeoutInMilliseconds){
		var availableMemory=application.memoryLimit.memoryInMegabytes-application.memoryLimit.currentMemoryUsage;
		if(availableMemory LT arguments.memoryInMegabytes){
			sleep(1);
		}
	}
	lock name="#request.zos.installPath#-memoryLimit-AtomicIntegerLock" timeout="100" type="exclusive"{
		application.memoryLimit.currentMemoryUsage+=arguments.memoryInMegabytes;
	}
	</cfscript>
</cffunction>

<!--- Must be executed in the error handler for any exception, before abort, and application.onRequestEnd --->
<cffunction name="onRequestEnd" localmode="modern" access="public" returntype="string">
	<cfargument name="requestId" type="numeric" required="yes">
	<cfscript>
	lock name="#request.zos.installPath#-memoryLimit-AtomicIntegerLock" timeout="100" type="exclusive"{
		application.memoryLimit.currentMemoryUsage-=application.memoryLimit.requestStruct[arguments.requestId];
	}
	structdelete(application.memoryLimit.requestStruct, arguments.requestId);
	</cfscript>
</cffunction>
</cfcomponent>