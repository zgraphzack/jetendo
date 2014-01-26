<cfcomponent>
<cfoutput>
	<cffunction name="getfunctionmeta" localmode="modern" returntype="any">
		<cfargument name="filepath" type="string" required="yes">
        <cfinclude template="#arguments.filepath#">
        <cfscript>
		funcstruct=structnew();
		for(i in variables){
			if(i neq 'getfunctionmeta' and iscustomfunction(variables[i])){
				funcstruct[i]=getmetadata(variables[i]);
			}
		}
		</cfscript>
		<cfreturn funcstruct>
	</cffunction>
    </cfoutput>
</cfcomponent>