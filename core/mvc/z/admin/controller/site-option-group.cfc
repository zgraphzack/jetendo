<cfcomponent>
<cfoutput>
 
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var theTitle=0;
	variables.allowGlobal=false;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
	if(application.zcore.user.checkServerAccess()){
		variables.allowGlobal=true;
		variables.siteIdList="'0','"&request.zos.globals.id&"'";
	}
	if(structkeyexists(form,'return') and structkeyexists(form,'site_option_group_id') and request.zos.CGI.HTTP_REFERER NEQ ""){
		StructInsert(request.zsession, "site_option_group_return"&form.site_option_group_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	if(not application.zcore.functions.zIsWidgetBuilderEnabled()){
		application.zcore.functions.z301Redirect('/member/');
	}
	theTitle="Manage Site Option Groups";
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
	
	this.displayoptionAdminNav();
	</cfscript>
</cffunction>


<cffunction name="displayoptionAdminNav" access="public" localmode="modern">
	<cfscript>
	
	form.site_option_app_id=application.zcore.functions.zso(form, 'site_option_app_id',false,0);
	if(form.site_option_app_id NEQ 0){
		application.zcore.template.setTemplate("zcorerootmapping.templates.blank",true,true);
	}
	</cfscript>
	<table style="border-spacing:0px;width:100%;" class="table-list">
		<tr>
			<th><a href="/z/admin/site-options/index?site_option_app_id=#form.site_option_app_id#">Site Options</a></th>
			<th style="text-align:right;"><strong>Developer Tools:</strong> 
				<cfif application.zcore.user.checkServerAccess()>
					<a href="/z/admin/site-options/searchReindex">Search Reindex</a> | 
				</cfif>
			<a href="/z/admin/sync/index">Sync</a> | 
			<a href="/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#">Options</a> | 
			<a href="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#">Groups</a> | 
			Add: <a href="/z/admin/site-options/add?site_option_app_id=#form.site_option_app_id#&amp;return=1">Option</a> | 
			<a href="/z/admin/site-option-group/add?site_option_app_id=#form.site_option_app_id#&amp;return=1">Group</a></th>
		</tr>
	</table>
	<br />
</cffunction>

<cffunction name="generateGroupCode" access="remote" localmode="modern">
	<cfargument name="groupId" type="numeric" required="yes"> 
	<cfargument name="parentIndex" type="numeric" required="yes"> 
	<cfargument name="parentGroupId" type="numeric" required="yes"> 
	<cfargument name="sharedStruct" type="struct" required="yes"> 
	<cfargument name="depth" type="numeric" required="yes"> 
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
	ss=arguments.sharedStruct;
	if(not structkeyexists(ss, 'curIndex')){
		ss.curIndex=arguments.parentIndex;
	}else{
		ss.curIndex++;
	}
	t9=application.zcore.siteGlobals[request.zos.globals.id].soGroupData;
	indent="";
	for(i=1;i LTE arguments.depth;i++){
		indent&=chr(9);
	}

	for(i in t9.optionGroupLookup){
		groupStruct=t9.optionGroupLookup[i];
		if(arguments.groupID NEQ 0 and arguments.groupID NEQ groupStruct.site_option_group_id){
			continue;
		}
		if(arguments.parentGroupID NEQ groupStruct.site_option_group_parent_id){ 	
			continue;
		}
		echo(chr(10)&indent&"<h2>Group: "&groupStruct.site_option_group_display_name&'</h2>'&chr(10));
		if(groupStruct.site_option_group_parent_id NEQ 0){
			parentGroupStruct=t9.optionGroupLookup[groupStruct.site_option_group_parent_id];
			echo(indent&'<cfscript>arr#ss.curIndex#=application.zcore.siteOptionCom.optionGroupStruct("#groupStruct.site_option_group_name#", 0, request.zos.globals.id, curStruct#arguments.parentIndex#);</cfscript>'&chr(10));
		}else{
			echo(indent&'<cfscript>arr#ss.curIndex#=application.zcore.siteOptionCom.optionGroupStruct("#groupStruct.site_option_group_name#");</cfscript>'&chr(10));
		}
		echo(indent&'<cfloop from="1" to="##arrayLen(arr#ss.curIndex#)##" index="i#ss.curIndex#">#chr(10)&indent&chr(9)#<cfscript>curStruct#ss.curIndex#=arr#ss.curIndex#[i#ss.curIndex#];</cfscript>#chr(10)#');
			for(n in t9.optionGroupFieldLookup[groupStruct.site_option_group_id]){
				optionStruct=t9.optionLookup[n];
				echo(indent&chr(9)&'##curStruct#ss.curIndex#["'&replace(replace(optionStruct.site_option_name, "##", "####", "all"), '"', '""', 'all')&'"]##<br />'&chr(10));
			}
			if(groupStruct.site_option_group_enable_unique_url EQ 1){
				echo(indent&chr(9)&'<a href="##curStruct#ss.curIndex#.__url##">View</a><br />'&chr(10));
			}
			if(groupStruct.site_option_group_enable_approval EQ 1){
				echo(indent&chr(9)&'<cfif curStruct#ss.curIndex#.__approved>Approved<cfelse>Not Approved</cfif><br />'&chr(10));
			}
			if(groupStruct.site_option_group_enable_image_library EQ 1){
				echo(indent&chr(9)&'<cfscript>'&chr(10));
				echo(indent&chr(9)&'if(structkeyexists(curStruct#ss.curIndex#, ''__image_library_id'')){'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts={};'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts.output=false;'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts.size="640x400";'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts.layoutType="";'&chr(10)); 
				echo(indent&chr(9)&chr(9)&'ts.image_library_id=curStruct#ss.curIndex#.__image_library_id;'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts.forceSize=true;'&chr(10)); 
				echo(indent&chr(9)&chr(9)&'ts.crop=0;'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts.offset=0;'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts.limit=0; // zero will return all images'&chr(10)); 
				echo(indent&chr(9)&chr(9)&'var arrImage=request.zos.imageLibraryCom.displayImages(ts);'&chr(10));
				echo(indent&chr(9)&'}else{'&chr(10));
				echo(indent&chr(9)&chr(9)&'arrImage=[];'&chr(10));
				echo(indent&chr(9)&'}'&chr(10));
				echo(indent&chr(9)&'for(i=1;i LTE arrayLen(arrImage);i++){'&chr(10));
				echo(indent&chr(9)&chr(9)&'echo(''<img src="##arrImage[i].link##" alt="##htmleditformat(arrImage[i].caption)##" /><br />'');'&chr(10));
				echo(indent&chr(9)&'}'&chr(10));
				echo(indent&chr(9)&'</cfscript>'&chr(10));
			}
			savecontent variable="childOutput"{
				generateGroupCode(0, ss.curIndex, groupStruct.site_option_group_id, arguments.sharedStruct, arguments.depth+2);
			}
			childOutput=trim(childOutput);
			if(len(childOutput)){
				echo(indent&chr(9)&'<h3>Child Groups:</h3>'&chr(10)&indent&chr(9)&chr(9)&childOutput&chr(10));
			}
		echo(indent&'</cfloop><hr />'&chr(10));
		ss.curIndex++;
	}
	</cfscript>
</cffunction>


<cffunction name="displayGroupCode" access="remote" localmode="modern" roles="member"> 
	<cfscript>
	application.zcore.functions.zSetPageHelpId("2.7.1.3");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
	request.zos.whiteSpaceEnabled=true;
	application.zcore.template.setPlainTemplate();
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id', true, 0);
	form.site_option_group_parent_id=application.zcore.functions.zso(form, 'site_option_group_parent_id', true, 0);
	
	echo('<div style="width:98% !important; float:left;margin:1%;">');
	echo('<h2>Source code generated below.</h2>
	<p>Note: searchOptionGroup retrieves all the records.  If "Enable Memory Caching" is disabled for the group, it will perform a query to select all the data.  This can be very slow if you are working with hundreds or thousands of records and it may cause nested queries to run if the sub-groups also have "Enable Memory Caching" disabled.   Conversely, for small datasets, this feature is much faster then running a query.</p>
	');
	echo('<textarea name="a222" cols="100" rows="30" style="width:100%;">');
	savecontent variable="output"{
		generateGroupCode(form.site_option_group_id, 1, form.site_option_group_parent_id, {}, 0);
		
		
	t9=application.zcore.siteGlobals[request.zos.globals.id].soGroupData;
		groupStruct=t9.optionGroupLookup[form.site_option_group_id];
		if(groupStruct.site_option_group_enable_unique_url EQ 1){
		echo('Below is an example of a CFC that is used for making a custom page, search result, and search index for a site_x_option_group_set record.
<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern">
	<cfargument name="query" type="query" required="yes">
	<cfscript>
	struct=application.zcore.siteOptionCom.getOptionGroupSetById(["Group", "SubGroup"], arguments.query.site_x_option_group_set_id);
	writedump(struct);
	
	application.zcore.template.setTag("title", struct.__title);
	application.zcore.template.setTag("pagetitle", struct.__title);
	</cfscript>
</cffunction>

<cffunction name="searchResult" access="public" roles="member" localmode="modern">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	// output the search result html
	</cfscript>
</cffunction>

<cffunction name="searchReindex" access="public" roles="member" localmode="modern">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="tableStruct" type="struct" required="yes">
	<cfscript>
	// map dataStruct custom fields to the tableStruct search fields.
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>');
		}
	}
	echo(trim(output));
	echo('</textarea>
	<div style="width:100%; float:left; padding-top:10px;">
	<h2>Miscellaneous Code</h2>
	<p>To select a single group set, use one of the following:</p>
	<ul>
	<li>Memory Cache Enabled: struct=application.zcore.siteOptionCom.getOptionGroupSetById(["Group", "SubGroup"], site_x_option_group_set_id);</li>
	<li>Memory Cache Disabled: showUnapproved=false; struct=application.zcore.siteOptionCom.getOptionGroupSetByID(["Group", "SubGroup"], site_x_option_group_set_id, request.zos.globals.id, showUnapproved); </li>
	</ul>');
	if(groupStruct.site_option_group_allow_public NEQ 0){
		if(groupStruct.site_option_group_public_form_url NEQ ""){
			link=groupStruct.site_option_group_public_form_url;
		}else{
			link='/z/misc/display-site-option-group/add?site_option_group_id=#groupStruct.site_option_group_id#';
		}
		link=application.zcore.functions.zURLAppend(link, 'modalpopforced=1');
		echo('<h2>Iframe Embed Code</h2><pre>'&htmlcodeformat('<iframe src="'&link&'" frameborder="0"  style=" margin:0px; border:none; overflow:auto;" seamless="seamless" width="100%" height="500" />')&'</pre>');
		echo('<h2>CFML Embed Form Code</h2><pre>'&htmlcodeformat('
application.zcore.functions.zheader("x_ajax_id", application.zcore.functions.zso(form, "x_ajax_id"));
// Note: if this group is a child group, you must update the array below to have the parent groups as well.
form.site_option_group_id=application.zcore.siteOptionCom.getOptionGroupIDWithNameArray(["#groupstruct.site_option_group_name#"]);
displayGroupCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.misc.controller.display-site-option-group");
displayGroupCom.add();')&'</pre>');
	}
	echo('<h2>Alternative Group Search Method</h2>
	<p>application.zcore.siteOptionCom.searchOptionGroup(); can also be used to filter records with SQL-LIKE object input.</p>
	<p>By default, all records are looped & compared in memory with a single thread, so be aware that it may take a lot of CPU time with a larger database.</p>
	<p>When working with hundreds or thousands of records, you can achieve better performance & reduced memory usage with the database based search method that is built in to searchOptionGroup.  It translates the structured input array into an efficient SQL query that returns only the records you select.  To switch to using database queries for searchOptionGroup, you only need to disable "Enable Memory Caching" on the edit group form.  Keep in mind the sub-groups have their own "Enable Memory Caching" setting which you may want to enable or disable.</p>
	<p>Even when memory cache is disabled queries are only necessary to retrieve data value because the schema information is still cached in memory.</p>
	<p>Simple Example with fake group/field info:</p>
	<pre>
	
	groupName="groupName";
	// build search as an array of structs.  Supports nested sub-group search, AND/OR, logic grouping, many operators, and multiple values.  See the function definition of searchOptionGroup for more information.
	arrSearch=[{
		type="=",
		field: "Title",
		arrValue:["Title1"]	
	}
	];
	parentGroupId=0;
	showUnapproved=true;
	offset=0;
	limit=10;
	// perform search and return struct with array of structs and whether or not there are more records.
	rs=application.zcore.siteOptionCom.searchOptionGroup(groupName, arrSearch, parentGroupId, showUnapproved, offset, limit);
	if(arraylen(rs.arrResult)){
		for(i=1;i LTE arraylen(rs.arrResult);i++){
			c=rs.arrResult[i];
			echo(c["Title"]&"&lt;br /&gt;");
		}
		if(rs.hasMoreRecords){
			// show next button
		}
	}
	</pre></div></div>
	');
	
	</cfscript>
</cffunction>

<cffunction name="help" access="remote" localmode="modern" roles="member"> 
	<cfscript>
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id', true, 0);
	
	t9=application.zcore.siteGlobals[request.zos.globals.id].soGroupData; 
	for(i in t9.optionGroupLookup){
		groupStruct=t9.optionGroupLookup[i];
		if(form.site_option_group_id NEQ 0 and form.site_option_group_id NEQ groupStruct.site_option_group_id){
			continue;
		} 
		echo("<h2>"&groupStruct.site_option_group_display_name&'(s) Help Page</h2>'&chr(10));
		echo('<div style="width:100%; float:left; padding-bottom:10px;">'&groupStruct.site_option_group_help_description&'</div>');
		echo('<div style="width:100%; float:left; padding-bottom:10px;"><h2>Fields</h2>
		<table class="table-list">');
		ss={};
		for(n in t9.optionGroupFieldLookup[groupStruct.site_option_group_id]){
			ss[n]=t9.optionLookup[n];
		}
		arrKey=structsort(ss, "text", "asc", "site_option_name");
		for(n=1;n LTE arraylen(arrKey);n++){
			optionStruct=t9.optionLookup[arrKey[n]];
			echo('<tr>');
			echo('<th style="width:150px; ">#htmleditformat(optionStruct.site_option_name)#</th><td>');
			if(optionStruct.site_option_tooltip EQ ""){
				echo('No help available.');
			}else{
				echo(optionStruct.site_option_tooltip);
			}
			echo('</td></tr>');
			
		}
		echo('</table></div>');
		
	}
	</cfscript>
</cffunction>


<cffunction name="saveMapFields" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);	
	for(local.i=1;local.i LTE form.fieldcount;local.i++){
		form.site_option_id=application.zcore.functions.zso(form, 'option'&local.i);
		form.mapField=application.zcore.functions.zso(form, 'mapField'&local.i);
		if(form.mapField NEQ ""){
			db.sql="INSERT INTO #db.table("site_option_group_map", request.zos.zcoredatasource)# 
			SET site_option_group_map_updated_datetime = #db.param(request.zos.mysqlnow)#, 
			site_option_id=#db.param(form.site_option_id)#,
			site_option_group_map_fieldname=#db.param(form.mapField)#,
			site_option_group_id=#db.param(form.site_option_group_id)#, 
			site_id=#db.param(request.zos.globals.id)#, 
			site_option_group_map_deleted=#db.param(0)#
			";
			db.execute("qInsert");
		}
	}
	db.sql="delete from #db.table("site_option_group_map", request.zos.zcoredatasource)# 
	where site_option_group_id=#db.param(form.site_option_group_id)# and 
	site_option_group_map_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	site_option_group_map_updated_datetime < #db.param(request.zos.mysqlnow)#";
	db.execute("qDelete");
	application.zcore.status.setStatus(request.zsid, "Map fields saved.");
	application.zcore.functions.zRedirect("/z/admin/site-option-group/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="export" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>

	content type="text/plain";
	setting requesttimeout="10000";
	var db=request.zos.queryObject;
	currentGroupId=application.zcore.functions.zso(form, 'site_option_group_id'); 
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_option_group_id = #db.param(currentGroupId)# and 
	site_option_group_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Site option group no longer exists.", form, true);
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&zsid=#request.zsid#");
	}
	header name="Content-Disposition" value="attachment; filename=#dateformat(now(), "yyyy-mm-dd-")&qGroup.site_option_group_name#.csv";
	optionCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");

	db.sql="SELECT * FROM  
	#db.table("site_option", request.zos.zcoreDatasource)# WHERE 
	site_option.site_option_group_id = #db.param(currentGroupId)# and  
	site_option_deleted = #db.param(0)# and 
	site_option.site_id = #db.param(request.zos.globals.id)#  
	ORDER BY site_option_sort ASC";
	qOption=db.execute("qOption");
	arrOption=[];
	arrRowDefault=[];
	optionStruct={};
	first=true;
	for(row in qOption){
		arrayAppend(arrRowDefault, "");
		arrayAppend(arrOption, row.site_option_name);
		v=replace(replace(replace(replace(replace(row.site_option_name, chr(10), ' ', 'all'), chr(13), '', 'all'), chr(9), ' ', 'all'), '\', '\\', 'all'), '"', '\"', "all");
		if(not first){
			echo(", ");
		}
		first=false;
		echo('"'&v&'"');
		optionStruct[row.site_option_id]=arraylen(arrOption);
	}
	echo(chr(13)&chr(10));

	doffset=0;
	for(i=1;i LTE 100000;i++){

		// process x groups at a time.
		xlimit=20;

		db.sql="SELECT * FROM #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# 
		WHERE site_option_group_id = #db.param(currentGroupId)# and 
		site_x_option_group_set_master_set_id = #db.param(0)# and 
		site_x_option_group_set_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# 
		LIMIT #db.param(doffset)#, #db.param(xlimit)#";
		qGroups=db.execute("qGroups");
		if(qGroups.recordcount EQ 0){
			break;
		}
		doffset+=xlimit;

		for(row in qGroups){
			db.sql="SELECT * FROM 
			#db.table("site_x_option_group", request.zos.zcoreDatasource)# 
			WHERE  
			site_x_option_group.site_option_group_id = #db.param(currentGroupId)# and 
			site_x_option_group_set_id = #db.param(row.site_x_option_group_set_id)# and 
			site_x_option_group_deleted = #db.param(0)# and 
			site_x_option_group.site_id = #db.param(request.zos.globals.id)#  ";
			qValues=db.execute("qValues");
 

			arrRow=duplicate(arrRowDefault);
			for(value in qValues){
				if(structkeyexists(optionStruct, value.site_option_id)){
					offset=optionStruct[value.site_option_id];
					arrRow[offset]=value.site_x_option_group_value;
				}
			}
			for(i2=1;i2 LTE arraylen(arrRow);i2++){
				if(i2 NEQ 1){
					echo(', ');
				}
				v=rereplace(replace(replace(replace(replace(replace(arrRow[i2], chr(10), ' ', 'all'), chr(13), '', 'all'), chr(9), ' ', 'all'), '\', '\\', 'all'), '"', '\"', "all"), '<.*?>', '', 'all');
				echo('"'&v&'"');
			}
			echo(chr(13)&chr(10));
		}
	}
	abort;
	</cfscript>
</cffunction>

<cffunction name="reindex" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var qGroup=0;
	var ts=0;
	var db=request.zos.queryObject;
	var row=0;
	var qOption=0;
	setting requesttimeout="10000";
	currentGroupId=application.zcore.functions.zso(form, 'site_option_group_id'); 
	form.site_option_app_id=application.zcore.functions.zso(form, 'site_option_app_id');
	variables.init();
	// get group
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_option_group_id = #db.param(currentGroupId)# and 
	site_option_group_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Site option group no longer exists.", form, true);
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&zsid=#request.zsid#");
	}
	optionCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");

	doffset=0;
	for(i=1;i LTE 100000;i++){

		// process x groups at a time.
		xlimit=20;

		db.sql="SELECT * FROM #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# 
		WHERE site_option_group_id = #db.param(currentGroupId)# and 
		site_x_option_group_set_deleted = #db.param(0)# and 
		site_x_option_group_set_master_set_id = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# 
		LIMIT #db.param(doffset)#, #db.param(xlimit)#";
		qGroups=db.execute("qGroups");
		if(qGroups.recordcount EQ 0){
			break;
		}
		doffset+=xlimit;

		for(row in qGroups){
			db.sql="SELECT * FROM 
			#db.table("site_x_option_group", request.zos.zcoreDatasource)#,
			#db.table("site_option", request.zos.zcoreDatasource)# 
			WHERE 
			site_option.site_option_id = site_x_option_group.site_option_id and 
			site_option.site_id = site_x_option_group.site_id and 
			site_option_deleted = #db.param(0)# and 
			site_x_option_group.site_option_group_id = #db.param(currentGroupId)# and 
			site_x_option_group_set_id = #db.param(row.site_x_option_group_set_id)# and 
			site_x_option_group_deleted = #db.param(0)# and 
			site_x_option_group.site_id = #db.param(request.zos.globals.id)#  ";
			qValues=db.execute("qValues");

			structclear(form);


			ts={};
			for(value in qValues){
				ts[value.site_option_name]=value.site_x_option_group_value;
				//form['newvalue'&value.site_option_id]=form[value.site_x_option_group_value];
			}
			// get all site options with label and value for current row.

			//throw("warning: this will delete unique url and image gallery id - because internalGroupUpdate is broken.");

			arrGroupName =application.zcore.siteOptionCom.getOptionGroupNameArrayById(qGroup.site_option_group_id); 
			application.zcore.siteOptionCom.setOptionGroupImportStruct(arrGroupName, 0, 0, ts, form); 
			structappend(form, row, true);
			// writedump(form);abort;
 
			rs=optionCom.internalGroupUpdate(); 
			if(not rs.success){
				writedump(rs);
				writedump(ts);
				writedump(form);
				application.zcore.functions.zStatusHandler(rs.zsid);
				abort;
			} 
		}
	}
	application.zcore.status.setStatus(request.zsid, "Group, ""#qGroup.site_option_group_name#"", was reprocessed successfully.");
	application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="mapFields" localmode="modern" access="remote" roles="member">
	<cfscript>
	var qGroup=0;
	var ts=0;
	var db=request.zos.queryObject;
	var row=0;
	var qOption=0;
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id'); 
	variables.init();
	// get group
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Site option group no longer exists.", form, true);
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&zsid=#request.zsid#");
	}
	echo("<h2>Map Fields For Site Option Group: #qGroup.site_option_group_display_name#</h2>");
	
	if(qGroup.site_option_group_map_group_id NEQ 0){
		db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# 
		WHERE site_option_group_id = #db.param(qGroup.site_option_group_map_group_id)# and 
		site_option_group_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		qMapGroup=db.execute("qMapGroup");
		if(qMapGroup.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "You must add an option to the group before you can use this feature.", form, true);
			application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&zsid=#request.zsid#");
		}
		echo("<p>Mapping to Site Option Group: ""#qMapGroup.site_option_group_display_name#""</p>");
	}else{
		echo("<p>Mapping to Inquiries Table.</p>");
	}
	db.sql="SELECT * FROM #db.table("site_option_group_map", request.zos.zcoreDatasource)# 
	WHERE site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_map_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	local.qMap=db.execute("qMap");
	local.mapStruct={};
	for(row in local.qMap){
		local.mapStruct[row.site_option_id]=row.site_option_group_map_fieldname;
	}
	db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# 
	WHERE site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	site_option_deleted = #db.param(0)#
	ORDER BY site_option_sort ASC";
	qOption=db.execute("qOption");
	
	mappingEnabled=true;
	if(qGroup.site_option_group_map_fields_type EQ "2"){ // group
		// get second group
		db.sql="SELECT site_option_display_name, site_option_id FROM #db.table("site_option", request.zos.zcoreDatasource)# 
		WHERE site_option_group_id = #db.param(qGroup.site_option_group_map_group_id)# and 
		site_option_deleted = #db.param(0)# and
		site_id = #db.param(request.zos.globals.id)# and
		site_option_allow_public = #db.param(1)#
		ORDER BY site_option_display_name";
		local.qOption2=db.execute("qOption2"); 
		if(local.qOption2.recordcount EQ 0){
			mappingEnabled=false;
			writeoutput('No site options in the mapped group, "#qMapGroup.site_option_group_display_name#",  are set to "allow public" = "yes".  Make at least 1 field public to allow this feature to be used.');
		}
		local.arrLabel=[];
		local.arrValue=[];
		for(row in local.qOption2){
			arrayAppend(local.arrLabel, row.site_option_display_name);
			arrayAppend(local.arrValue, row.site_option_id);
		}
		local.labels=arrayToList(local.arrLabel, chr(9));
		local.values=arrayToList(local.arrValue, chr(9));
	
	}else if(qGroup.site_option_group_map_fields_type EQ "1"){ // inquiries
		// get fields in inquiries
		// manually remove sensitive ones
		// structdelete
		// force some default values for new table
		local.tempColumns=duplicate(application.zcore.tableColumns["#request.zos.zcoreDatasource#.inquiries"]);
		//writedump(local.tempColumns);
		local.arrTemp=structkeyarray(local.tempColumns);
		arraySort(local.arrTemp, "text", "asc");
		local.labels="inquiries_custom_json"&chr(9)&arrayToList(local.arrTemp, chr(9));
		local.values=local.labels;
		
	}else{
		application.zcore.functions.z404("qGroup.site_option_group_map_fields_type: "&qGroup.site_option_group_map_fields_type&" is invalid");
	}

	local.index=1;
	if(mappingEnabled){
		writeoutput('<p>Map as many fields as you wish. You can map an option to the same field multiple times to automatically combine those values.</p>
			<p>To save time, try clicking <a href="##" class="zOptionGroupAutoMap">auto-map</a> first.</p>
		<form id="optionGroupMapForm" action="/z/admin/site-option-group/saveMapFields?site_option_group_id=#form.site_option_group_id#" method="post">
		<table class="table-list"><tr><th>Option Field</th><th>Map To Field</th></tr>');
		for(row in qOption){
			writeoutput('<tr><td><input type="hidden" name="option#local.index#" value="#row.site_option_id#" /><div id="fieldLabel#local.index#" class="fieldLabelDiv" data-id="#local.index#">'&htmleditformat(row.site_option_display_name)&'</div></td><td>');
			if(structkeyexists(local.mapStruct, row.site_option_id)){
				form["mapField"&local.index]=local.mapStruct[row.site_option_id];
			}
			ts = StructNew();
			ts.name = "mapField"&local.index;
			// options for list data
			ts.listLabels =local.labels;
			ts.listValues = local.values;
			ts.listLabelsDelimiter = chr(9);
			ts.listValuesDelimiter = chr(9);
			
			application.zcore.functions.zInputSelectBox(ts);
			
			writeoutput('</td></tr>');
			local.index++;
		}
		writeoutput('</table><br /><br />
		<input type="hidden" name="fieldcount" value="#local.index-1#" />
		<input type="submit" name="submit1" value="Save" /> 
		<input type="button" name="cancel1" value="Cancel" onclick="window.location.href=''/z/admin/site-option-group/index'';" />
		</form>');
	}
	</cfscript>
</cffunction>

<cffunction name="copyGroupForm" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=0;

	application.zcore.functions.zSetPageHelpId("2.7.1.2");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
	where site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	local.qGroup=db.execute("qGroup");
	if(local.qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid site option group.", form, true);
		application.zcore.functions.zRedirect('/z/admin/site-option-group/index?zsid=#request.zsid#');	
	}
	</cfscript>
	<h2>Copy Group: #local.qGroup.site_option_group_display_name#</h2>
	<p>Please note that the "select menu" type, and group / inquiries mapping data are not copied.  You will need to verify those are setup correctly after copying this site option group.</p>
	<form action="/z/admin/site-option-group/copyGroup" method="post">
		<input type="hidden" name="site_option_group_id" value="#form.site_option_group_id#" />
		<table style="border-spacing:0px; padding:5px;">
			<tr>
			<td>New Site</td>
			<td><!--- get sites --->
				<cfscript>
				application.zcore.functions.zGetSiteSelect('newsiteid');
				</cfscript>
			</td>
			</tr>
			<tr>
			<td>New Group Name</td>
			<td><cfscript>
				ts=StructNew();
				ts.name="newGroupName";
				ts.size=50;
				application.zcore.functions.zInput_Text(ts);
				</cfscript> (Leave blank to keep it the same)
			</td>
			</tr>
			<!--- <tr>
			<td>Copy Data?</td>
			<td>#application.zcore.functions.zInput_Boolean("copyData")#
			</td>
			</tr> --->
			<tr><td>&nbsp;</td>
			<td>
				<input type="submit" name="submit1" value="Copy" /> 
				<input type="button" name="cancel1" value="Cancel" onclick="window.location.href='/z/admin/site-option-group/index';" />
			</td></tr>
		</table>
	</form>
</cffunction>


<cffunction name="copyGroupRecursive" localmode="modern" access="public" roles="member">
	<cfargument name="site_option_group_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="rowStruct" type="struct" required="yes">
	<cfargument name="groupStruct" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var row=arguments.rowStruct;
	var row2=0;
	var ts=0;
	// 
	
	// TODO: we would need to guarantee inquiries_type_id is cloned first by checking for same new on the new site - then i could copy the map table too.  For now, it just removes these.
	row.inquiries_type_id=0;
	row.inquiries_type_id_siteIDType=0;
	row.site_option_group_map_group_id=0;
	row.site_id = arguments.site_id;
	ts=structnew();
	ts.struct=row;
	ts.datasource=request.zos.zcoreDatasource;
	ts.table="site_option_group";
	local.newoptionGroupId=application.zcore.functions.zInsert(ts);
	arguments.groupStruct[arguments.site_option_group_id]=local.newoptionGroupId;
	db.sql="select * from #db.table("site_option", request.zos.zcoredatasource)# 
	where site_id = #db.param(request.zos.globals.id)# and 
	site_option_deleted = #db.param(0)# and
	site_option_group_id = #db.param(arguments.site_option_group_id)# ";
	local.qOptions=db.execute("qOptions");
	for(row2 in local.qOptions){
		row2.site_id=arguments.site_id;
		row2.site_option_group_id=local.newoptionGroupId;
		// row2.site_option_appidlist     
		ts=structnew();
		ts.struct=row2;
		ts.datasource=request.zos.zcoreDatasource;
		ts.table="site_option";
		local.newoptionId=application.zcore.functions.zInsert(ts);
		arguments.optionStruct[row2.site_option_id]=local.newoptionId;
	}
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
	where site_option_group_parent_id = #db.param(arguments.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	local.qGroup=db.execute("qGroup");
	for(row in local.qGroup){
		row.site_option_group_parent_id=local.newoptionGroupId;
		this.copyGroupRecursive(row.site_option_group_id, arguments.site_id, row, arguments.groupStruct, arguments.optionStruct);
	}
	</cfscript>
</cffunction>

<cffunction name="copyGroup" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	var row2=0;
	var ts=0;
	var optionStruct={};
	var groupStruct={};
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);	
	form.newGroupName=application.zcore.functions.zso(form, 'newGroupName');
	form.newSiteId=application.zcore.functions.zso(form, 'newSiteId', true, 0);
	if(form.newSiteId EQ 0){
		form.newSiteId=request.zos.globals.id;
	}
	form.copyData=application.zcore.functions.zso(form, 'copyData', true, 0);
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id', true, 0); 
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
	where site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	local.qGroup=db.execute("qGroup");
	if(local.qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid site option group.", form, true);
		application.zcore.functions.zRedirect('/z/admin/site-option-group/index?zsid=#request.zsid#');	
	} 
	for(row in local.qGroup){
		if(form.newGroupName NEQ ""){
			row.site_option_group_name=form.newGroupName;
			row.site_option_group_display_name=form.newGroupName;
		}
		this.copyGroupRecursive(form.site_option_group_id, form.newSiteId, row, groupStruct, optionStruct);
	}
	application.zcore.functions.zOS_cacheSiteAndUserGroups(form.newSiteId);
		
	application.zcore.status.setStatus(request.zsid, "Site Option Group Copied.");
	application.zcore.functions.zRedirect("/z/admin/site-option-group/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="generateTableFromGroup" localmode="modern" access="remote" roles="member">
	<cfargument name="site_option_group_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	var row2=0;
	var dbNoVerify=request.zos.noVerifyQueryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
	local.arrSQL=[];
	db.sql="select * from #db.table("site_option_group", request.zos.zcoredatasource)# WHERE 
	site_option_group_id = #db.param(arguments.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	local.qGroup=db.execute("qGroup");
		
	db.sql="select * from #db.table("site_option", request.zos.zcoredatasource)# WHERE 
	site_option_group_id = #db.param(arguments.site_option_group_id)# and 
	site_option_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	local.qOption=db.execute("qOption");

	if(local.qGroup.recordcount EQ 0 or local.qOption.recordcount EQ 0){
		return;
	}
	
	local.optionLookup={};
	for(row in local.qOption){
		local.optionLookup[row.site_option_id]={
			type:row.site_option_type_id,
			name:row.site_option_name
		};
		if(row.site_option_type_id EQ 0){
			local.sqlType="varchar(255) NOT NULL";
		}else if(row.site_option_type_id EQ 1){
			local.sqlType="text NOT NULL";
		}else if(row.site_option_type_id EQ 2){
			local.sqlType="longtext NOT NULL";
		}else if(row.site_option_type_id EQ 3){
			local.sqlType="varchar(255) NOT NULL";
		}else if(row.site_option_type_id EQ 4){
			local.sqlType="datetime NOT NULL";
		}else if(row.site_option_type_id EQ 5){
			local.sqlType="date NOT NULL";
		}else if(row.site_option_type_id EQ 6){
			local.sqlType="time NOT NULL";
		}else if(row.site_option_type_id EQ 7){
			local.sqlType="varchar(255) NOT NULL";
		}else if(row.site_option_type_id EQ 8){
			local.sqlType="varchar(255) NOT NULL";
		}else if(row.site_option_type_id EQ 9){
			local.sqlType="varchar(255) NOT NULL";
		}else if(row.site_option_type_id EQ 10){
			local.sqlType="varchar(255) NOT NULL";
		}else if(row.site_option_type_id EQ 11){
			continue;
		}
		arrayappend(local.arrSQL, "`"&row.site_option_name&"` #local.sqlType# ");
	}
	arrayappend(local.arrSQL, "
	`_title` varchar(255) NOT NULL,
	`_sort` int(11) unsigned NOT NULL DEFAULT '0',
	`_active` int(11) unsigned NOT NULL DEFAULT '0',
	`_parent_id` int(11) unsigned NOT NULL DEFAULT '0',
	`_app_id` int(11) unsigned NOT NULL DEFAULT '0',
	`_url` varchar(255) NOT NULL,
	`_image_library_id` int(11) unsigned NOT NULL DEFAULT '0',
	`_set_id` int(11) unsigned NOT NULL DEFAULT '0',
	`_approved` char(1) NOT NULL DEFAULT '1'");
	arrayappend(local.arrSQL, "PRIMARY KEY (`_set_id`)");
  	// KEY `NewIndex1` (`site_id`),
	
	local.tableName="_#qGroup.site_option_group_name#_#qGroup.site_id#";
	dbNoVerify.sql="SHOW TABLES IN `#request.zos.zcoreTempDatasource#` LIKE '#local.tableName#_safe'";
	local.qCheck=dbNoVerify.execute("qCheck");
	if(local.qCheck.recordcount NEQ 0){
		dbNoVerify.sql=" DROP TABLE `#request.zos.zcoreTempDatasource#`.`#local.tableName#_safe` ";
		dbNoVerify.execute("qDrop");
	}
	dbNoVerify.sql=" CREATE TABLE  `#request.zos.zcoreTempDatasource#`.`#local.tableName#_safe` (
	"&arrayToList(local.arrSQL, ", "&chr(10))&") 
	ENGINE=InnoDB DEFAULT CHARSET=utf8";
	dbNoVerify.execute("qCreate");
	
	db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s1,
	 #db.table("site_x_option_group", request.zos.zcoreDatasource)# s2
	WHERE 
	s1.site_x_option_group_set_deleted = #db.param(0)# and 
	s2.site_x_option_group_deleted = #db.param(0)# and
	s1.site_option_group_id = #db.param(arguments.site_option_group_id)# and 
	s1.site_id = #db.param(request.zos.globals.id)# and 
	s1.site_id = s2.site_id and 
	s1.site_option_group_id = s2.site_option_group_id 
	ORDER BY s1.site_x_option_group_set_id asc ";
	local.qData=db.execute("qData");
	if(local.qData.recordcount){
		local.lastSetId=0;
		local.lastSetIdInserted=0;
		local.setStruct={};
		for(row2 in local.qData){
			if(local.lastSetId NEQ 0 and local.lastSetId NEQ row2.site_x_option_group_set_id){
				local.insertId=variables.insertRowInTempTable(local.tableName&"_safe", local.qGroup, local.setStruct, row2);
				if(local.insertId EQ false){
					
				}
				local.lastSetIdInserted=row2.site_x_option_group_set_id;
				local.setStruct={};
			}
			if(structkeyexists(local.optionLookup, row2.site_option_id)){
				local.tempOption=local.optionLookup[row2.site_option_id];
				if(local.tempOption.type EQ 4){
					local.setStruct[local.tempOption.name] = dateformat(row2.site_x_option_group_date_value, "yyyy-mm-dd")&' '& timeformat(row2.site_x_option_group_date_value, "HH:mm:ss");
				}else if(local.tempOption.type EQ 5){
					local.setStruct[local.tempOption.name] = dateformat(row2.site_x_option_group_date_value, "yyyy-mm-dd");
				}else if(local.tempOption.type EQ 6){
					local.setStruct[local.tempOption.name] = timeformat(row2.site_x_option_group_date_value, "HH:mm:ss");
				}else if(local.tempOption.type EQ 11){
					continue;
				}else{
					local.setStruct[local.tempOption.name] = '';
				}
			}
			local.lastSetId=row2.site_x_option_group_set_id;
		}
		if(structcount(local.setStruct) NEQ 0 and local.lastSetIdInserted NEQ row2.site_x_option_group_set_id){
			local.insertId=variables.insertRowInTempTable(local.tableName&"_safe", local.qGroup, local.setStruct, row2);
			if(local.insertId EQ false){
				
			}
			local.setStruct={};
		}
	}
	
	dbNoVerify.sql="SHOW TABLES IN `#request.zos.zcoreTempDatasource#` LIKE '#local.tableName#'";
	local.qCheck=dbNoVerify.execute("qCheck");
	if(local.qCheck.recordcount EQ 0){
		dbNoVerify.sql="RENAME TABLE 
		`#request.zos.zcoreTempDatasource#`.`#local.tableName#_safe` to `#request.zos.zcoreTempDatasource#`.`#local.tableName#` ";
		dbNoVerify.execute("qRename");
	}else{
		dbNoVerify.sql="RENAME TABLE 
		`#request.zos.zcoreTempDatasource#`.`#local.tableName#_safe` to `#request.zos.zcoreTempDatasource#`.`#local.tableName#_safetemp`, 
		`#request.zos.zcoreTempDatasource#`.`#local.tableName#` to `#request.zos.zcoreTempDatasource#`.`#local.tableName#_safe`,
		`#request.zos.zcoreTempDatasource#`.`#local.tableName#_safetemp` to `#request.zos.zcoreTempDatasource#`.`#local.tableName#`
		 ";
		dbNoVerify.execute("qRename");
		dbNoVerify.sql=" DROP TABLE `#request.zos.zcoreTempDatasource#`.`#local.tableName#_safe` ";
		dbNoVerify.execute("qDrop");
	}
	
	/*db.sql="select * from #db.table("#local.tableName#", request.zos.zcoreTempDatasource)# ";
	local.qData=db.execute("qData");
	writedump(local.qData);
	*/
	</cfscript>
</cffunction>

<cffunction name="insertRowInTempTable" localmode="modern" access="private">
	<cfargument name="tableName" type="string" required="yes">
	<cfargument name="qGroup" type="query" required="yes">
	<cfargument name="setStruct" type="struct" required="yes">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	var ts=structnew();
	// add other data from set
	local.tempURL="";
	if(request.zos.globals.optionGroupURLID NEQ 0 and arguments.qGroup.site_option_group_enable_unique_url EQ 1){
		if(arguments.row.site_x_option_group_set_override_url NEQ ""){
			local.tempURL=arguments.row.site_x_option_group_set_override_url;
		}else{
			local.tempURL="/#application.zcore.functions.zURLEncode(arguments.row.site_x_option_group_set_title, '-')#-#request.zos.globals.optionGroupURLID#-#arguments.row.site_x_option_group_set_id#.html";
		}
	}
	arguments.setStruct._title = arguments.row.site_x_option_group_set_title;
	arguments.setStruct._sort = arguments.row.site_x_option_group_set_sort;
	arguments.setStruct._active = arguments.row.site_x_option_group_set_active;
	arguments.setStruct._parent_id = arguments.row.site_x_option_group_set_parent_id;
	arguments.setStruct._app_id = arguments.row.site_option_app_id;
	arguments.setStruct._url = local.tempURL;
	arguments.setStruct._image_library_id = arguments.row.site_x_option_group_set_image_library_id;
	arguments.setStruct._set_id = arguments.row.site_x_option_group_set_id;
	arguments.setStruct._approved = arguments.row.site_x_option_group_set_approved;
	ts.struct=arguments.setStruct;
	ts.table=arguments.tableName;
	ts.enableTableFieldCache=false;
	ts.forcePrimaryInsert={"_set_id": arguments.row.site_x_option_group_set_id}; 
	ts.debug=true;
	ts.datasource=request.zos.zcoreTempDatasource;
	return application.zcore.functions.zInsert(ts);
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qGroup=0;
	var qProp=0;
	var curParentId=0;
	var arrParent=0;
	var q1=0;
	var i=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.7.1");
	application.zcore.functions.zstatushandler(request.zsid);
	form.site_option_group_parent_id=application.zcore.functions.zso(form, 'site_option_group_parent_id',true);
	if(form.site_option_group_parent_id NEQ 0){
		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
		where site_option_group_id=#db.param(form.site_option_group_parent_id)# and 
		site_option_group_deleted = #db.param(0)# and
		site_option_group.site_id =#db.param(request.zos.globals.id)#";
		qGroup=db.execute("qGroup");
        if(qGroup.recordcount EQ 0){
            application.zcore.functions.z301redirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#");	
        }
	}
	db.sql="SELECT site_option_group.*, if(child1.site_option_group_id IS NULL, #db.param(0)#,#db.param(1)#) hasChildren 
	FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group
	LEFT JOIN #db.table("site_option_group", request.zos.zcoreDatasource)# child1 ON 
	site_option_group.site_option_group_id = child1.site_option_group_parent_id and 
	child1.site_id = site_option_group.site_id and 
	child1.site_option_group_deleted = #db.param(0)# 
	WHERE
	site_option_group.site_option_group_deleted = #db.param(0)# and 
	site_option_group.site_id =#db.param(request.zos.globals.id)# and 
	site_option_group.site_option_group_parent_id = #db.param(form.site_option_group_parent_id)# 
	group by site_option_group.site_option_group_id 
	order by site_option_group.site_option_group_display_name ASC ";
	qProp=db.execute("qProp");
	if(form.site_option_group_parent_id NEQ 0){
		writeoutput('<p><a href="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#">Manage Groups</a> / ');
		curParentId=form.site_option_group_parent_id;
		arrParent=arraynew(1);
		loop from="1" to="25" index="i"{
			db.sql="select * 
			from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
			where site_option_group_id = #db.param(curParentId)# and 
			site_option_group_deleted = #db.param(0)# and
			site_id = #db.param(request.zos.globals.id)#";
			q1=db.execute("q1");
			loop query="q1"{
				arrayappend(arrParent, '<a href="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&site_option_group_parent_id=#q1.site_option_group_id#">
				#application.zcore.functions.zFirstLetterCaps(q1.site_option_group_display_name)#</a> / ');
				curParentId=q1.site_option_group_parent_id;
			}
			if(q1.recordcount EQ 0 or q1.site_option_group_parent_id EQ 0){
				break;
			}
		}
		for(i = arrayLen(arrParent);i GT 1;i--){
			writeOutput(arrParent[i]&' ');
		}
		if(form.site_option_group_parent_id NEQ 0){
			writeoutput(application.zcore.functions.zFirstLetterCaps(qGroup.site_option_group_display_name)&" /");
		}
		writeoutput('</p>');
	}
	</cfscript>
	<p><a href="/z/admin/site-option-group/add?site_option_group_parent_id=<cfif isquery(qgroup)>#qgroup.site_option_group_id#</cfif>">Add Group</a> 
	<cfif isquery(qgroup) and qgroup.site_option_group_id NEQ 0>
		| <a href="/z/admin/site-option-group/displayGroupCode?site_option_group_id=<cfif isquery(qgroup)>#qgroup.site_option_group_id#</cfif>" target="_blank">Display Group Code</a>
	</cfif>
	<cfif isquery(qgroup)> | <a href="/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#qgroup.site_option_group_id#&site_option_group_parent_id=#qgroup.site_option_group_parent_id#">Manage Options</a></cfif></p>
	<table style="border-spacing:0px;" class="table-list" >
		<tr>
			<th>Group Name</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qProp">
		<tr <cfif qProp.currentrow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
			<td>#qProp.site_option_group_name#</td>
			<td>
				<cfif qProp.site_option_group_admin_app_only EQ "0">
	
					<a href="/z/admin/site-options/manageGroup?site_option_app_id=0&site_option_group_id=#qProp.site_option_group_id#">List/Edit</a> | 
					<a href="/z/admin/site-options/import?site_option_app_id=0&site_option_group_id=#qProp.site_option_group_id#">Import</a> | 
					<a href="/z/admin/site-options/addGroup?site_option_app_id=0&site_option_group_id=#qProp.site_option_group_id#">Add</a> | 
				</cfif>
			<cfif qProp.site_id NEQ 0 or variables.allowGlobal>
					<a href="/z/admin/site-option-group/add?site_option_group_parent_id=#qProp.site_option_group_id#">Add Sub-Group</a> | 
					<a href="/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#qProp.site_option_group_id#&amp;site_option_group_parent_id=#qProp.site_option_group_parent_id#">Options</a> | 
					<cfif qProp.site_option_group_allow_public NEQ 0>
						<cfif qProp.site_option_group_public_form_url NEQ "">
							<a href="#htmleditformat(qProp.site_option_group_public_form_url)#" target="_blank">Public Form</a> | 
						<cfelse>
							<a href="/z/misc/display-site-option-group/add?site_option_group_id=#qProp.site_option_group_id#" target="_blank">Public Form</a> | 
						</cfif>
					</cfif>
					<cfif application.zcore.user.checkServerAccess()>
						<a href="/z/admin/site-option-group/export?site_option_group_id=#qProp.site_option_group_id#" target="_blank">Export</a> | 
						<a href="/z/admin/site-option-group/reindex?site_option_group_id=#qProp.site_option_group_id#" title="Will update site option group table for all records.  Useful after a config change.">Reprocess</a> | 
					</cfif>
	
					<cfif qProp.hasChildren EQ 1>
						<a href="/z/admin/site-option-group/index?site_option_group_parent_id=#qProp.site_option_group_id#">Sub-Groups</a> |
					</cfif>
					<a href="/z/admin/site-option-group/displayGroupCode?site_option_group_id=#qProp.site_option_group_id#&amp;site_option_group_parent_id=#qProp.site_option_group_parent_id#" target="_blank">Display Code</a> |
					
					<cfif qProp.site_option_group_map_fields_type NEQ 0>
						<a href="/z/admin/site-option-group/mapFields?site_option_group_id=#qProp.site_option_group_id#">Map Fields</a>
						<cfscript>
						db.sql="select count(site_option_group_map_id) count 
						from #db.table("site_option_group_map", request.zos.zcoreDatasource)# site_option_group_map WHERE 
						site_id = #db.param(qProp.site_id)# AND 
						site_option_group_map_deleted = #db.param(0)# and
						site_option_group_id = #db.param(qProp.site_option_group_id)# ";
						qMap=db.execute("qMap");
						if(qMap.recordcount EQ 0 or qMap.count EQ 0){
							echo('<strong>(Not Mapped Yet)</strong> ');
						}
						</cfscript> | 
					</cfif>
					<a href="/z/admin/site-option-group/edit?site_option_group_id=#qProp.site_option_group_id#&amp;site_option_group_parent_id=#qProp.site_option_group_parent_id#&amp;return=1">Edit</a> | 
					<cfif qProp.site_option_group_parent_id EQ 0>
						<a href="/z/admin/site-option-group/copyGroupForm?site_option_group_id=#qProp.site_option_group_id#">Copy</a> | 
					</cfif>
					<a href="/z/admin/site-option-group/delete?site_option_group_id=#qProp.site_option_group_id#&amp;site_option_group_parent_id=#qProp.site_option_group_parent_id#&amp;return=1">Delete</a>
				</cfif></td>
		</tr>
		</cfloop>
	</table>
</cffunction>


<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var result=0;
	var qCheck=0;
	var theTitle=0;
	var tempLink=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);	
	form.site_option_group_id=application.zcore.functions.zso(form,'site_option_group_id');
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group WHERE 
	site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "group is missing");
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&zsid="&request.zsid);
	}
	if(qCheck.site_id EQ 0 and variables.allowGlobal EQ false){
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index");
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		application.zcore.siteOptionCom.deleteGroupRecursively(form.site_option_group_id);
		application.zcore.status.setStatus(request.zsid, "Group deleted successfully.");
		application.zcore.siteOptionCom.updateOptionGroupCacheByGroupId(qCheck.site_option_group_id);

		structclear(application.sitestruct[request.zos.globals.id].administratorTemplateMenuCache);
		//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id); 
		if(structkeyexists(request.zsession, "site_option_group_return"&form.site_option_group_id)){
			tempLink=request.zsession["site_option_group_return"&form.site_option_group_id];
			structdelete(request.zsession,"site_option_group_return"&form.site_option_group_id);
			application.zcore.functions.z301Redirect(tempLink);
		}else{
			application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid="&request.zsid);
		}
		</cfscript>
	<cfelse>
		<cfscript>
		theTitle="Delete Group";
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
		</cfscript>
		<h2> Are you sure you want to delete this Group?<br />
		<br />
		Group: #qcheck.site_option_group_display_name#<br />
		<br />
		<a href="/z/admin/site-option-group/delete?confirm=1&site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&zrand=#gettickcount()#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_parent_id=#form.site_option_group_parent_id#">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">    
	<cfscript>
	var db=request.zos.queryObject;
	var errors=0;
	var tempLink=0;
	var qCheck=0;
	var ts=0;
	var redirecturl=0;
	var rCom=0;
	var myForm={};
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);	
	myForm.site_option_group_display_name.required=true;
	myForm.site_option_group_display_name.friendlyName="Display Name";
	myForm.site_option_group_name.required=true;
	myForm.site_option_group_name.friendlyName="Code Name";
	errors=application.zcore.functions.zValidateStruct(form, myForm,request.zsid, true);
	
	if(form.method EQ "update"){
		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
		where site_option_group_id = #db.param(form.site_option_group_id)# and 
		site_option_group_deleted = #db.param(0)# and
		site_id = #db.param(request.zos.globals.id)#";
		qCheck=db.execute("qCheck");
		if(qCheck.site_id EQ 0 and variables.allowGlobal EQ false){
			application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#");
		}
		// force code name to never change after initial creation
		form.site_option_group_name=qCheck.site_option_group_name;
	}
	if(application.zcore.functions.zso(form, 'site_option_group_enable_unique_url', false, 0) EQ 1){
		if(form.site_option_group_view_cfc_path EQ "" or form.site_option_group_view_cfc_method EQ ""){
			application.zcore.status.setStatus(request.zsid, "View CFC Path and View CFC Method are required when ""Enable Unique Url"" is set to yes.", form, true);
			errors=true;
		}
	}
	
	form.site_option_group_appidlist=","&application.zcore.functions.zso(form,'site_option_group_appidlist')&",";
	 if(application.zcore.functions.zso(form,'optionGroupglobal',false,0) EQ 1 and variables.allowGlobal){
		 form.site_id='0';
	 }else{
		 form.site_id=request.zos.globals.id;
	 }
	if(errors){
		if(form.method EQ 'insert'){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/admin/site-option-group/add?site_option_app_id=#form.site_option_app_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/admin/site-option-group/edit?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid=#request.zsid#");
		}
	} 
	
	if(form.inquiries_type_id NEQ ""){
		local.arrTemp=listToArray(form.inquiries_type_id, '|');
		form.inquiries_type_id=local.arrTemp[1];
		form.inquiries_type_id_siteIDType=application.zcore.functions.zGetSiteIdType(local.arrTemp[2]);
	}
	 
	ts=StructNew();
	ts.table="site_option_group";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ "insert"){
		form.site_option_group_id = application.zcore.functions.zInsert(ts);
		if(form.site_option_group_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Group couldn't be added at this time.",form,true);
			application.zcore.functions.zRedirect("/z/admin/site-option-group/add?site_option_app_id=#form.site_option_app_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid="&request.zsid);
		}else{ 
			application.zcore.status.setStatus(request.zsid, "Group added successfully.");
			redirecturl=("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid="&request.zsid);
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Group failed to update.",form,true);
			application.zcore.functions.zRedirect("/z/admin/site-option-group/edit?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Group updated successfully.");
			redirecturl=("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid="&request.zsid);
		}
	}
	
	
	application.zcore.siteOptionCom.updateOptionGroupCacheByGroupId(form.site_option_group_id);
	//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
	structclear(application.sitestruct[request.zos.globals.id].administratorTemplateMenuCache);
	application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
	
	if(structkeyexists(request.zsession, "site_option_group_return"&form.site_option_group_id)){
		tempLink=request.zsession["site_option_group_return"&form.site_option_group_id];
		structdelete(request.zsession,"site_option_group_return"&form.site_option_group_id);
		if(tempLink NEQ ""){
			application.zcore.functions.z301Redirect(tempLink);
		}
	}
	application.zcore.functions.zRedirect(redirecturl);
	</cfscript>
</cffunction>


<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qRate=0;
	var theTitle=0;
	var qApp=0;
	var qG=0;
	var htmlEditor=0;
	var selectStruct=0;
	var ts=0;
	application.zcore.functions.zSetPageHelpId("2.7.2");
	
	var currentMethod=form.method;
	variables.init();
	form.site_option_group_id=application.zcore.functions.zso(form,'site_option_group_id',true);
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
	WHERE site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id =#db.param(request.zos.globals.id)# ";
	qRate=db.execute("qRate");
	if(structkeyexists(form, 'site_option_group_parent_id')){
		application.zcore.functions.zQueryToStruct(qRate,form,'site_option_group_id,site_option_group_parent_id'); 
	}else{
		application.zcore.functions.zQueryToStruct(qRate,form,'site_option_group_id'); 
	}
	application.zcore.functions.zStatusHandler(request.zsid, true);
	
	if(currentMethod EQ "edit"){
		theTitle="Edit Group";
	}else{
		theTitle="Add Group";
	}
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
	</cfscript>
	<form name="myForm" id="myForm" action="/z/admin/site-option-group/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#" method="post">

		<cfscript>
		tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic","Public Form", "Landing Page", "Email & Mapping"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-site-option-group-edit");
		cancelURL="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#"; 
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#
		<table  style="border-spacing:0px;" class="table-list">
			<cfsavecontent variable="db.sql"> SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group WHERE 
			site_id = #db.param(request.zos.globals.id)# and 
			site_option_group_deleted = #db.param(0)# 
			<cfif form.site_option_group_id NEQ 0 and form.site_option_group_id NEQ "">
				and site_option_group_id <> #db.param(form.site_option_group_id)# and 
				site_option_group_parent_id <> #db.param(form.site_option_group_id)#
			</cfif>
			ORDER BY site_option_group_display_name </cfsavecontent>
			<cfscript>
			qG=db.execute("qG");
			</cfscript>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Parent Group","member.site-option-group.edit site_option_group_parent_id")#</th>
				<td><cfscript>
				selectStruct=structnew();
				selectStruct.name="site_option_group_parent_id";
				selectStruct.query = qG;
				selectStruct.onchange="doParentCheck();";
				selectStruct.queryLabelField = "site_option_group_display_name";
				selectStruct.queryValueField = "site_option_group_id";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Code Name","member.site-option-group.edit site_option_group_name")#</th>
				<td>
				<cfif currentMethod EQ "add">
					<input name="site_option_group_name" id="site_option_group_name" size="50" type="text" value="#htmleditformat(form.site_option_group_name)#"  onkeyup="var d1=document.getElementById('site_option_group_display_name');d1.value=this.value;" onblur="var d1=document.getElementById('site_option_group_display_name');d1.value=this.value;" maxlength="100" />
					<input type="hidden" name="site_option_group_type" value="1" />
				<cfelse>
					#form.site_option_group_name#<br />
					<input name="site_option_group_name" id="site_option_group_name" type="hidden" value="#htmleditformat(form.site_option_group_name)#"  />
					Note: Code Name can't be changed after initial creation to allow for simple syncing between sites &amp; servers.
				</cfif></td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Display Name","member.site-option-group.edit site_option_group_display_name")#</th>
				<td><input name="site_option_group_display_name" id="site_option_group_display_name" size="50" type="text" value="#htmleditformat(form.site_option_group_display_name)#" maxlength="100" />
				</td>
			</tr>
			<cfscript>
			if(form.site_id EQ 0){
				form.optionGroupglobal='1';
			}
			</cfscript> 
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Associate With Apps","member.site-option-group.edit site_option_group_appidlist")#</th>
					<td><cfscript>
					db.sql="select app.* from #db.table("app", request.zos.zcoreDatasource)# app, 
					#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
					WHERE app_x_site.site_id = #db.param(request.zos.globals.id)# and 
	 				app.app_built_in=#db.param(0)# and 
					app_x_site.app_id = app.app_id and 
					app_x_site_deleted = #db.param(0)# and 
					app_deleted = #db.param(0)# 
					order by app_name ";
					qApp=db.execute("qApp");
					
					selectStruct=structnew();
					selectStruct.name="site_option_group_appidlist";
					selectStruct.query = qApp;
					selectStruct.onchange="";
					selectStruct.queryLabelField = "app_name";
					selectStruct.queryValueField = "app_id";
					application.zcore.functions.zInput_Checkbox(selectStruct);
					</cfscript></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Enable Section?","member.site-option-group.edit site_option_group_enable_section")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_section")# (Requires Enable Unique URL to be set to Yes)</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Only Show App Admin?","member.site-option-group.edit site_option_group_admin_app_only")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_admin_app_only")#</td>
				</tr>
				
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Menu Name","member.site-option-group.edit site_option_group_menu_name")#</th>
					<td><div  id="groupMenuNameId">
							<input name="site_option_group_menu_name" id="site_option_group_menu_name" size="50" type="text" value="#htmleditformat(form.site_option_group_menu_name)#" maxlength="100" />
							(Put this group in a manager menu)</div>
						<div  id="groupMenuNameId2" style="display:none;">Disabled - Only allowed on the root groups.</div></td>
				</tr>
				<cfif variables.allowGlobal>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Global","member.site-option-group.edit optionGroupglobal")#</th>
						<td>#application.zcore.functions.zInput_Boolean("optionGroupglobal")#</td>
					</tr>
				</cfif>
				<cfscript>
				if(form.site_option_group_admin_paging_limit EQ ""){
					form.site_option_group_admin_paging_limit=0;
				}
				</cfscript>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Child Limit","member.site-option-group.edit site_option_group_limit")#</th>
					<td><input type="text" name="site_option_group_limit" id="site_option_group_limit" value="#htmleditformat(form.site_option_group_limit)#" /></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">Admin Paging Limit</th>
					<td><input name="site_option_group_admin_paging_limit" id="site_option_group_admin_paging_limit" type="text" value="#htmleditformat(form.site_option_group_admin_paging_limit)#"  /> (Number of records to display in admin until showing page navigation)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Form Description:","member.site-option-group.edit site_option_group_form_description")#</th>
					<td>
						<cfscript>
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "site_option_group_form_description";
						htmlEditor.value			= application.zcore.functions.zso(form, 'site_option_group_form_description');
						htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
						htmlEditor.height		= 250;
						htmlEditor.create();
						</cfscript></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Parent Field","member.site-option-group.edit site_option_group_parent_field")#</th>
					<td><input type="text" name="site_option_group_parent_field" id="site_option_group_parent_field" value="#htmleditformat(form.site_option_group_parent_field)#" /> (Optional, enables indented heirarchy on list view)</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Enable Sorting","member.site-option-group.edit site_option_group_enable_sorting")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_sorting")#</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Image Library?","member.site-option-group.edit site_option_group_enable_image_library")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_image_library")#</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Disable Admin?","member.site-option-group.edit site_option_group_disable_admin")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_disable_admin")#</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable List Recurse","member.site-option-group.edit site_option_group_enable_list_recurse")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_list_recurse")# (Displays this group's records on parent groups manager list view)</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Enable Versioning?","member.site-option-group.edit site_option_group_enable_versioning")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_versioning")#</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Max ## of Versions","member.site-option-group.edit site_option_group_version_limit")#</th>
					<td><input name="site_option_group_version_limit" id="site_option_group_version_limit" size="50" type="text" value="#htmleditformat(application.zcore.functions.zso(form, 'site_option_group_version_limit', true))#" maxlength="100" />
							</td></tr>

				
				<cfscript>
				if(form.site_option_group_enable_cache EQ ""){
					form.site_option_group_enable_cache=1;
				}
				</cfscript>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Memory Caching","member.site-option-group.edit site_option_group_enable_cache")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_cache")# (Warning: "Yes" will result in very slow manager performance if this group has many records.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable URL Caching","member.site-option-group.edit site_option_group_enable_partial_page_caching")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_partial_page_caching")# (Incomplete - will store rendered page in memory)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Help Description:","member.site-option-group.edit site_option_group_help_description")#</th>
					<td>
						<cfscript>
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "site_option_group_help_description";
						htmlEditor.value			= application.zcore.functions.zso(form, 'site_option_group_help_description');
						htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
						htmlEditor.height		= 350;
						htmlEditor.create();
						</cfscript></td>
				</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Public Form")#
		<table  style="border-spacing:0px;" class="table-list">
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Public Form Title","member.site-option-group.edit site_option_group_public_form_title")#</th>
					<td><input name="site_option_group_public_form_title" id="site_option_group_public_form_title" size="50" type="text" value="#htmleditformat(form.site_option_group_public_form_title)#" maxlength="100" />
							</td></tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Public Form?","member.site-option-group.edit site_option_group_allow_public")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_allow_public")#</td>
				</tr>
				<tr>
					<th>Require Captcha<br />For Public Data Entry:</th>
					<td>
					#application.zcore.functions.zInput_Boolean("site_option_group_enable_public_captcha")#
					</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Data Entry<br />For User Groups","member.site-option-group.edit site_option_group_user_group_id_list")#</th>
					<td>
					<cfscript>
					db.sql="SELECT *FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
					WHERE site_id = #db.param(request.zos.globals.id)# and 
					user_group_deleted = #db.param(0)# 
					ORDER BY user_group_name asc"; 
					var qGroup2=db.execute("qGroup2"); 
					ts = StructNew();
					ts.name = "site_option_group_user_group_id_list";
					ts.friendlyName="";
					// options for query data
					ts.multiple=true;
					ts.query = qGroup2;
					ts.queryLabelField = "user_group_name";
					ts.queryValueField = "user_group_id";
					application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'site_option_group_user_group_id_list', true, 0));
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Require Approval#chr(10)#of Public Data?","member.site-option-group.edit site_option_group_enable_approval")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_approval")#</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Public Form URL","member.site-option-group.edit site_option_group_public_form_url")#</th>
					<td>
							<input name="site_option_group_public_form_url" id="site_option_group_public_form_url" size="50" type="text" value="#htmleditformat(form.site_option_group_public_form_url)#" maxlength="100" />
					</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Public Thank You URL","member.site-option-group.edit site_option_group_public_thankyou_url")#</th>
					<td>
							<input name="site_option_group_public_thankyou_url" id="site_option_group_public_thankyou_url" size="50" type="text" value="#htmleditformat(form.site_option_group_public_thankyou_url)#" maxlength="100" />
					</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Ajax?","member.site-option-group.edit site_option_group_ajax_enabled")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_ajax_enabled")# (Yes will make public form insertions use ajax instead, but not for updating existing records.)</td>
				</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Landing Page")#
		<table  style="border-spacing:0px;" class="table-list">
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">Enable Unique URL</th>
					<td>
				<cfif request.zos.globals.optionGroupURLID NEQ 0>
					#application.zcore.functions.zInput_Boolean("site_option_group_enable_unique_url")#
				<cfelse>
					Option group URL ID must be set in server manager to use this feature.
				</cfif></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Meta Tags?","member.site-option-group.edit site_option_group_enable_meta")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_meta")#</td>
				</tr>
				<!--- 
				This field doesn't do anything yet!
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Embedding?","member.site-option-group.edit site_option_group_embed")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_embed")#</td>
				</tr> --->
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Embed HTML Code:","member.site-option-group.edit site_option_group_code")#</th>
					<td><textarea name="site_option_group_code" id="site_option_group_code" cols="100" rows="10">#htmleditformat(form.site_option_group_code)#</textarea></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("View CFC Path","member.site-option-group.edit site_option_group_view_cfc_path")#</th>
					<td><input type="text" name="site_option_group_view_cfc_path" id="site_option_group_view_cfc_path" value="#htmleditformat(form.site_option_group_view_cfc_path)#" /> (Should begin with zcorerootmapping, root or another root relative path.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("View CFC Method","member.site-option-group.edit site_option_group_view_cfc_method")#</th>
					<td><input type="text" name="site_option_group_view_cfc_method" id="site_option_group_view_cfc_method" value="#htmleditformat(form.site_option_group_view_cfc_method)#" /> (A function name in the CFC with access="remote")</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Disable Site Map?","member.site-option-group.edit site_option_group_disable_site_map")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_disable_site_map")#</td>
				</tr>
				<tr>
					<th>Searchable (public):</th>
					<td>
					<input name="site_option_group_public_searchable" id="site_option_group_public_searchable1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'site_option_group_public_searchable', true, 0) EQ 1>checked="checked"</cfif>  /> Yes
					<input name="site_option_group_public_searchable" id="site_option_group_public_searchable0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'site_option_group_public_searchable', true, 0) EQ 0>checked="checked"</cfif> /> No</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Search Index CFC Path","member.site-option-group.edit site_option_group_search_index_cfc_path")#</th>
					<td><input type="text" name="site_option_group_search_index_cfc_path" id="site_option_group_search_index_cfc_path" value="#htmleditformat(form.site_option_group_search_index_cfc_path)#" /> (Should begin with zcorerootmapping, root or another root relative path.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Search Index CFC Method","member.site-option-group.edit site_option_group_search_index_cfc_method")#</th>
					<td><input type="text" name="site_option_group_search_index_cfc_method" id="site_option_group_search_index_cfc_method" value="#htmleditformat(form.site_option_group_search_index_cfc_method)#" /> (A function name in the CFC with access="public")</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Search Result CFC Path","member.site-option-group.edit site_option_group_search_result_cfc_path")#</th>
					<td><input type="text" name="site_option_group_search_result_cfc_path" id="site_option_group_search_result_cfc_path" value="#htmleditformat(form.site_option_group_search_result_cfc_path)#" /> (Should begin with zcorerootmapping, root or another root relative path.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Search Result CFC Method","member.site-option-group.edit site_option_group_search_result_cfc_method")#</th>
					<td><input type="text" name="site_option_group_search_result_cfc_method" id="site_option_group_search_result_cfc_method" value="#htmleditformat(form.site_option_group_search_result_cfc_method)#" /> (A function name in the CFC with access="public")</td>
				</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Email & Mapping")#
		<table  style="border-spacing:0px;" class="table-list">
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Map Fields Type","member.site-option-group.edit site_option_group_map_fields_type")#</th>
					<td><cfscript>
					form.site_option_group_map_fields_type=application.zcore.functions.zso(form, 'site_option_group_map_fields_type', true, 0);
					ts = StructNew();
					ts.name = "site_option_group_map_fields_type";
					ts.listLabels = "Disabled,Inquiries,Group";
					ts.listValues = "0,1,2";
					ts.radio=true;
					ts.listLabelsDelimiter = ","; // tab delimiter
					ts.listValuesDelimiter = ",";
					writeoutput(application.zcore.functions.zInput_Checkbox(ts));
					</cfscript></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Map Group","member.site-option-group.edit site_option_group_map_group_id")#</th>
					<td><cfscript>
					selectStruct=structnew();
					selectStruct.name="site_option_group_map_group_id";
					selectStruct.query = qG;
					selectStruct.onchange="doParentCheck();";
					selectStruct.queryLabelField = "site_option_group_display_name";
					selectStruct.queryValueField = "site_option_group_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Map To Lead Type","member.site-option-group.edit inquiries_type_id")#</th>
					<td><cfscript>
					if(form.inquiries_type_id_siteIDType NEQ "" and form.inquiries_type_id_siteIDType NEQ 0){
						form.inquiries_type_id=form.inquiries_type_id&"|"&application.zcore.functions.zGetSiteIDFromSiteIdType(form.inquiries_type_id_siteIDType);
					}
					db.sql="SELECT *, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_type.site_id"))# as inquiries_type_id_siteIDType from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
					WHERE  site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
					inquiries_type_deleted = #db.param(0)# ";
					if(not application.zcore.app.siteHasApp("listing")){
						db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
					}
					if(not application.zcore.app.siteHasApp("rental")){
						db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
					}
					db.sql&="ORDER BY inquiries_type_sort ASC, inquiries_type_name ASC ";
					local.qType=db.execute("qType");
					selectStruct=structnew();
					selectStruct.name="inquiries_type_id";
					selectStruct.query = local.qType;
					selectStruct.queryLabelField = "inquiries_type_name";
					selectStruct.queryParseValueVars=true;
					selectStruct.queryValueField = "##inquiries_type_id##|##site_id##";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Map Insert Type","member.site-option-group.edit site_option_group_map_insert_type")#</th>
					<td><cfscript>
					form.site_option_group_map_insert_type=application.zcore.functions.zso(form, 'site_option_group_map_insert_type', true, 0);
					ts = StructNew();
					ts.name = "site_option_group_map_insert_type";
					ts.listLabels = "Disabled,Immediately on Insert,After Manual Approval";
					ts.listValues = "0,1,2";
					ts.radio=true;
					ts.listLabelsDelimiter = ","; // tab delimiter
					ts.listValuesDelimiter = ",";
					writeoutput(application.zcore.functions.zInput_Checkbox(ts));
					</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Delete On Map?","member.site-option-group.edit site_option_group_delete_on_map")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_delete_on_map")# (Set this to no when a file upload field is used on the form.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Lead Routing?","member.site-option-group.edit site_option_group_lead_routing_enabled")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_lead_routing_enabled")# | If Yes, an email will be generated when a new record is inserted.</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Email CFC Path","member.site-option-group.edit site_option_group_email_cfc_path")#</th>
					<td><input type="text" name="site_option_group_email_cfc_path" id="site_option_group_email_cfc_path" value="#htmleditformat(form.site_option_group_email_cfc_path)#" /> (Should begin with zcorerootmapping, root or another root relative path.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Email CFC Method","member.site-option-group.edit site_option_group_email_cfc_method")#</th>
					<td><input type="text" name="site_option_group_email_cfc_method" id="site_option_group_email_cfc_method" value="#htmleditformat(form.site_option_group_email_cfc_method)#" /> (A function name in the CFC with access="remote")</td>
				</tr>
		</table>
		#tabCom.endFieldSet()# 
		#tabCom.endTabMenu()#
				 
				
		<cfif variables.allowGlobal EQ false>
			<input type="hidden" name="optionGroupglobal" value="0" />
		</cfif>
	</form>
	<script type="text/javascript">
		/* <![CDATA[ */
		var arrD=[];<cfloop query="qG">arrD.push("#qG.site_id#");</cfloop>
		var firstLoad11=true;
		function doParentCheck(){
			var d1=document.getElementById("optionGroupglobal1");
			var d0=document.getElementById("optionGroupglobal0");
			var groupMenuName=document.getElementById("groupMenuNameId");
			var groupMenuName2=document.getElementById("groupMenuNameId2");
			var groupMenuNameField=document.getElementById("site_option_group_menu_name");
			if(groupMenuNameField == null){
				return;
			}
			if(firstLoad11){
				firstLoad11=false;
				$(d1).bind("change",function(){ doParentCheck(); });
				$(d0).bind("change",function(){ doParentCheck(); });
			}
			var a=document.getElementById("site_option_group_parent_id");
			if(a.selectedIndex != 0){
				groupMenuNameField.value='';
				groupMenuName.style.display="none";
				groupMenuName2.style.display="block";
				if(arrD[a.selectedIndex-1] == 0){
					d1.checked=true;
					d0.checked=false;	
				}else{
					d1.checked=false;
					d0.checked=true;	
				}
			}else{
				groupMenuName.style.display="block";
				groupMenuName2.style.display="none";
			}
		}
		zArrDeferredFunctions.push(function(){doParentCheck();});
		/* ]]> */
		</script>
</cffunction>
</cfoutput>
</cfcomponent>
