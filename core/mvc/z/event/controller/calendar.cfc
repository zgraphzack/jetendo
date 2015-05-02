<cfcomponent>
<cfoutput> 

<cffunction name="isDateWithinRange" access="public" returntype="boolean">
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
	if(datediff("d", arguments.startDate, arguments.inputDate) GTE 0 and datediff("d", arguments.inputDate, arguments.endDate) GTE 0){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="displayCalendarResults" access="private" localmode="modern">
	<cfscript>
	var ts=0;
	if(structkeyexists(form, 'categories')){
		local.ts9=structnew();
		local.ts9.name="calendar_categories";
		local.ts9.value=form.categories;
		local.ts9.expires=CreateTimeSpan(0,1,0,0); // 1 hour
		request.zos.functions.zcookie(local.ts9);
	}else if(structkeyexists(cookie, 'calendar_categories')){
		form.categories=cookie.calendar_categories;
	}else{
		form.categories=request.zos.functions.zso(form, 'categories', false, "");
	}
	</cfscript>
	<cfsavecontent variable="output">
		<cfscript>
		arr1=request.zos.functions.zSiteOptionGroupStruct("Event");
		dateStruct={}; 
		form.rootCategoryList=application.zcore.functions.zso(form, 'categories');
		</cfscript> 
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
			<cfif (isDateWithinRange(arr1[i]["start date"], form.startdate, form.enddate) or isDateWithinRange(dateformat(arr1[i]["end date"], 'yyyy-mm-dd'), form.startdate, form.enddate)) and isInSearchCategory(arr1[i]["category"], form.rootCategoryList)>
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
							<div style="width:100%; float:left;"><h3><a href="#htmleditformat(eventStruct.__url)#" class="event-link">#htmleditformat(eventStruct.title)#</a></h3></div>
							<div style="width:100%; float:left;">#request.zos.functions.zParagraphFormat(htmleditformat(eventStruct.summary))#</div>
						</div>
						<a href="#htmleditformat(eventStruct.__url)#" class="event-button">More Info</a>
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
		arrKey=structkeyarray(dateStruct);
		arraysort(arrKey, "numeric", "asc");
		var totalOutput=0;
		var totalOffset=0;
		form.zIndex=application.zcore.functions.zso(form, 'zIndex', true, 1);
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
				if(totalOffset GTE curOffset and totalOffset LT curOffset+countLimit){
					totalOutput++;
					outputThisDate=true;
					arrayAppend(arrCurrent, curHTML);
				}
				totalOffset++;
				if(totalOutput EQ countLimit){
					break;
				}
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
		
		if(count GT countLimit){
			// required
			searchStruct = StructNew();
			searchStruct.count = count;
			searchStruct.index = form.zIndex;
			searchStruct.url = "/events/index";
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
		<cfif count EQ 0>
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
	arrCat=listToArray(arguments.currentCategory, ",");
	for(i=1;i LTE arraylen(arrCat);i++){
		if(find(","&arrCat[i]&",", ","&arguments.categoryList&",") NEQ 0){
			return true;
		}
	}
	return false;
	</cfscript>
</cffunction>

<cffunction name="search" access="remote" localmode="modern">
	<cfscript> 
	if(structkeyexists(form, 'redirectToCalendar')){
		request.zos.functions.zRedirect('/calendar/index');
	}
	output=displayCalendarResults();
	writeoutput('{"success": true, "html":"#jsstringformat(output)#"}');
	header name="x_ajax_id" value="#request.zos.functions.zso(form, 'x_ajax_id', false, 'search')#";
	request.zos.functions.zabort();
	</cfscript>
</cffunction>


<cffunction name="results" access="remote" localmode="modern">
	<cfscript>
	var i=0;
	init();
	request.disableCenter=true; 
	request.zos.template.setTag("title", "Events Search Results");
	request.zos.template.setTag("pagetitle", "Events Search Results");
	</cfscript> 
	<div id="calendarResultsDiv" class="sn-23">
	
		#displayCalendarResults()#
	</div>
	<script type="text/javascript">
	zArrDeferredFunctions.push(function(){
		getCalendarData();
	});
	</script>
			
</cffunction>

<cffunction name="view" access="remote" localmode="modern">
	<cfargument name="query" type="query" required="yes">
	<cfscript>
	preview=false;
	if(structkeyexists(form, 'zpreview') and application.zcore.user.checkGroupAccess("member")){
		preview=true;
	}
	pageStruct=application.zcore.functions.zGetSiteOptionGroupSetById(form.site_x_option_group_set_id, request.zos.globals.id, ["Event"], preview);  
	if(structcount(pageStruct) EQ 0){
		application.zcore.functions.z404("Event doesn't exist or is not active.");
	}
	</cfscript>   
	<cfsavecontent variable="scriptOutput">
	<script src="https://maps.googleapis.com/maps/api/js?v=3.exp&amp;sensor=false"></script>
	<script type="text/javascript">
	/* <![CDATA[ */
	function mapSuccessCallback(){
		$("##mapContainerDiv").show();
	}
	zArrDeferredFunctions.push(function(){
		$("##eventSlideshowDiv").cycle({timeout:3000, speed:1200}); 
		<cfif pageStruct.address NEQ "">
			var optionsObj={ zoom: 13 };
			<cfif pageStruct["map coordinates"] NEQ "">
				arrLatLng=[#pageStruct["map coordinates"]#]; 
				zCreateMapWithLatLng("mapDivId", arrLatLng[0], arrLatLng[1], optionsObj, mapSuccessCallback);  
			<cfelse>
				zCreateMapWithAddress("mapDivId", "#jsstringformat(pageStruct.address&', '&pageStruct["City"]&", "&pageStruct["State"]&" "&pageStruct["Zip"])#", optionsObj, mapSuccessCallback); 
			</cfif>
		</cfif> 
	});
	/* ]]> */
	</script>
	<!--[if gte IE 7]>  
	<style type="text/css">
	.sn-79-2{display:none; }
	</style>
	<![endif]--> 
		<style type="text/css">
			.eventSlideshow img{ border:none; padding:none;}
			</style>
	</cfsavecontent>
	<cfscript>
	request.zos.template.appendTag("meta", scriptOutput); 
	request.zos.template.setTag("title", pageStruct["title"]);
	request.zos.template.setTag("pagetitle", pageStruct["title"]);
	</cfscript> 
	<a href="##" onclick="window.print();" style="display:block; float:right; padding:10px; border-radius:10px; background-color:##EEE; border:1px solid ##CCC; margin-top:-40px;">Print</a>
	<div style="width:100%; float:left;"> 
		<div style="width:320px; float:left;"> 
			
			<div style="width:100%; float:left;">
				<cfif pageStruct["address"] NEQ "">
					<h2>Location:</h2>
					<p>#htmleditformat(pageStruct["address"])#<br />
					#htmleditformat(pageStruct["City"]&", "&pageStruct["State"]&" "&pageStruct["Zip"])#</p>
					<p><a href="##directions">Get Directions</a></p>
				</cfif> 
				<h2>Time:</h2>
				<p> 
				<cfif pageStruct["start date"] EQ pageStruct["end date"]>
					#pageStruct["start date"]#
				<cfelse>
					#pageStruct["start date"]# to #pageStruct["end date"]#
				</cfif>
				</p>
				<cfif pageStruct["phone"] NEQ "">
					<h2>Contact:</h2>
					<p><a class="zPhoneLink">#htmleditformat(pageStruct["phone"])#</a></p>
				</cfif>
				<cfif left(pageStruct["web site URL"], 7) EQ "http://" or left(pageStruct["web site URL"], 8) EQ "https://">
					<h2>Website:</h2>
					<p><a href="#htmleditformat(pageStruct["web site URL"])#" target="_blank">#htmleditformat(pageStruct["web site URL"])#</a></p>
				</cfif>  
				<cfif (structkeyexists(pageStruct, "file 1") and pageStruct["file 1"] NEQ "") or (structkeyexists(pageStruct, "file 2") and pageStruct["file 2"] NEQ "")>
					<h2>File(s):</h2>
					<p><cfif structkeyexists(pageStruct, "file 1") and pageStruct["file 1"] NEQ "">
						<a href="#htmleditformat(pageStruct["file 1"])#" target="_blank"><cfif pageStruct["file 1 label"] NEQ "">#pageStruct["file 1 label"]#<cfelse>File 1</cfif></a>
						</cfif>
						<cfif structkeyexists(pageStruct, "file 2") and pageStruct["file 2"] NEQ "">
						<br /><a href="#htmleditformat(pageStruct["file 2"])#" target="_blank"><cfif pageStruct["file 2 label"] NEQ "">#pageStruct["file 2 label"]#<cfelse>File 2</cfif></a>
						</cfif></p>
				</cfif>
				<h2>Share:</h2>
				<!--- <a href="##" onclick="zShowModalStandard('/z/misc/share-with-friend/index?title=#urlencodedformat(pageStruct.title)#&amp;link=#urlencodedformat(request.zos.globals.domain&pageStruct.__url)#', 540, 630);return false;" rel="nofollow" style="display:block; float:left; margin-right:10px;"><img src="/images/shell/share_03.jpg" alt="Share by email" width="30" height="30" /></a> --->
				<a href="https://www.facebook.com/sharer/sharer.php?u=#urlencodedformat(request.zos.globals.domain&pageStruct.__url)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/images/shell/share_05.jpg" alt="Share on facebook" width="30" height="30" /></a>
				<a href="https://twitter.com/share?url=#urlencodedformat(request.zos.globals.domain&pageStruct.__url)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/images/shell/share_07.jpg" alt="Share on twitter" width="30" height="30" /></a>
				<a href="http://www.linkedin.com/shareArticle?mini=true&amp;url=#urlencodedformat(request.zos.globals.domain&pageStruct.__url)#&amp;title=#urlencodedformat(pageStruct.title)#&amp;summary=&amp;source=#urlencodedformat('Space Coast Fun Guide')#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/images/shell/share_09.jpg" alt="Share on linkedin" width="30" height="30" /></a>
					
			</div> 
		</div>
		<div class="eventSlideshow" style=" padding-left:35px;width:300px; float:left;">
			<cfif structkeyexists(pageStruct, '__image_library_id')>
				<cfscript>
				ts=structnew();
				ts.output=true;
				ts.image_library_id=pageStruct.__image_library_id;
				ts.forceSize=true;
				ts.size="300x230";
				ts.thumbSize="70x40";
				ts.layoutType="galleryview-1.1";
				ts.crop=0;
				ts.offset=0;
				ts.limit=0; // zero will return all images
				arrImage=request.zos.imageLibraryCom.displayImages(ts);  
				ts.output=false;
				ts.size="640x400";
				ts.layoutType="";
				var arrImage=request.zos.imageLibraryCom.displayImages(ts);
				var i=0;
				</cfscript>
				<div style="display:block; width:100%; height:30px; margin-bottom:10px; overflow:hidden; line-height:30px; font-size:18px; float:left;">  
					<cfloop from="1" to="#arrayLen(arrImage)#" index="i">
						<a href="#arrImage[i].link#" title="Image #i#" rel="placeImageColorbox" class="placeImageColorbox">View larger images</a><br />
					</cfloop>
					<cfscript>
					request.zos.template.appendTag("meta", request.zos.skin.includeCSS("/z/javascript/jquery/colorbox/example3/colorbox.css")&request.zos.skin.includeJS("/z/javascript/jquery/colorbox/colorbox/jquery.colorbox-min.js")&'<style type="text/css">##cboxNext, ##cboxPrevious{display:none !important;}</style>');
					request.zos.skin.addDeferredScript('$("a[rel=placeImageColorbox]").colorbox({photo:true, slideshow: true});');
					</cfscript>
				</div>
			</cfif>  
		</div>
			<div style="width:100%; padding-top:10px; padding-bottom:10px; float:left;">
				<h2>Event Description</h2>
				<div style="margin-bottom:20px; float:left; width:100%;">#application.zcore.functions.zparagraphformat(pageStruct["body text"])#</div>


				<h2 id="directions">Map &amp; Directions</h2>
				<cfif pageStruct["State"] NEQ "">
					<div id="mapContainerDiv" style="width:100%; float:left; clear:both;">
						<div  style="width:100%; height:300px; float:left;" id="mapDivId"></div> 
						<div style="width:100%; padding-top:5px; float:left;"> <a href="https://maps.google.com/maps?q=#urlencodedformat(pageStruct["address"]&", "&pageStruct["City"]&", "&pageStruct["State"]&" "&pageStruct["Zip"])#" target="_blank">Launch In Google Maps</a></div>
					</div>
				</cfif>
			</div>
	</div> 
					 
	<div style="width:100%; float:left;padding-top:20px; font-size:18px; line-height:21px;"><a href="/calendar/index" class="sf-28-2">
	<hr style="margin-top:10px; margin-bottom:10px;" />
	Back To Calendar</a></div> 
</cffunction>

<cffunction name="searchReindex" localmode="modern" access="public" roles="member">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="tableStruct" type="struct" required="yes">
	<cfscript>
	arguments.tableStruct.search_title=arguments.dataStruct.title;  
	arguments.tableStruct.search_fulltext=request.zos.functions.zCleanSearchText(
		arguments.dataStruct.title&" "&
		arguments.dataStruct.phone&" "& 
		arguments.dataStruct["State"]&" "&
		arguments.dataStruct["Zip"]&" "&
		arguments.dataStruct["Web Site URL"]&" "&
		arguments.dataStruct["summary"]&" "&
		arguments.dataStruct["Address"]&" "&
		arguments.dataStruct["body text"], false);
	arguments.tableStruct.search_summary=request.zos.functions.zStripHTMLTags(arguments.dataStruct["body text"]);
	arguments.tableStruct.search_url=arguments.dataStruct.__url;
	arguments.tableStruct.search_image="";
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	
	form.startDate=application.zcore.functions.zso(form, 'startDate', false, dateformat(now(), "m/d/yyyy"));
	form.endDate=application.zcore.functions.zso(form, 'endDate', false, dateformat(dateadd("d", 90, now()), "m/d/yyyy"));
	if(not isdate(form.startDate)){
		form.startDate=dateformat(now(), "m/d/yyyy");
	}else{
		form.startDate=dateformat(form.startDate, "m/d/yyyy");
	}
	if(not isdate(form.endDate)){
		form.endDate=dateformat(now(), "m/d/yyyy");
	}else{
		form.endDate=dateformat(form.endDate, "m/d/yyyy");
	}
	</cfscript>
</cffunction>

<cffunction name="calendarSidebar" localmode="modern" access="public">
	<cfargument name="disableAutoSearch" type="boolean" required="yes">
	<cfscript>
	init();
	</cfscript>
	<cfif arguments.disableAutoSearch>
		<script type="text/javascript">
		var disableCalendarSearch=true;
		</script>
		<div class="sh-mobilesearch">
		<form action="/calendar/results" method="get">
	</cfif>
	<div class="sh-33-2">
		<h2 style="color:##064775;font-size:30px;">Event Search</h2></div>
	<h2>Dates</h2>
	<h3>Start Date</h3>
	<p><input type="text" name="startdate" id="startdate<cfif arguments.disableAutoSearch>2</cfif>" class="datePicker" style="background-image:url(/images/shell/a_06.jpg); padding:5px; background-position:5px 5px; background-repeat:no-repeat; border:1px solid ##CCC; width:145px; font-weight:bold; color:##898989; padding-left:30px;" value="#form.startDate#" /></p>
	<h3>End Date</h3>
	<p><input type="text" name="enddate" id="enddate<cfif arguments.disableAutoSearch>2</cfif>" class="datePicker" style="background-image:url(/images/shell/a_06.jpg); padding:5px; background-position:5px 5px; background-repeat:no-repeat; border:1px solid ##CCC; width:145px; font-weight:bold; color:##898989; padding-left:30px;" value="#form.endDate#" /></p>
	
	<h2>Type of Event</h2>
	<h3>
	<cfscript>arr1=application.zcore.functions.zSiteOptionGroupStruct("Event Category");
	arrCategory=listToArray(application.zcore.functions.zso(form, 'categories'), ",");
	uniqueCat={};
	for(i=1;i LTE arraylen(arrCategory);i++){
		uniqueCat[arrCategory[i]]=true;
	}
	</cfscript>
	<cfloop from="1" to="#arrayLen(arr1)#" index="i1">
		<cfscript>curStruct1=arr1[i1];
		checked="";
		if(structkeyexists(uniqueCat, curStruct1.__setId)){
			checked=' checked="checked"';
		}
		</cfscript>
		<input type="checkbox" name="categories" class="categorySidebar<cfif arguments.disableAutoSearch>2</cfif>" id="categories#i1#<cfif arguments.disableAutoSearch>2</cfif>" value="#arr1[i1].__setId#" #checked# /> <label for="categories#i1#">#curStruct1["Name"]#</label><br />
	</cfloop>
	</h3>
	<input type="hidden" name="categoryCount" id="categoryCount<cfif arguments.disableAutoSearch>2</cfif>" value="#arrayLen(arr1)#" />
	<cfif arguments.disableAutoSearch>
		<input type="submit" name="search11" value="Search" style="padding:10px; font-weight:bold; font-size:16px;" />
		</form>
		<hr />
		<h2>Upcoming Events</h2>
		</div>
	</cfif>
	
</cffunction>

<cffunction name="list" access="remote" localmode="modern">
	<cfscript>
	
	application.zcore.template.setTag("title", "Event Calendar");
	application.zcore.template.setTag("pagetitle", "Event Calendar");
	
	echo('<div style="width:100%; float:left;">'&calendarSidebar(true)&'</div>');
	</cfscript>


	<cfscript>arr1=application.zcore.functions.zSiteOptionGroupStruct("Event");
	dateStruct={};
	nowDate=dateformat(now(), "yyyymmdd")&"000000";
	for(i=1;i LTE arraylen(arr1);i++){
		cDate=dateformat(arr1[i]["start date"], "yyyymmdd")&timeformat(arr1[i]["start date"], "HHmmss");
		if(cDate GT nowDate){
			dateStruct[i] = {
				dateAsNumber:cDate,
				data: arr1[i]
			};
		}
	}
	arrK=structsort(dateStruct, "numeric", "asc", "dateAsNumber");
	arr1=[];
	for(i=1;i LTE arraylen(arrK);i++){
		arrayAppend(arr1, dateStruct[arrK[i]].data);
	}
	</cfscript>  
	<cfloop from="1" to="#arrayLen(arr1)#" index="i1">
		<cfscript>curStruct1=arr1[i1];</cfscript>
		<h2><a href="#curStruct1.__url#">#curStruct1["Title"]#</a></h2>
		<p>Time: <cfif curStruct1["start date"] EQ curStruct1["end date"]>
				#curStruct1["start date"]#
			<cfelse>
				#curStruct1["start date"]# to #curStruct1["end date"]#
			</cfif></p>
	<p><a href="#curStruct1.__url#">View</a></p>
	<hr style="margin-top:10px; margin-bottom:10px;" />
	</cfloop>

</cffunction>
	
<cffunction name="index" access="remote" localmode="modern">
    <cfscript>
	var ts=structnew();
	ts.content_unique_name="/calendar/index";
	application.zcore.app.getAppCFC("content").includePageContentByName(ts);

	application.zcore.template.setTag("title", "Upcoming Events");
	application.zcore.functions.zRequireJqueryUI();

	arrEvent=[];
	</cfscript> 
	<h1>Calendar</h1>
	<cfscript>arr1=application.zcore.functions.zSiteOptionGroupStruct("Event");
	dateStruct={};
	nowDate=dateformat(now(), "yyyymmdd")&"000000";
	for(i=1;i LTE arraylen(arr1);i++){
		cDate=dateformat(arr1[i]["start date"], "yyyymmdd")&timeformat(arr1[i]["start date"], "HHmmss");
		if(cDate GT nowDate){
			dateStruct[i] = {
				dateAsNumber:cDate,
				data: arr1[i]
			};
		}
	}
	arrK=structsort(dateStruct, "numeric", "asc", "dateAsNumber");
	arr1=[];
	for(i=1;i LTE arraylen(arrK);i++){
		arrayAppend(arr1, dateStruct[arrK[i]].data);
	}
	</cfscript>  
	<div id="calendarResultsDiv" style="width:100%; float:left;">

		<div id="calendarHomeTabs">
			<ul>
				<li><a href="##calendarTab1">List View</a></li>
				<li><a href="##calendarTab2">Calendar View</a></li>
			</ul>
			<div style="width:100%; float:left;">
				<div id="calendarTab1">
					<cfloop from="1" to="#arrayLen(arr1)#" index="i1">
						<cfscript>curStruct1=arr1[i1];</cfscript>

						<div class="sn-36">
							<div class="sn-37">
								<div style="width:100%; float:left;"><h3><a href="#htmleditformat(curStruct1.__url)#" class="event-link">#htmleditformat(curStruct1.title)#</a></h3></div>
								<div style="width:100%; float:left;">#request.zos.functions.zParagraphFormat(htmleditformat(curStruct1.summary))#<br />Time: <cfif curStruct1["start date"] EQ curStruct1["end date"]>
										#curStruct1["start date"]#
									<cfelse>
										#curStruct1["start date"]# to #curStruct1["end date"]#
									</cfif>
									</div>
							</div>
							<a href="#htmleditformat(curStruct1.__url)#" class="event-button">More Info</a>
						</div>
						<hr /> 
					</cfloop>
				</div>
				<div id="calendarTab2" style="display:none;">
					<div id="calendarFullPageDiv"></div>
				</div>
			</div>
		</div>
	</div>
	</div>
	<cfscript>
	application.zcore.functions.zRequireFullCalendar();
	</cfscript>
	<script>

	zArrDeferredFunctions.push(function() {
		$("##calendarHomeTabs").tabs({
			active:0,
			activate:function(e, e2){ 
				if(e2.newPanel[0].id == "calendarTab2"){

					$('##calendarFullPageDiv').fullCalendar({
					    eventClick: function(calEvent, jsEvent, view) {
							if(typeof calEvent.link != "undefined"){
								window.location.href=calEvent.link;

							}
							return;
					    },
						header: {
							left: 'prev,next today',
							center: 'title',
							right: 'month,basicWeek,basicDay'
						},
						defaultDate: '#dateformat(now(), "yyyy-mm-dd")#',
						editable: false,
						events: [ 
							<cfscript>
							for(i1=1;i1 LTE arraylen(arr1);i1++){
								curStruct1=arr1[i1];
								if(i1 NEQ 1){
									echo(',');
								}
								echo('{
									title:"'&jsstringformat(curStruct1["Title"])&'",'&
									'start:$.fullCalendar.moment.parseZone("'&dateformat(curStruct1["Start Date"],"yyyy-mm-dd")&"T"&timeformat(curStruct1["Start Date"], "HH:mm:ss")&'"),'&
									'link:"'&curStruct1.__url&'"');
								if(curStruct1["Start Date"] NEQ curStruct1["End Date"]){
									echo(', end:$.fullCalendar.moment.parseZone("'&dateformat(curStruct1["End Date"],"yyyy-mm-dd")&"T"&timeformat(curStruct1["End Date"], "HH:mm:ss")&'")');
								}
								echo('}');
							}
							</cfscript>]
					});
					if(navigator.userAgent.indexOf("MSIE 7.0") != -1){
						$(".fc-icon-left-single-arrow").html("&lt;");
						$(".fc-icon-right-single-arrow").html("&gt;");
					}
				}
			}
		});
		
	});
	</script>  
</cffunction>
</cfoutput>
</cfcomponent>