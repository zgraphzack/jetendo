<cfcomponent>
<cfoutput>
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
	<p>The system currently doesn't have any bulk mailing features.  You must export the data into another system to send mail to your users.</p>
	<p>User who opt in and then click yes in the confirmation email are marked "1" in the "Opt In Confirmed" column.</p>
	<cfif structkeyexists(form,'alldata') EQ false>
		<p>Only people who have opt in are shown below. <a href="/z/admin/mailing-list-export/index?alldata=1">Click here if you want to export all data</a>.</p>
	<cfelse>
		<p><strong>Warning:</strong> All mailing list data is included below including those who have not opt in or who have chosen to opt out. Emailing people who have not agreed to receive email may result in your email hosting services being blocked or terminated.  Use this data at your own risk. <a href="/z/admin/mailing-list-export/index">Click here to only show data for opt in users</a>.</p>
	</cfif>
	<p>You should periodically re-download the list so that you don't email people who have opt out.  The <a href="/z/user/privacy/index" target="_blank">privacy policy</a> should say how long it takes for you to update the list. Let your web developer know if you need to change the privacy policy.</p>
	<p>Copy and paste the following mailing list data into a spreadsheet for us in another system.</p>
	<cfscript>
	arrayAppend(arrLine, '"Email","First Name","Last Name","Phone","Opt In","Opt In Confirmed"');
	db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_active=#db.param('1')# and 
	user_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# 
	#db.trustedSQL(filterSQL1)#";
	qU=db.execute("qU");
	loop query="qU"{
		arrayAppend(arrLine, '"'&qU.user_username&'","'&qU.user_first_name&'","'&qU.user_last_name&'","'&qU.user_phone&'","'&qU.user_pref_email&'","'&qU.user_confirm&'"');
	}
	db.sql="select * from #db.table("mail_user", request.zos.zcoreDatasource)# mail_user 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	mail_user_deleted = #db.param(0)# 
	#db.trustedSQL(filterSQL2)#";
	qM=db.execute("qM");
	loop query="qM"{
		arrayAppend(arrLine, '"'&qM.mail_user_email&'","'&qM.mail_user_first_name&'","'&qM.mail_user_last_name&'","'&qM.mail_user_phone&'","'&qM.mail_user_opt_in&'","'&qM.mail_user_confirm&'"');
	}
	writeoutput('<textarea name="ca2" onclick="this.select();" cols="100" rows="5">'&arraytolist(arrLine,chr(10))&'</textarea>');
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
