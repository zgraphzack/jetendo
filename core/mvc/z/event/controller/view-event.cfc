<cfcomponent>
<cfoutput>
<cffunction name="displayEvent" localmode="modern" access="private">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	struct=arguments.struct;


	eventCom=application.zcore.app.getAppCFC("event");
	//writedump(struct);
 	eventCalendarId=listGetAt(struct.event_calendar_id, 1);
	db.sql="SELECT * FROM #db.table("event_calendar", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	event_calendar_deleted=#db.param(0)# and 
	event_calendar_id = #db.param(eventCalendarId)# ";
	qCalendar=db.execute("qCalendar");

	calendarLink="##";
	for(row in qCalendar){
		calendarLink=eventCom.getCalendarURL(row);
	}
	</cfscript>  
	<cfif structkeyexists(form, 'print')>
		<cfsavecontent variable="local.metaOutput">
		<style type="text/css">
		/* <![CDATA[ */
		
		/* ]]> */
		</style>
		</cfsavecontent>
		<cfscript>
		request.zos.template.appendTag("stylesheets", local.metaOutput);
		</cfscript>
	</cfif>  
	<cfsavecontent variable="scriptOutput">
		<script src="https://maps.googleapis.com/maps/api/js?v=3.exp&amp;sensor=false"></script>
		<script type="text/javascript">
		/* <![CDATA[ */
		function zEventMapSuccessCallback(){
			$("##zEventViewMapContainer").show();
		}
		zArrDeferredFunctions.push(function(){
			//$("##zEventSlideshowDiv").cycle({timeout:3000, speed:1200});
			//$( "##startdate" ).datepicker();
			//$( "##enddate" ).datepicker();
			<cfif struct.event_address NEQ "">
				var optionsObj={ zoom: 13 };
				<cfif struct.event_map_coordinates NEQ "">
					arrLatLng=[#struct.event_map_coordinates#]; 
					zCreateMapWithLatLng("zEventMapDivId", arrLatLng[0], arrLatLng[1], optionsObj, zEventMapSuccessCallback);  
				<cfelseif structkeyexists(cityStruct, 'name')>
					zCreateMapWithAddress("zEventMapDivId", "#jsstringformat(struct.event_address&', '&struct.event_city&", "&struct.event_state&" "&struct.event_zip&" "&application.zcore.functions.zCountryAbbrToFullName(struct.event_country))#", optionsObj, zEventMapSuccessCallback); 
				</cfif>
			</cfif> 
		});
		/* ]]> */
		</script> 
	</cfsavecontent>
	<cfscript>
	request.zos.template.appendTag("meta", scriptOutput); 
	request.zos.template.setTag("title", struct.event_name);
	request.zos.template.setTag("pagetitle", struct.event_name);

	countryName=application.zcore.functions.zCountryAbbrToFullName(struct.event_country);

	</cfscript>
	<!--- <cfsavecontent variable="request.eventsSidebarHTML">#local.eventsCom.calendarSidebar()#</cfsavecontent>  --->
					
	<div class="zEventView1-4">
		<div class="zEventView1-1">Date:</div>
		<div class="zEventView1-2">
		#eventCom.getDateTimeRangeString(struct)# 
		</div>
	</div>

	<cfscript>

	savecontent variable="slideShowOut"{
		echo('<div class="zEventView1-3">');
		ts=structnew();
		ts.output=true;
		ts.size=request.zos.globals.maximagewidth&"x"&(request.zos.globals.maximagewidth*.6);
		ts.image_library_id=struct.event_image_library_id;
		ts.layoutType=application.zcore.imageLibraryCom.getLayoutType(struct.event_image_library_layout);
		ts.forceSize=true; 
		ts.crop=0;
		ts.offset=0;
		ts.limit=0;  
		arrImage=request.zos.imageLibraryCom.displayImages(ts); 
		ts.layoutType="";
		ts.output=false;
		ts.size="1900x1080";
		arrImage2=request.zos.imageLibraryCom.displayImages(ts); 
		echo('<div id="zEventViewLightGallery" class="zEventView1-larger">  ');
		for(i=1;i LTE arraylen(arrImage2);i++){
			echo('<a href="#arrImage2[i].link#" title="Image #i#" onclick="return false;" ');
			if(i NEQ 1){
				echo('style="display:none;"');
			}
			echo('>View larger images</a>');
		}
		echo('</div>');
		application.zcore.functions.zSetupLightbox("zEventViewLightGallery");
		echo('</div>');
	}
	if(application.zcore.imageLibraryCom.isBottomLayoutType(struct.event_image_library_layout)){
		slideshowOutBottom=slideshowOut;
		slideshowOutTop="";
	}else{
		slideshowOutTop=slideshowOut;
		slideshowOutBottom="";
	}
	</cfscript>
	

	#slideshowOutTop#
	<div style="width:100%; float:left;">
		<div class="zEventView1-3">
			<h2>Event Description</h2>
			#struct.event_description#
		</div>
		<div class="zEventView1-3">
			<cfif struct.event_address NEQ "">
				<div class="zEventView1-0">
					<div class="zEventView1-1">Location:</div>
					<div class="zEventView1-2">
						#htmleditformat(struct.event_address)#<br />
						#struct.event_city#

						#htmleditformat(struct.event_state&" "&struct.event_zip)# 
						<cfif struct.event_country NEQ "US">
							#countryName#
						</cfif>
					</div>
				</div>
			</cfif> 
			<cfif struct.event_phone NEQ "">
				<div class="zEventView1-0">
					<div class="zEventView1-1">Contact:</div>
					<div class="zEventView1-2"><a class="zPhoneLink">#htmleditformat(struct.event_phone)#</a></div>
				</div>
			</cfif>
			<cfif left(struct.event_website, 7) EQ "http://" or left(struct.event_website, 8) EQ "https://">
				<div class="zEventView1-0">
					<div class="zEventView1-1">Website:</div>
					<div class="zEventView1-2"><a href="#htmleditformat(struct.event_website)#" target="_blank">#htmleditformat(struct.event_website)#</a></div>
				</div>
			</cfif>
			<cfif struct.event_file1 NEQ "" or struct.event_file2 NEQ "">
				<div class="zEventView1-0">
					<div class="zEventView1-1">Download Files:</div>
					<div class="zEventView1-2">
						<cfif struct.event_file1 NEQ "">
							<a href="#htmleditformat(struct.event_file1)#" target="_blank">
								<cfif struct.event_file1label NEQ "">
									#struct.event_file1label#
								<cfelse>
									File 1
								</cfif>
							</a>
						</cfif>
						<cfif struct.event_file2 NEQ "">
							<br /><a href="#htmleditformat(struct.event_file2)#" target="_blank">
								<cfif struct.event_file2label NEQ "">
									#struct.event_file2label#
								<cfelse>
									File 2
								</cfif>
							</a>
						</cfif>
					</div>
				</div>
			</cfif>
			<div class="zEventView1-0">
				<div class="zEventView1-1">Share:</div>
				<div class="zEventView1-2"> 
					<a href="##"  data-ajax="false" onclick="zShowModalStandard('/z/misc/share-with-friend/index?title=#urlencodedformat(struct.event_name)#&amp;link=#urlencodedformat(request.zos.currentHostName&struct.__url)#', 540, 630);return false;" rel="nofollow" style="display:block; float:left; margin-right:10px;"><img src="/z/images/event/share_03.jpg" alt="Share by email" width="30" height="30" /></a>
					<a href="https://www.facebook.com/sharer/sharer.php?u=#urlencodedformat(request.zos.currentHostName&struct.__url)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/z/images/event/share_05.jpg" alt="Share on facebook" width="30" height="30" /></a>
					<a href="https://twitter.com/share?url=#urlencodedformat(request.zos.currentHostName&struct.__url)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/z/images/event/share_07.jpg" alt="Share on twitter" width="30" height="30" /></a>
					<a href="http://www.linkedin.com/shareArticle?mini=true&amp;url=#urlencodedformat(request.zos.currentHostName&struct.__url)#&amp;title=#urlencodedformat(struct.event_name)#&amp;summary=&amp;source=#urlencodedformat(request.zos.globals.shortDomain)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/z/images/event/share_09.jpg" alt="Share on linkedin" width="30" height="30" /></a> 
					<a href="##" onclick="window.print(); return false;" target="_blank" class="zEventView1-print" rel="nofollow">Print</a>
				</div>
			</div>
		</div>
		<cfif struct.event_address NEQ "">
			<div id="zEventViewMapContainer">
				<div class="zEventView1-Map"  id="zEventMapDivId"></div>
				<div style="width:100%; float:left;"> <a href="https://maps.google.com/maps?q=#urlencodedformat(struct.event_address&", "&struct.event_city&", "&struct.event_state&" "&struct.event_zip&" "&struct.event_country)#" target="_blank">Launch In Google Maps</a></div>
			</div>
		</cfif>
	</div>  
	#slideshowOutBottom#

	
 
</cffunction>
</cfoutput>


<cffunction name="viewRecurringEvent" localmode="modern" access="remote">
	<cfscript>
	
	db=request.zos.queryObject;
	if(not request.zos.istestserver){
		echo('<h2>View Event is coming soon.</h2>');
		return;
	}
	form.event_recur_id=application.zcore.functions.zso(form, 'event_recur_id', true);
	ts.event_recur_id=form.event_recur_id;
	ts.onlyFutureEvents=false;

	eventCom=application.zcore.app.getAppCFC("event");
	rs=eventCom.searchEvents(ts);

	if(rs.count NEQ 1){
		application.zcore.functions.z404("Recurring event, #form.event_recur_id#, is missing");
	}
	rs.arrData[1].event_start_datetime=rs.arrData[1].event_recur_start_datetime;
	rs.arrData[1].event_end_datetime=rs.arrData[1].event_recur_end_datetime;
	displayEvent(rs.arrData[1]); 
	</cfscript>
</cffunction>



<cffunction name="viewEvent" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	if(not request.zos.istestserver){
		echo('<h2>View Event is coming soon.</h2>');
		return;
	}
	form.event_id=application.zcore.functions.zso(form, 'event_id', true);
	ts.event_id=form.event_id;
	ts.perpage=1;
	ts.onlyFutureEvents=true;
	eventCom=application.zcore.app.getAppCFC("event");
	rs=eventCom.searchEvents(ts);
	if(rs.count EQ 0){
		ts.onlyFutureEvents=false;
		eventCom=application.zcore.app.getAppCFC("event");
		rs=eventCom.searchEvents(ts);
	} 
	if(rs.count NEQ 1){
		application.zcore.functions.z404("Event, #form.event_id#, is missing");
	}
	rs.arrData[1].event_start_datetime=rs.arrData[1].event_recur_start_datetime;
	rs.arrData[1].event_end_datetime=rs.arrData[1].event_recur_end_datetime; 


	if(structkeyexists(form, 'zUrlName')){
		if(rs.arrData[1].event_unique_url EQ ""){

			curLink=rs.arrData[1].__url; 
			urlId=application.zcore.app.getAppData("event").optionstruct.event_config_event_url_id;
			actualLink="/"&application.zcore.functions.zURLEncode(form.zURLName, '-')&"-"&urlId&"-"&rs.arrData[1].event_id&".html";

			if(compare(curLink,actualLink) neq 0){
				application.zcore.functions.z301Redirect(curLink);
			}
		}else{
			if(compare(rs.arrData[1].event_unique_url, request.zos.originalURL) NEQ 0){
				application.zcore.functions.z301Redirect(rs.arrData[1].event_unique_url);
			}
		}
	}
	displayEvent(rs.arrData[1]);
	</cfscript>
</cffunction>
</cfcomponent>