<cfcomponent>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript> 
	var i=0;
	var qD=0;
	var path=0;
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developers and server ips can access this url.");
	}
	if(request.zos.isDeveloper){
		form.forceMetaDataRebuild=true;  
	}
	for(i in application.zcore.listingStruct.mlsStruct){ 
		local.object=application.zcore.functions.zcreateobject("component",application.zcore.listingStruct.mlsStruct[i].mlsComPath);
		local.object.mls_id=i; 
		if(request.zos.isServer){
			path="#request.zos.sharedPath#mls-data/#i#/";
			directory directory="#path#" filter="metadata*.xml" name="qD" sort="dateLastModified DESC";
			if(qD.recordcount NEQ 0){ 
				application.zcore.listingStruct.mlsStruct[i].sharedStruct.metadataDateLastModified=qD.dateLastModified[1];	
			}
		}
		local.object.init(application.zcore.listingStruct.mlsStruct[i].sharedStruct); 
	}
	echo('Done.');
	abort;
	</cfscript>
</cffunction>
</cfcomponent>