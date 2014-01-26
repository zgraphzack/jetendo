<cfcomponent output="yes">
	<cfoutput>
	<cffunction name="index" access="remote" returntype="string" output="yes">
	    <cfscript>
		var ts=structnew();
		ts.content_unique_name="/";
		request.zos.tempObj.contentInstance.configCom.includePageContentByName(ts);
		</cfscript>
		test 
	</cffunction>
    </cfoutput>
</cfcomponent>