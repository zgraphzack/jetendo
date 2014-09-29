<cfcomponent>
<cfproperty name="context" type="zcorerootmapping.com.zos.context">

<cffunction name="__injectDependencies" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	structappend(variables, arguments.ss);
	</cfscript>
</cffunction>
</cfcomponent>