<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
<cfsetting requesttimeout="5000">
<cfscript>
var myloops=0;
var idxCom=0;
var r=0;
request.ignoreslowscript=true;
application.zcore.importMLSRunning=true;
myloops=40;
while(myloops GT 0){
	myloops--;
	idxCom=createobject("component","zcorerootmapping.mvc.z.listing.controller.idx");
	r=idxCom.init();
	if(r EQ false){
		idxCom.process();
		writeoutput('<br /><br />');
	}else{
		break;
	}
}
structdelete(application.zcore, 'importMLSRunning');
application.zcore.functions.zabort();
</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>