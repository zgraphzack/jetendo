<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Theme Options");
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	init();
	if(not request.zos.istestserver and not request.zos.isdeveloper and not request.zos.isserver){
		application.zcore.functions.z404("only server, test server or developers can view this.");
	}

	</cfscript>
	<h2>Theme Options</h2>
	Coming soon
</cffunction>
</cfoutput>
</cfcomponent>