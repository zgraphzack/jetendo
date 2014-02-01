<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern">
    <cfscript>
	var ts=structnew();
	ts.content_unique_name="/";
	request.zos.tempObj.contentInstance.configCom.includePageContentByName(ts);
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>