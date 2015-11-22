<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
    application.zcore.adminSecurityFilter.requireFeatureAccess("Orders", false);
	</cfscript>
	<h2>Manage Orders</h2>
	<!--- <p>Coming soon</p> --->
</cffunction>
	

</cfoutput>
</cfcomponent>