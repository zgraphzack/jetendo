<cfcomponent>
<cfoutput>


<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qU=0;
	var qSite=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	db.sql="SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id = #db.param(form.sid)# and 
	site_deleted=#db.param(0)#";
	qSite=db.execute("qSite");
	if(qSite.recordcount EQ 0){	
		application.zcore.status.setStatus(Request.zsid, "Site no longer exists.",false,true);
		application.zcore.functions.zRedirect('/z/server-manager/admin/site-select/index?action=list&zsid='&request.zsid);
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		form.site_id=form.sid;
		db.sql="UPDATE #db.table("site", request.zos.zcoreDatasource)# site 
			SET site_active =#db.param(0)#,
			site_updated_datetime=#db.param(request.zos.mysqlnow)#  
			WHERE site_id = #db.param(form.sid)# and 
			site_deleted=#db.param(0)# ";
		qU=db.execute("qU");
		application.zcore.functions.zOS_cacheSitePaths();

		var rs=application.zcore.functions.zGenerateNginxMap(false);
		var result=application.zcore.functions.zSecureCommand("publishNginxSiteConfig"&chr(9)&form.site_id, 30);
		fail=false;
		if(result EQ ""){
			application.zcore.status.setStatus(request.zsid, "Unknown failure when publishing Nginx configuration", form, true);
			fail=true;
		}else{
			js=deserializeJson(result);
			if(not js.success){
				fail=true;
				application.zcore.status.setStatus(request.zsid, "Nginx site config publish failed: "&js.errorMessage, form, true);
			}
		}
		application.zcore.status.setStatus(request.zsid, "Site deactivated. "&rs.message, form, rs.success);
		// go back to site overview page
		application.zcore.functions.zRedirect('/z/server-manager/admin/site-select/index?action=list&zsid='&request.zsid);
		</cfscript>
	<cfelse>
		<div style="text-align:center;"><span class="medium">
		Are you sure you want to deactivate this web site?<br /><br />
        Note: The files and database records for this site will not be removed.<br />
        It will simply be made inactive and you can manually remove the unused data later.<br /><br />
		#qSite.site_sitename#
		<br /><br />
		<a href="/z/server-manager/admin/site/delete?confirm=1&amp;sid=#form.sid#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="/z/server-manager/admin/site-select/index?action=select&amp;sid=#form.sid#">No</a></span></div>
	</cfif>
</cffunction>


<cffunction name="autoSyncSiteFiles" localmode="modern" access="public" returntype="boolean" roles="serveradministrator">
	<cfargument name="sourceSiteId" type="numeric" required="yes">
	<cfargument name="destinationSiteId" type="numeric" required="yes">
	<cfargument name="overwrite" type="boolean" required="no" default="#false#">
	<cfscript> 
	var db=request.zos.queryObject;
	if(arguments.sourceSiteId NEQ "" and arguments.sourceSiteId NEQ 0){
		db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(arguments.sourceSiteId)# and 
		site_active=#db.param(1)# ";
		local.qCloneSite=db.execute("qCloneSite");
		db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(arguments.destinationSiteId)# and 
		site_active=#db.param(1)# ";
		local.qDSite=db.execute("qDSite");
		if(local.qCloneSite.recordcount NEQ 0 and local.qDSite.recordcount NEQ 0){ 
			local.oldPath=application.zcore.functions.zGetDomainInstallPath(local.qCloneSite.site_short_domain, local.qCloneSite.site_id);
			local.newPath=application.zcore.functions.zGetDomainInstallPath(local.qDSite.site_short_domain, local.qDSite.site_id);
			application.zcore.functions.zCopyDirectory(local.oldPath, local.newPath, arguments.overwrite);
			return true;
		}
	}
	return false;
	</cfscript>
</cffunction>

<cffunction name="manualSync" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	var db=request.zos.queryObject;
	form.sid=application.zcore.functions.zso(form, 'sid', true);
	if(form.sid EQ 0){
		application.zcore.functions.z404('Invalid request - no site id provided.');	
	}
	db.sql="select site_theme_sync_site_id, site_short_domain from #db.table('site', request.zos.zcoreDatasource)# 
	where site_id = #db.param(form.sid)# and 
	site_active=#db.param(1)# ";
	local.primarySite="";
	local.currentSite="";
	local.qDestination=db.execute("qDestination");
	if(local.qDestination.recordcount NEQ 0 and local.qDestination.site_theme_sync_site_id NEQ 0){
		db.sql="select site_short_domain from #db.table('site', request.zos.zcoreDatasource)# 
		where site_id = #db.param(local.qDestination.site_theme_sync_site_id)# and 
		site_active=#db.param(1)# ";
		local.qSource=db.execute("qSource");
		local.currentSite=local.qDestination.site_short_domain;
		if(local.qSource.recordcount NEQ 0){
			local.primarySite=local.qSource.site_short_domain;
		}else{
			application.zcore.status.setStatus(request.zsid, "Current site no longer exists.", form, true);
		}	
	}else{
		application.zcore.status.setStatus(request.zsid, "Primary site no longer exists or isn't set yet.", form, true);
	}
	if(local.currentSite EQ "" or local.primarySite EQ ""){
		application.zcore.functions.zRedirect('/z/server-manager/admin/site-select/index?action=select&sid=#form.sid#&zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript> 
		local.result=this.autoSyncSiteFiles(local.qDestination.site_theme_sync_site_id, form.sid, true);
		if(local.result){
			application.zcore.status.setStatus(request.zsid, "Source code files synchronicized from primary site successfully");
		}else{
			application.zcore.status.setStatus(request.zsid, "Failed to synchronicized source code files from primary site.", form, true);
		}
		application.zcore.functions.zRedirect('/z/server-manager/admin/site-select/index?action=select&sid=#form.sid#&zsid=#request.zsid#');
		</cfscript>
	<cfelse> 
		<h2>Are you sure you want to manually synchronize the source code files from the primary site, "#local.primarySite#"?<br /><br />
		WARNING: The files on the destination site, "#local.currentSite#", will be permanently overwritten.<br /><br />
		<a href="/z/server-manager/admin/site/manualSync?confirm=1&amp;sid=#form.sid#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/server-manager/admin/site-select/index?action=select&amp;sid=#form.sid#">No</a>
		</h2>
	</cfif>
</cffunction>
	
<cffunction name="downloadAllSTE" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var d=0;
	var curPath=0;
	var i=0;
	var arrL=0;
	var f4444=0;
	var c=0;
	var curDomain=0;
	application.zcore.functions.zSetPageHelpId("8.1.1.4.1");
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	</cfscript>
	<h2>Dreamweaver STE Generation</h2>

    <cfif structkeyexists(form, 'dtee') EQ false>
    	<form action="/z/server-manager/admin/site/downloadallste?sid=#form.sid#" method="post" enctype="multipart/form-data">
		<p>Upload tab separated values file with the following columns: full domain, short domain (no www), ip address, username, password.</p>
		<p>Local Install Directory: <input type="text" name="installdir" value="C:\ServerData\vhosts\" /></p>
		<p>File: <input type="file" name="dtee"  /></p>
		<p><input type="submit" name="s444" value="Upload" /> <input type="button" name="s4443" value="Cancel" onclick="window.location.href='/z/server-manager/admin/site-select/index?action=select&amp;sid=#form.sid#';" /></p>
	    </form>
    <cfelse>
	<cfscript>
	application.zcore.functions.zdeletedirectory(request.zos.globals.serverprivatehomedir&"_cache/ste/");
	application.zcore.functions.zcreatedirectory(request.zos.globals.serverprivatehomedir&"_cache/ste/");
	f4444=application.zcore.functions.zUploadFile("dtee", request.zos.globals.serverprivatehomedir&"_cache/ste/", true);
	c=application.zcore.functions.zreadfile(request.zos.globals.serverprivatehomedir&"_cache/ste/"&f4444);
	arrL=listtoarray(c, chr(10));
	
	for(i=1;i LTE arraylen(arrL);i++){
		if(trim(arrL[i]) NEQ ""){
			arrR=listtoarray(arrL[i], chr(9));
			curDomain=arrR[2];
			if(arraylen(arrR) EQ 6){
				curDomain=arrR[6];
			}
			curPath=replacenocase(replacenocase(replacenocase(urlencodedformat(replace(replace(request.zos.sitesPath&curDomain,request.zos.sitesPath,form.installdir),"/","\","all")),"%3A",":"),"%2E",".","all"),"%5F","_","all");
			d=(('<?xml version="1.0" encoding="utf-8" ?>
<site SitePrefVersionMajor="11" SitePrefVersionMinor="2">
    <localinfo sitename="'&curDomain&'" ftporrdsserver="FALSE" localroot="'&curPath&'" assetfolder="'&curPath&'" imagefolder="" spacerfilepath="" refreshlocal="TRUE" rewritedocrellinks="FALSE" cache="FALSE" httpaddress="" relativeTo="DOCUMENT" caseSensitiveLinks="FALSE" curserver="webserver"/>
    <designnotes usedesignnotes="FALSE" sharedesignnotes="FALSE"/>
    <sitemap homepage="" pagesperrow="200" columnwidth="125" showdependentfiles="FALSE" showpagetitles="FALSE" showhiddenfiles="FALSE"/>
    <fileviewcolumns sharecolumns="FALSE">
        <column name="Local%20Files" align="left" show="TRUE" share="FALSE" builtin="TRUE" localwidth="80" remotewidth="180"/>
        <column name="Notes" align="center" show="FALSE" share="FALSE" builtin="TRUE" localwidth="36" remotewidth="36"/>
        <column name="Size" align="right" show="TRUE" share="FALSE" builtin="TRUE" localwidth="-2" remotewidth="-2"/>
        <column name="Type" align="left" show="TRUE" share="FALSE" builtin="TRUE" localwidth="60" remotewidth="60"/>
        <column name="Modified" align="left" show="TRUE" share="FALSE" builtin="TRUE" localwidth="102" remotewidth="102"/>
        <column name="Checked%20Out%20By" align="left" show="TRUE" share="FALSE" builtin="TRUE" localwidth="-1" remotewidth="-1"/>
</fileviewcolumns>
    <serverlist>
        <server servermodel="" servertype="remoteServer" weburl="" connectionsmigrated="FALSE" serverobjectsversion="0" defaultdoctype="HTML" accesstype="ftp" host="127.0.0.1:3001" remoteroot="/" name="centos-live" maintainSyncInfo="TRUE" autoUpload="FALSE" user="'&arrR[4]&'" pw="'&application.zcore.functions.zEncodeDreamweaverPassword(arrR[5])&'" savePW="TRUE" enablecheckin="FALSE" checkoutname="" checkoutwhenopen="TRUE" emailaddress="" usefirewall="FALSE" usepasv="TRUE" useSFTP="FALSE" useIPv6="FALSE" useftpoptimization="TRUE" usealternaterename="FALSE" pathNameCharacterSet="Windows-1252"/>
</serverlist>
    <cloaking enabled="TRUE" patterns="FALSE">
       <cloakedfolder folder="dw_php_codehinting.config"/>
        <cloakedfolder folder="_cache/"/>
        <cloakedfolder folder="zcache/"/>
        <cloakedfolder folder="static/"/>
        <cloakedpattern pattern=".fla"/>
        <cloakedpattern pattern=".psd"/>
</cloaking>
    <contributorintegration enabled="FALSE"/>
</site>'));
			application.zcore.functions.zwritefile(request.zos.globals.serverprivatehomedir&"_cache/ste/"&curDomain&".ste", d);
		}
	}
	application.zcore.functions.zdeletefile(request.zos.globals.serverprivatehomedir&"_cache/ste/"&f4444);
	</cfscript>
	<p>All dreamweaver ste files generated.</p>
	</cfif>
</cffunction>

	
	
<cffunction name="downloadSTE" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qSite=0;
	var curPath=0;
	application.zcore.functions.zSetPageHelpId("8.1.1.4");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id = #db.param(form.sid)# and 
	site_deleted=#db.param(0)# 
	</cfsavecontent><cfscript>qSite=db.execute("qSite");</cfscript>
	<cfif structkeyexists(form, 'temppassword1')>
    	 <cfheader name="Content-disposition" value="attachment;filename=#qsite.site_sitename#.ste"><cfcontent type="text/xml" reset="yes" /><cfscript>
	 local.tempPath=application.zcore.functions.zGetDomainInstallPath(qsite.site_short_domain);
		curPath=replacenocase(replacenocase(replacenocase(urlencodedformat(replace(replace(local.tempPath,request.zos.sitesPath, form.installdir)&"/","/","\","all")),"%3A",":"),"%2E",".","all"),"%5F","_","all");
		writeoutput(('<?xml version="1.0" encoding="utf-8" ?>
<site SitePrefVersionMajor="11" SitePrefVersionMinor="2">
    <localinfo sitename="'&qsite.site_sitename&'" ftporrdsserver="FALSE" localroot="'&curPath&'" assetfolder="'&curPath&'" imagefolder="" spacerfilepath="" refreshlocal="TRUE" rewritedocrellinks="FALSE" cache="FALSE" httpaddress="" relativeTo="DOCUMENT" caseSensitiveLinks="FALSE" curserver="webserver"/>
    <designnotes usedesignnotes="FALSE" sharedesignnotes="FALSE"/>
    <sitemap homepage="" pagesperrow="200" columnwidth="125" showdependentfiles="FALSE" showpagetitles="FALSE" showhiddenfiles="FALSE"/>
    <fileviewcolumns sharecolumns="FALSE">
        <column name="Local%20Files" align="left" show="TRUE" share="FALSE" builtin="TRUE" localwidth="80" remotewidth="180"/>
        <column name="Notes" align="center" show="FALSE" share="FALSE" builtin="TRUE" localwidth="36" remotewidth="36"/>
        <column name="Size" align="right" show="TRUE" share="FALSE" builtin="TRUE" localwidth="-2" remotewidth="-2"/>
        <column name="Type" align="left" show="TRUE" share="FALSE" builtin="TRUE" localwidth="60" remotewidth="60"/>
        <column name="Modified" align="left" show="TRUE" share="FALSE" builtin="TRUE" localwidth="102" remotewidth="102"/>
        <column name="Checked%20Out%20By" align="left" show="TRUE" share="FALSE" builtin="TRUE" localwidth="-1" remotewidth="-1"/>
</fileviewcolumns>
    <serverlist>
        <server servermodel="" servertype="remoteServer" weburl="" connectionsmigrated="FALSE" serverobjectsversion="0" defaultdoctype="HTML" accesstype="ftp" host="127.0.0.1:3001" remoteroot="/" name="centos-live" maintainSyncInfo="TRUE" autoUpload="FALSE" user="'&form.tempusername1&'" pw="'&application.zcore.functions.zEncodeDreamweaverPassword(form.temppassword1)&'" savePW="TRUE" enablecheckin="FALSE" checkoutname="" checkoutwhenopen="TRUE" emailaddress="" usefirewall="FALSE" usepasv="TRUE" useSFTP="FALSE" useIPv6="FALSE" useftpoptimization="TRUE" usealternaterename="FALSE" pathNameCharacterSet="Windows-1252"/>
</serverlist>
    <cloaking enabled="TRUE" patterns="FALSE">
       <cloakedfolder folder="dw_php_codehinting.config"/>
        <cloakedfolder folder="_cache/"/>
        <cloakedfolder folder="zcache/"/>
        <cloakedfolder folder="static/"/>
        <cloakedpattern pattern=".fla"/>
        <cloakedpattern pattern=".psd"/>
</cloaking>
    <contributorintegration enabled="FALSE"/>
</site>'));application.zcore.functions.zabort();</cfscript>
        <cfelse>
		<cfscript>
		value=application.zcore.functions.zso(cookie, "steInstallDir");
		if(value EQ ""){
			value="#request.zos.sambaInstallPath#sites/";
		}else{
			value=urldecode(value);
		}
		</cfscript>
		<table style="border-spacing:0px; padding:5px;">
		<tr><td>
		<h2>Download Dreamweaver STE File</h2>
		<form action="/z/server-manager/admin/site/downloadSTE?sid=#form.sid#" method="post">
		<table style="border-spacing:0px;">
		<tr><td>
		Local Install Directory: </td><td><input type="text" name="installdir" id="installdir" onkeyup="setInstallPath(this.value);" onpaste="setInstallPath(this.value);" size="70" value="#htmleditformat(value)#" />
		</td></tr>
		<tr><td>
		Enter Username: </td><td><input type="text" name="tempusername1" size="70" value="#htmleditformat(qsite.site_username)#" />
		</td></tr>
		<tr><td>
		Enter Password:</td><td> <input type="text" name="temppassword1" size="70" value="#htmleditformat(qsite.site_password)#" />
		</td></tr>
		<tr><td>&nbsp;</td><td>
		<input type="submit" name="submit1" value="Download" />
		</td></tr>
		</table>
		</form>
		</td></tr>
		</table>
		<hr />
		<cfif application.zcore.user.checkAllCompanyAccess()>
			<h2><a href="/z/server-manager/admin/site/downloadAllSTE?sid=#form.sid#">Generate All Dreamweaver STE Files</a></h2>
		</cfif>
		<script type="text/javascript">
		/* <![CDATA[ */
		function setInstallPath(){
			var d=document.getElementById('installdir');
			zSetCookie({key:"steInstallDir",value:d.value,futureSeconds:60 * 60 * 24 * 365,enableSubdomains:false}); 
		}
		/* ]]> */
		</script>
	</cfif>
</cffunction>
	
	
<cffunction name="insert" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var fix1=0;
	var fix2=0;
	var qTest=0;
	var qMessage=0;
	var sdomain=0;
	var i=0;
	var duser=0;
	var arrUser=0;
	var arrCUser=0;
	var qCheck=0;
	var solddomain=0;
	var arrId=0;
	var qCheck2=0;
	var ts=0;
	var rCom=0;
	var inputStruct=0;
	var qSite=0;
	var insertCheck=0;
	var qId1=0;
	var qId2=0;
	var qId3=0;
	var qId4=0;
	var qId5=0; 
	var qthemedirectory=0;
	var foundtheme=0;
	var updateMessage=0;
	var currentMethod=form.method;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	if(structkeyexists(form, 'site_active') EQ false){
		form.site_active=0;
	}
	if(not structkeyexists(form, 'site_lock_theme')){
		form.site_lock_theme=0;
	}


	if(not application.zcore.user.checkAllCompanyAccess()){
		form.company_id = request.zsession.user.company_id;
	}
	form.site_domain=request.zos.originalFormScope.site_domain;
	form.site_securedomain=request.zos.originalFormScope.site_securedomain;

	form.site_short_domain=lcase(form.site_short_domain);
	form.site_domain=lcase(form.site_domain);
	form.site_domainaliases=lcase(form.site_domainaliases);
	
	if(structkeyexists(form, 'clone_site_id') and form.clone_site_id NEQ ""){
		if(form.site_child_sync EQ 1){
			form.site_theme_sync_site_id=form.clone_site_id;
		}else{
			form.site_theme_sync_site_id=0;
		}
	}
	if(structkeyexists(form, 'site_enable_nginx_proxy_cache') EQ false){
		form.site_enable_nginx_proxy_cache=0;
	}
	if(structkeyexists(form, 'site_disable_dns_monitor') EQ false){
		form.site_disable_dns_monitor=0;
	}
	if(structkeyexists(form, 'site_require_captcha') EQ false){
		form.site_require_captcha=0;
	}else{
		if(form.site_recaptcha_secretkey EQ "" or form.site_recaptcha_sitekey EQ ""){
			application.zcore.status.setStatus(Request.zsid, "Recaptcha Secret Key and Site Key are required if you enable captcha on public forms.",form,true);
		}
	}
	if(not structkeyexists(form, 'site_enable_user_stats')){
		form.site_enable_user_stats=0;
	}
	if(structkeyexists(form, 'site_enable_ssi_publish') EQ false){
		form.site_enable_ssi_publish=0;
	}
	if(structkeyexists(form, 'site_multidomain_enabled') EQ false){
		form.site_multidomain_enabled=0;
	}
	if(structkeyexists(form, 'site_send_confirm_opt_in') EQ false){
		form.site_send_confirm_opt_in=0;
	}
	if(structkeyexists(form, 'site_disable_cfml') EQ false){
		form.site_disable_cfml=0;
	}
	if(structkeyexists(form, 'site_disable_openid') EQ false){
		form.site_disable_openid=0;
	}
	if(structkeyexists(form, 'site_plain_text_password') EQ false){
		form.site_plain_text_password=0;
	}
	if(structkeyexists(form, 'site_login_iframe_enabled') EQ false){
		form.site_login_iframe_enabled=0;
	}
	if(structkeyexists(form, 'site_require_ssl_for_user') EQ false){
		form.site_require_ssl_for_user=0;
	}
	if(structkeyexists(form, 'site_widget_builder_enabled') EQ false){
		form.site_widget_builder_enabled=0;
	}
	if(structkeyexists(form, 'site_require_login') EQ false){
		form.site_require_login=0;
	}
	if(structkeyexists(form, 'site_enable_spritemap') EQ false){
		form.site_enable_spritemap=0;
	}
	if(structkeyexists(form, 'site_enable_demo_mode') EQ false){
		form.site_enable_demo_mode=0;
	}
	if(structkeyexists(form, 'site_unit_testing_domain') EQ false){
		form.site_unit_testing_domain=0;
	} 
	if(structkeyexists(form, 'site_track_users') EQ false){
		form.site_track_users = 0;
	}
	if(structkeyexists(form, 'site_require_secure_login') EQ false){
		form.site_require_secure_login=0;
	}
	if(structkeyexists(form, 'site_assignsortbyname') EQ false){
		form.site_assignsortbyname=0;	
	}
	if(structkeyexists(form, 'site_publish_enabled') EQ false){
		form.site_publish_enabled = 0;
	}
	if(structkeyexists(form, 'site_debug_enabled') EQ false){
		form.site_debug_enabled = 0;
	}
	if(structkeyexists(form, 'site_enable_mincat') EQ false){
		form.site_enable_mincat = 0;
	}
	if(structkeyexists(form, 'site_enable_jquery_ui') EQ false){
		form.site_enable_jquery_ui=0;
	}
	if(structkeyexists(form, 'site_enable_instant_load') EQ false){
		form.site_enable_instant_load=0;
	}
	if(structkeyexists(form, 'site_allow_activation') EQ false){
		form.site_allow_activation=0;
	}
	if(right(form.site_domain, 1) EQ '/'){
		fix1 = "";
	}else{
		fix1 = "/";
	}
	if(right(form.site_securedomain, 1) EQ '/'){
		fix2 = "";
	}else{
		fix2 = "/";
	}	
	if(structkeyexists(form, 'site_email_active') EQ false){
		form.site_email_active=0;	
	}
	if(structkeyexists(form, 'site_email_smtp_authentication') EQ false){
		form.site_email_smtp_authentication=0; 
	}
	if(structkeyexists(form, 'site_email_ssl') EQ false){
		form.site_email_ssl=0;
	}
	</cfscript>
	<cfif form.site_datasource NEQ ''>
	<cftry>
		<cfsavecontent variable="db.sql">
		SHOW TABLES
		</cfsavecontent><cfscript>qTest=db.execute("qTest");</cfscript>
		<cfcatch type="any">
		<cfscript>
		application.zcore.status.setStatus(Request.zsid, "Datasource doesn't exist",form,true);
		application.zcore.status.setFieldError(Request.zsid, "site_datasource");
		</cfscript>
		</cfcatch>
	</cftry>
	</cfif>
    
    <cfif trim(form.site_email_popserver&form.site_email_username&form.site_email_password) NEQ ''>
    	<cftry>
            <CFPOP
            ACTION="GetHeaderOnly"
            name="qMessage" 
            SERVER="#form.site_email_popserver#"
            USERNAME="#form.site_email_username#"
            PASSWORD="#form.site_email_password#"
            messagenumber="1"
            maxrows="1"
            timeout="5">
            <cfcatch type="any">
				<cfscript>
                application.zcore.status.setStatus(Request.zsid, "The email server connection failed. You must supply a valid email server, username and password or leave these fields blank. Things to check: The ip for the domain defined in the Mail Server, the DNS and MX records, make sure the and username and password exists and that it is for a active pop account.",form,true);
                application.zcore.status.setFieldError(Request.zsid, "site_email_popserver");
                application.zcore.status.setFieldError(Request.zsid, "site_email_username");
                application.zcore.status.setFieldError(Request.zsid, "site_email_password");
                </cfscript>
	        </cfcatch>
       	</cftry>
    </cfif>
	<cfscript>
	if(form.site_ip_address EQ ""){
		application.zcore.status.setStatus(Request.zsid, "IP Address is required.",form,true);
		application.zcore.status.setFieldError(Request.zsid, "site_ip_address");
	}
	if(application.zcore.functions.zEmailValidate(form.site_admin_email) EQ false){
		application.zcore.status.setStatus(Request.zsid, "Site Admin Email is required and must be a valid email address.",form,true);
		application.zcore.status.setFieldError(Request.zsid, "site_admin_email");
	}
	if(form.site_developer_email NEQ "" and application.zcore.functions.zEmailValidate(form.site_developer_email) EQ false){
		application.zcore.status.setStatus(Request.zsid, "Site Developer Email must be left blank or be a valid email address.",form,true);
		application.zcore.status.setFieldError(Request.zsid, "site_admin_email");
	}
	if(application.zcore.functions.zso(form, 'site_email_link_from') NEQ '' and application.zcore.functions.zEmailValidate(form.site_email_link_from) EQ false){
		application.zcore.status.setStatus(Request.zsid, "Link Email Address must be a valid email address.",form,true);
		application.zcore.status.setFieldError(Request.zsid, "site_email_link_from");
	}
	if(request.zos.istestserver){
		sdomain=lcase(replacenocase(replacenocase(form.site_short_domain,"www.",""),"."&request.zos.testDomain,""));
	}else{
		sdomain=lcase(replacenocase(form.site_short_domain,"www.",""));
	}
	
	if(refind("[a-z0-9][a-z0-9\.-]*", sdomain) EQ 0){
		application.zcore.status.setStatus(Request.zsid, "A domain must be lower case and only contain a-z, 0-9 and hyphens ""-"".",form,true);
		application.zcore.status.setFieldError(Request.zsid, "site_short_domain");
	}
	/*
	if(request.zos.istestserver EQ false){
		if(form.site_password EQ "" or len(form.site_password) LT 20){
			application.zcore.status.setStatus(Request.zsid, "The password must be over 20 characters long.",form,true);
			application.zcore.status.setFieldError(Request.zsid, "site_password");
		}
		if(form.site_username EQ "" or rereplace(form.site_username, "[a-z_][a-z0-9_]{0,31}", "") NEQ ""){
			application.zcore.status.setStatus(Request.zsid, "The username must start with a-z or _.  It can contain letters, numbers or _.  It must be 32 characters or less.",form,true);
			application.zcore.status.setFieldError(Request.zsid, "site_username");
		}
	}*/
	sdomain2=application.zcore.functions.zGetDomainWritableInstallPath(sdomain);
	sdomain=application.zcore.functions.zGetDomainInstallPath(sdomain);
	form.site_homedir=sdomain;
	form.site_securehomedir=sdomain; 
	form.site_privatehomedir=sdomain2;
	if(currentMethod EQ "insert"){
		form.site_system_user_created=0;
		/*if(application.zcore.functions.zso(form, 'useExistingUsername', false) NEQ 1){
			if(request.zos.istestserver EQ false){
				// read the linux users on this system to determine if the username already exists.
				dUser=listToArray(application.zcore.functions.zSecureCommand("getUserList"));
				arrUser=listtoarray(dUser, chr(10),false);
				local.foundUser=false;
				for(i=1;i LTE arraylen(arrUser);i++){
					if(trim(arrUser[i]) NEQ ""){
						arrCUser=listtoarray(arrUser[i],":");
						if(trim(arrCUser[1]) EQ form.site_username){
							local.foundUser=true;
							application.zcore.status.setStatus(Request.zsid, "This username already exists.  Please choose another.",form,true);
							application.zcore.status.setFieldError(Request.zsid, "site_password");
							break;	
						}
					}
				}
				if(local.foundUser){
					form.site_system_user_created=1;
				}
			}
		}else{
			form.site_system_user_modifed=1;
		}*/
	}else{
		db.sql="select * FROM #db.table("site", request.zos.zcoreDatasource)# site 
		WHERE site_id =#db.param(form.sid)# and 
		site_deleted=#db.param(0)# ";
		qCheck=db.execute("qCheck"); 
		/*
		if(request.zos.istestserver EQ false){
			if(qCheck.site_username_previous EQ "" and qCheck.site_username NEQ form.site_username){
				form.site_username_previous=qCheck.site_username;
				form.site_system_user_modified=1;
			}
			if(qCheck.site_password_previous EQ "" and qCheck.site_password NEQ form.site_password){
				form.site_password_previous=qCheck.site_password;
				form.site_system_user_modified=1;
			}    
		}*/
		if(qCheck.site_short_domain_previous EQ "" and qCheck.site_short_domain NEQ "" and form.site_short_domain NEQ "" and qCheck.site_short_domain NEQ form.site_short_domain){
			if(directoryexists(sdomain)){
				application.zcore.status.setStatus(Request.zsid, "The new domain already exists. Please rename or remove the existing folders before renaming this domain.",form,true);
				application.zcore.status.setFieldError(Request.zsid, "site_short_domain");
			}
			result=application.zcore.functions.zSecureCommand("renameSite"&chr(9)&qCheck.site_short_domain&chr(9)&form.site_short_domain, 10);
			if(result EQ 0){
				application.zcore.status.setStatus(Request.zsid, "Failed to rename domain.  The system may have a lock on the files.  Try restarting the web server.",form,true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/site/edit?sid=#form.sid#&zsid=#request.zsid#");
			}
		}
	}
	if(form.site_ssl_manager_domain NEQ "" and (currentMethod EQ "insert" or qCheck.site_ssl_manager_domain NEQ form.site_ssl_manager_domain)){
		db.sql="select site_id, site_domain from 
		#db.table("site", request.zos.zcoreDatasource)#
		where site_id <> #db.param(form.sid)# and 
		site_ssl_manager_domain = #db.param(form.site_ssl_manager_domain)# and 
		site_deleted = #db.param(0)# and
		site_active = #db.param(1)# ";
		qCheckManagerDomain=db.execute("qCheckManagerDomain");
		if(qCheckManagerDomain.recordcount){
			application.zcore.status.setStatus(Request.zsid, "Site ###qCheckManagerDomain.site_id#, #qCheckManagerDomain.site_domain#, has the same SSL manager domain. Please specify a unique domain.",form,true);
			application.zcore.status.setFieldError(Request.zsid, "site_ssl_manager_domain");
		}
	}
	if(structkeyexists(form, 'site_manage_links_enabled') EQ false or form.site_manage_links_enabled EQ ''){
		form.site_manage_links_enabled='0';
	}
	if(right(form.site_domain,1) EQ "/"){
		form.site_domain = left(form.site_domain, len(form.site_domain)-1);
	}
	if(right(form.site_securedomain,1) EQ "/"){
		form.site_securedomain = left(form.site_securedomain, len(form.site_securedomain)-1);
	}
	form.site_live=application.zcore.functions.zso(form, 'site_live',true);
	if(trim(form.site_homelinktext) EQ ""){					
		application.zcore.status.setStatus(Request.zsid, "Home link text is required",form,true);
		application.zcore.status.setFieldError(Request.zsid, "site_homelinktext");
	}
	if(form.site_reserved_url_app_ids NEQ ""){
		arrId=listtoarray(application.zcore.functions.zescape(form.site_reserved_url_app_ids));
		for(i=1;i LTE arraylen(arrId);i++){
			if(isnumeric(arrId[i]) EQ false or arrId[i] LTE 0 or arrId[i] GT 250){
				application.zcore.status.setStatus(Request.zsid, "App Url Ids must be comma separated list between 1 to 250.",form,true);
				application.zcore.status.setFieldError(Request.zsid, "site_reserved_url_app_ids");
				break;
			}
			arrId[i]=trim(arrId[i]);
		}
		if(currentMethod EQ "update"){
			var idList=arraytolist(arrId,"','");
			db.sql="select * from #db.table("app_reserve", request.zos.zcoreDatasource)# app_reserve 
			WHERE app_reserve_url_id IN (#db.trustedSQL("'#idList#'")#) and 
			app_reserve_deleted = #db.param(0)# and
			site_id = #db.param(form.sid)# ";
			qCheck2=db.execute("qCheck2"); 
			if(qcheck2.recordcount NEQ 0){
				for(i=1;i lte qcheck2.recordcount;i++){
					application.zcore.status.setStatus(Request.zsid, "App url id, ""#qcheck2.app_reserve_url_id[i]#"", was already reserved by an existing application instance.",form,true);
					application.zcore.status.setFieldError(Request.zsid, "site_reserved_url_app_ids");
				}
			}
		}
		
		form.site_reserved_url_app_ids=arraytolist(arrId);
	}
	
	if(application.zcore.status.getErrorCount(Request.zsid) NEQ 0){
		if(currentMethod EQ "update"){
			application.zcore.functions.zRedirect("/z/server-manager/admin/site/edit?sid=#form.sid#&zsid=#Request.zsid#");
		}else{
			application.zcore.functions.zRedirect("/z/server-manager/admin/site/add?newdomain=#application.zcore.functions.zso(form, 'newdomain')#&zsid=#Request.zsid#");
		}
	}
	
	
	
	inputStruct = StructNew();
	inputStruct.table = "site";
	inputStruct.struct=form;
	inputStruct.datasource=request.zos.zcoreDatasource;
	if(currentMethod EQ "insert"){
		form.site_id = application.zcore.functions.zInsert(inputStruct);
		if(form.site_id EQ false){
			application.zcore.status.setStatus(Request.zsid, "Fail to add site",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/site/add?newdomain=#application.zcore.functions.zso(form, 'newdomain')#&zsid=#Request.zsid#");
		}else{
			application.zcore.status.setStatus(Request.zsid, "Site, '#form.site_sitename#', Added Successfully.");
		}
		db.sql="INSERT INTO #db.table("rewrite_rule", request.zos.zcoreDatasource)#  
		SET site_id = #db.param(form.site_id)#, 
		rewrite_rule_image=#db.param('')#,
		rewrite_rule_zsa=#db.param('')#,
		rewrite_rule_site=#db.param('')#,
		rewrite_rule_deleted=#db.param(0)#,
		rewrite_rule_updated_datetime=#db.param(request.zos.mysqlnow)#";
		db.execute("q"); 
	}else{
	
		form.site_id = form.sid;
		db.sql="select * FROM #db.table("site", request.zos.zcoreDatasource)# site 
		WHERE site_id = #db.param(form.site_id)# and 
		site_deleted=#db.param(0)#";
		qsite=db.execute("qsite"); 
		if(form.site_live EQ 1 and qsite.site_live EQ 0){
			application.zcore.functions.zdownloadlink(form.site_domain&"/z/misc/site-map/xmloutput");
		}
		if(application.zcore.functions.zUpdate(inputStruct) EQ false){
			application.zcore.status.setStatus(Request.zsid, "Fail to update site",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/site/edit?sid=#form.sid#&zsid=#Request.zsid#");
		}else{
			application.zcore.status.setStatus(Request.zsid, "Site, '#form.site_sitename#', Updated Successfully.");
		}
	}
	application.zcore.functions.zSecureCommand("verifySitePaths", 20);
	if(currentMethod EQ "insert"){
		application.zcore.functions.zcreatedirectory(sdomain2&'zupload');
		application.zcore.functions.zcreatedirectory(sdomain2&'zcache');
		application.zcore.functions.zcreatedirectory(sdomain2&'_cache');
		application.zcore.functions.zcreatedirectory(sdomain2&'_cache/html');
		application.zcore.functions.zcreatedirectory(sdomain2&'_cache/scripts');
		application.zcore.functions.zcreatedirectory(sdomain2&'_cache/scripts/sentenceData');
		application.zcore.functions.zcreatedirectory(sdomain2&'_cache/scripts/skins');
		application.zcore.functions.zcreatedirectory(sdomain2&'_cache/scripts/templates');
		application.zcore.functions.zcreatedirectory(sdomain2&'_cache/scripts/emailTemplates');
	}
	if(structkeyexists(form, 'createUserBlogContent')){
		createUserBlogContent(form.site_id);
		
		if(structkeyexists(form, 'site_theme_sync_site_id') and form.site_theme_sync_site_id NEQ 0){ 
		}else{
	
			form.themename=application.zcore.functions.zso(form, 'themename',false,'default');
			if(form.themename NEQ ""){
				qthemedirectory=application.zcore.functions.zreaddirectory(request.zos.installPath&"themes/");
				foundtheme=false;
				for(i=1;i LTE qthemedirectory.recordcount;i++){
					if(qthemedirectory.type[i] eq "dir" and qthemedirectory.name[i] NEQ "." and qthemedirectory.name[i] NEQ ".." and form.themename EQ qthemedirectory.name[i]){
						foundtheme=true;
					}
				}
				application.zcore.functions.zSecureCommand("installThemeToSite"&chr(9)&replace(form.themename, chr(9), "", "all")&chr(9)&form.site_homedir, 20);
			}
		}
	}
	if(form.method EQ "insert"){
		if(structkeyexists(form, 'site_theme_sync_site_id') and form.site_theme_sync_site_id NEQ 0){
			// if box is checked, i should probably copy all of the site option groups, menus and app configuration as well so site works in almost 1 click.
			this.autoSyncSiteFiles(form.site_theme_sync_site_id, form.site_id); 
		}
	}
	if(form.site_option_group_url_id NEQ 0 and form.site_option_group_url_id NEQ ""){
		ts=StructNew();
		ts.arrId=arrayNew(1);
		arrayappend(ts.arrId,trim(form.site_option_group_url_id));
		ts.app_id=14;
		ts.site_id=form.site_id;
		rCom=application.zcore.app.reserveAppUrlId(ts);
	}
	application.zcore.functions.zOS_cacheSitePaths();
	application.zcore.functions.zOS_cacheSiteAndUserGroups(form.site_id);
	
	if(structkeyexists(form, 'createUserBlogContent')){
		// must run after the globals are updated
		application.zcore.app.appUpdateCache(form.site_id);
	}

	var rs=application.zcore.functions.zGenerateNginxMap();
	var result=application.zcore.functions.zSecureCommand("publishNginxSiteConfig"&chr(9)&form.site_id, 30);
	fail=false;
	if(result EQ ""){
		application.zcore.status.setStatus(request.zsid, "Unknown failure when publishing Nginx configuration", form, true);
		fail=true;
	}else{
		js=deserializeJson(result);
		if(not js.success){
			fail=true;
			application.zcore.status.setStatus(request.zsid, "Nginx site config publish failed: "&js.errorMessage, form, true);
		}
	}
	if(fail){
		if(form.method EQ "update"){
			application.zcore.functions.zRedirect("/z/server-manager/admin/site/edit?sid=#form.sid#&zsid=#Request.zsid#");
		}else{
			application.zcore.functions.zRedirect("/z/server-manager/admin/site/add?sid=#form.sid#&zsid=#Request.zsid#");
		}
	}
	application.zcore.status.setStatus(request.zsid, rs.message, form, not rs.success);
	
	// go back to site overview page
	updateMessage="";
	if((structkeyexists(form, 'site_system_user_modified') and form.site_system_user_modified EQ 1) or (structkeyexists(form, 'site_system_user_created') and form.site_system_user_created EQ 0)){
		updateMessage="You may need to wait up to 10 seconds for the system to update.  If there are problems after 10 seconds, debug ""php #request.zos.scriptDirectory#newsite.php"" on the command line.  It is a cron job.";
	}
	application.zcore.status.setStatus(Request.zsid, "Saved. "&updateMessage);
	application.zcore.functions.zRedirect('/z/server-manager/admin/site-select/index?action=select&sid=#form.site_id#&zid='&form.zid&'&zsid='&request.zsid);
	</cfscript>
</cffunction>

<cffunction name="createUserBlogContent" localmode="modern" access="public">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	form.site_id=arguments.site_id;

	db.sql="INSERT INTO #db.table("app_x_site", request.zos.zcoreDatasource)#  (app_x_site_deleted, `app_id`,`site_id`,`app_x_site_status`, app_x_site_updated_datetime) VALUES #db.trustedSQL("(0, '10','#form.site_id#','1', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}else{
		qId1={id:local.rs.result};
	}
	db.sql="INSERT INTO #db.table("app_x_site", request.zos.zcoreDatasource)#  (app_x_site_deleted, `app_id`,`site_id`,`app_x_site_status`, app_x_site_updated_datetime) VALUES #db.trustedSQL("(0, '12','#form.site_id#','1', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}else{
		qId2={id:local.rs.result};
	}
	 db.sql="INSERT INTO #db.table("content_config", request.zos.zcoreDatasource)#  (content_config_deleted, `content_config_url_article_id`,`content_config_sidebar_tag`,`content_config_url_listing_user_id`,`content_config_inquiry_qualify`,`content_config_override_stylesheet`,`content_config_phone_required`,`content_config_default_subpage_link_layout`,`content_config_default_parentpage_link_layout`,`content_config_hide_inquiring_about`,`content_config_email_required`,`app_x_site_id`,`site_id`, content_config_updated_datetime, `content_config_contact_links`) VALUES #db.trustedSQL("(0, '6','','5','0','0','1','0','7','0','1','#qId2.id#','#form.site_id#', '#request.zos.mysqlnow#', '0')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	
	 db.sql="INSERT INTO #db.table("blog_config", request.zos.zcoreDatasource)#  (blog_config_deleted, `blog_config_title`,`blog_config_subtitle`,`blog_config_stylesheet`,`blog_config_manager_stylesheet`,`blog_config_root_url`,`blog_config_url_article_id`,`blog_config_url_category_id`,`blog_config_url_misc_id`,`blog_config_url_tag_id`,`blog_config_recent_name`,`blog_config_url_format`,`blog_config_category_home_name`,`blog_config_recent_url`,`blog_config_category_home_url`,`blog_config_archive_name`,`blog_config_home_url`,`blog_config_include_sidebar`,`blog_config_show_detail`,`app_x_site_id`,`site_id`, blog_config_updated_datetime) VALUES 
	 #db.trustedSQL("(0, 'Blog','','/z/a/blog/stylesheets/style.css','','{default}','1','2','3','4','Recent Articles','/##name##-##appid##-##id##.##ext##','Blog Categories','{default}','{default}','archive','/','0','0','#qId1.id#','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	 
	db.sql="INSERT INTO #db.table("app_reserve", request.zos.zcoreDatasource)#  (app_reserve_deleted, `app_reserve_url_id`,`site_id`, `app_id`, app_reserve_updated_datetime) VALUES #db.trustedSQL("(0, '6','#form.site_id#', 12, '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("app_reserve", request.zos.zcoreDatasource)#  (app_reserve_deleted, `app_reserve_url_id`,`site_id`, `app_id`, app_reserve_updated_datetime) VALUES #db.trustedSQL("(0, '5','#form.site_id#', 10, '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("app_reserve", request.zos.zcoreDatasource)#  (app_reserve_deleted, `app_reserve_url_id`,`site_id`, `app_id`, app_reserve_updated_datetime) VALUES #db.trustedSQL("(0, '1','#form.site_id#', 10, '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("app_reserve", request.zos.zcoreDatasource)#  (app_reserve_deleted, `app_reserve_url_id`,`site_id`, `app_id`, app_reserve_updated_datetime) VALUES #db.trustedSQL("(0, '2','#form.site_id#', 10, '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("app_reserve", request.zos.zcoreDatasource)#  (app_reserve_deleted, `app_reserve_url_id`,`site_id`, `app_id`, app_reserve_updated_datetime) VALUES #db.trustedSQL("(0, '3','#form.site_id#', 10, '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("app_reserve", request.zos.zcoreDatasource)#  (app_reserve_deleted, `app_reserve_url_id`,`site_id`, `app_id`, app_reserve_updated_datetime) VALUES #db.trustedSQL("(0, '4','#form.site_id#', 10, '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("user_group", request.zos.zcoreDatasource)#  (user_group_deleted, `user_group_name`,`user_group_friendly_name`,`site_id`,`user_group_primary`, user_group_updated_datetime) VALUES #db.trustedSQL("(0,   'administrator','','#form.site_id#','0', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}else{
		qId1={id:local.rs.result};
	}
	db.sql="INSERT INTO #db.table("user_group", request.zos.zcoreDatasource)#  (user_group_deleted, `user_group_name`,`user_group_friendly_name`,`site_id`,`user_group_primary`, user_group_updated_datetime) VALUES #db.trustedSQL("(0,   'agent','','#form.site_id#','0', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}else{
		qId2={id:local.rs.result};
	}
	db.sql="INSERT INTO #db.table("user_group", request.zos.zcoreDatasource)#  (user_group_deleted, `user_group_name`,`user_group_friendly_name`,`site_id`,`user_group_primary`, user_group_updated_datetime) VALUES #db.trustedSQL("(0,   'broker','','#form.site_id#','0', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}else{
		qId3={id:local.rs.result};
	}
	 db.sql="INSERT INTO #db.table("user_group", request.zos.zcoreDatasource)#  (user_group_deleted, `user_group_name`,`user_group_friendly_name`,`site_id`,`user_group_primary`, user_group_updated_datetime) VALUES #db.trustedSQL("(0,   'member','','#form.site_id#','1', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}else{
		qId4={id:local.rs.result};
	}
	db.sql="INSERT INTO #db.table("user_group", request.zos.zcoreDatasource)#  (user_group_deleted, `user_group_name`,`user_group_friendly_name`,`site_id`,`user_group_primary`, user_group_updated_datetime) VALUES #db.trustedSQL("(0,  'user','','#form.site_id#','0', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}else{
		qId5={id:local.rs.result};
	}
	//administrator
	 db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) VALUES #db.trustedSQL("(0,  '#qId1.id#','#qId1.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) VALUES #db.trustedSQL("(0,  '#qId1.id#','#qId2.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) VALUES #db.trustedSQL("(0,  '#qId1.id#','#qId3.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) VALUES #db.trustedSQL("(0,  '#qId1.id#','#qId4.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) VALUES #db.trustedSQL("(0,  '#qId1.id#','#qId5.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	
	//agent
	 db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) VALUES #db.trustedSQL("(0,  '#qId2.id#','#qId2.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) VALUES #db.trustedSQL("(0,  '#qId2.id#','#qId4.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) VALUES #db.trustedSQL("(0,  '#qId2.id#','#qId5.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	//broker
	db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) VALUES #db.trustedSQL("(0,  '#qId3.id#','#qId3.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) VALUES #db.trustedSQL("(0,  '#qId3.id#','#qId2.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) VALUES #db.trustedSQL("(0,  '#qId3.id#','#qId4.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) VALUES #db.trustedSQL("(0,  '#qId3.id#','#qId5.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	
	//member
	db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) 
	VALUES #db.trustedSQL("(0,  '#qId4.id#','#qId4.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) 
	VALUES #db.trustedSQL("(0,  '#qId4.id#','#qId5.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	
	//user
	db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  (user_group_x_group_deleted, `user_group_id`,`user_group_child_id`,`user_group_login_access`,`user_group_modify_user`,`user_group_share_user`,`site_id`, user_group_x_group_updated_datetime) 
	VALUES #db.trustedSQL("(0, '#qId5.id#','#qId5.id#','1','0','0','#form.site_id#', '#request.zos.mysqlnow#')")#";
	local.rs=db.insert("insertCheck", request.zOS.insertIDColumnForSiteIDTable); 
	if(not local.rs.success){
		application.zcore.template.fail("Failed to create site.  See the sql errors below.");	
	}
	</cfscript>
</cffunction>

<cffunction name="newDomain" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	</cfscript>
	<h2>Add Site</h2>
	<form action="/z/server-manager/admin/site/add" method="get">
    	New Domain: <input type="text" name="newdomain" value="" /> (format: domain.com)
        <br /><br />
        <input type="submit" name="submit1" value="Submit" />
        <input type="button" name="cancel1" value="Cancel" onclick="window.location.href='/z/server-manager/admin/site-select/index';" />
    </form>
</cffunction>



<cffunction name="add" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	if(not structkeyexists(form, 'newdomain')){
		application.zcore.functions.zRedirect("/z/server-manager/admin/site-select/index?action=list");
	}
	form.newdomain=lcase(trim(form.newdomain));
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qSites=0;
	var qWebsite=0;
	var curAction=0;
	var currentMethod=0;
        var selectStruct=0;
	var arrThemes=0;
	var i=0;
	var qthemedirectory=0;
	var currentMethod=0;
	var noGroupsOrApps=0;
	var qc=0;
	var qc2=0;
	var defaultIp=0;
	var firstIp=0;
	var defaultIpSet=0;
	var arrS=0;
	var arrS2=0;
	var arrD=0;
	var arrIp=0;
	var d=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8.1.1.1");
	form.sid=application.zcore.functions.zso(form, 'sid', false, '');
	currentMethod=form.method;
	db.sql="SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id = #db.param(form.sid)# and 
	site_deleted=#db.param(0)#  ";
	qWebSite=db.execute("qWebSite");
	db.sql="SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id <> #db.param(form.sid)# and 
	site_deleted = #db.param(0)#";
	if(not application.zcore.user.checkAllCompanyAccess()){
		db.sql&=" and company_id = #db.param(request.zsession.user.company_id)#";
	}
	db.sql&=" ORDER BY site_sitename ASC";
	qSites=db.execute("qSites");
	if(qWebSite.recordcount EQ 0 and currentMethod EQ "edit"){
		application.zcore.functions.zRedirect("/z/server-manager/admin/site-select/index?sid=");	
	}
	application.zcore.functions.zQueryToStruct(qWebSite);
	if(currentMethod EQ "add"){
		form.site_sitename=replace(form.newdomain,"www.","");
		form.site_homedir=application.zcore.functions.zGetDomainInstallPath(form.newdomain);
		form.site_privatehomedir=application.zcore.functions.zGetDomainWritableInstallPath(form.newdomain);
		form.site_datasource=request.zos.zcoreDatasource;
		form.site_homelinktext='Home';
		if(request.zos.istestserver){
			form.site_email_campaign_from=request.zos.developerEmailFrom;
			form.site_admin_email=request.zos.developerEmailTo;
		}else{
			form.site_email_campaign_from="news@"&form.newdomain;
			form.site_admin_email=form.site_email_campaign_from;
		}
		form.site_active='1';
		form.site_debug_enabled='1';
		form.site_editor_stylesheet='/stylesheets/style-manager.css';
		local.www="www.";
		if(listlen(form.newdomain,".") GT 2){
			local.www="";
		}
		if(request.zos.istestserver){
			form.site_domain='http://'&local.www&form.newdomain&'.'&request.zos.testDomain;
			form.site_short_domain=local.www&form.newdomain&"."&request.zos.testDomain;
		}else{
			form.site_short_domain=form.newdomain;
			form.site_domain='http://'&local.www&form.newdomain;
		}
		form.site_username=replace(replace(listdeleteat(form.newdomain, listlen(form.newdomain, "."), "."),"www.",""),".","","all");
		
	}
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>
    
		<h2><cfif currentMethod EQ "edit">Edit<cfelse>Add</cfif> Site</h2>
		<form action="/z/server-manager/admin/site/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?sid=#form.sid#" method="post">
		<input type="hidden" name="newdomain" value="#htmleditformat(application.zcore.functions.zso(form, 'newdomain'))#" />

		<cfscript>
		tabCom=createobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic","Advanced", "CallTrackingMetrics"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-site-edit");
		cancelURL="/z/server-manager/admin/site-select/index?zid=#form.zid#&action=select&sid=#form.sid#";
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#

		<table style="width:100%; border-spacing:0px;" class="table-list">
		<cfif application.zcore.user.checkAllCompanyAccess()>
			<tr>
				<td style="vertical-align:top; width:140px;">Company:</td>
				<td  #application.zcore.status.getErrorStyle(Request.zsid, "company_id", "table-error","")#>
				
				<cfscript>
				db.sql="SELECT *
				FROM #db.table("company", request.zos.zcoreDatasource)# company
				WHERE company_deleted = #db.param(0)# ";
				if(request.zsession.user.company_id NEQ 0){
					db.sql&=" and company_id = #db.param(request.zsession.user.company_id)#";
				}
				db.sql&=" ORDER BY company_name ASC";
				qcompany=db.execute("qcompany");
				selectStruct = StructNew();
				selectStruct.name = "company_id";
				selectStruct.query = qCompany;
				selectStruct.queryLabelField = "company_name";
				selectStruct.queryValueField = "company_id";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
			</tr>
		</cfif>
		<tr>
			<td style="vertical-align:top; width:140px;">Parent Site:</td>
			<td  #application.zcore.status.getErrorStyle(Request.zsid, "site_parent_id", "table-error","")#>
			
		<cfscript>
		selectStruct = StructNew();
		selectStruct.name = "site_parent_id";
		selectStruct.query = qSites;
		selectStruct.queryLabelField = "site_sitename";
		selectStruct.queryValueField = "site_id";
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript></td>
		</tr>
		<cfscript>
		if(form.site_short_domain NEQ ""){
			managerShortName=listGetAt(replace(form.site_short_domain, "www.", ""), 1, ".");
			if(managerShortName NEQ ""){
				managerShortName&=".";
			}
		}
		</cfscript>
		<tr >
			<td style="vertical-align:top; width:140px;">SSL Manager Domain:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_ssl_manager_domain", "table-error","")#><input name="site_ssl_manager_domain" type="text" size="70" maxlength="255" value="<cfif form.site_ssl_manager_domain EQ "" and request.zos.defaultSSLManagerDomain NEQ "">#managerShortName##request.zos.defaultSSLManagerDomain#<cfelse>#form.site_ssl_manager_domain#</cfif>"></td>
		</tr>
        
		<tr>
			<td style="vertical-align:top; width:140px;">IP Address:</td>
			<td  #application.zcore.status.getErrorStyle(Request.zsid, "site_ip_address", "table-error","")#>
				<cfscript>
				ipStruct=application.zcore.functions.getSystemIpStruct();

				/*if(form.site_ip_address EQ ""){
					form.site_ip_address=ipStruct.defaultIp;
				}*/
				ipStruct2={};
				if(structkeyexists(request.zos, 'arrAdditionalLocalIp')){
					for(i=1;i LTE arraylen(request.zos.arrAdditionalLocalIp);i++){
						ipStruct2[request.zos.arrAdditionalLocalIp[i]]=true;
					}
				}
				for(i=1;i LTE arraylen(ipStruct.arrIp);i++){
					ipStruct2[ipStruct.arrIp[i]]=true;
				}
				arrIp=structkeyarray(ipStruct2);
				arraysort(arrIp, "text", "asc");
				selectStruct = StructNew();
				selectStruct.name = "site_ip_address";
				selectStruct.listvalues=arraytolist(arrIp,",");
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript>
			</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Short Domain:</td>
			<td><input name="site_short_domain" type="text" size="70" maxlength="255" value="#htmleditformat(form.site_short_domain)#"><br />
            You must exclude. www., http:// and the test domain.  I.e. domain.com or subdomain.domain.com. This field is used for the root directory name for this domain.</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Site Name:</td>
			<td  #application.zcore.status.getErrorStyle(Request.zsid, "site_sitename", "table-error","")#><input name="site_sitename" type="text" size="70" maxlength="255" value="#form.site_sitename#"></td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Domain:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_domain", "table-error","")#><input name="site_domain" type="text" size="70" maxlength="255" value="#form.site_domain#"></td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Secure Domain:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_securedomain", "table-error","")#><input name="site_securedomain" type="text" size="70" maxlength="255" value="#form.site_securedomain#"></td>
		</tr>
		
		<tr >
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_require_ssl_for_user", "table-error","")#><input name="site_require_ssl_for_user" type="checkbox" value="1" <cfif form.site_require_ssl_for_user EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Require SSL for user logins? (Only works if Secure Domain field is not empty)</td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Domain Aliases:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_domainaliases", "table-error","")#><input name="site_domainaliases" type="text" size="70" maxlength="255" value="#form.site_domainaliases#"> (Enter a comma separated list of all allowed domain aliases. Example: test.client1.com,newsite.client2.com)</td>
		</tr> 
		<tr >
			<td style="vertical-align:top; width:140px;">Developer Email:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_developer_email", "table-error","")#><input name="site_developer_email" type="text" size="70" maxlength="50" value="#form.site_developer_email#"> (Used when working with a third party developer.  Certain support emails will be sent to them rather then your company.)</td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Site Admin Email:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_admin_email", "table-error","")#><input name="site_admin_email" type="text" size="70" maxlength="50" value="#form.site_admin_email#"> (Make sure you have SPF/DKIM permission to use this email address domain on this server.  AOL/YAHOO and others will be blocked.)</td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Bulk Email Signature:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_email_signature", "table-error","")#><textarea name="site_email_signature" type="text" cols="70" rows="6">#form.site_email_signature#</textarea><br />Note: Don't use html here.</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Home Link Text:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_homelinktext", "table-error","")#><input name="site_homelinktext" type="text" size="70" maxlength="100" value="#form.site_homelinktext#"></td>
		</tr>
        
		<tr >
			<td style="vertical-align:top; width:140px;">Email Campaign From:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_email_campaign_from", "table-error","")#><input name="site_email_campaign_from" type="text" size="70" maxlength="50" value="#form.site_email_campaign_from#"> (Default email address for email campaigns and opt-in confirmations)</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_active" type="checkbox" value="1" <cfif form.site_active EQ 1 or form.site_active EQ "">checked="checked"</cfif> style="background:none; border:none;"> Active?</td>
		</tr>
		
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_send_confirm_opt_in" type="checkbox" value="1" <cfif form.site_send_confirm_opt_in EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Confirm Opt-in?</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_live" type="checkbox" value="1" <cfif form.site_live EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Is this site live? WARNING: Do not check unless it is ready because XML Sitemap will start pinging when it is live.</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_require_login" type="checkbox" value="1" <cfif form.site_require_login EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Require login?<br /><br />
			Bypass IP List: <input type="text" name="site_require_login_bypass_ip_list" value="#htmleditformat(form.site_require_login_bypass_ip_list)#" /> (Useful for mobile testing.  This setting is inherited by child sites.)</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">MVC Paths:</td>
			<td><input name="site_mvcpaths" type="text" size="100" value="#htmleditformat(form.site_mvcpaths)#" /><br /> (Comma separate root relative paths i.e. mvc,admin.mvc)</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Site Option Group URL ID: </td>
			<td>
				<cfscript> 
				// excluding 1 to 9 prevents conflicts with the "install default apps" feature so that blog and content apps are auto-installed correctly.
				arrExclude=[];
				for(i=1;i LTE 9;i++){
					if(form.site_option_group_url_id NEQ i){
						arrayAppend(arrExclude, i);
					}
				}
				writeoutput(application.zcore.app.selectAppUrlId("site_option_group_url_id", form.site_option_group_url_id, 14, arrayToList(arrExclude, ",")));
				</cfscript>
			</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Max Image Width:</td>
			<td><input name="site_max_image_width" type="text" value="<cfif form.site_max_image_width EQ "" or form.site_max_image_width EQ 0>695<cfelse>#form.site_max_image_width#</cfif>"></td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Shared Default Theme:</td>
			<td>
			<cfscript>
			themeCom=createobject("zcorerootmapping.mvc.z.admin.controller.theme");
			themeStruct=themeCom.getThemeStruct();
			
			ts={};
			ts.name="site_theme_name";
			ts.listValues =structkeylist(themeStruct,"/"); 
			ts.listValuesDelimiter = "/";
			application.zcore.functions.zInputSelectBox(ts);
			
			</cfscript> (Overrides the default template to use a shared theme as the default template.)</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_lock_theme" type="checkbox" value="1" <cfif form.site_lock_theme EQ 1 or form.site_lock_theme EQ "">checked="checked"</cfif> style="background:none; border:none;"> Lock Theme? (This will prevent site manager users from changing the design of a custom built web site.)</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Enable CSS Framework?</td>
			<td >#application.zcore.functions.zInput_Boolean("site_enable_css_framework")#</td>
		</tr>
        <cfscript>
		noGroupsOrApps=false;
		if(currentMethod EQ "edit"){
			db.sql="select count(user_group_id) c from #db.table("user_group", request.zos.zcoreDatasource)# user_group 
			WHERE site_id = #db.param(form.sid)# and 
			user_group_deleted = #db.param(0)#";
			qc=db.execute("qc"); 
			db.sql="select count(app_x_site_id) c from #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
			WHERE site_id = #db.param(form.sid)# and 
			app_x_site_deleted = #db.param(0)#";
			qc2=db.execute("qc2"); 
			if((qc.recordcount EQ 0 or qc.c EQ 0) and (qc.recordcount EQ 0 or qc.c EQ 0)){
				noGroupsOrApps=true;
			}
		}
		</cfscript>
		
        <cfif currentMethod EQ "add" or noGroupsOrApps>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="createUserBlogContent" type="checkbox" value="1" <cfif structkeyexists(form, 'createUserBlogContent')>checked="checked"</cfif> style="background:none; border:none;"> Install Default Apps? | Note: It is best to have an empty directory prior to installation.</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Theme:</td>
			<td><cfscript>
			qthemedirectory=application.zcore.functions.zreaddirectory(request.zos.installPath&"themes/");
			arrThemes=arraynew(1);
			for(i=1;i LTE qthemedirectory.recordcount;i++){
				if(qthemedirectory.type[i] eq "dir" and qthemedirectory.name[i] NEQ "." and qthemedirectory.name[i] NEQ ".."){
					arrayappend(arrThemes, qthemedirectory.name[i]);
				}
			}
			form.themename=application.zcore.functions.zso(form,'themename',false,'');
			selectStruct = StructNew();
			selectStruct.name = "themename";
			selectStruct.listvalues=arraytolist(arrThemes, ",");
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript> | You can install new themes in #request.zos.installPath#themes/ | Only installed if you check box for "Install Default Apps".<br />
			<br />
			Or clone an existing site: 
			<cfscript>
			db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
			WHERE site_active = #db.param(1)# and 
			site_id <> #db.param(-1)# and 
			site_deleted = #db.param(0)#";
			if(not application.zcore.user.checkAllCompanyAccess()){
				db.sql&=" and company_id = #db.param(request.zsession.user.company_id)#";
			}
			db.sql&=" ORDER BY site_short_domain ASC";
			local.qActiveSites=db.execute("qActiveSites");
			selectStruct = StructNew();
			selectStruct.name = "clone_site_id";
			selectStruct.query = local.qActiveSites;
			selectStruct.queryLabelField = "site_sitename";
			selectStruct.queryValueField = "site_id";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript> | Autosync child files: 
			#application.zcore.functions.zInput_Boolean("site_child_sync")# 
			<br /><br />
			Warning: Selecting a theme or site WILL overwrite any files in the site directory the first time you do this if it already exists.
			</td>
		</tr> 
        </cfif>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Advanced")#
		<table style="width:100%; border-spacing:0px;" class="table-list">
        <cfif request.zos.istestserver EQ false>
		<tr>
			<td style="vertical-align:top; width:140px;">System Username:</td>
			<td  #application.zcore.status.getErrorStyle(Request.zsid, "site_username", "table-error","")#><input name="site_username" type="text" size="70" maxlength="32" value="#htmleditformat(form.site_username)#" /> 
			<input type="checkbox" name="useExistingUsername" value="1" <cfif application.zcore.functions.zso(form, 'useExistingUsername') EQ 1>checked="checked"</cfif> /> Use existing username?<br />
            </td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">System Password:</td>
			<td  #application.zcore.status.getErrorStyle(Request.zsid, "site_password", "table-error","")#><input name="site_password" type="text" size="70" value="<cfif currentMethod EQ "add" and form.site_password EQ "">#htmleditformat(application.zcore.functions.zGenerateStrongPassword())#<cfelse>#htmleditformat(form.site_password)#</cfif>" /><br />
            <cfif currentMethod EQ "add">This password was randomly generated right now.<br /></cfif>
            Must be 20+ characters. The password is stored as plain text since system admin should be secure via SSH tunneling instead.</td>
		</tr>
        </cfif>
		<!--- This field doesn't work anymore <tr>
			<td style="vertical-align:top; width:140px;">Site Root:</td>
			<td><input name="site_siteroot" type="text" size="70" maxlength="255" value="#form.site_siteroot#"> (i.e. /mysiteroot)</td>
		</tr> --->
		<tr>
			<td style="vertical-align:top; width:140px;">Post Login URL:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_member_post_login_url", "table-error","")#><input name="site_member_post_login_url" type="text" size="70" maxlength="100" value="#htmleditformat(form.site_member_post_login_url)#"> Note: Public users that manually login will be redirected to this url automatically.</td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Google Maps API Key:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_google_maps_api_key", "table-error","")#><input name="site_google_maps_api_key" type="text" size="70" maxlength="100" value="#form.site_google_maps_api_key#"></td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Datasource:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_datasource", "table-error","")#><input name="site_datasource" type="text" size="70" maxlength="50" value="#form.site_datasource#"></td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Email Enabled</td>
			<td><input name="site_email_active" type="checkbox" value="1" <cfif form.site_email_active EQ 1>checked="checked"</cfif> style="background:none; border:none;"> (Check the box to enable a custom POP/SMTP server for all emails.)</td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Email POP Server:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_email_popserver", "table-error","")#><input name="site_email_popserver" type="text" size="70" maxlength="50" value="#form.site_email_popserver#"></td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Email SMTP Server:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_email_smtpserver", "table-error","")#><input name="site_email_smtpserver" type="text" size="70" maxlength="50" value="#form.site_email_smtpserver#"></td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Email Username:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_email_username", "table-error","")#><input name="site_email_username" type="text" size="70" maxlength="50" value="#htmleditformat(form.site_email_username)#"></td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Email Password:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_email_password", "table-error","")#><input name="site_email_password" type="text" size="70" maxlength="50" value="#htmleditformat(form.site_email_password)#"></td>
		</tr>
        
		<tr >
			<td style="vertical-align:top; width:140px;">Email Connection:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_email_ssl", "table-error","")#><input name="site_email_ssl" type="radio" value="1"  <cfif form.site_email_ssl EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Use SSL <input name="site_email_ssl" type="radio" value="2"  <cfif form.site_email_ssl EQ 2>checked="checked"</cfif> style="background:none; border:none;"> Use TLS  <input name="site_email_ssl" type="radio" value="0"  <cfif form.site_email_ssl EQ 0 or form.site_email_ssl EQ "">checked="checked"</cfif> style="background:none; border:none;"> Not Secure |  SMTP Port: <input name="site_email_port" type="text" size="6" maxlength="5" value="<cfif form.site_email_port EQ "">25<cfelse>#form.site_email_port#</cfif>"> | SMTP Authentication? <input name="site_email_smtp_authentication" type="checkbox" value="1"  <cfif form.site_email_smtp_authentication EQ 1>checked="checked"</cfif> style="background:none; border:none;"> </td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Custom Create Account URL:</td>
			<td><input name="site_custom_create_account_url" type="text" size="70" maxlength="255" value="#htmleditformat(form.site_custom_create_account_url)#"></td>
		</tr>

		<tr>
			<td style="vertical-align:top; width:140px;">Disable New User Email?:</td>
			<td >#application.zcore.functions.zInput_Boolean("site_disable_new_user_email")#</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Enable Lead User Reminder:</td>
			<td >#application.zcore.functions.zInput_Boolean("site_enable_lead_user_reminder")#</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Enable Lead Admin Reminder:</td>
			<td >#application.zcore.functions.zInput_Boolean("site_enable_lead_admin_reminder")#</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Enable Lead Reminder For Users:</td>
			<td >#application.zcore.functions.zInput_Boolean("site_enable_lead_reminder_disable_cc")#</td>
		</tr>
		<cfscript>
		if(form.method EQ "add"){
			form.site_lead_reminder_email1_delay_minutes=720;
		}
		</cfscript>
		<tr>
			<td style="vertical-align:top; width:140px;">Lead Reminder 1 Delay:</td>
			<td><input name="site_lead_reminder_email1_delay_minutes" type="number" value="#htmleditformat(form.site_lead_reminder_email1_delay_minutes)#"> minutes<br />Enter the delay between the assignment and first reminder.  0 disables the reminder.</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Lead Reminder 2 Delay:</td>
			<td><input name="site_lead_reminder_email2_delay_minutes" type="number" value="#htmleditformat(form.site_lead_reminder_email2_delay_minutes)#"> minutes<br />Enter the delay between the first and second reminder.  0 disables the reminder.</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Lead Reminder 3 Delay:</td>
			<td><input name="site_lead_reminder_email3_delay_minutes" type="number" value="#htmleditformat(form.site_lead_reminder_email3_delay_minutes)#"> minutes<br />Enter the delay between the second and third reminder.  0 disables the reminder.</td>
		</tr>
 
		<!--- <tr >
			<td style="vertical-align:top; width:140px;">Link Email Address:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_email_link_from", "table-error","")#><input name="site_email_link_from" type="text" size="70" maxlength="50" value="#form.site_email_link_from#"></td>
		</tr>     --->    
		<tr >
			<td style="vertical-align:top; width:140px;">Content URL ID:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_content_url_id", "table-error","")#><input name="site_content_url_id" type="text" size="70" maxlength="50" value="#form.site_content_url_id#"></td>
		</tr>   

		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_enable_nginx_proxy_cache" type="checkbox" value="1" <cfif form.site_enable_nginx_proxy_cache EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Nginx Proxy Cache?</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_disable_dns_monitor" type="checkbox" value="1" <cfif form.site_disable_dns_monitor EQ 1 or form.site_disable_dns_monitor EQ "">checked="checked"</cfif> style="background:none; border:none;"> Disable DNS Monitor?</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_enable_user_stats" type="checkbox" value="1" <cfif form.site_enable_user_stats EQ 1 or form.site_enable_user_stats EQ "">checked="checked"</cfif> style="background:none; border:none;"> Enable User Stats Cookies?</td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_disable_openid", "table-error","")#><input name="site_disable_openid" type="checkbox" value="1" <cfif form.site_disable_openid EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Disable OpenID Login?</td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_disable_global_login_message", "table-error","")#><input name="site_disable_global_login_message" type="checkbox" value="1" <cfif form.site_disable_global_login_message EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Disable Global Login Message?</td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_login_iframe_enabled", "table-error","")#><input name="site_login_iframe_enabled" type="checkbox" value="1" <cfif form.site_login_iframe_enabled EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Iframe Login?</td>
		</tr>

        
		<tr >
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_plain_text_password", "table-error","")#><input name="site_plain_text_password" type="checkbox" value="1" <cfif form.site_plain_text_password EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable plain text user password storage?</td>
		</tr>
        
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_disable_cfml" type="checkbox" value="1" <cfif form.site_disable_cfml EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Disable CFML?</td>
		</tr>
		
		<!--- has no purpose <tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_allow_activation" type="checkbox" value="1" <cfif form.site_allow_activation EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Allow Activation? </td>
		</tr> --->
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_debug_enabled" type="checkbox" value="1" <cfif form.site_debug_enabled EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Debugging?</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_widget_builder_enabled" type="checkbox" value="1" <cfif form.site_widget_builder_enabled EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Widget Builder?</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_enable_demo_mode" type="checkbox" value="1" <cfif form.site_enable_demo_mode EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Demo Mode?</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_unit_testing_domain" type="checkbox" value="1" <cfif form.site_unit_testing_domain EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Unit Testing?</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_publish_enabled" type="checkbox" value="1" <cfif form.site_publish_enabled EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Publishing?</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_track_users" type="checkbox" value="1" <cfif form.site_track_users EQ 1 or form.site_track_users EQ "">checked="checked"</cfif> style="background:none; border:none;"> Track users? (Verifies visitor tracking code)</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_require_captcha" type="checkbox" value="1" <cfif form.site_require_captcha EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Require Captcha By Default on Public Forms?</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Recaptcha Secret Key</td>
			<td><input name="site_recaptcha_secretkey" type="text" value="#htmleditformat(form.site_recaptcha_secretkey)#" /> (Must register each site <a href="https://www.google.com/recaptcha/admin" target="_blank">here</a></td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Recaptcha Site Key</td>
			<td><input name="site_recaptcha_sitekey" type="text" value="#htmleditformat(form.site_recaptcha_sitekey)#" /></td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_require_secure_login" type="checkbox" value="1" <cfif form.site_require_secure_login EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Require secure login for Site Manager? (Permanent cookie login behavior)</td>
		</tr>
        
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_enable_jquery_ui" type="checkbox" value="1" <cfif form.site_enable_jquery_ui EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Jquery UI?</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_enable_instant_load" type="checkbox" value="1" <cfif form.site_enable_instant_load EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Instant Load?</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_enable_mincat" id="site_enable_mincat" type="checkbox" value="1" <cfif form.site_enable_mincat EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Minify &amp; Concat of CSS/JS files? (Not working - needs rewrite)</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_enable_spritemap" type="checkbox" onclick="if(this.checked){document.getElementById('site_enable_mincat').checked=true;}" value="1" <cfif form.site_enable_spritemap EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Spritemap?</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_multidomain_enabled" type="checkbox" value="1" <cfif (currentMethod EQ "add" and form.site_multidomain_enabled EQ "") or form.site_multidomain_enabled EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Multiple Domain Static File Loading? (disable with SSL web site)</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_enable_ssi_publish" type="checkbox" value="1" <cfif form.site_enable_ssi_publish EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Server Side Include Publishing?</td>
		</tr>


		<tr >
			<td style="vertical-align:top; width:140px;">Privacy Policy<br />Share With Partners:</td>
			<td >#application.zcore.functions.zInput_Boolean("site_privacy_share_with_partners")#</td>
		</tr>
        
		<tr>
			<td style="vertical-align:top; width:140px;">&nbsp;</td>
			<td><input name="site_manage_links_enabled" type="checkbox" value="1" <cfif form.site_manage_links_enabled EQ 1>checked="checked"</cfif> style="background:none; border:none;"> Enable Link Manager?</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Link Dir Rewrite ID:</td>
			<td><input name="site_manage_links_url_id" type="text" value="#form.site_manage_links_url_id#"></td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Link Page URL:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_manage_links_url", "table-error","")#><input name="site_manage_links_url" type="text" size="70" maxlength="255" value="#form.site_manage_links_url#"></td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Link Page Script Path:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_manage_links_scriptpath", "table-error","")#><input name="site_manage_links_scriptpath" type="text" size="70" maxlength="255" value="#form.site_manage_links_scriptpath#"> (Root relative script path to prevent spider abuse)</td>
		</tr>
        <tr>
        <td style="vertical-align:top; width:140px;">App Url Id List:</td>
        <td #application.zcore.status.getErrorStyle(Request.zsid, "site_reserved_url_app_ids", "table-error","")#><input type="text" name="site_reserved_url_app_ids" value="#form.site_reserved_url_app_ids#"> (Comma separated list of all MANUALLY reserved Application IDs)</td>
        </tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Editor CSS URL:</td>
			<td><input name="site_editor_stylesheet" size="100" type="text" value="#form.site_editor_stylesheet#"></td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">TypeKit.com JS URL:</td>
			<td><input name="site_typekit_url" type="text" size="100" value="#htmleditformat(form.site_typekit_url)#"> (The "src" attribute of the javascript code)</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Fonts.com CSS URL:</td>
			<td><input name="site_fonts_com_url" type="text" size="100" value="#htmleditformat(form.site_fonts_com_url)#"> (The "href" attribute of the css link code)</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Editor Fonts:</td>
			<td><input name="site_editor_fonts" type="text" size="100" value="#htmleditformat(form.site_editor_fonts)#"> (Syntax: "Arial=arial,helvetica,sans-serif;"+)</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Font Lists:</td>
			<td><input name="site_fontlist" type="text" size="100" value="#htmleditformat(form.site_fontlist)#"><br /> (List all custom web fonts with a pipe, "|", separating them. You can also set failback fonts by adding comma separated alternate fonts. Example: Futura, sans-serif|Sabon, times new roman)</td>
		</tr>
		<tr>
			<td style="vertical-align:top; width:140px;">Disqus Shortname:</td>
			<td><input name="site_disqus_shortname" type="text" value="#htmleditformat(form.site_disqus_shortname)#" /> (This replaces built-in comments with disqus.com and adds comments to more features of the web site.)</td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Exclude File/Dir<br />From Deployment:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_deploy_excluded_paths", "table-error","")#><textarea name="site_deploy_excluded_paths" type="text" cols="70" rows="10" >#htmleditformat(form.site_deploy_excluded_paths)#</textarea><p>Enter one excluded path/file per line. The path should be relative to this site's sites folder.  For example "#request.zos.sitesPath#site1_com/large-files" can be excluded with "large-files" without quotes, which would exclude this directory and anything inside it. </p>
			<p>You can use a wildcard "*" like ".ht*" which would exclude ".htaccess", ".htpasswd" and other files.</p>
			<p>If you exclude a directory like this "large-files/*", it will not exclude "large-files" from being created on the remote server, you should just type "large-files" instead. </p>
			<p>Be more explicit if you want to avoid accidentally matching multiple paths with the same name.  For example, if you type "images", it will exclude any "images" directory or file in the entire project.</p></td>
		</tr> 
		<tr >
			<td style="vertical-align:top; width:140px;">Nginx Config:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_nginx_config", "table-error","")#><textarea name="site_nginx_config" type="text" cols="70" rows="6">#htmleditformat(form.site_nginx_config)#</textarea><br />
			Note: by default nginx has an automatic mass virtual host configuration configured for all features.  Use this only to override for this specific site.</td>
		</tr>  
		<tr >
			<td style="vertical-align:top; width:140px;">Nginx SSL Config:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_nginx_ssl_config", "table-error","")#><textarea name="site_nginx_ssl_config" type="text" cols="70" rows="6">#htmleditformat(form.site_nginx_ssl_config)#</textarea><br />
			Note: by default nginx has an automatic mass virtual host configuration configured for all features.  Use this only to override for this specific site.</td>
		</tr> 
		<tr >
			<td style="vertical-align:top; width:140px;">Disable Nginx<br />Default Includes:</td>
			<td >#application.zcore.functions.zInput_Boolean("site_nginx_disable_jetendo")#</td>
		</tr>
        </table>
		#tabCom.endFieldSet()#

		#tabCom.beginFieldSet("CallTrackingMetrics")#
		<table style="width:100%; border-spacing:0px;" class="table-list">
		<tr >
			<td style="vertical-align:top; width:140px;">Enable:</td>
			<td>#application.zcore.functions.zInput_Boolean("site_calltrackingmetrics_enable_import")#</td> 
		</tr>
		<cfscript>
		if(form.site_calltrackingmetrics_import_datetime NEQ ""){
			form.site_calltrackingmetrics_import_datetime=dateformat(form.site_calltrackingmetrics_import_datetime, "yyyy-mm-dd")&" "&timeformat(form.site_calltrackingmetrics_import_datetime, "HH:mm:ss");
		}
		</cfscript>
		<tr >
			<td style="vertical-align:top; width:140px;">Last Import Date:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_calltrackingmetrics_import_datetime", "table-error","")#><input name="site_calltrackingmetrics_import_datetime" type="text" size="70" maxlength="50" value="#htmleditformat(form.site_calltrackingmetrics_import_datetime)#"> (Strict format required: yyyy-mm-dd HH:mm:ss)</td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">Account ID:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_calltrackingmetrics_account_id", "table-error","")#><input name="site_calltrackingmetrics_account_id" type="text" size="70" maxlength="50" value="#htmleditformat(form.site_calltrackingmetrics_account_id)#"></td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">API Access Key:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_calltrackingmetrics_access_key", "table-error","")#><input name="site_calltrackingmetrics_access_key" type="text" size="70" maxlength="50" value="#htmleditformat(form.site_calltrackingmetrics_access_key)#"> (Either the Agency or Account API Access Key)</td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">API Secret Key:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_calltrackingmetrics_secret_key", "table-error","")#><input name="site_calltrackingmetrics_secret_key" type="text" size="70" maxlength="50" value="#htmleditformat(form.site_calltrackingmetrics_secret_key)#"> (Either the Agency or Account API Access Key)</td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">CTM CFC Path:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_calltrackingmetrics_cfc_path", "table-error","")#><input name="site_calltrackingmetrics_cfc_path" type="text" size="70" maxlength="50" value="#htmleditformat(form.site_calltrackingmetrics_cfc_path)#"> (Used to define a custom CallTrackingMetrics.com Import Filter for this site)</td>
		</tr>
		<tr >
			<td style="vertical-align:top; width:140px;">CTM CFC Method:</td>
			<td #application.zcore.status.getErrorStyle(Request.zsid, "site_calltrackingmetrics_cfc_method", "table-error","")#><input name="site_calltrackingmetrics_cfc_method" type="text" size="70" maxlength="50" value="#htmleditformat(form.site_calltrackingmetrics_cfc_method)#"></td>
		</tr>
        </table>
		#tabCom.endFieldSet()#
		#tabCom.endTabMenu()#
		</form>
</cffunction>
</cfoutput>
</cfcomponent>