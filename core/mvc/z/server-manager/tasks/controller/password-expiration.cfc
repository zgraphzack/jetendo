<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	pastDate=application.zcore.functions.zAddTimespanToDate(-request.zos.passwordExpirationTimeSpan, now());
	db=request.zos.queryObject;
	db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# 
	SET 
	user_password = #db.param('')#,
	user_created_ip = #db.param('')#, 
	user_updated_ip = #db.param('')#,
	user_key = #db.param('')#,
	user_password = #db.param('')#,
	member_password = #db.param('')#,
	user_last_ip = #db.param('')#,
	user_salt  = #db.param('')#,  
	user_security_question1  = #db.param('')#,  
	user_security_answer1  = #db.param('')#,  
	user_security_question2  = #db.param('')#,  
	user_security_answer2  = #db.param('')#,  
	user_security_question3  = #db.param('')#,  
	user_security_answer3  = #db.param('')# 
	WHERE 
	user_password <> #db.param('')# and 
	user_updated_datetime <= #db.param(dateformat(pastDate, "yyyy-mm-dd")&" "&timeformat(pastDate, "HH:mm:ss"))# and 
	user_encrypted_key = #db.param('')# and 
	site_id <> #db.param(-1)#";
	db.execute("qUpdate");
	writeoutput("Old passwords were expired.");
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>