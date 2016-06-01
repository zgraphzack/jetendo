<cfcomponent>
<cffunction name="insert" localmode="modern" access="remote">
	<cfscript>
	local.soCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");
	local.soCom.publicInsertGroup();
	</cfscript>
</cffunction>

<cffunction name="insertAndReturn" localmode="modern" access="remote">
	<cfscript>
	local.soCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");
	rs=local.soCom.publicAjaxInsertGroup();
	return rs;
	</cfscript>
</cffunction>


<cffunction name="ajaxInsert" localmode="modern" access="remote">
	<cfscript>
	local.soCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");
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
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id', true);
	local.soCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");
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
	site_x_option_group_set_master_set_id = #db.param(0)# and 
	site_x_option_group_set_deleted = #db.param(0)# and 
	site_option_group_enable_unique_url=#db.param(1)# and 
	site_option_group.site_option_group_id = site_x_option_group_set.site_option_group_id and 
	site_x_option_group_set.site_id = site_option_group.site_id and 
	site_x_option_group_set.site_id=#db.param(request.zos.globals.id)# ";
	if(not structkeyexists(form, 'zpreview')){
		db.sql&=" and site_x_option_group_set.site_x_option_group_set_approved=#db.param(1)#";
	}
	qSet=db.execute("qSet");
	if(qSet.recordcount EQ 0){
		application.zcore.functions.z404("form.site_x_option_group_set_id, #form.site_x_option_group_set_id#, doesn't exist.");
	}else{
		//writeoutput('query output'&qSite.site_id);
	} 
	echo('<div id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/admin/site-options/editGroup?site_option_app_id=#qSet.site_option_app_id#&site_option_group_id=#qSet.site_option_group_id#&site_x_option_group_set_id=#qSet.site_x_option_group_set_id#&site_x_option_group_set_parent_id=#qSet.site_x_option_group_set_parent_id#&returnURL=#urlencodedformat(request.zos.originalURL)#">');
	if(qSet.site_option_group_enable_meta EQ "1"){
		application.zcore.template.setTag("title", qSet.site_x_option_group_set_metatitle);
		application.zcore.template.prependTag('meta', '<meta name="keywords" content="#htmleditformat(qSet.site_x_option_group_set_metakey)#" /><meta name="description" content="#htmleditformat(qSet.site_x_option_group_set_metadesc)#" />');
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
		local.groupCom=application.zcore.functions.zcreateobject("component", local.cfcpath);
		local.groupCom[qSet.site_option_group_view_cfc_method](qSet);
	}else{
		application.zcore.functions.z404("site_option_group_view_cfc_path and site_option_group_view_cfc_method must be set when editing the site option group to allow rendering of the group.");
	}
	echo('</div>');
	
	</cfscript>
</cffunction>
</cfcomponent>