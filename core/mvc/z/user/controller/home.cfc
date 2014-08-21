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

	ws=application.zcore.app.getWhitelabelStruct();
	</cfscript>
	<style type="text/css">
	.zPublicDashboardButton:link, .zPublicDashboardButton:visited{ width:150px;text-decoration:none; color:##000;padding:1%;display:block; border:1px solid ##CCC; margin-right:2%; margin-bottom:2%; background-color:##F3F3F3; border-radius:10px; text-align:center; float:left; }
	.zPublicDashboardButton:hover{background-color:##FFF; border:1px solid ##666;display:block; color:##666;}
	.zPublicDashboardButtonImage{width:100%; float:left;margin-bottom:5px;display:block;}
	.zPublicDashboardButtonTitle{width:100%; float:left;margin-bottom:5px; font-size:115%; display:block;font-weight:bold;}
	.zPublicDashboardButtonSummary{width:100%; float:left;}
	</style>
	<div style="margin-bottom:20px; width:100%; float:left;">#ws.whitelabel_public_dashboard_header_html#</div>
	<div style="margin-bottom:20px; width:100%; float:left;">
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

		<cfscript> 
		if(structkeyexists(ws, 'arrPublicButton')){
			echo('<div style="width:100%; float:left;margin-top:20px;">');
			for(i=1;i LTE arraylen(ws.arrPublicButton);i++){
				bs=ws.arrPublicButton[i];
				if(bs.whitelabel_button_builtin EQ ""){
					link=bs.whitelabel_button_url;
				}else{
					link=bs.whitelabel_button_builtin;
				}
				echo('<a href="#link#" target="#bs.whitelabel_button_target#" class="zPublicDashboardButton">');
				if(bs.whitelabel_button_image64 NEQ ""){
					echo('<span class="zPublicDashboardButtonImage"><img src="#ws.imagePath&bs.whitelabel_button_image64#" alt="#htmleditformat(bs.whitelabel_button_label)#" /></span>');
				}
				echo('<span class="zPublicDashboardButtonTitle">#bs.whitelabel_button_label#</span>
					<span class="zPublicDashboardButtonSummary">#bs.whitelabel_button_summary#</span></a>');

			}
			echo('</div>');
		}
		</cfscript>
	</div>
	<div style="margin-top:20px; width:100%; float:left;">#ws.whitelabel_public_dashboard_footer_html#</div>
</cffunction>
</cfoutput>
</cfcomponent>