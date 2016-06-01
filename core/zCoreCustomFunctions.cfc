<cfcomponent output="no">
<cfoutput>
<cffunction name="onSiteRequestStart" localmode="modern" output="no" returntype="any">
	<cfscript>
	application.zcore.functions.zEnableNewMetaTags(); 
	
	application.zcore.template.setTemplate("root.templates.default",true,true);
	</cfscript>
</cffunction>


<cffunction name="onSiteRequestEnd" localmode="modern" output="no" returntype="any">
	<cfscript>
    </cfscript>
</cffunction>

</cfoutput>
</cfcomponent>