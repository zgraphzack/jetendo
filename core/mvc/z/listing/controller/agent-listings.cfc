<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
<cfscript>
var tempName=0;
var qC=0;
var userusergroupid=0;
var t2=0;
var qM=0;
var userGroupCom=0;
var perpage=0;
var arrOrder=0;
var returnStruct=0;
var perpageDefault=0;
var propertyDataCom=0;
var parentChildSorting2=0;
var res=0;
var ts=0;
var i=0;
var propDisplayCom=0;
		var db=request.zos.queryObject;
		returnStruct={count:0};
userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");

application.zcore.app.getAppCFC("content").initExcludeContentId();

form.content_listing_user_id=application.zcore.functions.zso(form, 'content_listing_user_id');
userusergroupid = userGroupCom.getGroupId('user',request.zos.globals.id);
db.sql="select *, user.site_id userSiteId 
from #request.zos.queryObject.table("user", request.zos.zcoreDatasource)# user 
where user.user_id = #db.param(form.content_listing_user_id)#  and 
user_active=#db.param('1')# and 
member_public_profile=#db.param('1')# and 
user_deleted = #db.param(0)# and 
#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())#";
qM=db.execute("qM"); 
if(isQuery(qM) EQ false or qM.recordcount EQ 0){
	application.zcore.functions.z404("user record is missing.");
}
t2="#qM.member_first_name# #qM.member_last_name# ";
application.zcore.template.settag("title",t2);
application.zcore.template.settag("pagetitle",t2);
application.zcore.template.settag("pagenav","<a href=""#application.zcore.functions.zvar('domain')#/"">Home</a> / <a href=""/z/misc/members/index"">Our Team</a> /");
tempName=application.zcore.functions.zurlencode(lcase(t2),'-');

if(application.zcore.app.siteHasApp("content")){
	db.sql="select * FROM #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content 
	where content_listing_user_id = #db.param(form.content_listing_user_id)# and 
	content_mls_number = #db.param('')# and 
	content_for_sale=#db.param('1')# and 
	content_deleted=#db.param('0')# and 
	site_id = #db.param(request.zos.globals.id)#";
	qC=db.execute("qC"); 
	if(tempName NEQ form.zURLName){
		application.zcore.functions.z301Redirect("/#tempName#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_listing_user_id#-#qM.user_id#.html");
	}
}else{
	// old table
	db.sql="select * FROM #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content 
	where content_listing_user_id = #db.param(form.content_listing_user_id)# and 
	content_for_sale = #db.param('1')# and 
	site_id = #db.param(request.zos.globals.id)# and 
	content_deleted = #db.param(0)#";
	qC=db.execute("qC"); 
	if(tempName NEQ form.zURLName){
		application.zcore.functions.z301Redirect("/#tempName#-#urlappid#-#qM.user_id#.html");
	}
}
	request.contentCount=0;
	request.cOutStruct=structnew();	
</cfscript>

<cfloop query="qM">		
<div class="zMemberFullDiv">
        <div class="zMemberImageDiv"><a id="member#qM.user_id#"></a><cfif fileexists(application.zcore.functions.zVar('privatehomedir',qM.userSiteId)&removechars(request.zos.memberImagePath,1,1)&qM.member_photo)><span><img src="<cfif application.zcore.functions.zvar('domainaliases',qM.userSiteId) NEQ "">http://#application.zcore.functions.zvar('domainaliases',qM.userSiteId)#<cfelse>#application.zcore.functions.zvar('domain',qM.userSiteId)#</cfif>#request.zos.memberImagePath##qM.member_photo#" alt="#htmleditformat(qM.member_first_name&" "&qM.member_last_name)#" style="border:none;" /></span><cfelse>Image N/A</cfif></div>
        <div class="zMemberTextDiv">
		
         <cfif qM.member_title NEQ ''><strong>Title:</strong> #qM.member_title#<br /> </cfif>
          <cfif qM.member_phone NEQ ''><strong>Phone:</strong> #qM.member_phone#<br /></cfif>
		  <cfif qM.member_email NEQ '' and qM.user_hide_public_email EQ 0><strong>Email:</strong> #application.zcore.functions.zEncodeEmail(qM.member_email,true)#<br /></cfif>
		  <cfif qM.member_website NEQ ''><strong>Web Site:</strong> <a href="#qM.member_website#" target="_blank">Visit Web Site</a><br /></cfif>
		  <cfif qM.user_googleplus_url NEQ ''><strong>Google+:</strong> <a href="#qM.user_googleplus_url#" target="_blank">Find me on Google+</a><br /></cfif>
		  <cfif qM.user_twitter_url NEQ ''><strong>Twitter:</strong> <a href="#qM.user_twitter_url#" target="_blank">Find me on Twitter</a><br /></cfif>
		  <cfif qM.user_facebook_url NEQ ''><strong>Facebook:</strong> <a href="#qM.user_facebook_url#" target="_blank">Find me on Facebook</a><br /></cfif>

          <cfif qM.member_description NEQ ''><div>#trim(qM.member_description)#</div></cfif></div></div>
<!--- 
#application.zcore.functions.zdump(qm)#
#application.zcore.functions.zdump(qc)#
 #form.content_listing_user_id#| i am here! --->
<cfsavecontent variable="local.tempAgentOutput">
<cfloop from="1" to="#qC.recordcount#" index="i">
    <cfset content_id = qc.content_id[i]>
    <cfscript>
    application.zcore.app.getAppCFC("content").getPropertyInclude(content_id);
    </cfscript>
</cfloop>

<cfif application.zcore.app.siteHasApp("listing") and qm.member_mlsagentid NEQ "" and qm.member_mlsagentid NEQ ",,">
<cfscript>
propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");


ts = StructNew();
ts.offset =0;
perpageDefault=100;
perpage=100;
perpage=max(1,min(perpage,100));
if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
	ts.debug=true;	
}
ts.perpage = perpage;
ts.distance = 30; // in miles
ts.disableCount=true;
ts.searchCriteria=structnew();
ts.searchCriteria.search_result_limit=100;
form.search_result_limit=ts.searchCriteria.search_result_limit;
if(qm.user_listing_sort EQ 2){
	parentChildSorting2=2;
	ts.searchCriteria.search_sort="priceasc";
}else{
	parentChildSorting2=1;
	ts.searchCriteria.search_sort="pricedesc";
}
ts.searchCriteria.search_result_layout=application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_list_layout;
form.search_result_layout=ts.searchCriteria.search_result_layout; 
ts.searchCriteria.search_agent=qm.member_mlsagentid;
//ts.debug=true;
returnStruct = propertyDataCom.getProperties(ts);
structdelete(variables,'ts');
if(returnStruct.count NEQ 0){	
	ts = StructNew();
	ts.output=false;
	returnStruct.perpage=form.search_result_limit;
	ts.search_result_layout=form.search_result_layout;
	ts.dataStruct = returnStruct;
	propDisplayCom.init(ts);
	
	res=propDisplayCom.display();
} 

    if(parentChildSorting2 EQ 1){
		arrOrder=structsort(request.cOutStruct,"numeric","desc","price");
	}else if(parentChildSorting2 EQ 2){
		arrOrder=structsort(request.cOutStruct,"numeric","asc","price");
	}else if(parentChildSorting2 EQ 0){
		arrOrder=structsort(request.cOutStruct,"numeric","asc","sort");
	}
	for(i=1;i LTE arraylen(arrOrder);i++){
		writeoutput(request.cOutStruct[arrOrder[i]].output);
	}
	</cfscript>
</cfif>
</cfsavecontent>
<cfif qC.recordcount NEQ 0 or returnStruct.count NEQ 0>
<h2>View My Listings</h2>
</cfif>
#local.tempAgentOutput#
</cfloop>
</cffunction>
 </cfoutput>
 </cfcomponent>