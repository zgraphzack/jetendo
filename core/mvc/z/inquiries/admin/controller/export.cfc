<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qI=0;
	var arrLink=0;
	var arrF2n28=0;
	var i328=0;
	var urlMLSId=0;
	var urlMLSPid=0;
	var theSQL=0; 
	var i=0;
	var arrI=0;
	var arrP=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Export");
	if(application.zcore.user.checkGroupAccess("administrator") EQ false){
		application.zcore.functions.z404();	
	}
	form.format=application.zcore.functions.zso(form,'format',false,'csv');
	
	form.inquiries_start_date=application.zcore.functions.zso(form,'inquiries_start_date',false,createdatetime(2009,4,10,1,1,1));
	form.inquiries_end_date=application.zcore.functions.zso(form,'inquiries_end_date',false,now());
	form.exporttype=application.zcore.functions.zso(form,'exporttype',false,'0');
	header name="Content-Type" value="text/plain" charset="utf-8";
	if(form.format EQ 'csv'){
		header name="Content-Disposition" value="attachment; filename=inquiries.csv" charset="utf-8";
	}else if(form.format EQ 'html'){
		header name="Content-Disposition" value="attachment; filename=inquiries.html" charset="utf-8";
		writeoutput('#application.zcore.functions.zHTMLDoctype()#
		<head>
		<meta charset="utf-8" />
		<title>#request.zos.globals.shortdomain#Inquiries Export</title>
		<style type="text/css">
		body {
			font-family:Arial, Helvetica, sans-serif;
			font-size:11px;
			line-height:14px;
		}
		.row2 td {
			background-color:##EEEEEE;
		}
		.header td {
			background-color:##336699;
			color:##FFF;
			font-weight:bold;
		}
		td {
			border-right:1px solid ##CCCCCC;
		}
		h1 {
			line-height:24px;
			font-size:18px;
		}
		</style>
		</head>
		
		<body>
		<h1>#request.zos.globals.shortdomain# Inquiries Export</h1>
		<table style="border-spacing:0px;border:1px solid ##CCCCCC;">');
	}
	request.znotemplate=1;
	setting enablecfoutputonly="yes";
	if(structkeyexists(form,'keywordexport')){
		savecontent variable="theSql"{
			writeoutput(' SELECT * 
			from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
			#db.table("track_user", request.zos.zcoreDatasource)# track_user 
			WHERE inquiries.inquiries_email = track_user.track_user_email AND 
			inquiries.site_id = track_user.site_id AND
			track_user.site_id = #db.param(request.zos.globals.id)# AND 
			track_user_keywords <> #db.param('')# and 
			track_user_email <> #db.param('')# AND 
			(track_user_keywords LIKE #db.param('%#form.keywordsearch#%')# or 
			track_user_keywords LIKE #db.param('%#application.zcore.functions.zurlencode(form.keywordsearch,"%")#%')#) 
			and inquiries.inquiries_status_id <> #db.param(0)# 
			and inquiries.inquiries_spam = #db.param(0)# 
			and inquiries_parent_id = #db.param(0)#');
			if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "homeowner") eq false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
				writeoutput(' AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
				user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#');
			}
			if(application.zcore.functions.zso(request.zsession, 'agentuserid') NEQ ''){
				writeoutput(' and inquiries.user_id = #db.param(request.zsession.agentuserid)# and 
				user_id_siteIDType = #db.param(request.zsession.agentusersiteidtype)#');
			}
			if(form.inquiries_start_date EQ false){
				writeoutput(' and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
				inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#)');
			}else{
				writeoutput(' and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
				inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)');
			}
			if(application.zcore.functions.zso(form,'exporttype') EQ 1){
				writeoutput(' GROUP BY inquiries_email');
			}else if(application.zcore.functions.zso(form,'exporttype') EQ 2){
				writeoutput(' GROUP BY inquiries_phone1, inquiries_phone2');
			}
			writeoutput(' ORDER BY inquiries_datetime DESC');
		}
		db.sql=theSQL;
		qI=db.execute("qI");
	}else{
		savecontent variable="theSql"{
			writeoutput('SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries WHERE
			inquiries.site_id = #db.param(request.zOS.globals.id)# and 
			inquiries.inquiries_status_id <> #db.param(0)# and 
			inquiries.inquiries_spam = #db.param(0)# and 
			inquiries_parent_id = #db.param(0)#');
			if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "homeowner") eq false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
				writeoutput(' AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
				user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#');
			}
			if(application.zcore.functions.zso(request.zsession,'agentuserid') NEQ ''){
				writeoutput(' and inquiries.user_id = #db.param(request.zsession.agentuserid)# and 
				user_id_siteIDType = #db.param(request.zsession.agentusersiteidtype)# ');
			}
			if(application.zcore.functions.zso(form,'searchType',true) EQ 0){
				if(form.inquiries_start_date EQ false){
					writeoutput(' and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
					inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#)');
				}else{
					writeoutput(' and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
					inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)');
				}
			}else{
				if(form.inquiries_start_date EQ false){
					writeoutput(' and (inquiries_start_date >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
					inquiries_end_date <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#)');
				}else{
					writeoutput(' and (inquiries_start_date >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
					inquiries_end_date <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)');
				}
			}
			if(application.zcore.functions.zso(form,'inquiries_name') NEQ ""){
				writeoutput(' and concat(inquiries_first_name, #db.param(" ")#, inquiries_last_name) LIKE #db.param('%#form.inquiries_name#%')#');
			}
			if(isDefined('request.zsession.leadcontactfilter')){
				if(request.zsession.leadcontactfilter EQ 'new'){
					writeoutput(' and inquiries.inquiries_status_id =#db.param('1')#');
				}else if(request.zsession.leadcontactfilter EQ 'email'){
					writeoutput(' and inquiries_phone1 =#db.param('')# 	and inquiries_phone_time=#db.param('')#');
				}else if(request.zsession.leadcontactfilter EQ 'phone'){
					writeoutput(' and inquiries_phone1 <>#db.param('')# 	and inquiries_phone_time=#db.param('')#');
				}else if(request.zsession.leadcontactfilter EQ 'forced'){
					writeoutput(' and inquiries_phone_time<>#db.param('')#');
				}
			}
			if(isDefined('request.zsession.leademailgrouping') and request.zsession.leademailgrouping EQ '1'){
				writeoutput(' and inquiries_primary = #db.param('1')#');
			}
			if(application.zcore.functions.zso(form, 'exporttype') EQ 1){
				writeoutput(' GROUP BY inquiries_email');
			}else if(application.zcore.functions.zso(form, 'exporttype') EQ 2){
				writeoutput(' GROUP BY inquiries_phone1, inquiries_phone2');
			}
			writeoutput(' ORDER BY inquiries_datetime DESC ');
		}
		db.sql=theSQL;
		qI=db.execute("qI");
	}
	if(form.format EQ 'html'){
		writeoutput('<tr class="header">
			<td>First Name</td>
			<td>Last Name</td>
			<td>Email</td>
			<td>Phone1</td>
			<td>Phone2</td>
			<td>Company</td>
			<td>Date Received</td>
			<td colspan="40">Associated Links</td>
		</tr>');
	}else if(form.format EQ 'csv'){
		writeoutput('"First Name","Last Name","Email","Phone1","Phone2","Company","Date Received","Associated Links"#chr(13)&chr(10)#');
	}
	loop query="qI"{
		arrLink=arraynew(1);
		if(application.zcore.app.siteHasApp("content")){
			if(qI.content_id NEQ 0 and qI.content_id NEQ ""){
				arrF2n28=listtoarray(qI.content_id);
				for(i328=1;i328 LTE arraylen(arrF2n28);i328++){
					arrayappend(arrLink,request.zos.currentHostName&"/c-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#arrF2n28[i328]#.html");
				}
			}
		}
		if(application.zcore.app.siteHasApp("listing") and qI.property_id NEQ ''){
			arrP=listtoarray(qI.property_id,',');
			for(i=1;i LTE arraylen(arrP);i++){
				arrI=listtoarray(arrP[i],'-');
				if(arraylen(arrI) EQ 2){
					urlMlsId=application.zcore.listingCom.getURLIdForMLS(arrI[1]);
					urlMLSPId=arrI[2];
					arrayappend(arrLink,request.zos.currentHostName&"/c-#urlMlsId#-#urlMLSPId#.html");
				}
			}
		}
		if(qI.inquiries_referer NEQ "" and qI.inquiries_referer DOES NOT CONTAIN request.zos.currentHostName&'/inquiry'){
			arrayappend(arrLink,qI.inquiries_referer);	
		}
		if(qI.inquiries_referer2 NEQ "" and qI.inquiries_referer2 DOES NOT CONTAIN request.zos.currentHostName&'/inquiry'){
			arrayappend(arrLink, qI.inquiries_referer2);	
		}
		if(form.format EQ 'html'){
			for(i=1;i LTE arraylen(arrLink);i++){
				if(arrLink[i] NEQ ""){	
					arrLink[i]='<a href="#arrLink[i]#" target="_blank">Link #i#</a>';
				}
			}
		}
		if(form.format EQ 'html'){
			if(qI.currentrow MOD 2 EQ 0){
				writeoutput('<tr class="row2">');
			}else{
				writeoutput('<tr>');
			}
			writeoutput('<td>#qI.inquiries_first_name#&nbsp;</td>
			<td>#qI.inquiries_last_name#&nbsp;</td>
			<td>#qI.inquiries_email#&nbsp;</td>
			<td>#qI.inquiries_phone1#&nbsp;</td>
			<td>#qI.inquiries_phone2#&nbsp;</td>
			<td>#qI.inquiries_company#&nbsp;</td>
			<td>#DateFormat(qI.inquiries_datetime, "m/dd/yyyy")# #Timeformat(qI.inquiries_datetime, "h:mm tt")#&nbsp;</td>');
			loop from="1" to="#arraylen(arrLink)#" index="i"{
				writeoutput('<td>#arrLink[i]#&nbsp;</td>');
			}
			writeoutput('</tr>');
		}else{
			writeoutput('"#qI.inquiries_first_name#", "#qI.inquiries_last_name#", "#qI.inquiries_email#", "#qI.inquiries_phone1#", "#qI.inquiries_phone2#","#qI.inquiries_company#", "#DateFormat(qI.inquiries_datetime, "m/dd/yyyy")# #Timeformat(qI.inquiries_datetime, "h:mm tt")#"');
			loop from="1" to="#arraylen(arrLink)#" index="i"{
				writeoutput(',"#arrLink[i]#"');
			}
			writeoutput(chr(13)&chr(10));
		}
	}
	if(form.format EQ 'html'){
		writeoutput('</table></body></html>');
	}
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>