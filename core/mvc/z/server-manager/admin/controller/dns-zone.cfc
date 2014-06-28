<cfcomponent>
<cfoutput>
<cffunction name="publishZone" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	publishZoneFile(form.dns_group_id, form.dns_zone_id);

	application.zcore.status.setStatus(request.zsid, "Zone published", form, true);
	application.zcore.functions.zRedirect("/z/server-manager/admin/dns-zone/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#");
	</cfscript>
</cffunction>

<cffunction name="publishZones" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	publishZoneFile(form.dns_group_id, 0);

	application.zcore.status.setStatus(request.zsid, "Zones published", form, true);
	application.zcore.functions.zRedirect("/z/server-manager/admin/dns-zone/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#");
	</cfscript>
</cffunction>
<cffunction name="notifyZones" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	throw("not implemented");

	application.zcore.status.setStatus(request.zsid, "Zone notified", form, true);
	application.zcore.functions.zRedirect("/z/server-manager/admin/dns-zone/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#");
	</cfscript>
</cffunction>

<cffunction name="notifyZone" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	throw("not implemented");

	application.zcore.status.setStatus(request.zsid, "Zone notified", form, true);
	application.zcore.functions.zRedirect("/z/server-manager/admin/dns-zone/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#");
	</cfscript>
</cffunction>

<cffunction name="incrementZoneSerial" localmode="modern" access="public">
	<cfargument name="dns_zone_id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * FROM #db.table("dns_zone", request.zos.zcoreDatasource)# 
	WHERE dns_zone_id= #db.param(dns_zone_id)# ";
	qZone=db.execute("qZone");
	serial=int(right(qZone.dns_zone_serial,2));
	serial++;
	if(serial LT 10){
		serial=dateformat(now(), "YYYYMMDD")&"0"&serial;
	}else if(serial GT 100){
		throw("More then 100 zone serial updates in a single day is not supported.");
	}else{
		serial=dateformat(now(), "YYYYMMDD")&serial;
	}
	db.sql="update #db.table("dns_zone", request.zos.zcoreDatasource)# SET dns_zone_serial= #db.param(dns_zone_serial)#, 
	dns_zone_updated_datetime = #db.param(request.zos.mysqlnow)# 
	WHERE dns_zone_id = #db.param(dns_zone_id)# ";
	db.execute("qUpdate");

	zoneCom.publishZoneFile(form.dns_group_id, arguments.dns_zone_id);
	</cfscript>
</cffunction>

<cffunction name="formatDNSRecord" access="public" localmode="modern">
	<cfargument name="record" type="struct" required="yes">
	<cfscript>
	record=arguments.record;
	r="#record.dns_record_host# ";
	if(record.dns_record_ttl NEQ 0){
		r&=record.dns_record_ttl&" ";
	}
	r&="IN #record.dns_record_type# ";
	if(record.dns_ip_address NEQ ""){
		r&=record.dns_ip_address;
	}else{
		r&=record.dns_record_value;
	}
	r&=" ; #record.dns_record_comment#";
	return r;
	</cfscript>
</cffunction>

<cffunction name="publishZoneFile" localmode="modern" access="public">
	<cfargument name="dns_group_id" type="numeric" required="yes">
	<cfargument name="dns_zone_id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("dns_group", request.zos.zcoreDatasource)# dns_group LEFT JOIN
	#db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone ON 
	dns_zone.dns_group_id = dns_group.dns_group_id and 
	dns_zone.dns_zone_name = #db.param('default')# ";
	if(arguments.dns_group_id NEQ 0){
		db.sql&=" WHERE dns_group.dns_group_id = #db.param(arguments.dns_group_id)# ";
	}
	db.sql&=" ORDER BY dns_group.dns_group_name ASC ";
	qGroups=db.execute("qGroups");
	for(group in qGroups){
		db.sql="select * from #db.table("dns_zone", request.zos.zcoreDatasource)# 
		WHERE dns_group_id = #db.param(group.dns_group_id)# and 
		dns_zone_name <> #db.param('default')# ";
		if(arguments.dns_zone_id NEQ 0){
			db.sql&=" and dns_zone_id = #db.param(arguments.dns_zone_id)# ";
		}
		db.sql&=" ORDER BY dns_zone_name ASC ";
		qZones=db.execute("qZones");


		db.sql="select * from #db.table("dns_record", request.zos.zcoreDatasource)# 
		LEFT JOIN #db.table("dns_ip", request.zos.zcoreDatasource)# dns_ip 
		ON dns_record.dns_ip_id = dns_ip.dns_ip_id 
		WHERE dns_zone_id = #db.param(group.dns_zone_id)# 
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
			arrayAppend(arrZone, "#zone.dns_zone_name#.  #zone.dns_zone_soa_ttl#  IN     SOA #primaryNameserver#.    #replace(zone.dns_zone_email, "@", ".")#. (");
			arrayAppend(arrZone, "	#zone.dns_zone_serial# ; serial");
			arrayAppend(arrZone, "	#zone.dns_zone_refresh# ; refresh");
			arrayAppend(arrZone, "	#zone.dns_zone_retry# ; retry");
			arrayAppend(arrZone, "	#zone.dns_zone_expires# ; expire");
			arrayAppend(arrZone, "	#zone.dns_zone_minimum# ; minimum");
			arrayAppend(arrZone, ")");
			arrayAppend(arrZone, "; custom resource records below");
			db.sql="select * from #db.table("dns_record", request.zos.zcoreDatasource)# 
			LEFT JOIN #db.table("dns_ip", request.zos.zcoreDatasource)# dns_ip 
			ON dns_record.dns_ip_id = dns_ip.dns_ip_id 
			WHERE dns_zone_id = #db.param(zone.dns_zone_id)# 
			ORDER BY dns_record_host asc, dns_record_type asc, dns_record_value asc";
			qRecords=db.execute("qRecords");
			for(record in qRecords){
				arrayAppend(arrZone, formatDNSRecord(record));
			}
			arrayAppend(arrZone, "; default resource records below");
			customStruct={};
			if(zone.dns_zone_custom_ns EQ 1){
				customStruct["NS"]=true;
			}
			if(zone.dns_zone_custom_a EQ 1){
				customStruct["A"]=true;
			}
			if(zone.dns_zone_custom_aaaa EQ 1){
				customStruct["AAAA"]=true;
			}
			if(zone.dns_zone_custom_srv EQ 1){
				customStruct["SRV"]=true;
			}
			if(zone.dns_zone_custom_mx EQ 1){
				customStruct["MX"]=true;
			}
			if(zone.dns_zone_custom_txt EQ 1){
				customStruct["TXT"]=true;
			}
			if(zone.dns_zone_custom_cname EQ 1){
				customStruct["CNAME"]=true;
			}
			for(record in qGroupRecords){
				if(not structkeyexists(customStruct, record.dns_record_type)){
					arrayAppend(arrZone, formatDNSRecord(record));
				}
			}
			zoneOutput=arrayToList(arrZone, chr(10));
			zonePath=request.zos.globals.privateHomedir&zone.dns_zone_name&".zone";
			application.zcore.functions.zWriteFile(zonePath, zoneOutput);
			/*
			execute bind reload:
				rndc reload zone farbeyondcode.com
				rndc notify zone farbeyondcode.com
			*/
		}
	}
	</cfscript>
</cffunction>

<cffunction name="setCustom" localmode="modern" access="public">
	<cfargument name="dns_zone_id" type="string" required="yes">
	<cfargument name="dns_record_type" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="update #db.table("dns_zone", request.zos.zcoreDatasource)# 
	SET `dns_zone_custom_#application.zcore.functions.zescape(arguments.dns_record_type)#`=#db.param(1)# WHERE 
	dns_zone_id=#db.param(arguments.dns_zone_id)#";
	db.execute("qUpdate");
	return true;
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>	
	form.dns_group_id=application.zcore.functions.zso(form, 'dns_group_id', true, 0);
	db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("dns_group", request.zos.zcoreDatasource)# dns_group 
	WHERE dns_group_id=#db.param(form.dns_group_id)#";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "The selected dns group doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/dns-group/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#");
	}
	</cfscript>
</cffunction>	

<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	db.sql="SELECT * FROM #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone
	WHERE dns_zone_id= #db.param(application.zcore.functions.zso(form,'dns_zone_id'))# ";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'dns zone no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		db.sql="DELETE FROM #db.table("dns_zone", request.zos.zcoreDatasource)#  
		WHERE dns_zone_id= #db.param(application.zcore.functions.zso(form, 'dns_zone_id'))# ";
		q=db.execute("q");
		application.zcore.status.setStatus(Request.zsid, 'dns zone deleted');
		application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this dns zone?<br />
			<br />
			#qCheck.dns_zone_name#<br />
			<br />
			<a href="/z/server-manager/admin/dns-zone/delete?confirm=1&amp;dns_zone_id=#form.dns_zone_id#&amp;dns_group_id=#form.dns_group_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/server-manager/admin/dns-zone/index?dns_group_id=#form.dns_group_id#">No</a> 
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var ts={};
	var result=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	ts.dns_zone_name.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/add?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#');
		}else{
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/edit?dns_zone_id=#form.dns_zone_id#&dns_group_id=#form.dns_group_id#&zsid=#request.zsid#');
		}
	}
	form.dns_zone_updated_datetime = request.zos.mysqlnow;
	ts=StructNew();
	ts.table='dns_zone';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.dns_zone_id = application.zcore.functions.zInsert(ts);
		if(form.dns_zone_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save dns zone.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/add?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'DNS Zone saved.');
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save dns zone.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/edit?dns_zone_id=#form.dns_zone_id#&dns_group_id=#form.dns_group_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'DNS Zone updated.');
		}
		
	}
	incrementZoneSerial(form.dns_zone_id);
	application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#');
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="getDefaultZoneStruct" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("dns_group", request.zos.zcoreDatasource)# dns_group 
	WHERE dns_group_id=#db.param(form.dns_group_id)#";
	qGroup=db.execute("qGroup");

	defaultStruct={
		dns_zone_soa_ttl: 3600,
		dns_zone_ttl:3600,
		dns_zone_expires:3600000,
		dns_zone_refresh:86400,
		dns_zone_retry:7200,
		dns_zone_minimum:172800,
		dns_zone_email:request.zos.developerEmailTo
	};
	if(qGroup.dns_group_default_soa_ttl NEQ 0){
		defaultStruct.dns_zone_soa_ttl=qGroup.dns_group_default_soa_ttl;
	}
	if(qGroup.dns_group_default_ttl NEQ 0){
		defaultStruct.dns_zone_ttl=qGroup.dns_group_default_ttl;
	}
	if(qGroup.dns_group_default_expires NEQ 0){
		defaultStruct.dns_zone_expires=qGroup.dns_group_default_expires;
	}
	if(qGroup.dns_group_default_refresh NEQ 0){
		defaultStruct.dns_zone_refresh=qGroup.dns_group_default_refresh;
	}
	if(qGroup.dns_group_default_minimum NEQ 0){
		defaultStruct.dns_zone_minimum=qGroup.dns_group_default_minimum;
	}
	if(qGroup.dns_group_default_email NEQ ""){
		defaultStruct.dns_zone_email=qGroup.dns_group_default_email;
	}
	return defaultStruct;
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var ts=0;
	var db=request.zos.queryObject;
	var qRoute=0;
	var currentMethod=form.method;
	var htmlEditor=0;	
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	if(application.zcore.functions.zso(form,'dns_zone_id') EQ ''){
		form.dns_zone_id = -1;
	}
	db.sql="SELECT * FROM #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone 
	WHERE dns_zone_id=#db.param(form.dns_zone_id)#";
	qRoute=db.execute("qRoute");
	application.zcore.functions.zQueryToStruct(qRoute, form, 'dns_group_id');
	application.zcore.functions.zStatusHandler(request.zsid,true);

	defaultStruct=getDefaultZoneStruct();

	</cfscript>
	<h2>
		<cfif currentMethod EQ "add">
			Add
			<cfscript>
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
			</cfscript>
		<cfelse>
			Edit
		</cfif>
		DNS Zone</h2>
	<form action="/z/server-manager/admin/dns-zone/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?dns_zone_id=#form.dns_zone_id#" method="post">
		<table style="width:100%;" class="table-list">
			<tr>
				<th>Group</th>
				<td><cfscript>
					db.sql="SELECT * FROM #db.table("dns_group", request.zos.zcoreDatasource)# 
					ORDER BY dns_group_name";
					qGroups=db.execute("qGroups");
					selectStruct = StructNew();
					selectStruct.name = "dns_group_id";
					selectStruct.query = qGroups;
					selectStruct.queryLabelField = "dns_group_name";
					selectStruct.queryValueField = "dns_group_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
			</tr>
			<tr>
				<th>Name</th>
				<td><input type="text" name="dns_zone_name" size="50" value="#htmleditformat(form.dns_zone_name)#" /> (i.e. domain.com)</td>
			</tr>
			<tr>
				<th style="width:1%;">Comment</th>
				<td><cfscript>
				ts=StructNew();
				ts.name="dns_zone_comment";
				ts.multiline=false;
				ts.size=100;
				application.zcore.functions.zInput_Text(ts);
				</cfscript></td>
			</tr>
			<tr>
				<td colspan="2">Leave the following blank to accept default values.</td>
			</tr>
			<tr>
				<th>Zone TTL</th>
				<td><input type="text" name="dns_zone_ttl" value="#htmleditformat(form.dns_zone_ttl)#" /> (Default: #defaultStruct.dns_zone_soa_ttl#)</td>
			</tr>
			<tr>
				<th>Retry</th>
				<td><input type="text" name="dns_zone_retry" value="#htmleditformat(form.dns_zone_retry)#" /> (Default: #defaultStruct.dns_zone_retry#)</td>
			</tr>
			<tr>
				<th>Expires</th>
				<td><input type="text" name="dns_zone_expires" value="#htmleditformat(form.dns_zone_expires)#" /> (Default: #defaultStruct.dns_zone_expires#)</td>
			</tr>
			<tr>
				<th>Refresh</th>
				<td><input type="text" name="dns_zone_refresh" value="#htmleditformat(form.dns_zone_refresh)#" /> (Default: #defaultStruct.dns_zone_refresh#)</td>
			</tr>
			<tr>
				<th>Minimum</th>
				<td><input type="text" name="dns_zone_minimum" value="#htmleditformat(form.dns_zone_minimum)#" /> (Default: #defaultStruct.dns_zone_minimum#)</td>
			</tr>
			<tr>
				<th>SOA TTL</th>
				<td><input type="text" name="dns_zone_soa_ttl" value="#htmleditformat(form.dns_zone_soa_ttl)#" /> (Default: #defaultStruct.dns_zone_soa_ttl#)</td>
			</tr>
			<tr>
				<th>Email</th>
				<td><input type="text" name="dns_zone_email" value="#htmleditformat(form.dns_zone_email)#" /> (Default: #qGroup.dns_group_default_email#)</td>
			</tr>
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.location.href = '/z/server-manager/admin/dns-zone/index?dns_group_id=#form.dns_group_id#';">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>


<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qdns_zone=0;
	var arrImages=0;
	var ts=0;
	var i=0;
	var rs=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false){
		application.zcore.functions.zredirect('/member/');	
	}
	application.zcore.functions.zStatusHandler(request.zsid);

	db.sql="SELECT * FROM #db.table("dns_group", request.zos.zcoreDatasource)# dns_group 
	WHERE dns_group_id=#db.param(form.dns_group_id)#";
	qGroup=db.execute("qGroup");
 
	db.sql="SELECT *, group_concat(dns_record.dns_record_value SEPARATOR #db.param(',')#) aRecords
	FROM #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone 
	LEFT JOIN #db.table("dns_record", request.zos.zcoreDatasource)# dns_record
	ON dns_record.dns_record_type = #db.param('A')# and 
	dns_record.dns_zone_id = dns_zone.dns_zone_id 
	GROUP BY dns_zone.dns_zone_id 
	order by dns_zone_name asc";
	qdns_zone=db.execute("qdns_zone");
	</cfscript>
	<p><a href="/z/server-manager/admin/dns-group/index">DNS Groups</a> / #qGroup.dns_group_name#</p>
	<h2>Manage DNS Zones</h2>
	<p><a href="/z/server-manager/admin/dns-zone/add?dns_group_id=#form.dns_group_id#">Add DNS Zone</a> | 
	<a href="/z/server-manager/admin/dns-zone/publishZones?dns_group_id=#form.dns_group_id#">Publish All Zones</a> | 
	<a href="/z/server-manager/admin/dns-zone/notifyZones?dns_group_id=#form.dns_group_id#">Notify All Zones</a></p>
	<cfif qdns_zone.recordcount EQ 0>
		<p>No dns zones have been added.</p>
	<cfelse>
		<table  class="table-list">
			<tr>
				<th>Name</th>
				<th>A Records</th>
				<th>Comment</th>
				<th>Admin</th>
			</tr>
			<cfloop query="qdns_zone">
				<tr <cfif qdns_zone.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
					<td>#qdns_zone.dns_zone_name#</td>
					<td>#replace(qdns_zone.aRecords, ",", "<br />", "ALL")#</td>
					<td>#qdns_zone.dns_zone_comment#</td>
					<td>
						<a href="/z/server-manager/admin/dns-record/index?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#form.dns_group_id#">Manage Records</a>
						<cfif qdns_zone.dns_zone_name NEQ "default">
							 | 
							<a href="/z/server-manager/admin/dns-zone/publishZone?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#form.dns_group_id#">Publish</a> | 
							<a href="/z/server-manager/admin/dns-zone/notifyZone?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#form.dns_group_id#">Notify</a> |
							<a href="/z/server-manager/admin/dns-zone/edit?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#form.dns_group_id#">Edit</a>
							 | 
							<a href="/z/server-manager/admin/dns-zone/delete?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#form.dns_group_id#">Delete</a>
						</cfif>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>
