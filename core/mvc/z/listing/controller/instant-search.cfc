<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
<cfscript>
application.zcore.template.setTag("title", "Listing Search");
application.zcore.template.setTag("pagetitle", "Listing Search");
</cfscript>
<cfif isDefined('session.zos.tempVars.zListingSearchId') EQ false>
<input type="hidden" name="zListingSearchJsURLHidden" id="zListingSearchJsURLHidden" value="/z/listing/search-js/index?forceForm=1" />
</cfif>
</cffunction>
</cfoutput> 
</cfcomponent>