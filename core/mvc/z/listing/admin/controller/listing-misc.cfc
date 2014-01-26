<cfcomponent>
	<cffunction name="index" localmode="modern" access="remote">
		<cfscript>
		var absPath=request.zos.globals.serverHomeDir&"mvc/z/listing/mls-provider/"&form.mlsName&"data.cfc";
		if(not fileexists(absPath)){
			application.zcore.functions.z404("doesn't exist.");
		}
		var d=createobject("component", "zcorerootmapping.mvc.z.listing.mls-provider."&form.mlsName&"data");
		d.findFieldsInDatabaseNotBeingOutput();
		</cfscript>
	</cffunction>
</cfcomponent> 