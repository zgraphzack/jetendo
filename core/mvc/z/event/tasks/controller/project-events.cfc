<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	db=request.zos.queryObject;
	
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	request.ignoreSlowScript=true;
	setting requesttimeout="5000";

	request.ical=createobject("component", "zcorerootmapping.com.ical.ical");
	request.ical.init("");

	offset=0;
	while(true){
		db.sql="select * from #db.table("event", request.zos.zcoreDatasource)#, 
		#db.table("event_config", request.zos.zcoredatasource)#
		WHERE 
		event.site_id = event_config.site_id and 
		event_config_deleted=#db.param(0)# and 
		event.site_id = #db.param(request.zos.globals.id)# and 
		event_recur_ical_rules<> #db.param('')# and 
		(event_recur_count = #db.param(0)# or 
		event_recur_until_datetime >=#db.param(dateformat(now(), "yyyy-mm-dd")&" 00:00:00")#) and 
		event_deleted=#db.param(0)# 
		LIMIT #db.param(offset)#, #db.param(30)#";
		qEvent=db.execute("qEvent");
		if(qEvent.recordcount EQ 0){
			break;
		}

		for(row in qEvent){
			projectDays=row.event_config_project_recurrence_days;
			if(not isnumeric(projectDays)){
				projectDays=0;
			}
			arrDate=request.ical.getRecurringDates(row.event_start_datetime, row.event_recur_ical_rules, row.event_excluded_date_list, projectDays);

			minutes=datediff("n", row.event_start_datetime, row.event_end_datetime);

			db.sql="delete from #db.table("event_recur", request.zos.zcoreDatasource)# WHERE 
			event_recur_deleted=#db.param(0)# and 
			site_id=#db.param(row.site_id)# and 
			event_id=#db.param(row.event_id)# ";
			qDelete=db.execute("qDelete");
			for(i=1;i LTE arraylen(arrDate);i++){
				startDate=arrDate[i];
				endDate=dateadd("n", minutes, startDate);
				ts={
					table:"event_recur",
					datasource:request.zos.zcoreDatasource,
					struct:{
						event_id:row.event_id,
						site_id:row.site_id,
						event_recur_datetime:dateformat(startDate, "yyyy-mm-dd")&" "&timeformat(startDate, "HH:mm:ss"),
						event_recur_start_datetime:dateformat(startDate, "yyyy-mm-dd")&" "&timeformat(startDate, "HH:mm:ss"),
						event_recur_end_datetime:dateformat(endDate, "yyyy-mm-dd")&" "&timeformat(endDate, "HH:mm:ss"),
						event_recur_updated_datetime:dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'),
						event_recur_deleted:0
					}
				}
				application.zcore.functions.zInsert(ts);
			}
		}
		offset+=30;
	}
	echo('All event projections updated.');
	abort;
	</cfscript>
</cffunction>	
</cfoutput>
</cfcomponent>
