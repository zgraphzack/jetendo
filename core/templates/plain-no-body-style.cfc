<cfcomponent implements="zcorerootmapping.interface.view">
<cfoutput>
<cffunction name="init" access="public" returntype="string" localmode="modern">
	<cfscript> 
	</cfscript>
</cffunction>
<cffunction name="render" access="public" returntype="string" localmode="modern">
	<cfargument name="tagStruct" type="struct" required="yes">
	<cfscript>
	var tagStruct=arguments.tagStruct; 
	</cfscript>
	<cfsavecontent variable="output">
	<cfscript>
	request.znotemplate=1;
	if(not request.zos.istestserver){
		application.zcore.functions.zheader("X-UA-Compatible", "IE=edge,chrome=1");
	}
	</cfscript>#application.zcore.functions.zHTMLDoctype()#
	<head>
	    <meta charset="utf-8" />
	    <title>#tagStruct.title ?: ""#</title> 
		#tagStruct.stylesheets ?: ""#
		#tagStruct.meta ?: ""# 
	</head>
	<body>
	<!--- #tagStruct.topcontent ?: ""# --->
	<cfif application.zcore.template.getTagContent("pagetitle") NEQ "">
		<h1>#tagStruct.pagetitle ?: ""#</h1>
	</cfif>
	<div style="float:none;">
	#tagStruct.content ?: ""#
	#tagStruct.scripts ?: ""#</div>
	#application.zcore.functions.zvarso('Visitor Tracking Code')#
	</body>
	</html>
	</cfsavecontent>
	<cfreturn output>
</cffunction>
</cfoutput>
</cfcomponent>