<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	
</cffunction>

<cffunction name="view" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	
	writedump(form);
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>