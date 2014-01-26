<!--- 
/z/test/mvc/z/listing/mls-provider/datafunctionsTest/runTestRemote
 --->
<cfcomponent extends="mxunit.framework.TestCase">
<cfoutput>
	<!--- this will run before every single test in this test case --->
	<cffunction name="setUp" localmode="modern" returntype="void" access="public" hint="put things here that you want to run before each test">
        <cfscript>
		var qDir=0;
		variables.arrDataCom=[];
		</cfscript>
        <cfdirectory action="list" directory="#request.zos.globals.serverhomedir#mvc/z/listing/mls-provider/" name="qDir" filter="*data.cfc">
        <cfloop query="qDir">
			<cfscript>
			if(right(qDir.name, 8) EQ "data.cfc"){
				arrayappend(variables.arrDataCom, createobject("component", "zcorerootmapping.mvc.z.listing.mls-provider."&replace(name,".cfc","")));
			}
			</cfscript>
        </cfloop>
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
	<cffunction name="getDetailCache1" localmode="modern" returntype="void" access="public">
    	<cfscript>
		var i=0;
		var a=0;
		for(i=1;i LTE arraylen(variables.arrDataCom);i++){
			a=variables.arrDataCom[i].getDetailCache1(structnew());
			assert(len(a) EQ 0);
		}
		</cfscript>
	</cffunction>
    
	<!--- your test. Name it whatever you like... make it descriptive. --->
	<cffunction name="getDetailCache2" localmode="modern" returntype="void" access="public">
    	<cfscript>
		var i=0;
		var a=0;
		for(i=1;i LTE arraylen(variables.arrDataCom);i++){
			a=variables.arrDataCom[i].getDetailCache2(structnew());
			assert(len(a) EQ 0);
		}
		</cfscript>
	</cffunction>
    
	<!--- your test. Name it whatever you like... make it descriptive. --->
	<cffunction name="getDetailCache3" localmode="modern" returntype="void" access="public">
    	<cfscript>
		var i=0;
		var a=0;
		for(i=1;i LTE arraylen(variables.arrDataCom);i++){
			a=variables.arrDataCom[i].getDetailCache3(structnew());
			assert(len(a) EQ 0);
		}
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>