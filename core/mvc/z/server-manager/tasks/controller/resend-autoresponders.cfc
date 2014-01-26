<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	var emailCom=0;
	setting requesttimeout="10000";
	request.znotemplate=1;
	emailCom=CreateObject("component", "zcorerootmapping.com.app.email");
	application.zcore.functions.zSendMailUserAutoresponder();
	application.zcore.functions.zSendUserAutoresponder();
	</cfscript>
	done
</cffunction>
</cfoutput>
</cfcomponent>