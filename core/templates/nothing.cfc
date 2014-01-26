<cfcomponent implements="zcorerootmapping.interface.view">
<cfoutput>
<cffunction name="init" access="public" returntype="string" localmode="modern">
</cffunction>
<cffunction name="render" access="public" returntype="string" localmode="modern">
	<cfargument name="tagStruct" type="struct" required="yes">
	<cfscript>
	var tagStruct=arguments.tagStruct;
	</cfscript>
	<cfsavecontent variable="output">#tagStruct.content ?: ""#</cfsavecontent>
	<cfreturn output>
</cffunction>
</cfoutput>
</cfcomponent>