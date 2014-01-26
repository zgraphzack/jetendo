<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	if(not application.zcore.user.checkGroupAccess("user")){
		application.zcore.functions.zRedirect("/z/user/preference/index");
	}
	application.zcore.template.setTag("title","User Dashboard");
	application.zcore.template.setTag("pagetitle","User Dashboard");
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<ul style="line-height:150%; font-size:120%;">
	<cfif application.zcore.user.checkGroupAccess("member")>
		<li><a href="/z/admin/admin-home/index">Site Manager</a></li>
	</cfif>
	<li><a href="/z/user/preference/form">Edit Profile</a></li>
	<cfif application.zcore.app.siteHasApp("listing")>
		<li><a href="/z/listing/property/your-saved-searches">Your Saved Searches</a></li>
		<li><a href="/z/listing/sl/view">Your Saved Listings</a></li>
	</cfif>
	<li><a href="/z/user/preference/index?zlogout=1">Log Out</a></li>
	</ul>
	<hr />
	
	<cfscript>
	if(application.zcore.app.siteHasApp("content")){
		ts=structnew();
		ts.content_unique_name='/z/user/home/index';
		ts.disableContentMeta=true; 
		ts.disableLinks=true;
		r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
		if(r1 EQ false){
			inquiryTextMissing=true;
		}else{
			inquiryTextMissing=false;	
		}
	}
	if(structkeyexists(application.siteStruct[request.zos.globals.id].zcoreCustomFunctions, 'memberDashboard')){
		echo(application.siteStruct[request.zos.globals.id].zcoreCustomFunctions.memberDashboard());
		echo('<hr />');
	}
		// TODO: add stuff for listing / rentals here someday like saved searches, inquiries, etc.
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>