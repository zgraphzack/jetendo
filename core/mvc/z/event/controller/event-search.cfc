<cfcomponent>
<cfoutput> 

<cffunction name="ajaxEventSearch" access="remote" localmode="modern">
	<cfscript> 
	form.startdate=application.zcore.functions.zso(form, 'startdate');
	form.enddate=application.zcore.functions.zso(form, 'enddate');
	form.calendarids=application.zcore.functions.zso(form, 'calendarids');
	form.categories=application.zcore.functions.zso(form, 'categories');
	form.keyword=application.zcore.functions.zso(form, 'keyword');

	ts={
		categories:form.categories,
		keyword:form.keyword,
		onlyFutureEvents:1,
		startDate:form.startdate,
		endDate:form.enddate,
		calendarids:form.calendarids,
	 	offset=min(application.zcore.functions.zso(form, 'offset', true, 0), 1000),
 		perpage=min(application.zcore.functions.zso(form, 'perpage', true, 15),50)
	};
	if(ts.startDate NEQ ""){
		ts.onlyFutureEvents=false;
	}

 	eventCom=application.zcore.app.getAppCFC("event");
 	rs=eventCom.searchEvents(ts); 
 	rs.offset=ts.offset;
 	rs.perpage=ts.perpage;
 	rs.link="/z/event/event-search/ajaxEventSearch?startdate=#urlencodedformat(form.startdate)#&enddate=#urlencodedformat(form.enddate)#&calendarids=#urlencodedformat(form.calendarids)#&categories=#urlencodedformat(form.categories)#&keyword=#urlencodedformat(form.keyword)#";
	calendarCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.event.controller.event-calendar");
	calendarCom.returnListViewCalendarJson(rs);
	</cfscript>	

</cffunction>

<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	request.zos.currentURLISAnEventPage=true;
	application.zcore.template.setTag("title", "Event Search");
	application.zcore.template.setTag("pagetitle", "Event Search");
	</cfscript>

	<cfscript>
	
	ts={
		searchCalendars:true,
		searchCategories:true,
		searchKeyword:true
	};
	application.zcore.app.getAppCFC("event").displayEventSearchForm(ts);
 
	</cfscript> 
	<div id="zEventSearchResults">
	<div id="zCalendarTab_List"></div>
	</div>

</cffunction>
</cfoutput>
</cfcomponent>