<cfcomponent output="no">
	<cffunction name="new" localmode="modern" returntype="any" output="no">
    	<cfargument name="modelName" type="string" required="yes">
    	<cfargument name="mvcPath" type="string" required="no" default="#request.zos.zcorerootmapping#.mvc">
    	<cfscript>
		var local=structnew();
		local.path=arguments.mvcPath&".model."&arguments.modelName;
		/*
		for(local.i in application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache){
			writeoutput(local.i&'<br />');
		}
		application.zcore.functions.zdump(local.path);
		application.zcore.functions.zabort();
		*/
		
		if(structkeyexists(application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache, local.path)){
			local.rs=duplicate(application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]);
		}else{
			local.absPath=request.zos.globals.homedir&replace(arguments.mvcPath&".model."&arguments.modelName,".","/","all")&".cfc";
			if(fileexists(local.absPath)){
				// extended model
				application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]=createobject("component",arguments.mvcPath&".model."&arguments.modelName);
				local.rs=duplicate(application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]);
			}else{
				if(arguments.mvcPath EQ request.zos.zcorerootmapping&".mvc"){
					// generated model
					application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]=createobject("component","zcorecachemapping.model."&arguments.modelName);
					local.rs=duplicate(application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]);
				}else{
					// custom generated model
					application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]=createobject("component",request.zRootSecureCFCPath&"_cache.model."&arguments.modelName);
					local.rs=duplicate(application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]);
				}
			}
		}
		/*
		for(local.i in local.rs){
			if(isstruct(local.rs[local.i])){
				writeoutput(local.i&'<br />');
				local.t=local.rs[local.i];
				local.rs[local.i]=structnew();
				structappend(local.rs[local.i], duplicate(local.t),true);
			}
		}
		*/
		/*
		application.zcore.functions.zdump(local.rs);
		application.zcore.functions.zdump(local.rs.getVariables());
		application.zcore.functions.zabort();
		*/
		
		// return a new copy of the model object
		return local.rs;
		</cfscript>
    </cffunction>
    
</cfcomponent>