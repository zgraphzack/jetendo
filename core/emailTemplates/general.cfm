<cfoutput>
<cfsavecontent variable="htmlContent">
<cfif application.zcore.functions.zVarSO("Global Email HTML Header",request.zos.globals.id,true) NEQ "">
#application.zcore.functions.zVarSO("Global Email HTML Header",request.zos.globals.id,true)#
<cfelse>
<div style="padding:10px; padding-bottom:0px;">
<h1 style="font-size:21px; line-height:24px; padding:0px; margin:0px;">Sent from our web site: <a href="#request.zos.globals.domain#/">#request.zos.globals.shortdomain#</a></h1>
</div>
</cfif>
<div style="padding:10px; clear:both; font-size:14px; line-height:21px;">
#request.zTempNewEmailHTML#
</div>
<cfif application.zcore.functions.zVarSO("Global Email HTML Footer",request.zos.globals.id,true) NEQ "">
#application.zcore.functions.zVarSO("Global Email HTML Footer",request.zos.globals.id,true)#
<!--- <cfelse>
<cfif request.zos.globals.emailsignature NEQ ""><p>#replace(request.zos.globals.emailsignature,chr(10),"<br />","all")#</p>
<cfelse>
<p>#application.zcore.functions.zencodeemail(request.officeEmail, true)#</p>
</cfif> --->
</cfif>
</cfsavecontent>
<cfsavecontent variable="textContent">
<cfif application.zcore.functions.zVarSO("Global Email Plain Text Header",request.zos.globals.id,true) NEQ "">
#application.zcore.functions.zVarSO("Global Email Plain Text Header",request.zos.globals.id,true)#
<cfelse>
Sent from our web site: #request.zos.globals.domain#/
</cfif>
-------------------------------

#request.zTempNewEmailPlainText#

<cfif application.zcore.functions.zVarSO("Global Email Plain Text Footer",request.zos.globals.id,true) NEQ "">
#application.zcore.functions.zVarSO("Global Email Plain Text Footer",request.zos.globals.id,true)#
<!--- <cfelse>
<cfif request.zos.globals.emailsignature NEQ "">#request.zos.globals.emailsignature#</p>
<cfelse>
#request.officeEmail#
</cfif>
 ---></cfif>
</cfsavecontent>
</cfoutput>