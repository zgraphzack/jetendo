<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" output="yes" access="remote">
	<cfscript>
	var user_group_id2=0;
	var newlistingcount=0;
	var tmp=0;
	var propertyDataCom=0;
	var user_group_id=0;
	var r1=0;
	var user_group_id4=0;
	var user_group_id2=0;
	var user_group_id5=0;
	var user_group_id6=0;
	var user_group_id3=0;
	var ts=0;
	var inquiryTextMissing=0;
	var qMember=0;
	var propDisplayCom=0;
	var userGroupCom=0;
	var db=request.zos.queryObject;
	application.zcore.template.settag("pagenav","<a href=""#application.zcore.functions.zvar('domain')#/"">Home</a> /");
	</cfscript>
  <cfif application.zcore.app.siteHasApp("content")>
    <cfscript>
    inquiryTextMissing=false;
    ts=structnew();
    ts.content_unique_name='/z/misc/members/index';
    ts.disableContentMeta=false;
    ts.disableLinks=true;
    r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
    if(r1 EQ false){
        inquiryTextMissing=true;
    }
    </cfscript>
    <cfelse>
    <cfset inquiryTextMissing=true>
  </cfif>
  <cfif inquiryTextMissing>
    <cfscript>
		application.zcore.template.setTag("title","Our Team");
		application.zcore.template.setTag("pagetitle","Our Team");
        </cfscript>
    <p>Our team is here to serve you.</p>
  </cfif>
  <cfscript> 
userGroupCom = CreateObject("component","zcorerootmapping.com.user.user_group_admin");
user_group_id = userGroupCom.getGroupId('agent',request.zos.globals.id);
user_group_id2 = userGroupCom.getGroupId('broker',request.zos.globals.id);
user_group_id3 = userGroupCom.getGroupId('administrator',request.zos.globals.id);
user_group_id22 = userGroupCom.getGroupId('member',request.zos.globals.id);
if(request.zos.globals.parentid NEQ 0){
  user_group_id44 = userGroupCom.getGroupId('member',request.zos.globals.parentid);
	user_group_id4 = userGroupCom.getGroupId('agent',request.zos.globals.parentid);
	user_group_id5 = userGroupCom.getGroupId('broker',request.zos.globals.parentid);
	user_group_id6 = userGroupCom.getGroupId('administrator',request.zos.globals.parentid);/**/
}
</cfscript>
  <cfsavecontent variable="db.sql"> 
  SELECT *, count(content_id) listingcount, user.site_id userSiteId 
  FROM #request.zos.queryObject.table("user", request.zos.zcoreDatasource)# user
  <cfif application.zcore.app.siteHasApp("content")>
    LEFT JOIN #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content ON 
	content_listing_user_id = user.user_id and 
	content_for_sale = #db.param('1')# and 
	content_mls_number=#db.param('')# and 
	content_deleted=#db.param('0')#  and 
	content.site_id = #db.param(request.zos.globals.id)# and 
  content_deleted = #db.param(0)#
  </cfif>
  WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
member_public_profile=#db.param('1')# and 
user_deleted = #db.param(0)# 
  
  and user.user_group_id IN (#db.param(user_group_id)#,#db.param(user_group_id2)#,#db.param(user_group_id22)#,#db.param(user_group_id3)#
  <cfif request.zos.globals.parentid NEQ 0>
    ,#db.param(user_group_id44)#,#db.param(user_group_id4)#,#db.param(user_group_id5)#,#db.param(user_group_id6)#
  </cfif>
  )
  GROUP BY user_id 
  ORDER BY member_sort ASC, member_first_name ASC </cfsavecontent>
  <cfscript>
qMember=db.execute("qMember");
</cfscript>
  <cfif application.zcore.app.siteHasApp("listing")>
    <cfscript>
propertyDataCom = CreateObject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
propDisplayCom = CreateObject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");

</cfscript>
  </cfif>
  <cfloop query="qMember">
  <div class="zMemberFullDiv">
    <div class="zMemberImageDiv">
      <cfif fileexists(application.zcore.functions.zVar('privatehomedir',qMember.userSiteId)&removechars(request.zos.memberImagePath,1,1)&qMember.member_photo)>
        <span><img src="<cfif application.zcore.functions.zvar('domainaliases',qMember.userSiteId) NEQ "">http://#application.zcore.functions.zvar('domainaliases',qMember.userSiteId)#<cfelse>#application.zcore.functions.zvar('domain',qMember.userSiteId)#</cfif>#request.zos.memberImagePath##qMember.member_photo#" alt="#htmleditformat(qMember.member_first_name&" "&qMember.member_last_name)#" style="border:none;" /></span>
        <cfelse>
        &nbsp;<!--- Image N/A --->
      </cfif>
    </div>
    <div class="zMemberTextDiv"> <a id="#application.zcore.functions.zURLEncode(qMember.member_first_name&'-'&qMember.member_last_name,'-')#" id="#application.zcore.functions.zURLEncode(qMember.member_first_name&'-'&qMember.member_last_name,'-')#"></a> <strong>#qMember.member_first_name# #qMember.member_last_name#
      <cfif qMember.member_title NEQ ''>
        , #qMember.member_title#
      </cfif>
      </strong><br />
      <cfif qMember.member_phone NEQ ''>
        <strong>Phone:</strong> #qMember.member_phone#<br />
      </cfif>
      <cfif qMember.member_email NEQ ''>
        <strong>Email:</strong> #application.zcore.functions.zEncodeEmail(qMember.member_email,true)#<br />
      </cfif>
      <cfif qMember.member_website NEQ ''>
        <strong>Web Site:</strong> <a href="#qMember.member_website#" target="_blank">Visit Web Site</a><br />
      </cfif>
      
      <cfscript>
		  tmp=qMember.member_description;
		  tmp=rereplace(tmp,"<script.*?</script>"," ","ALL");
		  tmp=rereplace(tmp,"<.*?>"," ","ALL");
		  
		  newlistingcount=qMember.listingcount;
		  </cfscript>
      <cfif tmp NEQ ''>
        <div>#trim(left(tmp,250))#...</div>
        <br />
      </cfif>
      <strong>
      <cfif application.zcore.app.siteHasApp("content")>
        <a href="/#application.zcore.functions.zURLEncode(lcase(qMember.member_first_name&'-'&qMember.member_last_name),'-')#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_listing_user_id#-#qMember.user_id#.html" class="zMemberBioLink">View my
        <cfif newlistingcount NEQ 0>
          #newlistingcount# listings and
        </cfif>
        full bio</a>
        <cfelse>
        <a href="/#application.zcore.functions.zURLEncode(lcase(qMember.member_first_name&'-'&qMember.member_last_name),'-')#-14-#user_id#.html" class="zMemberBioLink">View my full bio</a>
      </cfif>
      </strong> </div>
  </div>
  </cfloop>
</cffunction>
</cfoutput>
</cfcomponent>
