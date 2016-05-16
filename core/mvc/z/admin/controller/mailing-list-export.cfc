<cfcomponent>
<cfoutput>
<cffunction name="download" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qU=0;
	var qM=0
	var arrLine=arraynew(1);
	var filterSQL1="";
	var filterSQL2="";
	application.zcore.functions.zSetPageHelpId("4.9");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Mailing List Export");	
	if(structkeyexists(form,'alldata') EQ false){
		filterSQL1=" and user_pref_email='1'";
		filterSQL2=" and mail_user_opt_in='1'";
	} 
	header name="Content-Type" value="text/plain" charset="utf-8";
	header name="Content-Disposition" value="attachment; filename=#dateformat(now(), 'yyyy-mm-dd')#-mailing-list-export.csv" charset="utf-8";

	echo('"Email","Company","First Name","Last Name","Phone","Opt In","Opt In Confirmed","Created Datetime"'&chr(10));
	db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_active=#db.param('1')# and 
	user_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# 
	#db.trustedSQL(filterSQL1)#";
	qU=db.execute("qU");
	loop query="qU"{
		echo('"'&qU.user_username&'","'&replace(qU.member_company,'"', "'", 'all')&'","'&qU.user_first_name&'","'&qU.user_last_name&'","'&qU.user_phone&'","'&qU.user_pref_email&'","'&qU.user_confirm&'","'&dateformat(qU.user_created_datetime, 'm/d/yyyy')&" "&timeformat(qU.user_created_datetime, 'h:mm tt')&'"'&chr(10));
	}
	db.sql="select * from #db.table("mail_user", request.zos.zcoreDatasource)# mail_user 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	mail_user_deleted = #db.param(0)# 
	#db.trustedSQL(filterSQL2)#";
	qM=db.execute("qM");
	loop query="qM"{
		echo('"'&qM.mail_user_email&'","","'&qM.mail_user_first_name&'","'&qM.mail_user_last_name&'","'&qM.mail_user_phone&'","'&qM.mail_user_opt_in&'","'&qM.mail_user_confirm&'","'&dateformat(qM.mail_user_datetime, 'm/d/yyyy')&" "&timeformat(qM.mail_user_datetime, 'h:mm tt')&'"'&chr(10));
	}
	abort;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qU=0;
	var qM=0
	var arrLine=arraynew(1);
	var filterSQL1="";
	var filterSQL2="";
	application.zcore.functions.zSetPageHelpId("4.9");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Mailing List Export");	
	if(structkeyexists(form,'alldata') EQ false){
		filterSQL1=" and user_pref_email='1'";
		filterSQL2=" and mail_user_opt_in='1'";
	}
	</cfscript>
	<h2>Mailing List Export</h2>
	<p>The system currently doesn't have any bulk mailing features.  You must export the data and import it into another system to send mail to your users.</p>
	<p>User who opt in and then click yes in the confirmation email are marked "1" in the "Opt In Confirmed" column.</p>
	<h2>Download Options</h2>
	<p><a href="/z/admin/mailing-list-export/download">Opt-in Only List (recommended)</a> | <a href="/z/admin/mailing-list-export/download?alldata=1">Opt-in and Opt-out list</a>.</p>

	<p><strong>Warning:</strong> Emailing people who have already opt-out is not advised and can cause serious problems preventing future emails from being delivered.  In most cases sending spam is against the rules for your email service provider and/or internet service provider.</p> 
	<p>You should periodically re-download the list so that you don't email people who have opt out.  The <a href="/z/user/privacy/index" target="_blank">privacy policy</a> should say how long it takes for you to update the list. Let your web developer know if you need to change the privacy policy.</p>
</cffunction>
</cfoutput>
</cfcomponent>
