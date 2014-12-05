<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
	<cfsetting requesttimeout="5000">
	<cfscript>
	var myloops=0;
	var idxCom=0;
	var r=0;
	request.ignoreslowscript=true;
	myloops=46;
	if(structkeyexists(application.zcore, 'importMLSRunning')){
		if(not structkeyexists(form, 'zforce')){
			echo('importMLS is already running | <a href="/z/listing/tasks/importMLS/index?zforce=1">Force execution</a>');
			application.zcore.functions.zabort();
		}
	}
	application.zcore.importMLSRunning=true;
	try{
		while(myloops GT 0){
			myloops--;
			idxCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.idx");
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