<cfcomponent displayname="Input/Output System" hint="This is used to isolate the variables scope of a page include.  The variables expire when the object is destroyed." output="no">
<cfoutput>	<cffunction name="__include" localmode="modern" output="false" returntype="string">
		<cfargument name="__path" type="string" required="yes">
		<cfargument name="__rethrow" type="boolean" required="no" default="#false#">
		<cfargument name="copyStruct" type="struct" required="no" default="#StructNew()#">
		<cfscript>
		var __content = ""; 
		var __i="";
		StructAppend(variables, arguments.copyStruct,true);
		</cfscript> 
		<cftry>
			<cfsavecontent variable="__content">
			<cfinclude template="#arguments.__path#">
			</cfsavecontent>
			<cfcatch type="any">
				<cfif isDefined('Request.zOS.throwError') or arguments.__rethrow>
					<cfrethrow>
				</cfif>
				<cfset Request.zOS.throwError = true>
				<cfreturn false>
			</cfcatch>
		</cftry>
		<cfif isDefined('request.zsession.modes.debug') and isDefined('request.zOS.introspection') EQ false>
			<cfscript>
			if(isDefined('Request.zOS.currentScript.variables') EQ false){
				Request.zOS.currentScript.variables = StructNew();
			}
			for(__i in variables){
				if(__i NEQ 'copyStruct' and isObject(variables[__i]) EQ false and isCustomFunction(variables[__i]) EQ false and __i NEQ "this" and __i NEQ "__content" and __i NEQ "arguments" and __i NEQ '__zTemplate' and __i NEQ '__path' and __i NEQ '__rethrow' and __i NEQ '__reset' and __i NEQ '__i' and __i NEQ '__include'){
					StructInsert(Request.zOS.currentScript.variables, __i, variables[__i],true);
				}
			}
			</cfscript>
		</cfif>
		<cfreturn trim(__content)>
	</cffunction>
    </cfoutput>
</cfcomponent>