<cfcomponent>
	<cfoutput><cffunction name="init" localmode="modern" output="no" returntype="object-cache">
    	<!--- <cfargument name="serverScopeManager" type="zcorerootmapping.com.shared-resource.scope" required="yes"> --->
    	<cfscript>
		var local=structnew();
		//variables.serverScopeManager=arguments.serverScopeManager;
		local.n="zcore-object-cache";
		/*if(variables.serverScopeManager.exists(local.n) EQ false){
			variables.serverScopeManager.write(local.n, structnew());
		}*/
		return this;
		</cfscript>
    </cffunction>
	<cffunction name="getObject" localmode="modern" access="public" returntype="string">
		<cfargument name="pluginName" type="string" required="yes">
		<cfargument name="objectName" type="string" required="yes">
		<cfscript>
		</cfscript>
	</cffunction>
	<cffunction name="storeObject" localmode="modern" access="public" returntype="string">
		<cfargument name="pluginName" type="string" required="yes">
		<cfargument name="objectName" type="string" required="yes">
		<cfargument name="object" type="any" required="yes">
		<cfscript>
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>