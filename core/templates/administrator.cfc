<cfcomponent implements="zcorerootmapping.interface.view">
<cfoutput>
<cffunction name="init" access="public" returntype="string" localmode="modern">
	<cfscript>
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
	</cfscript>
</cffunction>

<cffunction name="render" access="public" returntype="string" localmode="modern">
	<cfargument name="tagStruct" type="struct" required="yes">
	<cfscript>
	var tagStruct=arguments.tagStruct;
	</cfscript>
	<cfsavecontent variable="output">
	<cfscript>
	if(fileexists(request.zos.globals.homedir&'templates/administrator.cfc')){
		adminCom=createobject("component", request.zRootCFCPath&"templates.administrator");
		adminCom.init();
		echo(adminCom.render(tagStruct));
	}
	</cfscript>
	<cfif fileexists(request.zos.globals.homedir&'templates/administrator.cfm')><cfinclude template="#request.zrootpath#templates/administrator.cfm"></cfif>
	<cfscript>
	request.znotemplate=1;
	if(application.zcore.functions.zIsTestServer() EQ false){
		application.zcore.functions.zheader("X-UA-Compatible", "IE=edge,chrome=1");
	}
	</cfscript>#application.zcore.functions.zHTMLDoctype()#
	<head>
	    <meta charset="utf-8" />
	<title>#tagStruct.title ?: ""#</title>
	#tagStruct.stylesheets ?: ""#
	<cfscript>
	var sharedMenuStruct=0;
	var selectStruct=0;
	var secondNavHTML=tagStruct.secondnav ?: "";
	</cfscript> 
	#tagStruct.meta ?: ""#
	<script type="text/javascript">
	var zContentTransitionDisabled=true;
	</script>
	<!--[if lte IE 7]>
	<style>.zMenuBarDiv ul a {height: 1%;}</style>
	<![endif]-->
	<!--[if lte IE 6]>
	<style>.zMenuBarDiv li ul{width:1% !important; white-space:nowrap !important;}
	</style>
	<![endif]-->
	
	</head>
	<body>
	<!--- 
	A major system update is in progress. Please try again later.</body></html><cfscript>application.zcore.functions.zabort();</cfscript>
	 ---> 
	<cfif not request.zos.inServerManager and (application.zcore.functions.zso(form, 'zreset') NEQ 'template' and 
	structkeyexists(application.siteStruct[request.zos.site_id].administratorTemplateMenuCache, session.zos.user.site_id&"_"&session.zos.user.id&"_"&session.zos.user.group_id))>
		#application.siteStruct[request.zos.site_id].administratorTemplateMenuCache[session.zos.user.site_id&"_"&session.zos.user.id&"_"&session.zos.user.group_id]#
	<cfelse>
		<cfsavecontent variable="local.templateMenuOutput">
	<table cellpadding="0" cellspacing="0" border="0" width="100%" class="table-list" style="margin-bottom:10px; ">
	<tr>
	<td style="font-size:18px;line-height:normal;padding:10px;background-color:##336699; color:##DFDFDF; width:654px;">
		<cfif request.zos.inServerManager>
		<a href="/z/admin/admin-home/index" style="text-decoration:none; color:##FFFFFF;">Return to Site Manager</a>
		<cfelse>
		<a href="/" target="_blank" style="text-decoration:none; color:##FFFFFF;">#request.zos.globals.sitename#</a>
		 | Site Manager
		 </cfif>
		</td>
	<td style="text-align:right;background-color:##336699; color:##DFDFDF;width:400px; padding-right:5px;">
	
		<cfscript>
		if(request.zos.isDeveloper and session.zos.user.site_id EQ request.zos.globals.serverId and application.zcore.user.checkServerAccess()){
			local.siteIdSQL=" and site_id <> -1";
		}else{
			if(session.zos.user.site_id NEQ request.zos.globals.id and application.zcore.user.checkGroupAccess("administrator")){
				if(request.zos.globals.parentID NEQ 0){
					local.siteIdSQL=" and (site_id = '"&request.zos.globals.parentID&"' or site_parent_id ='"&request.zos.globals.parentID&"')";
				}else{
					local.siteIdSQL=" and (site_id = '"&request.zos.globals.id&"' or site_parent_id ='"&request.zos.globals.id&"')";
				}
			}else{
				local.qUser=application.zcore.functions.zexecutesql("select * from #application.zcore.functions.zTableSQL("user", "user", request.zos.zcoreDatasource)# WHERE user_id='"&application.zcore.functions.zescape(session.zos.user.id)&"' and site_id='"&application.zcore.functions.zescape(session.zos.user.site_id)&"'", request.zos.zcoredatasource);
				
				local.arrSiteId=listtoarray(local.qUser.user_sync_site_id_list, ",",false);
				arrayappend(local.arrSiteId, session.zos.user.site_id);
				local.siteIdSQL=" and site_id IN ('"&arraytolist(local.arrSiteId, "','")&"')";
			}
		}
		local.qSite=application.zcore.functions.zexecutesql("select replace(replace(site_short_domain, 'www.',''), '.#request.zos.testDomain#','') shortDomain, site_domain from #application.zcore.functions.zTableSQL("site", "site", request.zos.zcoreDatasource)# WHERE site_active='1' "&local.siteIdSQL&" and site_id <> '"&request.zos.globals.id&"' order by shortDomain asc", request.zos.zcoredatasource);
		if(local.qSite.recordcount NEQ 0){
			selectStruct = StructNew();
			selectStruct.name = "changeSiteID";
			selectStruct.query = local.qSite;
			selectStruct.selectLabel="-- Change Site --";
			selectStruct.onchange="var d1=this.options[this.selectedIndex].value;if(d1 !=''){window.location.href=d1+'/member/';}";
			selectStruct.queryLabelField = "shortDomain";
			selectStruct.queryValueField = "site_domain";
			application.zcore.functions.zInputSelectBox(selectStruct);
		}
	    </cfscript></td>
	    <td class="zapp-shell-logout" style="padding:0px;width:70px;"><a href="/z/admin/admin-home/index?zlogout=1">Log Off</a></td>
	    </tr>
		<cfif not request.zos.inServerManager>
	    <tr><td colspan="3" class="zapp-admin-nav-text2" style="padding:0px;border-top:1px solid ##CCCCCC;">
	
		<cfscript>
		sharedMenuStruct=structnew();
		
		sharedMenuStruct=application.zcore.app.getAdminMenu(sharedMenuStruct); 
		if(application.zcore.app.siteHasApp("content") EQ false){
			if(structkeyexists(sharedMenuStruct,"Files &amp; Images") EQ false){
				ts=structnew();
				ts.link="/z/admin/files/index";  
				ts.children=structnew();
				sharedMenuStruct["Files &amp; Images"]=ts;
			}
			if(structkeyexists(sharedMenuStruct,"Site Options") EQ false){
				ts=structnew();
				ts.link="/z/admin/site-options/index";
				ts.children=structnew();
				sharedMenuStruct["Site Options"]=ts;
			}
		}
		// remove links to the old system
		local.tmp=application.zcore.functions.zso(request, 'adminTemplateLinks');
		if(trim(local.tmp) NEQ ""){
			local.tmp='<li>'&rereplacenocase(local.tmp,'</a>(.*?)<a','</a></li> <li><a','ALL')&'</li>';
		}
		local.tmp=replacenocase(local.tmp,'<a ','<a class="trigger" ','ALL');
		if(application.zcore.app.siteHasApp("content")){
			local.tmp=replacenocase(local.tmp,">content<",' style="display:none;"><');
		}
		if(application.zcore.app.siteHasApp('listing')){
			local.tmp=replacenocase(local.tmp,">inquiries<",' style="display:none;"><');
			local.tmp=replacenocase(local.tmp,">saved searches<",' style="display:none;"><');
			local.tmp=replacenocase(local.tmp,">manage leads<",' style="display:none;"><');
		}
		application.zcore.app.outputAdminMenu(sharedMenuStruct, local.tmp);
	  </cfscript>
	</td>
	</tr>
	</cfif>
	</table>
	</cfsavecontent>
	    #local.templateMenuOutput#
		<cfif not request.zos.inServerManager>
			<cfset application.siteStruct[request.zos.site_id].administratorTemplateMenuCache[session.zos.user.site_id&"_"&session.zos.user.id&"_"&session.zos.user.group_id]=local.templateMenuOutput>
		</cfif>
	</cfif>
	<cfif request.zos.inServerManager>
	#secondNavHTML#
	</cfif>
	<div class="zapp-shell-container">
	
	
	
	<cfif application.zcore.functions.zso(request, 'adminTemplateContent') NEQ "">
	  #application.zcore.functions.zso(request, 'adminTemplateContent')#<hr />
	  </cfif>
	  #tagStruct.pagenav ?: ""#
	  <cfif application.zcore.template.getTagContent("pagetitle") NEQ "">
	  <h1>#tagStruct.pagetitle ?: ""#</h1>
	  </cfif>
	   #tagStruct.content ?: ""#
	  <div class="zapp-shell-foot"><hr />Copyright&copy; #year(now())# <a href="/">#request.zos.globals.shortdomain#</a>. All Rights Reserved.
	  </div>
	  </div>
	<script type="text/javascript">
	/* <![CDATA[ */ 
	  WebFontConfig = {
	    google: { families: [ 'Open+Sans:400italic,700italic,400,700:latin' ] }
	  };
	  (function() {
	    var wf = document.createElement('script');
	    wf.src = ('https:' == document.location.protocol ? 'https' : 'http') +
	      '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
	    wf.type = 'text/javascript';
	    wf.async = 'true';
	    var s = document.getElementsByTagName('script')[0];
	    s.parentNode.insertBefore(wf, s);
	  })(); 
	  var zDisableBackButton=false; 
	  
	function backButtonOverrideBody()
	{
		if(zDisableBackButton==false) return;
	  try {
	    history.forward();
	  } catch (e) {
	  }
	  setTimeout("backButtonOverrideBody()", 500);
	}
	zArrDeferredFunctions.push(function(){backButtonOverrideBody();});
	 /* ]]> */
	 </script>
	#tagStruct.scripts ?: ""#
	<!--- #(gettickcount()-s)/1000# seconds --->
	</body>
	</html>
	</cfsavecontent>
	<cfreturn output>
</cffunction>
</cfoutput>
</cfcomponent>