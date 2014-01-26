<!--- 
/z/test/mvc/z/listing/propertyDisplayTest/runTestRemote
 --->
<cfcomponent extends="mxunit.framework.TestCase">
<cfoutput>
	<!--- this will run before every single test in this test case --->
	<cffunction name="setUp" localmode="modern" returntype="void" access="public" hint="put things here that you want to run before each test">
		<cfscript>
		var contentQueryCom=createobject("component", "zcorerootmapping.mvc.z.test.mvc.z.listing.mock.contentQuery");
		var idxCom=createobject("component", "zcorerootmapping.mvc.z.test.mvc.z.listing.mock.idx-struct");
		variables.contentQuery=contentQueryCom.getContentQuery();
		variables.idx=idxCom.getIDXStruct();
		request.lastPhotoId=1; // this is ugly.
		variables.idx=idx;
		variables.propertyDisplayCom=createobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
		variables.propertyDisplayCom.init({dataStruct:{}});
		</cfscript>
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
	<cffunction name="listTemplate" localmode="modern" returntype="void" access="public">
    	<cfscript>
		variables.propertyDisplayCom.listTemplate(variables.idx);
		assert(true);
		</cfscript>
	</cffunction>
    
	<cffunction name="mapTemplate" localmode="modern" returntype="void" access="public">
    	<cfscript>
		variables.propertyDisplayCom.mapTemplate(variables.idx);
		assert(true);
		</cfscript>
	</cffunction>
    
	<cffunction name="thumbnailTemplate" localmode="modern" returntype="void" access="public">
    	<cfscript>
		variables.propertyDisplayCom.thumbnailTemplate(variables.idx);
		assert(true);
		</cfscript>
	</cffunction>
    
	<cffunction name="ajaxTemplate" localmode="modern" returntype="void" access="public">
    	<cfscript>
		variables.propertyDisplayCom.ajaxTemplate(variables.idx);
		assert(true);
		</cfscript>
	</cffunction>
    
	<cffunction name="contentEmailTemplate" localmode="modern" returntype="void" access="public">
    
    	<cfscript>
		variables.propertyDisplayCom.contentEmailTemplate(variables.contentQuery);
		assert(true);
		</cfscript>
	</cffunction>

	<cffunction name="contentTemplate" localmode="modern" returntype="void" access="public">
    	<cfscript>
		variables.propertyDisplayCom.contentTemplate(variables.idx);
		assert(true);
		</cfscript>
	</cffunction>
    
	<cffunction name="descriptionLinkTemplate" localmode="modern" returntype="void" access="public">
    	<cfscript>
		variables.propertyDisplayCom.descriptionLinkTemplate(variables.idx);
		assert(true);
		</cfscript>
	</cffunction>
    
	<cffunction name="rssTemplate" localmode="modern" returntype="void" access="public">
    	<cfscript>
		variables.propertyDisplayCom.rssTemplate(variables.idx);
		assert(true);
		</cfscript>
	</cffunction>
    
	<cffunction name="savedTemplate" localmode="modern" returntype="void" access="public">
    	<cfscript>
		variables.propertyDisplayCom.savedTemplate(variables.idx);
		assert(true);
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>