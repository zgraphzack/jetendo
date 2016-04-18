<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject; 
	setting requesttimeout="10000";
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Export");

	if(application.zcore.user.checkGroupAccess("administrator") EQ false){
		application.zcore.functions.z404();	
	}
	form.format=application.zcore.functions.zso(form,'format',false,'csv');
	
	form.inquiries_start_date=application.zcore.functions.zso(form,'inquiries_start_date',false,createdatetime(2009,4,10,1,1,1));
	form.inquiries_end_date=application.zcore.functions.zso(form,'inquiries_end_date',false,now());
	form.inquiries_status_id=application.zcore.functions.zso(form, 'inquiries_status_id');
	form.uid=application.zcore.functions.zso(form, 'uid');
	arrU=listToArray(form.uid, '|');
	form.selected_user_id=0;
	if(arrayLen(arrU) EQ 2){
		form.selected_user_id=arrU[1];
		form.selected_user_id_siteIDType=arrU[2];
	}
	form.exporttype=application.zcore.functions.zso(form,'exporttype',false,'0');
	if(form.format EQ 'csv'){
		header name="Content-Type" value="text/plain" charset="utf-8";
		header name="Content-Disposition" value="attachment; filename=#dateformat(now(), 'yyyy-mm-dd')#-inquiries.csv" charset="utf-8";
		//setting enablecfoutputonly="yes";
	}else if(form.format EQ 'html'){
		header name="Content-Disposition" value="attachment; filename=#dateformat(now(), 'yyyy-mm-dd')#-inquiries.html" charset="utf-8";
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


	db.sql="select * from #db.table("inquiries_type", request.zos.zcoreDatasource)# 
	WHERE 
	site_id IN (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	inquiries_type_deleted=#db.param(0)#";
	qType=db.execute("qType");
	typeStruct={};
	for(row in qType){
		if(row.site_id EQ request.zos.globals.id){
			sid=1;
		}else{
			sid=4;
		}
		typeStruct[row.inquiries_type_id&"|"&sid]=row.inquiries_type_name;
	}
	fieldStruct={};
	customStruct={};
	sortStruct={};
	for(i2=1;i2 LTE 2;i2++){
		doffset=0;
		// first loop finds all the field names
		// second loop outputs the field names and data in alphabetic order
		if(i2 EQ 2){ 
			structdelete(fieldStruct, 'inquiries_datetime');
			structdelete(fieldStruct, 'inquiries_custom_json');
			structdelete(fieldStruct, 'inquiries_type_id');
			structdelete(fieldStruct, 'inquiries_type_id_siteIdType');
			structdelete(fieldStruct, 'inquiries_type_other');
			structdelete(fieldStruct, 'inquiries_deleted');
			structdelete(fieldStruct, 'inquiries_status_id');
			structdelete(fieldStruct, 'inquiries_assign_email');
			structdelete(fieldStruct, 'user_id');
			structdelete(fieldStruct, 'inquiries_updated_datetime');
			structdelete(fieldStruct, 'inquiries_readonly');
			structdelete(fieldStruct, 'inquiries_external_id');
			structdelete(fieldStruct, 'site_id');
			arrF=structkeyarray(fieldStruct);
			arrF2=structkeyarray(customStruct);
			for(i3=1;i3 LTE arraylen(arrF2);i3++){
				arrayAppend(arrF, arrF2[i3]);
			}

			for(i3=1;i3 LTE arraylen(arrF);i3++){
				sortStruct[i3]={field:arrF[i3]};
			}
			arrFieldSort=structsort(sortStruct, "text", "asc", "field");
			
			if(form.format EQ 'html'){
				writeoutput('<tr class="header"><td>Type</td><td>Date Received</td>');
				for(i3=1;i3 LTE arraylen(arrFieldSort);i3++){
					c=sortStruct[arrFieldSort[i3]].field;
					f=replace(replace(c, 'inquiries_', ''), '_', ' ', 'all');
					echo('<td>'&f&'</td>');
				}
				echo('<td colspan="40">Associated Links</td></tr>'&chr(10));
			}else if(form.format EQ 'csv'){
				echo('"Type", "Date Received", ');
				for(i3=1;i3 LTE arraylen(arrFieldSort);i3++){ 
					c=sortStruct[arrFieldSort[i3]].field;
					f=replace(replace(c, 'inquiries_', ''), '_', ' ', 'all');
					echo('"'&replace(f, '"', '', 'all')&'", ');
				}
				echo(' "Associated Links"'&chr(13)&chr(10));
			}
		}
		while(true){
			if(structkeyexists(form,'keywordexport')){
				savecontent variable="theSql"{
					writeoutput(' SELECT * 
					from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
					#db.table("track_user", request.zos.zcoreDatasource)# track_user 
					WHERE inquiries.inquiries_email = track_user.track_user_email AND 
					inquiries_deleted = #db.param(0)# and 
					track_user_deleted = #db.param(0)# and 
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
					if(form.selected_user_id NEQ 0){
						writeoutput(' and inquiries.user_id = #db.param(form.selected_user_id)# and 
						user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)#');
					}
					if(form.inquiries_start_date EQ false){
						writeoutput(' and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
						inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#)');
					}else{
						writeoutput(' and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
						inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)');
					}
					if(application.zcore.functions.zso(form, 'inquiries_type_id') NEQ ""){
						echo(' and inquiries.inquiries_type_id = #db.param(listgetat(form.inquiries_type_id, 1, "|"))# and 
						inquiries_type_id_siteIDType = #db.param(listgetat(form.inquiries_type_id, 2, "|"))# ');
					}
					if(application.zcore.functions.zso(form,'exporttype') EQ 1){
						writeoutput(' GROUP BY inquiries_email');
					}else if(application.zcore.functions.zso(form,'exporttype') EQ 2){
						writeoutput(' GROUP BY inquiries_phone1, inquiries_phone2');
					}
					writeoutput(' ORDER BY inquiries_datetime DESC');
				} 
			}else{
				savecontent variable="theSql"{
					writeoutput('SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries WHERE
					inquiries.site_id = #db.param(request.zOS.globals.id)# and 
					inquiries.inquiries_status_id <> #db.param(0)# and 
					inquiries_deleted = #db.param(0)# and 
					inquiries.inquiries_spam = #db.param(0)# and 
					inquiries_parent_id = #db.param(0)#');
					if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "homeowner") eq false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
						writeoutput(' AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
						user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#');
					}
					if(form.selected_user_id NEQ 0){
						writeoutput(' and inquiries.user_id = #db.param(form.selected_user_id)# and 
						user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)# ');
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
					if(application.zcore.functions.zso(form, 'inquiries_type_id') NEQ ""){
						echo(' and inquiries.inquiries_type_id = #db.param(listgetat(form.inquiries_type_id, 1, "|"))# and 
						inquiries_type_id_siteIDType = #db.param(listgetat(form.inquiries_type_id, 2, "|"))# ');
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
			}

			db.sql=theSQL&" LIMIT #db.param(doffset)#, #db.param(100)# ";
			qInquiries=db.execute("qInquiries");
			if(qInquiries.recordcount EQ 0){
				break;
			}
			doffset+=100;
			if(i2 EQ 1){
				for(row in qInquiries){
					/*if(row.inquiries_custom_json EQ ""){
						continue;
					}*/

					for(n in row){
						if(row[n] NEQ "" and row[n] NEQ "0"){
							fieldStruct[n]="";
						}
					}
					if(row.inquiries_custom_json NEQ ""){
						j=deserializeJson(row.inquiries_custom_json);
						if(not isstruct(j)){
							j={arrCustom:[]};
						}
						if(structkeyexists(j, 'arrCustom')){
							for(n=1;n LTE arraylen(j.arrCustom);n++){
								r=j.arrCustom[n];
								if(r.value NEQ "" and r.value NEQ "0"){
									customStruct[r.label]="";
								}
							}
						}
					}
				}
			}else{
				currentRow=1;
				for(row in qInquiries){
					arrLink=arraynew(1);
					if(application.zcore.app.siteHasApp("content")){
						if(row.content_id NEQ 0 and row.content_id NEQ ""){
							arrF2n28=listtoarray(row.content_id);
							for(i328=1;i328 LTE arraylen(arrF2n28);i328++){
								arrayappend(arrLink,request.zos.currentHostName&"/c-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#arrF2n28[i328]#.html");
							}
						}
					}
					if(application.zcore.app.siteHasApp("listing") and row.property_id NEQ ''){
						arrP=listtoarray(row.property_id,',');
						for(i=1;i LTE arraylen(arrP);i++){
							arrI=listtoarray(arrP[i],'-');
							if(arraylen(arrI) EQ 2){
								urlMlsId=application.zcore.listingCom.getURLIdForMLS(arrI[1]);
								urlMLSPId=arrI[2];
								arrayappend(arrLink,request.zos.currentHostName&"/c-#urlMlsId#-#urlMLSPId#.html");
							}
						}
					}
					if(row.inquiries_referer NEQ "" and row.inquiries_referer DOES NOT CONTAIN request.zos.currentHostName&'/inquiry'){
						arrayappend(arrLink,row.inquiries_referer);	
					}
					if(row.inquiries_referer2 NEQ "" and row.inquiries_referer2 DOES NOT CONTAIN request.zos.currentHostName&'/inquiry'){
						arrayappend(arrLink, row.inquiries_referer2);	
					}
					if(form.format EQ 'html'){
						for(i=1;i LTE arraylen(arrLink);i++){
							if(arrLink[i] NEQ ""){	
								arrLink[i]='<a href="#arrLink[i]#" target="_blank">Link #i#</a>';
							}
						}
					}
					tid=row.inquiries_type_id&"|"&row.inquiries_type_id_siteIDType;
					typeName="";
					if(structkeyexists(typeStruct, tid)){
						typeName=typeStruct[tid];
					} 
					dateTime=dateformat(row.inquiries_datetime, "m/dd/yyyy")&" "&Timeformat(row.inquiries_datetime, "h:mm tt");
					
					if(row.inquiries_custom_json NEQ ""){
						j=deserializeJson(row.inquiries_custom_json);
						j2={};
						for(i3=1;i3 LTE arraylen(j.arrCustom);i3++){
							j2[j.arrCustom[i3].label]=j.arrCustom[i3].value;
						}
						j=j2;
					}else{
						j={};
					}
					if(form.format EQ 'html'){
						if(currentrow MOD 2 EQ 0){
							writeoutput('<tr class="row2">');
						}else{
							writeoutput('<tr>');
						}
						writeoutput('<td>#typeName#</td><td>#dateTime#</td>');
						for(i3=1;i3 LTE arraylen(arrFieldSort);i3++){
							c=sortStruct[arrFieldSort[i3]].field;
							if(structkeyexists(j, c)){
								v=j[c];
							}else if(structkeyexists(row, c)){
								v=row[c];
							}else{
								v="";
							} 
							v=left(replace(replace(replace(rereplace(v, '<.*?>', '', 'all'), chr(13), "", "all"), chr(10), " ", "all"), '"', "", 'all'), 100);
							if(v EQ ""){
								v="&nbsp;";
							}
							if(structkeyexists(j, c)){
								echo('<td>'&v&'</td>');
							}else if(structkeyexists(row, c)){
								echo('<td>'&v&'</td>');
							}else{
								echo('<td>&nbsp;</td>');
							} 
						}
						loop from="1" to="#arraylen(arrLink)#" index="i"{
							writeoutput('<td>#arrLink[i]#&nbsp;</td>');
						}
						echo('</tr>'&chr(10));
					}else if(form.format EQ 'csv'){
						echo('"'&replace(typeName, '"', "", 'all')&'", "'&dateTime&'", ');
						for(i3=1;i3 LTE arraylen(arrFieldSort);i3++){
							c=sortStruct[arrFieldSort[i3]].field;
							if(structkeyexists(j, c)){
								v=j[c];
							}else if(structkeyexists(row, c)){
								v=row[c];
							}else{
								v="";
							} 
							v=left(replace(replace(replace(rereplace(v, '<.*?>', '', 'all'), chr(13), "", "all"), chr(10), " ", "all"), '"', "", 'all'), 100);
							if(i3 NEQ 1){
								echo(", ");
							}
							echo('"'&v&'"');
						}
						loop from="1" to="#arraylen(arrLink)#" index="i"{
							writeoutput(',"#arrLink[i]#"');
						}
						echo(chr(13)&chr(10));
					}
					currentRow++;
				}
			}
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