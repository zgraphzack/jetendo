<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern">
    <!--- <cfscript>
    request.noSidebar=true;
	var ts=structnew();
	ts.content_unique_name="/suggest-an-event/index";
	application.zcore.app.getAppCFC("content").includePageContentByName(ts);
	</cfscript>
	<div class="sh-33" >
		<cfscript>
	
		application.zcore.functions.zheader("x_ajax_id", application.zcore.functions.zso(form, 'x_ajax_id'));
		form.site_option_group_id=application.zcore.functions.zGetSiteOptionGroupIDWithNameArray(["Event"]);
		displayGroupCom=createobject("component", "zcorerootmapping.mvc.z.misc.controller.display-site-option-group");
		displayGroupCom.add();

		application.zcore.template.setTag("pagetitle", "Suggest An Event");
		application.zcore.template.setTag("title", "Suggest An Event");
		</cfscript>
	</div>
	<div class="sh-32" >
		<img src="/images/shell/suggest_03.jpg" alt="Suggest an Event" />
	</div> --->
 
</cffunction>
</cfoutput>
</cfcomponent>