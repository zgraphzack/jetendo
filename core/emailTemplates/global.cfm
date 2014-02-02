<cfoutput>
<cfsavecontent variable="htmlContent">
<div style="padding:10px;">
#application.zcore.functions.zVarSO("Autoresponder html")#
</div>
</cfsavecontent>
<cfsavecontent variable="textContent">
#application.zcore.functions.zVarSO("Autoresponder Plain Text")#
</cfsavecontent>

<cfif trim(htmlContent) EQ "">
<cfsavecontent variable="htmlContent">
<table style="width: 600px; line-height: 14px; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px;" border="0" cellspacing="0" cellpadding="10">
<tbody>
<tr>
<td><span style="font-size: 18px; line-height: 24px;">Thank you for using our website.</span>
<p>Thank you for joining our newsletter.</p>
</td>
</tr>
</tbody>
</table>
</cfsavecontent>
</cfif>
<cfif trim(textContent) EQ "">
<cfsavecontent variable="textContent">
Thank you for using our website. 
Thank you for joining our newsletter. 
</cfsavecontent>
</cfif>
</cfoutput>