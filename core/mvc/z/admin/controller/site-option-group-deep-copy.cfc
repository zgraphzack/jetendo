<cfcomponent>
<cfoutput>
<!--- 
deep copy for site option groups
	two ways to handle this.
		create a "linked record" that will replace the original and maintain the same URL and original parent record ID, but all site_x_option_group_id ids will change, and the 
			complications?
				I should show modal window while version is being created, with loading animation, and maybe status feedback.   It might take a minute to copy some kinds of records.  Prevent double click.
			
				with versions, you could have multiple drafts, and one primary record that is "live".   
				administrator needs to be able to preview a record temporarily for their session -  the retrieval of data across entire system would have to be able to swap in these temporary records without changing the site code.
					non-primary records with "preview" session flag set must always be in memory, even if memory is disabled so it avoids extra queries to retrieve them.

					
When making a version the primary record, it will have option to preserve the original URL, meta tags.   Also, an option to delete the original afterwards, so that old versions don't clutter or confuse you later.
					
				because versions are stored in memory, we must limit the number of active versions.  archived versions are not stored in memory, and can't be previewed.  Users must "archive" 1 or more versions, to bring an archived one back to active or draft state.
					
				they can only work on the groups with parent_id = 0 because relationships with other records would break if we didn't restrict this.
				
				a "Version" is an inactive copy of the data. 
				site_x_option_group_set_version
					all the same fields as site_x_option_group_set with site_x_option_group_set_version prefix
					plus:
					site_x_option_group_set_version_status char(1) default 0 | 0 is archived | 1 is primary | 2 is primary preview  - there can only be 1 record at a time that is value 1, and 1 that is value 2.   preview records are only visible for logged in user with manager privileges.
					site_x_option_group_set_id
				site_x_option_group_set
					site_x_option_group_set_master_set_id (refers to the main site_x_option_group_set_id record)  
						if this is 0, then it is the master, else it is a version, and should not be included in the main arrays and query results that are used for site output.   
						when non-zero, the full tree of data for this record and its child records should ALWAYS be cached in memory if the version record for this id is not archived.
				site_x_option_group
					no changes.
				
			versions can only be viewed/edited/deleted on the version page.   The version page could be made into a modal window instead of a separate page.  This makes it easier to stay where you where, similar to edit.
			
			new fields:
				site_option_group_enable_versioning
				site_option_group_enable_version_limit int(11) default 0,  0 is unlimited, default this to 10 to reduce wasted space usage.
			
			"Make Primary" link, opens modal window, that has options for preserving specific data.
				i.e. Meta Tags, URL, more later.
					
					
		OR I can create a full copy, but force the unique url field blank so it doesn't conflict.
			simpler, but leads to SEO mistakes, and complications with losing relationships to other records.
			
		
 ---> 

<cffunction name="copyGroupRecursive" localmode="modern" access="public" roles="member">
	<cfargument name="option_group_set_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="rowStruct" type="struct" required="yes">
	<cfargument name="groupStruct" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var row=arguments.rowStruct;
	row.site_x_option_group_set_override_url="";
	row.site_x_option_group_set_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');
	row.site_id = arguments.site_id;

	if(row.site_x_option_group_set_image_library_id NEQ 0){

		logCopyMessage('Copying image library for set ###arguments.option_group_set_id#');
		row.site_x_option_group_set_image_library_id=application.zcore.imageLibraryCom.copyImageLibrary(row.site_x_option_group_set_image_library_id, row.site_id);
	}
	ts=structnew();
	ts.struct=row;
	ts.datasource=request.zos.zcoreDatasource;
	ts.table="site_x_option_group_set";
	newSetId=application.zcore.functions.zInsert(ts);

	logCopyMessage('Copying set ###arguments.option_group_set_id#');
	db.sql="select * from 
	#db.table("site_x_option_group", request.zos.zcoreDatasource)# WHERE 
	site_x_option_group_set_id = #db.param(arguments.option_group_set_id)# and 
	site_x_option_group_deleted=#db.param(0)# and 
	site_id = #db.param(arguments.site_id)# ";
	qValue=db.execute("qValue");
	typeCache={};
	tempPath=application.zcore.functions.zvar('privatehomedir', arguments.site_id);
	for(row2 in qValue){

		structdelete(row2, 'site_x_option_group_id');  
		row2.site_x_option_group_set_id=newSetId;
		row2.site_id=arguments.site_id;
		row2.site_x_option_group_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');

		if(row2.site_x_option_group_value NEQ ""){
			if(structkeyexists(arguments.optionStruct, row2.site_option_id)){
				typeId=arguments.optionStruct[row2.site_option_id].data.site_option_type_id;
				if(typeId EQ 9){
					tempOptionStruct=arguments.optionStruct[row2.site_option_id].type;
					path=tempPath;
					if(application.zcore.functions.zso(tempOptionStruct, 'file_securepath') EQ 'Yes'){
						path&='zuploadsecure/site-options/';
					}else{
						path&='zupload/site-options/';
					}
				}else if(typeId EQ 3){
					path=tempPath&'zupload/site-options/';
				}
				if(typeId EQ 9 or typeId EQ 3){
					newPath=application.zcore.functions.zcopyfile(path&row2.site_x_option_group_value);
					row2.site_x_option_group_value=getfilefrompath(newPath); 
					if(row2.site_x_option_group_original NEQ ""){
						newPath=application.zcore.functions.zcopyfile(path&row2.site_x_option_group_original);
						row2.site_x_option_group_original=getfilefrompath(newPath);
					}
				}
			}
		}
		ts=structnew();
		ts.struct=row2;
		ts.datasource=request.zos.zcoreDatasource;
		ts.table="site_x_option_group";
		newValueId=application.zcore.functions.zInsert(ts);

	}


	db.sql="select * from 
	#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE 
	site_x_option_group_set_parent_id = #db.param(arguments.option_group_set_id)# and 
	site_x_option_group_set_master_set_id = #db.param(0)# and 
	site_x_option_group_set_deleted=#db.param(0)#  and 
	site_id = #db.param(arguments.site_id)# ";
	typeCache={};
	qChild=db.execute("qChild");
	for(row3 in qChild){
		row3.site_x_option_group_set_parent_id=newSetId;
		this.copyGroupRecursive(row3.site_x_option_group_set_id, arguments.site_id, row3, arguments.groupStruct, arguments.optionStruct);
	}
	</cfscript>
</cffunction>

<cffunction name="getGroups" localmode="modern" access="public" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	groupStruct={};
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_deleted=#db.param(0)#";
	qGroup=db.execute("qGroup");
	for(row in qGroup){
		groupStruct[row.site_option_group_id]={
			data: row
		}
	}
	return groupStruct;
	</cfscript>
	
</cffunction>

<cffunction name="getOptions" localmode="modern" access="public" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	optionStruct={};
	db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	site_option_deleted=#db.param(0)# and 
	site_option_group_id <> #db.param(0)#";
	qOption=db.execute("qOption");
	for(row in qOption){
		optionStruct[row.site_option_id]={
			data: row,
			type: deserializeJson(row.site_option_type_json)
		}
	}
	return optionStruct;
	</cfscript>
</cffunction>

<cffunction name="getCopyMessage" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
	rs={
		success:true,
		message:application.zcore.functions.zso(request.zsession, 'siteOptionGroupDeepCopyMessage')
	};
	application.zcore.functions.zReturnJSON(rs);
	</cfscript>
</cffunction>
	
<cffunction name="logCopyMessage" localmode="modern" access="public" roles="member">
	<cfargument name="message" type="string" required="yes">
	<cfscript>
	request.zsession.siteOptionGroupDeepCopyMessage=arguments.message;
	application.zcore.session.put(request.zsession);
	</cfscript>
</cffunction>

<cffunction name="copyGroup" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	qSet=getSet();
	setting requesttimeout="10000";
	form.newSiteId=request.zos.globals.id;
	logCopyMessage('Copy Initializing.');
	groupStruct=getGroups();
	optionStruct=getOptions();

	try{
		for(row in qSet){
			row.site_x_option_group_set_copy_id=form.site_x_option_group_set_id;
			this.copyGroupRecursive(form.site_x_option_group_set_id, form.newSiteId, row, groupStruct, optionStruct);
		}
		application.zcore.functions.zOS_cacheSiteAndUserGroups(form.newSiteId);

	}catch(Any e){
		logCopyMessage('An error occured while copying.');
		savecontent variable="out"{
			echo('<h2>An error occured while copying.</h2>');
			writedump(e);
		}
		ts={
			type:"Custom",
			errorHTML:out,
			scriptName:request.zos.originalURL,
			url:request.zos.globals.domain&request.zos.originalURL,
			exceptionMessage:'An error occured while copying.',
			// optional
			lineNumber:''
		};
		application.zcore.functions.zLogError(ts);
		rs={
			success:false,
			errorMessage:"An error occurred while copying."
		};
		application.zcore.functions.zReturnJSON(rs);
	}
	logCopyMessage('');
	rs={
		success:true,
		redirectURL:"/z/admin/site-options/manageGroup?site_x_option_group_set_parent_id=#qSet.site_x_option_group_set_parent_id#&site_option_app_id=#qSet.site_option_app_id#&site_option_group_id=#qSet.site_option_group_id#&zsid=#request.zsid#"
	};
	application.zcore.functions.zReturnJSON(rs);
	</cfscript>
</cffunction>


<cffunction name="getSet" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.functions.zSetPageHelpId("2.7.1.2");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
	db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# 
	where site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
	site_x_option_group_set_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	qSet=db.execute("qSet");
	if(qSet.recordcount EQ 0){
		if(structkeyexists(form, 'x_ajax_id')){
			rs={
				success:false,
				errorMessage:"Invalid request."
			};
			application.zcore.functions.zReturnJSON(rs);
		}
		application.zcore.status.setStatus(request.zsid, "Invalid request.", form, true);
		application.zcore.functions.zRedirect('/z/admin/site-option-group/index?zsid=#request.zsid#');	
	}
	return qSet;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	qSet=getSet();
	</cfscript>

	<div id="copyMessageDiv">
		<h2>Select Copy Method</h2>
		<h3><a href="##" onclick="doDeepCopy('/z/admin/site-option-group-deep-copy/copyGroup?site_x_option_group_set_id=#form.site_x_option_group_set_id#'); return false;">Deep Copy</a></h3>
		<p>A deep copy will force the URL to be unique, but all other data including text, files And sub-records will be fully cloned.</p>
		<h3><a href="/z/admin/site-options/addGroup?site_option_app_id=#qSet.site_option_app_id#&amp;site_option_group_id=#qSet.site_option_group_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=#qSet.site_x_option_group_set_parent_id#">Shallow Copy</a></h3>
		<p>Shallow copy prefills the form for creating a new record with only this record's text.  All files and sub-records will be left blank on the new record.</p>
		<cfif request.zos.istestserver>
		
			<h3><a href="##" onclick="">Create new version (coming soon)</a></h3>
			<p>A version is a deep copy that is linked with the original record.  The new record will be invisible to the public until finalized.  You will be able to preserve the URL and existing relationships that the original record had when you set the version to be the primary record.</p>
		</cfif>
	</div>
	 <!--- ajax for /z/admin/site-option-group-deep-copy/getCopyMessage until it returns "", then refresh page... --->

	 <script type="text/javascript">
	 function ajaxMessageCallback(r){
	 	var r=eval('('+r+')');
	 	if(r.success){
	 		setMessage(r.message);
	 	}
	 }
	 function setMessage(m){
		var end = new Date().getTime();
		var time = end - start;
		$("##copyMessageDiv").html('<h2>Copying Status:</h2><p>'+m+'</p><p>Time elapsed: '+time+'</p>');
	 }
	 function ajaxCopyCallback(r){
	 	var r=eval('('+r+')');
	 	clearInterval(messageIntervalId);
	 	if(r.success){
	 		setMessage("Copy complete.");
	 		window.location.href=r.redirectURL;
	 	}else{
	 		setMessage(r.errorMessage);
	 	}
	 }
	 function checkMessage(){
		var obj={
			id:"ajaxGetMessage",
			method:"get",
			ignoreOldRequests:false,
			callback:ajaxMessageCallback,
			errorCallback:function(){},
			url:"/z/admin/site-option-group-deep-copy/getCopyMessage"
		}; 
		zAjax(obj);
	 }
	 var messageIntervalId=false;
	 var start = new Date().getTime();

	 function doDeepCopy(link){
	 	start = new Date().getTime();
	 	setMessage("Starting deep copy");
		var obj={
			id:"ajaxDoCopy",
			method:"get",
			ignoreOldRequests:false,
			callback:ajaxCopyCallback,
			errorCallback:function(){
	 			clearInterval(messageIntervalId);
				alert("There was an error while copying.");
			},
			url:link
		}; 
		zAjax(obj);
		messageIntervalId=setInterval(checkMessage, 1000);
	 }
	 </script>
</cffunction>
 
</cfoutput>
</cfcomponent>
