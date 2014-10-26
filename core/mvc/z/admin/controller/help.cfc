<cfcomponent>
<cfoutput>
<cffunction name="init" access="private" localmode="modern">
	<cfscript>
	application.zcore.skin.includeCSS("/z/stylesheets/zdoc.css");
	</cfscript>
</cffunction>
<cffunction name="index" access="remote" localmode="modern" roles="member">
	<cfscript>
	init();
	application.zcore.template.setTag("title", "Documentation");
	application.zcore.template.setTag("pagetitle", "Documentation");
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<div class="zhelp-manager-div">
		<p>Please choose one of the following resources to begin to learn more about managing the web site.</p>
		<ul>
			<li><a href="/z/admin/help/quickStart">Quick Start Guide</a></li>
			<li><a href="/z/admin/manual/view/0/index.html">Full Documentation</a></li>
			<li><a href="/z/admin/help/incontext">In-context Help Features</a></li>
		</ul>
		#searchForm()#
	</div>
</cffunction>

<cffunction name="searchForm" access="private" localmode="modern">

	<h1>Documentation Search</h1>
	<form action="/z/admin/help/search" method="get">
	<p><input type="text" name="searchtext" value="#application.zcore.functions.zso(form, 'searchtext')#" style="width:70%;" /> <input type="submit" name="submit112" value="Search" /></p>
	</form>
</cffunction>
	

<cffunction name="search" access="remote" localmode="modern" roles="member">
	<cfscript>
	form.zindex=application.zcore.functions.zso(form, 'zindex', true, 1);
	form.searchtext=application.zcore.functions.zso(form, 'searchtext');
	db=request.zos.queryObject;
	perpage=10;
	//echo(application.zcore.app.siteHasApp("blog"));
	//writedump(application.siteStruct[request.zos.globals.id].adminFeatureMapStruct);

	db.sql="select * from #db.table("search", request.zos.zcoreDatasource)# WHERE 
	app_id=#db.param(9)# and 
	search_fulltext LIKE #db.param('%'&form.searchtext&'%')# and 
	site_id IN (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	search_deleted=#db.param(0)#";
	if(structkeyexists(request.zsession, 'zManualStruct')){
		idlist="'global-documentation-"&structkeylist(request.zsession.zManualStruct.idstruct, "','global-documentation-")&"'"; 
		db.sql&=" and search_table_id IN (#db.trustedSQL(idlist)#) ";
	}
	db.sql&=" LIMIT #db.param((form.zindex-1)*perpage)#, #db.param(perpage)#";
	qSearch=db.execute("qSearch");

	db.sql="select count(search_id) count from #db.table("search", request.zos.zcoreDatasource)# WHERE 
	app_id=#db.param(9)# and 
	search_fulltext LIKE #db.param('%'&form.searchtext&'%')# and 
	site_id IN (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	search_deleted=#db.param(0)#";
	if(structkeyexists(request.zsession, 'zManualStruct')){
		idlist="'global-documentation-"&structkeylist(request.zsession.zManualStruct.idstruct, "','global-documentation-")&"'"; 
		db.sql&=" and search_table_id IN (#db.trustedSQL(idlist)#) ";
	}
	qCount=db.execute("qCount");
 
	searchStruct = StructNew();  
	searchStruct.indexName = 'zIndex'; 
	searchStruct.url = "/z/admin/help/search?searchtext=#urlencodedformat(form.searchtext)#";  
	searchStruct.buttons = 7; 
	searchStruct.index=form.zindex;
	searchStruct.count=qCount.count; 
	searchStruct.perpage = perpage;	
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);

	searchForm();

	echo('<h2>Search Results</h2>');
	if(qSearch.recordcount EQ 0){
		echo('No matches found.');
	}else{
		if(qCount.count GT perpage){
			echo(searchNav);
		}
		for(row in qSearch){
			echo('<div style="width:96%; border-bottom:1px solid ##CCC; padding:2%; float:left;">
				<div style="width:100%; float:left; padding-bottom:10px; font-size:18px; line-height:21px;"><a href="#row.search_url#">#row.search_title#</a></div>
				<div style="font-size:14px; line-height:18px;">#row.search_summary#</div>
			</div>');
		}
		if(qCount.count GT perpage){
			echo(searchNav);
		}
	}
	</cfscript>
</cffunction>
	
<cffunction name="quickStart" access="remote" localmode="modern" roles="member">
	<cfscript>
	init();
	application.zcore.template.setTag("title", "Quick Start Guide");
	application.zcore.template.setTag("pagetitle", "Quick Start Guide");
	</cfscript>
	<style type="text/css">
	</style>
	<div class="zhelp-manager-div">
		<h3>The documentation features were just added 2/8/2014, and we hope to fill them in over time.  
		For now, if you need help that isn't here, please contact the web developer for assistance.</h3>
		<div style="width:100%; float:left; text-align:right;"><a href="##" onclick="window.print();">Print</a></div>
		<p>This guide attempts to introduce you to the most commonly used web site management features.</p>
		<h2>Content Manager</h2>
		<h3>Manage Pages</h3>

		<h3>Add A Page</h3>
		<h2>Files &amp; Images</h2>
		<h3>Add A File</h3>
		<p></p>
		<h3>Add An Image</h3>
		<p></p>

		<h2>Manage Blog</h2>
		<h3>Add A Blog Category</h3>
		<p>The first time you use the blog, you will be required to create a category. 
		Articles are associated with categories, and this lets you create additional links on your site to group related content together.</p>
		<h3>Add A Blog Article</h3>
		<h3>Manage Blog Articles</h3>

		<h2>Manage Leads</h2>
		<h3>Lead Routing</h3>
		<p>The system generates an email with the full information provided by the prospect when an inquiry form is submitted on the web site.</p>
		<p>The system allows you to route these emails to different users or email addresses.</p>
		<p>To change the lead routing configuration, use the menu to go to: Manage Leads -> <a href="/z/inquiries/admin/routing/index">Lead Routing</a>.</p>
		<p>On this page, you'll be able to click a link to edit the "Office Email" at the bottom of the Content Manager -> <a href="/z/admin/site-options/index">Site Options</a> page, or add individual routes for specific types of leads.</p>
		<p>If you have a variety of departments within your organization, the lead routing tool can help you make sure that incoming requests go directly to the correct people.</p>
		<p>The system comes with a variety of built-in lead types depending on the features the web site has enabled, but additional forms and lead types can be added.</p>

		<h3>Add A Lead</h3>
		<p>In addition to collecting leads through forms on your web site, it is also possible to manually add a lead.</p>
		<p>You may want to do this for leads that come via the phone, email or in-person meetings you have throughout the day so your team is able to share the information, make notes, and add replies through one system.</p>
		<p>Keeping all your leads and notes in one place is easy thanks to this feature.</p>
		<p>To add a lead, go to the menu: Manage Leads -> <a href="/z/inquiries/admin/inquiry/add">Add Lead</a>.</p>
		<h3>Assign A Lead</h3>
		<p></p>
		<h3>Export Mailing List</h3>
		<h3>Export Leads</h3>
		<h3>Close A Lead</h3>
		<h3>View Lead</h3>

		<h2>Manage Users</h2>
		<p>It is possible to add additional users to manage the web site, with limited access to information.</p>
		<p>You can also create public profiles for members of your organization, to have a nice public page for them.</p>
		<h3>Add User</h3>
		<h3>Limiting Access</h3>
		<h3>Making A Public Profile</h3>
		<h3>Public Users</h3>
		<p>When users create an account on your web site, you will be able to manage their account by clicking 
		on the "View Public Users" link on the Users -> <a href="/z/admin/member/index">Manage Users</a> page.</p>
	</div>
</cffunction>

<cffunction name="docs" access="remote" localmode="modern" roles="member">
	<cfscript>
	application.zcore.template.setTag("title", "Documentation");
	application.zcore.template.setTag("pagetitle", "Documentation");

	// integrate jetendo manual here.
	</cfscript>

</cffunction>

<cffunction name="support" access="remote" localmode="modern" roles="member">
	<cfscript>
	application.zcore.template.setTag("title", "Support");
	application.zcore.template.setTag("pagetitle", "Support");

	// output information from the vendor record later
	</cfscript>
	<p>We are available to provide support for your web site.</p>
	
</cffunction>


<cffunction name="incontext" access="remote" localmode="modern" roles="member">
	<cfscript>
	application.zcore.template.setTag("title", "In-context Help Features");
	application.zcore.template.setTag("pagetitle", "In-context Help Features");
	</cfscript>
	<p>We try to make the application intuitive by providing help tips directly next to the features throughout the software.</p>
	<h2>Tooltips</h2>
	<p><!--- SCREENSHOT OF TOOLTIP ICON:  --->You can rollover or click on a tooltip to display a description of what that feature is intended to do.</p>
	<!--- <h2>Sorting</h2>
	<p><!--- SCREENSHOT OF SORT ICONS:  --->These icons are used to move records up or down in their position.  
	Use these arrows to change the order of photos in a slideshow, or the order of links on a menu depending on the feature you use them on.</p> --->
	<h2>Help for this page</h2>
	<p><!--- SCREENSHOT OF HELP FOR THIS PAGE MENU:  --->To help you find the documentation for the page you are on, we have integrated the help system directly into the manager. 
	If you see go to Help -> Help For This Page, you will be taken directly to a new window with the documentation for that page.</p>
	<h2>Descriptions on the page</h2>
	<p>Make sure you read all the text on the page, we often write important tips for helping you understand how the features work.</p>
</cffunction>

</cfoutput>
</cfcomponent>