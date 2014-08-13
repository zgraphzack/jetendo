<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var rateCom=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Manage Reservations");
	</cfscript>
	<h2 style="display:inline;">Manage Reservations | </h2>
	<cfscript> 
	application.zcore.functions.zstatushandler(request.zsid);
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	variables.init();
	//application.zcore.functions.zSetPageHelpId("7.4");   
	</cfscript> 
	
	<cfscript>	
	defaultStartDate=now();
	defaultEndDate=dateadd("m", 1, now());
	form.zIndex=application.zcore.functions.zso(form, 'zIndex', true, 1);
	form.startDate=application.zcore.functions.zso(form, 'startDate', false, defaultStartDate);
	form.endDate=application.zcore.functions.zso(form, 'endDate', false, defaultEndDate);
	if(not isdate(form.startDate)){
		form.startDate=defaultStartDate;
	}
	if(not isdate(form.endDate)){
		form.endDate=defaultEndDate;
	}
	db.sql=" SELECT * FROM 
	#request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)# reservation   
	WHERE reservation.site_id = #db.param(request.zOS.globals.id)# and 
	reservation.reservation_deleted = #db.param(0)# and 
	reservation_end_datetime >= #db.param(form.startDate)# and
	reservation_start_datetime <= #db.param(form.endDate)# ";
	qCount=db.execute("qCount");
	db.sql=" SELECT * FROM 
	#request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)# reservation   
	WHERE reservation.site_id = #db.param(request.zOS.globals.id)# and 
	reservation.reservation_deleted = #db.param(0)# and 
	reservation_end_datetime >= #db.param(form.startDate)# and
	reservation_start_datetime <= #db.param(form.endDate)#  
	order by reservation.reservation_start_datetime ASC, reservation.reservation_name ASC
	LIMIT #db.param((form.zIndex-1)*30)#, #db.param(30)#";
	qProp=db.execute("qProp");



	if(qCount.count GT 30){
		// required
		searchStruct = StructNew();
		searchStruct.count = qCount.count;
		searchStruct.index = form.zLogIndex;
		// optional
		searchStruct.url = "/z/reservation/admin/reservation-admin/index";
		searchStruct.buttons = 5;
		searchStruct.perpage = 30;
		searchStruct.indexName= "zIndex";
		// stylesheet overriding
		searchStruct.tableStyle = "table-list tiny";
		searchStruct.linkStyle = "tiny";
		searchStruct.textStyle = "tiny";
		searchStruct.highlightStyle = "highlight tiny";
		
		searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	}else{
		searchNav = "";
	}
	writeoutput(searchNav);
	</cfscript>
	<table class="table-list" style="border-spacing:0px; width:100%;">
		<tr>
			<th>Name</th>
			<th>Date Received</th>
			<th>Start Date</th>
			<th>End Date</th>
			<th>Admin</th>
		</tr>
		<cfscript>
		for(row in qProp){
			echo('<tr ');
			if(row.currentRow MOD 2 EQ 0){
				echo('class="row1"');
			}else{
				echo('class="row2"');
			}
			echo('>
				<td>#row.reservation_first_name# #row.reservation_last_name#</td>
				<td>#dateformat(row.reservation_created_datetime, "m/d/yyyy")# #timeformat(row.reservation_created_datetime, "h:mm tt")#</td>
				<td>');
					echo(application.zcore.app.getAppCFC("reservation").getReservationDateRange(row));
					
			echo('</td><td>
				<a href="/z/reservation/admin/reservation-admin/edit?reservation_id=#row.reservation_id#&amp;return=1">Edit</a> | 
				<a href="/z/reservation/admin/reservation-admin/delete?reservation_id=#row.reservation_id#&amp;return=1">Delete</a></td>
				</tr>');
		}
		</cfscript>
	</table> 
	<cfscript>
	
	writeoutput(searchNav);
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var tempLink=0;
	var qCheck=0;
	var result=0;
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Manage Reservations");
	form.reservation_id=application.zcore.functions.zso(form, 'reservation_id');
	db.sql=" SELECT * FROM #request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)# reservation 
	WHERE reservation_id = #db.param(form.reservation_id)# and 
	site_id = #db.param(request.zOS.globals.id)# ";
	qCheck=db.execute("qCheck");
    if(qCheck.recordcount EQ 0){
        application.zcore.status.setStatus(request.zsid, "Reservation is missing");
        application.zcore.functions.zRedirect("/z/reservation/admin/reservation-admin/index?zsid="&request.zsid);
    }
    </cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
        db.sql="DELETE FROM #request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)#  
		WHERE  reservation_id=#db.param(form.reservation_id)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		result = db.execute("result");  
		application.zcore.functions.zRedirect("/z/reservation/admin/reservation-admin/index?reservation_id="&form.reservation_id&"&zsid="&request.zsid); 
        </cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this Reservation?<br />
			<br />
			Reservation: 
			<cfscript>
			echo(application.zcore.app.getAppCFC("reservation").getReservationDateRange(row));
			</cfscript> for #qcheck.reservation_first_name# #qcheck.reservation_last_name# (#qcheck.reservation_email#)<br />
			<br />
			<a href="/z/reservation/admin/reservation-admin/delete?confirm=1&amp;reservation_id=#form.reservation_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/reservation/admin/reservation-admin/index">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	var myForm=structnew(); 
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Manage Reservations"); 
	if(form.method EQ "update"){
		db.sql=" SELECT * FROM #request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)# reservation 
		WHERE reservation_id = #db.param(form.reservation_id)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Reservation is missing");
			application.zcore.functions.zRedirect("/z/reservation/admin/reservation-admin/index?zsid="&request.zsid);
		}  
	}
	myForm.reservation_email.required=true;
	myForm.reservation_last_name.required=true;
	myForm.reservation_start_datetime.required=true;
	myForm.reservation_end_datetime.required=true;
	errors=application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	 
	if(errors){
		if(form.method EQ 'insert'){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/reservation/admin/reservation-admin/add?zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/reservation/admin/reservation-admin/edit?reservation_id=#form.reservation_id#&zsid=#request.zsid#");
		}
	} 
	form.reservation_updated_datetime=request.zos.mysqlnow;
	form.site_id=request.zos.globals.id;
	ts=StructNew();
	ts.table="reservation";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ "insert"){
		form.reservation_id = application.zcore.functions.zInsert(ts);
		if(form.reservation_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Reservation couldn't be added at this time.",form,true);
			application.zcore.functions.zredirect("/z/reservation/admin/reservation-admin/add?zsid="&request.zsid);
		}else{ 
			application.zcore.status.setStatus(request.zsid, "Reservation added successfully.");
			application.zcore.functions.zredirect("/z/reservation/admin/reservation-admin/index?zsid="&request.zsid);
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Reservation failed to update.",form,true);
			application.zcore.functions.zredirect("/z/reservation/admin/reservation-admin/edit?reservation_id=#form.reservation_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Reservation updated successfully.");
			application.zcore.functions.zredirect("/z/reservation/admin/reservation-admin/index?zsid="&request.zsid);
		}
	}
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>


<!--- zDateTimeSelect(fieldName, selectedDate, firstYear, lastYear, onChange); --->
<cffunction name="zDateTimeSelect" localmode="modern" output="yes" returntype="any">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="selectedDate" type="string" required="no">
	<cfscript>
	throw("zDateTimeSelect not implemented");
	</cfscript>
</cffunction>
	

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	var currentMethod=form.method;
	variables.init();
	//application.zcore.functions.zSetPageHelpId("7.5");
	form.reservation_id=application.zcore.functions.zso(form, 'reservation_id',true);
	db.sql=" SELECT * FROM #request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)# reservation 
	WHERE reservation_id = #db.param(form.reservation_id)# and 
	site_id = #db.param(request.zOS.globals.id)# ";
	qData=db.execute("qData");
	application.zcore.functions.zQueryToStruct(qData,form,'reservation_id,site_id'); 
	application.zcore.functions.zStatusHandler(request.zsid, true,true);
	</cfscript>
	<h2>
		<cfif currentMethod EQ "edit">
			Edit
		<cfelse>
			Add
			<cfscript>
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
			</cfscript>
		</cfif>
		Reservation</h2>
	<form name="myForm" id="myForm" action="/z/reservation/admin/reservation-admin/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?reservation_id=#form.reservation_id#" method="post">
		<cfscript>
		tabCom=createobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.setTabs(["Basic","Advanced"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-reservation-admin-edit");
		cancelURL="/z/reservation/admin/reservation-admin/index";
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Start Date","member.reservation.edit reservation_start_datetime")#</th>
				<td class="table-white">#zDateTimeSelect("reservation_start_datetime", "reservation_start_datetime", "2000", year(dateadd("y", 5, now())))#</td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("End Date","member.reservation.edit reservation_end_datetime")#</th>
				<td class="table-white">#zDateTimeSelect("reservation_end_datetime", "reservation_end_datetime", "2000", year(dateadd("y", 5, now())))#</td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("First Name","member.reservation.edit reservation_first_name")#</th>
				<td class="table-white"><input name="reservation_first_name" size="50" type="text" value="#form.reservation_first_name#" maxlength="50" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Last Name","member.reservation.edit reservation_last_name")#</th>
				<td class="table-white"><input name="reservation_last_name" size="50" type="text" value="#form.reservation_last_name#" maxlength="50" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Email","member.reservation.edit reservation_email")#</th>
				<td class="table-white"><input name="reservation_email" size="50" type="text" value="#form.reservation_email#" maxlength="100" /></td>
			</tr> 
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Phone","member.reservation.edit reservation_phone")#</th>
				<td class="table-white"><input name="reservation_phone" size="50" type="text" value="#form.reservation_phone#" maxlength="100" /></td>
			</tr> 
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Company","member.reservation.edit reservation_company")#</th>
				<td class="table-white"><input name="reservation_company" size="50" type="text" value="#form.reservation_company#" maxlength="100" /></td>
			</tr> 
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination Title","member.reservation.edit reservation_destination_title")#</th>
				<td class="table-white"><input name="reservation_destination_title" size="50" type="text" value="#form.reservation_destination_title#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination URL","member.reservation.edit reservation_destination_url")#</th>
				<td class="table-white"><input name="reservation_destination_url" size="50" type="text" value="#form.reservation_destination_url#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination Address","member.reservation.edit reservation_destination_address")#</th>
				<td class="table-white"><input name="reservation_destination_address" size="50" type="text" value="#form.reservation_destination_address#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination Address 2","member.reservation.edit reservation_destination_address2")#</th>
				<td class="table-white"><input name="reservation_destination_address2" size="50" type="text" value="#form.reservation_destination_address2#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination City","member.reservation.edit reservation_destination_city")#</th>
				<td class="table-white"><input name="reservation_destination_city" size="50" type="text" value="#form.reservation_destination_city#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination Address","member.reservation.edit reservation_destination_state")#</th>
				<td class="table-white">#application.zcore.functions.zStateSelect("reservation_destination_state", form.reservation_destination_state)#</td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination Zip","member.reservation.edit reservation_destination_zip")#</th>
				<td class="table-white"><input name="reservation_destination_zip" size="50" type="text" value="#form.reservation_destination_zip#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination Country","member.reservation.edit reservation_destination_country")#</th>
				<td class="table-white">#application.zcore.functions.zCountrySelect("reservation_destination_country", form.reservation_destination_country)#</td>
			</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Advanced")#
		#tabCom.endFieldSet()#
		#tabCom.endTabMenu()#
	</form>
</cffunction>
</cfoutput>
</cfcomponent>
