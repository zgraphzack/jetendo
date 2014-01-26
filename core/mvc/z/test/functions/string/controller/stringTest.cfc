<!--- 
/z/test/functions/string/stringTest/runTestRemote
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

	<!--- your test. Name it whatever you like... make it descriptive. --->
	<cffunction name="zGenerateStrongPasswordWithMinLength" localmode="modern" returntype="void" access="public">
		<cfset var result = len(application.zcore.functions.zGenerateStrongPassword(5))>
		<cfset assert(result GT 0)>
	</cffunction>
    
	<cffunction name="zGenerateStrongPasswordNoArguments" localmode="modern" returntype="void" access="public">
		<cfset var result = len(application.zcore.functions.zGenerateStrongPassword())>
		<cfset assert(result GT 0)>
	</cffunction>

</cfcomponent>

