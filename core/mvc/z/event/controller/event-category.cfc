<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	
	if(not request.zos.istestserver){
		application.zcore.functions.z404("Invalid request");
	}
	</cfscript>
</cffunction>

<cffunction name="viewCategory" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.istestserver){
		echo('<h2>View Event Category is coming soon.</h2>');
		return;
	}
	writedump(form);
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>