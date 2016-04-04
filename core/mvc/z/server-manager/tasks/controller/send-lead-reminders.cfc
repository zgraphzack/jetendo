<cfcomponent>
<cfoutput>
<cffunction name="send" localmode="modern" access="remote">
	<cfscript>
	setting requesttimeout="10000";
	if(not request.zos.isTestServer){
		throw("disabled on production for now");
	}
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}  
	db=request.zos.queryObject;
	emailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.email");
	previousDate=dateadd("d",-2,now());
	previousDateFormatted=dateformat(previousDate,'yyyy-mm-dd')&' '&timeformat(previousDate,'HH:mm:ss');
	db.sql="SELECT * 
	FROM #request.zos.queryObject.table("inquiries", request.zos.zcoreDatasource)# WHERE  
    inquiries_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_status_id IN (1, 2) ";
	qI=db.execute("qI");

	if(application.zcore.functions.zvar("enableLeadUserReminder") EQ 1){
		userReminderEnabled=true;
	}else{
		userReminderEnabled=true;
	}
	if(application.zcore.functions.zvar("enableLeadAdminReminder") EQ 1){
		adminReminderEnabled=true;
	}else{
		adminReminderEnabled=true;
	}
	if(not userReminderEnabled and not adminReminderEnabled){
		return;
	}

	if(application.zcore.functions.zvar("enableLeadReminderDisableCC") EQ 1){
		disableCC=true;
	}else{
		disableCC=false;
	}
	delay1=application.zcore.functions.zvar('leadReminderEmail1DelayMinutes');
	delay2=application.zcore.functions.zvar('leadReminderEmail2DelayMinutes');
	delay3=application.zcore.functions.zvar('leadReminderEmail3DelayMinutes');
	/*
	
	ADD COLUMN `site_enable_lead_reminder_disable_cc` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_custom_create_account_url`,
	ADD COLUMN `site_enable_lead_user_reminder` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_enable_lead_reminder_disable_cc`,
	ADD COLUMN `site_enable_lead_admin_reminder` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_enable_lead_user_reminder`,
	ADD COLUMN `site_lead_reminder_email1_delay_minutes` INT(11) DEFAULT 0  NOT NULL AFTER `site_enable_lead_admin_reminder`,
	ADD COLUMN `site_lead_reminder_email2_delay_minutes` INT(11) DEFAULT 0  NOT NULL AFTER `site_lead_reminder_email1_delay_minutes`,
	ADD COLUMN `site_lead_reminder_email3_delay_minutes` INT(11) DEFAULT 0  NOT NULL AFTER `site_lead_reminder_email2_delay_minutes`")){
	inquiries_reminder_sent_datetime
	inquiries_reminder_count
	user_alternate_email
	*/
	</cfscript>
    <cfloop query="qI">
        <cfscript>		
		ts={};
		ts.from=request.fromemail;
		ts.to=application.zcore.functions.zvarso("zofficeemail");
		if(ts.to EQ ""){
			ts.to=request.zos.developerEmailTo;
		}
		if(request.zos.isTestServer){
			ts.to=request.zos.developerEmailTo;
		}
		/*
		if(userIsAdministrator){
			// do I send reminder?
			site_enable_lead_user_reminder

		if(userIsMember){
			// http://www.mistyharborboats.com.127.0.0.2.nip.io/z/inquiries/admin/manage-inquiries/userView?inquiries_id=19&zPageId=4
		}else{
			// http://www.mistyharborboats.com.127.0.0.2.nip.io/z/inquiries/admin/manage-inquiries/userView?inquiries_id=19&zPageId=4
		}
		*/
		ts.subject="#groupName# has been #arguments.action# on #request.zos.cgi.http_host#";
		ts.html='<!DOCTYPE html>
		<html>
		<head><title>Alert</title></head>
		<body>
		<h3>Lead Status Not Updated</h3>

		<p>The following lead has not been had a status update since it was assigned to you.  We require you to login and update the lead status describing what action you''ve taken to contact the lead and what happened.</p>

		<a href="#request.zos.globals.domain#" target="_blank">#request.zos.globals.shortDomain#</a>.</h3>';
		/*
		if(qUser.recordcount){
			ts.html&='<p>User: #qUser.user_first_name# #qUser.user_last_name# (#qUser.user_email#)</p>';
		} 
		ts.html&='<p>#qCheckSet.site_x_option_group_set_title#</p> 
		<p>'; 
		if(arguments.action NEQ "deleted"){
			if(qGroup.site_option_group_enable_unique_url EQ 1){
				if(qCheckSet.site_x_option_group_set_override_url NEQ ""){
					link=qCheckSet.site_x_option_group_set_override_url;
				}else{
					var urlId=request.zos.globals.optionGroupUrlId;
					if(urlId EQ "" or urlId EQ 0){
						throw("site_option_group_url_id is not set for site_id, #site_id#.");
					}
					link="/#application.zcore.functions.zURLEncode(qCheckSet.site_x_option_group_set_title, '-')#-#urlId#-#qCheckSet.site_x_option_group_set_id#.html";
				}
				ts.html&='<a href="#request.zos.globals.domain##link#" target="_blank">View</a> | ';
			}
			ts.html&='<a href="#request.zos.globals.domain#/z/admin/site-options/editGroup?site_option_app_id=0&amp;site_option_group_id=#qCheckSet.site_option_group_id#&amp;site_x_option_group_set_id=#qCheckSet.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=0" target="_blank">Edit</a>';
		}
		*/ 
		ts.html&=' | <a href="#request.zos.globals.domain#/z/admin/site-options/manageGroup?site_option_app_id=0&site_option_group_id=#qCheckSet.site_option_group_id#" target="_blank">Manage #groupName#(s)</a></p>
		</body></html>';

		writedump(ts);
		abort;
		
		rCom=application.zcore.email.send(ts);
		if(rCom.isOK() EQ false){
			rCom.setStatusErrors(request.zsid);
			application.zcore.functions.zstatushandler(request.zsid);
			application.zcore.functions.zabort();
		}	 
        </cfscript> 
    </cfloop>
</cffunction>
 

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	if(not request.zos.isTestServer){
		throw("disabled on production for now");
	}
	setting requesttimeout="10000"; 
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_id <> #db.param(-1)# and 
	site_active = #db.param(1)# and 
	site_deleted = #db.param(0)# and 
	site_enable_lead_reminder = #db.param(1)#";
	qSite=db.execute("qSite"); 
	for(row in qSite){
		link=row.site_domain&"/z/server-manager/tasks/send-lead-reminders/send";
		rs=application.zcore.functions.zdownloadlink(link, 3000, true);
		writedump(rs);abort;
		if(not rs.success){
			savecontent variable="out"{
				echo('Failed to complete http request: #link#');
				writedump(rs);
			}
			throw(out);
		}
	}
	</cfscript>
	done
</cffunction>
</cfoutput>
</cfcomponent>