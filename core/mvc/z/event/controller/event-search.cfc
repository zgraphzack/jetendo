<cfcomponent>
<cfoutput> 

<cffunction name="ajaxEventSearch" access="remote" localmode="modern">
	<cfscript>
	rs={};
	savecontent variable="rs.html"{
		writedump(form);
	}
	rs.success=true;
	application.zcore.functions.zReturnJson(rs);
	</cfscript>	

</cffunction>

<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	application.zcore.template.setTag("title", "Event Search");
	application.zcore.template.setTag("pagetitle", "Event Search");

	ts={
		searchCalendars:true,
		searchCategories:true,
		searchKeyword:true
	};
	application.zcore.app.getAppCFC("event").displayEventSearchForm(ts);
 
	</cfscript>
	<div id="zEventSearchResultsDiv"></div>

</cffunction>
</cfoutput>
</cfcomponent>