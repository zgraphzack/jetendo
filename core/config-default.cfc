<cfcomponent>
<cfoutput>
<cffunction name="getConfig" localmode="modern" returntype="struct">
	<cfargument name="tempCGI" type="struct" required="yes">
	<cfscript>
	
	var ts=structnew();
    ts.timezone="America/New_York";
	ts.locale = "en_US"; 
	// install path of this Application.cfc - It must end with a forward slash.
	ts.zOS = StructNew();
	// domain to append to ALL of your test domains.
	ts.zos.testDomain="127.0.0.2.xip.io";
	ts.zos.testManagerDomain="127.0.0.2.xip.io";  // xip.io is much slower then using your local hosts file or a local dns server, but it works without additional configuration.  Learn more about xip.io: http://xip.io/  - You can also host your own xip daemon using node.js.
	if(findnocase("."&ts.zos.testDomain, arguments.tempCgi.http_host) NEQ 0 or findnocase("."&ts.zos.testManagerDomain, arguments.tempCgi.http_host) NEQ 0){
		ts.zos.installPath="/var/jetendo-server/jetendo/";
		ts.zOS.istestserver=true;
	}else{
		ts.zos.installPath="/var/jetendo-server/jetendo/";
		ts.zOS.istestserver=false;
	}
	if(structkeyexists(server, "jetendo_"&ts.zos.installPath&"_globalscache") and structkeyexists(form,'zreset') EQ false){
		return duplicate(server["jetendo_"&ts.zos.installPath&"_globalscache"]); 
	}
	
	// sign up for grammarly's affiliate program and replace this url with a tracking url provided by their system to earn commission.
	ts.zos.grammarlyTrackingURL="http://tr.grammarly.com/aff_c?offer_id=37&aff_id=3187";
	
	if(ts.zos.istestserver){
		ts.zos.defaultSSLManagerDomain="";
		ts.zos.defaultPasswordVersion=2; // Valid values are 0 - no hash,1 - hash with many iterations or 2 scrypt java.
		ts.zos.passwordExpirationTimeSpan=createtimespan(180, 0, 0, 0); // 180 days is the default
		ts.zos.isJavaEnabled=false;
		ts.zos.isImplicitScopeCheckEnabled=true;
		ts.zos.isExecuteEnabled=false;
		ts.zOS.thisistestserver=true;
		ts.zos.directoryMode=777;
		ts.zos.fileMode=777;
		ts.zos.sambaInstallPath="C:/serverData/jetendo/";
		ts.zos.scriptsPath="/var/jetendo-server/jetendo/scripts/";
		ts.zos.sharedPath="/var/jetendo-server/jetendo/share/";
		ts.zos.sharedPathForDatabase="/var/jetendo-server/jetendo/share/";
		ts.zos.backupDirectory="/var/jetendo-server/backup/";
		ts.zos.mysqlBackupDirectory="/var/jetendo-server/backup/";
		ts.zos.sitesWritablePath="/var/jetendo-server/jetendo/sites-writable/";
		ts.zos.sitesPath="/var/jetendo-server/jetendo/sites/";
		
		// The database name MUST match the datasource name.
		ts.zos.zcoreDatasource="jetendo"; 
		ts.zos.zcoreTempDatasource="ztemp"; 
		ts.zOS.insertIDColumnForSiteIDTable="id2";
		ts.zOS.railoUser="www-data";
		ts.zos.allowRequestCFC=true;
		ts.zOS.railoAdminReadEnabled=true;
	}else{ 
		ts.zos.defaultSSLManagerDomain=""; // leave blank until you install a wildcard ssl certificate on this domain's ip.
		ts.zos.defaultPasswordVersion=2; // Valid values are 0 - no hash,1 - hash with many iterations or 2 scrypt java.
		ts.zos.passwordExpirationTimeSpan=createtimespan(180, 0, 0, 0); // 180 days is the default
		ts.zos.allowRequestCFC=true;
		ts.zos.isImplicitScopeCheckEnabled=false;
		ts.zos.isJavaEnabled=false;
		ts.zos.isExecuteEnabled=false;
		ts.zOS.thisistestserver=false;
		ts.zos.directoryMode=770;
		ts.zos.fileMode=660;
		ts.zos.sambaInstallPath="/var/jetendo-server/jetendo/";
		ts.zos.scriptsPath="/var/jetendo-server/jetendo/scripts/";
		ts.zos.sharedPath="/var/jetendo-server/jetendo/share/";
		ts.zos.sharedPathForDatabase="/var/jetendo-server/jetendo/share/";
		ts.zos.installPath="/var/jetendo-server/jetendo/";
		ts.zos.sitesPath="/var/jetendo-server/jetendo/sites/";
		ts.zos.sitesWritablePath="/var/jetendo-server/jetendo/sites-writable/";
		ts.zos.backupDirectory="/var/jetendo-server/backup/";
		ts.zos.mysqlBackupDirectory="/var/jetendo-server/backup/";
		// The database name MUST match the datasource name.
		ts.zos.zcoreDatasource="jetendo"; 
		ts.zos.zcoreTempDatasource="ztemp";
		ts.zOS.insertIDColumnForSiteIDTable="id2";
		ts.zOS.railoUser="www-data";
		ts.zOS.railoAdminReadEnabled=false;
	};
	ts.zos.enableDatabaseVersioning=true; // set to true to allow the user to restore previous versions and/or to allow jetendo to synchronize records between multiple servers.
	ts.zos.geocodeFrequency=1; // 1 is every request on a domain that has the listing app installed, set to a higher number to use a random interval
	ts.zOS.railoAdminWriteEnabled=false; // must be enabled to allow deploying railo archives.
	ts.zos.errorEmailAlertsPerMinute=5;
	
	ts.zos.zcoreTestHost="test.your-company.com.127.0.0.2.xip.io";
		
	ts.zos.scriptDirectory="/var/jetendo-server/jetendo/scripts/";
	ts.zos.backupStructureOnlyTables={
		ts.zos.zcoreDatasource&".site":true, // the site table shouldn't be able to be imported at all since this could cause sites to be lost.  That kind of migration should replace entire database manually.
		// these tables contain data that is temporary in nature and shouldn't need to be migrated between servers
		ts.zos.zcoreDatasource&".login_log":true,
		ts.zos.zcoreDatasource&".user_token":true, 
		ts.zos.zcoreDatasource&".log":true,
		ts.zos.zcoreDatasource&".ip_block":true
	};
        
		
    ts.zos.adminIpStruct=structnew();
    // developer ips - always set to false;  define one key for each developer
    ts.zos.adminIpStruct["10.0.3.2"]=false;
    ts.zos.adminIpStruct["192.168.56.1"]=false;


    // localhost is always a server ip - always set to true
    ts.zOS.adminIpStruct["127.0.0.1"]=true;
        
		
	// new server ips - define one key for each ip
    ts.zos.adminIpStruct["your.production.server.ip"]=true;
    
    // test server ips - always set to true | note this also allows the test server to auto-login to the production server
    ts.zOS.adminIpStruct["192.168.56.104"] = true;
    ts.zOS.adminIpStruct["192.168.56.105"] = true;
    
    // dev email info - all error alerts, notifications will be from and to these addresses.
    ts.zOS.developerEmailFrom="server@your-company.com";
    ts.zOS.developerEmailTo="developer@your-company.com";
    
    // global site administration live domain - It must NOT end with a forward slash.
    ts.zOS.zcoreAdminDomain="https://jetendo.your-company.com";
    
    // global site administration test domain - It must NOT end with a forward slash.
    ts.zOS.zcoreTestAdminDomain="http://jetendo.your-company.com.127.0.0.2.xip.io";
	ts.zOS.zcoreTestAdminRailoPassword="your_railo_password";
    
    
    
    ts.zos.serverSessionVariable="zsessionid";
    
    // port defined for the java server connector when using SSL - used to detect a secure connection instead of port 443.
    ts.zos.alternatesecureport="8889";
    
    // google recaptcha key - http://www.google.com/recaptcha/ - domain name: global-key.farbeyondcode.com
    ts.zos.recaptchaPrivateKey="";
    
    
    // administration site - It must end with a forward slash.
    ts.zos.zcoreRootPath=ts.zos.installPath&"core/";
    
    // non-public path for administration site - It must end with a forward slash.
    ts.zos.zcoreRootPrivatePath=ts.zos.sitesWritablePath&"jetendo_your-company_com/";
    
    // cache folder for the administration site - It must end with a forward slash.
    ts.zos.zcoreRootCachePath=ts.zos.sitesWritablePath&"jetendo_your-company_com/_cache/";
     
    // cfml mapping which should point to the same path as ts.zos.zcoreRootPath
    ts.zos.zcoremapping="zcorerootmapping";
    
    // cfml mapping which should point to the same path as ts.zos.zcoreRootCachePath
    ts.zos.zcorecachemapping="zcorecachemapping";
    
    // cgi variable name that contains the url for routing engine.
    ts.zos.urlRoutingParameter="_zsa3_path";
    
    
	
	ts.zos.testDnsServer="192.168.56.1";
	ts.zos.dnsServer="8.8.8.8";
	
    ts.zos.excludeDatasourcesFromBackup={
		"information_schema":true,
		"mysql":true,
		"performance_schema":true
	};
	
    ts.zos.zcoreDatasourcePrefix="";
    
    // prepend a string that identifies mysql memory engine tables
    ts.zos.ramtableprefix="zram##";
    
    // prepend a string to the beginning of all system table names - currently not implemented.
    ts.zos.zcoreDBPrefix="";
    
    // A third datasource can be defined in the global settings for each site in the admin portal.

	server["jetendo_"&ts.zos.installPath&"_globalscache"]=ts;

    return ts;
	</cfscript>
</cffunction>

<cffunction name="getDatasources" localmode="modern" access="public" returntype="struct">
	<cfscript>
	ts={
		datasources:{}
	};
	return ts;
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>