<cfcomponent>
<cfoutput>

<cffunction name="index" localmode="modern" access="remote">
	reservation_config_id
reservation_config_confirmation_email_list
reservation_config_change_email_list
reservation_config_payment_failure_email_list
reservation_config_destination_on_email

reservation_config_email_creation_subject
reservation_config_email_creation_header
reservation_config_email_change_subject
reservation_config_email_change_header
reservation_config_email_cancelled_subject
reservation_config_email_cancelled_header

</cffunction>



<cffunction name="sendReminderEmail" localmode="modern" access="remote">
	<cfscript>
	throw("not implemented");
	db=request.zos.queryObject;
	if(not request.zos.isServer and not request.zos.isDeveloper){
		application.zcore.functions.z404("Only server or developer can access this url.");
	}
	db.sql="select * from #db.table("reservation", request.zos.zcoreDatasource)# reservation, 
	#db.table("reservation_type", request.zos.zcoreDatasource)# reservation_type
	WHERE 
	reservation_type.reservation_type_id = reservation.reservation_type_id and 
	reservation_type.site_id = reservation.site_id and 
	reservation.site_id = #db.param(request.zos.globals.id)# and 
	reservation.reservation_id = #db.param(form.reservation_id)# and 
	reservation.reservation_status = #db.param(1)# and 
	reservation.reservation_deleted=#db.param(0)# ";
	qReservation=db.execute("qReservation");
  
	if((request.zos.istestserver EQ false or structkeyexists(form, 'forceEmail')) and not structkeyexists(form, 'forceDebug')){
		form.debug=false;
	}else{
		form.debug=true;
	}
	form.site_id=request.zos.globals.id;

	arrOut=[];
	arrPlainOut=[];
	arrayAppend(arrOut, qReservation.reservation_config_email_reminder_header);
	arrayAppend(arrPlainOut, qReservation.reservation_config_email_reminder_header);

	// arrayAppend(arrOut, "details...");
	// arrayAppend(arrPlainOut, "");

	t1={};
	ts=StructNew(); 
	ts.subject=qReservation.reservation_config_email_reminder_subject;
	ts.site_id=request.zos.globals.id;
	

	// change this to be a custom script in the database, so that the variables read in.
	ts.zemail_template_type_name="general";
	if(row.html EQ 1){
		request.zTempNewEmailHTML=arrayToList(arrOut, chr(10));
		ts.html=true;
	}else{
		request.zTempNewEmailHTML="";
		ts.html=false;
	}
	request.zTempNewEmailPlainText=arrayToList(arrPlainOut, chr(10));
	if(request.zos.globals.emailCampaignFrom EQ ""){
		throw("request.zos.globals.emailCampaignFrom is missing, can't send listing alerts.");
	}
	ts.from=request.zos.globals.emailCampaignFrom;
	if(form.debug or request.zos.istestserver){
		ts.to=request.zos.developerEmailTo;
	}else{
		ts.to=qReservation.reservation_email;
		/*
		if(curMailUserId NEQ 0){
			ts.mail_user_id=curMailUserId;
		}else{
			ts.user_id=curUserId;
			ts.user_id_siteIDType=curUserSiteIdType;
		}*/
	} 
	if(form.debug){
		ts.preview=true;
	}else{
		ts.preview=false;
	}  
	rCom=application.zcore.email.sendEmailTemplate(ts); 
	if(rCom.isOK() EQ false){
		// user has opt out probably...
		if(form.debug){
			rCom.setStatusErrors(request.zsid);
			application.zcore.functions.zstatushandler(request.zsid); 
		}
	}
	if(form.debug or request.zos.istestserver){
		emailRS=rCom.getData();
		if(structkeyexists(emailRS, 'emailData')){
			writeoutput(emailRS.emailData.html);
			writeoutput('<pre>'&emailRS.emailData.text&'</pre>');
		}
		writedump(emailRS);
		application.zcore.functions.zabort(); 
	}


	</cfscript>
</cffunction>
	

<cffunction name="findReservationNeedingReminder" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	arrReminder=listToArray(application.zcore.app.getAppData("reservation").optionStruct.reservation_config_reminder_days_list, ",");
	arraySort(arrReminder, "numeric", "asc");
	for(i=1;i LTE arraylen(arrReminder);i++){
		xDays=arrReminder[i];
		futureDate=dateadd("d", xDays, now());
		db.sql="select reservation_id, site_id from #db.table("reservation", request.zos.zcoreDatasource)# 
		WHERE 
		reservation.site_id = #db.param(request.zos.globals.id)# and 
		reservation.reservation_status = #db.param(1)# and 
		reservation.reservation_deleted=#db.param(0)# and 
		reservation_reminder_email_sent_x_days < #db.param(xDays)# 
		reservation_start_datetime < #db.param(dateformat(futureDate, "yyyy-mm-dd")&" "&timeformat(futureDate, "HH:mm:ss"))# ";
		qReservation=db.execute("qReservation");
		for(reserve in qReservation){
			link=application.zcore.functions.zvar('domain', reserve.site_id)&"/z/reservation/tasks/reservation-email-alert/sendReminderEmail?reservation_id=#reserve.reservation_id#";
	        if(structkeyexists(form, 'forceDebug')){
	        	link&="&forceDebug=1";
	        }
	        if(structkeyexists(form, 'forceEmail')){
	        	link&="&forceEmail=1";
	        }
	        r1=application.zcore.functions.zDownloadLink(link);
	        if(r1.success){

				db.sql="update #db.table("reservation", request.zos.zcoreDatasource)# set 
				reservation_reminder_email_sent_x_days < #db.param(xDays)#, 
				reservation_updated_datetime=#db.param(request.zos.mysqlnow)#
				WHERE 
				reservation.site_id = #db.param(reserve.site_id)# and 
				reservation.reservation_id = #db.param(reserve.reservation_id)# and 
				reservation.reservation_deleted=#db.param(0)#";
				db.execute("qUpdate");
			}
		    if(request.zos.isTestServer){
		    	echo("Downloaded: "&link&"<br />");
		    	if(r1.success EQ false){
		    		writedump(r1);
		    	}else{
		            writeoutput(r1.cfhttp.FileContent&'<br /><br />');
					application.zcore.functions.zabort();
				}
		    }
		}
	}
	</cfscript>
</cffunction>
	

</cfoutput>
</cfcomponent>
