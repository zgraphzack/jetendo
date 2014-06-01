<cfcomponent>
<cfoutput>
<!--- FUNCTION: zPublishURL(source, destinationFile, includeOnly, forceTemplate);
source can be an absolute url (including remote URLs) or a root relative coldfusion template (must use template system)
 --->
<cffunction name="zPublishURL" localmode="modern" output="false" returntype="any">
	<cfargument name="source" required="yes" type="string">
	<cfargument name="destinationFile" required="yes" type="string">
	<cfargument name="includeOnly" required="no" type="boolean" default="#false#">
	<cfargument name="forceTemplate" required="no" type="boolean" default="#false#">
	<cfscript>
	var content = "";
	var result = "";
    var tempUnique='###getTickCount()#';
	var cfhttpresult=0;
	</cfscript>
	<!--- include templates instead of cfhttp --->
	<cfif arguments.includeOnly>
		<cfscript>
		content = trim(application.zcore.functions.zTemplateString(arguments.source, arguments.forceTemplate));		
		</cfscript>
	<cfelse>
		<CFHTTP METHOD="GET" URL="#arguments.source#" result="cfhttpresult" resolveurl="no" useragent="Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3 GoogleToolbarFF 3.1.20080730 Jetendo CMS" charset="utf-8">
		<cfhttpparam type="Header" name="Accept-Encoding" value="#request.httpCompressionType#">
		<cfhttpparam type="Header" name="TE" value="#request.httpCompressionType#">
		</CFHTTP>
		<cfif trim(cfhttpresult.FileContent) NEQ "CFMXConnectionFailure" and trim(cfhttpresult.FileContent) NEQ "Connection Failure">
			<cfset content = trim(cfhttpresult.FileContent)>
		<cfelse>
			<cfreturn "Publishing failed -> <a href=""#arguments.source#"" target=""_blank"">#arguments.source#</a>">
		</cfif>
	</cfif>
	<cftry>
        <cffile action="write" nameconflict="overwrite" charset="utf-8" file="#arguments.destinationFile##tempUnique#" output="#content#">
        <cffile action="rename" nameconflict="overwrite" source="#arguments.destinationFile##tempUnique#" destination="#arguments.destinationFile#">
		<cfcatch type="any"><cfreturn false></cfcatch>
	</cftry>
	<cfreturn true>
</cffunction>


 

<!--- 
// new function that can write binary files, checks status code correctly and always returns a boolean value for success or failure.
result=zHTTPtoFile(source, destinationFile);
 --->
<cffunction name="zHTTPtoFile" localmode="modern" output="false" returntype="boolean">
	<cfargument name="source" required="yes" type="string">
	<cfargument name="destinationFile" required="yes" type="string">
	<cfargument name="timeout" type="string" required="no" default="#30#">
	<cfargument name="throwOnError" type="boolean" required="no" default="#false#">
	<cfscript>
	var content = "";
    var tempUnique='###getTickCount()#';
	var cfhttpresult=0;

	path=getDirectoryFromPath(arguments.destinationFile);
	tempName=getFileFromPath(arguments.destinationFile);
	tempFilePath=path&tempName&tempUnique;
	if(not directoryexists(path)){
		throw("Directory, ""#path#"", doesn't exist.");
	}
	if(fileexists(tempFilePath)){
		application.zcore.functions.zdeletefile(tempFilePath);
	}
	try{
		HTTP METHOD="GET" URL="#arguments.source#" path="#path#" file="#tempName&tempUnique#" result="cfhttpresult" redirect="yes" timeout="#arguments.timeout#" resolveurl="no" charset="utf-8" useragent="Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3 GoogleToolbarFF 3.1.20080730 Jetendo CMS" getasbinary="auto" throwonerror="yes"{
			httpparam type="Header" name="Accept-Encoding" value="#request.httpCompressionType#";
			httpparam type="Header" name="TE" value="#request.httpCompressionType#";
		}
		if(structkeyexists(cfhttpresult,'statuscode') and left(cfhttpresult.statusCode,3) EQ '200'){
			if(fileexists(arguments.destinationFile)){
				application.zcore.functions.zdeletefile(arguments.destinationFile);
			}
			file action="rename" nameconflict="overwrite" source="#tempFilePath#" destination="#arguments.destinationFile#";
			return true;
		}
	}catch(Any e){
		// ignore exception
		if(arguments.throwOnError){
			if(fileexists(tempFilePath)){
				application.zcore.functions.zdeletefile(tempFilePath);
			}
			rethrow;
		}
	}
	if(fileexists(tempFilePath)){
		application.zcore.functions.zdeletefile(tempFilePath);
	}
	return false;
	</cfscript>
</cffunction>
	
<cffunction name="zPublishQuery" localmode="modern" output="true" returntype="any">
	<cfargument name="publishStruct" type="struct" required="yes">
	<cfscript>
	var local=structnew();
	var g=0;
	var ps = arguments.publishStruct;
	var tempStruct = StructNew();
	var currentURL = "";
	var currentFilePath = "";
	var n = 0;
	var tempVarList = "";
	var qPublish = "";
	var result = "";
	var db=request.zos.queryObject;
	
	// set defaults
	tempStruct.schedule = false;
	tempStruct.offset = 0;
	tempStruct.limit = 0;
	tempStruct.escapeWith = "-";
	tempStruct.escapeURL = true;
	tempStruct.datasource = request.zos.globals.datasource;
	tempStruct.template = false;
	// override defaults
	StructAppend(ps, tempStruct, false);
	</cfscript>
	<cfif isDefined('ps.url') EQ false and isDefined('ps.template') EQ false>
		<cfthrow type="exception" message="zPublishQuery: 'publishStruct.url' required">
	</cfif>
	<cfif isDefined('ps.fileNameFormat') EQ false>
		<cfthrow type="exception" message="zPublishQuery: 'publishStruct.fileNameFormat' required">
	</cfif>
	<cfif isDefined('ps.dirNameFormat') EQ false>
		<cfthrow type="exception" message="zPublishQuery: 'publishStruct.dirNameFormat' required">
	</cfif>
	
	<cfsavecontent variable="local.theSQL">
	#db.trustedSQL(ps.sql)# 
	<cfif ps.limit NEQ 0>
	LIMIT #db.param(ps.offset)#, #db.param(ps.limit)#
	</cfif>
	</cfsavecontent><cfscript>qPublish=db.execute("qPublish");</cfscript>
	
	<cfloop query="qPublish">
		<cfscript>
		// parse filename
		tempStruct.filename = application.zcore.functions.zParseVariables(ps.fileNameFormat,"-", qPublish);
		// parse dir
		tempStruct.dirname = application.zcore.functions.zParseVariables(ps.dirNameFormat,"-", qPublish);
		
		if(right(tempStruct.dirname,1) NEQ "/"){
			tempStruct.dirname = tempStruct.dirname&"/";
		}
		</cfscript>
		<cfif directoryexists(tempStruct.dirname) EQ false>
			<cfthrow type="exception" message="ZFUNCTION: zPublishQuery: directory doesn't exist, dirname = '#tempStruct.dirname#'">		
		</cfif>
		<cfscript>
			if(ps.escapeURL){
				result = application.zcore.functions.zPublishURL(application.zcore.functions.zParseVariables(ps.url,"_", qpublish), tempStruct.dirname&tempStruct.filename);
			}else{
				result = application.zcore.functions.zPublishURL(application.zcore.functions.zParseVariables(ps.url,false, qpublish), tempStruct.dirname&tempStruct.filename);
			}
		</cfscript>
	</cfloop>
</cffunction>






















<!--- FUNCTION: zPublishFile(sourceUrl, destinationFile) --->
<cffunction name="zPublishFile" localmode="modern" output="false" returntype="any">
	<cfargument name="sourceUrl" required="true" type="string">
	<cfargument name="destinationFile" required="true" type="string">
	<cfscript>
	var content=0;
	var result=0;
	var cfhttpresult=0;
	</cfscript>
	<CFHTTP METHOD="GET" URL="#arguments.sourceUrl#" result="cfhttpresult" resolveurl="no" useragent="Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3 GoogleToolbarFF 3.1.20080730 Jetendo CMS" charset="utf-8">
	<cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0">
	<cfhttpparam type="Header" name="TE" value="deflate;q=0"></CFHTTP>
	<cfif cfhttpresult.FileContent NEQ "Connection Failure">
		<cfset content = trim(cfhttpresult.FileContent)>
		<cfset result = application.zcore.functions.zWriteFile(arguments.destinationFile, content)>
		<cfif result EQ false>
			<cfreturn "Failed to write file: #arguments.destinationFile#<br />">
		<cfelse>
			<cfreturn result>		
		</cfif>
	<cfelse>
		<cfreturn "Publishing failed -> <a href=""#arguments.sourceUrl#"" target=""_blank"">#arguments.sourceUrl#</a>">
	</cfif>
</cffunction>

</cfoutput>
</cfcomponent>