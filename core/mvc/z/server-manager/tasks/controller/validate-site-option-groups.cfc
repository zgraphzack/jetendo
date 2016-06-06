<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	setting requesttimeout="300";
	var db=request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");  
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	echo('<h2>Validate Site Option Groups</h2>');
	arrError=[];
	// get all sites
	db.sql="SELECT * 
	FROM #db.table("site", request.zos.zcoreDatasource)#
	WHERE 
	site.site_id <> #db.param(-1)# and 
	site_deleted=#db.param(0)# and 
	site_active=#db.param(1)# 
	ORDER BY site_short_domain ASC";
	qSite=db.execute("qSite");

	for(site in qSite){

		// get all groups
		db.sql="SELECT * 
		FROM #db.table("site_option_group", request.zos.zcoreDatasource)#
		WHERE 
		site_id = #db.param(site.site_id)# and 
		site_option_group_deleted=#db.param(0)# 
		ORDER BY site_option_group_name ASC";
		qGroup=db.execute("qGroup");
		for(group in qGroup){
			hasURLTitleField=false;
			// get all fields

			db.sql="SELECT * 
			FROM #db.table("site_option", request.zos.zcoreDatasource)#
			WHERE 
			site_option_group_id=#db.param(group.site_option_group_id)# and 
			site_id = #db.param(site.site_id)# and 
			site_option_deleted=#db.param(0)# 
			ORDER BY site_option_name ASC";
			qField=db.execute("qField");
			for(field in qField){
				if(group.site_option_group_enable_unique_url EQ 1){
					if(field.site_option_url_title_field){
						hasURLTitleField=true;
					}
				}
				if(group.site_option_group_allow_public EQ 1 and field.site_option_allow_public EQ 0){
					arrayAppend(arrError, 'site: #site.site_short_domain# | group: "#group.site_option_group_name#" | option: "#field.site_option_name#" is not set to allow public, which may be a mistake or it could be intentional.');
				}
				if(field.site_option_type_id EQ 1 or field.site_option_type_id EQ 2){
					if(field.site_option_primary_field EQ 1){
						arrayAppend(arrError, 'site: #site.site_short_domain# | group: "#group.site_option_group_name#" | option: "#field.site_option_name#" should not have list view set to yes because it is long HTML/textarea field. Use shorter fields instead.');
					}
				}
			}
			if(group.site_option_group_enable_unique_url EQ 1){
				if(not hasURLTitleField){
					arrayAppend(arrError, 'site: #site.site_short_domain# | group: "#group.site_option_group_name#" doesn''t have any options with "Use for URL Title" set to yes.');
				}
			}


			// detect html / text area fields that are being displayed on list view


		}
	}

	if(arrayLen(arrError)){
		savecontent variable="out"{
			echo('<h2>The following errors were detected.</h2>');
			echo(arrayToList(arrError, '<hr />'));
		}
		if(request.zos.isDeveloper){
			echo(out);
		}else{
			ts={
				type:"Custom",
				errorHTML:out,
				scriptName:'/z/server-manager/tasks/validate-site-option-groups',
				url:request.zos.originalURL,
				exceptionMessage:'#arrayLen(arrError)# site option group errors detected',
				// optional
				lineNumber:'1'
			}
			application.zcore.functions.zLogError(ts);
		}
	}
	</cfscript>
	
</cffunction>
</cfoutput>
</cfcomponent>