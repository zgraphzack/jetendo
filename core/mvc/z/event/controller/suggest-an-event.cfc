<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	if(application.zcore.functions.zso(application.zcore.app.getAppData("event").optionStruct, 'event_config_enable_suggest_event', true) EQ 0){
		application.zcore.functions.z404("event_config_enable_suggest_event is not enabled for this site in server manager.");
	}
</cfscript>
</cffunction>


<cffunction name="complete" access="remote" localmode="modern">
	<cfscript>
	init();
	application.zcore.template.setTag("title", "Event Submitted Successfully");
	application.zcore.template.setTag("pagetitle", "Event Submitted Successfully");

	</cfscript>
	<p>Thank you for submitting an event.</p>
	<p>Your submission will be reviewed by someone on our team.</p>
	<p>Once your event is approved, it will be displayed on our public calendar.</p>
</cffunction>

<cffunction name="submit" access="remote" localmode="modern">
	<cfscript>
	init();
	manageCom=createobject("component", "zcorerootmapping.mvc.z.event.admin.controller.manage-events");
	form.method="publicInsertEvent";
	manageCom.publicInsertEvent();
	</cfscript>
</cffunction>

<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	init();
	application.zcore.template.setTag("title", "Suggest An Event");
	application.zcore.template.setTag("pagetitle", "Suggest An Event");
	manageCom=createobject("component", "zcorerootmapping.mvc.z.event.admin.controller.manage-events");
	form.method="publicAddEvent";
	manageCom.publicAddEvent();


	</cfscript>
 
</cffunction>
</cfoutput>
</cfcomponent>