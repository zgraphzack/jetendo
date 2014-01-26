<!--- 
/z/test/functions/fileAndDirectory/zGetDiskUsageTest/runTestRemote
 --->

<cfcomponent extends="mxunit.framework.TestCase">

	<!--- this will run before every single test in this test case --->
	<cffunction name="setUp" localmode="modern" returntype="void" access="public" hint="put things here that you want to run before each test">

	</cffunction>

	<!--- this will run after every single test in this test case --->
	<cffunction name="tearDown" localmode="modern" returntype="void" access="public" hint="put things here that you want to run after each test">

	</cffunction>

        <!--- this will run once after initialization and before setUp() --->
	<cffunction name="beforeTests" localmode="modern" returntype="void" access="public" hint="put things here that you want to run before all tests"> 
	</cffunction>

	<!--- this will run once after all tests have been run --->
	<cffunction name="afterTests" localmode="modern" returntype="void" access="public" hint="put things here that you want to run after all tests">

	</cffunction>
 
	<cffunction name="testExecuteEnabledDirectorySize" localmode="modern" returntype="void" access="public">
		<cfscript>
		local.backupExecute=request.zos.isExecuteEnabled;
		request.zos.isExecuteEnabled=true;
		assert(application.zcore.functions.zGetDiskUsage(request.zos.globals.serverhomedir&"mvc/z/test/functions/fileAndDirectory/controller/") GT 0);
		request.zos.isExecuteEnabled=local.backupExecute;
		</cfscript>
	</cffunction>
    
	<cffunction name="testExecuteDisabledDirectorySize" localmode="modern" returntype="void" access="public">
		<cfscript>
		local.backupExecute=request.zos.isExecuteEnabled;
		request.zos.isExecuteEnabled=false;
		assert(application.zcore.functions.zGetDiskUsage(request.zos.globals.serverhomedir&"mvc/z/test/functions/fileAndDirectory/controller/") GT 0);
		request.zos.isExecuteEnabled=local.backupExecute;
		</cfscript>
	</cffunction>

	<cffunction name="testExecuteEnabledFileSize" localmode="modern" returntype="void" access="public">
		<cfscript>
		local.backupExecute=request.zos.isExecuteEnabled;
		request.zos.isExecuteEnabled=true;
		assert(application.zcore.functions.zGetDiskUsage(request.zos.globals.serverhomedir&"mvc/z/test/functions/fileAndDirectory/controller/zGetDiskUsageTest.cfc") GT 0);
		request.zos.isExecuteEnabled=local.backupExecute;
		</cfscript>
	</cffunction>
    
	<cffunction name="testExecuteDisabledFileSize" localmode="modern" returntype="void" access="public">
		<cfscript>
		local.backupExecute=request.zos.isExecuteEnabled;
		request.zos.isExecuteEnabled=false;
		assert(application.zcore.functions.zGetDiskUsage(request.zos.globals.serverhomedir&"mvc/z/test/functions/fileAndDirectory/controller/zGetDiskUsageTest.cfc") GT 0);
		request.zos.isExecuteEnabled=local.backupExecute;
		</cfscript>
	</cffunction>
</cfcomponent>
