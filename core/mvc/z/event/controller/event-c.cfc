<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	var ts=0;
	var i=0;
	request.disableCenter=true;
	request.eventPage=true;
	/*if(structkeyexists(request.zsession, 'enableMobile') and request.zsession.enableMobile EQ 1){
		local.tempCom=createobject("component", "#request.zrootcfcpath#mvc.mobile.controller.event");
		local.tempCom.index();
		return;
	}*/
	var pageStruct=request.zos.functions.zGetSiteOptionGroupSetById(form.site_x_option_group_set_id, request.zos.globals.id, ["Event"]);
	if(structcount(pageStruct) EQ 0){
		request.zos.functions.z404("Event ID, #form.site_x_option_group_set_id# , not found");	
	}
	var cityStruct=request.zos.functions.zGetSiteOptionGroupSetById(pageStruct.city);
	if(pageStruct.city NEQ "" and structcount(cityStruct) EQ 0){
		request.zos.functions.z404("City ID, #pageStruct.city# , not found");	
	} 
	var categoryStruct=request.zos.functions.zGetSiteOptionGroupSetById(pageStruct.category);
	if(pageStruct.category NEQ "" and structcount(categoryStruct) EQ 0){
		request.zos.functions.z404("Category ID, #pageStruct.category# , not found");	
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
	<cfsavecontent variable="local.scriptOutput">
	<script src="https://maps.googleapis.com/maps/api/js?v=3.exp&amp;sensor=false"></script>
	<script type="text/javascript">
	/* <![CDATA[ */
	function mapSuccessCallback(){
		$("##mapContainerDiv").show();
	}
	zArrDeferredFunctions.push(function(){
		$("##eventSlideshowDiv").cycle({timeout:3000, speed:1200});
		$( "##startdate" ).datepicker();
		$( "##enddate" ).datepicker();
		<cfif pageStruct.address NEQ "">
			var optionsObj={ zoom: 13 };
			<cfif pageStruct["map coordinates"] NEQ "">
				arrLatLng=[#pageStruct["map coordinates"]#]; 
				zCreateMapWithLatLng("mapDivId", arrLatLng[0], arrLatLng[1], optionsObj, mapSuccessCallback);  
			<cfelseif structkeyexists(cityStruct, 'name')>
				zCreateMapWithAddress("mapDivId", "#jsstringformat(pageStruct.address&', '&cityStruct.name&", "&pageStruct["State"]&" "&pageStruct["Zip"])#", optionsObj, mapSuccessCallback); 
			</cfif>
		</cfif> 
	});
	/* ]]> */
	</script> 
	</cfsavecontent>
	<cfscript>
	request.zos.template.appendTag("meta", local.scriptOutput);
	local.eventsCom=createobject("component", "#request.zRootCFCPath#mvc.controller.events");
	request.zos.template.setTag("title", pageStruct["title"]);
	request.zos.template.setTag("pagetitle", pageStruct["title"]);
	</cfscript>
	<cfsavecontent variable="request.eventsSidebarHTML">#local.eventsCom.calendarSidebar()#</cfsavecontent> 
					
	<div class="sf-27"> <a class="sn-63" href="##" onclick="window.print(); return false;" target="_blank" rel="nofollow">Print</a>&nbsp;&nbsp; <!--- <a class="sn-65" href="##" onclick="zShowModalStandard('/z/misc/share-with-friend/index?title=#urlencodedformat(pageStruct.title)#&amp;link=#urlencodedformat(request.zos.currentHostName&pageStruct.__url)#', 540, 630);return false;" rel="nofollow">Share</a>  ---></div> 
	<div class="sn-22">
		<div class="sf-28"><a href="/events/index" class="sf-28-2">Back To Calendar</a></div>
		<div class="sf-29">
			<div class="sf-30">
				<div class="sf-31">
				
					<cfif pageStruct["End Date"] NEQ "" and dateformat(pageStruct["Start Date"], "mmm") NEQ dateformat(pageStruct["End Date"], "mmm")>
						<div class="sn-33"><span class="sh-98-2">#dateformat(pageStruct["Start Date"], "m/d")#</span><span class="sh-98-2">to</span>
						<span class="sh-98-2">#dateformat(pageStruct["End Date"], "m/d")#</span></div>
					<cfelse>
						<div class="sn-33">#dateformat(pageStruct["Start Date"], "mmm")#<br />
						<cfif pageStruct["End Date"] NEQ "" and dateformat(pageStruct["Start Date"], "d") NEQ dateformat(pageStruct["End Date"], "d")>
							<span class="sh-99" style="font-size:16px;">#dateformat(pageStruct["Start Date"], "d")#-#dateformat(pageStruct["End Date"], "d")#</span>
						<cfelse>
							<span class="sh-99">#dateformat(pageStruct["Start Date"], "d")#</span>
						</cfif>
						</div> 
					</cfif>
				</div>
			</div>
			<div class="sf-32">
				<div class="sf-33">#htmleditformat(pageStruct["title"])#</div>
				<div class="sf-34">
					<cfif structkeyexists(pageStruct, '__image_library_id')>
						<cfscript>
						ts=structnew();
						ts.output=true;
						ts.image_library_id=pageStruct.__image_library_id;
						ts.forceSize=true;
						ts.size="310x210";
						ts.thumbSize="70x40";
						ts.layoutType="galleryview-1.1";
						ts.crop=0;
						ts.offset=0;
						ts.limit=0; // zero will return all images
						local.arrImage=request.zos.imageLibraryCom.displayImages(ts); 
								ts.output=false;
								ts.size="640x400";
								ts.layoutType="";
								var arrImage=request.zos.imageLibraryCom.displayImages(ts);
								var i=0;
						</cfscript>
							<div style="display:block; width:100%; height:30px; margin-bottom:10px; overflow:hidden; line-height:30px; font-size:18px; float:left;">  
								<cfloop from="1" to="#arrayLen(arrImage)#" index="i">
									<a href="#arrImage[i].link#" title="Image #i#" class="placeImageColorbox">View larger images</a><br />
								</cfloop>
								<cfscript>
								request.zos.template.appendTag("meta", request.zos.skin.includeCSS("/z/javascript/jquery/colorbox/example3/colorbox.css")&request.zos.skin.includeJS("/z/javascript/jquery/colorbox/colorbox/jquery.colorbox-min.js")&'<style type="text/css">##cboxNext, ##cboxPrevious{display:none !important;}</style>');
								request.zos.skin.addDeferredScript('$(".placeImageColorbox").colorbox({photo:true, slideshow: true});');
								</cfscript>
							</div>
					</cfif>  
				</div>
				<div class="sf-34">
					<div class="sf-35">
						<div style="width:100%; padding-top:10px; padding-bottom:10px; float:left;">
							#replace(local.pageStruct["body text"], chr(10), '<br />', 'all')# 
						</div>
						
						<div class="sf-37">
							<cfif pageStruct["address"] NEQ "">
								<div class="sn-73">Location:</div>
								<div class="sf-38">#htmleditformat(pageStruct["address"])#<br />
								<cfif structkeyexists(cityStruct, 'name')>
									#cityStruct.name#, 
								</cfif>

								#htmleditformat(pageStruct["State"]&" "&pageStruct["Zip"])#</div>
							</cfif>
							<cfif structcount(categoryStruct) and categoryStruct.name NEQ "">
							<div class="sn-73">Category:</div>
							<div class="sf-38">#categoryStruct.name#</div>
							</cfif>
							<div class="sn-73">Time:</div>
							<div class="sf-38"> 
							<cfif pageStruct["start date"] EQ pageStruct["end date"]>
								#pageStruct["start date"]#
							<cfelse>
								#pageStruct["start date"]# to #pageStruct["end date"]#
							</cfif>
							<!--- #dateformat(pageStruct["start date"], "m/d/yy")# at #timeformat(pageStruct["start date"], "h:mm tt")#<br />to<br />#dateformat(pageStruct["end date"], "m/d/yy")# at #timeformat(pageStruct["end date"], "h:mm tt")# --->
							</div>
							<cfif pageStruct["phone"] NEQ "">
								<div class="sn-73">Contact:</div>
								<div class="sf-38"><a  class="zPhoneLink">#htmleditformat(pageStruct["phone"])#</a></div>
							</cfif>
							<cfif left(pageStruct["web site URL"], 7) EQ "http://" or left(pageStruct["web site URL"], 8) EQ "https://">
								<div class="sn-73">Website:</div>
								<div class="sf-38"><a href="#htmleditformat(pageStruct["web site URL"])#" target="_blank">#htmleditformat(pageStruct["web site URL"])#</a></div>
							</cfif>
							<cfif (structkeyexists(pageStruct, "file 1") and pageStruct["file 1"] NEQ "") or (structkeyexists(pageStruct, "file 2") and pageStruct["file 2"] NEQ "")>
								<div class="sn-73">Download Files:</div>
								<div class="sf-38">
									<cfif structkeyexists(pageStruct, "file 1") and pageStruct["file 1"] NEQ "">
									<a href="#htmleditformat(pageStruct["file 1"])#" target="_blank">File 1</a>
									</cfif>
									<cfif structkeyexists(pageStruct, "file 2") and pageStruct["file 2"] NEQ "">
									<br /><a href="#htmleditformat(pageStruct["file 2"])#" target="_blank">File 2</a>
									</cfif>
								</div>
							</cfif>
				<div style="width:100%; float:left; padding-top:10px;">
								<div class="sn-73">Share:</div>
								<div class="sf-38">
					<div style="width:220px; float:left;">
						<a href="##"  data-ajax="false" onclick="zShowModalStandard('/z/misc/share-with-friend/index?title=#urlencodedformat(pageStruct.title)#&amp;link=#urlencodedformat(request.zos.currentHostName&pageStruct.__url)#', 540, 630);return false;" rel="nofollow" style="display:block; float:left; margin-right:10px;"><img src="/images/shell/share_03.jpg" alt="Share by email" width="30" height="30" /></a>
						<a href="https://www.facebook.com/sharer/sharer.php?u=#urlencodedformat(request.zos.currentHostName&pageStruct.__url)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/images/shell/share_05.jpg" alt="Share on facebook" width="30" height="30" /></a>
						<a href="https://twitter.com/share?url=#urlencodedformat(request.zos.currentHostName&pageStruct.__url)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/images/shell/share_07.jpg" alt="Share on twitter" width="30" height="30" /></a>
						<a href="http://www.linkedin.com/shareArticle?mini=true&amp;url=#urlencodedformat(request.zos.currentHostName&pageStruct.__url)#&amp;title=#urlencodedformat(pageStruct.title)#&amp;summary=&amp;source=#urlencodedformat('Visit Cocoa Beach')#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/images/shell/share_09.jpg" alt="Share on linkedin" width="30" height="30" /></a>
					</div>
				</div>
						</div>
					</div>
					<cfif structcount(cityStruct)>
					<div id="mapContainerDiv" class="sf-40">
						<div class="sn-79" id="mapDivId"></div>
						<div class="sn-79-2"></div>
						<div class="sn-80"> <a class="sn-81" href="https://maps.google.com/maps?q=#urlencodedformat(pageStruct["address"]&", "&cityStruct.name&", "&pageStruct["State"]&" "&pageStruct["Zip"])#" target="_blank">Launch In Google Maps</a><!---  <a class="sn-82" href="##fullmap">Full Page Map</a> ---> </div>
					</div>
					</cfif>
				</div>
			</div>
		</div> 
	</div>
	</div>
</cffunction>


<cffunction name="searchResult" access="public" roles="member" localmode="modern">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	eventStruct=arguments.dataStruct;
	curDate=dateformat(eventStruct["start date"], "yyyymmdd");
	</cfscript>  
	<div style="width:94%; padding:3%; float:left;  background-color:##e5fde5; border:1px solid ##769373; margin-bottom:20px;">
	
		<div class="sn-32">
			<cfif eventStruct["End Date"] NEQ "" and dateformat(eventStruct["Start Date"], "mmm") NEQ dateformat(eventStruct["End Date"], "mmm")>
				<span  class="sn-34">#dateformat(eventStruct["Start Date"], "m/d")#</span><span >to</span>
				<span class="sn-34" >#dateformat(eventStruct["End Date"], "m/d")#</span> 
			<cfelse>
				<span class="sn-33">#dateformat(eventStruct["Start Date"], "mmm")#</span>
				<cfif eventStruct["End Date"] NEQ "" and dateformat(eventStruct["Start Date"], "d") NEQ dateformat(eventStruct["End Date"], "d")>
				<span  class="sn-33-2">#dateformat(eventStruct["Start Date"], "d")#-#dateformat(eventStruct["End Date"], "d")#</span>
				<cfelse>
				<span  class="sn-34">#dateformat(eventStruct["Start Date"], "d")#</span>
				</cfif>
			</cfif>
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
</cffunction>

<cffunction name="searchReindex" access="public" roles="member">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="tableStruct" type="struct" required="yes">
	<cfscript>
	arguments.tableStruct.search_title=arguments.dataStruct.title; 
	var cityStruct=request.zos.functions.zGetSiteOptionGroupSetById(arguments.dataStruct.city);
	var categoryStruct=request.zos.functions.zGetSiteOptionGroupSetById(arguments.dataStruct.category);
	/*if(arguments.dataStruct.city NEQ "" and structcount(cityStruct) EQ 0){
		request.zos.functions.z404("City ID, #arguments.dataStruct.city# , not found");	
	}
	if(arguments.dataStruct.category NEQ "" and structcount(categoryStruct) EQ 0){
		request.zos.functions.z404("Category ID, #arguments.dataStruct.category# , not found");	
	}*/
	if(structcount(cityStruct) EQ 0){
		cityStruct={name:""};
	}
	if(structcount(categoryStruct) EQ 0){
		categoryStruct={name:""};
	}
	arguments.tableStruct.search_fulltext=request.zos.functions.zCleanSearchText(
		arguments.dataStruct.title&" "&
		arguments.dataStruct.phone&" "&
		categoryStruct.name&" "&
		cityStruct.name&" "&
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
</cfoutput>
</cfcomponent>