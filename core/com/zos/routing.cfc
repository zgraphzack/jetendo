<cfcomponent output="no">
<cfoutput>
<cffunction name="processRequestURL" localmode="modern" access="public" output="true" returntype="string"><cfargument name="theURL" type="string" required="yes"><cfscript>
		var cfcLookupName="";
		var cfcURLName="";
		var cfcMethodForced=false;
		var arrURL="";
		var inputStruct=""; 
		var local=structnew();  
		request.zos.currentController="";
		request.zos.routingIsCFC=false;
		request.zos.routingCurrentComponentObject="";
		request.zos.routingArrArguments=arraynew(1);
		request.zos.routingArgumentsStruct=structnew();
		request.zos.routingDisableComponentInvoke=false;
		request.zos.routingCfcMethodWasMissing=false;
		if((request.zos.isdeveloper EQ false and request.zos.isserver EQ false) or structkeyexists(form,'zdebugurl2') EQ false){
			form.zdebugurl2=false;
			
		}
		
		if(structkeyexists(form,request.zos.urlRoutingParameter)){
			request.zos.cgi.query_string=replace(request.zos.cgi.query_string, request.zos.urlRoutingParameter&"="&form[request.zos.urlRoutingParameter], "","all");
			if(left(request.zos.cgi.query_string,1) EQ "&"){
				request.zos.cgi.query_string=removechars(request.zos.cgi.query_string,1,1);
			}
		}
		if(arguments.theURL EQ ""){
			application.zcore.functions.z404("Path doesn't exist or is a directory.");
		}else if((not structkeyexists(form,'__zcoreinternalroutingpath') or trim(form.__zcoreinternalroutingpath) EQ "")){
			local.notCFC=false;
			if(find(".cfc", arguments.theURL) EQ 0){
				local.notCFC=true;
			}
			local.ctemp1=request.zos.globals.homedir&removechars(arguments.theURL,1,1);
			if(not structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, local.ctemp1)){
				application.sitestruct[request.zos.globals.id].fileExistsCache[local.ctemp1]=fileexists(local.ctemp1);
			}
			/*
			// this code was unnecessary
			if(not structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, arguments.theURL)){
				application.sitestruct[request.zos.globals.id].fileExistsCache[arguments.theURL]=fileexists(arguments.theURL);
			}*/
			request.zos.routingDisableComponentInvoke=true;
			if(not local.notCFC and (application.sitestruct[request.zos.globals.id].fileExistsCache[local.ctemp1])){// or application.sitestruct[request.zos.globals.id].fileExistsCache[arguments.theURL]
				if(right(arguments.theURL,4) EQ ".cfc"){
					request.zos.routingIsCFC=true;
					if(structkeyexists(form,'method') EQ false){
						form.method="index";	
						request.zos.routingCfcMethodWasMissing=true;
					}
					request.zos.routingDisableComponentInvoke=false;
					if(form.zdebugurl2){
						writeoutput('url was a cfc :'&arguments.theURL&'<br />');
					}
				}
			}else{
				
				form.__zcoreinternalroutingpath=removechars(arguments.theURL,1,1);
				//form.__zcoreinternalroutingpath=removechars(form[request.zos.urlRoutingParameter],1,1);
				arrURL=listtoarray(form.__zcoreinternalroutingpath,"/",true);
				// find a matching registered controller
				local.curURLData="";
				local.urlPathCount=arraylen(arrURL);
				local.isUsingMVCAppScope=true;
				local.controllerFound=true;
				local.routingISMVC=false;
				for(local.i4=1;local.i4 LTE local.urlPathCount;local.i4++){
					local.lastURLData=local.curURLData;
					local.curURLData&="/"&arrURL[1];
					local.curURLPath=arrURL[1];
					arraydeleteat(arrURL, 1);
					
						if(form.zdebugurl2){
								writeoutput('curdata:'&local.curURLData&'<br />');
						}
					if(structkeyexists(application.sitestruct[request.zos.globals.id].registeredControllerStruct, "/controller"&local.curURLData)){
						if(form.zdebugurl2){
							writeoutput("Found controller in application scope: "&"/controller"&local.curURLData&".cfc<br />");
						}
						break;
					}else if(structkeyexists(application.sitestruct[request.zos.globals.id].registeredControllerPathStruct, local.curURLData) EQ false){
						
						cfcLookupName=local.lastURLData&"/controller/"&local.curURLPath;
						cfcURLName=local.lastURLData&"/"&local.curURLPath;
						
						if(local.isUsingMVCAppScope and structkeyexists(application.sitestruct[request.zos.globals.id].registeredControllerStruct, cfcLookupName)){
							local.routingISMVC=true;
							request.zos.routingIsCFC=true;
							request.zos.scriptNameTemplate=application.sitestruct[request.zos.globals.id].registeredControllerStruct[cfcLookupName];
							if(form.zdebugurl2){
								writeoutput("Found controller in site struct: "&local.curURLData&"<br />");
							}
						}else{
							if(form.zdebugurl2){
								writeoutput("Missing controller in application scope: "&local.curURLData&" | switching to global application struct<br />");
							}
							local.controllerFound=false;
						}
						break;
					}
				}
				if(local.controllerFound EQ false){
					local.lastURLData="";
					local.curURLData="";
					arrURL=listtoarray(form.__zcoreinternalroutingpath,"/",true);
					for(local.i4=1;local.i4 LTE local.urlPathCount;local.i4++){
						local.lastURLData=local.curURLData;
						local.curURLData&="/"&arrURL[1];
						local.curURLPath=arrURL[1];
						arraydeleteat(arrURL, 1);
						
						if(structkeyexists(application.zcore.registeredControllerStruct, "/controller"&local.curURLData)){
							if(form.zdebugurl2){
								writeoutput("Found controller in site struct: "&"/controller"&local.curURLData&".cfc<br />");
							}
							local.isUsingMVCAppScope=false;
							break;
						}else if(structkeyexists(application.zcore.registeredControllerStruct, local.curURLData) EQ false){
							if(form.zdebugurl2){
								writeoutput("Missing path: "&local.curURLData&" | switching to global application struct<br />");
							}
							local.isUsingMVCAppScope=false;
							if(structkeyexists(application.zcore.registeredControllerPathStruct, local.curURLData) EQ false){
								break;
							}
						}
					}
				}
				
				cfcLookupName=local.lastURLData&"/controller/"&local.curURLPath;
				cfcURLName=local.lastURLData&"/"&local.curURLPath;
				
				if(form.zdebugurl2){
					writeoutput('cfcLookupName:'&cfcLookupName&'<br />cfcURLName:'&cfcURLName&"<br />isUsingMVCAppScope:"&local.isUsingMVCAppScope&"<br />");
					writeoutput('Application MVC Cache<br />');
					writeoutput('application.zcore.registeredControllerPathStruct<br />');
					writedump(application.zcore.registeredControllerPathStruct);
					writeoutput('application.zcore.registeredControllerStruct<br />');
					writedump(application.zcore.registeredControllerStruct);
					writeoutput('Application MVC Cache<br />application.sitestruct[request.zos.globals.id].registeredControllerPathStruct<br />');
					writedump(application.sitestruct[request.zos.globals.id].registeredControllerPathStruct);
					writeoutput('application.sitestruct[request.zos.globals.id].registeredControllerStruct<br />');
					writedump(application.sitestruct[request.zos.globals.id].registeredControllerStruct);
				}
				local.routingISMVC=false;
				if(local.isUsingMVCAppScope and structkeyexists(application.sitestruct[request.zos.globals.id].registeredControllerStruct, cfcLookupName)){
					local.routingISMVC=true;
					request.zos.routingIsCFC=true;
					request.zos.scriptNameTemplate=application.sitestruct[request.zos.globals.id].registeredControllerStruct[cfcLookupName];
				}else{
					if(structkeyexists(application.zcore.registeredControllerStruct, cfcLookupName)){
						local.routingISMVC=true;
						request.zos.routingIsCFC=true;
						request.zos.scriptNameTemplate=application.zcore.registeredControllerStruct[cfcLookupName];
					}
				}
				if(local.routingISMVC){
					request.zos.cgi.SCRIPT_NAME="/"&form.__zcoreinternalroutingpath;
					//arraydeleteat(arrURL,1);
					request.zos.routingCfcMethodWasMissing=true;
					request.zos.routingDisableComponentInvoke=false;
					if(form.zdebugurl2){
						writeoutput("Running MVC Component:"&request.zos.scriptNameTemplate&"<br />");
					}
					if(arraylen(arrURL) GTE 1 and trim(arrURL[1]) NEQ ""){
						form.method=arrURL[1];
						arraydeleteat(arrURL,1);
						if(form.zdebugurl2){
							writeoutput("method:"&form.method&"<br />");
							writedump("Remaining url string: "&arraytolist(arrURL, "/"));
							writedump(arrURL);
						}
						if(arraylen(arrURL) EQ 1){
							if(trim(arrURL[1]) EQ ""){
								if(request.zos.cgi.query_string NEQ ""){
									if(form.zdebugurl2){
										writeoutput("1 - redirecting to "&cfcURLName&"/"&form.method&"?"&request.zos.cgi.query_string); 
										application.zcore.functions.zabort();
									}
									application.zcore.functions.z301redirect(cfcURLName&"/"&form.method&"?"&request.zos.cgi.query_string);
								}else{
									if(form.zdebugurl2){
										writeoutput("2 - redirecting to "&cfcURLName&"/"&form.method&""); 
										application.zcore.functions.zabort();
									}
									application.zcore.functions.z301redirect(cfcURLName&"/"&form.method&"");	
								}
							}
						}else if(arraylen(arrURL) GTE 1 and trim(arrURL[arraylen(arrURL)]) EQ ""){
							arraydeleteat(arrURL,arraylen(arrURL));
							if(request.zos.cgi.query_string NEQ ""){
								if(form.zdebugurl2){
									writeoutput("3 - redirecting to "&cfcURLName&"/"&form.method&"/"&arraytolist(arrURL,"/")&"?"&request.zos.cgi.query_string); 
									application.zcore.functions.zabort();
								}
								application.zcore.functions.z301redirect(cfcURLName&"/"&form.method&"/"&arraytolist(arrURL,"/")&"?"&request.zos.cgi.query_string);
							}else{
								if(form.zdebugurl2){
									writeoutput("4 - redirecting to "&cfcURLName&"/"&form.method&"/"&arraytolist(arrURL,"/")); 
									application.zcore.functions.zabort();
								}
								application.zcore.functions.z301redirect(cfcURLName&"/"&form.method&"/"&arraytolist(arrURL,"/"));
							}
						}
					}else{
						form.method="index";
						if(len(request.zos.cgi.query_string)){
							if(form.zdebugurl2){
								writeoutput("5 - redirecting to "&cfcURLName&"/"&form.method&"?"&request.zos.cgi.query_string); 
								application.zcore.functions.zabort();
							}
							application.zcore.functions.z301redirect(cfcURLName&"/"&form.method&"?"&request.zos.cgi.query_string);
						}else{
							if(form.zdebugurl2){
								writeoutput("6 - redirecting to "&cfcURLName&"/"&form.method); 
								application.zcore.functions.zabort();
							}
							application.zcore.functions.z301redirect(cfcURLName&"/"&form.method);
						}
						cfcMethodForced=true;
					}
					request.zos.routingArrArguments=arrURL;
				}
				if(form.zdebugurl2){
					application.zcore.functions.zabort();
				}
			}
			structdelete(form,'__zcoreinternalroutingpath');
		}else{
			if(form.__zcoreinternalroutingpath CONTAINS "www." or trim(form.__zcoreinternalroutingpath) CONTAINS " " or form.__zcoreinternalroutingpath CONTAINS "'" or form.__zcoreinternalroutingpath CONTAINS '"' or form.__zcoreinternalroutingpath CONTAINS "mailto:" or form.__zcoreinternalroutingpath CONTAINS "/undefined.cfm" or form.__zcoreinternalroutingpath CONTAINS "/.cfm" or right(form.__zcoreinternalroutingpath,9) EQ ".html.cfm" or right(form.__zcoreinternalroutingpath,8) EQ ".txt.cfm" or right(form.__zcoreinternalroutingpath,8) EQ ".cfm.cfm" or right(form.__zcoreinternalroutingpath,8) EQ ".php.cfm" or form.__zcoreinternalroutingpath CONTAINS "javascript:"){
				application.zcore.functions.z404("An invalid url was matched in routing() before further processing occurred.");	
			}
			// clean up query string
			var p=findnocase("__zcoreinternalroutingpath",request.zos.cgi.query_string);
			var p2=find("&",request.zos.cgi.query_string,p);
			if(p NEQ 0){
				if(p2 EQ 0){
					request.zos.cgi.query_string="";
				}else{
					request.zos.cgi.query_string=removeChars(request.zos.cgi.query_string,p,(p2-p)+1);
				}
			}
			
			// check for email click links
			if(left(form.__zcoreinternalroutingpath,2) EQ '-e'){
				this.processEmailClickURL();
			}else{
				// process all other mvc and zcore urls
				request.zos.scriptNameTemplate="/zcorerootmapping/#form.__zcoreinternalroutingpath#";
				if(right(form.__zcoreinternalroutingpath,4) NEQ ".cfm" and right(form.__zcoreinternalroutingpath,4) NEQ ".cfc"){
					request.zos.cgi.script_name=form.__zcoreinternalroutingpath;
				}else{
					if(len(form.__zcoreinternalroutingpath)-4 LTE 0){
						application.zcore.functions.z301redirect('/');	
					}
					request.zos.cgi.script_name="/z/_#left(form.__zcoreinternalroutingpath,len(form.__zcoreinternalroutingpath)-4)#";
				}
				
				if(find(","&left(form.__zcoreinternalroutingpath,4)&",", ',com/,') NEQ 0){
					request.zos.routingIsCFC=true;
				}else{
					writeoutput('old mvc is not supposed to happen - there is a problem.<br />URL:'&form.__zcoreinternalroutingpath);
					application.zcore.functions.zabort();
				}
			}
		}
		if(request.zos.routingIsCFC and structkeyexists(form,'method')){
			this.checkCFCSecurity(request.zos.scriptNameTemplate, form.method);
			arrayappend(request.zos.arrRunTime, {time:gettickcount('nano'), name:'routing.cfc after checkCFCSecurity'});
			request.zos.currentController=request.zos.scriptNameTemplate;
			//writeoutput('in isCFC'&request.zos.routingDisableComponentInvoke);
			if(request.zos.routingDisableComponentInvoke EQ false){
				request.zos.routingCurrentComponentObject[form.method](argumentcollection=request.zos.routingArgumentsStruct);
				request.zos.onrequestcompleted=true;
				if(request.zos.routingCfcMethodWasMissing){
					// disable the default introspection feature of coldfusion CFCs and end the request now.
					return;
					//throw("cfc method missing: #request.zos.currentController#", "custom");
					//server["zcore_"&request.zos.installPath&"_functionscache"].onRequestEnd();
					//abort;
				}
			}
		}
		</cfscript>
	</cffunction>
    
    <cffunction name="checkCFCSecurity" localmode="modern" output="no" returntype="any">
    	<cfargument name="scriptName" type="string" required="yes">
    	<cfargument name="method" type="string" required="yes">
    	<cfscript>
		var t=0;
		var inputStruct=0;
		var arrLoginRoles=0;
		var i=0;
		var curRole=0;
		var tempLoginSkip=0;
		var comPath="";
		var isTestCFC=false;
		var isServerCFC=false;
		var tempcommeta=0;
		var comTempPath=arguments.scriptName;
		arguments.method=trim(arguments.method);
		comPath=replace(replace(replace(mid(comTempPath,2,len(comTempPath)-5),"\",".","ALL"),"/",".","ALL"), request.zRootDomain&".", request.zRootCFCPath);
		if(left(comPath, 17) EQ "zcorerootmapping."){
			isServerCFC=true;
		}else if(len(request.zRootCFCPath) and left(comPath, len(request.zRootCFCPath)) NEQ request.zRootCFCPath){//request.zRootCFCPath){
			if(compare(request.zos.globals.id, request.zos.globals.serverid) EQ 0){
				comPath="zcorerootmapping."&comPath;
			}else{
				if(left(comPath, 15) NEQ "jetendo-themes."){
					comPath=request.zRootCFCPath&comPath;	
				}
			}
		}
		if(comPath CONTAINS ".test."){
			isTestCFC=true;
			if(request.zos.istestserver EQ false){
				application.zcore.template.fail("Running tests in production is not allowed.");	
			}
			request.znotemplate=true;
		}
		local.notFound=true;
		if(not request.zos.isTestServer){
			if(isServerCFC EQ false and structkeyexists(application.sitestruct[request.zos.globals.id].controllerComponentCache, comPath)){
				request.zos.routingCurrentComponentObject=duplicate(application.sitestruct[request.zos.globals.id].controllerComponentCache[comPath]);
				local.notFound=false;
			}else if(structkeyexists(application.zcore.controllerComponentCache, comPath)){
				request.zos.routingCurrentComponentObject=duplicate(application.zcore.controllerComponentCache[comPath]);
				local.notFound=false;
			}else if(Structkeyexists(application.sitestruct[request.zos.globals.id].comCache, comPath)){
				request.zos.routingCurrentComponentObject=duplicate(application.sitestruct[request.zos.globals.id].comCache[comPath]);
				local.notFound=false;
			}
		}
		if(local.notFound){
			//try{
			request.zos.routingCurrentComponentObject=createobject("component",comPath);
			/*}catch(Any local.excpt){
				writeoutput(comPath);
				writedump(local.excpt);
				abort;	
			}*/
			if(not request.zos.isTestServer){
				application.sitestruct[request.zos.globals.id].comCache[comPath]=request.zos.routingCurrentComponentObject;
			}
		}
		if(structkeyexists(request.zos.routingCurrentComponentObject,arguments.method) EQ false){
			application.zcore.functions.z404("Component method doesn't exist. Method = ""#arguments.method#""");
		}
		if(isServerCFC){
			cacheStruct=application.zcore.cfcMetaDataCache;
		}else{
			cacheStruct=application.sitestruct[request.zos.globals.id].cfcMetaDataCache;
		}
		if(request.zos.isTestServer or structkeyexists(cacheStruct, comPath) EQ false){
			commeta=GetMetaData(request.zos.routingCurrentComponentObject);
			cacheStruct[comPath]=commeta;
		}else{
			commeta=cacheStruct[comPath];
		}
		if(request.zos.isTestServer or structkeyexists(cacheStruct,comPath&":"&arguments.method) EQ false){
			tempcommeta=GetMetaData(request.zos.routingCurrentComponentObject[arguments.method]);
			cacheStruct[comPath&":"&arguments.method]=tempcommeta;
		}else{
			tempcommeta=cacheStruct[comPath&":"&arguments.method];
		}
		if(tempcommeta.access NEQ 'remote'){
			application.zcore.functions.z404("The component method must have access=""remote"" to be called directly via the URL. Please change access to remote for Method, ""#arguments.method#"", in #arguments.scriptName# if you need this function to be access remotely.");
		}
		if(isTestCFC EQ false){
			for(i=1;i LTE arraylen(tempcommeta.parameters);i++){
				if(tempcommeta.parameters[i].type NEQ "string" and tempcommeta.parameters[i].required EQ "yes"){
					application.zcore.functions.z404("All parameters of a Component method that have access=""remote"" must have the data type=""string"" or required=""no"" to prevent errors with unexpected data (robots &amp; pci scans, etc). Please change the argument, ""#tempcommeta.parameters[i].name#"", in method, ""#arguments.method#"" in #arguments.scriptName#.");
				}
			}
		}

		if(structkeyexists(request.zos.routingCurrentComponentObject, '__injectDependencies')){
			ds={
				context:application.zcore.componentObjectCache.context
			};
			if(structkeyexists(comMeta, 'properties')){
				for(i=1;i LTE arraylen(comMeta.properties);i++){
					property=comMeta.properties[i];
					if(right(property.name, 5) EQ "Model" and find(".model.", property.type) NEQ false){
						ds[property.name]=application.zcore.modelDataCache.modelComponentCache[property.type];
					}
				}
			}
			request.zos.routingCurrentComponentObject.__injectDependencies(ds);
		}
		for(i=1;i LTE arraylen(request.zos.routingArrArguments);i++){
			if(i LTE arraylen(tempcommeta.parameters)){
				request.zos.routingArgumentsStruct[tempcommeta.parameters[i].name]=request.zos.routingArrArguments[i];
			}else{
				// additional parameters with undefined arguments are sent in as an array
				if(structkeyexists(request.zos.routingArgumentsStruct, "_zExtraArguments") EQ false){
					request.zos.routingArgumentsStruct["_zExtraArguments"]=arraynew(1);
				}
				arrayappend(request.zos.routingArgumentsStruct["_zExtraArguments"], request.zos.routingArrArguments[i]);
			}
		}
		if(structkeyexists(tempcommeta,'roles') and application.zcore.user.checkSiteAccess() EQ false and application.zcore.user.checkServerAccess() EQ false){
			// only one user group role can be defined even though coldfusion supports more. Example: roles="member"
			arrLoginRoles=listtoarray(tempcommeta.roles,",");
			curRole="";
			for(i=1;i LTE arraylen(arrLoginRoles);i++){
				curRole=trim(arrLoginRoles[i]);
				tempLoginSkip=false;
				if(application.zcore.user.checkGroupAccess(curRole) EQ false){
					break;
				}else{
					curRole="";	
				}
			}
			if(curRole NEQ ""){
				request.zos.inMemberArea=true;
				application.zcore.skin.disableMinCat();
				request.disableShareThis=true;
				inputStruct = StructNew();
				inputStruct.user_group_name=curRole;
				if(request.zos.globals.requireSecureLogin EQ 1){
					inputStruct.secureLogin=true;
				}else{
					inputStruct.secureLogin=false;
				}
				inputStruct.noRedirect=false;
				inputStruct.template="zcorerootmapping.templates.blank";
				inputStruct.site_id = request.zos.globals.id;
				application.zcore.user.checkLogin(inputStruct); 
				
			} 
		}
		if(structkeyexists(tempcommeta,'roles') and tempcommeta.roles NEQ ""){
			if(tempcommeta.roles NEQ "user"){
				application.zcore.template.setTemplate("zcorerootmapping.templates.administrator",true,true);
				request.zos.inMemberArea=true;
				application.zcore.skin.disableMinCat();
				application.zcore.functions.zDisableContentTransition();
			}
		}
		</cfscript>
    </cffunction>
    
    <cffunction name="processEmailClickURL" localmode="modern" output="no" returntype="any">
    	<cfscript>
		var arrpath='';
		var qE='';
		var inputStruct='';
		var ts='';
		var i=0;
		var qM=0;
		var t=0;
		var urlType=0;
		var db=request.zos.queryObject;
		var mailUserType=false;
		//request.zos.znoredirect=true; // uncomment to debug redirects
		if(mid(form.__zcoreinternalroutingpath,5,1) EQ 'm'){
			mailUserType=true;
			var t=mid(form.__zcoreinternalroutingpath,6,len(form.__zcoreinternalroutingpath)-5);
			arrpath=listtoarray(t,'.');
			if(arraylen(arrpath) GTE 2){
				form.mail_user_id=arrpath[1];
				urlType=mid(form.__zcoreinternalroutingpath,3,2);
				if(urlType EQ 'ck' or urlType EQ 'in'){
					form.mail_user_key=arrpath[2];
				}else{
					form.zemail_campaign_id=arrpath[2];
					form.mail_user_key=arrpath[3];
				}
				db.sql="select * from #db.table("mail_user", request.zos.zcoreDatasource)# mail_user 
				WHERE mail_user_id=#db.param(form.mail_user_id)# and 
				mail_user_deleted = #db.param(0)# and 
				mail_user_key=#db.param(form.mail_user_key)# and 
				site_id=#db.param(request.zos.globals.id)#";
				qM=db.execute("qM"); 
				if(qM.recordcount EQ 0){
					application.zcore.functions.zredirect('/');
				}else{
					request.zsession.inquiries_email=qm.mail_user_email;
					request.zsession.inquiries_first_name=qm.mail_user_first_name;
					request.zsession.inquiries_last_name=qm.mail_user_last_name;
					request.zsession.inquiries_phone1=qm.mail_user_phone;
				}
			}else{
				application.zcore.functions.zredirect('/');
			}
			if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'in'){
				db.sql="update #db.table("user", request.zos.zcoreDatasource)# user 
				set user_confirm=#db.param(1)#, 
				user_pref_email=#db.param(1)#, 
				user_confirm_datetime=#db.param(request.zos.mysqlnow)#, 
				user_confirm_ip=#db.param(request.zos.cgi.remote_addr)#,
				user_updated_datetime=#db.param(request.zos.mysqlnow)#  
				WHERE user_username=#db.param(qM.mail_user_email)# and 
				user_deleted = #db.param(0)# and
				site_id=#db.param(request.zos.globals.id)#";
				db.execute("q"); 
				db.sql="update #db.table("mail_user", request.zos.zcoreDatasource)# mail_user 
				set mail_user_opt_in=#db.param(1)#, 
				mail_user_confirm=#db.param(1)#,
				mail_user_updated_datetime=#db.param(request.zos.mysqlnow)#  
				WHERE mail_user_id=#db.param(form.mail_user_id)# and 
				mail_user_deleted = #db.param(0)# and 
				mail_user_key=#db.param(form.mail_user_key)# and 
				site_id=#db.param(request.zos.globals.id)#";
				db.execute("q"); 
				form.__zcoreinternalroutingpath_new='mvc/z/user/controller/in.cfc';
				form.method="simple_confirmed";
				request.zos.routingIsCFC=true;
			}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'ou'){
				db.sql="update #db.table("user", request.zos.zcoreDatasource)# user 
				set user_pref_email=#db.param(0)#, 
				user_confirm=#db.param(1)#, 
				user_confirm_datetime=#db.param(request.zos.mysqlnow)#, 
				user_confirm_ip=#db.param(request.zos.cgi.remote_addr)#,
				user_updated_datetime=#db.param(request.zos.mysqlnow)#  
				WHERE user_username=#db.param(qM.mail_user_email)# and 
				user_deleted = #db.param(0)# and 
				site_id=#db.param(request.zos.globals.id)#";
				db.execute("q"); 
				 db.sql="update #db.table("mail_user", request.zos.zcoreDatasource)# mail_user 
				 set mail_user_opt_in=#db.param(0)#, 
				 mail_user_confirm=#db.param(1)#,  
				 mail_user_confirm_datetime=#db.param(request.zos.mysqlnow)#, 
				 mail_user_confirm_ip=#db.param(request.zos.cgi.remote_addr)#,
				 mail_user_updated_datetime=#db.param(request.zos.mysqlnow)#  
				WHERE mail_user_id=#db.param(form.mail_user_id)# and 
				mail_user_deleted = #db.param(0)# and 
				mail_user_key=#db.param(form.mail_user_key)# and 
				site_id=#db.param(request.zos.globals.id)#";
				db.execute("q");
				form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
				form.method="unsubscribed";
				request.zos.routingIsCFC=true;
			}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'vm'){
				form.__zcoreinternalroutingpath_new='mvc/z/user/controller/view.cfc';
				form.method="simple";
				//request.zEmailViewOnline=true;
				request.zos.routingIsCFC=true;
			}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'ck'){
				request.zEmailClickThrough=true;
			}
		}else{
			if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'in'){
				form.__zcoreinternalroutingpath_new='mvc/z/user/controller/in.cfc';
				form.method="index";
				request.zos.routingIsCFC=true;
			}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'ou'){
				form.__zcoreinternalroutingpath_new='mvc/z/user/controller/out.cfc';
				form.method="index";
				request.zos.routingIsCFC=true;
				request.zEmailUnsubscribe=true;
			}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'rp'){
				form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
				form.method="index";
				request.zos.routingIsCFC=true;
				form.npw=1;
			}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'ce'){
				form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
				form.method="index";
				request.zos.routingIsCFC=true;
				form.nea=1;
			}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'pr'){
				form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
				request.zos.routingIsCFC=true;
				form.method="form";
			}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'vm'){
				form.__zcoreinternalroutingpath_new='mvc/z/user/controller/view.cfc';
				form.method="index";
				request.zEmailViewOnline=true;
				request.zos.routingIsCFC=true;
			}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'ck'){
				request.zEmailClickThrough=true;
			}else{
				form.__zcoreinternalroutingpath_new='e/pref.cfm';
			}
			if(isDefined('request.zEmailViewOnline') or isDefined('request.zEmailUnsubscribe')){
				form.__zcoreinternalroutingpath=mid(form.__zcoreinternalroutingpath,5,len(form.__zcoreinternalroutingpath)-4);
				arrpath=listtoarray(form.__zcoreinternalroutingpath,'.');
				if(arraylen(arrpath) GTE 2){
					form.user_id=arrpath[1];
					form.zemail_campaign_id=arrpath[2];
					if(isDefined('request.zEmailViewOnline') and arraylen(arrpath) EQ 2){
						application.zcore.functions.zredirect('/');
					}else{
						if(arraylen(arrpath) GTE 3 or isDefined('request.zEmailViewOnline')){
							form.user_key=arrpath[3];
						}else{
							form.user_key=false;	
						}
						if(arraylen(arrpath) GTE 4){
							form.email_template_type_id=arrpath[4];
							if(form.email_template_type_id EQ 3){
								if(arraylen(arrpath) GTE 5){
									form.mls_saved_search_id=arrpath[5];
								}
							}
						}
							
					}
					// don't try to login again if already logged in
					if(form.user_key NEQ false){
						db.sql="SELECT user_username, user_key, user_password 
						FROM #db.table("user", request.zos.zcoreDatasource)# user 
						WHERE user_id = #db.param(form.user_id)# and 
						user_deleted = #db.param(0)# and
						user_active= #db.param(1)# and 
						(user_server_administrator= #db.param(1)# or 
						site_id = #db.param(request.zos.globals.id)#) and 
						user_key = #db.param(form.user_key)# ";
						qE=db.execute("qE"); 
						if(qE.recordcount NEQ 0){
							form.e=qE.user_username;
							form.k=qE.user_key;
							if(isDefined('request.zsession.user.id') EQ false or request.zsession.user.id NEQ form.user_id){
								form.zusername=qE.user_username;
								form.zpassword=qE.user_password;
								inputStruct = StructNew();
								inputStruct.user_group_name = "user";
								inputStruct.noRedirect=true;
								inputStruct.disableSecurePassword=true;
								inputStruct.secureLogin=false;
								inputStruct.site_id = request.zos.globals.id;
								application.zcore.user.checkLogin(inputStruct);
							}
						}
					}
				}else{
					application.zcore.functions.zredirect('/');
				}
				if(isDefined('request.zEmailUnsubscribe')){
					db.sql="INSERT INTO #db.table("zemail_campaign_click", request.zos.zcoreDatasource)#  
					SET zemail_campaign_click_type=#db.param(2)#, 
					zemail_campaign_click_html=#db.param(0)#, 
					zemail_campaign_click_offset=#db.param(0)#, 
					zemail_campaign_click_ip=#db.param(request.zos.cgi.remote_addr)#, 
					zemail_campaign_click_datetime=#db.param(request.zOS.mysqlnow)#, 
					zemail_campaign_click_updated_datetime=#db.param(request.zos.mysqlnow)#,
					zemail_campaign_id=#db.param(form.zemail_campaign_id)#,
					 user_id=#db.param(form.user_id)#,
					 site_id=#db.param(request.zos.globals.id)#";
					 db.execute("q"); 
					db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
					WHERE user_id = #db.param(form.user_id)# and 
					user_deleted = #db.param(0)# and
					(user_key=#db.param(form.user_key)# or 
					site_id = #db.param(request.zos.globals.id)#) ";
					qE=db.execute("qE"); 
					if(qE.recordcount EQ 0){
						application.zcore.functions.zRedirect('/z/user/out/index');
					}
					form.e=qE.user_username;
				}
			}else{
				if(structkeyexists(form,'user_id') EQ false or structkeyexists(form,'user_key') EQ false){
					// /z/_eck1.3423923.3.1.cfm
					form.__zcoreinternalroutingpath=mid(form.__zcoreinternalroutingpath,5,len(form.__zcoreinternalroutingpath)-4);
					arrpath=listtoarray(form.__zcoreinternalroutingpath,'.');
					if(arraylen(arrpath) GTE 2){
						form.user_id=arrpath[1];
						form.user_key=arrpath[2];
					}else{
						application.zcore.functions.zredirect('/');
					}
				}
				// don't try to login again if already logged in
				 db.sql="SELECT user_username, user_key, user_password 
				 FROM #db.table("user", request.zos.zcoreDatasource)# user 
				WHERE user_id = #db.param(form.user_id)# and 
				user_deleted = #db.param(0)# and 
				(user_server_administrator= #db.param(1)# or 
				site_id = #db.param(request.zos.globals.id)#) and 
				user_key = #db.param(form.user_key)# ";
				qE=db.execute("qE");
				if(qE.recordcount NEQ 0){
					form.e=qE.user_username;
					form.k=qE.user_key;
					if(isDefined('request.zsession.user.id') EQ false or request.zsession.user.id NEQ form.user_id){
						form.zusername=qE.user_username;
						form.zpassword=qE.user_password;
						inputStruct = StructNew();
						inputStruct.user_group_name = "user";
						inputStruct.noRedirect=true;
						inputStruct.disableSecurePassword=true;
						inputStruct.secureLogin=false;
						inputStruct.site_id = request.zos.globals.id;
						// perform check 
						application.zcore.user.checkLogin(inputStruct);
					}
				}
			}
		}
		if(structkeyexists(request,'zEmailClickThrough')){
			if(arraylen(arrpath) GTE 6){
				ts=StructNew();
				if(mailUserType EQ false){
					ts.user_id=arrpath[1];
					ts.user_key=arrpath[2];
					ts.mail_user_id='';
					ts.mail_user_key='';
				}else{
					ts.user_id='';
					ts.user_key='';
					ts.mail_user_id=arrpath[1];
					ts.mail_user_key=arrpath[2];
				}
				ts.zemail_campaign_id=arrpath[3];
				ts.zemail_campaign_click_html=arrpath[4];
				ts.zemail_campaign_click_offset=arrpath[5]; // zero = opened email (logged via hidden image or after click)
				ts.zemail_campaign_click_ip=request.zos.cgi.remote_addr;
				ts.zemail_campaign_click_datetime=request.zOS.mysqlnow;
				form.zr="";
				for(i=6;i LTE arraylen(arrpath);i++){
					if(i NEQ 6){
						form.zr&='.'&arrpath[i];
					}else{
						form.zr&=arrpath[i];
					}
				}
				if(ts.zemail_campaign_id NEQ 0 and ts.zemail_campaign_id NEQ ""){
					if(isNumeric(ts.zemail_campaign_click_html) EQ false or isNumeric(ts.zemail_campaign_id) EQ false or (isNumeric(ts.mail_user_id) EQ false and isNumeric(ts.user_id) EQ false) or isNumeric(ts.zemail_campaign_click_offset) EQ false){
						writeoutput('Access Denied');
						application.zcore.functions.zabort();
					}
					// used to track conversions
					application.zcore.tracking.setEmailCampaign(ts.zemail_campaign_id);
					
					// set type 1=open, 2=unsubscribe, 3=bounce, 4=click, 5=conversion, 6=outofoffice, 7=temporaryBounce, 8=challengeresponse, 9=antispamBounce, 10=other/replies - bounce must be handled by checking failed account and return emails
					if(left(form.zr,10) EQ '/z/_eou'){
						ts.zemail_campaign_click_type=2;
					}else if(ts.zemail_campaign_click_offset EQ 0){
						ts.zemail_campaign_click_type=1; 
	
					}else{
						ts.zemail_campaign_click_type=4;
					}
					db.sql="INSERT INTO #db.table("zemail_campaign_click", request.zos.zcoreDatasource)#  
					SET zemail_campaign_click_type=#db.param(ts.zemail_campaign_click_type)#, 
					zemail_campaign_click_html=#db.param(ts.zemail_campaign_click_html)#, 
					zemail_campaign_click_offset=#db.param(ts.zemail_campaign_click_offset)#,
					 zemail_campaign_click_ip=#db.param(ts.zemail_campaign_click_ip)#, 
					 zemail_campaign_click_datetime=#db.param(ts.zemail_campaign_click_datetime)#,
					 zemail_campaign_id=#db.param(ts.zemail_campaign_id)#,
					 user_id=#db.param(ts.user_id)#, 
					zemail_campaign_click_updated_datetime=#db.param(request.zos.mysqlnow)#, 
					 mail_user_id=#db.param(ts.mail_user_id)#,
					 site_id=#db.param(request.zos.globals.id)#";
					db.execute("q"); 
				}
				if(ts.zemail_campaign_click_offset EQ 0){
					// output tracking image and abort();
					application.zcore.functions.zImageOutput(request.zos.installPath&'public/a/images/s.gif','image/gif');
				}else{
					application.zcore.functions.zredirect(replacenocase(replacenocase(form.zr, "http:/","http://","all"), "https:/","https://","all"));
				}
			}else{
				// invalid request - redirect to home page
				application.zcore.functions.zredirect('/');
			}
		}
		form.__zcoreinternalroutingpath=form.__zcoreinternalroutingpath_new;
		request.zos.scriptNameTemplate="/zcorerootmapping/#form.__zcoreinternalroutingpath#";
		if(len(form.__zcoreinternalroutingpath)-4 LTE 0){
			application.zcore.functions.z301redirect('/');	
		}
		if(left(form.__zcoreinternalroutingpath,3) EQ "mvc"){
			request.zos.cgi.script_name="/z/#left(form.__zcoreinternalroutingpath,len(form.__zcoreinternalroutingpath)-4)#";
		}else{
			request.zos.cgi.script_name="/z/_#left(form.__zcoreinternalroutingpath,len(form.__zcoreinternalroutingpath)-4)#";
		}
		</cfscript>
    </cffunction>
    
    
    
<cffunction name="zProcessURLRoute" localmode="modern" output="yes" returntype="any"><cfscript>
	var zemail='';
	var arrpath='';
	var qE='';
	var inputStruct='';
	var db=request.zos.queryObject;
	var ts='';
	var zOverrideTitle='';
	var zTemplates='';
	if(structkeyexists(form,'__zcoreinternalroutingpath') EQ false){
		application.zcore.functions.zRedirect('/');
	}
	if(right(form.__zcoreinternalroutingpath,4) EQ '.cfm' and fileexists(expandpath('/zcorerootmapping/'&form.__zcoreinternalroutingpath)) EQ false){
		application.zcore.functions.z301redirect('/');
	}
	if(left(form.__zcoreinternalroutingpath,2) EQ '-e'){
		if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'in'){
			form.__zcoreinternalroutingpath_new='mvc/z/user/controller/in.cfc';
			form.method="index";
		}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'ou'){
			form.__zcoreinternalroutingpath_new='mvc/z/user/controller/out.cfc';
			form.method="index";
			request.zEmailUnsubscribe=true;
		}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'rp'){
			form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
			form.method="index";
			form.npw=1;
		}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'ce'){
			form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
			form.method="index";
			form.nea=1;
		}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'pr'){
			form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
			form.method="form";
		}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'vm'){
			form.__zcoreinternalroutingpath_new='mvc/z/user/controller/view.cfc';
			form.method="index";
			request.zEmailViewOnline=true;
		}else if(mid(form.__zcoreinternalroutingpath,3,2) EQ 'ck'){
			application.zcore.functions.zEndOfRunningScript();
			// url format
			// zemail.openImageUrl="#zemail.domain#/zcorerootmapping/_eck#user_id#.#user_key#.#arguments.ss.zemail_campaign_id#.1.0.cfm?zr="&URLEncodedFormat("/zcorerootmapping/a/images/s2.gif");
			request.zEmailClickThrough=true;
		}else{
			form.__zcoreinternalroutingpath_new='e/pref.cfm';
		}
		if(isDefined('request.zEmailViewOnline') or isDefined('request.zEmailUnsubscribe')){
			form.__zcoreinternalroutingpath=mid(form.__zcoreinternalroutingpath,5,len(form.__zcoreinternalroutingpath)-4);
			arrpath=listtoarray(form.__zcoreinternalroutingpath,'.');
			if(arraylen(arrpath) GTE 2){
				form.user_id=arrpath[1];
				form.zemail_campaign_id=arrpath[2];
				if(isDefined('request.zEmailViewOnline') and arraylen(arrpath) EQ 2){
					application.zcore.functions.zRedirect('/');
				}else{
					if(arraylen(arrpath) GTE 3 or isDefined('request.zEmailViewOnline')){
						form.user_key=arrpath[3];
					}else{
						form.user_key=false;	
					}
					if(arraylen(arrpath) GTE 4){
						form.zemail_template_type_id=arrpath[4];
						if(form.zemail_template_type_id EQ 3){
							if(arraylen(arrpath) GTE 5){
								form.mls_saved_search_id=arrpath[5];
							}
						}
					}
						
				}
				// don't try to login again if already logged in
				if(form.user_key NEQ false){
					 db.sql="SELECT user_username, user_key, user_password 
					 FROM #db.table("user", request.zos.zcoreDatasource)# user 
					WHERE user_id = #db.param(form.user_id)# and 
					user_deleted = #db.param(0)# and 
					((user_server_administrator= #db.param(1)# and 
					site_id=#db.param(Request.zos.globals.serverId)#) or 
					site_id = #db.param(request.zos.globals.id)#) and 
					user_key = #db.param(form.user_key)# ";
					qE=db.execute("qE");
					if(qE.recordcount NEQ 0){
						form.e=qE.user_username;
						form.k=qE.user_key;
						if(isDefined('request.zsession.user.id') EQ false or request.zsession.user.id NEQ form.user_id){
							form.zusername=qE.user_username;
							form.zpassword=qE.user_password;
							inputStruct = StructNew();
							inputStruct.user_group_name = "user";
							inputStruct.noRedirect=true;
							inputStruct.secureLogin=false;
							inputStruct.disableSecurePassword=true;
							inputStruct.site_id = request.zos.globals.id;
							// perform check 
							application.zcore.user.checkLogin(inputStruct);
						}
					}
				}
			}else{
				application.zcore.functions.zRedirect('/');
			}
			if(isDefined('request.zEmailUnsubscribe')){
				db.sql="INSERT INTO #db.table("zemail_campaign_click", request.zos.zcoreDatasource)#  
				SET zemail_campaign_click_type=#db.param(2)#, 
				zemail_campaign_click_html=#db.param(0)#, 
				zemail_campaign_click_offset=#db.param(0)#, 
				zemail_campaign_click_ip=#db.param(request.zos.cgi.remote_addr)#, 
				zemail_campaign_click_datetime=#db.param(request.zos.mysqlnow)#, 
				zemail_campaign_id=#db.param(form.zemail_campaign_id)#, 
				zemail_campaign_click_updated_datetime=#db.param(request.zos.mysqlnow)#, 
				user_id=#db.param(form.user_id)#,
				site_id=#db.param(request.zos.globals.id)#";
				db.execute("q"); 
				 db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
				WHERE user_id = #db.param(form.user_id)# and 
				user_deleted = #db.param(0)# and 
				((user_server_administrator= #db.param(1)# and 
				site_id=#db.param(Request.zos.globals.serverId)#) or 
				site_id = #db.param(request.zos.globals.id)#) ";
				qE=db.execute("qE");
				if(qE.recordcount EQ 0){
					application.zcore.functions.zRedirect('/z/user/out/index');
				}
				form.e=qE.user_username;
			}
		}else{
			if(structkeyexists(form,'user_id') EQ false or structkeyexists(form,'user_key') EQ false){
				// /z/_eck1.3423923.3.1.cfm
				form.__zcoreinternalroutingpath=mid(form.__zcoreinternalroutingpath,5,len(form.__zcoreinternalroutingpath)-4);
				arrpath=listtoarray(form.__zcoreinternalroutingpath,'.');
				if(arraylen(arrpath) GTE 2){
					form.user_id=arrpath[1];
					form.user_key=arrpath[2];
				}else{
					application.zcore.functions.zRedirect('/');
				}
			}
			// don't try to login again if already logged in
			db.sql="SELECT user_username, user_key, user_password FROM 
			#db.table("user", request.zos.zcoreDatasource)# user 
			WHERE user_id = #db.param(form.user_id)# and 
			((user_server_administrator= #db.param(1)# and 
			site_id=#db.param(Request.zos.globals.serverId)#) or 
			site_id = #db.param(request.zos.globals.id)#) and 
			user_deleted = #db.param(0)# and
			user_key = #db.param(form.user_key)# ";
			qE=db.execute("qE"); 
			if(qE.recordcount NEQ 0){
				form.e=qE.user_username;
				form.k=qE.user_key;
				if(isDefined('request.zsession.user.id') EQ false or request.zsession.user.id NEQ form.user_id){
					form.zusername=qE.user_username;
					form.zpassword=qE.user_password;
					inputStruct = StructNew();
					inputStruct.user_group_name = "user";
					inputStruct.noRedirect=true;
					inputStruct.secureLogin=false;
					inputStruct.disableSecurePassword=true;
					inputStruct.site_id = request.zos.globals.id;
					// perform check 
					application.zcore.user.checkLogin(inputStruct);
				}
			}
			if(structkeyexists(request,'zEmailClickThrough')){
				if(arraylen(arrpath) GTE 6 and isDefined('request.zsession.user.id')){
					ts=StructNew();
					ts.user_id=arrpath[1];
					ts.user_key=arrpath[2];
					ts.zemail_campaign_id=arrpath[3];
					ts.zemail_campaign_click_html=arrpath[4];
					ts.zemail_campaign_click_offset=arrpath[5]; // zero = opened email (logged via hidden image or after click)
					ts.zemail_campaign_click_ip=request.zos.cgi.remote_addr;
					ts.zemail_campaign_click_datetime=request.zos.mysqlnow;
					form.zr="";
					for(i=6;i LTE arraylen(arrpath);i++){
						if(i NEQ 6){
							form.zr&='.'&arrpath[i];
						}else{
							form.zr&=arrpath[i];
						}
					}
					if(isNumeric(ts.zemail_campaign_click_html) EQ false or isNumeric(ts.zemail_campaign_id) EQ false or isNumeric(ts.user_id) EQ false or isNumeric(ts.zemail_campaign_click_offset) EQ false){
						writeoutput('Access Denied');
						application.zcore.functions.zabort();
					}
					// used to track conversions
					application.zcore.tracking.setEmailCampaign(ts.zemail_campaign_id);
					
					// set type 1=open, 2=unsubscribe, 3=bounce, 4=click, 5=conversion, 6=outofoffice, 7=temporaryBounce, 8=challengeresponse, 9=antispamBounce, 10=other/replies - bounce must be handled by checking failed account and return emails
					if(left(form.zr,10) EQ '/zsa2/_eou'){ // kept for legacy behavior
						ts.zemail_campaign_click_type=2;
					}else if(left(form.zr,22) EQ '/zcorerootmapping/_eou'){
						ts.zemail_campaign_click_type=2;
					}else if(ts.zemail_campaign_click_offset EQ 0){
						ts.zemail_campaign_click_type=1; 
					}else{
						ts.zemail_campaign_click_type=4;
					}
					db.sql="INSERT INTO #db.table("zemail_campaign_click", request.zos.zcoreDatasource)#  
					SET zemail_campaign_click_type=#db.param(ts.zemail_campaign_click_type)#, 
					zemail_campaign_click_html=#db.param(ts.zemail_campaign_click_html)#, 
					zemail_campaign_click_offset=#db.param(ts.zemail_campaign_click_offset)#, 
					zemail_campaign_click_ip=#db.param(ts.zemail_campaign_click_ip)#, 
					zemail_campaign_click_datetime=#db.param(ts.zemail_campaign_click_datetime)#, 
					zemail_campaign_id=#db.param(ts.zemail_campaign_id)#, 
					user_id=#db.param(ts.user_id)#, 
					zemail_campaign_click_updated_datetime=#db.param(request.zos.mysqlnow)#,
					site_id=#db.param(request.zos.globals.id)#";
					db.execute("q"); 
					if(ts.zemail_campaign_click_offset EQ 0){
						// output tracking image and abort
						application.zcore.functions.zImageOutput(request.zos.globals.serverhomedir&'/a/images/s.gif','image/gif');
					}else{
						application.zcore.functions.zRedirect(replacenocase(replacenocase(form.zr,'http:/','http://'),'http:///','http://'));
					}
				}else{
					// invalid request - redirect to home page
					application.zcore.functions.zRedirect('/');
				}
			}
		}
		form.__zcoreinternalroutingpath=form.__zcoreinternalroutingpath_new;
		request.zos.tempScriptInclude="/zcorerootmapping/#form.__zcoreinternalroutingpath#";
		if(len(form.__zcoreinternalroutingpath)-4 LTE 0){
			application.zcore.functions.z301redirect('/');	
		}
		request.cgi_script_name="/z/_#left(form.__zcoreinternalroutingpath,len(form.__zcoreinternalroutingpath)-4)#";
	}else{
		request.zos.tempScriptInclude="/zcorerootmapping/#form.__zcoreinternalroutingpath#";
		if(len(form.__zcoreinternalroutingpath)-4 LTE 0){
			application.zcore.functions.z301redirect('/');	
		}
		request.cgi_script_name="/z/_#left(form.__zcoreinternalroutingpath,len(form.__zcoreinternalroutingpath)-4)#";
		Request.zOS.forceScriptName=request.zos.tempScriptInclude;
		if(find(","&left(form.__zcoreinternalroutingpath,4)&",", ',com/,') NEQ 0){
			request.zos.iscfc=true;
			Request.zOS.forceScriptName=listgetat(Request.zOS.forceScriptName,1,";");
			if(right(request.zos.forceScriptName,4) NEQ ".cfc"){
				request.zos.forceScriptName=request.zos.forceScriptName&".cfc";
			}
		}else if(find(","&left(form.__zcoreinternalroutingpath,2)&",", ',e/,') NEQ 0){
			// path is ok continue...
		}else{
			// server admin access denied - redirect to home page
			application.zcore.functions.zredirect('/');
		}
	}
	if(structkeyexists(request.zos,'iscfc') and structkeyexists(form,'method') and right(Request.zOS.forceScriptName,4) EQ '.cfc'){
		//application.zcore.template.prependErrorContent("There was an error while creating the component: #Request.zOS.forceScriptName#.");
		request.zos.tempcom=createobject("component",replace(replace(mid(Request.zOS.forceScriptName,2,len(Request.zOS.forceScriptName)-5),"\",".","ALL"),"/",".","ALL"));
		//application.zcore.template.replaceErrorContent("");
		if(structkeyexists(request.zos.tempcom,form.method) EQ false){
			application.zcore.template.fail("Method, #db.param(form.method)#, doesn't exist in #Request.zOS.forceScriptName#.");
		}
		request.zos.tempcommeta=GetMetaData(request.zos.tempcom[form.method]);
		if(request.zos.tempcommeta.access NEQ 'remote'){
			application.zcore.template.fail("Method, #db.param(form.method)#, doesn't allow 'remote' access in #Request.zOS.forceScriptName#. Access is set to '#request.zos.tempcommeta.access#'");
		}
		if(structkeyexists(request.zos.tempcommeta,'roles') and request.zos.tempcommeta.roles NEQ ""){
			if(request.zos.tempcommeta.roles NEQ "user"){
				request.zos.inMemberArea=true;
				application.zcore.skin.disableMinCat();
			}
			request._tempLoginRoles=request.zos.tempcommeta.roles;
			request._tempLoginSkip=false;
			if(request.zos.tempcommeta.roles EQ 'serveradministrator'){
				if(application.zcore.user.checkServerAccess()){
					request._tempLoginSkip=true;
				}else{
					request._tempLoginRoles="member";
				}
			}else if(request.zos.tempcommeta.roles EQ 'siteadministrator'){
				if(application.zcore.user.checkSiteAccess()){
					request._tempLoginSkip=true;
				}else{
					request._tempLoginRoles="member";
				}
			}
			if(request._tempLoginSkip EQ false){
				request.disableShareThis=true;
				inputStruct = StructNew();
				inputStruct.user_group_name=request._tempLoginRoles;
				if(request.zos.globals.requireSecureLogin EQ 1){
					inputStruct.secureLogin=true;
				}else{
					inputStruct.secureLogin=false;
				}
				inputStruct.noRedirect=false;
				inputStruct.site_id = request.zos.globals.id;
				application.zcore.user.setCustomTable(false);
				application.zcore.user.checkLogin(inputStruct); 
				application.zcore.template.setTemplate("zcorerootmapping.templates.administrator",true,true);
			}
		}
		request.zos.tempcom[form.method]();
	}else{
		include template="/zcorerootmapping/#form.__zcoreinternalroutingpath#";
	}
	</cfscript></cffunction>



<cffunction name="generateModProxyRewriteRules" localmode="modern" output="yes" returntype="any">
	<cfargument name="theC" type="string" required="yes">
	<cfargument name="proxyURL" type="string" required="yes">
	<cfscript>
    var local=structnew();
    arguments.theC=replace(arguments.theC,chr(13),"","all");
    arguments.theC=replace(arguments.theC,chr(9)," ","all");
    arguments.theC=replace(arguments.theC,chr(10)&chr(10),chr(10),"all");
    arguments.theC=replace(arguments.theC,chr(10)&chr(10),chr(10),"all");
    local.a1=listtoarray(arguments.theC,chr(10));
    local.b="/";
    local.c2="";
    local.r=arraynew(1);
    for(local.i=1;local.i LTE arraylen(local.a1);local.i++){
		local.a1[local.i]=replace(local.a1[local.i],"\\",chr(10),"all");
		local.a1[local.i]=replace(local.a1[local.i],"\ ",chr(9),"all");
        local.a2=listtoarray(trim(local.a1[local.i])," ",false);
		for(local.i4=1;local.i4 LTE arraylen(local.a2);local.i4++){
			local.a2[local.i4]=replace(replace(local.a2[local.i4],chr(10),"\\","all"),chr(9),"\ ","all");	
		}
        local.c="";
        if(arraylen(local.a2) NEQ 0){
            if(local.a2[1] CONTAINS "RewriteEngine") continue;
            if(local.a2[1] CONTAINS "RewriteMap") continue;
            if(local.a2[1] CONTAINS "RewriteBase"){
                continue;
            }else if(left(trim(local.a1[local.i]),1) EQ "##" or local.a2[1] CONTAINS "RewriteCond"){
				local.c2=local.a1[local.i]&chr(10);
				
                arrayappend(local.r, local.c2);
            }else if(local.a2[1] CONTAINS "RewriteRule"){
                arraydeleteat(local.a2, 1);
                if(left(trim(local.a2[1]),1) EQ "^"){
                    local.a2[1]=replace(local.a2[1],"^","^"&local.b,"one");
                }else{
                    local.a2[1]=b&local.a2[1];
                }
				if(left(local.a2[1],2) EQ "//"){
                	local.a2[1]=replace(local.a2[1],"//","/","one");
				}
                local.a2[2]=b&local.a2[2];
                    local.c&=chr(10)&'RewriteRule '&local.a2[1]&' ';
                local.a2[2]=replace(local.a2[2],"//","/","all");
                local.a2[2]=replace(local.a2[2],"/http:/","http://","all");
                local.a2[2]=replace(local.a2[2],"/https:/","https://","all");
				if(trim(local.a2[2]) EQ "/-"){
					local.a2[2]="-";	
				}
                if(arraylen(local.a2) EQ 2){
                	arrayappend(local.a2,'[L,QSA]');
				}
				if(local.a2[3] CONTAINS "R=301"){
                    // 301
                    local.c&=local.a2[2]&' [L,R=301,QSA]'&chr(10);
                }else{
                    local.t2=replace(local.a2[2],"\?","","ALL");
                    local.a3=listtoarray(local.t2,"?");
                    if(local.a2[3] CONTAINS "P," or (local.a2[3] CONTAINS ",P" and local.a2[3] DOES NOT CONTAIN ",PT") or local.a3[1] CONTAINS ".cfm" or local.a3[1] CONTAINS ".cfc"){
                        // passthrough coldfusion	
                        local.c&=' '&arguments.proxyURL&local.a2[2]&' [L,P,QSA]'&chr(10);
                    }else{
                        // static or non-cfml proxy
                        local.c&=' '&local.a2[2]&' '&local.a2[3]&chr(10);
                    }
                }
                arrayappend(local.r, local.c);
            }else{
                application.zcore.template.fail('Unknown rewriterule: '&local.a1[local.i]&'<br />');	
            }
        }
    }
    return arraytolist(local.r,"")&chr(10);
    </cfscript>
</cffunction>


<cffunction name="initRewriteRuleApplicationStruct" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var local=structnew();
	var ts=arguments.ss;
	var row=0;
	local.t9=structnew();
	local.ts2=structnew();
	local.ts2.uniqueURLStruct=structnew();
	local.ts2.reservedAppUrlIdStruct=structnew();
	local.t9.urlStruct=structnew();
	
	if(fileexists(request.zos.globals.homedir&"index.cfc")){
		local.t9.scriptName="/index.cfc";
		local.t9.urlStruct.method="index";
	}else if(fileexists(request.zos.globals.homedir&"index.cfm")){
		local.t9.scriptName="/index.cfm";
	}else if(fileexists(request.zos.globals.homedir&"content/index.cfm")){
		local.t9.scriptName="/content/index.cfm";
	}else if(fileexists(request.zos.globals.homedir&"home/index.cfm")){
		local.t9.scriptName="/home/index.cfm";
	}else if(fileexists(request.zos.globals.homedir&"index.html")){
		local.t9.scriptName="/index.html";
	}else{
		local.t9.scriptName="";
	}
	if(local.t9.scriptName NEQ ""){
		local.ts2.uniqueURLStruct["/"]=local.t9;
	}
	
	this.convertRewriteToStruct(local.ts2);
	
	db.sql="select * from #db.table("site_option_group", request.zos.zcoredatasource)# site_option_group
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_allow_public=#db.param(1)# and 
	site_option_group_deleted = #db.param(0)# and
	site_option_group_public_form_url<> #db.param('')# ";
	local.qS=db.execute("qS");
	for(local.row in local.qS){
		local.t9=structnew();
		local.t9.scriptName="/z/misc/display-site-option-group/add";
		local.t9.urlStruct=structnew();
		local.t9.urlStruct[request.zos.urlRoutingParameter]="/z/misc/display-site-option-group/add";
		local.t9.urlStruct.site_option_group_id=local.row.site_option_group_id;
		local.ts2.uniqueURLStruct[trim(local.row.site_option_group_public_form_url)]=local.t9;
	}
	// setup built in routing
	if(structkeyexists(request.zos.globals,'optionGroupURLID') and request.zos.globals.optionGroupURLID NEQ 0){
		local.ts2.reservedAppUrlIdStruct[request.zos.globals.optionGroupURLid]=[];
		local.t9=structnew();
		local.t9.type=1;
		local.t9.scriptName="/z/misc/display-site-option-group/index";
		local.t9.urlStruct=structnew();
		local.t9.urlStruct[request.zos.urlRoutingParameter]="/z/misc/display-site-option-group/index";
		local.t9.mapStruct=structnew();
		local.t9.mapStruct.urlTitle="zURLName";
		local.t9.mapStruct.dataId="site_x_option_group_set_id";
		arrayappend(local.ts2.reservedAppUrlIdStruct[request.zos.globals.optionGroupURLid], local.t9);
		db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoredatasource)# site_x_option_group_set
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		site_x_option_group_set_override_url<> #db.param('')# and 
		site_x_option_group_set_deleted = #db.param(0)# and
		site_x_option_group_set_approved=#db.param(1)#";
		local.qS=db.execute("qS");
		for(local.row in local.qS){
			local.t9=structnew();
			local.t9.scriptName="/z/misc/display-site-option-group/index";
			local.t9.urlStruct=structnew();
			local.t9.urlStruct[request.zos.urlRoutingParameter]="/z/misc/display-site-option-group/index";
			local.t9.urlStruct.site_x_option_group_set_id=local.row.site_x_option_group_set_id;
			local.ts2.uniqueURLStruct[trim(local.row.site_x_option_group_set_override_url)]=local.t9;
		}
	}
	
	// loop apps and call the function with ts sharedstruct
	 db.sql="SELECT app.app_id, app_x_site.site_id 
	 FROM #db.table("app", request.zos.zcoreDatasource)# app, 
	 #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
	WHERE app_x_site.site_id = #db.param(request.zos.globals.id)# and 
	app.app_built_in=#db.param(0)# and 
	app_x_site.app_x_site_status = #db.param('1')# and 
	app_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and
	app.app_id=app_x_site.app_id ";
	local.qApps=db.execute("qApps");
	for(row in local.qApps){
		local.configCom=createobject("component",application.zcore.appComPathStruct[row.app_id].cfcPath);
		local.configCom.setURLRewriteStruct(row.site_id,local.ts2);
	}
	if(fileexists(request.zos.globals.homedir&"zCoreCustomFunctions.cfc")){
		local.ts2.siteRewriteRuleCom=createobject("component",request.zRootCFCPath&"zCoreCustomFunctions");
	}
	ts.urlRewriteStruct=local.ts2;
	</cfscript>
</cffunction>


<cffunction name="deleteSiteOptionGroupSetUniqueURL" localmode="modern" output="yes" returntype="any">
	<cfargument name="site_x_option_group_set_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoredatasource)# site_x_option_group_set
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	site_x_option_group_set_deleted = #db.param(0)# and
	site_x_option_group_set_id = #db.param(arguments.site_x_option_group_set_id)# ";
	local.qS=db.execute("qS");
	if(local.qS.recordcount NEQ 0){
		if(local.qS.site_x_option_group_set_override_url NEQ ""){
			structdelete(application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct, trim(local.qS.site_x_option_group_set_override_url));
		}
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="updateSiteOptionGroupSetUniqueURL" localmode="modern" output="yes" returntype="any">
	<cfargument name="site_x_option_group_set_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoredatasource)# site_x_option_group_set
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	site_x_option_group_set_deleted = #db.param(0)# and
	site_x_option_group_set_id = #db.param(arguments.site_x_option_group_set_id)# and 
	site_x_option_group_set.site_x_option_group_set_approved=#db.param(1)# ";
	local.qS=db.execute("qS");
	if(local.qS.recordcount NEQ 0){
		local.t9=structnew();
		local.t9.scriptName="/z/misc/display-site-option-group/index";
		local.t9.urlStruct=structnew();
		local.t9.urlStruct[request.zos.urlRoutingParameter]="/z/misc/display-site-option-group/index";
		local.t9.urlStruct.site_x_option_group_set_id=local.qS.site_x_option_group_set_id;
		application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct[trim(local.qS.site_x_option_group_set_override_url)]=local.t9;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="processInternalURLRewrite" localmode="modern" output="yes" returntype="any">
	<cfargument name="theURL" type="string" required="yes">
	<cfscript>
	var local=structnew();
	local.newScriptName="";
	local.isDir=false;
	local.entireURL=trim(arguments.theURL);
	if(structkeyexists(form, 'zdebugurl') EQ false or form.zdebugurl EQ false){
		local.zdebugurl=false;
	}else{
		local.zdebugurl=form.zdebugurl;
	}
	
	if(local.newScriptName EQ ""){
		if(structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct,'siteRewriteRuleCom') and structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct.siteRewriteRuleCom, 'processURL')){
			local.tempVar=application.sitestruct[request.zos.globals.id].urlRewriteStruct.siteRewriteRuleCom.processURL(arguments.theURL, true);
			if(local.tempVar.scriptName NEQ ""){
				local.newScriptName=local.tempVar.scriptName;
				if(local.zdebugurl){
					writeoutput('siteRewriteRuleCom match:'&local.newScriptName&'<br />');
				}
			}
		}
	}
	if(local.newScriptName EQ ""){
		if(structkeyexists(application.zcore.urlRewriteStruct.redirectStruct, local.entireURL)){
			local.tempVar=application.zcore.urlRewriteStruct.redirectStruct[local.entireURL];
			if(structkeyexists(local.tempVar, 'urlStruct')){
				structappend(form, local.tempVar.urlStruct, true);
			}
			structdelete(form, request.zos.urlRoutingParameter);
			structdelete(form, 'fieldnames');
			structdelete(form, 'zdebugurl');
			local.arrU=[];
			for(local.i in form){
				if(isSimpleValue(form[local.i])){
					arrayappend(local.arrU, lcase(local.i)&"="&urlencodedformat(form[local.i]));
				}
			}
			local.tempLink=local.tempVar.url;
			if(arraylen(local.arrU)){
				local.tempLink&="?"&arraytolist(local.arrU, "&");	
			}
			if(local.zdebugurl){
				writeoutput('server redirectStruct match1<br />'&local.tempLink);
				application.zcore.functions.zabort();
			}else{
				application.zcore.functions.z301redirect(local.tempLink);
			}
		}
		if(structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct,'customRules')){
			if(structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.redirectStruct, local.entireURL)){
					if(local.zdebugurl) writeoutput('customRules.redirectStruct match<br />');
				application.zcore.functions.z301redirect(application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.redirectStruct[local.entireURL]);	
			}
			if(structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.uniqueStruct, local.entireURL)){
				if(application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.uniqueStruct[local.entireURL].cfml){
					if(local.zdebugurl) writeoutput('customRules.uniqueStruct match<br />');
					// set vars	
					structappend(form, application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.uniqueStruct[local.entireURL].vs, true);
					local.newScriptName=application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.uniqueStruct[local.entireURL].url;
				}else{
					local.path=application.zcore.functions.zGetDomainInstallPath(application.zcore.functions.zvar("shortDomain", request.zos.globals.id))&removechars(application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.uniqueStruct[local.entireURL].url,1,1);
					writeoutput(application.zcore.functions.zreadfile(local.path));
					application.zcore.functions.zabort();
				}
			}
			for(local.i in application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.wildcardRedirectStruct){
				if(compare(left(local.entireURL, len(local.i)), local.i) EQ 0){
					application.zcore.functions.z301redirect(application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.wildcardRedirectStruct[local.i]);
				}
			}
		}
		
		if(structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct, local.entireURL)){
			local.backupOriginal=form[request.zos.urlRoutingParameter];
			if(local.zdebugurl) writeoutput("unique url match:"&local.entireURL&"<br />");
			if(local.zdebugurl) writedump(application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct[local.entireURL]);
			local.curApp=application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct[local.entireURL];
			if(right(local.curApp.scriptName,5) EQ ".html"){
				writeoutput(application.zcore.functions.zreadfile(request.zos.globals.homedir&removeChars(local.curApp.scriptName,1,1)));
				application.zcore.functions.zabort();
			}
			structappend(url,  local.curApp.urlStruct, true);
			structappend(form, local.curApp.urlStruct, true);
			local.newScriptName=local.curApp.scriptName;
			form[request.zos.urlRoutingParameter]=local.backupOriginal;
			if(local.entireURL EQ "/" and request.zos.globals.id EQ request.zos.globals.serverId){
				request.zos.scriptNameTemplate="zcorerootmapping/"&removechars(local.newScriptName,1,1);
				if(structkeyexists(form,'method') EQ false){
					form.method="index";
				}
			}
		}else{
			if(right(local.entireURL, 5) EQ ".html"){
				local.ext="html";
			}else if(right(local.entireURL, 4) EQ ".xml"){
				local.ext="xml";	
			}else if(right(local.entireURL, 4) EQ ".cfm"){
				local.ext="cfm";	
			}else{
				local.ext="";	
			}
			if(local.zdebugurl) writeoutput("local.ext:"&local.ext&"<br />");
			if(left(local.entireURL, 5) EQ "/z/_e"){
				form.__zcoreinternalroutingpath=mid(local.entireURL,5, len(local.entireURL)-4)&".cfm";
				local.newScriptName=local.entireURL;
				if(local.zdebugurl) writeoutput(form.__zcoreinternalroutingpath&"|1<br />");
				
			}else if(left(local.entireURL, 7) EQ "/z/_com"){
				form.__zcoreinternalroutingpath=mid(local.entireURL,5, len(local.entireURL)-4)&".cfc";
				if(local.zdebugurl) writeoutput(form.__zcoreinternalroutingpath&"|2<br />");
				local.newScriptName=local.entireURL;
			}else if(left(local.entireURL, 5) EQ "/z/-e"){
				form.__zcoreinternalroutingpath="-"&mid(local.entireURL,5, len(local.entireURL)-4);
				local.newScriptName=local.entireURL;
				if(local.zdebugurl) writeoutput(form.__zcoreinternalroutingpath&"|3<br />");
			}else if(right(local.entireURL,1) EQ "/"){
				local.tempPath=Request.zOSHomeDir&removeChars(local.entireURL,1,1);
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, local.tempPath&"index.cfm") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.cfm"]=fileexists(local.tempPath&"index.cfm");
				} 
				
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, local.tempPath&"index.cfc") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.cfc"]=fileexists(local.tempPath&"index.cfc");
				}
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, local.tempPath&"index.htm") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.htm"]=fileexists(local.tempPath&"index.htm");
				}
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, local.tempPath&"index.html") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.html"]=fileexists(local.tempPath&"index.html");
				}
				if(application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.cfm"]){
					local.newScriptName=local.entireURL&"index.cfm";
					request.zos.scriptNameTemplate=request.zRootPath&removechars(local.newScriptName,1,1);
					form.__zcoreinternalroutingpath="";
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.cfc"]){
					local.newScriptName=local.entireURL&"index.cfc";
					request.zos.scriptNameTemplate=request.zRootPath&removechars(local.newScriptName,1,1);
					form.__zcoreinternalroutingpath="";
					if(structkeyexists(form,'method') EQ false){
						form.method="index";
					}
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.htm"]){
					writeoutput(application.zcore.functions.zreadfile(request.zos.globals.homedir&removeChars(local.entireURL,1,1)&"index.htm"));
					application.zcore.functions.zabort();
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.html"]){
					writeoutput(application.zcore.functions.zreadfile(request.zos.globals.homedir&removeChars(local.entireURL,1,1)&"index.html"));
					application.zcore.functions.zabort();
				}else{
					
					if(request.zos.themePath NEQ ""){
						local.newScriptName=request.zos.themePath&"index.cfc";
						request.zos.scriptNameTemplate=request.zos.themePath&removechars(local.newScriptName,1,1);
						form.__zcoreinternalroutingpath="";
						if(structkeyexists(form,'method') EQ false){
							form.method="index";
						}
					}else{
						local.isDir=true;
					}
				}
				if(local.zdebugurl) writeoutput('got in4:'&local.entireURL&"<br />");
			}else if(local.ext EQ "cfm" or local.ext EQ "cfc"){
				local.tempPath=Request.zOSHomeDir&removeChars(local.entireURL,1,1);
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, local.tempPath) EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath]=fileexists(local.tempPath);
				}
				if(application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath]){
					local.newScriptName=local.entireURL;
					request.zos.scriptNameTemplate=request.zRootPath&removechars(local.newScriptName,1,1);
					form.__zcoreinternalroutingpath="";
					if(structkeyexists(form,'method') EQ false){
						form.method="index";
					}
				}else{
					if(local.zdebugurl){
						writeoutput(expandpath(local.entireURL)&"| was 404 - second one<br />");
						application.zcore.functions.zabort();
					}else{
						application.zcore.functions.z404("processInternalURLRewrite(): "&expandpath(local.entireURL)&"| was 404 - second one<br />");
					}
				}
			}else if(local.ext EQ "html" or local.ext EQ "xml"){
				if(local.ext EQ "html"){
					local.arrT=listtoarray(left(local.entireURL, len(local.entireURL)-5), "-",true);
				}else{
					local.arrT=listtoarray(left(local.entireURL, len(local.entireURL)-4), "-",true);
				}
				local.count=arraylen(local.arrT);
				if(local.zdebugurl) writeoutput('got in3:'&local.entireURL&"<br />");
				local.urlMatched=false;
				if(local.count GTE 3){
					// check for title-1-2
					local.dataId=local.arrT[local.count];
					local.appId=local.arrT[local.count-1];
					arraydeleteat(local.arrT,local.count);
					arraydeleteat(local.arrT,local.count-1);
					local.urlTitle=removechars(arraytolist(local.arrT,"-"),1,1);
					
					if(local.zdebugurl) writeoutput('local.dataID:'&local.dataID&'<br />local.appId:'&local.appId&'<br />local.urlTitle:'&local.urlTitle&'<br />');
					if(local.zdebugurl) writeoutput('got in2:'&local.entireURL&"<br />");
					if(structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct.reservedAppUrlIdStruct, local.appId)){
						if(local.zdebugurl) writeoutput('got in:'&local.entireURL&"<br />");
						
						if(local.zdebugurl) writedump(application.sitestruct[request.zos.globals.id].urlRewriteStruct.reservedAppUrlIdStruct[local.appId]);
						
						for(local.n=1;local.n LTE arraylen(application.sitestruct[request.zos.globals.id].urlRewriteStruct.reservedAppUrlIdStruct[local.appId]);local.n++){
							local.curApp=application.sitestruct[request.zos.globals.id].urlRewriteStruct.reservedAppUrlIdStruct[local.appId][local.n];
							local.newScriptName=local.curApp.scriptName;
							if(structkeyexists(local.curApp, 'ifStruct')){
								// test conditions - it doesn't match, then continue;
								local.ifMatch=true;
								for(local.i2 in local.curApp.ifStruct){
									if(local[local.i2] NEQ local.curApp.ifStruct[local.i2]){
										local.ifMatch=false;
										break;
									}
								}
								if(local.ifMatch EQ false){
									continue;
								}
							}
							if(local.curApp.type EQ 1){
								// numeric
								if(isNumeric(local.dataId)){
									local.urlMatched=true;	
								}
							}else if(local.curApp.type EQ 2){
								// alphanumeric (including other punctuation like underscore - always match
								local.urlMatched=true;
							}else if(local.curApp.type EQ 3){
								// numeric with optional pagenav
								local.arrDataId=listToArray(local.dataId,"_");
								local.dataIdCount=arraylen(local.arrDataId);
								if(local.dataIdCount EQ 1){
									local.dataId=local.arrDataId[1];
									local.urlMatched=true;	
								}else if(local.dataIdCount EQ 2){
									// has pagenav set
									local.dataId=local.arrDataId[1];
									local.dataId2=local.arrDataId[2];
									local.urlMatched=true;	
								}else{
									// unknown multiple page nav or other
								}
							}else if(local.curApp.type EQ 4){
								// blog archive date
								if(local.count GTE 5){
									local.tempYear=local.arrT[local.count-3];
									local.tempMonth=local.arrT[local.count-2];
									if(len(local.tempYear) EQ 4 and len(local.tempMonth) EQ 2 and isNumeric(local.tempYear) and isNumeric(local.tempMonth)){
										local.dataId2=local.tempYear&"-"&local.tempMonth;
										local.urlMatched=true;	
									}
								}
							}else if(local.curApp.type EQ 5){
								// rental photo url
								if(local.count GTE 5){
									if(local.arrT[local.count-3] EQ "Photo"){
										local.dataId2=local.arrT[local.count-2];
										local.urlMatched=true;
									}
								}
							}else if(local.curApp.type EQ 6){
								// 2 numerics with optional pagenav
								local.arrDataId=listToArray(local.dataId,"_");
								local.dataIdCount=arraylen(local.arrDataId);
								if(local.dataIdCount EQ 2){
									local.dataId=local.arrDataId[1];
									local.dataId2=local.arrDataId[2];
									local.urlMatched=true;	
								}else if(local.dataIdCount EQ 3){
									// has pagenav set
									local.dataId=local.arrDataId[1];
									local.dataId2=local.arrDataId[2];
									local.dataId3=local.arrDataId[3];
									local.urlMatched=true;	
								}else{
									// unknown multiple page nav or other
								}
							}
							if(local.urlMatched){
								if(local.zdebugurl) writeoutput('Matched: '&local.n&'<br />');
								// copy urlStruct to url
								structappend(form,  local.curApp.urlStruct, true);
								structappend(form, local.curApp.urlStruct, true);
								for(local.i2 in local.curApp.mapStruct){
									if(structkeyexists(local, local.i2)){
										url[local.curApp.mapStruct[local.i2]]=local[local.i2];
									}else{
										if(local.zdebugurl) writedump(local.i2&' doesn''t exist<br />');
									}
								}
								if(local.zdebugurl) writedump(url);
								break;
							}
						}
					}
				}else{
					// some other kind of url	
				}
				if(local.urlMatched EQ false){
					// unknown url
					if(local.zdebugurl){
						writeoutput('not matched:'&local.entireURL&'<br />');
					}
				}else{
					if(local.zdebugurl){
						writeoutput('advanced match:'&local.newScriptName&'<br />');
					}
				}
			}
		}
	}
	//writedump(application.sitestruct[request.zos.globals.id].urlRewriteStruct);
	if(local.newScriptName EQ ""){
		if(structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct,'siteRewriteRuleCom') and structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct.siteRewriteRuleCom, 'processURL')){
			local.tempVar=application.sitestruct[request.zos.globals.id].urlRewriteStruct.siteRewriteRuleCom.processURL(arguments.theURL, false);
			if(local.tempVar.scriptName NEQ ""){
				local.newScriptName=local.tempVar.scriptName;
				if(local.zdebugurl){
					writeoutput('siteRewriteRuleCom match:'&local.newScriptName&'<br />');
				}
			}
		}
	}
	if(local.newScriptName EQ ""){
		local.tempPath=Request.zOSHomeDir&removeChars(local.entireURL,1,1);
		if(structkeyexists(application.sitestruct[request.zos.globals.id].directoryExistsCache, local.tempPath) EQ false){
			application.sitestruct[request.zos.globals.id].directoryExistsCache[local.tempPath]=directoryexists(local.tempPath);
		}
		if(application.sitestruct[request.zos.globals.id].directoryExistsCache[local.tempPath]){
			if(right(local.entireURL,1) NEQ "/"){
				local.tempPath=Request.zOSHomeDir&removeChars(local.entireURL,1,1)&"/";
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, local.tempPath&"index.cfm") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.cfm"]=fileexists(local.tempPath&"index.cfm");
				}
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, local.tempPath&"index.cfc") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.cfc"]=fileexists(local.tempPath&"index.cfc");
				}
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, local.tempPath&"index.php") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.php"]=fileexists(local.tempPath&"index.php");
				}
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, local.tempPath&"index.htm") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.htm"]=fileexists(local.tempPath&"index.htm");
				}
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, local.tempPath&"index.html") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.html"]=fileexists(local.tempPath&"index.html");
				}
				// might still have .cfm or .cfc index
				if(application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.cfm"]){
					local.newPath=local.entireURL&"/";
					application.zcore.functions.z301redirect(local.newPath);
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.cfc"]){
					local.newPath=local.entireURL&"/";
					application.zcore.functions.z301redirect(local.newPath);
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.php"]){
					local.newPath=local.entireURL&"/";
					application.zcore.functions.z301redirect(local.newPath);
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.htm"]){
					local.newPath=local.entireURL&"/";
					application.zcore.functions.z301redirect(local.newPath);
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[local.tempPath&"index.html"]){
					local.newPath=local.entireURL&"/";
					application.zcore.functions.z301redirect(local.newPath);
				}else{
					// application.zcore.functions.z404("processInternalURLRewrite() newScriptName was empty and there was no default index file");
				}
			}else{
				application.zcore.functions.z404("processInternalURLRewrite() newScriptName was empty and this is not a directory.");
			}
		}else{
			local.newScriptName=arguments.theURL;
		}
	}
	if(local.newScriptName EQ ""){
		if(local.zdebugurl){
			writeoutput('unknown url:'&local.entireURL&'<br />');
			application.zcore.functions.zabort();
		}
	}else{
		if(request.zos.isDeveloper){
			if(local.zdebugurl){
				writedump(url, true, 'simple');
				writedump(cgi, true, 'simple');
				
				writeoutput('going to be this url:'&local.newScriptName&'<br />');
				
			}
		}
		request.zos.scriptNameTemplate=local.newScriptName;
	}
	//n=c;
	if(local.zdebugurl){
		writeoutput("original:"&local.entireURL&"<br />translated:"&local.newScriptName&"<br />__zcoreinternalroutingpath:"&application.zcore.functions.zso(form, '__zcoreinternalroutingpath'));
		writeoutput('<hr />');
	}
	return local.newScriptName;
	
	</cfscript>
    
</cffunction>
    


<cffunction name="convertRewriteToStruct" localmode="modern" output="no" returntype="any"><cfargument name="sharedStruct" type="struct" required="yes"><cfscript>
	var local=structnew();
	var db=request.zos.queryObject;
	 db.sql="SELECT site.site_domain, rewrite_rule.* FROM #db.table("site", request.zos.zcoreDatasource)# site, 
	 #db.table("rewrite_rule", request.zos.zcoreDatasource)# rewrite_rule 
	WHERE site.site_id = rewrite_rule.site_id AND site.site_active= #db.param(1)# and 
	rewrite_rule_deleted = #db.param(0)# and 
	site_deleted = #db.param(0)# and 
	CONCAT(rewrite_rule_image,rewrite_rule_zsa, rewrite_rule_site) <> #db.param('')# and 
	site.site_id = #db.param(request.zos.globals.id)#";
	local.qR=db.execute("qR");
	local.specialRuleStruct=structnew();
	local.totalSpecialCount=0;
	loop query="local.qR"{
		local.rzsa=replacelist(rereplace(local.qR.rewrite_rule_zsa, "##[^\n]*","","all"),'^,\',',');
		local.rsite=replacelist(rereplace(local.qR.rewrite_rule_site, "##[^\n]*","","all"),'^,\',',');
		local.rimage=replacelist(rereplace(local.qR.rewrite_rule_image, "##[^\n]*","","all"),'^,\',',');
		local.arrR=arraynew(1);
		arrayappend(local.arrR,listtoarray(local.rzsa,chr(10),false));
		arrayAppend(local.arrR,listtoarray(local.rsite,chr(10),false));
		arrayAppend(local.arrR,listtoarray(local.rimage,chr(10),false));
		
		local.ts=structnew();
		local.ts.redirectStruct=structnew();
		local.ts.wildcardRedirectStruct=structnew();
		local.ts.wildcardSpecialStruct=structnew();
		local.ts.uniqueStruct=structnew();
		local.ts.requestStruct=structnew();
		
		
		local.tempSkipURL=structnew();
		local.tempSkipURL["/(.*(.gif|.jpg|.png|.css|.js))"]=true;
		local.tempSkipURL["/livezilla/.*"]=true;
		local.tempSkipURL["/(.*)/(.*).html"]=true;
		//local.tempSkipURL["/(.*).html"]=true;
		//local.tempSkipURL[""]=true;
	
		for(local.n=1;local.n LTE arraylen(local.arrR);local.n++){
			for(local.i=1;local.i LTE arraylen(local.arrR[local.n]);local.i++){
				// detect rewrite rule type
				local.cur=trim(local.arrR[local.n][local.i]);
				if(local.cur EQ "") continue;
				local.a301=false;
				local.aProxy=false;
				local.aWildCard=false;
				local.aWildCard2=false;
				local.aCFML=false;
				if(right(local.cur,10) CONTAINS 'R=301'){
					local.a301=true;
				}
				if(right(local.cur,10) CONTAINS ',P' or right(local.cur,10) CONTAINS 'P,' or right(local.cur,10) CONTAINS '[P' or right(local.cur,10) CONTAINS 'P]'){
					local.aProxy=true;
				}
				if(left(local.cur, len("RewriteRule")) EQ "RewriteRule"){
					local.cur="/"&removechars(local.cur, 1, len("RewriteRule")+1);
					local.arrC=listtoarray(local.cur, "$", true);
					local.newCount=arraylen(local.arrC);
					local.arrC[1]=trim(local.arrC[1]);
					if(right(local.arrC[1],2) EQ ".*"){
						local.aWildCard=true;
					}else if(local.arrC[1] CONTAINS ".*" or local.arrC[1] CONTAINS "[" or local.arrC[1] CONTAINS "*"){
						local.aWildCard2=true;	
					}
					local.sUrl=local.arrC[1];
					if(structkeyexists(local.tempSkipURL, local.sUrl)){
						continue;	
					}
					arraydeleteat(local.arrC,1);
					local.dUrl=arraytolist(local.arrC,"$");
					if(local.newCount GTE 2){
						local.pos=find("[", local.dUrl);
						if(local.pos NEQ 0){
							local.dUrl=left(local.dUrl, local.pos-1);
						}
						local.dUrl=trim(local.dUrl);
						if(left(local.dUrl,4) EQ "http"){
							// don't change url
						}else if(left(local.dUrl,1) NEQ "/"){
							local.dUrl="/"&local.dUrl;
						}
					}else{
						writeoutput('Broken url:'&local.cur&'<br />');	
					}
					if(local.dUrl EQ "/-"){
						local.dUrl="-";
					}
					if(local.dUrl CONTAINS ".cfm" or local.dUrl CONTAINS ".cfc"){
						local.aCFML=true;
					}
					if(local.aWildCard2){
						writeoutput('special rule: '&local.sUrl&' | '&local.cur&'<br />');
						local.ts.wildcardSpecialStruct[local.sUrl]=local.dUrl;
					}else{
						if(local.a301){
							if(local.aWildCard){
								//writeoutput('wildcard: ');
								local.ts.wildcardRedirectStruct[left(local.sUrl,len(local.sUrl)-2)]=local.dUrl;
							}else{
								local.ts.redirectStruct[local.sUrl]=local.dUrl;
							}
						}else{
							if(local.aWildCard){
								application.zcore.template.fail('requestStruct is never used - wildcard: probably needs to be removed: '&local.sUrl&"<br />"&local.dUrl);
								local.t9=structnew();
								local.t9.url=local.dUrl;
								local.t9.cfml=local.aCFML;
								local.ts.requestStruct[local.sUrl]=local.t9;
								writeoutput(' map '&local.sUrl&' to '&local.dUrl&'<br />');
							}else{
								local.t9=structnew();
								local.t9.url=replacelist(local.dUrl,"$1,$2,$3,$4,$5,$6",",,,,,");
								local.t9.cfml=local.aCFML;
								local.t9.vs=structnew();
								local.arrT=listtoarray(local.t9.url,"?");
								local.t9.url=local.arrT[1];
								writeoutput(' setup unique '&local.sUrl&' to '&local.dUrl&'<br />');
								if(arraylen(local.arrT) EQ 2){
									local.arrTF=listtoarray(local.arrT[2], "&");
									for(local.i2=1;local.i2 LTE arraylen(local.arrTF);local.i2++){
										local.arrTFV=listToArray(local.arrTF[local.i2], "=", true);
										local.t9.vs[local.arrTFV[1]]=URLDecode(local.arrTFV[2]);
									}
								}else if(arraylen(local.arrT) GT 2){
									application.zcore.template.fail("invalid destination url:"&local.tempURL);
								}
								local.ts.uniqueStruct[local.sUrl]=local.t9;
							}
						}
					}
				}else if(left(local.cur, len("RewriteRule")) EQ "RewriteCond"){
					writeoutput('rewritecond:'&local.cur&'<br />');
				}else{
					writeoutput('unknown url:'& local.cur&'<br />');	
				}
				
			}
		}
		arguments.sharedStruct.customRules=local.ts;
	};
	return;
	</cfscript>
</cffunction>


    </cfoutput>
</cfcomponent>