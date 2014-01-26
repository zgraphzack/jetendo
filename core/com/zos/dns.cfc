<cfcomponent>
<cfoutput>
<!--- 

TODO: geo-location bind dns configuration:
			http://backreference.org/2010/02/01/geolocation-aware-dns-with-bind/
		
nettica bulk dns for $200 per year
	use api to automate failover without paying them for it?
	https://www.nettica.com/Support/Developers.aspx#Bulk
	
	use cronjob to automate bulk dns api change to opposite IP address
	update local nginx of remote server to call the other server while railo / database is down.
		location / {
				proxy_pass              http://lb;
				proxy_redirect          off;
				proxy_next_upstream     error timeout invalid_header http_500;
				proxy_connect_timeout   2;
				proxy_set_header        Host            $host;
				proxy_set_header        X-Real-IP       $remote_addr;
				proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
		}
 --->
<cffunction name="index" access="public" localmode="modern">

</cffunction>
</cfoutput>
</cfcomponent>