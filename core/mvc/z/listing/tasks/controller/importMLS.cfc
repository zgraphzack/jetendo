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
	try{
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
	}catch(Any e){
		structdelete(application.zcore, 'importMLSRunning');
		rethrow;	
	}
	structdelete(application.zcore, 'importMLSRunning');
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="abortImport" localmode="modern" access="remote" returntype="any">
	<cfscript>
	
	application.zcore.abortIdxImport=true;
	application.zcore.status.setStatus(request.zsid, "Import cancelled.");
	application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>