<cfcomponent>
<cfoutput>


<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Manage Events", true);	
	db.sql="SELECT * FROM #db.table("event", request.zos.zcoreDatasource)# event
	WHERE event_id= #db.param(application.zcore.functions.zso(form,'event_id'))# and 
	event_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Event no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/event/admin/manage-events/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript> 
		application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.event_image_library_id);

		db.sql="DELETE FROM #db.table("event_x_category", request.zos.zcoreDatasource)#  
		WHERE event_id= #db.param(application.zcore.functions.zso(form, 'event_id'))# and 
		event_x_category_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");

		application.zcore.functions.zDeleteUniqueRewriteRule(qCheck.event_unique_url);

		db.sql="DELETE FROM #db.table("event", request.zos.zcoreDatasource)#  
		WHERE event_id= #db.param(application.zcore.functions.zso(form, 'event_id'))# and 
		event_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");



		application.zcore.status.setStatus(Request.zsid, 'Event deleted');
		application.zcore.functions.zRedirect('/z/event/admin/manage-events/index?zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this Event?<br />
			<br />
			#qCheck.event_name#<br />
			<br />
			<a href="/z/event/admin/manage-events/delete?confirm=1&amp;event_id=#form.event_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/event/admin/manage-events/index">No</a> 
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	var ts={};
	var result=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Manage Events", true);	
	form.site_id = request.zos.globals.id;
	ts.event_name.required = true;
	ts.event_start_datetime_date.required = true;
	ts.event_end_datetime_date.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);


	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/event/admin/manage-events/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/event/admin/manage-events/edit?event_id=#form.event_id#&zsid=#request.zsid#');
		}
	}

	if(form.event_uid EQ ""){
		form.event_uid=createuuid();
	}


	if(form.event_start_datetime_date NEQ "" and isdate(form.event_start_datetime_date)){
		form.event_start_datetime=dateformat(form.event_start_datetime_date, 'yyyy-mm-dd');
	}
	if(form.event_start_datetime_time NEQ "" and isdate(form.event_start_datetime_time)){
		form.event_start_datetime=form.event_start_datetime&" "&dateformat(form.event_start_datetime_time, 'HH:mm:ss');
	}
	if(form.event_end_datetime_date NEQ "" and isdate(form.event_end_datetime_date)){
		form.event_end_datetime=dateformat(form.event_end_datetime_date, 'yyyy-mm-dd');
	}
	if(form.event_end_datetime_time NEQ "" and isdate(form.event_end_datetime_time)){
		form.event_end_datetime=form.event_end_datetime&" "&dateformat(form.event_end_datetime_time, 'HH:mm:ss');
	} 
	if(form.method EQ 'insert'){
		form.event_created_datetime=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	}
	form.event_updated_datetime=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
 


	uniqueChanged=false;
	oldURL='';
	if(form.method EQ 'insert' and application.zcore.functions.zso(form, 'event_unique_url') NEQ ""){
		uniqueChanged=true;
	}
	if(form.method EQ 'update'){
		db.sql="SELECT * FROM #db.table("event", request.zos.zcoreDatasource)# 
		WHERE event_id = #db.param(form.event_id)# and 
		event_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this event.',form,true);
			application.zcore.functions.zRedirect('/z/event/admin/manage-events/index?zsid=#request.zsid#');
		}
		oldURL=qCheck.event_unique_url;
		if(structkeyexists(form, 'event_unique_url') and qcheck.event_unique_url NEQ form.event_unique_url){
			uniqueChanged=true;	
		}
	}

	ts=StructNew();
	ts.table='event';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.event_id = application.zcore.functions.zInsert(ts);
		if(form.event_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save Event.',form,true);
			application.zcore.functions.zRedirect('/z/event/admin/manage-events/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Event saved.');
		}

	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save Event.',form,true);
			application.zcore.functions.zRedirect('/z/event/admin/manage-events/edit?event_id=#form.event_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Event updated.');
		}
		
	} 

	application.zcore.siteOptionCom.activateOptionAppId(application.zcore.functions.zso(form, 'site_option_app_id'));
	application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'event_image_library_id'));

	if(uniqueChanged){
		application.zcore.app.getAppCFC("event").updateRewriteRuleEvent(form.event_id, oldURL);	
	}
	application.zcore.app.getAppCFC("event").searchReindexEvent(form.event_id, false);

	application.zcore.functions.zRedirect('/z/event/admin/manage-events/index?zsid=#request.zsid#');
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript> 
	var db=request.zos.queryObject; 
	var currentMethod=form.method;
	var htmlEditor=0;
	application.zcore.functions.zSetPageHelpId("10.2");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Events");	
	if(application.zcore.functions.zso(form,'event_id') EQ ''){
		form.event_id = -1;
	}
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}
	db.sql="SELECT * FROM #db.table("event", request.zos.zcoreDatasource)# event 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	event_deleted = #db.param(0)# and 
	event_id=#db.param(form.event_id)#";
	qEvent=db.execute("qEvent");
	application.zcore.functions.zQueryToStruct(qEvent);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	application.zcore.functions.zRequireJqueryUI();
	</cfscript>
	<h2>
		<cfif currentMethod EQ "add">
			Add
			<cfscript>
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
			</cfscript>
		<cfelse>
			Edit
		</cfif> Event</h2>
	<form action="/z/event/admin/manage-events/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?event_id=#form.event_id#" method="post">
		<input name="event_uid" type="hidden" value="#htmleditformat(application.zcore.functions.zso(form, 'event_uid'))#" />
		<table style="width:100%;" class="table-list">  
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button></td>
			</tr>
			<tr>
				<th>Calendar</th>
				<td>
					<cfscript>
					db.sql="select * from #db.table("event_calendar", request.zos.zcoreDatasource)# WHERE 
					site_id = #db.param(request.zos.globals.id)# and 
					event_calendar_deleted=#db.param(0)# 
					ORDER BY event_calendar_name ASC";
					qCalendar=db.execute("qCalendar"); 
					ts = StructNew();
					ts.name = "event_calendar_id"; 
					ts.size = 1; 
					ts.multiple = true; 
					ts.query = qCalendar;
					ts.queryLabelField = "event_calendar_name";
					ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
					ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
					ts.queryValueField = "event_calendar_id"; 
					application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'event_calendar_id', true, 0));
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript>
				</td>
			</tr>  
			<tr>
				<th>Name</th>
				<td><input type="text" name="event_name" style="width:500px;" value="#htmleditformat(form.event_name)#" /></td>
			</tr>  
			<tr>
				<th>Category</th>
				<td>
					<cfscript>
					db.sql="select * from #db.table("event_category", request.zos.zcoreDatasource)# WHERE 
					site_id = #db.param(request.zos.globals.id)# and 
					event_category_deleted=#db.param(0)# 
					ORDER BY event_category_name ASC";
					qCategory=db.execute("qCategory");

					ts = StructNew();
					ts.name = "event_category_id"; 
					ts.size = 1; 
					ts.multiple = true; 
					ts.query = qCategory;
					ts.queryLabelField = "event_category_name";
					ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
					ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
					ts.queryValueField = "event_category_id"; 
					application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'event_category_id', true, 0));
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript>
				</td>
			</tr>  
			<tr>
				<th>Body Text</th>
				<td>
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "event_description";
					htmlEditor.value			= form.event_description;
					htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
					htmlEditor.height		= 350;
					htmlEditor.create();
					</cfscript>   
				</td>
			</tr> 
			<cfscript>

			onChangeJavascript='';
			application.zcore.functions.zRequireTimePicker();  
			application.zcore.skin.addDeferredScript('  
				$("##event_start_datetime_time").timePicker({
					show24Hours: false,
					step: 15
				});
				$("##event_end_datetime_time").timePicker({
					show24Hours: false,
					step: 15
				});
				$( "##event_start_datetime_date" ).datepicker();
				$( "##event_end_datetime_date" ).datepicker();
			'); 
			</cfscript>
			<tr>
				<th>Start Date</th>
				<td>
					<input type="text" name="event_start_datetime_date" onchange="#onChangeJavascript#" onkeyup="#onChangeJavascript#" onpaste="#onChangeJavascript#" id="event_start_datetime_date" value="#htmleditformat(dateformat(form.event_start_datetime, 'mm/dd/yyyy'))#" size="9" />
					<input type="text" name="event_start_datetime_time" id="event_start_datetime_time" value="#htmleditformat(timeformat(form.event_start_datetime, 'HH:mm:ss'))#" size="9" />
					 </td>
			</tr> 

			<tr>
				<th>End Date</th>
				<td><input type="text" name="event_end_datetime_date" onchange="#onChangeJavascript#" onkeyup="#onChangeJavascript#" onpaste="#onChangeJavascript#" id="event_end_datetime_date" value="#htmleditformat(dateformat(form.event_end_datetime, 'mm/dd/yyyy'))#" size="9" />
					<input type="text" name="event_end_datetime_time" id="event_end_datetime_time" value="#htmleditformat(timeformat(form.event_end_datetime, 'HH:mm:ss'))#" size="9" />
				</td>
			</tr>  
			<tr>
				<th>All Day Event?</th>
				<td>#application.zcore.functions.zInput_Boolean("event_allday")# (Yes, will hide the start/end times)</td>
			</tr> 

			<tr>
				<th>Timezone</th>
				<td><input type="text" name="event_timezone" value="#htmleditformat(form.event_timezone)#" /></td>
			</tr> 
			<tr>
				<th>Location Name</th>
				<td><input type="text" name="event_location" style="width:500px;" value="#htmleditformat(form.event_location)#" /></td>
			</tr> 
			<tr>
				<th>Address</th>
				<td><input type="text" name="event_address" style="width:500px;" value="#htmleditformat(form.event_address)#" /></td>
			</tr> 
			<tr>
				<th>Address 2</th>
				<td><input type="text" name="event_address2" style="width:500px;" value="#htmleditformat(form.event_address2)#" /></td>
			</tr> 
			<tr>
				<th>City</th>
				<td><input type="text" name="event_city" style="width:500px;" value="#htmleditformat(form.event_city)#" /></td>
			</tr> 
			<tr>
				<th>State</th>
				<td>#application.zcore.functions.zStateSelect("event_state", application.zcore.functions.zso(form, 'event_state'))#</td>
			</tr> 
			<tr>
				<th>Country</th>
				<td>#application.zcore.functions.zCountrySelect("event_country", application.zcore.functions.zso(form, 'event_country'))#</td>
			</tr> 
			<tr>
				<th>Zip/Postal Code</th>
				<td><input type="text" name="event_zip" value="#htmleditformat(form.event_zip)#" /></td>
			</tr> 
			<tr>
				<th>Web Site URL</th>
				<td><input type="text" name="event_website" style="width:500px;" value="#htmleditformat(form.event_website)#" /></td>
			</tr> 
			<tr>
				<th>File 1</th>
				<td><cfscript>
					ts={
						name:"event_file1"
					};
					application.zcore.functions.zInput_File(ts);
					</cfscript></td>
			</tr> 
			<tr>
				<th>File 1 Label</th>
				<td><input type="text" name="event_file1label" style="width:500px;" value="#htmleditformat(form.event_file1label)#" /></td>
			</tr> 
			<tr>
				<th>File 2</th>
				<td><cfscript>
					ts={
						name:"event_file2"
					};
					application.zcore.functions.zInput_File(ts);
					</cfscript></td>
			</tr> 
			<tr>
				<th>File 2 Label</th>
				<td><input type="text" name="event_file2label" style="width:500px;" value="#htmleditformat(form.event_file2label)#" /></td>
			</tr> 
			<tr>
				<th>Featured Event</th>
				<td>#application.zcore.functions.zInput_Boolean("event_featured", application.zcore.functions.zso(form, 'event_featured'))#</td>
			</tr>  
			<tr>
				<th>Recurring Event</th>
				<td><a href="##" onclick="openRecurringEventOptions(); return false;">Edit</a> | Show Config Here
				<input type="hidden" name="event_recur_ical_rules" id="event_recur_ical_rules" value="#htmleditformat(form.event_recur_ical_rules)#" />
				</td>
			</tr> 
			<!--- 
fileName=application.zcore.functions.zUploadFile("filepath", request.zos.globals.privateHomedir&"zupload/user/");
			 --->
			<!--- 
			http://www.farbeyondcode.com.127.0.0.2.xip.io/z/event/admin/recurring-event/index?event_start_datetime=04/30/2015%20&event_end_datetime=06/17/2015%20&event_recur_ical_rules=&ztv=0.33506121183745563
			 --->
			<script type="text/javascript">
			function openRecurringEventOptions(){
				var startDate=$("##event_start_datetime_date").val();
				var startTime=$("##event_start_datetime_time").val();
				var endDate=$("##event_end_datetime_date").val();
				var endTime=$("##event_end_datetime_time").val();
				var rules=$("##event_recur_ical_rules").val();
				var d={
					"event_start_datetime": startDate+" "+startTime,
					"event_end_datetime": endDate+" "+endTime, 
					"event_recur_ical_rules": rules
				};
				var a=[];
				for(var i in d){
					a.push(i+"="+d[i]);
				}
				zShowModalStandard('/z/event/admin/recurring-event/index?'+a.join("&"), zWindowSize.width-100, zWindowSize.height-100);

			}
			</script>
			<tr>
				<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Photos","member.event.edit event_image_library_id")#</th>
				<td>
					<cfscript>
					ts=structnew();
					ts.name="event_image_library_id";
					ts.value=form.event_image_library_id;
					application.zcore.imageLibraryCom.getLibraryForm(ts);
					</cfscript>
				</td>
			</tr>

			<tr>
				<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Photo Layout","member.event.edit event_image_library_layout")#</th>
				<td>
					<cfscript>
					ts=structnew();
					ts.name="event_image_library_layout";
					ts.value=form.event_image_library_layout;
					application.zcore.imageLibraryCom.getLayoutTypeForm(ts);
					</cfscript>
				</td>
			</tr>
			<tr>
				<th>Unique URL</th>
				<td><input type="text" name="event_unique_url" value="#htmleditformat(form.event_unique_url)#" /></td>
			</tr> 

			<!---          
event_recur_ical_rules      varchar(255)      utf8_general_ci  NO              (NULL)           select,insert,update,references        
event_recur_until_datetime  datetime          (NULL)           NO              (NULL)           select,insert,update,references           
event_recur_count           int(11) unsigned  (NULL)           NO              0                select,insert,update,references           
event_recur_interval        int(11) unsigned  (NULL)           NO              0                select,insert,update,references           
event_recur_frequency       varchar(15)       utf8_general_ci  NO              (NULL)           select,insert,update,references    
event_excluded_date_list
 
          
event_generated - what is this?
event_reservation_enabled - not needed yet.
event_status - what is this?
 
Map Coordinates	Map Location Picker  
			 --->
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;

 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Manage Events");
	application.zcore.functions.zSetPageHelpId("10.1");
	db.sql="select * from #db.table("event", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	event_deleted=#db.param(0)# ";
	qList=db.execute("qList");

	
	eventCom=application.zcore.app.getAppCFC("event");
	eventCom.getAdminNavMenu();
	</cfscript>
	<h2>Manage Events</h2>

	<p><a href="/z/event/admin/manage-events/add">Add Event</a></p>

	<table class="table-list">
		<tr>
			<th>Name</th>
			<th>Admin</th>
		</tr>
		<cfscript>
		for(row in qList){
			echo('<tr>
				<td>#row.event_name#</td>
				<td>
					<a href="#eventCom.getEventURL(row)#" target="_blank">View</a> | 
					<a href="/z/event/admin/manage-events/edit?event_id=#row.event_id#&amp;modalpopforced=1" onclick="zTableRecordEdit(this);  return false;">Edit</a> | 
					<a href="##" onclick="zDeleteTableRecordRow(this, ''/z/event/admin/manage-events/delete?event_id=#row.event_id#&amp;returnJson=1&amp;confirm=1''); return false;">Delete</a>
				</td>
			</tr>');

		}
		</cfscript>  
	</table>
</cffunction>
</cfoutput>
</cfcomponent>