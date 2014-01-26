<cfcomponent>
<cfoutput> 
<cffunction name="index" localmode="modern" access="remote"><cfscript>
	var i=0;
	if(structkeyexists(application, 'sessionstruct')){
		// clear application scope sessions:
		request.zos.oldestPossibleSessionDate=now()-request.zos.sessiontimeout;
		request.zos.oldestPossibleSessionDate=createodbcdatetime(dateformat(request.zos.oldestPossibleSessionDate,"yyyy-mm-dd")&" "&timeformat(request.zos.oldestPossibleSessionDate, "HH:mm:ss"));
		for(i in application.sessionstruct){
			if(structkeyexists(application.sessionstruct[i], 'lastvisit') and datecompare(application.sessionstruct[i].lastvisit, request.zos.oldestPossibleSessionDate) LTE 0){
				structdelete(application.sessionstruct, i);
			}
		}
	}
	
	writeoutput('1 is OK');
	// This script is monitored by alertra.com
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>
<cffunction name="updateRewriteRules" localmode="modern" access="remote">
	<cfscript>
if(structkeyexists(form, 'zforceapplicationurlrewriteupdate')){
    application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
}
</cfscript>Done.<cfscript>application.zcore.functions.zabort();</cfscript>
</cffunction>

<cffunction name="logClientError" localmode="modern" access="remote">
    <cfscript>
	form.errorStacktrace=application.zcore.functions.zso(form, 'errorStacktrace');
	form.errorMessage=application.zcore.functions.zso(form, 'errorMessage');
	form.errorURL=application.zcore.functions.zso(form, 'errorUrl');
	form.requestURL=application.zcore.functions.zso(form, 'requestURL');
	form.errorLineNumber=application.zcore.functions.zso(form, 'errorLineNumber');
	form.errorObj=application.zcore.functions.zso(form, 'errorObj');
	if(form.errorMessage NEQ ""){
		var ts={
			type:'javascript-error',
			scriptName: form.errorURL,
			lineNumber: form.errorLineNumber, 
			url:form.requestURL,
			exceptionMessage: form.errorMessage
		}
		if(left(ts.url, 1) EQ "/"){
			ts.url=request.zos.currentHostName&ts.url;
		}
		if(left(ts.scriptName, 1) EQ "/"){
			ts.scriptName=request.zos.currentHostName&ts.scriptName;
		}
		savecontent variable="ts.errorHTML"{
			echo("Error Message: "&application.zcore.functions.zParagraphFormat(form.errorMessage)&'<br />');
			echo("Line Number: "&form.errorLineNumber&'<br />');
			if(form.errorObj NEQ ""){
				echo("Error Object:"&form.errorObj&"<br />");
			}
			if(form.errorStacktrace NEQ ""){
				echo("Stacktrace: "&application.zcore.functions.zParagraphFormat(form.errorStacktrace)&'<br />');
			}
		}
		application.zcore.functions.zLogError(ts);
		echo('{"success":true}');
		application.zcore.functions.zabort();
	}
	</cfscript>
</cffunction>
	
	
<cffunction name="getSplitTemplate" localmode="modern" access="remote" hint="Currently used for ssi template generation.">
	<cfscript>
	application.zcore.template.appendTag("meta", '<script type="text/javascript">zContentTransitionDisabled=true;</script>');
	request.zPageDebugDisabled=true;
	writeoutput('~SSISPLIT~');
	</cfscript>
</cffunction>

<cffunction name="redirect" localmode="modern" access="remote">
	<cfscript>
	request.znotemplate=true;
	application.zcore.tracking.backOneHit();
	application.zcore.functions.zModalCancel();
	form.link=application.zcore.functions.zso(form, 'link');
	if(left(form.link,1) EQ "/"){
		application.zcore.functions.zRedirect(form.link);
	}else if(left(form.link,7) NEQ "http://" and left(form.link,8) NEQ "https://"){
		application.zcore.functions.z301redirect('/');	
	}else{
		application.zcore.functions.zRedirect(form.link);	
	}
	</cfscript>
</cffunction>

<cffunction name="missing" localmode="modern" access="remote">
	Please browse our site or go back and try a different link.<br />
	<br />
	<cfscript>
	application.zcore.template.setTag("title",'Sorry, this page no longer exists.');
	application.zcore.template.setTag("pagetitle",'Sorry, this page no longer exists.');
	//application.zcore.template.setTag("meta",tempMeta);
	//application.zcore.template.setTag("pagenav",tempPageNav);
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>