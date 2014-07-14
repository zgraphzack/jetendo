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
	db=request.zos.queryObject;
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
	<cfscript>
	if(structkeyexists(request.zsession.user, 'group_id')){
		userGroupId=request.zsession.user.group_id;
	}else{
		userGroupId=0;
	}
	</cfscript>
	<cfif not request.zos.inServerManager and (application.zcore.functions.zso(form, 'zreset') NEQ 'template' and 
	structkeyexists(application.siteStruct[request.zos.site_id].administratorTemplateMenuCache, request.zsession.user.site_id&"_"&request.zsession.user.id))>
		#application.siteStruct[request.zos.site_id].administratorTemplateMenuCache[request.zsession.user.site_id&"_"&request.zsession.user.id]#
	<cfelse>
		<cfsavecontent variable="templateMenuOutput">
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
		if(request.zos.isDeveloper and request.zsession.user.site_id EQ request.zos.globals.serverId and application.zcore.user.checkServerAccess()){
			siteIdSQL=" and site_id <> -1";
		}else{
			if(request.zsession.user.site_id NEQ request.zos.globals.id and application.zcore.user.checkGroupAccess("administrator")){
				if(request.zos.globals.parentID NEQ 0){
					siteIdSQL=" and (site_id = '"&request.zos.globals.parentID&"' or site_parent_id ='"&request.zos.globals.parentID&"')";
				}else{
					siteIdSQL=" and (site_id = '"&request.zos.globals.id&"' or site_parent_id ='"&request.zos.globals.id&"')";
				}
			}else{
				db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# user 
				WHERE user_id=#db.param(request.zsession.user.id)# and 
				site_id=#db.param(request.zsession.user.site_id)# and
				user_deleted = #db.param(0)#";
				qUser=db.execute("qUser");
				
				arrSiteId=listtoarray(qUser.user_sync_site_id_list, ",",false);
				arrayappend(arrSiteId, request.zsession.user.site_id);
				siteIdSQL=" and site_id IN ('"&arraytolist(arrSiteId, "','")&"')";
			}
		}
		db.sql="select replace(replace(site_short_domain, #db.param('www.')#, #db.param('')#), #db.param('.#request.zos.testDomain#')#,#db.param('')#) shortDomain, 
		site_domain 
		from #db.table("site", request.zos.zcoreDatasource)# site
		WHERE site_active=#db.param(1)# "&db.trustedSQL(siteIdSQL)&" and 
		site_id <> #db.param(request.zos.globals.id)# and 
		site_deleted = #db.param(0)#
		order by shortDomain asc";
		qSite=db.execute("qSite");
		if(qSite.recordcount NEQ 0){
			selectStruct = StructNew();
			selectStruct.name = "changeSiteID";
			selectStruct.query = qSite;
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
				ts.featureName="Files & Images";
				ts.link="/z/admin/files/index";  
				ts.children=structnew();
				sharedMenuStruct["Files &amp; Images"]=ts;
			}
			if(structkeyexists(sharedMenuStruct,"Site Options") EQ false){
				ts=structnew();
				ts.featureName="Site Options";
				ts.link="/z/admin/site-options/index";
				ts.children=structnew();
				sharedMenuStruct["Site Options"]=ts;
			}
		}
		// remove links to the old system
		tmp=application.zcore.functions.zso(request, 'adminTemplateLinks');
		if(trim(tmp) NEQ ""){
			tmp='<li>'&rereplacenocase(tmp,'</a>(.*?)<a','</a></li> <li><a','ALL')&'</li>';
		}
		tmp=replacenocase(tmp,'<a ','<a class="trigger" ','ALL');
		if(application.zcore.app.siteHasApp("content")){
			tmp=replacenocase(tmp,">content<",' style="display:none;"><');
		}
		if(application.zcore.app.siteHasApp('listing')){
			tmp=replacenocase(tmp,">inquiries<",' style="display:none;"><');
			tmp=replacenocase(tmp,">saved searches<",' style="display:none;"><');
			tmp=replacenocase(tmp,">manage leads<",' style="display:none;"><');
		}
		application.zcore.app.outputAdminMenu(sharedMenuStruct, tmp);
	  </cfscript>
	</td>
	</tr>
	</cfif>
	</table>
	</cfsavecontent>
	    #templateMenuOutput#
		<cfif not request.zos.inServerManager>
			<cfset application.siteStruct[request.zos.site_id].administratorTemplateMenuCache[request.zsession.user.site_id&"_"&request.zsession.user.id]=templateMenuOutput>
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