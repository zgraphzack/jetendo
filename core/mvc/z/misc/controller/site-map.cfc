<cfcomponent>
<cfoutput> 
<cffunction name="getLinks" localmode="modern" access="private" returntype="array">
	<cfscript>
	var arrURL=arraynew(1);
	var arrURL2=arraynew(1);
	var uniqueStruct=structnew();
	var i=0;
	if(fileexists(request.zos.globals.privatehomedir&"_cache/scripts/hardcoded-urls.json")){
		arrURL=deserializeJson(application.zcore.functions.zReadFile(request.zos.globals.privatehomedir&"_cache/scripts/hardcoded-urls.json"));
	}
	arrURL=application.zcore.app.getSiteMap(arrUrl);
	for(i=1;i LTE arraylen(arrURL);i++){
		if(structkeyexists(uniqueStruct, arrURL[i].url) EQ false){
			arrayAppend(arrURL2, arrURL[i]);
			uniqueStruct[arrURL[i].url]=true;
		}
	}
	return arrURL2;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var i=0;
	var g=0;
	var firstEmptyGroup=0;
	var arrUrl=this.getLinks();
	application.zcore.template.setTag("title","Site Map");
	application.zcore.template.setTag("pagetitle","Site Map");
	firstEmptyGroup=true;
	for(i=1;i LTE arraylen(arrUrl);i++){
		if(arrUrl[i].url CONTAINS "/z/misc/thank-you/index"){
			continue;
		}
		if(firstEmptyGroup and structkeyexists(arrUrl[i],'groupName') EQ false){
			writeoutput('<ul>');
			firstEmptyGroup=false;
		}else if(structkeyexists(arrUrl[i],'groupName') and arrUrl[i].groupName NEQ g){
			if(i NEQ 1){ writeoutput('</ul>'); }
			g=arrUrl[i].groupName;
			writeoutput('<h2>'&htmleditformat(g)&'</h2><ul>');
		}
		if(structkeyexists(arrUrl[i],"indent")){
			writeoutput('<li style="margin-left:'&(len(arrUrl[i].indent)*8)&'px;"><a href="'&replace(arrUrl[i].url,request.zos.globals.domain, request.zos.currentHostName)&'">'&htmleditformat(arrUrl[i].title)&'</a></li>');
		}else{
			writeoutput('<li><a href="'&replace(arrUrl[i].url,request.zos.globals.domain, request.zos.currentHostName)&'">'&htmleditformat(arrUrl[i].title)&'</a></li>');
		}
	}
	writeoutput('<li><a href="/sitemap.xml.gz" target="_blank">XML Site Map</a></li>');
	writeoutput('</ul>');
	</cfscript>
</cffunction>

        
<cffunction name="xmloutput" localmode="modern" access="remote">
        <cfscript>
	var arrXML=arraynew(1);
        var g="";
	var arrURL=this.getLinks();
	
	arrayappend(arrXML,'<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');
	for(i=1;i LTE arraylen(arrUrl);i++){
		if(arrUrl[i].url CONTAINS "/z/misc/thank-you/index"){
			continue;
		}
		arrayappend(arrXML,'<url><loc>'&xmlformat(arrUrl[i].url)&'</loc>');
		if(structkeyexists(arrUrl[i],'lastmod')){
			arrayappend(arrXML,'<lastmod>'&xmlformat(arrURl[i].lastmod)&'</lastmod>');
		}
		arrayappend(arrXML,'</url>');
	}
	arrayappend(arrXML,'</urlset>');
	xDoc=arraytolist(arrXML,'');
	filePath=request.zos.globals.privatehomedir&'zcache/sitemap.xml';
	domainPath=request.zos.globals.domain&'/sitemap.xml.gz';
	if(not fileexists(filePath) or hash(xDoc) NEQ hash(application.zcore.functions.zreadfile(filePath)) or structkeyexists(form, 'force')){
		application.zcore.functions.zwritefile(filePath, xDoc);
		application.zcore.functions.zGzipFilePath(filePath, 10);
		if(fileexists(filePath)){
			application.zcore.functions.zdeletefile(filePath);
		}
		if(request.zos.istestserver EQ false and (structkeyexists(application.sitestruct[request.zos.globals.id],'lastSiteMapPing') EQ false or datecompare(dateadd("n",-30,now()),application.sitestruct[request.zos.globals.id].lastSiteMapPing) EQ 1)){
			application.sitestruct[request.zos.globals.id].lastSiteMapPing=now();
			pingURL="https://www.google.com/webmasters/tools/ping?sitemap="&URLEncodedFormat(domainPath);
			r1=application.zcore.functions.zdownloadlink(pingURL);
			if(r1.success EQ false){
				savecontent variable="output"{
					writedump(r1);
				}
				throw("Failed to ping google with pingURL = #pingURL#. "&output);
			}
		}
	}
	writeoutput('Done');
	application.zcore.functions.zabort();
        </cfscript>
</cffunction>
</cfoutput>
</cfcomponent>