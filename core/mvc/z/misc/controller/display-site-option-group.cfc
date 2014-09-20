<cfcomponent>
<cffunction name="insert" localmode="modern" access="remote">
	<cfscript>
	local.soCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");
	local.soCom.publicInsertGroup();
	</cfscript>
</cffunction>

<cffunction name="ajaxInsert" localmode="modern" access="remote">
	<cfscript>
	local.soCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");
	rs=local.soCom.publicAjaxInsertGroup();
    if(not rs.success){
    	arrError=application.zcore.status.getErrors(rs.zsid);
    	rs.errorMessage=arrayToList(arrError, chr(10));
    	rs.arrErrorField=application.zcore.status.getErrorFields(rs.zsid);
    }
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote">
	<cfscript>
	local.soCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");
	local.soCom.publicAddGroup();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	var qSet=0;
	/*
	Need url rewrite rule to route urls to this.
	request.zos.globals.optionGroupURLID - is the app_id
	form.site_x_option_group_set_id should be defined by the rewrite rule
	
	*/
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
	db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set,
	#db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
	site_option_group_deleted = #db.param(0)# and 
	site_x_option_group_set_deleted = #db.param(0)# and 
	site_option_group.site_option_group_id = site_x_option_group_set.site_option_group_id and 
	site_x_option_group_set.site_id = site_option_group.site_id and 
	site_x_option_group_set.site_id=#db.param(request.zos.globals.id)# ";
	if(not structkeyexists(form, 'zpreview')){
		db.sql&=" and site_x_option_group_set.site_x_option_group_set_approved=#db.param(1)#";
	}
	qSet=db.execute("qSite");
	if(qSet.recordcount EQ 0){
		application.zcore.functions.z404("form.site_x_option_group_set_id, #form.site_x_option_group_set_id#, doesn't exist.");
	}else{
		//writeoutput('query output'&qSite.site_id);
	}
	if(structkeyexists(form, 'zURLName')){
		local.encodedTitle=application.zcore.functions.zURLEncode(qSet.site_x_option_group_set_title, '-');
		if(qSet.site_x_option_group_set_override_url NEQ ""){
			if(compare(qSet.site_x_option_group_set_override_url, request.zos.originalURL) NEQ 0){
				application.zcore.functions.z301Redirect(qSet.site_x_option_group_set_override_url);
			}
		}else{
			if(compare(form.zURLName, local.encodedTitle) NEQ 0){
				application.zcore.functions.z301Redirect("/#local.encodedTitle#-#request.zos.globals.optionGroupURLID#-#qSet.site_x_option_group_set_id#.html");
			}
		}
	}
	if(qSet.site_option_group_view_cfc_path NEQ ""){
		if(left(qSet.site_option_group_view_cfc_path, 5) EQ "root."){
			local.cfcpath=replace(qSet.site_option_group_view_cfc_path, 'root.',  request.zRootCfcPath);
		}else{
			local.cfcpath=qSet.site_option_group_view_cfc_path;
		}
		local.groupCom=createobject("component", local.cfcpath);
		local.groupCom[qSet.site_option_group_view_cfc_method](qSet);
	}else{
		throw("site_option_group_view_cfc_path and site_option_group_view_cfc_method must be set when editing the site option group to allow rendering of the group.", "custom");
	}
	
	</cfscript>
</cffunction>
</cfcomponent>