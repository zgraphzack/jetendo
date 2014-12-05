<cfcomponent>
<cfoutput>
<cffunction name="thank-you" localmode="modern" access="remote">
	<cfscript>
	title="Thank you for your payment.";
	application.zcore.template.setTag("title", title);
	application.zcore.template.setTag("pagetitle", title);
	</cfscript>
	<p>You can continue to browse our web site or close this window.</p>
</cffunction>
	
<cffunction name="ipn" localmode="modern" access="remote">
	<cfscript>
	paypalIpnCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.ecommerce.paypal");
	paypalIpnCom.processIPN(form);
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>