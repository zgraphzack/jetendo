<cfcomponent>
<cfoutput>
<cffunction name="onSiteRequestStart" output="no" returntype="any" localmode="modern">
	<cfargument name="variablesScope" type="struct" required="yes">
	<cfscript>
	var ts=structnew();
    application.zcore.template.setTemplate("root.templates.default"); 
    request.zos.functions.zEnableNewMetaTags();
	ts.arrIgnoreURLs=arraynew(1);
	arrayappend(ts.arrIgnoreURLs,"/");
	//ts.arrIgnoreURLContains=arraynew(1);
	request.zos.functions.zEnableContentTransition(ts);
	</cfscript>	
</cffunction>

<cffunction name="onSiteRequestEnd" output="no" returntype="any" localmode="modern">
	<cfargument name="variablesScope" type="struct" required="yes">
	<cfscript>
	</cfscript>
</cffunction>

<cffunction name="getSiteMap" output="no" returntype="array" localmode="modern">
	<cfargument name="arrURL" type="array" required="yes">
    <cfscript>
	return arguments.arrUrl;
	</cfscript>
</cffunction>

<cffunction name="processURL" output="no" returntype="struct" localmode="modern">
	<cfargument name="theURL" type="string" required="yes">
	<cfargument name="topRules" type="boolean" required="no" default="#false#">
	<cfscript>
	var local=structnew();
	var rs=structnew();
	rs.scriptName="";
	if(arguments.topRules EQ false){
		
	}
	return rs;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>