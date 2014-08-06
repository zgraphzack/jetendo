<cfcomponent>
<cfoutput>
<cffunction name="getFeatureMap" localmode="modern" returntype="struct">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT site_option_group.* 
	FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group  
	WHERE site_option_group.site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_parent_id = #db.param('0')# and 
	site_option_group_deleted = #db.param(0)# and 
	site_option_group_type =#db.param('1')# and 
	site_option_group.site_option_group_disable_admin=#db.param(0)# 
	ORDER BY site_option_group.site_option_group_display_name ASC ";
	qGroup=db.execute("qGroup"); 

	ms=structnew("linked");
	if(application.zcore.app.siteHasApp("blog")){
		ms["Blog"]={ parent:'', label:"Blog" };
		ms["Blog Articles"]={ parent:'Blog', label:chr(9)&"Blog Articles"};
		ms["Blog Categories"]={ parent:'Blog', label:chr(9)&"Blog Categories"};
		ms["Blog Tags"]={ parent:'Blog', label:chr(9)&"Blog Tags"};
	}
	ms["Content Manager"]={ parent:'', label:"Content Manager"};
	if(application.zcore.app.siteHasApp("content")){
		ms["Pages"]={ parent:'Content Manager', label:chr(9)&"Pages"};
		ms["Content Permissions"]={ parent:'Content Manager', label:chr(9)&"Content Permissions"};
	}	
	ms["Image Library"]={ parent:'Content Manager', label:chr(9)&"Images Library"};
	ms["Files & Images"]={ parent:'Content Manager', label:chr(9)&"Files & Images"};
	ms["Menus"]={ parent:'Content Manager', label:chr(9)&"Menus"};
	ms["Problem Link Report"]={ parent:'Content Manager', label:	chr(9)&"Problem Link Report"};
	ms["Slideshows"]={ parent:'Content Manager', label:chr(9)&"Slideshows"};
	ms["Site Options"]={ parent:'Content Manager', label:chr(9)&"Site Options"};
	if(request.zos.isTestServer){
		ms["Manage Design & Layout"]={ parent:'Content Manager', label:chr(9)&"Manage Design & Layout"};
	}
	if(application.zcore.functions.zso(request.zos.globals, 'lockTheme', true, 1) EQ 0){
		ms["Themes"]={ parent:'Content Manager', label:chr(9)&"Themes"};
	}
	ms["Video Library"]={ parent:'Content Manager', label:chr(9)&"Video Library"};
	if(qGroup.recordcount NEQ 0){
		ms["Custom"]={ parent:'', label: "Custom"};
		// loop the groups
		// get the code from manageoptions"
		// site_option_group_disable_admin=0
		for(row in qGroup){
			ms["Custom: "&row.site_option_group_display_name]={ parent:'Custom', label:chr(9)&row.site_option_group_display_name&chr(10)};
		}
	}
	ms["Leads"]={ parent:'', label:"Leads"};
	ms["Manage Leads"]={ parent:'Leads', label:chr(9)&"Manage Leads"};
	ms["Lead Types"]={ parent:'Leads', label:chr(9)&"Lead Types"};
	ms["Lead Source Report"]={ parent:'Leads', label:chr(9)&"Lead Source Report"};
	ms["Lead Templates"]={ parent:'Leads', label:chr(9)&"Lead Templates"};
	ms["Lead Reports"]={ parent:'Leads', label:chr(9)&"Lead Reports"};
	ms["Lead Export"]={ parent:'Leads', label:chr(9)&"Lead Export"};
	ms["Mailing List Export"]={ parent:'Leads', label:chr(9)&"Mailing List Export"};
	ms["Lead Routing"]={ parent:'Leads', label:chr(9)&"Lead Routing"};

	if(application.zcore.app.siteHasApp("listing")){
		ms["Listings"]={ parent:'', label:"Listings"};
		ms["Manage Listings"]={ parent:'Listings', label:chr(9)&"Manage Listings"};
		ms["Listing Research Tool"]={ parent:'Listings', label:chr(9)&"Listing Research Tool"};
		ms["Saved Listing Searches"]={ parent:'Listings', label:chr(9)&"Saved Listing Searches"};
		ms["Listing Search Filter"]={ parent:'Listings', label:chr(9)&"Listing Search Filter"};
		ms["Widgets For Other Sites"]={ parent:'Listings', label:chr(9)&"Widgets For Other Sites"};
	}

	if(application.zcore.app.siteHasApp("rental")){
		ms["Rentals"]={ parent:'', label:"Rentals"};
		ms["Manage Rentals"]={ parent:'Rentals', label:chr(9)&"Manage Rentals"};
		ms["Rental Amenities"]={ parent:'Rentals', label:chr(9)&"Rental Amenities"};
		ms["Rental Categories"]={ parent:'Rentals', label:chr(9)&"Rental Categories"};
		ms["Rental Calendars"]={ parent:'Rentals', label:	chr(9)&"Rental Calendars"};
		ms["Rental Reservations"]={parent:'Rentals', label: chr(9)&"Rental Reservations"};
	}
	ms["Users"]={ parent:'', label:"Users"};
	ms["Manage Users"]={ parent:'Users', label:chr(9)&"Manage Users"};
	ms["Offices"]={ parent:'Users', label:chr(9)&"Offices"};

	return ms;
	</cfscript>
</cffunction>


<cffunction name="getFormField" localmode="modern">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	ms=getFeatureMap();
	arrValue=[];
	arrLabel=[];
	for(i in ms){
		arrayAppend(arrLabel, replace(ms[i].label, chr(9), "__", "all"));
		arrayAppend(arrValue, i);
	}

	application.zcore.functions.zRequireJqueryUI();
	application.zcore.skin.includeCSS("/z/javascript/jquery/jquery-ui-multiselect-widget/jquery.multiselect.css");
	application.zcore.skin.includeCSS("/z/javascript/jquery/jquery-ui-multiselect-widget/jquery.multiselect.filter.css");
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery-ui-multiselect-widget/src/jquery.multiselect.js", '', 2);
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery-ui-multiselect-widget/src/jquery.multiselect.filter.js", '', 2);
	application.zcore.skin.addDeferredScript('
		$("###arguments.fieldName#").multiselect().multiselectfilter();
	');
	selectStruct = StructNew();
	selectStruct.multiple=true;
	selectStruct.size=10;
	selectStruct.name = arguments.fieldName;
	selectStruct.listLabelsDelimiter = ",";
	selectStruct.listValuesDelimiter = ",";
	selectStruct.listLabels=arrayToList(arrLabel, ",");
	selectStruct.listValues=arrayToList(arrValue, ",");
	application.zcore.functions.zInputSelectBox(selectStruct);

	</cfscript><br />By default, a user has access to all features for the group they are assigned to. Seleting one or more options here will limit them to the selected options only.  All other existing and future features will be hidden.
</cffunction>

<cffunction name="validateFeatureAccessList" localmode="modern" returntype="string">
	<cfargument name="featureList" type="string" required="yes">
	<cfscript>
	arrFeature=listToArray(arguments.featureList, ",");
	fs={};
	for(i=1;i LTE arraylen(arrFeature);i++){
		if(not structkeyexists(application.siteStruct[request.zos.globals.id].adminFeatureMapStruct, arrFeature[i])){
			throw(arrFeature[i]&" is not a valid admin feature name. Please review/modify the features in adminSecurityFilter.cfc.");
		}
		fs[arrFeature[i]]=true;
		currentFeature=application.siteStruct[request.zos.globals.id].adminFeatureMapStruct[arrFeature[i]];
		if(currentFeature.parent NEQ ""){
			fs[currentFeature.parent]=true;
		}
	}
	return structkeylist(fs, ",");
	</cfscript>
</cffunction>


<cffunction name="auditFeatureAccess" localmode="modern" returntype="any">
	<cfargument name="featureName" type="string" required="yes">
	<cfargument name="requiresWriteAccess" type="boolean" required="no" default="#false#">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>

	if(arguments.requiresWriteAccess or request.zos.auditTrackReadOnlyRequests){
		ts={
			table:"audit",
			datasource:request.zos.zcoreDatasource,
			struct:{
				audit_description:"",
				site_id:request.zos.globals.id,
				audit_url:request.zos.originalURL&"?"&request.zos.cgi.query_string,
				audit_updated_datetime:request.zos.mysqlnow,
				audit_security_feature:arguments.featureName,
				audit_ip:request.zos.cgi.remote_addr,
				audit_user_agent:request.zos.cgi.http_user_agent
			}
		}
		if(arguments.requiresWriteAccess){
			ts.struct.audit_security_action_write=1;
		}
		if(isdefined('request.zsession.user.id')){
			ts.struct.user_id=request.zsession.user.id;
		}
		application.zcore.functions.zInsert(ts);
	}
	</cfscript>
</cffunction>

<cffunction name="requireFeatureAccess" localmode="modern" returntype="any">
	<cfargument name="featureName" type="string" required="yes">
	<cfargument name="requiresWriteAccess" type="boolean" required="no" default="#false#">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	if(not application.zcore.adminSecurityFilter.checkFeatureAccess(arguments.featureName, arguments.site_id)){ 
		application.zcore.status.setStatus(request.zsid, "You don't have permission to use that feature.", form, true);
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	// check for write access
	if(arguments.requiresWriteAccess and not application.zcore.user.checkServerAccess() and request.zos.globals.enableDemoMode EQ 1){
		application.zcore.status.setStatus(request.zsid, "You don't have write access for the #arguments.featureName# feature because this web site is in demo mode.", form, true);
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	auditFeatureAccess(arguments.featureName, arguments.requiresWriteAccess, arguments.site_id);
	</cfscript>
</cffunction>

<cffunction name="checkFeatureAccess" localmode="modern" returntype="boolean">
	<cfargument name="featureName" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	userSiteId='user';
	if(arguments.site_id NEQ request.zos.globals.id){
		userSiteId='user'&arguments.site_id;
	} 
	if(structkeyexists(request.zsession,userSiteId)){
		if(not structkeyexists(request.zsession[userSiteId], 'limitManagerFeatureStruct') or structcount(request.zsession[userSiteId].limitManagerFeatureStruct) EQ 0){
			return true;
		}else{
			//if(structkeyexists(arguments.functionMetaData, 'jetendo-admin-feature')){
			arrFeature=listToArray(arguments.featureName, ",");
			for(i=1;i LTE arraylen(arrFeature);i++){
				if(not structkeyexists(application.siteStruct[request.zos.globals.id].adminFeatureMapStruct, arrFeature[i])){
					throw(arrFeature[i]&" is not a valid admin feature name. Please review/modify the features in adminSecurityFilter.cfc.");
				}
				if(not structkeyexists(request.zsession[userSiteId].limitManagerFeatureStruct, arrFeature[i])){
					currentFeature=application.siteStruct[request.zos.globals.id].adminFeatureMapStruct[arrFeature[i]];
					return false;
				}
			}
			return true;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction>
</cfoutput>

</cfcomponent>