<cfcomponent displayName="iCal" hint="A iCal processor." output="false">
<cfoutput>

<cffunction name="init" localmode="modern" returnType="ical" access="public" output="false"
			hint="Init function for the CFC. Loads in the initial string data.">
	<cfargument name="data" type="string" required="true">
	<cfscript>
	variables.data = "";
	 this.dayStruct={
		"SU":"Sunday",
		"MO":"Monday",
		"TU":"Tuesday",
		"WE":"Wednesday",
		"TH":"Thursday",
		"FR":"Friday",
		"SA":"Saturday"
	 };
	 this.dayStructIndex={
		"SU":1,
		"MO":2,
		"TU":3,
		"WE":4,
		"TH":5,
		"FR":6,
		"SA":7
	 };
	variables.data = arguments.data;
	return this;
	</cfscript>
</cffunction>

<cffunction name="parseDay" localmode="modern" access="public" returntype="any">
<cfargument name="d" type="string" required="yes">
<cfscript>
	arrD=listtoarray(arguments.d,",");
	for(n=1;n LTE arraylen(arrD);n++){
		match=false; 
		arrD[n]=trim(arrD[n]);

		ts={};
		d=right(arrD[n], 2);
		if(structkeyexists(this.dayStruct, d)){
			ts.day=this.dayStruct[d];
			ts.dayIndex=this.dayStructIndex[d];
		}else{
			throw("Invalid day value: "&arrD[n]);
		}
		ts.num=0;
		if(len(arrD[n])-2 GT 0){
			d2=removeChars(arrD[n], len(arrD[n])-1, 2);
			if(left(d2, 1) EQ "+"){
				ts.fromStart=true;
				ts.num=removeChars(d2, 1,1);
				if(not isnumeric(ts.num)){
					ts.num=0;
				}
			}else if(left(d2, 1) EQ "-"){
				ts.fromEnd=false;
				ts.num=removeChars(d2, 1,1);
				if(not isnumeric(ts.num)){
					ts.num=0;
				}
			}
		}
		arrD[n]=ts;
	}
	return arrD;
	</cfscript>
</cffunction>

<cffunction
    name="GetNthDayOfMonth"
    access="public"
    returntype="any"
    output="false"
    hint="I return the Nth instance of the given day of the week for the given month (ex. 2nd Sunday of the month).">
 
    <!--- Define arguments. --->
    <cfargument
        name="Month"
        type="date"
        required="true"
        hint="I am the month for which we are gathering date information."
        />
 
    <cfargument
        name="DayOfWeek"
        type="numeric"
        required="true"
        hint="I am the day of the week (1-7) that we are locating."
        />
 
    <cfargument
        name="Nth"
        type="numeric"
        required="false"
        default="1"
        hint="I am the Nth instance of the given day of the week for the given month."
        />
 
    <!--- Define the local scope. --->
    <cfset var LOCAL = {} />
 
    <!---
        First, we need to make sure that the date we were given
        was actually the first of the month.
    --->
    <cfset ARGUMENTS.Month = CreateDate(
        Year( ARGUMENTS.Month ),
        Month( ARGUMENTS.Month ),
        1
        ) />
 
 
    <!---
        Now that we have the correct start date of the month, we
        need to find the first instance of the given day of the
        week.
    --->
    <cfif (DayOfWeek( ARGUMENTS.Month ) LTE ARGUMENTS.DayOfWeek)>
 
        <!---
            The first of the month falls on or before the first
            instance of our target day of the week. This means we
            won't have to leave the current week to hit the first
            instance.
        --->
        <cfset LOCAL.Date = (
            ARGUMENTS.Month +
            (ARGUMENTS.DayOfWeek - DayOfWeek( ARGUMENTS.Month ))
            ) />
 
    <cfelse>
 
        <!---
            The first of the month falls after the first instance
            of our target day of the week. This means we will
            have to move to the next week to hit the first target
            instance.
        --->
        <cfset LOCAL.Date = (
            ARGUMENTS.Month +
            (7 - DayOfWeek( ARGUMENTS.Month )) +
            ARGUMENTS.DayOfWeek
            ) />
 
    </cfif>
 
 
    <!---
        At this point, our Date is the first occurrence of our
        target day of the week. Now, we have to navigate to the
        target occurence.
    --->
    <cfset LOCAL.Date += (7 * (ARGUMENTS.Nth - 1)) />
 
    <!---
        Return the given date. There is a chance that this date
        will be in the NEXT month of someone put in an Nth value
        that was too large for the current month to handle.
    --->
    <cfreturn DateFormat( LOCAL.Date ) />
</cffunction>

<cffunction name="lastDayOfWeekOfMonth" localmode="modern" access="public">
	<cfargument name="date" type="date" required="yes">
	<cfargument name="day" type="string" required="yes">
	<cfscript>
	day=arguments.day;
	d=dateadd("d", -1, dateadd("m", 1, dateformat(arguments.date, 'yyyy-mm-01')));
	if(day==-1 or day == 0){
		return d;
	}
	while (dayOfWeek(d) != day) {
		d=dateadd("d", -1, d);
	}
	return d;
	</cfscript>
</cffunction>
	
<cffunction name="getRecurringDates" localmode="modern" access="remote" returntype="any">
	<cfargument name="startDate" type="date" required="yes">
	<cfargument name="endDate" type="date" required="yes">
	<cfargument name="rule" type="string" required="yes">
	<cfargument name="excludeDateList" type="string" required="yes">
	<cfscript>
	emptydate='0000-00-00 00:00:00';
	endDate=arguments.endDate;//dateadd("y",1,now());
	startDate=arguments.startDate;//createdatetime(2008,3,1,0,0,0);
	
	debug=true;
	arrExcludeDate=[];
	if(arguments.excludeDateList NEQ ""){
		arrExcludeDate=listToArray(arguments.excludeDateList, ',');
	}
	excludeStruct={};
	for(i=1;i LTE arraylen(arrExcludeDate);i++){
		excludeStruct[dateformat(arrExcludeDate[i], 'yyyymmdd')]=true;
	}

	 arrDate=[];
	intervalSkipCount=0;
	monthMatch=0;
	monthMatch2=0;
	yearMatch=0;
	dayMatch=0;
	yearMatchCount=0;
	countTotal=0;

	
	/*v="FREQ=WEEKLY;INTERVAL=2;BYDAY=WE;BYMONTH=1,11;UNTIL=20130102T045959Z"; // works
	v="FREQ=MONTHLY;INTERVAL=1;BYDAY=1TU;WKST=SU;UNTIL=20130102T045959Z";
	v="FREQ=YEARLY;BYMONTH=3;BYDAY=2SU;COUNT=3";
	*/
	v=arguments.rule;
	 arr1=listtoarray(v,";");
	 ts=structnew();
	 ts.count=0;
	 ts.interval=1;
	 ts.until='0000-00-00 00:00:00';
	 for(n=1;n LTE arraylen(arr1);n++){
		 arr2=listtoarray(arr1[n],"=");
		 ts[arr2[1]]=arr2[2];
	 }
	firstDate="";
	if(not structkeyexists(excludeStruct, dateformat(startDate, 'yyyymmdd'))){
		firstDate=parsedatetime(dateformat(startDate, 'yyyy-mm-dd'));
		//arrayappend(arrDate, firstDate);
		yearMatch=dateformat(firstDate, 'yyyy');
		yearMatchCount=2;
		if(ts.interval GT 1){
		//	intervalSkipCount++;
		}
	}

	 if(emptydate EQ ts.until){
		 lastDate=dateadd("yyyy",2,startDate); 
	 }else{
		 lastDate=icalParseDateTime(ts.until); 
		 ts.count=0;
	 } 
	futureDaysToProject=datediff("d",startDate,lastDate);
	if(ts.count != 0){
		futureDaysToProject=50000;
		lastDate=dateadd("d",futureDaysToProject,startDate); 
	}
	 g=1;
	if(structkeyexists(ts,'byday') and ts.byday NEQ ""){
		ts.byday=this.parseDay(ts.byday);
	}
	if(structkeyexists(ts,'WKST') and ts.WKST NEQ ""){
		ts.WKST=this.parseDay(ts.WKST);
	}
	unsupported={
		"BYSECOND"=true,
		"BYMINUTE"=true,
		//"COUNT"=true,
		"BYHOUR"=true,
	//	"BYMONTHDAY"=true,
		"BYYEARDAY"=true,
		"BYWEEKNO"=true,
		"BYSETPOS"=true
	}
	
	for(i in ts){
		if(structkeyexists(unsupported, i)){
			request.zos.template.fail(i&" icalendar recurring rule is unsupported.");
		}
	}
 
	byDayStartMatchCount=0;
	byDayStartMatchMonth="";
	byDayEndMatchCount=0;
	byDayEndMatchMonth="";

	firstMatch=true;

	startYear=dateformat(startDate, 'yyyy');
	firstStartDate=startDate;
	bydayMonthlyInterval=false;
	bydayMonthlyIntervalCount=0;
	bydayMonthlyIntervalMonth=0;



	/* new code*/
	skipYears=0;
	skipMonths=0;
	skipWeeks=0;
	skipDays=0;
	if(ts.freq EQ "YEARLY"){
		skipYears=ts.interval;
	}else if(ts.freq EQ "MONTHLY"){
		skipMonths=ts.interval;
	}else if(ts.freq EQ "WEEKLY"){
		skipWeeks=ts.interval;
	}else if(ts.freq EQ "DAILY"){
		skipDays=ts.interval;
	}

	totalMonthCount=0;
	monthDayCount=0;
	monthDayCountMonth=0;
	monthlyLastDayOfWeekMatch=0;
	lastYear=0;

	var lastDayOfMonth=0;

	var firstMonth=true;
	var totalMonthCount=0;
	var firstWeek=true;
	var firstYear=true;
	var lastYear=dateFormat(startDate, "yyyy");
	var firstDay=true;
	var everyWeekday=false;
	var recurCount=0;


	dayLookup={
		"Sunday":1,
		"Monday":2,
		"Tuesday":3,
		"Wednesday":4,
		"Thursday":5,
		"Friday":6,
		"Saturday":7
	};
	var weeklyDayLookup={
		1:false,
		2:false,
		3:false,
		4:false,
		5:false,
		6:false,
		7:false
	};
	everyDayEnabled=false;
	whichValue=""; 
	whichDayEnabled=false;
	if(structkeyexists(ts, 'byday') and arraylen(ts.byday)){
		for(var i=1;i<=arraylen(ts.byday);i++){
			whichDayEnabled=true;
			weeklyDayLookup[dayLookup[ts.byday[i].day]]=true;
		}
		if(arraylen(ts.byday) == 7){
			everyDayEnabled=true;
		}
		if(structkeyexists(ts.byday[1], 'fromStart')){
			whichValue=ts.byday[1].num;
		}else if(structkeyexists(ts.byday[1], 'fromEnd')){
			whichValue="The Last";
		}else{
			whichValue="Every";
		}
	}
	writedump(ts);
	writedump(whichValue);
	writedump(weeklyDayLookup);//abort;
	var monthlyDayLookup={};
	writedump(ts);
	if(structkeyexists(ts, 'bymonthday')){
		arrDay=listtoarray(ts.bymonthday,",");
		for(var i=1;i<=arraylen(arrDay);i++){
			monthlyDayLookup[arrDay[i]]=true;
		}
	}
	writedump(monthlyDayLookup);
	monthMatchLookup={};
	if(structkeyexists(ts,'bymonth')){
		arrMonth=listtoarray(ts.bymonth,",");
		for(i2=1;i2 LTE arraylen(arrMonth);i2++){
			monthMatchLookup[arrMonth[i2]+1]=true;
		}
	}

	echo('skipWeeks:'&skipWeeks&' | skipDays:'&skipDays&' | skipMonths:'&skipMonths&' | skipYears:'&skipYears&'<br>');

	curDate=parseDatetime(startDate);
	echo("futureDaysToProject:"&futureDaysToProject&"<br>");

	for(i=1;i LTE futureDaysToProject+1;i++){
		if(i EQ 50000){
			echo('Infinite loop detected<br>');
			abort;
		} 
		currentMonth=dateformat(curDate, "m");
		currentYear=dateformat(curDate, "yyyy");
		currentDay=dayOfWeek(curDate);
		if(!firstWeek && ts.freq EQ "WEEKLY" and currentDay EQ 1 && skipWeeks-1 > 0){ 
			echo(curDate&" | ");
			curDate=dateAdd("d", (skipWeeks-1)*7, curDate);
			echo('skipWeeks! #curDate#<br>');
		}
		if(!firstDay && ts.freq EQ "DAILY" && skipDays-1){
			//i+=skipDays-1;
			echo(curDate&" | ");
			curDate=dateAdd("d", skipDays-1, curDate);
			echo('skipDays! #curDate#<br>');
		}
		monthDayCount=0;
		if(monthDayCountMonth != currentMonth){
			totalMonthCount++;
			if(!firstMonth && ts.freq EQ "MONTHLY" && skipMonths-1){ 
				echo(curDate&" | ");
				curDate=dateAdd("m", skipMonths-1, curDate);
				echo('skipMonths! #curDate#<br>');
			}
			firstMonth=false;

			lastDayOfMonth=dateadd("d", -1, DateAdd( "m", 1, dateformat(curDate, 'yyyy-mm-01')));

			if(structkeyexists(ts,'byday') and arraylen(ts.byday)){
				if(!weeklyDayLookup[1] && weeklyDayLookup[2] && weeklyDayLookup[3] && weeklyDayLookup[4] && weeklyDayLookup[5] && weeklyDayLookup[6] && !weeklyDayLookup[7]){
					everyWeekday=true;
				}
				if(structkeyexists(ts.byday[1], 'fromEnd')){
					monthlyLastDayOfWeekMatch=lastDayOfWeekOfMonth(curDate, dayLookup[ts.byday[1].day]);
					echo('#curDate# | monthlyLastDayOfWeekMatch:'&monthlyLastDayOfWeekMatch&'<br>');
				}
			}
		}
		if(lastYear != currentYear){
			if(ts.freq EQ "YEARLY" && skipYears-1){ 
				echo(curDate&" | ");
				curDate=dateAdd("yyyy", skipYears-1, curDate);
				echo('skipYears! #curDate#<br>');
			}
		} 
		currentMonth=dateformat(curDate, "m");
		currentYear=dateformat(curDate, "yyyy");
		currentDay=dayOfWeek(curDate); 
		monthDayCountMonth=currentMonth;
		lastYear=currentYear;
		isEvent=false; 
		if(ts.count EQ 0 and curDate > lastDate){
			break;
		}
		//writedump(ts);abort;

		if(ts.freq == "Daily"){
			if(everyWeekday){
				echo(curDate&' | everyWeekday<br>');
				if(currentDay != 1 && currentDay != 7){
					echo(curDate&' | everyWeekday2<br>');
					isEvent=true;
				}
			}else{

				echo(curDate&' | not everyWeekday<br>');
				isEvent=true;
			}
		}else if(ts.freq == "Weekly"){
			if(weeklyDayLookup[currentDay]){
				isEvent=true;
			}
		}else if(ts.freq == "Monthly"){
			if(structcount(monthlyDayLookup)){
				if(structkeyexists(monthlyDayLookup, "0") and curDate == lastDayOfMonth){
					isEvent=true;
				}
				if(structkeyexists(monthlyDayLookup, dateformat(curDate, "d"))){
					isEvent=true;
				}
			}else{
				echo('here111<br>');
				if(structcount(weeklyDayLookup)){
					var dayMatch=false;
					//writedump(currentDay);					writedump(weeklyDayLookup);					abort;
					if(everyDayEnabled or structkeyexists(weeklyDayLookup, currentDay) and weeklyDayLookup[currentDay]){
						monthDayCount++;	
				echo('here222<br>');
						dayMatch=true; 
					}

					if(whichValue == "Every"){

						if(dayMatch){
							echo('here666<br>');
							isEvent=true;
						}
					}else if(whichValue == "The Last"){
						if(dayMatch && curDate == monthlyLastDayOfWeekMatch){
							isEvent=true;
						}
					}else if(everyDayEnabled){
				echo('here333<br>');
						if(dayMatch){
							isEvent=true;
						}
					}else{
				echo('here444<br>');
						if(dayMatch && curDate EQ getNthDayOfMonth(curDate, currentDay, whichValue)){
				echo('here555<br>');
							isEvent=true;
						}
					}
				}
			}
		}else if(ts.freq == "Yearly"){
			if(structkeyexists(monthMatchLookup, currentMonth)){
 
				echo('year1<br>');
				if(structcount(monthlyDayLookup)){
					/*if(structkeyexists(monthlyDayLookup, "0") and curDate == lastDayOfMonth){
					echo(curDate&' | year1-2<br>');
						isEvent=true;
					}*/
					if(structkeyexists(monthlyDayLookup, '-1')){
						echo(curDate&' | year1-4<br />');
						if(lastDayOfMonth EQ curDate){
							echo(curDate&' | year1-5<br />');
							isEvent=true;
						}
					}else if(structkeyexists(monthlyDayLookup, dateformat(curDate, "d"))){
					echo(curDate&' | year1-3<br>');
						isEvent=true;
					}
				}else{
					if(whichDayEnabled){
						var dayMatch=false;
						if(everyDayEnabled or (structkeyexists(weeklyDayLookup, currentDay) and weeklyDayLookup[currentDay])){
							echo(curDate&' | year2<br>');
							monthDayCount++;	
							dayMatch=true;
						}
						if(whichValue == "Every"){ // the first/second, etc
							echo(curDate&' | year3<br>');
							if(dayMatch){
								echo('year4<br>');
								isEvent=true;
							}
						}else if(whichValue == "The Last"){ // the first/second, etc
							echo(curDate&' | year5<br>'); 
							if(dayMatch && curDate == monthlyLastDayOfWeekMatch){
								echo('year6<br>');
								isEvent=true;
							}
						}else if(everyDayEnabled){
							echo(curDate&' | year7<br>');
							if(dayMatch){
								echo('year8<br>');
								isEvent=true;
							}
						}else{
							if(dayMatch && curDate EQ getNthDayOfMonth(curDate, currentDay, whichValue)){
								echo(curDate&' | year9<br>');
								isEvent=true;
							}
						}
					}else{

						echo(curDate&' | year10 | whichValue: '&whichValue&"<br>");
						if(whichValue == dateformat(curDate, "d")){ // the first/second, etc

							echo(curDate&' | year11<br>');
							isEvent=true;
						}
					}
				}
				if(i EQ 5){
					echo('stop33');abort;
				}
			}
		}
		if(curDate==startDate){
			if(!isEvent){
				recurCount--;
			}
			isEvent=true;
		}
		if(isEvent){
			if(structkeyexists(excludeStruct, dateformat(curDate, "yyyymmdd"))){
				continue;
			}
			if(curDate>=startDate && curDate<=lastDate){

				if(debug) echo('added date: '&curDate&" | #i# of #futureDaysToProject#<br>");
				arrayAppend(arrDate, curDate);
				recurCount++;
				firstDay=false;
				firstWeek=false;
			}
		}
		curDate=dateadd("d", 1, curDate);
		if(ts.count != 0 && recurCount==ts.count){
			break;
		}
	}

	writedump(arrDate);
	return arrDate;


	// old code
	for(i=1;i LTE futureDaysToProject+1;i++){
		break;

		matchcount=0;
		totalmatchcount=0;

		
		if(monthMatch2 NEQ dateformat(curDate,'m')){
			dayMatch=0;
		}
		// on a monthly calendar, this become the first and only occurance day, like first tuesday, second thursday, etc.
		if(structkeyexists(ts,'byday')){
			totalmatchcount++;
			//writedump(ts.byday);abort;
			for(n=1;n LTE arraylen(ts.byday);n++){

				if(ts.byday[n].day EQ dateformat(curDate,'dddd')){
					//if(debug) echo('byday111:'&ts.byday[n].day&' EQ '&dateformat(curDate,'dddd')&'<br />');
					if(structkeyexists(ts.byday[n], 'fromStart')){
						m=dateformat(curDate, 'm');
						if(byDayStartMatchMonth NEQ m){
							byDayStartMatchMonth=m;
							byDayStartMatchCount=0;
						}
						byDayStartMatchCount++;


						targetDate=getNthDayOfMonth(curDate, ts.byday[n].dayIndex, ts.byday[n].num);

						if(targetDate EQ curDate){
							matchcount=1;
							totalmatchcount=1;
						}else{
							matchcount=0;
							totalmatchcount=1;
						}
						/*
						if(dateformat(targetDate, 'm') NEQ m){
						 
						    targetDate = dateadd("d", -7, targetDate);
						}
						*/
						/*if(byDayStartMatchCount EQ ts.byday[n].num){
							matchcount=1;
							totalmatchcount=1;
						}else if(byDayStartMatchCount GT ts.byday[n].num){
							matchcount=0;
							totalmatchcount=1;
						}*/
						// need to know if we're already past the first date in month
						// always start from beginning of month at top of loop, but don't save dates until the startDate
					}else if(structkeyexists(ts.byday[n], 'fromEnd')){ 
						m=dateformat(curDate, 'm');
						if(byDayEndMatchMonth NEQ m){
							byDayEndMatchMonth=m;
							byDayEndMatchCount=0;
						}

						// currently only supports the "last day" and not -2MO, etc
						if(byDayEndMatchCount NEQ 0){
							continue;
						}

						dtLastDay=dateadd("d", -1, DateAdd( "m", 1, dateformat(curDate, 'yyyy-mm-01')));
						targetDate = dateadd("d", -(DayOfWeek(dtLastDay)-ts.byday[n].dayIndex), dtLastDay);
						if(dateformat(targetDate, 'm') NEQ m){
						 
						    targetDate = dateadd("d", -7, targetDate);
						}
						//targetDate=parsedatetime(dateformat(targetDate, 'yyyy-mm-dd'));
						//if(debug) echo(ts.byday[n].dayIndex&" | "&ts.byday[n].day&" | "&curDate&" | "&targetDate&"<br>");
						if(curDate EQ targetDate){
							matchcount=1;
							totalmatchcount=1;
							byDayEndMatchCount++;
						}else{
							matchcount=0;
							totalmatchcount=1;
						}
					}else{
						/*if(ts.freq EQ "monthly" and ts.interval GT 1){
							if(bydayMonthlyInterval NEQ dateformat(curDate, 'm'){
								bydayMonthlyInterval=dateformat(curDate, 'm');
								bydayMonthlyIntervalCount++;
							}
						}*/
						if(ts.freq EQ "monthly"){
							bydayMonthlyInterval=true;
						}
						if(debug) echo(curDate&' | byday was here<br />');
						matchcount++;
						dayMatch++; 
					}
				}
			}
		}
		var matchcountBackup=0;
		if(firstDate EQ curDate){
			if(not structkeyexists(excludeStruct, dateformat(curDate, 'yyyymmdd'))){
				if(debug) echo('already added first date: '&curDate&"<br>");
				//matchcount=0;
				//arrayappend(arrDate, curDate);
			}
			yearMatchCount=0;
			intervalSkipCount=0; 
			matchcountBackup=matchcount;
			matchcount=0;
		} 
		if(structkeyexists(ts,'bymonthday')){
			totalmatchcount++;
			arrMonthDay=listtoarray(ts.bymonthday,",");
			for(i2=1;i2 LTE arraylen(arrMonthDay);i2++){
				if(arrMonthDay[i2] EQ "-1"){
					dtLastDay=dateadd("d", -1, DateAdd( "m", 1, dateformat(curDate, 'yyyy-mm-01')));
					if(dtLastDay EQ curDate){
						totalmatchcount=1;
						matchcount=1;
					}
				}else{
					if(arrMonthDay[i2] EQ dateformat(curDate,'d')){
						matchcount++;
						//monthMatch2=dateformat(curDate,'m');
						break;
					}
				}
			}
		}
		if(structkeyexists(ts,'bymonth')){
			monthNotMatching=false;
			totalmatchcount++;
			arrMonth=listtoarray(ts.bymonth,",");
			for(i2=1;i2 LTE arraylen(arrMonth);i2++){
				if(arrMonth[i2]+1 NEQ dateformat(curDate,'m')){
					monthNotMatching=true;
					//if(debug) echo('Month already passed<br />');
					//yearMatch=dateformat(curDate, 'yyyy');
					//yearMatchCount++;
				}
				if(arrMonth[i2]+1 EQ dateformat(curDate,'m')){
					matchcount++;
					break;
				}
			}
			if(monthNotMatching){
				futureDate=dateadd("m", 1, dateformat(curDate, 'yyyy-mm-01'));
				dayCount=datediff("d", curDate, futureDate);
				if(debug) echo("skip to next month | curDate: #curDate# | dayCount:"&dayCount&"<br>");
				i+=dayCount-1;
				continue;
			}
		}
		// No existing use cases of this one: The WKST rule part specifies the day on which the workweek starts. Valid values are MO, TU, WE, TH, FR, SA and SU. This is significant when a WEEKLY RRULE has an interval greater than 1, and a BYDAY rule part is specified. This is also significant when in a YEARLY RRULE when a BYWEEKNO rule part is specified. The default value is MO.
		if(ts.interval GT 1){
			if(structkeyexists(ts,'WKST')){
				request.zos.template.fail('WKST (Work week start day (i.e., Monday, Sunday, etc) is not supported yet when interval is greater then 1 (icalendar rules).');
				totalmatchcount++;
				if(ts.WKST.day EQ dateformat(curDate,'dddd')){
					matchcount++;
				}
			}
		} 
		if(debug) echo(curDate&":"&matchcount&' EQ '&totalmatchcount&" | "&monthMatch&"<br>");
		if(firstDate EQ curDate and matchcountBackup+matchcount EQ totalmatchcount){
			countTotal++;
		}
		if(matchcount EQ totalmatchcount){
		//if(matchcount EQ totalmatchcount or firstDate EQ curDate){
			//if(ts.interval NEQ 1){
				if(ts.freq EQ "monthly"){
					/*if(monthMatch EQ dateformat(curDate,'m')){
						if(debug) echo('skipping<br>');
						continue;
					}*/
				}
				if(ts.interval EQ 1){
					intervalSkipCount=0;
				}else{

					if(ts.freq EQ "monthly"){
						if(firstMatch){
							firstMatch=false;
							if(debug) echo('firstMatch<br />'); 
							if(dateformat(firstDate, "m") EQ dateformat(curDate, "m")){ 
								intervalSkipCount=0; 
							}else{ 
								intervalSkipCount=1; 
							} 
						}

						if(bydayMonthlyInterval){

						}
					}

					if(ts.freq EQ "yearly"){
						if(firstMatch){
							firstMatch=false;
							if(debug) echo('firstMatch<br />'); 
							if(dateformat(firstDate, "yyyy") EQ dateformat(curDate, "yyyy")){
								yearMatchCount=0;
								intervalSkipCount=0; 
							}else{
								yearMatchCount=1;
								intervalSkipCount=1; 
							}
							yearMatch=dateformat(curDate, 'yyyy');
						}else{
							if(debug) echo('yearMatchCount:'&yearMatchCount&'<br>');
							if(yearMatch NEQ dateformat(curDate,'yyyy')){
								if(yearMatch EQ 0){
									yearMatchCount=ts.interval;
									yearMatch=dateformat(curDate, 'yyyy');
								}else{
									yearMatch=dateformat(curDate, 'yyyy');
									yearMatchCount++;
								}
							}else{
								//continue;
							}
							if(yearMatchCount GTE ts.interval){
								intervalSkipCount=0;
								yearMatchCount=0;
							}else{
								intervalSkipCount=1;
							}
						}
					}
				}
				if(bydayMonthlyInterval){
					intervalSkipCount=bydayMonthlyIntervalCount-1;
				}
				//totalmatchcount++;
				if(debug) echo(curDate&" | yearMatchCount: #yearMatchCount# | intervalSkipCount:"&intervalSkipCount&" | interval: "&ts.interval&"<br>");
				if(intervalSkipCount EQ 0){
					//matchcount++;
					//arrayappend(arrDate, dateformat(curDate,'yyyy-mm-dd dddd'));

					if(not structkeyexists(excludeStruct, dateformat(curDate, 'yyyymmdd'))){
						if(debug) echo('added date: '&curDate&"<br>");
						arrayappend(arrDate, curDate);
					}
					countTotal++;
					if(ts.count GT 0 and countTotal EQ ts.count){
						// all occurrences have occured.
						break;	
					}
					monthMatch=dateformat(curDate,'m');
					//yearMatch=dateformat(curDate,'yyyy');
				}

				if(bydayMonthlyInterval){
					if(bydayMonthlyIntervalMonth NEQ dateformat(curDate,'m')){
						bydayMonthlyIntervalMonth=dateformat(curDate,'m');
						bydayMonthlyIntervalCount++;
					}
					if(bydayMonthlyIntervalCount GTE ts.interval){
						bydayMonthlyIntervalCount=0;
						intervalSkipCount=0;
					}
				}else{
					intervalSkipCount++;
					if(intervalSkipCount GTE ts.interval){
						intervalSkipCount=0;
					}
				}
			//}
		}
		// writeoutput(dateformat(curDate,'yyyy-mm-dd dddd')&" | "&matchcount&" EQ "&totalmatchcount&"<br>");
		if(datecompare(curDate, lastDate) EQ 0){
			// this is the until date, stop processing!
			break;	
		}
	}
	//writedump(arrDate);abort;
	return arrDate;
	 //ts2.event_recur_ical_rules=eventData.rrule.data;
	 </cfscript>
	
	<!--- notes from recur_functions.php in php icalendar
	"BYxxx rule parts modify the recurrence in some manner. BYxxx rule parts for a period of time which is the same or greater than the frequency generally reduce or limit the number of occurrences of the recurrence generated. For example, "FREQ=DAILY;BYMONTH=1" reduces the number of recurrence instances from all days (if BYMONTH tag is not present) to all days in January. BYxxx rule parts for a period of time less than the frequency generally increase or expand the number of occurrences of the recurrence. For example, "FREQ=YEARLY;BYMONTH=1,2" increases the number of days within the yearly recurrence set from 1 (if BYMONTH tag is not present) to 2.
	
	If multiple BYxxx rule parts are specified, then after evaluating the specified FREQ and INTERVAL rule parts, the BYxxx rule parts are applied to the current set of evaluated occurrences in the following order: BYMONTH, BYWEEKNO, BYYEARDAY, BYMONTHDAY, BYDAY, BYHOUR, BYMINUTE, BYSECOND and BYSETPOS; then COUNT and UNTIL are evaluated."
	
	We will use two kinds of functions - those that restrict the date to allowed values and those that expand allowed values --->
</cffunction>


<cffunction name="importEvents" localmode="modern"  access="public" output="yes" hint="Gets the events from an iCal string.">
	<cfargument name="cfcObject" type="component" required="yes">
	<cfargument name="cfcMethod" type="string" required="yes">
	<cfscript>
	marker = "BEGIN:VEVENT";
	endmarker = "END:VEVENT";
	eventStrArray = "";
	eventSubString = "";
	results = arrayNew(1);
	x = "";
	eventStr = "";
	line = "";
	token = "";
	eventData = "";
	endPosition = "";
	leftLine = "";
	pos = "";
	foundAt = "";
	key = "";
	value = "";
	subline = "";
	local=structnew();
	//  translate the lines into packages of strings beginning and ending with our marker 
	//  why didn't we use it in the var above? because it may be slow, and we have the possibility to leave early if stuff is cached 		
	eventStrArray = reGet(variables.data,"#marker#(.*?)#endmarker#"); 
	for(x=1;x LTE arrayLen(eventStrArray);x++){
		eventSubString = replace(eventStrArray[x],marker,"");
		eventSubString = replace(eventSubString,endmarker,"");

		
		/* Now we have a format that looks like this:
		  KEY;PARAM:VALUE
		
		params are optional
		params can be multiple:   ;x=1;y=2
		params can have multiple values, but we don't care:   ;x=a,b;y=c,d
		VALUE can also be a list, but we don't need to parse it. It can also contain a :
		PARAM can also contain a :, but it will be quoted
			ex: DESCRIPTION;ALTREP="http://www.wiz.org":The Fall'98 Wild Wizards Conference - - Las Vegas, NV, USA			

		It is possible that a long line will "wrap". This means a line break and a line with a space in the beginning. 
		We can translate only LINEBREAK+SPACE to just one line. 
		space can be ascii 32 or 9
		
		*/
		//  First, let's "fold" the lines in 
		eventSubString = replace(eventSubString, chr(13) & chr(10) & chr(9), "", "all");
		eventSubString = replace(eventSubString, chr(13) & chr(10) & chr(32), "", "all");
		//  This makes it easier for our looping 
		eventSubString = replace(eventSubString, chr(13), chr(10), "all");
		//  get rid of blanks 
		eventSubString = trim(replace(eventSubString, chr(10) & chr(10), chr(10), "all"));
		
		eventData = structNew();
		arr1=listtoarray(eventSubString, chr(10));
		lenArr1=arraylen(arr1);
		for(i=1;i LTE lenArr1;i++){
			line=arr1[i];
			// this token is the first entry before ; or : 
			token = listFirst(line, ";,:");
			tokenKey=token;
			if(structkeyexists(eventData, token)){
				for(i2=2;i2 LTE 25;i2++){
					if(structkeyexists(eventData, token&"-"&i2) EQ false){
						tokenKey=token&"-"&i2;
						break;
					}
				}
			}
			eventData[tokenKey] = structNew();
			eventData[tokenKey].params = structNew();
			eventData[tokenKey].data = "";
			//  remove the token 
			line = replace(line,token,"");
			//  now we either have params or a value. We need to see if we have funky colons inside quotes 
			//  we can do this by using a new UDF, findNotInQuotes. This will find a char that ISNT inside quotes. 
			//  first though, do we have to bother? if we _start_ with a :, we just have data 
			
			if(left(line,1) is ";"){
				line = right(line, len(line)-1);
				//  so, we need to move through LINE, going until we get a NON in quotes :, or a NON in quotes , 
				//  let's first find the END of our section by getting the firstNonInQuotes colon 
				endPosition = findNotInQuotes(line,":");
				leftLine = mid(line, 1, endPosition-1);
				eventData[tokenKey].data = mid(line, endPosition+1, len(line)-endPosition+1);
				//  so, now we need to look for ; not in quotes. We can cheat though.    I can replace semicolons not in a quote with chr(10) 
				pos = 1;
				while(findNotInQuotes(leftLine,";",pos)){
					foundAt = findNotInQuotes(leftLine,";",pos);
					leftLine = mid(leftLine,1,foundAt-1) & chr(10) & mid(leftLine, foundAt+1, len(leftLine)-foundAt+1);
					pos = foundAt + 1;
				}
				//  now split by chr(10) 
				loop index="subline" list="#leftLine#" delimiters="#chr(10)#"{
					//  each line is foo=goo 
					key = listFirst(subline,"=");
					value = listRest(subline,"=");
					eventData[tokenKey].params[key] = value;
				}
			}else{
				if(len(line) GT 1){
					eventData[tokenKey].data = right(line,len(line)-1);
				}
			}
		}
		ts=variables.prepareForDatabase(eventData);
		arguments.cfcObject[arguments.cfcMethod](ts);
		arrayClear(request.zos.arrQueryLog);
		/*if(x EQ 2){
			// quit after 20 to debug performance issues.
			break;
		}*/
	}
	</cfscript>
</cffunction>

<cffunction name="prepareForDatabase" localmode="modern" access="private" returntype="struct" roles="member">
	<cfargument name="data" type="struct" required="yes">
	<cfscript>
	eventData=arguments.data;
	ts2={
		timezone:"",
		summary:"",
		description:"",
		location:"",
		startDate:"",
		endDate:"",
		recurRules:"",
		uid:"",
		arrExDate:[],
		updateDatetime:request.zos.mysqlnow
	};
	if(structkeyexists(eventData.dtstart.params,'tzid')){
		ts2.timezone=eventData.dtstart.params.tzid;
	}
	if(structKeyExists(eventData,"summary")){
		ts2.summary=replace(replace(eventData.summary.data,"\,","\","all"),"\ "," ","all");
	}
	if(structKeyExists(eventData,"description")){
		ts2.description=replace(replace(replace(eventData.description.data,"\n",chr(10),"all"),"\,","\","all"),"\ "," ","all");
	}
	if(structKeyExists(eventData,"location")){
		ts2.location=replace(replace(eventData.location.data,"\,","\","all"),"\ "," ","all");;
	}
	d1=this.icalParseDateTime(eventData.dtstart.data);
	if(structKeyExists(eventData,"dtend")){
		d2=this.icalParseDateTime(eventData.dtend.data);
	}else if(structKeyExists(eventData,"duration") and eventData.duration.data NEQ "P1D"){
		d2=this.icalParseDuration(eventData.duration.data, d1);
	}else{
		d2=d1;
	}
	curTime=timeformat(d1,'HH:mm:ss');
	if(curTime EQ "00:00:00"){
		ts2.startDate=dateformat(d1,'yyyy-mm-dd'); 
	}else{
		ts2.startDate=dateformat(d1,'yyyy-mm-dd')&' '&timeformat(d1,'HH:mm:ss'); 
	}
	curTime=timeformat(d2,'HH:mm:ss');
	if(curTime EQ "00:00:00"){
		ts2.endDate=dateformat(d2,'yyyy-mm-dd');
	}else{
		ts2.endDate=dateformat(d2,'yyyy-mm-dd')&' '&timeformat(d2,'HH:mm:ss');
	}
	ts2.uid=eventData.uid.data;
	arrD=arraynew(1);
	if(structkeyexists(eventData, 'exdate')){
		arrayappend(arrD, this.icalParseDateTime(eventData.exdate.data)); 
		for(i2=2;i2 LTE 25;i2++){
			if(structkeyexists(eventData, 'exdate-'&i2)){
				arrayappend(arrD, this.icalParseDateTime(eventData["exdate-"&i2].data)); 
			}
		}
		ts2.arrExDate=arrD;
	}
	ts2.updateDatetime=request.zos.mysqlnow;
	if(structkeyexists(eventData, 'rrule')){
		ts2.recurRules=eventData.rrule.data;
	}
	/*if(structkeyexists(eventData, 'rrule')){
		ts2.recurStruct=variables.parseRecurringRule(eventData);
	}else{
		ts2.recurStruct={};
	}*/
	return ts2;
	</cfscript>
</cffunction>
<!--- 
<cffunction name="parseRecurringRule" localmode="modern" access="private" returntype="struct" roles="member">
	<cfargument name="data" type="struct" required="yes">
	<cfscript>
	var eventData=arguments.data;
	 arr1=listtoarray(arguments.data.rrule.data,";");
	 emptyDate='0000-00-00 00:00:00';
	 ts=structnew();
	 ts.count=0;
	 ts.interval=1;
	 ts.until=emptyDate;
	 for(n=1;n LTE arraylen(arr1);n++){
		 arr2=listtoarray(arr1[n],"=");
		 ts[arr2[1]]=arr2[2];
	 }
	 ts2=structnew();
	 ts2.event_recur_count=ts.count;
	 ts2.event_recur_interval=ts.interval;
	 
	 ts2.event_recur_ical_rules=eventData.rrule.data;
	 if(emptydate EQ ts.until){
		 ts2.event_recur_until_datetime=oneyearfuture;
	 }else{
		 d2=this.icalParseDateTime(ts.until);
		 curTime=timeformat(d2,'HH:mm:ss');
		 if(curTime EQ "00:00:00"){
		 	ts2.event_recur_until_datetime=dateformat(d2,'yyyy-mm-dd');
		 }else{
			 ts2.event_recur_until_datetime=dateformat(d2,'yyyy-mm-dd')&' '&timeformat(d2,'HH:mm:ss');
		 }
	 }
	 ts2.event_recur_frequency=ts.freq;
	return ts2;
	</cfscript>
</cffunction>  --->

<cffunction name="iCalParseDateTime" localmode="modern" returnType="date" access="public" output="false" hint="Takes a date/time string in the format YYYYMMDDTHHMMSS or YYYYMMDD and returns a date.">
	<cfargument name="str" type="string" required="true">
	<cfscript>
	var local=structnew();
	var str=arguments.str;
	var dateStr = "";
	var timeStr = "";
	var year = "";
	var month = "";
	var day = "";
	var hour = "";
	var minute = "";
	var second = "";
	
	if(find("T",str)) {
		dateStr = listFirst(str,"T");
		timeStr = listLast(str,"T");
	} else {
		dateStr = str;
		timeStr = "000000";
	}
	
	//first 4 digits are year
	year = left(dateStr,4);
	month = mid(dateStr,5,2);
	day = right(dateStr,2);

	hour = left(timeStr,2);
	minute = mid(timeStr,3,2);
	second = mid(timeStr,5,2);
	//20121224T144219Z
	//YYYYMMDDTHHMMSS
	try{
	curDate=CreateDateTime(year,month,day,hour,minute,second);
	}catch(Any e){
		writeoutput(dateStr);
		writedump(e);	
		abort;
	}
	if(right(arguments.str, 1) EQ "Z"){
		curDate=DateConvert( "UTC2Local", curDate );
	}
	return curDate;
	</cfscript>
</cffunction>

<cffunction name="iCalParseDuration" localmode="modern" returnType="date" access="public" output="false" hint="Takes an iCal duration and adds it to a date.">
	<cfargument name="str" type="string" required="true">
	<cfargument name="date" type="date" required="true">
	<cfscript>
	chrPos = "";
	num = "";
	curChr = "";
	parts = "";
	x = "";
	dir = "1";
	/*
	iCal durations take the form of:
	PXXXXXXXXX
	where XXXXXXXX is the data we care about. 
	Each item in the string is a number and a type. 
	So an example is 7W, which is 7 weeks.
	Also, a "T" may be present, it means a hour/min/sec pair follows it. 
	However, we can ignore the T, and in general, just treat the strings
	as pairs of numbers and types. 	
	*/

	// are we a negative duration? Although I don't understand how a duration can go -back- in time...
	if(left(arguments.str,1) is "-"){
		dir = "-1";
	}
	// remove potential + or - in front 
	arguments.str = replace(arguments.str, "+", "");
	arguments.str = replace(arguments.str, "-", "");
	// remove the P, and then a T
	arguments.str = replace(arguments.str, "P", "");
	arguments.str = replace(arguments.str, "T", "");

	parts = reGet(arguments.str,"[0-9]{1,}[A-Za-z]");
	
	// now we loop
	for(x=1;x LTE arrayLen(parts);x++){
		chrPos = reFindNoCase("[A-Z]",parts[x]);
		if(chrPos is 0){
			break;
		}
		num = left(parts[x], chrPos - 1);
		curChr = mid(parts[x], chrPos, 1);
		// The strings iCal uses don't match exactly with dateAdd, but close...
		if(curChr is "W"){
			curChr = "WW";
		}else if(curChr is "M"){
			curChr = "N";
		}
		arguments.date = dateAdd(curChr, dir * num, arguments.date);
	}
	return arguments.date;
	</cfscript>
</cffunction>

<cffunction name="reGet" localmode="modern" returnType="array" access="private" output="false" hint="Returns all the matches of a regex from a string.">
	<cfargument name="str" type="string" required="true">
	<cfargument name="regex" type="string" required="true">
	<cfscript>
	var str=arguments.str;
	var results = arrayNew(1);
	var test = REFind(arguments.regex,str,1,1);
	var pos = test.pos[1];
	var oldpos = 1;
	
	while(pos gt 0) {
		arrayAppend(results,mid(str,pos,test.len[1]));
		oldpos = pos+test.len[1];
		test = REFind(arguments.regex,str,oldpos,1);
		pos = test.pos[1];
	}
	return results;
	</cfscript>
</cffunction>
	
<cffunction name="findNotInQuotes" localmode="modern" returnType="numeric" access="private" output="false" hint="Finds the instance of the character where it isn't in quotes.">
	<cfargument name="data" type="string" required="true">
	<cfargument name="target" type="string" required="true" hint="Must be just one character.">
	<cfargument name="start" type="numeric" required="false" default="1">
	<cfscript>
	var inQuotes = false;
	var c = "";

	for(; arguments.start lte len(arguments.data); arguments.start=arguments.start+1) {
		c = mid(arguments.data,arguments.start,1);
		if(c is """") {
			if(inQuotes) inQuotes=false;
			else inQuotes = true;
		}
		if(c is arguments.target and not inQuotes) return arguments.start;
	}
	return 0;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>