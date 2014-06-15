<cfcomponent displayname="Track Users">
<cfoutput>     <cffunction name="disable" localmode="modern" output="no" returntype="any">
     	<cfscript>
		request.zos.trackingDisabled=true;
		</cfscript>
     </cffunction>
     
     <cffunction name="updateLogs" localmode="modern" output="no" returntype="any">
     	<cfreturn>
     </cffunction>
     <cffunction name="updateDailyLogs" localmode="modern" output="no" returntype="any">
	</cffunction>
     
     <cffunction name="backOneHit" localmode="modern" output="no" returntype="any">
     	<cfscript>
		if(structkeyexists(request.zos,'trackingDisabled')) return;
		if(structkeyexists(request.zos,'trackingInitOnce') and isDefined('request.zsession.tracking') and structkeyexists(request.zos,'trackingDisableBackOneHit') EQ false){
			request.zos.trackingDisableBackOneHit=true;
			request.zsession.tracking.track_user_hits--;
			if(arraylen(request.zsession.trackingArrPages) NEQ 0 and arrayisdefined(request.zsession.trackingArrPages, arraylen(request.zsession.trackingArrPages))){
				try{
				arraydeleteat(request.zsession.trackingArrPages, arraylen(request.zsession.trackingArrPages));
				}catch(Any excpt){
				}
			}
		}
		</cfscript>
     </cffunction>
     
     
	 
	<!--- trackCom.init(); --->
	<cffunction name="init" localmode="modern" output="true">
		<cfscript>
		var t4=0;
		var tempVar=structnew();
		var ts=0;
		var tempVar2=0;
		var local=structnew();
		var i=0;
		var curminute=timeformat(request.zos.now,"m");
		var db=request.zos.queryObject;
		var tempUserAgent=rereplace(lcase(request.zos.cgi.http_user_agent), "[^[a-z]]","_","ALL");
		request.zos.trackingspider=false;
		
		if(application.zcore.requestCacheIndex GT 3000){
			application.zcore.requestCacheIndex=0;	
		}
		application.zcore.requestCacheIndex++;
		request.zos.trackingrequestCacheIndex=(application.zcore.requestcacheindex);
		tempVar=structnew();
		tempVar.formvars=structnew();//duplicate(form);
		tempVar.scriptName=request.zos.cgi.SCRIPT_NAME;
		tempVar.queryString=request.zos.cgi.QUERY_STRING;
		tempVar.userAgent=request.zos.cgi.HTTP_USER_AGENT;
		tempVar.host=request.zos.cgi.HTTP_HOST;
		tempVar.runtime=0;
		tempVar.datetime=request.zOS.now;
		application.zcore.arrRequestcache[request.zos.trackingRequestCacheIndex]=tempVar;
		
		application.zcore.runningScriptIndex++;
		if(application.zcore.runningScriptIndex GT 1000000){
			application.zcore.runningScriptIndex=1;
		}
		request.zos.trackingrunningScriptIndex=application.zcore.runningScriptIndex;
		if(request.zos.cgi.SERVER_PORT EQ 443){
			tempVar2='https://';
		}else{
			tempVar2='http://';
		}
		tempVar=structnew();
		tempVar.url=tempVar2&request.zos.cgi.HTTP_HOST&request.zos.cgi.SCRIPT_NAME&"?"&request.zos.cgi.QUERY_STRING;
		tempVar.startTime=request.zOS.now;
		application.zcore.runningScriptStruct['r'&request.zos.trackingrunningScriptIndex]=tempVar;
		
		local.skipAbuseTracking=false;
		/*
		if(structkeyexists(request.zos.adminIpStruct, request.zos.cgi.remote_addr) EQ false){
			local.tempMinute=application.zcore.abusiveIPDate;
			if(local.tempMinute and local.tempMinute NEQ curminute){
				application.zcore.abusiveIPDate=curminute;
				structclear(application.zcore.abusiveIPStruct[local.tempMinute]);
			}
			local.trackingAbuseCount=1;
			local.abusiveIPStruct=(application.zcore.abusiveIPStruct[curminute]);
			if(structkeyexists(local.abusiveIPStruct,request.zos.cgi.remote_addr) EQ false){
				local.abusiveIPStruct[request.zos.cgi.remote_addr]=1;
			}else{
				local.abusiveIPStruct[request.zos.cgi.remote_addr]=local.abusiveIPStruct[request.zos.cgi.remote_addr]+1;
				application.zcore.abusiveIPStruct[curminute]=local.abusiveIPStruct;
			}
			if(request.zos.istestserver EQ false and local.trackingAbuseCount GTE 500 and structkeyexists(application.zcore.abusiveBlockedIpStruct, request.zos.cgi.remote_addr) EQ false){
				db.sql="INSERT INTO #request.zos.queryObject.table("ip_block", request.zos.zcoreDatasource)#  
				SET `ip_block_datetime`=#db.param(request.zos.mysqlnow)#, 
				`ip_block_user_agent`=#db.param(request.zos.cgi.http_user_agent)#, 
				ip_block_ip=#db.param(request.zos.cgi.remote_addr)#, 
				ip_block_url=#db.param(request.zos.cgi.http_host&request.zos.cgi.script_name&"?"&request.zos.cgi.QUERY_STRING)#";
				db.execute("q");
				application.zcore.abusiveBlockedIpStruct[request.zos.cgi.remote_addr]=true;
				application.zcore.session.clear();
				mail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="Abusive spidering detected for #request.zos.cgi.remote_addr#"{
writeoutput('Abusive spidering detected:
IP:#request.zos.cgi.remote_addr#
User Agent:#request.zos.cgi.HTTP_USER_AGENT#
track_user_id: #application.zcore.functions.zso(request.zsession.tracking, 'track_user_id')#
Date:#request.zOS.mysqlnow#
Last URL: #request.zos.cgi.http_host##request.zos.cgi.script_name#?#request.zos.cgi.query_string#

USER WAS PERMANENTLY BLOCKED.');
				}
				header statuscode="403" statustext="Forbidden";
				application.zcore.functions.zabort();
			}
		}*/
		if(cgi.HTTP_USER_AGENT EQ "" or replacelist(tempUserAgent, application.zcore.spiderList, application.zcore.spiderListReplace) NEQ tempUserAgent){
			/*if(cgi.HTTP_USER_AGENT CONTAINS "baiduspider"){
				header statuscode="404" statustext="Page not found";
				application.zcore.functions.zabort();
			}*/
			request.zos.trackingspider=true;
			//this.checkForSpamTrap();
			if(request.zos.trackingspider and structkeyexists(application.zcore.spiderTrapScripts, request.cgi_script_name)){
				if(structkeyexists(application.zcore.robotThatHitSpamTrap, request.zos.cgi.remote_addr&"_"&cgi.http_user_agent) EQ false){
					application.zcore.robotThatHitSpamTrap[request.zos.cgi.remote_addr&"_"&cgi.http_user_agent]=1;
				}else{
					application.zcore.robotThatHitSpamTrap[request.zos.cgi.remote_addr&"_"&cgi.http_user_agent]++;
				}
			}
			
			request.zos.trackingDisabled=true;
		}
		if(structkeyexists(request.zos,'trackingDisabled')) return;
		
		if(structkeyexists(form, 'zsource')){
			ts=structnew();
			ts.name="zsource";
			ts.value=form.zsource;
			ts.expires=60*60*24*30;
			application.zcore.functions.zCookie(ts);
		}else if(structkeyexists(cookie, 'zsource')){
			form.zsource=cookie.zsource;	
		}
	 	if(structkeyexists(request.zos.userSession.groupAccess, "member") or request.zos.inMemberArea){
			request.zos.trackingDisabled=true;
			return;	
		}	
		// check session
		if(isDefined('request.zsession') EQ false){
			request.zsession=StructNew();
		}
		
		if(isDefined('request.zsession') EQ false or structkeyexists(request.zsession,'tracking') EQ false){
			t4=structnew();
			t4.inquiries_id=0;
			t4.track_user_id=0;
			t4.track_user_email=application.zcore.functions.zso(request.zsession, 'inquiries_email');
			t4.track_user_parent_id=0;
			if(isdefined('request.zsession.user.id')){
				t4.user_id=request.zsession.user.id;
			}else{
				t4.user_id=0;
			}
			if(t4.track_user_email NEQ ""){
				db.sql="select * from #request.zos.queryObject.table("track_user", request.zos.zcoreDatasource)# track_user 
				where track_user_email = #db.param(t4.track_user_email)# and 
				site_id=#db.param(request.zos.globals.id)#";	
				local.qUser=db.execute("qUser");
				if(local.qUser.recordcount NEQ 0){
					t4.track_user_parent_id=qUser.track_user_id;
					if(qUser.user_id NEQ 0){
						t4.user_id=qUser.user_id;	
					}
				}
			}
			t4.track_user_datetime=request.zos.now;
			t4.track_user_recent_datetime=t4.track_user_datetime;
			t4.track_user_session_length=0;
			t4.track_user_agent=cgi.HTTP_USER_AGENT;
			t4.track_user_spider=0;
			t4.track_user_ip=request.zos.cgi.remote_addr;
			t4.track_user_referer=request.zos.cgi.http_referer;
			t4.track_user_hits=1;
			t4.track_user_conversions=0;
			t4.track_user_ppc=0;
			if(cgi.QUERY_STRING CONTAINS "gclid="){
				t4.track_user_ppc=1;		
			}
			if(structkeyexists(form, 'zsource')){
				t4.track_user_source=form.zsource;
			}
			if(request.zos.cgi.http_referer NEQ "" and findNoCase(request.zos.globals.domain, request.zos.cgi.http_referer) EQ 0 and findnocase(request.zos.currentHostName, request.zos.cgi.http_referer) EQ 0){
				t4.track_user_keywords=getSearchTerms(request.zos.cgi.http_referer);
			}else{
				t4.track_user_keywords="";
			}
			t4.site_id=request.zos.globals.id;
			t4.zemail_campaign_id=0;
			request.zsession.tracking=t4;
			request.zsession.trackingArrPages=arraynew(1);
		}else{
			request.zsession.tracking.track_user_hits++;
			request.zsession.tracking.track_user_recent_datetime=request.zos.mysqlnow;
			request.zsession.tracking.track_user_session_length=DateDiff("s", request.zsession.tracking.track_user_datetime, now());
		}
		local.ps=structnew();
		// get the actual script name, not the URL rewrite engine
		if(CGI.SERVER_PORT EQ '443'){
			local.ps.track_page_script='https://'&request.zos.cgi.HTTP_HOST&request.zos.originalURL;
		}else{
			local.ps.track_page_script='http://'&request.zos.cgi.HTTP_HOST&request.zos.originalURL;
		}
		local.ps.track_page_qs=request.zos.cgi.query_string;
		//local.ps.track_page_form=local.rs.formString;
		local.ps.track_page_datetime=request.zos.mysqlnow;
		
		arrayappend(request.zsession.trackingArrPages, local.ps);
		if(arraylen(request.zsession.trackingArrPages) GT 3){
			arraydeleteat(request.zsession.trackingArrPages,1);	
		}
		</cfscript>
	</cffunction>
	
	
	<!--- trackCom.getUser(track_user_id); --->
	<cffunction name="getUser" localmode="modern" output="false">
		<cfargument name="track_user_id" type="string" required="no" default="#application.zcore.functions.zso(request.zsession, 'track_user_id')#">
		<cfscript>
		var qUser="";
		var local=structnew();
		return false;
		</cfscript>
	</cffunction>
    
	
	<!--- TODO: integrate with login system for sites with tracking on --->
	<!--- trackCom.setUserId(user_id); --->
	<cffunction name="setUserId" localmode="modern" output="false">
		<cfargument name="user_id" type="string" required="yes">
		<cfscript>
		if(structkeyexists(request.zos,'trackingDisabled')) return;
		if(isDefined('request.zsession.tracking') EQ false){
			return false;
		}
		request.zsession.tracking.user_id=arguments.user_id;
		</cfscript>
	</cffunction>
	
	<!--- TODO: every form that submits email should do this. --->
	<!--- trackCom.setUserEmail(track_user_email); --->
	<cffunction name="setUserEmail" localmode="modern" output="false">
		<cfargument name="track_user_email" type="string" required="yes">
		<cfscript>
		var quser=0;
		var local=structnew();
		var qupdate=0;
		var db=request.zos.queryObject;
		if(structkeyexists(request.zos,'trackingDisabled')) return;
		if(isDefined('request.zsession.tracking') EQ false){
			return false;
		}
		request.zsession.tracking.track_user_email=trim(arguments.track_user_email);
		</cfscript>
		<!--- set parent id if it exists --->
		<cfsavecontent variable="db.sql">
		SELECT * FROM #request.zos.queryObject.table("track_user", request.zos.zcoreDatasource)# track_user 
		WHERE track_user_email = #db.param(arguments.track_user_email)# and 
		site_id = #db.param(request.zos.globals.id)#
		</cfsavecontent><cfscript>qUser=db.execute("qUser");
		if(qUser.recordcount NEQ 0){
			request.zsession.tracking.track_user_id=qUser.track_user_id;
			request.zsession.tracking.user_id=qUser.user_id;
		}
		</cfscript>
	</cffunction>
	
<!--- trackCom.setConversion(track_convert_name); --->
<cffunction name="setConversion" localmode="modern" output="false">
	<cfargument name="track_convert_name" type="string" required="yes">
	<cfargument name="inquiries_id" type="string" required="no" default="">
	<cfscript>
	var track_convert_id=0;
	var track_page_id='';
	var i='';
	var local=structnew();
	var qInsert='';
	var qId='';
	var qConvert='';
	var qUser='';
	var qUpdate='';
	var db=request.zos.queryObject;
	var ts=structnew();
	if(structkeyexists(request.zos,'trackingDisabled')) return;
	if(isDefined('request.zsession.tracking') EQ false){
		return false;
	}
	local.tempSource="";
	if(structkeyexists(cookie, 'zsource')){
		local.tempSource=cookie.zsource;	
	}
	request.zsession.tracking.inquiries_id=arguments.inquiries_id;
	local.c=application.zcore.db.getConfig();
	local.c.autoReset=false;
	local.c.datasource=request.zos.zcoreDatasource;
	db=application.zcore.db.newQuery(local.c);
	hasSession=false;
	if(isdefined('request.zsession.tracking.track_user_id') and not isnull(request.zsession.tracking.track_user_id)){
		hasSession=true;
		track_user_id=request.zsession.tracking.track_user_id;
		db.sql="UPDATE #request.zos.queryObject.table("track_user", request.zos.zcoreDatasource)#  SET ";
	}else{
		db.sql="INSERT INTO #request.zos.queryObject.table("track_user", request.zos.zcoreDatasource)#  SET ";
	}
        db.sql&=" inquiries_id=#db.param(request.zsession.tracking.inquiries_id)#, 
        track_user_email=#db.param(request.zsession.tracking.track_user_email)#, 
        track_user_parent_id=#db.param(request.zsession.tracking.track_user_parent_id)#, 
        user_id=#db.param(request.zsession.tracking.user_id)#, 
        track_user_datetime=#db.param(dateformat(request.zsession.tracking.track_user_datetime,'yyyy-mm-dd')&' '&timeformat(request.zsession.tracking.track_user_datetime,'HH:mm:ss'))#, 
        track_user_recent_datetime=#db.param(dateformat(request.zsession.tracking.track_user_recent_datetime,'yyyy-mm-dd')&' '&timeformat(request.zsession.tracking.track_user_recent_datetime,'HH:mm:ss'))#, 
        track_user_session_length=#db.param(request.zsession.tracking.track_user_session_length)#, 
        track_user_agent=#db.param(request.zsession.tracking.track_user_agent)#, 
        track_user_spider=#db.param(request.zsession.tracking.track_user_spider)#, 
        track_user_ip=#db.param(request.zsession.tracking.track_user_ip)#, 
        track_user_referer=#db.param(request.zsession.tracking.track_user_referer)#, 
        track_user_hits=#db.param(request.zsession.tracking.track_user_hits)#, 
        track_user_conversions=#db.param(request.zsession.tracking.track_user_conversions)#, 
        track_user_ppc=#db.param(request.zsession.tracking.track_user_ppc)#, 
        track_user_keywords=#db.param(request.zsession.tracking.track_user_keywords)#, 
	track_user_source=#db.param(local.tempSource)#, 
        zemail_campaign_id=#db.param(request.zsession.tracking.zemail_campaign_id)# ";
	if(hasSession){
		db.sql&=" WHERE track_user_id = #db.param(request.zsession.tracking.track_user_id)# and ";
	}
        db.sql&=" site_id=#db.param(request.zsession.tracking.site_id)# ";
	if(hasSession){
		db.execute("qUpdate");
	}else{
		local.rs=db.insert("qInsert", request.zOS.insertIDColumnForSiteIDTable);
		if(local.rs.success){ 
			track_user_id=local.rs.result;
			request.zsession.tracking.track_user_id=local.rs.result;
		}else{
			throw("track_user insert failed");	
		}
	}
	for(i=1;i LTE arraylen(request.zsession.trackingArrPages);i++){
		db.sql="INSERT INTO #request.zos.queryObject.table("track_page", request.zos.zcoreDatasource)#  SET 
		track_page_script=#db.param(request.zsession.trackingArrPages[i].track_page_script)#,
		track_page_qs=#db.param(request.zsession.trackingArrPages[i].track_page_qs)#,
		track_page_datetime=#db.param(dateformat(request.zsession.trackingArrPages[i].track_page_datetime,'yyyy-mm-dd')&' '&timeformat(request.zsession.trackingArrPages[i].track_page_datetime, 'HH:mm:ss'))#,
		track_user_id=#db.param(request.zsession.tracking.track_user_id)#,
		site_id=#db.param(request.zos.globals.id)#";
		local.rs=db.insert("qInsert", request.zOS.insertIDColumnForSiteIDTable);
	}
	if(arraylen(request.zsession.trackingArrPages)){
		if(local.rs.success){
			track_page_id=local.rs.result;
		}else{
			throw("track_page insert failed");	
		}
	}
	if(isnull(track_page_id)){
		track_page_id=0;
	}
	db.sql="SELECT * FROM #request.zos.queryObject.table("track_convert", request.zos.zcoreDatasource)# track_convert 
	WHERE track_convert_name = #db.param(arguments.track_convert_name)# ";
	qConvert=db.execute("qConvert");
	if(qConvert.recordcount EQ 0){
		ts.struct.track_convert_name=arguments.track_convert_name;
		ts.table="track_convert";
		ts.datasource="#request.zos.zcoreDatasource#";
		track_convert_id=application.zcore.functions.zInsert(ts);
	}else{
		track_convert_id=qconvert.track_convert_id;
	}
	db.sql="INSERT INTO #request.zos.queryObject.table("track_user_x_convert", request.zos.zcoreDatasource)#  SET 
	track_user_id = #db.param(track_user_id)#,
	track_page_id = #db.param(track_page_id)#,
	track_convert_id = #db.param(track_convert_id)#,
	track_user_x_convert_datetime = #db.param(request.zos.mysqlnow)#, 
	site_id = #db.param(request.zos.globals.id)#";
	db.execute("qUser");
	db.sql="UPDATE #request.zos.queryObject.table("track_user", request.zos.zcoreDatasource)# track_user 
	SET track_user_conversions=track_user_conversions+#db.param(1)# 
	WHERE track_user_id = #db.param(track_user_id)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qUpdate=db.execute("qUpdate");
	</cfscript>
	</cffunction>
	
	<cffunction name="getSearchTerms" localmode="modern" output="false">
		<cfargument name="link" type="string" required="yes">
		<cfscript>
		var arrParam='';
		var paramcount='';
		var keywords='';
		var i='';
		var startpos='';
		var endpos='';
		// this code matches keywords out of hundreds of search engine referer urls
		if(len(trim(arguments.link)) EQ 0) return '';
		arrParam=ListToArray("query=,q=,p=,keywords=,keyword=,searchfor=,qry=,ask=,s=,w=,string=,f_name=,qkw=,find=,searchstr=,k=,C=,N=");
		paramcount=ArrayLen(arrParam);
		
		keywords="";
		for(i=1;i LTE paramcount;i=i+1){
			startpos=findnocase(arrParam[i], arguments.link);
			if(startpos NEQ 0 and refindnocase("([a-z0-9])", mid(arguments.link, startpos-1,1)) EQ 0){
				startpos = startpos+len(arrParam[i]);
				endpos=findnocase("&", arguments.link, startpos);
				if(endpos EQ 0) endpos = len(arguments.link);
				keywords=trim(URLDecode(mid(arguments.link, startpos, endpos-(startpos-1))));
				if(right(keywords,1) EQ '&'){
					keywords=removeChars(keywords,len(keywords),1);
				}
			}
		}
		return lcase(keywords);
		</cfscript>
	</cffunction>
	
    <!--- trackCom.setEmailCampaign(zemail_campaign_id); --->
	<cffunction name="setEmailCampaign" localmode="modern" returntype="any" output="false">
    	<cfargument name="zemail_campaign_id" type="string" required="yes">
		<cfscript>
		if(structkeyexists(request.zos,'trackingDisabled')) return;
		request.zsession.zemail_campaign_id=arguments.zemail_campaign_id;
		request.zsession.tracking.zemail_campaign_id=arguments.zemail_campaign_id;
		</cfscript>
        <cfcookie name="__#request.zos.zcoremapping#ecid" expires="never" value="#arguments.zemail_campaign_id#" domain=".#request.zCookieDomain#">
    </cffunction>
    
    
    <!--- trackCom.setEmailConversion(conversionId); --->
    <cffunction name="setEmailConversion" localmode="modern" returntype="void" output="no">
    	<cfargument name="conversionId" type="numeric" required="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		var q=0;
		if(structkeyexists(request.zos,'trackingDisabled')) return;
		if(isDefined('request.zsession.zemail_campaign_id') and isDefined('request.zsession.user.id')){
			db.sql="INSERT INTO #request.zos.queryObject.table("zemail_campaign_click", request.zos.zcoreDatasource)# zemail_campaign_click 
			SET zemail_campaign_click_type=#db.param('5')#, 
			zemail_campaign_click_html=#db.param('1')#, 
			zemail_campaign_click_offset=#db.param(arguments.conversionId)#, 
			zemail_campaign_click_ip=#db.param(request.zos.cgi.remote_addr)#, 
			zemail_campaign_click_datetime=#db.param(request.zos.mysqlnow)#, 
			zemail_campaign_id=#db.param(request.zsession.zemail_campaign_id)#, 
			user_id=#db.param(request.zsession.user.id)#,
			site_id=#db.param(request.zos.globals.id)#";
			db.execute("q");
		}else if(isDefined('cookie.__#request.zos.zcoremapping#ecid') and isDefined('cookie.__#request.zos.zcoremapping#euid')){
			db.sql="INSERT INTO #request.zos.queryObject.table("zemail_campaign_click", request.zos.zcoreDatasource)# zemail_campaign_click SET 
			zemail_campaign_click_type=#db.param('5')#, 
			zemail_campaign_click_html=#db.param('1')#, 
			zemail_campaign_click_offset=#db.param(arguments.conversionId)#, 
			zemail_campaign_click_ip=#db.param(request.zos.cgi.remote_addr)#, 
			zemail_campaign_click_datetime=#db.param(request.zos.mysqlnow)#, 
			zemail_campaign_id=#db.param(cookie["__#request.zos.zcoremapping#ecid"])#, 
			user_id=#db.param(cookie["__#request.zos.zcoremapping#euid"])#,
			site_id=#db.param(request.zos.globals.id)#";
			db.execute("q");
		}
		</cfscript>
    </cffunction>
    
    
    
	<cffunction name="endRequest" localmode="modern" output="yes" returntype="any">
    	<cfscript>
		if(structkeyexists(form, 'zab') EQ false){
			// disable slow script detection for ab.exe benchmarking
			this.detectSlowScript();
			try{
			application.zcore.arrRequestcache[request.zos.trackingRequestCacheIndex].runtime=(gettickcount('nano')-request.zos.startTime)/1000000000;
			}catch(Any excpt){	
					
			}
			/*
			if(isDefined('request.zos.processId') and isDefined('application.zcore.processList')){
				StructDelete(application.zcore.processList, request.zos.processId);
			}*/
			if(request.zos.trackingspider and structcount(request.zsession)){
				application.zcore.session.clear();
			}
		}
		
		</cfscript>
    </cffunction>
    
    
	<cffunction name="detectSlowScript" localmode="modern" output="false" returntype="void">
     <cfif request.zos.istestserver EQ false and structkeyexists(request, 'ignoreSlowScript') EQ false and (gettickcount('nano')-request.zos.startTime)/1000000000 GT 15><cfmail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="Jetendo CMS Slow Script Alert" type="html">
#application.zcore.functions.zHTMLDoctype()#
<head>
<meta charset="utf-8" />
<title>Slow Script</title>
</head>

<body>
<strong style="font-size:14px;">Jetendo CMS Slow Script Alert</strong><br /><br />
<a href="http://#request.zos.cgi.HTTP_HOST##request.zos.originalURL#?#request.zos.cgi.QUERY_STRING#">http://#request.zos.cgi.HTTP_HOST##request.zos.originalURL#?#request.zos.cgi.QUERY_STRING#</a><br />
#(gettickcount('nano')-request.zos.startTime)/1000000000# seconds to complete<br />
user ip: #request.zos.cgi.remote_addr#<br />
user agent: #request.zos.cgi.HTTP_USER_AGENT#<br />
<cfif request.zos.importMLSRunning>
	Import MLS was running when this slow script alert was triggered.<br />
</cfif>
<br />
<cfscript>	
if(structkeyexists(request.zos, 'arrRunTime')){
	writeoutput('<h2>Script Run Time Measurements</h2>');
	arrayprepend(request.zos.arrRunTime, {time:request.zos.startTime, name:'Application.cfc onCoreRequest Start'});
	for(i=2;i LTE arraylen(request.zos.arrRunTime);i++){
		writeoutput(((request.zos.arrRunTime[i].time-request.zos.arrRunTime[i-1].time)/1000000000)&' seconds | '&request.zos.arrRunTime[i].name&'<br />');	
	}
}
</cfscript>
<a href="#request.zos.globals.serverDomain#/z/server-manager/admin/recent-requests/index?force=1">Click here to view recent request history.</a>

</body>
</html>
</cfmail></cfif>
	</cffunction>
    </cfoutput>
</cfcomponent>