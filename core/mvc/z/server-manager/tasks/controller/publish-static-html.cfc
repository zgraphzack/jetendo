<cfcomponent>
<cfoutput>
<cffunction name="getNginxCachePath" localmode="modern" access="public">
	<cfargument name="absoluteURL" type="string" required="yes">
	<cfscript>
	h=lcase(hash(arguments.absoluteURL));
	return "/opt/nginx/cache/"&right(h, 1)&"/"&mid(h, len(h)-2, 2)&"/"&h;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	setting requesttimeout="5000";
	request.ignoreSlowScript=true;

	arrURL=[];
	arrURL=application.zcore.app.getSiteMap(arrUrl);
	// f6f544fe0da34babf9023b8ac55e84a4
	// http://sa.farbeyondcode.com.192.168.56.104.xip.io/z/server-manager/tasks/publish-static-html/index
	for(i=1;i LTE arraylen(arrURL);i++){
		link=arrURL[i].url;
		path=getNginxCachePath(link);
		echo(path&"<br>");
		/*if(fileexists(path)){
			echo("Path exists: "&path&"<br>");
		}*/
	}
	abort;

	/*
if (!empty($_COOKIE[session_name()]) || $_SERVER['REQUEST_METHOD'] == 'POST') {
    session_id() || session_start();
}
	
might want to detect if session id was output, then disable proxy_cache
if ($http_cookie ~ "zsessionid"){
	rewrite or map or something
}

	search for "TODO add a way of testing nginx proxy cache here" to add in a testing mode for proxy caching.
	in http

		proxy_cache_path /opt/nginx/cache levels=1:2 keys_zone=nginxproxycache:1m max_size=500m inactive=5m;

	in server or location:

		proxy_cache nginxproxycache;
		proxy_ignore_headers Set-Cookie;
		proxy_cache_key "$scheme://$host$request_uri";
		#proxy_hide_header Set-Cookie;
		proxy_hide_header Expires;
		proxy_hide_header Cache-Control;
		proxy_cache_methods GET HEAD;
		#proxy_cache_bypass $cookie_ZLOGGEDIN $cookie_ZNOCACHE;
		proxy_no_cache $cookie_ZLOGGEDIN;
		proxy_no_cache $cookie_ZNOCACHE;
		proxy_no_cache $http_pragma    $http_authorization;
		
		proxy_cache_valid 200 302 600h;
		proxy_cache_valid any 90m;
		proxy_cache_min_uses 1;
	apparmor fix:
	  /opt/nginx/cache/ rw,
	  /opt/nginx/cache/** rw,

	mkdir /opt/nginx/cache
	chown nginx:root /opt/nginx/cache
	chmod 770 /opt/nginx/cache

    */

	writedump(arrURL);

	/*	
	db.sql="select * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
	where site.site_active =#db.param('1')# and 
	site_deleted = #db.param(0)# and 
	site_id <> #db.param('1')#";
	qs=db.execute("qs");
	for(row in qS){
		local.tempPath=application.zcore.functions.zGetDomainWritableInstallPath(row.site_short_domain);
		if(directoryexists(local.tempPath)){
			application.zcore.functions.zCreateDirectory(local.tempPath&'_cache/html/');
			r=application.zcore.functions.zhttptofile("#row.site_domain#/z/misc/system/missing", local.tempPath&'_cache/html/404.html');
		}
	}
	writeoutput('missing published');
	*/
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>