<cfcomponent>
<cfoutput>
<cffunction name="view" localmode="modern" access="remote" returntype="any">
	<cfscript>
	application.zcore.template.setTag("title", "Your Saved Listings");
	application.zcore.template.setTag("pagetitle", "Your Saved Listings");
	form.saveAct='view';
	form.returnURL=request.zos.originalURL;
	variables.index();  
	pageNav='<a href="/">Home</a> / ';
	
	if(application.zcore.user.checkGroupAccess("user")){
		pageNav&='<a href="/z/user/home/index">User Dashboard</a> / ';
	}else{
		echo(application.zcore.user.createAccountMessage());
	}
	application.zcore.template.setTag("pagenav", pagenav);
	</cfscript>
	
	<cfif cookie.SAVEDLISTINGCOUNT EQ 0 and cookie.savedContentCount EQ 0>
		<h2>You have no saved listings at this time.</h2>
	<cfelse>
		<hr />
		<button id="zSLEmailButton1" type="button" name="button1" onclick="zShowModalStandard('/z/listing/sl/index?saveAct=inquiry', 540, 630);return false;" rel="nofollow" class="zSavedList-link" style="display:none;">Email your saved listings to us</button>
		<script type="text/javascript">
		/* <![CDATA[ */
		zArrDeferredFunctions.push(function(){
			$("##zSLEmailButton1").show();
		});
		/* ]]> */
		</script>
	</cfif>
	<!--- this is empty on purpose to allow viewing ONLY the saved listings --->
</cffunction>

<cffunction name="index" localmode="modern" access="remote" returntype="any">
<cfscript>
var qC=0;
var ts={};
var j=0;

var tempCom=0;

var qContent=0;
var propertyDataCom=0;
var returnStruct=0;
var propDisplayCom=0;
var contentIdList=0;
var propertyHTML=0;
var db=request.zos.queryObject; 
request.disableShareThis=true;
form.saveAct=application.zcore.functions.zso(form, 'saveAct'); 
if(isDefined('request.zsession.user.id')){
	if(isDefined('request.zsession.listing.savedListingUserLoaded') EQ false){
		db.sql="select * from #request.zos.queryObject.table("saved_listing", request.zos.zcoreDatasource)# saved_listing 
		WHERE site_id=#db.param(request.zos.globals.id)# and 
		user_id=#db.param(request.zsession.user.id)# and 
		saved_listing_deleted = #db.param(0)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#";
		qC=db.execute("qC"); 
		if(qC.recordcount NEQ 0){
			ts=structnew();
			ts.name="savedListingStruct";
			ts.value=qc.saved_listing_idlist;
			ts.expires="never";
			application.zcore.functions.zCookie(ts);
			ts=structnew();
			ts.name="savedListingCount";
			ts.value=qc.saved_listing_count;
			ts.expires="never";
			application.zcore.functions.zCookie(ts);
			ts=structnew();
			ts.name="savedContentStruct";
			ts.value=qc.saved_content_idlist;
			ts.expires="never";
			application.zcore.functions.zCookie(ts);
			ts=structnew();
			ts.name="savedcontentCount";
			ts.value=qc.saved_content_count;
			ts.expires="never";
			application.zcore.functions.zCookie(ts);
			arrKey=listtoarray(qc.saved_listing_idlist);
			if(isDefined('request.zsession.listing.savedListingStruct') EQ false){
				request.zsession.listing.savedListingStruct=structnew();
			}
			for(i=1;i LTE arraylen(arrKey);i++){
				request.zsession.listing.savedListingStruct[arrKey[i]]=true;
			}
			if(isDefined('request.zsession.listing.savedCountStruct') EQ false){
				request.zsession.listing.savedContentStruct=structnew();
			}
			arrKey=listtoarray(qc.saved_content_idlist);
			for(i=1;i LTE arraylen(arrKey);i++){
				request.zsession.listing.savedContentStruct[arrKey[i]]=true;
			}
			
		}else if(isDefined('request.zsession.listing.savedContentStruct') and isDefined('request.zsession.listing.savedListingStruct') and (structcount(request.zsession.listing.savedContentStruct) NEQ 0 or structcount(request.zsession.listing.savedListingStruct) NEQ 0)){
			application.zcore.listingCom.updateUserSavedListings();	
			//application.zcore.functions.zdump(request.zos.arrQueryLog);
			//application.zcore.functions.zabort();
		}
		request.zsession.listing.savedListingUserLoaded=true;
	}
}else if(isDefined('request.zsession.listing.savedListingUserLoaded')){
	ts=structnew();
	ts.name="savedListingStruct";
	ts.value="";
	ts.expires="never";
	application.zcore.functions.zCookie(ts);
	ts=structnew();
	ts.name="savedListingCount";
	ts.value=0;
	ts.expires="never";
	application.zcore.functions.zCookie(ts);
	ts=structnew();
	ts.name="savedContentStruct";
	ts.value="";
	ts.expires="never";
	application.zcore.functions.zCookie(ts);
	ts=structnew();
	ts.name="savedcontentCount";
	ts.value=0;
	ts.expires="never";
	application.zcore.functions.zCookie(ts);
	request.zsession.listing.savedListingStruct=structnew();
	request.zsession.listing.savedContentStruct=structnew();
	structdelete(request.zsession.listing,"savedListingUserLoaded");
}
if(isDefined('request.zsession.listing.savedListingStruct') eq false){
	request.zsession.listing.savedListingStruct=structnew();
	if(isDefined('cookie.savedListingStruct')){
		arrKey=listtoarray(cookie.savedListingStruct);
		for(i=1;i LTE arraylen(arrKey);i++){
			request.zsession.listing.savedListingStruct[arrKey[i]]=true;
		}
	}
}
if(isDefined('request.zsession.listing.savedContentStruct') eq false){
	request.zsession.listing.savedContentStruct=structnew();
	if(isDefined('cookie.savedContentStruct')){
		arrKey=listtoarray(cookie.savedContentStruct);
		for(i=1;i LTE arraylen(arrKey);i++){
			request.zsession.listing.savedContentStruct[arrKey[i]]=true;
		}
	}
}
</cfscript>
<cfif isDefined('cookie.savedListingCount') eq false>
	<cfcookie name="savedListingCount" value="0" expires="never">
</cfif>
<cfif isDefined('cookie.savedContentCount') eq false>
	<cfcookie name="savedContentCount" value="0" expires="never">
</cfif>
<cfif form.saveAct EQ 'list'><cfscript>
application.zcore.tracking.backOneHit();
application.zcore.functions.zModalCancel();
application.zcore.functions.zHeader("Content-type","text/javascript");
    request.znotemplate=1;
	if(cookie.SAVEDLISTINGCOUNT EQ 0 and cookie.savedContentCount EQ 0){
		application.zcore.functions.zabort();	
	}
    </cfscript>
    <cfoutput><cfsavecontent variable="j">
    <table style="width:100%; border-spacing:5px;border:1px solid ##CCCCCC;" class="zSavedList-table">
    <tr>
    <td class="zSavedList-title">Your Saved Listings</td>
    <td style="text-align:right;" class="zSavedList-left-td">Actions: <a href="##" onclick="zShowModalStandard('/z/listing/sl/index?saveAct=inquiry', 540, 630);return false;" rel="nofollow" class="zSavedList-link">Send all to us</a> | <cfif isDefined('request.zsession.user.id') EQ false><a href="/z/user/preference/index?action=form&zSignupMessage=#URLEncodedFormat("By creating an account below, your saved listings will be stored with the email and password you provide making it easy to retrieve them later.")#" rel="nofollow">Save to New Account</a> | </cfif><a href="/z/listing/sl/index?saveAct=removeall&returnURL=#urlencodedformat(request.zos.cgi.http_referer)#" rel="nofollow">Remove All</a></td>
    </tr>
    <tr><td colspan="2">
	<iframe id="zlsSavedListingIframe" src="/z/listing/sl/index?saveAct=view&returnURL=#urlencodedformat(request.zos.cgi.http_referer)#&t=#timeformat(now(),'hhmmss')#" width="100%" height="155" marginheight="0" marginwidth="0"  style="border:none; overflow:auto;padding:0px; margin:0px; margin-bottom:0px; " seamless="seamless"></iframe></td></tr>
    </table>
    <hr />
    </cfsavecontent>

	
    function rc(c) {
     var te=""+document.cookie;
     var i=te.indexOf(c);
     if (i==-1 || c=="") return ""; 
     var i1=te.indexOf(';',i);
     if (i1==-1) i1=te.length; 
     return unescape(te.substring(i+c.length+1,i1));
    }
    if(rc("SAVEDLISTINGCOUNT") != 0 || rc("SAVEDCONTENTCOUNT") != 0){
    var el = document.getElementById('sl894nsdh783');el.innerHTML = "#replace(jsstringformat(j),"</","<\/","all")#";
    }
	
   	</cfoutput><cfscript>application.zcore.functions.zabort();</cfscript>
</cfif>
<cfif form.saveAct eq 'view'><cfscript>application.zcore.tracking.backOneHit();</cfscript>
<script type="text/javascript">
/* <![CDATA[ */ zArrDeferredFunctions.push(function(){ zListingSearchJsToolHide();zContentTransition.disable();}); /* ]]> */
</script>
	<cfscript>
	request.zpagedebugdisabled=true;
	if(form.method NEQ "view"){
		application.zcore.template.setTemplate("zcorerootmapping.templates.blank");
		application.zcore.template.prependtag("stylesheets",'<style type="text/css">body{background:none !important;} body, table{ background-color:##FFF !important; color:##000 !important;} a:link, a:visited{ color:##369 !important; } </style><meta name="ROBOTS" content="NOINDEX,NOFOLLOW" />');
	}
	propertyDataCom = CreateObject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
	// get select properties based on mls_id and listing_id
	ts.arrMLSPid=structkeyarray(request.zsession.listing.savedListingStruct);
	//ts.debug=true;
	ts.perpage=200;
	ts.showInactive=true;
	returnStruct = propertyDataCom.getProperties(ts);
	propDisplayCom = CreateObject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
	ts = StructNew();
	ts.baseCity = 'db';
	ts.datastruct = returnStruct;
	ts.searchScript=false;
	ts.compact=true;
	propDisplayCom.init(ts);
	//zdump(ts.datastruct);

	// inputStruct should contain all search parameters. (on daytona beach page, this would only be city_name and state_abbr)
	propertyHTML = propDisplayCom.displayTop();	
	//cookie.savedListingCount=returnstruct.count;
	contentIdList=structkeylist(request.zsession.listing.savedContentStruct,"','");
	
	</cfscript>
    <cfcookie name="savedListingCount" value="#returnstruct.count#" expires="never">
	<table style="border-spacing:2px;width:#returnStruct.count*115#px; ">
		<tr>
			#propertyHTML#
            <cfsavecontent variable="db.sql">
            SELECT * FROM #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content 
			WHERE content.site_id = #db.param(request.zos.globals.id)# and 
            content_id IN (#db.trustedSQL("'#(contentIdList)#'")#)  and 
			content_for_sale <> #db.param(2)# and 
			content_deleted = #db.param(0)#
             ORDER BY content_sort ASC, content_datetime DESC, content_created_datetime DESC
            </cfsavecontent><cfscript>qContent=db.execute("qContent");
			if(qContent.recordcount EQ 0 and returnStruct.count EQ 0){
				request.zsession.listing.savedListingStruct=structnew();
				request.zsession.listing.savedcontentStruct=structnew();
				application.zcore.listingCom.updateUserSavedListings();
				ts=structnew();
				ts.name="savedListingStruct";
				ts.value="";
				ts.expires="never";
				application.zcore.functions.zCookie(ts);
				ts=structnew();
				ts.name="savedListingCount";
				ts.value=0;
				ts.expires="never";
				application.zcore.functions.zCookie(ts);
				ts=structnew();
				ts.name="savedContentStruct";
				ts.value="";
				ts.expires="never";
				application.zcore.functions.zCookie(ts);
				ts=structnew();
				ts.name="savedcontentCount";
				ts.value=0;
				ts.expires="never";
				application.zcore.functions.zCookie(ts);
			}
			</cfscript>
            <cfloop query="qContent">
<td style="text-align:center; border-right:1px solid ##999;"><a href="<cfif qContent.content_url_only NEQ ''>#application.zcore.functions.zForceAbsoluteUrl(request.zos.currentHostName,qContent.content_url_only)#<cfelse>#request.zos.currentHostName#<cfif qContent.content_unique_name NEQ ''>#qContent.content_unique_name#<cfelse>/#application.zcore.functions.zURLEncode(qContent.content_name,'-')#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_article_id#-#qContent.content_id#.html</cfif></cfif>" style=" font-weight:normal;  " target="_top"><cfif fileexists(request.zos.globals.homedir&'images/content/'&qContent.content_thumbnail)><img src="#request.zos.currentHostName&'/images/content/'##qContent.content_thumbnail#" class="listing-d-img" id="zclistingdimg#qContent.content_id#" width="100" height="78"><cfelse>Image N/A</cfif><br /> #left(qContent.content_name,30)#<cfif len(qContent.content_name) GT 30>...</cfif></a><br /><a href="/z/listing/sl/index?saveAct=delete&amp;content_id=#qContent.content_id#<cfif structkeyexists(form, 'returnURL')>&amp;returnURL=#URLEncodedFormat(form.returnURL)#</cfif>" rel="nofollow" style=" font-weight:bold;  " title="Delete This Property From Your List" target="_top">Remove</a></td>
            </cfloop>
            </tr>
	</table>
</cfif>

<!--- Send For Inquiry--->
<cfif form.saveAct eq 'check'><cfscript>application.zcore.tracking.backOneHit();
	if(structkeyexists(form, 'listing_id')){
		
		if(structkeyexists(request.zsession.listing.savedListingStruct, form.listing_id) EQ false){
			request.zsession.listing.savedListingStruct[form.listing_id]=true;
			application.zcore.listingCom.updateUserSavedListings();
		}
		ts=structnew();
		ts.name="savedListingStruct";
		ts.value=structkeylist(request.zsession.listing.savedListingStruct);
		ts.expires="never";
		application.zcore.functions.zCookie(ts);
		ts=structnew();
		ts.name="savedListingCount";
		ts.value=structcount(request.zsession.listing.savedListingStruct);
		ts.expires="never";
		application.zcore.functions.zCookie(ts);
		//cookie.savedListingCount=structcount(request.zsession.listing.savedListingStruct);
		if(structkeyexists(form, 'returnURL')){
			application.zcore.functions.zRedirect(form.returnURL);
		}else{
			application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(request.zos.listing.functions.getSearchFormLink(), 'searchid='&application.zcore.functions.zso(form, 'searchId')));
		}
	}else if(structkeyexists(form, 'content_id')){
		if(structkeyexists(request.zsession.listing.savedcontentStruct, form.content_id) EQ false){
			request.zsession.listing.savedcontentStruct[form.content_id]=true;
			application.zcore.listingCom.updateUserSavedListings();
		}
		ts=structnew();
		ts.name="savedContentStruct";
		ts.value=structkeylist(request.zsession.listing.savedContentStruct);
		ts.expires="never";
		application.zcore.functions.zCookie(ts);
		ts=structnew();
		ts.name="savedcontentCount";
		ts.value=structcount(request.zsession.listing.savedcontentStruct);
		ts.expires="never";
		application.zcore.functions.zCookie(ts);
		//cookie.savedcontentCount=structcount(request.zsession.listing.savedcontentStruct);
		if(structkeyexists(form, 'returnURL')){
			application.zcore.functions.zRedirect(form.returnURL);
		}else{
			application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(request.zos.listing.functions.getSearchFormLink(), 'searchid='&application.zcore.functions.zso(form, 'searchId')));
		}
	}else{
		//Throw Error
		application.zcore.functions.z301Redirect('/');
	}
	</cfscript>
</cfif>

<!--- Send To Inquiry--->
<cfif form.saveAct eq 'inquiry'>
	<cfscript>
	form.listing_id=structkeylist(request.zsession.listing.savedListingStruct);
	form.content_id=structkeylist(request.zsession.listing.savedContentStruct);
	
		tempCom=createobject("component","zcorerootmapping.mvc.z.listing.controller.inquiry");
		tempCom.index();
		</cfscript>
</cfif>

<cfif form.saveAct eq 'removeall'><cfscript>application.zcore.tracking.backOneHit();
	request.zsession.listing.savedListingStruct=structnew();
	request.zsession.listing.savedcontentStruct=structnew();
	application.zcore.listingCom.updateUserSavedListings();
	ts=structnew();
	ts.name="savedListingStruct";
	ts.value="";
	ts.expires="never";
	application.zcore.functions.zCookie(ts);
	ts=structnew();
	ts.name="savedListingCount";
	ts.value=0;
	ts.expires="never";
	application.zcore.functions.zCookie(ts);
	ts=structnew();
	ts.name="savedContentStruct";
	ts.value="";
	ts.expires="never";
	application.zcore.functions.zCookie(ts);
	ts=structnew();
	ts.name="savedcontentCount";
	ts.value=0;
	ts.expires="never";
	application.zcore.functions.zCookie(ts);
	if(structkeyexists(form, 'returnURL')){
		application.zcore.functions.zRedirect(form.returnURL);
	}else{
		searchFormURL=request.zos.listing.functions.getSearchFormLink();
		application.zcore.functions.zRedirect(searchFormURL&'?searchId='&application.zcore.functions.zso(form, 'searchId'));
	}
	</cfscript>
</cfif>
<cfif form.saveAct eq 'delete'><cfscript>application.zcore.tracking.backOneHit();
	if(structkeyexists(form, 'listing_id')){
		structdelete(request.zsession.listing.savedListingStruct, form.listing_id);
		application.zcore.listingCom.updateUserSavedListings();
		ts=structnew();
		ts.name="savedListingCount";
		ts.value=structcount(request.zsession.listing.savedListingStruct);
		ts.expires="never";
		application.zcore.functions.zCookie(ts);
		ts=structnew();
		ts.name="savedListingStruct";
		ts.value=structkeylist(request.zsession.listing.savedListingStruct);
		ts.expires="never";
		application.zcore.functions.zCookie(ts);
		//cookie.savedListingCount=structcount(request.zsession.listing.savedListingStruct);
	}else if(structkeyexists(form, 'content_id')){
		structdelete(request.zsession.listing.savedcontentStruct, form.content_id);
		application.zcore.listingCom.updateUserSavedListings();
		ts=structnew();
		ts.name="savedcontentCount";
		ts.value=structcount(request.zsession.listing.savedcontentStruct);
		ts.expires="never";
		application.zcore.functions.zCookie(ts);
		ts=structnew();
		ts.name="savedcontentStruct";
		ts.value=structkeylist(request.zsession.listing.savedcontentStruct);
		ts.expires="never";
		application.zcore.functions.zCookie(ts);
		//cookie.savedcontentCount=structcount(request.zsession.listing.savedcontentStruct);
	}
	if(structkeyexists(form, 'returnURL')){
		application.zcore.functions.zRedirect(form.returnURL);
	}else{
		searchFormURL=request.zos.listing.functions.getSearchFormLink();
		application.zcore.functions.zRedirect(searchFormURL&'?searchId='&application.zcore.functions.zso(form, 'searchId'));
	}
	</cfscript>
</cfif>
</cffunction>
</cfoutput>
</cfcomponent>