<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
<cfscript>
var detailCom=0;
var ts=0;
var firstImageToShow=0;
var urlMLSId=0;
var listingHasMap=0;
var cfcatch=0;
var urlMLSPId=0;
var excpt=0;
var temp=structnew();
var ps=0;
var propertyDataCom=0;
var propertyDisplayCom=0;
var hideSearchBar=0;
var returnStruct=0;
var isOfficeListing=0;
var idx=0;
var titleStruct=0;
var tempURL=0;
var propertyLink=0;
var fullPropertyLink=0;
var tempText=0;
var theBegin=0;
var theEnd=0;
var pos=0;
var hideSearchBar=0;
var searchStruct=0;
var i=0;
var newD=0;
var message1=0;
var message2=0;
var message3=0;
var message4=0;
var mapStageStruct=0;
var hideControls=0;
var mapHTML=0;
var ms=0;
var mapCom=0;
var d3=0;
var metacontent=0;
var featureText=0;
var metaKey=0;
request.zos.tempObj.listingDetailPage=true;
</cfscript>
<cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_detail_layout') EQ 2 and not structkeyexists(request.zos, 'forceDefaultListingPage')><cfinclude template="#request.zRootPath&application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_detail_template#"><cfelseif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_detail_layout') EQ 1><cfscript>
detailCom=createobject("component", "detail-new");
detailCom.index();
</cfscript><cfelse><cfscript>
application.zcore.template.setTag("title","Property Detail");
ts=StructNew();
ts.list='';
//request.zos.page.setActions(ts);
if(structkeyexists(form, 'searchId') EQ false and isDefined('request.zsession.tempVars.zListingSearchId')){
	form.searchId=request.zsession.tempVars.zListingSearchId;
}
if(isDefined('request.zsession.zlistingdetailhitcount') EQ false){
	request.zsession.zlistingdetailhitcount=1;
}else{
	request.zsession.zlistingdetailhitcount++;
}

firstImageToShow=1;
</cfscript>

<table style="width:100%;">
<tr><td>
	<cfscript>
	temp.title = "Listing";
	application.zcore.template.setTag('title', temp.title);
	application.zcore.template.setTag('pagetitle', temp.title);
	</cfscript>
	<cfsavecontent variable="temp.pageNav">
	<a href="/">#request.zos.globals.homelinktext#</a> :: #temp.title#
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag('pagenav', temp.pageNav);
	
if(structkeyexists(form, 'mls_pid') EQ false){
	application.zcore.functions.z301Redirect('/');
}
if(structkeyexists(form, 'mls_id') and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.urlMLSIDStruct, form.mls_id)){
	form.mls_id=application.zcore.app.getAppData("listing").sharedStruct.urlMLSIDStruct[form.mls_id];
	form.listing_id=form.mls_id&'-'&form.mls_pid;
}
if(structkeyexists(form, 'mls_id') EQ false or structkeyexists(form, 'listing_id') EQ false){
	application.zcore.functions.z301Redirect('/');
}

propertyDataCom = CreateObject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
propertyDisplayCom = CreateObject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
ts = StructNew();

ps=StructNew();

hideSearchBar=true;
	ts.arrMLSPid=ArrayNew(1);
	ArrayAppend(ts.arrMLSPid, form.listing_id);
	ts.showInactive=true;

ts.perpage=1;
if(structkeyexists(form, 'showInactive')){
	ts.useMLSCopy=true;
	ts.showInactive=true;
}

returnStruct = propertyDataCom.getProperties(ts);

if(returnStruct.count EQ 0 or returnStruct.query.recordcount EQ 0 or arraylen(returnStruct.arrQuery) EQ 0 or returnStruct.arrQuery[1].recordcount EQ 0){
	if(request.zos.isDeveloper){
		writeoutput("<h1>listing record is missing. (non-developers see 404 Not Found or 301 redirect)</h1>");
		writedump(returnStruct);
		application.zcore.functions.zabort();
	}
	if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_missing_listing_behavior',true, 1) EQ 1){
		application.zcore.functions.z404("listing record is missing.");
	}else{
		application.zcore.functions.z301Redirect('/');
	}
}else{
	application.zcore.functions.zQueryToStruct(returnStruct.arrQuery[1]);
}
idx=request.zos.listingMlsComObjects[form.mls_id].getDetails(returnStruct.arrQuery[1],1,true);

structappend(variables, idx,true);

isOfficeListing=false;
try{
if(request.zos.listing.site_x_mls_office_id EQ variables.listing_office){
	isOfficeListing=true;
}
}catch(Any excpt){}


				idx.listing_id=variables.listing_id;
titleStruct = request.zos.listing.functions.zListinggetTitle(idx);

// redirect if the page url changed

tempURL = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#idx.urlMLSId#-#idx.urlMLSPId#.html';

if(structkeyexists(form, 'zurlname')){
	if(compare(form.zURLName,titleStruct.urlTitle) NEQ 0){
		if(hideSearchBar EQ false){
			if(structkeyexists(form, 'searchId')){
				tempURL = application.zcore.functions.zURLAppend(tempURL, 'searchId=#form.searchid#');
			}
			if(structkeyexists(form, 'zdIndex')){
				tempURL = application.zcore.functions.zURLAppend(tempURL, 'zdIndex=#zdIndex#');
			}
		}
 		application.zcore.functions.z301Redirect(tempURL);
	}
}else{
 	application.zcore.functions.z301Redirect(tempURL);
}
if(structkeyexists(form, 'zdIndex')){
	if(zdindex NEQ "" and isnumeric(zdindex) EQ false){
		application.zcore.functions.z301redirect('/');	
	}	
}

propertyLink = tempURL; 
fullPropertyLink=application.zcore.functions.zURLAppend(propertyLink, 'searchId=#application.zcore.functions.zso(form, 'searchId')#&zdIndex=#application.zcore.functions.zso(form, 'zdIndex')#');
propertyLink=htmleditformat(propertyLink);
fullPropertyLink=htmleditformat(fullPropertyLink);
/*if(structkeyexists(form, 'debugPhotos')){
	application.zcore.functions.zdump(returnStruct.arrQuery[1]);
	for(i in idx){
		if(i contains "photo"){
			echo(i&"="&idx[i]&"<br>");
		}
	}
	abort;
}*/
</cfscript>
<cfsavecontent variable="temp.pageNav">
	<a href="#request.zos.globals.siteroot#/">#request.zos.globals.homelinktext#</a> /
	
<cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_search',true) EQ 0>
<cfif hideSearchBar EQ false or structkeyexists(form, 'searchId')>
<cfelse>
	<a href="#request.zos.listing.functions.getSearchFormLink()#" class="zNoContentTransition">Property Search</a> /
	</cfif> 
</cfif>
</cfsavecontent>
<cfscript>
application.zcore.template.setTag("title","#replace(titleStruct.title,'<br />','','ALL')#");
application.zcore.template.setTag("pagetitle","#titleStruct.title#");
	application.zcore.template.setTag("pagenav",temp.pageNav);
	

tempText = application.zcore.functions.zFixAbusiveCaps(variables.listing_data_remarks);
tempText = rereplace(tempText, "<.*?>","","ALL");
theBegin = left(tempText, 100);
theEnd = mid(tempText, 101, len(tempText));
pos = find(' ', theEnd);
if(pos NEQ 0){
	theBegin=theBegin&left(theEnd, pos);
	theEnd=removeChars(theEnd, 1, pos);
}
</cfscript>
<cfif hideSearchBar EQ false>

	<cfscript>
	// required
	searchStruct = StructNew();
	// optional
	searchStruct.showString = "";
	// allows custom url formatting
	//searchStruct.parseURLVariables = true;
	searchStruct.indexName = 'zdIndex';
	searchStruct.url = application.zcore.functions.zURLAppend(propertyLink, 'searchId=#form.searchid#'); 
	searchStruct.buttons = 1;
	searchStruct.count = returnStruct.count;
	// set from query string or default value
	searchStruct.index = application.zcore.status.getField(form.searchid, "zdIndex",1);
	searchStruct.perpage = 1;
	searchStruct.returnDataOnly=true;
	navOutput=application.zcore.functions.zSearchResultsNav(searchStruct);
	</cfscript>
	<span class="search-nav">
	<div class="search-nav-l">
	<cfscript>
	for(i=1;i LTE ArrayLen(navOutput.arrData);i=i+1){
		if(navOutput.arrData[i].url EQ ''){
			writeoutput('<span class="search-nav-t">'&navOutput.textPosition&'</span>');
		}else{
			writeoutput('<a href="'&htmleditformat(navOutput.arrData[i].url)&'">'&navOutput.arrData[i].label&'</a>');
		}
	}
	</cfscript></div>
	</span>
</cfif>

<cfscript>
if(form.mls_id EQ "4"){
	firstImageToShow++;
	i=1;
	if(structkeyexists(idx,'photo'&i)){
		if(structkeyexists(idx, 'photo_description'&i)){
			newD=htmleditformat(idx['photo_description'&i]);
		}else{
			newD=htmleditformat(titleStruct.title);
		}
		writeoutput('<div style="text-align:center; padding-bottom:15px;"><img id="zmlslistingphoto#i#" src="#idx["photo#i#"]#" alt="#newD#" style=" max-width:#request.zos.globals.maximagewidth#px;margin-bottom:5px; clear:both;" /><script type="text/javascript">/* <![CDATA[ */
document.getElementById("zmlslistingphoto#i#").onerror=function(){zImageOnError(this);};
/* ]]> */</script></div>');
	}
}


ts = StructNew();
ts.dataStruct = returnStruct;
propertyDisplayCom.init(ts);
writeoutput(propertyDisplayCom.display());
</cfscript>


<div class="listing-d-div-l">

<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 0>

<cfscript>
message1=application.zcore.functions.zVarSO("Listing: Sales Message 1");
message2=application.zcore.functions.zVarSO("Listing: Sales Message 2");
message3=application.zcore.functions.zVarSO("Listing: Sales Message 3");
message4=application.zcore.functions.zVarSO("Listing: Email Text",request.zos.globals.id,true);
</cfscript>
<div style="border:1px solid ##999; float:left; padding:2%; width:96%;">
<span style="font-size:14px; font-weight:bold; line-height:18px;"><cfif message1 NEQ "">#message1#<cfelse>We are experts at price negotiation:</cfif><br />
<a href="##" onclick="zShowModalStandard('/z/listing/inquiry/index?action=form&amp;modalpopforced=1&amp;listing_id=#variables.listing_id#&amp;inquiries_comments=<cfif message4 NEQ "">#URLEncodedformat(message4)#<cfelse>I%27d%20like%20to%20make%20an%20offer%20of%20%24</cfif>', 540, 630);return false;" rel="nofollow"><cfif message2 NEQ "">#message2#<cfelse>MAKE AN OFFER and we'll help you save thousands</cfif></a></span><br />

<cfif message3 NEQ "">#message3#<cfelse>We work hard to quickly narrow the thousands of properties down to just a select few that meet your family's needs.  Our services are paid for by the seller.  We represent your best interests on every transaction to make sure home is safe, more financially sound and in the right neighborhood for your lifestyle. <strong><a href="/z/misc/inquiry/index">Contact Us</a></strong> to learn how we can work for you.<br /></cfif>

</cfif>

<cfif variables.listing_track_datetime NEQ "">
<div id="zls-list-date-detail">
This listing was first listed on this web site on #dateformat(variables.listing_track_datetime,'mmmm d, yyyy')# and it was last updated on #dateformat(variables.listing_track_updated_datetime,'mmmm d, yyyy')#<br />
</div>
</cfif>

	<cfif listingHasMap and application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_enable_walkscore',true,1) EQ 1>
<div style=" width:480px; font-size:18px; margin-bottom:10px; margin-top:10px;" id="walkscore-div"><a href="##" onclick="zAjaxWalkscore({'latitude':'#variables.listing_latitude#','longitude':'#variables.listing_longitude#'}); return false;">Click here to check Walkscore</a></div>
</cfif>
<span style="font-size:80%;">Source: #request.zos.globals.shortdomain#</span>
</div>
<!--- <h3>Property Information</h3> --->

#idx.details#

	<cfif listingHasMap>
    <a id="googlemap"></a>
<h3>Neighborhood Map</h3>
	<cfscript>
	mapStageStruct=StructNew();
	mapStageStruct.width=480;
	mapStageStruct.height=300;
	mapStageStruct.fullscreen.width=770;
	mapStageStruct.fullscreen.height=300;
	mapQuery=returnStruct;
	hideMapControls=true;
	</cfscript>
    <cfsavecontent variable="mapHTML"><table style="width:280px;"><tr><td><cfscript>propertyDisplayCom.mapTemplate(idx, 1);</cfscript></td></tr></table></cfsavecontent>

    <cfscript>
	mapStageStruct.arrMapTotalLat=listtoarray(variables.listing_latitude);
	mapStageStruct.arrMapTotalLong=listtoarray(variables.listing_longitude);
	mapStageStruct.arrMapText=arraynew(1);
	arrayappend(mapStageStruct.arrMapText, "#(mapHTML)#");
	
		ms={
			mapQuery=mapQuery,
			mapStageStruct=mapStageStruct,
			listing_latitude=variables.listing_latitude,
			listing_longitude=variables.listing_longitude,
			listing_data_address=variables.listing_data_address,
			listing_data_zip=variables.listing_data_zip,
			cityName=cityName,
			hideMapControls=hideMapControls	
		}
		mapCom=createobject("component","zcorerootmapping.mvc.z.listing.controller.map");
		mapCom.index(ms);
		</cfscript><br style="clear:both;" />
 
	</cfif>


	
</div>
<cfscript>
if(variables.listing_type_id NEQ 0){
d3=application.zcore.listingCom.listingLookupValue("listing_type",variables.listing_type_id);
}else{
	d3="real estate";
}
//d3=request.zos.listing.cacheStruct.listing_type_name[variables.listing_type_id];
</cfscript>
<div class="zls2-right-column" style="float:left; width:#request.zos.globals.maximagewidth-510#px; padding-left:10px;">
	<cfsavecontent variable="featureText"><cfif trim(idx.features) NEQ ""><table class="ztablepropertyinfo">#idx.features#</table></cfif></cfsavecontent>
	
	<cfsavecontent variable="metacontent">
    <cfscript>
	metaKey=rereplacenocase(titleStruct.title&" "&idx.features,"<.*?>"," ","ALL");
	</cfscript>
    <link rel="canonical" href="#request.zos.currentHostName##propertyLink#" />
    <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>
    <meta name="robots" content="noindex,nofollow,noarchive" />
    </cfif>
	<meta name="keywords" content="#htmleditformat(metaKey)#" />
	<meta name="description" content="#htmleditformat(titleStruct.listing_x_site_description)#<!--- #htmleditformat(theBegin)# --->" />
	<!--- 	<link href="/z/a/listing/stylesheets/detail.css" type="text/css" rel="stylesheet" /> --->
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("meta",metacontent);
	</cfscript>
	
	#featureText#
</div>
<br style="clear:both;" />
<a id="photos"></a>
<h3>All Available Photos</h3>

<div class="zmls-listing-detail-photos" style="overflow:hidden;">
<cfloop from="#firstImageToShow#" to="#variables.listing_photocount#" index="i">
<cfif structkeyexists(idx,'photo'&i)>
<!--- <cfif variables.listing_mls_id EQ 17>width:100%;</cfif>  --->
#application.zcore.functions.zLoadAndCropImage({id:"zmlslistingphoto#i#",width:10000,height:10000, url:idx['photo'&i], style:"margin-bottom:5px; clear:both; width:100%; max-width:#request.zos.globals.maximagewidth#px;", canvasStyle:"", crop:false})#
<!--- 
<img id="zmlslistingphoto#i#" src="#application.zcore.listingCom.getThumbnail(idx['photo'&i], request.lastPhotoId, i, 10000, 10000, 0)#<!--- #idx["photo#i#"]# --->" alt="<cfif structkeyexists(idx, 'photo_description'&i)>#htmleditformat(idx['photo_description'&i])#<cfelse>Listing Photo #i#</cfif>" style="margin-bottom:5px; clear:both; " /> --->
<!--- <script type="text/javascript">/* <![CDATA[ */
document.getElementById("zmlslistingphoto#i#").onerror=function(){this.style.display="none";/*zImageOnError(this);*/};
/* ]]> */</script> --->
</cfif>
</cfloop>
</div>
<cfif structkeyexists(idx, 'officeName')><!--- isOfficeListing EQ false and  --->
	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_compliantIDX EQ 1>
        <hr />
        <span >Listing courtesy of #idx.officeName#</span> <br />
    <cfelse>
		<cfscript>
        application.zcore.template.setTag('listoffice','listing courtesy of #idx.officeName#');
        </cfscript>
    </cfif>
</cfif>
</td></tr>
</table> 
</cfif>
</cffunction>
</cfoutput>
</cfcomponent>