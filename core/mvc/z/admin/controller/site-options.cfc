<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject;
	var qSiteOptionApp=0; 
	variables.allowGlobal=false;
	form.site_id=request.zos.globals.id;
	variables.siteIdList="'"&request.zos.globals.id&"'";
	variables.publicSiteIdList="'0','"&request.zos.globals.id&"'";
	if(application.zcore.user.checkGroupAccess("user")){
		if(request.zos.isDeveloper){
			variables.allowGlobal=true;
			variables.siteIdList="'0','"&request.zos.globals.id&"'";
		}
	}
	form.site_option_app_id=application.zcore.functions.zso(form, 'site_option_app_id',false,0);
	if(form.site_option_app_id NEQ 0){//left(request.cgi_script_name, 21) EQ '/z/_com/app/site-option'){
		application.zcore.template.setTemplate("zcorerootmapping.templates.blank",true,true);
		db.sql="select * FROM #db.table("site_option_app", request.zos.zcoreDatasource)# site_option_app 
		where site_option_app_id=#db.param(form.site_option_app_id)# and 
		site_id=#db.param(request.zos.globals.id)#";
		qSiteOptionApp=db.execute("qSiteOptionApp");
		if(qSiteOptionApp.recordcount EQ 0){
			writeoutput('Invalid Request');
			application.zcore.functions.zabort();	
		}
		variables.currentAppId=qSiteOptionApp.app_id;
	}else{
		variables.currentAppId="0";
	}
	if(not application.zcore.functions.zIsWidgetBuilderEnabled()){
		if(form.method EQ "manageoptions" or form.method EQ "add" or form.method EQ "edit"){
			application.zcore.functions.z301Redirect('/member/');
		}
	}
	
	variables.recurseCount=0;
	</cfscript>
	<cfif form.method NEQ "internalGroupUpdate" and form.method NEQ "publicAddGroup" and application.zcore.user.checkGroupAccess("member") and application.zcore.functions.zIsWidgetBuilderEnabled()>
		<table style="border-spacing:0px; width:100%; " class="table-list">
			<tr>
				<cfif form.method NEQ "list">
					<th><a href="/z/admin/site-options/index?site_option_app_id=#form.site_option_app_id#">Site Options</a></th>
				</cfif>
				<th style="text-align:right;"><strong>Change Structure:</strong> For Advanced Users Only! 
				<cfif application.zcore.functions.zso(form, 'site_option_group_id') NEQ "">
					Current Group:
					<a href="/z/admin/site-option-group/edit?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#">Edit</a> | 
					<a href="/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#">Edit Options</a> | 
				</cfif>
				Manage: 
				<a href="/z/admin/sync/index">Sync</a> | 
				<a href="/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#">Options</a> | 
				<a href="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#">Groups</a> | 
				Add: <a href="/z/admin/site-options/add?site_option_app_id=#form.site_option_app_id#&amp;return=1">Option</a> | 
				<a href="/z/admin/site-option-group/add?site_option_app_id=#form.site_option_app_id#&amp;return=1">Group</a></th>
			</tr>
		</table>
		<br />
	</cfif>
</cffunction>



<cffunction name="import" localmode="modern" access="remote" roles="member">
	<cfscript>
	var row=0;
	var qOption=0;
	var db=request.zos.queryObject;
	variables.init();
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id');
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
	site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	local.qS=db.execute("qS");
	if(local.qS.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Site option group doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index?zsid=#request.zsid#");
	}
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id');
	// all options except for html separator
	db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# WHERE 
	site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_type_id <> #db.param(11)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qOption=db.execute("qOption");
	local.arrRequired=arraynew(1);
	local.arrOptional=arraynew(1);
	for(row in qOption){
		if(row.site_option_required EQ 1){
			arrayAppend(local.arrRequired, row.site_option_name);	
		}else{
			arrayAppend(local.arrOptional, row.site_option_name);	
		}
	}
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h3>File Import for Group: #local.qS.site_option_group_display_name#</h3> 
	<p>The first row of the CSV file should contain the required fields and as many optional fields as you wish.</p>
	<p>If a value doesn't match the system, it will be left blank when imported.</p> 
	<p>Required fields:<br /><textarea type="text" cols="100" rows="2" name="a1">#arrayToList(local.arrRequired, chr(9))#</textarea></p>
	<p>Optional fields:<br /><textarea type="text" cols="100" rows="2" name="a2">#arrayToList(local.arrOptional, chr(9))#</textarea></p>
	<form action="/z/admin/site-options/processImport?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#" enctype="multipart/form-data" method="post">
		<p><input type="file" name="filepath" value="" /></p>
		<cfif request.zos.isDeveloper>
			<h2>Specify optional CFC filter.</h2>
			<p>A struct with each column name as a key will be passed as the first argument to your custom function.</p>
			<p>Code example<br />
			<textarea type="text" cols="100" rows="4" name="a3">#htmleditformat('<cfcomponent>
			<cffunction name="importFilter" localmode="modern" roles="member">
			<cfargument name="struct" type="struct" required="yes">
			<cfscript>
			if(arguments.struct["column1"] EQ "bad value"){
			arguments.struct["column1"]="correct value";
			}
			</cfscript>
			</cffunction>
			</cfcomponent>')#</textarea></p>
			<p>Filter CFC CreateObject Path: <input type="text" name="cfcPath" value="" /> (i.e. root.myImportFilter)</p>
			<p>Filter CFC Method: <input type="text" name="cfcMethod" value="" /> (i.e. functionName)</p>
		</cfif>
		 <input type="submit" name="submit1" value="Import CSV" onclick="this.style.display='none';document.getElementById('pleaseWait').style.display='block';" />
		<div id="pleaseWait" style="display:none;">Please wait...</div>
	</form>
</cffunction>

<cffunction name="processImport" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var fileContents=0;
	var d1=0;
	var qOption=0;
	var dataImportCom=0;
	var n=0;
	var row=0;
	var g=0;
	var arrData=0;
	var arrSiteOptionId=0;
	var f1=0;
	var t38=0;
	var i=0;
	var ts=0;
	var ts2=0;
	setting requesttimeout="10000";
	form.site_option_app_id=application.zcore.functions.zso(form, 'site_option_app_id');
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id');
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
	site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	local.qS=db.execute("qS");
	if(local.qS.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Site option group doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index?zsid=#request.zsid#");
	}
	// all options except for html separator
	db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# WHERE 
	site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_type_id <> #db.param(11)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qOption=db.execute("qOption");
	local.arrRequired=arraynew(1);
	local.arrOptional=arraynew(1);
	local.requiredStruct={};
	local.optionalStruct={};
	local.defaultStruct={};
	var siteOptionIdLookupByName={}; 
	var dataStruct={};
	
	
	for(row in qOption){
		siteOptionIdLookupByName[row.site_option_name]=row.site_option_id;
		local.defaultStruct[row.site_option_name]=row.site_option_default_value;
		
		optionStruct=deserializeJson(row.site_option_type_json); 
		var currentCFC=application.zcore.siteOptionTypeStruct[row.site_option_type_id];
		dataStruct[row.site_option_id]=currentCFC.onBeforeImport(row, optionStruct); 
		
		if(row.site_option_required EQ 1){
			local.requiredStruct[row.site_option_name]="";	
		}else{
			local.optionalStruct[row.site_option_name]="";
		}
	}
	 
	if(structkeyexists(form, 'filepath') EQ false or form.filepath EQ ""){
		application.zcore.status.setStatus(request.zsid, "You must upload a CSV file", true);
		application.zcore.functions.zRedirect("/z/admin/site-options/import?zsid=#request.zsid#&site_option_group_id=#form.site_option_group_id#&site_option_app_id=#form.site_option_app_id#");
	}
	f1=application.zcore.functions.zuploadfile("filepath", request.zos.globals.privatehomedir&"/zupload/user/",false);
	fileContents=application.zcore.functions.zreadfile(request.zos.globals.privatehomedir&"/zupload/user/"&f1);
	d1=application.zcore.functions.zdeletefile(request.zos.globals.privatehomedir&"/zupload/user/"&f1);
	 
	dataImportCom = CreateObject("component", "zcorerootmapping.com.app.dataImport");
	dataImportCom.parseCSV(fileContents);
	dataImportCom.getFirstRowAsColumns(); 
	local.requiredCheckStruct=duplicate(local.requiredStruct); 
	ts=StructNew();
	for(n=1;n LTE arraylen(dataImportCom.arrColumns);n++){
		dataImportCom.arrColumns[n]=trim(dataImportCom.arrColumns[n]);
		if(not structkeyexists(local.defaultStruct, dataImportCom.arrColumns[n]) ){
			application.zcore.status.setStatus(request.zsid, "#dataImportCom.arrColumns[n]# is not a valid column name.  Please rename columns to match the supported fields or delete extra columns so no data is unintentionally lost during import.", false, true);
			application.zcore.functions.zRedirect("/z/admin/site-options/import?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&zsid=#request.zsid#");
		}
		structdelete(local.requiredCheckStruct, dataImportCom.arrColumns[n]);
		if(structkeyexists(ts, dataImportCom.arrColumns[n])){
			application.zcore.status.setStatus(request.zsid, "The column , ""#dataImportCom.arrColumns[n]#"",  has 1 or more duplicates.  Make sure only one column is used per field name.", false, true);
			application.zcore.functions.zRedirect("/z/admin/site-options/import?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&zsid=#request.zsid#"); 
		}
		ts[dataImportCom.arrColumns[n]]=dataImportCom.arrColumns[n];
	}
	if(structcount(local.requiredCheckStruct)){
		application.zcore.status.setStatus(request.zsid, "The following required fields were missing in the column header of the CSV file: "&structKeyList(local.requiredCheckStruct)&".", false, true);
		application.zcore.functions.zRedirect("/z/admin/site-options/import?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&zsid=#request.zsid#"); 
	} 
	dataImportCom.mapColumns(ts);
	arrData=arraynew(1);
	local.curCount=dataImportCom.getCount();
	for(g=1;g  LTE local.curCount;g++){
		ts=dataImportCom.getRow();	
		for(i in local.requiredStruct){
			if(trim(ts[i]) EQ ""){
				application.zcore.status.setStatus(request.zsid, "#i# was empty on row #g# and it is a required field.  Make sure all required fields are entered and re-import.", false, true);
				application.zcore.functions.zRedirect("/z/admin/site-options/import?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&zsid=#request.zsid#"); 
			}
		}
		// check required fields are set for all rows
	}
	dataImportCom.resetCursor();
	//dataImportCom.skipLine();
	arrSiteOptionId=[];
	for(i in defaultStruct){
		arrayAppend(arrSiteOptionId, siteOptionIdLookupByName[i]); 
	}
	form.site_x_option_group_set_id=0;
	form.site_id=request.zos.globals.id;
	form.site_x_option_group_set_parent_id=0;
	form.site_option_id=arraytolist(arrSiteOptionId, ",");
	
	filterEnabled=false;
	if(request.zos.isDeveloper){
		if(form.cfcPath NEQ "" and form.cfcMethod NEQ ""){
			if(left(form.cfcPath, 5) EQ "root."){
				form.cfcPath=request.zrootcfcpath&removechars(form.cfcPath, 1, 5);
			}
			filterInstance=createobject("component", form.cfcPath);	
			filterEnabled=true;
		}
	}
	request.zos.disableSiteCacheUpdate=true; 
	for(g=1;g  LTE local.curCount;g++){
		ts=dataImportCom.getRow();	
		for(i in ts){
			ts[i]=trim(ts[i]);
			if(len(ts[i]) EQ 0){
				structdelete(ts, i);
			}
		}
		if(filterEnabled){
			filterInstance[form.cfcMethod](ts);
		}
		structappend(ts, defaultStruct, false);  
		for(i in defaultStruct){ 
			if(structkeyexists(dataStruct, siteOptionIdLookupByName[i]) and dataStruct[siteOptionIdLookupByName[i]].mapData){
				if(structkeyexists(dataStruct[siteOptionIdLookupByName[i]].struct, ts[i])){
					ts[i]=dataStruct[siteOptionIdLookupByName[i]].struct[ts[i]];
				}else{
					ts[i]="";
				}
			} 
			form['newvalue'&siteOptionIdLookupByName[i]]=ts[i];
		}   
		//writedump(ts);		writedump(form);		abort;
		form.site_x_option_group_set_approved=1;
		local.rs=this.importInsertGroup(); 
		arrayClear(request.zos.arrQueryLog);
	} 
	// update cache only once for better performance.
	application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
	application.zcore.status.setStatus(request.zsid, "Import complete.");
	application.zcore.functions.zRedirect("/z/admin/site-options/import?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&zsid=#request.zsid#");
	 
	</cfscript>
</cffunction> 


<cffunction name="recurseSOP" localmode="modern" output="yes" returntype="any">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="set_id" type="any" required="yes">
	<cfargument name="parent_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var local=structnew();
	if(arguments.set_id EQ false){
		local.setSQL="";	
	}else{
		local.setSQL=" and site_option_group.site_option_group_id ='"&application.zcore.functions.zescape(arguments.parent_id)&"' and 
		site_x_option_group_set.site_x_option_group_set_id = '"&application.zcore.functions.zescape(arguments.set_id)&"' ";
	}
	variables.recurseCount++;
	if(variables.recurseCount GT 20){
		writeoutput('Recurse is infinite');
		return;
	}
	db.sql="SELECT * FROM (#db.table("site_option", request.zos.zcoreDatasource)# site_option, 
	#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group) 
	LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# site_x_option_group ON 
	site_option.site_option_group_id = site_x_option_group.site_option_group_id and 
	site_option.site_option_id = site_x_option_group.site_option_id and 
	site_x_option_group.site_id = #db.param(arguments.site_id)#
	LEFT JOIN #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set ON 
	site_x_option_group_set.site_option_group_id = site_x_option_group.site_option_group_id and 
	site_x_option_group_set.site_x_option_group_set_id = site_x_option_group.site_x_option_group_set_id and 
	site_x_option_group_set.site_id = site_x_option_group.site_id 
    WHERE site_option.site_id IN (#db.param('0')#,#db.param(arguments.site_id)#) 
	"&local.setSQL&" and
    site_option_group.site_id = site_option.site_id and
    site_option_group.site_option_group_id = site_option.site_option_group_id and 
	site_option_group.site_option_group_type=#db.param('1')#
     ORDER BY site_option_group.site_option_group_parent_id asc, site_x_option_group.site_option_group_id asc, 
	 site_x_option_group_set.site_x_option_group_set_sort asc, site_option.site_option_name ASC";
	local.qS2=db.execute("qS2");
	 
	local.lastGroup="";
	local.lastSet="";
	local.curSet=0;
	local.ts=structnew();
	loop query="local.qs2"{
		if(local.lastGroup NEQ site_option_group_id){
			local.lastGroup=site_option_group_id;
			local.ts[site_option_group_id]=structnew();
			local.curGroup=local.ts[site_option_group_id];
		}
		if(local.lastSet NEQ site_x_option_group_set_id){
			local.lastSet=site_x_option_group_set_id;
			local.t92=structnew();
			local.t92.optionStruct=structnew();
			local.t92.childStruct=structnew();
			local.setCount=structcount(local.curGroup);
			local.curGroup[local.setCount+1]=local.t92;
			local.curSet=local.curGroup[local.setCount+1];
			local.curSet.childStruct=variables.recurseSOP(arguments.site_id, site_x_option_group_set_id, site_option_group_parent_id);
		}
		local.t9=structnew();
		if(form.site_option_type_id EQ 1 and site_option_line_breaks EQ 1){
			if(site_x_option_group_id EQ ""){
				local.t9.value=application.zcore.functions.zparagraphformat(site_option_default_value);
			}else{
				local.t9.value=application.zcore.functions.zparagraphformat(site_x_option_group_value);
			}
		}else{
			if(site_x_option_group_id EQ ""){
				local.t9.value=site_option_default_value;
			}else{
				local.t9.value=site_x_option_group_value;
			}
		}
		local.t9.editEnabled=site_option_edit_enabled;
		local.t9.sort=site_x_option_group_set_sort;
		local.t9.editURL="&amp;site_option_group_id="&site_option_group_id&"&amp;site_x_option_group_set_id="&site_x_option_group_set_id;
		local.curSet.optionStruct[site_option_name]=local.t9;
	}
	return local.ts;
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var siteIdSQL=0;
	var qS2=0;
	var theTitle=0;
	var i=0;
	var qS=0;
	var tempURL=0;
	var q=0;
	var queueSortStruct=0;
	var queueComStruct=0;
	variables.init();
	siteIdSQL=" ";
	if(form.site_option_group_id NEQ 0){
		siteIdSQL=" and site_option.site_id='"&application.zcore.functions.zescape(request.zos.globals.id)&"'";
		form.site_id =request.zos.globals.id;
		form.siteIDType=1;
	}else{
		if(structkeyexists(form, 'globalvar')){
			siteIdSQL=" and site_option.site_id='0'";
			form.site_id='0';
			form.siteIDType=4;
		}else{
			siteIdSQL=" and site_option.site_id='"&application.zcore.functions.zescape(request.zos.globals.id)&"'";
			form.site_id=request.zos.globals.id;
			form.siteIDType=1;
		}
	}
	db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
	WHERE site_option_id = #db.param(form.site_option_id)# and 
	site_id=#db.param(form.site_id)#";
	qS2=db.execute("qS2");
	if(qS2.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, "Site option no longer exists.",false,true);
		if(isDefined('session.siteoption_return')){
			tempURL = session['siteoption_return'];
			StructDelete(session, 'siteoption_return', true);
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(tempURL, true);
		}else{
			application.zcore.functions.zRedirect('/z/admin/site-options/manageoptions?site_option_group_id=#form.site_option_group_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid=#request.zsid#');
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		var arrSiteOptionIdCustomDeleteStruct=[];
		for(var i in application.zcore.siteOptionTypeStruct){
			if(application.zcore.siteOptionTypeStruct[i].hasCustomDelete()){
				arrayAppend(arrSiteOptionIdCustomDeleteStruct, application.zcore.functions.zescape(i));
			}
		}
		db.sql="SELECT * FROM #db.table("site_x_option", request.zos.zcoreDatasource)# site_x_option, 
		#db.table("site_option", request.zos.zcoreDatasource)# site_option 
		WHERE site_x_option.site_id = #db.param(request.zos.globals.id)# and 
		site_option.site_id=#db.param(form.site_id)# and 
		site_x_option.site_option_id = site_option.site_option_id and 
		site_option.site_option_id IN (#db.trustedSQL("'"&arrayToList(arrSiteOptionIdCustomDeleteStruct, "','")&"'")#) and 
		site_option.site_option_id=#db.param(form.site_option_id)#";
		qS=db.execute("qS");
		var row=0;
		for(row in qS){
			var currentCFC=application.zcore.siteOptionTypeStruct[row.site_option_type_id]; 
			var optionStruct=deserializeJson(row.site_option_type_json);
			currentCFC.onDelete(row, optionStruct); 
		} 
			
		db.sql="SELECT * FROM #db.table("site_x_option_group", request.zos.zcoreDatasource)# site_x_option_group, 
		#db.table("site_option", request.zos.zcoreDatasource)# site_option 
		WHERE site_x_option_group.site_id = #db.param(request.zos.globals.id)# and 
		site_option.site_id=#db.param(form.site_id)# and 
		site_x_option_group.site_option_id = site_option.site_option_id and 
		site_option.site_option_id IN (#db.trustedSQL("'"&arrayToList(arrSiteOptionIdCustomDeleteStruct, "','")&"'")#) and 
		site_option.site_option_id=#db.param(form.site_option_id)#";
		var qSGroup=db.execute("qSGroup"); 
		for(row in qSGroup){
			var currentCFC=application.zcore.siteOptionTypeStruct[row.site_option_type_id]; 
			var optionStruct=deserializeJson(row.site_option_type_json);
			currentCFC.onDelete(row, optionStruct); 
		} 
		form.site_id=request.zos.globals.id;
		db.sql="DELETE FROM #db.table("site_x_option", request.zos.zcoreDatasource)#  
		WHERE site_option_id = #db.param(form.site_option_id)# and 
		site_option_id_siteIDType=#db.param(form.siteIDType)# and 
		site_id = #db.param(request.zos.globals.id)#";
		q=db.execute("q");
		db.sql="DELETE FROM #db.table("site_x_option_group", request.zos.zcoreDatasource)#  
		WHERE site_option_id = #db.param(form.site_option_id)# and 
		site_option_id_siteIDType=#db.param(form.siteIDType)# and 
		site_id = #db.param(request.zos.globals.id)#";
		q=db.execute("q");
		application.zcore.functions.zDeleteRecord("site_option","site_option_id,site_id", request.zos.zcoreDatasource);
		if(qS2.site_id EQ 0){
			application.zcore.functions.zOS_rebuildCache();
		}else{
			for(i=1;i LTE qS.recordcount;i++){
				application.zcore.functions.zOS_cacheSiteAndUserGroups(qS.site_id[i]);
			}
		}
		if(qS2.site_option_group_id NEQ 0){
			queueSortStruct = StructNew();
			queueSortStruct.tableName = "site_option";
			queueSortStruct.sortFieldName = "site_option_sort";
			queueSortStruct.primaryKeyName = "site_option_id";
			queueSortStruct.datasource=request.zos.zcoreDatasource;
			queueSortStruct.where ="  site_option_group_id = '#application.zcore.functions.zescape(qS2.site_option_group_id)#' and 
			site_option.site_id ='#application.zcore.functions.zescape(request.zos.globals.id)#' ";
			
			queueSortStruct.disableRedirect=true;
			queueComStruct = CreateObject("component", "zcorerootmapping.com.display.queueSort");
			queueComStruct.init(queueSortStruct);
			queueComStruct.sortAll();
		}
		application.zcore.status.setStatus(request.zsid, "Site option deleted.");
		if(isDefined('session.siteoption_return')){
			tempURL = session['siteoption_return'];
			StructDelete(session, 'siteoption_return', true);
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(tempURL, true);
		}else{
			application.zcore.functions.zRedirect('/z/admin/site-options/manageOptions?site_option_group_id=#form.site_option_group_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid=#request.zsid#');
		}
		</cfscript>
	<cfelse>
		<cfscript>
		if(structkeyexists(form, 'return')){
			StructInsert(session, "siteoption_return"&form.site_option_id, request.zos.CGI.HTTP_REFERER, true);		
		}
		theTitle="Delete Site Option";
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
		</cfscript>
		<div style="text-align:center;"><span class="medium"> Are you sure you want to delete this site option?<br />
			<br />
			<strong>WARNING: </strong>This cannot be undone and any saved values will be deleted and any references to the site option on the web site will throw errors upon deletion.<br />
			<br />
			Make sure you have removed all hardcoded references from the source code before continuing!<br />
			<br />
			#qS2.site_option_name#<br />
			<br />
			<script type="text/javascript">
			/* <![CDATA[ */
			function confirmDelete(){
				var r=confirm("Are you sure you want to permanently delete this option?");
				if(r){
					window.location.href='/z/admin/site-options/delete?site_option_app_id=#form.site_option_app_id#&confirm=1&site_option_group_id=#form.site_option_group_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&site_option_id=#form.site_option_id#<cfif structkeyexists(form, 'globalvar')>&globalvar=1</cfif>';	
				}else{
					window.location.href='/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_option_group_parent_id=#form.site_option_group_parent_id#';
				}
			}
			/* ]]> */
			</script> 
			<a href="##" onclick="confirmDelete();return false;">Yes, delete this option</a><br />
			<br />
			<a href="/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;site_option_group_parent_id=#form.site_option_group_parent_id#">No, don't delete this option</a></span>
		</div>
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
	var qCheck=0;
	var result=0;
	var returnAppendString=0;
	var siteglobal=0;
	var tempURL=0;
	var qDF=0;
	var queueSortStruct=0;
	var queueComStruct=0;
	var ts=0;
	var myForm=structnew();
	var formaction=0;
	variables.init();
	if(form.method EQ 'insert'){
		formaction='add';	
	}else{
		formaction='edit';
	}
	if(structkeyexists(form, 'globalvar') or (application.zcore.functions.zso(form,'siteglobal', false, 0) EQ 1 and variables.allowGlobal)){
		form.site_id=0;	
		returnAppendString="&globalvar=1";
	}else{
		returnAppendString="";
		form.site_id=request.zos.globals.id;
	} 
	form.site_option_appidlist=","&application.zcore.functions.zso(form, 'site_option_appidlist')&",";
	
	if(form.method EQ "update"){
		db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# site_option 
		where site_option_id = #db.param(form.site_option_id)# and site_id = #db.param(form.site_id)#"; 
		qCheck=db.execute("qCheck");
		if(qCheck.site_id EQ 0 and variables.allowGlobal EQ false){
			application.zcore.functions.zRedirect("/z/admin/site-options/index");
		}
		// force code name to never change after initial creation
		form.site_option_name=qCheck.site_option_name;
	}
	myForm.site_option_display_name.required=true;
	myForm.site_option_display_name.friendlyName="Display Name";
	myForm.site_option_name.required = true;
	myForm.site_option_name.friendlyName="Code Name";
	result = application.zcore.functions.zValidateStruct(form, myForm, Request.zsid,true);
	if(result eq true){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.functions.zRedirect("/z/admin/site-options/#formAction#?zsid=#Request.zsid#&site_option_id=#form.site_option_id#"&returnAppendString);
	}
	var rs=0;
	var currentCFC=application.zcore.siteOptionTypeStruct[form.site_option_type_id];
	form.site_option_type_json="{}";
	// need this here someday: var rs=currentCFC.validateFormField(row, optionStruct, 'newvalue', form);
	rs=currentCFC.onUpdate(form);   
	if(not rs.success){ 
		application.zcore.functions.zRedirect("/z/admin/site-options/#formAction#?zsid=#Request.zsid#&site_option_id=#form.site_option_id#"&returnAppendString);	
	}
	db.sql="SELECT count(site_option_id) count 
	FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
	WHERE site_option_name = #db.param(form.site_option_name)# and 
	site_option_group_id =#db.param(form.site_option_group_id)# and 
	site_option_id <> #db.param(form.site_option_id)# and 
	site_id = #db.param(form.site_id)#";
	qDF=db.execute("qDF");
	if(qDF.count NEQ 0){
		application.zcore.status.setStatus(request.zsid,"Failed to create site option because ""#form.site_option_name#"" already exists. Please make the name unique.",form);
		application.zcore.functions.zRedirect("/z/admin/site-options/#formaction#?site_option_id=#form.site_option_id#&zsid=#request.zsid#"&returnAppendString);	
	}
	ts=structnew();
	ts.table="site_option";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ 'insert'){
		form.site_option_id=application.zcore.functions.zInsert(ts);
		if(form.site_option_id EQ false){
			application.zcore.status.setStatus(request.zsid,"Failed to create site option because ""#form.site_option_name#"" already exists. Please make the name unique.",form);
			application.zcore.functions.zRedirect("/z/admin/site-options/#formaction#?zsid=#request.zsid#"&returnAppendString);
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid,"Failed to UPDATE #db.table("site", request.zos.zcoreDatasource)# site option because ""#form.site_option_name#"" already exists. Please make the name unique.",form);
			application.zcore.functions.zRedirect("/z/admin/site-options/#formaction#?site_option_id=#form.site_option_id#&zsid=#request.zsid#"&returnAppendString);	
		}
	}
	
	if(siteglobal EQ 1){
		application.zcore.functions.zOS_rebuildCache();
	}else{
		application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
	}
	if(form.method EQ 'insert'){
		if(form.site_option_group_id NEQ 0 and form.site_option_group_id NEQ ""){
			queueSortStruct = StructNew();
			queueSortStruct.tableName = "site_option";
			queueSortStruct.sortFieldName = "site_option_sort";
			queueSortStruct.primaryKeyName = "site_option_id";
			queueSortStruct.datasource=request.zos.zcoreDatasource;
			queueSortStruct.where ="  site_option_group_id = '#application.zcore.functions.zescape(form.site_option_group_id)#' and 
			site_option.site_id ='#application.zcore.functions.zescape(request.zos.globals.id)#' ";
			
			queueSortStruct.disableRedirect=true;
			queueComStruct = CreateObject("component", "zcorerootmapping.com.display.queueSort");
			queueComStruct.init(queueSortStruct);
			queueComStruct.sortAll();
		}
		application.zcore.status.setStatus(request.zsid, "Site option added.");
		if(isDefined('session.siteoption_return')){
			tempURL = session['siteoption_return'];
			StructDelete(session, 'siteoption_return', true);
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(tempURL, true);
		}
	}else{
		application.zcore.status.setStatus(request.zsid, "Site option updated.");
	}
	if(structkeyexists(form, 'site_option_id') and isDefined('session.siteoption_return'&form.site_option_id)){	
		tempURL = session['siteoption_return'&form.site_option_id];
		StructDelete(session, 'siteoption_return'&form.site_option_id, true);
		tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
		application.zcore.functions.zRedirect(tempURL, true);
	}else{	
		application.zcore.functions.zRedirect('/z/admin/site-options/manageoptions?zsid=#request.zsid#&site_option_group_id=#form.site_option_group_id#');
	}
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
	var theTitle=0;
	var qS=0;
	var htmlEditor=0;
	var qGroup=0;
	var siteglobal=0;
	var ts=0;
	var selectStruct=0;
	var qApp=0;
	var qOptionGroup=0;
	var currentMethod=form.method;
	variables.init();
	form.site_option_id=application.zcore.functions.zso(form, 'site_option_id');
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id');
	db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
	WHERE site_option_id = #db.param(form.site_option_id)# ";
	if(structkeyexists(form, 'globalvar')){
		db.sql&="and site_id = #db.param('0')#";
	}else{
		db.sql&="and site_id = #db.param(request.zos.globals.id)#";
	}
	qS=db.execute("qS");
	if(structkeyexists(form, 'return')){
		StructInsert(session, "siteoption_return"&form.site_option_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	if(currentMethod EQ 'edit' and qS.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Site option doesn't exist.");
		application.zcore.functions.zRedirect("/z/admin/site-options/index?zsid=#request.zsid#");	
	}
    application.zcore.functions.zQueryToStruct(qS, form, 'site_option_group_id');
    application.zcore.functions.zstatusHandler(request.zsid,true);
	if(form.site_option_group_id NEQ "" and form.site_option_group_id NEQ 0){
		variables.allowGlobal=false;
		db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
		WHERE site_option_group_id = #db.param(form.site_option_group_id)#  and 
		site_id = #db.param(request.zos.globals.id)#";
		qOptionGroup=db.execute("qOptionGroup");
	}
	if(currentMethod EQ 'add'){
		theTitle="Add Site Option";
	}else{
		theTitle="Edit Site Option";
	}
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
    </cfscript>
	<script type="text/javascript">
	/* <![CDATA[ */
	function setType(n){
		for(var i=0;i<=20;i++){
			var t=document.getElementById('typeOptions'+i);	
			if(t!=null){
				if(i==n){
					t.style.display="block";
				}else{
					t.style.display="none";
				}
			}
		}
	}
	var displayDefault=<cfif currentMethod EQ 'edit'>false<cfelse>true</cfif>;
	/* ]]> */
	</script>
	<form name="myForm2" action="/z/admin/site-options/<cfif currentMethod EQ "add">insert<cfelse>update</cfif>?site_option_app_id=#form.site_option_app_id#&amp;site_option_id=#form.site_option_id#<cfif structkeyexists(form, 'globalvar')>&amp;globalvar=1</cfif>" method="post">
		<table style="border-spacing:0px;" class="table-list">
			<cfscript>
			db.sql="SELECT *  FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group WHERE
			site_option_group.site_id =#db.param(request.zos.globals.id)# 
			order by site_option_group.site_option_group_display_name ASC ";
			qGroup=db.execute("qGroup");
			</cfscript>
			<tr>
				<th>Group:</th>
				<td><cfscript>
				selectStruct = StructNew();
				selectStruct.name = "site_option_group_id";
				selectStruct.query = qGroup;
				selectStruct.onchange="checkAssociateTr();";
				selectStruct.queryLabelField = "site_option_group_display_name";
				selectStruct.queryValueField = "site_option_group_id";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
			</tr>
			<tr>
				<th>Code Name:</th>
				<td>
				<cfif currentMethod EQ "add">
					<input type="text" size="50" name="site_option_name" id="site_option_name" value="#htmleditformat(form.site_option_name)#" onkeyup="var d1=document.getElementById('site_option_display_name');if(displayDefault){d1.value=this.value;}" onblur="var d1=document.getElementById('site_option_display_name');if(displayDefault){d1.value=this.value;}">
				<cfelse>
					#form.site_option_name#<br />
					<input name="site_option_name" id="site_option_name" type="hidden" value="#htmleditformat(form.site_option_name)#"  />
					Note: Code Name can't be changed after initial creation to allow for simple syncing between sites &amp; servers.
				</cfif>
				</td>
			</tr>
			<tr>
				<th>Display Name:</th>
				<td><input type="text" size="50" name="site_option_display_name" id="site_option_display_name" value="#htmleditformat(form.site_option_display_name)#" onkeyup="displayDefault=false;"></td>
			</tr>
			<cfscript>
			if(form.site_option_type_json EQ ""){
				form.site_option_type_json="{}";
			}
			var optionStruct=deserializeJson(form.site_option_type_json); 
			</cfscript>
			<tr>
				<th>Type:</th>
				<td>
					<cfscript>
					if(form.site_option_type_id EQ ""){
						form.site_option_type_id=0;
					}
					var typeStruct={};
					var i=0;
					for(i in application.zcore.siteOptionTypeStruct){
						var currentCFC=application.zcore.siteOptionTypeStruct[i];
						typeStruct[currentCFC.getTypeName()]=i;
					}
					var arrTemp=structkeyarray(typeStruct);
					arraySort(arrTemp, "text", "asc");
					for(i=1;i LTE arraylen(arrTemp);i++){
						var currentCFC=application.zcore.siteOptionTypeStruct[typeStruct[arrTemp[i]]];
						writeoutput(currentCFC.getTypeForm(form, optionStruct, 'site_option_type_id'));
					}
					</cfscript> 
					<script type="text/javascript">
					/* <![CDATA[ */
					setType(#application.zcore.functions.zso(form, 'site_option_type_id',true)#);
					/* ]]> */
					</script>
					</td>
			</tr>
			<tr>
				<th>Default Value:</th>
				<td><textarea cols="40" rows="5" name="site_option_default_value">#htmleditformat(form.site_option_default_value)#</textarea></td>
			</tr>
			<tr>
				<th>Tooltip Help Box:</th>
				<td><cfscript>
				htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "site_option_tooltip";
				htmlEditor.value			= form.site_option_tooltip;
				htmlEditor.width			= "100%";
				htmlEditor.height		= 200;
				htmlEditor.create();
				</cfscript></td>
			</tr>
			<cfscript>
			if(form.site_id EQ 0){
				siteglobal=1;
			}else{
				siteglobal=0;
			}
			if(form.site_option_line_breaks EQ ""){
				form.site_option_line_breaks=0;	
			}
			if(form.site_option_edit_enabled EQ ""){
				form.site_option_edit_enabled=0;
			}
			</cfscript>
			<tr id="associateTrId">
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Associate With Apps","member.site-option.edit site_option_appidlist")#</th>
				<td class="table-white"><cfscript>
				db.sql="select app.* from #db.table("app", request.zos.zcoreDatasource)# app, 
				#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
				WHERE app_x_site.site_id = #db.param(request.zos.globals.id)# and 
	 			app.app_built_in=#db.param(0)# and 
				app_x_site.app_id = app.app_id order by app_name ";
				qApp=db.execute("qApp");
				
				selectStruct=structnew();
				selectStruct.name="site_option_appidlist";
				selectStruct.query = qApp;
				selectStruct.onchange="";
				selectStruct.queryLabelField = "app_name";
				selectStruct.queryValueField = "app_id";
				application.zcore.functions.zInput_Checkbox(selectStruct);
				</cfscript></td>
			</tr>
			<tr>
				<th>Show in List View:</th>
				<td>
					<input name="site_option_primary_field" id="site_option_primary_field1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'site_option_primary_field', true, 0) EQ 1>checked="checked"</cfif> /> Yes
					<input name="site_option_primary_field" id="site_option_primary_field0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'site_option_primary_field', true, 0) EQ 0>checked="checked"</cfif>  onclick="document.getElementById('site_option_admin_searchable0').checked=true; document.getElementById('site_option_admin_sort_field0').checked=true; " /> No</td>
			</tr>
			<tr>
				<th>Required:</th>
				<td>#application.zcore.functions.zInput_Boolean("site_option_required")#</td>
			</tr>
			<cfif form.site_option_group_id NEQ '' and form.site_option_group_id NEQ 0>
				<cfif qOptionGroup.site_option_group_enable_unique_url EQ 1>
					<tr>
						<th>Use for URL Title:</th>
						<td>#application.zcore.functions.zInput_Boolean("site_option_url_title_field")#</td>
					</tr>
					<tr>
						<th>Use for Search Summary:</th>
						<td>#application.zcore.functions.zInput_Boolean("site_option_search_summary_field")#</td>
					</tr>
					<tr>
						<th>Enable Search Index:</th>
						<td>#application.zcore.functions.zInput_Boolean("site_option_enable_search_index")#</td>
					</tr>
				</cfif>
				<tr>
					<th>Searchable (public):</th>
					<td>
					<input name="site_option_public_searchable" id="site_option_public_searchable1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'site_option_public_searchable', true, 0) EQ 1>checked="checked"</cfif>  /> Yes
					<input name="site_option_public_searchable" id="site_option_public_searchable0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'site_option_public_searchable', true, 0) EQ 0>checked="checked"</cfif> /> No</td>
				</tr>
				<tr>
					<th>Searchable (admin):</th>
					<td>
					<input name="site_option_admin_searchable" id="site_option_admin_searchable1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'site_option_admin_searchable', true, 0) EQ 1>checked="checked"</cfif>  onclick="document.getElementById('site_option_primary_field1').checked=true;" /> Yes
					<input name="site_option_admin_searchable" id="site_option_admin_searchable0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'site_option_admin_searchable', true, 0) EQ 0>checked="checked"</cfif> /> No</td>
				</tr>
				<tr>
					<th>Sort (admin):</th>
					<td>
					<input name="site_option_admin_sort_field" id="site_option_admin_sort_field1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'site_option_admin_sort_field', true, 0) EQ 1>checked="checked"</cfif>  onclick="document.getElementById('site_option_primary_field1').checked=true;"  />  Ascending
					<input name="site_option_admin_sort_field" id="site_option_admin_sort_field2" style="border:none; background:none;" type="radio" value="2" <cfif application.zcore.functions.zso(form, 'site_option_admin_sort_field', true, 0) EQ 2>checked="checked"</cfif>  onclick="document.getElementById('site_option_primary_field1').checked=true;"  />  Descending
					<input name="site_option_admin_sort_field" id="site_option_admin_sort_field0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'site_option_admin_sort_field', true, 0) EQ 0>checked="checked"</cfif> /> Disabled</td>
				</tr>
				
				<tr>
					<th>Search Default (admin):</th>
					<td><input type="text" name="site_option_admin_search_default" value="#htmleditformat(form.site_option_admin_search_default)#" /></td>
				</tr>
				<tr>
					<th>Validator CFC:</th>
					<td><cfscript>
					ts=StructNew();
					ts.name="site_option_validator_cfc";
					ts.size=50;
					application.zcore.functions.zInput_Text(ts);
					</cfscript> (Must begin with zcorerootmapping or request.zRootCFCPath)</td>
				</tr>
				<tr>
					<th>Validator CFC Method:</th>
					<td><cfscript>
					ts=StructNew();
					ts.name="site_option_validator_method";
					ts.size=50;
					application.zcore.functions.zInput_Text(ts);
					</cfscript></td>
				</tr>
			</cfif>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Allow Public?</th>
				<td>#application.zcore.functions.zInput_Boolean("site_option_allow_public")#</td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Hide Label?</th>
				<td>#application.zcore.functions.zInput_Boolean("site_option_hide_label")#</td>
			</tr>
			<tr>
				<th>Add Line Breaks:</th>
				<td>#application.zcore.functions.zInput_Boolean("site_option_line_breaks")#</td>
			</tr>
			<cfif variables.allowGlobal>
				<tr>
					<th>Listing Only:</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_listing_only")#</td>
				</tr>
			</cfif>
			<cfif variables.allowGlobal>
				<cfscript>
				if(form.site_id EQ 0){
					form.siteglobal=1;
				}
				</cfscript>
				<tr>
					<th>Global:</th>
					<td>#application.zcore.functions.zInput_Boolean("siteglobal")#</td>
				</tr>
			</cfif>
			<tr>
				<th>Edit Enabled:</th>
				<td>#application.zcore.functions.zInput_Boolean("site_option_edit_enabled")# (Make sure you select no for options that are not visible.)</td>
			</tr>
			<tr>
				<th>&nbsp;</th>
				<td><input type="submit" name="submitForm" value="Submit" />
					<input type="button" name="cancel" value="Cancel" onClick="window.location.href = '/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#application.zcore.functions.zso(form, 'site_option_group_id')#&amp;site_option_group_parent_id=#application.zcore.functions.zso(form, 'site_option_group_parent_id')#';" /></td>
			</tr>
		</table>
		<cfif variables.allowGlobal EQ false>
			<input type="hidden" name="siteglobal" value="0" />
		</cfif>
	</form>
	<script type="text/javascript">
	/* <![CDATA[ */
	function checkAssociateTr(){
		var i=document.getElementById("site_option_group_id");
		var d=document.getElementById("associateTrId");
		if(i.selectedIndex==0){
			d.style.display="table-row";	
		}else{
			d.style.display="none";
			for(i2=1;i2<255;i2++){
				var d2=document.getElementById('site_option_appidlist'+i2);
				if(d2){
					d2.checked=false;	
				}else{
					break;
				}
			}
		}
	}
	checkAssociateTr();
	/* ]]> */
	</script>
</cffunction>

<cffunction name="manageOptions" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qGroup=0;
	var theTitle=0;
	var queueComStruct=0;
	var queueSortStruct=0;
	var lastGroup=0;
	var qS=0;
	var i=0;
	var arrParent=0;
	var q1=0;
	var curParentId=0;
	variables.init();
    application.zcore.functions.zstatusHandler(request.zsid);
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id',true);
    db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
	WHERE site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qGroup=db.execute("qGroup");
	queueComStruct=structnew();
	if(form.site_option_group_id NEQ 0){
		if(qGroup.recordcount EQ 0){
			application.zcore.functions.zredirect("/z/admin/site-options/index");
		}  
		  
		theTitle="Manage Group Site Options: "&qGroup.site_option_group_display_name;
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
	}else{
		theTitle="Manage Site Options";
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
	}
	lastGroup="";
	loop query="qGroup"{
		lastGroup=qGroup.site_option_group_display_name;
		queueSortStruct = StructNew();
		queueSortStruct.tableName = "site_option";
		queueSortStruct.sortFieldName = "site_option_sort";
		queueSortStruct.primaryKeyName = "site_option_id";
		//queueSortStruct.sortVarName="siteGroup"&qGroup.site_option_group_id;
		queueSortStruct.datasource=request.zos.zcoreDatasource;
		queueSortStruct.where ="  site_option_group_id = '#application.zcore.functions.zescape(qGroup.site_option_group_id)#' and 
		site_option.site_id ='#application.zcore.functions.zescape(request.zos.globals.id)#' ";
		
		queueSortStruct.disableRedirect=true;
		queueComStruct["obj"&qGroup.site_option_group_id] = CreateObject("component", "zcorerootmapping.com.display.queueSort");
		queueComStruct["obj"&qGroup.site_option_group_id].init(queueSortStruct);
		if(structkeyexists(form, 'zQueueSort')){
			application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
			application.zcore.functions.zredirect(request.cgi_script_name&"?"&replacenocase(request.zos.cgi.query_string,"zQueueSort=","ztv=","all"));
		}
	}
	if(form.site_option_group_id EQ 0){
		db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
		LEFT JOIN #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group ON 
		site_option_group.site_option_group_id = site_option.site_option_group_id and 
		site_option_group.site_id=#db.param(-1)# 
		WHERE site_option.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#)
		and site_option.site_option_group_id = #db.param('0')# 
		ORDER BY site_option_group.site_option_group_display_name asc, site_option.site_option_sort ASC, site_option.site_option_name ASC";
	}else{
		db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
		LEFT JOIN #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group ON 
		site_option_group.site_option_group_id = site_option.site_option_group_id and 
		site_option_group.site_id = site_option.site_id 
		WHERE site_option.site_id =#db.param(request.zos.globals.id)# and 
		site_option.site_option_group_id = #db.param(form.site_option_group_id)# 
		ORDER BY site_option_group.site_option_group_display_name asc, site_option.site_option_sort ASC, site_option.site_option_name ASC";
	}
	qS=db.execute("qS");
	writeoutput('<p><a href="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#">Manage Groups</a> / ');
	if(qgroup.recordcount NEQ 0 and qgroup.site_option_group_parent_id NEQ 0){
		curParentId=qgroup.site_option_group_parent_id;
		arrParent=arraynew(1);
		loop from="1" to="25" index="i"{
			db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
			where site_option_group_id = #db.param(curParentId)# and 
			site_id = #db.param(request.zos.globals.id)#";
			q1=db.execute("q1");
			loop query="q1"{
				arrayappend(arrParent, '<a href="/z/admin/site-option-group/index?site_option_group_parent_id=#q1.site_option_group_id#">#application.zcore.functions.zFirstLetterCaps(q1.site_option_group_display_name)#</a> / ');
				curParentId=q1.site_option_group_parent_id;
			}
			if(q1.recordcount EQ 0 or q1.site_option_group_parent_id EQ 0){
				break;
			}
		}
		for(i = arrayLen(arrParent);i GTE 1;i--){
			writeOutput(arrParent[i]&' ');
		}
		if(qgroup.site_option_group_parent_id NEQ 0){
			writeoutput(application.zcore.functions.zFirstLetterCaps(qGroup.site_option_group_display_name)&" / ");
		}
	}
	writeoutput('</p>');
	</cfscript>
	<cfif qGroup.recordcount NEQ 0>
		<p><a href="/z/admin/site-options/add?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;site_option_group_parent_id=#qgroup.site_option_group_parent_id#&amp;return=1">Add Site Option</a> | <a href="/z/admin/site-option-group/index?site_option_group_parent_id=#form.site_option_group_id#">Manage Sub-Groups</a></p>
	</cfif>
	<table class="table-list">
		<tr>
			<th>Name</th>
			<th>Type</th>
			<cfif variables.allowGlobal>
				<th>Global</th>
			</cfif>
			<th>Admin</th>
		</tr>
		<cfscript>
		var row=0;
		for(row in qS){
			writeoutput('<tr ');
			if(qS.currentrow MOD 2 EQ 0){
				writeoutput('class="row1"');
			}else{
				writeoutput('class="row2"');
			}
			writeoutput('>
				<td>#qS.site_option_name#</td>
				<td>');
				var currentCFC=application.zcore.siteOptionTypeStruct[qS.site_option_type_id];
				writeoutput(currentCFC.getTypeName()); 
				writeoutput('</td>');
				if(variables.allowGlobal){
					writeoutput('<td>');
					if(qS.site_id EQ 0){
						writeoutput('Yes');
					}else{
						writeoutput('No');
					}
					writeoutput('</td>');
				}
				writeoutput('<td>');
				if(qS.site_id NEQ 0 or variables.allowGlobal){
					if(lastGroup NEQ ""){
						writeoutput('#queueComStruct["obj"&qS.site_option_group_id].getLinks(qS.recordcount, qS.currentrow, '/z/admin/site-options/manageOptions?site_option_group_parent_id=#qS.site_option_group_parent_id#&amp;site_option_group_id=#qS.site_option_group_id#&amp;site_option_id=#qS.site_option_id#', "vertical-arrows")#');
					}
					var globalTemp="";
					if(qS.site_id EQ 0){
						globalTemp="&amp;globalvar=1";
					}
					writeoutput('<a href="/z/admin/site-options/edit?site_option_app_id=#form.site_option_app_id#&amp;site_option_id=#qS.site_option_id#&amp;site_option_group_id=#qS.site_option_group_id#&amp;site_option_group_parent_id=#qS.site_option_group_parent_id#&amp;return=1#globalTemp#">Edit</a> | 
					<a href="/z/admin/site-options/delete?site_option_app_id=#form.site_option_app_id#&amp;site_option_id=#qS.site_option_id#&amp;site_option_group_id=#qS.site_option_group_id#&amp;site_option_group_parent_id=#qS.site_option_group_parent_id#&amp;return=1#globalTemp#">Delete</a>');
				}
				writeoutput('</td>
			</tr>');
		}
		</cfscript>
	</table>
</cffunction>

<cffunction name="saveOptions" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var nv=0;
	var i=0;
	var qD=0;
	var nvd=0;
	var arrList=0;
	var oldnv=0;
	var tempURL=0;
	var qD2=0;
	var q=0;
	var photoresize=0;
	var nowDate=request.zos.mysqlnow;
	variables.init();
	local.arrSiteIdType=listtoarray(form.siteidtype);
	local.arrSiteOptionId=listtoarray(form.site_option_id);
	if(arraylen(local.arrSiteOptionId) NEQ arraylen(local.arrSiteIdType)){
		application.zcore.status.setStatus(request.zsid, "Invalid request");
		application.zcore.functions.zRedirect("/z/admin/site-options/index?zsid=#request.zsid#");	
	}
	local.arrSQL=arraynew(1);
	for(local.i=1;local.i LTE arraylen(local.arrSiteIdType);local.i++){
		arrayappend(local.arrSQL, "(site_option.site_id='"&application.zcore.functions.zescape(application.zcore.functions.zGetSiteIdFromSiteIdType(local.arrSiteIdType[local.i]))&"' and 
		site_option.site_option_id='"&application.zcore.functions.zescape(local.arrSiteOptionId[local.i])&"')");	
	}
	db.sql="SELECT *, site_option.site_id siteOptionSiteId 
	FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
	LEFT JOIN #db.table("site_x_option", request.zos.zcoreDatasource)# site_x_option ON 
	site_x_option.site_option_app_id = #db.param(form.site_option_app_id)# and 
	site_option.site_option_id = site_x_option.site_option_id and 
	site_x_option.site_id = #db.param(request.zos.globals.id)# 
	and site_option.site_id = "&db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("site_x_option.site_option_id_siteIDType"))&" 
	WHERE ("&db.trustedSQL(arraytolist(local.arrSQL, " or "))&")";
	qD=db.execute("qD");
	
	var row=0;
	for(row in qD){
		var currentCFC=application.zcore.siteOptionTypeStruct[row.site_option_type_id];  
		nv=application.zcore.functions.zso(form, 'newvalue'&row.site_option_id);
		var optionStruct=deserializeJson(row.site_option_type_json);
		if(row.siteOptionSiteId EQ 0){
			form.siteIDType=4;
		}else{
			form.siteIDType=1;
		} 
		var currentCFC=application.zcore.siteOptionTypeStruct[row.site_option_type_id];
		var rs=currentCFC.onBeforeUpdate(row, optionStruct, 'newvalue', form);
		if(not rs.success){
			application.zcore.functions.zRedirect("/z/admin/site-options/index?zsid=#request.zsid#");
		}
		nv=rs.value;
		var nvDate=rs.dateValue;  
		if(nv EQ "" and row.site_x_option_id EQ ''){
			nv=row.site_option_default_value;
			nvdate=nv;
		} 
		db.sql="REPLACE INTO #db.table("site_x_option", request.zos.zcoreDatasource)#  SET 
		site_option_app_id=#db.param(form.site_option_app_id)#, 
		site_id=#db.param(request.zos.globals.id)#, 
		site_option_id_siteIDType=#db.param(form.siteIDType)#, 
		site_x_option_value=#db.param(nv)#, 
		site_x_option_date_value=#db.param(nvdate)#, 
		site_option_id=#db.param(row.site_option_id)#, 
		site_x_option_updated_datetime=#db.param(nowDate)# ";
		qD2=db.execute("qD2");
	}
	db.sql="DELETE FROM #db.table("site_x_option", request.zos.zcoreDatasource)#  
	WHERE site_x_option.site_option_app_id = #db.param(form.site_option_app_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	site_x_option_updated_datetime<#db.param(nowDate)#";
	q=db.execute("q");
	application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
	
	application.zcore.status.setStatus(request.zsid,"Site options saved.");
	if(isDefined('session.siteoption_return') and form.site_option_app_id EQ 0){	
		tempURL = session['siteoption_return'];
		StructDelete(session, 'siteoption_return', true);
		tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
		application.zcore.functions.zRedirect(tempURL, true);
	}else{	
		application.zcore.functions.zRedirect("/z/admin/site-options/index?zsid=#request.zsid#");
	}
	</cfscript>
</cffunction>


<cffunction name="internalGroupUpdate" localmode="modern" access="public">
	<cfscript>
	form.method="internalGroupUpdate";
	return this.updateGroup();
	</cfscript>
</cffunction> 

<cffunction name="importInsertGroup" localmode="modern" access="public" roles="member">
	<cfscript>
	form.method="importInsertGroup";
	return this.updateGroup();
	</cfscript>
</cffunction>
<cffunction name="publicMapInsertGroup" localmode="modern" access="public" roles="member">
	<cfscript>
	form.method="publicMapInsertGroup";
	return this.updateGroup();
	</cfscript>
</cffunction>

<cffunction name="publicInsertGroup" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicInsertGroup";
	this.updateGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="publicUpdateGroup" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicUpdateGroup";
	this.updateGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="insertGroup" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.updateGroup();
	</cfscript>
</cffunction>

<cffunction name="updateGroup" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	var db=request.zos.queryObject;
	var qG2=0;
	var q=0;
	var qD=0;
	var i=0;
	var nv=0;
	var nvdate=0;
	var ts=0;
	var rCom=0;
	var nvd=0;
	var arrList=0;
	var photoresize=0;
	var oldnv=0;
	var qId=0;
	var row=0;
	var qD2=0;
	var queueSortStruct=structnew();
	var queueSortCom=0;
	var r1=0;
	var nowDate=request.zos.mysqlnow;
	var methodBackup=form.method;
	request.zos.siteOptionInsertGroupCache={};
	if(methodBackup NEQ "publicMapInsertGroup" and methodBackup NEQ "importInsertGroup"){
		variables.init();
	}
	local.errors=false;
	var debug=false;
	/*if(request.zos.isdeveloper){
		debug=true;
	}*/
	var startTime=0;
	if(debug) startTime=gettickcount();
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id');
	if(not structkeyexists(request.zos.siteOptionInsertGroupCache, form.site_option_group_id)){
		request.zos.siteOptionInsertGroupCache[form.site_option_group_id]={};
	}
	curCache=request.zos.siteOptionInsertGroupCache[form.site_option_group_id];
	if(not structkeyexists(curCache, 'qCheck')){
		db.sql="select * from #db.table("site_option_group", request.zos.zcoredatasource)# 
		WHERE site_option_group_id=#db.param(form.site_option_group_id)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		local.qCheck=db.execute("qCheck");
		if(local.qCheck.recordcount EQ 0){
			application.zcore.functions.z404("Invalid site_option_group_id, #form.site_option_group_id#");	
		}
		curCache.qCheck=local.qCheck;
	}else{
		local.qCheck=curCache.qCheck;
	}
	if(local.qCheck.site_option_group_enable_approval EQ 0){
		form.site_x_option_group_set_approved=1;
	}
	if(methodBackup EQ "publicInsertGroup"){
		 
		if(local.qCheck.site_option_group_enable_public_captcha EQ 1){
			if(not application.zcore.functions.zVerifyRecaptcha()){
				application.zcore.status.setStatus(request.zsid, "The ReCaptcha security phrase wasn't entered correctly. Please try again.", form, true);
				local.errors=true;
			}
		}
		form.inquiries_spam=0;
		form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',false,0);
		if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
			form.inquiries_spam=1;
			//application.zcore.status.setStatus(request.zsid, "Invalid submission.  Please submit the form again.",form,true);
			//local.errors=true;
		}
		if(form.modalpopforced EQ 1){
			if(application.zcore.functions.zso(form, 'js3811') NEQ "j219"){
				form.inquiries_spam=1;
				//application.zcore.status.setStatus(request.zsid, "Invalid submission.  Please submit the form again.",form,true);
				//local.errors=true;
			}
			if(application.zcore.functions.zCheckFormHashValue(application.zcore.functions.zso(form, 'js3812')) EQ false){
				form.inquiries_spam=1;
				//application.zcore.status.setStatus(request.zsid, "Your session has expired.  Please submit the form again.",form,true);
				//local.errors=true;
			}
		}
		if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
			form.inquiries_spam=1;
			//application.zcore.status.setStatus(request.zsid, "Invalid submission.  Please submit the form again.",form,true);
			//local.errors=true;
		}
	}
	nowDate="#request.zos.mysqlnow#";
	if(not structkeyexists(curCache, 'qD')){
		db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
		LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# site_x_option_group ON 
		site_x_option_group.site_option_app_id = #db.param(form.site_option_app_id)# and 
		site_option.site_option_id = site_x_option_group.site_option_id and 
		site_x_option_group.site_id = #db.param(request.zos.globals.id)# and 
		site_x_option_group.site_option_group_id = site_option.site_option_group_id and 
		site_x_option_group.site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)# 
		WHERE ";
		if(local.methodBackup EQ "publicInsertGroup" or local.methodBackup EQ "publicUpdateGroup"){
			db.sql&=" (site_option_allow_public=#db.param(1)#";
			if(structkeyexists(arguments.struct, 'arrForceFields')){
				for(i=1;i LTE arraylen(arguments.struct.arrForceFields);i++){
					db.sql&=" or site_option_name = #db.param(arguments.struct.arrForceFields[i])# ";
				}
			}
			db.sql&=" ) and ";
		}else{
			db.sql&=" site_option.site_option_id IN ("&db.trustedSQL("'"&replace(application.zcore.functions.zescape(form.site_option_id),",","','","ALL")&"'")&")  and ";
		}
		db.sql&="site_option.site_option_group_id = #db.param(form.site_option_group_id)# and 
		site_option.site_id = #db.param(request.zos.globals.id)#";
		qD=db.execute("qD");
		curCache.qD=qD;
	}else{
		qD=curCache.qD;
	}
	local.newDataStruct={};
	
	var optionStructCache={};
	form.siteOptionTitle="";
	form.siteOptionSummary="";
	form.site_x_option_group_set_start_date='';
	form.site_x_option_group_set_end_date='';
	hasTitleField=false;
	hasSummaryField=false;
	hasPrimaryField=false;
	for(row in qD){
		if(row.site_option_search_summary_field EQ 1){
			hasSummaryField=true;
		}
		if(row.site_option_url_title_field EQ 1){
			hasTitleField=true;
		}
		if(row.site_option_primary_field EQ 1){
			hasPrimaryField=true;
		}
	}
	for(row in qD){
		var currentCFC=application.zcore.siteOptionTypeStruct[row.site_option_type_id];
		if(structkeyexists(form, row.site_option_name)){
			form['newvalue'&row.site_option_id]=form[row.site_option_name];
		}
		nv=currentCFC.getFormValue(row, 'newvalue', form);
		if(row.site_option_required EQ 1){
			if(nv EQ ""){
				application.zcore.status.setStatus(request.zsid, row.site_option_display_name&" is a required field.", false, true);
				local.errors=true;
				continue;
			}
		}
		var optionStruct=deserializeJson(row.site_option_type_json);
		optionStructCache[row.site_option_id]=optionStruct; 
		var rs=currentCFC.validateFormField(row, optionStruct, 'newvalue', form);
		if(not rs.success){
			application.zcore.status.setStatus(request.zsid, rs.message, form, true);
			local.errors=true;
			continue;
		}
		dataStruct=currentCFC.onBeforeListView(row, optionStruct, form);
		if(hasSummaryField){
			if(row.site_option_search_summary_field EQ 1){
				if(len(form.siteOptionSummary)){
					form.siteOptionSummary&=" "&currentCFC.getListValue(dataStruct, optionStruct, nv);
				}else{
					form.siteOptionSummary=currentCFC.getListValue(dataStruct, optionStruct, nv);
				}
			}
		}
		
		if(hasTitleField){
			if(row.site_option_url_title_field EQ 1){
				if(len(form.siteOptionTitle)){
					form.siteOptionTitle&=" "&currentCFC.getListValue(dataStruct, optionStruct, nv);
				}else{
					form.siteOptionTitle=currentCFC.getListValue(dataStruct, optionStruct, nv);
				}
			}
		}else{
			if(not hasPrimaryField){
				if(form.siteOptionTitle EQ ""){
					form.siteOptionTitle=currentCFC.getListValue(dataStruct, optionStruct, nv); 
				}
			}else if(row.site_option_primary_field EQ 1){
				if(len(form.siteOptionTitle)){
					form.siteOptionTitle&=" "&currentCFC.getListValue(dataStruct, optionStruct, nv);
				}else{
					form.siteOptionTitle=currentCFC.getListValue(dataStruct, optionStruct, nv);
				}
			}
		}
	}  
	if(application.zcore.functions.zso(form,'site_x_option_group_set_override_url') CONTAINS "?"){
		application.zcore.status.setStatus(request.zsid, "The URL can't contain query string parameters.  I.e. ""?id=1""", form, true);
		local.errors=true;
	}
	if(local.errors){
		application.zcore.status.setStatus(request.zsid, false, form, true);
		if(methodBackup EQ "publicMapInsertGroup" or methodBackup EQ "internalGroupUpdate" or methodBackup EQ "importInsertGroup"){
			return {success:false, zsid:request.zsid};
		}else if(methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicUpdateGroup"){
			
			if(structkeyexists(arguments.struct, 'returnURL')){
				application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.struct.returnURL, "zsid=#request.zsid#&modalpopforced=#form.modalpopforced#"));
			}else{
				if(local.qCheck.site_option_group_public_form_url NEQ ""){
					application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(local.qCheck.site_option_group_public_form_url, "zsid=#request.zsid#&modalpopforced=#form.modalpopforced#"));
				}else{
					application.zcore.functions.zRedirect("/z/misc/display-site-option-group/add?site_option_group_id=#form.site_option_group_id#&site_option_group_id=#form.site_option_group_id#&zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
				}
			}
		}else{
			if(methodBackup EQ "insertGroup"){
				local.newMethod="addGroup";
			}else{
				local.newMethod="editGroup";
			}
			application.zcore.functions.zRedirect("/z/admin/site-options/#local.newMethod#?zsid=#request.zsid#&site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#");
		}
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1<br>'); startTime=gettickcount();
	var row=0; 
	var arrTempData=[];
	for(row in qD){
		nv=application.zcore.functions.zso(form, 'newvalue'&row.site_option_id);
		nvdate="";
		form.site_id=request.zos.globals.id;
		form.site_x_option_group_disable_time=0;
		var optionStruct=optionStructCache[row.site_option_id]; 
		var currentCFC=application.zcore.siteOptionTypeStruct[row.site_option_type_id];
		var rs=currentCFC.onBeforeUpdate(row, optionStruct, 'newvalue', form);
		if(not rs.success){
			local.newAction="addGroup";
			if(methodBackup EQ "updateGroup"){
				local.newAction="editGroup";
			}
			if(methodBackup EQ "publicMapInsertGroup" or methodBackup EQ "internalGroupUpdate" or methodBackup EQ "importInsertGroup"){
				return {success:false, zsid:request.zsid};
			}else{
				application.zcore.functions.zRedirect("/z/admin/site-options/#local.newAction#?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&zsid=#request.zsid#");
			}
		}
		nv=rs.value;
		nvDate=rs.dateValue; 
		if(nvDate NEQ ""){
			if(timeformat(nvDate, 'h:mm tt') EQ "12:00 am"){
				local.newDataStruct[row.site_option_name]=dateformat(nvDate, 'm/d/yyyy');
			}else{
				local.newDataStruct[row.site_option_name]=dateformat(nvDate, 'm/d/yyyy')&' '&timeformat(nvDate, 'h:mm tt');
			}
		}else{
			local.newDataStruct[row.site_option_name]=rs.value; 
		}
		if(nv EQ "" and row.site_x_option_group_id EQ ''){
			nv=row.site_option_default_value;
			nvdate=nv;
		} 
		var tempData={
			site_option_app_id:form.site_option_app_id,
			site_option_id_siteIDType:1,
			site_x_option_group_set_id: form.site_x_option_group_set_id,
			site_id:request.zos.globals.id,
			site_x_option_group_value:nv,
			site_x_option_group_disable_time:form.site_x_option_group_disable_time,
			site_x_option_group_date_value:nvDate,
			site_option_id: row.site_option_id,
			site_option_group_id: row.site_option_group_id,
			site_x_option_group_updated_datetime: nowDate 
		}
		arrayAppend(arrTempData, tempData); 
	}
	form.site_x_option_group_set_approved=application.zcore.functions.zso(form, 'site_x_option_group_set_approved', false, 1);
	if(methodBackup EQ "publicUpdateGroup" or methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicMapInsertGroup" or methodBackup EQ "importInsertGroup"){
		if((methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicUpdateGroup") and (local.qCheck.recordcount EQ 0 or local.qCheck.site_option_group_allow_public NEQ 1)){
			hasAccess=false;
			if(local.qCheck.recordcount NEQ 0){
				arrUserGroup=listToArray(local.qCheck.site_option_group_user_group_id_list, ",");
				for(i=1;i LTE arraylen(arrUserGroup);i++){
					if(application.zcore.user.checkGroupIdAccess(arrUserGroup[i])){
						hasAccess=true;
						break;
					}
				}
			}
			if(not hasAccess){
				application.zcore.functions.z404("site_option_group_id, #form.site_option_group_id#, doesn't allow public data entry.");
			}
		}
		if(local.qCheck.site_option_group_enable_approval EQ 1){
			if(methodBackup EQ "publicUpdateGroup"){
				// must force approval status to stay the same on updates.
				db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE 
				site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
				site_id = #db.param(request.zos.globals.id)# ";
				qSetCheck=db.execute("qSetCheck");
				if(not application.zcore.user.checkGroupAccess("administrator") and qSetCheck.site_x_option_group_set_approved EQ 2){
					form.site_x_option_group_set_approved=0;
				}else{
					form.site_x_option_group_set_approved=qSetCheck.site_x_option_group_set_approved;
				}
			}else{
				form.site_x_option_group_set_approved=0;
			}
		}
	}
	if(methodBackup EQ "insertGroup" or methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicMapInsertGroup" or methodBackup EQ "importInsertGroup"){
		if(not structkeyexists(curCache, 'sortValue')){
			db.sql="select max(site_x_option_group_set_sort) sortid 
			from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set 
			WHERE site_option_group_id = #db.param(form.site_option_group_id)# and 
			site_id = #db.param(request.zos.globals.id)#";
			qG2=db.execute("qG2");
			if(qG2.recordcount EQ 0 or qG2.sortid EQ ""){
				sortValue=0;
			}else{
				sortValue=qG2.sortid;
			}
			curCache.sortValue=sortValue;
		}else{
			sortValue=curCache.sortValue;
		}
		sortValue++;
		form.site_x_option_group_set_sort=sortValue;
		if(methodBackup EQ "importInsertGroup"){
			form.site_x_option_group_set_approved=1;
		}
		db.sql="INSERT INTO #db.table("site_x_option_group_set", request.zos.zcoreDatasource)#  SET 
		site_option_app_id=#db.param(form.site_option_app_id)#, 
		site_x_option_group_set_sort=#db.param(form.site_x_option_group_set_sort)#,
		site_x_option_group_set_datetime=#db.param(request.zos.mysqlnow)#, 
		 site_id=#db.param(request.zos.globals.id)#, 
		 site_option_group_id=#db.param(form.site_option_group_id)#,  
		 site_x_option_group_set_start_date=#db.param(form.site_x_option_group_set_start_date)#,
		 site_x_option_group_set_end_date=#db.param(form.site_x_option_group_set_end_date)#,
		 site_x_option_group_set_parent_id=#db.param(form.site_x_option_group_set_parent_id)#,
		site_x_option_group_set_override_url=#db.param(application.zcore.functions.zso(form,'site_x_option_group_set_override_url'))#,
		site_x_option_group_set_approved=#db.param(form.site_x_option_group_set_approved)#, 
		site_x_option_group_set_image_library_id=#db.param(application.zcore.functions.zso(form, 'site_x_option_group_set_image_library_id'))#, 
		site_x_option_group_set_updated_datetime=#db.param(request.zos.mysqlNow)# , 
		site_x_option_group_set_title=#db.param(form.siteOptionTitle)# , 
		site_x_option_group_set_summary=#db.param(form.siteOptionSummary)#";
		local.rs=db.insert("q", request.zOS.insertIDColumnForSiteIDTable); 
		if(local.rs.success){
			form.site_x_option_group_set_id=local.rs.result;
		}else{
			throw("Failed to insert site option group set");
		} 
		if(arraylen(arrTempData)){
			for(var n=1;n LTE arraylen(arrTempData);n++){
				arrTempData[n].site_x_option_group_set_id=form.site_x_option_group_set_id;
			}
		}  
	}else{ 
		structdelete(form, 'site_x_option_group_set_sort'); 
	}
	if(arraylen(arrTempData)){
		var arrSQL=["REPLACE INTO #db.table("site_x_option_group", request.zos.zcoreDatasource)#  "];
		var arrKey=structkeyarray(tempData);
		var tempCount=arraylen(arrKey);
		arrayAppend(arrSQL, " ( "&arrayToList(arrKey, ", ")&" ) VALUES ");
		for(var n=1;n LTE arraylen(arrTempData);n++){
			if(n NEQ 1){
				arrayAppend(arrSQL, ", ");
			}
			arrayAppend(arrSQL, " ( ");
			for(var i=1;i LTE tempCount;i++){
				if(i NEQ 1){
					arrayAppend(arrSQL, ", ");
				}
				arrayAppend(arrSQL, db.param(arrTempData[n][arrKey[i]]));
			}
			arrayAppend(arrSQL, " ) ");
		}
		db.sql=arrayToList(arrSQL, "");
		db.execute("qReplace");
		
	}
	libraryId=application.zcore.functions.zso(form, 'site_x_option_group_set_image_library_id');
	if(libraryId NEQ 0 and libraryId NEQ ""){
		if(form.site_x_option_group_set_approved EQ 1){
			application.zcore.imageLibraryCom.approveLibraryId(libraryId);
		}else{
			application.zcore.imageLibraryCom.unapproveLibraryId(libraryId);
		}
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds2<br>'); startTime=gettickcount();
	local.arrDataStructKeys=structkeyarray(local.newDataStruct);
	if(methodBackup NEQ "publicInsertGroup" and methodBackup NEQ "publicMapInsertGroup" and methodBackup NEQ "importInsertGroup"){
		db.sql="update #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# 
		set site_x_option_group_set_override_url=#db.param(application.zcore.functions.zso(form,'site_x_option_group_set_override_url'))#,
		site_x_option_group_set_datetime=#db.param(request.zos.mysqlnow)#, 
		site_x_option_group_set_approved=#db.param(form.site_x_option_group_set_approved)#, 
		 site_x_option_group_set_start_date=#db.param(form.site_x_option_group_set_start_date)#,
		 site_x_option_group_set_end_date=#db.param(form.site_x_option_group_set_end_date)#,
		site_x_option_group_set_image_library_id=#db.param(application.zcore.functions.zso(form, 'site_x_option_group_set_image_library_id'))#, 
		site_x_option_group_set_updated_datetime=#db.param(request.zos.mysqlNow)# , 
		site_x_option_group_set_title=#db.param(form.siteOptionTitle)# , 
		site_x_option_group_set_summary=#db.param(form.siteOptionSummary)#
		WHERE 
		site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)# and 
		site_id = #db.param(request.zos.globals.id)#";
		db.execute("qUpdate");
	}
	if(application.zcore.functions.zso(form, 'site_x_option_group_set_image_library_id') NEQ ""){
        	application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'site_x_option_group_set_image_library_id'));
	}
	/*
	// this isn't necessary, is it?
	db.sql="DELETE FROM #db.table("site_x_option_group", request.zos.zcoreDatasource)#  WHERE 
	site_x_option_group.site_option_app_id = #db.param(form.site_option_app_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)# and 
	site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_x_option_group_updated_datetime<#db.param(nowDate)#";
	q=db.execute("q");
	*/
	application.zcore.routing.updateSiteOptionGroupSetUniqueURL(form.site_x_option_group_set_id);
	
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds3<br>'); startTime=gettickcount();
	if(not structkeyexists(request.zos, 'disableSiteCacheUpdate') and local.qCheck.site_option_group_enable_cache EQ 1){ 
		application.zcore.siteOptionCom.updateSiteOptionGroupSetIdCache(request.zos.globals.id, form.site_x_option_group_set_id); 
		//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id); 
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds4<br>'); startTime=gettickcount();
	if(local.qCheck.site_option_group_enable_unique_url EQ 1 and local.qCheck.site_option_group_parent_id EQ 0 and local.qCheck.site_option_group_public_searchable EQ 1){
		application.zcore.siteOptionCom.searchReindexSet(form.site_x_option_group_set_id, request.zos.globals.id, [local.qCheck.site_option_group_display_name]);
	}
	
	local.mapRecord=false;
	if(not structkeyexists(form, 'disableSiteOptionGroupMap')){
		form.disableSiteOptionGroupMap=true;
		if(local.qCheck.site_option_group_map_insert_type EQ 1){
			if(methodBackup EQ "publicInsertGroup"){
				local.mapRecord=true;
			}
		}else if(local.qCheck.site_option_group_map_insert_type EQ 2){
			if((methodBackup EQ "updateGroup" or methodBackup EQ "internalGroupUpdate") and form.site_x_option_group_set_approved EQ 1){
				// only if this record was just approved
				local.mapRecord=true;
			}
		}
	}
	local.setIdBackup=form.site_x_option_group_set_id; 
	local.sendEmail=false;
	local.setIdBackup2=form.site_x_option_group_set_id;
	local.groupIdBackup2=local.qCheck.site_option_group_id;
	if(methodBackup EQ "publicInsertGroup" and local.qCheck.site_option_group_lead_routing_enabled EQ 1 and not structkeyexists(form, 'disableGroupEmail')){
		local.newDataStruct.site_x_option_group_set_id=local.setIdBackup2; 
		local.newDataStruct.site_option_group_id=local.groupIdBackup2;
		
		if(local.qCheck.site_option_group_email_cfc_path NEQ "" and local.qCheck.site_option_group_email_cfc_method NEQ ""){
			if(left(local.qCheck.site_option_group_email_cfc_path, 5) EQ "root."){
				local.cfcpath=replace(local.qCheck.site_option_group_email_cfc_path, 'root.',  request.zRootCfcPath);
			}else{
				local.cfcpath=qSet.site_option_group_email_cfc_path;
			}
		} 
		if(local.qCheck.site_option_group_map_fields_type EQ 1){
			if(local.qCheck.site_option_group_email_cfc_path NEQ "" and local.qCheck.site_option_group_email_cfc_method NEQ ""){
				local.tempCom=createobject("component", local.cfcpath);
				local.sendEmail=true;
				local.emailStruct=local.tempCom[local.qCheck.site_option_group_email_cfc_method](local.newDataStruct, local.arrDataStructKeys);
			}
		}else if(local.qCheck.site_option_group_map_fields_type EQ 0 or local.qCheck.site_option_group_map_fields_type EQ 2){
			if(local.qCheck.site_option_group_email_cfc_path NEQ "" and local.qCheck.site_option_group_email_cfc_method NEQ ""){
				local.tempCom=createobject("component", local.cfcpath);
				local.emailStruct=local.tempCom[local.qCheck.site_option_group_email_cfc_method](local.newDataStruct, local.arrDataStructKeys);
			}else{
				local.emailStruct=variables.generateGroupEmailTemplate(local.newDataStruct, local.arrDataStructKeys);
			}
			local.sendEmail=true;
		}
	}
	if(local.mapRecord){
		if(local.qCheck.site_option_group_map_fields_type EQ 1){ 
			local.newDataStruct.site_option_group_id =form.site_option_group_id;
			form.inquiries_type_id =local.qCheck.inquiries_type_id;
			local.newDataStruct.inquiries_type_id =local.qCheck.inquiries_type_id;
			variables.mapDataToInquiries(local.newDataStruct, form, local.sendEmail); 
		}else if(local.qCheck.site_option_group_map_fields_type EQ 2){
			if(local.qCheck.site_option_group_map_group_id NEQ 0){
				local.groupIdBackup2=local.qCheck.site_option_group_map_group_id;
				local.newDataStruct.site_option_group_id =form.site_option_group_id;
				local.newDataStruct.site_option_group_map_group_id=local.qCheck.site_option_group_map_group_id;
				variables.mapDataToGroup(local.newDataStruct, form, local.sendEmail); 
			}
		}
		local.setIdBackup2=form.site_x_option_group_set_id; 
		if(local.qCheck.site_option_group_delete_on_map EQ 1){
			form.site_option_group_id=local.qCheck.site_option_group_id;
			form.site_x_option_group_set_id=local.setIdBackup;
			local.tempResult=variables.autoDeleteGroup(); 
		}
	}
	if(local.sendEmail and not structkeyexists(form, 'disableGroupEmail')){
		ts=StructNew();
		
		ts.to=request.officeEmail;
		ts.from=request.fromEmail;
		ts.embedImages=true;
		structappend(ts, local.emailStruct, true);
		if(local.qCheck.inquiries_type_id NEQ 0){
			leadStruct=application.zcore.functions.zGetLeadRouteForInquiriesTypeId(ts.from, local.qCheck.inquiries_type_id, local.qCheck.inquiries_type_id_siteIDType);
			//writedump(leadStruct);
			if(structkeyexists(leadStruct, 'cc')){
				ts.cc=leadStruct.cc;
			}
			if(leadStruct.user_id NEQ "0"){
				ts.user_id=leadStruct.user_id;
				ts.user_id_siteIDType=leadStruct.user_id_siteIDType;
			}
			if(leadStruct.assignEmail NEQ ""){
				ts.to=leadStruct.assignEmail;
			}
		}
		// required
		/*
		ts.subject=local.emailStruct.subject;
		if(structkeyexists(local.emailStruct, 'html')){
			ts.html=local.emailStruct.html;
		}
		if(structkeyexists(local.emailStruct, 'text')){
			ts.text=local.emailStruct.text;
		}*/
		ts.site_id=request.zos.globals.id;
		//writedump(ts);abort;
		//ts.spoolenable=false;
		rCom=application.zcore.email.send(ts);
		if(rCom.isOK() EQ false){
			rCom.setStatusErrors(request.zsid);
			application.zcore.functions.zstatushandler(request.zsid);
			application.zcore.functions.zabort();
		}
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds5<br>'); startTime=gettickcount();
	if(debug) application.zcore.functions.zabort();
	if(methodBackup EQ "publicMapInsertGroup" or methodBackup EQ "internalGroupUpdate" or methodBackup EQ "importInsertGroup"){
		return {success:true, zsid:request.zsid, site_x_option_group_set_id:local.setIdBackup};
	}else if(methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicUpdateGroup"){ 
		form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced');
		application.zcore.status.setStatus(request.zsid,"Saved successfully.");
		if(structkeyexists(arguments.struct, 'successURL')){
			application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.struct.successURL, "zsid=#request.zsid#&modalpopforced=#form.modalpopforced#&site_x_option_group_set_id=#local.setIdBackup#"));
		}else{
			if(local.qCheck.site_option_group_public_thankyou_url NEQ ""){
				application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(local.qCheck.site_option_group_public_thankyou_url, "zsid=#request.zsid#&modalpopforced=#form.modalpopforced#"));
			}else{
				application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#");
			}
		}
	}else{
		application.zcore.status.setStatus(request.zsid,"Saved successfully.");
		application.zcore.functions.zRedirect("/z/admin/site-options/manageGroup?zsid=#request.zsid#&site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#");
	}
	</cfscript>
</cffunction>

<!--- 
Define this function in another CFC to override the default email format
<cffunction name="publicEmailExample" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="arrKey" type="array" required="yes">
	<cfscript>
	var rs={
		html:"",
		text:"",
		subject:""
	};
	rs.html='#application.zcore.functions.zHTMLDoctype()#
	<head>
	<meta charset="utf-8" />
	<title>Email</title>
	</head>
	
	<body>
	<p>Testing email</p>
	<p>'&application.zcore.functions.zso(ss, 'title')&'</p>
	</body>
	</html>';
	rs.subject="Test subject";
	rs.text="Testing email";
	return rs;
	</cfscript>
</cffunction>
 --->
 
 
<!--- variables.mapDataToInquiries(form); --->
<cffunction name="mapDataToInquiries" localmode="modern" access="public">
	<cfargument name="newDataStruct" type="struct" required="yes">
	<cfargument name="sourceStruct" type="struct" required="yes">
	<cfargument name="disableEmail" type="boolean" required="no" default="#false#">
	<cfscript>
	var ts=arguments.newDataStruct;
	var rs=0;
	var row=0;
	var db=request.zos.queryObject;  
	form.inquiries_spam=application.zcore.functions.zso(form, 'inquiries_spam', false, 0);
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_option_group_id = #db.param(arguments.newDataStruct.site_option_group_id)# and 
	site_id = #db.param(request.zos.globals.id)# "; 
	local.qGroup=db.execute("qGroup"); 
	db.sql="select site_option_group_map.*, s2.site_option_display_name, s2.site_option_name originalFieldName from 
	#db.table("site_option_group_map", request.zos.zcoredatasource)# site_option_group_map,  
	#db.table("site_option", request.zos.zcoredatasource)# s2
	WHERE site_option_group_map.site_option_group_id = #db.param(ts.site_option_group_id)# and 
	site_option_group_map.site_id = #db.param(request.zos.globals.id)# and  
	site_option_group_map.site_id = s2.site_id and 
	site_option_group_map.site_option_id = s2.site_option_id and 
	site_option_group_map.site_option_group_id =s2.site_option_group_id 
	ORDER BY s2.site_option_sort asc";
	local.qMap=db.execute("qMap");
	 
	if(local.qMap.recordcount EQ 0){
		return;
	} 
	form.emailLabelStruct={};
	local.countStruct=structnew();
	for(row in local.qMap){
		if(row.site_option_group_map_fieldname NEQ ""){
			if(not structkeyexists(local.countStruct, row.site_option_group_map_fieldname)){
				local.countStruct[row.site_option_group_map_fieldname]=1;
			}else{
				local.countStruct[row.site_option_group_map_fieldname]++;
			}
		}
	} 
	var jsonStruct={ arrCustom: [] };
	// this doesn't support all fields yet, I'd have to use getListValue on all the rows instead - or does it?
	for(row in local.qMap){ 
		if(row.site_option_group_map_fieldname NEQ ""){
			if(structkeyexists(ts, row.originalFieldName)){
				if(row.site_option_group_map_fieldname EQ "inquiries_custom_json"){
					arrayAppend(jsonStruct.arrCustom, { label: row.site_option_display_name, value: ts[row.originalFieldName] });
				}else{
					local.tempString="";
					if(structkeyexists(form, row.site_option_group_map_fieldname)){
						local.tempString=form[row.site_option_group_map_fieldname];
					}
					if(local.countStruct[row.site_option_group_map_fieldname] GT 1){
						//if(request.zos.isdeveloper){ writeoutput('shared:'&row.originalFieldName&'<br />'); }
						form[row.site_option_group_map_fieldname]=local.tempString&row.originalFieldName&": "&ts[row.originalFieldName]&" "&chr(10); 
					}else{
						//if(request.zos.isdeveloper){ writeoutput(' not shared:'&row.originalFieldName&'<br />'); }
						form[row.site_option_group_map_fieldname]=ts[row.originalFieldName]; 
					}
				}
			} 
		}
	} 
	if(structcount(jsonStruct)){
		form.inquiries_custom_json=serializejson(jsonStruct);
	}
	/*
	if(request.zos.isdeveloper){
		writedump(arguments.sourceStruct);
		writedump(ts);
		writedump(local.qMap);
		writedump(local.countStruct);
		writedump(form);
		abort;
	}*/
	ts=structnew();
	ts.table="inquiries";
	ts.datasource=request.zos.zcoreDatasource;
	form.inquiries_type_id=local.qGroup.inquiries_type_id;
	form.inquiries_type_id_siteIDType=local.qGroup.inquiries_type_id_siteIDType; 
	if(form.inquiries_type_id EQ 0 or form.inquiries_type_id EQ ""){
		form.inquiries_type_id=1;
		form.inquiries_type_id_siteIDType=4;
	}
	form.inquiries_datetime=request.zos.mysqlnow;
	form.inquiries_status_id = 1;
	form.site_id = request.zOS.globals.id;
	form.inquiries_primary=1;
	if(application.zcore.functions.zso(form, 'inquiries_email') NEQ ""){
		db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
		SET inquiries_primary=#db.param(0)# 
		WHERE inquiries_email=#db.param(form.inquiries_email)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		db.execute("q"); 
		application.zcore.tracking.setUserEmail(form.inquiries_email);
	}
	ts.struct=form;
	form.inquiries_id=application.zcore.functions.zInsert(ts); 
	
	application.zcore.tracking.setConversion('inquiry',form.inquiries_id);
	 if(form.inquiries_spam EQ 0 and not arguments.disableEmail and not structkeyexists(form, 'disableGroupEmail')){
		ts=structnew();
		ts.inquiries_id=form.inquiries_id;
		if(local.qGroup.site_option_group_public_form_title EQ ""){
			local.tempTitle="Lead capture";
		}else{
			local.tempTitle=local.qGroup.site_option_group_public_form_title;
		}
		ts.subject="#tempTitle# form submitted on #request.zos.globals.shortdomain#";
		// send the lead
		rs=application.zcore.functions.zAssignAndEmailLead(ts);
		if(rs.success EQ false){
			// failed to assign/email lead
			//zdump(rs);
		}
	 }
	local.tempStruct=form;
	application.zcore.functions.zUserMapFormFields(local.tempStruct);
	if(application.zcore.functions.zso(form, 'inquiries_email') NEQ "" and application.zcore.functions.zEmailValidate(form.inquiries_email)){
		form.mail_user_id=application.zcore.user.automaticAddUser(form);
	}
	</cfscript>
</cffunction>

<!--- variables.mapDataToGroup(form); --->
<cffunction name="mapDataToGroup" localmode="modern" access="public">
	<cfargument name="newDataStruct" type="struct" required="yes">
	<cfargument name="sourceStruct" type="struct" required="yes">
	<cfargument name="disableEmail" type="boolean" required="no" default="#false#">
	<cfscript>
	var ts=arguments.newDataStruct;
	var row=0;
	var db=request.zos.queryObject;
	if(ts.site_option_group_map_group_id EQ ts.site_option_group_id){
		// can't map to the same group
		return;
	}
	db.sql="select site_option.*, s2.site_option_name originalFieldName from 
	#db.table("site_option_group_map", request.zos.zcoredatasource)# site_option_group_map, 
	#db.table("site_option", request.zos.zcoredatasource)# site_option, 
	#db.table("site_option", request.zos.zcoredatasource)# s2
	WHERE site_option_group_map.site_option_group_id = #db.param(ts.site_option_group_id)# and 
	site_option_group_map.site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_map.site_id = site_option.site_id and 
	site_option_group_map.site_option_group_map_fieldname = site_option.site_option_id and 
	site_option.site_option_group_id = #db.param(ts.site_option_group_map_group_id)# and
	
	site_option_group_map.site_id = s2.site_id and 
	site_option_group_map.site_option_id = s2.site_option_id and 
	site_option_group_map.site_option_group_id =s2.site_option_group_id
	";
	local.qMap=db.execute("qMap");
	if(local.qMap.recordcount EQ 0){
		return;
	}
	local.arrId=[];
	local.countStruct=structnew();
	for(row in local.qMap){
		if(not structkeyexists(local.countStruct, row.site_option_name)){
			local.countStruct[row.site_option_name]=0;
		}else{
			local.countStruct[row.site_option_name]++;
		}
	}
	for(row in local.qMap){
		// new newValue
		if(structkeyexists(ts, row.originalFieldName)){
			local.tempString="";
			if(structkeyexists(form, row.site_option_name)){
				local.tempString=form[row.site_option_name];
			}
			form["newValue"&row.site_option_id]=ts[row.originalFieldName]; 
			if(local.countStruct[row.site_option_name] GT 1){
				ts[row.site_option_name]=local.tempString&row.originalFieldName&": "&ts[row.originalFieldName]&" "&chr(10); 
			}else{
				ts[row.site_option_name]=ts[row.originalFieldName]; 
			}  
		}else if(not structkeyexists(form, "newValue"&row.site_option_id)){
			form["newValue"&row.site_option_id]="";
			ts[row.site_option_name]="";
		}
		arrayAppend(local.arrId, row.site_option_id);
	}
	form.site_option_id=arrayToList(local.arrId, ",");
	form.site_id=request.zos.globals.id;
	form.site_option_group_id=ts.site_option_group_map_group_id;
	form.site_x_option_group_set_id=0;
	form.disableGroupEmail=arguments.disableEmail;
	variables.publicMapInsertGroup(); 
	structdelete(form, 'disableGroupEmail');
	</cfscript>
</cffunction>
	
<cffunction name="generateGroupEmailTemplate" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="arrKey" type="array" required="yes">
	<!--- <cfargument name="site_option_group_id" type="struct" required="yes">
	<cfargument name="subject" type="struct" required="yes"> --->
	<cfscript>
	var ts=arguments.ss;
	var i=0;
	var db=request.zos.queryObject;
	var rs={
		subject:"",
		html:"",
		text:""
	};
	arraySort(arguments.arrKey, "text", "asc");
	db.sql="select * from #db.table("site_option_group", request.zos.zcoredatasource)# 
	WHERE site_option_group_id = #db.param(ts.site_option_group_id)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	local.qD=db.execute("qD");
	rs.subject='New '&local.qd.site_option_group_display_name&' submitted on '&request.zos.globals.shortDomain;
	local.editLink=request.zos.globals.domain&"/z/admin/site-options/editGroup?site_option_group_id=#ts.site_option_group_id#&site_x_option_group_set_id=#ts.site_x_option_group_set_id#";
	savecontent variable="local.output"{
		writeoutput('New '&local.qd.site_option_group_display_name&' submitted'&chr(10)&chr(10));
		for(i=1;i LTE arraylen(arguments.arrKey);i++){
			if(arguments.arrKey[i] NEQ "site_option_group_id" and arguments.arrKey[i] NEQ "site_x_option_group_set_id"){
				writeoutput(arguments.arrKey[i]&': '&ts[arguments.arrKey[i]]&chr(10));
			}
		}
		writeoutput(chr(10)&chr(10)&'Edit in Site Manager'&chr(10)&local.editLink);
	}
	rs.text=local.output;
	savecontent variable="local.output"{
		writeoutput('#application.zcore.functions.zHTMLDoctype()#
		<head>
		<meta charset="utf-8" />
		<title>'&rs.subject&'</title>
		</head>
		
		<body>
		<p>New '&htmleditformat(local.qd.site_option_group_display_name)&' submitted on '&request.zos.globals.shortDomain&'</p>
		<table style="border-spacing:0px;">');
		for(i=1;i LTE arraylen(arguments.arrKey);i++){
			if(arguments.arrKey[i] NEQ "site_option_group_id" and arguments.arrKey[i] NEQ "site_x_option_group_set_id"){
				writeoutput('<tr><td style="padding:5px;">'&htmleditformat(arguments.arrKey[i])&'</td><td style="padding:5px;">'&htmleditformat(ts[arguments.arrKey[i]])&'</td></tr>');
			}
		}
		writeoutput('</table>
		<br /><p><a href="#htmleditformat(local.editLink)#">Edit in Site Manager</a></p>
		</body>
		</html>');
	}
	rs.html=local.output;
	return rs;
	</cfscript>
</cffunction>

<cffunction name="publicManageGroup" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	this.manageGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="manageGroup" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	var db=request.zos.queryObject;
	var queueSortStruct = StructNew();
	var queueSortCom=0;
	var qGroup=0;
	var r1=0;
	var q1=0;
	var n=0;
	var i=0;
	var qs2=0;
	var arrLabel=arraynew(1);
	var arrVal=arraynew(1);
	var arrType=arraynew(1);
	var arrRow=arraynew(1);
	var arrDisplay=[];
	var arrOptionStruct=[];
	var fakePrimaryId=0;
	var fakePrimaryLabel="";
	var ts=0;
	var fakeRow={};
	var fakePrimaryType=0;
	var theTitle=0;
	var curParentId=0;
	var curParentSetId=0;
	var arrParent=0;
	var selectStruct=0;
	var searchStruct=0;
	var ts2=0;
	var qS=0;
	var q12=0;
	variables.init();
	
	defaultStruct={
		addURL:"/z/admin/site-options/addGroup",
		editURL:"/z/admin/site-options/editGroup",
		deleteURL:"/z/admin/site-options/deleteGroup",
		insertURL:"/z/admin/site-options/insertGroup",
		updateURL:"/z/admin/site-options/updateGroup",
		listURL:"/z/admin/site-options/manageGroup"
	};
	structappend(arguments.struct, defaultStruct, false);
	
	form.zIndex=application.zcore.functions.zso(form, 'zIndex', true, 1);
	application.zcore.functions.zstatusHandler(request.zsid);
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id',true);
	form.site_x_option_group_set_parent_id=application.zcore.functions.zso(form, 'site_x_option_group_set_parent_id',true);
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group WHERE 
	site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_id IN (#db.trustedsql(variables.siteIdList)# ) ";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0){
		application.zcore.functions.zredirect("/z/admin/site-options/index");
	}
	if(qGroup.site_option_group_enable_sorting EQ 1){
		queueSortStruct.tableName = "site_x_option_group_set";
		queueSortStruct.sortFieldName = "site_x_option_group_set_sort";
		queueSortStruct.primaryKeyName = "site_x_option_group_set_id";
		queueSortStruct.datasource=request.zos.zcoreDatasource;
		
		queueSortStruct.where =" site_x_option_group_set.site_option_app_id = '#application.zcore.functions.zescape(form.site_option_app_id)#' and  
		site_option_group_id = '#application.zcore.functions.zescape(form.site_option_group_id)#' and 
		site_x_option_group_set_parent_id='#application.zcore.functions.zescape(form.site_x_option_group_set_parent_id)#' and 
		site_id = '#request.zos.globals.id#'  ";
		
		queueSortStruct.disableRedirect=true;
		queueSortCom = CreateObject("component", "zcorerootmapping.com.display.queueSort");
		r1=queueSortCom.init(queueSortStruct);
		if(structkeyexists(form, 'zQueueSort')){
			// update cache
			if(qGroup.site_option_group_enable_cache EQ 1){
				application.zcore.siteOptionCom.updateSiteOptionGroupSetIdCache(request.zos.globals.id, form.site_x_option_group_set_id); 
			}
			//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
			// redirect with zqueuesort renamed
			application.zcore.functions.zredirect(request.cgi_script_name&"?"&replacenocase(request.zos.cgi.query_string,"zQueueSort=","ztv=","all"));
		}
	}
	if(form.site_option_group_id NEQ 0){
		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
		where site_option_group_id = #db.param(form.site_option_group_id)# and 
		site_id = #db.param(request.zos.globals.id)# 
		ORDER BY site_option_group_display_name";
		q1=db.execute("q1");
		if(q1.recordcount EQ 0){
			application.zcore.functions.z301redirect("/z/admin/site-options/index");	
		}
	}
	db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# site_option 
	where site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_id =#db.param(request.zos.globals.id)# 
	ORDER BY site_option_sort";
	qS2=db.execute("qS2");
	local.parentIndex=0;
	local.arrSearchTable=[];
	local.arrSortSQL=[];
	for(local.row in qS2){
		if(local.row.site_option_admin_searchable EQ 1){
			arrayAppend(local.arrSearchTable, local.row);
		}
		local.added=false;
		ts2={};
		if(qGroup.site_option_group_parent_field NEQ "" and qGroup.site_option_group_parent_field EQ local.row.site_option_name){
			local.added=true;
			arrayappend(arrRow, local.row);
			arrayappend(arrLabel, local.row.site_option_display_name);
			arrayappend(arrVal, local.row.site_option_id);
			arrayappend(arrType, local.row.site_option_type_id);
			local.parentIndex=arraylen(arrVal);
			if(local.row.site_option_primary_field EQ 1){
				arrayAppend(arrDisplay, 1);
			}else{
				arrayAppend(arrDisplay, 0);
			}
		}else if(local.row.site_option_primary_field EQ 1){
			local.added=true;
			arrayAppend(arrDisplay, 1);
			arrayappend(arrRow, local.row);
			arrayappend(arrLabel, local.row.site_option_display_name);
			arrayappend(arrVal, local.row.site_option_id);
			arrayappend(arrType, local.row.site_option_type_id);
		}
		if(local.added){
			if(local.row.site_option_admin_sort_field NEQ 0){ 
				var currentCFC=application.zcore.siteOptionTypeStruct[local.row.site_option_type_id];
				var sortDirection="asc";
				if(local.row.site_option_admin_sort_field EQ 2){
					sortDirection="desc";
				}
				local.tempSQL=currentCFC.getSortSQL(arraylen(arrVal), sortDirection);
				if(local.tempSQL NEQ ""){
					arrayAppend(local.arrSortSQL, local.tempSQL);
				}
			}
		}
		if(local.row.site_option_type_id EQ 0){
			fakeRow=local.row;
			fakePrimaryId=local.row.site_option_id;	
			fakePrimaryLabel=local.row.site_option_display_name;	
			fakePrimaryType=local.row.site_option_type_id;	
		}
	}
	if(fakePrimaryId EQ 0 and qS2.recordcount NEQ 0){
		for(local.row in qS2){
			fakeRow=local.row;
			break;
		}
		fakePrimaryId=qS2.site_option_id;
		fakePrimaryLabel=qS2.site_option_display_name;
		fakePrimaryType=qS2.site_option_type_id;
	}
	if(arraylen(arrVal) EQ 0){
		arrayAppend(arrDisplay, 1);
		arrayappend(arrRow, fakeRow);
		arrayappend(arrVal, fakePrimaryId);
		arrayappend(arrLabel, fakePrimaryLabel);
		arrayappend(arrType, fakePrimaryType);
	}
	local.arrSearch=[];
	var dataStruct=[];
	for(i=1;i LTE arraylen(arrType);i++){
		if(not structkeyexists(arrRow[i], 'site_option_type_json')){
			continue;
		}
		var optionStruct=deserializeJson(arrRow[i].site_option_type_json);
		arrayAppend(arrOptionStruct, optionStruct);
		
		var currentCFC=application.zcore.siteOptionTypeStruct[arrType[i]];
		dataStruct[i]=currentCFC.onBeforeListView(arrRow[i], optionStruct, form);
	}
	theTitle="Manage #htmleditformat(qGroup.site_option_group_display_name)#(s)";
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
	curParentId=q1.site_option_group_parent_id;
	curParentSetId=form.site_x_option_group_set_parent_id;
	arrParent=arraynew(1);
	if(not structkeyexists(arguments.struct, 'hideNavigation') or not arguments.struct.hideNavigation){
		if(curParentSetId NEQ 0){
			loop from="1" to="25" index="i"{
				db.sql="select s1.*, s2.site_x_option_group_set_title, s2.site_x_option_group_set_id d2, s2.site_x_option_group_set_parent_id d3 
				from #db.table("site_option_group", request.zos.zcoreDatasource)# s1, 
				#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s2
				where s1.site_id = s2.site_id and 
				s1.site_id = #db.param(request.zos.globals.id)# and 
				s1.site_option_group_id=s2.site_option_group_id and 
				s2.site_x_option_group_set_id=#db.param(curParentSetId)# and 
				s1.site_option_group_id = #db.param(curParentId)# 
				LIMIT #db.param(0)#,#db.param(1)#";
				q12=db.execute("q12");
				loop query="q12"{
					arrayappend(arrParent, '<a href="#application.zcore.functions.zURLAppend(arguments.struct.listURL, "site_option_group_id=#q12.site_option_group_id#&amp;site_x_option_group_set_parent_id=#q12.d3#")#">#application.zcore.functions.zFirstLetterCaps(q12.site_option_group_display_name)#</a> / #q12.site_x_option_group_set_title# /');
					curParentId=q12.site_option_group_parent_id;
					curParentSetId=q12.d3;
				}
				if(q12.recordcount EQ 0 or curParentSetId EQ 0){
					break;
				}
			}
		}
		if(arraylen(arrParent)){
			writeoutput('<p>');
			for(i = arrayLen(arrParent);i GTE 1;i--){
				writeOutput(arrParent[i]&' ');
			}
			writeoutput(" </p>");
		}
	}
	db.sql="select *, count(s3.site_option_group_id) childCount 
	from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
	left join #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s3 ON 
	site_option_group.site_option_group_id = s3.site_option_group_id and 
	s3.site_id = site_option_group.site_id  
	where 
	site_option_group.site_option_group_parent_id = #db.param(form.site_option_group_id)# and 
	site_option_group.site_id = #db.param(request.zos.globals.id)# 
	GROUP BY site_option_group.site_option_group_id
	ORDER BY site_option_group.site_option_group_display_name";
	q1=db.execute("q1");
	
	local.arrSearchSQL=[];
	local.searchStruct={};
	searchFieldEnabledStruct={};
	
	local.tempGroupKey="#form.site_option_app_id#-#form.site_option_group_id#";
	if(structkeyexists(session, 'siteOptionGroupSearch') and structkeyexists(session.siteOptionGroupSearch, local.tempGroupKey)){
		if(structkeyexists(form, 'clearSearch')){
			structdelete(session.siteOptionGroupSearch, local.tempGroupKey);
		}else if(not structkeyexists(form, 'searchOn')){
			form.searchOn=1;
			structappend(form, session.siteOptionGroupSearch[local.tempGroupKey], false);
		}
	}
	if(form.site_option_group_id NEQ 0 and arraylen(local.arrSearchTable)){ 
		arrayAppend(local.arrSearch, '<form action="#arguments.struct.listURL#" method="get">
		<input type="hidden" name="searchOn" value="1" />
		<input type="hidden" name="site_option_group_id" value="#form.site_option_group_id#" />
		<input type="hidden" name="site_option_app_id" value="#form.site_option_app_id#" />
		<table class="table-list" style="width:100%;"><tr>');
		for(n=1;n LTE arraylen(arrVal);n++){
			local.arrSearchSQL[n]="";
		}
		for(i=1;i LTE arraylen(local.arrSearchTable);i++){
			row=local.arrSearchTable[i];
			for(n=1;n LTE arraylen(arrVal);n++){
				if(row.site_option_id EQ arrVal[n]){
					local.curValIndex=n;
					break;
				}
			}
			
			form['newvalue'&row.site_option_id]=application.zcore.functions.zso(form, 'newvalue'&row.site_option_id);
			 
			var optionStruct=arrOptionStruct[local.curValIndex];
			var currentCFC=application.zcore.siteOptionTypeStruct[row.site_option_type_id];
			if(currentCFC.isSearchable()){
				arrayAppend(local.arrSearch, '<td style="vertical-align:top;">'&row.site_option_name&'<br />');
				var tempValue=currentCFC.getSearchValue(row, optionStruct, 'newvalue', form, local.searchStruct);
				if(structkeyexists(form, 'searchOn')){
					local.arrSearchSQL[local.curValIndex]=currentCFC.getSearchSQL(row, optionStruct, 'newvalue', form, 's#local.curValIndex#.site_x_option_group_value',  's#local.curValIndex#.site_x_option_group_date_value', tempValue); 
					if(local.arrSearchSQL[local.curValIndex] NEQ ""){
						searchFieldEnabledStruct[local.curValIndex]=true;
					}
					local.searchStruct['newvalue'&row.site_option_id]=tempValue;
				}
				arrayAppend(local.arrSearch, currentCFC.getSearchFormField(row, optionStruct, 'newvalue', form, tempValue, '')); 
				arrayAppend(local.arrSearch, '</td>');
			}
		} 
		if(structkeyexists(form, 'searchOn')){
			if(not structkeyexists(session, 'siteOptionGroupSearch')){
				session.siteOptionGroupSearch={};
			}
			session.siteOptionGroupSearch[local.tempGroupKey]=local.searchStruct;
		}
		local.arrNewSearchSQL=[];
		for(n=1;n LTE arraylen(local.arrSearchSQL);n++){
			if(local.arrSearchSQL[n] NEQ ""){
				arrayappend(local.arrNewSearchSQL, local.arrSearchSQL[n]);
			}
		}
		local.arrSearchSQL=local.arrNewSearchSQL; 
		
		if(qGroup.site_option_group_enable_approval EQ 1){
			if(structkeyexists(form, 'searchOn')){
				local.searchStruct['site_x_option_group_set_approved']=application.zcore.functions.zso(form,'site_x_option_group_set_approved');
				if(not structkeyexists(session, 'siteOptionGroupSearch')){
					session.siteOptionGroupSearch={};
				}
				session.siteOptionGroupSearch[local.tempGroupKey]=local.searchStruct;
			}
			arrayAppend(local.arrSearch, '<td style="vertical-align:top;">Approval Status:<br />');
			ts = StructNew();
			ts.name = "site_x_option_group_set_approved";
			ts.listLabels= "Approved|Pending|Deactivated By User|Rejected";
			ts.listValues= "1|0|2|3";
			ts.listLabelsdelimiter="|";
			ts.listValuesdelimiter="|";
			ts.output=false;
			ts.struct=form;
			arrayAppend(local.arrSearch, application.zcore.functions.zInputSelectBox(ts));
			arrayAppend(local.arrSearch, '</td>');
		}
		arrayAppend(local.arrSearch, '<td style="vertical-align:top;"><input type="submit" name="searchSubmit1" value="Search" /> 
			<input type="button" onclick="window.location.href=''#application.zcore.functions.zURLAppend(arguments.struct.listURL, 'site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;clearSearch=1')#'';" name="searchSubmit1" value="Clear Search" /></td></tr></table></form>');
		 
	}
	status=application.zcore.functions.zso(local.searchStruct, 'site_x_option_group_set_approved');
	if(qGroup.site_option_group_admin_paging_limit NEQ 0){
		db.sql="SELECT count(site_option_group.site_option_group_id) count
		FROM (#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group, 
		#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set)  ";
		for(i=1;i LTE arraylen(arrVal);i++){
			if(structkeyexists(searchFieldEnabledStruct, i)){
				db.sql&="LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# s#i# on 
				s#i#.site_x_option_group_set_id = site_x_option_group_set.site_x_option_group_set_id and 
				s#i#.site_option_id = #db.param(arrVal[i])# and 
				s#i#.site_option_group_id = site_option_group.site_option_group_id and 
				s#i#.site_id = site_option_group.site_id and 
				s#i#.site_option_app_id = #db.param(form.site_option_app_id)# ";
			}
		}
		db.sql&="WHERE  
		site_x_option_group_set.site_option_app_id = #db.param(form.site_option_app_id)# and 
		site_option_group.site_id=site_x_option_group_set.site_id and 
		site_option_group.site_option_group_id=site_x_option_group_set.site_option_group_id ";
		if(form.site_x_option_group_set_parent_id NEQ 0){
			db.sql&=" and site_x_option_group_set.site_x_option_group_set_parent_id = #db.param(form.site_x_option_group_set_parent_id)#";
		}
		if(status NEQ ""){
			db.sql&=" and site_x_option_group_set_approved = #db.param(status)# ";
		}
		if(arraylen(local.arrSearchSQL)){
			db.sql&=(" and "&arrayToList(local.arrSearchSQL, ' and '));
		}
		db.sql&=" and site_option_group.site_id =#db.param(request.zos.globals.id)# and 
		site_option_group.site_option_group_id = #db.param(form.site_option_group_id)# and 
		site_option_group.site_option_group_type=#db.param('1')# ";
		local.qCount=db.execute("qCount");
	}
	db.sql="SELECT site_option_group.*,  site_x_option_group_set.*";
	for(i=1;i LTE arraylen(arrVal);i++){
		db.sql&=" , s#i#.site_x_option_group_value sVal#i# ";
	}
	db.sql&=" FROM (#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group, 
	#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set) ";
	for(i=1;i LTE arraylen(arrVal);i++){
		db.sql&="LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# s#i# on 
		s#i#.site_x_option_group_set_id = site_x_option_group_set.site_x_option_group_set_id and 
		s#i#.site_option_id = #db.param(arrVal[i])# and 
		s#i#.site_option_group_id = site_option_group.site_option_group_id and 
		s#i#.site_id = site_option_group.site_id and 
		s#i#.site_option_app_id = #db.param(form.site_option_app_id)# ";
	}
	db.sql&="
	WHERE  
	site_x_option_group_set.site_option_app_id = #db.param(form.site_option_app_id)# and 
	site_option_group.site_id=site_x_option_group_set.site_id and 
	site_option_group.site_option_group_id=site_x_option_group_set.site_option_group_id ";
	if(arraylen(local.arrSearchSQL)){
		db.sql&=(" and "&arrayToList(local.arrSearchSQL, ' and '));
	}
	if(status NEQ ""){
		db.sql&=" and site_x_option_group_set_approved = #db.param(status)# ";
	}
	if(form.site_x_option_group_set_parent_id NEQ 0){
		db.sql&=" and site_x_option_group_set.site_x_option_group_set_parent_id = #db.param(form.site_x_option_group_set_parent_id)#";
	}
	db.sql&=" and site_option_group.site_id =#db.param(request.zos.globals.id)# and 
	site_option_group.site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group.site_option_group_type=#db.param('1')# ";
	//GROUP BY site_x_option_group_set.site_x_option_group_set_id
	if(arraylen(local.arrSortSQL)){
		db.sql&= "ORDER BY "&arraytolist(local.arrSortSQL, ", ");
	}else{
		db.sql&=" ORDER BY site_x_option_group_set_sort asc ";
	}
	if(qGroup.site_option_group_admin_paging_limit NEQ 0){
		db.sql&=" LIMIT #db.param((form.zIndex-1)*qGroup.site_option_group_admin_paging_limit)#, #db.param(qGroup.site_option_group_admin_paging_limit)# ";
	}
	qS=db.execute("qS");
	//writedump(qS);abort;
	// sort and indent 
	if(local.parentIndex NEQ 0){
		local.rs=application.zcore.siteOptionCom.prepareRecursiveData(arrVal[local.parentIndex], form.site_option_group_id, arrOptionStruct[local.parentIndex], false);
	}
	
	local.rowStruct={};
	local.rowIndexFix=1;
	if(qGroup.site_option_group_limit EQ 0 or qS.recordcount LT qGroup.site_option_group_limit){
		writeoutput('<p><a href="#application.zcore.functions.zURLAppend(arguments.struct.addURL, "site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#")#">Add #htmleditformat(application.zcore.functions.zFirstLetterCaps(qGroup.site_option_group_display_name))#</a></p>');
	}
	writeoutput(arraytolist(local.arrSearch, ""));
	if(qS.recordcount){
		writeoutput('<table style="border-spacing:0px; width:100%; " class="table-list" >
		<tr>');
		for(i=1;i LTE arraylen(arrVal);i++){
			if(arrDisplay[i]){
				writeoutput('<th>#arrLabel[i]#</th>');
			}
		}
		if(qGroup.site_option_group_enable_approval EQ 1){
			echo('<th>Approval Status</th>');
		}
		writeoutput('
		<th style="white-space:nowrap;">Admin</th>
		</tr>');
		var row=0;
		var currentRowIndex=0;
		for(row in qS){
			currentRowIndex++;
			if(local.parentIndex){
				local.curRowIndex=0;
				local.curIndent=0;
				for(local.n=1;local.n LTE arraylen(local.rs.arrValue);local.n++){
					if(row.site_x_option_group_set_id EQ local.rs.arrValue[local.n]){
						local.curRowIndex=local.n;
						local.curIndent=len(local.rs.arrLabel[local.n])-len(replace(local.rs.arrLabel[local.n], "_", "", "all"));
						break;
					}
				}
				if(local.curRowIndex EQ 0){
					local.curRowIndex="1000000"&local.rowIndexFix;
					local.rowIndexFix++;
				}
			}else{
				local.curRowIndex=qS.currentrow;
			}
			local.firstDisplayed=true; 
			savecontent variable="local.rowOutput"{ 
				for(var i=1;i LTE arraylen(arrVal);i++){
					if(arrDisplay[i]){
						writeoutput('<td>');
						if(local.firstDisplayed){
							local.firstDisplayed=false;
							if(local.parentIndex NEQ 0 and local.curIndent){
								writeoutput(replace(ljustify(" ", local.curIndent*2), " ", "&nbsp;", "all"));
							}
						}
						var currentCFC=application.zcore.siteOptionTypeStruct[arrType[i]];
						value=currentCFC.getListValue(dataStruct[i], arrOptionStruct[i], application.zcore.functions.zso(row, 'sVal'&i));
						if(value EQ ""){
							writeoutput(arrRow[i].site_option_default_value);
						}else{
							writeoutput(value);
						}
						writeoutput('</td>');
					}
				}
				if(qGroup.site_option_group_enable_approval EQ 1){
					echo('<td>'&application.zcore.siteOptionCom.getStatusName(row.site_x_option_group_set_approved)&'</td>');
				}
				writeoutput('<td style="white-space:nowrap;white-space: nowrap;">');
				if(row.site_id NEQ 0 or variables.allowGlobal){
					if(qGroup.site_option_group_enable_sorting EQ 1){
						writeoutput(queueSortCom.getLinks(qS.recordcount, currentRowIndex, application.zcore.functions.zURLAppend(arguments.struct.listURL, "site_option_group_id=#row.site_option_group_id#&amp;site_x_option_group_set_parent_id=#row.site_x_option_group_set_parent_id#&amp;site_x_option_group_set_id=#row.site_x_option_group_set_id#"), "vertical-arrows"));
					}
					if(q1.recordcount NEQ 0){
						writeoutput('<select name="editGroupSelect#currentRowIndex#" id="editGroupSelect#currentRowIndex#" size="1" onchange="if(this.selectedIndex!=0){ var d=this.options[this.selectedIndex].value; this.selectedIndex=0;window.location.href=''#application.zcore.functions.zURLAppend(arguments.struct.listURL, "site_option_group_id")#=''+d;}">
						<option value="">-- Edit Sub-group --</option>');
						/*arrGroupName=listToArray(row.groupNameList, chr(9));
						arrGroupId=listToArray(row.groupIdList, chr(9));
						childCount=row.childCount;
						LEFT JOIN #db.table("site_option_group", request.zos.zcoreDatasource)# sg3 ON 
						site_option_group.site_option_group_id = sg3.site_option_group_parent_id AND 
						site_option_group.site_id = sg3.site_id
						LEFT JOIN #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# sg4 ON 
						sg3.site_option_group_id = sg4.site_option_group_id AND 
						sg3.site_id = sg4.site_id AND 
						site_x_option_group_set.site_x_option_group_set_id = sg4.site_x_option_group_set_parent_id
						*/ 
						for(var n in q1){
							writeoutput('<option value="#q1.site_option_group_id#&amp;site_x_option_group_set_parent_id=#row.site_x_option_group_set_id#">
							#htmleditformat(application.zcore.functions.zFirstLetterCaps(q1.site_option_group_display_name))#</option>');// (#q1.childCount#)
						}
						writeoutput('</select>
						| ');
					}
					if(row.site_option_group_enable_unique_url EQ 1){
						var tempLink="";
						if(row.site_x_option_group_set_override_url NEQ ""){
							tempLink=row.site_x_option_group_set_override_url;
						}else{
							tempLink="/#application.zcore.functions.zURLEncode(row.site_x_option_group_set_title, '-')#-#request.zos.globals.optionGroupURLID#-#row.site_x_option_group_set_id#.html";
						}
						if(row.site_x_option_group_set_approved EQ 1){
							writeoutput('<a href="'&tempLink&'" target="_blank">View</a> | ');
						}else{
							writeoutput(' <a href="'&application.zcore.functions.zURLAppend(tempLink, "zpreview=1")&'" target="_blank">Preview</a> | ');
						}
					}
					writeoutput('<a href="#application.zcore.functions.zURLAppend(arguments.struct.editURL, "site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#row.site_option_group_id#&amp;site_x_option_group_set_id=#row.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=#row.site_x_option_group_set_parent_id#")#">Edit</a> | 
					<a href="#application.zcore.functions.zURLAppend(arguments.struct.deleteURL, "site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#row.site_option_group_id#&amp;site_x_option_group_set_id=#row.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=#row.site_x_option_group_set_parent_id#")#">Delete</a>');
				}
				writeoutput('</td>'); 
			}
			local.rowStruct[local.curRowIndex]=local.rowOutput;
		}
		local.arrKey=structkeyarray(local.rowStruct);
		arraysort(local.arrKey, "numeric", "asc");
		for(i=1;i LTE arraylen(local.arrKey);i++){
			writeoutput('<tr ');
			if(i MOD 2 EQ 0){
				writeoutput('class="row2"');
			}else{
				writeoutput('class="row1"');
			}
			writeoutput('>'&local.rowStruct[local.arrKey[i]]&'</tr>');
		} 
		writeoutput('</table>');
		if(form.site_option_group_id NEQ 0){
			if(qGroup.site_option_group_admin_paging_limit NEQ 0){
				searchStruct = StructNew();
				searchStruct.count = qCount.count;
				searchStruct.index = form.zIndex;
				searchStruct.showString = "Results ";
				searchStruct.url = application.zcore.functions.zURLAppend(arguments.struct.listURL, "site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#");
				searchStruct.indexName = "zIndex";
				searchStruct.buttons = 5;
				searchStruct.perpage = qGroup.site_option_group_admin_paging_limit;
				if(searchStruct.count GT searchStruct.perpage){
					writeoutput( '<table class="table-list" style="width:100%; border-spacing:0px;" ><tr><td style="padding:0px;">'&application.zcore.functions.zSearchResultsNav(searchStruct)&'</td></tr></table>');
				}
			} 
		}
	}
	</cfscript> 
</cffunction>


<cffunction name="publicEditGroup" localmode="modern" access="remote" roles="public">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicEditGroup";
	this.editGroup(arguments.struct);
	</cfscript>
</cffunction>
<cffunction name="publicAddGroup" localmode="modern" access="remote" roles="public">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicAddGroup";
	this.editGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="addGroup" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.editGroup();
	</cfscript>
</cffunction>

<cffunction name="editGroup" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	var db=request.zos.queryObject;
	var qS=0;
	var theTitle=0;
	var htmlEditor=0;
	var selectStruct=0;
	var ts=0;
	if(not structkeyexists(arguments.struct, 'action')){
		arguments.struct.action='/z/misc/display-site-option-group/insert';	
	}
	if(not structkeyexists(arguments.struct, 'returnURL')){
		arguments.struct.returnURL='/z/misc/display-site-option-group/add?site_option_group_id=#form.site_option_group_id#';	
	}
	variables.init();
	local.methodBackup=form.method;
	application.zcore.functions.zstatusHandler(request.zsid, true, false, form); 
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
	form.site_x_option_group_set_parent_id=application.zcore.functions.zso(form, 'site_x_option_group_set_parent_id',true);
	
	
	
	form.jumpto=application.zcore.functions.zso(form, 'jumpto');
	db.sql="SELECT * FROM (#db.table("site_option", request.zos.zcoreDatasource)# site_option, 
	#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group) 
	LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# site_x_option_group ON 
	site_option.site_option_group_id = site_x_option_group.site_option_group_id and 
	site_option.site_option_id = site_x_option_group.site_option_id and 
	site_x_option_group.site_id = site_option_group.site_id and 
	site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)# WHERE 
	site_option.site_id = site_option_group.site_id and 
	site_option.site_id = #db.param(request.zos.globals.id)# and 
	site_option_group.site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group.site_option_group_id = site_option.site_option_group_id and 
	site_option_group.site_option_group_type=#db.param('1')# ";
	if(local.methodBackup EQ "publicAddGroup" or local.methodBackup EQ "publicEditGroup"){
		db.sql&=" and site_option_allow_public=#db.param(1)#";
	}
	db.sql&=" ORDER BY site_option.site_option_sort asc, site_option.site_option_name ASC";
	qS=db.execute("qS"); 
	if(qS.recordcount EQ 0){
		application.zcore.functions.z404("No site_options have been set to allow public form data entry.");	
	}
	curParentId=qS.site_option_group_parent_id;
	curParentSetId=form.site_x_option_group_set_parent_id;
	arrParent=arraynew(1);
	if(not structkeyexists(arguments.struct, 'hideNavigation') or not arguments.struct.hideNavigation){
		if(curParentSetId NEQ 0){
			loop from="1" to="25" index="i"{
				db.sql="select s1.*, s2.site_x_option_group_set_title, s2.site_x_option_group_set_id d2, s2.site_x_option_group_set_parent_id d3 
				from #db.table("site_option_group", request.zos.zcoreDatasource)# s1, 
				#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s2
				where s1.site_id = s2.site_id and 
				s1.site_id = #db.param(request.zos.globals.id)# and 
				s1.site_option_group_id=s2.site_option_group_id and 
				s2.site_x_option_group_set_id=#db.param(curParentSetId)# and 
				s1.site_option_group_id = #db.param(curParentId)# 
				LIMIT #db.param(0)#,#db.param(1)#";
				q12=db.execute("q12");
				loop query="q12"{
					arrayappend(arrParent, '<a href="#application.zcore.functions.zURLAppend("/z/admin/site-options/manageGroup", "site_option_group_id=#q12.site_option_group_id#&amp;site_x_option_group_set_parent_id=#q12.d3#")#">#application.zcore.functions.zFirstLetterCaps(q12.site_option_group_display_name)#</a> / #q12.site_x_option_group_set_title# / ');
					curParentId=q12.site_option_group_parent_id;
					curParentSetId=q12.d3;
				}
				if(q12.recordcount EQ 0 or curParentSetId EQ 0){
					break;
				}
			}
		}
		if(arraylen(arrParent)){
			writeoutput('<p>');
			for(i = arrayLen(arrParent);i GTE 1;i--){
				writeOutput(arrParent[i]&' ');
			}
			writeoutput(" </p>");
		}
	}
	db.sql="SELECT * FROM #db.table("site_x_option_group_set", request.zos.zcoredatasource)# 
	WHERE
	site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)# and 
	site_id = #db.param(request.zos.globals.id)#  ";
	
	local.qSet=db.execute("qSet");
	if(local.methodBackup EQ "editGroup"){
		if(local.qSet.recordcount EQ 0){
			application.zcore.functions.z404("This site option group no longer exists.");	
		}
	}
	
	db.sql="select * from #db.table("site_option_group", request.zos.zcoredatasource)# 
	WHERE site_option_group_id=#db.param(form.site_option_group_id)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	local.qCheck=db.execute("qCheck");
	if(local.qCheck.recordcount EQ 0){
		application.zcore.functions.z404("This group doesn't allow public data entry.");	
	}
	if(local.qCheck.site_option_group_form_description NEQ ""){
		writeoutput(local.qCheck.site_option_group_form_description);
	}
	if(local.methodBackup EQ "publicAddGroup" or local.methodBackup EQ "addGroup"){
		application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
	}
	if(local.methodBackup EQ "publicAddGroup" or local.methodBackup EQ "publicEditGroup"){
		// 404 if group doesn't allow public entry
		if(local.qCheck.site_option_group_allow_public NEQ 1){
			arrUserGroup=listToArray(local.qCheck.site_option_group_user_group_id_list, ",");
			hasAccess=false;
			for(i=1;i LTE arraylen(arrUserGroup);i++){
				if(application.zcore.user.checkGroupIdAccess(arrUserGroup[i])){
					hasAccess=true;
					break;
				}
			}
			if(not hasAccess){
				application.zcore.functions.z404("site_option_group_id, #form.site_option_group_id#, doesn't allow public data entry.");
			}
		}
		
		if(local.qCheck.site_option_group_public_form_title NEQ ""){
			theTitle=local.qCheck.site_option_group_public_form_title;
		}else if(local.methodBackup EQ "publicEditGroup"){
			theTitle="Edit "&local.qCheck.site_option_group_display_name;
		}else{
			theTitle="Add "&local.qCheck.site_option_group_display_name;
		}
	}else if(local.methodBackup EQ "addGroup"){
		theTitle="Add "&local.qCheck.site_option_group_display_name;
	}else{
		theTitle="Edit "&local.qCheck.site_option_group_display_name;
	}
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle); 
	if(local.methodBackup EQ "publicAddGroup" or local.methodBackup EQ "publicEditGroup"){
		form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced');
		if(form.modalpopforced EQ 1){
			application.zcore.functions.zSetModalWindow();
		}
        	form.set9=application.zcore.functions.zGetHumanFieldIndex();
	}
	local.arrEnd=arraynew(1);
	</cfscript>
	<cfif local.methodBackup EQ "publicEditGroup">
		<cfif qSet.site_x_option_group_set_approved EQ 2>
			<p><strong>Note: Updating this record will re-submit this listing for approval.</strong></p>
		</cfif>
	</cfif>
	<p>* denotes required field.
	<cfif local.methodBackup EQ "addGroup" or local.methodBackup EQ "editGroup">
		 | <a href="/z/admin/site-option-group/help?site_option_group_id=#form.site_option_group_id#" target="_blank">View help in new window.</a>
	</cfif>
	</p>
	<form  name="myForm" action="<cfif local.methodBackup EQ "publicAddGroup" or local.methodBackup EQ "publicEditGroup">#arguments.struct.action#<cfelse>/z/admin/site-options/<cfif local.methodBackup EQ "addGroup">insertGroup<cfelse>updateGroup</cfif>?site_option_app_id=#form.site_option_app_id#</cfif>" method="post" enctype="multipart/form-data" <cfif local.methodBackup EQ "publicAddGroup" or local.methodBackup EQ "publicEditGroup">onsubmit="zSet9('zset9_#form.set9#');"</cfif>>
		<cfif local.methodBackup EQ "publicAddGroup" or local.methodBackup EQ "publicEditGroup">
			<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
			#application.zcore.functions.zFakeFormFields()#
		</cfif>
		<input type="hidden" name="site_option_group_id" value="#htmleditformat(form.site_option_group_id)#" />
		<input type="hidden" name="site_x_option_group_set_id" value="#htmleditformat(form.site_x_option_group_set_id)#" />
		<input type="hidden" name="site_x_option_group_set_parent_id" value="#htmleditformat(form.site_x_option_group_set_parent_id)#" />
		<table style="border-spacing:0px;" class="table-list">
			<cfscript>
			var row=0;
			var currentRowIndex=0;
			var optionStruct={};
			var dataStruct={};
			var labelStruct={};
			for(row in qS){
				currentRowIndex++;
				if(form.jumpto EQ "soid_#application.zcore.functions.zurlencode(row.site_option_name,"_")#"){
					local.jumptoanchor="soid_#row.site_option_id#";
				}
				if(not structkeyexists(form, "newvalue"&row.site_option_id)){
					if(structkeyexists(form, row.site_option_name)){
						form["newvalue"&row.site_option_id]=form[row.site_option_name];
					}else{
						if(row.site_x_option_group_value NEQ ""){
							form["newvalue"&row.site_option_id]=row.site_x_option_group_value;
						}else{
							form["newvalue"&row.site_option_id]=row.site_option_default_value;
						}
					}
				}
				form[row.site_option_name]=form["newvalue"&row.site_option_id];
				if(row.site_x_option_group_id EQ ""){
					if(not structkeyexists(form, "newvalue"&row.site_option_id)){
						form["newvalue"&row.site_option_id]=row.site_option_default_value;
					}
				}
				optionStruct[row.site_option_id]=deserializeJson(row.site_option_type_json);
				var currentCFC=application.zcore.siteOptionTypeStruct[row.site_option_type_id]; 
				dataStruct=currentCFC.onBeforeListView(row, optionStruct[row.site_option_id], form);
				value=currentCFC.getListValue(dataStruct, optionStruct[row.site_option_id], form["newvalue"&row.site_option_id]);
				if(value EQ ""){
					value=row.site_option_default_value;
				}
				labelStruct[row.site_option_name]=value;
			}
			var currentRowIndex=0;
			for(row in qS){
				currentRowIndex++;
			
				var currentCFC=application.zcore.siteOptionTypeStruct[row.site_option_type_id]; 
				var rs=currentCFC.getFormField(row, optionStruct[row.site_option_id], 'newvalue', form, labelStruct);
				if(rs.hidden){
					arrayAppend(local.arrEnd, rs.value);
				}else{
					writeoutput('<tr ');
					if(currentRowIndex MOD 2 EQ 0){
						writeoutput('class="row1"');
					}else{
						writeoutput('class="row2"');
					}
					writeoutput('>');
					if(rs.label and row.site_option_hide_label EQ 0){
						writeoutput('<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">'&application.zcore.functions.zOutputToolTip(row.site_option_display_name, row.site_option_tooltip)&'<a name="soid_#row.site_option_id#" id="soid_#row.site_option_id#" style="display:block; float:left;"></a>
						</div></th>
					<td style="vertical-align:top;white-space: nowrap;"><input type="hidden" name="site_option_id" value="#htmleditformat(row.site_option_id)#" />');
					}else{
						writeoutput('<td style="vertical-align:top; padding-top:5px;" colspan="2">');
						if(rs.label){
							writeoutput('<input type="hidden" name="site_option_id" value="#htmleditformat(row.site_option_id)#" />');
						}
					} 
					writeoutput(rs.value);
				}
				if(row.site_option_required){
					writeoutput(' * ');
				} 
				if(rs.label){
					writeoutput('</td>');	
					writeoutput('</tr>');
				}
			}
			</cfscript>
			<cfset local.tempIndex=qS.recordcount+1>
			<cfif local.methodBackup NEQ "publicAddGroup" and local.methodBackup NEQ "publicEditGroup">
				<cfif local.qCheck.site_option_group_enable_approval EQ 1>
					<cfscript>
					if(local.methodBackup EQ 'addGroup'){
						form.site_x_option_group_set_approved=1;
					}else{
						form.site_x_option_group_set_approved=local.qSet.site_x_option_group_set_approved;
					}
					</cfscript>
					<tr <cfif local.tempIndex MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Approved?</div></th>
					<td style="vertical-align:top;white-space: nowrap;">
						<cfscript>
						ts = StructNew();
						ts.name = "site_x_option_group_set_approved";
						ts.labelList = "Approved|Pending|Deactivated By User|Rejected";
						ts.valueList = "1|0|2|3";
						ts.delimiter="|";
						ts.output=true;
						ts.struct=form;
						writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
						</cfscript>
					</td>
					</tr>
					<cfset local.tempIndex++>
				</cfif>
				<cfif qS.site_option_group_enable_unique_url EQ 1>
					<tr <cfif local.tempIndex MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Override URL:</div></th>
					<td style="vertical-align:top; white-space: nowrap;"><input type="text" style="width:95%;" name="site_x_option_group_set_override_url" value="<cfif local.qSet.recordcount NEQ 0>#htmleditformat(qSet.site_x_option_group_set_override_url)#</cfif>" /> <br />It is not recommended to use this feature.  It is used to change the URL within the site.  Don't use this for external links.
					</td>
					</tr>
					<cfset local.tempIndex++>
				</cfif>
			</cfif>
			<cfif qS.site_option_group_enable_image_library EQ 1>
				<tr <cfif local.tempIndex MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
				<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Image Library:</div></th>
				<td style="vertical-align:top;white-space: nowrap;">
					<cfscript>
					ts=structnew();
					ts.name="site_x_option_group_set_image_library_id";
					if(qSet.recordcount NEQ 0){
						ts.value=qSet.site_x_option_group_set_image_library_id;
					}else{
						ts.value=0;
					}
					ts.allowPublicEditing=true;
					application.zcore.imageLibraryCom.getLibraryForm(ts);
					
					</cfscript>
				</td>
				</tr>
				<cfset local.tempIndex++>
			</cfif> 
			<cfif qS.site_option_group_enable_public_captcha EQ 1 and (local.methodBackup EQ "publicAddGroup" or local.methodBackup EQ "publicEditGroup")>
				<tr <cfif local.tempIndex MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
				<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">&nbsp;</div></th>
				<td style="vertical-align:top;white-space: nowrap;">
				#application.zcore.functions.zDisplayRecaptcha()#
				</td>
				</tr>
				<cfset local.tempIndex++>
			</cfif>
			<tr>
				<th>&nbsp;</th>
				<td>
				#arraytolist(local.arrEnd, '')#
				<cfif local.methodBackup EQ "publicAddGroup" or local.methodBackup EQ "publicEditGroup">
					<button type="submit" name="submitForm">Submit</button>
					<cfif structkeyexists(arguments.struct, 'cancelURL')>
						<button type="button" name="cancel1" onclick="window.location.href='#htmleditformat(arguments.struct.cancelURL)#';">Cancel</button>
					</cfif>
					&nbsp;&nbsp; <a href="/z/user/privacy/index" target="_blank">Privacy Policy</a>
					    <cfif form.modalpopforced EQ 1>
						<input type="hidden" name="modalpopforced" value="1" />
						<input type="hidden" name="js3811" id="js3811" value="" />
						<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" />
					    </cfif>
				<cfelse>
					<button type="submit" name="submitForm">Save</button>
						&nbsp;
						<button type="button" name="cancel" onclick="window.location.href='/z/admin/site-options/manageGroup?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#';">Cancel</button>
				</cfif>
				</td>
			</tr>
		</table>
	</form>
	<div style="width:100%; <cfif form.site_option_group_id EQ "">min-height:1000px; </cfif> float:left; clear:both;"></div>
	<cfif structkeyexists(local, 'jumptoanchor')>
		<script type="text/javascript">
		/* <![CDATA[ */
		var d1=document.getElementById("#local.jumptoanchor#");
		var p=zGetAbsPosition(d1);
		window.scrollTo(0, p.y);
		/* ]]> */
		</script>
	</cfif>
</cffunction>


<cffunction name="autoDeleteGroup" localmode="modern" access="public" roles="member">
	<cfscript>
	form.method="autoDeleteGroup";
	form.confirm=1;
	form.site_option_app_id=0;
	this.deleteGroup();
	</cfscript>
</cffunction>


<cffunction name="publicDeleteGroup" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicDeleteGroup";
	this.deleteGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="deleteGroup" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	var db=request.zos.queryObject;
	var queueSortStruct=0;
	var queueSortCom=0;
	var r1=0;
	var qS=0;
	var qCheck=0;
	var theTitle=0;
	var i=0;
	var result=0;   
	defaultStruct={
		addURL:"/z/admin/site-options/addGroup",
		editURL:"/z/admin/site-options/editGroup",
		deleteURL:"/z/admin/site-options/deleteGroup",
		insertURL:"/z/admin/site-options/insertGroup",
		updateURL:"/z/admin/site-options/updateGroup",
		listURL:"/z/admin/site-options/manageGroup",
		errorURL:"/z/admin/site-options/index"
	};
	structappend(arguments.struct, defaultStruct, false);
	
	variables.init();
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id');
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group, 
	#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set WHERE
	site_x_option_group_set.site_id = site_option_group.site_id and 
	site_option_group.site_option_group_id = site_x_option_group_set.site_option_group_id and 
	site_x_option_group_set_id= #db.param(form.site_x_option_group_set_id)# and 
	site_option_group.site_option_group_id= #db.param(form.site_option_group_id)# and 
	site_x_option_group_set.site_id= #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Site Option Group is missing");
		if(form.method EQ "autoDeleteGroup"){
			return false;
		}else{
			application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.struct.errorURL, "zsid="&request.zsid));
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		if(qCheck.site_x_option_group_set_image_library_id NEQ 0){
			application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.site_x_option_group_set_image_library_id);
		}
		db.sql="SELECT * FROM #db.table("site_x_option_group", request.zos.zcoreDatasource)# site_x_option_group, 
		#db.table("site_option", request.zos.zcoreDatasource)# site_option WHERE 
		site_option.site_id = site_x_option_group.site_id and 
		site_x_option_group.site_option_app_id=#db.param(form.site_option_app_id)# and 
		site_x_option_group.site_option_id = site_option.site_option_id and 
		site_option.site_option_group_id=#db.param(form.site_option_group_id)# and 
		site_x_option_group_set_id= #db.param(form.site_x_option_group_set_id)# and 
		site_x_option_group.site_id =#db.param(request.zos.globals.id)#";
		qS=db.execute("qS");
		var row=0;
		for(row in qS){
			var currentCFC=application.zcore.siteOptionTypeStruct[row.site_option_type_id]; 
			if(currentCFC.hasCustomDelete()){
				var optionStruct=deserializeJson(row.site_option_type_json);
				currentCFC.onDelete(row, optionStruct); 
			}
		}
		db.sql="DELETE FROM #db.table("site_x_option_group", request.zos.zcoreDatasource)#  
		WHERE site_option_app_id=#db.param(form.site_option_app_id)# and 
		site_x_option_group_set_id= #db.param(form.site_x_option_group_set_id)# and 
		site_option_group_id=#db.param(form.site_option_group_id)#  and 
		site_id= #db.param(request.zos.globals.id)# ";
		result = db.execute("result");
		application.zcore.routing.deleteSiteOptionGroupSetUniqueURL(form.site_x_option_group_set_id);
		db.sql="DELETE FROM #db.table("site_x_option_group_set", request.zos.zcoreDatasource)#  
		WHERE site_option_app_id=#db.param(form.site_option_app_id)# and 
		site_x_option_group_set_id= #db.param(form.site_x_option_group_set_id)# and 
		site_option_group_id=#db.param(form.site_option_group_id)#  and 
		site_id= #db.param(request.zos.globals.id)#  ";
		result = db.execute("result");
		if(qCheck.site_option_group_enable_image_library EQ 1 and qCheck.site_x_option_group_set_image_library_id NEQ 0){
			application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.site_x_option_group_set_image_library_id);
		}
		
		local.siteOptionCom=createobject("component", "zcorerootmapping.com.app.site-option");
		local.siteOptionCom.deleteSiteOptionGroupSetIndex(form.site_x_option_group_set_id, request.zos.globals.id);
		
		if(qCheck.site_option_group_enable_sorting EQ 1){
			queueSortStruct = StructNew();
			queueSortStruct.tableName = "site_x_option_group_set";
			queueSortStruct.sortFieldName = "site_x_option_group_set_sort";
			queueSortStruct.primaryKeyName = "site_x_option_group_set_id";
			queueSortStruct.datasource=request.zos.zcoreDatasource;
			
			queueSortStruct.where =" site_x_option_group_set.site_option_app_id = '#application.zcore.functions.zescape(form.site_option_app_id)#' and  
			site_option_group_id = '#application.zcore.functions.zescape(form.site_option_group_id)#' and 
			site_id = '#request.zos.globals.id#'  ";
			
			queueSortStruct.disableRedirect=true;
			queueSortCom = CreateObject("component", "zcorerootmapping.com.display.queueSort");
			r1=queueSortCom.init(queueSortStruct);
			queueSortCom.sortAll();
		}
		if(qCheck.site_option_group_enable_cache EQ 1){
			application.zcore.siteOptionCom.deleteSiteOptionGroupSetIdCache(request.zos.globals.id, form.site_x_option_group_set_id);
		}
		//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
		application.zcore.status.setStatus(request.zsid, "Deleted successfully.");
		if(form.method EQ "autoDeleteGroup"){
			return true;
		}else{
			application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.struct.listURL, "site_option_group_id="&form.site_option_group_id&"&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&zsid="&request.zsid));
		}
        	</cfscript>
	<cfelse>
		<cfscript>
		theTitle="Delete Group";
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
		</cfscript>
		<h2>
		Are you sure you want to delete this data?<br />
		<br />
		#qcheck.site_option_group_display_name# 		<br />
		ID## #form.site_x_option_group_set_id# <br />
		<br />
		<a href="#application.zcore.functions.zURLAppend(arguments.struct.deleteURL, "site_option_app_id=#form.site_option_app_id#&amp;confirm=1&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#")#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="#application.zcore.functions.zURLAppend(arguments.struct.listURL, "site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#")#">No</a>
	</cfif>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qS=0;
	var qGroup=0;
	var qU9=0;
	var theTitle=0;
	var htmlEditor=0;
	var lastGroup=0;
	var ts=0;
	var site_option_group_id=0;
	variables.init();
	application.zcore.functions.zStatusHandler(request.zsid);
	if(structkeyexists(form, 'return') and request.zos.CGI.HTTP_REFERER NEQ ""){
		StructInsert(session, "siteoption_return", request.zos.CGI.HTTP_REFERER, true);		
	}
	form.jumpto=application.zcore.functions.zso(form, 'jumpto');
	site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id',true);
   	db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
	LEFT JOIN #db.table("site_x_option", request.zos.zcoreDatasource)# site_x_option ON 
	site_option.site_option_id = site_x_option.site_option_id and 
	site_x_option.site_id = #db.param(request.zos.globals.id)# and 
	site_option.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("site_x_option.site_option_id_siteIDType"))# and 
	site_x_option.site_option_app_id=#db.param(form.site_option_app_id)# 
	LEFT JOIN #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group ON 
	site_option_group.site_option_group_id = site_option.site_option_group_id and 
	site_option_group.site_id = site_x_option.site_id and 
	site_option_group.site_id = #db.param(request.zos.globals.id)# and 
	(site_option_group.site_option_group_appidlist like #db.param('%,#variables.currentAppId#,%')#";
	if(variables.currentAppId EQ 0){
		db.sql&=" or site_option_group.site_option_group_appidlist like #db.param('%,,%')#";
	}
	db.sql&=")
	WHERE site_option.site_id IN (#db.trustedSQL(variables.publicSiteIdList)#) and 
	(site_option_group.site_option_group_id IS NULL or 
	site_option_group.site_option_group_type =#db.param('0')#)
	and (site_option.site_option_appidlist like #db.param('%,#variables.currentAppId#,%')#";
	if(variables.currentAppId EQ 0){
		db.sql&=" or site_option.site_option_appidlist like #db.param('%,,%')#";
	}
	db.sql&=")";
	if(site_option_group_id EQ 0){
		db.sql&=" and site_option.site_option_group_id=#db.param('0')#";
	}
	if(structkeyexists(request.zos,'listing') EQ false){
		db.sql&=" and site_option_listing_only=#db.param('0')#";
	}
	db.sql&=" ORDER BY site_option_group.site_option_group_display_name ASC, site_option.site_option_name ASC ";
	qS=db.execute("qS");
	theTitle="Site Options";
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
	db.sql="SELECT site_option_group.*, count(site_x_option_group_set.site_option_group_id) childCount 
	FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
	LEFT JOIN #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set ON 
	site_x_option_group_set.site_id = #db.param(request.zos.globals.id)# and 
	site_x_option_group_set.site_option_group_id = site_option_group.site_option_group_id and 
	site_option_app_id=#db.param(form.site_option_app_id)# 
	WHERE site_option_group.site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_parent_id = #db.param('0')# and 
	site_option_group_type =#db.param('1')# and 
	(site_option_group.site_option_group_appidlist like #db.param('%,#variables.currentAppId#,%')# ";
	if(variables.currentAppId EQ 0){
		db.sql&=" or site_option_group.site_option_group_appidlist like #db.param('%,,%')#";
	}
	db.sql&=" )  and 
	site_option_group.site_option_group_disable_admin=#db.param(0)#
	GROUP BY site_option_group.site_option_group_id 
	ORDER BY site_option_group.site_option_group_display_name ASC ";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount NEQ 0){
		writeoutput('<h2>Custom Admin Features</h2>
		<table style="border-spacing:0px;" class="table-list">');
		var row=0;
		for(row in qGroup){
			writeoutput('<tr ');
			if(qGroup.currentRow MOD 2 EQ 0){
				writeoutput('class="row2"');
			}else{
				writeoutput('class="row1"');
			}
			writeoutput('>
				<td>#qGroup.site_option_group_display_name#</td>
				<td><a href="/z/admin/site-options/manageGroup?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#qGroup.site_option_group_id#">List/Edit</a> 
					| <a href="/z/admin/site-options/import?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#qGroup.site_option_group_id#">Import</a> ');
				
					if(qGroup.site_option_group_allow_public NEQ 0){
						writeoutput(' | ');
						if(qGroup.site_option_group_public_form_url NEQ ""){
							writeoutput('<a href="#htmleditformat(qGroup.site_option_group_public_form_url)#" target="_blank">Public Form</a> ');
						}else{
							writeoutput('<a href="/z/misc/display-site-option-group/add?site_option_group_id=#qGroup.site_option_group_id#" target="_blank">Public Form</a> ');
						}
					}
					if(qGroup.site_option_group_limit EQ 0 or qGroup.childCount LT qGroup.site_option_group_limit){
						writeoutput('| <a href="/z/admin/site-options/addGroup?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#qGroup.site_option_group_id#">Add</a>');
					}else{
						writeoutput(' | Limit Reached');
					}
					writeoutput('</td>
			</tr>');
		}
		writeoutput('</table>
		<br />');
	}
	writeoutput('<h2>Global Site Options</h2>');
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
	where user_id = #db.param(session.zos.user.id)# and 
	site_id=#db.param(session.zos.user.site_id)#";
	qU9=db.execute("qU9");
	if(qu9.recordcount NEQ 0 and form.site_option_app_id EQ 0){
		writeoutput('<a href="/z/-evm#session.zos.user.id#.0.#qu9.user_key#.1" rel="external" onclick="window.open(this.href); return false;">View email autoresponder</a><br />
		<br />');
	}
	if(qS.recordcount EQ 0){
		writeoutput('<table style="border-spacing:0px;" class="table-list">
			<tr>
				<th>No site options are available at this time.</th>
			</tr>
		</table>');
	}else{
		writeoutput('<form  name="myForm" action="/z/admin/site-options/saveOptions?site_option_app_id=#form.site_option_app_id#" method="post" enctype="multipart/form-data">
			<table style="border-spacing:0px; width:100%;" class="table-list">');
			lastGroup="";
			var row=0;
			var optionStruct={};
			var currentRowIndex=0;
			var dataStruct={};
			var labelStruct={};
			for(row in qS){
				currentRowIndex++;
				if(form.jumpto EQ "soid_#application.zcore.functions.zurlencode(row.site_option_name,"_")#"){
					local.jumptoanchor="soid_#row.site_option_id#";
				}
				if(not structkeyexists(variables, "newvalue"&row.site_option_id)){
					variables["newvalue"&row.site_option_id]=row.site_x_option_value;
					if(row.site_x_option_id EQ ""){
						variables["newvalue"&row.site_option_id]=row.site_option_default_value;
					}
				}
				variables[row.site_option_name]=variables["newvalue"&row.site_option_id];
				if(row.site_x_option_id EQ ""){
					if(not structkeyexists(variables, "newvalue"&row.site_option_id)){
						variables["newvalue"&row.site_option_id]=row.site_option_default_value;
					}
				}
				optionStruct[row.site_option_id]=deserializeJson(row.site_option_type_json);
				var currentCFC=application.zcore.siteOptionTypeStruct[row.site_option_type_id]; 
				dataStruct=currentCFC.onBeforeListView(row, optionStruct[row.site_option_id], variables);
				value=currentCFC.getListValue(dataStruct, optionStruct[row.site_option_id], application.zcore.functions.zso(variables, "newvalue"&row.site_option_id));
				if(value EQ ""){
					value=row.site_option_default_value;
				}
				labelStruct[row.site_option_name]=value;
			}
			currentRowIndex=0;
			for(row in qS){
				currentRowIndex++;
				if(lastGroup NEQ row.site_option_group_name){
					lastGroup = row.site_option_group_name;
					writeoutput('<tr>
						<td colspan="2"><h2>#htmleditformat(row.site_option_group_display_name)#</h2></td>
					</tr>');
				}
				writeoutput('<tr ');
				if(currentRowIndex MOD 2 EQ 0){
					writeoutput('class="row2"');
				}else{
					writeoutput('class="row1"');
				}
				writeoutput('>
				<td style="vertical-align:top;" colspan="2" style="padding-bottom:10px;"><a name="soid_#row.site_option_id#" id="soid_#row.site_option_id#" style="display:block; float:left;"></a>
					<div style="padding-bottom:5px;float:left; width:99%;">#row.site_option_display_name# <a href="##" onclick="document.myForm.submit();return false;" style="font-size:11px; text-decoration:none; font-weight:bold; padding:4px; display:block; float:right; border:1px solid ##999;">Save</a></div>
					<input type="hidden" name="site_option_id" value="#row.site_option_id#" />
					<input type="hidden" name="siteidtype" value="#application.zcore.functions.zGetSiteIdType(row.site_id)#" />
					<br style="clear:both;" />');
					var currentCFC=application.zcore.siteOptionTypeStruct[row.site_option_type_id]; 
					var rs=currentCFC.getFormField(row, optionStruct[row.site_option_id], 'newvalue', variables, labelStruct);
					writeoutput(rs.value);
					writeoutput('</td>
				</tr>');
			}
			writeoutput('<tr>
				<td>&nbsp;</td>
				<td><button type="submit" name="submitForm">Save Options</button>
					&nbsp;');
					if(structkeyexists(form, 'return')){
						writeoutput('<button type="button" name="cancel" onclick="window.location.href=''#request.zos.CGI.HTTP_REFERER#'';">Cancel</button>');
					}
					writeoutput('</td>
				</tr>
			</table>
		</form>
		<a name="s1"></a>
		<div style="width:100%; height:1000px; float:left; clear:both;"></div>');
		if(structkeyexists(local, 'jumptoanchor')){
			writeoutput('<script type="text/javascript">
			/* <![CDATA[ */
			zArrDeferredFunctions.push(function(){
				setTimeout(function(){
				var d1=document.getElementById("#local.jumptoanchor#");
				var p=zGetAbsPosition(d1);
				window.scrollTo(0, p.y);
				},600);
			});
			/* ]]> */
			</script>');
		}
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
