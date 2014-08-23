<cfcomponent>
<cfoutput>
<cffunction name="viewErrors" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	</cfscript>
	<h2>Verify Sites Error Log</h2>
	<textarea name="name2" cols="100" rows="40">#application.zcore.functions.zreadfile(request.zos.globals.serverPrivateHomedir&"verifySitesLog.txt")#
	</textarea>
</cffunction>
<cffunction name="countAllSites" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var i=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	setting requesttimeout="1000";
	var db=request.zos.queryObject;
	db.sql="select replace(replace(site_short_domain, #db.param('www.')#, #db.param('')#), #db.param('.'&request.zos.testDomain)#, #db.param('')#) domain
	from #db.table("site", request.zos.zcoredatasource)#
	where site_active=#db.param(1)# and 
	site_id <> #db.param(-1)# and 
	site_deleted = #db.param(0)#
	ORDER BY domain ASC";
	local.qSite=db.execute("qSite");
	
	writeoutput('<h2>Source Code Line Count Report For All Sites</h2>
	<p>Currently counts only .CFM and .CFC files.</p>
	<table style="border-spacing:0px;" class="table-white">
	<tr>
	<th>Domain</th>
	<th>CFM</th>
	<th>CFC</th>
	<th>HTML</th>
	<th>Javascript</th>
	<th>CSS</th>
	<th>Total</th>
	</tr>');
	local.ts={
		cfcLines:0,
		cfmLines:0,
		htmlLines:0,
		jsLines:0,
		cssLines:0,
		totalLines:0
	}
	for(local.row in local.qSite){
		form.path=application.zcore.functions.zGetDomainInstallPath(local.row.domain);
		if(form.path NEQ "" and directoryexists(form.path) and form.path DOES NOT CONTAIN 'mxunit'){
			i++;
			if(i MOD 2 EQ 0){
				writeoutput('<tr class="table-white">');
			}else{
				writeoutput('<tr class="table-bright">');
			}
			local.rs=application.zcore.functions.zCountCFMLLinesInDirectory(form.path);
			local.ts.cfcLines+=local.rs.cfcLines;
			local.ts.cfmLines+=local.rs.cfmLines;
			local.ts.htmlLines+=local.rs.htmlLines;
			local.ts.jsLines+=local.rs.jsLines;
			local.ts.cssLines+=local.rs.cssLines;
			local.ts.totalLines+=local.rs.totalLines;
			writeoutput('
			<td>'&local.row.domain&'</td>
			<td>'&numberformat(local.rs.cfmLines)&'</td>
			<td>'&numberformat(local.rs.cfcLines)&'</td>
			<td>'&numberformat(local.rs.htmlLines)&'</td>
			<td>'&numberformat(local.rs.jsLines)&'</td>
			<td>'&numberformat(local.rs.cssLines)&'</td>
			<td>'&numberformat(local.rs.totalLines)&'</td>
			</tr>');
		}
	}
	writeoutput('<tr>
	<th><strong>Total</strong></th>
	<th>'&numberformat(local.ts.cfmLines)&'</th>
	<th>'&numberformat(local.ts.cfcLines)&'</th>
	<th>'&numberformat(local.ts.htmlLines)&'</th>
	<th>'&numberformat(local.ts.jsLines)&'</th>
	<th>'&numberformat(local.ts.cssLines)&'</th>
	<th>'&numberformat(local.ts.totalLines)&'</th>
	</tr>');
	writeoutput('</table>');
	</cfscript>
</cffunction>

<cffunction name="countLines" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	setting requesttimeout="1000";
	form.path=application.zcore.functions.zso(form, 'path');
	if(form.path NEQ "" and directoryexists(form.path)){
		local.rs=application.zcore.functions.zCountCFMLLinesInDirectory(form.path);
		writeoutput('<h2>Source Code Line Count Report</h2>
	<p>Currently counts only .CFM and .CFC files.</p><p>');
		for(local.i in local.rs){
			writeoutput(local.i&": "&numberformat(local.rs[local.i])&'<br />');
		}
		writeoutput('</p>');
	}
	</cfscript>
	<h2>CFML Line Counter</h2>
	<form action="/z/server-manager/admin/server-home/countLines" method="get">
	Directory: <input type="text" name="path" value="#form.path#" /> <input type="submit" name="submit1" value="Count Lines" />
	</form>
	<hr />
	<h2>Other Reports</h2>
	<p><a href="/z/server-manager/admin/server-home/countAllSites" target="_blank">Count Source Code Lines For All Sites</a></p>
</cffunction>


<cffunction name="prepareForDistribution" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	dbUpgradeCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.db-upgrade");
	result=dbUpgradeCom.dumpInitialDatabase();
	if(not result){
		application.zcore.status.setStatus(request.zsid, "Failed to dump initial database.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	}
	application.zcore.status.setStatus(request.zsid, "The current installation is ready for distribution.");
	application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var selectStruct=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8");
	application.zcore.functions.zStatusHandler(request.zsid);
 
	</cfscript>
	<cfsavecontent variable="local.theMeta"> 
		<style type="text/css">
		/* <![CDATA[ */
		.zdashboard-container{padding:1%; width:98%; float:left; background-color:##FFF;}
		.zdashboard-panel{width:30%; min-width:300px; margin-right:1%; margin-bottom:1%; padding:1%; border:1px solid ##CCC; float:left;}
		/* ]]> */
		</style>
		</cfsavecontent>
		<cfscript> 
		application.zcore.template.setTag("meta", local.theMeta);
		</cfscript> 
	<div class="zdashboard-container">
	  <h2>Dashboard</h2>
	  <div class="zdashboard-panel">
		  <h3>Customize</h3>
		<p><a href="/z/server-manager/admin/white-label/index" target="_blank">White Label Settings</a></p>
	  	<h3>Maintenance Scripts</h3>
		<p><a href="/z/server-manager/tasks/publish-system-css/index" target="_blank">Re-publish System CSS</a></p>
		<p><a href="/z/server-manager/admin/site-import/index" target="_blank">Site Import</a></p>
		<p><a href="/z/server-manager/admin/server-home/countLines">CFML Line Counter</a></p> 
		<p><a href="/z/server-manager/admin/server-home/prepareForDistribution" target="_blank">Prepare For Distribution</a></p>
		<cfif request.zos.istestserver>
			<p><a href="/z/server-manager/admin/db-upgrade/installDatabaseVersion">Install Test Database</a></p>
		</cfif>
		<h3>Scheduled Tasks</h3>
		<p><a href="/z/server-manager/tasks/password-expiration/index" target="_blank">Delete passwords for inactive accounts</a></p>
		<p><a href="/z/server-manager/tasks/verify-tables/index" target="_blank">Verify Table Structure</a></p>
		<p>Verify Sites: 
		<cfscript>
		if(fileexists(request.zos.globals.serverPrivateHomedir&"verifySitesLog.txt")){
			writeoutput('<a href="/z/server-manager/admin/server-home/viewErrors">View Error Log</a>');
		}else{
			writeoutput('No Errors Detected');
		}
		</cfscript>
		</p>
		<p><a href="/z/server-manager/tasks/verify-conventions/index" target="_blank">Verify Conventions</a></p>
		<p><a href="/z/server-manager/tasks/update-sitemap/index" target="_blank">Update Sitemaps</a></p>
		<p><a href="/z/blog/admin/ping/index" target="_blank">Blog Ping</a></p>
		<p><a href="/z/_com/display/skin?method=deleteOldCache">Delete Old Skin File Versioning Cache</a></p>
		<p><a href="/z/server-manager/tasks/memory-dump/index" target="_blank">Memory Dump</a></p>
		<p><a href="/z/misc/system/index" target="_blank">Railo uptime and session clearing</a></p>
		<p><a href="/z/server-manager/tasks/site-backup/index" target="_blank">Backup All Sites</a></p>
		<p><a href="/z/server-manager/tasks/search-index/index" target="_blank">Re-index All Site Content</a></p>
		<p><a href="/z/server-manager/tasks/verify-apps/index" target="_blank">Verify Apps</a></p>
		<p><a href="/z/server-manager/tasks/send-mailing-list-alerts/index?forceDebug=1" target="_blank">Debug Mailing List Alerts (Won't Send Email)</a></p>
		<cfif request.zos.istestserver>
			<h3>Unit Tests</h3>
			<cfscript>
			db.sql="select site_domain from #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
			where site_active=#db.param('1')#  and 
			site_unit_testing_domain=#db.param(1)# and 
			site_deleted = #db.param(0)# and 
			site_id <> #db.param(-1)# 
			LIMIT #db.param(0)#,#db.param(1)#";
			local.qm=db.execute("qm");
			</cfscript>
			<cfif local.qm.recordcount EQ 0>
				<p>You must setup a site with "Enable Unit Testing?" enabled on globals page to run the unit tests.  The CFML engine must allow Java calls for testing since mxunit uses Java. All features you wish to test should be setup for that site in the server manager first.</p>
			<cfelse>
				<p>Warning: Running all tests could take a long time to complete. You can run individual tests by calling the runTestRemote method as a normal MVC url for the test file such as:</p>
				<p style="font-size:10px; "><a href="#local.qm.site_domain#/z/test/functions/fileAndDirectory/zGetDiskUsageTest/runTestRemote" target="_blank">/z/test/functions/fileAndDirectory/zGetDiskUsageTest/runTestRemote</a></p>
				<p><a href="#local.qm.site_domain#/z/test/runAllTests/index" target="_blank">Run All Tests</a></p>
			</cfif>
		</cfif>
		<h3>Listing App</h3>
		<p>These tasks may take a while to complete. Be patient and don't run the same task multiple times simultaneously.</p>
		<cfscript>
		db.sql="select * from #request.zos.queryObject.table("mls", request.zos.zcoreDatasource)# mls 
		where mls_status=#db.param('1')# and 
		mls_deleted = #db.param(0)#
		order by mls_id";
		local.qm=db.execute("qm");
		</cfscript>
		<p>Display fields not output for mls provider:
		  <cfscript>
			selectStruct = StructNew();
			selectStruct.name = "mls_provider1";
			selectStruct.query = local.qm;
			//selectStruct.style="monoMenu";
			selectStruct.queryLabelField = "mls_name";
			selectStruct.queryValueField = "mls_provider";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
		  <button type="button" name="button3243" onclick="gotoFieldNotOutput();">Run</button>
		</p>
		<p>Reset data import:
		  <cfscript>
			selectStruct = StructNew();
			selectStruct.name = "mls_id1";
			selectStruct.query = local.qm;
			//selectStruct.style="monoMenu";
			selectStruct.queryLabelField = "##mls_id## | ##mls_name##";
			selectStruct.queryparselabelvars=true;
			selectStruct.queryValueField = "mls_id";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
		  <button type="button" name="button3243a" onclick="gotoReimport();">Run</button>
		</p>
		<p><a href="/z/listing/tasks/update-metadata/index" target="_blank">Update Metadata</a></p>
		<p><a href="/z/listing/admin/remap-data/index">Remap Real Estate Saved Search Data</a></p>
		<p><a href="/z/listing/tasks/sendListingAlerts/index" target="_blank">Send Email Alerts</a></p>
		<p><a href="/z/listing/tasks/importMLS/index" target="_blank">Import Data</a> 
		<cfif structkeyexists(application.zcore, 'importMLSRunning')>
			(Running -
				<a href="/z/listing/tasks/importMLS/abortImport">Cancel</a> 
				<cfif structkeyexists(application.zcore, 'idxImportStatus')>
					| #application.zcore.idxImportStatus#
				</cfif>
			)
		</cfif></p>
		<p><a href="/z/listing/tasks/generateData/index" target="_blank">Generate Cache Data</a></p>
		<p><a href="/z/listing/tasks/listingLookupBuilder/index" target="_blank">Update Lookup Tables</a></p>
		<p><a href="/z/listing/tasks/listingLookupBuilder/updateDistanceCache" target="_blank">Update City Distance Table</a></p>
		<p><a href="/z/listing/ajax-geocoder/index?debugajaxgeocoder=1" target="_blank">Ajax Geocoder (debug)</a></p>
		
	  </div>
	  <!--- <div class="zdashboard-panel">test
	  </div>
	  <div class="zdashboard-panel">test2
	  </div> --->
	</div>
</cffunction>
</cfoutput>
</cfcomponent>