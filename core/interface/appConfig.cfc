<cfinterface displayname="appConfig" hint="This interface sets up the minimum requirements for making an application that is integrated with the applications system.">
 
    <!--- <cffunction name="registerHooks" localmode="modern" output="no" access="public" returntype="array">
    </cffunction> --->
    
    <cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="add links to sitemap array">
    	<cfargument name="arrUrl" type="array" required="yes">
    </cffunction>
    <cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
    	<cfargument name="linkStruct" type="struct" required="yes">
    </cffunction>
    <cffunction name="getCacheStruct" localmode="modern" output="no" access="public" returntype="struct" hint="publish the application cache">
    	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
    </cffunction>
    
	<cffunction name="onSiteStart" localmode="modern" output="no"  returntype="struct" hint="Runs on application start and should return arguments.sharedStruct">
    	<cfargument name="sharedStruct" type="struct" required="yes" hint="Exclusive application scope structure for this application.">
	</cffunction>
	<cffunction name="onRequestEnd" localmode="modern" output="yes"  returntype="void" hint="Runs after zos end file."> </cffunction>
	<cffunction name="onRequestStart" localmode="modern" output="yes"  returntype="void" hint="Runs before zos begin file."> </cffunction>
         
    <cffunction name="getCSSJSIncludes" localmode="modern" output="no" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    </cffunction>
    
	<cffunction name="configSave" localmode="modern" output="no"  returntype="any" hint="saves the application data submitted by the configForm() function."> </cffunction>
	<cffunction name="configForm" localmode="modern" output="no"  returntype="any" hint="displays a form to add/edit application instance options."> </cffunction>
	<cffunction name="configDelete" localmode="modern" output="no"  returntype="any" hint="delete the record from test table."> </cffunction>
    
    
</cfinterface>