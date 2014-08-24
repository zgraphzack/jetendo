<cfcomponent>
<cfoutput>
<!--- 
integrate with namecheap api: https://www.namecheap.com/support/api/methods/ssl/renew.aspx
easier ssl renewal

It is possible to automate all steps of SSL certificates except for clicking the email link to approve the certificate.

generate key and csr, place order, retrieve certificate, install certificate in web server.

with every customer on SSL, it would be important to do this.

https://www.namecheap.com/support/api/methods/ssl.aspx

I'm building the visual Jetendo SSL management features right now.   It will be impossible to view / read the private key from the application, which will make it more secure.   Later it would automate installation to multiple servers.

If Zgraph made an effort to ensure we have a forwarding email address at every customer's domain, it would simplify the approval step.    For example,  webmaster@client.com forwarding to ssl@zgraph.com.

I will automate the steps of detecting upcoming expirations, SSL installation errors (non matching certificate due to duplicate IP / wrong server configuration), and create email alerts for different things.



	

 --->
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript> 
	if(structkeyexists(form, 'zid') EQ false){
		form.zid = application.zcore.status.getNewId();
		if(structkeyexists(form, 'sid')){
			application.zcore.status.setField(form.zid, 'site_id', form.sid);
		}
	}
	form.ssl_id=application.zcore.functions.zso(form, 'ssl_id');
	form.sid = application.zcore.status.getField(form.zid, 'site_id');
	</cfscript>
</cffunction>


<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0;
	init();
	form.site_id=form.sid;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	db.sql="SELECT * FROM #db.table("ssl", request.zos.zcoreDatasource)# `ssl`
	WHERE ssl_id= #db.param(application.zcore.functions.zso(form,'ssl_id'))# and 
	ssl_deleted = #db.param(0)# and
	site_id = #db.param(form.site_id)#";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'SSL Certificate no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/admin/ssl/index?sid=#form.site_id#&zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		result=application.zcore.functions.zSecureCommand("sslDeleteCertificate"&chr(9)&qCheck.ssl_hash, 50);
		if(result == ""){
			application.zcore.status.setStatus(request.zsid, "Failed to delete SSL Certificate files.", form, true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/ssl/index?sid=#form.sid#&zsid=#request.zsid#');
		}else{
			js=deserializeJson(result);
			if(not js.success){
				application.zcore.status.setStatus(request.zsid, "Failed to delete SSL Certificate files: "&js.errorMessage, form, true);
				application.zcore.functions.zRedirect('/z/server-manager/admin/ssl/index?sid=#form.sid#&zsid=#request.zsid#');
			}
		}

		form.ssl_deleted=0;
		application.zcore.functions.zDeleteRecord("ssl", "ssl_id,site_id,ssl_deleted", request.zos.zcoreDatasource);
		application.zcore.status.setStatus(Request.zsid, 'SSL Certificate deleted');
		result=application.zcore.functions.zSecureCommand("publishNginxSiteConfig"&chr(9)&form.site_id, 30);
		if(result EQ false){
			application.zcore.status.setStatus(request.zsid, "Invalid Nginx configuration after publishing SSL Certificate - The previous Nginx configuration was restored.", form, true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/ssl/index?sid=#form.sid#&zsid=#request.zsid#');
		}

		application.zcore.functions.zRedirect('/z/server-manager/admin/ssl/index?sid=#form.sid#&zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this SSL Certificate?<br />
			<br />
			Display name: #qCheck.ssl_display_name#<br />
			Common name: #qCheck.ssl_common_name#
			<br />
			<a href="/z/server-manager/admin/ssl/delete?confirm=1&amp;ssl_id=#form.ssl_id#&amp;sid=#form.sid#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/server-manager/admin/ssl/index?sid=#form.sid#">No</a> 
		</div>
	</cfif>
</cffunction>

<cffunction name="insertExisting" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	update();
	</cfscript>
</cffunction>
	
<cffunction name="update" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qSite=0;
	var qGlobal=0;
	var qRule=0;
	var fileexisted=0;
	var ts=0;
	var newContents=0;
	var newZSARules=0;
	var arrRules=0;
	var configCom=0;
	var qApps=0;
	var i=0;
	var tempfile=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	init();
	form.site_id=form.sid;

	form.ssl_updated_datetime=request.zos.mysqlnow;
	if(form.method EQ "insert" or form.method EQ "insertExisting"){
		form.ssl_created_datetime=request.zos.mysqlnow;
		form.ssl_hash=hash(application.zcore.functions.zGenerateStrongPassword(80,200), "sha-256");
	}else{
		db.sql="SELECT * FROM #db.table("ssl", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(form.sid)# and 
		ssl_deleted = #db.param(0)# ";
		qSSL=db.execute("qSSL");
		if(qSSL.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid SSL Certificate", form, true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/index?sid=#form.sid#&zsid="&request.zsid);
		}
		for(row in qSSL){
			form.ssl_hash=row.ssl_hash;
			if(row.ssl_public_key NEQ ""){
				application.zcore.status.setStatus(request.zsid, "SSL Certificate already activated. You must create a new SSL Certificate to replace this one.", form, true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/index?sid=#form.sid#&zsid="&request.zsid);
			}
		}
	}
	if(form.method EQ "insertExisting"){
		form.ssl_active=0;
		myform={};
		myform.ssl_display_name.required=true;
		myform.ssl_private_key.required=true;
		myform.ssl_public_key.required=true;
		myform.ssl_ca_certificate.required=true;
		errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
		if(errors){
			application.zcore.status.setStatus(request.zsid, "Failed to Install SSL Certificate.", form, true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/addExisting?sid=#form.sid#&zsid="&request.zsid);
		}
		js={
			ssl_private_key: form.ssl_private_key,
			ssl_public_key: form.ssl_public_key,
			ssl_intermediate_certificate: form.ssl_intermediate_certificate,
			ssl_ca_certificate: form.ssl_ca_certificate,
			ssl_hash:form.ssl_hash,
			site_id:form.site_id
		};
		jsonOutput=serializeJson(js);
		
		result=application.zcore.functions.zSecureCommand("sslInstallCertificate"&chr(9)&jsonOutput, 50);
		if(result EQ ""){
			application.zcore.status.setStatus(request.zsid, "Install SSL Certificate command failed.", form, true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/addExisting?sid=#form.sid#&zsid="&request.zsid);
		}else{
			resultStruct=deserializeJson(result);
			if(not resultStruct.success){
				application.zcore.status.setStatus(request.zsid, "Install SSL Certificate Failed: "&resultStruct.errorMessage, form, true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/addExisting?sid=#form.sid#&zsid="&request.zsid);
			}
			if(structkeyexists(resultStruct, 'ssl_expiration_datetime')){
				d=resultStruct.ssl_expiration_datetime;
				form.ssl_expiration_datetime=createdatetime(d.year, d.month, d.day, d.hour, d.minute, d.second);
			}
			form.ssl_country=application.zcore.functions.zso(resultStruct.csrData, 'c');
			form.ssl_state=application.zcore.functions.zso(resultStruct.csrData, 'st');
			form.ssl_city=application.zcore.functions.zso(resultStruct.csrData, 'l');
			form.ssl_organization=application.zcore.functions.zso(resultStruct.csrData, 'o');
			form.ssl_organization_unit=application.zcore.functions.zso(resultStruct.csrData, 'ou');
			form.ssl_common_name=application.zcore.functions.zso(resultStruct.csrData, 'cn');
			form.ssl_email=application.zcore.functions.zso(resultStruct.csrData, 'emailAddress');
		}

	}else if(form.method EQ "insert"){
		form.ssl_active=0;
		myform={};
		myform.ssl_display_name.required=true;
		myform.ssl_country.required=true;
		myform.ssl_state.required=true;
		myform.ssl_city.required=true;
		myform.ssl_organization.required=true;
		myform.ssl_organization_unit.required=true;
		myform.ssl_common_name.required=true;
		myform.ssl_key_size.required=true;
		errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
		if(errors){
			application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/add?sid=#form.sid#&zsid="&request.zsid);
		}
		form.ssl_country=rereplace(form.ssl_country, "[^\w\s]", "", "all");
		form.ssl_state=rereplace(form.ssl_state, "[^\w\s\.,-]", "", "all");
		form.ssl_city=rereplace(form.ssl_city, "[^\w\s\.,-]", "", "all");
		form.ssl_organization=rereplace(form.ssl_organization, "[^\w\s\.,-]", "", "all");
		form.ssl_organization_unit=rereplace(form.ssl_organization_unit, "[^\w\s\.,-]", "", "all");
		form.ssl_common_name=rereplace(form.ssl_common_name, "[^\w\s\.,-]", "", "all");
		form.ssl_key_size=rereplace(form.ssl_key_size, "[^0-9]", "", "all");
		js={
			ssl_selfsign:form.ssl_selfsign,
			ssl_country:form.ssl_country,
			ssl_state:form.ssl_state,
			ssl_city:form.ssl_city,
			ssl_organization:form.ssl_organization,
			ssl_organization_unit:form.ssl_organization_unit,
			ssl_common_name:form.ssl_common_name,
			ssl_email:form.ssl_email,
			ssl_key_size:form.ssl_key_size,
			ssl_hash:form.ssl_hash,
			site_id:form.site_id
		};
		jsonOutput=serializeJson(js);

		result=application.zcore.functions.zSecureCommand("sslGenerateKeyAndCSR"&chr(9)&jsonOutput, 50);
		if(result EQ ""){
			application.zcore.status.setStatus(request.zsid, 'Failed to generate private key and CSR.',form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/add?ssl_id=#form.ssl_id#&sid=#form.sid#&zsid=#request.zsid#");
		}else{
			js=deserializeJson(result);
			if(not js.success){
				application.zcore.status.setStatus(request.zsid, 'Failed to generate private key and CSR: '&js.errorMessage,form,true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/add?ssl_id=#form.ssl_id#&sid=#form.sid#&zsid=#request.zsid#");
			}
			if(form.ssl_selfsign EQ "1"){
				form.ssl_public_key=js.ssl_public_key;
				form.ssl_active="1";
				if(structkeyexists(js, 'ssl_expiration_datetime')){
					d=js.ssl_expiration_datetime;
					form.ssl_expiration_datetime=createdatetime(d.year, d.month, d.day, d.hour, d.minute, d.second);
					form.ssl_expiration_datetime=dateformat(form.ssl_expiration_datetime, "yyyy-mm-dd")&" "&timeformat(form.ssl_expiration_datetime, "HH:mm:ss");
				}
			}
		}
	}else if(form.method EQ "update"){
		myform={};
		myform.ssl_display_name.required=true;
		myform.ssl_public_key.required=true;
		myform.ssl_ca_certificate.required=true;
		errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
		if(errors){
			application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/add?sid=#form.sid#&zsid="&request.zsid);
		}
		js={
			ssl_public_key: form.ssl_public_key,
			ssl_intermediate_certificate: form.ssl_intermediate_certificate,
			ssl_ca_certificate: form.ssl_ca_certificate,
			ssl_hash:form.ssl_hash,
			site_id:form.site_id
		};
		jsonOutput=serializeJson(js);
		
		result=application.zcore.functions.zSecureCommand("sslSavePublicKeyCertificates"&chr(9)&jsonOutput, 50);
		resultStruct=deserializeJson(result);
		if(not resultStruct.success){
			application.zcore.status.setStatus(request.zsid, "Install SSL Certificate Failed: "&resultStruct.errorMessage, form, true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/add?sid=#form.sid#&zsid="&request.zsid);
		}
		if(structkeyexists(resultStruct, 'ssl_expiration_datetime')){
			d=resultStruct.ssl_expiration_datetime;
			form.ssl_expiration_datetime=createdatetime(d.year, d.month, d.day, d.hour, d.minute, d.second);
			form.ssl_expiration_datetime=dateformat(form.ssl_expiration_datetime, "yyyy-mm-dd")&" "&timeformat(form.ssl_expiration_datetime, "HH:mm:ss");
		}
	}
	if(structkeyexists(form, 'ssl_common_name')){
		if(left(form.ssl_common_name, 2) EQ "*."){
			form.ssl_wildcard=1;
		}else{
			form.ssl_wildcard=0;
		}
	}
	ts=StructNew();
	ts.table="ssl";
	ts.datasource=request.zos.zcoreDatasource;
	ts.forceWhereFields="site_id";
	ts.struct=form;
	

	if(form.method EQ "insert" or form.method EQ "insertExisting"){
		if(not application.zcore.functions.zInsert(ts)){
			application.zcore.status.setStatus(request.zsid, 'Failed to save SSL Certificate due to duplicate certificate.',form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/add?ssl_id=#form.ssl_id#&sid=#form.sid#&zsid=#request.zsid#");
		}
		application.zcore.status.setStatus(request.zsid, 'SSL Certificate Saved.');
	}else if(application.zcore.functions.zUpdate(ts)){
		application.zcore.status.setStatus(request.zsid, 'SSL Certificate Updated.');
	}else{
		application.zcore.status.setStatus(request.zsid, 'Failed to updated SSL Certificate.',form,true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/edit?ssl_id=#form.ssl_id#&sid=#form.sid#&zsid=#request.zsid#");
	}
	result=application.zcore.functions.zSecureCommand("publishNginxSiteConfig"&chr(9)&form.site_id, 30);
	if(result EQ false){
		application.zcore.status.setStatus(request.zsid, "Invalid Nginx configuration after publishing SSL Certificate - The previous Nginx configuration was restored.", form, true);
		
	}
	application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/index?sid=#form.sid#&zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="view" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qGroup=0;
	var qSite=0;
	var qin=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	init();
	//application.zcore.functions.zSetPageHelpId("8.1.1.9");
	db.sql="SELECT * FROM #db.table("ssl", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(form.sid)# and 
	ssl_deleted = #db.param(0)# ";
	qSSL=db.execute("qSSL");
	if(form.method EQ "edit" and qSSL.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"SSL Certificate doesn't exist.");
		application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/index?sid=#form.sid#&zsid=#request.zsid#");
	}
	application.zcore.functions.zQueryToStruct(qSSL, form);
	</cfscript>
	<h2>View SSL Certificate</h2>
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Display Name:</td>
			<td class="table-white">#htmleditformat(form.ssl_display_name)#</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Common Name:</td>
			<td class="table-white">#htmleditformat(form.ssl_common_name)# <cfif left(form.ssl_common_name, 2) EQ "*."> (Wildcard SSL) </cfif> </td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Country:</td>
			<td class="table-white">#htmleditformat(form.ssl_country)#</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">State:</td>
			<td class="table-white">#htmleditformat(form.ssl_state)#</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">City:</td>
			<td class="table-white">#htmleditformat(form.ssl_city)#</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Organization:</td>
			<td class="table-white">#htmleditformat(form.ssl_organization)#</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Organization Unit:</td>
			<td class="table-white">#htmleditformat(form.ssl_organization_unit)#</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Email:</td>
			<td class="table-white">#htmleditformat(form.ssl_email)#</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Key Size:</td>
			<td class="table-white">#htmleditformat(form.ssl_key_size)#</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Created Date:</td>
			<td class="table-white">#dateformat(form.ssl_created_datetime, "m/d/yyyy")# #timeformat(form.ssl_created_datetime, "h:mm tt")#</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Expiration Date:</td>
			<td class="table-white">#dateformat(form.ssl_expiration_datetime, "m/d/yyyy")# #timeformat(form.ssl_expiration_datetime, "h:mm tt")#</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Public Key:</td>
			<td class="table-white"><pre>#form.ssl_public_key#</pre></td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Intermediate Certificate:</td>
			<td class="table-white"><pre>#form.ssl_intermediate_certificate#</pre></td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">CA Certificate:</td>
			<td class="table-white"><pre>#form.ssl_ca_certificate#</pre></td>
		</tr>
	</table>
</cffunction>

<cffunction name="addExisting" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	edit();
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	edit();
	</cfscript>
</cffunction>
	

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qGroup=0;
	var qSite=0;
	var qin=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	init();
	backupMethod=form.method;
	//application.zcore.functions.zSetPageHelpId("8.1.1.9");
	db.sql="SELECT * FROM #db.table("ssl", request.zos.zcoreDatasource)# `ssl` 
	WHERE site_id = #db.param(form.sid)# and 
	ssl_id = #db.param(form.ssl_id)# and 
	ssl_deleted = #db.param(0)# ";
	qSSL=db.execute("qSSL");
	if(backupMethod EQ "edit" and qSSL.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"SSL Certificate doesn't exist.");
		application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/index?sid=#form.sid#&zsid=#request.zsid#");
	}
	if(qSSL.ssl_public_key NEQ ""){
		application.zcore.status.setStatus(request.zsid, "SSL Certificate already activated. You must create a new SSL Certificate to replace this one.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/ssl/index?sid=#form.sid#&zsid="&request.zsid);
	}
	application.zcore.functions.zQueryToStruct(qSSL, form);


	form.ssl_active=application.zcore.functions.zso(form, 'ssl_active',true,1);
	if(backupMethod EQ "add"){
		newAction="insert";
		db.sql="SELECT * FROM #db.table("ssl", request.zos.zcoreDatasource)# `ssl`
		WHERE site_id <> #db.param(-1)# and 
		ssl_deleted = #db.param(0)# 
		ORDER BY ssl_created_datetime DESC 
		LIMIT #db.param(0)#, #db.param(1)#";
		qSSL2=db.execute("qSSL2");
		if(qSSL2.recordcount NEQ 0){
			// make the default values the same as the last certificate's CSR
			form.ssl_country=qSSL2.ssl_country;
			form.ssl_state=qSSL2.ssl_state;
			form.ssl_city=qSSL2.ssl_city;
			form.ssl_organization=qSSL2.ssl_organization;
			form.ssl_organization_unit=qSSL2.ssl_organization_unit;
			form.ssl_email=qSSL2.ssl_email;
			form.ssl_key_size=qSSL2.ssl_key_size;
		}
	}else if(backupMethod EQ "addExisting"){
		newAction="insertExisting";
	}else{
		newAction="update";
	}
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>	
	<p><a href="/z/server-manager/admin/ssl/index?amp;sid=#form.sid#">Manage SSL Certificates</a> /</p>
	<h2><cfif backupMethod EQ "add">
		Add
	<cfelseif backupMethod EQ "addExisting">
		Add Existing
	<cfelse>
		Edit
	</cfif> SSL Certificate</h2>
	<form name="editForm" action="/z/server-manager/admin/ssl/#newAction#?sid=#form.sid#&amp;ssl_id=#form.ssl_id#" method="post" style="margin:0px;">
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Display Name:</td>
			<td class="table-white"><input type="text" name="ssl_display_name" value="#htmleditformat(form.ssl_display_name)#" /> (i.e. www.domain.com-#year(now())# or companyCert1)</td>
		</tr>
		<cfif backupMethod EQ "add">
		
			<tr>
				<td class="table-list" style="vertical-align:top; width:120px;">Common Name:</td>
				<td class="table-white"><input type="text" name="ssl_common_name" value="#htmleditformat(form.ssl_common_name)#" /> (The EXACT domain that will be protected by SSL, i.e. www.domain.com)</td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:120px;">Country:</td>
				<td class="table-white">#application.zcore.functions.zCountrySelect("ssl_country", form.ssl_country)#</td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:120px;">State:</td>
				<td class="table-white"><input type="text" name="ssl_state" value="#htmleditformat(form.ssl_state)#" /></td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:120px;">City:</td>
				<td class="table-white"><input type="text" name="ssl_city" value="#htmleditformat(form.ssl_city)#" /></td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:120px;">Organization:</td>
				<td class="table-white"><input type="text" name="ssl_organization" value="#htmleditformat(form.ssl_organization)#" /></td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:120px;">Orgnization Unit:</td>
				<td class="table-white"><input type="text" name="ssl_organization_unit" value="#htmleditformat(form.ssl_organization_unit)#" /></td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:120px;">Email:</td>
				<td class="table-white"><input type="text" name="ssl_email" value="#htmleditformat(form.ssl_email)#" /></td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:120px;">Key Size:</td>
				<td class="table-white"><cfscript>
				ts={};
				ts.name="ssl_key_size";
				ts.hideSelect=true;
				ts.listLabels = "2048,4096";
				ts.listValues = "2048,4096";
				ts.listLabelsDelimiter = ","; 
				ts.listValuesDelimiter = ",";
				application.zcore.functions.zInputSelectBox(ts);
				</cfscript> (2048 is recommended)</td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:120px;">Self-sign?:</td>
				<td class="table-white">#application.zcore.functions.zInput_Boolean("ssl_selfsign")#<br />
				Note: Self signed certificates will display a security warning until the user adds an exception for the certificate temporarily or permanently. It is not recommended to use this option except for testing purposes.</td>
			</tr>
		<cfelse>
			<cfif backupMethod EQ "addExisting">
				<tr>
					<td class="table-list" style="vertical-align:top; width:120px;">Private Key:</td>
					<td class="table-white"><textarea name="ssl_private_key" cols="100" rows="10">#htmleditformat(application.zcore.functions.zso(form, 'ssl_private_key'))#</textarea></td>
				</tr>
			<cfelse>
				<tr>
					<td class="table-list" style="vertical-align:top; width:120px;">Common Name:</td>
					<td class="table-white">#htmleditformat(form.ssl_common_name)#</td>
				</tr>
				<tr>
					<td class="table-list" style="vertical-align:top; width:120px;">Country:</td>
					<td class="table-white">#htmleditformat(form.ssl_country)#</td>
				</tr>
				<tr>
					<td class="table-list" style="vertical-align:top; width:120px;">State:</td>
					<td class="table-white">#htmleditformat(form.ssl_state)#</td>
				</tr>
				<tr>
					<td class="table-list" style="vertical-align:top; width:120px;">City:</td>
					<td class="table-white">#htmleditformat(form.ssl_city)#</td>
				</tr>
				<tr>
					<td class="table-list" style="vertical-align:top; width:120px;">Organization:</td>
					<td class="table-white">#htmleditformat(form.ssl_organization)#</td>
				</tr>
				<tr>
					<td class="table-list" style="vertical-align:top; width:120px;">Organization Unit:</td>
					<td class="table-white">#htmleditformat(form.ssl_organization_unit)#</td>
				</tr>
				<tr>
					<td class="table-list" style="vertical-align:top; width:120px;">Email:</td>
					<td class="table-white">#htmleditformat(form.ssl_email)#</td>
				</tr>
				<tr>
					<td class="table-list" style="vertical-align:top; width:120px;">Key Size:</td>
					<td class="table-white">#htmleditformat(form.ssl_key_size)#</td>
				</tr>
			</cfif>
			<tr>
				<td class="table-list" style="vertical-align:top; width:120px;">Signed Certificate:<br />(Public Key)</td>
				<td class="table-white"><textarea name="ssl_public_key" cols="100" rows="5">#htmleditformat(form.ssl_public_key)#</textarea></td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:120px;">Intermediate Certificate:</td>
				<td class="table-white"><textarea name="ssl_intermediate_certificate" cols="100" rows="5">#htmleditformat(form.ssl_intermediate_certificate)#</textarea></td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:120px;">CA Certificate:</td>
				<td class="table-white"><textarea name="ssl_ca_certificate" cols="100" rows="5">#htmleditformat(form.ssl_ca_certificate)#</textarea></td>
			</tr>
			<cfif backupMethod EQ "edit">
				<tr>
					<td class="table-list" style="vertical-align:top; width:120px;">Active:</td>
					<td class="table-white">#application.zcore.functions.zInput_Boolean("ssl_active")#<br />
					Note: If you deactivate this SSL Certificate, the next newest Active SSL Certificate for this site will be used.   If no other active certificates exist, SSL will be disabled for this domain.</td>
				</tr>
			</cfif>
		</cfif>
		<!--- <tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Wildcard Certificate:</td>
			<td class="table-white">#application.zcore.functions.zInput_Boolean("ssl_wildcard")# (If yes, the common name MUST be like *.domain.com) </td>
		</tr> --->
	<tr>
		<td class="table-list" style="width:120px;">&nbsp;</td>
		<td class="table-white">
		<button type="submit" name="submit" value="Save">Save</button> <button type="button" name="cancel" value="Cancel" onClick="window.location.href = '/z/server-manager/admin/ssl/index?sid=#form.sid#';">Cancel</button></td>
	</tr>
	</table>	
	</form>
</cffunction>

<cffunction name="ipUsageReport" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	db.sql="select site_ip_address, site_short_domain, group_concat(site_domain SEPARATOR #db.param(",")#) domainlist 
	from #db.table("site", request.zos.zcoreDatasource)# site
	LEFT JOIN 
	#db.table("ssl", request.zos.zcoreDatasource)# `ssl` ON 
	ssl.site_id = site.site_id and 
	ssl_deleted=#db.param(0)# and 
	ssl_active=#db.param(1)# 
	WHERE 
	site.site_id <> #db.param(-1)# and 
	site_deleted = #db.param(0)# and 
	site_active = #db.param(1)# 
	GROUP BY site_ip_address 
	ORDER BY site_ip_address ASC";
	qIp=db.execute("qIp");
	</cfscript>
	<p><a href="/z/server-manager/admin/ssl/index?sid=#form.sid#">Manage SSL Certificates</a> /</p>
	<h2>IP Address Usage Report</h2>
	<table class="table-list">
		<tr>
			<th>IP</th>
			<th>Active SSL Certificate</th>
			<th>Expiration Date</th>
			<th>Domain(s)</th>
		</tr>
		<cfloop query="qIp">
			<tr>
				<td>#qIp.site_ip_address#</td>
				<td>#qIp.ssl_common_name#</td>
				<td>#dateformat(qIp.ssl_expiration_datetime, "m/d/yyyy")# #timeformat(qIp.ssl_expiration_datetime, "h:mm tt")#</td>
				<td><cfscript>
				if(qIp.domainlist CONTAINS ","){
					echo(listLen(qIp.domainlist, ",")&" domains");
				}else{
					echo(qIp.site_short_domain);
				}
				</cfscript></td>
			</tr>
		</cfloop>
	</table>
</cffunction>
	

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var selectStruct=0;
	var qSites=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	//application.zcore.functions.zSetPageHelpId("8.1.1.9.1");
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	db.sql="SELECT * FROM #db.table("ssl", request.zos.zcoreDatasource)#   
	WHERE ssl_deleted = #db.param(0)# and 
	site_id = #db.param(form.sid)#";
	qSSL=db.execute("qSSL");
	</cfscript> 
	<h2 style="display:inline;">Manage SSL Certificates</h2> | 
	<a href="/z/server-manager/admin/ssl/ipUsageReport?sid=#form.sid#">IP Address Usage Report</a> 
	| <a href="/z/server-manager/admin/ssl/add?sid=#form.sid#">New SSL Certificate</a> | 
	<a href="/z/server-manager/admin/ssl/addExisting?sid=#form.sid#">Add Existing Certificate</a>
	<br /><br />
	<cfif qSSL.recordcount EQ 0>
		<p>No SSL Certificate installed for this site.</p>

	<cfelse>
		<table class="table-list">
			<tr>
				<th>Display Name</th>
				<th>Common Name</th>
				<th>Created Date</th>
				<th>Expiration Date</th>
				<th>Status</th>
				<th>Admin</th>
			</tr>
			<cfloop query="qSSL">
				<tr>
					<td>#qSSL.ssl_display_name#</td>
					<td>#qSSL.ssl_common_name#</td>
					<td>#dateformat(qSSL.ssl_created_datetime, "m/d/yyyy")# #timeformat(qSSL.ssl_created_datetime, "h:mm tt")#</td>
					<td>#dateformat(qSSL.ssl_expiration_datetime, "m/d/yyyy")# #timeformat(qSSL.ssl_expiration_datetime, "h:mm tt")#</td>
					<td><cfscript>
					if(qSSL.ssl_public_key NEQ ""){
						if(isdate(qSSL.ssl_expiration_datetime) and datecompare(qSSL.ssl_expiration_datetime, now()) LTE 0){
							echo("Expired");
						}else{
							echo("Active");
						}
					}else{
						echo("Not Activated");
					}
					</cfscript>
					</td>
					<td>
						<cfif qSSL.ssl_public_key EQ "">
							<a href="/z/server-manager/admin/ssl/edit?ssl_id=#qSSL.ssl_id#&amp;sid=#form.sid#">Activate</a>
						<cfelse>
							<a href="/z/server-manager/admin/ssl/view?ssl_id=#qSSL.ssl_id#&amp;sid=#form.sid#">View</a>
						</cfif> | 
						<a href="/z/server-manager/admin/ssl/delete?ssl_id=#qSSL.ssl_id#&amp;sid=#form.sid#">Delete</a>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>