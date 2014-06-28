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


dnsAdmin
	deleteGroup
	insertGroup
	updateGroup
	addGroup
	editGroup
	listGroup
	forceSerialIncrementGroup
	forceNotifyGroup

	notifyZone
	deleteZone
	insertZone
	updateZone
	addZone
	editZone
	listZones
	deleteRecord
	insertRecord
	updateRecord
	addRecord
	editRecord
	listRecords

<cffunction name="publishZoneFile" localmode="modern" access="public">
	<cfargument name="dns_group_id" type="numeric" required="yes">
	<cfargument name="dns_zone_id" type="numeric" required="yes">
	<cfscript>
	db.sql="select * from #db.table("dns_group", request.zos.zcoreDatasource)# ";
	if(arguments.dns_group_id NEQ 0){
		db.sql&=" and dns_group_id = #db.param(arguments.dns_group_id)# ";
	}
	db.sql&=" ORDER BY dns_group_name ASC ";
	qGroups=db.execute("qGroups");
	for(group in qGroups){
		db.sql="select * from #db.table("dns_zone", request.zos.zcoreDatasource)# 
		WHERE dns_group_id = #db.param(group.dns_group_id)# ";
		if(arguments.dns_zone_id NEQ 0){
			db.sql&=" and dns_zone_id = #db.param(arguments.dns_zone_id)# ";
		}
		db.sql&=" ORDER BY dns_zone_name ASC ";
		qZones=db.execute("qZones");


		db.sql="select * from #db.table("dns_record", request.zos.zcoreDatasource)# 
		WHERE dns_zone_id = #db.param(0)# and 
		dns_group_id = #db.param(group.dns_group_id)# ";
		ORDER BY dns_record_host asc, dns_record_type asc, dns_record_value asc";
		qGroupRecords=db.execute("qGroupRecords");

		for(zone in qZones){
			arrZone=[];
			if(zone.dns_zone_primary_nameserver EQ ""){
				primaryNameserver=zone.dns_zone_primary_nameserver;
			}else{
				primaryNameserver=listgetat(group.dns_group_default_ns, 1, chr(10));
			}
			if(zone.dns_zone_soa_ttl EQ 0){
				soaTTL=group.dns_group_default_soa_ttl;
			}else{
				soaTTL=zone.dns_zone_soa_ttl;
			}
			arrayAppend(arrZone, "$TTL #zone.dns_zone_minimum# ;");
			arrayAppend(arrZone, "#dns_zone_name#.  #zone.dns_zone_soa_ttl#  IN     SOA #primaryNameserver#.    #replace(dns_zone_email, "@", ".")#. (");
			arrayAppend(arrZone, "	#zone.dns_zone_serial# ; serial");
			arrayAppend(arrZone, "	#zone.dns_zone_refresh# ; refresh");
			arrayAppend(arrZone, "	#zone.dns_zone_retry# ; retry");
			arrayAppend(arrZone, "	#zone.dns_zone_expire# ; expire");
			arrayAppend(arrZone, "	#zone.dns_zone_minimum# ; minimum");
			arrayAppend(arrZone, ")");
			arrayAppend(arrZone, "; custom resource records below");
			db.sql="select * from #db.table("dns_record", request.zos.zcoreDatasource)# 
			WHERE dns_zone_id = #db.param(zone.dns_zone_id)# 
			ORDER BY dns_record_host asc, dns_record_type asc, dns_record_value asc";
			qRecords=db.execute("qRecords");
			for(record in qRecords){
				arrayAppend(arrZone, "#record.dns_record_host# #record.dns_record_ttl# IN #record.dns_record_type# #record.dns_record_value# ; #record.dns_record_comment#");
			}
			arrayAppend(arrZone, "; default resource records below");
			customStruct={};
			if(dns_zone_custom_ns EQ 1){
				customStruct["NS"]=true;
			}
			if(dns_zone_custom_a EQ 1){
				customStruct["A"]=true;
			}
			if(dns_zone_custom_aaaa EQ 1){
				customStruct["AAAA"]=true;
			}
			if(dns_zone_custom_srv EQ 1){
				customStruct["SRV"]=true;
			}
			if(dns_zone_custom_mx EQ 1){
				customStruct["MX"]=true;
			}
			if(dns_zone_custom_txt EQ 1){
				customStruct["TXT"]=true;
			}
			if(dns_zone_custom_cname EQ 1){
				customStruct["CNAME"]=true;
			}
			for(record in qGroupRecords){
				if(not structkeyexists(customStruct, record.dns_record_type)){
					arrayAppend(arrZone, "#record.dns_record_host# #record.dns_record_ttl# IN #record.dns_record_type# #record.dns_record_value# ; #record.dns_record_comment#");
				}
			}
			zoneOutput=arrayToList(arrZone, chr(10));
			zonePath=request.zos.globals.privateHomedir&zone.dns_zone_name&".zone";
			application.zcore.functions.zWriteFile(zonePath, zoneOutput);
		}
	}
	</cfscript>
</cffunction>

might want to manage ips, and the health checks and the multiple ip latency based routing/failover too.	
dns_ip
dns_ip_id
dns_ip_address
dns_ip_description
dns_ip_parent_id // used to link together ips that should be assigned together for failover
dns_ip_sharable char 1 0 // check to allow sharing the ip on multiple zones
dns_health_id
dns_ip_updated_datetime
dns_ip_deleted

dns_health_id
dns_health_url
dns_health_failed char 1 0 // set to 1 to mark failed status
dns_health_match_text text
dns_health_updated_datetime
dns_health_deleted



dns_zone
	dns_zone_id int
	dns_zone_name varchar 255
	dns_zone_updated_datetime datetime
	dns_zone_deleted char 1 0
	dns_zone_serial (YYYYMMDD plus 01)
	dns_group_id int
	dns_zone_ttl int
	dns_zone_primary_nameserver varchar(255)
	dns_zone_expires int
	dns_zone_refresh int
	dns_zone_minimum int
	dns_zone_email varchar(100)
	dns_zone_soa_ttl int
	dns_zone_custom_ns char 1 0
	dns_zone_custom_cname char 1 0
	dns_zone_custom_a char 1 0
	dns_zone_custom_aaaa char 1 0
	dns_zone_custom_mx char 1 0
	dns_zone_custom_srv char 1 0
	dns_zone_custom_txt char 1 0
	dns_zone_comment text
dns_record
	dns_record_id int
	dns_record_type varchar(10) (SRV, TXT, A, AAAA, MX, CNAME, NS)
	dns_ip_id int 11 0
	dns_zone_id int 0
	dns_record_updated_datetime datetime
	dns_record_deleted char 1 0
	dns_record_host varchar(255)
	dns_record_ttl int
	dns_record_value text
	dns_record_comment text
dns_group
	dns_group_id int
	dns_group_name varchar 255
	dns_group_comment text
	dns_group_notify_ip_list text
	dns_group_default_ttl int
	dns_group_default_expires int
	dns_group_default_refresh int
	dns_group_default_minimum int
	dns_group_default_email varchar(100)
	dns_group_default_soa_ttl int
	dns_group_default_mx text,
	dns_group_default_txt text,
	dns_group_default_a text,
	dns_group_default_aaaa text,
	dns_group_default_srv text,
	dns_group_default_cname text,
	dns_group_default_ns text,

CREATE TABLE `jetendo`.`dns_health`(  
  `dns_health_id` INT(11) NOT NULL AUTO_INCREMENT,
  `dns_health_url` VARCHAR(500) NOT NULL,
  `dns_health_failed` CHAR(1) NOT NULL DEFAULT '0',
  `dns_health_match_text` TEXT NOT NULL,
  `dns_health_updated_datetime` DATETIME NOT NULL,
  `dns_health_deleted` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`dns_health_id`),
  UNIQUE INDEX `newindex1` (`dns_health_url`)
);
	
CREATE TABLE `jetendo`.`dns_ip`(  
  `dns_ip_id` INT(11) NOT NULL AUTO_INCREMENT,
  `dns_ip_address` VARCHAR(45) NOT NULL,
  `dns_ip_comment` TEXT NOT NULL,
  `dns_ip_parent_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `dns_ip_sharable` CHAR(1) NOT NULL DEFAULT '0',
  `dns_health_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `dns_ip_updated_datetime` DATETIME NOT NULL,
  `dns_ip_deleted` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`dns_ip_id`),
  UNIQUE INDEX `newindex1` (`dns_ip_address`)
);


CREATE TABLE `jetendo`.`dns_zone`(  
  `dns_zone_id` INT(11) NOT NULL AUTO_INCREMENT,
  `dns_zone_name` VARCHAR(255) NOT NULL,
  `dns_zone_updated_datetime` DATETIME NOT NULL,
  `dns_zone_deleted` CHAR(1) NOT NULL DEFAULT '0',
  `dns_zone_serial` VARCHAR(10) NOT NULL,
  `dns_group_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `dns_zone_ttl` INT(11) UNSIGNED NOT NULL,
  `dns_zone_primary_nameserver` VARCHAR(255) NOT NULL,
  `dns_zone_expires` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `dns_zone_refresh` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `dns_zone_minimum` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `dns_zone_email` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `dns_zone_soa_ttl` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `dns_zone_custom_ns` CHAR(1) NOT NULL,
  `dns_zone_custom_cname` CHAR(1) NOT NULL,
  `dns_zone_custom_a` CHAR(1) NOT NULL,
  `dns_zone_custom_aaaa` CHAR(1) NOT NULL,
  `dns_zone_custom_mx` CHAR(1) NOT NULL,
  `dns_zone_custom_srv` CHAR(1) NOT NULL,
  `dns_zone_custom_txt` CHAR(1) NOT NULL,
  `dns_zone_comment` TEXT NOT NULL,
  PRIMARY KEY (`dns_zone_id`),
  INDEX `newindex1` (`dns_group_id`),
  UNIQUE INDEX `newindex2` (`dns_group_id`, `dns_zone_name`),
  INDEX `newindex3` (`dns_zone_name`)
);


CREATE TABLE `jetendo`.`dns_record`(  
  `dns_record_id` INT(11) NOT NULL AUTO_INCREMENT,
  `dns_record_type` VARCHAR(10) NOT NULL,
  `dns_zone_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `dns_ip_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `dns_record_updated_datetime` DATETIME NOT NULL,
  `dns_record_deleted` CHAR(1) NOT NULL DEFAULT '0',
  `dns_record_host` VARCHAR(255) NOT NULL,
  `dns_record_ttl` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `dns_record_value` TEXT NOT NULL,
  PRIMARY KEY (`dns_record_id`),
  INDEX `newindex1` (`dns_zone_id`)
);


CREATE TABLE `jetendo`.`dns_group`(  
  `dns_group_id` INT(11) NOT NULL AUTO_INCREMENT,
  `dns_group_name` VARCHAR(255) NOT NULL,
  `dns_group_comment` TEXT NOT NULL,
  `dns_group_notify_ip_list` TEXT NOT NULL,
  `dns_group_default_ttl` INT(11) NOT NULL DEFAULT 0,
  `dns_group_default_expires` INT(11) NOT NULL DEFAULT 0,
  `dns_group_default_refresh` INT(11) NOT NULL DEFAULT 0,
  `dns_group_default_minimum` INT(11) NOT NULL DEFAULT 0,
  `dns_group_default_soa_ttl` INT(11) NOT NULL DEFAULT 0,
  `dns_group_default_email` VARCHAR(100) NOT NULL,
  `dns_group_updated_datetime` DATETIME NOT NULL,
  `dns_group_deleted` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`dns_group_id`),
  UNIQUE INDEX `newindex1` (`dns_group_name`)
);



defaultStruct={
	dns_zone_soa_ttl: 3600,
	dns_zone_ttl:3600,
	dns_zone_expires:3600000,
	dns_zone_refresh:7200,
	dns_zone_minimum:172800,
	dns_zone_email:request.zos.developerEmailTo,
};

defaultStruct={
	dns_group_default_soa_ttl: 3600,
	dns_group_default_ttl:3600,
	dns_group_default_expires:3600000,
	dns_group_default_refresh:7200,
	dns_group_default_minimum:172800,
	dns_group_default_email:request.zos.developerEmailTo,
};
return defaultStruct;

implement dns zone parser, instead of forcing many small fields.




<cfloop from="1" to="10" index="i">

	<cfscript>
	ts = StructNew();
	ts.name = "custom#i#";
	ts.labelList = "Default|Custom";
	ts.valueList = "Default|Custom";
	ts.delimiter="|";
	ts.onclick="alert('change');";
	ts.output=true;
	ts.struct=form;
	writeoutput(application.zcore.functions.zInput_RadioGroup(ts));

	
	</cfscript>

	<cfscript>
	ts={
		name:"dns_zone_mx_value1",
		size:3

	};
	application.zcore.functions.zInput_Text(ts);
	</cfscript>

	<cfscript>
	ts={
		name:"dns_zone_mx_value1",
		size:40
	};
	application.zcore.functions.zInput_Text(ts);
	</cfscript>
</cfloop>

A
CNAME

MX
Format: 
    [priority] [mail server host name] 
Example: 
    10 mailserver.example.com. 
    20 mailserver2.example.com.

SRV
Format: 
    [priority] [weight] [port] [server host name]
Example: 
    1 10 5269 xmpp-server.example.com. 
    2 12 5060 sip-server.example.com.

AAAA
	2001:0db8:85a3:0:0:8a2e:0370:7334

TXT
	"anything"
	"anything2"

NS
    ns1.amazon.com 
    ns2.amazon.org 
    ns3.amazon.net 
    ns4.amazon.co.uk

PTR
    www.example.com

 --->
<cffunction name="index" access="public" localmode="modern">

</cffunction>
</cfoutput>
</cfcomponent>