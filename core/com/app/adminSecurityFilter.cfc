<cfcomponent>
<cfoutput>
<cffunction name="getFeatureMap" localmode="modern" returntype="struct">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT site_option_group.* 
	FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group  
	WHERE site_option_group.site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_parent_id = #db.param('0')# and 
	site_option_group_type =#db.param('1')# and 
	site_option_group.site_option_group_appidlist like #db.param('%,,%')# and
	site_option_group.site_option_group_disable_admin=#db.param(0)# 
	ORDER BY site_option_group.site_option_group_display_name ASC ";
	qGroup=db.execute("qGroup");

	ms=structnew("linked");
	ms["Blog"]="Blog";
	ms["Blog Articles"]=chr(9)&"Blog Articles";
	ms["Blog Categories"]=chr(9)&"Blog Categories";
	ms["Blog Tags"]=chr(9)&"Blog Tags";
	ms["Content Manager"]="Content Manager";
	ms["Pages"]="Pages";
	ms["Files & Images"]=chr(9)&"Files & Images";
	ms["Menus"]=chr(9)&"Menus";
	ms["Pages"]=chr(9)&"Pages";
	ms["Problem Link Report"]=	chr(9)&"Problem Link Report";
	ms["Slideshows"]=chr(9)&"Slideshows";
	ms["Site Options"]=chr(9)&"Site Options";
	ms["Video Library"]=chr(9)&"Video Library";
	ms["Custom"]= "Custom";
	// loop the groups
	// get the code from manageoptions"
	// site_option_group_disable_admin=0
	for(row in qGroup){
		ms["Custom: "&row.site_option_group_display_name]=chr(9)&row.site_option_group_display_name&chr(10);
	}
	ms["Leads"]="Leads";
	ms["Lead Types"]=chr(9)&"Lead Types";
	ms["Lead Templates"]=chr(9)&"Lead Templates";
	ms["Lead Reports"]=chr(9)&"Lead Reports";
	ms["Lead Export"]=chr(9)&"Lead Export";
	ms["Mailing List Export"]=chr(9)&"Mailing List Export";
	ms["Lead Routing"]=chr(9)&"Lead Routing";
	ms["Listings"]="Listings";
	ms["Listings"]=chr(9)&"Listings";
	ms["Research Tool"]=chr(9)&"Research Tool";
	ms["Saved Searches"]=chr(9)&"Saved Searches";
	ms["Search Filter"]=chr(9)&"Search Filter";
	ms["Widgets For Other Sites"]=chr(9)&"Widgets For Other Sites";
	ms["Rentals"]="Rentals";
	ms["Rentals"]=chr(9)&"Rentals";
	ms["Amenities"]=chr(9)&"Amenities";
	ms["Rental Categories"]=chr(9)&"Rental Categories";
	ms["Rental Calendars"]=	chr(9)&"Rental Calendars";
	ms["Shared Documents"]=	"Shared Documents";
	ms["Users"]="Users";
	ms["Users"]=chr(9)&"Users";
	ms["Offices"]=chr(9)&"Offices";
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
		arrayAppend(arrLabel, replace(ms[i], chr(9), "__", "all"));
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

	</cfscript><br />By default, a user has access to all features for the group they are assign to. Seleting one or more options here will limit them to the selected options only.  All other existing and future features will be hidden.
</cffunction>


<cffunction name="pageRequiresFeature" localmode="modern" returntype="boolean">
	<cfscript>
	// rather do this by removing manager links first
	// then add attributes to cffunction everywhere like jetendo-admin-feature="Blog" and
	//  upgrade the URL security filter in routing.cfc to call this cfc
	
	</cfscript>
</cffunction>

<cffunction name="page2" localmode="modern" jetendo-admin-feature="Slideshows" returntype="boolean">
	// rather do this by removing manager links first
	// then add attributes to cffunction everywhere like jetendo-admin-feature="Blog" and
	//  upgrade the URL security filter in routing.cfc to call this cfc
</cffunction>

<cffunction name="checkFeatureAccess" localmode="modern" returntype="boolean">
	<cfargument name="functionMetaData" type="struct" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	userSiteId='user';
	if(arguments.site_id NEQ request.zos.globals.id){
		userSiteId='user'&arguments.site_id;			
	}
	if(structkeyexists(session, 'zos') and structkeyexists(session.zos,userSiteId)){
		if(not structkeyexists(session.zOS[userSiteId], 'limitManagerFeatureStruct') or structcount(session.zOS[userSiteId].limitManagerFeatureStruct) EQ 0){
			return true;
		}else{
			if(structkeyexists(arguments.functionMetaData, 'jetendo-admin-feature')){
				arrFeature=listToArray(arguments.functionMetaData['jetendo-admin-feature'], ",");
				for(i=1;i LTE arraylen(arrFeature);i++){
					if(not structkeyexists(application.siteStruct[request.zos.globals.id].adminFeatureMapStruct, arrFeature[i])){
						throw(arrFeature[i]&" is not a valid admin feature name. Please review/modify the features in adminSecurityFilter.cfc.");
					}
					if(not structkeyexists(session.zOS[userSiteId].limitManagerFeatureStruct, arrFeature[i])){
						return false;
					}
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