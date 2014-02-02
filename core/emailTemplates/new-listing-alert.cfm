<cfoutput>
<cfif isDefined('request.zTempNewEmailListingAlertHTML') EQ false>
	<cfset action ="show">
    <cfinclude template="/zcorerootmapping/a/listing/util/sendListingAlerts.cfm">
</cfif>
<cfsavecontent variable="htmlContent">
<cfif application.zcore.functions.zVarSO("Global Email HTML Header",request.zos.globals.id,true) NEQ "">
#application.zcore.functions.zVarSO("Global Email HTML Header",request.zos.globals.id,true)#
<cfelse>
<div style="padding:10px; padding-bottom:0px;">
<h1 style="font-size:24px; line-height:30px; padding:0px; margin:0px;"><a href="#request.zos.globals.domain#/">#request.zos.globals.shortdomain#</a></h1>
</div>
</cfif>
<div style="padding:10px; clear:both; font-size:14px; line-height:21px;">
<cfif application.zcore.functions.zVarSO("New listing email alert html",request.zos.globals.id,true) NEQ "">
#application.zcore.functions.zVarSO("New listing email alert html",request.zos.globals.id,true)#
<cfelse>
#request.zTempNewEmailListingAlertHTML#
</cfif>
#request.zTempNewEmailListingAlertHTMLFooter#
</div>
<cfif application.zcore.functions.zVarSO("Global Email HTML Footer",request.zos.globals.id,true) NEQ "">
#application.zcore.functions.zVarSO("Global Email HTML Footer",request.zos.globals.id,true)#
<cfelse>
</cfif>
</cfsavecontent>
<cfsavecontent variable="textContent">
<cfif application.zcore.functions.zVarSO("Global Email Plain Text Header",request.zos.globals.id,true) NEQ "">
#application.zcore.functions.zVarSO("Global Email Plain Text Header",request.zos.globals.id,true)#
<cfelse>
#request.zos.globals.domain#/
</cfif>
<cfif application.zcore.functions.zVarSO("New listing email alert plain text",request.zos.globals.id,true) NEQ "">#trim(application.zcore.functions.zVarSO("New listing email alert plain Text",request.zos.globals.id,true))#
<cfelse>#trim(request.zTempNewEmailListingAlertPlainText)#
</cfif>
#trim(request.zTempNewEmailListingAlertPlainTextFooter)#


<cfif application.zcore.functions.zVarSO("Global Email Plain Text Footer",request.zos.globals.id,true) NEQ "">
#application.zcore.functions.zVarSO("Global Email Plain Text Footer",request.zos.globals.id,true)#
</cfif>
</cfsavecontent>
</cfoutput>