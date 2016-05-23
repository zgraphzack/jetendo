<cfcomponent displayname="User" output="no" hint="This component will be used for all user logins, login forms and permission checks">
<cfoutput>
<cfscript>
this.comName = "zcorerootmapping.com.user.user";
this.customSet = true;
this.customStruct = StructNew();
</cfscript>

<cffunction name="createAccountMessage" localmode="modern">
	<cfscript>
	return '<p>Did you know you can create an account to make your saved information easier to retrieve in the future? <a href="/z/user/preference/index">Create an account or login</a></p>';
	</cfscript>
</cffunction>

<cffunction name="isCustomSet" localmode="modern" returntype="any" output="false">
	<cfscript>
	if(this.customSet){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>
<cffunction name="getPublicMembers" localmode="modern" returntype="any" output="false">
	<cfscript> 
	var qmember=0;
	var db=request.zos.queryObject;
	var local=structnew();
	var userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	var user_group_id = userGroupCom.getGroupId('agent',request.zos.globals.id);
	var user_group_id2 = userGroupCom.getGroupId('broker',request.zos.globals.id);
	var user_group_id3 = userGroupCom.getGroupId('administrator',request.zos.globals.id);
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user.site_id = #db.param(request.zos.globals.id)# and 
	user_deleted = #db.param(0)# and 
	user.user_group_id IN (#db.param(user_group_id)#,#db.param(user_group_id2)#,#db.param(user_group_id3)#) and member_public_profile=#db.param('1')# 
	ORDER BY member_sort ASC, member_first_name ASC ";
	qMember=db.execute("qMember");
	return qMember;
	</cfscript>
</cffunction>

<!--- user_id=application.zcore.user.automaticAddUser(application.zcore.functions.zUserMapFormFields(structnew())); --->
<cffunction name="automaticAddUser" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qU=0;
	var db=request.zos.queryObject;
	var ts=structnew();
	var mail_user_id=false;
	if(application.zcore.functions.zso(arguments.ss, 'user_pref_list', false,'0') EQ '0'){
		// don't add them if they didn't check opt in box.
		return 0;	
	}
	db.sql="select user_id, user_pref_email from #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_username=#db.param(arguments.ss.user_username)# and 
	user_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)#";
	qU=db.execute("qU"); 
	if(qU.recordcount NEQ 0){
		// already a user
		if(qU.user_pref_email EQ 0){
			// reset autoresponder confirm
			db.sql="update #db.table("user", request.zos.zcoreDatasource)# user 
			set user_confirm=#db.param(0)#, 
			user_confirm_count =#db.param(0)#, 
			user_pref_email=#db.param(1)#,
			user_updated_datetime=#db.param(request.zos.mysqlnow)#  
			WHERE user_id=#db.param(qU.user_id)# and 
			user_deleted = #db.param(0)# and 
			site_id=#db.param(request.zos.globals.id)#";
			db.execute("q"); 
		}
		return 0;	
	}
	db.sql="select mail_user_id, mail_user_opt_in, mail_user_confirm 
	from #db.table("mail_user", request.zos.zcoreDatasource)# mail_user 
	WHERE mail_user_email=#db.param(arguments.ss.user_username)# and 
	mail_user_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)#";
	qU=db.execute("qU"); 
	if(qU.recordcount NEQ 0){
		if(qU.mail_user_opt_in EQ 0){
			db.sql="update #db.table("mail_user", request.zos.zcoreDatasource)#  
			set mail_user_confirm=#db.param(0)#, 
			mail_user_confirm_count=#db.param(0)#, 
			mail_user_opt_in=#db.param(1)#,
			mail_user_updated_datetime=#db.param(request.zos.mysqlnow)#  
			WHERE mail_user_id=#db.param(qU.mail_user_id)# and 
			mail_user_deleted = #db.param(0)# and 
			site_id=#db.param(request.zos.globals.id)#";
			db.execute("q"); 
			mail_user_id=qU.mail_user_id;
		}
	}else{
		ts.table="mail_user";
		ts.datasource=request.zos.zcoreDatasource;
		ts.struct=structnew();
		ts.struct.mail_user_email=application.zcore.functions.zso(arguments.ss, 'user_username');
		ts.struct.mail_user_first_name=application.zcore.functions.zso(arguments.ss, 'user_first_name');
		ts.struct.mail_user_last_name=application.zcore.functions.zso(arguments.ss, 'user_last_name');
		ts.struct.mail_user_phone=application.zcore.functions.zso(arguments.ss, 'user_phone');
		ts.struct.mail_user_datetime=request.zos.mysqlnow;
		ts.struct.mail_user_sent_datetime=request.zos.mysqlnow;
		ts.struct.mail_user_updated_datetime=request.zos.mysqlnow;
		ts.struct.mail_user_key=hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256'); 
		ts.struct.mail_user_opt_in=1;
		ts.struct.mail_user_confirm=0;
		ts.struct.site_id=request.zos.globals.id;
		ts.struct.mail_user_confirm_count=0;
		mail_user_id=application.zcore.functions.zInsert(ts);
	}
	if(mail_user_id NEQ false){
		// send autoresponder
		application.zcore.functions.zSendMailUserAutoresponder(mail_user_id);
	}
	
	return mail_user_id;
	</cfscript>
</cffunction>

<cffunction name="setCustomTable" localmode="modern" returntype="any" output="false" hint="Use this function to connect your custom user table to the zsites user table field.  This must be done before checkLogin or checkGroupAccess can be used. If you're not using a custom table, then send no parameters to this function.">
	<cfargument name="inputStruct" type="any" required="no" default="#false#">
	<!--- this is here for legacy apps only - has no purpose now. --->
</cffunction>

<cffunction name="setLoginLog" localmode="modern" returntype="any" output="no">
	<cfargument name="status" type="numeric" required="yes">
	<cfscript>
	var qLog=0;
	var db=request.zos.queryObject;
	var local=structnew();
	/* definition of status numbers:
	0 - failed login attempt
	1 - successful login
	2 - user account data and login is no longer valid
	3 - manually logged out
	*/
	db.sql="INSERT INTO #db.table("login_log", request.zos.zcoreDatasource)# SET 
	login_log_datetime=#db.param(request.zos.mysqlnow)#,
	login_log_ip=#db.param(request.zos.cgi.remote_addr)#,
	login_log_user_agent=#db.param(cgi.HTTP_USER_AGENT)#,
	site_id=#db.param(request.zos.globals.id)#,
	login_log_status=#db.param(arguments.status)#,
	login_log_updated_datetime=#db.param(request.zos.mysqlnow)#,
	login_log_deleted=#db.param(0)# ";
	if(structkeyexists(form, 'zusername')){
		db.sql&=" , login_log_username = #db.param(form.zusername)#";
	}
	db.execute("qLog");
	</cfscript>
</cffunction>

<!--- #(application.zcore.user.getUserSiteWhereSQL("user", request.zos.globals.id)# --->
<cffunction name="getUserSiteWhereSQL" localmode="modern" output="true" returntype="any">
	<cfargument name="tableName" type="string" required="no" default="user">
	<cfargument name="site_id" type="any" required="no" default="#request.zos.globals.id#">
	<cfscript>
	var r=" (#arguments.tableName#.site_id = #arguments.site_id# or (#arguments.tableName#.user_server_administrator = '1' and #arguments.tableName#.site_id = #Request.zos.globals.serverId#)";
	if(application.zcore.functions.zvar('parentid',arguments.site_id,0) NEQ 0){
		r&=" or (#arguments.tableName#.site_id = #application.zcore.functions.zvar('parentid',arguments.site_id)# and (#arguments.tableName#.user_access_site_children = 1 or #arguments.tableName#.user_sync_site_id_list LIKE '%,#application.zcore.functions.zescape(arguments.site_id)#,%')) ";
	}
	r&=") ";
	return r;
	</cfscript>
</cffunction>

<cffunction name="getSiteIdTypeFromLoggedOnUser" localmode="modern" output="no" returntype="any">
	<cfscript>
	var r="";
	if(request.zsession.user.site_id EQ request.zos.globals.id){
		return "1";
	}else if(request.zsession.user.site_id EQ request.zos.globals.parentId){
		return "2";
	}else if(request.zsession.user.site_id EQ request.zos.globals.serverid){
		return "3";
	}else{
		return "0";
	}
	</cfscript>
</cffunction>

<!--- 
<cfscript>
// set checkLogin options
inputStruct = StructNew();
inputStruct.user_group_name = "administrator";
// optional
inputStruct.secureLogin=true; // secureLogin=false; doesn't have access to areas with secureLogin=true;
inputStruct.noRedirect=false;
inputStruct.loginUrl=request.cgi_script_name;
inputStruct.template = "default";
inputStruct.loginMessage = "Please login below";
inputStruct.usernameLabel = "Your Email Address";
inputStruct.passwordLabel = "Your Password";
// override styles, set to false to use no style
inputStruct.styles.inputs = false;
inputStruct.styles.table = "plaintable";
inputStruct.styles.loginMessage = "highlight";
inputStruct.styles.labels = false;
inputStruct.site_id = request.zos.globals.id;
// perform check 
userCom.checkLogin(inputStruct); 
</cfscript>
 --->
<cffunction name="checkLogin" localmode="modern" returntype="any" output="true" hint="Checks login, displays login form and performs the log out functionality.">
	<cfargument name="inputStruct" type="struct" required="yes">
	<cfscript>
	var qCustom = "";
	var overrideContent = "";
	var qUserCheck = "";
	var i = "";
	var sql = "";
	var local=structnew();
	var oldDate=0;
	var arrG=0;
	var ss = arguments.inputStruct;
	var userSiteId='user';
	var arrLogOut=arrayNew(1);
	var failCount=0;
	var emailSent=false;
	var db=request.zos.queryObject;
	var tmpFail='';
	var qcheck="";
	var rs=structnew();
	var ts={
		openIdEnabled=false,
		noLoginForm=false,
		tokenLoginEnabled=false,
		disableSecurePassword=false,
		checkServerAdministrator=false,
		loginFormUrl=false,
		loginUrl=request.cgi_script_name,
		noRedirect=false,
		secureLogin=true,
		site_id = request.zos.globals.id
	}
	application.zcore.functions.zNoCache();
	
	rs.arrDebugLog=[];
	request.zos.requestLogEntry('user.cfc checkLogin start');
	local.failedLogin=false;
	StructAppend(ss, ts, false);
	if(ss.site_id NEQ request.zos.globals.id){
		userSiteId='user'&ss.site_id;			
	}
	if(ss.user_group_name EQ "serveradministrator"){
		ss.checkServerAdministrator=true;
		ss.user_group_name = "administrator";
	}
	if(isDefined('ss.user_group_name') EQ false){
		throw("Error: COMPONENT: user.cfc: checkLogin: arguments.inputStruct.user_group_name is required.", "exception");
	}
	if(structkeyexists(form,'zLogOut')){
		this.logOut();
		// set login form options
		arguments.inputStruct = ss;
		arguments.inputStruct.loginMessage = "You've been logged out.";
		overrideContent = this.loginForm(arguments.inputStruct);
		if(structkeyexists(ss,'template')){
			if(ss.template EQ false){
				application.zcore.template.setTemplate("zcorerootmapping.templates.nothing",true,true);
			}else{
				application.zcore.template.setTemplate(ss.template,true,true);
			}
		}
		// abort with login form
		application.zcore.template.abort(overrideContent);
	}else if(structkeyexists(form,'zUsername') and structkeyexists(form,'zPassword')){
		// check login_log for repeated failed logins 
		oldDate=dateadd("h",-4,now());
		oldDate=DateFormat(oldDate,'yyyy-mm-dd')&' '&TimeFormat(oldDate,'HH:mm:ss');
		db.sql="SELECT * FROM #db.table("login_log", request.zos.zcoreDatasource)# login_log 
		WHERE login_log_ip=#db.param(request.zos.cgi.remote_addr)# and 
		login_log_deleted = #db.param(0)# and 
		login_log_user_agent=#db.param(left(request.zos.cgi.HTTP_USER_AGENT,150))# and 
		login_log_datetime > #db.param(oldDate)# and 
		login_log_username=#db.param(form.zUsername)# and 
		login_log_status NOT IN (#db.param('1')#,#db.param('3')#) and 
		site_id <> #db.param(-1)# ORDER BY login_log_datetime DESC 
		LIMIT #db.param(0)#,#db.param(10)# ";
		qCheck=db.execute("qCheck");
		arrLogOut=arrayNew(1);
		failCount=0;
		emailSent=false;
		for(local.row in qCheck){
			tmpFail=DateFormat(local.row.login_log_datetime,'yyyy-mm-dd')&' '&TimeFormat(local.row.login_log_datetime,'HH:mm:ss')&" | ";
			if(local.row.login_log_status EQ 0){
				tmpFail&="failed login attempt";
			}else if(local.row.login_log_status EQ 1){
				tmpFail&="successful login";
			}else if(local.row.login_log_status EQ 2){
				tmpFail&="user account data and login is no longer valid";
			}else if(local.row.login_log_status EQ 3){
				tmpFail&="manually logged out";
			}
			arrayappend(arrLogOut, tmpFail);
			if(local.row.login_log_status NEQ 1){
				failCount++;
			}
			if(local.row.login_log_email_sent EQ 1){
				emailSent=true;
			}
		}
		if(structkeyexists(form, 'zdebug')){
			arrayAppend(rs.arrDebugLog, "FailCount is #failCount#");
		}
		if(failCount EQ 10){
			if(emailSent EQ false){
				db.sql="UPDATE #db.table("login_log", request.zos.zcoreDatasource)# login_log 
				SET login_log_email_sent =#db.param(1)#,
				login_log_updated_datetime=#db.param(request.zos.mysqlnow)# 
				WHERE login_log_ip=#db.param(request.zos.cgi.remote_addr)# and 
				login_log_deleted = #db.param(0)# and 
				login_log_user_agent=#db.param(left(request.zos.cgi.HTTP_USER_AGENT,150))# and 
				login_log_datetime > #db.param(oldDate)# and 
				site_id <> #db.param(-1)# ";
				qCheck=db.execute("qCheck");
				// need to make sure i only email myself once 
				mail  to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="Jetendo CMS has detected abusive login behavior."{
					writeoutput('Domain: #request.zos.cgi.http_host##chr(10)#Username: #form.zUsername##chr(10)#IP: #request.zos.cgi.remote_addr##chr(10)#User Agent: #cgi.HTTP_USER_AGENT##chr(10)#Date: #request.zos.mysqlnow##chr(10)#Last 10 login attempts failed within 4 hours:#chr(10)##arraytolist(arrLogOut,chr(10))##chr(10)&chr(10)#This IP+User Agent+username will not be able to login until there are fewer then 10 failures in the `#request.zos.zcoreDatasource#`.login_log in the last 4 hours.');
				}
			}
			if(structkeyexists(form, 'zdebug')){
				arrayAppend(rs.arrDebugLog, "Too many login failures");
			}
			if(ss.noLoginForm){
				rs.error=2;
				rs.success=false;
				return rs;
			}else{
				this.logOut(true); // log out and skip logging
				overrideContent = "<strong>Your account has been temporarily disabled</strong> due to repeated login failures.<br />Your IP address and other information have been logged and the administrator has been notified.";//this.loginForm(arguments.inputStruct);
				if(structkeyexists(ss, 'template')){
					if(ss.template EQ false){
						application.zcore.template.setTemplate("zcorerootmapping.templates.nothing",true,true);
					}else{
						application.zcore.template.setTemplate(ss.template,true,true);
					}
				}
				// abort with login form
				application.zcore.template.abort(overrideContent);
			}
		}
		request.zos.requestLogEntry('user.cfc checkLogin before password hashing');
		db.sql="SELECT *
		FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE user.user_username = #db.param(form.zUsername)# and 
		user_deleted = #db.param(0)# and 
		user_active = #db.param(1)# and 
		(user.site_id = #db.param(ss.site_id)# or 
		(user.user_server_administrator = #db.param('1')# and 
		user.site_id = #db.param(Request.zos.globals.serverId)# and 
		(	user_server_admin_site_id_list = #db.param('')# or 
			concat(#db.param(',')#, user_server_admin_site_id_list, #db.param(',')#) LIKE #db.param('%'&ss.site_id&'%')# 
		))";
		if(request.zos.globals.parentid NEQ 0){
			db.sql&=" or (user.site_id = #db.param(request.zos.globals.parentid)# and 
			(user.user_access_site_children = #db.param(1)# or 
			user.user_sync_site_id_list LIKE #db.param('%,#ss.site_id#,%')#))";
		}
		db.sql&=")";
		qUserCheck=db.execute("qUserCheck");
		failedLogin=false;
		if(qUserCheck.recordcount EQ 1){

			if(structkeyexists(form, 'zdebug')){
				arrayAppend(rs.arrDebugLog, "Found user_id: #qUserCheck.user_id#");
			}
			if(qUserCheck.user_password EQ ""){// and qUserCheck.user_password_new EQ ""){
				if(structkeyexists(form, 'zdebug')){
					arrayAppend(rs.arrDebugLog, "Password missing in database");
				}
				rs.error=3;
				rs.success=false;
				return rs;
			}
			if(qUserCheck.user_openid_required EQ 1 and qUserCheck.user_openid_id NEQ ""){
				if(arguments.inputStruct.openIdEnabled EQ false and arguments.inputStruct.tokenLoginEnabled EQ false){
					if(structkeyexists(form, 'zdebug')){
						arrayAppend(rs.arrDebugLog, "openid login method is required for this user.");
					}
					failedLogin=true;
					rs.error=4;
					rs.success=false;
					return rs;
				}
			}
		}
		if(not failedLogin){
			if(qUserCheck.recordcount NEQ 0){
				if(qUserCheck.user_server_administrator EQ "1"){  
					if(qUserCheck.company_id NEQ "0"){  
						companyId=application.zcore.functions.zvar("companyId", ss.site_id);
						parentSiteId=application.zcore.functions.zvar("parentId", ss.site_id);
						if(parentSiteId NEQ 0){
							parentCompanyId=application.zcore.functions.zvar("companyId", parentSiteId);
						}else{
							parentCompanyId=-1;
						}
						if(qUserCheck.company_id EQ companyId){
							// ok
						}else if(qUserCheck.company_id EQ parentCompanyId){
							// ok
						}else{
							failedLogin=true;
						}
					}
				}
			}
		}
		if(not failedLogin){
			if(qUserCheck.recordcount NEQ 0){
				if(arguments.inputStruct.secureLogin){
					if(arguments.inputStruct.disableSecurePassword EQ false){
						passwordVerificationResult=application.zcore.user.verifySecurePassword(form.zPassword, qUserCheck.user_salt, qUserCheck.user_password, qUserCheck.user_password_version);
						
						if(structkeyexists(form, 'zdebug')){
							arrayAppend(rs.arrDebugLog, "Password verification result: #passwordVerificationResult#");
						}
						if(passwordVerificationResult EQ "" or not passwordVerificationResult){
							failedLogin=true; // password didn't match
							if(structkeyexists(request, 'hashThreadDeathOccurred')){
								if(structkeyexists(form, 'zdebug')){
									arrayAppend(rs.arrDebugLog, "hashThreadDeathOccurred");
								}
								db.sql="update #db.table("user", request.zos.zcoreDatasource)# 
								SET user_salt = #db.param('')#,
								user_password = #db.param('')#,
								member_password = #db.param('')#,
								user_password_version = #db.param(request.zos.defaultPasswordVersion)#,
								user_updated_datetime=#db.param(request.zos.mysqlnow)#  
								WHERE user_id = #db.param(qUserCheck.user_id)# and 
								user_deleted = #db.param(0)# and 
								site_id = #db.param(qUserCheck.site_id)#";
								db.execute("qDeleteUserPassword");
							}else{
								if(structkeyexists(form, 'zdebug')){
									arrayAppend(rs.arrDebugLog, "Password didn't match");
								}
							}
						}else if(qUserCheck.user_password_version NEQ request.zos.defaultPasswordVersion){
							// auto-upgrade this user to the new default password version
							if(structkeyexists(form, 'zdebug')){
								arrayAppend(rs.arrDebugLog, "Password version was upgraded");
							}
							var userSalt=application.zcore.functions.zGenerateStrongPassword(256,256);
							var userPasswordHash=application.zcore.user.convertPlainTextToSecurePassword(form.zPassword, userSalt, request.zos.defaultPasswordVersion, false);
							db.sql="update #db.table("user", request.zos.zcoreDatasource)# 
							SET user_salt = #db.param(userSalt)#,
							user_password = #db.param(userPasswordHash)#,
							member_password = #db.param(userPasswordHash)#,
							user_password_version = #db.param(request.zos.defaultPasswordVersion)#,
							user_updated_datetime=#db.param(request.zos.mysqlnow)#  
							WHERE user_id = #db.param(qUserCheck.user_id)# and 
							user_deleted = #db.param(0)# and 
							site_id = #db.param(qUserCheck.site_id)#";
							db.execute("qUpdateUserPassword");
						}else{
						}
					}
				}
			}else{
				if(structkeyexists(form, 'zdebug')){
					arrayAppend(rs.arrDebugLog, "user doesn't exist");
				}
				failedLogin=true; // user doesn't exist.
			} 
		} 
		request.zos.requestLogEntry('user.cfc checkLogin after password hashing'); 
		if(not failedLogin){
			if(structkeyexists(form, 'zdebug')){
				arrayAppend(rs.arrDebugLog, "Login successful, updating session and database.");
			}
			application.zcore.session.forceEnable();
			request.zsession.member_id = qUserCheck.member_id;
			local.config=application.zcore.db.getConfig();
			local.config.cacheEnabled=false;
			application.zcore.db.init(local.config);	// disable query caching for logged in users.
			request.zsession.secureLogin=arguments.inputStruct.secureLogin;
			if(structkeyexists(request.zos, 'tracking')){
				application.zcore.tracking.setUserId(qUserCheck.user_id);
			}
			request.zsession[userSiteId]=StructNew();
			request.zsession[userSiteId].id = qUserCheck.user_id;
			request.zsession[userSiteId].email = qUserCheck.user_username;
			request.zsession[userSiteId].login_site_id = request.zos.globals.id;
			this.updateSession(arguments.inputStruct);
			db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
			SET user_updated_ip = #db.param(request.zos.cgi.remote_addr)#, 
			user_updated_datetime = #db.param(request.zos.mysqlnow)# 
			WHERE user.user_id = #db.param(qUserCheck.user_id)# and 
			user_deleted = #db.param(0)# and 
			site_id = #db.param(qUserCheck.site_id)#";
			db.execute("q"); 
			application.zcore.tracking.setUserEmail(qUserCheck.user_username);
			this.setLoginLog(1);
			request.zos.requestLogEntry('user.cfc checkLogin before createToken');
			
			if(structkeyexists(form,'zautologin') and compare(form.zautologin,"1") EQ 0){
				this.createToken(); // set permanent login cookie
			}else if(structkeyexists(cookie,'zautologin') and compare(cookie.zautologin,"1") EQ 0){
				this.createToken(); // set permanent login cookie
			}
			request.zos.requestLogEntry('user.cfc checkLogin after createToken');
			
			if(ss.noLoginForm){
				rs.error=0;
				rs.success=true;
				return rs;
			}else{
				if(ss.noRedirect EQ false){
					tempId = application.zcore.status.getNewId();
					StructDelete(form, 'zlogin');
					StructDelete(form, 'zusername');
					StructDelete(form, 'zpassword');
					StructDelete(form, 'zreset');
					StructDelete(form, 'fieldnames');
					arrTempURL=ArrayNew(1);
					for(i in url){
						if(isSimpleValue(url[i])){
							ArrayAppend(arrTempURL, i&'='&url[i]);
						}
					}
					form.zreset="";
					request.zos.zreset="";
					tempURL = ArrayToList(arrTempURL,'&');
					application.zcore.status.setStatus(tempId, false, form);
					if(ss.loginURL NEQ request.cgi_script_name){
						tempURL = application.zcore.functions.zURLAppend(ss.loginUrl,'zld='&tempId);
					}else{
						if(len(tempURL) EQ 0){
							tempURL = application.zcore.functions.zURLAppend(ss.loginUrl,'zld='&tempId);
						}else{
							tempURL = application.zcore.functions.zURLAppend(ss.loginUrl,tempURL&'&zld='&tempId);
						}
					}
					application.zcore.functions.zRedirect(tempURL);
				}
			}
		}else{
			if(structkeyexists(form, 'zdebug')){
				arrayAppend(rs.arrDebugLog, "Login failed");
			}
			if(structkeyexists(request, 'zsession')){
				StructDelete(request.zsession, "user");
			}
			if(ss.noLoginForm){
				rs.error=1;
				rs.success=false;
				return rs;
			}else{
				// set login form options
				inputStruct = ss;
				inputStruct.loginMessage = "Invalid Login.";
				overrideContent = this.loginForm(inputStruct);
				if(isDefined('ss.template')){
					if(ss.template EQ false){
						application.zcore.template.setTemplate("zcorerootmapping.templates.nothing",true,true);
					}else{
						application.zcore.template.setTemplate(ss.template,true,true);
					}
				}
				this.setLoginLog(0);
				// abort with login form
				application.zcore.template.abort(overrideContent);
			}
		}
	}else{
		if(request.cgi_script_name EQ '/z/user/login/process' or request.cgi_script_name EQ '/z/user/login/index'){
			rs.success=true;
			return rs;
		}
		if(ss.checkServerAdministrator and request.zos.isServer EQ false and this.checkServerAccess() EQ false){
			// no access
		}else{
			if(isDefined('request.zsession.secureLogin') and request.zsession.secureLogin EQ false and arguments.inputStruct.secureLogin and isDefined('request.zsession.user.email')){
				// insecure user has moved to a secure area, require password entry!
				form.zusername=request.zsession.user.email;
			}else{
				arrG=listtoarray(ss.user_group_name);
				for(i=1;i lte arraylen(arrg);i++){
					if(this.checkGroupAccess(arrg[i], ss.site_id)){
						this.updateSession(arguments.inputStruct);
						rs.success=true;
						return rs;
					}
				}
			}
		}
		if(isDefined('request.zsession.user.id')){
			this.setLoginLog(2); // user account data and login is no longer valid
		}
		// set login form options
		overrideContent = this.loginForm(ss);
		if(isDefined('ss.template')){
			if(ss.template EQ false){
				application.zcore.template.setTemplate("zcorerootmapping.templates.nothing",true,true);
			}else{
				application.zcore.template.setTemplate(ss.template,true,true);
			}
		}
		
		// abort with login form
		application.zcore.template.abort(overrideContent);
	}
	</cfscript>
</cffunction>


<cffunction name="createSecurePasswordVersion1" localmode="modern" access="private" output="no" returntype="string">
	<cfargument name="password" type="string" required="yes">
	<cfargument name="salt" type="string" required="no" default="">
	<cfargument name="allowFailure" type="boolean" required="yes">
	<cfscript>
	if(structkeyexists(request.zos,'convertPlainTextToSecurePasswordIndex1') EQ false){
		request.zos.convertPlainTextToSecurePasswordIndex1=1;
	}else{
		request.zos.convertPlainTextToSecurePasswordIndex1++;
	}
	var threadName="#request.zos.installPath#-convertPlainTextToSecurePassword#request.zos.convertPlainTextToSecurePasswordIndex1#";
	thread action="run" name="#threadName#" args="#arguments#" { 
		var hashStruct={
			passwordPlusSalt=insert(attributes.args.password,attributes.args.salt, 128),
			algorithms=[{
				encoding:'utf-8',
				algorithm:'MD5'
			},
			{
				encoding:'utf-8',
				algorithm:'SHA'
			},
			{
				encoding:'utf-8',
				algorithm:'SHA-256'
			}]
		}	
		var storedPasswordValue=""; 
		for(var i=1;i LTE arraylen(hashStruct.algorithms);i++){
			storedPasswordValue&=hash40(hashStruct.passwordPlusSalt, hashStruct.algorithms[i].algorithm, hashStruct.algorithms[i].encoding, 50000);
		}
		thread.storedPasswordValue=storedPasswordValue;
	}
	thread action="join" name="#threadName#" timeout="2000"  { }
	myThread=cfthread[threadName];
	var storedPasswordValue=""; 
	if(myThread.status EQ "COMPLETED"){
		storedPasswordValue=myThread.storedPasswordValue;
	}else{
		thread name="#threadName#" action="terminate" { }
		savecontent variable="dumpResult"{
			writedump(myThread);
		}
		if(arguments.allowFailure EQ false){
			throw("Failed to convert a password to a secure hash in under two seconds. Thread terminated with this dump result.<br /><br />#dumpResult#");
			
		}
		mail to="#request.zos.developerEmailFrom#" from="#request.zos.developerEmailTo#" subject="Secure password conversion timeout occurred" type="html"{
			writeoutput('#application.zcore.functions.zHTMLDoctype()#
			<head>
			<meta charset="utf-8" />
			<title>Error</title>
			</head>
			
			<body>
			Failed to convert a password to a secure hash in under two seconds. Thread terminated with this dump result: <br /><br />
			#dumpResult#
			</body>
			</html>');
		}
		request.hashThreadDeathOccurred=true;
	}
	return storedPasswordValue;
	</cfscript>
</cffunction>


<cffunction name="createSecurePasswordVersion2" localmode="modern" access="private" output="no" returntype="string">
	<cfargument name="password" type="string" required="yes">
	<cfscript>
	return application.zcore.functions.zSecureCommand("getScryptEncrypt#chr(9)##replace(arguments.password, chr(9), "", "all")#", 20); 
	</cfscript>
</cffunction>

<cffunction name="verifySecurePassword" localmode="modern" output="no" returntype="string">
	<cfargument name="password" type="string" required="yes">
	<cfargument name="salt" type="string" required="yes">
	<cfargument name="hashedPassword" type="string" required="yes">
	<cfargument name="version" type="numeric" required="yes">
	<cfscript>
	if(arguments.version EQ 0){
		if(compare(arguments.password, arguments.hashedPassword) EQ 0){
			return true;
		}else{
			return false;
		}
	}else if(arguments.version EQ 1){
		if(len(arguments.password) EQ 0 or len(arguments.salt) EQ 0){
			return false;
		}
		result=variables.createSecurePasswordVersion1(arguments.password, arguments.salt, arguments.version, false); 
		if(compare(result, arguments.hashedPassword) EQ 0){
			return true;
		}else{
			return false;
		}
	}else if(arguments.version EQ 2){
		result=application.zcore.functions.zSecureCommand("getScryptCheck"&chr(9)&replace(arguments.password, chr(9), "", "all")&chr(9)&arguments.hashedPassword, 20);
		if(result EQ ""){
			return false;
		}else{
			return result;
		}
	}else{
		throw("convertPlainTextToSecurePassword() error: Invalid arguments.version. Supported values are: 0,1 or 2. 2 is recommended if Java is enabled.");	
	}
	</cfscript>
</cffunction>

<cffunction name="convertPlainTextToSecurePassword" localmode="modern" output="no" returntype="string">
	<cfargument name="password" type="string" required="yes">
	<cfargument name="salt" type="string" required="no" default="">
	<cfargument name="version" type="numeric" required="no" default="2">
	<cfargument name="allowFailure" type="boolean" required="no" default="#false#">
	<cfscript> 
	if(arguments.version EQ 1){
		storedPasswordValue=variables.createSecurePasswordVersion1(arguments.password, arguments.salt, arguments.allowFailure);
	}else if(arguments.version EQ 2){
		storedPasswordValue=variables.createSecurePasswordVersion2(arguments.password);
	}else if(arguments.version EQ 0){
		storedPasswordValue=arguments.password;
	}else{
		throw("convertPlainTextToSecurePassword() error: Invalid arguments.version. Supported values are: 0,1 or 2. 2 is recommended if Java is enabled.");	
	}
	return storedPasswordValue;
        </cfscript>
</cffunction>

<cffunction name="logOut" localmode="modern" returntype="any" output="false">
	<cfargument name="skipLog" type="boolean" required="no" default="#false#">
	<cfargument name="retainToken" type="boolean" required="no" default="#false#">
	<cfscript>
	var ts=0;
	request.zos.userSession=structnew();
	request.zos.userSession.groupAccess=structnew();
	
	if(isdefined('request.zsession.user.id') and isdefined('request.zsession.user.site_id')){
		for(i in application.siteStruct){
			if(structkeyexists(application.siteStruct[i], 'administratorTemplateMenuCache')){
				structdelete(application.siteStruct[i].administratorTemplateMenuCache, request.zsession.user.site_id&"_"&request.zsession.user.id);
			}
		}
	}
	if(arguments.skipLog EQ false){
		this.setLoginLog(3);
	}
	StructDelete(request.zsession, "user");
	StructDelete(request.zsession,'secureLogin');
	structdelete(request.zsession,"ztoken");
	structdelete(request.zsession,"inquiries_email");
	structdelete(request.zsession,"inquiries_first_name");
	structdelete(request.zsession,"inquiries_last_name");
	structdelete(request.zsession,"inquiries_phone1");
	structdelete(request.zsession,"zUserInquiryInfoLoaded");
	
	
	structdelete(cookie, "zLoggedIn");
	structdelete(cookie, "zIsAdmin");
	structdelete(cookie, "zSessionExpireDate");
	structdelete(cookie, "zparentlogincheck");
	structdelete(cookie, "zautologin");
	structdelete(cookie, "zNoCache");
	</cfscript>
	<cfcookie name="z_user_id" value="" expires="now">
	<cfcookie name="z_user_siteIdType" value="" expires="now">
	<cfcookie name="z_user_key" value="" expires="now">
	<cfcookie name="z_tmpusername2" value="" expires="now">
	<cfcookie name="z_tmppassword2" value="" expires="now">
	<cfif not arguments.retainToken>
		<cfcookie name="ztoken" value="" expires="now" httponly="true">	
	</cfif>
	<cfcookie name="inquiries_email" value="" expires="now">
	<cfcookie name="inquiries_first_name" value="" expires="now">
	<cfcookie name="inquiries_last_name" value="" expires="now">
	<cfcookie name="inquiries_phone1" value="" expires="now">

	<cfscript>
	application.zcore.session.clear();
	</cfscript>
</cffunction>

<cffunction name="updateSession" localmode="modern" access="public" returntype="any" output="no" hint="This function should happen every page view once the user is logged in.">
	<cfargument name="inputStruct" required="yes" type="struct">
	<cfscript>
	var qUser = "";
	var i=0;
	var ts=StructNew();
	var local=structnew();
	var userSiteId='user';
	var qCustom=0;
	var db=request.zos.queryObject;
	var qCustom2=0;
	var ss = arguments.inputStruct;
	ts.site_id = request.zos.globals.id;
	StructAppend(ss,ts,false);
	request.zos.requestLogEntry('updateSession start');
	
	
	if(ss.site_id NEQ request.zos.globals.id){
		userSiteId='user'&ss.site_id;			
	}
	if(isDefined('request.zsession.#userSiteId#.id') EQ false){
		this.logOut(true);
		return;
	}
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_id = #db.param(request.zsession[userSiteId].id)# and  
	user_active = #db.param(1)# and 
	user_deleted = #db.param(0)# and 
	user_username = #db.param(request.zsession[userSiteId].email)# and 
	(site_id = #db.param(ss.site_id)# or 
	(user_server_administrator = #db.param('1')# and 
	site_id = #db.param(Request.zos.globals.serverId)#) ";
	if(request.zos.globals.parentid NEQ 0){
		db.sql&=" or site_id = #db.param(request.zos.globals.parentid)#";
	}
	db.sql&=" )";
	qUser=db.execute("qUser");
	if(qUser.recordcount EQ 0 or qUser.user_group_id EQ 0){
		this.logOut(true);
		if(isDefined('request.zsession')){
			StructDelete(request.zsession, "user");
		}
		this.setLoginLog(2); // user account data and login is no longer valid
		// set login form options
		//inputStruct = ss;
		//inputStruct.loginMessage = "Your account has been disabled.";
		overrideContent = "Your account has been disabled.";//this.loginForm(inputStruct);
		if(isDefined('ss.template')){
			application.zcore.template.setTemplate(ss.template,true,true);
		}
		// abort with login form
		application.zcore.template.abort(overrideContent);
	}
	request.zsession[userSiteId].first_name = qUser.user_first_name;
	request.zsession[userSiteId].last_name = qUser.user_last_name;
	request.zsession[userSiteId].email = qUser.user_email;
	request.zsession[userSiteId].server_administrator = qUser.user_server_administrator;
	request.zsession[userSiteId].site_administrator = qUser.user_site_administrator;
	request.zsession[userSiteId].enableWidgetBuilder=qUser.user_enable_widget_builder;
	request.zsession[userSiteId].intranet_administrator = qUser.user_intranet_administrator;
	request.zsession[userSiteId].access_site_children = qUser.user_access_site_children;
	request.zsession[userSiteId].company_id = qUser.company_id;
	arrLimitManagerFeatures=listToArray(qUser.user_limit_manager_features, ",");
	featureStruct={};
	for(i=1;i LTE arraylen(arrLimitManagerFeatures);i++){
		featureStruct[arrLimitManagerFeatures[i]]=true;
	}
	request.zsession[userSiteId].limitManagerFeatureStruct = featureStruct;
	request.zsession[userSiteId].server_admin_site_id_list = qUser.user_server_admin_site_id_list;
	request.zsession[userSiteId].id = qUser.user_id;
	request.zsession[userSiteId].site_id = qUser.site_id;
	request.zsession[userSiteId].groupAccess = StructNew();
	request.zsession[userSiteId].login_site_id = request.zos.globals.id;
	
	// have to use query for other site group access
	if(qUser.site_id NEQ request.zos.globals.id){
		hasAllGroups=false
		if(request.zsession[userSiteId].server_administrator EQ 1 or request.zsession[userSiteId].site_administrator EQ 1 or (request.zsession[userSiteId].site_id NEQ ss.site_id and request.zsession[userSiteId].access_site_children EQ 1)){
			hasAllGroups=true;
		}
		//if(not hasAllGroups){
			db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
			WHERE user_group_id = #db.param(qUser.user_group_id)# and 
			user_group_deleted = #db.param(0)# and 
			site_id = #db.param(qUser.site_id)# ";
			qGroupCheck=db.execute("qGroupCheck");
			db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
			WHERE user_group_name = #db.param(qGroupCheck.user_group_name)# and 
			user_group_deleted = #db.param(0)# and 
			site_id = #db.param(request.zos.globals.id)# ";
			qGroupCheck2=db.execute("qGroupCheck");

			db.sql="SELECT user_group.* FROM 
			#db.table("user_group", request.zos.zcoreDatasource)# user_group, 
			#db.table("user_group_x_group", request.zos.zcoreDatasource)# user_group_x_group
			WHERE user_group.user_group_id = user_group_x_group.user_group_child_id and 
			user_group.site_id = user_group_x_group.site_id and 
			user_group_deleted = #db.param(0)# and 
			user_group_x_group_deleted = #db.param(0)# and 
			user_group.site_id = #db.param(request.zos.globals.id)# and 
			user_group_x_group.user_group_id = #db.param(qGroupCheck2.user_group_id)# 
			ORDER BY user_group_primary DESC";
		/*}else{
			db.sql="SELECT * FROM 
			#db.table("user_group", request.zos.zcoreDatasource)# user_group, 
			#db.table("user_group_x_group", request.zos.zcoreDatasource)# user_group_x_group 
			WHERE user_group.user_group_id = user_group_x_group.user_group_child_id and 
			user_group.site_id = user_group_x_group.site_id and 
			user_group_deleted = #db.param(0)# and 
			user_group_x_group_deleted = #db.param(0)# and 
			user_group.site_id = #db.param(request.zos.globals.id)# and 
			user_group_x_group.user_group_id = #db.param(qUser.user_group_id)#  ";
			db.sql&=" ORDER BY user_group_primary DESC";
		}*/
		qUserGroup=db.execute("qUserGroup"); 
		if(hasAllGroups){
			// give access to all groups for server administrator or site administrator
			if(qUserGroup.recordcount EQ 0 or qUserGroup.user_group_primary EQ 0){
				application.zcore.template.fail("#this.comName#: updateSession: This site is missing a primary user group<br /><br /><a href=""#request.zOS.globals.serverDomain#/z/server-manager/admin/user/editSitePermissions?sid=#ss.site_id#"" target=""_blank"">Edit Site Permissions</a>",true);
			}
			request.zsession[userSiteId].group_id = qUserGroup.user_group_id;
			for(i=1;i LTE qusergroup.recordcount;i=i+1){
				request.zsession[userSiteId].groupAccess[qusergroup.user_group_name[i]] = qusergroup.user_group_id[i];
			}
		}else{
			request.zsession[userSiteId].group_id = qUserGroup.user_group_id;
			for(i=1;i LTE qusergroup.recordcount;i=i+1){
				request.zsession[userSiteId].groupAccess[qusergroup.user_group_name[i]] = qusergroup.user_group_id[i];
			}
		}
		
	}else{
		
		if(isDefined('request.zsession.user.server_administrator') and (request.zsession[userSiteId].server_administrator EQ 1 or request.zsession[userSiteId].site_administrator EQ 1 or (request.zsession[userSiteId].site_id NEQ ss.site_id and request.zsession[userSiteId].access_site_children EQ 1))){
		// give access to all groups for server administrator or site administrator
			if(isDefined('Request.zOS.globals.user_group.primary') EQ false){
				application.zcore.template.fail("#this.comName#: updateSession: This site is missing a primary user group<br /><br /><a href=""#request.zOS.globals.serverDomain#/z/server-manager/admin/user/editSitePermissions?sid=#ss.site_id#"" target=""_blank"">Edit Site Permissions</a>",true);
			}
			request.zsession[userSiteId].group_id = Request.zOS.globals.user_group.primary;
			for(i in Request.zOS.globals.user_group.ids){
				request.zsession[userSiteId].groupAccess[Request.zOS.globals.user_group.ids[i]] = i;
			}
		}else{
			if(qUser.site_id NEQ ss.site_id){
				try{
					t9453=application.siteStruct[quser.site_id].globals.user_group.ids[qUser.user_group_id];
					// find administrator or whatever in current site group ids...
					request.zsession[userSiteId].group_id = Request.zOS.globals.user_group.names[t9453];
				}catch(Any excpt){
					application.zcore.template.fail("User Group ID is missing from database, #qUser.user_group_id# for site_id = #quser.site_id#.  This id came from the user table 
					WHERE user_id = #db.param(qUser.user_id)#",true);
				}
			
			}else{
				request.zsession[userSiteId].group_id = qUser.user_group_id;
			}
			try{
				StructAppend(request.zsession[userSiteId].groupAccess, Request.zOS.globals.user_group.access[request.zsession[userSiteId].group_id], true);
			}catch(Any excpt){
				application.zcore.template.fail("User Group ID is missing from database, #request.zsession[userSiteId].group_id#.  This id came from the user table 
				WHERE user_id = #db.param(qUser.user_id)#",true);
			}
		}
	}
	if(request.zsession[userSiteId].server_administrator EQ 1){
		request.zsession[userSiteId].groupAccess["serveradministrator"] =1;
	}
	if(request.zsession[userSiteId].site_administrator EQ 1){
		request.zsession[userSiteId].groupAccess["siteadministrator"] =1;
	}
	
	if(ss.site_id EQ request.zos.globals.id){
		if(isDefined('request.zsession.user')){
			request.zos.userSession=duplicate(request.zsession.user);
		}else{
			request.zos.userSession=structnew();
			request.zos.userSession.groupAccess=structnew();	
		}
	}
	local.isDeveloper=0;
	if(request.zos.userSession.site_id EQ request.zos.globals.serverID and application.zcore.user.checkServerAccess()){
		local.isDeveloper="1";
		local.ts9=structnew();
		local.ts9.name="zdeveloper";
		local.ts9.value=local.isDeveloper;
		local.ts9.expires="never";
		application.zcore.functions.zcookie(local.ts9);
	}else{
		structdelete(cookie, 'zdeveloper');
	}
	
	</cfscript>
</cffunction>

<!--- application.zcore.user.checkGroupAccess(user_group_name); 	--->
<cffunction name="checkGroupAccess" localmode="modern" returntype="any" hint="Used to check if the current user has access to a specific group" output="false">
	<cfargument name="user_group_name" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#0#">
	<cfscript>
	var userSiteId='user';
	var c=0;
	if(not structkeyexists(request.zos, 'globals') or not structkeyexists(request.zos.globals, 'id')){
		return false;
	}else if(arguments.site_id EQ 0){
		arguments.site_id=request.zos.globals.id;
	}
	if(arguments.site_id NEQ request.zos.globals.id){
		userSiteId='user'&arguments.site_id;			
	}
	
	if(not structkeyexists(request.zsession, userSiteId)){
		return false;
	}else{
		c=request.zsession[userSiteId];
		if(not structkeyexists(c, 'login_site_id') or c.login_site_id NEQ arguments.site_id){
			return false;
		}
		if((structkeyexists(c,'groupAccess') and structkeyexists(c.groupAccess, arguments.user_group_name)) or ((structkeyexists(c,'user_administrator') and c.user_administrator EQ 1) and c.site_id EQ arguments.site_id) or (structkeyexists(c,'user_server_administrator') and c.user_server_administrator EQ 1)){
			return true;
		}else{
			return false;
		}
	}
	</cfscript>
</cffunction>

<!--- userCom.checkGroupIdAccess(user_group_id); --->
<cffunction name="checkGroupIdAccess" localmode="modern" returntype="any" hint="Used to check if the current user has access to a specific group id" output="false">
	<cfargument name="user_group_id" type="numeric" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	var v=0;
	var i=0;
	var userSiteId='user';
	if(arguments.site_id NEQ request.zos.globals.id){
		userSiteId='user'&arguments.site_id;			
	}
	
	if(isDefined('request.zsession.#userSiteId#.groupAccess')){
		v=request.zsession[userSiteId].groupAccess;
		for(i in v){
			if(v[i] EQ arguments.user_group_id){
				return true;
			}
		}
	}
	return false;
	</cfscript>
</cffunction>

<!--- application.zcore.user.checkSiteAccess();  --->
<cffunction name="checkSiteAccess" localmode="modern" returntype="any" hint="Used to check if the current user has access to the current site" output="false">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	var userSiteId='user';
	if(arguments.site_id NEQ request.zos.globals.id){
		userSiteId='user'&arguments.site_id;			
	}
	if(structkeyexists(request.zos,'checkSiteAccessCached'&userSiteId)){
		return request.zos['checkSiteAccessCached'&userSiteId];
	}
	if(isDefined('request.zsession') and structkeyexists(request.zsession,userSiteId) and ( request.zsession[userSiteId].server_administrator EQ 1 or request.zsession[userSiteId].site_administrator EQ 1  )){
		request.zos['checkSiteAccessCached'&userSiteId]=true;
		return true;
	}else{
		request.zos['checkSiteAccessCached'&userSiteId]=false;
		return false;
	}
	</cfscript>
</cffunction>

<!--- application.zcore.user.checkServerAccess(); --->
<cffunction name="checkServerAccess" localmode="modern" returntype="any" hint="Used to check if the current user has access to the entire server" output="false">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	var userSiteId='user';
	if(arguments.site_id NEQ request.zos.globals.id){
		userSiteId='user'&arguments.site_id;			
	}
	if(isDefined('request.zsession') and structkeyexists(request.zsession,userSiteId) and structkeyexists(request.zsession[userSiteId],'server_administrator') and request.zsession[userSiteId].server_administrator EQ 1){
		if(not structkeyexists(request.zsession[userSiteId], 'server_admin_site_id_list') or request.zsession[userSiteId].server_admin_site_id_list NEQ ""){
			if(","&request.zsession[userSiteId].server_admin_site_id_list&"," CONTAINS ",#arguments.site_id#,"){
				return true;
			}else{
				return false;
			}
		}else{
			return true;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<!--- loginForm/*
<cfscript>
// set login form options
inputStruct = StructNew();
inputStruct.user_group_name = arguments.user_group_name;
// optional
inputStruct.loginMessage = "Please login Below";
inputStruct.usernameLabel = "Username";
inputStruct.passwordLabel = "Password";
// override styles, set to false to use no style
inputStruct.styles.inputs = false;
inputStruct.styles.table = "plaintable";
inputStruct.styles.loginMessage = "highlight";
inputStruct.styles.labels = false;
// return form as string
formString = userCom.loginForm(inputStruct);
</cfscript>
*/loginForm
--->
<cffunction name="loginForm" localmode="modern" returntype="any" hint="This is used by checkLogin ONLY." output="false">
	<cfargument name="inputStruct" type="struct" required="yes">
	<cfscript>
	var ss = StructNew();
	var i = 0;
	var local=structnew();
	var ts=structnew();
	application.zcore.functions.zIncludeZOSFORMS();
	var returnStruct = application.zcore.functions.zGetRepostStruct();
	var returnString = "";
	var tempStruct = StructNew();
	tempStruct.loginMessage = "Please Login Below";
	tempStruct.usernameLabel = "Username";
	tempStruct.passwordLabel = "Password";
	tempStruct.styles.inputs = false;
	tempStruct.styles.table = "plaintable";
	tempStruct.styles.loginMessage = "highlight";
	tempStruct.styles.labels = false;
	StructAppend(arguments.inputStruct, tempStruct, false);
	ss = arguments.inputStruct;
	this.displayTokenScripts();
	
	request.zos.inMemberArea=true;
	
	request.zos.tempObj.disableMinCat=true;
	application.zcore.functions.zRequireJquery();
	</cfscript>
	<cfif structkeyexists(ss,'user_group_name') EQ false>
		<cfthrow type="exception" message="Error: COMPONENT: user.cfc: loginForm: inputStruct.user_group_name is required.">
	</cfif>
	<cfsavecontent variable="returnString">
	<cfif request.zos.globals.loginIframeEnabled NEQ 1>
			<cfscript>
			ws=application.zcore.app.getWhitelabelStruct();
			</cfscript>
			<style type="text/css">
			<cfscript>
			if(ws.whitelabel_login_header_image_960 NEQ ""){
				echo('.zblanktemplatedivcontainer{ padding:0px !important;}');
			}
			</cfscript>
			.zloginContainerPad{width:97%; padding:1.5%; float:left;}
			.zloginContainer{width:100%; }
			.zloginHeader{width:98%; padding:1%; float:left;}
			.zloginMainContainer{width:100%; float:left;}
			<cfif ws.whitelabel_login_sidebar_html NEQ "">
				.zloginMain{max-width:67%; padding:1%; width:100%; float:left;}
				.zloginSidebar{ margin-left:2%; padding:1%; width:26%; float:left; }
			<cfelse>
				.zloginMain{ width:98%; padding:1%; float:left;}
			</cfif>
			.zlogin-header-image320 img{float:left;}
			.zlogin-header-image640 img{float:left;}
			.zlogin-header-image960 img{float:left;}
			.zlogin-header-image320{float:left; width:100%;background-color:###ws.whitelabel_login_header_background_color#;  display:none;}
			.zlogin-header-image640{float:left; width:100%;background-color:###ws.whitelabel_login_header_background_color#; display:none;}
			.zlogin-header-image960{float:left; width:100%;background-color:###ws.whitelabel_login_header_background_color#; display:block;}
			
			.zloginFooter{width:98%; padding:1%;  float:left;}
			

			@media only screen and (max-width: 992px) { 
				.zloginContainer{width:100%;} 
			}

			@media only screen and (max-width: 660px) { 
				.zlogin-header-image960{display:none;}
				.zlogin-header-image640{display:block;}
				.zloginContainer{width:100%;}
				.zloginMain{max-width:100%;width:98%;}
				.zloginSidebar{margin-left:0px; width:98%; float:left;}

			}
			@media only screen and (max-width: 340px) { 
				.zlogin-header-image960{display:none;}
				.zlogin-header-image640{display:none;}
				.zlogin-header-image320{display:block;}
			}
			<cfscript>
			echo(ws.whitelabel_css);
			</cfscript>
			</style>
			<cfif ws.whitelabel_login_header_image_320 NEQ "">
	
				<div class="zlogin-header-image320" style="background-color:###ws.whitelabel_login_header_background_color#;"><img src="#ws.imagePath##ws.whitelabel_login_header_image_320#" style="width:100%; " alt="Site Manager"></div>
				<div class="zlogin-header-image640" style="background-color:###ws.whitelabel_login_header_background_color#;"><img src="#ws.imagePath##ws.whitelabel_login_header_image_640#" style="width:100%; " alt="Site Manager"></div>
				<div class="zlogin-header-image960" style="background-color:###ws.whitelabel_login_header_background_color#;"><img src="#ws.imagePath##ws.whitelabel_login_header_image_960#" style="max-width:100%; " alt="Site Manager"></div>
			</cfif>


			<div class="zloginContainerPad">
				<div class="zloginContainer">
					<cfif ws.whitelabel_login_header_html NEQ "">
						<div class="zloginHeader">
							#ws.whitelabel_login_header_html#
						</div>
					</cfif>
					
					<div class="zloginMainContainer">
						<div class="zloginMain">
		<div style="width:100%; margin:0 auto;">
	</cfif>
	<cfscript>
	if(application.zcore.app.siteHasApp("content") and left(request.cgi_script_name,8) NEQ '/member/'){
		ts=structnew();
		ts.content_unique_name='/z/user/login/index';
		ts.disableLinks=true;
		application.zcore.app.getAppCFC("content").includePageContentByName(ts);
	}
	
	application.zcore.functions.zModalCancel();
	</cfscript>
	<cfif isDefined('ss.loginMessage') and ss.loginMessage NEQ false>
		<p>
		<cfif isDefined('ss.loginMessage')>
			<cfif ss.styles.loginMessage NEQ false>
				<span id="statusDiv" class="#ss.styles.loginMessage#" style="font-size:120%;">
			</cfif>
			#ss.loginMessage#
			<cfif ss.styles.loginMessage NEQ false>
				</span>
			</cfif>
			</p>
		</cfif>
	<cfelse>
		<div style="display:none; clear:both; color:##000; font-size:120%;" id="statusDiv"></div>
	</cfif>


	<div style="float:left;width:100%;">
		<div style="float:left;margin-bottom:20px;  margin-right:20px;  width:180px;">
			<cfscript>
			local.actionVar="";
			if(structkeyexists(form,  request.zos.urlRoutingParameter)){
				local.actionVar&=form[request.zos.urlRoutingParameter];
			}else{
				local.actionVar&=request.cgi_script_name;
			}
			if(returnStruct.urlString NEQ "" or returnStruct.cgiFormString NEQ ""){
				local.actionVar&="?";
			}
			if(returnStruct.urlString NEQ ""){
				local.actionVar&=returnStruct.urlString&"&";
			}
			if(returnStruct.urlString NEQ ""){
				local.actionVar&=returnStruct.urlString;
			}
			</cfscript>
			<cfif structkeyexists(form, 'returnURL')>
				<form name="zRepostForm" id="zRepostForm" method="get" action="#htmleditformat(form.returnURL)#">
				<cfelse>
				<form name="zRepostForm" id="zRepostForm" method="post" action="#htmleditformat(local.actionVar)#">
#returnStruct.formString#
			</cfif>
			</form>
			<cfscript>
			local.loginCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.user.controller.login");
			</cfscript>
			<cfif request.zos.globals.loginIframeEnabled EQ 1>
				<iframe src="/z/user/login/index?zIsMemberArea=<cfif request.zos.inMemberArea>1<cfelse>0</cfif>" height="375" width="100%" style="margin:0px; border:none; overflow:auto;" seamless="seamless"></iframe>
			<cfelse>
				<cfscript>   
				local.loginCom.index();
				</cfscript>
			</cfif>
		</div>
		<cfscript>
			writeoutput(local.loginCom.displayOpenIdLoginForm(request.zos.currentHostName&local.actionVar&returnStruct.cgiFormString));
			</cfscript>
	</div> 
	<cfif request.zos.globals.parentID EQ 0 or application.zcore.functions.zvar("disableGlobalLoginMessage", request.zos.globals.parentID) NEQ 1>
		<div id="loginFooterMessage" style="width:100%; float:left; font-size:120%; padding-top:10px; padding-bottom:10px;<cfif request.zos.globals.id EQ request.zos.globals.serverId>display:none !important;</cfif> border-top:1px solid ##999; margin-top:20px;">
			<cfif request.zos.globals.parentID NEQ 0 or request.zos.isdeveloper>
				<h2>Global login available</h2>
				<p>Login to the parent web site and select "Yes" for the automatic login prompt.</p>
				<p>Then your login will be automatic across all your web sites.</p>
			</cfif>
			<div class="zmember-openid-buttons" style="width:100%;">
				<cfif request.zos.globals.parentID NEQ 0>
					<a href="#application.zcore.functions.zvar("domain", request.zos.globals.parentId)#/member/" style="height:16px;" target="_blank">Log in to #application.zcore.functions.zvar("shortdomain", request.zos.globals.parentId)#</a>
				</cfif>
				<cfif request.zos.isdeveloper>
					<a href="#application.zcore.functions.zvar("domain", request.zos.globals.serverId)#/" style="height:16px;" target="_blank">Log in to Server Manager</a>
				</cfif>
			</div>
		</div>
		<cfif structkeyexists(form, 'zlogout') and request.zos.globals.id NEQ request.zos.globals.serverId>
			<cfif request.zos.isdeveloper or request.zos.globals.parentID NEQ 0>
				<div style="width:100%; float:left; padding-top:10px; padding-bottom:10px;font-size:150%;color:##900 !important; border-top:1px solid ##900; margin-top:20px;"><strong>Warning:</strong> You may still be logged in to your other web sites.</div>
				<div style="width:100%; float:left; font-size:120%; padding-top:5px; padding-bottom:5px;">If you want to log out of all your web sites, click on the following link(s):</div>
				<div class="zmember-openid-buttons" style="width:100%; float:left; font-size:120%; padding-top:5px; padding-bottom:5px;">
					<cfif request.zos.globals.parentID NEQ 0>
						<a href="#application.zcore.functions.zvar('domain',request.zos.globals.parentId)#/member/?zlogout=1" style="height:16px;" target="_blank">Log out of #application.zcore.functions.zvar("shortdomain", request.zos.globals.parentId)#</a>
					</cfif>
					<cfif request.zos.isDeveloper>
						<a href="#request.zos.globals.serverdomain#/?zlogout=1" style="height:16px;" target="_blank">Log out of Server Manager</a>
					</cfif>
				</div>
			</cfif>
		</cfif>
	</cfif>
	<cfif request.zos.globals.loginIframeEnabled NEQ 1>
		</div>
						</div>
						<cfif ws.whitelabel_login_sidebar_html NEQ "">
							<div class="zloginSidebar">
								#ws.whitelabel_login_sidebar_html#
							</div>
						</cfif>
					</div>
					<cfif ws.whitelabel_login_footer_html NEQ "">
						<div class="zloginFooter">
							#ws.whitelabel_login_footer_html#
						</div>
					</cfif>
				</div>
			</div>
	</cfif>
	</cfsavecontent>
	<cfreturn returnString>
</cffunction>

<cffunction name="displayTokenScripts" localmode="modern" access="public">
	<cfscript>
	var local=structnew();
	if(structkeyexists(request.zos, 'displayTokenScriptsRan')){
		return;
	}
	request.zos.displayTokenScriptsRan=true;
	
	if(request.zos.globals.parentId NEQ 0){
		//if(request.zos.cgi.SERVER_PORT NEQ 443 or application.zcore.functions.zvar('securedomain', request.zos.globals.parentId) CONTAINS "https://"){
			application.zcore.skin.includeJS(application.zcore.functions.zvar('domain', request.zos.globals.parentId)&'/z/user/login/parentToken?ztv='&randrange(100000,900000));
		//}
	}
	if(request.zos.isdeveloperIpMatch){
		//if(request.zos.cgi.SERVER_PORT NEQ 443 or application.zcore.functions.zvar('securedomain', request.zos.globals.serverId) CONTAINS "https://"){
			application.zcore.skin.includeJS(request.zos.globals.serverDomain&'/z/user/login/serverToken?ztv='&randrange(100000,900000));
		//}
	}
	</cfscript>
</cffunction>

<cffunction name="createToken" localmode="modern" output="yes" returntype="any">
	<cfscript>
	var ts=0;
	// user logs in first time, with no valid cookie in existence
	// system creates new user_token record
	local.uniqueTokenTemp=hash(application.zcore.functions.zGenerateStrongPassword(156,256), 'sha-256');
	ts=structnew();
	ts.table="user_token";
	ts.datasource=request.zos.zcoredatasource;
	ts.struct=structnew();
	ts.struct.user_token_salt=application.zcore.functions.zGenerateStrongPassword(256,256);
	ts.struct.user_token_key=application.zcore.user.convertPlainTextToSecurePassword(local.uniqueTokenTemp, ts.struct.user_token_salt, request.zos.defaultPasswordVersion, false);
	ts.struct.user_token_user_agent=request.zos.cgi.http_user_agent;
	ts.struct.site_id=request.zos.globals.id;
	ts.struct.user_token_username=form.zUsername; // prevents abuve
	ts.struct.user_token_version=request.zos.defaultPasswordVersion; // hardcoded until we make a new token handling system
	ts.struct.user_token_datetime=request.zos.mysqlnow; // we only allow accept tokens for login if they are less then 30 days old.
	ts.forcePrimaryInsert.user_token_username=true;
	local.user_token_id=application.zcore.functions.zInsert(ts);
	
	request.zsession.ztoken="#ts.struct.user_token_version#|#local.user_token_id#|#ts.struct.user_token_username#|#local.uniqueTokenTemp#";
	//new permanent token cookie is set
	local.ts9=structnew();
	local.ts9.name="ztoken";
	local.ts9.httponly=true;
	local.ts9.value=request.zsession.ztoken;
	local.ts9.expires="never";
	application.zcore.functions.zcookie(local.ts9);
	</cfscript>
</cffunction>

<cffunction name="verifyToken" localmode="modern" output="yes" returntype="any">
	<cfscript>
	var local=structnew();
	var db=request.zos.queryObject;
	var inputStruct=0;
	var local.debug=false;
	var ts=0;
	if(request.zos.isdeveloper){
		if(structkeyexists(form, 'zdebugVerifyToken')){
			local.debug=true;
		}
	}
	
	if(not structkeyexists(cookie, 'ztoken') or len(cookie.ztoken) EQ 0){
		if(local.debug){ 
			writeoutput('cookie.ztoken is not defined.<br />'); 
			abort;
		}
		return false;
	}else{
		if(local.debug){ 
			writeoutput('Verifying cookie.ztoken: #cookie.ztoken#<br />'); 
		}
	}
	if(structkeyexists(request.zsession, 'ztoken') and structkeyexists(request.zsession, 'user')){
		if(compare(request.zsession.ztoken, cookie.ztoken) NEQ 0){
			if(local.debug){ 
				writeoutput('current login doesn''t match the cookie, override it<br />'); 
				abort;
			}
			local.ts9=structnew();
			local.ts9.name="ztoken";
			local.ts9.httponly=true;
			local.ts9.value=request.zsession.ztoken;
			local.ts9.expires="never";
			application.zcore.functions.zcookie(local.ts9);
			return false;
		}else{
			if(local.debug){ 
				writeoutput('user is logged in and ztoken matches - do no further work.<br />Dumping session:'); 
				writedump(request.zsession);
				abort;
			}
			return true;
		}
	}
	if(local.debug){ 
		//writedump(application.zcore.session.isSessionEnabled());
		//writedump(request.zsession);
		writeoutput('user not logged in, check if cookie.ztoken is still valid<br />'); 
	}
	local.arrToken=listtoarray(cookie.ztoken,"|");
	db.sql="select * from #db.table("user_token", request.zos.zcoreDatasource)# user_token 
	WHERE 
	user_token_version=#db.param(local.arrToken[1])# and 
	user_token_deleted = #db.param(0)# and 
	user_token_id=#db.param(local.arrToken[2])# and 
	user_token_username=#db.param(local.arrToken[3])# and 
	user_token_datetime>=#db.param(dateformat(dateadd("d",-30,now()),"yyyy-mm-dd")&" 00:00:00")# and 
	site_id=#db.param(request.zos.globals.id)# 
	";
	local.qUserToken=db.execute("qUserToken"); 
	if(local.qUserToken.recordcount EQ 0){
		if(local.debug){ 
			writedump(request.zos.arrQueryLog);
			writeoutput('no token exists<br />');
			abort; 
		}
		local.ts9=structnew();
		local.ts9.name="ztoken";
		local.ts9.value="";
		local.ts9.httponly=true;
		local.ts9.expires="now";
		application.zcore.functions.zcookie(local.ts9);
		return false;
	}
	form.zusername=local.qUserToken.user_token_username;
	/*
	removed user agent validation until it can be made more specific so constant browser upgrades don't invalidate request.zsession.
	if(local.qUserToken.user_token_user_agent NEQ request.zos.cgi.http_user_agent){
		if(local.debug){ 
			writeoutput('token is valid, but user agent changed.  Removing ztoken for this id and clearing cookie. User will have to login again.<br />'); 
		}
		db.sql="delete from #db.table("user_token", request.zos.zcoreDatasource)#  
		WHERE 
		user_token_version=#db.param(local.arrToken[1])# and 
		user_token_id=#db.param(local.arrToken[2])# and 
		user_token_deleted = #db.param(0)# and 
		user_token_username=#db.param(local.arrToken[3])# and 
		site_id=#db.param(request.zos.globals.id)# 
		";
		db.execute("q"); 
		local.ts9=structnew();
		local.ts9.name="ztoken";
		local.ts9.value="";
		local.ts9.httponly=true;
		local.ts9.expires="now";
		application.zcore.functions.zcookie(local.ts9);
		this.setLoginLog(0);
	}*/
	keyIsValid=application.zcore.user.verifySecurePassword(local.arrToken[4], local.qUserToken.user_token_salt, local.qUserToken.user_token_key, local.arrToken[1]);
	if(keyIsValid){
		if(local.debug){ 
			writeoutput('token is valid, perform an secure user login<br />'); 
		}
		form.zpassword="password";
		inputStruct = StructNew();
		inputStruct.user_group_name = "user";
		inputStruct.noRedirect=true;
		inputStruct.noLoginForm=true;
		inputStruct.tokenLoginEnabled=true;
		inputStruct.disableSecurePassword=true;
		inputStruct.secureLogin=true;
		inputStruct.site_id = request.zos.globals.id;
		application.zcore.user.checkLogin(inputStruct); 
		if(application.zcore.user.checkGroupAccess("user")){ 
			structdelete(form,'zpassword');
			structdelete(form,'zusername');
			if(local.debug){ 
				writeoutput('token secure login was successful.  issuing new token.<br />');
				writedump(request.zsession.user);
			}
			local.uniqueTokenTemp=hash(application.zcore.functions.zGenerateStrongPassword(156,256), 'sha-256');
			local.user_token_salt=application.zcore.functions.zGenerateStrongPassword(256,256);
			local.user_token_key=application.zcore.user.convertPlainTextToSecurePassword(local.uniqueTokenTemp, local.user_token_salt, request.zos.defaultPasswordVersion, false);
			db.sql="update #db.table("user_token", request.zos.zcoreDatasource)# user_token 
			set user_token_key=#db.param(local.user_token_key)#, 
			user_token_salt=#db.param(local.user_token_salt)#, 
			user_token_datetime=#db.param(request.zos.mysqlnow)#,
			user_token_updated_datetime=#db.param(request.zos.mysqlnow)# 
			WHERE 
			user_token_version=#db.param(local.arrToken[1])# and 
			user_token_deleted = #db.param(0)# and
			user_token_id=#db.param(local.arrToken[2])# and 
			user_token_username=#db.param(local.arrToken[3])# and 
			site_id=#db.param(request.zos.globals.id)# 
			";
			db.execute("q"); 
			request.zsession.ztoken="#local.qUserToken.user_token_version#|#local.qUserToken.user_token_id#|#local.qUserToken.user_token_username#|#local.uniqueTokenTemp#";
			if(local.debug){ 
				writeoutput('token updated:'&request.zsession.ztoken&'<br />'); 
			}
			//new permanent token cookie is set
			local.ts9=structnew();
			local.ts9.name="ztoken";
			local.ts9.value=request.zsession.ztoken;
			local.ts9.expires="never";
			local.ts9.httponly=true;
			application.zcore.functions.zcookie(local.ts9);
			if(local.debug){
				abort;	
			}
			return true;
		}else{
			local.ts9=structnew();
			local.ts9.name="ztoken";
			local.ts9.value="";
			local.ts9.httponly=true;
			local.ts9.expires="now";
			application.zcore.functions.zcookie(local.ts9);
			if(local.debug){ 
				writeoutput('invalid login - account may be throttled or inactive.<br />'); 
				abort;
			}
			return false;
		}
	}
	if(local.debug){ 
		writeoutput(local.qUserToken.user_token_key&'<br />'&local.tempTokenKey&'<br />invalid token key - should log and throttle these. for now, just delete and clear cookie<br />'); 
	}
	this.setLoginLog(0);
	db.sql="delete from #db.table("user_token", request.zos.zcoreDatasource)#  
	WHERE 
	user_token_version=#db.param(local.arrToken[1])# and 
	user_token_id=#db.param(local.arrToken[2])# and 
	user_token_deleted = #db.param(0)# and 
	user_token_username=#db.param(local.arrToken[3])# and 
	site_id=#db.param(request.zos.globals.id)# 
	";
	db.execute("q"); 
	local.ts9=structnew();
	local.ts9.name="ztoken";
	local.ts9.value="";
	local.ts9.httponly=true;
	local.ts9.expires="now";
	application.zcore.functions.zcookie(local.ts9);
	if(local.debug){
		abort;
	}
	return false;
    </cfscript>
</cffunction>

<cffunction name="checkAllCompanyAccess" localmode="modern" access="public">
	<cfscript>
	if(structkeyexists(request.zsession, 'user')  and structkeyexists(request.zsession.user, 'company_id')){
		if(request.zsession.user.company_id EQ 0){
			return true;
		}
	}
	return false;
	</cfscript>
</cffunction>

<cffunction name="requireAllCompanyAccess" localmode="modern" access="public">
	<cfscript>
	if(not application.zcore.user.checkAllCompanyAccess()){
		application.zcore.status.setStatus(request.zsid, "Access denied.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	}
	</cfscript>
</cffunction>

<cffunction name="getUserById" localmode="modern" access="public">
	<cfargument name="user_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# WHERE 
	user_id = #db.param(arguments.user_id)# and 
	user_deleted = #db.param(0)# and
	site_id = #db.param(arguments.site_id)#";
	qUser=db.execute("qUser");
	row={};
	if(qUser.recordcount){
		for(row2 in qUser){
			row=row2;
		}
	}
	return row;
	</cfscript>
</cffunction>

<cffunction name="getUserByEmail" localmode="modern" access="public">
	<cfargument name="email" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# WHERE 
	user_username = #db.param(arguments.email)# and 
	user_deleted = #db.param(0)# and
	site_id = #db.param(arguments.site_id)#";
	qUser=db.execute("qUser");
	row={};
	if(qUser.recordcount){
		for(row2 in qUser){
			row=row2;
		}
	}
	return row;
	</cfscript>
</cffunction>

<cffunction name="requireLogin" localmode="modern" access="public">
	<cfargument name="user_group_name" type="string" required="no" default="user">
	<cfscript>
	inputStruct = StructNew();
	inputStruct.user_group_name = arguments.user_group_name;
	inputStruct.secureLogin=true;
	inputStruct.site_id = request.zos.globals.id;
	application.zcore.user.checkLogin(inputStruct); 
	</cfscript>
</cffunction>


<cffunction name="getUsersWithGroupAccess" localmode="modern" access="public">
	<cfargument name="user_group_name" type="string" required="no" default="user">
	<cfscript> 
	db=request.zos.queryObject;
	userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	memberGroupId = userGroupCom.getGroupId(arguments.user_group_name,request.zos.globals.id);
	memberParentGroupId = userGroupCom.getGroupId(arguments.user_group_name,request.zos.globals.parentId);
	parentSiteId=application.zcore.functions.zvar('parentid',request.zos.globals.id,0);
	if(parentSiteId NEQ 0){
		db.sql="SELECT * FROM  #db.table("user_group_x_group", request.zos.zcoreDatasource)#  
		WHERE user_group_child_id = #db.param(memberParentGroupId)# and 
		user_group_x_group_deleted = #db.param(0)# and 
		site_id = #db.param(parentSiteId)# 
		GROUP BY user_group_id ";
		qParentGroup=db.execute("qParentGroup"); 
	}
	db.sql="SELECT * FROM  #db.table("user_group_x_group", request.zos.zcoreDatasource)# 
	WHERE user_group_child_id = #db.param(memberGroupId)# and 
	user_group_x_group_deleted = #db.param(0)# and ";
	if(parentSiteId NEQ 0){
		db.sql&=" site_id in (#db.param(request.zos.globals.id)#, #db.param(request.zos.globals.parentId)#) ";
	}else{
		db.sql&=" site_id in (#db.param(request.zos.globals.id)#) ";
	}
	db.sql&=" GROUP BY user_group_id ";
	qGroup=db.execute("qGroup"); 
	arrGroup=[];
	for(row in qGroup){
		arrayAppend(arrGroup, row.user_group_id);
	}
	db.sql="SELECT * FROM  #db.table("user", request.zos.zcoreDatasource)#  
	WHERE 
	((user_group_id IN (#db.trustedSQL("'"&arrayToList(arrGroup, "','")&"'")#) and 
	site_id = #db.param(request.zos.globals.id)#) ";
	if(parentSiteId NEQ 0){
		arrGroup=[];
		for(row in qParentGroup){
			arrayAppend(arrGroup, row.user_group_id);
		}
		db.sql&=" or (user_group_id IN (#db.trustedSQL("'"&arrayToList(arrGroup, "','")&"'")#) and 
		site_id = #db.param(request.zos.globals.parentId)#) ";
	}
 	db.sql&=") and 
	user_deleted = #db.param(0)# and   
	user_server_administrator=#db.param(0)#";
	qUser=db.execute("qUser"); 
	return qUser;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
