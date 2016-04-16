<cfcomponent> 
<cfoutput>
<cffunction name="loadIndex" localmode="modern" access="public" output="no">
	<cfscript>
	// some widgets should only be enabled on a site that has certain features enabled, like listing, ecommerce, rentals, etc.
	ts={
		"1":"zcorerootmapping.mvc.z.widget.controller.widget-example"
	}
	if(structkeyexists(application, 'widgetIndexStruct')){
		structappend(ts, application.widgetIndexStruct, true);
	}
	application.zcore.widgetIndexStruct=ts;
	return ts;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>