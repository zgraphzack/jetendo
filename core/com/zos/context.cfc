<cfcomponent>
<cfoutput>
<!--- <cffunction name="init" localmode="modern" access="private">
	
</cffunction> --->
	
<cffunction name="getSession" localmode="modern" access="public">
	<cfscript>
	return request.zsession;
	</cfscript>
</cffunction>

<cffunction name="getRequest" localmode="modern" access="public">
	<cfscript>
	return request;
	</cfscript>
</cffunction>

<cffunction name="getApplication" localmode="modern" access="public">
	<cfscript>
	return application;
	</cfscript>
</cffunction>

<cffunction name="getCookie" localmode="modern" access="public">
	<cfscript>
	return cookie;
	</cfscript>
</cffunction>


<cffunction name="getServer" localmode="modern" access="public">
	<cfscript>
	return server;
	</cfscript>
</cffunction>

<cffunction name="getForm" localmode="modern" access="public">
	<cfscript>
	return form;
	</cfscript>
</cffunction>
	
<cffunction name="getCGI" localmode="modern" access="public">
	<cfscript>
	return request.zos.cgi;
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>