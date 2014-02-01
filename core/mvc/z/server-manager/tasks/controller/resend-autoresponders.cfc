<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	var emailCom=0;
	
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
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