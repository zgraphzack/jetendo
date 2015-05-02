<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	
</cffunction>

<cffunction name="view" localmode="modern" access="remote">
	<cfscript>
	writedump(form);
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>