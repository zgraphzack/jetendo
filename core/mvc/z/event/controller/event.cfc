<cfcomponent>
<cfoutput>
<cfscript>
this.app_id=17;
</cfscript>
<!--- 
event and recurring event must work.
	Must be able to reserve for a specific occurence of the recurring event.
event
	event_id
	site_id
	event_reservation_enabled char(1) 0
	event_status
	site_option_app_id
	event_updated_datetime
	event_deleted

event_recur
	event_recur_id
	event_id
	event_recur_datetime
	event_recur_updated_datetime
	event_recur_deleted
	site_id
event_category
	event_category_id
	site_id
	event_category_updated_datetime
	event_category_deleted
event_x_category
	event_x_category_id
	event_id
	event_category_id
	site_id
	event_x_category_updated_datetime
	event_x_category_deleted




in server manager, need event application - it should have option to adjust recurring event projection X days per site, which also prevents reservation of dates beyond that.
	New scheduled task reads all recurring events, and projects them from event_last_projected_datetime to dateadd("d", x, now());
	Also run this when a recurring event is updated.
	When recur is disabled, make sure to delete all recurring entries.

Cancel an event that has reservations attached.  It should be able to cancel all the reservations in one step.


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



<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
	<cfargument name="linkStruct" type="struct" required="yes">
	<cfscript>
	var ts=0;
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
		if(structkeyexists(arguments.linkStruct,"event") EQ false){
			ts=structnew();
			ts.featureName="Events";
			ts.link='/z/event/admin/event-admin/index';
			ts.children=structnew();
			arguments.linkStruct["event"]=ts;
		}
		if(structkeyexists(arguments.linkStruct["event"].children,"Manage Events") EQ false){
			ts=structnew();
			ts.featureName="Manage Events";
			ts.link="/z/event/admin/event-admin/index";
			arguments.linkStruct["event"].children["Manage Events"]=ts;
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
	db.sql="SELECT * FROM #db.table("event_config", request.zos.zcoreDatasource)# event_config 
	where 
	site_id = #db.param(arguments.site_id)# and 
	event_config_deleted = #db.param(0)#";
	qData=db.execute("qData");
	for(row in qData){
		return row;
	}
	throw("event_config record is missing for site_id=#arguments.site_id#.");
	</cfscript>
</cffunction>


<cffunction name="setURLRewriteStruct" localmode="modern" output="no" access="public" returntype="any" hint="Generate the URL rewrite rules as a string">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var theText="";
	var qconfig=0;
	var t9=0;
	var qcontent=0;
	var link=0;
	var t999=0;
	var pos=0;
	db.sql="SELECT * FROM #db.table("event_config", request.zos.zcoreDatasource)# event_config, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site.site_id = app_x_site.site_id and 
	app_x_site.site_id = event_config.site_id and 
	event_config.site_id = #db.param(arguments.site_id)# and 
	event_config_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	site_deleted = #db.param(0)#";
	qConfig=db.execute("qConfig"); 
	/*
	loop query="qConfig"{
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_url_article_id]=[];
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_url_section_id]=[];
		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/content/content/viewPage";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/content/content/viewPage";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="content_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_url_article_id],t9);
		if(qConfig.event_config_url_listing_user_id NEQ 0 and qConfig.event_config_url_listing_user_id NEQ ""){
			arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_url_listing_user_id]=arraynew(1);
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/listing/agent-listings/index";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/listing/agent-listings/index";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			t9.mapStruct.dataId="content_listing_user_id";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_url_listing_user_id],t9);
		}
		t999=application.zcore.functions.zvar('contenturlid',qConfig.site_id);
		if(t999 NEQ 0 and t999 NEQ ''){
			arguments.sharedStruct.reservedAppUrlIdStruct[t999]=arraynew(1);
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/content/content/viewPage";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/content/content/viewPage";
			t9.mapStruct=structnew();
			t9.mapStruct.entireURL="content_unique_name";
			t9.mapStruct.urlTitle="zURLName";
			t9.mapStruct.dataId="content_listing_user_id";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[t999],t9);
			
		}
	}

	t9=structnew();
	t9.type=1;
	t9.scriptName="/z/content/content/displayContentSection";
	t9.ifStruct=structnew();
	t9.ifStruct.ext="html";
	t9.urlStruct=structnew();
	t9.urlStruct[request.zos.urlRoutingParameter]="/z/content/content/displayContentSection";
	t9.mapStruct=structnew();
	t9.mapStruct.urlTitle="zURLName";
	t9.mapStruct.dataId="site_x_option_group_set_id";
	arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_url_section_id],t9);

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
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	db.sql="DELETE FROM #db.table("event_config", request.zos.zcoreDatasource)#  
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	event_config_deleted = #db.param(0)#	";
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

	df.event_config_sandbox_enabled=0;
	df.event_config_order_confirmation_email_list="1,2,3";
	df.event_config_order_change_email_list="1,2,3";
	df.event_config_paypal_ipn_failure_email_list=1;
	for(i in df){	
		if(arguments.validate){
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){	
				error=true;
				field=trim(lcase(replacenocase(replacenocase(i,"event_config_",""),"_"," ","ALL")));
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
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	var result='';
	if(this.loadDefaultConfig(true) EQ false){
		rCom.setError("Please correct the above validation errors and submit again.",1);
		return rCom;
	}	
	form.site_id=form.sid;
	/*
	ts=StructNew();
	ts.arrId=arrayNew(1);
	arrayappend(ts.arrId,trim(form.event_config_category_url_id));
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
	form.event_config_updated_datetime=request.zos.mysqlnow;
	ts.table="event_config";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(application.zcore.functions.zso(form, 'event_config_id',true) EQ 0){ // insert
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
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	savecontent variable="theText"{
		db.sql="SELECT * FROM #db.table("event_config", request.zos.zcoreDatasource)# event_config 
		WHERE site_id = #db.param(form.sid)# and 
		event_config_deleted = #db.param(0)#";
		qConfig=db.execute("qConfig");
		application.zcore.functions.zQueryToStruct(qConfig);//, "configStruct");
		if(qConfig.recordcount EQ 0){
			this.loadDefaultConfig();
		}
		/*
event_config
	event_config_id
	event_config_schedule_ical_import char(1) 0 // 1 will auto-import each day and enable manager menu link for manual sync.
	event_config_ical_url_list  TEXT comma separated ical urls.
	event_config_project_recurrence_days X days
	event_config_updated_datetime
	event_config_deleted
	site_id
			*/
		application.zcore.functions.zStatusHandler(request.zsid,true);
		echo('<input type="hidden" name="event_config_id" value="#form.event_config_id#" />
		<table style="border-spacing:0px;" class="table-list">
		<tr>
		<th>Paypal Merchant ID:</th>
		<td>');
		ts = StructNew();
		ts.name = "event_config_paypal_merchant_id";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Sandbox Enabled?</th>
		<td>');
		form.event_config_sandbox_enabled=application.zcore.functions.zso(form, 'event_config_sandbox_enabled',true);
		ts = StructNew();
		ts.name = "event_config_sandbox_enabled";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' (Yes, will disable real money transactions.)</td>
		</tr>');
		echo('<tr>
		<th>Order Confirmation Email List:</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "event_config_order_confirmation_email_list";
		selectStruct.hideSelect=true;
		selectStruct.multiple=true;
		selectStruct.size=3;
		selectStruct.listLabels="Developer,Administrator,Customer";
		selectStruct.listValues = "1,2,3";
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>');

		echo('<tr>
		<th>Order Change Email List:</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "event_config_order_change_email_list";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Developer,Administrator,Customer";
		selectStruct.listValues = "1,2,3";
		selectStruct.multiple=true;
		selectStruct.size=3;
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>');

		echo('<tr>
		<th>Paypal IPN Failure Email List:</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "event_config_paypal_ipn_failure_email_list";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Developer,Administrator";
		selectStruct.listValues = "1,2";
		selectStruct.multiple=true;
		selectStruct.size=2;
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>');
		
		
		
		/*
		<tr>
		<th>Category URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("event_config_category_url_id", form.event_config_category_url_id, this.app_id));
		echo('</td>
		</tr>
		<tr>
		<th>Sidebar Tag</th>
		<td>');
		ts=StructNew();
		ts.label="";
		ts.name="event_config_sidebar_tag";
		ts.size="20";
		application.zcore.functions.zInput_Text(ts);
		echo(' (i.e. type "sidebar" for &lt;z_sidebar&gt;)</td>
		</tr>
		
		<tr>
		<th>Default Parent Page<br />Link Layout</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "event_config_default_parentpage_link_layout";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Invisible,Top with numbered columns,Top with columns,Top on one line";//,Bottom with summary (default),Bottom without summary,Left Sidebar,Right Sidebar";
		selectStruct.listValues = "7,2,3,4";//,0,1,5,6";
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>
		<tr>
		<th>Section Title Affix:</th>
		<td>');
		ts = StructNew();
		ts.name = "event_config_section_title_affix";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>*/
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