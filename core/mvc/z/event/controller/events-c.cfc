<cfcomponent>
<cfoutput>
<cffunction name="generateWidgetCode" access="remote" roles="member" localmode="modern">
	<cfscript>
	form.categories=request.zos.functions.zso(form, 'categories');
	form.color=request.zos.functions.zso(form, 'color', false, 'orange');
	form.limit=request.zos.functions.zso(form, 'limit', true, 4);
	form.width=request.zos.functions.zso(form, 'width', true, 300);
	form.height=request.zos.functions.zso(form, 'height', true, 500);
	</cfscript>
	<h2>Calendar Widget Code</h2>
	<form action="/events/generateWidgetCode" method="get">
	<div style="width:100%; float:left;">
	<div style="width:70px; float:left;">
	## of Events: 
	</div>
	<div style="width:500px; float:left;">
	<input type="text" name="limit" value="#form.limit#" />
	</div>
	</div>
	<div style="width:100%; float:left;">
	<div style="width:70px; float:left;">
	Width: 
	</div>
	<div style="width:500px; float:left;"><input type="text" name="width" value="#form.width#" />
	</div>
	</div>
	<div style="width:100%; float:left;">
	<div style="width:70px; float:left;">
	Height:
	</div>
	<div style="width:500px; float:left;"> <input type="text" name="height" value="#form.height#" />
	</div>
	</div>
	<div style="width:100%; float:left;">
	<div style="width:70px; float:left;">
	&nbsp;
	</div>
	<div style="width:500px; float:left;">
	<input type="submit" name="submit1" value="Generate Widget Code" />
	</div></div>
	</form>
	<cfsavecontent variable="output">
	<iframe width="#form.width#" height="#form.height#" src="#request.zos.currentHostName#/events/widget?limit=#form.limit#"></iframe>
	</cfsavecontent>
	<p>Copy and paste the following code into the source code of another web page to embed it.</p>
	<textarea name="widget1" cols="100" rows="3" onclick="this.select();">#htmleditformat(trim(output))#</textarea>
	<br /><br />
	#output#
</cffunction>

<cffunction name="widget" access="remote" localmode="modern">
	<cfscript>
	request.zPageDebugDisabled=true;
	request.zos.functions.zIncludeZOSForms();
	request.zos.functions.zrequirejquery();
	</cfscript>
	<cfsavecontent variable="output">
	<style type="text/css">
	/* <![CDATA[ */
	.sh-47{ margin-left:0px !important;}
	##sh-calendar-widget{display:none;width:100%; float:left;}
	.calendar-link1:link, .calendar-link1:visited{   width:100% !important; color:##253667;}
	.sh-50-22, .sh-50-22:link, .sh-50-22:visited {display:block; margin-left:10px; margin-top:0px;  padding-left:10px; padding-top:5px;font-size:20px; line-height:24px; font-family:'Chaparral W01 SmBd';height:26px; float:left; color:##253667;}
	/* ]]> */
	</style>
	<script type="text/javascript">
	/* <![CDATA[ */
	function fixCalendarWidth(){
		var newWidth=$(window).width()-105;
		if(newWidth < 200){
			$(".sh-49").css("width", newWidth+50);
			$(".sh-50-22").css("font-size", "14px");
			$(".sh-48").css({ 
				"font-size": "14px",
				"line-height": "14px"
			});
			$(".sh-47").css({
				"padding-top": "2px",
				"background-image": "url(/images/shell/circle_03sm.png)",
				"width": "40px",
				"height": "40px",
				"font-size":"12px;"
			});
			$(".calendar-link1:link, .calendar-link1:visited").css("font-size", "14px");
		}else{
			$(".sh-49").css("width", newWidth);
			$(".sh-50-22").css("font-size", "18px");
			$(".sh-48").css({ 
				"font-size": "24px",
				"line-height": "24px"
			});
			$(".sh-47").css({
				"padding-top": "10px",
				"background-image": "url(/images/shell/circle_03.png)",
				"width": "66px",
				"height": "66px",
				"font-size":"16px;"
			});
			$(".calendar-link1:link, .calendar-link1:visited").css("font-size", "18px");
		}
	}
	zArrDeferredFunctions.push(function(){
		fixCalendarWidth();
		$(window).bind("resize", fixCalendarWidth);
		$(window).bind("clientresize", fixCalendarWidth);
		$("##sh-calendar-widget").hide().fadeIn("slow");
	});
	/* ]]> */
	</script>
	</cfsavecontent>
	<div id="sh-calendar-widget">
	<cfscript>
	request.zos.template.setTag("meta", output);
	request.zos.template.setPlainTemplate();
	form.startdate=now();
	form.enddate=dateadd("d", 365, now());
	form.categories="";
	form.categories=request.zos.functions.zso(form, 'categories');
	form.color=request.zos.functions.zso(form, 'color', false, 'orange');
	form.limit=request.zos.functions.zso(form, 'limit', true, 4);
	writeoutput(variables.simpleCalendarSidebar(form.categories, form.limit, form.color, "_blank"));
	</cfscript>
	<a class="sh-50-22" href="/events/index" target="_blank">View The Full Calendar</a>
	</div>
</cffunction>

<cffunction name="init" access="public" localmode="modern">
	<cfscript>
	if(structkeyexists(request, 'eventInitRunOnce')){
		return;
	}
	request.eventInitRunOnce=true;
	oneMonthInFuture=dateadd("d", 365, now());
	if(structkeyexists(form, 'categories')){
		ts9=structnew();
		ts9.name="calendar_categories";
		ts9.value=form.categories;
		ts9.expires=CreateTimeSpan(0,1,0,0); // 1 hour
		request.zos.functions.zcookie(ts9);
	}else if(structkeyexists(cookie, 'calendar_categories')){
		form.categories=cookie.calendar_categories;
	}else{
		form.categories=request.zos.functions.zso(form, 'categories', false, "");
	}
	/*arrCategory=listToArray(form.categories, ",");
	var formCat={};
	for(i=1;i LTE arraylen(arrCategory);i++){
		formCat[arrCategory[i]]=true;
	}
	arr1=request.zos.functions.zSiteOptionGroupStruct("Category");
	var a2=[];
	for(i=1;i LTE arraylen(arr1);i++){
		if(
		arrayAppend(a2, arr1[i].__setId);
	}*/
	form.rootCategoryList=form.categories;//arrayToList(a2,",");
	/*
	rowIndex=1;
	categoryRootLookup={};
	for(i=1;i LTE arraylen(arr1);i++){
		curParent=arr1[i]["Parent Category"];
		rootCategoryId=arr1[i].__setId;
		f=1;
		while(true){
			if(curParent NEQ "" and curParent NEQ "0"){
				found=false;
				for(n=1;n LTE arraylen(arr1);n++){
					if(arr1[n].__setId EQ curParent){
						found=true;
						if(curParent NEQ "" and curParent NEQ "0"){
							curParent=arr1[n]["Parent Category"]; 
							rootCategoryId=arr1[n].__setId;
						}else{
							rootCategoryId=arr1[n].__setId;
						}
						break;
					}
				}
				if(not found){
					break;
				}
			}else{
				break;
			}
			if(f GT 10000){
				throw("Infinite loop occurred.", "Custom");
			}
			f++;
		}
		categoryRootLookup[arr1[i].__setId]=rootCategoryId;
	}
	
	
	arrCategory=listToArray(form.categories, ",");
	for(i=1;i LTE arraylen(arrCategory);i++){
		if(structkeyexists(categoryRootLookup, arrCategory[i])){
			arrCategory[i]=categoryRootLookup[arrCategory[i]];
		}
	}
	form.rootCategoryList=arrayToList(arrCategory, ",");
					*/
	if(structkeyexists(form, 'startdate')){
		ts9=structnew();
		ts9.name="calendar_startdate";
		ts9.value=form.startdate;
		ts9.expires=CreateTimeSpan(0,1,0,0); // 1 hour
		request.zos.functions.zcookie(ts9);
	}else if(structkeyexists(cookie, 'calendar_startdate')){
		form.startdate=cookie.calendar_startdate;
	}else{
		form.startdate=request.zos.functions.zso(form, 'startdate', false, now());
	}
	if(not isdate(form.startdate)){
		form.startdate=now();
	}
	if(structkeyexists(form, 'enddate') and isdate(form.enddate)){
		ts9=structnew();
		ts9.name="calendar_enddate";
		ts9.value=form.enddate;
		ts9.expires=CreateTimeSpan(0,1,0,0); // 1 hour
		request.zos.functions.zcookie(ts9);
	}else if(structkeyexists(cookie, 'calendar_enddate')){
		form.enddate=cookie.calendar_enddate;
	}else{
		form.enddate=request.zos.functions.zso(form, 'enddate', false, oneMonthInFuture);
	}
	if(not isdate(form.enddate)){
		form.enddate=oneMonthInFuture;
	}
	/*if(datediff("d", form.startdate, form.enddate) GT 30){
		form.enddate=oneMonthInFuture;
	}*/
	</cfscript>
</cffunction>

<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	var i=0;
	request.disableCenter=true;
	variables.init();
	request.zos.template.setTag("title", "Events Calendar");
	request.zos.template.setTag("pagetitle", "Events Calendar");
	</cfscript>
	<cfsavecontent variable="request.eventsSidebarHTML">#variables.calendarSidebar()#</cfsavecontent>
	<div id="calendarResultsDiv" class="sn-23">
	
		#variables.displayCalendarResults()#
	</div>
			
</cffunction>



<cffunction name="mobileCalendarSidebar" access="public" localmode="modern">
	<cfscript>
	var ts=0;
	variables.init();
	redirectToCalendar=false;
	if(form[request.zos.urlRoutingParameter] NEQ "/mobile/events/index"){
		redirectToCalendar=true;
	}
	</cfscript>
	<div style="width:100%; float:left;">
		<div class="mobile-search1">
			<input type="text" size="10" name="startdate" id="startdate" readonly="true" value="#dateformat(form.startdate, "mm/dd/yyyy")#" />
		</div>
		<div class="mobile-search1">
			<input type="text" size="10" name="enddate" id="enddate"  readonly="true" value="#dateformat(form.enddate, "mm/dd/yyyy")#" />
		</div>
		<div class="mobile-search1" style="padding-right:0px;">
			<cfset arr1=request.zos.functions.zSiteOptionGroupStruct("Category")> 
			<cfset rowIndex=1>
			<cfscript>
			arrSelectLabel=[];
			arrSelectValue=[];
			rowIndex=0;
			for(n=1;n LTE arraylen(arr1);n++){
				if(arr1[n]["Parent Category"] EQ ""){
					arrayAppend(arrSelectLabel, arr1[n]["Name"]);
					arrayAppend(arrSelectValue, arr1[n].__setId);
					rowIndex++;
				}
			}
			ts = StructNew();
			ts.name = "categories";
			ts.size = 1; // more for multiple select
			ts.output = true; // set to false to save to variable
			ts.selectLabel = "Category"; // override default first element text
			ts.onChange = "getCalendarData();";
			ts.inlineStyle="width:100px;";
			ts.listLabels = arrayToList(arrSelectLabel, chr(9));
			ts.listValues =arrayToList(arrSelectValue,chr(9));
			ts.listLabelsDelimiter = chr(9); // tab delimiter
			ts.listValuesDelimiter = chr(9);
			request.zos.functions.zInputSelectBox(ts);
			</cfscript>
		</div>
	</div>
		<cfsavecontent variable="scriptOutput"><script type="text/javascript">
		/* <![CDATA[ */
		function ajaxCalendarDataCallback(r){
			var r2=eval('(' + r + ')');
			if(r2.success){
				$("##calendarResultsDiv").html(r2.html);
			}
		}
		function getCalendarData(){
			var startdate=document.getElementById("startdate").value;
			var enddate=document.getElementById("enddate").value;
			var arr=[];
			var c=document.getElementById("categories");
			if(c.selectedIndex != 0){
				arr.push(c.options[c.selectedIndex].value);
			}
			var tempObj={};
			tempObj.id="ajaxCalendarData";
			tempObj.url="/events/mobileSearch?startdate="+escape(startdate)+"&enddate="+escape(enddate)+"&categories="+escape(arr.join(","));
			
			tempObj.cache=false;
			tempObj.callback=ajaxCalendarDataCallback;
			tempObj.ignoreOldRequests=true;
			if(#redirectToCalendar#){
				window.location.href=tempObj.url+"&redirectToCalendar=1";	
			}
			zAjax(tempObj);
		}
		zArrDeferredFunctions.push(function(){
			$( "##startdate" ).datepicker({ 
				minDate: -20, 
				maxDate: "+1Y",
				numberOfMonths:1,
				onClose: function( selectedDate ) {
					return;
					$( "##enddate" ).datepicker( "option", "minDate", selectedDate );
					var newdate=new Date(selectedDate);
					var newdate2=new Date(selectedDate);
					newdate.setDate(newdate.getDate() + 30);
					newdate2.setDate(newdate2.getDate() + 180);
					
					year = String(newdate.getFullYear());
					month = String(newdate.getMonth() + 1);
					if (month.length == 1) {
					    month = "0" + month;
					}
					day = String(newdate.getDate());
					if (day.length == 1) {
					    day = "0" + day;
					}
					document.getElementById("enddate").value=month+"/"+day+"/"+year;
					$( "##enddate" ).datepicker( "option", "maxDate", newdate2);
				}
			});
			$( "##enddate" ).datepicker({ 
				minDate: -20, 
				maxDate: "+1Y",
				numberOfMonths:1,
				onClose: function( selectedDate ) {
				//	$( "##startdate" ).datepicker( "option", "maxDate", selectedDate );
				} 
			});
			$( "##startdate" ).bind("change", getCalendarData);
			$( "##enddate" ).bind("change", getCalendarData);
			$( "##allcat" ).bind("click", getCalendarData);
			var categoryCount=parseInt(document.getElementById("categoryCount").value);
			for(var i=1;i<=categoryCount;i++){
				$( "##event"+i ).bind("click", getCalendarData);
			}
		});
		/* ]]> */
		</script></cfsavecontent>
		<cfscript>
		request.zos.template.appendTag("scripts", scriptOutput);
		</cfscript>
	<input type="hidden" name="categoryCount" id="categoryCount" value="#rowIndex-1#" />
</cffunction>


<cffunction name="calendarSidebar" access="public" localmode="modern">
	<cfscript>
	variables.init();
	redirectToCalendar=false;
	if(form[request.zos.urlRoutingParameter] NEQ "/events/index"){
		redirectToCalendar=true;
	}
	</cfscript>
	<div style="width:100%; float:left; font-size:21px; line-height:24px; color:##FFF;padding-bottom:10px;">Dates:</div>
	<div class="sn-18">
		<div class="sn-18-2">Start Date:</div>
		<div class="sn-18-3">
			<input type="text" size="10" name="startdate" id="startdate" value="#dateformat(form.startdate, "mm/dd/yyyy")#" />
		</div>
		<div class="sn-18-2">End Date:</div>
		<div class="sn-18-3">
			<input type="text" size="10" name="enddate" id="enddate" value="#dateformat(form.enddate, "mm/dd/yyyy")#" />
		</div>
		
		<div class="sn-18-3">
			<input type="button" name="but1" onclick="getCalendarData();" value="Search" />
		</div>
		<cfsavecontent variable="scriptOutput"><script type="text/javascript">
		/* <![CDATA[ */
		function ajaxCalendarDataCallback(r){
			var r2=eval('(' + r + ')');
			if(r2.success){
				$("##calendarResultsDiv").html(r2.html);
			}
		}
		function getCalendarData(){
			var categoryCount=document.getElementById("categoryCount");
			if(categoryCount==null){
				return;
			}
			var startdate=document.getElementById("startdate").value;
			var enddate=document.getElementById("enddate").value;
			var categoryCount=parseInt(document.getElementById("categoryCount").value);
			var arr=[];
			for(var i=1;i<=categoryCount;i++){
				var c=document.getElementById('event'+i);
				if(c && c.checked){
					arr.push(c.value);
				}
			}
			var tempObj={};
			tempObj.id="ajaxCalendarData";
			tempObj.url="/events/search?startdate="+escape(startdate)+"&enddate="+escape(enddate)+"&categories="+escape(arr.join(","));
			
			tempObj.cache=false;
			tempObj.callback=ajaxCalendarDataCallback;
			tempObj.ignoreOldRequests=true;
			if((typeof zArrURLParam["zIndex"] != "undefined" && zArrURLParam["zIndex"] != 1)){
				window.location.href=tempObj.url+"&redirectToCalendar=1";
			}else if(#redirectToCalendar#){
				window.location.href=tempObj.url+"&redirectToCalendar=1";	
			}
			zAjax(tempObj);
		}
		zArrDeferredFunctions.push(function(){
			var categoryCount=document.getElementById("categoryCount");
			if(categoryCount==null){
				return;
			}
			$( "##startdate" ).datepicker({ 
				minDate: -20, 
				maxDate: "+1Y",
				numberOfMonths:3,
				onClose: function( selectedDate ) {
					return;
					$( "##enddate" ).datepicker( "option", "minDate", selectedDate );
					$( "##enddate" ).datepicker( "option", "maxDate", "+1Y");//selectedDate );
					var newdate=new Date(selectedDate);
					newdate.setDate(newdate.getDate() + 365);
					
					year = String(newdate.getFullYear());
					month = String(newdate.getMonth() + 1);
					if (month.length == 1) {
					    month = "0" + month;
					}
					day = String(newdate.getDate());
					if (day.length == 1) {
					    day = "0" + day;
					}
					document.getElementById("enddate").value=month+"/"+day+"/"+year;
				}
			});
			$( "##enddate" ).datepicker({ 
				minDate: -20, 
				maxDate: "+1Y",
				numberOfMonths:3,
				onClose: function( selectedDate ) {
				//	$( "##startdate" ).datepicker( "option", "maxDate", selectedDate );
				} 
			});
			$( "##startdate" ).bind("change", getCalendarData);
			$( "##enddate" ).bind("change", getCalendarData);
			$( "##allcat" ).bind("click", getCalendarData);
			var categoryCount=parseInt(document.getElementById("categoryCount").value);
			for(var i=1;i<=categoryCount;i++){
				$( "##event"+i ).bind("click", getCalendarData);
			}
		});
		/* ]]> */
		</script></cfsavecontent>
		<cfscript>
		request.zos.template.appendTag("scripts", scriptOutput);
		</cfscript>
	</div>
	<cfscript>
	if(structkeyexists(form, 'categories')){
		request.zsession.eventCategories=form.categories;
	}
	if(not structkeyexists(request.zsession, 'eventCategories')){
		request.zsession.eventCategories=383;
	}
	</cfscript>
	<input type="hidden" name="categories" value="#request.zsession.eventCategories#" />
	<input type="hidden" name="categoryCount" id="categoryCount" value="1" />
	<!--- <div style="width:100%; float:left; font-size:21px; line-height:24px; color:##FFF;padding-bottom:10px;">Categories:</div>
	<label for="allcat" class="sn-21">
		<input type="checkbox" name="allcat" id="allcat" onclick="var c=parseInt(document.getElementById('categoryCount').value); for(var i=1;i<= c;i++){document.getElementById('event'+i).checked=false;}" <cfif form.categories EQ "">checked="checked"</cfif> class="sn-42" />
		All Categories 
		<span class="category-icon">&nbsp;</span></label>
		 
	Disabled<cfabort>
	<cfscript>
	var arr1=request.zos.functions.zSiteOptionGroupStruct("Event");
	var categoryStruct={};
	var categoryUniqueStruct={};
	var n=1; 
	for(var i=1;i LTE arraylen(arr1);i++){
		var c=arr1[i];
		if(c["Start Date"] NEQ "" and isDate(c["Start Date"]) and c["End Date"] NEQ "" and isDate(c["End Date"])){
			var startDate=parseDatetime(c["Start Date"]);
			var endDate=parseDatetime(c["End Date"]); 
			if(datecompare(startDate, form.startdate) GTE 0 and datecompare(endDate, form.enddate) LTE 0){
				var t=request.zos.functions.zGetSiteOptionGroupSetById(c.category);
				if(structcount(t)){
					if(not structkeyexists(categoryUniqueStruct, t.name)){
						categoryUniqueStruct[t.name]=true;
						categoryStruct[n]={
							id:t.__setId,
							name: t.name
						}
					}
				}
				n++;
			}
		}
	}
	var arrKey=structsort(categoryStruct, "text" ,"asc", "name");  
	</cfscript>
	<!--- <cfset arr1=request.zos.functions.zSiteOptionGroupStruct("Category")>  --->
	<cfset rowIndex=1>
	<cfloop from="1" to="#arraylen(arrKey)#" index="n"> 
		<cfscript>
		var c=categoryStruct[arrKey[n]];
		</cfscript>
		<label for="event#rowIndex#" class="sn-21">
			<input type="checkbox" onclick="if(this.checked){ document.getElementById('allcat').checked=false;}" name="categories" id="event#rowIndex#" value="#c.id#" <cfif form.categories NEQ "" and variables.isInSearchCategory(c.id, form.categories)>checked="checked"</cfif> class="sn-42" /> #htmleditformat(c.name)# </label>
		<cfset rowIndex++>
	</cfloop>  
	<input type="hidden" name="categoryCount" id="categoryCount" value="#rowIndex-1#" /> --->
</cffunction>

<cffunction name="isDateWithinRange" access="public" returntype="boolean" localmode="modern">
	<cfargument name="inputDate" type="string" required="yes">
	<cfargument name="startDate" type="string" required="yes">
	<cfargument name="endDate" type="string" required="yes">
	<cfscript>
	if(arguments.inputDate EQ "" or not isdate(arguments.inputDate)){
		return false;
	}
	if(arguments.startDate EQ "" or not isdate(arguments.startDate)){
		return false;
	}
	if(arguments.endDate EQ "" or not isdate(arguments.endDate)){
		return false;
	} 
	echo(arguments.startDate&":"&arguments.endDate&" | #datediff("d", arguments.startDate, arguments.inputDate)# GTE 0 and #datediff("d", arguments.inputDate, arguments.endDate)# GTE 0<br>");
	if(datediff("d", arguments.startDate, arguments.inputDate) GTE 0 and datediff("d", arguments.inputDate, arguments.endDate) GTE 0){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<!--- 
<cffunction name="mobileDisplayCalendarResults" access="public" localmode="modern">
	<cfscript>
	var ts=0;
	variables.init();
	</cfscript>
	Disabled<cfabort>
	<cfsavecontent variable="output">
		<cfscript>
		arr1=request.zos.functions.zSiteOptionGroupStruct("Event");
		dateStruct={};
		signatureDisplayed=false;
		</cfscript>
		<cfloop from="1" to="#arraylen(arr1)#" index="i">
			<cfscript>
			eventStruct=arr1[i];
			</cfscript>
		</cfloop>
	Disabled<cfabort>
		<cfscript>
		arr1=request.zos.functions.zSiteOptionGroupStruct("Event");
		dateStruct={};
		if(form.method EQ "viewAll"){
			countLimit=0; // show everything, but the date range must always be no more then 30 days.
		}else{
			countLimit=15;
		}
		count=0;
		resultsLimited=false;
		</cfscript>
		<cfloop from="1" to="#arraylen(arr1)#" index="i">
			<cfif (variables.isDateWithinRange(arr1[i]["start date"], form.startdate, form.enddate) or variables.isDateWithinRange(dateformat(arr1[i]["end date"], 'yyyy-mm-dd'), form.startdate, form.enddate)) and variables.isInSearchCategory(arr1[i]["category"], form.rootCategoryList) and arr1[i]["Signature Event"] NEQ "1">
				<cfscript>
				/*if(countLimit NEQ 0 and count GTE countLimit){
					resultsLimited=true;
					break;
				}*/
				count++;
				eventStruct=arr1[i];
				curDate=dateformat(arr1[i]["start date"], "yyyymmdd");
				if(not structkeyexists(dateStruct, curDate)){
					dateStruct[curDate]={};
				}
				</cfscript>
				<cfsavecontent variable="event">
				<a href="#htmleditformat(eventStruct.__url)#" class="mobile-link1" <!--- <cfif count MOD 2 EQ 0>style="background-color:##F2F2F2;"</cfif> --->>
					<span class="mobile-link1-3">#htmleditformat(eventStruct.title)#
					<span class="mobile-button3">VIEW</span></span>
				</a>
					<!--- <div class="sn-36">
						<div class="sn-37">
							<div class="sn-38"><a href="#htmleditformat(eventStruct.__url)#" class="event-link">#htmleditformat(eventStruct.title)#</a></div>
							<div class="sn-39">#request.zos.functions.zParagraphFormat(htmleditformat(eventStruct.summary))#</div>
						</div>
						<a href="#htmleditformat(eventStruct.__url)#" class="event-button">View Details</a>
					</div> --->
				</cfsavecontent>
				<cfscript>
				dateStruct[curDate][eventStruct.__setId]={
					html:event,
					date:eventStruct["start date"],
					dateAsNumber:dateformat(eventStruct["start date"], "yyyymdd")&timeformat(eventStruct["start date"],"HHmmss")
				};
				</cfscript>
			</cfif>
		</cfloop>
		<cfscript>
		arrKey=structkeyarray(dateStruct);
		arraysort(arrKey, "numeric", "asc");
		for(i=1;i LTE arraylen(arrKey);i++){
			arrCurrent=[];
			arrKey2=structsort(dateStruct[arrKey[i]], "numeric", "asc", "dateAsNumber");
			//writeoutput('<br /><br >'&arrKey[i]&' | '&dateformat(arrKey[i], 'm/d/yy')&'<br />');
			for(n=1;n LTE arraylen(arrKey2);n++){
				//writeoutput(dateStruct[arrKey[i]][arrKey2[n]].date);
				curDate=dateStruct[arrKey[i]][arrKey2[n]].date;
				curHTML=dateStruct[arrKey[i]][arrKey2[n]].html;
				if(n EQ arraylen(arrKey2)){
					curHTML=replace(curHTML, ' class="sn-36"', ' class="sn-36" style="border-bottom:none;"');
				}
				arrayAppend(arrCurrent, curHTML);
			}
			
			writeoutput('
		<div class="mobile-link1-container">
			<span class="mobile-link1-circle">
				<span class="mobile-link1-1">#dateformat(curDate, 'mmm')#</span>
				<span class="mobile-link1-2" >#dateformat(curDate, 'd')#</span>
			</span> 
			<div class="mobile-link-box">'&arrayToList(arrCurrent, " ")&'
			</div>
			</div>');
			
		}
		</cfscript>
		<cfif resultsLimited and form.method NEQ "viewAll" and count NEQ 0>
			<div style="text-align:right; width:96%; float:left; padding:2%;">
				<a href="/events/mobileViewAll"" class="mobile-button2"><span>SEE ALL EVENTS</span></a>
			</div>
		</cfif>
		<cfif not signatureDisplayed and count EQ 0>
			<div style="padding:40px;">
			<h2>Please adjust your search</h2>
			<p>No events match your search.</p></div>
			<cfelse>
		<!--- <cfif not signatureDisplayed></div></cfif> --->
		</cfif>
	</cfsavecontent>
	<cfscript>
	return output;
	</cfscript>
</cffunction> --->

<cffunction name="displayCalendarResults" access="private" localmode="modern">
	<cfscript>
	var ts=0;
	</cfscript> 
	<cfsavecontent variable="output">
		<cfscript>
		ts={};
		form.zIndex=application.zcore.functions.zso(form, 'zIndex', true, 1);
		if(form.zIndex LTE 0){
			application.zcore.functions.z301redirect("/events/index");
		}

		if(structkeyexists(form, 'startDate')){
			if(structkeyexists(form, 'startDate') and isdate(form.startDate)){
				ts.startDate=form.startDate;
			}else{
				ts.startDate=now();
			}
			if(structkeyexists(form, 'endDate') and isdate(form.endDate)){
				ts.endDate=form.endDate;
			}else{
				ts.endDate=dateAdd("m", 3, now());
			}
			ts.arrGroupName=["event"];
			ts.limit=15;
			ts.offset=(form.zIndex-1)*ts.limit;
			ts.orderBy="startDateASC"; // startDateASC | startDateDESC
			arr1=application.zcore.siteOptionCom.optionGroupSetFromDatabaseBySearch(ts, request.zos.globals.id);  
			countTotal=application.zcore.siteOptionCom.optionGroupSetCountFromDatabaseBySearch(ts, request.zos.globals.id);
		}else{

			ts=[];
			arrayAppend(ts, {
				type:">=",
				field: "Start Date",
				arrValue:[request.zos.mysqlnow]	
			});
			arrayAppend(ts, {
				type:">",
				field: "End Date",
				arrValue:[request.zos.mysqlnow]	
			});
			
			form.limit=15;
			form.offset=(form.zIndex-1)*form.limit;
			rs2=application.zcore.siteOptionCom.searchOptionGroup("Event", ts, 0, false, form.offset, form.limit, "Start Date", "text", "asc", true);
			arr1=rs2.arrResult;
			countTotal=rs2.count;
		}
		ts=[];
		arrayAppend(ts, {
			type:"<",
			field: "Start Date",
			arrValue:[request.zos.mysqlnow]	
		});
		arrayAppend(ts, {
			type:">",
			field: "End Date",
			arrValue:[request.zos.mysqlnow]	
		});
		
		form.limit=25;
		form.offset=0;
		rs=application.zcore.siteOptionCom.searchOptionGroup("Event", ts, 0, false, form.offset, form.limit, "Start Date", "text", "asc", true);

		ongoing={};
		for(i=1;i LTE arraylen(rs.arrResult);i++){
			eventStruct=rs.arrResult[i];
			savecontent variable="event"{
				echo('	<div class="sn-36">
							<div class="sn-37">
								<div class="sn-38"><a href="#htmleditformat(eventStruct.__url)#" class="event-link">#htmleditformat(eventStruct.title)#</a></div>
								<div class="sn-39">#request.zos.functions.zParagraphFormat(htmleditformat(eventStruct.summary))#</div>
							</div>
							<a href="#htmleditformat(eventStruct.__url)#" class="event-button">View Details</a>
						</div>
						<hr />');
			}
			ongoing[eventStruct.__setId]={
				html:event,
				date:eventStruct["start date"],
				dateAsNumber:dateformat(eventStruct["start date"], "yyyymdd")&timeformat(eventStruct["start date"],"HHmmss")
			};
		} 
		//arr1=request.zos.functions.zSiteOptionGroupStruct("Event");
		dateStruct={};
		signatureDisplayed=false;   

		</cfscript>
		<cfloop from="1" to="#arraylen(arr1)#" index="i">
			<cfscript>
			eventStruct=arr1[i]; 
			</cfscript>
			<cfif arr1[i]["Signature Event"] EQ "1">
			<!--- <cfif (variables.isDateWithinRange(eventStruct["start date"], form.startdate, form.enddate) or variables.isDateWithinRange(dateformat(eventStruct["end date"], 'yyyy-mm-dd'), form.startdate, form.enddate)) and (form.rootCategoryList EQ "" or variables.isInSearchCategory(arr1[i]["category"], form.rootCategoryList))  and eventStruct["Signature Event"] EQ "1">  --->
				<cfscript>
				signatureDisplayed=true; 
				eventStruct=arr1[i];
				curDate=dateformat(arr1[i]["start date"], "yyyymmdd");
				if(not structkeyexists(dateStruct, curDate)){
					dateStruct[curDate]={};
				}
				</cfscript>  
				<div style="width:618px; padding:25px; float:left;  background-color:##e5fde5; border:1px solid ##769373; margin-bottom:20px;">
					<div class="sn-32">
						<div class="sn-33">#dateformat(arr1[i]["start date"], 'mmm')#</div>
						<div class="sn-34">#dateformat(arr1[i]["start date"], 'd')#</div>
					</div>
					<div class="sn-35">
						<div class="sn-36">
							<div class="sn-37">
								<div class="sn-38"><a href="#htmleditformat(eventStruct.__url)#" class="event-link">#htmleditformat(eventStruct.title)#</a></div>
								<div class="sn-39">#request.zos.functions.zParagraphFormat(htmleditformat(eventStruct.summary))#</div>
							</div>
							<a href="#htmleditformat(eventStruct.__url)#" class="event-button">View Details</a>
						</div> 
					</div> 
				</div> 
			</cfif>
		</cfloop> 
	<!--- Disabled<cfabort> --->
		<cfscript>
		//arr1=request.zos.functions.zSiteOptionGroupStruct("Event");
		dateStruct={};
		if(form.method EQ "viewAll"){
			countLimit=0; // show everything, but the date range must always be no more then 30 days.
		}else{
			countLimit=15;
		}
		count=0;
		resultsLimited=false;  
		</cfscript>
		<cfloop from="1" to="#arraylen(arr1)#" index="i"> 
			<!--- <cfif (variables.isDateWithinRange(arr1[i]["start date"], form.startdate, form.enddate) or variables.isDateWithinRange(dateformat(arr1[i]["end date"], 'yyyy-mm-dd'), form.startdate, form.enddate)) and (form.rootCategoryList EQ "" or variables.isInSearchCategory(arr1[i]["category"], form.rootCategoryList)) and arr1[i]["Signature Event"] NEQ "1"> --->
			<cfif arr1[i]["Signature Event"] NEQ "1">
				<cfscript>
				/*if(countLimit NEQ 0 and count GTE countLimit){
					resultsLimited=true;
					break;
				}*/
				count++;
				eventStruct=arr1[i];
				curDate=dateformat(arr1[i]["start date"], "yyyymmdd");
				if(not structkeyexists(dateStruct, curDate)){
					dateStruct[curDate]={};
				}
				</cfscript>
				<cfsavecontent variable="event">
					<div class="sn-36">
						<div class="sn-37">
							<div class="sn-38"><a href="#htmleditformat(eventStruct.__url)#" class="event-link">#htmleditformat(eventStruct.title)#</a></div>
							<div class="sn-39">#request.zos.functions.zParagraphFormat(htmleditformat(eventStruct.summary))#</div>
						</div>
						<a href="#htmleditformat(eventStruct.__url)#" class="event-button">View Details</a>
					</div>
					<hr />
				</cfsavecontent>
				<cfscript> 
				dateStruct[curDate][eventStruct.__setId]={
					html:event,
					date:eventStruct["start date"],
					dateAsNumber:dateformat(eventStruct["start date"], "yyyymdd")&timeformat(eventStruct["start date"],"HHmmss")
				}; 
				</cfscript>
			</cfif>
		</cfloop> 
		<cfscript>
		arrKey2=structsort(ongoing, "numeric", "asc", "dateAsNumber");
		savecontent variable="sidebarContent"{
			if(arraylen(arrKey2)){
				echo('<div style="width:100%;clear:both; float:left;font-size:18px;  font-weight:bold; line-height:24px; padding-bottom:10px; padding-top:20px;">Ongoing Events</div>');
				for(i=1;i LTE arraylen(arrKey2);i++){
					echo(ongoing[arrKey2[i]].html);
				}
			}
		}
		if(not structkeyexists(request, 'eventsSidebarHTML')){
			request.eventsSidebarHTML="";
		}
		request.eventsSidebarHTML&=sidebarContent;
		arrKey=structkeyarray(dateStruct);
		arraysort(arrKey, "numeric", "asc");
		var totalOutput=0;
		var totalOffset=0;
		var curOffset=(form.zIndex-1)*countLimit;
		for(i=1;i LTE arraylen(arrKey);i++){
			arrCurrent=[];
			arrKey2=structsort(dateStruct[arrKey[i]], "numeric", "asc", "dateAsNumber");
			//writeoutput('<br /><br >'&arrKey[i]&' | '&dateformat(arrKey[i], 'm/d/yy')&'<br />');
			var outputThisDate=false;
			for(n=1;n LTE arraylen(arrKey2);n++){
				//writeoutput(dateStruct[arrKey[i]][arrKey2[n]].date);
				curDate=dateStruct[arrKey[i]][arrKey2[n]].date;
				curHTML=dateStruct[arrKey[i]][arrKey2[n]].html;
				if(n EQ arraylen(arrKey2)){
					curHTML=replace(curHTML, ' class="sn-36"', ' class="sn-36" style="border-bottom:none;"');
				}
				//if(totalOffset GTE curOffset and totalOffset LT curOffset+countLimit){
					totalOutput++;
					outputThisDate=true;
					arrayAppend(arrCurrent, curHTML);
				//}
				/*totalOffset++;
				if(totalOutput EQ countLimit){
					break;
				}*/
			}
			if(outputThisDate){
				writeoutput('
				<div class="sn-31">
					<div class="sn-32">
						<div class="sn-33">#dateformat(curDate, 'mmm')#</div>
						<div class="sn-34">#dateformat(curDate, 'd')#</div>
					</div>
					<div class="sn-35">'&arrayToList(arrCurrent, " ")&'
					</div>
				</div>');
			}
			if(totalOutput EQ countLimit){ 
				resultsLimited=true;
				break;
			}
		} 
		//writeoutput(countTotal&" | "&((form.zIndex-1)*15)+countLimit);
		if(form.zIndex NEQ 1 or countTotal GTE ((form.zIndex-1)*15)+countLimit){
			// required
			searchStruct = StructNew();
			searchStruct.count = countTotal;
			searchStruct.index = form.zIndex;
			searchStruct.url = "/events/index?startDate=#urlencodedformat(dateformat(form.startDate, "m/d/yyyy"))#&endDate=#urlencodedformat(dateformat(form.endDate, "m/d/yyyy"))#";
			searchStruct.indexName = "zIndex";
			searchStruct.buttons = 5;
			searchStruct.perpage = countLimit;
			var searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
			writeoutput(searchNav);
		}
		//writeoutput(totalOutput &":"&countLimit&":"&count);
		</cfscript>
		<!--- <cfif resultsLimited and form.method NEQ "viewAll" and count NEQ 0>
			<div class="sn-41"> <a href="/events/viewAll" class="big-button">VIEW ALL</a></div>
		</cfif> --->
		<cfif not signatureDisplayed and count EQ 0>
			<div style="padding:40px;">
			<h2>Please adjust your search</h2>
			<p>No events match your search.</p></div>
			<cfelse> 
		</cfif>
	</cfsavecontent>
	<cfscript>
	return output;
	</cfscript>
</cffunction>




<cffunction name="getParentNavigation" access="public" localmode="modern">
	<cfargument name="categoryId" type="string" required="yes">
	<cfargument name="showCurrentCategory" type="boolean" required="yes">
	<cfscript>
	// loop the categories to build breadcrumb links
	arr1=request.zos.functions.zSiteOptionGroupStruct("Category");
	arrResults=[];
	if(arguments.categoryId NEQ "" and arguments.categoryId NEQ "0"){
		for(i=1;i LTE arraylen(arr1);i++){
			if(arguments.categoryId EQ arr1[i].__setId){
				curParent=arr1[i]["Parent Category"];
				if(arguments.showCurrentCategory){
					arrayappend(arrResults, ' : <a href="'&htmleditformat(arr1[i].__url)&'">'&htmleditformat(arr1[i]["Name"])&'</a>');
				}
				f=1;
				while(true){
					if(curParent NEQ "" and curParent NEQ "0"){
						found=false;
						for(n=1;n LTE arraylen(arr1);n++){
							if(arr1[n].__setId EQ curParent){
								found=true;
								arrayappend(arrResults, ' : <a href="'&htmleditformat(arr1[n].__url)&'">'&htmleditformat(arr1[n]["Name"])&'</a>');
								if(curParent NEQ "" and curParent NEQ "0"){
									curParent=arr1[n]["Parent Category"]; 
								}
								break;
							}
						}
						if(not found){
							break;
						}
					}else{
						break;
					}
					if(f GT 100){
						throw("Infinite loop occurred in parent navigation.", "Custom");
					}
					f++;
				}
			}
		}
	}
	arrReturn=[];
	for(i=arraylen(arrResults);i GTE 1;i--){
		arrayAppend(arrReturn, arrResults[i]);	
	}
	return arrayToList(arrReturn, "");
	</cfscript>
</cffunction>

<cffunction name="isInSearchCategory" access="public" returntype="boolean" localmode="modern">
	<cfargument name="currentCategory" type="string" required="yes">
	<cfargument name="categoryList" type="string" required="yes">
	<cfscript>
	if(arguments.categoryList EQ ""){
		return true;
	}
	if(arguments.currentCategory EQ ""){
		return false;
	}
	if(find(","&arguments.currentCategory&",", ","&arguments.categoryList&",") NEQ 0){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="viewAll" access="remote" localmode="modern">
	<cfscript>
	this.index();
	</cfscript>
</cffunction>


	

<cffunction name="simpleCalendarSidebar" access="public" localmode="modern">
	<cfargument name="categories" type="string" required="no" default="">
	<cfargument name="limit" type="numeric" required="no" default="4">
	<cfargument name="color" type="string" required="no" default="orange">
	<cfargument name="target" type="string" required="no" default="">
	Disabled<cfabort>
	<cfsavecontent variable="output">
		
		<cfset arr1=request.zos.functions.zSiteOptionGroupStruct("Event")> 
		<cfscript>
		variables.init(); // default dates are now and 30 days into future
		sortStruct={};
		for(n=1;n LTE arrayLen(arr1);n++){
			if(arr1[n]["start date"] NEQ ""){
				sortStruct[arr1[n].__setId] = { date: arr1[n]["start date"], data: arr1[n]};
			}
		}
		arrKeys=structsort(sortStruct, "numeric", "asc", "date");
		count=0;
		dateCSS={};
		if(arguments.color EQ "blue"){
			dateCSS.circle="sh-98";
			dateCSS.line1small="sh-98-2";
			dateCSS.line1="sh-47-22";
			dateCSS.line2small="sh-98-2";
			dateCSS.line2="sh-99";
			dateCSS.link="sh-49-2";
		}else{
			// orange
			dateCSS.circle="sh-47";
			dateCSS.line1small="sh-98-2";
			dateCSS.line1="sh-47-22";
			dateCSS.line2small="sh-98-2";
			dateCSS.line2="sh-48";
			dateCSS.link="sh-49";
		}
		</cfscript>
		<cfloop from="1" to="#arraylen(arrKeys)#" index="n">  
			<cfset curStruct=sortStruct[arrKeys[n]].data> 
			<cfif count LT arguments.limit and (variables.isDateWithinRange(dateformat(curStruct["start date"], 'yyyy-mm-dd'), form.startdate, form.enddate) or variables.isDateWithinRange(dateformat(curStruct["end date"], 'yyyy-mm-dd'), form.startdate, form.enddate)) and (arguments.categories EQ "" or variables.isInSearchCategory(curStruct["category"], arguments.categories))>
				
					<a href="#htmleditformat(curStruct.__url)#" class="calendar-link1" <cfif arguments.target NEQ "">target="#arguments.target#"</cfif>> 
					<span class="#dateCSS.circle#">
						<cfif curStruct["End Date"] NEQ "" and dateformat(curStruct["Start Date"], "mmm") NEQ dateformat(curStruct["End Date"], "mmm")>
							<span class="#dateCSS.line1small#">#dateformat(curStruct["Start Date"], "m/d")#</span><span class="#dateCSS.line2small#">to</span>
							<span class="#dateCSS.line2small#">#dateformat(curStruct["End Date"], "m/d")#</span> 
						<cfelse>
							<span class="#dateCSS.line1#">#dateformat(curStruct["Start Date"], "mmm")#</span>
							<cfif curStruct["End Date"] NEQ "" and dateformat(curStruct["Start Date"], "d") NEQ dateformat(curStruct["End Date"], "d")>
							<span class="#dateCSS.line2small#" <!--- style="font-size:16px;" --->>#dateformat(curStruct["Start Date"], "d")#-#dateformat(curStruct["End Date"], "d")#</span>
							<cfelse>
							<span class="#dateCSS.line2#">#dateformat(curStruct["Start Date"], "d")#</span>
							</cfif>
						</cfif>
					</span> 
					<span class="#dateCSS.link#">#htmleditformat(curStruct["Title"])#</span>
					 </a> 
				<cfset count++>
			</cfif>
		</cfloop> 
	</cfsavecontent>
	<cfscript>
	return output;
	</cfscript>
</cffunction>

<cffunction name="search" access="remote" localmode="modern">
	<cfscript>
	variables.init();
	if(structkeyexists(form, 'redirectToCalendar')){
		request.zos.functions.zRedirect('/events/index');
	}
	output=variables.displayCalendarResults();
	writeoutput('{"success": true, "html":"#jsstringformat(output)#"}');
	header name="x_ajax_id" value="#request.zos.functions.zso(form, 'x_ajax_id', false, 'search')#";
	request.zos.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="mobileSearch" access="remote" localmode="modern">
	<cfscript>
	variables.init();
	if(structkeyexists(form, 'redirectToCalendar')){
		request.zos.functions.zRedirect('/mobile/events/index');
	}
	output=variables.mobileDisplayCalendarResults();
	writeoutput('{"success": true, "html":"#jsstringformat(output)#"}');
	header name="x_ajax_id" value="#form.x_ajax_id#";
	request.zos.functions.zabort();
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>