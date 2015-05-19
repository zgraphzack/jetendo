<!--- 
todo: open source projects
	filesystem indexing requires too much integration with jetendo cms.  this should be in a separate CFC from the rest.
	minify + concat can be made into a function that accepts arrays instead of tight integration with jetendo cms
	compiling and rendering html and txt template files, should be isolated as a separate project.

 --->
<cfcomponent displayname="Skinning Engine" output="no">
<cfoutput>
<cffunction name="onSiteStart" localmode="modern" returntype="any" output="no">
<cfargument name="ss" type="struct" required="yes">
<cfscript>
	if(request.zos.zreset NEQ "site" and structkeyexists(application.sitestruct, arguments.ss.site_id) and structkeyexists(application.sitestruct[arguments.ss.site_id], 'skinObj') and structkeyexists(form, 'zforce') EQ false){
		arguments.ss.skinObj=application.sitestruct[arguments.ss.site_id].skinObj;
		return;
	}
	arguments.ss.skinObj={};
	
	arguments.ss.skinObj.curCompiledVersionNumber=dateformat(request.zos.now,'yyyymmdd')&timeformat(request.zos.now,'HHmmss');
	variables.rebuildCache(arguments.ss.skinObj);
	if(request.zos.zreset NEQ ""){
		local.threadName="zcore_skin_onSiteStart"&request.zos.globals.id&"_"&gettickcount();
		//if(not structkeyexists(application.sitestruct, arguments.ss.site_id) or (request.zos.isdeveloper and structkeyexists(form, 'zforce') and structkeyexists(form, "zdisablethread")) or request.zos.istestserver){
			variables.verifyCache(arguments.ss.skinObj, arguments.ss.site_id);
		/*}else{
			thread action="run" name="#local.threadName#" skinObjArg="#arguments.ss.skinObj#" skinObj="#variables#" site_id="#arguments.ss.site_id#" timeout="300"{
				attributes.skinObj.verifyCache(attributes.skinObjArg, attributes.site_id);
			}
		}*/
	}
	return arguments.ss;
	</cfscript>
</cffunction>

<cffunction name="addDeferredScript" localmode="modern" access="public" output="no">
	<cfargument name="script" type="string" required="yes">
	<cfscript>
	application.zcore.template.appendTag("scripts", '<script type="text/javascript">/* <![CDATA[ */zArrDeferredFunctions.push(function(){#arguments.script# });/* ]]> */</script>');
	</cfscript>
</cffunction>
	
	
<cffunction name="checkCompiledJS" output="no" returntype="any" localmode="modern">
	<cfscript>
	/*if(request.zos.globals.enableInstantLoad EQ 1){
		return false; // This isn't true anymore: history.js doesn't work with closure compiled code.
	}*/
	//request.forceNewJS=true;
	if(not request.zos.isTestServer or structkeyexists(request, 'forceNewJS')){
		if(application.zcore.app.siteHasApp("listing")){
			application.zcore.skin.includeJS("/z/javascript-compiled/jetendo.js");
		}else{
			application.zcore.skin.includeJS("/z/javascript-compiled/jetendo-no-listing.js");
		}
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>
	
<cffunction name="onApplicationStart" localmode="modern" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	if(not structkeyexists(form, 'zforce') and structkeyexists(application, 'zcore') and structkeyexists(application.zcore, 'skinObj') and structkeyexists(application.zcore.skinObj, 'fileStruct')){
		arguments.ss.skinObj=application.zcore.skinObj; 
		return arguments.ss;
	}
	arguments.ss.skinObj=structnew();
	variables.rebuildServerCache(arguments.ss.skinObj);
	//local.threadName="zcore_skin_onApplicationStart"&gettickcount();
	//if(structkeyexists(form, 'zdisablethread') or request.zos.istestserver){
		variables.verifyServerCache(arguments.ss.skinObj);
	/*}else{
		thread action="run" name="#local.threadName#" skinObjArg="#arguments.ss.skinObj#" skinObj="#variables#" timeout="300"{
			attributes.skinObj.verifyServerCache(attributes.skinObjArg);
		}
	}*/
	return arguments.ss;
	</cfscript>
</cffunction>
    
<!--- daily scheduled task 
/z/_com/display/skin?method=deleteOldCache --->
<cffunction name="deleteOldCache" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	var local=structnew();
	var i=0;
	var db=request.zos.queryObject;
	var fs={}
	var q=0;
	var ts=0;
	var ts1=0;
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("This feature requires developer or server access permissions.");
	}
	if(request.zos.isDeveloper and not application.zcore.user.checkAllCompanyAccess()){
		application.zcore.status.setStatus(request.zsid, "Access denied.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	}
	permanentStruct={
		"zsystem.css":true,
		"listing-search-form.js":true,
		"sitemap.xml.gz":true,
		"robots.txt":true,
		"_z.system.mincat.css":true,
		"_z.system.mincat.js":true,
		"zspritemap.jpg":true,
		"zspritemap.png":true
	}
	var validStruct=duplicate(permanentStruct);
	setting requesttimeout="5000";
	// build list of valid file names from the struct in memory
	for(i in application.zcore.skinObj.fileStruct){
		ts=application.zcore.skinObj.fileStruct[i];
		validStruct["#application.zcore.functions.zGetFileName(ts.file_name)#.#ts.file_id#.#ts.file_version_number#.#ts.file_type#"]=true;
	}
	local.arrPath=[];
	local.tempPath=request.zos.globals.serverprivatehomedir&"zcache/";
	directory action="list" directory="#local.tempPath#" name="local.qDir" sort="name desc";
	for(ts in local.qDir){
		if(not structkeyexists(validStruct, ts.name) and left(ts.name, 2) NEQ "_z"){
			//writeoutput("delete: "&local.tempPath&ts.name&"<br>");
			application.zcore.functions.zdeletefile(local.tempPath&ts.name);
		}
	}
	db.sql="select site_id from #db.table("site", request.zos.zcoreDatasource)# 
	where site_active=#db.param(1)# and 
	site_id <> #db.param(1)# and 
	site_deleted = #db.param(0)#";
	q=db.execute("q");
	for(ts1 in q){
		writeoutput("site_id:"&ts1.site_id&"<br>");
		validStruct=duplicate(permanentStruct);
		if(not structkeyexists(application.siteStruct, ts1.site_id) or not structkeyexists(application.siteStruct[ts1.site_id], 'skinObj')) continue;
		for(i in application.siteStruct[ts1.site_id].skinObj.fileStruct){
			ts=application.siteStruct[ts1.site_id].skinObj.fileStruct[i];
			validStruct["#application.zcore.functions.zGetFileName(ts.file_name)#.#ts.file_id#.#ts.file_version_number#.#ts.file_type#"]=true;
		}
		local.tempPath=application.zcore.functions.zvar('privatehomedir', ts1.site_id)&"zcache/";
		directory action="list" directory="#local.tempPath#" name="local.qDir" sort="name desc";
		for(ts in local.qDir){
			if(not structkeyexists(validStruct, ts.name) and left(ts.name, 2) NEQ "_z"){
				//writeoutput("delete: "&local.tempPath&ts.name&"<br>");
				application.zcore.functions.zdeletefile(local.tempPath&ts.name);
			}
		}
	}
	echo('Done.');
	abort;
	</cfscript>
</cffunction>
    
<cffunction name="rebuildCache" localmode="modern" access="private" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qFile=0;
	var ts=0;
	var db=request.zos.queryObject;
	var local=structnew();
	arguments.ss.fileStruct=structnew(); 
	if(directoryexists(request.zos.globals.privateHomedir&"_cache/scripts/skins/") EQ false){
		application.zcore.functions.zcreatedirectory(request.zos.globals.privateHomedir&"_cache/scripts/skins/");	
	} 
	db.sql="select *
	from #db.table("file", request.zos.zcoreDatasource)# file 
	WHERE file.site_id = #db.param(request.zos.globals.id)# and 
	file_deleted = #db.param(0)# ";
	if(request.zos.globals.id EQ request.zos.globals.serverId){
		db.sql&=" and left(file_path, #db.param(3)#) <> #db.param('/z/')# ";
	}
	db.sql&=" GROUP BY file.file_id";
	qFile=db.execute("qFile");
	
	local.absSavePath=request.zos.globals.privatehomedir&"zcache/";
	if(fileexists(local.absSavePath) EQ false){
		application.zcore.functions.zcreatedirectory(local.absSavePath);	
	}
	local.arrDeleteID=[];
	for(ts in qFile){
		if(fileexists(request.zos.globals.homedir&removechars(ts.file_path,1,1))){
			ts.file_modified_datetime=parsedatetime(dateformat(ts.file_modified_datetime,"yyyy-mm-dd")&" "&timeformat(ts.file_modified_datetime,"HH:mm:ss"));
			ts.fileDisplayPath="/zcache/#application.zcore.functions.zGetFileName(ts.file_name)#.#ts.file_id#.#ts.file_version_number#.#ts.file_type#";
			arguments.ss.fileStruct[ts.file_path]=ts;
		}else{
			arrayAppend(local.arrDeleteID, ts.file_id);
		}
	}
	if(arrayLen(local.arrDeleteID)){
		/*
		writedump("rebuildCache");
		writedump(local.arrDeleteId);
		abort;
		*/
		db.sql="delete from #db.table("file", request.zos.zcoreDatasource)# 
		WHERE site_id=#db.param(request.zos.globals.id)# and 
		file_deleted = #db.param(0)# and 
		file_id IN ("&db.trustedSQL("'"&arraytolist(local.arrDeleteID,"','")&"'")&")";
		db.execute("q");
	}
	
	return arguments.ss;
	</cfscript>
</cffunction>
   
   
<cffunction name="rebuildServerCache" localmode="modern" access="private" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qFile=0;
	var ts=0;
	var db=request.zos.queryObject;
	local.arrDeleteID=[];
	arguments.ss.fileStruct=structnew(); 
	db.sql="select *
	from #db.table("file", request.zos.zcoreDatasource)# file 
	WHERE file.site_id =#db.param(Request.zos.globals.serverId)# 
	and left(file_path, #db.param(3)#) = #db.param('/z/')# and 
	file_deleted = #db.param(0)# 
	GROUP BY file.file_id";
	application.zcore.functions.zCreateDirectory(request.zos.globals.serverPrivateHomedir&"zcache/global/");
	qFile=db.execute("qFile");
	for(ts in qFile){
		if(fileexists(request.zos.installPath&"public/"&removechars(ts.file_path,1,3))){
			ts.fileDisplayPath="/z/zcache/global/#application.zcore.functions.zGetFileName(ts.file_name)#.#ts.file_id#.#ts.file_version_number#.#ts.file_type#";
			ts.file_modified_datetime=parsedatetime(dateformat(ts.file_modified_datetime,"yyyy-mm-dd")&" "&timeformat(ts.file_modified_datetime,"HH:mm:ss"));
			arguments.ss.fileStruct[ts.file_path]=ts;
		}else{
			arrayAppend(local.arrDeleteId, ts.file_id);	
		}
	}
	if(arrayLen(local.arrDeleteID)){
		/*
		writedump("rebuildServerCache");
		writedump(local.arrDeleteId);
		abort;
		*/
		db.sql="delete from #db.table("file", request.zos.zcoreDatasource)# 
		WHERE site_id=#db.param(request.zos.globals.serverid)# and 
		file_deleted = #db.param(0)# and 
		file_id IN ("&db.trustedSQL("'"&arraytolist(local.arrDeleteID,"','")&"'")&")";
		db.execute("q");
	} 
	arguments.ss.widgetFunctions=variables.getWidgetFunctions();
	return arguments.ss;
	</cfscript>
</cffunction>

<cffunction name="getWidgetFunctions" localmode="modern" public="private">
	<cfscript>
	ts=structnew();
	ts.zif=application.zcore.functions.zSkinWidget_if;
	ts.zendif=application.zcore.functions.zSkinWidget_endif;
	ts.zelseif=application.zcore.functions.zSkinWidget_elseif;
	ts.zelse=application.zcore.functions.zSkinWidget_else;
	ts.zloop=application.zcore.functions.zSkinWidget_loop;
	ts.zendloop=application.zcore.functions.zSkinWidget_endloop;
	ts.zfor=application.zcore.functions.zSkinWidget_loop;
	ts.zendfor=application.zcore.functions.zSkinWidget_endloop;
	ts.zout=application.zcore.functions.zSkinWidget_out;
	ts.zdump=application.zcore.functions.zSkinWidget_dump;
	return duplicate(ts);
	</cfscript>
</cffunction>
   
<cffunction name="onCodeDeploy" localmode="modern" access="public" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	arguments.ss.widgetFunctions=variables.getWidgetFunctions();
	</cfscript>
</cffunction>
   
<cffunction name="verifyCache" localmode="modern" access="public" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	var ts=0;
	var fileext='';
	var ts9='';
	var rs='';
	var newfileid=0;
	var newfileversionid=0;
	var db=application.zcore.db.newQuery();
	var rootRelativePath=0;
	var i=0;
	var qDir=0;
	var ds=0;
	var fs=0; 
	local.tempHomeDirPath=application.zcore.functions.zGetDomainInstallPath(application.zcore.functions.zvar("shortDomain", arguments.site_id));
	directory name="qDir" directory="#local.tempHomeDirPath#" action="list" recurse="yes" type="file" filter="*js|*css";//,*html
	for(i in arguments.ss.fileStruct){
		arguments.ss.fileStruct[i].processed=false;
	} 
	errorSent=false;
	
	for(ds in qDir){ 
		if(right(ds.name, 3) EQ "css" and right(ds.name, 4) NEQ ".css"){
			continue;
		}else if(right(ds.name, 2) EQ "js" and right(ds.name, 3) NEQ ".js"){
			continue;
		}
		if(ds.directory DOES NOT CONTAIN "/wp-admin" and ds.directory DOES NOT CONTAIN "/wp-includes" and ds.directory DOES NOT CONTAIN "/wp-content" and 
			ds.directory DOES NOT CONTAIN "/published_files" and ds.directory DOES NOT CONTAIN "/tiny_mce"){
			if(structkeyexists(arguments.ss,'newestApplicationDateLastModified') EQ false or datecompare(ds.dateLastModified, arguments.ss.newestApplicationDateLastModified) EQ 1){
				arguments.ss.newestApplicationDateLastModified=ds.dateLastModified;
			}
			rootRelativePath=replace(replace(ds.directory&"/"&ds.name,"\","/","ALL"), local.tempHomeDirPath,"/");
			fileext=application.zcore.functions.zgetfileext(ds.name);
			
			local.compileNow=false;
			local.skinCacheFound=false;
			local.versionNumber=1;
			if(structkeyexists(arguments.ss.fileStruct,rootRelativePath) EQ false){
				local.compileNow=true;
			}else{
				fs=arguments.ss.fileStruct[rootRelativePath];
				local.skinCacheFound=true;
				if(ds.dateLastModified NEQ fs.file_modified_datetime or ds.size NEQ fs.file_size){
					local.versionNumber=fs.file_version_number+local.versionNumber;
					local.compileNow=true;	
				}else{
					if(fileext EQ "html"){
						if(left(rootRelativePath, 7) EQ '/skins/' and not fileexists(request.zos.globals.privatehomedir&"_cache/scripts/skins/#fs.file_id#-#fs.file_version_number#.cfc")){
							local.compileNow=true; 
						}
					}else if(not fileexists(application.zcore.functions.zvar('privatehomedir', arguments.site_id)&"zcache/#application.zcore.functions.zGetFileName(fs.file_name)#.#fs.file_id#.#fs.file_version_number#.#fs.file_type#")){
						local.versionNumber=fs.file_version_number+local.versionNumber;
						local.compileNow=true;
					}
				}
			} 
			if(local.compileNow){
				ts=structnew();
				ts.table="file";
				ts.datasource=request.zos.zcoreDatasource;
				ts.struct=structnew();
				ts.struct.file_modified_datetime=dateformat(ds.dateLastModified,"yyyy-mm-dd")&" "&timeformat(ds.dateLastModified,"HH:mm:ss");
				ts.struct.file_size=ds.size;
				ts.struct.file_type=fileext;
				ts.struct.file_version_number=local.versionNumber;
				ts.struct.file_name=ds.name;
				ts.struct.file_path=rootRelativePath;
				ts.struct.site_id=arguments.site_id;
			}
			if(not local.skinCacheFound){
				ts.struct.file_id=application.zcore.functions.zInsert(ts);
			}else{
				if(local.compileNow){
					ts.struct.file_id=fs.file_id;
					application.zcore.functions.zUpdate(ts);
				}
			}
			if(fileext EQ "html"){
				local.compileNow=false;
			}
			if(local.compileNow and structkeyexists(application, 'zcore') and structkeyexists(application.zcore, 'skinObj')){
				rs=this.compile(ts.struct, arguments.site_id);
				if(not rs.success){
					throw(application.zcore.functions.zvar("domain", arguments.site_id)&"<br />"&arraytolist(rs.arrErrors,"<br />")&"<br />");
				}
				if(rs.success){
					local.tempFileName=application.zcore.functions.zGetFileName(ts.struct.file_name);
					local.tempPath=application.zcore.functions.zGetDomainWritableInstallPath(application.zcore.functions.zvar("shortDomain", arguments.site_id));
					local.absSavePath=local.tempPath&"zcache/#local.tempFileName#.#ts.struct.file_id#.#ts.struct.file_version_number#.#ts.struct.file_type#";
					ts.struct.fileDisplayPath="/zcache/#local.tempFileName#.#ts.struct.file_id#.#ts.struct.file_version_number#.#ts.struct.file_type#";
					if(fileexists(local.absSavePath)){
						application.zcore.functions.zdeletefile(local.absSavePath);
					}
					moved=application.zcore.functions.zrenameFile(rs.tempFilePath, local.absSavePath);
					if(not moved){
						application.zcore.functions.zDeleteFile(rs.tempFilePath);
						savecontent variable="output"{
							writedump(ts);
						}
						throw("Failed to rename #rs.tempFilePath# to #local.absSavePath# Current File Struct: "&output);
					}
					application.zcore.functions.zDeleteFile(rs.tempFilePath);
					if(ts.struct.file_type EQ "html"){
						if(left(ts.struct.file_path, 3) EQ "/z/"){
							local.savePath="zcorecachemapping.scripts.skins.#ts.struct.file_id#-#ts.struct.file_version_number#";
						}else{
							local.savePath=request.zRootSecureCFCPath&"_cache.scripts.skins.#ts.struct.file_id#-#ts.struct.file_version_number#";
						}
						if(left(ts.struct.file_path,15) EQ "/z/skin/"){
							ts.struct.skinCom=application.zcore.functions.zcreateobject("component",local.savePath);	
						}
					}
				}
				arguments.ss.fileStruct[rootRelativePath]=ts.struct;
			}
			
		}
	}
	return arguments.ss;
	</cfscript>
</cffunction>
    
	
<cffunction name="verifyServerCache" localmode="modern" access="private" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var local=structnew();
	var ts=0;
	var fileext='';
	var ts9='';
	var db=application.zcore.db.newQuery();
	var rs='';
	var newfileid=0;
	var newfileversionid=0;
	var rootRelativePath=0;
	var i=0;
	var qDir=0;
	var fs=0;
	var ds=0;
	application.zcore.functions.zCreateDirectory(request.zos.globals.serverPrivateHomedir&"zcache/global/");
	directory name="qDir" directory="#request.zos.installPath#public/" action="list" recurse="yes" type="file" filter="*js|*css";//*html,
	for(ds in qDir){

		if(right(ds.name, 3) EQ "css" and right(ds.name, 4) NEQ ".css"){
			continue;
		}else if(right(ds.name, 2) EQ "js" and right(ds.name, 3) NEQ ".js"){
			continue;
		}
		if(ds.directory DOES NOT CONTAIN "/tiny_mce"){
			if(structkeyexists(arguments.ss,'newestServerDateLastModified') EQ false or datecompare(ds.dateLastModified, arguments.ss.newestServerDateLastModified) EQ 1){
				arguments.ss.newestServerDateLastModified=ds.dateLastModified;
			}
			rootRelativePath="/z"&replace(replace(ds.directory&"/"&ds.name,"\","/","ALL"),"#request.zos.installPath#public/","/");
			
			fileext=application.zcore.functions.zgetfileext(ds.name);
			local.compileNow=false;
			local.skinCacheFound=false;
			local.versionNumber=1;
			if(structkeyexists(arguments.ss.fileStruct,rootRelativePath) EQ false){ 
				local.compileNow=true;  
			}else{
				fs=arguments.ss.fileStruct[rootRelativePath];
				local.skinCacheFound=true;
				if(ds.dateLastModified NEQ fs.file_modified_datetime or ds.size NEQ fs.file_size){
					/*local.versionNumber=fs.file_version_number+local.versionNumber;
					writedump(rootRelativePath&": "&ds.dateLastModified&" NEQ "&fs.file_modified_datetime&" or "&ds.size&" NEQ "&fs.file_size&"<br>");
					abort;*/
					local.compileNow=true;	 
					local.versionNumber=fs.file_version_number+local.versionNumber; 
				}else{
					if(fs.file_type EQ "html"){
						if(left(rootRelativePath, 16) EQ '/z/skins/' and not fileexists(request.zos.globals.serverprivatehomedir&"_cache/scripts/skins/#fs.file_id#-#fs.file_version_number#.cfc")){
							local.versionNumber=fs.file_version_number+local.versionNumber; 
							local.compileNow=true; 
						}
					}else if(not fileexists(request.zos.globals.serverprivatehomedir&"zcache/global/#application.zcore.functions.zGetFileName(fs.file_name)#.#fs.file_id#.#fs.file_version_number#.#fs.file_type#")){
						/*writedump(rootRelativePath&": "&ds.dateLastModified&" NEQ "&fs.file_modified_datetime&" or "&ds.size&" NEQ "&fs.file_size&"<br>");
						abort;*/
						local.compileNow=true; 
					}	
				}
			}
			if(fileext EQ "html"){
				local.compileNow=false;
			}
			if(local.compileNow){ 
				ts=structnew();
				ts.table="file";
				ts.datasource=request.zos.zcoreDatasource;
				ts.struct=structnew();
				ts.struct.file_modified_datetime=dateformat(ds.dateLastModified,"yyyy-mm-dd")&" "&timeformat(ds.dateLastModified,"HH:mm:ss");
				ts.struct.file_size=ds.size;
				ts.struct.file_type=fileext;
				ts.struct.file_version_number=local.versionNumber;
				ts.struct.file_name=ds.name;
				ts.struct.file_path=rootRelativePath;
				ts.struct.site_id=request.zos.globals.serverid;
			}
			if(not local.skinCacheFound){
				ts.struct.file_id=application.zcore.functions.zInsert(ts);
			}else{
				if(local.compileNow){
					ts.struct.file_id=fs.file_id;
					application.zcore.functions.zUpdate(ts);
				}
			} 
			if(local.compileNow and structkeyexists(application, 'zcore') and structkeyexists(application.zcore, 'skinObj')){
				
				rs=this.compile(ts.struct, request.zos.globals.serverid);
				if(not rs.success){
					application.zcore.functions.zError("server domain:<br />"&arrayToList(rs.arrErrors)&"<br />");
				}
				if(rs.success){
					local.tempFileName=application.zcore.functions.zGetFileName(ts.struct.file_name);
					local.absSavePath=request.zos.globals.serverPrivateHomedir&"zcache/global/#local.tempFileName#.#ts.struct.file_id#.#ts.struct.file_version_number#.#ts.struct.file_type#";
					ts.struct.fileDisplayPath="/z/zcache/global/#local.tempFileName#.#ts.struct.file_id#.#ts.struct.file_version_number#.#ts.struct.file_type#";
					if(fileexists(local.absSavePath)){
						application.zcore.functions.zdeletefile(local.absSavePath);
					}
					moved=application.zcore.functions.zrenameFile(rs.tempFilePath, local.absSavePath);
					if(not moved){
						application.zcore.functions.zDeleteFile(rs.tempFilePath);
						savecontent variable="output"{
							writedump(ts);
						}
						throw("Failed to rename #rs.tempFilePath# to #local.absSavePath# Current File Struct: "&output);
					}
					if(ts.struct.file_type EQ "html"){
						if(left(ts.struct.file_path, 3) EQ "/z/"){
							local.savePath="zcorecachemapping.scripts.skins.#ts.struct.file_id#-#ts.struct.file_version_number#";
						}else{
							local.savePath=request.zRootSecureCFCPath&"_cache.scripts.skins.#ts.struct.file_id#-#ts.struct.file_version_number#";
						}
						if(left(ts.struct.file_path,15) EQ "/z/skin/"){
							ts.struct.skinCom=application.zcore.functions.zcreateobject("component",local.savePath);	
						}
					}
				}
				arguments.ss.fileStruct[rootRelativePath]=ts.struct;
			}
			
		}
	} 
	return arguments.ss;
	</cfscript>
</cffunction>
    
<cffunction name="getFile" localmode="modern" access="public" output="no" returntype="any">
	<cfargument name="file_path" type="string" required="yes">
	<cfscript>
	var tempFilePath="";
	if(left(arguments.file_path, 3) EQ "/z/"){
		tempFilePath="/z/"&removechars(arguments.file_path, 1,3);
		if(structkeyexists(application.zcore.skinObj.fileStruct, tempFilePath)){
			return application.zcore.skinObj.fileStruct[tempFilePath];
		}else{
			this.verifyServerCache(application.zcore.skinObj);
			if(structkeyexists(application.zcore.skinObj.fileStruct, tempFilePath) EQ false){
				application.zcore.functions.zError("skin.cfc getFile() | Invalid file_path, #tempFilePath#");
			}else{
				return application.zcore.skinObj.fileStruct[tempFilePath];
			}
		}
	}else{
		if(structkeyexists(application.sitestruct[request.zos.globals.id].skinObj.fileStruct, arguments.file_path)){
			return application.sitestruct[request.zos.globals.id].skinObj.fileStruct[arguments.file_path];
		}else{
			this.verifyCache(application.sitestruct[request.zos.globals.id].skinObj);
			if(structkeyexists(application.sitestruct[request.zos.globals.id].skinObj.fileStruct, arguments.file_path) EQ false){
				application.zcore.functions.zError("skin.cfc getFile() | Invalid file_path, #arguments.file_path#");
			}else{
				return application.sitestruct[request.zos.globals.id].skinObj.fileStruct[arguments.file_path];
			}
		}
	}
	</cfscript>
</cffunction>
    
	
<cffunction name="compile" localmode="modern" access="private" output="no" returntype="struct">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	var local=structnew(); 
	var rs={
		success:true,
		arrErrors:[],
		tempFilePath:""
	};
	if(left(arguments.ss.file_path,3) EQ "/z/"){
		rs.tempFilePath=request.zos.globals.serverPrivateHomeDir&"zcache/global/_tempFile"&gettickcount('nano')&"_"&randrange(1,9999);
	}else{
		rs.tempFilePath=request.zos.globals.privateHomeDir&"zcache/_tempFile"&gettickcount('nano')&"_"&randrange(1,9999);
	}
	if(arguments.ss.file_type EQ "html" and left(arguments.ss.file_path,15) EQ "/z/skin/"){
		this.compileHTML(arguments.ss);
	}else if(arguments.ss.file_type EQ "js" or arguments.ss.file_type EQ "css"){
		if(left(arguments.ss.file_path,3) EQ "/z/"){
			local.curTempPath=request.zos.installPath&"public/"&removechars(arguments.ss.file_path,1,3);
		}else{
			local.curTempPath=application.zcore.functions.zGetDomainInstallPath(application.zcore.functions.zvar("shortDomain", arguments.site_id))&removechars(arguments.ss.file_path,1,1);
		}
		if(fileexists(local.curTempPath)){
			/*if(request.zos.isExecuteEnabled){
				// use google closure compiler here instead
				local.out=trim(application.zcore.functions.zexecute('/var/jetendo-server/railo/jdk/jre/bin/java','-jar #request.zos.installPath#public/javascript/yuicompressor-2.4.6.jar "#local.curTempPath#" -o "#rs.tempFilePath#" --charset utf-8', 5));
				if(local.out EQ "false" or local.out NEQ ""){
					arrayappend(rs.arrErrors,"Failed to run yuicompressor on: "&rs.tempFilePath&'<br />command:'&'/var/jetendo-server/railo/jdk/jre/bin/java -jar #request.zos.installPath#public/javascript/yuicompressor-2.4.6.jar "#local.curTempPath#" -o "#rs.tempFilePath#" --charset utf-8<br /><br />result:'&local.out);
					application.zcore.functions.zDeleteFile(rs.tempFilePath);
					rs.success=false;
					return rs;
				}
			}else{*/
				local.out=application.zcore.functions.zreadfile(local.curTempPath); 
				application.zcore.functions.zwritefile(rs.tempFilePath, local.out); 	
			//}
		}else{ 
			arrayappend(rs.arrErrors,"Failed to run yuicompressor because file is missing: #arguments.ss.file_path#<br /><br />#local.curTempPath#");
			rs.success=false;
			return rs;
		}
	}
	return rs;
	</cfscript>
</cffunction>
    
<cffunction name="checkGlobalHeadCodeForUpdate" localmode="modern" access="public">
	<cfscript>
	
	local.d=application.zcore.functions.zvarso("Global HTML Head Source Code");
	newHash=hash(local.d);
	if(not structkeyexists(application.sitestruct[request.zos.globals.id],'globalHTMLHeadSourceArrCSS') or application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceMD5 NEQ newHash){
		local.tempArrCSS=arraynew(1);
		local.tempArrJS=arraynew(1);
		if(local.d NEQ ""){
			local.v2=rematchnocase('<script [^>]*src="[^"]*"[^>]*>[^>]*</script>', local.d);
			for(local.i=1;local.i LTE arraylen(local.v2);local.i++){
				local.v22=refindnocase('src="([^"]*)"', local.v2[local.i], 1, true);
				local.n=mid(local.v2[local.i], local.v22.pos[2], local.v22.len[2]);
				if(left(local.n, 7) EQ "http://"){
					local.n=replace(local.n,"http://","//");
				}else if(left(local.n, 7) EQ "https://"){
					local.n=replace(local.n,"https://","//");
				} 
				arrayappend(local.temparrJS, local.n);
				if(local.debug) writeoutput('from global html varso:'&local.n&'<br />');
			}
			local.d=rereplacenocase(local.d,'<script [^>]*src="[^"]*"[^>]*>[^>]*</script>', '', 'all');
			local.v3=rematchnocase('<link [^>]*href="[^"]*"[^>]*/>',local.d);
			arrNonStylesheet=[];
			for(local.i=1;local.i LTE arraylen(local.v3);local.i++){
				if(find('rel="stylesheet"', local.v3[local.i]) EQ 0 and find("rel='stylesheet'", local.v3[local.i]) EQ 0 and find('rel=stylesheet', local.v3[local.i]) EQ 0){
					arrayAppend(arrNonStylesheet, local.v3[local.i]);
					continue;
				}
				local.v22=refindnocase('href="([^"]*)"', local.v3[local.i], 1, true);
				local.n=mid(v3[local.i], local.v22.pos[2], local.v22.len[2]);
				if(left(local.n, 7) EQ "http://"){
					local.n=replace(local.n,"http://","//");
				}else if(left(local.n, 7) EQ "https://"){
					local.n=replace(local.n,"https://","//");
				} 
				arrayappend(local.temparrCSS, local.n);
				if(local.debug) writeoutput('from global html varso:'&local.n&'<br />');
			}
			local.d=trim(rereplacenocase(local.d,'<link [^>]*href="[^"]*"[^>]*/>', '', 'all'))&arrayToList(arrNonStylesheet, chr(10));
		}
		application.sitestruct[request.zos.globals.id].globalHTMLHeadSource=local.d;
		application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceMD5=newHash;
		application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceArrCSS=local.tempArrCSS;
		application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceArrJS=local.tempArrJS;
	}

	</cfscript>
</cffunction>

<cffunction name="compilePackage" localmode="modern" access="public" output="yes" returntype="any">
	<cfscript>
	var local=structnew();
	var newHash=0;
	var start3=gettickcount();
	local.debug=false;
	if((request.zos.isDeveloper or request.zos.isTestServer) and structkeyexists(form, 'debugSkinCompile')){
		local.debug=true;
	}
		
	if(local.debug){
		writeoutput("request.zos.globals.enableMinCat:"&request.zos.globals.enableMinCat&"<br />");
	}
	if(request.zos.globals.enableMinCat EQ 0){
		return;
	}
	local.tempPath=request.zos.globals.privatehomedir&"zcache/_z.system.mincat.js";
	if(not structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, local.tempPath)){
		application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath]=fileexists(local.tempPath);
	}
	if(application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath]){
		local.fileObj=application.zcore.functions.zGetFileAttrib(request.zos.globals.privatehomedir&"zcache/_z.system.mincat.js");
	}else{
		local.fileObj=structnew();	
		local.fileObj.size=0;
		local.fileObj.dateLastModified=now();
	}
		
	if(local.debug){
		writeoutput(((gettickcount()-start3)/1000)&' seconds1<br />');
		start3=gettickcount();
	}
	if(structkeyexists(form, 'zforce') EQ false and 
	local.fileObj.size NEQ 0 and 
	structkeyexists(application.sitestruct[request.zos.globals.id].skinObj,'newestApplicationDateLastModified') and 
	structkeyexists(application.zcore.skinObj,'newestServerDateLastModified') and 
	(datecompare(local.fileObj.dateLastModified, application.zcore.skinObj.newestServerDateLastModified) GTE 0 and 
	datecompare(local.fileObj.dateLastModified, application.sitestruct[request.zos.globals.id].skinObj.newestApplicationDateLastModified) GTE 0)){
		application.sitestruct[request.zos.globals.id].skinObj.curCompiledVersionNumber=dateformat(local.fileObj.dateLastModified,'yyyymmdd')&timeformat(local.fileObj.dateLastModified,'HHmmss');
		
		
	}else{
		local.ts=structnew();
		local.ts.js=arraynew(1);
		local.ts.css=arraynew(1);
		local.cssOut="";
		local.jsOut="";
		
		application.zcore.app.getCSSJSIncludes(local.ts);
		
		if(local.debug){
			writeoutput(((gettickcount()-start3)/1000)&' seconds2 - after getCSSJSIncludes<br />');
			start3=gettickcount();
		}
		for(local.i=1;local.i LTE arraylen(application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceArrCSS);local.i++){
			arrayappend(local.ts.css, application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceArrCSS[local.i]);
		}
		for(local.i=1;local.i LTE arraylen(application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceArrJS);local.i++){
			arrayappend(local.ts.js, application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceArrJS[local.i]);
		}
		if(local.debug){
			writedump(local.ts);
		}
		for(local.i=1;local.i LTE arraylen(local.ts.css);local.i++){
			c=local.ts.css[local.i];
			if(left(c,3) EQ "/z/"){
				filePath=request.zos.installPath&"public/"&removechars(c,1,3);
			}else if(left(local.c,8) EQ "/zthemes/"){
				filePath=request.zos.installPath&"themes/"&removechars(c,1,8);
			}else{
				filePath=request.zos.globals.homedir&removechars(c,1,1);
			}
			fileContents=application.zcore.functions.zreadfile(filePath);
			local.cssOut&="@@z@@"&filePath&"~"&c&"@"&chr(10)&fileContents&chr(10);
		}
				/*
		for(local.i=1;local.i LTE arraylen(local.ts.css);local.i++){
			local.c=local.ts.css[local.i];
			if(left(local.c,3) EQ "/z/"){
				local.checkPath=local.c;
				if(structkeyexists(application.zcore.skinObj.fileStruct, local.checkPath)){
					local.d2=application.zcore.functions.zreadfile(request.zos.installPath&"public/"&removechars(local.checkPath,1,3));
					if(local.debug) writeoutput("css path1:"&request.zos.installPath&"public/"&removechars(local.checkPath,1,3)&'<br />');//local.d2&'<br />');
					if(local.d2 EQ false){
						if(local.debug) writeoutput('fail<br /><br />');
					}
					local.cssOut&="@@z@@"&local.c&"@"&chr(10)&local.d2&chr(10);
				}else{
					local.d2=application.zcore.functions.zreadfile(request.zos.installPath&"public/"&removechars(local.checkPath,1,3));
					if(local.debug) writeoutput("css direct:"&request.zos.installPath&"public/"&removechars(local.checkPath,1,3)&'<br />');
					if(local.d2 EQ false){
						if(local.debug) writeoutput('fail<br /><br />');
					}
					local.cssOut&=local.d2;
				}
			}else{
				local.checkPath=local.c;
				if(structkeyexists(application.sitestruct[request.zos.globals.id].skinObj.fileStruct, local.checkPath)){
					local.d2=application.zcore.functions.zreadfile(request.zos.globals.homedir&removechars(local.checkPath,1,1));
					if(local.debug) writeoutput("css path2:"&request.zos.globals.homedir&removechars(local.checkPath,1,1)&'<br />');//local.d2&'<br />');
					if(local.d2 EQ false){
						if(local.debug) writeoutput('fail<br /><br />');
					}
					local.cssOut&="@@z@@"&local.c&"@"&chr(10)&local.d2&chr(10);
				}else{
					local.d2=application.zcore.functions.zreadfile(request.zos.globals.homedir&removechars(local.checkPath,1,1));
					if(local.debug) writeoutput("js direct:"&request.zos.globals.homedir&removechars(local.checkPath,1,1)&'<br />');
					if(local.d2 EQ false){
						if(local.debug) writeoutput('fail<br /><br />');
					}
					local.cssOut&=local.d2;
				}
			}
		}
		*/
		if(local.debug){
			writeoutput(((gettickcount()-start3)/1000)&' seconds3 after read &amp; concat css<br />');
			start3=gettickcount();
		}
		for(local.i=1;local.i LTE arraylen(local.ts.js);local.i++){
			local.c=local.ts.js[local.i];
			if(left(local.c,3) EQ "/z/"){
				local.checkPath=local.c; 
				if(structkeyexists(application.zcore.skinObj.fileStruct, local.checkPath)){
					if(local.debug) writeoutput("js fileDisplayPath:"&request.zos.globals.serverprivateHomedir&"_cache/"&removechars(application.zcore.skinObj.fileStruct[local.checkPath].fileDisplayPath,1,3)&'<br />');
					local.d2=application.zcore.functions.zreadfile(request.zos.globals.serverprivateHomedir&"_cache/"&removechars(application.zcore.skinObj.fileStruct[local.checkPath].fileDisplayPath,1,3));
					if(local.d2 EQ false){
						if(local.debug) writeoutput('fail<br /><br />');
					}
					local.jsOut&=local.d2;
				}else{
					local.d2=application.zcore.functions.zreadfile(request.zos.installPath&"public/"&removechars(local.checkPath,1,3));
					if(local.debug) writeoutput("js direct:"&request.zos.installPath&"public/"&removechars(local.checkPath,1,3)&'<br />');
					if(local.d2 EQ false){
						if(local.debug) writeoutput('fail<br /><br />');
					}
					local.jsOut&=local.d2;
				}
			}else{
				local.checkPath=local.c;
				if(structkeyexists(application.sitestruct[request.zos.globals.id].skinObj.fileStruct, local.checkPath)){
					if(local.debug) writeoutput("js fileDisplayPath:"&request.zos.globals.privatehomedir&"_cache/"&removechars(application.sitestruct[request.zos.globals.id].skinObj.fileStruct[local.checkPath].fileDisplayPath,1,1)&'<br />');
					local.d2=application.zcore.functions.zreadfile(request.zos.globals.privatehomedir&"_cache/"&removechars(application.sitestruct[request.zos.globals.id].skinObj.fileStruct[local.checkPath].fileDisplayPath,1,1));
					if(local.d2 EQ false){
						if(local.debug) writeoutput('fail<br /><br />');
					}
					local.jsOut&=local.d2;
				}else{
					local.d2=application.zcore.functions.zreadfile(request.zos.globals.homedir&removechars(local.checkPath,1,1));
					if(local.debug) writeoutput("js direct:"&request.zos.globals.homedir&removechars(local.checkPath,1,1)&'<br />');
					if(local.d2 EQ false){
						if(local.debug) writeoutput('fail<br /><br />');
					}
					local.jsOut&=local.d2;
				}
			}
		}
		
		if(local.debug){
			writeoutput(((gettickcount()-start3)/1000)&' seconds4 after read &amp; concat js<br />');
			start3=gettickcount();
		}
		local.dt=dateformat(now(),'yyyymmdd')&'.'&timeformat(now(),'HHmmss');
		if(local.debug){
			startTime=gettickcount();
		}
		cssSpriteMap=application.zcore.functions.zcreateobject("component", "cssSpriteMap");
		cssSpriteMap.init({
			charset:"utf-8", // the charset used to read and write CSS files
			spritePad:1, // the number of pixels between each image in the sprite image. At least 1 pixel is recommended for best browser rendering compatibility.
			disableMinify: false, // Set disableMinify to true to output CSS with perfect indenting and line breaks
			aliasStruct:{
				"/":request.zos.globals.homedir,
				// if you normal server files from a web server alias directory like this in nginx:
				// location /cssSpriteMapAlias { alias /path/to/cssSpriteMap-dot-cfc/example/alias; }
				// cssSpriteMap-dot-cfc can process the alias folder if you specify any additional folders to use when evaluating the absolute path of a file.
				// This even works when the web server alias doesn't exist, so we have a fake alias setup in the example by default
				"/zupload/":request.zos.globals.privatehomedir&"zupload/",
				"/z/":request.zos.installPath&"public/"
			},
			jpegFilePath:request.zos.globals.privatehomedir&"zcache/zspritemap.jpg", // the absolute path to the JPEG sprite image that will be output
			pngFilePath:request.zos.globals.privatehomedir&"zcache/zspritemap.png", // the absolute path to the PNG sprite image that will be output. i.e. /absolute/path/to/cssSpriteMap.jpg
			jpegRootRelativePath:"/zcache/zv#randrange(199999,999999)#/zspritemap.jpg", // the root relative path to the JPEG sprite image that will be output. i.e. /path/to/cssSpriteMap.jpg
			pngRootRelativePath:"/zcache/zv#randrange(199999,999999)#/zspritemap.png", // the root relative path to the PNG sprite image that will be output. i.e. /path/to/cssSpriteMap.jpg
			disableSpriteMap:false, // disable the sprite map feature and only concatenate and minify the CSS
			root:request.zos.globals.homedir // specify the root directory for the current web server virtual host
		
		});
		
		destinationFile=request.zos.globals.privatehomedir&"zcache/_z.system.mincat.css";
		cssSpriteMap.setCSSRoot(request.zos.globals.homedir, "/");
		rs=cssSpriteMap.convertAndReturnCSS(local.cssOut);
		cssSpriteMap.saveCSS(destinationFile, rs.css);
		
		if(local.debug){
			writeoutput(((gettickcount()-startTime)/1000)&' seconds<br>');
			cssSpriteMap.displayCSS(rs.arrCSS, rs.cssStruct);
		}
		if(local.debug){
			writeoutput(((gettickcount()-start3)/1000)&' seconds5 after spritemapper<br />');
			start3=gettickcount();
		}
		local.cd=application.zcore.functions.zGetFileAttrib(destinationFile).dateLastModified;
		
		if(local.debug){
			writeoutput(((gettickcount()-start3)/1000)&' seconds6 after final write<br />');
			start3=gettickcount();
		}
		application.sitestruct[request.zos.globals.id].skinObj.curCompiledVersionNumber=dateformat(local.cd,'yyyymmdd')&timeformat(local.cd,'HHmmss');
		if(local.debug){
			application.zcore.functions.zabort();
		}
	}
	</cfscript>
</cffunction>


<!--- application.zcore.skin.includeSkin("/skins/template/default.html"); --->
<cffunction name="includeSkin" localmode="modern" access="public" output="no" returntype="any">
	<cfargument name="file_path" type="string" required="yes">
	<cfargument name="viewdata" type="struct" required="no" default="#structnew()#">
	<cfargument name="rerun" type="boolean" required="no" default="#false#">
	<cfscript>
	var zSkinHTMLContents99="";
	var sa=false;
	var e=0;
	var cfcatch=0;
	if(left(arguments.file_path,3) EQ "/z/"){
		sa=true;
	}
	if(arguments.rerun){
		if(sa){
			variables.verifyServerCache(application.zcore.skinObj);	
		}else{
			this.verifyCache(application.sitestruct[request.zos.globals.id].skinObj);
		}
	}
	request.zos.tempObj.viewData=arguments.viewdata;
	if(sa and structkeyexists(application.zcore.skinObj.fileStruct,arguments.file_path)){
		try{
			savecontent variable="zSkinHTMLContents99"{
				writeoutput(application.zcore.skinObj.fileStruct[arguments.file_path].skinCom.render(arguments.viewdata));
			}
		}catch(Any e){
			application.zcore.functions.zErrorMetaData("application.zcore.skin.includeSkin("""&arguments.file_path&"""); generated this error.<br /><br />#e.Message#<br /><br />It is easy to get confused about which file to work on since the skin system compiles your skin to a different file name.<br /><br />Make sure you fix the error in this file: "&arguments.file_path);
			rethrow;
		}
		return zSkinHTMLContents99;
	}else if(structkeyexists(application.sitestruct[request.zos.globals.id].skinObj.fileStruct,arguments.file_path)){
		try{
			savecontent variable="zSkinHTMLContents99"{
				writeoutput(application.sitestruct[request.zos.globals.id].skinObj.fileStruct[arguments.file_path].skinCom.render());
			}
		}catch(Any e){
			application.zcore.functions.zErrorMetaData("application.zcore.skin.includeSkin("""&arguments.file_path&"""); generated this error.<br /><br />#e.Message#<br /><br />It is easy to get confused about which file to work on since the skin system compiles your skin to a different file name.<br /><br />Make sure you fix the error in this file: "&arguments.file_path);
			rethrow;
		}
		return zSkinHTMLContents99;
	}else{
		if(arguments.rerun){
			application.zcore.functions.zError("application.zcore.skin.includeSkin() Failed: file_path, ""#arguments.file_path#"" doesn't exist.  Check your spelling or append ?zreset=application to the current url to rebuild the skin cache and try again.");
		}else{
			this.includeSkin(arguments.file_path, arguments.viewdata, true);	
		}
	}
	</cfscript>
</cffunction>


<cffunction name="compileHTML" localmode="modern" access="private" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var local=structnew();
	if(left(arguments.ss.file_path,3) EQ "/z/"){
		local.absPath=replace(arguments.ss.file_path,"/z/",request.zos.installPath&"public/","one");
	}else{
		local.absPath=replace(arguments.ss.file_path,"/",request.zos.globals.homeDir,"one");
	}
	//writeoutput('<hr>'&local.absPath&'<br />');
	//writeoutput("compiling: "&arguments.ss.file_path&"<br />");
	local.theHTML=application.zcore.functions.zreadfile(local.absPath);//arguments.ss.file_version_data;
	if(isBoolean(local.theHTML)){
		return {success:false, error: "local.absPath, ""#local.absPath#"", doesn't exist."};
	}
	//request.zos.tempObj.viewData=arguments.viewData;
	application.zcore.functions.zHTMLSetupGlobals();
	local.ts=structnew();
	local.ts.theHTML=local.theHTML;
	local.ts.allowColdfusion=false;
	local.rs=application.zcore.functions.zParseHTMLIntoArray(local.ts);
	//writedump(local.rs);
	//writeoutput("c1<br />");
	if(local.rs.success EQ false){
		writeoutput(local.rs.error);
		application.zcore.functions.zabort();
		//application.zcore.functions.zdump(local.rs);
		//writeoutput("c2<br />");
	}else{
		
		//writeoutput("c3<br />");
		//application.zcore.functions.zdump(local.rs);
		local.rs.arrHTML=application.zcore.functions.zHtmlRemoveServerSideScriptsFromArray(local.rs.arrHTML,true);
		
		//writeoutput("c4<br />");
		//application.zcore.functions.zdump(local.rs.arrHTML);
		local.rs=application.zcore.functions.zAnalyzeXHTMLNestingFromArray(local.rs.arrHTML);
		//writeoutput("c5<br />");
		//application.zcore.functions.zdump(local.rs);
		if(local.rs.success EQ false){
			for(local.i=1;local.i LTE arraylen(local.rs.arrErrorMessage);local.i++){
				writeoutput(local.rs.arrErrorMessage[local.i]&'<br />');
			}
			writeoutput('<h3>Error Output</h3>'&'<textarea name="c49" style="width:700px; height:300px; ">'&htmleditformat(local.theHTML)&'</textarea>');
			//application.zcore.functions.zdump(local.rs);
			application.zcore.functions.zabort();
		}else{
		
			//writeoutput("c6<br />");
			//application.zcore.functions.zdump(local.rs);
			//local.xmlDoc=application.zcore.functions.zHTMLArrayToXMLObject(local.rs.arrHTML);
			//application.zcore.functions.zdump(local.xmlDoc);
			local.ts=structnew();
			local.ts.arrHTML=local.rs.arrHTML;
			local.ts.enableIndenting=true;
			local.ts.enableXHTMLStrictOutput=true;
			local.ts.enableUTF8=true;
			local.ts.html5=true;
			//application.zcore.functions.zdump(local.ts);
			local.rs=application.zcore.functions.zRebuildXHTMLFromArray(local.ts);
			//writeoutput("rebuilt html:<br />");
			//application.zcore.functions.zdump(local.rs);
			if(local.rs.success EQ false){
				writeoutput("ERROR on line ###rs.line#: "&local.rs.error&'<br />');
				writeoutput(application.zcore.functions.zGetLineFromVariable(local.theHTML, local.rs.line));
				application.zcore.functions.zabort();
			}else{
				local.rs=application.zcore.functions.zSkinProcessVars(local.rs.result);
				if(local.rs.success EQ false){
					writeoutput("ERROR on line ###rs.line#: "&local.rs.error&'<br />');
					writeoutput(application.zcore.functions.zGetLineFromVariable(local.theHTML, local.rs.line));
					application.zcore.functions.zabort();
				}else{
					if(left(arguments.ss.file_path,3) EQ "/z/"){
						local.savePath=  "zcorecachemapping.scripts.skins.#arguments.ss.file_id#-#arguments.ss.file_version_number#";
						local.absSavePath=  request.zos.globals.serverPrivateHomedir&"_cache/scripts/skins/#arguments.ss.file_id#-#arguments.ss.file_version_number#.cfc";
					}else{
						local.savePath="zcorecachemapping.scripts.skins.#arguments.ss.file_id#-#arguments.ss.file_version_number#";
						local.absSavePath=request.zos.globals.serverPrivateHomedir&"_cache/scripts/skins/#arguments.ss.file_id#-#arguments.ss.file_version_number#.cfc";
					}
					//writeoutput('<h3>Compiled</h3>'&'<textarea name="c49" style="width:700px; height:300px; ">'&htmleditformat(rs.result)&'</textarea>');//<br /><br />'&rs.result);
					application.zcore.functions.zwritefile(local.absSavePath, '<cfcomponent output="no">
					<cffunction name="render" localmode="modern" output="yes" access="public" returntype="any">
						<cfargument name="viewdata" type="struct" required="yes">
						'&local.rs.result&'
					</cffunction>
					</cfcomponent>');
					/*
					<cfscript>
					page=structnew();
					page.date=now();
					news=now();
					blog=structnew();
					author="Auth";
					blog.author="Author";
					blog.authordate=now();
					blog.authorlink="Test link";
					</cfscript>*/
					//local.r=application.zcore.functions.zreadfile(local.savePath);//"ram://tempCompiledSkin.cfc");
					//writeoutput(htmleditformat(local.r));
					//writeoutput('<h3>Compiled</h3>'&'<textarea name="c49" style="width:700px; height:300px; ">'&htmleditformat(local.r)&'</textarea><br /><br /><hr /><h3>Rendered</h3>');
					arguments.ss.skinCom=application.zcore.functions.zcreateobject("component", local.savePath);//"inmemory.tempCompiledSkin");
					//local.c.render();
				}
			}
		}
	}
	return arguments.ss;
	</cfscript>
</cffunction>

<cffunction name="includeCSSPackage" localmode="modern" access="public" output="no" returntype="any">
<cfargument name="file_path" type="string" required="yes">
	<cfargument name="forcePosition" required="no" type="string" default="" hint="This can be set to first or last.">
	<cfargument name="package" type="string" required="no" default="" hint="Allow minification and concatenation of multiple stylesheet files">
	<cfscript>
	var ts=structnew();
	if(left(arguments.file_path,2) EQ "//" or left(arguments.file_path,1) NEQ "/"){
		application.zcore.functions.zError("skin.cfc includeCSSPackage() - file_path must be a root relative url, such as /stylesheets/style.css");
	}
	ts.type="";
	ts.url=arguments.file_path;
	ts.forcePosition=arguments.forcePosition;
	ts.package=arguments.package;
	arrayappend(request.zos.arrCSSIncludes, ts);
	</cfscript>
</cffunction>

<cffunction name="includeJSPackage" localmode="modern" access="public" output="no" returntype="any">
<cfargument name="file_path" type="string" required="yes">
	<cfargument name="forcePosition" required="no" type="string" default="" hint="This can be set to first or last.">
	<cfargument name="package" type="string" required="no" default="" hint="Allow minification and concatenation of multiple stylesheet files">
	<cfscript>
	var ts=structnew();
	if(left(arguments.file_path,2) EQ "//" or left(arguments.file_path,1) NEQ "/"){
		application.zcore.functions.zError("skin.cfc includeJSPackage() - file_path must be a root relative url, such as /scripts/cc.js");
	}
	ts.type="";
	ts.url=arguments.file_path;
	ts.forcePosition=arguments.forcePosition;
	ts.package=arguments.package;
	arrayappend(request.zos.arrJSIncludes, ts);
	</cfscript>

</cffunction>

<cffunction name="disableMinCat" localmode="modern" access="public" output="no" returntype="any">
	<cfscript>
	request.zos.tempObj.disableMinCat=true;
	</cfscript>
</cffunction>

<!--- application.zcore.skin.includeCSS("/skins/css/style.css"); --->
<cffunction name="includeCSS" localmode="modern" access="public" output="no" returntype="any">
	<cfargument name="file_path" type="string" required="yes">
	<cfargument name="forcePosition" required="no" type="string" default="" hint="This can be set to first or last or empty string.">
	<cfscript>
	var zSkinHTMLContents99="";
	var sa=false;
	var s="";
	var forceFirst=false;
	var templateTagName="stylesheets";
	var templateTagFunction="prependTag";
	var checkPath=arguments.file_path;
	var zS=application.zcore.skinObj.fileStruct;
	var aS1=application.sitestruct[request.zos.globals.id].skinObj.fileStruct;
	if(left(arguments.file_path,3) EQ "/z/"){
		sa=true;
	}
	if(structkeyexists(request.zos.cssIncludeUniqueStruct, checkPath)){
		return "";
		//throw("arguments.file_path, ""#checkPath#"", was already included.");
	}
	request.zos.cssIncludeUniqueStruct[checkPath]=true;
	if(arguments.forcePosition EQ "first"){
		forceFirst=true;
	}else if(arguments.forcePosition EQ "last"){
		templateTagFunction="prependTag";
		templateTagName="meta";
	}
	if(left(arguments.file_path,2) EQ "//"){
		s='<link rel="stylesheet" type="text/css" href="#arguments.file_path#" />';
		application.zcore.template[templateTagFunction](templateTagName, s&chr(10), forceFirst);
		return "";
	}
	if(right(arguments.file_path,4) NEQ ".css"){
		application.zcore.functions.zError("application.zcore.skin.includeCSS() Failed: file_path, ""#arguments.file_path#"" is not a stylesheet file ending with .css.  Correct your spelling.");
	}
	randomVersion="";
	if(request.zos.isTestServer){
	//	randomVersion=gettickcount();
	}
	if(sa and structkeyexists(zS, checkPath)){
		s='<link rel="stylesheet" type="text/css" href="#request.zos.staticFileDomain##arguments.file_path#?zversion=#zS[checkPath].file_id#-#zS[checkPath].file_version_number##randomVersion#" />';
		application.zcore.template[templateTagFunction](templateTagName, s&chr(10), forceFirst);
		return "";
	}else if(structkeyexists(aS1,arguments.file_path)){
		s='<link rel="stylesheet" type="text/css" href="#request.zos.staticFileDomain##arguments.file_path#?zversion=#aS1[arguments.file_path].file_id#-#aS1[arguments.file_path].file_version_number##randomVersion#" />';
		application.zcore.template[templateTagFunction](templateTagName, s&chr(10), forceFirst);
		return "";
	}else{
		s='<link rel="stylesheet" type="text/css" href="#request.zos.staticFileDomain##arguments.file_path#?zv=#application.sitestruct[request.zos.globals.id].skinObj.curCompiledVersionNumber##randomVersion#" />';
		application.zcore.template[templateTagFunction](templateTagName, s&chr(10), forceFirst);
		return "";
	}
</cfscript>
</cffunction>

<!--- application.zcore.skin.includeJS("/skins/js/script.js", "", ""); --->
<cffunction name="includeJS" localmode="modern" access="public" output="no" returntype="any">
<cfargument name="file_path" type="string" required="yes">
	<cfargument name="forcePosition" required="no" type="string" default="" hint="This can be set to first or last or empty string.">
	<cfargument name="loadLevel" type="string" required="no" default="1">
	<cfscript>
	var zSkinHTMLContents99="";
	var sa=false;
	var s="";
	var checkPath=arguments.file_path;
	if(left(arguments.file_path,3) EQ "/z/"){
		sa=true;
		//checkPath=replace(arguments.file_path,"/z/","/z/");
	}
	if(structkeyexists(request.zos.jsIncludeUniqueStruct, checkPath)){
		return "";
		//throw("arguments.file_path, ""#checkPath#"", was already included.");
	}
	request.zos.jsIncludeUniqueStruct[checkPath]=true;
	arrayappend(request.zos.arrScriptIncludeLevel, arguments.loadLevel);
	if(left(arguments.file_path,2) EQ "//"){
		arrayappend(request.zos.arrScriptInclude, arguments.file_path);
		return "";
	}
	var joinString="?";
	if(arguments.file_path CONTAINS "?"){
		joinString="&";
	}
	randomVersion="";
	if(request.zos.isTestServer){
		//randomVersion=gettickcount();
	}
	if(sa and structkeyexists(application.zcore.skinObj.fileStruct,checkPath)){
		arrayappend(request.zos.arrScriptInclude, request.zos.staticFileDomain&arguments.file_path&"#joinString#zversion="&application.zcore.skinObj.fileStruct[checkPath].file_id&"-"&application.zcore.skinObj.fileStruct[checkPath].file_version_number&randomVersion);
		return "";
	}else if(structkeyexists(application.sitestruct[request.zos.globals.id].skinObj.fileStruct,arguments.file_path)){
		arrayappend(request.zos.arrScriptInclude, request.zos.staticFileDomain&arguments.file_path&"#joinString#zversion="&application.sitestruct[request.zos.globals.id].skinObj.fileStruct[arguments.file_path].file_id&"-"&application.sitestruct[request.zos.globals.id].skinObj.fileStruct[arguments.file_path].file_version_number&randomVersion);
		return "";
	}else{
		arrayappend(request.zos.arrScriptInclude, request.zos.staticFileDomain&arguments.file_path&"#joinString#zv=#application.sitestruct[request.zos.globals.id].skinObj.curCompiledVersionNumber##randomVersion#");
		return "";
	}
	</cfscript>
</cffunction>

<cffunction name="loadJS" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	writeoutput('{arrJS:[{file:"/z/skin/view/js/blog/article.js",renderObj:"blog-article", callbackFunction: function(){ /* code here */ return "ajax loaded cb func called"; }},{file:"/z/skin/view/js/blog/comments.js", renderObj:"blog-comments", callbackFunction: function(){ return "ajax cb comments called"; }}] }');
	header name="x_ajax_id" value="#x_ajax_id#";
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="getSkinData" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	writeoutput('{"cacheIndex":"#jsstringformat(application.zcore.functions.zso(form, 'cacheIndex'))#", "query1":[["rtitle","rdate","ruser","remail"],["rtitle2","rdate2","ruser2","remail2"]],  "query2":[["rsometitle2"]]');
	for(i in form){
		writeoutput(',"#i#": "#jsstringformat(form[i])#"');
	}
	writeoutput(' }');
	header name="x_ajax_id" value="#form.x_ajax_id#";
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>