<cfcomponent>
<cfoutput> 
<cffunction name="calculateEventLength" output="no" returntype="struct">
	<cfargument name="startDate" type="date" required="yes">
	<cfargument name="endDate" type="date" required="yes">
	<cfargument name="newDate" type="date" required="yes">
	<cfscript>
	var local=structnew();
	var rs=structnew();
	
	
	local.rs.minutes=datediff("n", arguments.startDate, arguments.endDate);
	if(local.rs.minutes MOD 1440 EQ 0){
		local.rs.string=dateformat(arguments.newDate, "mmmm d, yyyy");
		local.rs.days=local.rs.minutes/1440;
		if(local.rs.days GT 1){
			local.tempNewDate=dateadd("n",local.rs.minutes,arguments.newDate);
			local.rs.string&=" to "&dateformat(local.tempNewDate, "mmmm d, yyyy");
		}
		local.rs.hours=0;	
		local.rs.minutes=0;
	}else if(local.rs.minutes GTE 1440){
		// 1+ days
		local.tempNewDate=dateadd("n",local.rs.minutes,arguments.newDate);
		local.rs.string=dateformat(arguments.newDate, "mmmm d, yyyy")&" through "&dateformat(local.tempNewDate, "mmmm d, yyyy")&" at "&timeformat(arguments.newDate,"h:mm tt")&" to "&timeformat(local.tempNewDate,"h:mm tt");
		local.rs.days=(local.rs.minutes/1440);	
		local.rs.minutes=(local.rs.minutes-(1440*local.rs.days));
		local.rs.hours=(local.rs.minutes/60);	
		local.rs.minutes=(local.rs.minutes%60);
	}else{
		local.tempNewDate=dateadd("n",local.rs.minutes,arguments.newDate);
		local.rs.days=0;
		local.rs.hours=(local.rs.minutes/60);	
		local.rs.minutes=(local.rs.minutes%60);
		local.rs.string=dateformat(arguments.newDate, "mmmm d, yyyy")&" at "&timeformat(arguments.newDate,"h:mm tt")&" to "&timeformat(local.tempNewDate,"h:mm tt");
	}
	local.rs.date=arguments.newDate;
	return local.rs;
	</cfscript>
</cffunction>

<cffunction name="eventRecur" localmode="modern" access="remote" returntype="string">
	<cfscript>
	var theSQL=0;
	var local=structnew();
	db=request.zos.queryObject;
	local.event_id=application.zcore.functions.zso(form, 'event_id',false,-1);
	local.event_recur_id=application.zcore.functions.zso(form, 'event_recur_id',false,-1);
	</cfscript>
	<cfsavecontent variable="theMeta">
	<meta name="robots" content="noindex,nofollow,noarchive" />
	</cfsavecontent>
	<cfscript>
	request.zos.template.appendTag("meta",theMeta);
	db.sql="SELECT * FROM #db.table("event", request.zos.zcoreDatasource)# event, 
	#db.table("event_recur", request.zos.zcoreDatasource)# event_recur 
	WHERE event_recur.event_id = event.event_id and 
	event_recur_ical_rules<> #db.param('')# and 
	event_recur.site_id = event.site_id and 
	event.event_id=#db.param(local.event_id)# and 
	event_recur.event_recur_id=#db.param(local.event_recur_id)# and 
	event.site_id = #db.param(request.zos.globals.id)# 
	ORDER BY event_recur_datetime ASC limit #db.param(0)#, #db.param(20)#";
	local.qQuery=db.execute("qQuery");
	
	</cfscript>
	<cfloop query="local.qquery">
	<cfscript>
		local.curDateLen=this.calculateEventLength(event_start_datetime,event_end_datetime, event_recur_datetime);
		request.zos.template.settag("pagetitle","Event: "&event_summary);
		request.zos.template.settag("title","Event: "&event_summary);
		</cfscript>
	<h3>
	#local.curDateLen.string#<br />
	<cfif event_summary NEQ "">Event: #event_summary#<br /></cfif>
	<cfif event_description NEQ "">Description: #event_description#<br /></cfif>
	<cfif event_location NEQ "">location: #event_location#<br /></cfif></h3>
	</cfloop>
</cffunction>


<cffunction name="event" localmode="modern" access="remote" returntype="string">
	<cfscript>
	var theSQL=0;
	var local=structnew();
	db=request.zos.queryObject;
	local.event_id=request.zos.functions.zso(form, 'event_id',false,-1);
	</cfscript>
	<cfsavecontent variable="theMeta">
	<meta name="robots" content="noindex,nofollow,noarchive" />
	</cfsavecontent>
	<cfscript>
	request.zos.template.appendTag("meta",theMeta);
	db.sql="SELECT * FROM #db.table("event", request.zos.zcoreDatasource)# event 
	WHERE event.event_id=#db.param(local.event_id)# and 
	event.site_id = #db.param(request.zos.globals.id)#";
	local.qQuery2=db.execute("qQuery2");
	</cfscript>
	<cfloop query="local.qquery2">
		<cfscript>
		local.curDateLen=this.calculateEventLength(event_start_datetime,event_end_datetime, event_start_datetime);
		request.zos.template.settag("pagetitle","Event: "&event_summary);
		request.zos.template.settag("title","Event: "&event_summary);
		</cfscript>
		<h3>#local.curDateLen.string#<br />
		<cfif event_summary NEQ "">Event: #event_summary#<br /></cfif>
		<cfif event_description NEQ "">Description: #event_description#<br /></cfif>
		<cfif event_location NEQ "">location: #event_location#<br /></cfif>
		</h3>
	</cfloop>
</cffunction>

<cffunction name="getNextDay" localmode="modern" access="remote" returntype="string">
	<cfscript>
	var theSQL=0;
	var local=structnew();
	db=request.zos.queryObject;
	db.sql="SELECT min(event_recur_datetime) d FROM #db.table("event", request.zos.zcoreDatasource)# event, 
	#db.table("event_recur", request.zos.zcoreDatasource)# event_recur
	WHERE event_recur.event_id = event.event_id and 
	event_recur.site_id = event.site_id AND 
	event_recur_datetime >= #db.param(dateformat(now(), 'yyyy-mm-dd')&' 00:00:00')# and 
	event.site_id = #db.param(request.zos.globals.id)# ";
	local.qQuery=db.execute("qQuery");
	db.sql="SELECT min(event_start_datetime) d 
	FROM #db.table("event", request.zos.zcoreDatasource)# 
	WHERE event_start_datetime >= #db.param(dateformat(now(), 'yyyy-mm-dd')&' 00:00:00')# and 
	event_recur_ical_rules=#db.param('')# and 
	event.site_id = #db.param(request.zos.globals.id)# ";
	local.qQuery2=db.execute("qQuery2");
	if(local.qQuery.recordcount NEQ 0 and isdate(local.qQuery.d)){
		local.curDate=parsedatetime(local.qQuery.d);
	}
	if(local.qQuery2.recordcount NEQ 0 and isdate(local.qQuery2.d)){
		local.curDate2=parsedatetime(local.qQuery2.d);
	}
	if(structkeyexists(local, 'curDate') and structkeyexists(local, 'curDate2')){
		if(datecompare(local.curDate, local.curDate2) GT 0){
			local.curDate=local.curDate2;
		}
	}else{
		local.curDate=now();
	}
	db.sql="SELECT * FROM #db.table("event", request.zos.zcoreDatasource)# 
	WHERE event_start_datetime >= #db.param(dateformat(local.curDate, 'yyyy-mm-dd')&' 00:00:00')# and 
	event_recur_ical_rules=#db.param('')# and 
	event.site_id = #db.param(request.zos.globals.id)#
	 limit #db.param(0)#, #db.param(25)#";
	local.qQuery2=db.execute("qQuery2");

	local.eventStruct=structnew();
	</cfscript>
	<style type="text/css">
	.cd-1{width:40px;clear:left; line-height:18px; margin-right:5px; float:left;text-align:center; padding:3px; background-color:##8BA5C0; color:##FFF; text-transform:uppercase; border:1px solid ##DDD; border-radius:3px;}
	.cd-2{color:##507295; text-decoration:none;}
	.cd-3{font-size:18px;}
	.cd-4{width:171px; float:left;padding:2px; display:block;border:1px solid ##DDD; background-color:##FFF; margin-bottom:5px; border-radius:3px;}
	.cd-4 a:link, .cd-4 a:visited{text-decoration:none; color:##507295;}
	.cd-4 a:hover{text-decoration:underline;}
	.cd-5{font-weight:bold;text-transform:lowercase;}
	.cd-6{}
	.cd-7{}
	</style>
	<cfloop query="local.qQuery2">
	<cfscript>
		local.curDateLen=this.calculateEventLength(event_start_datetime,event_end_datetime, event_start_datetime);
	local.sTime=timeformat(event_start_datetime,"h:mmtt");
	local.eTime=timeformat(event_end_datetime,"h:mmtt");
	if(local.sTime NEQ local.eTime){
		local.cTime=local.sTime&" to "&local.eTime;	
	}else{
		local.cTime=local.sTime;
	}
		</cfscript>
	<cfsavecontent variable="local.dateHTML">
	<div class="cd-1">
	#dateformat(local.curDateLen.date,'mmm')#<br /><span class="cd-3">#dateformat(local.curDateLen.date,'d')#</span><br />#dateformat(local.curDateLen.date,'ddd')#</a>
	</div>
	</cfsavecontent>
	<cfsavecontent variable="local.theHTML">
	<!--- #local.curDateLen.string#<br />
	<cfif event_summary NEQ "">Event: #event_summary#<br /></cfif>
	<cfif event_description NEQ "">Description: #event_description#<br /></cfif>
	<cfif event_location NEQ "">location: #event_location#<br /></cfif> --->
	<div class="cd-4"><a href="/ical/ical-view.cfc?method=event&amp;event_id=#event_id#" title="#htmleditformat(event_summary&" | "&local.cTime)#"><span class="cd-5">#timeformat(local.curDateLen.date, 'h:mmtt')#</span> #event_summary#</a></div>
	</cfsavecontent>
	<cfscript>
	
	local.eventStruct[event_id]={dateHTML=local.dateHTML,html=local.theHTML, date=event_start_datetime, summary=event_summary&" | "&local.cTime};
	local.dayCount=datediff("d", event_start_datetime, event_end_datetime);
	if(local.dayCount GTE 1){
		for(local.i3=1;local.i3 LTE local.dayCount;local.i3++){
			local.eventStruct[event_id&"~"&local.i3]={ dateHTML=local.dateHTML, html=local.theHTML, date=dateadd("d", local.i3, event_start_datetime), summary=event_summary&" | "&local.cTime};
		}
	}
	</cfscript>
	</cfloop>
	<cfscript>
	db.sql="SELECT * FROM #db.table("event", request.zos.zcoreDatasource)# event, 
	#db.table("event_recur", request.zos.zcoreDatasource)# event_recur 
	WHERE event_recur.event_id = event.event_id and 
	event_recur_ical_rules<> #db.param('')# and 
	event_recur.site_id = event.site_id and 
	event_recur_datetime >= #db.param(dateformat(local.curDate, 'yyyy-mm-dd')&' 00:00:00')# and 
	event.site_id = #db.param(request.zos.globals.id)# 
	ORDER BY event_recur_datetime ASC 
	limit #db.param(0)#, #db.param(25)#";
	local.qQuery=db.execute("qQuery");
	</cfscript>
	<cfloop query="local.qQuery">
	<cfscript>
		local.skipThisDay=false;
		if(event_excluded_date_list NEQ ""){
			local.arrD1=listtoarray(event_excluded_date_list,",");
			for(local.i2=1;local.i2 LTE arraylen(local.arrD1);local.i2++){
				if(dateformat(event_recur_datetime,'yyyymmdd') EQ dateformat(local.arrD1[local.i2],'yyyymmdd')){
					local.skipThisDay=true;	
				}
			}
		}
		</cfscript>
	<cfif local.skipThisDay EQ false>
		<cfscript>
			local.sTime=timeformat(event_start_datetime,"h:mmtt");
			local.eTime=timeformat(event_end_datetime,"h:mmtt");
			if(local.sTime NEQ local.eTime){
				local.cTime=local.sTime&" to "&local.eTime;	
			}else{
				local.cTime=local.sTime;
			}
			local.curDateLen=this.calculateEventLength(event_start_datetime,event_end_datetime, event_recur_datetime);
			</cfscript>
	    <cfsavecontent variable="local.dateHTML">
	    <div class="cd-1">
	    #dateformat(local.curDateLen.date,'mmm')#<br /><span class="cd-3">#dateformat(local.curDateLen.date,'d')#</span><br />#dateformat(local.curDateLen.date,'ddd')#
	    </div>
	    </cfsavecontent>
			<!--- #local.curDateLen.string#<br />
	    <cfif event_summary NEQ "">Event: #event_summary#<br /></cfif>
	    <cfif event_description NEQ "">Description: #event_description#<br /></cfif>
	    <cfif event_location NEQ "">location: #event_location#<br /></cfif> --->
	    
	    <!--- <div style="width:100%; float:left;"> --->
		<cfsavecontent variable="local.theHTML">
		<div class="cd-4"><a href="/ical/ical-view.cfc?method=eventRecur&amp;event_id=#event_id#&amp;event_recur_id=#event_recur_id#" title="#htmleditformat(event_summary&" | "&local.cTime)#"><span class="cd-5">#timeformat(local.curDateLen.date, 'h:mmtt')#</span> #event_summary#</a></div>
	    <!--- </div> --->
	    </cfsavecontent>
	    <cfscript>
	    local.eventStruct[event_id&"_"&event_recur_id]={dateHTML=local.dateHTML,html=local.theHTML, date=event_recur_datetime, summary=event_summary&" | "&local.cTime};
	    </cfscript>
	</cfif>
	</cfloop>
	<cfscript>

	local.arrK=structsort(local.eventStruct, "text", "asc", "date");
	local.curDate=0;
	local.limit=20;
	local.lastDay=0;
	for(local.i=1;local.i LTE arraylen(local.arrK);local.i++){
		local.cdate=dateformat(local.eventStruct[local.arrK[local.i]].date,'yyyymmdd');
		if(local.i GTE local.limit and local.lastDay NEQ local.cdate) break;
		local.lastDay=local.cdate;
		if(local.curDate NEQ local.cdate){
			if(local.i NEQ 1){
				writeoutput('</div>');
			}
			local.curDate=local.cdate;
			writeoutput(local.eventStruct[local.arrK[local.i]].dateHTML&'<div style="width:165px; float:left;">');
		}
		writeoutput(local.eventStruct[local.arrK[local.i]].html);	
	}
	if(arraylen(local.arrK) NEQ 0){
		writeoutput('</div>');
	}
	</cfscript>
</cffunction>


<cffunction name="index" localmode="modern" access="remote" returntype="string">
	<cfscript>
	var viewmonth='';
	var monthdays='';
	var day_of_week='';
	var curDay='';
	var start_day='';
	var prevmonth='';
	var monthspan='';
	var nextmonth='';
	var thisone='';
	var rightnow='';
	var curDate='';
	var storyStruct='';
	var ts='';
	var d='';
	var query='';
	var curDateTemp='';
	var theLink='';
	var qd='';
	var archives='';
	var cal_month=CreateDate(year(NOW()), month(NOW()),1);
	var local=structnew();
	db=request.zos.queryObject;
	//request.zos.template.setTemplate("no-sidebar.cfm",true,true);
	ts=structnew();
	ts.content_unique_name="/connect/";
	request.zos.tempObj.contentInstance.configCom.includePageContentByName(ts); 
	local.curDate=now();
	form.period=application.zcore.functions.zso(form, 'period',false,"month");
	form.offsetday=application.zcore.functions.zso(form, 'offsetday',false,0);
	form.offsetmonth=application.zcore.functions.zso(form, 'offsetmonth',false,0);
	form.offsetweek=application.zcore.functions.zso(form, 'offsetweek',false,0);
	if(not isnumeric(form.offsetmonth) or not isnumeric(form.offsetweek) or not isnumeric(form.offsetday)){
		request.zos.functions.z404("Invalid offset");
	}
	if(form.offsetmonth NEQ 0){
		local.curDate=dateadd("m",form.offsetmonth,local.curDate);
	}
	if(form.offsetday NEQ 0){
		local.curDate=dateadd("d",form.offsetday,local.curDate);
	}
	if(form.period EQ "week"){
		if(form.offsetweek NEQ 0){
			local.curDate=dateadd("d",7*form.offsetweek,local.curDate);
		}
	}
	oneYearAgo=dateadd("yyyy",-1,now());
	oneYearFuture=dateadd("yyyy",1,now());
	if(datecompare(local.curDate, oneYearAgo) LT 0){
		local.curDate=oneYearAgo;
		// should redirect here
		request.zos.functions.z404();
	}
	if(datecompare(local.curDate, oneYearFuture) GT 0){
		local.curDate=oneYearFuture;
		// should redirect here
		request.zos.functions.z404();
	}
	form.period=application.zcore.functions.zso(form, 'period',false,'week');
	if(form.period EQ "week"){
		local.startDate=dateadd("d",-(dayofweek(local.curDate)-1), local.curDate);
		local.futureDate=dateadd("d",6,local.startDate);
	}else if(form.period EQ "day"){
		local.startDate=local.curDate;//request.zos.now;
		local.futureDate=dateadd("d",1,local.curDate);
	}else if(form.period EQ "month"){
		local.startDate=createdate(year(local.curDate),month(local.curDate), 1);
		local.futureDate=dateadd("d",-1,dateadd("m",1,local.startDate));
	}else{
		request.zos.functions.z404("Invalid period");
	}
	local.endDate=local.futureDate;
	</cfscript> 
	<cfsavecontent variable="theMeta">
	<style type="text/css">
	.icalnav a:link, .icalnav a:visited{ padding:5px; display:block; font-size:16px; line-height:21px; float:left; border:1px solid ##EEE; background-color:##FFF; margin-right:5px; color:##666;}
	.icalnav a:hover{background-color:##EEE; color:##000;}
	.zevent-datelink{width:78px;float:left; padding:0px; <!--- background-color:##FFF; border:1px solid ##EEE; ---> margin-bottom:0px; height:17px; overflow:hidden;}
	.zevent-datelink a:link, .zevent-datelink a:visited{text-decoration:none; color:##354e69;}
	.zevent-datelink a:hover{ text-decoration:underline;}
	</style>
	<meta name="robots" content="noindex,nofollow,noarchive" />
	</cfsavecontent>
	<cfscript>
	request.zos.template.appendTag("meta",theMeta);
	</cfscript>
	<div style="width:100%; padding-bottom:15px; float:left;">
	<div class="icalnav" style="width:#request.zos.globals.maximagewidth-200#px; float:left;">
	<cfif form.period EQ "week">
	<a href="#request.cgi_script_name#?method=index&amp;period=#form.period#&amp;offsetweek=#form.offsetweek-1#">&lt; Previous</a> 
	<cfelseif form.period EQ "day">
	<a href="#request.cgi_script_name#?method=index&amp;period=#form.period#&amp;offsetday=#form.offsetday-1#">&lt; Previous</a> 
	<cfelse>
		<cfscript>
	local.nd=dateadd("m",-1,local.curDate);
	local.nd2=dateadd("yyyy",-1,local.curDate);
	</cfscript>
	<cfif datecompare(local.nd2, oneYearAgo) GTE 0>
	<a href="#request.cgi_script_name#?method=index&amp;period=#form.period#&amp;offsetmonth=#form.offsetmonth-12#">&lt; #dateformat(local.nd2,'yyyy')#</a> 
	</cfif>
	<cfif datecompare(local.nd, oneYearAgo) GTE 0>
	<a href="#request.cgi_script_name#?method=index&amp;period=#form.period#&amp;offsetmonth=#form.offsetmonth-1#">&lt; #dateformat(local.nd,'mmmm')#</a> 
	</cfif>
	</cfif>
	<div style="padding:5px;font-size:20px; line-height:24px; float:left;">
	<cfif form.period EQ "day">#dateformat(local.curDate,"mmmm d, yyyy")#
	<cfelseif form.period EQ "week">Week of #dateformat(local.startDate,"mmmm d, yyyy")#
	<cfelseif form.period EQ "month">#dateformat(local.curDate,"mmmm, yyyy")#
	</cfif>
	</div>
	<cfif form.period EQ "week">
	<a href="#request.cgi_script_name#?method=index&amp;period=#form.period#&amp;offsetweek=#form.offsetweek+1#">Next &gt;</a> 
	<cfelseif form.period EQ "day">
	<a href="#request.cgi_script_name#?method=index&amp;period=#form.period#&amp;offsetday=#form.offsetday+1#">Next &gt;</a> 
	<cfelse>
		<cfscript>
	local.nd=dateadd("m",1,local.curDate);
	local.nd2=dateadd("yyyy",1,local.curDate);
	</cfscript>
	<cfif datecompare(local.nd, oneYearFuture) LTE 0>
	<a href="#request.cgi_script_name#?method=index&amp;period=#form.period#&amp;offsetmonth=#form.offsetmonth+1#">#dateformat(local.nd,'mmmm')# &gt;</a> 
	</cfif>
	<cfif datecompare(local.nd2, oneYearFuture) LTE 0>
	<a href="#request.cgi_script_name#?method=index&amp;period=#form.period#&amp;offsetmonth=#form.offsetmonth+12#">#dateformat(local.nd2,'yyyy')# &gt;</a> 
	</cfif>
	</cfif>
	
	</div>
	<div style="width:200px; text-align:right; float:left;">
	<h3><cfif form.period EQ "day">Day<cfelse>
	<a href="#request.cgi_script_name#?method=index&period=day">Day</a>
	</cfif> | 
	<cfif form.period EQ "week">Week<cfelse>
	<a href="#request.cgi_script_name#?method=index&period=week">Week</a>
	</cfif> | 
	<cfif form.period EQ "month">Month<cfelse>
	<a href="#request.cgi_script_name#?method=index&period=month">Month</a>
	</cfif>
	</h3>
	</div></div>
	<hr />
	<cfscript>
	
	db.sql="SELECT * FROM #db.table("event", request.zos.zcoreDatasource)# 
	WHERE event_start_datetime <=#db.param(dateformat(local.endDate, 'yyyy-mm-dd')&' 23:59:59')# AND 
	event_start_datetime >= #db.param(dateformat(local.startDate, 'yyyy-mm-dd')&' 00:00:00')# and 
	event_recur_ical_rules=#db.param('')# and 
	event.site_id = #db.param(request.zos.globals.id)#";
	local.qQuery2=db.execute("qQuery2");
	local.eventStruct=structnew();
	</cfscript>
	<cfloop query="local.qQuery2">
		<cfscript>
		if(event_start_datetime NEQ "0000-00-00 00:00:00" and isdate(event_start_datetime) and isdate(event_end_datetime)){
			local.curDateLen=this.calculateEventLength(startDate=event_start_datetime,endDate=event_end_datetime, newDate=event_start_datetime,recur=false);
		}else{
			local.curDateLen=1;
		}
		</cfscript>
		<cfsavecontent variable="local.theHTML2">
		<cfif isDefined('local.qQuery2.event_start_datetime')> #lcase(timeformat(event_start_datetime,"h:mmtt"))#</cfif> #event_summary#
		</cfsavecontent>
		<cfsavecontent variable="local.theHTML">
		#local.curDateLen.string#<br />
		<cfif event_summary NEQ ""><a href="/ical/ical-view.cfc?method=event&amp;event_id=#event_id#">Event: #event_summary#</a><br /></cfif>
		<cfif event_description NEQ "">Description: #event_description#<br /></cfif>
		<cfif event_location NEQ "">location: #event_location#<br /></cfif>
		</cfsavecontent>
		<cfscript>
		local.sTime=timeformat(event_start_datetime,"h:mmtt");
		local.eTime=timeformat(event_end_datetime,"h:mmtt");
		if(local.sTime NEQ local.eTime){
			local.cTime=local.sTime&" to "&local.eTime;	
		}else{
			local.cTime=local.sTime;
		}
		
		local.eventStruct[event_id]={event_id=event_id,html=local.theHTML,html2=local.theHTML2, date=event_start_datetime, summary=event_summary&" | "&local.cTime};
		local.dayCount=datediff("d", event_start_datetime, event_end_datetime);
		if(local.dayCount GTE 1){
			for(local.i3=1;local.i3 LTE local.dayCount;local.i3++){
				local.eventStruct[event_id&"~"&local.i3]={event_id=event_id, html=local.theHTML, html2=local.theHTML2, date=dateadd("d", local.i3, event_start_datetime), summary=event_summary&" | "&local.cTime};
			}
		}
		</cfscript>
	</cfloop>
	<cfscript>
	db.sql="SELECT * FROM #db.table("event", request.zos.zcoreDatasource)# event, 
	#db.table("event_recur", request.zos.zcoreDatasource)# event_recur 
	WHERE event_recur.event_id = event.event_id and 
	event_recur.site_id = event.site_id and 
	event_recur.event_recur_datetime <=#db.param(dateformat(local.endDate, 'yyyy-mm-dd')&' 23:59:59')# and 
	event_recur_ical_rules<> #db.param('')# AND 
	event_recur_datetime >= #db.param(dateformat(local.startDate, 'yyyy-mm-dd')&' 00:00:00')# and 
	event.site_id = #db.param(request.zos.globals.id)# ";
	local.qQuery=db.execute("qQuery");
	</cfscript>
	<cfloop query="local.qQuery">
	<cfscript>
		local.curDateLen=this.calculateEventLength(event_start_datetime,event_end_datetime, event_recur_datetime);
		local.skipThisDay=false;
		if(event_excluded_date_list NEQ ""){
			local.arrD1=listtoarray(event_excluded_date_list,",");
			for(local.i2=1;local.i2 LTE arraylen(local.arrD1);local.i2++){
				if(dateformat(event_recur_datetime,'yyyymmdd') EQ dateformat(local.arrD1[local.i2],'yyyymmdd')){
					local.skipThisDay=true;	
				}
			}
		}
		</cfscript>
		<cfif local.skipThisDay EQ false>
		<cfsavecontent variable="local.theHTML2">
		#lcase(timeformat(event_recur_datetime,"h:mmtt"))# #event_summary#
		</cfsavecontent>
		<cfsavecontent variable="local.theHTML">
		#local.curDateLen.string#<br />
		<cfif event_summary NEQ ""><a href="/ical/ical-view.cfc?method=eventRecur&amp;event_id=#event_id#&amp;event_recur_id=#event_recur_id#">Event: #event_summary#</a><br /></cfif>
		<cfif event_description NEQ "">Description: #event_description#<br /></cfif>
		<cfif event_location NEQ "">location: #event_location#<br /></cfif>
		</cfsavecontent>
		<cfscript>
		local.sTime=timeformat(event_start_datetime,"h:mmtt");
		local.eTime=timeformat(event_end_datetime,"h:mmtt");
		if(local.sTime NEQ local.eTime){
		local.cTime=local.sTime&" to "&local.eTime;	
		}else{
		local.cTime=local.sTime;
		}
		local.eventStruct[event_id&"_"&event_recur_id]={event_id=event_id,event_recur_id=event_recur_id,html=local.theHTML,html2=local.theHTML2, date=event_recur_datetime,recur=true, summary=event_summary&" | "&local.cTime};
		</cfscript>
		</cfif>
	</cfloop>
	<cfscript>
	storyStruct=structnew();
	
	local.arrK=structsort(local.eventStruct, "text", "asc", "date");
	for(local.i=1;local.i LTE arraylen(local.arrK);local.i++){
		if(local.i NEQ 1){
			//writeoutput('<hr />');
		}
		//writeoutput(local.eventStruct[local.arrK[local.i]].html);	
    ts=structnew();
		ts.struct=local.eventStruct[local.arrK[local.i]];
		if(isDefined('ts.struct.recur') and ts.struct.recur){
			ts.link="/ical/ical-view.cfc?method=eventRecur&amp;event_id=#local.eventStruct[local.arrK[local.i]].event_id#&amp;event_recur_id=#local.eventStruct[local.arrK[local.i]].event_recur_id#";
		}else{
			ts.link="/ical/ical-view.cfc?method=event&amp;event_id=#local.eventStruct[local.arrK[local.i]].event_id#";
		}
		
		/*
		ts.id=blog_id;
		ts.title=blog_title;
		ts.datetime=blog_datetime;
		d=dateformat(blog_datetime, 'yyyy-mm-dd');
		*/
		d=dateformat(local.eventStruct[local.arrK[local.i]].date, 'yyyy-mm-dd');
		if(structkeyexists(storyStruct, d) EQ false){
			storyStruct[d]=arraynew(1);
		}
		arrayappend(storyStruct[d], ts);
	}
	</cfscript>

    <cfset viewmonth = local.startDate>

<cfset monthdays = daysinmonth(viewmonth)>
<cfset day_of_week = 1>
<cfset curDay = 1>
<cfset start_day = dayofweek(createdate(year(viewmonth), month(viewmonth), 1))>
<!--- end of tag assignments --->
    <cfscript>
		if(form.period EQ "month"){
     curDate=dateformat(local.startDate,'yyyy-mm-01 00:00:00');
		}else{
			curDate=local.startDate;
		}
    </cfscript>
<!--- start display of calendar --->
<div  class="zevent-calendar">
    <table class="zevent-calendar-table"> 
    <cfif form.period EQ "day">
    <tr style="vertical-align:top;" class="zevent-calendar-dayheader"><th style="text-align:left;">#dateformat(curDate,'dddd')#</th></tr>
    <cfelseif form.period EQ "week" or form.period EQ "month">
<tr style="vertical-align:top;" class="zevent-calendar-dayheader"><th><!--- Sunday ---><strong>S</strong></th>
<th><!--- Monday ---><strong>M</strong></th>
<th><!--- Tuesday ---><strong>T</strong></th>
<th><!--- Wednesday ---><strong>W</strong></th>
<th><!--- Thursday ---><strong>T</strong></th>
<th><!--- Friday ---><strong>F</strong></th>
<th><!--- Saturday ---><strong>S</strong></th>
    </tr>
    </cfif>
    <cfif form.period EQ "day">
	<cfloop from="0" to="0" index="i">
	<cfscript>
	curDateTemp=dateadd("d",curDay-1,curDate);
	</cfscript><!--- 
	    <cfif curDay lte monthdays> --->
	    <cfset thisone = #dateformat(curDateTemp, "mm-dd-yyyy")#>
	    <cfset rightnow = #dateformat(now(), "mm-dd-yyyy")#><td <cfif thisone NEQ rightnow>class="zevent-calendar-day"<cfelse>class="zevent-calendar-today"</cfif>><cfscript>
		    d=dateformat(curDateTemp, 'yyyy-mm-dd');
						writeoutput('<div class="zevent-calendar-datetext">'&dateformat(curDateTemp,'d')&'</div><div class="zevent-calendar-datebox">');
		    if(structkeyexists(storyStruct, d)){
							if(arraylen(storyStruct[d]) NEQ 0){
								//writeoutput('<ul>');
								for(i3=1;i3 LTE arraylen(storyStruct[d]);i3++){
									//writeoutput('<li><a href="'&storyStruct[d][i3].link&'">'&htmleditformat(storyStruct[d][i3].title)&'</a></li>');
									writeoutput('<div class="zevent-datelink" style=""><a href="'&storyStruct[d][i3].link&'"  title="'&htmleditformat(storyStruct[d][i3].struct.summary)&'">'&storyStruct[d][i3].struct.html2&'</a></div><br />');
								}
								//writeoutput('</ul>');
							}
		    }
						writeoutput('</div>');
		    </cfscript></td><cfset curDay = curDay + 1>
	    <!--- <cfelse>
		<td class="zevent-calendar-noday">&nbsp;</td>
	    </cfif> --->
	</tr></cfloop>
	
	</table>
    <cfelseif form.period EQ "week">
    <tr style="vertical-align:top;">
	<cfloop from="0" to="6" index="i">
	<cfscript>
	curDateTemp=dateadd("d",curDay-1,curDate);
	</cfscript><!--- 
	    <cfif curDay lte monthdays> --->
	    <cfset thisone = #dateformat(curDateTemp, "mm-dd-yyyy")#>
	    <cfset rightnow = #dateformat(now(), "mm-dd-yyyy")#><td <cfif thisone NEQ rightnow>class="zevent-calendar-day"<cfelse>class="zevent-calendar-today"</cfif>><cfscript>
		    d=dateformat(curDateTemp, 'yyyy-mm-dd');
						writeoutput('<div class="zevent-calendar-datetext">'&dateformat(curDateTemp,'d')&'</div><div class="zevent-calendar-datebox">');
		    if(structkeyexists(storyStruct, d)){
							if(arraylen(storyStruct[d]) NEQ 0){
								//writeoutput('<ul>');
								for(i3=1;i3 LTE arraylen(storyStruct[d]);i3++){
									//writeoutput('<li><a href="'&storyStruct[d][i3].link&'">'&htmleditformat(storyStruct[d][i3].title)&'</a></li>');
									writeoutput('<div class="zevent-datelink" style=""><a href="'&storyStruct[d][i3].link&'"  title="'&htmleditformat(storyStruct[d][i3].struct.summary)&'">'&storyStruct[d][i3].struct.html2&'</a></div>');
								}
								//writeoutput('</ul>');
							}
		    }
						writeoutput('</div>');
		    </cfscript></td><cfset curDay = curDay + 1>
	    <!--- <cfelse>
		<td class="zevent-calendar-noday">&nbsp;</td>
	    </cfif> --->
	</cfloop>
	</tr>
	</table>
    <cfelseif form.period EQ "month">
    <cfloop condition="curDay lte monthdays">
    <!--- 1 through end of month ---><tr style="vertical-align:top;">
<cfloop condition="day_of_week lte 7">
	<cfloop condition="start_day neq 1">
	    <td class="zevent-calendar-noday">&nbsp;</td>
	    <cfset start_day = start_day - 1>
	    <cfset day_of_week = day_of_week + 1>
	</cfloop>
	<cfscript>
	curDateTemp=dateadd("d",curDay-1,curDate);
	</cfscript>
	    <cfif curDay lte monthdays>
	    <cfset thisone = #dateformat(curDateTemp, "mm-dd-yyyy")#>
	    <cfset rightnow = #dateformat(now(), "mm-dd-yyyy")#><td <cfif thisone NEQ rightnow>class="zevent-calendar-day"<cfelse>class="zevent-calendar-today"</cfif>><cfscript>
		    d=dateformat(curDateTemp, 'yyyy-mm-dd');
						writeoutput('<div class="zevent-calendar-datetext">'&dateformat(curDateTemp,'d')&'</div><div class="zevent-calendar-datebox">');
		    if(structkeyexists(storyStruct, d)){
							if(arraylen(storyStruct[d]) NEQ 0){
								//writeoutput('<ul>');
								for(i3=1;i3 LTE arraylen(storyStruct[d]);i3++){
									//writeoutput('<li><a href="'&storyStruct[d][i3].link&'">'&htmleditformat(storyStruct[d][i3].title)&'</a></li>');
									writeoutput('<div class="zevent-datelink" style=""><a href="'&storyStruct[d][i3].link&'"  title="'&htmleditformat(storyStruct[d][i3].struct.summary)&'">'&storyStruct[d][i3].struct.html2&'</a></div>');
								}
								//writeoutput('</ul>');
							}
		    }
						writeoutput('</div>');
		    </cfscript></td><cfset curDay = curDay + 1>
	    <cfelse>
		<td class="zevent-calendar-noday">&nbsp;</td>
	    </cfif>
	    <cfset day_of_week = day_of_week + 1>
	</cfloop>
	<cfset day_of_week = 1></tr>
    </cfloop></table>
    </cfif>
    </div>
    
    
</cffunction>
</cfoutput>
</cfcomponent>