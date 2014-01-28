<!--- 
TODO:
prevent duplicate search criteria or titles
make a script that lets you browse for another file to link to on this page.
drag and drop sorting and content tree heirarchy interface
more options for the site owner to reconfigure the site
add fields to set location of content (listing) on google map (using address or lat/long or mls lat/long)
 ---->
<cfcomponent displayname="content" hint="Content Application">
	<cfoutput>
	<cfscript>
	this.app_id=12;
	</cfscript>
	
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
    
    <cffunction name="initExcludeContentId" localmode="modern" output="no" returntype="any">
        <cfscript>
	    request.cArrExcludedContentIDs=arraynew(1);
		</cfscript>
    </cffunction>
    
    <cffunction name="getExcludeContentId" localmode="modern" output="no" returntype="array">
        <cfscript>
		return request.cArrExcludedContentIDs;
		</cfscript>
    </cffunction>
    <cffunction name="excludeContentId" localmode="modern" output="no" returntype="any">
    	<cfargument name="content_id" type="string" required="yes">
        <cfscript>
		arrayappend(request.cArrExcludedContentIDs, arguments.content_id);
		</cfscript>
    </cffunction>
    
    
    <cffunction name="getRobotsTxt" localmode="modern" output="no" access="public" returntype="string" hint="Generate the Robots.txt file as a string">
    	<cfargument name="site_id" type="numeric" required="yes">
        <cfscript>
		var qa="";
		var local=structnew();
		var rs="";
		var c1="";
		var db=request.zos.queryObject;
		</cfscript>
        <cfsavecontent variable="db.sql">
        SELECT * FROM #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site where site_id = #db.param(arguments.site_id)# 
        </cfsavecontent><cfscript>qa=db.execute("qa");
		if(application.zcore.functions.zvar('live',qa.site_id) EQ 1){
			rs&="Sitemap: "&application.zcore.functions.zvar('domain',qa.site_id)&"/sitemap.xml.gz"&chr(10);
		}
		return rs;
		</cfscript>
    </cffunction>
 
    <cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="add links to sitemap array">
    	<cfargument name="arrUrl" type="array" required="yes">
    <cfscript>
	var local=structnew();
	var ts=application.zcore.app.getInstance(this.app_id);
	var db=request.zos.queryObject;
	</cfscript>
    <cfsavecontent variable="local.returnText">
        <cfsavecontent variable="db.sql">
		SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content WHERE content.site_id = #db.param(request.zos.globals.id)# and content_parent_id = #db.param(0)# and content_for_sale <> #db.param(2)# and content_deleted=#db.param(0)# and content_user_group_id =#db.param(0)#
     and content_show_site_map = #db.param(1)#
     ORDER BY content_name ASC
        </cfsavecontent><cfscript>local.qContent=db.execute("qContent");
        request.allTempIds=StructNew();
        local.childStruct=application.zcore.app.getAppCFC("content").getAllContent(local.qContent,0,0,structnew(),false," and content_for_sale <> 2 and content_show_site_map = 1 ",true);//and content_hide_link = #db.param(0)# ");
		for(local.i=1;local.i LTE arraylen(local.childStruct.arrContentId);local.i++){
			local.t2=StructNew();
			local.t2.groupName="Content";
			if(local.childStruct.arrContentUrlOnly[local.i] NEQ ''){
				local.t2.url=application.zcore.functions.zForceAbsoluteURL(request.zos.globals.domain, local.childStruct.arrContentUrlOnly[local.i]);
			}else if(local.childStruct.arrContentUniqueName[i] NEQ ''){
				local.t2.url=request.zos.globals.domain&childStruct.arrContentUniqueName[local.i];
			}else{
				if(local.childStruct.arrIndent[local.i] NEQ ""){
					local.c1=replace(local.childStruct.arrContentName[local.i], local.childStruct.arrIndent[local.i],"","one");
				}else{
					local.c1=local.childStruct.arrContentName[local.i];
				}
				local.t2.url=request.zos.globals.domain&"/#application.zcore.functions.zURLEncode(local.c1,'-')#-#local.ts.optionStruct.content_config_url_article_id#-#local.childStruct.arrContentId[local.i]#.html";
			}
			if(isdate(local.childStruct.arrContentUpdatedDatetime[local.i])){
				local.t2.lastmod=dateformat(local.childStruct.arrContentUpdatedDatetime[local.i],'yyyy-mm-dd');//2005-05-10T17:33:30+08:00
			}else{
				local.t2.lastmod=dateformat(now(),'yyyy-mm-dd');//2005-05-10T17:33:30+08:00
			}
			local.t2.indent=replace(local.childStruct.arrIndent[local.i],"_","  ","ALL");
			local.t2.title=replace(local.childStruct.arrContentName[local.i],"_"," ","ALL");
			arrayappend(arguments.arrUrl,local.t2);
		}
        </cfscript>	
</cfsavecontent>
    	<cfreturn arguments.arrUrl>
    </cffunction>
    
<!--- recurse all content_id and build an array of struct.name struct.id ---->
<!--- application.zcore.app.getAppCFC("content").getAllContent(qAll,0,content_id); --->
<cffunction name="getAllContent" localmode="modern" output="yes" returntype="any">
	<cfargument name="arrQuery" required="yes" type="query">
	<cfargument name="level" required="no" type="any" default="#0#">
	<cfargument name="filterId" required="no" type="any" default="#false#">
	<cfargument name="usedId" required="no" type="struct" default="#structnew()#">
	<cfargument name="cropTitle" required="no" type="boolean" default="#true#">
	<cfargument name="whereSQL" required="no" type="string" default="">
	<cfscript>
		var local=structnew();
	var cs=StructNew();
	var i=0;
	var g=0;
	var qChildren="";
	var rs=StructNew();
	var allowId=false;
	var spaces="";
	var db=request.zos.queryObject;
	
	rs.arrContentName=ArrayNew(1);
	rs.arrContentId=ArrayNew(1);
	rs.arrContentUrlOnly=ArrayNew(1);
	rs.arrContentUniqueName=ArrayNew(1);
	rs.arrContentUpdatedDatetime=ArrayNew(1);
	rs.arrIndent=ArrayNew(1);
	for(g=0;g LT arguments.level;g=g+1){
		//spaces=spaces&"&nbsp;&nbsp;";
		spaces=spaces&"__";
	}
	</cfscript> 
	<cfloop query="arguments.arrQuery">
		<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false>
			<cfscript>
			allowId=false;
			if(structkeyexists(request.allTempIds,arguments.arrQuery.content_id) EQ false){
				allowId=true;
				StructInsert(request.allTempIds, arguments.arrQuery.content_id,true,true);
			}
			</cfscript>
		<cfelse>
			<cfset allowId=true>
		</cfif>
		<cfif allowId>
			<cfscript>
			if(arguments.cropTitle){
				ArrayAppend(rs.arrContentName, spaces&left(replace(arguments.arrQuery.content_name,chr(9)," ","ALL"),80));
			}else{
				ArrayAppend(rs.arrContentName, spaces&replace(arguments.arrQuery.content_name,chr(9)," ","ALL"));
			}
			ArrayAppend(rs.arrIndent, spaces);
			ArrayAppend(rs.arrContentId, arguments.arrQuery.content_id);
			ArrayAppend(rs.arrContentUrlOnly, arguments.arrQuery.content_url_only);
			ArrayAppend(rs.arrContentUniqueName, arguments.arrQuery.content_unique_name);
			ArrayAppend(rs.arrContentUpdatedDatetime, arguments.arrQuery.content_updated_datetime);
			</cfscript>
            <cfif arguments.filterID NEQ arguments.arrQuery.content_id>
			<cfsavecontent variable="db.sql">
			SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content WHERE site_id = #db.param(request.zos.globals.id)# and content_parent_id = #db.param(arguments.arrQuery.content_id)#   and content_deleted=#db.param(0)#  
			#db.trustedsql(arguments.whereSQL)# ORDER BY content_name ASC
			</cfsavecontent><cfscript>qChildren=db.execute("qChildren");
			if(qchildren.recordcount NEQ 0){
				cs=getAllContent(qChildren,arguments.level+1,arguments.filterId,arguments.usedid,arguments.cropTitle, arguments.whereSQL);
				for(i=1;i LTE ArrayLen(cs.arrContentName);i=i+1){
					ArrayAppend(rs.arrIndent, cs.arrIndent[i]);
					ArrayAppend(rs.arrContentName, cs.arrContentName[i]);
					ArrayAppend(rs.arrContentId, cs.arrContentId[i]);
					ArrayAppend(rs.arrContentUrlOnly, cs.arrContentUrlOnly[i]);
					ArrayAppend(rs.arrContentUniqueName, cs.arrContentUniqueName[i]);
					ArrayAppend(rs.arrContentUpdatedDatetime, cs.arrContentUpdatedDatetime[i]);
				}
			}
			</cfscript>
            </cfif>
		</cfif>
	</cfloop>
	<cfreturn rs>
</cffunction>
    
    
    
    <cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
    	<cfargument name="linkStruct" type="struct" required="yes">
    	<cfscript>
		var ts=0;
		if(structkeyexists(request.zos.userSession.groupAccess, "content_manager") or structkeyexists(request.zos.userSession.groupAccess, "administrator")){
			if(structkeyexists(arguments.linkStruct,"Content Manager") EQ false){
				ts=structnew();
				ts.link='/z/content/admin/content-admin/index';
				ts.children=structnew();
				arguments.linkStruct["Content Manager"]=ts;
			}
			if(application.zcore.user.checkServerAccess()){
				if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Import iCalendar") EQ false){
					ts=structnew();
					ts.link='/z/admin/ical-import/index';
					arguments.linkStruct["Content Manager"].children["Import iCalendar"]=ts;
				} 
			}
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Manage Pages") EQ false){
				ts=structnew();
				ts.link='/z/content/admin/content-admin/index';
				arguments.linkStruct["Content Manager"].children["Manage Pages"]=ts;
			} 
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Add Page") EQ false){
				ts=structnew();
				ts.link='/z/content/admin/content-admin/add';
				arguments.linkStruct["Content Manager"].children["Add Page"]=ts;
			} 
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Files &amp; Images") EQ false){
				ts=structnew();
				ts.link="/z/admin/files/index";  
				arguments.linkStruct["Content Manager"].children["Files &amp; Images"]=ts;
			} 
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Video Library") EQ false){
				ts=structnew();
				ts.link="/z/_com/app/video-library?method=videoform";  
				arguments.linkStruct["Content Manager"].children["Video Library"]=ts;
			} 
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Advanced Spell/Grammar Check") EQ false){
				ts=structnew();
				ts.link="/z/admin/admin-home/spellCheck";
				arguments.linkStruct["Content Manager"].children["Advanced Spell/Grammar Check"]=ts;
			}
			if(request.minimalManagerDisabled){
				if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Site Options") EQ false){
					ts=structnew();
					ts.link="/z/admin/site-options/index";
					arguments.linkStruct["Content Manager"].children["Site Options"]=ts;
				}  
				if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Manage Slideshows") EQ false){
					ts=structnew();
					ts.link="/z/admin/slideshow/index";
					arguments.linkStruct["Content Manager"].children["Manage Slideshows"]=ts;
				}   
				if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Add Slideshow") EQ false){
					ts=structnew();
					ts.link="/z/admin/slideshow/add";
					arguments.linkStruct["Content Manager"].children["Add Slideshow"]=ts;
				}    
			}
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Manage Menus") EQ false){
				ts=structnew();
				ts.link="/z/admin/menu/index";
				arguments.linkStruct["Content Manager"].children["Manage Menus"]=ts;
			}   
			if(application.zcore.functions.zso(request.zos.globals, 'lockTheme', true, 1) EQ 0){
				if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Themes") EQ false){
					ts=structnew();
					ts.link="/z/admin/theme/index";
					arguments.linkStruct["Content Manager"].children["Themes"]=ts;
				}    
			}
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Add Menu") EQ false){
				ts=structnew();
				ts.link="/z/admin/menu/add";
				arguments.linkStruct["Content Manager"].children["Add Menu"]=ts;
			}
			if(request.minimalManagerDisabled){
				if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Problem Link Report") EQ false){
					ts=structnew();
					ts.link="/z/admin/site-report/index";
					arguments.linkStruct["Content Manager"].children["Problem Link Report"]=ts;
				}
			}
			if(request.zos.istestserver){
				if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Manage Design &amp; Layout") EQ false){
					ts=structnew();
					ts.link="/z/admin/template/index";
					arguments.linkStruct["Content Manager"].children["Manage Design &amp; Layout"]=ts;
				}
			}
		}
		return arguments.linkStruct;
		</cfscript>
    </cffunction>
    
    <cffunction name="getCacheStruct" localmode="modern" output="no" access="public" returntype="struct" hint="publish the application cache">
    	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
    	<cfscript>
		var qdata=0;
		var local=structnew();
		var ts=StructNew();
		var qdata=0;
		var arrcolumns=0;
		var i=0;
		var db=request.zos.queryObject;
		db.sql="SELECT * FROM #db.table("content_config", request.zos.zcoreDatasource)# content_config 
		where 
		site_id = #db.param(arguments.site_id)#";
		qData=db.execute("qData");
		arrColumns=listToArray(lcase(qdata.columnlist));
		loop query="qdata"{
			for(i=1;i LTE arraylen(arrColumns);i++){
                ts[arrColumns[i]]=qdata[arrColumns[i]];
			}
		}
		return ts;
		</cfscript>
    </cffunction>
    
    <cffunction name="isContentPage" localmode="modern" output="no" returntype="boolean">
    	<cfscript>
		if(request.cgi_script_name EQ "/z/content/content/viewPage"){
			return true;	
		}else{
			return false;
		}
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
		var local=structnew();
		var t999=0;
		var pos=0;
		db.sql="SELECT * FROM #db.table("content_config", request.zos.zcoreDatasource)# content_config, 
		#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
		#db.table("site", request.zos.zcoreDatasource)# site 
		WHERE site.site_id = app_x_site.site_id and 
		app_x_site.app_x_site_id = content_config.app_x_site_id and 
		content_config.site_id = #db.param(arguments.site_id)#";
        qConfig=db.execute("qConfig");
		db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content WHERE
        content_system_url=#db.param(0)# and 
         site_id = #db.param(qConfig.site_id)# and 
		 content_unique_name <> #db.param('')# and  
		 content_unique_name <> #db.param('/')# and 
		 content_unique_name NOT LIKE #db.param('/z/%')# and 
		 content_url_only = #db.param('')# and 
		 content_for_sale<>#db.param(2)# and 
		 content_deleted=#db.param(0)# 
        ORDER BY content_deleted ASC, content_for_sale ASC, content_unique_name DESC ";
		qContent=db.execute("qContent");
		loop query="qConfig"{
			arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.content_config_url_article_id]=arraynew(1);
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/content/content/viewPage";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/content/content/viewPage";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			t9.mapStruct.dataId="content_id";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.content_config_url_article_id],t9);
			if(qConfig.content_config_url_listing_user_id NEQ 0 and qConfig.content_config_url_listing_user_id NEQ ""){
				arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.content_config_url_listing_user_id]=arraynew(1);
				t9=structnew();
				t9.type=1;
				t9.scriptName="/z/listing/agent-listings/index";
				t9.urlStruct=structnew();
				t9.urlStruct[request.zos.urlRoutingParameter]="/z/listing/agent-listings/index";
				t9.mapStruct=structnew();
				t9.mapStruct.urlTitle="zURLName";
				t9.mapStruct.dataId="content_listing_user_id";
				arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.content_config_url_listing_user_id],t9);
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
		loop query="qContent"{
			t9=structnew();
			t9.scriptName="/z/content/content/viewPage";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/content/content/viewPage";
			t9.urlStruct.content_id=qcontent.content_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qContent.content_unique_name)]=t9;
		}
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
		var local=structnew();
		var qconfig=0;
		var rCom=createObject("component","zcorerootmapping.com.zos.return");
		db.sql="DELETE FROM #db.table("content_config", request.zos.zcoreDatasource)#  
		WHERE site_id = #db.param(request.zos.globals.id)#	";
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
		df.content_config_url_article_id="6";
		for(i in df){	
			if(arguments.validate){
				if(structkeyexists(form,i) EQ false or form[i] EQ ""){	
					error=true;
					field=trim(lcase(replacenocase(replacenocase(i,"content_config_",""),"_"," ","ALL")));
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
		ts=StructNew();
		ts.arrId=arrayNew(1);
		arrayappend(ts.arrId,trim(form.content_config_url_article_id));
		if(form.content_config_url_listing_user_id NEQ ""){
			arrayappend(ts.arrId,trim(form.content_config_url_listing_user_id));
		}
		form.site_id=form.sid;
		ts.site_id=form.site_id;
		ts.app_id=this.app_id;
		rCom=application.zcore.app.reserveAppUrlId(ts);
		if(rCom.isOK() EQ false){
			return rCom;
			application.zcore.functions.zstatushandler(request.zsid);
			application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=configForm&app_x_site_id=#this.app_x_site_id#&zsid=#request.zsid#");
			application.zcore.functions.zabort();
		}		
		ts.table="content_config";
		ts.struct=form;
		ts.datasource=request.zos.zcoreDatasource;
		if(application.zcore.functions.zso(form, 'content_config_id',true) EQ 0){ // insert
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
		var local=structnew();
		var rs=structnew();
		var qConfig='';
		var theText='';
		var rCom=createObject("component","zcorerootmapping.com.zos.return");
		</cfscript>
        <cfsavecontent variable="theText">
        <cfsavecontent variable="db.sql">
        SELECT * FROM #db.table("content_config", request.zos.zcoreDatasource)# content_config WHERE site_id = #db.param(form.sid)#
        </cfsavecontent><cfscript>qConfig=db.execute("qConfig");
        application.zcore.functions.zQueryToStruct(qConfig);//, "local.configStruct");
		if(qConfig.recordcount EQ 0){
			this.loadDefaultConfig();
		}
        application.zcore.functions.zStatusHandler(request.zsid,true);
        </cfscript>
        <input type="hidden" name="content_config_id" value="#form.content_config_id#" />
        <table style="border-spacing:0px;" class="table-list">
        <tr>
        <th>URL Article ID</th>
        <td>
        <cfscript>
		writeoutput(application.zcore.app.selectAppUrlId("content_config_url_article_id", form.content_config_url_article_id, this.app_id));
		</cfscript></td>
        </tr>
        <tr>
        <th>Sidebar Tag</th>
        <td>
		<cfscript>
		ts=StructNew();
		ts.label="";
		ts.name="content_config_sidebar_tag";
		ts.size="20";
		application.zcore.functions.zInput_Text(ts);
		</cfscript> (i.e. type "sidebar" for &lt;z_sidebar&gt;)</td>
        </tr>
        
        <tr>
        <th>Default Parent Page<br />Link Layout</th>
        <td>
		<cfscript>
		selectStruct = StructNew();
		selectStruct.name = "content_config_default_parentpage_link_layout";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Invisible,Top with numbered columns,Top with columns,Top on one line";//,Bottom with summary (default),Bottom without summary,Left Sidebar,Right Sidebar";
		selectStruct.listValues = "7,2,3,4";//,0,1,5,6";
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript></td>
        </tr>
        <tr>
        <th>Default Sub-page<br />Link Layout</th>
        <td>
		<cfscript>
		if(application.zcore.functions.zso(form, 'content_config_default_subpage_link_layout') EQ ''){
			form.content_config_default_subpage_link_layout=0;
		}
		selectStruct = StructNew();
		selectStruct.name = "content_config_default_subpage_link_layout";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Invisible,Bottom with summary (default),Bottom without summary,Top with numbered columns,Top with columns,Top on one line";//,Left Sidebar,Right Sidebar";
		selectStruct.listValues = "7,0,1,2,3,4";//,5,6";
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript></td>
        </tr>
        
        <tr>
        <th>URL Agent ID</th>
        <td>
        <cfscript>
		writeoutput(application.zcore.app.selectAppUrlId("content_config_url_listing_user_id", form.content_config_url_listing_user_id, this.app_id));
		</cfscript> (This is used for viewing agent listings)</td>
        </tr>
        
        <tr>
        <th>Contact Links?</th>
        <td>
        <cfscript>
		form.content_config_contact_links=application.zcore.functions.zso(form, 'content_config_contact_links',false,1);
		if(form.content_config_contact_links EQ ""){
			form.content_config_contact_links=1;
		}
		ts = StructNew();
		ts.name = "content_config_contact_links";
		ts.radio=true;
		ts.separator=" ";
		ts.listLabels="Yes	No";
		ts.listValues="1	0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript> (No, Removes the options from entire site)</td>
        </tr>
        <tr>
        <th>Inquiry Qualify?</th>
        <td>
        <cfscript>
		form.content_config_inquiry_qualify=application.zcore.functions.zso(form, 'content_config_inquiry_qualify',true);
		ts = StructNew();
		ts.name = "content_config_inquiry_qualify";
		ts.radio=true;
		ts.separator=" ";
		ts.listLabels="Yes	No";
		ts.listValues="1	0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript> (On sites with listing application, it will display additional fields on inquiry form to qualify the lead.)</td>
        </tr>
        <tr>
        <th>Override Listing Stylesheet?:</th>
        <td>
        <cfscript>
		form.content_config_override_stylesheet=application.zcore.functions.zso(form, 'content_config_override_stylesheet',true);
		ts = StructNew();
		ts.name = "content_config_override_stylesheet";
		ts.radio=true;
		ts.separator=" ";
		ts.listLabels="Yes	No";
		ts.listValues="1	0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript> Note: Checking yes will disable the built-in listing stylesheet.</td>
        </tr>
        
        <tr>
        <th>Hide Inquiring About?:</th>
        <td>
        <cfscript>
		form.content_config_hide_inquiring_about=application.zcore.functions.zso(form,'content_config_hide_inquiring_about',true,0);
		ts = StructNew();
		ts.name = "content_config_hide_inquiring_about";
		ts.radio=true;
		ts.separator=" ";
		ts.listLabels="Yes	No";
		ts.listValues="1	0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript> (Affects all contact forms).</td>
        </tr>
        <tr>
        <th>Phone Number Required?:</th>
        <td>
        <cfscript>
		form.content_config_phone_required=application.zcore.functions.zso(form, 'content_config_phone_required',true,1);
		ts = StructNew();
		ts.name = "content_config_phone_required";
		ts.radio=true;
		ts.separator=" ";
		ts.listLabels="Yes	No";
		ts.listValues="1	0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript> (Affects all contact forms).</td>
        </tr>
        <tr>
        <th>Comments Required?:</th>
        <td>
        <cfscript>
		form.content_config_comments_required=application.zcore.functions.zso(form, 'content_config_comments_required',true,1);
		ts = StructNew();
		ts.name = "content_config_comments_required";
		ts.radio=true;
		ts.separator=" ";
		ts.listLabels="Yes	No";
		ts.listValues="1	0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript> (Affects all contact forms).</td>
        </tr>
        <tr>
        <th>E-Mail Required?:</th>
        <td>
        <cfscript>
		form.content_config_phone_required=application.zcore.functions.zso(form,'content_config_email_required',true,1);
		if(form.content_config_email_required EQ ""){
			form.content_config_email_required=1;
		}
		ts = StructNew();
		ts.name = "content_config_email_required";
		ts.radio=true;
		ts.separator=" ";
		ts.listLabels="Yes	No";
		ts.listValues="1	0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript> (Affects all contact forms).</td>
        </tr>
        <tr>
        <th>Thumbnail Image Size:</th>
        <td>
		<cfscript>
		form.content_config_thumbnail_width=application.zcore.functions.zso(form, 'content_config_thumbnail_width',true,250);
		form.content_config_thumbnail_height=application.zcore.functions.zso(form, 'content_config_thumbnail_height',true,200);
		form.content_config_thumbnail_crop=application.zcore.functions.zso(form, 'content_config_thumbnail_crop',true,0);
		</cfscript>
		Width: <input type="text" name="content_config_thumbnail_width" value="#htmleditformat(form.content_config_thumbnail_width)#" /> 
		Height: <input type="text" name="content_config_thumbnail_height" value="#htmleditformat(form.content_config_thumbnail_height)#" /> 
		Crop: 
		<cfscript>
		ts = StructNew();
		ts.name = "content_config_thumbnail_crop";
		ts.radio=true;
		ts.separator=" ";
		ts.listLabels="Yes	No";
		ts.listValues="1	0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript> (Default is 250x250, uncropped).</td>
        </tr>
        </table>
        </cfsavecontent>
        <cfscript>
		rs.output=theText;
		rCom.setData(rs);
		return rCom;
		</cfscript>
	</cffunction>
    
    
    
    
    <cffunction name="forceInitialContentSetup" localmode="modern" output="no" returntype="any">
    	<cfscript>
		var db=request.zos.queryObject;
		var local=structnew();
		local.curInstance=application.zcore.app.getInstance(this.app_id);
		local.curInstance.initialcontentsetup=true;
		local.arrDefaultTitle=listtoarray('Home,Contact Us,Thank You For Your Inquiry,Join Our Mailing List,Thank You For Joining Our Mailing List,User Home Page',',');
		local.arrDefaultURL=listtoarray('/,/z/misc/inquiry/index,/z/misc/thank-you/index,/z/misc/mailing-list/index,/z/misc/mailing-list/thankyou,/z/user/home/index',',');
		
		if(application.zcore.app.siteHasApp("rental")){
			var rentalStruct=application.zcore.app.getAppData("rental");
			var rentalInstance=application.zcore.app.getAppCFC("rental");
			rentalInstance.onRequestStart();
			arrayappend(local.arrDefaultTitle,'Our Rentals');
			arrayappend(local.arrDefaultURL, rentalInstance.getRentalHomeLink());
			arrayappend(local.arrDefaultTitle,'Rental Reservation Policies');
			arrayappend(local.arrDefaultURL,'/Rental-Reservation-Policies-'&rentalStruct.optionStruct.rental_config_misc_url_id&'-1.html');
			arrayappend(local.arrDefaultTitle,'Compare Rental Amenities');
			arrayappend(local.arrDefaultURL,'/Compare-Rental-Amenities-'&rentalStruct.optionStruct.rental_config_misc_url_id&'-2.html');
		}
		if(application.zcore.app.siteHasApp("listing")){
			arrayappend(local.arrDefaultTitle,'Meet Our Agents');
			arrayappend(local.arrDefaultURL,'/z/misc/members/index');
			arrayappend(local.arrDefaultTitle,'Mortgage Calculator');
			arrayappend(local.arrDefaultURL,'/z/misc/mortgage-calculator/index');
			arrayappend(local.arrDefaultTitle,'Find Your Property''s Value');
			arrayappend(local.arrDefaultURL,'/z/listing/cma-inquiry/index');
			arrayappend(local.arrDefaultTitle,'Property Inquiry');
			arrayappend(local.arrDefaultURL,'/z/listing/inquiry/index'); 
		}
		for(local.i=1;local.i LTE arraylen(local.arrDefaultTitle);local.i++){
			if(local.arrDefaultURL[local.i] EQ "/z/misc/thank-you/index" or local.arrDefaultURL[local.i] EQ "/z/misc/search-site/results" or local.arrDefaultURL[local.i] EQ "/z/misc/search-site/no-results"){
				local.siteMap=0;	
				local.hideLink=1;
			}else{
				local.siteMap=1;
				local.hideLink=0;
			}
			db.sql="SELECT content_id FROM #db.table("content", request.zos.zcoreDatasource)# content 
			WHERE site_id = #db.param(request.zos.globals.id)# and 
			content_unique_name = #db.param(local.arrDefaultURL[local.i])# and 
			content_for_sale =#db.param(1)# and 
			content_deleted=#db.param(0)#";
			local.qIdCheck=db.execute("qIDCheck");
			if(local.qIdCheck.recordcount EQ 0){
				db.sql="INSERT INTO #db.table("content", request.zos.zcoreDatasource)#  
				SET `content_text` = #db.param('')#,
				`content_summary` = #db.param('')#,
				`content_metakey` = #db.param('')#,
				`content_metadesc` = #db.param('')#,
				`content_name` = #db.param(arrDefaultTitle[i])#,
				`content_name2` = #db.param('')#,
				`content_unique_name` = #db.param(local.arrDefaultURL[local.i])#,
				`content_parent_id` = #db.param(0)#,
				`content_locked` = #db.param(0)#,
				`content_mls_price` = #db.param(1)#,
				`content_created_datetime` = #db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(),'HH:mm:ss'))#,
				`content_updated_datetime` =#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(),'HH:mm:ss'))#,
				`content_sort` = #db.param(local.i)#,
				`content_datetime` = #db.param('')#,
				`content_hide_link` = #db.param(local.hideLink)#,
				`content_show_site_map` = #db.param(local.siteMap)#,
				`content_hide_modal` = #db.param(0)#,
				`content_for_sale` = #db.param(1)#,
				`content_mls_override` = #db.param(1)#,
				`content_search_mls` = #db.param(0)#,
				`content_search` = "&db.param(local.arrDefaultTitle[local.i])&",
				`content_child_sorting` = #db.param(0)#,
				`content_mix_sold` = #db.param(0)#,
				`content_user_group_id` = #db.param('')#,
				`content_hide_global` = #db.param(0)#,
				`content_text_position` = #db.param(0)#,
				`content_parentpage_link_layout` = #db.param(7)#, 
				site_id="&db.param(request.zos.globals.id)&" ";
				db.execute("qInsert");
			}
		}
		</cfscript>
    </cffunction>
    
    <cffunction name="onRequestStart" localmode="modern" output="yes" returntype="void">
		<cfscript>
		var db=request.zos.queryObject;
		var tmpUsrId='';
		var qc='';
		var ts='';
		var db=request.zos.queryObject;
		if(request.zos.allowRequestCFC){
			request.zos.tempObj.contentInstance=structnew();
			structappend(request.zos.tempObj.contentInstance, application.sitestruct[request.zos.globals.id].app.appCache[this.app_id]);
			request.zos.tempObj.contentInstance.configCom=this;
		}
		if(isDefined('cookie.inquiries_email') and isDefined('cookie.inquiries_first_name') and isDefined('cookie.inquiries_phone1')){
			if(cookie.inquiries_email NEQ ""){
				session.inquiries_email = cookie.inquiries_email;
			}
			if(cookie.inquiries_first_name NEQ ""){
				session.inquiries_first_name=cookie.inquiries_first_name;
			}
			if(cookie.inquiries_phone1 NEQ ""){
			session.inquiries_phone1=cookie.inquiries_phone1;	
			}
		}
		
		if(structkeyexists(form, 'zlogout') EQ false){
			if(isDefined('session.zos.user.id') and isDefined('session.zos.user.site_id')){
				if(isDefined('session.zUserInquiryInfoLoaded') EQ false){
					tmpUsrId=session.zos.user.id;
					db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
					WHERE user_id = #db.param(session.zos.user.id)# and 
					user_active=#db.param(1)# and 
					site_id = #db.param(session.zos.user.site_id)#";
					qc=db.execute("qc");
					ts=structnew();
					ts.name="z_user_id";
					ts.value=tmpUsrId;
					ts.expires="never";
					application.zcore.functions.zCookie(ts);
					ts=structnew();
					ts.name="z_user_key";
					ts.value=qc.user_key;
					ts.expires="never";
					application.zcore.functions.zCookie(ts);
					ts=structnew();
					ts.name="z_user_siteIDType";
					ts.value=application.zcore.user.getSiteIdTypeFromLoggedOnUser();
					ts.expires="never";
					application.zcore.functions.zCookie(ts);
					session.zUserInquiryInfoLoaded=true;
				}
			}else if(application.zcore.functions.zso(cookie, 'z_user_id') NEQ "" and application.zcore.functions.zso(cookie, 'z_user_key') NEQ ""){
				tmpUsrId=cookie.z_user_id;
				db.sql="SELECT user_username, user_first_name, user_last_name, user_phone 
				FROM #db.table("user", request.zos.zcoreDatasource)# user 
				WHERE user_id = #db.param(cookie.z_user_id)# and 
				user_key = #db.param(cookie.z_user_key)# and 
				user_active=#db.param(1)# and 
				site_id = #db.param(request.zos.globals.id)#";
				qc=db.execute("qc");
			}
			if(isquery(qc) and qc.recordcount NEQ 0){
				session.inquiries_email=qc.user_username;
				session.inquiries_first_name=qc.user_first_name;
				session.inquiries_last_name=qc.user_last_name;
				session.inquiries_phone1=qc.user_phone;
				ts=structnew();
				ts.name="inquiries_email";
				ts.value="";
				ts.expires="now";
				application.zcore.functions.zCookie(ts);
				ts=structnew();
				ts.name="inquiries_first_name";
				ts.value="";
				ts.expires="now";
				application.zcore.functions.zCookie(ts);
				ts=structnew();
				ts.name="inquiries_last_name";
				ts.value="";
				ts.expires="now";
				application.zcore.functions.zCookie(ts);
				ts=structnew();
				ts.name="inquiries_phone1";
				ts.value="";
				ts.expires="now";
				application.zcore.functions.zCookie(ts);
				session.zUserInquiryInfoLoaded=true;
			}
		}
		
		if(structkeyexists(application.sitestruct[request.zos.globals.id].app.appCache[this.app_id],'initialcontentsetup') EQ false){
			this.forceInitialContentSetup();
		}
        </cfscript>
    </cffunction>
    
	<cffunction name="onRequestEnd" localmode="modern" output="yes" returntype="void" hint="Runs after zos end file.">
    	<cfscript>
		
		</cfscript>
	</cffunction>
    
    <!--- 
	ts=structnew();
	ts.content_unique_name="";
	qContent=application.zcore.app.getAppCFC("content").getContentByName(ts);
	if(isQuery(qContent)){
		
	}
	 --->
    <cffunction name="getContentByName" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
        <cfscript>
		var db=request.zos.queryObject;
        var qC=0;
		var ts=structnew();
		var local=structnew();
		ts.idOnly=true;
		ts.content_unique_name='';
		structappend(arguments.ss,ts,false);
		if(trim(arguments.ss.content_unique_name) EQ ''){
			return false;
		}
		</cfscript>
        <cfsavecontent variable="db.sql">
        SELECT <cfif arguments.ss.idOnly>content_id<cfelse>*</cfif> FROM #db.table("content", request.zos.zcoreDatasource)# content WHERE content_deleted=#db.param(0)# and content_for_sale <> #db.param(2)# and content_unique_name = #db.param(arguments.ss.content_unique_name)# and site_id=#db.param(request.zos.globals.id)# 
        </cfsavecontent><cfscript>qC=db.execute("qC");
		if(qC.recordcount NEQ 0){
			return qc;
		}else{
			return false;	
		}
		</cfscript>
    </cffunction>
    
    <!--- template variables are ##link## and ##linktext##
	
	<a href="#link#">#linktext#</a>
	<z_if var="photo" validate="notempty"><img src="#photo#"><z_else><img src="/images/shell/not-available.jpg"></z_if> #summary#
	
	 --->
    <cffunction name="getSidebar" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
        <cfscript>
		var db=request.zos.queryObject;
		var p=0;
		var p2=0;
		var qpar=0;
		var arrL=arraynew(1);
		var image=0;
		var tmp="";
		var local=structnew();
		var ts=structnew();
		var t9=structnew();
		var arrImages=0;
		var rs=structnew();
		var useSummary=true;
		var qc='';
		var summarylen='';
		var rs2=structnew();
		var parseStruct=structnew();
		rs.arrLink=arraynew(1);
		rs.arrText=arraynew(1);
		rs.arrID=arraynew(1);
		rs.arrStatus=arraynew(1);
		rs.arrLot=arraynew(1);
		ts.limit=0; // 0 is unlimited
		ts.delimiter="<br />";
		ts.beforeCode="";
		ts.afterCode="";
		ts.disableMoreLink=false;
		ts.cropTitleAt="";
		ts.forceLinkForCurrentPage=false;
		ts.sortAlpha=false;
		ts.returnData=false;
		ts.dateSortAsc=false;
		ts.dateSortDesc=false;
		ts.linkTextLength=0;
		ts.showHidden=false;
		ts.summaryTextLength=250;
		ts.insertAtPercent=0;
		ts.insertAtHTML='';
		ts.appendUrl="";
		ts.content_parent_id=0;
		ts.content_unique_name="";
		ts.moretemplate="";
		ts.template="";
		structappend(arguments.ss,ts, false);
		if(arguments.ss.content_unique_name NEQ ""){
			t9.content_unique_name=arguments.ss.content_unique_name;
			qc=this.getContentByName(t9);
			if(isQuery(qc) and qc.recordcount NEQ 0){
				arguments.ss.content_parent_id=qc.content_id;
			}else{
				return "";
			}
		}
		if(findnocase("##summary##",arguments.ss.template) EQ 0){
			useSummary=false;
		}
		
		// you must have a group by in your query or it may miss rows
		ts=structnew();
		ts.image_library_id_field="content.content_image_library_id";
		ts.count =  1; // how many images to get
		rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
		</cfscript>

		<cfsavecontent variable="db.sql">  
		SELECT <cfif useSummary>*<cfelse>content_id, content_lot_number, content_for_sale, content_unique_name, content_name, content_menu_title, content_url_only, content_image_library_id</cfif> #db.trustedsql(rs2.select)# 
		FROM #db.table("content", request.zos.zcoreDatasource)# content 
		#db.trustedsql(rs2.leftJoin)# 
		where content_parent_id = #db.param(arguments.ss.content_parent_id)# 
		<cfif arguments.ss.showHidden EQ false>and content_hide_link=#db.param(0)#</cfif> and 
		content_for_sale <>#db.param(2)# and 
		content_deleted = #db.param(0)# and 
		content.site_id = #db.param(request.zos.globals.id)#   
		GROUP BY content.content_id
		ORDER BY <cfif arguments.ss.sortAlpha>trim(if(content_menu_title <>#db.param('')#,content_menu_title,content_name)) 
		<cfelseif arguments.ss.dateSortAsc> content_datetime ASC <cfelseif arguments.ss.dateSortDesc> content_datetime DESC 
		<cfelse>content_sort </cfif>
        	<cfif arguments.ss.limit NEQ 0> LIMIT #db.param(0)#,#db.param(arguments.ss.limit)# </cfif>
		</cfsavecontent><cfscript>qpar=db.execute("qpar");</cfscript>
        <cfloop query="qpar">
        <cfif arguments.ss.disablemorelink OR qpar.currentrow NEQ arguments.ss.limit>
        <cfscript>
		parseStruct=structnew();
		parseStruct.content_id=local.qpar.content_id;
		if(qpar.content_url_only NEQ ''){
			parseStruct.link=application.zcore.functions.zForceAbsoluteURL(request.zos.globals.domain, qpar.content_url_only);
		}else if(qpar.content_unique_name NEQ ''){
			parseStruct.link=qpar.content_unique_name;
		}else{
			parseStruct.link="/#application.zcore.functions.zURLEncode(qpar.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#qpar.content_id#.html";
		}
		if(arguments.ss.appendUrl NEQ ""){
			application.zcore.functions.zURLAppend(parseStruct.link, arguments.ss.appendUrl);
		}
		
		local.ts=structnew();
		local.ts.image_library_id=qpar.content_image_library_id;
		local.ts.output=false;
		local.ts.query=qpar;
		local.ts.row=qpar.currentrow;
		local.ts.size="250x187";
		//local.ts.crop=1;
		local.ts.count = 1; // how many images to get
		//zdump(ts);
		local.arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(local.ts);
		parseStruct.image=request.zos.globals.domain&"/z/a/images/s.gif";
		if(arraylen(local.arrImages) NEQ 0){
			parseStruct.image=request.zos.globals.domain&local.arrImages[1].link;
		}
		if(qpar.content_menu_title NEQ ""){
			parseStruct.linktext=qpar.content_menu_title;
		}else{
			parseStruct.linktext=qpar.content_name;
		}
		if(arguments.ss.cropTitleAt NEQ ""){
			p=findnocase(arguments.ss.cropTitleAt, parseStruct.linktext)-1;
			if(p GTE 1){
				parseStruct.linktext=left(parseStruct.linktext,p);
			}
		}
		if(arguments.ss.linkTextLength NEQ 0){
			p=reverse(left(parseStruct.linktext,arguments.ss.linkTextLength));
			if(len(parseStruct.linktext) GT arguments.ss.linkTextLength){
				p2=find(" ",p);
				if(p2 NEQ 0){
					p='... '&removechars(p,1,p2);
				}
			}
			parseStruct.linktext=reverse(p);
		}
		if(useSummary){
			parseStruct.summary=qpar.content_summary;
			if(content_summary EQ ""){
				parseStruct.summary=qpar.content_text;
			}
			parseStruct.summary=rereplace(parseStruct.summary,"<[^>]*>"," ","ALL");
			summarylen=len(parseStruct.summary);
			parseStruct.summary=left(parseStruct.summary,arguments.ss.summaryTextLength);
			if(summarylen GT arguments.ss.summaryTextLength){
				parseStruct.summary&="...";	
			}
		}
		ts=structnew();
		ts.image_library_id=qpar.content_image_library_id;
		ts.output=false;
		ts.query=qpar;
		ts.row=qpar.currentrow;
		ts.size="200x140";
		//ts.crop=1;
		ts.count = 1; // how many images to get
		//zdump(ts);
		arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts);
		parseStruct.photo=""; 
		if(arraylen(arrImages) NEQ 0){
			parseStruct.photo=(arrImages[1].link);
		}
		parseStruct.link=htmleditformat(parseStruct.link);
		parseStruct.linktext=htmleditformat(parseStruct.linktext);
		if(arguments.ss.template NEQ ""){
			tmp=application.zcore.functions.zParseVariables(arguments.ss.template, false, parseStruct);
		}else if(not arguments.ss.forceLinkForCurrentPage and (request.zos.originalURL EQ parseStruct.link or request.zos.originalURL EQ qpar.content_url_only)){
			tmp='<span>'&parseStruct.linkText&'</span>';
		}else{
			tmp='<a href="#parseStruct.link#">#parseStruct.linktext#</a>';
		}
		tmp=arguments.ss.beforeCode&tmp&arguments.ss.afterCode&arguments.ss.delimiter;
		if(arguments.ss.insertAtPercent NEQ 0){
			p=(qpar.currentrow/qpar.recordcount)*100;
			if(p GTE arguments.ss.insertAtPercent){
				arguments.ss.insertAtPercent=0;
				arrayappend(arrL,arguments.ss.insertAtHTML);
			}
		}
		arrayappend(arrL,tmp);
		if(arguments.ss.returnData){
			arrayappend(rs.arrId,qpar.content_id);
			arrayappend(rs.arrLink,parseStruct.link); 
			arrayappend(rs.arrLot, qpar.content_lot_number); 
			arrayappend(rs.arrStatus,qpar.content_for_sale);
			arrayappend(rs.arrText,parseStruct.linktext);
		}
		</cfscript>
        </cfif>
		</cfloop>
        
        <cfif arguments.ss.disableMoreLink EQ false and qpar.recordcount EQ arguments.ss.limit>
        <cfscript>
        // you must have a group by in your query or it may miss rows
        local.ts=structnew();
        local.ts.image_library_id_field="content.content_image_library_id";
        local.ts.count =  100; // how many images to get
        rs2=application.zcore.imageLibraryCom.getImageSQL(local.ts);
        </cfscript>
		<cfsavecontent variable="db.sql">
		SELECT * #db.trustedsql(rs2.select)# FROM #db.table("content", request.zos.zcoreDatasource)# content #db.trustedsql(rs2.leftJoin)# where <cfif arguments.ss.content_parent_id EQ 0>content_unique_name = #db.param('/')# <cfelse> content_id = #db.param(arguments.ss.content_parent_id)# </cfif> <cfif arguments.ss.showHidden EQ false>and content_hide_link=#db.param(0)#</cfif> and content_for_sale=#db.param(1)# and content_deleted = #db.param(0)# and content.site_id = #db.param(request.zos.globals.id)# 
        GROUP BY content.content_id
		</cfsavecontent><cfscript>qpar=db.execute("qpar");</cfscript>
        <cfloop query="qpar">
        <cfscript>
		parseStruct=structnew();
		parseStruct.content_id=local.qpar.content_id;
		parseStruct.summary="";
		parseStruct.photo="";
		if(qpar.content_url_only NEQ ''){
			parseStruct.link=application.zcore.functions.zForceAbsoluteURL(request.zos.globals.domain, qpar.content_url_only);
		}else if(qpar.content_unique_name NEQ ''){
			parseStruct.link=qpar.content_unique_name;
		}else{
			parseStruct.link="/#application.zcore.functions.zURLEncode(qpar.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#qpar.content_id#.html";
		}
		if(arguments.ss.appendUrl NEQ ""){
			parseStruct.link=application.zcore.functions.zURLAppend(parseStruct.link, arguments.ss.appendUrl);
		}
		local.ts=structnew();
		local.ts.image_library_id=qpar.content_image_library_id;
		local.ts.output=false;
		local.ts.query=qpar;
		local.ts.row=qpar.currentrow;
		local.ts.size="250x187";
		//local.ts.crop=1;
		local.ts.count = 1; // how many images to get
		//zdump(ts);
		local.arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(local.ts);
		parseStruct.image=request.zos.globals.domain&"/z/a/images/s.gif";
		if(arraylen(local.arrImages) NEQ 0){
			parseStruct.image=request.zos.globals.domain&local.arrImages[1].link;
		}
		parseStruct.linktext="Click here for more";
		parseStruct.link=htmleditformat(parseStruct.link);
		parseStruct.linktext=htmleditformat(parseStruct.linktext);
		if(arguments.ss.moretemplate NEQ ""){
			tmp=application.zcore.functions.zParseVariables(arguments.ss.moretemplate, false, parseStruct);
		}else if(arguments.ss.template NEQ ""){
			tmp=application.zcore.functions.zParseVariables(arguments.ss.template, false, parseStruct);
		}else{
			tmp='<a href="#parseStruct.link#">#parseStruct.linktext#</a>';
		}
		tmp=arguments.ss.beforeCode&tmp&arguments.ss.afterCode;//&arguments.ss.delimiter;
		if(arguments.ss.insertAtPercent NEQ 0){
			p=(qpar.currentrow/qpar.recordcount)*100;
			if(p GTE arguments.ss.insertAtPercent){
				arguments.ss.insertAtPercent=0;
				arrayappend(arrL,arguments.ss.insertAtHTML);
			}
		}
		arrayappend(arrL,tmp);
		if(arguments.ss.returnData){
			arrayappend(rs.arrId,  qpar.content_id);
			arrayappend(rs.arrLink,parseStruct.link);
			arrayappend(rs.arrLot, qpar.content_lot_number);
			arrayappend(rs.arrStatus, qpar.content_for_sale);
			arrayappend(rs.arrText,parseStruct.linktext);
		}
		</cfscript>
		</cfloop>
        </cfif>
        <cfscript>
		if(arguments.ss.returnData){
			return rs;
		}else{
			return arraytolist(arrL,"");
		}
		</cfscript>
    </cffunction>
    
    
    <!--- 
	ts=structnew();
	ts.content_id="";
	configCom.includeContent(ts);
	 --->
    <cffunction name="includeContent" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
    	<cfargument name="query" type="any" required="no" default="#false#">
        <cfscript>
		var r1=0;
		var qc=0;
		var ts=structnew();
		var ts19156=duplicate(application.zcore.contentDefaultConfigStruct);//application.zcore.app.getAppCFC("content").getDefaultContentIncludeConfig();
		ts19156.contentWasIncluded=true;
		if(trim(arguments.ss.content_id) EQ ''){
			return false;
		}
		ts.hideTitle=false;
		ts.disableLinks=false;
		ts.simpleFormat=false;
		structappend(arguments.ss,ts,false);
		if(arguments.ss.simpleFormat){
			ts19156.contentSimpleFormat=true;	
			ts19156.disableChildContentSummary=true;
			ts19156.contentEmailFormat=true;
		}
		if(arguments.ss.hideTitle){
			ts19156.contentHideTitle=true;
		}
		if(arguments.ss.disableLinks){
			ts19156.contentDisableLinks=true;
		}
		ts19156.contentForceOutput=true;
		application.zcore.app.getAppCFC("content").setContentIncludeConfig(ts19156);
		r1=application.zcore.app.getAppCFC("content").getPropertyInclude(arguments.ss.content_id, arguments.query);
		return r1;
		</cfscript>
    </cffunction>
    
    <!--- 
	ts=structnew();
	ts.content_id="";
	ts.disableContentMeta=false;
	configCom.includePageContent(ts);
	 --->
    <cffunction name="includePageContent" localmode="modern" output="yes" returntype="boolean">
    	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
        <cfscript>
		var r1=0;
		var ts19156=duplicate(application.zcore.contentDefaultConfigStruct);//application.zcore.app.getAppCFC("content").getDefaultContentIncludeConfig();
		ts19156.contentWasIncluded=true;
		structappend(arguments.ss, ts19156, false);
		application.zcore.app.getAppCFC("content").setContentIncludeConfig(arguments.ss);
		r1=this.includeFullContent();
		
		if(r1){
			return true;
		}else{
			return false;
		}
        </cfscript>
    </cffunction>
    
    
    <cffunction name="viewPage" localmode="modern" access="remote" output="yes" returntype="boolean">
        <cfscript>
		var r1=0;
		var output="";
		var local=structnew();
		var ts19156=duplicate(application.zcore.contentDefaultConfigStruct);//application.zcore.app.getAppCFC("content").getDefaultContentIncludeConfig();
		ts19156.content_id=application.zcore.functions.zso(form,'content_id');
		ts19156.content_unique_name=application.zcore.functions.zso(form,'content_unique_name');
		application.zcore.app.getAppCFC("content").setContentIncludeConfig(ts19156);
		r1=this.includeFullContent();
		if(r1){
			return true;
		}else{
			return false;
		}
        </cfscript>
    </cffunction>
        
    <!--- 
	ts=structnew();
	ts.content_unique_name="";
	ts.disableContentMeta=false;
	configCom.includePageContentByName(ts);
	 --->
    <cffunction name="includePageContentByName" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
        <cfscript>
		var r1=0;
		var qc=0;
		var db=request.zos.queryObject;
		var local=structnew();
		var ts19156=duplicate(application.zcore.contentDefaultConfigStruct);//application.zcore.app.getAppCFC("content").getDefaultContentIncludeConfig();
		ts19156.contentWasIncluded=true;
		if(trim(arguments.ss.content_unique_name) EQ ''){
			return false;
		}
		</cfscript>
        <cfsavecontent variable="db.sql">
        SELECT content_id FROM #db.table("content", request.zos.zcoreDatasource)# content WHERE content_deleted=#db.param(0)# and content_for_sale <> #db.param(2)# and content_unique_name = #db.param(arguments.ss.content_unique_name)# and site_id=#db.param(request.zos.globals.id)# 
        </cfsavecontent><cfscript>qC=db.execute("qC");
		if(qC.recordcount NEQ 0){
			structappend(arguments.ss, ts19156, false);
			arguments.ss.content_id=qc.content_id;
			application.zcore.app.getAppCFC("content").setContentIncludeConfig(arguments.ss);
			r1=this.includeFullContent();
			if(r1){
				return true;
			}else{
				return false;
			}
		}else{
			return false;
		}
		</cfscript>
    </cffunction>
    
    
    <!--- 
	ts=structnew();
	ts.content_unique_name="";
	ts.disableContentMeta=false;
	configCom.includeContentByName(ts);
	 --->
    <cffunction name="includeContentByName" localmode="modern" output="yes" returntype="boolean">
    	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
        <cfscript>
		var r1=0;
		var qc=0;
		var db=request.zos.queryObject;
		var local=structnew();
		if(trim(arguments.ss.content_unique_name) EQ ''){
			return false;
		}
        // you must have a group by in your query or it may miss rows
        local.ts=structnew();
        local.ts.image_library_id_field="content.content_image_library_id";
        local.ts.count =  100; // how many images to get
        local.rs=application.zcore.imageLibraryCom.getImageSQL(local.ts);
        </cfscript>
        <cfsavecontent variable="db.sql">
        SELECT *  #db.trustedsql(local.rs.select)# FROM #db.table("content", request.zos.zcoreDatasource)# content #db.trustedsql(local.rs.leftJoin)#
         WHERE content_deleted=#db.param(0)# and content_for_sale <> #db.param(2)# and content_unique_name = #db.param(arguments.ss.content_unique_name)# and content.site_id=#db.param(request.zos.globals.id)# 
        GROUP BY content.content_id
        </cfsavecontent><cfscript>qc=db.execute("qC");
		if(qC.recordcount NEQ 0){
			arguments.ss.content_id=qc.content_id;
			r1=this.includeContent(arguments.ss, qc);
			if(r1){
				return true;
			}else{
				return false;
			}
		}else{
			return false;
		}
		</cfscript>
    </cffunction>
    
    
    
<!--- application.zcore.app.getAppCFC("content").searchReindexContent(false, true); --->
<cffunction name="searchReindexContent" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexEverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	searchCom=createobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	offset=0;
	limit=30;
	while(true){
		db.sql="SELECT content.*, content_config_url_article_id FROM #db.table("content", request.zos.zcoreDatasource)# content,
		#db.table("content_config", request.zos.zcoreDatasource)# content_config
		WHERE 
		content_config.site_id = content.site_id ";
		if(arguments.indexeverything EQ false){
			db.sql&=" and content.site_id = #db.param(request.zos.globals.id)# ";
		}else{
			db.sql&=" and content.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and content_id = #db.param(arguments.id)# ";
		}
		db.sql&=" and
                content_for_sale <> #db.param(2)# and 
		content_hide_link =#db.param(0)# and 
		content_deleted=#db.param(0)#    ";
		db.sql&=" LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteContent(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.content_name&" "&row.content_summary&" "&row.content_text;
				ds.search_title=row.content_name;
				ds.search_summary=row.content_summary;
				if(len(ds.search_summary) EQ 0){
					ds.search_summary=row.content_text;
				}
				
				if(row.content_url_only NEQ ''){
					ds.search_url=application.zcore.functions.zForceAbsoluteURL(request.zos.globals.domain, row.content_url_only);
				}else if(row.content_unique_name NEQ ''){
					ds.search_url=row.content_unique_name;
				}else{
					ds.search_url="/#application.zcore.functions.zURLEncode(row.content_name,'-')#-#row.content_config_url_article_id#-#row.content_id#.html";
				}
				ds.search_table_id=row.content_id;
				ds.app_id=this.app_id;
				ds.search_content_datetime=dateformat(row.content_updated_datetime, "yyyy-mm-dd")&" "&timeformat(row.content_updated_datetime, "HH:mm:ss");
				ds.site_id=row.site_id;
				
				searchCom.saveSearchIndex(ds); 
				if(arguments.id NEQ false){
					return;
				}
			}
		}
	}
	if(arguments.indexeverything){
		db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# WHERE 
		site_id <> #db.param(-1)# and 
		app_id = #db.param(this.app_id)# and 
		search_updated_datetime < #db.param(request.zos.mysqlnow)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>
    
    
<!--- application.zcore.app.getAppCFC("content").searchIndexDeleteContent(content_id); --->
<cffunction name="searchIndexDeleteContent" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)# ";
	db.execute("qDelete");
	</cfscript>
</cffunction>
    
    
    
<cffunction name="setRequestThumbnailSize" localmode="modern" output="no" returntype="struct">
	<cfargument name="width" type="numeric" required="yes">
	<cfargument name="height" type="numeric" required="yes">
	<cfargument name="crop" type="numeric" required="yes">
	<cfscript>
	local.thumbnailStruct={};
	local.thumbnailStruct.width=arguments.width;
	local.thumbnailStruct.height=arguments.height;
	local.thumbnailStruct.crop=arguments.crop;
	if(local.thumbnailStruct.width EQ 0){
		local.thumbnailStruct.width=application.zcore.functions.zso(application.zcore.app.getAppData("content").optionstruct, 'content_config_thumbnail_width', true, 0);
		local.thumbnailStruct.height=application.zcore.functions.zso(application.zcore.app.getAppData("content").optionstruct, 'content_config_thumbnail_height', true, 0);
		local.thumbnailStruct.crop=application.zcore.functions.zso(application.zcore.app.getAppData("content").optionstruct, 'content_config_thumbnail_crop', true, 0);
	}
	if(local.thumbnailStruct.width EQ 0){
		local.thumbnailStruct.width=200;
		local.thumbnailStruct.height=140;
		local.thumbnailStruct.crop=1;
	}
	request.zos.thumbnailSizeStruct=local.thumbnailStruct;
	return local.thumbnailStruct;
	</cfscript>
</cffunction>
    
    <cffunction name="getPropertyInclude" localmode="modern" output="yes" returntype="boolean">
    	<cfargument name="argContentId" type="string" required="yes">
    	<cfargument name="query" type="any" required="no" default="#false#">
        <cfscript>
		var db=request.zos.queryObject;
		var contentConfig=application.zcore.app.getAppCFC("content").getContentIncludeConfig();
		var local=structnew();
		local.includeLoopCount=0;
		if(not structkeyexists(request.zos, 'thumbnailSizeStruct')){
			this.setRequestThumbnailSize(0,0,0); 
			if(contentConfig.contentEmailFormat or application.zcore.functions.zso(request, 'contentUseSmallThumbnails',false,false) NEQ false){
				request.zos.thumbnailSizeStruct.width=120;
				request.zos.thumbnailSizeStruct.height=90;
			}
		}
            </cfscript>
    	<cfif isQuery(arguments.query) EQ false>
        
        
        <cfscript>
        // you must have a group by in your query or it may miss rows
        local.ts=structnew();
        local.ts.image_library_id_field="content.content_image_library_id";
        local.ts.count =  100; // how many images to get
        local.rs=application.zcore.imageLibraryCom.getImageSQL(local.ts);
        </cfscript>
        <cfsavecontent variable="db.sql">
        SELECT *  #db.trustedsql(local.rs.select)# FROM #db.table("content", request.zos.zcoreDatasource)# content #db.trustedsql(local.rs.leftJoin)# WHERE content.site_id = #db.param(request.zos.globals.id)# and 
        
        content_id =#db.param(arguments.argContentId)# <cfif application.zcore.functions.zso(session, 'zcontentshowinactive') EQ 0> and content_for_sale <> #db.param(2)# </cfif> and content_deleted = #db.param(0)# 
        GROUP BY content.content_id 
        <!---  ORDER BY content_sort ASC, content_datetime DESC, content_created_datetime DESC --->
        </cfsavecontent><cfscript>local.qContent=db.execute("qContent");</cfscript>
        <cfset local.tempQueryName=local.qContent>
        <cfelse>
        <cfset local.tempQueryName=arguments.query>
        </cfif>
        <cfloop query="local.tempQueryName">	
            <cfscript>
            
                local.ts=structnew();
                local.ts.image_library_id=local.tempQueryName.content_image_library_id;
                local.ts.output=false;
                local.ts.query=local.tempQueryName;
                local.ts.row=local.tempQueryName.currentrow;
                local.ts.size=request.zos.thumbnailSizeStruct.width&"x"&request.zos.thumbnailSizeStruct.height;
                local.ts.crop=request.zos.thumbnailSizeStruct.crop;
                local.ts.count = 1; 
                local.arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(local.ts);
                local.contentPhoto99=""; 
                if(arraylen(local.arrImages) NEQ 0){
                    local.contentPhoto99=(local.arrImages[1].link);
                }
                </cfscript>
             <cfsavecontent variable="local.output">
             <cfscript>
            if((structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager")) and contentConfig.contentEmailFormat EQ false and contentConfig.editLinksEnabled){
                writeoutput('<div style="display:inline; width:100%;" id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" onmouseover="zOverEditDiv(this,''/z/content/admin/content-admin/edit?content_id=#arguments.argContentId#&amp;return=1'');">');
            }
            if(isDefined('request.zos.propertyIncludeIndex') EQ false){
                request.zos.propertyIncludeIndex=0;
            }
            request.zos.propertyIncludeIndex++;
            
            if(local.tempQueryName.content_url_only NEQ ''){
                local.propertyLink=local.tempQueryName.content_url_only;
            }else if(local.tempQueryName.content_unique_name NEQ ''){
                local.propertyLink=local.tempQueryName.content_unique_name;
            }else{
                local.propertyLink="/#application.zcore.functions.zURLEncode(local.tempQueryName.content_name,'-')#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_article_id#-#local.tempQueryName.content_id#.html";
            }
            if(application.zcore.functions.zso(form, 'zsearchtexthighlight') NEQ ""){
                if(local.propertyLink DOES NOT CONTAIN "?"){
                    local.propertyLink&="?ztv1=1";	
                }
               local.propertyLink&="&zsearchtexthighlight=#urlencodedformat(form.zsearchtexthighlight)#";
            }
            local.pci3891=false;
            local.propDisplayCom = CreateObject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
            
           local.propertyLink=htmleditformat(local.propertyLink);
           </cfscript>
            <cfif application.zcore.app.siteHasApp("listing")>
                 <cfscript>
                 local.mlsPIncluded=false;
                 </cfscript>
                    <cfif local.tempQueryName.content_mls_number NEQ "" and local.tempQueryName.content_mls_override  EQ 1>
                        <cfscript>
                        local.propertyDataCom = CreateObject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
                        
                        local.ts = StructNew();
                        local.ts.offset =0;
                        local.perpageDefault=10;
                        local.perpage=10;
                        local.perpage=max(1,min(local.perpage,100));
                        local.ts.perpage = local.perpage;
                        local.ts.distance = 30; // in miles
                        local.ts.searchCriteria=structnew();
                        local.ts.arrMLSPID=arraynew(1);
                        local.ts.disableCount=true;
                        local.ts.arrMLSPID[1]=local.tempQueryName.content_mls_number; 
                        //local.ts.debug=true;
                        local.returnStruct = local.propertyDataCom.getProperties(ts);
                        if(local.returnStruct.query.recordcount NEQ 0){	
                            local.pci3891=true;
                            local.mlsPIncluded=true;
                            local.ts = StructNew();
                            local.ts.contentDetailView=false;
                            if(contentConfig.contentSimpleFormat){
                                local.ts.emailFormat=true;
                            }
                            local.ts.dataStruct = local.returnStruct;
                           // local.ts.navStruct=searchStruct;
                            local.propDisplayCom.init(local.ts);
                        
                            local.res=propDisplayCom.display();
                            writeoutput('<table style="width:100%;"><tr><td>'&local.res&'</td></tr></table>');
                        }
                        </cfscript>
                    </cfif>
                <cfif contentConfig.showmlsnumber and application.zcore.app.siteHasApp("listing")> 
                <cfscript>
                local.tempMlsId=local.tempQueryName.content_mls_provider;
                local.tempMlsPId=local.tempQueryName.content_mls_number;
                if(local.tempMLSId NEQ "" and local.tempMlsPId NEQ ""){
                    local.tempMLSStruct=application.zcore.listingCom.getMLSStruct(local.tempMLSId);
                    if(isStruct(local.tempMLSStruct)){
                        if(local.tempMLSStruct.mls_login_url NEQ ''){
                            writeoutput('MLS ###local.tempMLSPid# found in #local.tempMLSStruct.mls_name# MLS, <a href="#local.tempMLSStruct.mls_login_url#" target="_blank">click here to login to MLS</a><br />');
                        }else{
                            writeoutput('MLS ###local.tempMLSPid# found in #local.tempMLSStruct.mls_name# MLS<br />');
                        }
                    }
                }
                </cfscript>
                </cfif>
                <cfif local.mlsPIncluded EQ false and (local.tempQueryName.content_mls_number NEQ "" or local.tempQueryName.content_is_listing EQ 1)>
            <cfscript>
            local.statusMessage="";
            if(local.tempQueryName.content_diagonal_message NEQ ""){
                local.statusMessage=local.tempQueryName.content_diagonal_message;
            }else if(local.tempQueryName.content_for_sale EQ '4'){
                local.statusMessage="UNDER#chr(10)#CONTRACT";	
            }else if(local.tempQueryName.content_for_sale EQ '3'){
                local.statusMessage="SOLD";	
            }
            for(local.i in application.zcore.app.getAppData("listing").sharedStruct.mlsStruct){
                local.mls_id=local.i;
                break;
            }
		if(structkeyexists(request.zos.listing.cityNameStruct,local.tempQueryName.content_property_city)){
			local.cityName=request.zos.listing.cityNameStruct[local.tempQueryName.content_property_city];
		}else{
			local.cityName="";	
		}
        local.pci3891=true;
		local.lpc38=0;
        application.zcore.listingCom.outputEnlargementDiv();
        </cfscript>
        <cfsavecontent variable="local.thePaths"><cfif local.contentPhoto99 NEQ "">#local.contentPhoto99#</cfif></cfsavecontent>
        <input type="hidden" name="mc#local.tempQueryName.content_id#_#request.zos.propertyIncludeIndex#_mlstempimagepaths" id="mc#local.tempQueryName.content_id#_#request.zos.propertyIncludeIndex#_mlstempimagepaths" value="#htmleditformat(local.thePaths)#" />
        
        <cfscript>
        local.link9='/z/listing/sl/index?saveAct=check&content_id=#local.tempQueryName.content_id#';
        local.link9&='&returnURL='&urlEncodedFormat(request.zos.originalURL&"?"&replacenocase(replacenocase(request.zos.cgi.QUERY_STRING,"searchid=","ztv=","ALL"),"__zcoreinternalroutingpath=","ztv=","ALL"));
       
        </cfscript>
            <cfif contentConfig.disableChildContentSummary> 
            <h2><a href="#local.propertyLink#">#local.tempQueryName.content_name#</a></h2>
            <hr />
            <cfelse>
                    <table class="zls2-1">
                    <tr><td class="zls2-15" colspan="3" style="padding-right:0px;">
                     <table class="zls2-8" style="border-spacing:5px;">
                    <cfif contentConfig.contentEmailFormat EQ false>
                    <tr><td class="zls2-9"><span class="zls2-10"><cfif local.tempQueryName.content_price NEQ "" and local.tempQueryName.content_price NEQ "0">#dollarformat(local.tempQueryName.content_price)# <cfif local.tempQueryName.content_price LT 20> per sqft</cfif></cfif></span></td><cfif local.tempQueryName.content_address CONTAINS "unit:">
        <td class="zls2-9-3">UNIT ##<cfscript>
        p=findnocase("unit:",local.tempQueryName.content_address);
        writeoutput(trim(removechars(local.tempQueryName.content_address,1, p+5)));
        </cfscript></td>
        </cfif>
        <td class="zls2-9-2"><strong>#local.cityName# </strong><br />
        <cfif local.tempQueryName.content_property_bedrooms NEQ 0>#local.tempQueryName.content_property_bedrooms# beds, </cfif>
        <cfif local.tempQueryName.content_property_bathrooms NEQ 0>#local.tempQueryName.content_property_bathrooms# baths, </cfif>
        <cfif local.tempQueryName.content_property_half_baths NEQ "" and local.tempQueryName.content_property_half_baths NEQ 0>#local.tempQueryName.content_property_half_baths# half baths, </cfif>
        <cfif local.tempQueryName.content_property_sqfoot neq '0' and local.tempQueryName.content_property_sqfoot neq ''>#local.tempQueryName.content_property_sqfoot# living sqft</cfif>
    	</td></tr></table><br style="clear:both;" />
                    
                    <div class="zls-buttonlink">
                   <cfif request.cgi_script_name EQ '/z/listing/property/detail/index' or (local.tempQueryName.content_id EQ application.zcore.functions.zso(form, 'content_id') and request.cgi_script_name EQ '/z/content/content/viewPage')><cfelse><a href="#request.zos.globals.domain##local.propertyLink#">View Full Details<cfif lpc38 GT 1> &amp; Photos</cfif></a></cfif>
				   <cfif request.cgi_script_name NEQ '/z/misc/inquiry/index'><cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 0>
				   <cfelse><a href="##" onclick="zShowModalStandard('/z/listing/inquiry/index?action=form&amp;modalpopforced=1&amp;content_id=#local.tempQueryName.content_id#&amp;inquiries_comments=#urlencodedformat('I''d like to apply to rent this property')#', 540, 630);return false;" rel="nofollow">Apply Now</a></cfif></cfif><cfif request.cgi_script_name NEQ '/z/listing/inquiry/index'><a href="#request.zos.globals.domain&application.zcore.functions.zBlockURL(link9)#" rel="nofollow" class="zNoContentTransition">Save Listing</a></cfif><cfif local.tempQueryName.content_virtual_tour NEQ ""><a href="#application.zcore.functions.zblockurl(local.tempQueryName.content_virtual_tour)#" rel="nofollow" onclick="window.open(this.href); return false;">Virtual Tour</a></cfif><cfif request.cgi_script_name NEQ '/z/listing/inquiry/index'><div style="float:right;  width:110px;"><a href="##" onclick="zShowModalStandard('/z/misc/inquiry/index?content_id=#local.tempQueryName.content_id#&modalpopforced=1', 540, 630);return false;" rel="nofollow">Ask Question</a></div></cfif>
                    
                    </div></td></tr></cfif>
                    <tr><td class="zls2-3" colspan="2"><table class="zls2-16">
                    <tr>
                    <td class="zls2-4" rowspan="4">
         <cfif structkeyexists(request.zos,'listingApp') and application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_image_enlarge',false,0)  EQ 0>
         <div id="mc#local.tempQueryName.content_id#_#request.zos.propertyIncludeIndex#" class="zls2-5" onmousemove="zImageMouseMove('mc#local.tempQueryName.content_id#_#request.zos.propertyIncludeIndex#',event);" onmouseout="setTimeout('zImageMouseReset(\'mc#local.tempQueryName.content_id#_#request.zos.propertyIncludeIndex#\')',100);"><a href="#local.propertyLink#"><cfif local.contentPhoto99 NEQ ""><img id="mc#local.tempQueryName.content_id#_#request.zos.propertyIncludeIndex#_img" class="zlsListingImage" src="#request.zos.globals.domain&local.contentPhoto99#"  alt="Listing Image" /><cfelse><img id="mc#local.tempQueryName.content_id#_#request.zos.propertyIncludeIndex#_img" src="#request.zos.globals.domain&'/z/a/listing/images/image-not-available.gif'#" alt="Image Not Available" /></cfif></a>
         </div><a class="zls2-5-2" href="#local.propertyLink#" onmousemove="zImageMouseMove('mc#local.tempQueryName.content_id#_#request.zos.propertyIncludeIndex#',event);" onmouseout="setTimeout('zImageMouseReset(\'mc#local.tempQueryName.content_id#_#request.zos.propertyIncludeIndex#\')',100);">
        <cfif local.statusMessage NEQ "" and contentConfig.contentEmailFormat EQ false><div style="display:none;" class="zFlashDiagonalStatusMessage">#htmleditformat(local.statusMessage)#</div></cfif></a>
                    <cfif local.lpc38 LTE 1 or ( structkeyexists(request.zos,'listingApp') and application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_image_enlarge',false,0) EQ 2)><div class="zls2-6"></div><cfelse><div class="zls2-7"><cfif local.lpc38 NEQ 0>ROLLOVER TO VIEW #local.lpc38# PHOTO<cfif local.lpc38 GT 1>S</cfif></cfif></div></cfif>
                    <cfelse>
                     <div id="mc#local.tempQueryName.content_id#_#request.zos.propertyIncludeIndex#" class="zls2-5"><a href="#local.propertyLink#"><cfif local.contentPhoto99 NEQ ""><img id="mc#local.tempQueryName.content_id#_#request.zos.propertyIncludeIndex#_img" class="zlsListingImage" src="#request.zos.globals.domain&local.contentPhoto99#"  alt="Listing Image" /><cfelse><img id="mc#local.tempQueryName.content_id#_#request.zos.propertyIncludeIndex#_img" src="#request.zos.globals.domain&'/z/a/listing/images/image-not-available.gif'#" alt="Image Not Available" /></cfif></a>
                     </div>
                     </cfif></td><td class="zls2-17" style="vertical-align:top;padding:0px;">
                     <cfif contentConfig.contentEmailFormat>
                     <h2><a href="#local.propertyLink#">#local.tempQueryName.content_name#</a></h2>
                     <cfelse>
                     <table style="width:100%;">
                    <cfif local.tempQueryName.content_mls_number NEQ ""><tr><td class="zls2-2">MLS ###listgetat(local.tempQueryName.content_mls_number,2,'-')# | Source: #request.zos.globals.shortdomain#</td></tr></cfif>
                        <tr>
                            <td><div class="zls2-11"><cfscript>
                        </cfscript><h2><a href="#local.propertyLink#">#local.tempQueryName.content_name#</a></h2>
                   #local.tempQueryName.content_summary#</div>
                    
                    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 0 and structkeyexists(request.zos,'listingApp') and application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_enable_mortgage_quote',true,1) EQ 1><table class="zls2-13"><tr><td>Low interest financing available. <a href="##" onclick="zShowModalStandard('/z/misc/mortgage-quote/index?modalpopforced=1', 540, 630);return false;" rel="nofollow"><!--- <a href="/z/misc/mortgage-quote/index" rel="nofollow"> ---><strong>Get Pre-Qualified</strong></a></td></tr></table></cfif>
                    <cfif local.tempQueryName.content_for_sale EQ '3' or local.tempQueryName.content_for_sale EQ "4"><table class="zls2-14"><tr><td><cfif local.tempQueryName.content_for_sale EQ '3'><span class="zls2-status">This listing is SOLD</span><cfelseif local.tempQueryName.content_for_sale EQ '4'><span class="zls2-status">This listing is UNDER CONTRACT</span></cfif>
                    </td></tr></table></cfif>
                    </cfif>
                    </td>
                    <cfscript>
                    local.newagentid="";
                    for(local.n in application.zcore.app.getAppData("listing").sharedStruct.mlsStruct){
                        local.mls_id=local.n;
                        if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[local.mls_id],'userAgentIdStruct') and local.tempQueryName.content_listing_user_id NEQ 0){
                            if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[local.mls_id].userAgentIdStruct, local.tempQueryName.content_listing_user_id) and structcount(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[local.mls_id].userAgentIdStruct[local.tempQueryName.content_listing_user_id]) NEQ 0){
                                for(local.n in application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[local.mls_id].userAgentIdStruct[local.tempQueryName.content_listing_user_id]){
                                    local.newagentid=local.n;
                                    break;
                                }
                            }
                        }
                        if(local.newagentid NEQ ""){
                            break;
                        }
                    }
                    </cfscript>
                    </tr>
                    </table>
                    </td></tr></table></td>
                    <cfif contentConfig.contentEmailFormat EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[local.mls_id], "agentIdStruct") and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[mls_id].agentIdStruct, local.newagentid)>
                        <cfscript>
                        
                        local.agentStruct=application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[local.mls_id].agentIdStruct[local.newagentid];
                        local.userGroupCom = CreateObject("component", "zcorerootmapping.com.user.user_group_admin");
                        local.userusergroupid = local.userGroupCom.getGroupId('user', request.zos.globals.id);
                        </cfscript>	
                        <td class="zls2-agentPanel">
                        LISTING AGENT<br />
                            <cfif fileexists(application.zcore.functions.zVar('privatehomedir', local.agentStruct.userSiteId)&removechars(request.zos.memberImagePath,1,1)&local.agentStruct.member_photo)>
                                <img src="#application.zcore.functions.zvar('domain', local.agentStruct.userSiteId)##request.zos.memberImagePath##local.agentStruct.member_photo#" alt="Listing Agent" width="90" /><br />
                            </cfif>
                        <cfif local.agentStruct.member_first_name NEQ ''>#local.agentStruct.member_first_name#</cfif> <cfif local.agentStruct.member_last_name NEQ ''>#local.agentStruct.member_last_name#<br /></cfif>
                        <cfif local.agentStruct.member_phone NEQ ''><strong>#local.agentStruct.member_phone#</strong><br /></cfif>
                        <cfif application.zcore.app.getAppData("content").optionstruct.content_config_url_listing_user_id NEQ "0" and local.agentStruct.member_public_profile EQ 1>
                        <cfscript>
                        local.tempName=application.zcore.functions.zurlencode(lcase("#local.agentStruct.member_first_name# #local.agentStruct.member_last_name# "),'-');
                        </cfscript>
                        <a href="/#local.tempName#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_listing_user_id#-#local.agentStruct.user_id#.html" target="_blank">Bio &amp; Listings</a>
                        </cfif>
                        </td>
                    </cfif></tr></table>
        <div class="zls2-divider"></div>
                </cfif>
                </cfif>
            </cfif>
            <cfif local.pci3891 EQ false>
	    
        <table <cfif len(contentConfig.tablestyle)> #contentConfig.tablestyle#<cfelse> style="width:100%;"</cfif>>
            <tr><cfif local.contentPhoto99 NEQ ""><td class="zcontent-imagethumbwidth" style="width:#request.zos.thumbnailSizeStruct.width#px;  vertical-align:top;padding-right:20px;">
            <cfif contentConfig.contentDisableLinks EQ false><a href="#local.propertyLink#"></cfif>
            <img src="#request.zos.globals.domain&local.contentPhoto99#" alt="#htmleditformat(local.tempQueryName.content_name)#" <cfif contentConfig.contentEmailFormat or application.zcore.functions.zso(request, 'contentUseSmallThumbnails',false,false) NEQ false>width="120"</cfif> style="border:none;" /><cfif contentConfig.contentDisableLinks EQ false></a></cfif></td></cfif>
            <td style="vertical-align:top; "><cfif application.zcore.functions.zso(form, 'content_id') NEQ local.tempQueryName.content_id or contentConfig.contentForceOutput><cfif application.zcore.functions.zso(form, 'contentHideTitle',false,false) EQ false><h2><cfif contentConfig.contentDisableLinks EQ false><a href="#local.propertyLink#"></cfif>#htmleditformat(local.tempQueryName.content_name)#<cfif contentConfig.contentDisableLinks EQ false></a></cfif></h2></cfif></cfif>
            
            
            <cfif contentConfig.disableChildContentSummary EQ false>
            
        <cfif local.tempQueryName.content_is_listing EQ 1>
            <table style="width:100%;">
        <tr>
          <td><cfif local.tempQueryName.content_property_bedrooms NEQ 0>#local.tempQueryName.content_property_bedrooms# Bedroom</cfif><cfif local.tempQueryName.content_property_type_id NEQ 0 and local.tempQueryName.content_property_type_id NEQ "">
            <cfsavecontent variable="db.sql">SELECT * FROM #db.table("content_property_type", request.zos.zcoreDatasource)# content_property_type WHERE content_property_type_id = #db.param(local.tempQueryName.content_property_type_id)# </cfsavecontent><cfscript>local.qCp3i2=db.execute("qCp3i2");</cfscript>
            <cfif local.qCp3i2.recordcount NEQ 0><br />
        #local.qCp3i2.content_property_type_name#</cfif>
            </cfif>
          </td>
          <td style="white-space:nowrap;"><cfif local.tempQueryName.content_property_bathrooms NEQ 0 or local.tempQueryName.content_property_half_baths NEQ 0>#local.tempQueryName.content_property_bathrooms# Bath <cfif local.tempQueryName.content_property_half_baths NEQ 0><br />#local.tempQueryName.content_property_half_baths# half&nbsp;baths</cfif></cfif></td>
          <td style="white-space:nowrap;"><cfif local.tempQueryName.content_property_sqfoot NEQ "" and local.tempQueryName.content_property_sqfoot NEQ 0>#local.tempQueryName.content_property_sqfoot# SQFT<br /></cfif><cfscript>
            local.arr1=arraynew(1);
            if(local.tempQueryName.content_address NEQ ""){ 
                arrayappend(local.arr1,local.tempQueryName.content_address);
            }
            if(cityName NEQ ""){ 
                arrayappend(local.arr1,cityName);
            }
            if(local.tempQueryName.content_property_state NEQ ""){ 
                arrayappend(local.arr1,local.tempQueryName.content_property_state);
            }
            if(arraylen(local.arr1) NEQ 0){
                writeoutput(arraytolist(local.arr1, ", "));
            }
            if(local.tempQueryName.content_property_zip NEQ ""){ 
                writeoutput(" "&local.tempQueryName.content_property_zip);
            }
            if(local.tempQueryName.content_property_country NEQ "" and local.tempQueryName.content_property_country NEQ "US"){ 
                writeoutput(" "&local.tempQueryName.content_property_country);
            }
            </cfscript></td>
          
          
        </tr>
        </table>
        
         <cfif local.tempQueryName.content_price NEQ 0 and local.tempQueryName.content_for_sale EQ 1><span style="font-size:14px; font-weight:bold;">Priced at #dollarformat(local.tempQueryName.content_price)#</span></cfif>
        <cfif local.tempQueryName.content_for_sale EQ '3'><span style="color:##FF0000; font-size:14px; font-weight:bold;">This listing is SOLD</span><br /><br /><cfelseif local.tempQueryName.content_for_sale EQ '4'><span style="color:##FF0000; font-size:14px; font-weight:bold;">This listing is UNDER CONTRACT</span><br /><br /></cfif>
            <cfif local.tempQueryName.content_datetime NEQ ''><strong class="news-date"><cfif isdate(local.tempQueryName.content_datetime)>#DateFormat(local.tempQueryName.content_datetime,'m/d/yyyy')#</cfif> 
            <cfif local.tempQueryName.content_datetime NEQ '' and Timeformat(local.tempQueryName.content_datetime,'HH:mm:ss') NEQ '00:00:00'>#TimeFormat(local.tempQueryName.content_datetime,'h:mm tt')#</cfif></strong> <br /></cfif>
           
           </cfif>
            <cfif local.tempQueryName.content_id NEQ application.zcore.functions.zso(form, 'content_id')><cfif local.tempQueryName.content_summary EQ ""><cfscript>if(request.cgi_script_name EQ "/z/misc/search-site/results"){ local.shortSummary=left(rereplace(local.tempQueryName.content_text,"<[^>]*>"," ","ALL"),250);  writeoutput(local.shortSummary); } </cfscript><cfelse>#local.tempQueryName.content_summary#</cfif></cfif>
        <div style="font-weight:bold; font-size:13px;">
        <cfset local.detailShown=false><cfif local.tempQueryName.content_id NEQ application.zcore.functions.zso(form, 'content_id') and local.tempQueryName.content_is_listing EQ 1><a href="#local.propertyLink#">Read More</a> <cfset local.detailShown=true></cfif>
        <cfif contentConfig.contentEmailFormat EQ false and local.tempQueryName.content_is_listing EQ 1><cfif local.detailShown> | </cfif><cfif contentConfig.contentDisableLinks EQ false>
<a href="#application.zcore.functions.zblockurl('/z/misc/inquiry/index?content_id=#local.tempQueryName.content_id#')#" style="font-size:14px; font-weight:bold;">Inquire about this property</a>
</cfif></cfif>
        <cfif  local.tempQueryName.content_virtual_tour NEQ ''> | 
                             <a href="#application.zcore.functions.zblockurl(local.tempQueryName.content_virtual_tour)#" rel="nofollow" onclick="window.open(this.href); return false;">View 360&deg; Virtual Tour</a>
                         </cfif></div>
            <cfelse>  
            </cfif>
            </td></tr></table><cfif local.tempQueryName.content_id NEQ application.zcore.functions.zso(form, 'content_id')><hr /></cfif>
            </cfif>
            <cfscript>
        if((structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager")) and contentConfig.contentEmailFormat EQ false and contentConfig.editLinksEnabled){
                writeoutput('</div>');
            }
            </cfscript>
            </cfsavecontent>
            <cfscript>
            if(contentConfig.contentForceOutput EQ false and structkeyexists(request,'cOutStruct') and structkeyexists(request,'contentCount')){
                // add content
                request.contentCount++;
                local.ts=StructNew();
                local.ts.output=local.output;
                if(local.tempQueryName.content_price EQ 0){
                    local.ts.price=1000000000;
                }else{
                    local.ts.price=local.tempQueryName.content_price;
                }
                local.ts.id=local.tempQueryName.content_mls_number;
                local.ts.name=local.tempQueryName.content_name;
                local.ts.sort=local.tempQueryName.content_sort;
                application.zcore.app.getAppCFC("content").excludeContentId(local.tempQueryName.content_id);
                request.cOutStruct[request.contentCount]=local.ts;
            }else{
                writeoutput(local.output);	
            }
			local.includeLoopCount++;
            </cfscript>
        </cfloop>
        <cfscript>
		return local.includeLoopCount;
		</cfscript>
    </cffunction>
    
    <cffunction name="searchCurrentParentLinks" localmode="modern" output="no" returntype="boolean" access="public">
    	<cfargument name="theURL" type="string" required="yes">
        <cfscript>
		var local=structnew();
		if(structkeyexists(request.zos,'arrContentParentURLStruct')){
			for(local.i=arraylen(request.zos.arrContentParentURLStruct);local.i GTE 1;local.i--){
				if(compare(arguments.theURL, request.zos.arrContentParentURLStruct[local.i]) EQ 0 and request.zos.arrContentParentURLStruct[local.i] NEQ "/"){
					return true;	
				}
			}
		}
		return false;
		</cfscript>
    </cffunction>
    
<cffunction name="getParentId" localmode="modern" output="no" returntype="boolean" access="public">
	<cfscript>
	if(structkeyexists(request.zos,'arrContentParentIDStruct')){
		return request.zos.arrContentParentIDStruct[arraylen(request.zos.arrContentParentIDStruct)];
	}
	return 0;
	</cfscript>
</cffunction>

<cffunction name="searchCurrentParentIds" localmode="modern" output="no" returntype="boolean" access="public">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	var local=structnew();
	if(structkeyexists(request.zos,'arrContentParentIDStruct')){
		for(local.i=arraylen(request.zos.arrContentParentIDStruct);local.i GTE 1;local.i--){
			if(compare(arguments.id, request.zos.arrContentParentIDStruct[local.i]) EQ 0){
				return true;	
			}
		}
	}
	return false;
	</cfscript>
</cffunction>
    
    
	<!--- split all the globals into function calls - then worry about mvc principles after it works with all the globals being updated. --->
	<cffunction name="includeFullContent" localmode="modern" access="public" output="yes" returntype="boolean">
    	<cfscript>
		var local=structnew();
		var content_id=0;
		var db=request.zos.queryObject;
		var contentConfig=application.zcore.app.getAppCFC("content").getContentIncludeConfig();
		// uncomment to enable cache
		//application.zcore.cache.enableCache();
		// application.zcore.cache.setExpiration(seconds);
		/*local.cacheString=application.zcore.functions.zStructToCacheString(contentConfig);
		if(structkeyexists(application.sitestruct[request.zos.globals.id].contentPageCache, local.cacheString) and application.zcore.user.checkGroupAccess("member") EQ false){
			// needs to output the title, meta, stylesheets and script in struct instead of only the output!
			writeoutput(application.sitestruct[request.zos.globals.id].contentPageCache[local.cacheString]);
			return true;
		}*/
		application.zcore.app.getAppCFC("content").initExcludeContentId();
        if(structkeyexists(contentConfig, 'content_unique_name') and len(contentConfig.content_unique_name)){
            local.ts =structnew();
            local.ts.content_unique_name=contentConfig.content_unique_name;
            local.qContent=application.zcore.app.getAppCFC("content").getContentByName(local.ts);
            if(isQuery(local.qContent)){// and (contentConfig.disableContentMeta EQ false)){
                content_id=local.qContent.content_id;
            }else{
				return 0;
			}
        }else{
            if((contentConfig.disableContentMeta EQ false) and len(contentConfig.content_id)){
                content_id=contentConfig.content_id;
            }
        }/**/
		
		/*if(structkeyexists(application.sitestruct[request.zos.globals.id].contentPageIdCache, content_id) EQ false){
			application.sitestruct[request.zos.globals.id].contentPageIdCache[content_id]=structnew();
		}
		application.sitestruct[request.zos.globals.id].contentPageIdCache[content_id][local.cacheString]=true;
		*/
		if(not contentConfig.contentWasIncluded){
			if(len(content_id) EQ false or content_id EQ 0){
				if(contentConfig.disableContentMeta EQ false){
					application.zcore.functions.z301Redirect('/');
				}else{
					return 0;
				}
			}
		}
		if(structkeyexists(request.zos.userSession.groupAccess, "member")){
			if(isDefined('zcontentshowinactive')){
				session.zcontentshowinactive=zcontentshowinactive;
			}else{
				session.zcontentshowinactive=application.zcore.functions.zso(session, 'zcontentshowinactive',true);	
			}
			request.zos.zcontentshowinactive=true;
		}else{
			request.zos.zcontentshowinactive=false;
		}
        </cfscript>
        <cfsavecontent variable="local.output">
        <cfscript>
        // you must have a group by in your query or it may miss rows
        local.ts =structnew();
        local.ts.image_library_id_field="content.content_image_library_id";
        local.ts.count =  1; // how many images to get
        local.rs=application.zcore.imageLibraryCom.getImageSQL(local.ts);
        </cfscript>
                
            
        <cfsavecontent variable="db.sql">
        SELECT * #db.trustedsql(local.rs.select)# FROM #db.table("content", request.zos.zcoreDatasource)# content  #db.trustedsql(local.rs.leftJoin)#  WHERE content.site_id = #db.param(request.zos.globals.id)#
        and content.content_id = #db.param(content_id)# 
        <cfif structkeyexists(form, 'preview') EQ false and request.zos.zcontentshowinactive EQ false>
        and content_for_sale <> #db.param(2)#
        </cfif> and content_deleted=#db.param(0)# 
        GROUP BY content.content_id 
        </cfsavecontent><cfscript>local.qContent=db.execute("qContent");
		local.returnCountTotal=local.qContent.recordcount;
        if(local.qContent.recordcount EQ 0 and contentConfig.disableContentMeta EQ false){
            application.zcore.functions.z404("Content record was missing in includeFullContent");//301Redirect('/');
        }
        //application.zcore.functions.zQueryToStruct(local.qContent);
        local.ts994824713=structnew();
        application.zcore.functions.zQueryToStruct(local.qContent,local.ts994824713);
		
		application.zcore.siteOptionCom.setCurrentSiteOptionAppId(local.ts994824713.content_site_option_app_id);
		local.contentSearchMLS=local.ts994824713.content_search_mls;
		
        //structappend(variables, local.ts994824713, true);
        request.zos.zPrimaryContentId=content_id;
        local.parentChildSorting=local.ts994824713.content_child_sorting;
		if(not contentConfig.contentWasIncluded){
			if(local.ts994824713.content_unique_name EQ ""){
				if(structkeyexists(form, 'zurlname') and structkeyexists(form, 'forcecontent') EQ false and compare(application.zcore.functions.zURLEncode(local.ts994824713.content_name,'-'), form.zURLName) NEQ 0){
					application.zcore.functions.z301Redirect('/#application.zcore.functions.zURLEncode(local.ts994824713.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#local.ts994824713.content_id#.html');
				}
				local.currentContentURL='/#application.zcore.functions.zURLEncode(local.ts994824713.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#local.ts994824713.content_id#.html';
			}else{
				if(compare(local.ts994824713.content_unique_name, request.zos.originalURL) NEQ 0){
					application.zcore.functions.z301Redirect(local.ts994824713.content_unique_name);
				}
				local.currentContentURL=local.ts994824713.content_unique_name;
			}
			if(local.ts994824713.content_url_only NEQ "" and (left(local.ts994824713.content_url_only,1) EQ '/' or left(local.ts994824713.content_url_only,4) EQ 'http')){
				if(local.ts994824713.content_unique_name EQ "" or local.ts994824713.content_unique_name NEQ local.ts994824713.content_url_only){
					if('/#application.zcore.functions.zURLEncode(local.ts994824713.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#local.ts994824713.content_id#.html' NEQ local.ts994824713.content_url_only){
						application.zcore.functions.z301Redirect(local.ts994824713.content_url_only);	
					}
				}
			}
		}
		local.arrNav=ArrayNew(1);
		local.cpi=local.ts994824713.content_parent_id;
		if((structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager")) and contentConfig.contentEmailFormat EQ false and contentConfig.editLinksEnabled){
			writeoutput('<div style="display:inline;"  id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" onmouseover="zOverEditDiv(this,''/z/content/admin/content-admin/edit?content_id=#local.ts994824713.content_id#&amp;return=1'');">');
			application.zcore.template.prependTag('pagetitle','<span style="display:inline;" id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" onmouseover="zOverEditDiv(this,''/z/content/admin/content-admin/edit?content_id=#local.ts994824713.content_id#&amp;return=1'');">');
			application.zcore.template.appendTag('pagetitle','</span>');
		//position:relative;float:left;
		}
        if(local.ts994824713.content_hide_modal EQ 1){
            application.zcore.functions.zModalCancel();	
        }
        if(local.ts994824713.content_hide_global EQ 1){
            request.hideGlobalText=true;
        }
        if(trim(local.ts994824713.content_engine_name) NEQ ''){
            request.engineName=local.ts994824713.content_engine_name;
        }
        local.mlsListingIncluded=false;
    
        if(structkeyexists(local, 'subpageLinkLayoutBackup') EQ false){
            local.subpageLinkLayoutBackup=local.ts994824713.content_subpage_link_layout;
        }
        if(structkeyexists(local, 'parentpageLinkLayoutBackup') EQ false){
            local.parentpageLinkLayoutBackup=local.ts994824713.content_parentpage_link_layout;
        }
        form.content_parent_id = local.ts994824713.content_parent_id;
        </cfscript>
        <cfsavecontent variable="local.theImageOutputHTML">
        <cfscript>
        
        local.ts =structnew();
        local.ts.image_library_id=local.ts994824713.content_image_library_id;
        local.ts.size="#request.zos.globals.maximagewidth#x2000";
        local.ts.crop=0; 
	local.ts.top=true;
        if(local.ts994824713.content_photo_hide_image EQ 1){
            local.ts.offset=0;
        }else{
            local.ts.offset=1;
        }
	if(local.ts994824713.content_image_library_layout EQ 7){
		local.ts.limit=1;
	}
        local.ts.layoutType=application.zcore.imageLibraryCom.getLayoutType(local.ts994824713.content_image_library_layout);
        application.zcore.imageLibraryCom.displayImages(local.ts);
       
       </cfscript>
       </cfsavecontent>
        <cfif local.ts994824713.content_image_library_layout EQ 7 or local.ts994824713.content_image_library_layout EQ 3 or local.ts994824713.content_image_library_layout EQ 4 or local.ts994824713.content_image_library_layout EQ 6>
        #local.theImageOutputHTML#
        </cfif>
        <cfsavecontent variable="local.theContentHTMLSection">
        
        <cfif local.ts994824713.content_slideshow_id NEQ 0>
            <table style="width:100%;" class="zContentSlideShowDiv"><tr><td style="text-align:center;"><cfscript>application.zcore.functions.zEmbedSlideShow(local.ts994824713.content_slideshow_id);</cfscript></td></tr></table>
        </cfif>
        
        
        <cfscript>
        request.contentCount=0;
        request.cOutStruct=structnew();	
		application.zcore.app.getAppCFC("content").excludeContentId(local.ts994824713.content_id);
        </cfscript>
        
        <cfset local.curId = local.ts994824713.content_id>
        <cfif local.curId EQ 0> <cfset local.curId = local.ts994824713.content_parent_id></cfif>
        <!---  ---><cfset local.hasAccess=false>
        <cfscript>
        local.arrAllowGroupIds=ArrayNew(1);
        // disable local.defaultContentId
        //local.defaultContentId=0;
        </cfscript>
        <!--- <cfif isDefined('local.defaultContentId') and (local.defaultContentId EQ 0 or local.curId EQ local.defaultContentId)>
            <!--- always allow the default even without database set... ---->
            <cfset local.hasAccess=true>
        </cfif> --->
        
    	<cfif local.ts994824713.content_user_group_id NEQ "0" and application.zcore.user.checkGroupIdAccess(local.ts994824713.content_user_group_id) EQ false>
	    	<cfset local.hasAccess=true>
        </cfif>
        <cfset local.forceLogin=false>
        <cfif local.curId NEQ 0 and local.hasAccess EQ false>
        <cfloop from="1" to="100" index="local.i">
            <cfsavecontent variable="db.sql">
            SELECT content_user_group_id, content_parent_id FROM #db.table("content", request.zos.zcoreDatasource)# content WHERE content_id = #db.param(local.curId)# and site_id = #db.param(request.zos.globals.id)# and content_deleted=#db.param(0)# <cfif structkeyexists(form,'preview') EQ false and request.zos.zcontentshowinactive EQ false> and content_for_sale <> #db.param(2)# </cfif> <cfif contentConfig.hideContentSold> and content_for_sale =#db.param(1)#</cfif>
            </cfsavecontent><cfscript>local.qParent=db.execute("qParent");
            ArrayAppend(local.arrAllowGroupIds, local.curId);		
            </cfscript>
            <cfif local.qParent.recordcount EQ 0>
                <cfbreak>
            <cfelseif local.qParent.content_user_group_id EQ 0>
                <!--- skip this one ---->
            <cfelseif application.zcore.user.checkGroupIdAccess(local.qParent.content_user_group_id) EQ false>
                <!--- found access! ---->
                <cfset local.hasAccess=true>
                <cfset local.forceLogin=true>
                <cfbreak>
            <!--- <cfelseif isDefined('local.defaultContentId') and local.curId EQ local.defaultContentId>
                <!--- found access! ---->
                <cfset local.hasAccess=true>
                <cfbreak> --->
            </cfif>
            <cfset local.curId=local.qParent.content_parent_id>
        </cfloop>
        </cfif>
        <cfif local.hasAccess or local.forceLogin>
        	<cfscript>
			local.returnStruct9 = application.zcore.functions.zGetRepostStruct();
			</cfscript>
        	<cfsavecontent variable="local.actionVar"><cfif structkeyexists(form,  request.zos.urlRoutingParameter)>#form[request.zos.urlRoutingParameter]#<cfelse>#request.cgi_script_name#</cfif><cfif local.returnStruct9.urlString NEQ "" or local.returnStruct9.cgiFormString NEQ "">?</cfif><cfif local.returnStruct9.urlString NEQ "">#local.returnStruct9.urlString#&</cfif><cfif local.returnStruct9.urlString NEQ "">#local.returnStruct9.urlString#</cfif></cfsavecontent>
            <cfscript>
			application.zcore.functions.zredirect("/z/user/preference/index?returnURL=#urlencodedformat(local.actionVar)#");
			/*
            local.inputStruct = StructNew();
            local.inputStruct.user_group_name = "user";
            local.inputStruct.secureLogin=false;
			local.inputStruct.loginFormUrl="/z/user/preference/index";
            application.zcore.user.checkLogin(local.inputStruct);
			*/
            </cfscript>
        </cfif>
    
	
     <cfscript>
     local.arrParentLinks=[];
     local.theTemplate="";
    if(local.ts994824713.content_template NEQ "" and local.ts994824713.content_template NEQ 'default' and local.theTemplate EQ ''){
		local.theTemplate=local.ts994824713.content_template;
		application.zcore.template.setTemplate(local.ts994824713.content_template,true,true);
    }
    request.zos.arrContentParentIDStruct=arraynew(1);
	request.zos.arrContentParentURLStruct=arraynew(1);
	arrayappend(request.zos.arrContentParentIDStruct, local.ts994824713.content_id);
	if(local.ts994824713.content_unique_name NEQ ''){
		arrayappend(request.zos.arrContentParentURLStruct, local.ts994824713.content_unique_name);
	}else{
		arrayappend(request.zos.arrContentParentURLStruct, "/#application.zcore.functions.zURLEncode(local.ts994824713.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#local.ts994824713.content_id#.html");
	}
	local.curParentSortingSet=false;
	local.curParentSorting=0;
	
	local.parentThumbnailSize={width:0, height:0, crop:0};
     </cfscript>
        <cfloop from="1" to="255" index="local.g">
            <cfsavecontent variable="db.sql">
            SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content where <cfif local.cpi NEQ 0>content_id = #db.param(local.cpi)#<cfelse> content_unique_name = #db.param('/')#</cfif> and content.site_id = #db.param(request.zos.globals.id)# and content_deleted=#db.param(0)# <cfif structkeyexists(form, 'preview') EQ false and request.zos.zcontentshowinactive EQ false> and content_for_sale <> #db.param(2)# </cfif> and content_hide_link=#db.param(0)#
            </cfsavecontent><cfscript>local.qpar=db.execute("qpar");</cfscript>
            <cfif local.qpar.recordcount EQ 0><cfbreak></cfif>
            <cfscript>
	    if(local.parentThumbnailSize.width EQ 0 and local.parentThumbnailSize.height EQ 0 and (local.qpar.content_thumbnail_width NEQ 0 or local.qpar.content_thumbnail_height NEQ 0)){
		    local.parentThumbnailSize.width=local.qpar.content_thumbnail_width;
		    local.parentThumbnailSize.height=local.qpar.content_thumbnail_height;
		    local.parentThumbnailSize.crop=local.qpar.content_thumbnail_crop;
	    }
	    if(not local.curParentSortingSet){
		    local.curParentSorting=local.qpar.content_child_sorting;
	    }if(local.qpar.content_template NEQ "" and local.qpar.content_template NEQ 'default' and local.theTemplate EQ ''){
				local.theTemplate=local.qpar.content_template;
				application.zcore.template.setTemplate(local.qpar.content_template,true,true);
            }
            </cfscript><cfif local.cpi EQ 0><cfbreak></cfif><cfscript>
		arrayappend(request.zos.arrContentParentIDStruct, local.qpar.content_id);
            if(local.qpar.content_unique_name NEQ ''){
				arrayappend(request.zos.arrContentParentURLStruct, local.qpar.content_unique_name);
                arrayappend(local.arrNav, '<a href="#local.qpar.content_unique_name#">#local.qpar.content_name#</a> / ');
            }else{
				arrayappend(request.zos.arrContentParentURLStruct, "/#application.zcore.functions.zURLEncode(local.qpar.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#local.qpar.content_id#.html");
                arrayappend(local.arrNav, '<a href="/#application.zcore.functions.zURLEncode(local.qpar.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#local.qpar.content_id#.html">#local.qpar.content_name#</a> / ');
            }
            local.cpi=local.qpar.content_parent_id;
        
            local.t2=structnew();
            local.t2.type="tab";
            local.t2.text=local.qpar.content_name;
            if(local.qpar.content_unique_name NEQ ''){local.t2.url=request.zos.globals.domain&local.qpar.content_unique_name;
            }else{ local.t2.url=request.zos.globals.domain&"/#application.zcore.functions.zURLEncode(local.qpar.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#local.qpar.content_id#.html"; }
            arrayprepend(local.arrParentLinks,local.t2);
            if(local.g GT 200){
                application.zcore.template.fail("Infinite loop on parent links");	
            }
            </cfscript>
            <cfif local.cpi EQ 0>
            <cfbreak>
            </cfif>
        </cfloop>
	
	<cfscript>
	if(local.ts994824713.content_thumbnail_width EQ 0){
		this.setRequestThumbnailSize(local.parentThumbnailSize.width, local.parentThumbnailSize.height, local.parentThumbnailSize.crop);
	}else{
		this.setRequestThumbnailSize(local.ts994824713.content_thumbnail_width, local.ts994824713.content_thumbnail_height, local.ts994824713.content_thumbnail_crop);
	}
	</cfscript>
    
        <cfsavecontent variable="local.tempMeta">
        <meta name="Keywords" content="#htmleditformat(local.ts994824713.content_metakey)#" />
        <meta name="Description" content="#htmleditformat(local.ts994824713.content_metadesc)#" />
        </cfsavecontent>
        <cfsavecontent variable="local.temppagenav">
        <a href="/">#application.zcore.functions.zvar('homelinktext')#</a> /
        <cfscript>
        for(local.i=arraylen(local.arrNav);local.i GTE 1;local.i=local.i-1){
            writeoutput(local.arrNav[local.i]);
        }
        </cfscript>
        </cfsavecontent> 
        <cfscript>
        if(contentConfig.disableContentMeta EQ false){
            if(trim(local.ts994824713.content_metatitle) NEQ ""){
                application.zcore.template.setTag('title',local.ts994824713.content_metatitle);
            }else{
                application.zcore.template.setTag('title',local.ts994824713.content_name);
            }
            application.zcore.template.setTag('meta',local.tempMeta);
            application.zcore.template.setTag('pagetitle',replacenocase(replacenocase(local.ts994824713.content_name,"<br />"," ","ALL"),"<br />"," ","ALL"));
            application.zcore.template.setTag('menutitle',replacenocase(replacenocase(local.ts994824713.content_menu_title,"<br />"," ","ALL"),"<br />"," ","ALL"));
            application.zcore.template.setTag('pagenav',local.temppagenav);
        }
        </cfscript>
        
        <cfif local.ts994824713.content_name2 NEQ ''><h2>#htmleditformat(local.ts994824713.content_name2)#</h2></cfif>
                <cfif local.ts994824713.content_photo_hide_image EQ 0> <!---(local.ts994824713.content_group_photo_gallery NEQ 1 or  local.ts994824713.content_parent_id EQ 0)> --->
                <cfscript>
                local.ts =structnew();
                local.ts.image_library_id=local.ts994824713.content_image_library_id;
                local.ts.output=false;
                local.ts.query=local.qContent;
                local.ts.row=1;
                local.ts.count = 1; // how many images to get
                //application.zcore.functions.zdump(local.ts);
                local.arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(local.ts); 
                if(arraylen(local.arrImages) NEQ 0){
                    writeoutput('<p id="zcontentmainimagepid"><img id="zcontentmainimageimgid" src="'&local.arrImages[1].link&'" alt="#htmleditformat(local.arrImages[1].caption)#" style="border:none;" /></p>');
                }
                </cfscript>
                </cfif>
                
        
        <cfif local.ts994824713.content_datetime NEQ ''><strong class="news-date">Date: <cfif isdate(local.ts994824713.content_datetime)>#DateFormat(local.ts994824713.content_datetime,'m/d/yyyy')#</cfif> <cfif local.ts994824713.content_datetime NEQ '' and Timeformat(local.ts994824713.content_datetime,'HH:mm:ss') NEQ '00:00:00'>#TimeFormat(local.ts994824713.content_datetime,'h:mm tt')#</cfif></strong> <br /><br /></cfif>
        <cfif local.ts994824713.content_for_sale EQ '3'><span style="color:##FF0000; font-size:14px; font-weight:bold;">This listing is SOLD</span><br /><br /><cfelseif local.ts994824713.content_for_sale EQ '4'><span style="color:##FF0000; font-size:14px; font-weight:bold;">This listing is UNDER CONTRACT</span><br /><br /></cfif>
        <cfif fileexists(request.zos.globals.homedir&'images/files/'&local.ts994824713.content_file)>
        <table style="border-spacing:5px; width:150px;">
        <tr><td><cfif local.ts994824713.content_file_caption NEQ ''>#local.ts994824713.content_file_caption#<br /></cfif>
        <a href="/images/files/#local.ts994824713.content_file#">Download File</a>
        </td></tr>
        </table>
        </cfif>
    <cfscript>
    if(local.ts994824713.content_text EQ ''){
        local.ct1948=local.ts994824713.content_summary;
    }else{
        local.ct1948=local.ts994824713.content_text;
    }
    if(application.zcore.app.siteHasApp("content") and application.zcore.app.getAppData("content").optionStruct.content_config_contact_links EQ 1 and local.ts994824713.content_disable_contact_links EQ 1){
        //local.ct1948=rereplacenocase(local.ct1948,"(\b)(call)(\b)",'\1<a href="##cjumpform" title="Call Us Today">\2</a>\3',"ALL");
        local.ct1948=rereplacenocase(local.ct1948,"(\b)(contact)(\b)",'\1<a href="/z/misc/inquiry/index" title="Contact Us">\2</a>\3',"ALL");
        local.ct1948=rereplacenocase(local.ct1948,"(\b)(email)(\b)",'\1<a href="/z/misc/inquiry/index" title="Email Us">\2</a>\3',"ALL");
        local.ct1948=rereplacenocase(local.ct1948,"(\b)(e-mail)(\b)",'\1<a href="/z/misc/inquiry/index" title="Email Us">\2</a>\3',"ALL");
    }
    if(local.ts994824713.content_metacode NEQ ""){
        application.zcore.template.appendTag("meta", local.ts994824713.content_metacode);
    }
    </cfscript>
    
    <cfif contentConfig.disableChildContent EQ false>
        <cfscript>
        // you must have a group by in your query or it may miss rows
        local.ts =structnew();
        local.ts.image_library_id_field="content.content_image_library_id";
        local.ts.count =  1; // how many images to get
        local.rs=application.zcore.imageLibraryCom.getImageSQL(local.ts);
        </cfscript>
        <cfsavecontent variable="db.sql">
        SELECT *
	<cfif local.ts994824713.content_child_sorting EQ "3">
		, if(content.content_menu_title = #db.param('')#, content.content_name, content.content_menu_title) as _sortName
	</cfif>
	  #db.trustedSQL(local.rs.select)# FROM #db.table("content", request.zos.zcoreDatasource)# content #db.trustedSQL(local.rs.leftJoin)# WHERE content.site_id = #db.param(request.zos.globals.id)# and content_id <> #db.param(local.ts994824713.content_id)#  and 
        content.content_parent_id =#db.param(local.ts994824713.content_id)# <cfif structkeyexists(form,'preview') EQ false and request.zos.zcontentshowinactive EQ false> and content_for_sale <> #db.param(2)# </cfif> and content_deleted = #db.param(0)# and content_hide_link =#db.param(0)# <cfif contentConfig.hideContentSold> and content_for_sale =#db.param(1)#</cfif>
         GROUP BY content.content_id 
	ORDER BY <cfif local.ts994824713.content_child_sorting EQ "3"> _sortName ASC 
	<cfelseif local.ts994824713.content_child_sorting EQ "1"> content_price desc 
	<cfelseif local.ts994824713.content_child_sorting EQ "2"> content_price asc 
	<cfelse> content_sort ASC, content_datetime DESC, content_created_datetime DESC </cfif>
        </cfsavecontent><cfscript>local.qContentChild=db.execute("qContentChild");</cfscript>
        <cfif (local.subpageLinkLayoutBackup EQ "11" or local.subpageLinkLayoutBackup EQ "12") and local.ct1948 CONTAINS '%child_links%'>
            <cfsavecontent variable="local.theChildLinkHTML"><cfscript>
            if(local.subpageLinkLayoutBackup EQ "12"){
                writeoutput('<ul id="zcontent-child-links">');
            }
            </cfscript><cfloop query="local.qContentChild">
			
            <cfscript>
            
			local.ts=structnew();
			local.ts.image_library_id=local.qContentChild.content_image_library_id;
			local.ts.output=false;
			local.ts.query=local.qContentChild;
			local.ts.row=local.qContentChild.currentrow;
			/*if(contentConfig.contentEmailFormat){
				local.ts.size="120x90";
			}else{*/
			local.ts.size=request.zos.thumbnailSizeStruct.width&"x"&request.zos.thumbnailSizeStruct.height;
			local.ts.crop=request.zos.thumbnailSizeStruct.crop;
			//	local.ts.size="250x187";
			//}
			//local.ts.crop=1;
			local.ts.count = 1; // how many images to get
			//zdump(ts);
			local.arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(local.ts);
            local.t2=structnew();
			local.t2.photo=""; 
			if(arraylen(local.arrImages) NEQ 0){
				local.t2.photo=(local.arrImages[1].link);
			}
            local.t2.text=local.qContentChild.content_name;
            if(local.qContentChild.content_menu_title NEQ ""){
                local.t2.text=local.qContentChild.content_menu_title;	
            }
            local.t2.isparent=false;
            local.t2.type="subtab";
            if(local.qContentChild.content_unique_name NEQ ''){local.t2.url=request.zos.globals.domain&local.qContentChild.content_unique_name;
            }else{ local.t2.url=request.zos.globals.domain&"/#application.zcore.functions.zURLEncode(local.qContentChild.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#local.qContentChild.content_id#.html"; }
            if(local.subpageLinkLayoutBackup EQ "11"){
                writeoutput('<a href="#local.t2.url#">#local.t2.text#</a><br />');
            }else if(local.subpageLinkLayoutBackup EQ "12"){
                writeoutput('<li><a href="#local.t2.url#">#local.t2.text#</a></li>');
            }
            
            </cfscript>
            </cfloop><cfscript>
            if(local.subpageLinkLayoutBackup EQ "12"){
                writeoutput('</ul>');
            }
            </cfscript></cfsavecontent>
            <cfscript>
            local.ct1948=rereplacenocase(local.ct1948,"%child_links%", local.theChildLinkHTML,"ONE");
            </cfscript>
        </cfif>
    </cfif>
    <cfscript>
    
    if(arraylen(contentConfig.arrContentReplaceKeywords)){
        for(local.i=1;local.i LTE arraylen(contentConfig.arrContentReplaceKeywords);local.i++){
            if(isDefined(contentConfig.arrContentReplaceKeywords[local.i])){
                local.ct1948=replacenocase(local.ct1948,"##"&contentConfig.arrContentReplaceKeywords[local.i]&"##",evaluate(contentConfig.arrContentReplaceKeywords[local.i]));
            }
        }
    }
    if(local.ts994824713.content_html_text_bottom EQ 0 and local.ts994824713.content_html_text NEQ ""){
        writeoutput(local.ts994824713.content_html_text&'<br style="clear:both;" /><br />');
    }
    
    </cfscript>
    <cfset local.pcount=0>
    
        <cfif application.zcore.app.siteHasApp("listing") and local.contentSearchMLS EQ 1>
        <hr />
            <cfscript>
			local.returnPropertyDisplayStruct=request.zos.listing.functions.zMLSSearchOptionsDisplay(local.ts994824713.content_saved_search_id);
			local.pcount+=local.returnPropertyDisplayStruct.returnStruct.count;
			</cfscript>
        </cfif>
        
        <cfif local.ts994824713.content_show_map EQ 1 and local.pcount NEQ 0>
            <div style="width:100%; clear:both; float:left;">
            <div id="contentPropertySummaryDiv" style="width:#request.zos.globals.maximagewidth-400#px; float:left;">
            </div>
            
            <div id="mapContentDivId" style="width:380px; float:right; margin-left:20px; margin-bottom:20px;">
            <iframe id="embeddedmapiframe" src="/z/listing/map-embedded/index?content_id=#local.ts994824713.content_id#" width="100%" height="320" style="border:none; overflow:auto;" seamless="seamless"></iframe>
            </div>
            </div>
        </cfif>
        
    
    
    <cfif local.ts994824713.content_text_position EQ 0>#ct1948#<cfif ct1948 NEQ ""><br style="clear:both;" /></cfif></cfif>
    
    <cfif local.ts994824713.content_image_library_layout EQ 7>
		<cfsavecontent variable="local.theImageOutputHTML">
		<cfscript> 
		local.ts =structnew();
		local.ts.image_library_id=local.ts994824713.content_image_library_id;
		local.ts.size="#request.zos.globals.maximagewidth#x2000";
		local.ts.crop=0; 
		if(local.ts994824713.content_photo_hide_image EQ 1){
		    local.ts.offset=1;
		}else{
		    local.ts.offset=2;
		} 
		local.ts.layoutType=application.zcore.imageLibraryCom.getLayoutType(local.ts994824713.content_image_library_layout);
		application.zcore.imageLibraryCom.displayImages(local.ts);
	       
	       </cfscript>
	       </cfsavecontent>
       </cfif>
        <cfif local.ts994824713.content_image_library_layout EQ 7 or local.ts994824713.content_image_library_layout EQ 1 or local.ts994824713.content_image_library_layout EQ 2 or local.ts994824713.content_image_library_layout EQ 0 or local.ts994824713.content_image_library_layout EQ 5>
        #local.theImageOutputHTML#
        </cfif>
       <cfscript>
    if(local.ts994824713.content_html_text_bottom EQ 1 and local.ts994824713.content_html_text NEQ ""){
        writeoutput(local.ts994824713.content_html_text&'<br style="clear:both;" /><br />');
    }
       
        if((structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager")) and contentConfig.contentEmailFormat EQ false and contentConfig.editLinksEnabled){
            writeoutput('</div>');
        }
        </cfscript>
        
                
                <cfif structkeyexists(request.zos,'listingApp') and structkeyexists(request.zos,'listingApp') and application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_compliantidx',false,true) EQ true and local.ts994824713.content_firm_name NEQ ''><br />Listing courtesy of #local.ts994824713.content_firm_name#</cfif>
                
                
                </cfsavecontent>
        <cfscript>
        if(structkeyexists(form, 'zsearchtexthighlight') AND contentConfig.searchincludebars EQ false and form[request.zos.urlRoutingParameter] NEQ "/z/misc/search-site/results"){
            local.t99=application.zcore.functions.zHighlightHTML(form.zsearchtexthighlight,local.theContentHTMLSection);
        }else{
            local.t99=local.theContentHTMLSection;
        }
        //local.t99=local.theContentHTMLSection;
        writeoutput(local.t99);
        local.out99="";
        </cfscript>
        
		<cfif request.zos.currentContentIncludeConfigStruct.contentWasIncluded EQ false and application.zcore.functions.zIsExternalCommentsEnabled()>
            <cfscript>
             // display external comments
             writeoutput(application.zcore.functions.zDisplayExternalComments(application.zcore.app.getAppData("content").optionstruct.app_x_site_id&"-"&local.ts994824713.content_id, local.ts994824713.content_name, request.zos.globals.domain&local.currentContentURL));
             </cfscript>
        </cfif>
    
        <cfscript>
		
	
        local.ts =structnew();
        local.ts.output=false;
        if(isDefined('request.zsidebarwidth')){
            local.ts.width=request.zsidebarwidth;
        }else{
            local.ts.width=225;
        }
        local.ts.arrLinks=arraynew(1);//local.arrParentLinks;
        local.selectedContentId=local.ts994824713.content_id;
        local.selectedIndex=1;
		</cfscript>
    <cfif contentConfig.disableChildContent EQ false>
	<cfif local.ts994824713.content_parent_id NEQ 0>
        <cfsavecontent variable="db.sql">
        SELECT * 
	<cfif local.curParentSorting EQ "3">
		, if(content.content_menu_title = #db.param('')#, content.content_name, content.content_menu_title) as _sortName
	</cfif>
	FROM #db.table("content", request.zos.zcoreDatasource)# content WHERE content.site_id = #db.param(request.zos.globals.id)# and 
        content.content_parent_id =#db.param(local.ts994824713.content_parent_id)# <cfif structkeyexists(form, 'preview') EQ false and request.zos.zcontentshowinactive EQ false> and content_for_sale <> #db.param(2)# </cfif> and content_deleted = #db.param(0)# and content_hide_link =#db.param(0)# <cfif contentConfig.hideContentSold> and content_for_sale =#db.param(1)#</cfif>
         ORDER BY <cfif local.curParentSorting EQ "3"> _sortName ASC 
		     <cfelseif local.curParentSorting EQ "1"> content_price desc 
		     <cfelseif local.curParentSorting EQ "2"> content_price asc 
		     <cfelse> content_sort ASC, content_datetime DESC, content_created_datetime DESC </cfif>
        </cfsavecontent><cfscript>local.qParent5=db.execute("qParent5");</cfscript>
                    
        <cfloop query="local.qParent5"><cfscript>
            local.t2=structnew();
            local.t2.text=local.qParent5.content_name;
            if(local.qParent5.content_menu_title NEQ ""){
                local.t2.text=local.qParent5.content_menu_title;	
            }
            local.t2.photo="";
            local.t2.isparent=true;
            if(local.qParent5.content_id EQ local.selectedContentId){
                local.t2.type="selected";
                local.selectedIndex=arraylen(local.ts.arrLinks)+1;
            }else{
                local.t2.type="tab";
            }
            if(local.qParent5.content_unique_name NEQ ''){local.t2.url=request.zos.globals.domain&local.qParent5.content_unique_name;
            }else{ local.t2.url=request.zos.globals.domain&"/#application.zcore.functions.zURLEncode(local.qParent5.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#local.qParent5.content_id#.html"; }
            arrayappend(local.ts.arrLinks,local.t2);
            </cfscript>
            <cfif local.t2.type EQ "selected">
            </cfif>
        </cfloop>
        <cfscript>
        if(local.qParent5.recordcount NEQ 0){
            local.ts.link_layout=local.parentpageLinkLayoutBackup;
            local.out99&=this.displayMenuLinks(local.ts);
        }
        </cfscript>
    </cfif>
    <cfscript>
    local.ts.arrLinks=arraynew(1);
    </cfscript>
        <cfloop query="local.qContentChild"><cfscript>
		local.ts3=structnew();
		local.ts3.image_library_id=local.qContentChild.content_image_library_id;
		local.ts3.output=false;
		local.ts3.query=local.qContentChild;
		local.ts3.row=local.qContentChild.currentrow;
		/*if(contentConfig.contentEmailFormat){
			local.ts.size="120x90";
		}else{*/
		
                local.ts3.size=request.zos.thumbnailSizeStruct.width&"x"&request.zos.thumbnailSizeStruct.height;
                local.ts3.crop=request.zos.thumbnailSizeStruct.crop; 
		//}
		//local.ts.crop=1;
		local.ts3.count = 1; // how many images to get
		//zdump(ts);
		local.arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(local.ts3);
		local.t2=structnew();
		local.t2.photo=""; 
		if(arraylen(local.arrImages) NEQ 0){
			local.t2.photo=(local.arrImages[1].link);
		}
        local.t2.text=local.qContentChild.content_name;
        if(local.qContentChild.content_menu_title NEQ ""){
            local.t2.text=local.qContentChild.content_menu_title;	
        }
		
        local.t2.isparent=false;
        local.t2.type="subtab";
        if(local.qContentChild.content_unique_name NEQ ''){local.t2.url=request.zos.globals.domain&local.qContentChild.content_unique_name;
        }else{ local.t2.url=request.zos.globals.domain&"/#application.zcore.functions.zURLEncode(local.qContentChild.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#local.qContentChild.content_id#.html"; }
        local.selectedIndex++;
        if(arraylen(local.ts.arrLinks) LT local.selectedIndex){
            arrayappend(local.ts.arrLinks,local.t2);
        }else{
            arrayinsertat(local.ts.arrLinks,local.selectedIndex,local.t2);
        }
        </cfscript></cfloop>
    <cfscript>
    if(local.qContentChild.recordcount NEQ 0){
        local.ts.link_layout=local.subpageLinkLayoutBackup;
        local.out99&=this.displayMenuLinks(local.ts);
    }
    
    if(local.subpageLinkLayoutBackup EQ 8 or local.subpageLinkLayoutBackup EQ 9 or local.subpageLinkLayoutBackup EQ 10){
        writeoutput(local.out99);
    }else if(application.zcore.app.getAppData("content").optionStruct.content_config_sidebar_tag NEQ ""){
        application.zcore.template.setTag(application.zcore.app.getAppData("content").optionStruct.content_config_sidebar_tag,local.out99);
    }else{// if(local.subpageLinkLayoutBackup NEQ 8 and local.subpageLinkLayoutBackup NEQ 9 and local.subpageLinkLayoutBackup NEQ 10){
        application.zcore.template.prependtag("content",local.out99);
    }
    </cfscript>
    
    <cfif local.subpageLinkLayoutBackup EQ 1 or local.subpageLinkLayoutBackup EQ 0>
        <cfif local.subpageLinkLayoutBackup EQ 1>
			<cfscript>
            local.ts43=structnew();
            local.ts43.disableChildContentSummary=true;
            application.zcore.app.getAppCFC("content").setContentIncludeConfig(local.ts43);
            </cfscript>
        </cfif>
        <cfscript>
		application.zcore.app.getAppCFC("content").getPropertyInclude(local.ts994824713.content_id, local.qContentChild);
		</cfscript>
    </cfif>
    
    <cfscript>
    structdelete(request.zos,'contentPropertyIncludeQueryName');
    </cfscript>
    <cfif local.ts994824713.content_include_listings NEQ ''>
    <br style="clear:both;" />
        <cfscript>
        local.arrListings=listToArray(local.ts994824713.content_include_listings, ",");
        local.pcount+=arraylen(local.arrListings);
        </cfscript>
        <cfloop from="1" to="#arraylen(local.arrListings)#" index="local.i">
            <cfscript>
			application.zcore.app.getAppCFC("content").getPropertyInclude(local.arrListings[local.i]);
			</cfscript>
        </cfloop>
        
    </cfif>
    
        
        <cfif local.pcount NEQ 0>
        <br style="clear:both;" />
        </cfif>
        
    <cfif application.zcore.app.siteHasApp("listing") and local.contentSearchMLS EQ 1 and application.zcore.functions.zso(form, 'hidemls',true) EQ 0>
    
               
		<cfscript>
        
        if((local.returnPropertyDisplayStruct.mlsSearchSearchQuery.search_Rate_low NEQ 0 AND local.returnPropertyDisplayStruct.mlsSearchSearchQuery.search_rate_high neq 0)){
            local.startPrice=local.returnPropertyDisplayStruct.mlsSearchSearchQuery.search_rate_low;
            local.endPrice=local.returnPropertyDisplayStruct.mlsSearchSearchQuery.search_rate_high;
        }else if(application.zcore.functions.zso(local.ts994824713, 'content_price',true) NEQ 0){
            local.percent=local.ts994824713.content_price*0.25;
            local.startPrice=max(0,local.ts994824713.content_price-local.percent);
            local.endPrice=local.ts994824713.content_price+local.percent;
        }
        
        </cfscript>
    
            
        <cfif local.ts994824713.content_show_map EQ 1>
    		<div id="zMapOverlayDivV3" style="position:absolute; left:0px; top:0px; display:none; z-index:1000;"></div>
       </cfif>
       
        <cfif local.ts994824713.content_show_map EQ 1>
			<cfscript>
            local.ts = StructNew();
            local.ts.offset =0;
            local.ts.perpage = 1;
            local.ts.distance = 30; // in miles
            local.ts.zReturnSimpleQuery=true;
            local.ts.onlyCount=true;
            //local.ts.debug=true;
            local.ts.zselect=" min(listing.listing_price) minprice, max(listing.listing_price) maxprice, count(listing.listing_id) count";
            local.rs4 = local.returnPropertyDisplayStruct.propertyDataCom.getProperties(local.ts);
            local.ts.zselect=" min(listing.listing_square_feet) minsqft, max(listing.listing_square_feet) maxsqft";
            local.ts.zwhere=" and listing.listing_square_feet <> '' and listing.listing_square_feet <>'0'";
            local.rs4_2 = local.returnPropertyDisplayStruct.propertyDataCom.getProperties(local.ts);
            local.ts.zselect=" min(listing.listing_beds) minbed, min(listing.listing_beds) maxbed";
            local.ts.zwhere=" and listing.listing_beds <> '' and listing.listing_beds<>'0'";
            local.rs4_3 = local.returnPropertyDisplayStruct.propertyDataCom.getProperties(local.ts);
            local.ts.zselect=" min(listing.listing_baths) minbath, max(listing.listing_baths) maxbath";
            local.ts.zwhere=" and listing.listing_baths <> '' and listing.listing_baths<>'0'";
            local.rs4_4 = local.returnPropertyDisplayStruct.propertyDataCom.getProperties(local.ts);
            local.ts.zselect=" min(listing.listing_year_built) minyear, max(listing.listing_year_built) maxyear";
            local.ts.zwhere=" and listing.listing_year_built <> '' and listing.listing_year_built<>'0'";
            local.rs4_5 = local.returnPropertyDisplayStruct.propertyDataCom.getProperties(local.ts);
            </cfscript>
			<cfif local.rs4.count NEQ 0>
                <cfsavecontent variable="local.contentSummaryHTML">
                <cfif local.rs4.count NEQ 0><div style="font-weight:bold; font-size:120%; padding-bottom:10px;"> #numberformat(local.rs4.count)# listings</div></cfif>
                <div style="font-weight:bold;">Listing Summary:</div>
                <cfif local.rs4.minprice NEQ "" and local.rs4.minprice NEQ 0>$#numberformat(local.rs4.minprice)# <cfif local.rs4.minprice NEQ local.rs4.maxprice>to $#numberformat(local.rs4.maxprice)#</cfif><br /></cfif>
                <cfif local.rs4_2.minsqft NEQ "" and local.rs4_2.minsqft NEQ 0>#numberformat((local.rs4_2.minsqft))#<cfif local.rs4_2.minsqft NEQ local.rs4_2.maxsqft> to #numberformat((local.rs4_2.maxsqft))#</cfif> square feet (living area)<br /></cfif>
                <cfif local.rs4_3.minbed NEQ "" and local.rs4_3.minbed NEQ 0>#(local.rs4_3.minbed)# <cfif local.rs4_3.minbed NEQ local.rs4_3.maxbed> #(local.rs4_3.maxbed)#</cfif> Bedrooms<br /></cfif>
                <cfif local.rs4_4.minbath NEQ "" and local.rs4_4.minbath NEQ 0>#(local.rs4_4.minbath)# <cfif local.rs4_4.minbath NEQ local.rs4_4.maxbath>to #(local.rs4_4.maxbath)#</cfif> Bathrooms<br /></cfif>
                <cfif local.rs4_5.minyear NEQ "" and local.rs4_5.minyear NEQ 0>Built <cfif local.rs4_5.minyear NEQ local.rs4_5.maxyear>between #(local.rs4_5.minyear)# to #(local.rs4_5.maxyear)#<cfelse> in #(local.rs4_5.minyear)#</cfif><br /></cfif>
                <br /> <div style="font-weight:bold; font-size:120%;"><a href="##zbeginlistings">View Listings</a></div></cfsavecontent>
                
                 <cfscript>
                //structclear(form);
                </cfscript>
                <script type="text/javascript">/* <![CDATA[ */ 
                document.getElementById('contentPropertySummaryDiv').innerHTML="#jsstringformat(local.contentSummaryHTML)#";
                 /* ]]> */
                 </script>
             </cfif>
        </cfif>
    </cfif>
    
        <cfscript>
        try{
            if(isNumeric(local.parentChildSorting) EQ false){
                local.arrOrder=structsort(request.cOutStruct,"numeric","desc","price");
            }else if(local.parentChildSorting EQ 1){
                local.arrOrder=structsort(request.cOutStruct,"numeric","desc","price");
            }else if(local.parentChildSorting EQ 2){
                local.arrOrder=structsort(request.cOutStruct,"numeric","asc","price");
            }else if(local.parentChildSorting EQ 3){
                local.arrOrder=structsort(request.cOutStruct,"text","asc","name");
            }else if(local.parentChildSorting EQ 0){
                local.arrOrder=structsort(request.cOutStruct,"numeric","asc","sort");
            }
        }catch(Any excpt){local.arrOrder=arraynew(1);
            for(local.i in request.cOutStruct){
                arrayappend(local.arrOrder, local.i);
            }
        }
        
        //application.zcore.functions.zdump(request.cOutStruct);
        local.uniqueChildStruct3838=structnew();
        for(local.i=1;local.i LTE arraylen(local.arrOrder);local.i++){
            if(request.cOutStruct[local.arrOrder[local.i]].id EQ "" or structkeyexists(local.uniqueChildStruct3838, request.cOutStruct[local.arrOrder[local.i]].id) EQ false){
            local.uniqueChildStruct3838[request.cOutStruct[local.arrOrder[local.i]].id]=true;
                writeoutput(request.cOutStruct[local.arrOrder[local.i]].output);
            }
        }
        </cfscript>
    
    
        <cfif application.zcore.app.siteHasApp("listing") and local.contentSearchMLS EQ 1>
        <!--- <hr /> --->
            <cfscript>
			writeoutput(local.returnPropertyDisplayStruct.output);
			</cfscript>
        </cfif>
    
        <cfif local.ts994824713.content_text_position EQ 1>
        <cfscript>
        
        if((structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager")) and contentConfig.contentEmailFormat EQ false and contentConfig.editLinksEnabled){
            writeoutput('<div style="display:inline;" id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" onmouseover="zOverEditDiv(this,''/z/content/admin/content-admin/edit?content_id=#local.ts994824713.content_id#&amp;return=1'');">');
            application.zcore.template.prependTag('pagetitle','<div style="display:inline;" id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" onmouseover="zOverEditDiv(this,''/z/content/admin/content-admin/edit?content_id=#local.ts994824713.content_id#&amp;return=1'');">');
            application.zcore.template.appendTag('pagetitle','</div>');
        }
        writeoutput(ct1948);
		if(trim(ct1948) NEQ ""){writeoutput('<br style="clear:both;" />');}
        if(structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager") and contentConfig.contentEmailFormat EQ false and contentConfig.editLinksEnabled){
            writeoutput('</div>');
        }
        </cfscript>
        </cfif>
    
        </cfif>
        <cfscript>
		this.resetContentIncludeConfig();
		</cfscript>
        </cfsavecontent>
        <cfscript>
		writeoutput(local.output);
		//application.sitestruct[request.zos.globals.id].contentPageCache[local.cacheString]=local.output;
		</cfscript>
		<cfreturn local.returnCountTotal>
	</cffunction>
    
    
    
    
    
	<!--- 
    <cfscript>
    ts=structnew();
    ts.width=190;
    ts.arrLinks=[];
    ts.output=true;
    ts.tabClass="";
    ts.subTabClass="";
    ts.selectedClass="";
    ts.columnClass="";
    ts.containerClass="";
    ts.columnContainerClass="";
    displayMenuLinks(ts);
    </cfscript>
     --->
    <cffunction name="displayMenuLinks" localmode="modern" output="yes" returntype="any">
        <cfargument name="ss" type="struct" required="yes">
        <cfscript>
        var arrOut=arraynew(1);
        var ts=structnew();
        var i=1;
        var c=0;
        var c2=0;
        var c3="";
        var c4="";
        var c5="";
        var c6="";
        var cw=0;
        var columnOutput=false;
        var lineCount=0;
        var lines=0; 
        ts.width=200;
        ts.fontSize=10;
        ts.output=false;
        ts.delimiter='<span class="zcontent-sublink-link-delimiter"> | </span>';
        ts.tabClass="zcontent-sublink-tab";
        ts.link_layout=0;
        ts.subLinkClass="zcontent-sublink-link";
        ts.subLinkSelectedClass="zcontent-sublink-link-selected";
        ts.subTabClass="zcontent-sublink-subtab";
        ts.selectedClass="zcontent-sublink-selected";
        ts.columnClass="zcontent-sublink-column";
        ts.containerClass="zcontent-sublink-container";
        ts.thumbnailContainerClass="zcontent-sublink-thumbnail-container";
        ts.thumbnailClass="zcontent-sublink-thumbnail";
        ts.thumbnailTextClass="zcontent-sublink-thumbnail-text";
        ts.columnContainerClass="zcontent-sublink-columncontainer";
        ts.tableofContentClass="zcontent-sublink-tableofcontents";
        structappend(arguments.ss, ts,false);
        if(arraylen(arguments.ss.arrLinks) EQ 0){
            return "";	
        }
        /*
                selectStruct.listLabels="Invisible,Top with numbered columns,Top with columns,Top on one line,Bottom with numbered columns,Bottom with columns";//,Bottom with summary (default),Bottom without summary,Left Sidebar,Right Sidebar";
                selectStruct.listValues = "7,2,3,4,8,9";//,0,1,5,6";
                */
                
        if(arguments.ss.link_layout EQ 7 or arguments.ss.link_layout EQ 0 or arguments.ss.link_layout EQ 1){
            // normal functionality...
            return "";
        }else if(arguments.ss.link_layout EQ 10){
            arrayappend(arrOut,'<div class="#arguments.ss.thumbnailContainerClass#">');
            for(i=1;i LTE arraylen(arguments.ss.arrLinks);i++){
                c=arguments.ss.arrLinks[i];
                arrayappend(arrOut,'<a href="'&htmleditformat(c.url)&'" class="#arguments.ss.thumbnailClass#"><img src="#c.photo#" alt="'&htmleditformat(c.text)&'" /><br /><span class="#arguments.ss.thumbnailTextClass#">'&htmleditformat(c.text)&'</span></a>');
            }
            arrayappend(arrOut,'</div>');
            
        }else if(arguments.ss.link_layout EQ 2 or arguments.ss.link_layout EQ 3 or arguments.ss.link_layout EQ 8 or arguments.ss.link_layout EQ 9){
            //Top with columns	
            if(arguments.ss.link_layout NEQ 3){
                c5='<ul class="zcontent-sublink-number-ul">';
                c6="</ul>";
            }else{
                c5='<ul class="zcontent-sublink-ul">';
                c6="</ul>";
            }
            arrayappend(arrOut, '<div class="#arguments.ss.columnContainerClass#"><div class="#arguments.ss.tableofContentClass#">TABLE OF CONTENTS</div>');
            arrayappend(arrOut,'<div class="#arguments.ss.columnClass#">#c5#');
            cw=(request.zos.globals.maximagewidth/2)-20;
            cw=cw/(arguments.ss.fontSize*1.4);
            lineCount=0;
            for(i=1;i LTE arraylen(arguments.ss.arrLinks);i++){
                lines=ceiling(len(arguments.ss.arrLinks[i].text)/cw);
                lineCount+=lines;
            }
            //c2=ceiling(arraylen(arguments.ss.arrLinks)/2);
            c2=ceiling((lineCount)/2);
            columnOutput=false;
            lineCount=0;
            for(i=1;i LTE arraylen(arguments.ss.arrLinks);i++){
                c=arguments.ss.arrLinks[i];
                lines=ceiling(len(arguments.ss.arrLinks[i].text)/cw);
                if(arguments.ss.link_layout NEQ 3 and arguments.ss.link_layout NEQ 9){
                    c3='<li><span class="zcontent-sublink-number-style">'&i&'.</span><span class="zcontent-sublink-number-link">';
                    c4="</span></li>";
                }else{
                    c3="<li>";	
                    c4="</li>";
                }
                if(columnOutput EQ false and lineCount GTE c2){
                    columnOutput=true;
                    // output new column	
                    arrayappend(arrOut, '#c6#</div><div class="#arguments.ss.columnClass#">#c5#');
                }
                lineCount+=lines;
                if(c.type EQ "tab"){
                    arrayappend(arrOut,'#c3#<a href="#c.url#" class="#arguments.ss.tabClass#">#c.text#</a>#c4#');
                }else if(c.type EQ 'subtab'){
                    arrayappend(arrOut,'#c3#<a href="#c.url#" class="#arguments.ss.subTabClass#">#c.text#</a>#c4#');
                }else if(c.type EQ 'selected'){
                    arrayappend(arrOut,'#c3#<span class="#arguments.ss.selectedClass#">#c.text#</span>#c4#');
                }else{
                    application.zcore.template.fail("Invalid link type, #c.type#");	
                }
                
                
            }
            arrayappend(arrOut, '#c6#</div>');
            arrayappend(arrOut, '<br style="clear:both;" /></div>');
        }else if(arguments.ss.link_layout EQ 4){
            // Top on one line
            arrayappend(arrOut, '<div class="#arguments.ss.columnContainerClass#"><div class="#arguments.ss.tableofContentClass#">TABLE OF CONTENTS</div>');
            arrayappend(arrOut, '<div class="#arguments.ss.containerClass#">');
            for(i=1;i LTE arraylen(arguments.ss.arrLinks);i++){
                if(i EQ arraylen(arguments.ss.arrLinks)){
                    arguments.ss.delimiter="";
                }
                c=arguments.ss.arrLinks[i]; 
                if(c.type EQ "tab"){
                    arrayappend(arrOut,'<a href="#c.url#" class="#arguments.ss.subLinkClass#">#c.text#</a>#arguments.ss.delimiter#');
                }else if(c.type EQ 'subtab'){
                    arrayappend(arrOut,'<a href="#c.url#" class="#arguments.ss.subLinkClass#">#c.text#</a>#arguments.ss.delimiter#');
                }else if(c.type EQ 'selected'){
                    arrayappend(arrOut,'<span class="#arguments.ss.subLinkSelectedClass#">#c.text#</span>#arguments.ss.delimiter#');
                }else{
                    application.zcore.template.fail("Invalid link type, #c.type#");	
                }
            }
            arrayappend(arrOut, '<br style="clear:both;" /></div>');
            arrayappend(arrOut, '</div>');
        }else if(arguments.ss.link_layout EQ 5){
            // create a left sidebar...
            
        }else if(arguments.ss.link_layout EQ 6){
            // create a right sidebar...
            
        }
        //application.zcore.template.prependtag("meta",'<style type="text/css">/* <![CDATA[ */.zcontent-sublink-tab{width:#arguments.ss.width-7#px;} .zcontent-sublink-subtab{width:#arguments.ss.width-14#px;} .zcontent-sublink-selected{width:#arguments.ss.width-7#px;}	.zcontent-sublink-column{float:left; width:40%; padding:5%;}/* ]]> */</style>');
        /*
        for(i=1;i LTE arraylen(arguments.ss.arrLinks);i++){
            c=arguments.ss.arrLinks[i];
            if(c.type EQ "tab"){
                arrayappend(arrOut,'<a href="#c.url#" class="ztablink #arguments.ss.tabClass#">#c.text#</a>');
            }else if(c.type EQ 'subtab'){
                arrayappend(arrOut,'<a href="#c.url#" class="zsubtablink #arguments.ss.subTabClass#">#c.text#</a>');
            }else if(c.type EQ 'selected'){
                arrayappend(arrOut,'<span class="ztablink-selected #arguments.ss.selectedClass#">#c.text#</span>');
            }else{
                application.zcore.template.fail("Invalid link type, #c.type#");	
            }
        }*/
        c=arraytolist(arrOut,"");
        if(arguments.ss.output){
            writeoutput(c);
        }else{
            return c;
        }
        </cfscript>
    </cffunction>
    
    <!--- application.zcore.app.getAppCFC("content").resetContentIncludeConfig(); --->
    <cffunction name="resetContentIncludeConfig" localmode="modern" output="no" returntype="any">
    	<cfscript>
		request.zos.currentContentIncludeConfigStruct={
				disableContentMeta=false,
				arrContentReplaceKeywords=[],
				searchincludebars=false,
				disableChildContentSummary=false,
				hideContentSold=false,
				disableChildContent=false,
				contentForceOutput=false,
				contentDisableLinks=false,
				contentSimpleFormat=false,
				tablestyle="",
				content_id="",
				contentWasIncluded=false,
				showmlsnumber=false,
				contentEmailFormat=false,
				editLinksEnabled=true
			};
		</cfscript>
    </cffunction>
    
    <!--- application.zcore.app.getAppCFC("content").getContentIncludeConfig(); --->
    <cffunction name="getContentIncludeConfig" localmode="modern" output="no" returntype="struct">
    	<cfscript>
		var ts=0;
		
		if(structkeyexists(request.zos, 'currentContentIncludeConfigStruct') EQ false){
			request.zos.currentContentIncludeConfigStruct={
				disableContentMeta=false,
				arrContentReplaceKeywords=[],
				searchincludebars=false,
				disableChildContentSummary=false,
				hideContentSold=false,
				disableChildContent=false,
				contentForceOutput=false,
				contentDisableLinks=false,
				contentSimpleFormat=false,
				tablestyle="",
				content_id="",
				contentWasIncluded=false,
				showmlsnumber=false,
				contentEmailFormat=false,
				editLinksEnabled=true
			};
		}
		return request.zos.currentContentIncludeConfigStruct;
		</cfscript>
    </cffunction>
    
    <!--- application.zcore.app.getAppCFC("content").setContentIncludeConfig(ts); --->
    <cffunction name="setContentIncludeConfig" localmode="modern" output="no" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		if(structkeyexists(request.zos, 'currentContentIncludeConfigStruct') EQ false){
			request.zos.currentContentIncludeConfigStruct={
				disableContentMeta=false,
				arrContentReplaceKeywords=[],
				searchincludebars=false,
				disableChildContentSummary=false,
				hideContentSold=false,
				disableChildContent=false,
				contentForceOutput=false,
				contentDisableLinks=false,
				contentSimpleFormat=false,
				tablestyle="",
				content_id="",
				contentWasIncluded=false,
				showmlsnumber=false,
				contentEmailFormat=false,
				editLinksEnabled=true
			};
		}
		structappend(request.zos.currentContentIncludeConfigStruct, arguments.ss, true);
		</cfscript>
    </cffunction>
    
    
    </cfoutput>
</cfcomponent>