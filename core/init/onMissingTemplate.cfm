<cffunction name="OnMissingTemplate" localmode="modern" access="public" returntype="void" output="true" hint="Fires when an exception occures that is not caught by a try/catch.">
	<cfargument name="template" type="any" required="true" />
	<cfscript>
	var theR="";
	var curTemplate=arguments.template;
	</cfscript>
	<cfsavecontent variable="theR">
	#application.zcore.functions.zHTMLDoctype()#
	<head>
	<meta charset="utf-8" />
	<title>404 File Not Found</title>
	</head>
	
	<body><h1>404 File Not Found. <a href="/">Visit Home Page</a></h1>
	</body>
	</html>
	</cfsavecontent>
	<cfheader statuscode="404" statustext="File Not Found">
	<cfif structkeyexists(form,request.zos.urlRoutingParameter) EQ false>
		<cfscript>writeoutput(theR);</cfscript>
	<cfelse>
		    <cftry>
			<cfcontent type="text/html; iso-8859-1">
			<cfheader statuscode="404" statustext="Page not found">
			
			<cfsavecontent variable="local.zErrorTempURL"><cfif request.zos.CGI.SERVER_PORT EQ "80">http://<cfelse>https://</cfif>#listgetat(request.zOS.CGI.http_host,1,":")#<cfif isDefined('form._zsa3_path')>#form._zsa3_path#?#replace(CGI.QUERY_STRING,"_zsa3_path=","_zsa3_pathdisabled=","all")#<cfelse>#request.cgi_script_name#<cfif CGI.QUERY_STRING NEQ "">?#CGI.QUERY_STRING#</cfif></cfif></cfsavecontent>
			<cfscript>
			local.ignoreStruct={
				"/z/listing/property/":true
			};
			local.logEnabled=true;
			for(local.i in local.ignoreStruct){
				if(local.zErrorTempURL CONTAINS local.i){
					local.logEnabled=false;
				}
			}
			</cfscript>
			<cfif local.logEnabled>
				<cftry>
					<cfquery name="qLog" datasource="#request.zos.zcoredatasource#">
					INSERT INTO log404 SET 
					log404_url ='#application.zcore.functions.zescape(local.zErrorTempURL)#',
					log404_user_agent='#application.zcore.functions.zescape(cgi.http_user_agent)#',
					log404_ip ='#application.zcore.functions.zescape(cgi.remote_addr)#',
					log404_datetime ='#application.zcore.functions.zescape(request.zos.mysqlnow)#', 
					log404_referer='#application.zcore.functions.zescape(cgi.http_referer)#'
					</cfquery>
					<cfcatch type="database">
						<!--- ignore database errors --->
					</cfcatch>
				</cftry>
			</cfif>
			<cfscript>
			if(isDefined('request.zos.cgi.http_host')){
				host=request.zos.cgi.http_host;
			}else{
				host=cgi.http_host;
			}
			</cfscript>
			<cfquery name="qSite" datasource="#request.zos.zcoredatasource#">
			SELECT * FROM site WHERE site_domain = 'http://#listgetat(host,1,":")#' and site_active='1' and site_id <> '1'
			</cfquery>
			<cfscript>
			
			if(qsite.recordcount NEQ 0){
				p=request.zos.globals.privatehomedir&'_cache/html/404.html';
				if(fileexists(p)){
					f=getfileinfo(p);
					ndate=dateadd("d",-7,now());
					if(datecompare(ndate,f.lastmodified) GTE 0){
						try{
							filedelete(p);
						}catch(Any e){}
					}
				}
			}else{
				p="";
			}
			if(cgi.server_port_secure EQ 1 or cgi.server_port EQ request.zos.alternatesecureport or cgi.server_port EQ "443"){
				ph="https://";	
			}else{
				ph="http://";
			}
			ph&='#listgetat(host, 1, ":")#/z/misc/system/missing';
			</cfscript>
			<cfif (p NEQ "" and fileexists(p) EQ false)>
				<cfset request.httpCompressionType="deflate;q=0.5">
				<CFHTTP METHOD="GET" URL="#ph#" resolveurl="yes" useragent="Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3 GoogleToolbarFF 3.1.20080730 ZSA/2.0" charset="utf-8">
					<cfhttpparam type="Header" name="Accept-Encoding" value="#request.httpCompressionType#">
					<cfhttpparam type="Header" name="TE" value="#request.httpCompressionType#">
				</CFHTTP>
				<cfscript>
				tempUnique='###getTickCount()#';
				</cfscript>
				<cfif (left(CFHTTP.statusCode,3) EQ '200' or left(CFHTTP.statusCode,3) EQ '404') and trim(CFHTTP.FileContent) NEQ "CFMXConnectionFailure" and trim(CFHTTP.FileContent) NEQ "Connection Failure">
					<cflock name="zcore|404file|#qsite.site_id#" timeout="60" type="exclusive">
						<cffile addnewline="no" action="write" nameconflict="overwrite" charset="utf-8" file="#p##tempUnique#" output="#trim(cfhttp.FileContent)#">
						<cffile action="rename" nameconflict="overwrite" source="#p##tempUnique#" destination="#p#">
						<cffile action="append" charset="utf-8" file="#p#" output=" ">
					</cflock>
				</cfif>
			</cfif>
			<cfif p NEQ "" and fileexists(p)>
				<cffile action="read" file="#p#" variable="fout" charset="utf-8">#fout#<cfabort>
			<cfelse>
				#application.zcore.functions.zHTMLDoctype()#
				<head>
				<title>Missing File</title>
				<meta charset="utf-8" />
				<META HTTP-EQUIV=Refresh CONTENT="25; URL=http://#listgetat(host,1,":")#"> 
				<style type="text/css">
				<!--
				.style1 {
					font-family: Arial, Helvetica, sans-serif;
					font-size: 14pt;
					font-weight: bold;
				}
				.style2 {
					font-family: Arial, Helvetica, sans-serif;
					font-size: 10pt;
				}
				-->
				</style>
				</head>
				<body>
				<p class="style1">Sorry, this page no longer exists.</p>
				<p class="style2"><strong>Now redirecting you to the home page.</strong></p>
				<p class="style2">If your browser doesn't automatically redirect in 25 seconds, <a href="http://#listgetat(CGI.HTTP_HOST,1,':')#/">click here</a>.</p>
				</body>
				</html>
			</cfif>
			<cfcatch type="any">
			<cfscript>writeoutput(theR);</cfscript>
			</cfcatch>
		</cftry>
	</cfif>
	<cfabort>
	<cfreturn />
</cffunction>