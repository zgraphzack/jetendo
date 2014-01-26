<cfcomponent>
<cfoutput>
<cffunction name="siteSearch" localmode="modern" access="private" roles="serveradministrator">
	<cfargument name="word" type="any" required="yes">
	<cfargument name="defaultValue" type="any" required="no" default="">
	<cfscript>
	var found = false;
	/*if(find(" "&arguments.word, ss) NEQ 0){
		ss = replace(ss, " "&arguments.word,"","ALL");
		found = true;
	}
	if(found EQ false and find(" "&arguments.word&"s", ss) NEQ 0){
		ss = replace(ss, " "&arguments.word&"s","","ALL");
		found = true;
	}*/
	if(found){
		return true;
	}else{
		return arguments.defaultValue;
	}
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var i=0;
	var alphabet=0;  
	var qCount=0;
	var perpage=0;
	var inputStruct=0;
	var searchNav=0;
	var searchStruct=0;
	var myColumnOutput=0; 
	form.zid=application.zcore.functions.zso(form, 'zid');
	form.action=application.zcore.functions.zso(form, 'action',false,'list');
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<cfif form.action EQ "select">
		<br />
	</cfif>
	<cfif form.action EQ "list">
		<cfscript>
		structdelete(variables,"qsites");
		</cfscript>
		<cfif structkeyexists(form, 'site_search')>
			<cfscript>
			ss = application.zcore.functions.zso(form, 'site_search');
			/*users = siteSearch("user",false);
			pages = siteSearch("page",false);
			globals = siteSearch("global",false);
			apps = siteSearch("app",false);
			skins = siteSearch("skin",false);
			logs = siteSearch("log",false);*/
			db.sql="SELECT * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
			WHERE site_id <> #db.param(-1)# and 
			(site_sitename LIKE #db.param('%#ss#%')# or 
			site_domain LIKE #db.param('%#ss#%')#)"; 
			qSites = db.execute("qSites"); 
			perpage=qsites.recordcount;
			qCount=structnew();
			qCount.count=perpage;
			if(qSites.recordcount EQ 0){
				application.zcore.status.setStatus(Request.zsid, "No sites matched your search.");
				application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#Request.zsid#");
			}else if(qSites.recordcount EQ 1){
				form.sid = qSites.site_id;
				if(users){
					application.zcore.functions.zRedirect('/z/server-manager/admin/user/index?sid=#form.sid#');
				}else if(globals){
					application.zcore.functions.zRedirect('/z/server-manager/admin/site/edit?sid=#form.sid#');
				}else if(apps){
					application.zcore.functions.zRedirect('/z/_com/zos/app?method=instanceSiteList&sid=#form.sid#');
				}else{
					application.zcore.functions.zRedirect('/z/server-manager/admin/site-select/index?action=select&sid=#form.sid#');
				}
			}
			</cfscript>
			<!--- <cfloop query="qSites">
		#site_sitename#<br />
		</cfloop> --->
		</cfif>
		
		<cfif structkeyexists(form, 'showInactiveSites')>
			<cfset session.showInactiveSites=form.showInactiveSites>
		</cfif>
		
		<form action="#request.cgi_script_name#?action=list" method="get">
			<table style="border-spacing:0px; width:100%;" class="table-list">
				<tr class="table-shadow">
					<td colspan="13" class="tiny"><h2 style="display:inline;">Sites | </h2><a href="/z/server-manager/admin/site/newDomain">Add Site</a> <!--- | <a href="#request.cgi_script_name#?action=manageBudget">Manage Budgets</a>  --->
						<cfif application.zcore.functions.zso(session, 'showInactiveSites', true, 0) EQ 1>
							| <a href="/z/server-manager/admin/site-select/index?showInactiveSites=0">Hide Inactive</a>
							<cfelse>
							| <a href="/z/server-manager/admin/site-select/index?showInactiveSites=1">Show Inactive</a>
						</cfif>
						| <a href="/z/server-manager/admin/site-import/index">Import Site</a>
						| <a href="/z/server-manager/admin/global-import/index">Import Global Database</a></td>
					<td style="text-align:right" colspan="13" class="tiny"><input type="text" name="site_search" value="#application.zcore.functions.zso(form, 'site_search')#" size="35">
						<input type="submit" name="searchSubmit" value="Search"> <input type="button" name="name11" value="Clear" onclick="window.location.href='/z/server-manager/admin/site-select/index';" /></td>
				</tr>
				<tr>
					<cfscript>
	if(structkeyexists(form, 'selectedChar')){
		application.zcore.status.setField(form.zid, 'selectedChar', form.selectedChar);
	}
	selectedChar = application.zcore.status.getField(form.zid, 'selectedChar');
	alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	</cfscript>
					<cfloop from="1" to="26" index="i">
					<cfif selectedChar EQ mid(alphabet, i,1)>
						<td style="text-align:center; width:3%; cursor:pointer;" onMouseOver="this.className = 'table-site-select';" onMouseOut="this.className = 'table-error';" class="table-error" onClick="window.location.href = '#Request.zScriptName#&selectedChar=';">#mid(alphabet, i,1)#</td>
						<cfelse>
						<td style="text-align:center; width:3%; cursor:pointer;" onMouseOver="this.className = 'table-site-select';" onMouseOut="this.className = 'table-list';" class="table-list" onClick="window.location.href = '#Request.zScriptName#&selectedChar=#mid(alphabet, i,1)#';">#mid(alphabet, i,1)#</td>
					</cfif>
					</cfloop>
				</tr>
			</table>
		</form>
		<cfif structkeyexists(local, 'qSites') EQ false or qSites.recordcount EQ 0>
			<cfsavecontent variable="db.sql"> SELECT count(site_id) as count 
			FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
			WHERE site_id <> #db.param(-1)#
			<cfif len(selectedChar) NEQ 0>
				and left(site_sitename,#db.param(1)#) = #db.param(selectedChar)#
			</cfif>
			<cfif application.zcore.functions.zso(session, 'showInactiveSites', true, 0) NEQ 1>
				and site_active=#db.param(1)#
			</cfif>
			</cfsavecontent>
			<cfscript>
qCount=db.execute("qCount");

        perpage = 200;
        </cfscript>
			<cfsavecontent variable="db.sql"> SELECT * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
			WHERE site_id <> #db.param(-1)#
			<cfif len(selectedChar) NEQ 0>
				and left(site_sitename,#db.param(1)#) = #db.param(selectedChar)#
			</cfif>
			<cfif application.zcore.functions.zso(session, 'showInactiveSites') NEQ 1>
				and site_active=#db.param(1)#
			</cfif>
			ORDER BY site_sitename ASC 
			LIMIT #db.param((form.zIndex-1)*perpage)#, #db.param(perpage)# </cfsavecontent>
			<cfscript>
qSites=db.execute("qSites");
</cfscript>
			<cfelse>
			<cfset qCount.count = qSites.recordcount>
		</cfif>
		<cfscript>
	if(qCount.count GT perpage){
		// required
		searchStruct = StructNew();
		searchStruct.count = qCount.count;
		searchStruct.index = form.zIndex;
		searchStruct.url = Request.zScriptName;
		searchStruct.buttons = 5;
		searchStruct.perpage = perpage;
		
		// stylesheet overriding
		searchStruct.tableStyle = "table-list";
		searchStruct.linkStyle = "tiny";
		searchStruct.textStyle = "tiny";
		searchStruct.highlightStyle = "tiny highlight";
		
		searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	}else{
		if(form.zIndex NEQ 1){
			// manual redirect when index is wrong
			application.zcore.functions.zRedirect(request.zScriptName&'&zIndex=1');
		}
		searchNav = "";
	}
	writeoutput(searchNav);
	</cfscript>
		<!--- could be used for ie7 to ie9 multi-column:
		<table style="width:100%; border-spacing:0px;" class="table-white">
			<cfscript>	
	inputStruct = StructNew();
	if(qSites.recordcount GT 40){
		inputStruct.colspan = 3;
	}else if(qSites.recordcount GT 30){
		inputStruct.colspan = 2;
	}else{
		inputStruct.colspan = 1;
	}
	inputStruct.rowspan = qSites.recordcount;
	inputStruct.vertical = true;
	myColumnOutput = CreateObject("component", "zcorerootmapping.com.display.loopOutput");
	myColumnOutput.init(inputStruct);
	</cfscript> --->
	<div class="siteSelectDiv">
			<cfloop query="qSites">
			<div class="siteSelect1" onMouseOver="$('.site-links', this).css('visibility', 'visible'); " onMouseOut=" $('.site-links', this).css('visibility', 'hidden');">
				<div class="siteSelect4">
				<div class="siteSelect2">
					<a href="##" onclick="window.location.href='#Request.zScriptName#&action=select&sid=#qSites.site_id#';return false;" style="text-decoration:none;" title="Manage Site">#qSites.site_sitename#</a>
				</div>
				<div class="site-links siteSelect3"> | <a href="#qSites.site_domain#" target="_blank" style="">View</a> | 
				<a href="##" onclick="window.location.href='#Request.zScriptName#&action=select&sid=#qSites.site_id#';return false;">Manage</a></div>
				</div>
			</div>
			</cfloop>
		</div>
		<cfscript>
	writeoutput(searchNav);
	application.zcore.template.appendTag("stylesheets", '<style type="text/css">
	.siteSelectDiv{float:left; width:100%;  -moz-column-width:300px; -webkit-column-width:300px; column-width:300px; padding-bottom:10px; padding-top:10px; }
	.siteSelect1{width:100%; clear:both;}
	.siteSelect1:hover{color:##FF0 !important; }
	.siteSelect4{padding:3px;float:left; width:100%; }
	.siteSelect1:hover .siteSelect4{ background-color:##69C !important; color:##FFF !important;}
	.siteSelect1:hover .siteSelect4 a:link, .siteSelect1:hover .siteSelect4 a:visited{ color:##FFF !important;}
	.siteSelect2{float:left;}
	.siteSelect3{visibility:hidden;float:left;}
	</style>');
	</cfscript>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>
