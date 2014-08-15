<cfcomponent>
<cfoutput>
<cfscript>
this.app_id=16;
</cfscript>
<!--- 

Reservation Options for a service
	must be able to set rates per reservation_type_id

	reservation_price
		reservation_price_start_datetime
		reservation_price_end_datetime
	
allowed_reservation_type_list - multiple select of reservation_type_id - which are site specific

			
	reservation_period_type_name event | hourly | nightly | weekly | monthly | yearly

if(reservation_period_type_name EQ "event"){
	use event_id for display purposes
}else if(reservation_period_type_name EQ "hourly"){
	use time in reservation_start_datetime and reservation_end_datetime
}else{
	ignore time
}


reservation_allowed_hours  - add more then one for the same day if there is lunch break, etc.
	reservation_allowed_hours_id
	reservation_type_id // 0 for global settings, otherwise it will allow overriding the settings for a specific reservation type
	reservation_allowed_hours_day_of_week (monday through sunday)
	reservation_allowed_hours_start_time
	reservation_allowed_hours_end_time
	reservation_allowed_hours_all_day char(1) 0 // allows availability search to be more efficient when time comparison is not required.
	reservation_allowed_hours_updated_datetime
	reservation_allowed_hours_deleted
	site_id
reservation_excluded_hours  - Used to disable times or entire days from being booked
	reservation_excluded_hours_id
	reservation_type_id // 0 for global settings, otherwise it will allow overriding the settings for a specific reservation type
	reservation_excluded_hours_date
	reservation_excluded_hours_start_time
	reservation_excluded_hours_end_time
	reservation_excluded_hours_all_day char(1) 0 // allows availability search to be more efficient when time comparison is not required.
	reservation_excluded_hours_updated_datetime
	reservation_excluded_hours_deleted
	site_id

reservation_payment_type
	reservation_payment_type_id
	reservation_type_id
	reservation_payment_type_amount
	reservation_payment_type_title
	reservation_payment_type_description
	reservation_payment_type_updated_datetime
	reservation_payment_type_deleted
	site_id
	
validation rules for custom fields.
	i.e. max guests, min guests, pets, adults, children, 

how could reservation be used for an event instead of letting user select any time?

reservation siteOptionType
	select fields for start / end date, date description, title, etc?

	link any record with a reservation
		type options
			Period (event/hourly etc)
			For Event Only:
				Start Date: 
				End Date: 
			Map Fields:
				Title: field
				Date Description: 
		reservation_type_id_list

	site_x_option_group_set_x_reservation
		site_x_option_group_set_x_reservation_id
		site_x_option_group_set_id
		reservation_id
		site_x_option_group_set_x_reservation_updated_datetime
		site_x_option_group_set_x_reservation_deleted
		site_id


	select * from reservation 
	left join on 
	site_x_option_group_set_x_reservation s1 ON 
	reservation.reservation_id = s1.reservation_id and 
	reservation.site_id = s1.site_id and 
	s1.site_x_option_group_set_x_reservation_deleted = #db.param(0)# 
	left join on 
	site_x_option_group_set s2 ON 
	s1.site_x_option_group_set_id = s2.site_x_option_group_set_id and 
	s2.site_id = s1.site_id and 
	s2.site_x_option_group_set_deleted = #db.param(0)# 
	
	// loop each search field as a left join
	

Where "Associate With Apps" is, add a new field called "Associate With Reservation Types" when application.zcore.app.siteHasApp("reservation")
	Add these fields:
		site_option_reservation_type_id_list
		site_option_group_reservation_type_id_list



Another idea is to let the user modify / cancel their own reservation as a feature from the email alert or reservation ID + email address.  I wouldn't do this feature yet unless required.

 --->
<cffunction name="onSiteStart" localmode="modern" output="no" access="public"  returntype="struct" hint="Runs on application start and should return arguments.sharedStruct">
	<cfargument name="sharedStruct" type="struct" required="yes" hint="Exclusive application scope structure for this application.">
	<cfscript>
	return arguments.sharedStruct;
	</cfscript>
</cffunction>

<cffunction name="getCSSJSIncludes" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
</cffunction>

<cffunction name="initAdmin" localmode="modern" output="no" access="public" returntype="any">
	<cfscript>
	</cfscript>
</cffunction>

<cffunction name="getRobotsTxt" localmode="modern" output="no" access="public" returntype="string" hint="Generate the Robots.txt file as a string">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	var qa="";
	var rs="";
	var c1="";
	var db=request.zos.queryObject;

	return rs;
	</cfscript>
</cffunction>

<cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="add links to sitemap array">
	<cfargument name="arrUrl" type="array" required="yes">
	<cfscript>
	ts=application.zcore.app.getInstance(this.app_id);
	db=request.zos.queryObject;
	return arguments.arrURL;
	</cfscript>
</cffunction>


<cffunction name="getReservationTypeDateRange" localmode="modern" output="no" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	ss=arguments.struct;
	savecontent variable="out"{
		if(ss.reservation_type_period EQ "event"){
			throw("event date description not implemented");
		}else if(ss.reservation_type_period EQ "hourly"){
			s=dateformat(ss.reservation_type_start_datetime, "m/d/yyyy");
			e=dateformat(ss.reservation_type_end_datetime, "m/d/yyyy");
			echo(timeformat(ss.reservation_type_start_datetime, "h:mm tt")&" to "&timeformat(ss.reservation_type_end_datetime, "h:mm tt")&" on "&s);
			if(s NEQ e){
				echo(" through "&e);
			}
		}else{
			s=dateformat(ss.reservation_type_start_datetime, "m/d/yyyy");
			e=dateformat(ss.reservation_type_end_datetime, "m/d/yyyy");
			echo(s&" to "&e);
		}
	}
	return out;
	</cfscript>
</cffunction>


<cffunction name="getReservationTypeByName" localmode="modern" access="public">
	<cfargument name="reservation_type_name" type="numeric" required="yes">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="select * from #db.table("reservation_type", request.zos.zcoreDatasource)# 
	WHERE reservation_type_name = #db.param(arguments.reservation_type_name)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	reservation_type_deleted = #db.param(0)# and 
	reservation_type_status = #db.param(1)# ";
	qType=db.execute("qType"); 
	for(row in qType){
		return row;
	}
	throw("reservation_type_name=#arguments.reservation_type_name# is not available or doesn't exist.");
	</cfscript>
	
</cffunction>

<cffunction name="getReservationTypeById" localmode="modern" access="public">
	<cfargument name="reservation_type_id" type="numeric" required="yes">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="select * from #db.table("reservation_type", request.zos.zcoreDatasource)# 
	WHERE reservation_type_id = #db.param(arguments.reservation_type_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	reservation_type_deleted = #db.param(0)# and 
	reservation_type_status = #db.param(1)# ";
	qType=db.execute("qType"); 
	for(row in qType){
		return row;
	}
	throw("reservation_type_id=#arguments.reservation_type_id# is not available or doesn't exist.");
	</cfscript>
</cffunction>

<cffunction name="isDateRangeAvailableForEvent" localmode="modern" access="remote">
	<cfargument name="reservationTypeStruct" type="struct" required="yes">
	<cfargument name="event_id" type="string" required="yes">
	<cfargument name="reservation_start_datetime" type="string" required="yes">
	<cfargument name="reservation_end_datetime" type="string" required="yes">
	<cfscript>
	throw("not implemented");
	</cfscript>
</cffunction>


<!--- 
ts=application.zcore.reservation.getReservationTypeByName("event");
ss={
	reservation_start_datetime:form.reservation_start_datetime,
	reservation_end_datetime:form.reservation_end_datetime
	
	// for site_option_group records
	site_x_option_group_set_id:form.site_x_option_group_set_id,

	// for event records
	event_id:form.event_id
};
if(not application.zcore.reservation.isDateRangeAvailable(ts, ss)){
	application.zcore.status.setStatus(request.zsid, "Not available", form, true);
	application.zcore.functions.zRedirect();
}
 --->
<cffunction name="isDateRangeAvailable" localmode="modern" access="remote" returntype="struct">
	<cfargument name="reservationTypeStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">

	<cfscript>
	ds=application.zcore.app.getAppData("reservation");
	if(not structkeyexists(ds, 'availabilityStruct')){
		ds.availabilityStruct={
			eventCache:{},
			siteOptionGroupCache:{}
		};
	}
	os=application.zcore.app.getAppData("reservation").optionStruct;
	os.reservation_config_furthest_reservation_days	
	ts=arguments.reservationTypeStruct;
	ss=arguments.searchStruct;
	if(datecompare(dateadd("d", os.reservation_config_soonest_reservation_days, now()), ss.reservation_start_datetime) EQ -1){
		return {
			errorMessage:"The reservation must be at least #os.reservation_config_soonest_reservation_days# days in the future.",
			success:false
		};
	}
	if(ts.reservation_type_period NEQ "hourly"){
		throw("not implemented");
	}
	if(application.zcore.app.getAppData("reservation").optionstruct.reservation_config_availability_in_memory EQ "1"){

		if(structkeyexists(ss, 'site_x_option_group_set_id')){
			if(structkeyexists(ds.availabilityStruct.siteOptionGroupCache, ss.site_x_option_group_set_id)){
				setStruct=ds.availabilityStruct.siteOptionGroupCache[ss.site_x_option_group_set_id];
				startDay=dateformat(ss.reservation_start_datetime, 'yyyy-mm-dd');
				if(not structkeyexists(setStruct, startDay)){
					return {
						errorMessage:"",
						success:true
					};
				}else{
					startTime=int(timeformat(ss.reservation_start_datetime, 'HHmm'));
					endTime=int(timeformat(ss.reservation_end_datetime, 'HHmm'));
					for(i in setStruct[startDay]){
						r=setStruct[startDay][i];
						if(endTime GT r.startTime and startTime LT r.endTime){
							return {
								errorMessage:"A reservation already exists for this time.",
								success:false
							};
						}
					}
					return {
						errorMessage:"",
						success:true
					};
				}
			}else{
				return {
					errorMessage:"",
					success:true
				};
			}
		}else if(structkeyexists(ss, 'event_id')){
			throw("in memory search not implemented yet");
		}
	}else{
		db=request.zos.queryObject; 
		if(structkeyexists(ss, 'site_x_option_group_set_id')){
			db.sql="SELECT count(site_x_option_group_set_id) count FROM 
			#db.table("site_x_option_group_set_id", request.zos.zcoreDatasource)# WHERE 
			site_id = #db.param(request.zos.globals.id)# and 
			site_x_option_group_set_id = #db.param(arguments.site_x_option_group_set_id)# and 
			site_x_option_group_set_deleted=#db.param(0)# ";
			qSet=db.execute("qSet");
			if(qSet.count EQ 0){
				return {
					errorMessage:"The associated record for this reservation doesn't exist.",
					success:false
				};
			}
		}else if(structkeyexists(ss, 'event_id')){
			throw("Not implemented");
		}else{
			throw("arguments.searchStruct.site_x_option_group_set_id or arguments.searchStruct.event_id is required.");
		}
		db=request.zos.queryObject; 
		db.sql="SELECT count(reservation_id) count FROM 
		#db.table("reservation", request.zos.zcoreDatasource)# reservation
		WHERE ";
		if(structkeyexists(ss, 'site_x_option_group_set_id')){
			db.sql&=" site_x_option_group_set_id = #db.param(arguments.site_x_option_group_set_id)# and ";
		}else if(structkeyexists(ss, 'event_id')){
			db.sql&=" event_id = #db.param(arguments.event_id)# and ";
		}
		db.sql&=" reservation.site_id = #db.param(request.zOS.globals.id)# and 
		reservation.reservation_deleted = #db.param(0)# and ";
		if(ts.reservation_type_period EQ "hourly"){
			db.sql&=" reservation_end_datetime >= #db.param(dateformat(arguments.reservation_start_datetime, 'yyyy-mm-dd')&' '&timeformat(arguments.reservation_start_datetime, "HH:mm:ss"))# and
			reservation_start_datetime <= #db.param(dateformat(arguments.reservation_end_datetime, 'yyyy-mm-dd')&' '&timeformat(arguments.reservation_end_datetime, "HH:mm:ss"))# and ";
		}else{

		}
		db.sql&=" reservation_status = #db.param(1)#";
		qCount=db.execute("qCount");
		if(qCount.count NEQ 0){
			return {
				errorMessage:"A reservation already exists at this time.",
				success:false
			};
		}
	}
	return {
		errorMessage:"",
		success:true
	};
	</cfscript>
</cffunction>


<cffunction name="rebuildMemoryCache" localmode="modern" access="remote">
	<cfscript>
	
	availabilityStruct={
		eventCache:{},
		siteOptionGroupCache:{}
	};
	db.sql="SELECT count(reservation_id) count FROM 
	#db.table("reservation", request.zos.zcoreDatasource)# reservation WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	reservation_status = #db.param(1)# and 
	reservation_deleted = #db.param(0)#";
	qReserve=db.execute("qReserve");
	for(row in qReserve){
		if(not structkeyexists(availabilityStruct.siteOptionGroupCache, row.site_x_option_group_set_id)){
			availabilityStruct.siteOptionGroupCache[row.site_x_option_group_set_id]={};
		}
		if(row.reservation_period EQ "hourly"){
			availabilityStruct.siteOptionGroupCache[row.site_x_option_group_set_id][dateformat(row.reservation_start_datetime, 'yyyy-mm-dd')]={
				startTime:int(timeformat(row.reservation_start_datetime, 'HHmm')),
				endTime:int(timeformat(row.reservation_end_datetime, 'HHmm'))
			};
		}else if(row.reservation_period EQ "event"){

		}
	}
	ds=application.zcore.app.getAppData("reservation");
	ds.availabilityStruct=availabilityStruct;
	</cfscript>
</cffunction>

<cffunction name="validateReservationAgainstReservationType" localmode="modern" access="remote">
	<cfargument name="reservationTypeStruct" type="struct" required="yes">
	<cfargument name="reservationStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject; 

	ts=arguments.reservationTypeStruct;
	rs=arguments.reservationStruct;
	if(ts.reservation_type_period EQ "hourly"){
	}else{
		throw(ts.reservation_type_period&" not implemented");
	}

	</cfscript>
</cffunction>
	

<cffunction name="publicNewReservation" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject; 
	var myForm=structnew(); 
	form.reservation_search=form.reservation_first_name&" "&form.reservation_last_name&" "&form.reservation_email&" "&form.reservation_phone&" "&form.reservation_comments;
	form.reservation_search=application.zcore.functions.zCleanSearchText(form.reservation_search, true);
	if(form.method EQ "insert"){
		form.reservation_created_datetime=request.zos.mysqlnow;
	}
	form.reservation_start_datetime=application.zcore.functions.zGetDateTimeSelect("reservation_start_datetime", "yyyy-mm-dd", "HH:mm:ss");
	form.reservation_end_datetime=application.zcore.functions.zGetDateTimeSelect("reservation_end_datetime", "yyyy-mm-dd", "HH:mm:ss");
	myForm.reservation_period.required=true;
	myForm.reservation_email.required=true;
	myForm.reservation_email.email=true;
	myForm.reservation_last_name.required=true;
	myForm.reservation_start_datetime.required=true;
	myForm.reservation_end_datetime.required=true;
	errors=application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	 
	if(errors){
		application.zcore.status.setStatus(request.zsid, false, form,true);
		application.zcore.functions.zRedirect("/z/reservation/admin/reservation-admin/add?zsid=#request.zsid#");
	}
	if(structkeyexists(form, 'reservation_type_name')){
		typeStruct=getReservationTypeByName(form.reservation_type_name);
	}else if(structkeyexists(form, 'reservation_type_id')){
		typeStruct=getReservationTypeByName(form.reservation_type_name);
	}else{
		throw("A valid active reservation type must be specified using form.reservation_type_name or form.reservation_type_id.");
	}

	form=validateReservationAgainstReservationType(typeStruct, form);

	form.reservation_status=typeStruct.reservation_type_new_reservation_status;
	
	form.reservation_updated_datetime=request.zos.mysqlnow;
	form.site_id=request.zos.globals.id;
	ts=StructNew();
	ts.table="reservation";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	form.reservation_id = application.zcore.functions.zInsert(ts);
	if(form.reservation_id EQ false){
		application.zcore.status.setStatus(request.zsid, "Reservation couldn't be added at this time.",form,true);
		application.zcore.functions.zredirect("/z/reservation/admin/reservation-admin/add?zsid="&request.zsid);
	}else{ 
		application.zcore.status.setStatus(request.zsid, "Reservation added successfully.");
		application.zcore.functions.zredirect("/z/reservation/admin/reservation-admin/index?zsid="&request.zsid);
	}
	</cfscript>
</cffunction>

<cffunction name="getReservationDateRange" localmode="modern" output="no" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	ss=arguments.struct;
	savecontent variable="out"{
		if(ss.reservation_period EQ "event"){
			throw("event date description not implemented");
		}else if(ss.reservation_period EQ "hourly"){
			s=dateformat(ss.reservation_start_datetime, "m/d/yyyy");
			e=dateformat(ss.reservation_end_datetime, "m/d/yyyy");
			echo(timeformat(ss.reservation_start_datetime, "h:mm tt")&" to "&timeformat(ss.reservation_end_datetime, "h:mm tt")&" on "&s);
			if(s NEQ e){
				echo(" through "&e);
			}
		}else{
			s=dateformat(ss.reservation_start_datetime, "m/d/yyyy");
			e=dateformat(ss.reservation_end_datetime, "m/d/yyyy");
			echo(s&" to "&e);
		}
	}
	return out;
	</cfscript>
</cffunction>



<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
	<cfargument name="linkStruct" type="struct" required="yes">
	<cfscript>
	var ts=0;
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
		if(structkeyexists(arguments.linkStruct,"Reservation") EQ false){
			ts=structnew();
			ts.featureName="Reservations";
			ts.link='/z/reservation/admin/reservation-admin/index';
			ts.children=structnew();
			arguments.linkStruct["Reservation"]=ts;
		}
		if(structkeyexists(arguments.linkStruct["reservation"].children,"Manage Reservations") EQ false){
			ts=structnew();
			ts.featureName="Manage Reservations";
			ts.link="/z/reservation/admin/reservation-admin/index";
			arguments.linkStruct["Reservation"].children["Manage Reservations"]=ts;
		}
		if(structkeyexists(arguments.linkStruct["reservation"].children,"Manage Reservation Types") EQ false){
			ts=structnew();
			ts.featureName="Manage Reservation Types";
			ts.link="/z/reservation/admin/reservation-type/index";
			arguments.linkStruct["Reservation"].children["Manage Reservation Types"]=ts;
		}
	}
	return arguments.linkStruct;
	</cfscript>
</cffunction>

<cffunction name="getCacheStruct" localmode="modern" output="no" access="public" returntype="struct" hint="publish the application cache">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfscript>
	var qdata=0;
	var ts=StructNew();
	var qdata=0;
	var arrcolumns=0;
	var i=0;
	var db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("reservation_config", request.zos.zcoreDatasource)# reservation_config 
	where 
	site_id = #db.param(arguments.site_id)# and 
	reservation_config_deleted = #db.param(0)#";
	qData=db.execute("qData");
	for(row in qData){
		return row;
	}
	throw("reservation_config record is missing for site_id=#arguments.site_id#.");
	</cfscript>
</cffunction>


<cffunction name="setURLRewriteStruct" localmode="modern" output="no" access="public" returntype="any" hint="Generate the URL rewrite rules as a string">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	/*
	db.sql="SELECT * FROM #db.table("reservation_config", request.zos.zcoreDatasource)# reservation_config, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site.site_id = app_x_site.site_id and 
	app_x_site.site_id = reservation_config.site_id and 
	reservation_config.site_id = #db.param(arguments.site_id)# and 
	reservation_config_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	site_deleted = #db.param(0)#";
	qConfig=db.execute("qConfig"); 
	loop query="qConfig"{
	}

	*/
	</cfscript>
</cffunction>
	
<cffunction name="updateRewriteRules" localmode="modern" output="no" access="public" returntype="boolean">
	<cfscript>
	application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
	return true;
	</cfscript>
</cffunction>

<cffunction name="configDelete" localmode="modern" output="no" access="public" returntype="any" hint="delete the record from config table.">
	<!--- delete all content and content_group and images? --->
	<cfscript>
	var db=request.zos.queryObject;
	var qconfig=0;
	var rCom=createObject("component","zcorerootmapping.com.zos.return");
	db.sql="DELETE FROM #db.table("reservation_config", request.zos.zcoreDatasource)#  
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	reservation_config_deleted = #db.param(0)#	";
	qConfig=db.execute("qConfig");
	return rCom;
	</cfscript>   
</cffunction>

<cffunction name="loadDefaultConfig" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="validate" required="no" type="boolean" default="#false#">
	<cfscript>
	var field="";
	var i=0;
	var error=false;
	var df=structnew();
	df.reservation_config_confirmation_email_list="1,2,3";
	df.reservation_config_change_email_list="1,2,3";
	df.reservation_config_payment_failure_email_list=1;
	df.reservation_config_destination_on_email=1;
	df.reservation_config_email_reminder_subject='Reservation reminder';
	df.reservation_config_email_reminder_header='This is a friendly reminder regarding your reservation, which is detailed below.';
	df.reservation_config_email_creation_subject='Reservation confirmation email';
	df.reservation_config_email_creation_header='Thanks for making a reservation.  We have received the following information.  If you need to make changes, please use the cancellation link below or contact us.';
	df.reservation_config_email_change_subject='Reservation updated';
	df.reservation_config_email_change_header='We''ve updated your reservation.  The latest details are included below.';
	df.reservation_config_email_cancelled_subject='Reservation cancelled';
	df.reservation_config_email_cancelled_header='Your reservation has been cancelled. The reservation details are included below.';
	df.reservation_config_reminder_days_list="15,7,1";
	df.reservation_config_soonest_reservation_days="1";
	df.reservation_config_furthest_reservation_days="365";
	df.reservation_config_availability_in_memory="0";
	df.reservation_config_new_reservation_status=1;
	for(i in df){	
		if(arguments.validate){
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){	
				error=true;
				field=trim(lcase(replacenocase(replacenocase(i,"reservation_config_",""),"_"," ","ALL")));
				application.zcore.status.setStatus(request.zsid,"#field# is required.",form);
			}
		}else{
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){			
				form[i]=df[i];
			}
		}
	}
	if(error){
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<cffunction name="configSave" localmode="modern" output="no" access="remote" returntype="any" hint="saves the application data submitted by the change() form.">
	<cfscript>
	var ts=StructNew();
	var rCom=CreateObject("component","zcorerootmapping.com.zos.return");
	var result='';
	if(this.loadDefaultConfig(true) EQ false){
		rCom.setError("Please correct the above validation errors and submit again.",1);
		return rCom;
	}	
	form.site_id=form.sid;
	/*
	ts=StructNew();
	ts.arrId=arrayNew(1);
	arrayappend(ts.arrId,trim(form.reservation_config_category_url_id));
	ts.site_id=form.site_id;
	ts.app_id=this.app_id;
	rCom=application.zcore.app.reserveAppUrlId(ts);
	if(rCom.isOK() EQ false){
		return rCom;
		application.zcore.functions.zstatushandler(request.zsid);
		application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=configForm&app_x_site_id=#this.app_x_site_id#&zsid=#request.zsid#");
		application.zcore.functions.zabort();
	}		
	*/
	form.reservation_config_updated_datetime=request.zos.mysqlnow;
	ts.table="reservation_config";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(application.zcore.functions.zso(form, 'reservation_config_id',true) EQ 0){ // insert
		result=application.zcore.functions.zInsert(ts); 
		if(result EQ false){
			rCom.setError("Failed to save configuration.",2);
			return rCom;
		}
	}else{ // update
		result=application.zcore.functions.zUpdate(ts);
		if(result EQ false){
			rCom.setError("Failed to save configuration.",3);
			return rCom;
		}
	}
	application.zcore.status.setStatus(request.zsid,"Configuration saved.");
	return rCom;
	</cfscript>
</cffunction>


<cffunction name="configForm" localmode="modern" output="no" access="remote" returntype="any" hint="displays a form to add/edit applications.">
   	<cfscript>
	var db=request.zos.queryObject;
	var ts='';
	var selectStruct='';
	var rs=structnew();
	var qConfig='';
	var theText='';
	var rCom=createObject("component","zcorerootmapping.com.zos.return");
	savecontent variable="theText"{
		db.sql="SELECT * FROM #db.table("reservation_config", request.zos.zcoreDatasource)# reservation_config 
		WHERE site_id = #db.param(form.sid)# and 
		reservation_config_deleted = #db.param(0)#";
		qConfig=db.execute("qConfig");
		application.zcore.functions.zQueryToStruct(qConfig);//, "configStruct");
		if(qConfig.recordcount EQ 0){
			this.loadDefaultConfig();
		}
		/*

		and the email would auto-display the publicly visible fields at the bottom including the reservation info.
		Email needs to be customer specific.  I.e. for location based reservation, it should have it listed along with google map link to the address.
			store address in the reservation?

			*/
		application.zcore.functions.zStatusHandler(request.zsid,true);
		echo('<input type="hidden" name="reservation_config_id" value="#form.reservation_config_id#" />
		<table style="border-spacing:0px;" class="table-list">
		<tr>
		<th>Email Reminder Days:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_reminder_days_list";
		application.zcore.functions.zInput_Text(ts);
		echo(' (The number of days before a reservation to send an email reminder notification.  Leave blank to disable reminder emails.  You can comma separate multiple values. i.e. 15,7,1)</td>
		</tr>
		<tr>
		<th>Soonest Reservation Allowed:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_soonest_reservation_days";
		application.zcore.functions.zInput_Text(ts);
		echo(' (## of days | 0 is unlimited)</td>
		</tr>
		<tr>
		<th>Furthest Reservation Allowed:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_furthest_reservation_days";
		application.zcore.functions.zInput_Text(ts);
		echo(' (## of days | 0 is unlimited)</td>
		</tr> 
		<tr>
			<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("New Reservation Status","member.reservation_type.edit reservation_type_new_reservation_status")#</th>
			<td>');
				selectStruct = StructNew();
				selectStruct.name = "reservation_config_new_reservation_status";
				selectStruct.hideSelect=true; 
				selectStruct.size=1;
				selectStruct.listLabels="Approved,Pending Approval";
				selectStruct.listValues = "1,0";
				application.zcore.functions.zInputSelectBox(selectStruct);
				echo('</td>
		</tr>
		<tr>
		<th>Reminder Email Subject:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_email_reminder_subject";
		ts.style="width:100%;";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Reminder Email Header:</th>
		<td>');
        htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
        htmlEditor.instanceName	= "reservation_config_email_reminder_header";
        htmlEditor.value			= form.reservation_config_email_reminder_header;
        htmlEditor.width			= "100%";
        htmlEditor.height		= 300;
        htmlEditor.create();
		echo('</td>
		</tr>
		<tr>
		<th>New Reservation Email Subject:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_email_creation_subject";
		ts.style="width:100%;";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>New Reservation Email Header:</th>
		<td>');
        htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
        htmlEditor.instanceName	= "reservation_config_email_creation_header";
        htmlEditor.value			= form.reservation_config_email_creation_header;
        htmlEditor.width			= "100%";
        htmlEditor.height		= 300;
        htmlEditor.create();
		echo('</td>
		</tr>
		<tr>
		<th>Change Email Subject:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_email_change_subject";
		ts.style="width:100%;";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Change Email Header:</th>
		<td>');
        htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
        htmlEditor.instanceName	= "reservation_config_email_change_header";
        htmlEditor.value			= form.reservation_config_email_change_header;
        htmlEditor.width			= "100%";
        htmlEditor.height		= 300;
        htmlEditor.create();
		echo('</td>
		</tr>
		<tr>
		<th>Cancelled Email Subject:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_email_cancelled_subject";
		ts.style="width:100%;";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Cancelled Email Header:</th>
		<td>');
        htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
        htmlEditor.instanceName	= "reservation_config_email_cancelled_header";
        htmlEditor.value			= form.reservation_config_email_cancelled_header;
        htmlEditor.width			= "100%";
        htmlEditor.height		= 300;
        htmlEditor.create();
		echo('</td>
		</tr>
		<tr>
		<th>Show Destination On Email?</th>
		<td>'); 
		ts = StructNew();
		ts.name = "reservation_config_destination_on_email";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' </td>
		</tr>');
		echo('<tr>
		<th>Availability Search In Memory?</th>
		<td>'); 
		ts = StructNew();
		ts.name = "reservation_config_availability_in_memory";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' </td>
		</tr>');
		echo('<tr>
		<th>Reservation Confirmation Email List:</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "reservation_config_confirmation_email_list";
		selectStruct.hideSelect=true;
		selectStruct.multiple=true;
		selectStruct.size=3;
		selectStruct.listLabels="Developer,Administrator,Customer";
		selectStruct.listValues = "1,2,3";
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>');

		echo('<tr>
		<th>Reservation Change Email List:</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "reservation_config_change_email_list";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Developer,Administrator,Customer";
		selectStruct.listValues = "1,2,3";
		selectStruct.multiple=true;
		selectStruct.size=3;
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>');
		echo('<tr>
		<th>Reservation Payment Failure Email List:</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "reservation_config_payment_failure_email_list";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Developer,Administrator";
		selectStruct.listValues = "1,2";
		selectStruct.multiple=true;
		selectStruct.size=3;
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>');
		
		
		echo('
		
		</table>');
	}
	rs.output=theText;
	rCom.setData(rs);
	return rCom;
	</cfscript>
</cffunction>



<cffunction name="onRequestStart" localmode="modern" output="yes" returntype="void">
	<cfscript>
	var db=request.zos.queryObject; 
	</cfscript>
</cffunction>

<cffunction name="onRequestEnd" localmode="modern" output="yes" returntype="void" hint="Runs after zos end file.">
	<cfscript>
	
	</cfscript>
</cffunction>


</cfoutput>
</cfcomponent>