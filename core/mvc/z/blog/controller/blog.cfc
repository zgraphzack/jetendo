<cfcomponent displayname="blog" hint="Blog Application">
<cfoutput>
<cfscript>
this.app_id=10;
</cfscript>
<cffunction name="init" localmode="modern" output="yes" access="private" returntype="any">
	<cfscript>
	request.zos.currentURLISABlogPage=true;
	
	request.disableShareThis=true;
	application.zcore.functions.zstatushandler(request.zsid,true,true);
	</cfscript>
</cffunction>

<cffunction name="isCurrentPageInBlog" localmode="modern" returntype="boolean" access="remote">
	<cfscript>
	if(structkeyexists(request.zos, 'currentURLISABlogPage')){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>
<cffunction name="isCurrentPageInBlogCategoryById" localmode="modern" returntype="boolean" access="remote">
	<cfargument name="blog_category_id" type="string" required="yes">
	<cfscript>
	if(structkeyexists(form, 'blog_category_id')){
		if(","&form.blog_category_id&"," CONTAINS ","&arguments.blog_category_id&","){
			return true;
		}else{
			return false;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction> 

<cffunction name="registerHooks" localmode="modern" output="no" access="public">
	<cfscript>
	
	</cfscript>
</cffunction>

<cffunction name="initAdmin" localmode="modern" output="no" access="public" returntype="any">
<cfscript>
	variables.rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	</cfscript>
</cffunction>
<cffunction name="onSiteStart" localmode="modern" output="no" access="public"  returntype="struct" hint="Runs on application start and should return arguments.sharedStruct">
	<cfargument name="sharedStruct" type="struct" required="yes" hint="Exclusive application scope structure for this application.">
	<cfscript>
	return arguments.sharedStruct;
	</cfscript>
</cffunction>

<cffunction name="getRobotsTxt" localmode="modern" output="no" access="public" returntype="string" hint="Generate the Robots.txt file as a string">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	return "";
	</cfscript>
</cffunction>

<cffunction name="getBlogLinkFromStruct" localmode="modern" returntype="string" output="no">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	if(arguments.struct.blog_unique_name NEQ ''){
		return arguments.struct.blog_unique_name;
	}else{
		return application.zcore.app.getAppCFC("blog").getBlogLink(
			application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id, 
			arguments.struct.blog_id,"html",
			arguments.struct.blog_title,
			arguments.struct.blog_datetime);
	}
	</cfscript>
</cffunction>

<cffunction name="getBlogLink" localmode="modern" returntype="string" output="no">
	<cfargument name="appid" type="string" required="yes">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="ext" type="string" required="yes">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="date" type="string" required="no" default="">
	<cfscript>
	return "/"&application.zcore.functions.zURLEncode(arguments.name,'-')&"-"&arguments.appid&"-"&arguments.id&"."&arguments.ext;
	</cfscript>
</cffunction>

<cffunction name="getBlogCategoryLink" localmode="modern" returntype="string">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(row.blog_category_unique_name NEQ ""){
		return arguments.row.blog_category_unique_name;
	}else{
		return "/"&application.zcore.functions.zURLEncode(row.blog_category_name,'-')&"-"&application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id&"-"&row.blog_category_id&".html";
	}	
	</cfscript>
</cffunction>

<cffunction name="getBlogCategorySectionLink" localmode="modern" returntype="string">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="site_x_option_group_set_id" type="string" required="yes">
	<cfargument name="zIndex" type="numeric" required="no" default="1">
	<cfscript>
	row=arguments.row;
	if(arguments.zIndex EQ 1){
		return "/"&application.zcore.functions.zURLEncode(row.blog_category_name,'-')&"-"&application.zcore.app.getAppData("blog").optionStruct.blog_config_url_section_id&"-"&arguments.site_x_option_group_set_id&"_"&row.blog_category_id&".html";
	}else{
		return "/"&application.zcore.functions.zURLEncode(row.blog_category_name,'-')&"-"&application.zcore.app.getAppData("blog").optionStruct.blog_config_url_section_id&"-"&arguments.site_x_option_group_set_id&"_"&row.blog_category_id&"_"&arguments.zIndex&".html";
	}
	</cfscript>
</cffunction>

<cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="add links to sitemap array">
	<cfargument name="arrUrl" type="array" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	
	var ts=application.zcore.app.getInstance(this.app_id);
	</cfscript>
	<cfsavecontent variable="returnText">
		<cfscript>
		if(ts.optionstruct.blog_config_root_url NEQ "{default}"){
			// blog root url 
			t2=StructNew();
			t2.groupName="Blog";
			t2.url=request.zos.currentHostName&ts.optionStruct.blog_config_root_url;
			t2.title=ts.optionStruct.blog_config_title;
			arrayappend(arguments.arrUrl,t2);
		}else{
			// default home url
			t2=StructNew();
			t2.groupName="Blog";
			t2.url=request.zos.currentHostName&this.getBlogLink(ts.optionStruct.blog_config_url_misc_id,3,"html",ts.optionStruct.blog_config_title);
			t2.title=ts.optionStruct.blog_config_title;
			arrayappend(arguments.arrUrl,t2);
		}
		
		/*
		// recent xml feed link
		t2=StructNew();
		t2.groupName="Blog";
		if(application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_feedburner_url') NEQ ''){
			t2.url=application.zcore.app.getAppData("blog").optionStruct.blog_config_feedburner_url;
		}else if(ts.optionStruct.blog_config_recent_url NEQ "{default}"){
			t2.url=request.zos.currentHostName&ts.optionStruct.blog_config_recent_url;
		}else{
			t2.url=request.zos.currentHostName&this.getBlogLink(ts.optionStruct.blog_config_url_misc_id,0,"xml",ts.optionStruct.blog_config_recent_name);
		}
		t2.title=ts.optionStruct.blog_config_recent_name;
		arrayappend(arguments.arrUrl,t2);
		*/
		// category feeds
		t2=StructNew();
		t2.groupName="Blog";
		if(ts.optionStruct.blog_config_category_home_url NEQ "{default}"){
			t2.url=request.zos.currentHostName&ts.optionStruct.blog_config_category_home_url;
		}else{
			t2.url=request.zos.currentHostName&this.getBlogLink(ts.optionStruct.blog_config_url_misc_id,1,"html",ts.optionStruct.blog_config_category_home_name);
		}
		t2.title=ts.optionStruct.blog_config_category_home_name;
		arrayappend(arguments.arrUrl,t2);
		</cfscript>
		<!--- archive pages for --->
		<cfsavecontent variable="db.sql">
		select *, date_format(blog_datetime, #db.param('%Y-%m')#) thismonth 
		from #db.table("blog", request.zos.zcoreDatasource)# blog 
		where site_id=#db.param(request.zos.globals.id)# and 
		(blog_datetime<=#db.param(request.zos.mysqlnow)# or 
		blog_event =#db.param(1)#) and 
		blog_status <> #db.param(2)# and 
		blog_deleted = #db.param(0)#
		GROUP BY date_format(blog_datetime, #db.param('%Y-%m')#)
		</cfsavecontent><cfscript>qArchive=db.execute("qArchive");
		</cfscript>
		<cfloop query="qArchive"><cfscript>
		t2=StructNew();
		t2.groupName="Blog Archives";
		t2.url=request.zos.currentHostName&"/#ts.optionStruct.blog_config_archive_name#-#dateformat(qArchive.blog_datetime, 'yyyy-mm')#-#ts.optionStruct.blog_config_url_misc_id#-2.html";
		t2.title="#dateformat(qArchive.blog_datetime, 'mmmm yyyy')# #ts.optionStruct.blog_config_archive_name#";
		arrayappend(arguments.arrUrl,t2);
		</cfscript></cfloop>
	
		<cfsavecontent variable="db.sql">
		select * from #db.table("blog", request.zos.zcoreDatasource)# blog 
		where site_id=#db.param(request.zos.globals.id)# and 
		(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
			blog_event =#db.param(1)#) and 
		blog_status <> #db.param(2)# and 
		blog_deleted = #db.param(0)#
		</cfsavecontent><cfscript>qArticle=db.execute("qArticle");</cfscript>
		<cfloop query="qArticle"><cfscript>
		t2=StructNew();
		t2.groupName="Blog Articles";
		if(qArticle.blog_unique_name NEQ ""){
			t2.url=request.zos.currentHostName&qArticle.blog_unique_name;
		}else{
			t2.url=request.zos.currentHostName&this.getBlogLink(ts.optionStruct.blog_config_url_article_id,qArticle.blog_id,"html",qArticle.blog_title,qArticle.blog_datetime);
		}
			//t2.url=request.zos.currentHostName&blog_unique_name;
		t2.lastmod=dateformat(qArticle.blog_datetime,'yyyy-mm-dd');
		t2.title=qArticle.blog_title;
		arrayappend(arguments.arrUrl,t2);
		</cfscript></cfloop>
	
		<cfsavecontent variable="db.sql">
		SELECT *,repeat(#db.param("&nbsp;")#,blog_category_level*#db.param(3)#) catpad, count(distinct blog.blog_id) count
		from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category
		left join #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category on 
		blog_x_category.blog_category_id = blog_category.blog_category_id  and 
		blog_x_category_deleted = #db.param(0)# and 
		blog_category.site_id = blog_x_category.site_id 
		left join #db.table("blog", request.zos.zcoreDatasource)# blog on 
		blog_x_category.blog_id = blog.blog_id and 
		blog_deleted = #db.param(0)# and 
		(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
		blog_event =#db.param(1)#) and 
		blog_status <> #db.param(2)#  and 
		blog.site_id = blog_category.site_id  and 
		blog_x_category.site_id = blog.site_id
		where blog_category.site_id=#db.param(request.zos.globals.id)# and 
		blog_category_deleted = #db.param(0)#
		group by blog_category.blog_category_id
		order by blog_category_name ASC
		</cfsavecontent><cfscript>qcat=db.execute("qcat");</cfscript>
		<cfloop query="qcat">
			<cfscript>
			if(qcat.count EQ 0){
				continue;
			}
			pages=ceiling(qcat.count/10);
			link=this.getBlogLink(ts.optionStruct.blog_config_url_category_id,qcat.blog_category_id&'_##zIndex##',"html",qcat.blog_category_name);
			t2=StructNew();
			t2.groupName="Blog Categories";
			if(qcat.blog_category_unique_name NEQ ""){
				t2.url=request.zos.currentHostName&qcat.blog_category_unique_name;
			}else{
				t2.url=request.zos.currentHostName&this.getBlogLink(ts.optionStruct.blog_config_url_category_id,qcat.blog_category_id,"html",qcat.blog_category_name);
			}
			t2.title=qcat.blog_category_name;
			arrayappend(arguments.arrUrl,t2);
			for(i=2;i LTE pages;i++){
				t2=StructNew();
				t2.groupName="Blog Categories";
				t2.url=request.zos.currentHostName&replace(link,"##zIndex##",i);
				t2.title=qcat.blog_category_name&" (page #i#)";
				arrayappend(arguments.arrUrl,t2);
			}
			</cfscript>
		</cfloop>
		<!--- <cfloop query="qcat">
			<cfscript>
			t2=StructNew();
			t2.groupName="Blog Category XML Feeds";
			t2.url=request.zos.currentHostName&this.getBlogLink(ts.optionStruct.blog_config_url_category_id,qcat.blog_category_id,"xml",qcat.blog_category_name);
			t2.title=qcat.blog_category_name;
			arrayappend(arguments.arrUrl,t2);
			</cfscript>
		</cfloop> --->


		<cfsavecontent variable="db.sql">
		SELECT *, count(distinct blog.blog_id) count
		from #db.table("blog", request.zos.zcoreDatasource)# blog, 
		#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s, 
		#db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category,
		#db.table("blog_category", request.zos.zcoreDatasource)# blog_category
		WHERE
		s.site_x_option_group_set_deleted = #db.param(0)# and 
		blog_x_category_deleted = #db.param(0)# and 
		blog_category_deleted = #db.param(0)# and 
		blog_deleted = #db.param(0)# and 
		blog_x_category.blog_category_id = blog_category.blog_category_id  and 
		blog_category.site_id = blog_x_category.site_id and 
		blog_x_category.blog_id = blog.blog_id and 
		blog_x_category.site_id = blog.site_id and 
		(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
		blog_event =#db.param(1)#) and 
		blog_status <> #db.param(2)#  and 
		blog.site_id = blog_category.site_id and 
		site_x_option_group_set_master_set_id = #db.param(0)# and 
		s.site_x_option_group_set_id = blog.site_x_option_group_set_id and 
		s.site_id = blog.site_id and 
		blog_category.site_id=#db.param(request.zos.globals.id)#
		group by blog_category.blog_category_id
		order by s.site_x_option_group_set_title ASC, blog_category_name ASC
		</cfsavecontent><cfscript>qcat=db.execute("qcat");
		for(row in qcat){
			if(row.count EQ 0){
				continue;
			}
			pages=ceiling(qcat.count/10);
			t2=StructNew();
			t2.groupName="Blog Section Categories";
			t2.url=request.zos.currentHostName&this.getBlogCategorySectionLink(row, row.site_x_option_group_set_id);
			t2.title=row.site_x_option_group_set_title&" "&row.blog_category_name;
			arrayappend(arguments.arrUrl,t2);
			for(i=2;i LTE pages;i++){
				t2=StructNew();
				t2.groupName="Blog Section Categories";
				t2.url=request.zos.currentHostName&this.getBlogCategorySectionLink(row, row.site_x_option_group_set_id, i);
				t2.title=row.site_x_option_group_set_title&" "&row.blog_category_name&" (page #i#)";
				arrayappend(arguments.arrUrl,t2);
			}
		}
		</cfscript>
		
		<cfsavecontent variable="db.sql">
		SELECT *, count(distinct blog.blog_id) count
		from #db.table("blog", request.zos.zcoreDatasource)# blog, 
		#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s
		WHERE 
		blog_deleted = #db.param(0)# and 
		s.site_x_option_group_set_deleted = #db.param(0)# and 
		(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
		blog_event =#db.param(1)#) and 
		blog_status <> #db.param(2)#  and 
		blog.site_id=#db.param(request.zos.globals.id)# and 
		blog.site_x_option_group_set_id <> #db.param(0)# and 
		site_x_option_group_set_master_set_id = #db.param(0)# and 
		s.site_x_option_group_set_id = blog.site_x_option_group_set_id and 
		blog.site_id = s.site_id 
		group by blog.site_x_option_group_set_id
		order by s.site_x_option_group_set_title ASC
		</cfsavecontent><cfscript>qsection=db.execute("qsection");</cfscript>
		<cfloop query="qsection">
			<cfscript>
			if(qsection.count EQ 0){
				continue;
			}
			pages=ceiling(qsection.count/10);
			t2=StructNew();
			t2.groupName="Blog Sections";
			currentLink=request.zos.currentHostName&this.getSectionHomeLink(qsection.site_x_option_group_set_id);
			t2.url=currentLink;
			t2.title=qsection.site_x_option_group_set_title&" Blog Articles";
			arrayappend(arguments.arrUrl,t2);
			for(i=2;i LTE pages;i++){
				t2=StructNew();
				t2.groupName="Blog Sections";
				t2.url=request.zos.currentHostName&currentLink&"?zIndex=#i#";
				t2.title=qsection.site_x_option_group_set_title&" Blog Articles (page #i#)";
				arrayappend(arguments.arrUrl,t2);
			}
			</cfscript>
		</cfloop>


		<cfsavecontent variable="db.sql">
		SELECT *, count(distinct blog.blog_id) count
		from #db.table("blog", request.zos.zcoreDatasource)# blog, 
		#db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category, 
		#db.table("blog_category", request.zos.zcoreDatasource)# blog_category, 
		#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s
		WHERE 
		(blog.blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
		blog_event =#db.param(1)#) and 
		blog_status <> #db.param(2)#  and 
		blog.site_id=#db.param(request.zos.globals.id)# and 
		blog.site_x_option_group_set_id <> #db.param(0)# and 
		s.site_x_option_group_set_id = blog.site_x_option_group_set_id and 
		blog.site_id = s.site_id and 
		blog_x_category.blog_id = blog.blog_id and 
		blog_x_category.site_id = blog.site_id and 
		blog_x_category.blog_category_id = blog_category.blog_category_id and 
		blog_x_category.site_id = blog_category.site_id  and 
		blog_deleted = #db.param(0)# and 
		blog_x_category_deleted = #db.param(0)# and 
		blog_category_deleted = #db.param(0)# and 
		blog_category_deleted = #db.param(0)# and 
		site_x_option_group_set_master_set_id = #db.param(0)# and 
		site_x_option_group_set_deleted = #db.param(0)# 
		group by blog.site_x_option_group_set_id
		order by s.site_x_option_group_set_title ASC
		</cfsavecontent><cfscript>qsection=db.execute("qsection");

		for(row in qsection){
			if(row.count EQ 0){
				continue;
			}
			pages=ceiling(row.count/10);
			t2=StructNew();
			t2.groupName="Blog Sections";
			currentLink=request.zos.currentHostName&this.getSectionHomeLink(row.site_x_option_group_set_id);
			t2.url=currentLink;
			t2.title=row.site_x_option_group_set_title&" "&row.blog_category_name&" Articles";
			arrayappend(arguments.arrUrl,t2);
			for(i=2;i LTE pages;i++){
				t2=StructNew();
				t2.groupName="Blog Sections";
				t2.url=request.zos.currentHostName&currentLink&"?zIndex=#i#";
				t2.title=row.site_x_option_group_set_title&" "&row.blog_category_name&" Articles (page #i#)";
				arrayappend(arguments.arrUrl,t2);
			}
		}
		</cfscript>
		
		<cfsavecontent variable="db.sql">
		select *, count(blog.blog_id) count 
		from (#db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag, 
		#db.table("blog_x_tag", request.zos.zcoreDatasource)# blog_x_tag, 
		#db.table("blog", request.zos.zcoreDatasource)# blog)
		where blog_tag.site_id=#db.param(request.zos.globals.id)# and 
		blog_tag.blog_tag_id = blog_x_tag.blog_tag_id and 
		blog_x_tag.blog_id = blog.blog_id and 
		(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
		blog_event =#db.param(1)#) and 
		blog_status <> #db.param(2)# 
		 and blog.site_id = blog_x_tag.site_id 
		and blog_tag.site_id = blog.site_id and 
		blog_tag_deleted = #db.param(0)# and 
		blog_x_tag_deleted = #db.param(0)# and 
		blog_deleted = #db.param(0)#
		group by blog_tag.blog_tag_id
		order by blog_sticky desc, blog_datetime desc
		</cfsavecontent><cfscript>qTag=db.execute("qTag");</cfscript>
		<cfloop query="qTag">
			<cfscript>
			if(qtag.count EQ 0){
				continue;
			}
			pages=ceiling(qTag.count/10);
			link=this.getBlogLink(ts.optionStruct.blog_config_url_tag_id,qtag.blog_tag_id&'_##zIndex##',"html",qtag.blog_tag_name);
			for(i=2;i LTE pages;i++){
				t2=StructNew();
				t2.groupName="Blog Tags";
				t2.url=request.zos.currentHostName&replace(link,"##zIndex##",i);
				t2.title=qTag.blog_tag_name&" Tag Page #i#";
				arrayappend(arguments.arrUrl,t2);
			}
			t2=StructNew();
			t2.groupName="Blog Tags";
			if(qtag.blog_tag_unique_name NEQ ""){
				t2.url=request.zos.currentHostName&qtag.blog_tag_unique_name;
			}else{
				t2.url=request.zos.currentHostName&this.getBlogLink(ts.optionStruct.blog_config_url_tag_id,qtag.blog_tag_id,"html",qtag.blog_tag_name);
			}
			t2.title=qtag.blog_tag_name&" Tag Page 1";
			arrayappend(arguments.arrUrl,t2);
			</cfscript>
		</cfloop>
	</cfsavecontent>
<cfreturn arguments.arrUrl>
</cffunction>


<cffunction name="ping" localmode="modern" output="yes" access="remote">
	<cfscript>
	var pingData="";
	var db=request.zos.queryObject;
	var cfhttpresult=0;
	var pingDataLen="";
	var pingList="";
	var qR="";
	var qTag="";
	var pingUrl="";
	var link="";
	var statuscode="";
	var xr=0;
	
	var xrt=0;
	var gg=0;
	var pingStruct=structnew();
	var arrPingResult=0;
	var arrPingKeys=0;
	var pingDoneStruct=structnew();
	var k=0;
	var i2=0;
	var arrError=arraynew(1);
	var pageURL='';
	var pingDataNoTags='';
	var pingDataSimple='';
	var success='';
	var i='';
	var pingData1='';
	var pingData2='';
	var pingData3='';
	request.znotemplate=1;
	
	if(not request.zos.isDeveloper and not request.zos.isServer){
			application.zcore.functions.z404("Force ping can only be run by developers and the server itself.");
	}
	writeoutput('Remote ping doesn''t actually execute on test server<br />');
	// The key numbers are hardcoded unique ids for each ping server url  Don't re-number the keys when adding/deleting from pingStruct.
	//pingStruct[1]="http://api.moreover.com/ping";
	pingStruct[2]="http://blogsearch.google.com/ping/RPC2";
	//pingStruct[3]="http://ping.feedburner.com";
	//pingStruct[4]="http://www.syndic8.com/xmlrpc.php";
	//pingStruct[5]="http://rpc.blogrolling.com/pinger/";
	//pingStruct[6]="http://rpc.icerocket.com:10080/";
	//pingStruct[7]="http://rpc.pingomatic.com/";
	//	pingStruct[8]="http://rpc.technorati.com/rpc/ping";
	pingStruct[9]="http://rpc.weblogs.com/RPC2";
	//pingStruct[10]="http://api.my.yahoo.com/rss/ping";
	//pingStruct[10]="http://search.yahooapis.com/SiteExplorerService/V1/ping?sitemap=";//
	arrPingKeys=structkeyarray(pingStruct);
	arraysort(arrPingKeys,"numeric","asc");
	</cfscript>
   
	<cfsavecontent variable="db.sql">
		select * 
		from #db.table("blog", request.zos.zcoreDatasource)# blog 
		where blog.blog_id = #db.param(form.blog_id)# and 
		blog.site_id=#db.param(request.zos.globals.id)# and 
		(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
			blog_event =#db.param(1)#) and 
		blog_status <> #db.param(2)# and 
		blog_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qR=db.execute("qR");</cfscript>
	<cfif qR.recordcount EQ 0>
		<cfscript>
		return false;
		</cfscript>
	</cfif>
	<cfloop query="qR">
		<cfscript>
		arrPingResult=listtoarray(qR.blog_ping_result,',');
		for(i2=1;i2 LTE arraylen(arrPingResult);i2++){
			if(structkeyexists(pingStruct,arrPingResult[i2])){
				pingDoneStruct[arrPingResult[i2]]=1;
			}
		}
		if(qR.blog_unique_name NEQ ""){
			pageURL=request.zos.currentHostName&qR.blog_unique_name;
		}else{
			pageURL=request.zOS.currentHostName&application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,form.blog_id,"html",qR.blog_title,qR.blog_datetime);
		}
		</cfscript>
		<!--- RPC endpoint:  http://rpc.weblogs.com/RPC2 --->
		<cfsavecontent variable="pingData1">
		<?xml version="1.0"?>
		<!--- Method name:  weblogUpdates.ping OR weblogUpdates.extendedPing --->
		<methodCall>
		<methodName>weblogUpdates.extendedPing</methodName>
		<params>
		<param>
		<!--- name of site (string, limited to 1024 characters)  --->
		<value>#xmlformat(application.zcore.app.getAppData("blog").optionStruct.blog_config_title)#</value>
		</param>
		<param>
		<!--- URL of site or RSS feed (string, limited to 255 characters)  --->
		<cfscript>
		if(application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url EQ "{default}"){
			link=request.zOS.currentHostName&'/#application.zcore.functions.zurlencode(application.zcore.app.getAppData("blog").optionStruct.blog_config_title,"-")#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-3.html';
		}else{
			link=request.zOS.currentHostName&application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url;
		}
		</cfscript>
		<value>#xmlformat(link)#</value>
		</param>
		<param>
		<!--- the url of the page to be checked for changes (string, limited to 255 characters) (non-optional when using the extended ping interface)  --->
		<value>#xmlformat(pageURL)#</value>
		</param>
		<param>
		<!--- the URL of an RSS, RDF, or Atom feed (when using the extended ping interface) (string, limited to 255 characters, non-optional when using the extended ping interface)  --->
		<cfscript>
		if(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_url EQ '{default}'){
		link= request.zOS.currentHostName&'/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name,'-')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-0.xml';
		}else{
		link= request.zOS.currentHostName&application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_url;
		}
		</cfscript>
		<value>#xmlFormat(link)#</value>
		</param>
		</cfsavecontent>
		
		<cfsavecontent variable="pingData2">
		<cfsavecontent variable="db.sql">
		select group_concat(blog_tag_name SEPARATOR #db.param('|')#) tagList FROM #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag, 
		#db.table("blog_x_tag", request.zos.zcoreDatasource)# blog_x_tag WHERE 
		blog_x_tag.blog_tag_id = blog_tag.blog_tag_id and 
		blog_x_tag.blog_id = #db.param(form.blog_id)# and 
		blog_tag.site_id=#db.param(request.zos.globals.id)# and 
		blog_tag.site_id = blog_x_tag.site_id and 
		blog_tag_deleted = #db.param(0)# and 
		blog_x_tag_deleted = #db.param(0)#
		</cfsavecontent><cfscript>qTag=db.execute("qTag");</cfscript> 
		<cfif qTag.tagList NEQ "">
		<param>
		<!--- a name (or "tag") categorizing your site content (string, limited to 1024 characters. You may delimit multiple values by using the &apos;|&apos; character.)  --->
		<value>#xmlFormat(qTag.tagList)#</value>
		</param>
		</cfif>
		</cfsavecontent>
		<cfsavecontent variable="pingData3">
		</params>
		</methodCall>
		</cfsavecontent>




		<cfsavecontent variable="pingDataSimple">
		<?xml version="1.0" encoding="utf-8"?>
		<methodCall>
		<methodName>ping</methodName>
		<params>
		   <param>
			  <value>
				 <string>#xmlformat(qR.blog_title)#</string>
			  </value>
		   </param>
		   <param>
			  <value>
				 <string>#xmlformat(pageURL)#</string>
			  </value>
		   </param>
		</params>
		</methodCall>
		</cfsavecontent>
		<cfscript>
		pingData=replace(replace(trim(pingData1&pingData2&pingData3),chr(10),'','ALL'),chr(13),'','ALL');
		pingDataNoTags=replace(replace(trim(pingData1&pingData3),chr(10),'','ALL'),chr(13),'','ALL');
		pingDataSimple=replace(replace(trim(pingDataSimple),chr(10),'','ALL'),chr(13),'','ALL');
		</cfscript>

		<cfloop from="1" to="#arraylen(arrPingKeys)#" index="gg">
			<cfscript>
			k=arrPingKeys[gg];
			pingURL = pingStruct[k];
			</cfscript>
			<cfif pingURL NEQ false and structkeyexists(pingDoneStruct, k) EQ false>
				<cfset pingData = trim(pingData)>
				<cfset pingDataLen = len(pingData)>
				<cfscript>
				success=false;
				</cfscript>
				<cfif request.zos.istestserver EQ false>
					<cfif k EQ 10>
						
						<cfhttp method="POST" url="#pingUrl##URLEncodedFormat(pageURL)#" 
						timeout="15" throwonerror="No" result="cfhttpresult">
						<cfhttpparam type="HEADER" name="User-Agent" value="Jetendo CMS"/>
						</cfhttp>
						<cfscript>
						statuscode=0;
						if(cfhttpresult.statuscode contains "200"){
							xrt=cfhttpresult.FileContent;
							statuscode="200";
						}
						</cfscript>
					<cfelse>
						<cfhttp method="POST" result="cfhttpresult" url="#pingUrl#" 
						timeout="15" throwonerror="No">
						<cfhttpparam type="HEADER" name="User-Agent" value="Jetendo CMS"/>
						<!--- <cfhttpparam type="HEADER" name="Content-length" value="#pingDataLen#"/> --->
						<cfif k EQ 6>
							<cfhttpparam type="XML" value="#pingDataSimple#"/>
						<cfelseif k EQ 4>
							<cfhttpparam type="XML" value="#pingDataNoTags#"/>
						<cfelse>
							<cfhttpparam type="XML" value="#pingData#"/>
						</cfif>
						</cfhttp>
						<cfscript>
						statuscode=0;
						if(cfhttpresult.statuscode contains "200"){
							xrt=cfhttpresult.FileContent;
							statuscode="200";
						}
						</cfscript>
					 </cfif>
				<cfelse>
					<cfscript>
					statuscode="200";
					xrt='<?xml version="1.0"?><methodResponse>  <params>    <param>      <value>        <struct>  <member><name>flerror</name><value><boolean>0</boolean></value></member>  <member><name>message</name><value><string>Pings being forwarded to 16 services!</string></value></member></struct>      </value>    </param>  </params></methodResponse>';
					xr=xmlparse(xrt);
					cfhttpresult={FileContent:""};
					</cfscript>
				</cfif>
				<cfscript>
				if(statuscode EQ "200"){
					if(cfhttpresult.FileContent EQ '' or k EQ 10){
						success=true; // some pings return blank document
					}else if(k EQ 1 and findnocase('thank you',cfhttpresult.FileContent) NEQ 0){
						success=true; // moreover successful ping
					}else if(k EQ 5 and findnocase('refresh',cfhttpresult.FileContent) NEQ 0){
						success=true; // blogrolling
					}else{
						xr=xmlparse(xrt);
					}
					if(isDefined('xr.methodResponse.params.param.value.struct.member')){
						for(i=1;i LTE arraylen(xr.methodResponse.params.param.value.struct.member);i++){
							c=xr.methodResponse.params.param.value.struct.member[i];
							if(c.name.xmltext EQ 'flerror'){
								if(c.value.boolean.xmltext EQ '0'){
									success=true;
								}
								break;
							}
						}
					}
					if(success){ 
						// continue
						pingDoneStruct[k]=1;
					}else if(xrt CONTAINS 'Ping is throttled'){
						pingDoneStruct[k]=1;
					}else if(xrt contains 'Pinging too fast'){
						pingDoneStruct[k]=1;
						// wait until next ping and try again
						//arrayappend(arrError,"Blog ping occurred too fast for blog_id = '#form.blog_id#' | ping id: #k# | URL:#pingURL#.<br />"&htmlcodeformat(xrt));
					}else{
						arrayappend(arrError,"Blog ping unknown error for blog_id = '#form.blog_id#' | ping id: #k# | URL:#pingURL#.<br />"&htmlcodeformat(xrt));
					}
				}else{
					arrayappend(arrError,"Blog ping connection failure for blog_id = '#form.blog_id#' | ping id: #k# | URL:#pingURL#.<br />status code:"&cfhttpresult.statuscode);
				}
				</cfscript>
			</cfif>
		</cfloop>
	</cfloop>
	<cfscript>
	// don't stop pinging until all active pings server are pinged successfully.
	pingList=structkeylist(pingDoneStruct);
	db.sql="UPDATE #db.table("blog", request.zos.zcoreDatasource)#  
	SET blog_ping_result=#db.param(pingList)#,
	blog_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE blog_id = #db.param(form.blog_id)# and 
	blog_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");
	if(structcount(pingStruct) EQ structcount(pingDoneStruct)){
		db.sql="UPDATE #db.table("blog", request.zos.zcoreDatasource)#  
		SET blog_ping_datetime = #db.param(request.zos.mysqlnow)#, 
		blog_updated_datetime=#db.param(request.zos.mysqlnow)#  
		WHERE blog_id = #db.param(form.blog_id)# and 
		blog_deleted = #db.param(0)# and
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");
	}
	if(arraylen(arrError) NEQ 0){
		application.zcore.template.fail(arraytolist(arrError,'<br />'));
	}
	writeoutput('Done');
	application.zcore.functions.zabort();
	</cfscript>
   
   
   
</cffunction>


<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
	<cfargument name="linkStruct" type="struct" required="yes">
	<cfscript>
	var ts=application.zcore.app.getInstance(this.app_id);
	var homeLink="";
	var adminLink="/z/blog/admin/blog-admin/articleList";
	
	if(application.zcore.app.getAppData("blog").optionstruct.blog_config_root_url NEQ "{default}"){
		homelink=request.zos.currentHostName&application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url;
	}else{
		// default home url
		homelink=request.zos.currentHostName&application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id,3,"html",application.zcore.app.getAppData("blog").optionStruct.blog_config_title);
	}
	if(structkeyexists(request.zos.userSession.groupAccess, "content_manager") or structkeyexists(request.zos.userSession.groupAccess, "administrator")){
		if(structkeyexists(arguments.linkStruct,"Blog") EQ false){
			ts=structnew();
			ts.featureName="Blog";
			ts.link="/z/blog/admin/blog-admin/articleList";
			ts.children=structnew();
			arguments.linkStruct["Blog"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Blog"].children,"View Blog Home Page") EQ false){
			ts=structnew();
			ts.featureName="Blog";
			ts.link=homeLink;
			ts.target="_blank";
			arguments.linkStruct["Blog"].children["View Blog Home Page"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Blog"].children,"View Blog RSS Feeds") EQ false){
			ts=structnew();
			ts.featureName="Blog";
			ts.link=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id, 1,"html",application.zcore.app.getAppData("blog").optionStruct.blog_config_category_home_name);
			ts.target="_blank";
			arguments.linkStruct["Blog"].children["View Blog RSS Feeds"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Blog"].children,"Add Article") EQ false){
			ts=structnew();
			ts.featureName="Blog Articles";
			ts.link="/z/blog/admin/blog-admin/articleAdd";
			arguments.linkStruct["Blog"].children["Add Article"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Blog"].children,"Add Event") EQ false){
			ts=structnew();
			ts.featureName="Blog Articles";
			ts.link="/z/blog/admin/blog-admin/articleAdd?blog_event=1";
			arguments.linkStruct["Blog"].children["Add Blog Event"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Blog"].children,"Add Category") EQ false){
			ts=structnew();
			ts.featureName="Blog Categories";
			ts.link="/z/blog/admin/blog-admin/categoryAdd";
			arguments.linkStruct["Blog"].children["Add Category"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Blog"].children,"Add Tag") EQ false){
			ts=structnew();
			ts.featureName="Blog Tags";
			ts.link="/z/blog/admin/blog-admin/tagAdd";
			arguments.linkStruct["Blog"].children["Add Tag"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Blog"].children,"Manage Articles & Events") EQ false){
			ts=structnew();
			ts.featureName="Blog Articles";
			ts.link="/z/blog/admin/blog-admin/articleList";
			arguments.linkStruct["Blog"].children["Manage Articles & Blog Events"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Blog"].children,"Manage Categories") EQ false){
			ts=structnew();
			ts.featureName="Blog Categories";
			ts.link="/z/blog/admin/blog-admin/categoryList";
			arguments.linkStruct["Blog"].children["Manage Categories"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Blog"].children,"Manage Tags") EQ false){
			ts=structnew();
			ts.featureName="Blog Tags";
			ts.link="/z/blog/admin/blog-admin/tagList";
			arguments.linkStruct["Blog"].children["Manage Tags"]=ts;
		} 
	}
	return arguments.linkStruct;
	</cfscript>
</cffunction>

<cffunction name="getCacheStruct" localmode="modern" output="no" access="public" returntype="struct" hint="publish the application cache">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfscript>
	var db=request.zos.queryObject;
	var qdata=0;
	var ts=StructNew();
	
	var arrColumns=0;
	var i=0;
	db.sql="SELECT * FROM #db.table("blog_config", request.zos.zcoreDatasource)# blog_config 
	where 
	blog_config_deleted = #db.param(0)# and
	site_id=#db.param(arguments.site_id)# 
	LIMIT #db.param(0)#,#db.param(1)#";
	qData=db.execute("qData");
	for(row in qData){
		return row;
	}
	throw("blog_config record is missing for site_id=#arguments.site_id#.");
	</cfscript>
</cffunction>



<cffunction name="setURLRewriteStruct" localmode="modern" output="no" access="public" returntype="any" hint="Generate the URL rewrite rules as a string">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var theText="";
	var qconfig=0;
	var t9=0;
	var db=request.zos.queryObject;
	var qF=0;
	var nl='';
	
	var link='';
	var pos='';
	var linkformat='';
	var appid='';
	var ext='';
	var cid='';
	db.sql="SELECT * FROM #db.table("blog_config", request.zos.zcoreDatasource)# blog_config , 
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE blog_config.site_id = site.site_id and 
	blog_config_deleted = #db.param(0)# and 
	site_deleted = #db.param(0)# and 
	blog_config.site_id = #db.param(arguments.site_id)#";
	qConfig=db.execute("qConfig");
	</cfscript>
	<cfloop query="qConfig">
		<cfscript>
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_misc_id]=arraynew(1);
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_tag_id]=arraynew(1);
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_category_id]=arraynew(1);
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_article_id]=arraynew(1);
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_section_id]=arraynew(1);
		db.sql="SELECT * from #db.table("blog", request.zos.zcoreDatasource)# blog 
		WHERE site_id=#db.param(arguments.site_id)# and 
		blog_unique_name<>#db.param('')# and 
		blog_deleted = #db.param(0)#
		ORDER BY blog_unique_name DESC";
		qF=db.execute("qF");
		loop query="qF"{
			t9=structnew();
			t9.scriptName="/z/blog/blog/articleTemplate";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/articleTemplate";
			t9.urlStruct.blog_id=qF.blog_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qF.blog_unique_name)]=t9;
		}
		db.sql="SELECT * from #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag 
		WHERE site_id=#db.param(arguments.site_id)# and 
		blog_tag_unique_name<>#db.param('')# and 
		blog_tag_deleted = #db.param(0)#
		ORDER BY blog_tag_unique_name DESC";
		qF=db.execute("qF");
		loop query="qF"{
			t9=structnew();
			t9.scriptName="/z/blog/blog/tagTemplate";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/tagTemplate";
			t9.urlStruct.blog_tag_id=qF.blog_tag_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qF.blog_tag_unique_name)]=t9;
		}
		db.sql="SELECT * from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
		WHERE site_id=#db.param(arguments.site_id)# and 
		blog_category_unique_name<>#db.param('')# and 
		blog_category_deleted = #db.param(0)#
		ORDER BY blog_category_unique_name DESC";
		qF=db.execute("qF");
		loop query="qF"{
			t9=structnew();
			t9.scriptName="/z/blog/blog/categoryTemplate";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/categoryTemplate";
			t9.urlStruct.blog_category_id=qF.blog_category_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qF.blog_category_unique_name)]=t9;
		}
		if(qConfig.blog_config_root_url NEQ "{default}"){
			t9=structnew();
			t9.scriptName="/z/blog/blog/index";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/index";
			
			arguments.sharedStruct.uniqueURLStruct[trim(qConfig.blog_config_root_url)]=t9;
		}else{
			// ## blog home
			//  /#name#-#appid#-#id#.#ext#
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/blog/blog/index";
			t9.ifStruct=structnew();
			t9.ifStruct.dataId="3";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/index";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_misc_id],t9);
		}

		t9=structnew();
		t9.type=6;
		t9.scriptName="/z/blog/blog/displayBlogCategorySection";
		t9.ifStruct=structnew();
		t9.ifStruct.ext="html";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/displayBlogCategorySection";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="site_x_option_group_set_id";
		t9.mapStruct.dataId2="blog_category_id";
		t9.mapStruct.dataId3="zindex";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_section_id],t9);
/*
		t9=structnew();
		t9.type=6;
		t9.scriptName="/z/blog/blog/displayBlogCategorySection";
		t9.ifStruct=structnew();
		t9.ifStruct.ext="html";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/displayBlogCategorySection";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="site_x_option_group_set_id";
		t9.mapStruct.dataId2="blog_category_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_section_id],t9);
*/

		// ## blog archive
		t9=structnew();
		t9.type=4;
		t9.scriptName="/z/blog/blog/archiveTemplate";
		t9.ifStruct=structnew();
		t9.ifStruct.dataId="2";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/archiveTemplate";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId2="archive";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_misc_id],t9);
		// ## blog tags
		t9=structnew();
		t9.type=3;
		t9.scriptName="/z/blog/blog/tagTemplate";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/tagTemplate";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="blog_tag_id";
		t9.mapStruct.dataId2="zindex";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_tag_id],t9);
		
		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/blog/blog/tagTemplate";
		t9.urlStruct=structnew();
		// hardcode the values to be insert into url scope
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/tagTemplate";
		t9.urlStruct.method="tagTemplate";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="blog_tag_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_tag_id],t9);
		// ## blog category 
		t9=structnew();
		t9.type=3;
		t9.scriptName="/z/blog/blog/categoryTemplate";
		t9.ifStruct=structnew();
		t9.ifStruct.ext="html";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/categoryTemplate";
		t9.urlStruct.method="categoryTemplate";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="blog_category_id";
		t9.mapStruct.dataId2="zindex";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_category_id],t9);

		/*
		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/blog/blog/categoryTemplate";
		t9.ifStruct=structnew();
		t9.ifStruct.ext="html";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/categoryTemplate";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="blog_category_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_category_id],t9);
		*/

		if(qConfig.blog_config_url_section_id NEQ 0){
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/blog/blog/displayBlogSection";
			t9.ifStruct=structnew();
			t9.ifStruct.ext="html";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/displayBlogSection";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			t9.mapStruct.dataId="site_x_option_group_set_id";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_section_id],t9);
		}

		
		// ## blog category rss 
		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/blog/blog/feedCategoryTemplate";
		t9.ifStruct=structnew();
		t9.ifStruct.ext="xml";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/feedCategoryTemplate";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="blog_category_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_category_id],t9);
		
		// ## blog recent rss 
		if(qConfig.blog_config_recent_url NEQ "{default}"){
			t9=structnew();
			t9.scriptName="/z/blog/blog/feedRecentTemplate";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/feedRecentTemplate";
			arguments.sharedStruct.uniqueURLStruct[trim(qConfig.blog_config_recent_url)]=t9;
		}else{
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/blog/blog/feedRecentTemplate";
			t9.ifStruct=structnew();
			t9.ifStruct.ext="xml";
			t9.ifStruct.dataId="0";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/feedRecentTemplate";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_misc_id],t9);
		}
		// ## blog category home
		if(qConfig.blog_config_category_home_url NEQ "{default}"){
			t9=structnew();
			t9.scriptName="/z/blog/blog/rssTemplate";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/rssTemplate";
			arguments.sharedStruct.uniqueURLStruct[trim(qConfig.blog_config_category_home_url)]=t9;
		}else{
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/blog/blog/rssTemplate";
			t9.urlStruct=structnew();
			t9.ifStruct=structnew();
			t9.ifStruct.dataId="1";
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/rssTemplate";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_misc_id],t9);
		}
			
		// ## blog article 
		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/blog/blog/articleTemplate";
		t9.urlStruct=structnew();
		// hardcode the values to be insert into url scope
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/articleTemplate";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="blog_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.blog_config_url_article_id],t9);
		</cfscript> 
	</cfloop>
</cffunction>


<cffunction name="updateRewriteRuleBlogTag" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="oldURL" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	s=application.sitestruct[request.zos.globals.id];

	db.sql="SELECT * from #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	blog_tag_unique_name<>#db.param('')# and 
	blog_tag_deleted = #db.param(0)# and 
	blog_tag_id = #db.param(arguments.id)#";
	qF=db.execute("qF");
	if(qF.recordcount EQ 0){
		structdelete(s.urlRewriteStruct.uniqueURLStruct, arguments.oldURL);
	}
	loop query="qF"{
		t9=structnew();
		t9.scriptName="/z/blog/blog/tagTemplate";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/tagTemplate";
		t9.urlStruct.blog_tag_id=qF.blog_tag_id;
		s.urlRewriteStruct.uniqueURLStruct[trim(qF.blog_tag_unique_name)]=t9;
	} 
	return true;
	</cfscript>
</cffunction>

<cffunction name="updateRewriteRuleBlogCategory" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="oldURL" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	s=application.sitestruct[request.zos.globals.id];

	db.sql="SELECT * from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	blog_category_unique_name<>#db.param('')# and 
	blog_category_deleted = #db.param(0)# and 
	blog_category_id = #db.param(arguments.id)#";
	qF=db.execute("qF");
	if(qF.recordcount EQ 0){
		structdelete(s.urlRewriteStruct.uniqueURLStruct, arguments.oldURL);
	}
	loop query="qF"{
		t9=structnew();
		t9.scriptName="/z/blog/blog/categoryTemplate";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/categoryTemplate";
		t9.urlStruct.blog_category_id=qF.blog_category_id;
		s.urlRewriteStruct.uniqueURLStruct[trim(qF.blog_category_unique_name)]=t9;
	} 
	return true;
	</cfscript>
</cffunction>

<cffunction name="updateRewriteRuleBlogArticle" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="oldURL" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	s=application.sitestruct[request.zos.globals.id];

	db.sql="SELECT * from #db.table("blog", request.zos.zcoreDatasource)# blog 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	blog_unique_name<>#db.param('')# and 
	blog_deleted = #db.param(0)# and 
	blog_id = #db.param(arguments.id)#";
	qF=db.execute("qF");
	if(qF.recordcount EQ 0){
		structdelete(s.urlRewriteStruct.uniqueURLStruct, arguments.oldURL);
	}
	loop query="qF"{
		t9=structnew();
		t9.scriptName="/z/blog/blog/articleTemplate";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/blog/blog/articleTemplate";
		t9.urlStruct.blog_id=qF.blog_id;
		s.urlRewriteStruct.uniqueURLStruct[trim(qF.blog_unique_name)]=t9;
	} 
	return true;
	</cfscript>
</cffunction>

<cffunction name="updateRewriteRules" localmode="modern" output="no" access="public" returntype="boolean">
	<cfscript>
	application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
	return true;
	</cfscript>
</cffunction>

<cffunction name="configDelete" localmode="modern" output="no" access="public" returntype="any" hint="delete the record from test table.">
	<cfscript>
	var db=request.zos.queryObject;
	var qconfig=0;
	
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	db.sql="DELETE FROM #db.table("blog_config", request.zos.zcoreDatasource)#  
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	blog_config_deleted = #db.param(0)#";
	qConfig=db.execute("qConfig");
	return variables.rCom;
	</cfscript>
</cffunction>

<cffunction name="loadDefaultConfig" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="validate" required="no" type="boolean" default="#false#">
	<cfscript>
	var field=0;
	var i=0;
	var error=false;
	var df=structnew();
	df.blog_config_title="Blog";
	df.blog_config_root_url="{default}";
	df.blog_config_url_article_id="1";
	df.blog_config_url_category_id="2";
	df.blog_config_url_misc_id="3";
	df.blog_config_url_tag_id="4";
	df.blog_config_url_section_id="5";
	df.blog_config_recent_name="Recent Articles";
	df.blog_config_url_format="/##name##-##appid##-##id##.##ext##";
	df.blog_config_category_home_name="Blog Categories";
	df.blog_config_category_home_url="{default}";
	df.blog_config_recent_url="{default}";
	df.blog_config_archive_name="archive";
	df.blog_config_home_url="/";
	for(i in df){	
		if(arguments.validate){
			if(structkeyexists(form,i) EQ false or (form[i] EQ "")){	
				error=true;
				field=trim(lcase(replacenocase(replacenocase(i,"blog_config_",""),"_"," ","ALL")));
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
	var result='';
	var ts=StructNew();
	if(this.loadDefaultConfig(true) EQ false){
		variables.rCom.setError("Please correct the above validation errors and submit again.",1);
		return variables.rCom;
	}
	form.blog_config_include_sidebar=application.zcore.functions.zso(form, 'blog_config_include_sidebar',false,0);
	
	form.site_id=form.sid;
	ts=StructNew();
	ts.arrId=arrayNew(1);
	arrayappend(ts.arrId,trim(form.blog_config_url_article_id));
	arrayappend(ts.arrId,trim(form.blog_config_url_category_id));
	arrayappend(ts.arrId,trim(form.blog_config_url_tag_id));
	arrayappend(ts.arrId,trim(form.blog_config_url_misc_id));
	arrayappend(ts.arrId,trim(form.blog_config_url_section_id));
	ts.app_id=this.app_id;
	ts.site_id=form.sid;
	variables.rCom=application.zcore.app.reserveAppUrlId(ts);
	if(variables.rCom.isOK() EQ false){
		return variables.rCom;
	}
	
	
	ts.table="blog_config";
	ts.struct=form;
	ts.datasource="#request.zos.zcoreDatasource#";
	if(application.zcore.functions.zso(form,'blog_config_id',true) EQ 0){ // insert
		result=application.zcore.functions.zInsert(ts);
		if(result EQ false){
			variables.rCom.setError("Failed to save configuration.",2);
			return variables.rCom;
		}
	}else{ // update
		result=application.zcore.functions.zUpdate(ts);
		if(result EQ false){
			variables.rCom.setError("Failed to save configuration.",3);
			return variables.rCom;
		}
	} 
	application.zcore.status.setStatus(request.zsid,"Configuration saved.");
	return variables.rCom;
	</cfscript>
</cffunction>


<cffunction name="configForm" localmode="modern" output="no" access="remote" returntype="any" hint="displays a form to add/edit applications.">
	<cfscript>
	var selectStruct='';
	var db=request.zos.queryObject;
	var rs=structnew();
	var ts=0;
	var qConfig='';
	
	var qTemplate='';
	var theText="";
	</cfscript>
	<cfsavecontent variable="theText"> 
		<cfsavecontent variable="db.sql">
		SELECT * FROM #db.table("blog_config", request.zos.zcoreDatasource)# blog_config 
		WHERE site_id=#db.param(form.sid)# and 
		blog_config_deleted = #db.param(0)#
		</cfsavecontent><cfscript>qConfig=db.execute("qConfig");
		application.zcore.functions.zQueryToStruct(qConfig);
		this.loadDefaultConfig();
		application.zcore.functions.zStatusHandler(request.zsid,true);
		</cfscript>
		<input type="hidden" name="blog_config_id" value="#application.zcore.functions.zso(form, 'blog_config_id')#">
		<table style="border-spacing:0px;" class="table-list">
		<tr>
		<th>Title:</th>
		<td><input type="text" name="blog_config_title" value="#form.blog_config_title#" size="60" maxlength="255"></td>
		</tr> 
		<tr>
		<th>Root URL</th>
		<td><input type="text" name="blog_config_root_url" id="blog_config_root_url" value="#form.blog_config_root_url#" size="40"  maxlength="100"> <a href="##" onclick=" document.getElementById('blog_config_root_url').value='{default}'; return false;">Restore default</a></td>
		</tr>
		<tr>
		<th>URL Article ID</th>
		<td>
		<cfscript>
		writeoutput(application.zcore.app.selectAppUrlId("blog_config_url_article_id",form.blog_config_url_article_id, this.app_id));
		</cfscript></td>
		</tr>
		<tr>
		<th>URL Category ID</th>
		<td>
		<cfscript>
		writeoutput(application.zcore.app.selectAppUrlId("blog_config_url_category_id",form.blog_config_url_category_id, this.app_id));
		</cfscript></td>
		</tr>
		<tr>
		<th>URL Tag ID</th>
		<td>
		<cfscript>
		writeoutput(application.zcore.app.selectAppUrlId("blog_config_url_tag_id",form.blog_config_url_tag_id, this.app_id));
		</cfscript></td>
		</tr>
		<tr>
		<th>URL Misc ID</th>
		<td>
		<cfscript>
		writeoutput(application.zcore.app.selectAppUrlId("blog_config_url_misc_id",form.blog_config_url_misc_id, this.app_id));
		</cfscript> Used for major landing pages</td>
		</tr>
		<tr>
		<th>URL Section ID</th>
		<td>
		<cfscript>
		writeoutput(application.zcore.app.selectAppUrlId("blog_config_url_section_id",form.blog_config_url_section_id, this.app_id));
		</cfscript></td>
		</tr>
		<tr>
		<th>Section Title Affix:</th>
		<td><cfscript>
		ts = StructNew();
		ts.name = "blog_config_section_title_affix";
		application.zcore.functions.zInput_Text(ts);
		</cfscript></td>
		</tr>
		<tr>
		<th>Recent Name</th>
		<td><input type="text" name="blog_config_recent_name" value="#form.blog_config_recent_name#" size="30"  maxlength="30"></td>
		</tr>
		<tr>
		<th>Recent XML URL</th>
		<td><input type="text" name="blog_config_recent_url" id="blog_config_recent_url" value="#form.blog_config_recent_url#" size="40"  maxlength="100"> <a href="##" onclick="document.getElementById('blog_config_recent_url').value='{default}';return false;">Restore default</a></td>
		</tr>
		<tr>
		<th>URL Format</th>
		<td><input type="text" name="blog_config_url_format" value="#form.blog_config_url_format#" size="60"  maxlength="100"></td>
		</tr>
		<tr>
		<th>Google Feedburner URL</th>
		<td><input type="text" name="blog_config_feedburner_url" value="#form.blog_config_feedburner_url#" size="60"  maxlength="100"></td>
		</tr>
		<tr>
		<th>Home URL</th>
		<td><input type="text" name="blog_config_home_url" value="#form.blog_config_home_url#" size="60"  maxlength="255"></td>
		</tr>
		<tr>
		<th>Category Home Name</th>
		<td><input type="text" name="blog_config_category_home_name" value="#form.blog_config_category_home_name#" size="60"  maxlength="100"></td>
		</tr>
		<tr>
		<th>Category Home URL</th>
		<td><input type="text" name="blog_config_category_home_url" id="blog_config_category_home_url" value="#form.blog_config_category_home_url#" size="40"  maxlength="100"> <a href="##" onclick=" document.getElementById('blog_config_category_home_url').value='{default}';return false;">Restore default</a></td>
		</tr>
		<tr>
		<th>Email Alerts Enabled?</th>
		<td>#application.zcore.functions.zInput_Boolean("blog_config_email_alerts_enabled")#</td>
		</tr>
		<tr>
		<th>Email Alert Subject</th>
		<td><input type="text" name="blog_config_email_alert_subject" value="#form.blog_config_email_alert_subject#" size="60"  maxlength="100"></td>
		</tr>
		<tr>
		<th>Email Full Article?</th>
		<td>#application.zcore.functions.zInput_Boolean("blog_config_email_full_article")#</td>
		</tr>
		<tr>
		<th>Archive Name</th>
		<td><input type="text" name="blog_config_archive_name" value="#form.blog_config_archive_name#" size="60"  maxlength="100"></td>
		</tr>
		<tr> 
		<th style="vertical-align:top;">Disable Comments?</th>
		<td style="vertical-align:top;"><input type="radio" name="blog_config_disable_comments" value="1" <cfif form.blog_config_disable_comments EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes <input type="radio" name="blog_config_disable_comments" value="0" <cfif form.blog_config_disable_comments EQ 0 or form.blog_config_disable_comments EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> No 
		</td>
		</tr>
		<tr> 
		<th style="vertical-align:top;">&nbsp;</th>
		<td style="vertical-align:top;">Always show section articles on main blog pages?<br />
		<input type="radio" name="blog_config_always_show_section_articles" value="1" <cfif form.blog_config_always_show_section_articles EQ 1 or form.blog_config_always_show_section_articles EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> Yes 
		<input type="radio" name="blog_config_always_show_section_articles" value="0" <cfif form.blog_config_always_show_section_articles EQ 0 >checked="checked"</cfif> style="border:none; background:none;" /> No 
		</td>
		</tr>
		<tr> 
		<th style="vertical-align:top;">&nbsp;</th>
		<td style="vertical-align:top;">Display Full Detail of first article on category page?<br />
		<input type="radio" name="blog_config_show_detail" value="1" <cfif form.blog_config_show_detail EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes 
		<input type="radio" name="blog_config_show_detail" value="0" <cfif form.blog_config_show_detail EQ 0 or form.blog_config_show_detail EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> No 
		</td>
		</tr>
		<tr>
		<th>Thumbnail Image:</th>
		<td>
		<cfscript>
		form.blog_config_thumbnail_width=application.zcore.functions.zso(form, 'blog_config_thumbnail_width',true,250);
		form.blog_config_thumbnail_height=application.zcore.functions.zso(form, 'blog_config_thumbnail_height',true,200);
		form.blog_config_thumbnail_crop=application.zcore.functions.zso(form, 'blog_config_thumbnail_crop',true,0);
		</cfscript>
		Width: <input type="text" name="blog_config_thumbnail_width" value="#htmleditformat(form.blog_config_thumbnail_width)#" /> 
		Height: <input type="text" name="blog_config_thumbnail_height" value="#htmleditformat(form.blog_config_thumbnail_height)#" /> 
		Crop: 
		<cfscript>
		ts = StructNew();
		ts.name = "blog_config_thumbnail_crop";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript> (Default is 250x250).</td>
		</tr>
		</table>
	</cfsavecontent>
	<cfscript>
	rs.output=theText;
	variables.rCom.setData(rs);
	return variables.rCom;
	</cfscript>
</cffunction>

<cffunction name="onRequestStart" localmode="modern" output="yes" returntype="void">
	<cfscript>
	 
	if(request.zos.allowRequestCFC){
		request.zos.tempObj.blogInstance=structnew();
		structappend(request.zos.tempObj.blogInstance, application.sitestruct[request.zos.globals.id].app.appCache[this.app_id]);
		request.zos.tempObj.blogInstance.configCom=this;
	}
	
	if(form[request.zos.urlRoutingParameter] EQ "/"){
		if(application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_feedburner_url') NEQ ''){
			curLink=application.zcore.app.getAppData("blog").optionStruct.blog_config_feedburner_url;
		}else if(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_url EQ '{default}'){
			curLink=request.zos.currentHostName&"/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name,'-')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-0.xml";
		}else{
			curLink=request.zos.currentHostName&application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_url;
		}
		application.zcore.template.prependTag("meta", '<link rel="alternate" type="application/rss+xml" title="'&htmleditformat(application.zcore.app.getAppData("blog").optionStruct.blog_config_title)&'" href="'&curLink&'" />');
	}
	</cfscript>
</cffunction>

<cffunction name="onRequestEnd" localmode="modern" output="yes" returntype="void" hint="Runs after zos end file.">
</cffunction>



<!--- application.zcore.app.getAppCFC("blog").searchReindexBlogArticles(false, true); --->
<cffunction name="searchReindexBlogArticles" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexEverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	offset=0;
	limit=30;
	while(true){
		db.sql="SELECT * FROM #db.table("blog", request.zos.zcoreDatasource)# blog ,
		#db.table("blog_config", request.zos.zcoreDatasource)# blog_config
		WHERE 
		blog_deleted = #db.param(0)# and 
		blog_config_deleted = #db.param(0)# and 
		blog_config.site_id = blog.site_id ";
		if(arguments.indexeverything EQ false){
			db.sql&=" and blog.site_id = #db.param(request.zos.globals.id)# ";
		}else{
			db.sql&=" and blog.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and blog_id = #db.param(arguments.id)# ";
		}
		db.sql&=" and (blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&" "&timeformat(now(),'HH:mm:ss'))# or 
		blog_event =#db.param(1)#) and 
		blog_status <> #db.param(2)#  ";
		db.sql&=" LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteBlogArticle(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.blog_title&" "&row.blog_summary&" "&row.blog_story;
				ds.search_title=row.blog_title;
				ds.search_summary=row.blog_summary;
				if(len(ds.search_summary) EQ 0){
					ds.search_summary=row.blog_story;
				}
				if(row.blog_unique_name NEQ ''){
					ds.search_url=row.blog_unique_name;
				}else{
					ds.search_url="/"&application.zcore.functions.zURLEncode(row.blog_title,'-')&"-"&row.blog_config_url_article_id&"-"&row.blog_id&".html";
				}
				ds.search_table_id='blog-article-'&row.blog_id;
				ds.app_id=this.app_id;
				ds.search_content_datetime=dateformat(row.blog_datetime, "yyyy-mm-dd")&" "&timeformat(row.blog_datetime, "HH:mm:ss");
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
		search_deleted = #db.param(0)# and
		search_table_id LIKE #db.param("blog-article-%")# and 
		search_updated_datetime < #db.param(startDate)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>

<!--- application.zcore.app.getAppCFC("blog").searchReindexBlogTags(false, true); --->
<cffunction name="searchReindexBlogTags" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexeverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	offset=0;
	limit=30;
	while(true){
		db.sql="SELECT * FROM #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag ,
		#db.table("blog_config", request.zos.zcoreDatasource)# blog_config
		WHERE 
		blog_config_deleted = #db.param(0)# and 
		blog_tag_deleted = #db.param(0)# and 
		blog_config.site_id = blog_tag.site_id ";
		if(arguments.indexeverything EQ false){
			db.sql&=" and blog_tag.site_id = #db.param(request.zos.globals.id)#  ";
		}else{
			db.sql&=" and blog_tag.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and blog_tag_id = #db.param(arguments.id)# ";
		}
		db.sql&=" LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteBlogTag(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.blog_tag_name&" "&row.blog_tag_description;
				ds.search_title=row.blog_tag_name;
				ds.search_summary=row.blog_tag_description;
				if(row.blog_tag_unique_name NEQ ''){
					ds.search_url=row.blog_tag_unique_name;
				}else{
					ds.search_url="/"&application.zcore.functions.zURLEncode(row.blog_tag_name,'-')&"-"&row.blog_config_url_tag_id&"-"&row.blog_tag_id&".html";
				}
				ds.search_table_id='blog-tag-'&row.blog_tag_id;
				ds.app_id=this.app_id;
				ds.search_content_datetime=request.zos.mysqlnow;
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
		search_deleted = #db.param(0)# and
		search_table_id LIKE #db.param("blog-tag-%")# and 
		search_updated_datetime < #db.param(startDate)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>

<!--- application.zcore.app.getAppCFC("blog").searchReindexBlogCategories(false, true); --->
<cffunction name="searchReindexBlogCategories" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexeverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	offset=0;
	limit=30;
	while(true){
		db.sql="SELECT * FROM #db.table("blog_category", request.zos.zcoreDatasource)# blog_category ,
		#db.table("blog_config", request.zos.zcoreDatasource)# blog_config
		WHERE 
		blog_category_deleted = #db.param(0)# and 
		blog_config_deleted = #db.param(0)# and
		blog_config.site_id = blog_category.site_id ";
		if(arguments.indexeverything EQ false){
			db.sql&=" and blog_category.site_id = #db.param(request.zos.globals.id)#  ";
		}else{
			db.sql&=" and blog_category.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and blog_category_id = #db.param(arguments.id)# ";
		}
		db.sql&=" LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteBlogCategory(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.blog_category_name&" "&row.blog_category_description;
				ds.search_title=row.blog_category_name;
				ds.search_summary=row.blog_category_description;
				if(row.blog_category_unique_name NEQ ''){
					ds.search_url=row.blog_category_unique_name;
				}else{
					ds.search_url="/"&application.zcore.functions.zURLEncode(row.blog_category_name,'-')&"-"&row.blog_config_url_category_id&"-"&row.blog_category_id&".html";
				}
				ds.search_table_id='blog-category-'&row.blog_category_id;
				ds.app_id=this.app_id;
				ds.site_id=row.site_id;
				ds.search_content_datetime=request.zos.mysqlnow;
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
		search_deleted = #db.param(0)# and
		app_id = #db.param(this.app_id)# and 
		search_table_id LIKE #db.param("blog-category-%")# and 
		search_updated_datetime < #db.param(startDate)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>



<!--- application.zcore.app.getAppCFC("blog").searchIndexDeleteBlogTag(blog_tag_id); --->
<cffunction name="searchIndexDeleteBlogTag" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)# and 
	search_deleted = #db.param(0)# and
	search_table_id = #db.param("blog-tag-"&arguments.id)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>

<!--- application.zcore.app.getAppCFC("blog").searchIndexDeleteBlogArticle(blog_id); --->
<cffunction name="searchIndexDeleteBlogArticle" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)# and 
	search_deleted = #db.param(0)# and
	search_table_id = #db.param("blog-article-"&arguments.id)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>

<!--- application.zcore.app.getAppCFC("blog").searchIndexDeleteBlogCategory(blog_category_id); --->
<cffunction name="searchIndexDeleteBlogCategory" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)# and 
	search_deleted = #db.param(0)# and
	search_table_id = #db.param("blog-category-"&arguments.id)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>




<cffunction name="articleTemplate" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	var content='';
	var blog_title='';
	var blog_datetime='';
	var noComments='';
	var theLink='';
	var curLink='';
	var actualLink='';
	var tempCurrentBlogUrl='';
	var viewdata='';
	var curDate='';
	var tempText='';
	var qComments=0;
	var theHTML='';
	
	var set9='';
	var query='';
	var ts=0;
	var rs2=0;
	var nextMonth='';
	var qArticle='';
	var qupdate='';
	var qRelated='';
	var qPopular='';
	var temp='';
	var tempMeta='';
	var db=request.zos.queryObject;
	var tempMenu='';
	var tempPagenav='';
	variables.init();
	if(structkeyexists(form, 'rss_id')){
		application.zcore.functions.z404("rss_id is not supposed to be defined for articleTemplate()");	
	}
	if(not structkeyexists(form, 'blog_id')){
		application.zcore.functions.z404("blog_id is required");	
	}
	form.preview=application.zcore.functions.zso(form, 'preview', true, 0);
	previewEnabled=false;
	if(application.zcore.user.checkGroupAccess("member")){
		previewEnabled=true;
	}else{
		if(form.preview EQ 1){
			previewEnabled=true;
		}
		structdelete(form, 'preview');
	} 
	//previewEnabled=false;
	</cfscript>
	<script type="text/javascript">
	/* <![CDATA[ */ function textCounter(field,cntfield,maxlimit) {
		if (field.value.length > maxlimit){ // if too long...trim it!
			field.value = field.value.substring(0, maxlimit);
			// otherwise, update 'characters left' counter
		}else{
			cntfield.value = maxlimit - field.value.length;
		}
	}
	/* ]]> */
	</script>
	<cfscript>
	// you must have a group by in your query or it may miss rows
	ts=structnew();
	ts.image_library_id_field="blog.blog_image_library_id";
	ts.count = 0; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	</cfscript> 
	<cfsavecontent variable="db.sql">
	select * 
	#db.trustedsql(rs2.select)#
	from #db.table("blog", request.zos.zcoreDatasource)# blog
	#db.trustedsql(rs2.leftJoin)#
	left join #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment on 
	blog.blog_id = blog_comment.blog_id and 
	blog_comment_approved=#db.param(1)#  and 
	blog_comment.site_id = blog.site_id and 
	blog_comment_deleted = #db.param(0)#
	left join #db.table("blog_category", request.zos.zcoreDatasource)# blog_category on 
	blog_category.blog_category_id = blog.blog_category_id and 
	blog_category.site_id = blog.site_id and 
	blog_category_deleted = #db.param(0)#
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user 
	ON blog.user_id = user.user_id  and 
	user_deleted = #db.param(0)# and
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("blog.user_id_siteIDType"))#
	where blog.blog_id = #db.param(form.blog_id)# and 
	blog.site_id=#db.param(request.zos.globals.id)# and
	blog_deleted = #db.param(0)# 
	<cfif not previewEnabled> 
		and (blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&" "&timeformat(now(),'HH:mm:ss'))# or 
		blog_event =#db.param(1)#) and 
		blog_status <> #db.param(2)#
	</cfif>
	GROUP BY blog.blog_id
	order by blog_sticky desc, blog_datetime, blog_comment_datetime
	</cfsavecontent>
	<cfscript>
	qArticle=db.execute("qArticle"); 
 
	// login required to view blog preview url - added to allow sharing blog urls for approval.
	if(qArticle.recordcount NEQ 0){
		if(previewEnabled){
			if(datecompare(dateformat(qArticle.blog_datetime, "yyyy-mm-dd")&" "&timeformat(qArticle.blog_datetime, "HH:mm:ss"), now()) GTE 0){
				// active
			}else if(qArticle.blog_event and qArticle.blog_status NEQ 2){
				// active
			}else if(application.zcore.user.checkGroupAccess("member")){
				// active
			}else{
				application.zcore.user.requireLogin("member");
			
				// don't stay on preview URL if we don't need to
				if(structkeyexists(form, 'preview')){
					if(qArticle.blog_unique_name EQ ""){
						curLink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,qarticle.blog_id,"html",qArticle.blog_title,qArticle.blog_datetime);
						application.zcore.functions.z301Redirect(curLink);
					}else{
						application.zcore.functions.z301Redirect(qArticle.blog_unique_name);
					} 
				}
			}
		}
	} 

	form.blog_category_id=qArticle.blog_category_id;
   	if(qArticle.site_x_option_group_set_id NEQ 0){
   		form.site_x_option_group_set_id=qArticle.site_x_option_group_set_id;
   	} 
	
	if(isDefined('request.zos.supressBlogArticleDetails') EQ false or request.zos.supressBlogArticleDetails NEQ 1){
		if(qArticle.recordcount eq 0){
			application.zcore.functions.z404("articleTemplate() Blog article was missing.");
		}
	}
	</cfscript>
	<cfsavecontent variable="db.sql">
	select * from #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment where
	blog_comment_approved=#db.param(1)#  and  
	blog_comment_deleted = #db.param(0)# and
	blog_id = #db.param(form.blog_id)# and 
	site_id=#db.param(request.zos.globals.id)# 
	ORDER BY blog_comment_datetime 
	</cfsavecontent><cfscript>qComments=db.execute("qComments");</cfscript> 
	<cfscript>
	if(isdate(qArticle.blog_datetime) EQ false or (datecompare(qArticle.blog_datetime,now()) EQ 1 and qArticle.blog_event EQ 0) or qArticle.blog_status EQ '2'){
		application.zcore.template.prependTag("content",'<table style="border-spacing:10px;width:100%;border:1px solid ##990000;"><tr><td style="font-size:14px; font-weight:bold; color:##FF0000;">This is a preview of an unpublished article. <a href="/z/blog/admin/blog-admin/articleEdit?blog_id='&form.blog_id&'" class="zNoContentTransition">Click here to edit</a></td></tr></table><br />');
	}
	
	if(structkeyexists(form, 'zUrlName')){
		if(qArticle.blog_unique_name EQ ""){
			curLink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,qarticle.blog_id,"html",qArticle.blog_title,qArticle.blog_datetime);
			actualLink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,qarticle.blog_id,"html",form.zUrlName); 
			if(compare(curLink, actualLink) neq 0){
				application.zcore.functions.z301Redirect(curLink);
			}
		}else{
			if(compare(qArticle.blog_unique_name, request.zos.originalURL) NEQ 0){
				application.zcore.functions.z301Redirect(qArticle.blog_unique_name);
			}
		}
	}
	if(qArticle.blog_unique_name EQ ""){
		currentBlogURL=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,qarticle.blog_id,"html",qArticle.blog_title,qArticle.blog_datetime);
	}else{
		currentBlogURL=qArticle.blog_unique_name;
	}
	application.zcore.siteOptionCom.setCurrentOptionAppId(qarticle.blog_site_option_app_id);
	</cfscript>
	
	<cfif request.zos.trackingSpider EQ false>
		<!--- only hit after 12/4/2011 count because spiders were allowed before this time. --->
		<cfsavecontent variable="db.sql">
		UPDATE #db.table("blog", request.zos.zcoreDatasource)#  
		SET blog_views=blog_views+#db.param(1)# 
		where blog_id = #db.param(form.blog_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		blog_deleted = #db.param(0)#
		</cfsavecontent><cfscript>qupdate=db.execute("qupdate");</cfscript>
		</cfif>
		<cfsavecontent variable="tempPageNav">
		<a href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_home_url#">#htmleditformat(application.zcore.functions.zvar("homelinktext"))#</a> / <cfif application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url EQ "{default}"><a class="#application.zcore.functions.zGetLinkClasses()#" href="/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_title,"-")#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-3.html" class="#application.zcore.functions.zGetLinkClasses()#">#htmleditformat(application.zcore.app.getAppData("blog").optionStruct.blog_config_title)#</a><cfelse><a href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url#">#htmleditformat(application.zcore.app.getAppData("blog").optionStruct.blog_config_title)#</a></cfif> / <a class="#application.zcore.functions.zGetLinkClasses()#" href="<cfif qArticle.blog_category_unique_name NEQ ''>#qArticle.blog_category_unique_name#<cfelse>#application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id,qArticle.blog_category_id,"html",qArticle.blog_category_name)#</cfif>">#htmleditformat(qArticle.blog_category_name)#</a> / 
		</cfsavecontent>
		<cfsavecontent variable="tempMenu">
			<cfset content = '#content#'>
			<cfset blog_title = '#qArticle.blog_title#'>
			<cfset blog_datetime = '#qArticle.blog_datetime#'>
		</cfsavecontent>
		<cfsavecontent variable="tempMeta">
			<cfif qArticle.blog_metakey NEQ ""><meta name="Keywords" content="#htmleditformat(qArticle.blog_metakey)#" /></cfif>
			<meta name="Description" content="<cfif qArticle.blog_metadesc NEQ "">#htmleditformat(qArticle.blog_metadesc)#<cfelse>#htmleditformat(application.zcore.functions.zLimitStringLength(application.zcore.functions.zStripHTMLTags(qArticle.blog_story), 100))#</cfif>" />
		</cfsavecontent>
		<cfif qArticle.blog_slideshow_id NEQ 0>
		<cfscript>application.zcore.functions.zEmbedSlideShow(qarticle.blog_slideshow_id);</cfscript>
	</cfif>
    
    
    
	<cfscript> 
	if(isDefined('request.zos.supressBlogArticleDetails')) {
		if(qArticle.blog_unique_name NEQ ""){
			tempCurrentBlogUrl=qArticle.blog_unique_name;
		}else{
			tempCurrentBlogUrl=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,blog_id,"html",qArticle.blog_title,qArticle.blog_datetime);
		}
		writeoutput('<h2><a href="#tempCurrentBlogUrl#">'  & htmleditformat(qArticle.blog_title) & '</a></h2><br />');
	} else {
		application.zcore.template.setTag("title","#qArticle.blog_title#");
		application.zcore.template.setTag("pagetitle","#qArticle.blog_title#");
		application.zcore.template.setTag("pagenav",tempPageNav);
		application.zcore.template.setTag("menu",tempMenu);
		application.zcore.template.setTag("meta",tempMeta);
	}
	
	viewdata=structnew();
	viewdata.qArticle=qArticle;
	viewdata.article=structnew();
	application.zcore.functions.zQueryToStruct(qArticle, viewdata.article);
	
	curDate=dateformat(blog_datetime,'yyyy-mm-01 00:00:00');
	
	// run a security filter
	// application.zcore.functions.zViewDataSecurityFilter("secureField,List,Here");
	// or run a query to object view mapping function which has all tables predefined
	// or define the available fields right here.
	
	viewdata.article.story="";
	viewdata.article.story&=('<div id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/blog/admin/blog-admin/articleEdit?blog_id=#form.blog_id#&amp;return=1">');
	application.zcore.template.prependTag('pagetitle','<span id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/blog/admin/blog-admin/articleEdit?blog_id=#form.blog_id#&amp;return=1">');
	application.zcore.template.appendTag('pagetitle','</span>');
	if(isDefined('request.zos.supressBlogArticleDetails')){
		tempText=qArticle.blog_story;
		viewdata.article.story&=(replace(tempText,"##zbeginlistings","#tempCurrentBlogUrl###zbeginlistings","ALL"));
		
	}else{
		viewdata.article.story&=qArticle.blog_story;
	} 
	viewdata.article.story&=('</div>'); 
	// might need to support this in the skin language instead
	//viewdata.article.secureEmailURL=application.zcore.functions.zEncodeEmail(qArticle.user_username);
	//viewdata.article.secureEmailAddress=application.zcore.functions.zEncodeEmail(qArticle.user_username); 
	db.sql="select * ";
	if(application.zcore.enableFullTextIndex){
		db.sql&=" , MATCH(blog_search) AGAINST (#db.param(qArticle.blog_title)# ) c ";// WITH QUERY EXPANSION 
	}
	db.sql&=" from #db.table("blog", request.zos.zcoreDatasource)# blog ";
	if(application.zcore.enableFullTextIndex){
		db.sql&=" FORCE INDEX(search) ";
	} 
	// blog_search like '%#db.param(replace(qArticle.blog_title,' ','%','ALL'))#%'  and
	db.sql&="where 
	blog_deleted = #db.param(0)# and
	blog_category_id =#db.param(qArticle.blog_category_id)# and 
	blog_id <> #db.param(qArticle.blog_id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
	blog_event =#db.param(1)#) and 
	blog_status <> #db.param(2)# ";
	if(application.zcore.enableFullTextIndex){
		db.sql&=" order by c desc, blog_sticky desc, blog_datetime desc";
	}
	db.sql&=" LIMIT #db.param(0)#,#db.param(5)#";
	qRelated=db.execute("qRelated");
	viewdata.qRelated=qRelated;
	/*if(request.zos.isTestServer){
	writeoutput(application.zcore.skin.includeSkin("/z/static/skin/blog/article.html", viewdata));
	abort;
	}*/
	authorLabel=qArticle.user_first_name&" "&qArticle.user_last_name;
	if(trim(authorLabel) EQ ""){
		authorLabel=qArticle.user_username;
	}
	</cfscript>
	<div class="zblog-author" style="font-size:100%; font-weight:700; clear:both; ">Author: #application.zcore.functions.zEncodeEmail(qArticle.user_username,true, authorLabel,true,false)# 
	<cfset curFeedLink=application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_feedburner_url')> 
	<cfif qArticle.user_googleplus_url NEQ "" or qArticle.user_twitter_url NEQ "" or qArticle.user_facebook_url NEQ "">
		&nbsp; Follow me: 
	</cfif>
	<cfif curFeedLink NEQ "">
	<a href="#curFeedLink#" target="_blank" title="Follow us by email subscription"><img src="/z/images/icons/rss.png" alt="Follow #qArticle.user_first_name&" "&qArticle.user_last_name# by email subscription" width="16" height="16" /></a>
	</cfif>
	<cfif qArticle.user_googleplus_url NEQ ""><a href="#qArticle.user_googleplus_url#?rel=author" rel="author" target="_blank" title="#qArticle.user_first_name&" "&qArticle.user_last_name# on Google+"><img src="/z/images/icons/googleplusv2.png" alt="#qArticle.user_first_name&" "&qArticle.user_last_name# on Google+" width="16" height="16" /></a></cfif> 
	<cfif qArticle.user_twitter_url NEQ ""><a href="#qArticle.user_twitter_url#" target="_blank" title="#qArticle.user_first_name&" "&qArticle.user_last_name# on Twitter"><img src="/z/images/icons/twitter.png" alt="#qArticle.user_first_name&" "&qArticle.user_last_name# on Twitter" width="16" height="16" /></a></cfif>
	<cfif qArticle.user_facebook_url NEQ ""><a href="#qArticle.user_facebook_url#" target="_blank" title="#qArticle.user_first_name&" "&qArticle.user_last_name# on Facebook"><img src="/z/images/icons/facebook.png" alt="#qArticle.user_first_name&" "&qArticle.user_last_name# on Facebook" width="16" height="16" /></a></cfif>

	<cfif qArticle.user_instagram_url NEQ ''>
		<a href="#qArticle.user_instagram_url#" target="_blank" title="#qArticle.user_first_name&" "&qArticle.user_last_name# on Instagram"><img src="/z/images/icons/instagram.png" alt="#qArticle.user_first_name&" "&qArticle.user_last_name# on Instagram" width="16" height="16" /></a>
	</cfif>
	<cfif qArticle.user_linkedin_url NEQ ''>
		<a href="#qArticle.user_linkedin_url#" target="_blank" title="#qArticle.user_first_name&" "&qArticle.user_last_name# on LinkedIn"><img src="/z/images/icons/linkedin.png" alt="#qArticle.user_first_name&" "&qArticle.user_last_name# on LinkedIn" width="16" height="16" /></a>
	</cfif>
	<br />
	<span style="font-weight:normal; font-style:italic;"><cfif qArticle.blog_event EQ 1> Event Date:  </cfif> #dateformat(qArticle.blog_datetime, 'ddd, mmm dd, yyyy')#
	<cfif qArticle.blog_hide_time EQ 0> at #timeformat(qArticle.blog_datetime, 'h:mmtt')# </cfif>
	<cfif qArticle.blog_end_datetime NEQ "" and qArticle.blog_end_datetime NEQ qArticle.blog_datetime>
		<cfif dateformat(qArticle.blog_end_datetime,'yyyymmdd') NEQ dateformat(qArticle.blog_datetime,'yyyymmdd')>
		to #dateformat(qArticle.blog_end_datetime, 'ddd, mmm dd, yyyy')# 
			<cfif qArticle.blog_hide_time EQ 0 and qArticle.blog_event EQ 1> at #timeformat(qArticle.blog_end_datetime, "h:mmtt")# </cfif>
		<cfelse>
			<cfif qArticle.blog_hide_time EQ 0 and qArticle.blog_event EQ 1> to #timeformat(qArticle.blog_end_datetime, "h:mmtt")# </cfif>
		</cfif>
	</cfif>
	</span><br />
	<hr /></div>
	
	<cfsavecontent variable="theImageOutputHTML">
	<cfscript> 
	ts =structnew();
	ts.image_library_id=qArticle.blog_image_library_id;
	ts.size="#request.zos.globals.maximagewidth#x2000";
	ts.crop=0; 
	ts.offset=0; 
	ts.top=true;
	if(qArticle.blog_image_library_layout EQ 7 or qArticle.blog_image_library_layout EQ 9){
		ts.limit=1;
	}
	ts.layoutType=application.zcore.imageLibraryCom.getLayoutType(qArticle.blog_image_library_layout); 
	application.zcore.imageLibraryCom.displayImages(ts); 
	</cfscript>
	</cfsavecontent>
	<cfscript> 
	if(not application.zcore.imageLibraryCom.isBottomLayoutType(qArticle.blog_image_library_layout) or application.zcore.imageLibraryCom.isAlwaysDisplayedLayoutType(qArticle.blog_image_library_layout)){
		echo(theImageOutputHTML);
	}
	</cfscript> 
	
	<cfif isDefined('request.zos.supressBlogArticleDetails')>
		<cfscript>
		tempText=qArticle.blog_story;
		writeoutput(replace(tempText,"##zbeginlistings","#tempCurrentBlogUrl###zbeginlistings","ALL"));
		</cfscript>
	<cfelse>
		#qArticle.blog_story#
	</cfif>
	<cfscript>
	
	if(qArticle.blog_image_library_layout EQ 7 or qArticle.blog_image_library_layout EQ 9){
		savecontent variable="theImageOutputHTML"{
			ts =structnew();
			ts.image_library_id=qArticle.blog_image_library_id;
			ts.size="#request.zos.globals.maximagewidth#x2000";
			ts.crop=0;  
			ts.offset=1;
			ts.layoutType=application.zcore.imageLibraryCom.getLayoutType(qArticle.blog_image_library_layout);
			application.zcore.imageLibraryCom.displayImages(ts);
		}
	}
	if(application.zcore.imageLibraryCom.isBottomLayoutType(qArticle.blog_image_library_layout) or application.zcore.imageLibraryCom.isAlwaysDisplayedLayoutType(qArticle.blog_image_library_layout)){
		echo(theImageOutputHTML);
	}

	if(application.zcore.app.siteHasApp("listing") and qArticle.blog_search_mls EQ 1){
		if(not structkeyexists(request.zos, 'supressBlogArticleDetails') or request.zos.supressBlogArticleDetails NEQ 1){
			application.zcore.listingStruct.functions.zListingDisplaySavedSearch(qArticle.mls_saved_search_id); 
		}
	} 
	</cfscript>
	<cfif isDefined('request.zos.supressBlogArticleDetails') and request.zos.supressBlogArticleDetails EQ 1>
		<h2><a href="#tempCurrentBlogUrl###addC">Leave a comment</a></h2>
		<hr />
	<cfelse>
		<hr />
		<h3>Bookmark &amp; Share</h3>
		#application.zcore.template.getShareButton("font-size:100%;",true)#<br style="clear:both;" />
		
		<hr />
		<cfif application.zcore.functions.zIsExternalCommentsEnabled()>
		<cfscript>
		// display external comments
		writeoutput(application.zcore.functions.zDisplayExternalComments(application.zcore.app.getAppData("blog").optionstruct.app_x_site_id&"-"&qArticle.blog_id, qArticle.blog_title, request.zos.globals.domain&currentBlogURL));
		</cfscript>
		<cfelseif application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionstruct,'blog_config_disable_comments',false,0) EQ 0>
		
		<h2><a id="comment"></a>User Comments</h2>
		<cfset noComments=true>
		<cfloop query="qComments">
			<cfif qComments.blog_comment_approved eq 1>
				<cfset noComments=false>
				<div class="rss-comments-box">
				<div class="rss-comments-subject">#htmleditformat(qComments.blog_comment_title)#</div>
				<div class="rss-comments-text">
				#htmleditformat(qComments.blog_comment_text)#
				</div>
				<div class="rss-comments-posted">Author: #application.zcore.functions.zEncodeEmail(qComments.blog_comment_author_email,true,qComments.blog_comment_author,true,false)#  on #dateformat(qComments.blog_comment_datetime, 'ddd, mmm dd, yyyy')# at #timeformat(qComments.blog_comment_datetime, 'h:mmtt')#  
				</div></div>
			</cfif>
		</cfloop>
    
    
		<cfif noComments>
			<br style="clear:both;" />
			<strong>Be the first to comment on this news release below!</strong><br />
			</cfif>
			<a id="addC"></a>
			<cfscript>
			application.zcore.functions.zStatusHandler(request.zsid,true);
			</cfscript>
			<div style="width:100%; float:left "><hr />
			<cfscript>
			form.set9=application.zcore.functions.zGetHumanFieldIndex();
			</cfscript> 
			<div style="width:100%; float:left; line-height:130%; padding-bottom:10px;font-size:130%;"><a href="##" onclick="document.getElementById('blogCommentForm').style.display='block'; return false;">Add A Comment</a></div>
			<div style="width:100%; float:left; display:none;" id="blogCommentForm">
			<form action="/z/blog/blog/addComment?blog_id=#qArticle.blog_id#" method="post" onsubmit="zSet9('zset9_#form.set9#');" name="myForm99">
			<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
			#application.zcore.functions.zFakeFormFields()#
			<table style="width:100%;"> 
			<tr>
			<td style="white-space: nowrap;">Your Name: <span style="color:##FF0000; font-weight:bold"> *</span></td>
			<td style="width:90%;"><input type="text" name="blog_comment_author" value="<cfif isDefined('request.zsession.blog_comment_author')>#htmleditformat(request.zsession.blog_comment_author)#<cfelse>#htmleditformat(application.zcore.functions.zso(form,'blog_comment_author'))#</cfif>"  style="width:96%;" /></td>
			</tr>
			<tr>
			<td style="white-space: nowrap;">Your Email: <span style="color:##FF0000; font-weight:bold"> *</span></td>
			<td style="width:90%;"><input type="text" name="blog_comment_author_email" value="<cfif isDefined('request.zsession.blog_comment_author_email')>#htmleditformat(request.zsession.blog_comment_author_email)#<cfelse>#htmleditformat(application.zcore.functions.zso(form,'blog_comment_author_email'))#</cfif>" style="width:96%;" maxlength="50" /></td>
			</tr>
			<tr>
			<td style="white-space: nowrap;">Subject: </td>
			<td style="width:90%;"><input type="text" name="blog_comment_title" value="#htmleditformat(application.zcore.functions.zso(form,'blog_comment_title'))#" style="width:96%;" maxlength="100" /></td>
			</tr>
			<tr>
			<td style="white-space: nowrap;vertical-align:top; ">Comments: <span style="color:##FF0000; font-weight:bold"> *</span></td>
			<td style="width:90%;">
			<textarea name="blog_comment_text"  style="width:97%; height:200px;" onkeydown="textCounter(document.myForm99.blog_comment_text,document.myForm99.remLen2,1000)" 
			onkeyup="textCounter(document.myForm99.blog_comment_text,document.myForm99.remLen2,1000)">#htmleditformat(application.zcore.functions.zso(form,'blog_comment_text'))#</textarea><br />
			<input readonly="readonly" type="text" name="remLen2" size="3" maxlength="3" value="1000" /> characters left
			</td>
			</tr>

			<cfif application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1>
			
				<tr>
					<td style="vertical-align:top; ">&nbsp;</td>
					<td>#application.zcore.functions.zDisplayRecaptcha()#</td>
				</tr>
			</cfif>
			<tr>
			<td style="white-space: nowrap;">&nbsp;<input type="hidden" name="blog_id" value="#htmleditformat(form.blog_id)#" /></td>
			<td style="width:90%;"><input type="submit" value="Add Comment" /></td>
			</tr>
			</table>
			</form>
			</div>
			</div>
			<br style="clear:both;" />
		</cfif>

		<cfif qArticle.blog_category_name NEQ "" or qRelated.recordcount NEQ 0>
			<div class="zblog-relatedarticles">
				<hr />
				<h3>Related Articles</h3>
				<ul>
				<cfloop query="qRelated">
					<li><a class="#application.zcore.functions.zGetLinkClasses()#" href="<cfif qRelated.blog_unique_name NEQ ''>#qRelated.blog_unique_name#<cfelse>#application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,qRelated.blog_id,"html",qRelated.blog_title,qRelated.blog_datetime)#</cfif>">#htmleditformat(qRelated.blog_title)#</a></li>
				</cfloop>
				<cfif qArticle.blog_category_name NEQ "">
					<li><a class="#application.zcore.functions.zGetLinkClasses()#" href="<cfif qArticle.blog_category_unique_name NEQ ''>#qArticle.blog_category_unique_name#<cfelse>#application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id,qArticle.blog_category_id,"html",qArticle.blog_category_name)#</cfif>">View more articles in the #htmleditformat(qArticle.blog_category_name)# category</a></li>
				</cfif>
				</ul>
			</div>
		</cfif>
		<cfsavecontent variable="db.sql">
		select * from #db.table("blog", request.zos.zcoreDatasource)# blog where blog_id <> #db.param(qArticle.blog_id)# and  
		site_id=#db.param(request.zos.globals.id)# and 
		(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
			blog_event =#db.param(1)#) and 
		blog_status <> #db.param(2)# and 
		blog_views <> #db.param(0)# and
		blog_deleted = #db.param(0)# 
		order by <!--- blog_views desc --->
		blog_views-((DATE_FORMAT(NOW(), #db.param('%Y%m%d')#)-DATE_FORMAT(blog_datetime, #db.param('%Y%m%d')#))*#db.param(randrange(5,30)/100)#) DESC  
		LIMIT #db.param(0)#,#db.param(10)#
		</cfsavecontent><cfscript>qPopular=db.execute("qPopular");</cfscript>
		<cfif qPopular.recordcount NEQ 0> 
			<div class="zblog-populararticles">
				<h3>Most Popular Articles</h3>
				<ul>
				<cfloop query="qPopular">
					<li><a class="#application.zcore.functions.zGetLinkClasses()#" href="<cfif qPopular.blog_unique_name NEQ ''>#qPopular.blog_unique_name#<cfelse>#application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,qpopular.blog_id,"html",qPopular.blog_title,qPopular.blog_datetime)#</cfif>">#htmleditformat(qPopular.blog_title)#</a><!---  (#qPopular.blog_views# page views) ---></li>
				</cfloop>
				</ul> 
			</div>
		</cfif>
		<cfscript>
		db.sql="select * from #db.table("blog", request.zos.zcoreDatasource)# blog where 
		blog_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)# and blog_id <> #db.param(form.blog_id)# and  
		blog_datetime < #db.param(dateformat(qarticle.blog_datetime,'yyyy-mm-dd')&' '&Timeformat(qarticle.blog_datetime,'HH:mm:ss'))# and 
		(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
		blog_event =#db.param(1)#) and 
		blog_status <> #db.param(2)#  
		ORDER BY blog_sticky desc, blog_datetime DESC LIMIT #db.param(0)#,#db.param(1)# ";
		query=db.execute("query");
		</cfscript>


		<div class="zblog-articlepagenav">
			<cfif query.recordcount NEQ 0 and isdate(query.blog_datetime)>
				<cfset theLink =application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,query.blog_id,"html",query.blog_title,query.blog_datetime)>
				<p>Previous Article: <a class="#application.zcore.functions.zGetLinkClasses()#" href="#theLink#">#htmleditformat(query.blog_title)#</a></p>
			</cfif>
			<cfscript>
			nextMonth=dateformat(dateadd("m",1,curDate),'yyyy-mm-01')&' 00:00:00';
			db.sql="select * from #db.table("blog", request.zos.zcoreDatasource)# blog where 
			blog_deleted = #db.param(0)# and
			site_id=#db.param(request.zos.globals.id)# and blog_id <> #db.param(form.blog_id)# and  
			blog_datetime > #db.param(dateformat(qarticle.blog_datetime,'yyyy-mm-dd')&' '&Timeformat(qarticle.blog_datetime,'HH:mm:ss'))# 
			ORDER BY blog_sticky asc, blog_datetime ASC 
			LIMIT #db.param(0)#,#db.param(1)# ";
			query=db.execute("query");
			</cfscript>
			<cfif query.recordcount NEQ 0>
				<cfset theLink =application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,query.blog_id,"html",query.blog_title,query.blog_datetime)>
				<p>Next Article: <a class="#application.zcore.functions.zGetLinkClasses()#" href="#theLink#">#htmleditformat(query.blog_title)#</a></p>
			</cfif>
		</div>
	</cfif> 
	#application.zcore.app.getAppCFC("blog").getPopularTags()#
</cffunction>

<cffunction name="getThumbnailSizeStruct" localmode="modern" access="private">
	<cfscript>
	thumbnailStruct={};
	thumbnailStruct.width=application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionstruct, 'blog_config_thumbnail_width', true, 0);
	thumbnailStruct.height=application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionstruct, 'blog_config_thumbnail_height', true, 0);
	thumbnailStruct.crop=application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionstruct, 'blog_config_thumbnail_crop', true, 0);
	if(thumbnailStruct.width EQ 0){
		thumbnailStruct.width=200;
		thumbnailStruct.height=140;
		thumbnailStruct.crop=1;
	}
	return thumbnailStruct;
	</cfscript>
</cffunction>

<cffunction name="articleIncludeTemplate" localmode="modern" access="public" output="yes" returntype="any">
	<cfargument name="displayStruct" type="struct" required="yes">
	<cfargument name="displayCount" type="numeric" required="yes">
	<cfargument name="futureEventsOnly" type="boolean" required="no" default="#false#" hint="Returns only future events including the current day.">
	<cfargument name="blog_category_id" type="string" required="no" default="">
	<cfargument name="exclude_blog_category_id" type="string" required="no" default=""> 
	<cfscript>
	var loadBlogArticleInclude='';
	var content='';
	var ts='';
	var ts2=0;
	var db=request.zos.queryObject;
	
	var shortSummary='';
	var qList='';
	loadBlogArticleInclude=false;
	content = 'include'; 
	if(not structkeyexists(arguments.displayStruct, 'randomize')){
		arguments.displayStruct.randomize=false;
	}
	if(structcount(application.zcore.app.getAppData("blog")) NEQ 0){
		loadBlogArticleInclude=true;
	}
	if(not structkeyexists(arguments.displayStruct, 'site_x_option_group_set_id')){
		arguments.displayStruct.site_x_option_group_set_id =0;
	}
	arguments.displayStruct.arrBlog=arraynew(1);
	
	thumbnailStruct=variables.getThumbnailSizeStruct();
	if(structkeyexists(arguments.displayStruct, 'imageSize')){
		arrSize=listToArray(arguments.displayStruct.imageSize, "x");
		if(arrayLen(arrSize) NEQ 2){
			throw("arguments.displayStruct.imageSize must be formatted like widthxheight, i.e. 150x100.");
		}
		thumbnailStruct.width=arrSize[1];
		thumbnailStruct.height=arrSize[2];
	}
	if(structkeyexists(arguments.displayStruct, 'crop')){
		thumbnailStruct.crop=arguments.displayStruct.crop;
	}
	</cfscript>
	<cfif loadBlogArticleInclude>
		<cfscript>
		if(arguments.displayStruct.randomize){ 
			db.sql="select count(blog.blog_id) count
			from #db.table("blog", request.zos.zcoreDatasource)# blog  
			left join #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category on 
			blog_x_category.blog_id = blog.blog_id and 
			blog_x_category.site_id = blog.site_id and 
			blog_x_category_deleted = #db.param(0)# 
			where blog.site_id=#db.param(request.zos.globals.id)# and 
			blog_deleted = #db.param(0)# and ";
			if(arguments.displayStruct.site_x_option_group_set_id NEQ 0){
		        db.sql&=" (blog.site_x_option_group_set_id = #db.param(arguments.displayStruct.site_x_option_group_set_id)# 
		        	or blog.blog_show_all_sections=#db.param(1)# 
					
		        ) and ";
		    }else if(structkeyexists(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_always_show_section_articles') and application.zcore.app.getAppData("blog").optionStruct.blog_config_always_show_section_articles EQ 0){
				db.sql&=" blog.site_x_option_group_set_id = #db.param(0)#  and ";
			}
			db.sql&=" (blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
			blog_event =#db.param(1)#) and ";
			if(arguments.blog_category_id NEQ "" and arguments.blog_category_id NEQ "0"){
				arrId=listToArray(arguments.blog_category_id, ",");
				for(i=1;i LTE arraylen(arrId);i++){
					arrId[i]="'"&application.zcore.functions.zescape(arrId[i])&"'";
				}
				db.sql&=" blog_x_category.blog_category_id IN (#db.trustedSQL(arrayToList(arrId, ","))#)  and ";
			}
			if(arguments.exclude_blog_category_id NEQ "" and arguments.exclude_blog_category_id NEQ "0"){
				arrId=listToArray(arguments.exclude_blog_category_id, ",");
				for(i=1;i LTE arraylen(arrId);i++){
					arrId[i]="'"&application.zcore.functions.zescape(arrId[i])&"'";
				}
				db.sql&=" blog_x_category.blog_category_id NOT IN (#db.trustedSQL(arrayToList(arrId, ","))#) and ";
			}
			if(arguments.futureEventsOnly){
				db.sql&="  blog_end_datetime >= #db.param(dateformat(now(),'yyyy-mm-dd')&' 00:00:00')#  and 
				blog_event =#db.param(1)# and ";
			}
			db.sql&=" blog_status <> #db.param(2)#  
			 ";
			qCount=db.execute("qCount");
		}
		// you must have a group by in your query or it may miss rows
		ts=structnew();
		ts.image_library_id_field="blog.blog_image_library_id";
		ts.count =  1; // how many images to get
		rs=application.zcore.imageLibraryCom.getImageSQL(ts);
		db.sql="select *, count(blog_comment.blog_comment_id) as commentCount 
		#db.trustedsql(rs.select)#  
		from #db.table("blog", request.zos.zcoreDatasource)# blog 
		#db.trustedsql(rs.leftJoin)#
		left join #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category on 
		blog_x_category.blog_id = blog.blog_id and 
		blog_x_category.site_id = blog.site_id and 
		blog_x_category_deleted = #db.param(0)#
		left join #db.table("blog_category", request.zos.zcoreDatasource)# blog_category on 
		blog_x_category.blog_category_id = blog.blog_category_id and 
		blog_category.site_id = blog.site_id and 
		blog_category_deleted = #db.param(0)#
		left join #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment on 
		blog.blog_id = blog_comment.blog_id and 
		blog_comment_approved=#db.param(1)#  and 
		blog_comment.site_id = blog.site_id and 
		blog_comment_deleted = #db.param(0)#
		LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
		blog.user_id = user.user_id  and 
		user_deleted = #db.param(0)# and
		user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("blog.user_id_siteIDType"))#
		where blog.site_id=#db.param(request.zos.globals.id)# and 
		blog_deleted = #db.param(0)# and ";
		if(arguments.displayStruct.site_x_option_group_set_id NEQ 0){
	        db.sql&=" (blog.site_x_option_group_set_id = #db.param(arguments.displayStruct.site_x_option_group_set_id)# 
	        	or blog.blog_show_all_sections=#db.param(1)# 
				
	        ) and ";
	    }else if(structkeyexists(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_always_show_section_articles') and application.zcore.app.getAppData("blog").optionStruct.blog_config_always_show_section_articles EQ 0){
			db.sql&=" blog.site_x_option_group_set_id = #db.param(0)#  and ";
		}
		db.sql&=" (blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
		blog_event =#db.param(1)#) and ";
		if(arguments.blog_category_id NEQ "" and arguments.blog_category_id NEQ "0"){
			arrId=listToArray(arguments.blog_category_id, ",");
			for(i=1;i LTE arraylen(arrId);i++){
				arrId[i]="'"&application.zcore.functions.zescape(arrId[i])&"'";
			}
			db.sql&=" blog_x_category.blog_category_id IN (#db.trustedSQL(arrayToList(arrId, ","))#)  and ";
		}
		if(arguments.exclude_blog_category_id NEQ "" and arguments.exclude_blog_category_id NEQ "0"){
			arrId=listToArray(arguments.exclude_blog_category_id, ",");
			for(i=1;i LTE arraylen(arrId);i++){
				arrId[i]="'"&application.zcore.functions.zescape(arrId[i])&"'";
			}
			db.sql&=" blog_x_category.blog_category_id NOT IN (#db.trustedSQL(arrayToList(arrId, ","))#) and ";
		}
		if(arguments.futureEventsOnly){
			db.sql&="  blog_end_datetime >= #db.param(dateformat(now(),'yyyy-mm-dd')&' 00:00:00')#  and 
			blog_event =#db.param(1)# and ";
		}
		if(arguments.displayStruct.randomize){
			startId=randrange(1, qCount.count-arguments.displayCount);
			db.sql&=" blog.blog_id >=#db.param(startId)# and ";
		}
		db.sql&=" blog_status <> #db.param(2)#  
		group by blog.blog_id ";
		if(not arguments.displayStruct.randomize){ 
			if(arguments.futureEventsOnly){
				db.sql&=" order by blog_datetime asc";
			}else{
				db.sql&=" order by blog_sticky desc, blog_datetime desc";
			}
		}
		db.sql&=" LIMIT #db.param(0)#,#db.param(arguments.displayCount)#";
		qList=db.execute("qList");
		

		processArticleIncludeQuery(qList, arguments.displayStruct);
		</cfscript>
	</cfif>
</cffunction>



<cffunction name="getArticleByUniqueURL" localmode="modern" access="public" output="yes" returntype="any">
	<cfargument name="link" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	// you must have a group by in your query or it may miss rows
	ts=structnew();
	ts.image_library_id_field="blog.blog_image_library_id";
	ts.count =  1; // how many images to get
	rs=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="select *, count(blog_comment.blog_comment_id) as commentCount 
	#db.trustedsql(rs.select)#  
	from #db.table("blog", request.zos.zcoreDatasource)# blog 
	#db.trustedsql(rs.leftJoin)#
	left join #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category on 
	blog_x_category.blog_id = blog.blog_id and 
	blog_x_category.site_id = blog.site_id and 
	blog_x_category_deleted = #db.param(0)#
	left join #db.table("blog_category", request.zos.zcoreDatasource)# blog_category on 
	blog_x_category.blog_category_id = blog.blog_category_id and 
	blog_category.site_id = blog.site_id and 
	blog_category_deleted = #db.param(0)#
	left join #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment on 
	blog.blog_id = blog_comment.blog_id and 
	blog_comment_approved=#db.param(1)#  and 
	blog_comment.site_id = blog.site_id and 
	blog_comment_deleted = #db.param(0)#
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	blog.user_id = user.user_id  and 
	user_deleted = #db.param(0)# and
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("blog.user_id_siteIDType"))#
	where blog.site_id=#db.param(request.zos.globals.id)# and 
	blog_deleted = #db.param(0)# and 
	blog.blog_unique_name = #db.param(arguments.link)# and
	(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
	blog_event =#db.param(1)#) and 
	blog_status <> #db.param(2)#  
	group by blog.blog_id";
	qList=db.execute("qList");
	displayStruct={arrBlog:[]};
	processArticleIncludeQuery(qList, displayStruct);
	if(qList.recordcount NEQ 0){
		return displayStruct.arrBlog[1];
	}else{
		return {};
	} 
	</cfscript>
</cffunction>


<cffunction name="getArticleById" localmode="modern" access="public" output="yes" returntype="any">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	// you must have a group by in your query or it may miss rows
	ts=structnew();
	ts.image_library_id_field="blog.blog_image_library_id";
	ts.count =  1; // how many images to get
	rs=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="select *, count(blog_comment.blog_comment_id) as commentCount 
	#db.trustedsql(rs.select)#  
	from #db.table("blog", request.zos.zcoreDatasource)# blog 
	#db.trustedsql(rs.leftJoin)#
	left join #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category on 
	blog_x_category.blog_id = blog.blog_id and 
	blog_x_category.site_id = blog.site_id and 
	blog_x_category_deleted = #db.param(0)#
	left join #db.table("blog_category", request.zos.zcoreDatasource)# blog_category on 
	blog_x_category.blog_category_id = blog.blog_category_id and 
	blog_category.site_id = blog.site_id and 
	blog_category_deleted = #db.param(0)#
	left join #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment on 
	blog.blog_id = blog_comment.blog_id and 
	blog_comment_approved=#db.param(1)#  and 
	blog_comment.site_id = blog.site_id and 
	blog_comment_deleted = #db.param(0)#
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	blog.user_id = user.user_id  and 
	user_deleted = #db.param(0)# and
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("blog.user_id_siteIDType"))#
	where blog.site_id=#db.param(request.zos.globals.id)# and 
	blog_deleted = #db.param(0)# and ";
	if(arguments.id CONTAINS "-"){
		db.sql&=" blog.blog_guid = #db.param(arguments.id)# and ";
	}else{
		db.sql&=" blog.blog_id = #db.param(arguments.id)# and ";
	}
	db.sql&=" (blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
	blog_event =#db.param(1)#) and 
	blog_status <> #db.param(2)#  
	group by blog.blog_id";
	qList=db.execute("qList");
	displayStruct={arrBlog:[]};
	processArticleIncludeQuery(qList, displayStruct);
	if(qList.recordcount NEQ 0){
		return displayStruct.arrBlog[1];
	}else{
		return {};
	} 
	</cfscript>
</cffunction>

<cffunction name="processArticleIncludeQuery" localmode="modern" access="private" returntype="any">
	<cfargument name="q" type="query" required="yes">
	<cfargument name="displayStruct" type="struct" required="yes">
	<cfscript>
	qList=arguments.q;
	thumbnailStruct=variables.getThumbnailSizeStruct();
	if(structkeyexists(arguments.displayStruct, 'imageSize')){
		arrSize=listToArray(arguments.displayStruct.imageSize, "x");
		if(arrayLen(arrSize) NEQ 2){
			throw("arguments.displayStruct.imageSize must be formatted like widthxheight, i.e. 150x100.");
		}
		thumbnailStruct.width=arrSize[1];
		thumbnailStruct.height=arrSize[2];
	}
	if(structkeyexists(arguments.displayStruct, 'crop')){
		thumbnailStruct.crop=arguments.displayStruct.crop;
	}
	</cfscript>
	<cfloop query="qList">
	
		<cfscript>
		ts=StructNew();
		ts.id=qList.blog_id;
		ts.guid=qList.blog_guid;
		if(qList.blog_unique_name NEQ ""){
			ts.link=qList.blog_unique_name;
		}else{
			ts.link=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,qList.blog_id,"html",qList.blog_title,qList.blog_datetime);
		}
		ts.commentLink=ts.link&"##comment";
		ts.commentCount=qList.commentCount;
		shortSummary=rereplace(qList.blog_story,"<[^>]*>"," ","ALL");
		shortSummary=application.zcore.functions.zLimitStringLength(shortSummary,350); 
		ts.fullStory=qList.blog_story;
		ts.story=shortSummary;
		ts.summary=qList.blog_summary;
		ts.title=qList.blog_title;
		ts.category=qList.blog_category_name;
		if(qList.blog_category_unique_name NEQ ""){
			ts.categoryLink=qList.blog_category_unique_name;
		}else{
			ts.categoryLink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id,qList.blog_category_id,"html",qList.blog_category_name);
		}
		ts.author=qList.user_first_name&" "&qList.user_last_name;
		ts.authorEmail=qList.user_username;
		ts.datetime=qList.blog_datetime;
		if(qList.blog_end_datetime NEQ "0000-00-00 00:00:00" and qList.blog_end_datetime NEQ ""){
			ts.endDatetime=qList.blog_end_datetime;
		}else{
			ts.endDatetime=qList.blog_datetime;
		}
		
		
		ts2=structnew();
		ts2.image_library_id=qList.blog_image_library_id;
		ts2.output=false;
		ts2.query=qList;
		ts2.row=qList.currentrow;
		ts2.size=thumbnailStruct.width&"x"&thumbnailStruct.height;
		ts2.crop=thumbnailStruct.crop;
		ts2.count = 1;  
		arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts2);
		ts.image=request.zos.currentHostName&"/z/a/images/s.gif";
		ts.hasImage=false;
		if(arraylen(arrImages) NEQ 0){
			ts.hasImage=true;
			ts.image=request.zos.currentHostName&arrImages[1].link;
		} 
		arrayappend(arguments.displayStruct.arrBlog,ts);
		</cfscript>
	</cfloop>
</cffunction>

<cffunction name="getBlogCategories" localmode="modern" access="public" returntype="array">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("blog_category", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	blog_category_parent_id = #db.param(0)# and 
	blog_category_deleted = #db.param(0)#
	order by blog_category_name asc";
	qCategory=db.execute("qCategory");
	arrCategory=[];
	appData=application.zcore.app.getAppData("blog");
	for(row in qCategory){
		if(row.blog_category_unique_name NEQ ""){
			theLink=row.blog_category_unique_name;
		}else{
			theLink =getBlogLink(appData.optionStruct.blog_config_url_category_id, row.blog_category_id,"html", row.blog_category_name, '');
		}
		arrayAppend(arrCategory, {
			name: row.blog_category_name,
			link: theLink
		});
	}
	return arrCategory;
	</cfscript>
</cffunction>

<cffunction name="calendarTemplate" localmode="modern" access="public" output="yes" returntype="any">
	<cfscript>
	var browser='';
	var viewmonth='';
	var monthdays='';
	var day_of_week='';
	var curDay='';
	var start_day='';
	var prevmonth='';
	var monthspan='';
	var nextmonth='';
	
	var thisone='';
	var rightnow='';
	var db=request.zos.queryObject;
	var curDate='';
	var storyStruct='';
	var ts='';
	var d='';
	var query='';
	var curDateTemp='';
	var theLink='';
	var qd='';
	var archives='';
	var cal_month=CreateDate(year(NOW()), month(NOW()),1);
	var cal_navigation='ON';
	var cal_width='100%';
	var cal_height='90';
	var cal_fontsize='10';
	var cal_fontfamily='Arial, Helvetica, sans-serif';
	var cal_border='ON';
	var cal_bordercolor='##CCCCCC';
	var cal_header_bgcolor='white';
	var cal_header_textcolor='black';
	var cal_dayofweek_bgcolor='white';
	var cal_dayofweek_textcolor='black';
	var cal_noday_bgcolor='white';
	var cal_today_bgcolor='##99AACC';
	var cal_today_textcolor='white';
	var cal_weekday_bgcolor='white';
	var cal_weekday_textcolor='##999999';
	var cal_weekend_bgcolor='white';
	var cal_weekend_textcolor='##999999';
	</cfscript>
	<cfif structkeyexists(form, 'url') EQ false>
		<cfset form.url = '/'>
	</cfif>
	<cfif cgi.http_user_agent CONTAINS "MSIE">
		<!--- Browser is MS IE --->
		<cfset browser = "MSIE">
	<cfelseif cgi.http_user_agent CONTAINS "Mozilla">
		<!--- Browser is NN --->
		<cfset browser = "Netscape">
	<cfelse>
		<!--- Browser is unknown --->
		<cfset browser = "Other">
	</cfif>
	
	
	<!--- tag assignments --->
	<cfif structkeyexists(form, 'blog_datetime') and isdate(form.blog_datetime)>
		<cfset viewmonth = dateformat(blog_datetime,"yyyy-mm-dd")>
	<cfelseif ISDEFINED("request.month") and isdate(request.month)>
		<cfset viewmonth = request.month>
	<cfelseif structkeyexists(form, "month") and isdate(form.month)>
		<cfset viewmonth = form.month>
	<cfelse>
		<cfset viewmonth = cal_month>
	</cfif>
	
	<cfset monthdays = daysinmonth(viewmonth)>
	<cfset day_of_week = 1>
	<cfset curDay = 1>
	<cfset start_day = dayofweek(createdate(year(viewmonth), month(viewmonth), 1))>
	<!--- end of tag assignments --->
	<cfif structkeyexists(form, 'blog_id')>
		<cfsavecontent variable="db.sql">
		select blog_datetime from #db.table("blog", request.zos.zcoreDatasource)# blog
		where blog_id = #db.param(form.blog_id)# 
		<cfif structkeyexists(form, 'preview') EQ false> 
			 and (blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
				blog_event =#db.param(1)#) and 
			blog_status <> #db.param(2)# 
		</cfif>  and 
		blog.site_id = #db.param(request.zos.globals.id)# and 
		blog_deleted = #db.param(0)#
		</cfsavecontent><cfscript>qd=db.execute("qd");
		if(qd.recordcount NEQ 0){
			curDate=dateformat(qd.blog_datetime,'yyyy-mm-01 00:00:00');
		}else{
			curDate=dateformat(now(),'yyyy-mm-01 00:00:00');
		}
		</cfscript>
	<cfelse>
		<cfscript>
		if(structkeyexists(form, 'archive')){
			curDate=dateformat(form.archive,'yyyy-mm')&'-01 00:00:00';
		}else{
			curDate=dateformat(now(),'yyyy-mm-01 00:00:00');
		}
		</cfscript>
	</cfif>
	<cfsavecontent variable="db.sql">
	select *, count(blog.blog_id) as count from #db.table("blog", request.zos.zcoreDatasource)# blog
	where blog_datetime between #db.param(dateformat(viewmonth, 'yyyy-mm'&'-01 00:00:00'))# and 
	#db.param(dateformat(viewmonth, 'yyyy-mm-'&monthdays&' 23:59:59'))# and 
	site_id=#db.param(request.zos.globals.id)# and 
	blog_deleted = #db.param(0)#
	group by date_format(blog_datetime, #db.param("%Y-%m-%d")#)
	</cfsavecontent><cfscript>archives=db.execute("archives");
	storyStruct=structNew();
	</cfscript>
	<cfloop query="archives">
		<cfscript>
		ts=structnew();
		ts.count=archives.count;
		ts.uniqueName=archives.blog_unique_name;
		ts.id=archives.blog_id;
		ts.title=archives.blog_title;
		ts.datetime=archives.blog_datetime;
		d=dateformat(archives.blog_datetime, 'yyyy-mm-dd');
		storyStruct[d]=ts;
		</cfscript>
	</cfloop>
	<!--- start display of calendar --->
	<table style="border:none; width:#cal_width#px; height:#cal_height#px;">
	<tr>
	<td>
		<table style="width:100%; border-spacing:1px; background-color:#cal_bordercolor#; text-align:center; font-family:Arial, Helvetica, sans-serif; font-size:10px; font-weight:bold;" class="rss-calendar" >
		<tr style="vertical-align:top;">
		
		<cfif cal_navigation is "ON">
			<td  style="background-color: #cal_header_bgcolor#; color: #cal_header_textcolor#;  text-align:center; ">
			<cfscript>
			db.sql="select blog_datetime from #db.table("blog", request.zos.zcoreDatasource)# blog where 
			blog_deleted = #db.param(0)# and 
			site_id=#db.param(request.zos.globals.id)# and 
			(blog_datetime<#db.param(dateformat(curdate,'yyyy-mm-dd')&' '&timeformat(curdate,'HH:mm:ss'))# or 
				blog_event =#db.param(1)#) and blog_status <> #db.param(2)#  
			ORDER BY blog_datetime DESC LIMIT #db.param(0)#,#db.param(1)# ";
			query = db.execute("query");
			</cfscript>
			<cfif query.recordcount NEQ 0 and isdate(query.blog_datetime)>
				<cfset prevmonth = '/#application.zcore.app.getAppData("blog").optionStruct.blog_config_archive_name#-#dateformat(query.blog_datetime, "yyyy-mm")#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-2.html'>
				<a href="#prevmonth#" style="color:#cal_header_textcolor#;">&lt;&lt;</a>
			</cfif>
			</td>
			<cfset monthspan = 5>
		<cfelse>
			<cfset monthspan = 7>
		</cfif>
		<!--- this header displays current month --->
		<th colspan="#monthspan#" style="background-color: #cal_header_bgcolor#; color: #cal_header_textcolor#;">
		<strong>#monthasstring(month(viewmonth))# #year(viewmonth)#</strong>
		</th>
		<cfif cal_navigation is "ON">
			<td style="background-color: #cal_header_bgcolor#; color: #cal_header_textcolor#; text-align:center; ">
			<cfscript>
			try{
			nextMonth=dateformat(dateadd("m",1,curDate),'yyyy-mm-01')&' 00:00:00';
			}catch(Any excpt){
			application.zcore.functions.z301redirect('/');	
			}
			db.sql="select blog_datetime from #db.table("blog", request.zos.zcoreDatasource)# blog where 
			site_id=#db.param(request.zos.globals.id)# and 
			blog_deleted = #db.param(0)# and
			blog_datetime >= #db.param(nextMonth)# and 
			(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
				blog_event =#db.param(1)#) and blog_status <> #db.param(2)#  
			ORDER BY blog_datetime ASC LIMIT #db.param(0)#,#db.param(1)# ";
			query = db.execute("query");
			
			
			</cfscript>
			<cfif query.recordcount NEQ 0>
				<cfset nextmonth = '/#application.zcore.app.getAppData("blog").optionStruct.blog_config_archive_name#-#dateformat(query.blog_datetime, "yyyy-mm")#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-2.html'>
				<a href="#nextmonth#" style="color:#cal_header_textcolor#;">&gt;&gt;</a>
			</cfif>
			</td>
		</cfif>
		</tr>
		<tr style="vertical-align:top;"><th style="background-color: #cal_dayofweek_bgcolor#; color: #cal_dayofweek_textcolor#;"><!--- Sunday ---><strong>S</strong></th>
		<th style="background-color: #cal_dayofweek_bgcolor#; color: #cal_dayofweek_textcolor#;"><!--- Monday ---><strong>M</strong></th>
		<th style="background-color: #cal_dayofweek_bgcolor#; color: #cal_dayofweek_textcolor#;"><!--- Tuesday ---><strong>T</strong></th>
		<th style="background-color: #cal_dayofweek_bgcolor#; color: #cal_dayofweek_textcolor#;"><!--- Wednesday ---><strong>W</strong></th>
		<th style="background-color: #cal_dayofweek_bgcolor#; color: #cal_dayofweek_textcolor#;"><!--- Thursday ---><strong>T</strong></th>
		<th style="background-color: #cal_dayofweek_bgcolor#; color: #cal_dayofweek_textcolor#;"><!--- Friday ---><strong>F</strong></th>
		<th style="background-color: #cal_dayofweek_bgcolor#; color: #cal_dayofweek_textcolor#;"><!--- Saturday ---><strong>S</strong></th>
		</tr>
		
		<cfloop condition="curDay lte monthdays">
			<!--- 1 through end of month ---><tr style="vertical-align:top;">
			<cfloop condition="day_of_week lte 7">
				<cfloop condition="start_day neq 1">
					<cfif browser IS "MSIE"><td style="background-color: #cal_noday_bgcolor#; font-size: #cal_fontsize#px;">&nbsp;</td><!--- if this day is a noday at beginning of month --->
					<cfelse><td style="background-color: #cal_noday_bgcolor#; font-size: #cal_fontsize#px;">&nbsp;</td><!--- if this day is a noday at beginning of month --->
					</cfif>
					<cfset start_day = start_day - 1>
					<cfset day_of_week = day_of_week + 1>
				</cfloop>
				<cfscript>
				curDateTemp=dateadd("d",curDay-1,curDate);
				</cfscript>
				<cfif curDay lte monthdays>
					<cfset thisone = #dateformat(curDateTemp, "mm-dd-yyyy")#>
					<cfset rightnow = #dateformat(now(), "mm-dd-yyyy")#><td <cfif thisone NEQ rightnow><cfif day_of_week is 1 or day_of_week is 7><!--- weekend --->style="background-color: #cal_weekend_bgcolor#; color: #cal_weekend_textcolor#;"<cfelse><!--- weekday ---> style="background-color: #cal_weekday_bgcolor#; color: #cal_weekday_textcolor#;"</cfif> <cfelse>style="background-color: #cal_today_bgcolor#; color: #cal_today_textcolor#;"</cfif>><cfscript>
					d=dateformat(curDateTemp, 'yyyy-mm-dd');
					if(structkeyexists(storyStruct, d)){
						if(storyStruct[d].count GT 1){
							// link to archive for the selected day
							theLink="/#application.zcore.app.getAppData("blog").optionStruct.blog_config_archive_name#-#dateformat(curDate, 'yyyy-mm')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-2.html##"&numberformat(curDay, '00');
						}else{
							// link to article
							if(storyStruct[d].uniqueName NEQ ""){
							theLink=storyStruct[d].uniqueName;
							}else{
								theLink =application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,storyStruct[d].id,"html",storyStruct[d].title,storyStruct[d].datetime);
							}
						}
						writeoutput('<strong><a class="#application.zcore.functions.zGetLinkClasses()#" href="#theLink#" style="color:#cal_header_textcolor#;">#curDay#</a></strong>');
					}else{
						writeoutput('#curDay#');
					}
					</cfscript></td><cfset curDay = curDay + 1>
				<cfelse>
					<cfif browser IS "MSIE"><td style="background-color: #cal_noday_bgcolor#; font-size: #cal_fontsize#px;">&nbsp;</td><!--- if this day is a noday at end of month --->
					<cfelse><td style="background-color: #cal_noday_bgcolor#; font-size: #cal_fontsize#px;">&nbsp;</td><!--- if this day is a noday at end of month --->
					</cfif>
				</cfif>
				<cfset day_of_week = day_of_week + 1>
			</cfloop>
			<cfset day_of_week = 1></tr>
		</cfloop></table>
	</td></tr>
	</table>
</cffunction>


<cffunction name="categoryTemplate" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	db=request.zos.queryObject;
	init();

	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0);

	request.month=CreateDate(year(now()),month(now()),1);
	if(application.zcore.functions.zso(form, 'ListID') EQ ''){ 
		form.ListId = application.zcore.status.getNewId(); 
	} 
	if(structkeyexists(form, 'zIndex')){ 
		application.zcore.status.setField(form.ListID,'zIndex',form.zIndex); 
	}
	if(application.zcore.functions.zso(form, 'zIndex') GT 100 or structkeyexists(form,'blog_category_id') EQ false){
		application.zcore.functions.z404("form.blog_category_id was not defined or zIndex was greater then 100.");//301redirect('/'); 
	}
	// required 
	searchStruct = StructNew(); 
	// optional 
	searchStruct.showString = "Articles "; 
	// allows custom url formatting 
	//searchStruct.parseURLVariables = true; 
	searchStruct.indexName = 'zIndex'; 
	searchStruct.buttons = 7; 
	// set from query string or default value 
	searchStruct.parseURLVariables=true;
	searchStruct.firstPageHack=true;
	searchStruct.perpage = 10;	
	//searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	searchStruct.index = application.zcore.status.getField(form.listId, "zIndex",1); 
	start = searchStruct.perpage * max(1,searchStruct.index) - 10;
	
	db.sql="select * 
	from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
	where blog_category.blog_category_id = #db.param(form.blog_category_id)# and 
	blog_category.site_id=#db.param(request.zos.globals.id)# and 
	blog_category_deleted = #db.param(0)#";
	qCategory=db.execute("qCategory"); 
	if(qCategory.recordcount eq 0){
		application.zcore.functions.z404("qCategory record was missing in categoryTemplate().");//301Redirect('/');
	}
	
	ts=structnew();
	ts.image_library_id_field="blog.blog_image_library_id";
	ts.count = 1; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="select *, count(blog_comment.blog_comment_id) as commentCount
	#db.trustedsql(rs2.select)# 
	from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category
	left join #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category on 
	blog_x_category.blog_category_id = blog_category.blog_category_id  and 
	blog_x_category.site_id = blog_category.site_id and 
	blog_x_category_deleted = #db.param(0)#
	left join #db.table("blog", request.zos.zcoreDatasource)# blog on 
	blog_x_category.blog_id = blog.blog_id and 
	blog_deleted = #db.param(0)# and 
	(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or blog_event =#db.param(1)#) and 
	blog_status <> #db.param(2)#  and 
	blog_category.site_id = blog.site_id
	#db.trustedsql(rs2.leftJoin)#
	left join #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment on 
	blog.blog_id = blog_comment.blog_id and 
	blog_comment_deleted = #db.param(0)# and
	blog_comment_approved=#db.param(1)# and 
	blog_comment.site_id = blog_category.site_id
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	blog.user_id = user.user_id  and 
	user_deleted = #db.param(0)# and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("blog.user_id_siteIDType"))#
	where blog_category.blog_category_id = #db.param(form.blog_category_id)# and 
	blog_category.site_id=#db.param(request.zos.globals.id)# and 
	blog_category_deleted = #db.param(0)# ";
	if(qCategory.blog_category_enable_events EQ 1){
		db.sql&=" and (blog_event=#db.param(1)# and blog_datetime>=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# )";
	}

	if(form.site_x_option_group_set_id NEQ 0){
        db.sql&="and (blog.site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# 
        	or blog.blog_show_all_sections=#db.param(1)# 
        ) ";
	}else if(structkeyexists(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_always_show_section_articles') and application.zcore.app.getAppData("blog").optionStruct.blog_config_always_show_section_articles EQ 0){
		db.sql&="and blog.site_x_option_group_set_id = #db.param(0)# ";
	}
	db.sql&=" group by blog.blog_id ";
	if(qCategory.blog_category_enable_events EQ 1){
		db.sql&=" order by blog_sticky desc, blog_datetime asc";
	}else{
		db.sql&=" order by blog_sticky desc, blog_datetime desc";
	}
	db.sql&=" LIMIT #db.param(start)#, #db.param(searchStruct.perpage)#";
	qArticles=db.execute("qArticles"); 
	if(form.method EQ "categoryTemplate"){
		if(structkeyexists(form, 'zUrlName')){
			if(qcategory.blog_category_unique_name EQ ""){
				curLink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id, form.blog_category_id,"html",qCategory.blog_category_name);
				actualLink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id, form.blog_category_id,"html",form.zUrlName);
				if(compare(curLink,actualLink) neq 0){
					application.zcore.functions.z301Redirect(curLink);
				}
			}else{
				if(compare(qcategory.blog_category_unique_name, request.zos.originalURL) NEQ 0){
					application.zcore.functions.z301Redirect(qcategory.blog_category_unique_name);
				}
			}
		}
	}
	application.zcore.siteOptionCom.setCurrentOptionAppId(qcategory.blog_category_site_option_app_id);
	db.sql="select count(*) as count from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
	left join #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category on 
	blog_x_category.blog_category_id = blog_category.blog_category_id and 
	blog_x_category.site_id = blog_category.site_id and 
	blog_x_category_deleted = #db.param(0)#
	left join #db.table("blog", request.zos.zcoreDatasource)# blog on 
	blog_x_category.blog_id = blog.blog_id and 
	blog_deleted = #db.param(0)# and 
	(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
		blog_event =#db.param(1)#) and 
	blog_status <> #db.param(2)# and 
	blog.site_id = blog_category.site_id 
	where blog_category.site_id=#db.param(request.zos.globals.id)# and 
	blog_category.blog_category_id = #db.param(form.blog_category_id)#  and 
	blog_category_deleted = #db.param(0)# and 
	blog.blog_id IS NOT NULL";
	qCount=db.execute("qCount");
	searchStruct.url = application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id, form.blog_category_id&'_##zIndex##',"html",qcategory.blog_category_name);
	if(qcategory.blog_category_unique_name NEQ ""){
		searchStruct.firstpageurl=qcategory.blog_category_unique_name;
	}else{
		searchStruct.firstpageurl=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id, form.blog_category_id,"html",qcategory.blog_category_name);
	}
	searchStruct.count = qCount.count;
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	</cfscript>
	<cfsavecontent variable="tempPageNav">
	<a href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_home_url#">#application.zcore.functions.zvar("homelinktext")#</a> / <cfif application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url EQ "{default}"><a href="/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_title,"-")#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-3.html">#application.zcore.app.getAppData("blog").optionStruct.blog_config_title#</a><cfelse><a href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url#">#application.zcore.app.getAppData("blog").optionStruct.blog_config_title#</a></cfif> /
	</cfsavecontent>
	<cfsavecontent variable="tempMenu"> 
	<cfset blog_category_name = '#qCategory.blog_category_name#'>
	#this.menuTemplate()#
	</cfsavecontent>
	<cfsavecontent variable="tempMeta">
	<cfif qCategory.blog_category_metakey NEQ ""><meta name="keywords" content="#htmleditformat(qCategory.blog_category_metakey)#" /></cfif>
	<meta name="description" content="<cfif qCategory.blog_category_metadesc NEQ "">#htmleditformat(qCategory.blog_category_metadesc)#<cfelse>#htmleditformat(application.zcore.functions.zLimitStringLength(application.zcore.functions.zStripHTMLTags(qCategory.blog_category_description), 100))#</cfif>" />
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("title","#qCategory.blog_category_name#");
	application.zcore.template.setTag("pagetitle","#qCategory.blog_category_name#");
	application.zcore.template.setTag("pagenav",tempPageNav);
	application.zcore.template.setTag("menu",tempMenu);
	application.zcore.template.setTag("meta",tempMeta);
     
	writeoutput('<div id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/blog/admin/blog-admin/categoryEdit?blog_category_id=#form.blog_category_id#&amp;return=1">');
	application.zcore.template.prependTag('pagetitle','<span id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/blog/admin/blog-admin/categoryEdit?blog_category_id=#form.blog_category_id#&amp;return=1">');
	application.zcore.template.appendTag('pagetitle','</span>'); 
	</cfscript>
	#qcategory.blog_category_description# <br style="clear:both;" />
	
	<cfscript> 
	writeoutput('</div>'); 
	</cfscript>
	<cfif application.zcore.app.getAppData("blog").optionStruct.blog_config_show_detail EQ 1> 
		<cfsavecontent variable="db.sql">
		select blog_id from #db.table("blog", request.zos.zcoreDatasource)# blog where 
		site_id=#db.param(request.zos.globals.id)# and 
		blog_category_id = #db.param(qCategory.blog_category_id)# and 
		blog_deleted = #db.param(0)#
		</cfsavecontent><cfscript>rssFeedID=db.execute("rssFeedID");</cfscript>
		<cfif rssFeedId.recordcount NEQ 0>
			<cfset form.blog_id=rssFeedID.blog_id>
			<cfset request.zos.supressBlogArticleDetails = 1>
			
			#this.articleTemplate()#
		</cfif> 
	</cfif>	
	
	
	<cfsavecontent variable="db.sql">
	SELECT *,repeat(#db.param("&nbsp;")#,blog_category_level*#db.param(3)#) catpad, count(blog_x_category.blog_id) count 
	from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
	LEFT JOIN #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category ON 
	blog_x_category.blog_category_id = blog_category.blog_category_id AND 
	blog_x_category.site_id = blog_category.site_id and 
	blog_x_category_deleted = #db.param(0)#
	where blog_category.site_id=#db.param(request.zos.globals.id)# and 
	blog_category.blog_category_parent_id = #db.param(qCategory.blog_category_id)# and 
	blog_category_deleted = #db.param(0)#
	group by blog_category.blog_category_id 
	having(count >#db.param(0)#)
	order by blog_category_sort ASC
	</cfsavecontent><cfscript>qMenu=db.execute("qMenu");</cfscript>
	<cfif qmenu.recordcount NEQ 0>
		<strong style="font-size:14px;">Additional Categories in #qCategory.blog_category_name#</strong><br />
		<br />
		 
		<div style="float:left; width:100%; padding-bottom:10px;">
		<cfscript>	
		inputStruct = StructNew();
		inputStruct.colspan = 3;
		inputStruct.rowspan = qmenu.recordcount;
		inputStruct.vertical = true;
		inputStruct.minWidth=150;
		inputStruct.divoutput=true;
		myColumnOutput = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.loopOutput");
		myColumnOutput.init(inputStruct);
		</cfscript>
		<cfloop query="qMenu">
			#myColumnOutput.check(qMenu.currentRow)#
			<a class="#application.zcore.functions.zGetLinkClasses()#" href="<cfif qmenu.blog_category_unique_name NEQ ''>#qmenu.blog_category_unique_name#<cfelse>#application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id,qmenu.blog_category_id,"html",qmenu.blog_category_name)#</cfif>" <cfif qmenu.catpad neq ''>style="font-weight:normal;"</cfif>>#qmenu.blog_category_name#</a> (#qmenu.count#)<br />
			#myColumnOutput.ifLastRow(qMenu.currentRow)#
		</cfloop>
		</div>
		<br />
	
	</cfif>  


	<cfif qArticles.recordcount NEQ 0>
		<strong style="font-size:14px;">Articles in this category:</strong><br />
		<br />
		
		<cfif qArticles.blog_title neq ''>
			<cfif searchStruct.count gt searchStruct.perpage>
				#searchNAV#
			</cfif>
			<cfloop query="qArticles">
				<cfif qArticles.blog_title NEQ ''>
				#this.summaryTemplate(qArticles)#
				</cfif>
			</cfloop>
			<cfif searchStruct.count gt searchStruct.perpage>
			#searchNAV#
			</cfif>
		<cfelse>
			<cfsavecontent variable="db.sql">
			select * 
			from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category
			where blog_category.blog_category_id = #db.param(form.blog_category_id)# and 
			blog_category.site_id=#db.param(request.zos.globals.id)# and 
			blog_category_deleted = #db.param(0)#
			limit #db.param(0)#, #db.param(5)#
			</cfsavecontent><cfscript>qCategory=db.execute("qCategory");</cfscript> 
			There are no articles in this category yet.<br /><br />
		</cfif>

		<cfif qCategory.blog_category_parent_id NEQ 0> 
		
			<cfsavecontent variable="db.sql">
			SELECT *,repeat(#db.param("&nbsp;")#,blog_category_level*#db.param(3)#) catpad
			from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
			where blog_category.site_id=#db.param(request.zos.globals.id)# and 
			blog_category_deleted = #db.param(0)# and 
			blog_category.blog_category_id = #db.param(qCategory.blog_category_parent_id)# 
			</cfsavecontent><cfscript>qMenu=db.execute("qMenu");</cfscript>
			<cfif qmenu.recordcount NEQ 0>
				<cfloop query="qMenu">
					<strong style="font-size:14px;">Read more about: <a class="#application.zcore.functions.zGetLinkClasses()#" href="<cfif qMenu.blog_category_unique_name NEQ ''>#htmleditformat(qMenu.blog_category_unique_name)#<cfelse>#htmleditformat(application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id,qMenu.blog_category_id,"html",qMenu.blog_category_name))#</cfif>" <cfif qmenu.catpad neq ''>style="font-weight:normal;"</cfif>>#htmleditformat(qMenu.blog_category_name)#</a></strong><br />
				</cfloop>
			</cfif>  
		</cfif>
	</cfif>
	<cfif application.zcore.app.siteHasApp("listing") and qcategory.blog_category_search_mls EQ 1>
		<hr />
		<cfscript>
		application.zcore.listingStruct.functions.zListingDisplaySavedSearch(qCategory.blog_category_saved_search_id); 
		</cfscript>
	</cfif> 
	#application.zcore.app.getAppCFC("blog").getPopularTags()#
</cffunction>



<!--- 
<cffunction name="categoryTemplateViewRewrite" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	db=request.zos.queryObject;
	init();

	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0);

	request.month=CreateDate(year(now()),month(now()),1);
	if(application.zcore.functions.zso(form, 'ListID') EQ ''){ 
		form.ListId = application.zcore.status.getNewId(); 
	} 
	if(structkeyexists(form, 'zIndex')){ 
		application.zcore.status.setField(form.ListID,'zIndex',form.zIndex); 
	}
	if(application.zcore.functions.zso(form, 'zIndex') GT 100 or structkeyexists(form,'blog_category_id') EQ false){
		application.zcore.functions.z404("form.blog_category_id was not defined or zIndex was greater then 100.");//301redirect('/'); 
	}
	// required 
	searchStruct = StructNew(); 
	// optional 
	searchStruct.showString = "Articles "; 
	// allows custom url formatting 
	//searchStruct.parseURLVariables = true; 
	searchStruct.indexName = 'zIndex'; 
	searchStruct.buttons = 7; 
	// set from query string or default value 
	searchStruct.parseURLVariables=true;
	searchStruct.firstPageHack=true;
	searchStruct.perpage = 10;	
	//searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	searchStruct.index = application.zcore.status.getField(form.listId, "zIndex",1); 
	start = searchStruct.perpage * max(1,searchStruct.index) - 10;
	
	db.sql="select * 
	from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
	where blog_category.blog_category_id = #db.param(form.blog_category_id)# and 
	blog_category.site_id=#db.param(request.zos.globals.id)#";
	qCategory=db.execute("qCategory"); 
	if(qCategory.recordcount eq 0){
		application.zcore.functions.z404("qCategory record was missing in categoryTemplate().");//301Redirect('/');
	}
	
	ts=structnew();
	ts.image_library_id_field="blog.blog_image_library_id";
	ts.count = 1; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="select *, count(blog_comment.blog_comment_id) as commentCount
	#db.trustedsql(rs2.select)# 
	from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category
	left join #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category on 
	blog_x_category.blog_category_id = blog_category.blog_category_id  and 
	blog_x_category.site_id = blog_category.site_id and 
	blog_x_category_deleted = #db.param(0)#
	left join #db.table("blog", request.zos.zcoreDatasource)# blog on 
	blog_x_category.blog_id = blog.blog_id and 
	blog_deleted = #db.param(0)# and 
	(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
	blog_event =#db.param(1)#) and 
	blog_status <> #db.param(2)#  and 
	blog_category.site_id = blog.site_id
	#db.trustedsql(rs2.leftJoin)#
	left join #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment on 
	blog.blog_id = blog_comment.blog_id and 
	blog_comment_deleted = #db.param(0)# and
	blog_comment_approved=#db.param(1)# and 
	blog_comment.site_id = blog_category.site_id
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	blog.user_id = user.user_id  and 
	user_deleted = #db.param(0)# and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("blog.user_id_siteIDType"))#
	where blog_category.blog_category_id = #db.param(form.blog_category_id)# and 
	blog_category.site_id=#db.param(request.zos.globals.id)# and 
	blog_category_deleted = #db.param(0)# ";

	if(form.site_x_option_group_set_id NEQ 0){
        db.sql&="and (blog.site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# 
        	or blog.blog_show_all_sections=#db.param(1)# 
        ) ";
	}else if(structkeyexists(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_always_show_section_articles') and application.zcore.app.getAppData("blog").optionStruct.blog_config_always_show_section_articles EQ 0){
		db.sql&="and blog.site_x_option_group_set_id = #db.param(0)# ";
	}
	db.sql&=" group by blog.blog_id
	order by blog_sticky desc, blog_datetime desc
	LIMIT #db.param(start)#, #db.param(searchStruct.perpage)#";
	qArticles=db.execute("qArticles"); 
	if(form.method EQ "categoryTemplate"){
		if(structkeyexists(form, 'zUrlName')){
			if(qcategory.blog_category_unique_name EQ ""){
				curLink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id, form.blog_category_id,"html",qCategory.blog_category_name);
				actualLink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id, form.blog_category_id,"html",form.zUrlName);
				if(compare(curLink,actualLink) neq 0){
					application.zcore.functions.z301Redirect(curLink);
				}
			}else{
				if(compare(qcategory.blog_category_unique_name, request.zos.originalURL) NEQ 0){
					application.zcore.functions.z301Redirect(qcategory.blog_category_unique_name);
				}
			}
		}
	}
	application.zcore.siteOptionCom.setCurrentOptionAppId(qcategory.blog_category_site_option_app_id);
	db.sql="select count(*) as count from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
	left join #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category on 
	blog_x_category.blog_category_id = blog_category.blog_category_id and 
	blog_x_category.site_id = blog_category.site_id and 
	blog_x_category_deleted = #db.param(0)#
	left join #db.table("blog", request.zos.zcoreDatasource)# blog on 
	blog_x_category.blog_id = blog.blog_id and 
	blog_deleted = #db.param(0)# and 
	(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
		blog_event =#db.param(1)#) and 
	blog_status <> #db.param(2)# and 
	blog.site_id = blog_category.site_id 
	where blog_category.site_id=#db.param(request.zos.globals.id)# and 
	blog_category.blog_category_id = #db.param(form.blog_category_id)#  and 
	blog_category_deleted = #db.param(0)# and 
	blog.blog_id IS NOT NULL";
	qCount=db.execute("qCount");
	searchStruct.url = application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id, form.blog_category_id&'_##zIndex##',"html",qcategory.blog_category_name);
	if(qcategory.blog_category_unique_name NEQ ""){
		searchStruct.firstpageurl=qcategory.blog_category_unique_name;
	}else{
		searchStruct.firstpageurl=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id, form.blog_category_id,"html",qcategory.blog_category_name);
	}
	searchStruct.count = qCount.count;
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);

	viewStruct={};

	viewStruct.homeURL=application.zcore.app.getAppData("blog").optionStruct.blog_config_home_url;
	viewStruct.homeLinkText=application.zcore.functions.zvar("homelinktext");
	if(application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url EQ "{default}"){
		viewStruct.blogURL="/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_title,"-")#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-3.html";
		viewStruct.blogLinkText=application.zcore.app.getAppData("blog").optionStruct.blog_config_title;
	}else{
		viewStruct.blogURL=application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url;
		viewStruct.blogLinkText=application.zcore.app.getAppData("blog").optionStruct.blog_config_title;
	}
	viewStruct.qCategory=qCategory;
	</cfscript>
	<cfsavecontent variable="tempPageNav">
	<a href="#viewStruct.homeURL#">#viewStruct.homeLinkText#</a> / <a href="#viewStruct.blogURL#">#viewStruct.blogLinkText#</a> /
	</cfsavecontent>
	<cfsavecontent variable="tempMenu">
	<cfset content = '#content#'>
	<cfset blog_category_name = '#qCategory.blog_category_name#'>
	#this.menuTemplate()#
	</cfsavecontent>
	<cfsavecontent variable="tempMeta">
	<cfif qCategory.blog_category_metakey NEQ ""><meta name="keywords" content="#htmleditformat(qCategory.blog_category_metakey)#" /></cfif>
	<meta name="description" content="<cfif qCategory.blog_category_metadesc NEQ "">#htmleditformat(qCategory.blog_category_metadesc)#<cfelse>#htmleditformat(application.zcore.functions.zLimitStringLength(application.zcore.functions.zStripHTMLTags(qCategory.blog_category_description), 100)#</cfif>" />
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("title","#qCategory.blog_category_name#");
	application.zcore.template.setTag("pagetitle","#qCategory.blog_category_name#");
	application.zcore.template.setTag("pagenav",tempPageNav);
	application.zcore.template.setTag("menu",tempMenu);
	application.zcore.template.setTag("meta",tempMeta);
    
	//if(structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager")){
		writeoutput('<div id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/blog/admin/blog-admin/categoryEdit?blog_category_id=#form.blog_category_id#&amp;return=1">');
		application.zcore.template.prependTag('pagetitle','<span id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/blog/admin/blog-admin/categoryEdit?blog_category_id=#form.blog_category_id#&amp;return=1">');
		application.zcore.template.appendTag('pagetitle','</span>');
	//}
	</cfscript>
	#qcategory.blog_category_description# <br style="clear:both;" />
	
	<cfscript>
	//if(structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager")){
		writeoutput('</div>');
	//}
	</cfscript>
	<cfif application.zcore.app.getAppData("blog").optionStruct.blog_config_show_detail EQ 1> 
		<cfsavecontent variable="db.sql">
		select blog_id from #db.table("blog", request.zos.zcoreDatasource)# blog where 
		site_id=#db.param(request.zos.globals.id)# and 
		blog_category_id = #db.param(qCategory.blog_category_id)# and 
		blog_deleted = #db.param(0)#
		</cfsavecontent><cfscript>rssFeedID=db.execute("rssFeedID");</cfscript>
		<cfif rssFeedId.recordcount NEQ 0>
			<cfset form.blog_id=rssFeedID.blog_id>
			<cfset request.zos.supressBlogArticleDetails = 1>
			
			#this.articleTemplate()#
		</cfif> 
	</cfif>	
	
	
	<cfsavecontent variable="db.sql">
	SELECT *,repeat(#db.param("&nbsp;")#,blog_category_level*#db.param(3)#) catpad, count(blog_x_category.blog_id) count 
	from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
	LEFT JOIN #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category ON 
	blog_x_category.blog_category_id = blog_category.blog_category_id AND 
	blog_x_category.site_id = blog_category.site_id and 
	blog_x_category_deleted = #db.param(0)#
	where blog_category.site_id=#db.param(request.zos.globals.id)# and 
	blog_category.blog_category_parent_id = #db.param(qCategory.blog_category_id)# and 
	blog_category_deleted = #db.param(0)#
	group by blog_category.blog_category_id 
	having(count >#db.param(0)#)
	order by blog_category_sort ASC
	</cfsavecontent><cfscript>qMenu=db.execute("qMenu");</cfscript>
	<cfif qmenu.recordcount NEQ 0>
		<strong style="font-size:14px;">Additional Categories in #qCategory.blog_category_name#</strong><br />
		<br />
		 
		<div style="float:left; width:100%; padding-bottom:10px;">
		<cfscript>	
		inputStruct = StructNew();
		inputStruct.colspan = 3;
		inputStruct.rowspan = qmenu.recordcount;
		inputStruct.vertical = true;
		inputStruct.minWidth=150;
		inputStruct.divoutput=true;
		myColumnOutput = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.loopOutput");
		myColumnOutput.init(inputStruct);
		</cfscript>
		<cfloop query="qMenu">
			#myColumnOutput.check(qMenu.currentRow)#
			<a class="#application.zcore.functions.zGetLinkClasses()#" href="<cfif qmenu.blog_category_unique_name NEQ ''>#qmenu.blog_category_unique_name#<cfelse>#application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id,qmenu.blog_category_id,"html",qmenu.blog_category_name)#</cfif>" <cfif qmenu.catpad neq ''>style="font-weight:normal;"</cfif>>#qmenu.blog_category_name#</a> (#qmenu.count#)<br />
			#myColumnOutput.ifLastRow(qMenu.currentRow)#
		</cfloop>
		</div>
		<br />
	
	</cfif>  


	<cfif qArticles.recordcount NEQ 0>
		<strong style="font-size:14px;">Articles in this category:</strong><br />
		<br />
		
		<cfif qArticles.blog_title neq ''>
			<cfif searchStruct.count gt searchStruct.perpage>
				#searchNAV#
			</cfif>
			<cfloop query="qArticles">
				<cfif qArticles.blog_title NEQ ''>
				#this.summaryTemplate(qArticles)#
				</cfif>
			</cfloop>
			<cfif searchStruct.count gt searchStruct.perpage>
			#searchNAV#
			</cfif>
		<cfelse>
			<cfsavecontent variable="db.sql">
			select * 
			from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category
			where blog_category.blog_category_id = #db.param(form.blog_category_id)# and 
			blog_category.site_id=#db.param(request.zos.globals.id)# and 
			blog_category_deleted = #db.param(0)#
			limit #db.param(0)#, #db.param(5)#
			</cfsavecontent><cfscript>qCategory=db.execute("qCategory");</cfscript> 
			There are no articles in this category yet.<br /><br />
		</cfif>

		<cfif qCategory.blog_category_parent_id NEQ 0> 
		
			<cfsavecontent variable="db.sql">
			SELECT *,repeat(#db.param("&nbsp;")#,blog_category_level*#db.param(3)#) catpad
			from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
			where blog_category.site_id=#db.param(request.zos.globals.id)# and 
			blog_category_deleted = #db.param(0)# and 
			blog_category.blog_category_id = #db.param(qCategory.blog_category_parent_id)# 
			</cfsavecontent><cfscript>qMenu=db.execute("qMenu");</cfscript>
			<cfif qmenu.recordcount NEQ 0>
				<cfloop query="qMenu">
					<strong style="font-size:14px;">Read more about: <a class="#application.zcore.functions.zGetLinkClasses()#" href="<cfif qMenu.blog_category_unique_name NEQ ''>#htmleditformat(qMenu.blog_category_unique_name)#<cfelse>#htmleditformat(application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id,qMenu.blog_category_id,"html",qMenu.blog_category_name))#</cfif>" <cfif qmenu.catpad neq ''>style="font-weight:normal;"</cfif>>#htmleditformat(qMenu.blog_category_name)#</a></strong><br />
				</cfloop>
			</cfif>  
		</cfif>
	</cfif>
	<cfif application.zcore.app.siteHasApp("listing") and qcategory.blog_category_search_mls EQ 1>
		<hr />
		<cfscript>
		application.zcore.listingStruct.functions.zListingDisplaySavedSearch(qCategory.blog_category_saved_search_id); 
		</cfscript>
	</cfif> 
	#application.zcore.app.getAppCFC("blog").getPopularTags()#
</cffunction>
 --->

<cffunction name="feedCategoryTemplate" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript> 
	var feedDescription='';
	var curLink='';
	var actualLink='';
	var title='';
	var blog_title='';
	var blog_author='';
	
	var blog_summary='';
	var blog_story='';
	var blog_sources='';
	var user_username='';
	var date='';
	var time='';
	var db=request.zos.queryObject;
	var tempLink='';
	var tempText='';
	var ts=0;
	var ts2=0;
	var rs2=0;
	var count='';
	var feedLink=0;
	var q_blog_feed='';
	var blog_feed='';
	variables.init();
	form.blog_category_id=application.zcore.functions.zso(form, 'blog_category_id', true, 0);
	if(form.blog_category_id EQ 0){
		application.zcore.functions.z404("Missing blog_category_id");
	}
	application.zcore.template.clearPrependAppendTagData("content");
	// set default action
	application.zcore.template.setTemplate("zcorerootmapping.templates.nothing",true,true);
	Request.zPageDebugDisabled=true;
	// you must have a group by in your query or it may miss rows
	ts=structnew();
	ts.image_library_id_field="blog.blog_image_library_id";
	ts.count = 0; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	</cfscript> 
	<cfsavecontent variable="db.sql">
	select * 
	#db.trustedsql(rs2.select)# 
	from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category
	left join #db.table("blog", request.zos.zcoreDatasource)# blog on 
	blog_category.blog_category_id = blog.blog_category_id and
	 (blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
	blog_event =#db.param(1)#) and 
	blog_status <> #db.param(2)#  and 
	blog_deleted = #db.param(0)# and
	blog.site_id = blog_category.site_id
	#db.trustedsql(rs2.leftJoin)# 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	blog.user_id = user.user_id  and 
	user_deleted = #db.param(0)# and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("blog.user_id_siteIDType"))#
	where blog_category.blog_category_id = #db.param(form.blog_category_id)# and 
	blog_category.site_id=#db.param(request.zos.globals.id)# and 
	blog_category_deleted = #db.param(0)#
	group by blog.blog_id
	order by blog_sticky desc, blog_datetime desc
	</cfsavecontent><cfscript>q_blog_feed=db.execute("q_blog_feed");
	</cfscript>
	<cfif q_blog_feed.recordcount eq 0 or NOT isDefined('q_blog_feed.blog_STORY')>
		<cfscript>
			application.zcore.functions.z301Redirect('/');
		</cfscript>
	</cfif>
	<cfscript>
	curLink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id,form.blog_category_id,"xml",q_blog_feed.blog_category_name);
	actualLink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id,form.blog_category_id,"xml",form.zUrlName);
	if(compare(curLink,actualLink) neq 0){
		application.zcore.functions.z301Redirect(curLink);
	}
	title = replace(q_blog_feed.blog_category_name, "&", "&amp;", "ALL");
	</cfscript>
	<cfsavecontent variable="feedLink">#request.zOS.currentHostName#<cfif q_blog_feed.blog_category_unique_name NEQ ''>#q_blog_feed.blog_category_unique_name#<cfelse>#application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id,q_blog_feed.blog_category_id,"html",q_blog_feed.blog_category_name)#</cfif></cfsavecontent>

	<cfsavecontent variable="blog_feed">
	<rss  version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
	<channel>
<atom:link href="#feedLink#" rel="self" type="application/rss+xml" />
	<title>#title# From #request.zos.globals.shortdomain#</title>
	<link>#feedLink#</link>
	<cfset feedDescription=application.zcore.functions.zXmlFormat('This feed is a list of stories from #request.zOS.currentHostName# in the "#q_blog_feed.blog_category_name#" category.')>
	<description>Get the latest #application.zcore.functions.zXmlFormat(q_blog_feed.blog_category_name)# from #request.zos.globals.shortdomain#</description>
	<language>en-us</language>
	<copyright>#year(now())#</copyright>
	<lastBuildDate>#gethttptimestring()#</lastBuildDate>
	<cfloop from="1" to="#q_blog_feed.recordcount#" index="count">
		<cfif q_blog_feed.blog_id[count] NEQ ''>
			<cfscript>	
			blog_title = application.zcore.functions.zXMLFormat(q_blog_feed.blog_title[count]);
			blog_author = application.zcore.functions.zXMLFormat(q_blog_feed.user_first_name[count]&" "&q_blog_feed.user_last_name[count]);
			blog_summary = q_blog_feed.blog_summary[count];
			blog_story = q_blog_feed.blog_story[count];
			blog_sources = application.zcore.functions.zXMLFormat(q_blog_feed.blog_sources[count]);
			user_username = application.zcore.functions.zXMLFormat(q_blog_feed.user_username[count]);
			date = dateformat(q_blog_feed.blog_datetime[count], "ddd, dd mmm yyyy");
			time = timeformat(q_blog_feed.blog_datetime[count], "HH:mm:ss") & " EST";
			if(q_blog_feed.blog_unique_name[count] NEQ ""){
				tempLink=request.zOS.currentHostName&application.zcore.functions.zXMLFormat(q_blog_feed.blog_unique_name[count]);
			}else{
				tempLink = request.zOS.currentHostName&application.zcore.functions.zXMLFormat(application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,q_blog_feed.blog_id[count],"html",q_blog_feed.blog_title[count],q_blog_feed.blog_datetime[count]));
			} 
			thumbnailStruct=variables.getThumbnailSizeStruct();
			ts2=structnew();
			ts2.image_library_id=q_blog_feed.blog_image_library_id[count];
			ts2.output=false;
			ts2.query=q_blog_feed;
			ts2.row=count;
			ts2.size=request.zos.globals.maximagewidth&"x2000";//thumbnailStruct.width&"x"&thumbnailStruct.height;
			ts2.crop=thumbnailStruct.crop;
			ts2.count = 1;  
			arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts2);
			image="";
			if(arraylen(arrImages) NEQ 0){
				image=arrImages[1].link;
			}  
			</cfscript>
			<item>
				<title>#blog_title#</title>
				<link>#tempLink#</link>
				<cfif image NEQ ""> 
					<enclosure url="#request.zos.currentHostName&image#" type="image/*"/>
				</cfif>
				<cfscript>
				if(blog_summary EQ ''){
					tempText = blog_story;
				/*	tempText = rereplaceNoCase(tempText,"<.*?>","","ALL");
					if(len(tempText) GT 1000){
						tempText=left(tempText,1000)&'...';
					}*/
				}else{
					tempText = blog_summary;
				//	tempText = rereplaceNoCase(tempText,"<.*?>","","ALL");
				}
				//tempText = application.zcore.functions.zXMLFormat(tempText);
				</cfscript><!--- 
				<description>#tempText#</description> --->
				<description><![CDATA[ <cfif image NEQ ""><p><img src="#image#" /></p></cfif> #tempText# ]]></description>
				<pubDate>#date# #time#</pubDate>
				<author><cfif user_username EQ "">#application.zcore.functions.zvarso("zofficeemail")#<cfelse>#user_username#</cfif><cfif blog_author NEQ ""> (#blog_author#)<cfelse> (Site Admin)</cfif></author>
				<comments>#tempLink###comments</comments>
		    <guid isPermaLink="false">#q_blog_feed.blog_guid[count]#</guid>
			</item>
		</cfif>
	</cfloop>
	</channel>
	</rss>
	</cfsavecontent>
	<cfscript>
	blog_feed=replace(blog_feed, ' href="/', ' href="#request.zos.currentHostName#/', 'all');
	blog_feed=replace(blog_feed, ' src="/', ' src="#request.zos.currentHostName#/', 'all');
	</cfscript>
	<!--- <cfcontent type="text/xml"> --->
	<cfcontent type="text/xml; utf-8">
	#blog_feed#
	<cfscript>
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>


<cffunction name="feedRecentTemplate" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	var curLink='';
	var actualLink='';
	var blog_title='';
	var blog_author='';
	var blog_summary='';
	var blog_story='';
	var blog_sources='';
	var user_username='';
	var date='';
	
	var time='';
	var tempLink='';
	var ts2=0;
	var ts=0;
	var rs2=0;
	var tempText='';
	var db=request.zos.queryObject;
	var count='';
	var q_blog_feed='';
	var blog_feed='';
	var feedLink=0;
	variables.init();
	application.zcore.template.clearPrependAppendTagData("content");
	application.zcore.template.setTemplate("zcorerootmapping.templates.nothing", true,true);
	Request.zPageDebugDisabled=true;
	// you must have a group by in your query or it may miss rows
	ts=structnew();
	ts.image_library_id_field="blog.blog_image_library_id";
	ts.count = 0; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	</cfscript><cfsavecontent variable="db.sql">
	select *
	#db.trustedsql(rs2.select)#
	from #db.table("blog", request.zos.zcoreDatasource)# blog
	#db.trustedsql(rs2.leftJoin)#
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	blog.user_id = user.user_id  and 
	user_deleted = #db.param(0)# and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("blog.user_id_siteIDType"))#
	where blog.site_id=#db.param(request.zos.globals.id)# and 
	(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
	blog_event =#db.param(1)#) and 
	blog_deleted = #db.param(0)# and 
	blog_status <> #db.param(2)#  
	group by blog.blog_id 
	order by blog_sticky desc, blog_datetime desc 
	LIMIT #db.param(0)#,#db.param(25)#
	</cfsavecontent><cfscript>q_blog_feed=db.execute("q_blog_feed");
	if(structkeyexists(form, 'zURLName') and application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_url EQ '{default}'){
		curLink="/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name,'-')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-0.xml";
		actualLink="/#form.zURLName#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-0.xml";
		if(compare(curLink,actualLink) neq 0){
			application.zcore.functions.z301Redirect(curLink);
		}
	}else if(structkeyexists(form, 'zUrlName')){
		application.zcore.functions.z301Redirect(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_url);
	}else{
		curLink=application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_url;
	}
	</cfscript>

	<cfsavecontent variable="feedLink">#request.zOS.currentHostName##curLink#</cfsavecontent>
	<cfsavecontent variable="blog_feed">
	<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
	<channel>
	<atom:link href="#feedLink#" rel="self" type="application/rss+xml" />
	<title>#application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name# From #request.zos.globals.shortdomain#</title>
	<link>#feedLink#</link>
	<description>This feed contains recent stories from #request.zOS.currentHostName#.</description>
	<language>en-us</language>
	<copyright>#year(now())#</copyright>
	<lastBuildDate>#gethttptimestring()#</lastBuildDate><cfloop from="1" to="#q_blog_feed.recordcount#" index="count"><cfscript>
	blog_title = application.zcore.functions.zXMLFormat(q_blog_feed.blog_title[count]);
	blog_author = application.zcore.functions.zXMLFormat(q_blog_feed.user_first_name[count]&" "&q_blog_feed.user_last_name[count]);
	blog_summary = q_blog_feed.blog_summary[count];
	blog_story = q_blog_feed.blog_story[count];
	blog_sources = application.zcore.functions.zXMLFormat(q_blog_feed.blog_sources[count]);
	user_username = application.zcore.functions.zXMLFormat(q_blog_feed.user_username[count]);
	date = dateformat(q_blog_feed.blog_datetime[count], "ddd, dd mmm yyyy");
	time = timeformat(q_blog_feed.blog_datetime[count], "HH:mm:ss") & " EST";
	if(q_blog_feed.blog_unique_name[count] NEQ ""){
		tempLink=request.zOS.currentHostName&application.zcore.functions.zXMLFormat(q_blog_feed.blog_unique_name[count]);
	}else{
		tempLink = request.zOS.currentHostName&application.zcore.functions.zXMLFormat(application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,q_blog_feed.blog_id[count],"html",q_blog_feed.blog_title[count],q_blog_feed.blog_datetime[count]));
	}
	thumbnailStruct=variables.getThumbnailSizeStruct();
	ts2=structnew();
	ts2.image_library_id=q_blog_feed.blog_image_library_id[count];
	ts2.output=false;
	ts2.query=q_blog_feed;
	ts2.row=count;
	ts2.size=thumbnailStruct.width&"x"&thumbnailStruct.height;//request.zos.globals.maximagewidth&"x2000";//
	ts2.crop=thumbnailStruct.crop;
	ts2.count = 1;   
	arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts2);
	image="";
	if(arraylen(arrImages) NEQ 0){
		image=arrImages[1].link;
	}  
	</cfscript><item>
	<title>#blog_title#</title>
	<link>#tempLink#</link>
	<cfif image NEQ ""> 
		<enclosure url="#request.zos.currentHostName&image#" type="image/*"/>
	</cfif>
	<cfscript>
	if(blog_summary EQ ''){
		tempText = blog_story;
		/*tempText = rereplaceNoCase(tempText,"<.*?>","","ALL");
		if(len(tempText) GT 1000){
			tempText=left(tempText,1000)&'...';
		}*/
	}else{
		tempText = blog_summary;
		//tempText = rereplaceNoCase(tempText,"<.*?>","","ALL");
	}
	//tempText = application.zcore.functions.zXMLFormat(tempText);
	</cfscript>
	<description><![CDATA[ <cfif image NEQ ""><p><img src="#image#" /></p></cfif> #tempText# ]]></description>
	<pubDate>#date# #time#</pubDate>
	<author><cfif user_username EQ "">#application.zcore.functions.zvarso("zofficeemail")#<cfelse>#user_username#</cfif><cfif blog_author NEQ ""> (#blog_author#)<cfelse> (Site Admin)</cfif></author>
	<comments>#tempLink###comments</comments>
	<guid isPermaLink="false">#q_blog_feed.blog_guid[count]#</guid>
	</item></cfloop></channel></rss></cfsavecontent><cfcontent type="text/xml; utf-8">
	<cfscript>
	blog_feed=replace(blog_feed, ' href="/', ' href="#request.zos.currentHostName#/', 'all');
	blog_feed=replace(blog_feed, ' src="/', ' src="#request.zos.currentHostName#/', 'all');
	</cfscript>#blog_feed#<cfscript>application.zcore.functions.zabort();</cfscript>
</cffunction>


<cffunction name="menuTemplate" localmode="modern" access="public" output="yes" returntype="any">
	<cfscript>
	var loadBlogSidebar='';
	var content='';
	var xmlLink='';
	
	var htmlLink='';
	var db=request.zos.queryObject;
	var qMenu='';
	</cfscript>
	<cfif isDefined('request.zos.zppBlogMenuLoaded') EQ false>
		<cfscript>
		request.zos.zppBlogMenuLoaded=true;
		loadBlogSidebar=true;
		content = 'include';
		loadBlogSidebar=false;
		if(structcount(application.zcore.app.getAppData("blog")) NEQ 0){
		loadBlogSidebar=true;
		}
		</cfscript>
		<cfif loadBlogSidebar>
			<cfsavecontent variable="db.sql">
			SELECT *,repeat(#db.param("&nbsp;")#,blog_category_level*#db.param(3)#) catpad, count(blog.blog_category_id) count
			from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category
			left join #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category on 
			blog_x_category.blog_category_id = blog_category.blog_category_id and 
			blog_x_category.site_id = blog_category.site_id  and 
			blog_x_category_deleted = #db.param(0)#
			left join #db.table("blog", request.zos.zcoreDatasource)# blog on 
			blog_x_category.blog_id = blog.blog_id and 
			blog_deleted = #db.param(0)# and 
			(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
				blog_event =#db.param(1)#) and 
			blog_status <> #db.param(2)#  and 
			blog.site_id = blog_category.site_id 
			where blog_category.site_id=#db.param(request.zos.globals.id)# and 
			blog_category_deleted = #db.param(0)#
			group by blog_category.blog_category_id
			order by blog_category_sort ASC
			</cfsavecontent><cfscript>qMenu=db.execute("qMenu");</cfscript>
			<div class="rss-menu-box"><div class="rss-menu-box-inner"><div class="rss-menu-blog-title"><h3><cfif application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url EQ "{default}"><a class="#application.zcore.functions.zGetLinkClasses()#" href="/#application.zcore.functions.zurlencode(application.zcore.app.getAppData("blog").optionStruct.blog_config_title,"-")#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-3.html">#htmleditformat(application.zcore.app.getAppData("blog").optionStruct.blog_config_title)#</a><cfelse><a class="#application.zcore.functions.zGetLinkClasses()#" href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url#">#htmleditformat(application.zcore.app.getAppData("blog").optionStruct.blog_config_title)#</a></cfif></h3></div>
			<cfloop query="qMenu">
				#qMenu.catpad#<a class="#application.zcore.functions.zGetLinkClasses()#" href="<cfif qMenu.blog_category_unique_name NEQ ''>#qMenu.blog_category_unique_name#<cfelse>#application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id, qMenu.blog_category_id, "html", qMenu.blog_category_name)#</cfif>" <cfif qmenu.catpad neq ''>style="font-weight:normal;"</cfif>>#htmleditformat(qMenu.blog_category_name)#</a><span style=" font-weight:normal;"><cfif qMenu.count NEQ 0> (#qMenu.count#)</cfif></span><br />
			</cfloop>
			<br />
			<div class="rss-menu-archive">
			<h3>Archive</h3>
			#this.calendarTemplate()#
			</div>
			<cfif request.zos.cgi.SERVER_PORT NEQ "443">
				<div class="rss-menu-share">
				<hr /> <h3>Bookmark &amp; Share</h3>
				#application.zcore.template.getShareButton("font-size:11px;",true)#<br style="clear:both;" />
				</div>
			</cfif>

			<div class="rss-menu-rss">
			<h3>RSS Subscription</h3>
			<cfscript>
			if(application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_feedburner_url') NEQ ''){
				xmlLink=application.zcore.app.getAppData("blog").optionStruct.blog_config_feedburner_url;
			}else if(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_url EQ '{default}'){
				xmlLink= request.zOS.currentHostName&'/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name,'-')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-0.xml';
			}else{
				xmlLink= request.zOS.currentHostName&application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_url;
			}
			htmlLink= request.zOS.currentHostName&'/';
			</cfscript>
    
			<div class="rss-menu-spacer">
			<a class="#application.zcore.functions.zGetLinkClasses()#" href="#xmlLink#" target="_blank"><img src="/z/a/blog/images/rss-xml.gif"  alt="RSS: #htmleditformat(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name)#" style="padding-right:5px; border:none;  text-align:middle; "/>#htmleditformat(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name)#</a>
			</div>
			<div class="rss-menu-spacer">
			<a class="#application.zcore.functions.zGetLinkClasses()#" href="http://add.my.yahoo.com/rss?url=#URLEncodedFormat(xmlLink)#" target="_blank"><img src="/z/a/blog/images/addtomyyahoo.gif"  alt="Add To My Yahoo: #htmleditformat(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name)#" style="padding-right:5px;border:none; "/>#htmleditformat(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name)#</a>
			</div>
			<div class="rss-menu-spacer">
			<a class="#application.zcore.functions.zGetLinkClasses()#" href="http://my.msn.com/addtomymsn.armx?id=rss&amp;ut=#URLEncodedFormat(xmlLink)#&amp;ru=#URLEncodedFormat(htmlLink)#" target="_blank"><img src="/z/a/blog/images/msn-add.gif" alt="Add To My MSN: #htmleditformat(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name)#" style="padding-right:5px; border:none;"/>#htmleditformat(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name)#</a>
			</div>
    
			<div class="rss-menu-spacer">
			<cfscript>
			if(application.zcore.app.getAppData("blog").optionStruct.blog_config_category_home_url EQ '{default}'){
				htmlLink= request.zOS.currentHostName&'/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_category_home_name,'-')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-1.html';
			}else{
				htmlLink= request.zOS.currentHostName&application.zcore.app.getAppData("blog").optionStruct.blog_config_category_home_url;
			}
			</cfscript>
			<a class="#application.zcore.functions.zGetLinkClasses()#" href="#htmlLink#">Personalize RSS Feed</a>
			</div>
			</div>
			</div>
			</div>
		</cfif>
	</cfif>
</cffunction>


<cffunction name="getBlogCategoryById" localmode="modern" access="public" output="no" returntype="struct">
	<cfargument name="blog_category_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("blog_category", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	blog_category_id = #db.param(arguments.blog_category_id)# and 
	blog_category_deleted = #db.param(0)#";
	for(row in db.execute("qBlogCategory")){
		return row;
	}
	throw("Blog category doesn't exist: ""#blog_category_id#""");
	</cfscript>
</cffunction>

<cffunction name="getBlogCategoryByName" localmode="modern" access="public" output="no" returntype="struct">
	<cfargument name="blog_category_name" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("blog_category", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	blog_category_name = #db.param(arguments.blog_category_name)# and 
	blog_category_deleted = #db.param(0)#";
	for(row in db.execute("qBlogCategory")){
		return row;
	}
	throw("Blog category doesn't exist: ""#blog_category_name#""");
	</cfscript>
</cffunction>

<cffunction name="getSectionHomeLink" localmode="modern" access="public" output="no" returntype="string">
	<cfargument name="site_x_option_group_set_id" type="string" required="yes">
	<cfscript>
	application.zcore.functions.z404("getSectionHomeLink disabled");
	return "/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_title,'-')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_section_id#-#arguments.site_x_option_group_set_id#.html";
	</cfscript>
</cffunction>
	
<cffunction name="displayBlogSection" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	application.zcore.functions.z404("displayBlogSection disabled");
	variables.init();
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0);

	struct=application.zcore.functions.zGetSiteOptionGroupSetById(form.site_x_option_group_set_id);
	if(structcount(struct) EQ 0){
		application.zcore.functions.z404("form.site_x_option_group_set_id, ""#form.site_x_option_group_set_id#"" doesn't exist, so displayBlogSection can't load.");
	}


	if(application.zcore.functions.zso(form, 'listId') EQ ''){ 
		form.listId = application.zcore.status.getNewId(); 
	} 
	if(structkeyexists(form, 'zIndex') and isNumeric(form.zIndex)){ 
		application.zcore.status.setField(form.listId,'zIndex',form.zIndex); 
	}else{
		curLink=getSectionHomeLink(form.site_x_option_group_set_id);
		actualLink="/#application.zcore.functions.zso(form, 'zUrlName')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_section_id#-#form.site_x_option_group_set_id#.html";
		if(compare(curLink,actualLink) neq 0){
			application.zcore.functions.z301Redirect(curLink);
		}
	}
	index();
	tempPageNav='<a class="#application.zcore.functions.zGetLinkClasses()#" href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_home_url#">#application.zcore.functions.zvar("homelinktext")#</a> / <a href="#struct.__url#">#struct.__title#</a> /';
	application.zcore.template.setTag("pagenav",tempPageNav);
	affix=application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_section_title_affix');
	if(affix NEQ ""){
		title=struct.__title&" "&affix;
	}else{
		title=struct.__title&" Blog Articles";
	}
	application.zcore.template.setTag("pagetitle", title);
	application.zcore.template.setTag("title", title);
	</cfscript>

	
</cffunction>


<cffunction name="displayBlogCategorySection" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	application.zcore.functions.z404("displayBlogCategorySection disabled");
	variables.init();
	form.blog_category_id=application.zcore.functions.zso(form, 'blog_category_id', true, 0);
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0);

	try{
		blogCategoryStruct=getBlogCategoryById(form.blog_category_id);
	}catch(Any e){
		application.zcore.functions.z404("Blog category, #form.blog_category_id#, doesn't exist.");
	}

	struct=application.zcore.functions.zGetSiteOptionGroupSetById(form.site_x_option_group_set_id);
	if(structcount(struct) EQ 0){
		application.zcore.functions.z404("form.site_x_option_group_set_id, ""#form.site_x_option_group_set_id#"" doesn't exist, so displayBlogSection can't load.");
	}


	if(application.zcore.functions.zso(form, 'listId') EQ ''){ 
		form.listId = application.zcore.status.getNewId(); 
	} 
	if(structkeyexists(form, 'zIndex') and isNumeric(form.zIndex)){ 
		application.zcore.status.setField(form.listId,'zIndex',form.zIndex); 
	}else{
		curLink=getBlogCategorySectionLink(blogCategoryStruct, form.site_x_option_group_set_id);
		actualLink="/#application.zcore.functions.zso(form, 'zUrlName')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_section_id#-#form.site_x_option_group_set_id#_#form.blog_category_id#.html";
		if(compare(curLink,actualLink) neq 0){
			application.zcore.functions.z301Redirect(curLink);
		}
	}
	categoryTemplate();
	tempPageNav='<a class="#application.zcore.functions.zGetLinkClasses()#" href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_home_url#">#application.zcore.functions.zvar("homelinktext")#</a> / <a href="#struct.__url#">#struct.__title#</a> /';
	application.zcore.template.setTag("pagenav", tempPageNav);
	affix=application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_section_title_affix');
	if(affix NEQ ""){
		title=struct.__title&" "&blogCategoryStruct.blog_category_name&" "&affix;
	}else{
		title=struct.__title&" "&blogCategoryStruct.blog_category_name&" Articles";
	}
	application.zcore.template.setTag("pagetitle", title);
	application.zcore.template.setTag("title", title);
	</cfscript>

	
</cffunction>

<cffunction name="index" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	var content='';
	var curLink='';
	var actualLink='';
	var searchStruct='';
	var searchNav='';
	var start='';
	var qList='';
	
	var qCount='';
	var temp='';
	var ts=0;
	var rs2=0;
	var tempMeta='';
	var db=request.zos.queryObject;
	var tempMenu='';
	var tempPagenav='';
	request.month=CreateDate(year(now()),month(now()),1); 
	variables.init();
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0);

	if(form.method EQ "index"){
		tempPageNav='<a class="#application.zcore.functions.zGetLinkClasses()#" href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_home_url#">#application.zcore.functions.zvar("homelinktext")#</a> /';
		if(application.zcore.functions.zso(form, 'listId') EQ ''){ 
			form.listId = application.zcore.status.getNewId(); 
		} 
		if(structkeyexists(form, 'zIndex') and isNumeric(form.zIndex)){ 
			application.zcore.status.setField(form.listId,'zIndex',form.zIndex); 
		}else{
			if(application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url EQ '{default}'){
				curLink="/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_title,'-')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-3.html";
				actualLink="/#application.zcore.functions.zso(form, 'zUrlName')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-3.html";
				if(compare(curLink,actualLink) neq 0){
					application.zcore.functions.z301Redirect(curLink);
				}
			}else if(structkeyexists(form, 'zUrlName')){
				application.zcore.functions.z301Redirect(application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url);
			}
		}
	}
	// required 
	searchStruct = StructNew(); 
	// optional 
	searchStruct.showString = "Stories "; 
	// allows custom url formatting 
	//searchStruct.parseURLVariables = true; 
	searchStruct.indexName = 'zIndex'; 
	searchStruct.firstPageHack=true;
	if(application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url EQ "{default}"){
		searchStruct.firstPageURL="/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_title,"-")#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-3.html";
	}else{
		searchStruct.firstPageURL=application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url;
	}
	searchStruct.noFollow=true;
	searchStruct.url = "#request.cgi_script_name#";
	searchStruct.buttons = 7; 
	// set from query string or default value 
	searchStruct.perpage = 10;	
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	searchStruct.index = min(1000,application.zcore.status.getField(form.listId, "zIndex",1)); 
	start = searchStruct.perpage * max(1,searchStruct.index) - 10;
	ts=structnew();
	ts.image_library_id_field="blog.blog_image_library_id";
	ts.count = 1; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	</cfscript> 
	<cfsavecontent variable="db.sql">
	select *, count(blog_comment.blog_comment_id) as commentCount
	#db.trustedsql(rs2.select)# 
	from #db.table("blog", request.zos.zcoreDatasource)# blog
	#db.trustedsql(rs2.leftJoin)# 
	left join #db.table("blog_category", request.zos.zcoreDatasource)# blog_category on 
	blog_category.blog_category_id = blog.blog_category_id and 
	blog_category.site_id = blog.site_id and 
	blog_category_deleted = #db.param(0)#
	left join #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment on 
	blog.blog_id = blog_comment.blog_id and 
	blog_comment_approved=#db.param(1)# and 
	blog_comment.site_id = blog.site_id and 
	blog_comment_deleted = #db.param(0)#
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	blog.user_id = user.user_id   and 
	user_deleted = #db.param(0)# and
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("blog.user_id_siteIDType"))#
	where blog.site_id=#db.param(request.zos.globals.id)# and 
	blog_deleted = #db.param(0)# and 
	<cfif form.site_x_option_group_set_id NEQ 0>
        (blog.site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# 
        	or blog.blog_show_all_sections=#db.param(1)# 
			
        ) and 
    <cfelseif structkeyexists(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_always_show_section_articles') and application.zcore.app.getAppData("blog").optionStruct.blog_config_always_show_section_articles EQ 0>
		blog.site_x_option_group_set_id = #db.param(0)#  and 
    </cfif>
	 (blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
	 blog_event =#db.param(1)#) and 
	 blog_status <> #db.param(2)# 
	group by blog.blog_id
	order by blog_sticky desc, blog_datetime desc
	LIMIT #db.param(start)#, #db.param(searchStruct.perpage)#
	</cfsavecontent><cfscript>
	qList=db.execute("qList");
	</cfscript>
	<cfsavecontent variable="tempMenu">
	<cfset content = '#content#'>
	#this.menuTemplate()#
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("title",application.zcore.app.getAppData("blog").optionStruct.blog_config_title);
	application.zcore.template.setTag("pagetitle",application.zcore.app.getAppData("blog").optionStruct.blog_config_title);
	if(tempPageNav NEQ ""){
		application.zcore.template.setTag("pagenav",tempPageNav);
	}
	application.zcore.template.setTag("menu",tempMenu);
	</cfscript>
	<cfsavecontent variable="db.sql">
	select count(*) as count from #db.table("blog", request.zos.zcoreDatasource)# blog where 
	site_id=#db.param(request.zos.globals.id)# and 
	blog_deleted = #db.param(0)# and 
	(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
		blog_event =#db.param(1)#) and 
	blog_status <> #db.param(2)# 
	</cfsavecontent><cfscript>qCount=db.execute("qCount");
	searchStruct.count = qCount.count;
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	</cfscript>
	<cfif qCount.count gt searchStruct.perpage>
		#searchNAV#<br />
	</cfif>

	<cfloop query="qList">
		<cfif qList.blog_title NEQ ''>
			#this.summaryTemplate(qlist)#
		</cfif>
	</cfloop>
	
	<cfif qCount.count gt searchStruct.perpage>
		#searchNAV#<br />
	</cfif>
	
	#application.zcore.app.getAppCFC("blog").getPopularTags()#
</cffunction>


<cffunction name="rssTemplate" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	var tempTitle='';
	var blog_title='';
	var blog_datetime='';
	var curLink='';
	var actualLink='';
	var xmlLink='';
	var htmlLink='';
	var s='';
	
	var i='';
	var qCat='';
	var temp='';
	var tempMeta='';
	var tempMenu='';
	var db=request.zos.queryObject;
	var tempPagenav='';
	variables.init();
	tempTitle = "RSS Feed Categories";
	</cfscript>
	<cfsavecontent variable="tempPageNav">
	<a class="#application.zcore.functions.zGetLinkClasses()#" href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_home_url#">#application.zcore.functions.zvar("homelinktext")#</a> / <cfif application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url EQ "{default}"><a class="#application.zcore.functions.zGetLinkClasses()#" href="/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_title,"-")#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-3.html">#application.zcore.app.getAppData("blog").optionStruct.blog_config_title#</a><cfelse><a class="#application.zcore.functions.zGetLinkClasses()#" href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url#">#application.zcore.app.getAppData("blog").optionStruct.blog_config_title#</a></cfif> </cfsavecontent>
	<cfsavecontent variable="tempMenu">
	<cfset blog_datetime = now()>
	#this.menuTemplate()#
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("title",tempTitle);
	application.zcore.template.setTag("pagetitle",tempTitle);
	application.zcore.template.setTag("pagenav",tempPageNav);
	application.zcore.template.setTag("menu",tempMenu);
	</cfscript>
	
	<cfsavecontent variable="db.sql">
	SELECT * from #db.table("blog_category", request.zos.zcoreDatasource)# blog_category 
	LEFT JOIN #db.table("blog", request.zos.zcoreDatasource)# blog ON 
	blog.blog_category_id = blog_category.blog_category_id and 
	(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
	blog_event =#db.param(1)#) and 
	blog_status <> #db.param(2)#  and 
	blog_deleted = #db.param(0)# and
	blog.site_id = blog_category.site_id 
	WHERE blog_category.site_id=#db.param(request.zos.globals.id)# and 
	blog.blog_id IS NOT NULL and 
	blog_category_deleted = #db.param(0)# 
	GROUP BY blog_category.blog_category_id
	ORDER BY blog_category_name ASC
	</cfsavecontent><cfscript>qCat=db.execute("qCat");
	if(application.zcore.app.getAppData("blog").optionStruct.blog_config_category_home_url EQ '{default}'){
		curLink="/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_category_home_name,'-')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-1.html";
		if(not structkeyexists(form, 'zURLName')){
			application.zcore.functions.z301Redirect(curLink);
		}
		actualLink="/#form.zUrlName#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-1.html";
		if(compare(curLink,actualLink) neq 0){
			application.zcore.functions.z301Redirect(curLink);
		}
	}else if(structkeyexists(form, 'zUrlName')){
		application.zcore.functions.z301Redirect(application.zcore.app.getAppData("blog").optionStruct.blog_config_category_home_url);
	}
	</cfscript>

	We offer the following RSS 2.0 XML feeds for our blog.  Get the  latest #application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name# from #request.zos.globals.shortdomain# syndicated with My Yahoo&reg;, Mozilla Firefox or other RSS readers<!--- <a href="http://my.yahoo.com">My Yahoo&reg;</a> or <a href="http://www.mozilla.org/products/firefox/">Mozilla Firefox</a> --->.<br /><br />
	
	<cfscript>
	if(application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_feedburner_url') NEQ ''){
		xmlLink=application.zcore.app.getAppData("blog").optionStruct.blog_config_feedburner_url;
	}else if(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_url EQ '{default}'){
		xmlLink= request.zOS.currentHostName&'/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name,'-')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-0.xml';
	}else{
		xmlLink= request.zOS.currentHostName&application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_url;
	}
	htmlLink= request.zOS.currentHostName&'/';
	</cfscript>
    
	<div style="padding-bottom:10px; width:240px; float:left; "><a class="#application.zcore.functions.zGetLinkClasses()#" href="#xmlLink#" target="_blank" style="text-decoration:none; "><img src="/z/a/blog/images/rss-xml.gif" alt="RSS: #htmleditformat(application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name)#"  style="padding-right:10px; padding-bottom:2px; border:none;  text-align:middle; " />#application.zcore.app.getAppData("blog").optionStruct.blog_config_recent_name#</a></div>
	
	<div style="padding-bottom:10px; width:100px; float:left;"><a class="#application.zcore.functions.zGetLinkClasses()#" href="http://add.my.yahoo.com/rss?url=#URLEncodedFormat(xmlLink)#" target="_blank"><img src="/z/a/blog/images/addtomyyahoo-big.gif" alt="Add to My Yahoo" style=" border:none;" /></a></div>
	
	<div style="padding-bottom:10px; width:65px; float:left;"><a class="#application.zcore.functions.zGetLinkClasses()#" href="http://my.msn.com/addtomymsn.armx?id=rss&amp;ut=#URLEncodedFormat(xmlLink)#&amp;ru=#URLEncodedFormat(htmlLink)#" target="_blank"><img src="/z/a/blog/images/rss_mymsn.gif" alt="Add to My MSN" style=" border:none;" /></a></div>
	<br style="clear:both;" />
	<hr />
	<cfloop query="qCat">
		<cfscript>
		xmlLink= request.zOS.currentHostName&application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_category_id,qCat.blog_category_id,"xml",qCat.blog_category_name);
		htmlLink= request.zOS.currentHostName&'/';
		</cfscript>
		
		<div style="padding-bottom:10px; width:240px; float:left; "><a class="#application.zcore.functions.zGetLinkClasses()#" href="#xmlLink#" target="_blank" style="text-decoration:none; "><img src="/z/a/blog/images/rss-xml.gif" alt="RSS: #htmleditformat(qCat.blog_category_name)#" style="padding-right:10px; padding-bottom:2px;border:none;  text-align:middle; " />#qCat.blog_category_name#</a></div>
		
		<div style="padding-bottom:10px; width:100px; float:left;"><a class="#application.zcore.functions.zGetLinkClasses()#" href="http://add.my.yahoo.com/rss?url=#URLEncodedFormat(xmlLink)#" target="_blank"><img src="/z/a/blog/images/addtomyyahoo-big.gif" alt="Add to My Yahoo" style=" border:none;" /></a></div>
		
		<div style="padding-bottom:10px; width:65px; float:left;"><a class="#application.zcore.functions.zGetLinkClasses()#" href="http://my.msn.com/addtomymsn.armx?id=rss&amp;ut=#URLEncodedFormat(xmlLink)#&amp;ru=#URLEncodedFormat(htmlLink)#" target="_blank"><img src="/z/a/blog/images/rss_mymsn.gif" alt="Add to My MSN" style=" border:none;" /></a></div>
		
		<br style="clear:both;" />
		<hr />
	</cfloop>
</cffunction>


<cffunction name="tagTemplate" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	var content='';
	var blog_tag_name='';
	var searchStruct='';
	var searchNav='';
	var start='';
	var curLink='';
	var db=request.zos.queryObject;
	var actualLink='';
	var qtagdata='';
	var qCount='';
	
	var qArticles=0;
	var ts=0;
	var rs2=0;
	var temp='';
	var tempMeta='';
	var tempMenu='';
	var tempPagenav='';
	variables.init();
	if(application.zcore.functions.zso(form, 'listId') EQ ''){ 
		form.listId = application.zcore.status.getNewId(); 
	} 
	if(structkeyexists(form, 'zIndex')){ 
		application.zcore.status.setField(form.listId,'zIndex',form.zIndex); 
	}
	// required 
	searchStruct = StructNew(); 
	// optional 
	searchStruct.showString = "Articles "; 
	// allows custom url formatting 
	//searchStruct.parseURLVariables = true; 
	searchStruct.indexName = 'zIndex'; 
	searchStruct.buttons = 7; 
	// set from query string or default value 
	searchStruct.parseURLVariables=true;
	searchStruct.firstPageHack=true;
	searchStruct.perpage = 10;	
	//searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	searchStruct.index = application.zcore.status.getField(form.listId, "zIndex",1); 
	start = searchStruct.perpage * searchStruct.index - 10;
	// you must have a group by in your query or it may miss rows
	
	db.sql="select * 
	from #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag 
	where blog_tag.blog_tag_id = #db.param(form.blog_tag_id)# and 
	blog_tag.site_id=#db.param(request.zos.globals.id)# and 
	blog_tag_deleted=#db.param(0)#  ";
	qtagdata=db.execute("qtagdata");
	if(qtagdata.recordcount eq 0){
		application.zcore.functions.z404("qtagdata record was missing in tagTemplate().");
	}
	
	ts=structnew();
	ts.image_library_id_field="blog.blog_image_library_id";
	ts.count = 1; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="select *, count(blog_comment.blog_comment_id) as commentCount
	#db.trustedsql(rs2.select)# 
	from (#db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag, 
	#db.table("blog_x_tag", request.zos.zcoreDatasource)# blog_x_tag, 
	#db.table("blog", request.zos.zcoreDatasource)# blog)
	#db.trustedsql(rs2.leftJoin)#
	
	left join #db.table("blog_category", request.zos.zcoreDatasource)# blog_category on 
	blog.blog_category_id = blog_category.blog_category_id and 
	blog_tag.site_id = blog_category.site_id and 
	blog_category_deleted = #db.param(0)#
	left join #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment on 
	blog.blog_id = blog_comment.blog_id and
	blog_comment_deleted = #db.param(0)# and 
	 blog_comment_approved=#db.param(1)# and 
	blog_tag.site_id = blog_comment.site_id 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	blog.user_id = user.user_id   and 
	user_deleted = #db.param(0)# and
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("blog.user_id_siteIDType"))#
	where blog_tag.blog_tag_id = #db.param(form.blog_tag_id)# and 
	blog_tag_deleted = #db.param(0)# and 
	blog_deleted = #db.param(0)# and 
	blog_x_tag_deleted = #db.param(0)# and 
	blog_tag.site_id=#db.param(request.zos.globals.id)# and 
	blog_tag.site_id = blog_x_tag.site_id and 
	blog_x_tag.site_id = blog.site_id and 
	blog_tag.blog_tag_id = blog_x_tag.blog_tag_id and 
	blog_x_tag.blog_id = blog.blog_id and 
	(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
	blog_event =#db.param(1)#) and 
	blog_status <> #db.param(2)# 
	group by blog.blog_id
	order by blog_sticky desc, blog_datetime desc
	LIMIT #db.param(start)#, #db.param(searchStruct.perpage)#";
	qArticles=db.execute("qArticles"); 
	if(structkeyexists(form, 'zUrlName')){
		if(qtagdata.blog_tag_unique_name EQ ""){
			curLink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_tag_id, form.blog_tag_id,"html",qtagdata.blog_tag_name);
			actualLink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_tag_id, form.blog_tag_id,"html",form.zUrlName);
			if(compare(curLink,actualLink) neq 0){
				application.zcore.functions.z301Redirect(curLink);
			}
		}else{
			if(compare(qtagdata.blog_tag_unique_name, request.zos.originalURL) NEQ 0){
				application.zcore.functions.z301Redirect(qtagdata.blog_tag_unique_name);
			}
		}
	}
	
	application.zcore.siteOptionCom.setCurrentOptionAppId(qtagdata.blog_tag_site_option_app_id); 
	</cfscript>
	<cfsavecontent variable="db.sql">
	select count(*) as count
	from (#db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag, 
	#db.table("blog_x_tag", request.zos.zcoreDatasource)# blog_x_tag, 
	#db.table("blog", request.zos.zcoreDatasource)# blog)
	WHERE blog_tag.blog_tag_id = blog_x_tag.blog_tag_id and
	blog_tag_deleted = #db.param(0)# and 
	blog_x_tag_deleted = #db.param(0)# and 
	blog_deleted = #db.param(0)# 
	and blog_tag.site_id = blog_x_tag.site_id and 
	blog.site_id = blog_tag.site_id 
	and blog.blog_id = blog_x_tag.blog_id and 
	(blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
	blog_event =#db.param(1)#) and 
	blog_status <> #db.param(2)# 
	and  blog_tag.blog_tag_id = #db.param(form.blog_tag_id)# and 
	blog_tag.site_id=#db.param(request.zos.globals.id)#
	</cfsavecontent><cfscript>qCount=db.execute("qCount");
	searchStruct.url = application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_tag_id, form.blog_tag_id&'_##zIndex##',"html",qtagdata.blog_tag_name);
	if(qtagdata.blog_tag_unique_name NEQ ""){
		searchStruct.firstpageurl=qtagdata.blog_tag_unique_name;
	}else{
		searchStruct.firstpageurl=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_tag_id, form.blog_tag_id,"html",qtagdata.blog_tag_name);
	}
	searchStruct.count = qCount.count;
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	</cfscript>
	<cfsavecontent variable="tempPageNav">
	<a class="#application.zcore.functions.zGetLinkClasses()#" href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_home_url#">#application.zcore.functions.zvar("homelinktext")#</a> / <cfif application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url EQ "{default}"><a class="#application.zcore.functions.zGetLinkClasses()#" href="/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_title,"-")#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-3.html">#application.zcore.app.getAppData("blog").optionStruct.blog_config_title#</a><cfelse><a class="#application.zcore.functions.zGetLinkClasses()#" href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url#">#application.zcore.app.getAppData("blog").optionStruct.blog_config_title#</a></cfif> / 
	</cfsavecontent>
	<cfsavecontent variable="tempMeta">
	<cfif qtagdata.blog_tag_metakey NEQ ""><meta name="keywords" content="#htmleditformat(qtagdata.blog_tag_metakey)#" /></cfif>
	<meta name="description" content="<cfif qtagdata.blog_tag_metadesc NEQ "">#htmleditformat(qtagdata.blog_tag_metadesc)#<cfelse>#htmleditformat(application.zcore.functions.zLimitStringLength(application.zcore.functions.zStripHTMLTags(qtagdata.blog_tag_description), 100))#</cfif>" />
	</cfsavecontent>
	<cfsavecontent variable="tempMenu">
	<cfset content = '#content#'>
	<cfset blog_tag_name = '#qtagdata.blog_tag_Name#'>
	#this.menuTemplate()#
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("title","#qtagdata.blog_tag_name# Tag Page #application.zcore.status.getField(form.listId, "zIndex",1)#");
	application.zcore.template.setTag("pagetitle","#qtagdata.blog_tag_name# Tag Page #application.zcore.status.getField(form.listId, "zIndex",1)#");
	application.zcore.template.setTag("pagenav",tempPageNav);
	application.zcore.template.setTag("menu",tempMenu);
	application.zcore.template.setTag("meta",tempMeta);
		
	//if((structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager")) ){
		writeoutput('<div style="display:inline;" id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/blog/admin/blog-admin/tagEdit?blog_tag_id=#form.blog_tag_id#&amp;return=1">');
		application.zcore.template.prependTag('pagetitle','<span style="display:inline;" id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/blog/admin/blog-admin/tagEdit?blog_tag_id=#form.blog_tag_id#&amp;return=1">');
		application.zcore.template.appendTag('pagetitle','</span>');
	//}
	</cfscript>
	#qtagdata.blog_tag_description# 
	<cfscript>
	//if(structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager")){
		writeoutput('</div>');
	//}
	</cfscript><br style="clear:both;" />
	
	<cfif qtagdata.recordcount NEQ 0>
		<strong style="font-size:14px;">Articles associated with this tag:</strong><br />
		<br />
	</cfif>
	
	<cfif qArticles.recordcount neq 0>
		<cfif searchStruct.count gt searchStruct.perpage>
			#searchNAV#
		</cfif>
		<cfloop query="qArticles">
			<cfif qArticles.blog_id NEQ ''>
				#this.summaryTemplate(qArticles)#
			</cfif>
		</cfloop>
		<cfif searchStruct.count gt searchStruct.perpage>
		#searchNAV#
		</cfif>
	<cfelse>
		There are no articles ssociated with this tag yet.<br /><br />
	</cfif>
	
	<cfif application.zcore.app.siteHasApp("listing") and qtagdata.blog_tag_search_mls EQ 1>
		<hr />
		<cfscript>
		application.zcore.listingStruct.functions.zListingDisplaySavedSearch(qtagdata.blog_tag_saved_search_id);
		</cfscript>
	</cfif> 
	#application.zcore.app.getAppCFC("blog").getPopularTags()#
</cffunction>


<cffunction name="archiveTemplate" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	var content=''; 
	var searchStruct='';
	var searchNav='';
	var start='';
	var curLink='';
	var actualLink='';
	var tempTitle='';
	var ts=0;
	var rs2=0;
	
	var qList='';
	var temp='';
	var tempMeta='';
	var tempMenu='';
	var tempPagenav='';
	var db=request.zos.queryObject;
	variables.init();
	if(structkeyexists(form, 'archive') EQ false or form.archive EQ "" or isDate(form.archive&'-01') EQ false){
		application.zcore.functions.zRedirect('/');
	}else{
		form.archive=parsedatetime(form.archive&'-01');
		request.month = form.archive;
	}
	if(application.zcore.functions.zso(form, 'ListID') EQ ''){ 
		  form.ListId = application.zcore.status.getNewId(); 
	 } 
	 if(structkeyexists(form, 'zIndex')){ 
		  application.zcore.status.setField(form.ListID,'zIndex',form.zIndex); 
	 }
	// required 
	searchStruct = StructNew(); 
	
	// optional 
	searchStruct.showString = "Stories "; 
	// allows custom url formatting 
	//searchStruct.parseURLVariables = true; 
	searchStruct.indexName = 'zIndex'; 
	searchStruct.buttons = 7; 
	// set from query string or default value 
	searchStruct.perpage = 10;	
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	searchStruct.index = application.zcore.status.getField(form.ListId, "zIndex",1); 
	start = searchStruct.perpage * searchStruct.index - 10;
	searchStruct.url = "#request.cgi_script_name#?archive=#form.archive#";
	curLink='/#application.zcore.app.getAppData("blog").optionStruct.blog_config_archive_name#-#dateformat(form.archive,'yyyy-mm')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-2.html';
	actualLink='/#form.zurlname#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-2.html';
	if(compare(curLink,actualLink) neq 0){
		application.zcore.functions.z301Redirect(curLink);
	} 
	// you must have a group by in your query or it may miss rows
	ts=structnew();
	ts.image_library_id_field="blog.blog_image_library_id";
	ts.count = 1; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	</cfscript> 
	<cfsavecontent variable="db.sql">
	select *, count(blog_comment.blog_comment_id) as commentCount
	#db.trustedsql(rs2.select)#
	from #db.table("blog", request.zos.zcoreDatasource)# blog
	#db.trustedsql(rs2.leftJoin)#
	left join #db.table("blog_category", request.zos.zcoreDatasource)# blog_category on 
	blog_category.blog_category_id = blog.blog_category_id and 
	blog_category.site_id = blog.site_id and 
	blog_category_deleted = #db.param(0)#
	left join #db.table("blog_comment", request.zos.zcoreDatasource)# blog_comment on 
	blog.blog_id = blog_comment.blog_id and 
	blog_comment_approved=#db.param(1)# and 
	blog_comment.site_id = blog.site_id and 
	blog_comment_deleted = #db.param(0)#
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	blog.user_id = user.user_id  and 
	user_deleted = #db.param(0)# and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("blog.user_id_siteIDType"))#
	where blog.site_id=#db.param(request.zos.globals.id)# and 
	blog_deleted = #db.param(0)# and 
	blog_datetime < #db.param(dateformat(form.archive, 'yyyy-mm-')&daysInMonth(form.archive)&' '&timeformat(now(), 'HH:mm:ss'))# AND 
	blog_datetime > #db.param(dateformat(form.archive, 'yyyy-mm-01')&' 00:00:00')# and 
	blog_status <> #db.param(2)#  and
	 (blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'))# or 
	blog_event =#db.param(1)#)
	group by blog.blog_id
	order by blog_sticky desc, blog_datetime desc
	</cfsavecontent><cfscript>qList=db.execute("qList");</cfscript>
	<cfsavecontent variable="tempMenu">
	<cfset content = '#content#'> 
	#this.menuTemplate()#
	</cfsavecontent>
	<cfscript>
	tempTitle = "#dateformat(form.archive, "mmmm yyyy")# Blog Archive";
	</cfscript>
	<cfsavecontent variable="tempPageNav">
	<a class="#application.zcore.functions.zGetLinkClasses()#" href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_home_url#">#application.zcore.functions.zvar("homelinktext")#</a> / <cfif application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url EQ "{default}"><a class="#application.zcore.functions.zGetLinkClasses()#" href="/#application.zcore.functions.zURLEncode(application.zcore.app.getAppData("blog").optionStruct.blog_config_title,"-")#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id#-3.html">#application.zcore.app.getAppData("blog").optionStruct.blog_config_title#</a><cfelse><a class="#application.zcore.functions.zGetLinkClasses()#" href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_root_url#">#application.zcore.app.getAppData("blog").optionStruct.blog_config_title#</a>  </cfif>
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("title",tempTitle);
	application.zcore.template.setTag("pagetitle",tempTitle);
	application.zcore.template.setTag("pagenav",tempPageNav);
	application.zcore.template.setTag("menu",tempMenu);
	</cfscript>
	<cfif qList.recordcount lt 1>
		Sorry, there are no news entries from #dateformat(archive, "mmmm yyyy")#.
	<cfelse>
		<cfloop query="qList">
			<cfif qList.blog_title NEQ ''>
				<a class="#application.zcore.functions.zGetLinkClasses()#" id="#dateformat(qList.blog_datetime, 'dd')#"></a>
				#this.summaryTemplate(qList)#
			</cfif>
		</cfloop>
		<cfif qlist.recordcount LTE 5>
			<div style="width:100px; height:1000px;"></div>
		</cfif>
	</cfif>
	
	#application.zcore.app.getAppCFC("blog").getPopularTags()#
</cffunction>


<cffunction name="addComment" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	var query='';
	var ulink='';
	var result='';
	var inputStruct='';
	var blog_comment_id='';
	var link='';
	var t='';
	var db=request.zos.queryObject;

	if(application.zcore.functions.zIsExternalCommentsEnabled()){
		application.zcore.functions.z404("Invalid request");
	}

	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
		application.zcore.functions.z404("Invalid request");
	}
	if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
		application.zcore.functions.z404("Invalid request");
	}

	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0);
	if(structkeyexists(form,'blog_id') EQ false){
	    application.zcore.functions.zRedirect('/');
	}
	if(form.blog_id CONTAINS ","){
		form.blog_id=listGetAt(form.blog_id, 1, ",");
	}
	db.sql="select * from #db.table("blog", request.zos.zcoreDatasource)# blog where 
	blog_id = #db.param(form.blog_id)# and 
	site_id=#db.param(request.zos.globals.id)#";
	query = db.execute("query");
	if(query.recordcount EQ 0){
		application.zcore.functions.z404("blog record doesn't exist in addComment.");
	}
	if(query.blog_unique_name NEQ ""){
		ulink=application.zcore.functions.zURLAppend(request.zOS.currentHostName&query.blog_unique_name,"zsid=#request.zsid#");
	}else{
		ulink=request.zOS.currentHostName&application.zcore.app.getAppCFC("blog").getBlogLink(
		application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id, 
		form.blog_id, 
		"html",
		query.blog_title, 
		query.blog_datetime)&"?zsid=#request.zsid###addC";
	}
	
	if(application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1){
		if(not application.zcore.functions.zVerifyRecaptcha()){
			application.zcore.status.setStatus(request.zsid, "The ReCaptcha security phrase wasn't entered correctly. Please try again.", form, true);
			application.zcore.functions.zRedirect(ulink);
		}
	}

	if(structkeyexists(form, 'blog_comment_text') and (findnocase("[/url]", form.blog_comment_text) NEQ 0 or findnocase("http://", form.blog_comment_text) NEQ 0)){
		application.zcore.status.setStatus(Request.zsid, "Invalid Request",form,true);
		application.zcore.functions.zRedirect(ulink);
	}
	if(structkeyexists(form, 'blog_comment_title') EQ false){
		application.zcore.functions.zRedirect('/');	
	}
	form.blog_comment_author=htmleditformat(form.blog_comment_author);
	form.blog_comment_author_email=htmleditformat(form.blog_comment_author_email);
	form.blog_comment_title=htmleditformat(form.blog_comment_title);
	form.blog_comment_text=htmleditformat(form.blog_comment_text);
	result=false;
	form.blog_comment_datetime = '#dateformat(now(), 'yyyy-mm-dd')# #timeformat(now(), 'HH:mm:ss')#';
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager")){
		form.blog_comment_approved=1;
	}else{
		form.blog_comment_approved = 0;
	}
	if(form.blog_comment_title eq ''){
		form.blog_comment_title = 'Re: '&query.blog_title;
	}
	if(form.blog_comment_author eq ''){
		//throw error
		application.zcore.status.setStatus(request.zsid, 'You must submit your name.', form,false);
		application.zcore.functions.zRedirect(ulink);
	}else{
		request.zsession.blog_comment_author = form.blog_comment_author;
	}
	if(len(form.blog_comment_text) lt 1 or len(form.blog_comment_text) GT 1000){
		//throw error
		application.zcore.status.setStatus(request.zsid, 'You must have a comment and it must be less then 250 characters.', form,false);
		application.zcore.functions.zRedirect(ulink);
	}
	if(structkeyexists(form, 'blog_comment_author_email') EQ false or application.zcore.functions.zEmailValidate(form.blog_comment_author_email) EQ false){
		//throw error
		application.zcore.status.setStatus(request.zsid, 'Comments Author Email must be a well formatted email address, (ex. johndoe@domain.com)', form,false);
		application.zcore.functions.zRedirect(ulink);
	}else{
		request.zsession.blog_comment_author_email = form.blog_comment_author_email;
	}
	inputStruct = StructNew();
	inputStruct.table = "blog_comment";
	inputStruct.datasource="#request.zos.zcoreDatasource#";
	form.site_id=request.zos.globals.id;
	inputStruct.struct=form;
	blog_comment_id = application.zcore.functions.zInsert(inputStruct); 
	application.zcore.status.setStatus(Request.zsid, false,blog_comment_id,false);
	if(blog_comment_id EQ false){
		// failed, on duplicate key or sql error
		application.zcore.status.setStatus(request.zsid, 'An error has occurred with your submission.', form,false);
		application.zcore.functions.zRedirect(ulink);
	}else{
		// success
	}
	link=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_misc_id, 4, "html",application.zcore.app.getAppData("blog").optionStruct.blog_config_title);
	tempEmail=application.zcore.functions.zvarso('zofficeemail');
	</cfscript>
	<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "content_manager") EQ false>
		<cfmail  to="#tempEmail#" from="#tempEmail#" subject="New blog comment on #request.zos.globals.shortdomain#" type="html">
		#application.zcore.functions.zHTMLDoctype()#
		<head>
		<meta charset="utf-8" />
		<title>New Blog Comment</title>
		</head>
		
		<body>
		<span style="font-family:Verdana, Geneva, sans-serif; font-size:12px; line-height:18px;">
		<strong style="font-size:14px;">A new blog comment was posted for: #query.blog_title#</strong><br /><br />
		<table style="border-spacing:5px; font-family:Verdana, Geneva, sans-serif; font-size:12px; line-height:18px;">
		<tr><td>Date Added:</td><td>#dateformat(now(),"m/d/yyyy")&" at "&timeformat(now(),"h:mm tt")#</td></tr>
		<tr><td>Name:</td><td>#form.blog_comment_author#</td></tr>
		<tr><td>Email:</td><td><a href="mailto:#form.blog_comment_author_email#">#form.blog_comment_author_email#</a></td></tr>
		<tr><td>Subject:</td><td>#form.blog_comment_title#</td></tr>
		<tr><td>Comments:</td><td>#application.zcore.functions.zparagraphformat(form.blog_comment_text)#</td></tr>
		</table><br />
		 
		<strong>You must choose to approve or delete this comment:</strong><br /><br />
		
		<a href="#application.zcore.functions.zvar('domain')#/z/blog/admin/blog-admin/commentApprove?blog_comment_id=#blog_comment_id#&amp;blog_id=#form.blog_id#">Approve</a> | <a href="#application.zcore.functions.zvar('domain')#/z/blog/admin/blog-admin/commentDelete?blog_comment_id=#blog_comment_id#&amp;blog_id=#form.blog_id#">Delete</a> (You may be asked to login)<br /><br />
		<a href="#ulink#">Click here to view blog article</a><br /><br />
		If you see code or other unusual characters, this may be an attempt to add spam to your site and you should delete it.
		</span>
		</body>
		</html>
		
		</cfmail>
	</cfif>
	<cfscript>
	if((structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager"))){
		if(structkeyexists(form, 'managerReturn')){
			application.zcore.status.setStatus(request.zsid, 'Your submission was successful and was automatically posted since you are a content manager.');
			application.zcore.functions.zRedirect('/z/blog/admin/blog-admin/commentList?blog_id=#form.blog_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Your submission was successful and was automatically posted since you are a content manager.');
			application.zcore.functions.zRedirect(ulink);
		}
	}else{
		application.zcore.status.setStatus(request.zsid, 'Your submission was successful and it will be posted after it has been reviewed.');
		application.zcore.functions.zRedirect(ulink);
	}
	</cfscript>
</cffunction>



<cffunction name="getPopularTags" localmode="modern" output="yes" returntype="any">
	<cfscript>
	var qTag=0;
	var arrStyle=0;
	
	var styleIndex=0;
	var arrQueryParam=arraynew(1);
	var db=request.zos.queryObject;
	</cfscript> 
	
	<cfsavecontent variable="db.sql">
	SELECT *, count(blog_tag.blog_tag_id) count FROM 
	#db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag, 
	#db.table("blog_x_tag", request.zos.zcoreDatasource)# blog_x_tag WHERE 
	blog_tag_deleted = #db.param(0)# and 
	blog_x_tag_deleted = #db.param(0)# and
	blog_tag.blog_tag_id = blog_x_tag.blog_tag_id 
	<cfif structkeyexists(form, 'blog_tag_id')> and blog_tag.blog_tag_id <> #db.param(form.blog_tag_id)#</cfif>
	and blog_tag.site_id=#db.param(request.zos.globals.id)#
	and blog_tag.site_id = blog_x_tag.site_id 
	GROUP BY blog_tag.blog_tag_id 
	ORDER BY blog_tag_name
	</cfsavecontent><cfscript>
	qTag=db.execute("qTag");
	</cfscript>
	<cfif qTag.recordcount NEQ 0>
		<h2>Popular tags on this blog</h2>
		<cfscript>
		arrStyle=arraynew(1);
		arrayappend(arrStyle,"font-size:90%; font-weight:normal;");
		arrayappend(arrStyle,"font-size:95%; font-weight:normal;");
		arrayappend(arrStyle,"font-size:100%; font-weight:normal;");
		arrayappend(arrStyle,"font-size:105%; font-weight:normal;");
		arrayappend(arrStyle,"font-size:110%; font-weight:normal;");
		arrayappend(arrStyle,"font-size:120%; font-weight:normal;");
		</cfscript>
		
		<cfloop query="qtag">
			<cfscript>
			styleIndex=max(1,min(qtag.count,arraylen(arrStyle)));
			</cfscript>
			<a class="#application.zcore.functions.zGetLinkClasses()#" href="<cfif qtag.blog_tag_unique_name NEQ ''>#qtag.blog_tag_unique_name#<cfelse>#application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_tag_id,qtag.blog_tag_id,"html",qtag.blog_tag_name)#</cfif>" style="#arrStyle[styleIndex]#">#qtag.blog_tag_name#</a> | 
		</cfloop>
	</cfif>
</cffunction>

<cffunction name="summaryTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="query" type="query" required="yes">
	<cfscript>
	var tempText=0;
	var n2=0;
	var ts2=0;
	var pos=0;
	//if((structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager"))){
		writeoutput('<div style="display:inline;width:100%;" id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/blog/admin/blog-admin/articleEdit?blog_id=#arguments.query.blog_id#&amp;return=1&amp;site_x_option_group_set_id=#arguments.query.site_x_option_group_set_id#">');
	//}
	
	thumbnailStruct=variables.getThumbnailSizeStruct();
	ts2=structnew();
	ts2.image_library_id=arguments.query.blog_image_library_id;
	ts2.output=false;
	ts2.query=arguments.query;
	ts2.row=arguments.query.currentrow;
	ts2.size=thumbnailStruct.width&"x"&thumbnailStruct.height;
	ts2.crop=thumbnailStruct.crop;
	ts2.count = 1;  
	arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts2);
	image="";//request.zos.currentHostName&"/z/a/images/s.gif";
	if(arraylen(arrImages) NEQ 0){
		image=request.zos.currentHostName&arrImages[1].link;
	} 
	if(arguments.query.blog_unique_name NEQ ''){
		currentLink=arguments.query.blog_unique_name;
	}else{
		currentLink=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,arguments.query.blog_id,"html",arguments.query.blog_title,arguments.query.blog_datetime);
	}
	if(structkeyexists(request,'arrSearchSiteLinks')){
		n2=arguments.query.blog_title;
		pos=find("|",n2);
		if(pos NEQ 0){ n2=trim(left(n2,pos-1)); }
		arrayappend(request.arrSearchSiteLinks,'<a href="#currentLink#">#htmleditformat(n2)#</a>');
	} 
	</cfscript>
	<div class="rss-summary-d" style="max-width:#request.zos.globals.maximagewidth#px;">
		<cfif image NEQ "">
			<div class="rss-summary-thumbnail" style="width:#thumbnailStruct.width#px; <!--- height:#thumbnailStruct.height#px; --->"><span><a href="#currentLink#"><img src="#image#" alt="#htmleditformat(arguments.query.blog_title)#" /></a></span></div>
			<div class="rss-summary-ds rss-summary-ds-2"  style="max-width:#request.zos.globals.maximagewidth-62-thumbnailStruct.width#px;">
		<cfelse>
			<div class="rss-summary-ds">
		</cfif>
		<a href="#currentLink#" class="rss-summary-title #application.zcore.functions.zGetLinkClasses()#">#htmleditformat(arguments.query.blog_title)#</a>
			<span class="rss-summary-date"><cfif arguments.query.blog_event EQ 1> Event Date: </cfif>
    #dateformat(arguments.query.blog_datetime, 'ddd, mmm dd, yyyy')# 
				<cfif arguments.query.blog_hide_time EQ 0 and arguments.query.blog_event EQ 1> at #timeformat(arguments.query.blog_datetime, "h:mmtt")#  </cfif>
				<cfif arguments.query.blog_end_datetime NEQ "" and arguments.query.blog_end_datetime NEQ arguments.query.blog_datetime> 
					<cfif dateformat(arguments.query.blog_end_datetime,'yyyymmdd') NEQ dateformat(arguments.query.blog_datetime,'yyyymmdd')>
						to #dateformat(arguments.query.blog_end_datetime, 'ddd, mmm dd, yyyy')# 
					<cfif arguments.query.blog_hide_time EQ 0 and arguments.query.blog_event EQ 1> at #timeformat(arguments.query.blog_end_datetime, "h:mmtt")# </cfif>
					<cfelse>
						<cfif arguments.query.blog_hide_time EQ 0 and arguments.query.blog_event EQ 1> to #timeformat(arguments.query.blog_end_datetime, "h:mmtt")# </cfif>
					</cfif>
				</cfif></span>
			<cfscript> 
			if(arguments.query.blog_summary EQ ''){
				tempText = arguments.query.blog_story;
			}else{
				tempText = arguments.query.blog_summary;
			}
			tempText = rereplaceNoCase(tempText,"<.*?>","","ALL");
			</cfscript>
			#left(tempText, 250)#<cfif len(tempText) GT 250>...</cfif><br />
		
		<div class="rss-summary-box">
			<div>
				<cfif arguments.query.user_first_name NEQ "" and arguments.query.user_last_name NEQ "">
					Author: #application.zcore.functions.zEncodeEmail(arguments.query.user_username,true,arguments.query.user_first_name&" "&arguments.query.user_last_name,true,false)# in 
				<cfelse>
					Author: #application.zcore.functions.zEncodeEmail(arguments.query.user_username,true,arguments.query.user_username,true,false)# in 
				</cfif>
				<a href="#currentLink#" class="#application.zcore.functions.zGetLinkClasses()#">#htmleditformat(arguments.query.blog_category_name)#</a> <!--- | <a href="<cfif arguments.query.blog_unique_name NEQ ''>#arguments.query.blog_unique_name#<cfelse>#application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,arguments.query.blog_id,"html",arguments.query.blog_title,arguments.query.blog_datetime)#</cfif>##comment" class="#application.zcore.functions.zGetLinkClasses()#">Comments (#commentCount#)</a> --->
			</div>		
		</div>
		<!--- <cfif image NEQ "">
			</div>
		</cfif> --->
			</div> <br style="clear:both;" />
	</div>
	<br style="clear:both;" /><br />
	<cfscript>
	//if((structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "content_manager"))){
		writeoutput('</div>');
	//}
	</cfscript>
</cffunction>

<cffunction name="displayBlogSummaries" localmode="modern" output="yes" returntype="any">
	<cfargument name="query" type="query" required="yes">
	<cfloop query="arguments.query">
		<cfscript>
		this.summaryTemplate(arguments.query);
		</cfscript>
	</cfloop>
</cffunction>

<cffunction name="getCSSJSIncludes" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
</cffunction>

</cfoutput>
</cfcomponent>