<cfcomponent displayName="iCal" hint="A iCal processor." output="false">
<cfoutput>
<cfscript>
variables.data = "";
 this.dayStruct={
	"SU"="Sunday",
	"MO"="Monday",
	"TU"="Tuesday",
	"WE"="Wednesday",
	"TH"="Thursday",
	"FR"="Friday",
	"SA"="Saturday"
 };
 </cfscript>

<cffunction name="parseDay" localmode="modern" access="public" returntype="any">
<cfargument name="d" type="string" required="yes">
<cfscript>
	arrD=listtoarray(arguments.d,",");
	for(n=1;n LTE arraylen(arrD);n++){
		match=false; 
		for(i=1;i LTE len(arrD[n]);i++){
			if(isnumeric(mid(arrD[n],i,1)) EQ false){
				if(i EQ 1){
					arrD[n]={day=this.dayStruct[arrD[n]],num=1};	
				}else{
					arrD[n]={day=this.dayStruct[mid(arrD[n], i, len(arrD[n])-(i-1))],num=left(arrD[n],i-1)};	
				}
				match=true;
				break;
			}
		}
		if(match EQ false){
			request.zos.template.fail("Invalid day value: "&arrD[n]);
		}
	}
	return arrD;
	</cfscript>
</cffunction>

<cffunction name="getRecurringDates" localmode="modern" access="remote" returntype="any">
	<cfargument name="startDate" type="date" required="yes">
	<cfargument name="endDate" type="date" required="yes">
	<cfargument name="rule" type="string" required="yes">
	<cfscript>
	emptydate='0000-00-00 00:00:00';
	endDate=arguments.endDate;//dateadd("y",1,now());
	startDate=arguments.startDate;//createdatetime(2008,3,1,0,0,0);
	
	futureDaysToProject=datediff("d",startDate,endDate);
	
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
	 /*ts2=structnew();
	 ts2.event_recur_count=ts.count;
	 ts2.event_recur_interval=ts.interval;*/
	 if(emptydate EQ ts.until){
		 //ts2.event_recur_until_datetime=emptydate;
		 d2=dateadd("y",2,now());
	 }else{
		 d2=icalParseDateTime(ts.until);
		 //ts2.event_recur_until_datetime=dateformat(d2,'yyyy-mm-dd')&' '&timeformat(d2,'HH:mm:ss');
	 }
	 g=1;
	 arrDate=[];
	if(structkeyexists(ts,'byday') and ts.byday NEQ ""){
		ts.byday=this.parseDay(ts.byday);
	}
	if(structkeyexists(ts,'WKST') and ts.WKST NEQ ""){
		ts.WKST=this.parseDay(ts.WKST);
	}
	/*
	if(structkeyexists(ts,'bymonth') and ts.bymonth NEQ ""){
		ts.bymonth=this.parseMonth(ts.bymonth);
		writedump(c);
		abort;
	}*/
	intervalSkipCount=0;
	monthMatch=0;
	monthMatch2=0;
	yearMatch=0;
	dayMatch=0;
	countTotal=0;
	
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
	
	for(i=1;i LTE futureDaysToProject+1;i++){
		curDate=dateadd("d",i-1,startDate);
		matchcount=0;
		totalmatchcount=0;
		
		if(monthMatch2 NEQ dateformat(curDate,'m')){
			dayMatch=0;
		}
		// on a monthly calendar, this become the first and only occurance day, like first tuesday, second thursday, etc.
		if(structkeyexists(ts,'byday')){
			totalmatchcount++;
			for(n=1;n LTE arraylen(ts.byday);n++){
				if(ts.byday[n].day EQ dateformat(curDate,'dddd')){
					matchcount++;
					dayMatch++;
					monthMatch2=dateformat(curDate,'m');
				}
				if(ts.byday[n].num NEQ 1){
					totalmatchcount++;
					if(ts.byday[n].num EQ dayMatch){
						matchcount++;
					}
				}
			}
		}
		if(structkeyexists(ts,'bymonthday')){
			totalmatchcount++;
			arrMonthDay=listtoarray(ts.bymonthday,",");
			for(i2=1;i2 LTE arraylen(arrMonthDay);i2++){
				if(arrMonthDay[i2] EQ dateformat(curDate,'d')){
					matchcount++;
					monthMatch2=dateformat(curDate,'m');
					break;
				}
			}
		}
		
		if(structkeyexists(ts,'bymonth')){
			totalmatchcount++;
			arrMonth=listtoarray(ts.bymonth,",");
			for(i2=1;i2 LTE arraylen(arrMonth);i2++){
				if(arrMonth[i2] EQ dateformat(curDate,'m')){
					matchcount++;
					break;
				}
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
		if(matchcount EQ totalmatchcount){
			//if(ts.interval NEQ 1){
				if(ts.freq EQ "monthly"){
					if(monthMatch EQ dateformat(curDate,'m')){
						continue;
					}
				}
				if(ts.freq EQ "yearly"){
					if(yearMatch EQ dateformat(curDate,'yyyy')){
						continue;
					}
				}
				//totalmatchcount++;
				if(intervalSkipCount EQ 0){
					//matchcount++;
					//arrayappend(arrDate, dateformat(curDate,'yyyy-mm-dd dddd'));
					arrayappend(arrDate, curDate);
					countTotal++;
					if(countTotal EQ ts.count){
						// all occurrences have occured.
						break;	
					}
					monthMatch=dateformat(curDate,'m');
					yearMatch=dateformat(curDate,'yyyy');
				}
				intervalSkipCount++;
				if(intervalSkipCount+1 GTE ts.interval){
					intervalSkipCount=0;
				}
			//}
		}
		// writeoutput(dateformat(curDate,'yyyy-mm-dd dddd')&" | "&matchcount&" EQ "&totalmatchcount&"<br>");
		if(datecompare(curDate, d2) EQ 0){
			// this is the until date, stop processing!
			break;	
		}
	}
	return arrDate;
	 //ts2.event_recur_ical_rules=eventData.rrule.data;
	 </cfscript>
	
	<!--- notes from recur_functions.php in php icalendar
	"BYxxx rule parts modify the recurrence in some manner. BYxxx rule parts for a period of time which is the same or greater than the frequency generally reduce or limit the number of occurrences of the recurrence generated. For example, "FREQ=DAILY;BYMONTH=1" reduces the number of recurrence instances from all days (if BYMONTH tag is not present) to all days in January. BYxxx rule parts for a period of time less than the frequency generally increase or expand the number of occurrences of the recurrence. For example, "FREQ=YEARLY;BYMONTH=1,2" increases the number of days within the yearly recurrence set from 1 (if BYMONTH tag is not present) to 2.
	
	If multiple BYxxx rule parts are specified, then after evaluating the specified FREQ and INTERVAL rule parts, the BYxxx rule parts are applied to the current set of evaluated occurrences in the following order: BYMONTH, BYWEEKNO, BYYEARDAY, BYMONTHDAY, BYDAY, BYHOUR, BYMINUTE, BYSECOND and BYSETPOS; then COUNT and UNTIL are evaluated."
	
	We will use two kinds of functions - those that restrict the date to allowed values and those that expand allowed values --->
</cffunction>

<cffunction name="init" localmode="modern" returnType="ical" access="public" output="false"
			hint="Init function for the CFC. Loads in the initial string data.">
	<cfargument name="data" type="string" required="true">
	<cfscript>
	variables.data = arguments.data;
	return this;
	</cfscript>
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