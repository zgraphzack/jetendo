<cfcomponent>
	<cffunction name="getRequest" localmode="modern" access="private" hint="This function allows for lazy initialization of request scope.">
		<cfscript>
		if(structkeyexists(request, variables.moduleName) EQ false){
			request[variables.moduleName]=createobject("component", "__data");
		}
		return request.user;
		</cfscript>
	</cffunction>
	
	<cffunction name="getSession" localmode="modern" access="private" hint="This function allows for lazy initialization of session scope.">
		<cfscript>
		if(structkeyexists(session, variables.moduleName) EQ false){
			session[variables.moduleName]=createobject("component", "__data");
		}
		return session[variables.moduleName];
		</cfscript>
	</cffunction>
	
	<!--- implement other scopes... --->
	
</cfcomponent>