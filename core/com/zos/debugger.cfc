<cfcomponent displayname="Debugger" output="no">
<cfoutput><cffunction name="init" localmode="modern" returntype="any" output="false">
  <cfscript>
		var i = 0;
		if(request.zos.isdeveloper){
			if(Request.zOS.debuggerEnabled EQ false){
				return "";
			}
			if(isDefined('session.zOS.modes') EQ false){
				session.zOS.modes = StructNew();
			}
			if(structkeyexists(form, 'zOS_mode')){
				if(form.zOS_Mode EQ 'VerifyQueries'){
					if(form.zOS_modeValue EQ "true"){
						session.zos.verifyQueries=true;
					}else{
						session.zos.verifyQueries=false;
					}
				}
				if(structkeyexists(form, 'zOS_modeValue') and form.zOS_modeValue){
					session.zOS.modes[form.zOS_Mode] = true;
					if(form.zOS_Mode EQ 'varDump' and structkeyexists(form, 'zOS_modeVarDumpName')){
						session.zOS.modes.varDumpName = form.zOS_modeVarDumpName;
					} 
				}else{
					StructDelete(session.zOS.modes, form.zOS_Mode);
				}
			}
		}
		</cfscript>
</cffunction>

<cffunction name="outputDebugBarTag" localmode="modern" output="yes" returntype="string">
	<cfscript>
	if(request.zos.isDeveloper or request.zos.isTestServer){
		echo('##zDebugBar##');
	}
	</cfscript>
</cffunction>

<cffunction name="getForm" localmode="modern" output="false" returntype="struct">
  <cfscript>
		var returnString = "";
		var returnString2="";
		var returnStruct = StructNew();
		var arrURL = ArrayNew(1);
		if(Request.zOS.debuggerEnabled EQ false){
			return {returnString:"", returnString2:""};
		}
		Request.zOS.modes.time.end = GetTickCount();
		</cfscript>
  <cfsavecontent variable="returnString">
	<cfif request.zos.isdeveloper>
	<br style="clear:both;" />
	<cfscript>
	returnStruct = application.zcore.functions.zGetRepostStruct();
	</cfscript> 
    <form name="zOS_mode_form" id="zOS_mode_form" onsubmit="return zOS_mode_check();" action="<cfif structkeyexists(form,  request.zos.urlRoutingParameter)>#form[request.zos.urlRoutingParameter]#<cfelse>#request.zos.cgi.script_name#</cfif><cfif returnStruct.urlString NEQ "">?#htmleditformat(replacenocase(returnStruct.urlString,'zdisablesystemcaching=','ztv=','all'))#</cfif>" method="post">
      <input type="hidden" name="zOS_mode" id="zOS_mode" value="debug" />
      <input type="hidden" name="zOS_modeValue" id="zOS_modeValue" value="true" />
	#returnStruct.formString#  
      <div <!--- onmouseover="zOS_mode_show();" onmouseout="zOS_mode_hide();" ---> style="width:99%; float:left; ">
        <div class="zOS_mode_table" id="zOS_mode_table_tag" style="width:100%;display:block; ">
          <div class="zOS_mode_td">Developer Toolbar | 
              Reset: ( <a href="##" onclick="zOS_mode_submit('reset','true','code');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" ---> class="zOS_mode_link">Code</a> | 
              <a href="##" onclick="zOS_mode_submit('reset','true','app');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" ---> class="zOS_mode_link">App</a> | 
	      <a href="##" onclick="zOS_mode_submit('reset','true','app', '&amp;zforce=1');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" ---> class="zOS_mode_link">App &amp; Skin</a> | 
	      <a href="##" onclick="zOS_mode_submit('reset','true','app', '&amp;zforcelisting=1');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" ---> class="zOS_mode_link">App &amp; Listing</a> | 
	      <a href="##" onclick="zOS_mode_submit('reset','true','app','&amp;zforcelisting=1&amp;zrebuildramtable=1');return false;"  <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->>App &amp; DB Ram</a> | 
	      <a href="##" onclick="zOS_mode_submit('reset','true','template');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" ---> class="zOS_mode_link">Template</a> | 
	      <a href="##" onclick="zOS_mode_submit('reset','true','site');return false;"  <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->>Site</a> | 
	      <a href="##" onclick="zOS_mode_submit('reset','true','session');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->>Session</a> | 
              <a href="##" onclick="zOS_mode_submit('reset','true','all');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->>All</a> | 
              <a href="##" onclick="zOS_mode_submit('reset','true','all', '&amp;zforce=1');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" ---> class="zOS_mode_link">All &amp; Skin Cache Rebuild</a> ) <a href="##" onclick="zOS_mode_submit('reset','true','cache');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->>Rebuild Global Files</a></div>
            <div class="zOS_mode_td"> Component Cache: <cfif request.zos.disableSystemCaching><a href="##" onclick="document.zOS_mode_form.zOS_mode.value='';document.zOS_mode_form.action+='<cfif returnStruct.urlString NEQ "">&amp;<cfelse>?</cfif>zdisablesystemcaching=false'; document.zOS_mode_form.submit(); return false;">Off</a><cfelse><a href="##" onclick="document.zOS_mode_form.zOS_mode.value='';document.zOS_mode_form.action+='<cfif returnStruct.urlString NEQ "">&amp;<cfelse>?</cfif>zdisablesystemcaching=true'; document.zOS_mode_form.submit(); return false;">On</a></cfif> | Debug:
            
              <cfif isDefined('session.zOS.modes.debug')>
                <a href="##" onclick="zOS_mode_submit('debug','false');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->>On</a>
                <cfelse>
                <a href="##" onclick="zOS_mode_submit('debug','true');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->>Off</a>
              </cfif>
              | Time:
              <cfset session.zOS.modes.time=true>
              <cfif isDefined('session.zOS.modes.time')>
                <a href="##" onclick="zOS_mode_submit('time','false');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->>On</a>
                <cfelse>
                <a href="##" onclick="zOS_mode_submit('time','true');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->>Off</a>
              </cfif>
              <br />Var Dump:
              <cfif isDefined('session.zOS.modes.varDump')>
#session.zOS.modes.varDumpName#                                                                            &nbsp; <a href="##" onclick="zOS_mode_submit('varDump','false');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->>On</a>
                <input type="hidden" name="zOS_modeVarDumpName" id="zOS_modeVarDumpName" value="" class="zOS_modeInput" />
                <cfelse>
                <input type="text" name="zOS_modeVarDumpName" id="zOS_modeVarDumpName" value="" class="zOS_modeInput" />
                &nbsp; <a href="##" onclick="zOS_mode_submit('varDump','true');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->>Off</a>
              </cfif>
              
              | Verify Queries: 
            	<cfif isDefined('session.zos.verifyQueries') and session.zos.verifyQueries>
                 <a href="##" onclick="zOS_mode_submit('VerifyQueries','false');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->>On</a>
                <cfelse>
                &nbsp; <a href="##" onclick="zOS_mode_submit('VerifyQueries','true');return false;" <!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->>Off</a>
                </cfif>
		<cfif request.zos.isTestServer>
			<br />
			Deploy: 
			<a href="/z/server-manager/admin/deploy/index?sid=#request.zos.globals.id#" target="_blank">Site</a> | 
			<a href="/z/server-manager/admin/deploy/deployCore" target="_blank">Core</a> | 
			<a href="/z/server-manager/admin/deploy/deployPublic" target="_blank">Public</a>
		</cfif>
              </div>
            <div class="zOS_mode_td">
              <cfif isDefined('session.zos.tracking.track_user_hits')>Hits: #session.zos.tracking.track_user_hits#</cfif>
              <cfif isDefined('session.zlistingpageviewcount')> Listing Pages: #session.zlistingpageviewcount#</cfif>
              <cfif isDefined('session.zlistingdetailhitcount')>  Detail Hits: #session.zlistingdetailhitcount#</cfif>
              
              <cfscript>
			if(structkeyexists(form, 'zOS_viewXHTMLError')){
				XMLParse(request.zos.debuggerFinalString);
				writeoutput('This page is XHTML 1.0 Compliant');
			}
			</cfscript>
              <cfif isDefined('session.zOS.modes.validateXHTML')>
                <cfscript>
			StructDelete(session.zOS.modes, 'validateXHTML');
			try{
				XMLParse(request.zos.debuggerFinalString);
				writeoutput('This page is XHTML 1.0 Compliant');
			}catch(Any excpt){
				writeoutput('XHTML 1.0 Validation failed. <a href="##" onclick="zOS_mode_submit(''validateXHTML'',''true'',''true'');return false;" >View Error</a>');//<!--- onmouseover="zOS_mode_status();" onmousemove="zOS_mode_status();" onmouseout="zOS_mode_status_off();" --->
			}
			</cfscript>
              </cfif>
	      ##zdebuggerTimeOutput##</div>
          </div>
          </cfif>
  </cfsavecontent>
  <cfsavecontent variable="returnString2"><cfif request.zos.isdeveloper></div></form></cfif></cfsavecontent>
  
  <cfset returnString = replace(returnString, chr(10), "", "ALL")>
  <cfset returnString = replace(returnString, chr(13), "", "ALL")>
  <cfset returnString = replace(returnString, chr(9), "", "ALL")>
  <cfif structkeyexists(form, 'zOS_viewAsXML')>
	<cfcontent type="text/xml">
	<cfscript>
	returnString = "";
	returnString2 = "";
	</cfscript>
  </cfif> 
  <cfreturn {returnString:returnString, returnString2:returnString2}>
</cffunction>

<cffunction name="getOutput" localmode="modern" output="false" returntype="string">
  <cfscript>
		var returnString = "";
		var styleString = "";
		var dumpcode = "";
		if(Request.zOS.debuggerEnabled EQ false){
			return "";
		}
		</cfscript>
  
  <cfsavecontent variable="styleString">
  <style type="text/css">
			.zOS_mode_table {
				background-color:##FFFFFF;
				color:##000000;
				font-family: Arial, Helvetica, sans-serif;
				font-size: 10px;
				border: 1px solid ##999999;
			}
			.zOS_mode_td {
				background-color:##FFFFFF;
				color:##000000;
				font-family: Arial, Helvetica, sans-serif;
				font-size: 10px;
				border: 0px solid ##999999;
				font-weight:bold;
			}
			body {
			margin-left: 0px;
			margin-top: 0px;
			margin-right: 0px;
			margin-bottom: 0px;
			}
			</style>
  </cfsavecontent>
  <cfsavecontent variable="returnString">
  <cfscript>
			try{
				if(isDefined('session.zOS.modes.varDump')){
					writeoutput('Dumping: '&session.zOS.modes.varDumpName&'<br /><br />');
					if(find("(", session.zOS.modes.varDumpName) EQ 0){ 
						if(isDefined(session.zOS.modes.varDumpName)){
							if(session.zOS.modes.varDumpName EQ 'request.zos.templateData.tagContent'){
								StructDelete(request.zos.templateData.tagContent, 'content');
							}
							application.zcore.functions.zDump(evaluate(session.zOS.modes.varDumpName),session.zOS.modes.varDumpName,false);
						
						}else if(isDefined('Request.zOS.currentScript.variables.#session.zOS.modes.varDumpName#')){
							application.zcore.functions.zDump(Request.zOS.currentScript.variables[session.zOS.modes.varDumpName],session.zOS.modes.varDumpName,false);
						
						}else{
							writeoutput("{missing variable}");
						}
					}
					writeoutput("</td></tr><tr><td style=""vertical-align:top; border:1px solid ##999999"">");
				}
			}catch(Any excpt){
				// nothing
			}
			if(isDefined('session')){
				request._______mysession = duplicate(session);
				if(isDefined('request._______mysession.zos')){
					StructDelete(request._______mysession.zos, 'statusstruct');
					StructDelete(request._______mysession.zos, 'ZOSDEBUGGERLASTOUTPUT');
				}
			}
			if(isDefined('application.zcore.functions.zdump')){
				request.tempZdump = application.zcore.functions.zdump;
			}
			StructDelete(request, 'cfdumpinited');
			</cfscript>
  <cfif isDefined('session.zOS.modes.debug')>
    Debug Output (Components and functions were removed)<br />
    <br />
    <cfif isDefined('form') and StructCount(form) NEQ 0>
      <cfscript>
					writeoutput(request.tempZdump(form,'FORM',false));
					</cfscript>
      <br />
      <br />
    </cfif>
    <cfif isDefined('request._______mysession')>
      <cfscript>
					writeoutput(request.tempZdump(request._______mysession,'SESSION',false));
					</cfscript>
      <br />
      <br />
    </cfif>
    <cfif isDefined('cookie')>
      <cfscript>
					writeoutput(request.tempZdump(cookie,'COOKIE',false));
					</cfscript>
      <br />
      <br />
    </cfif>
    <cfif isDefined('Request.zOS.currentScript.variables') and StructCount(Request.zOS.currentScript.variables) NEQ 0>
      <cfscript>
				tempVars = StructNew();
				for(__i in Request.zOS.currentScript.variables){
					if(__i NEQ 'copyStruct' and isObject(Request.zOS.currentScript.variables[__i]) EQ false and isCustomFunction(Request.zOS.currentScript.variables[__i]) EQ false and __i NEQ "this" and __i NEQ "__content" and __i NEQ "arguments" and __i NEQ '__zTemplate' and __i NEQ '__path' and __i NEQ '__rethrow' and __i NEQ '__reset' and __i NEQ '__i' and __i NEQ '__include'){
						StructInsert(tempVars, __i, Request.zOS.currentScript.variables[__i],true);
					}
				}
				
					writeoutput(request.tempZdump(tempVars,'VARIABLES',false));
					</cfscript>
      <br />
      <br />
    </cfif>
    <cfif StructCount(Request) NEQ 0>
      <cfdump var="#request#" showudfs="no" hide="zos,_______mysession" label="REQUEST">
     <br />
      <br />
    </cfif>
    <cfscript>
				writeoutput(request.tempZdump(cgi,'CGI',false));
				</cfscript>
    <br />
    <br />
  </cfif>
  </cfsavecontent>
  <cfset dumpcode="">
  <cfscript>
		if(len(trim(returnString)) EQ 0){
			session.zos.zOSDebuggerLastOutput = '';
			return '';
		}else{
			returnString = '#application.zcore.functions.zHTMLDoctype()#<head><title>Debugger</title></head><body><table class="zOS_mode_table" style="width:100%;"><tr><td 
style="vertical-align:top; " class="zOS_mode_td">#returnString#</td></tr></table></body></html>';
			session.zos.zOSDebuggerLastOutput = styleString&returnString;
			return '<iframe width="700" height="500" src="#request.cgi_script_name#?zOSDebuggerLastOutput=1">No output</iframe>';
		}
		</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
