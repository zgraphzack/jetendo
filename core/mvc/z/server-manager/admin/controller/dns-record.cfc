<cfcomponent>
<cfoutput>
<cffunction name="incrementZoneSerial" localmode="modern" access="public">
	<cfargument name="dns_zone_id" type="string" required="yes">
	<cfscript>
	zoneCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.dns-zone");
	zoneCom.incrementZoneSerial(form.dns_group_id, arguments.dns_zone_id);

	</cfscript>
</cffunction>


<cffunction name="formatDNSRecord" localmode="modern" access="public">
	<cfargument name="record" type="struct" required="yes">
	<cfscript>
	zoneCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.dns-zone");
	return zoneCom.formatDNSRecord(arguments.record);
	</cfscript>
</cffunction>

<cffunction name="setCustom" localmode="modern" access="public">
	<cfargument name="dns_zone_id" type="string" required="yes">
	<cfargument name="dns_record_type" type="string" required="yes">
	<cfscript>
	zoneCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.dns-zone");
	zoneCom.setCustom(arguments.dns_zone_id, arguments.dns_record_type);
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>	
	form.dns_zone_id=application.zcore.functions.zso(form, 'dns_zone_id', true, 0);
	db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone, 
	#db.table("dns_group", request.zos.zcoreDatasource)# dns_group
	WHERE dns_zone.dns_zone_id=#db.param(form.dns_zone_id)# and 
	dns_group.dns_group_id = dns_zone.dns_group_id";
	qZone=db.execute("qZone");
	if(qZone.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "The selected dns zone doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/dns-record/index?zsid=#request.zsid#&dns_zone_id=#form.dns_zone_id#");
	}
	form.dns_group_id=qZone.dns_group_id;
	form.dns_zone_name=qZone.dns_zone_name;
	form.dns_group_name=qZone.dns_group_name;
	</cfscript>
</cffunction>	

<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0;
	db.sql="SELECT * FROM #db.table("dns_record", request.zos.zcoreDatasource)# dns_record
	LEFT JOIN #db.table("dns_ip", request.zos.zcoreDatasource)# dns_ip 
	ON dns_record.dns_ip_id = dns_ip.dns_ip_id 
	WHERE dns_record_id= #db.param(application.zcore.functions.zso(form,'dns_record_id'))# ";
	qCheck=db.execute("qCheck");
	application.zcore.functions.zSetModalWindow();
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'dns record no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/index?zsid=#request.zsid#&dns_zone_id=#form.dns_zone_id#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		setCustom(form.dns_record_id, qCheck.dns_record_type);
		db.sql="DELETE FROM #db.table("dns_record", request.zos.zcoreDatasource)#  
		WHERE dns_record_id= #db.param(application.zcore.functions.zso(form, 'dns_record_id'))#
		";
		q=db.execute("q");
		incrementZoneSerial(form.dns_zone_id);
		application.zcore.status.setStatus(Request.zsid, 'dns record deleted');
		application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/autoCloseAndRefresh?zsid=#request.zsid#&dns_zone_id=#form.dns_zone_id#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this dns record?<br />
			<br />
			#qCheck.dns_record_host# <cfif qCheck.dns_record_ttl NEQ 0>
						#qCheck.dns_record_ttl#
					</cfif>
					 IN #qCheck.dns_record_type# 
					 <cfif qCheck.dns_ip_address NEQ "">
						#qCheck.dns_ip_address#
					<cfelse>
					 	#qCheck.dns_record_value#
					 </cfif> ;
					 #qCheck.dns_record_comment#<br />
			<br />
			<a href="/z/server-manager/admin/dns-record/delete?confirm=1&amp;dns_record_id=#form.dns_record_id#&amp;dns_zone_id=#form.dns_zone_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="##"  onclick="window.parent.zCloseModal();">No</a> 
		</div>
	</cfif>
</cffunction>


<cffunction name="autoCloseAndRefresh" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.functions.zSetModalWindow();
	//application.zcore.functions.zStatusHandler(Request.zsid);
	</cfscript>
	<script type="text/javascript">
	zArrDeferredFunctions.push(function(){
		//setTimeout(function(){
			window.parent.zCloseModal();
			window.parent.location.href="/z/server-manager/admin/dns-record/index?dns_zone_id=#form.dns_zone_id#";
		//}, 10);
	});
	</script>
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
	init();
	ts.dns_record_type.required = true;
	error=false;
	if(form.dns_record_value EQ "" and form.dns_ip_id EQ ""){
		application.zcore.status.setStatus(Request.zsid, "You must select an IP or enter a value.",form,true);
		error=true;
	}
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result or error){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/add?zsid=#request.zsid#&dns_zone_id=#form.dns_zone_id#');
		}else{
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/edit?dns_record_id=#form.dns_record_id#&dns_zone_id=#form.dns_zone_id#&zsid=#request.zsid#');
		}
	}
	setCustom(form.dns_zone_id, form.dns_record_type);
	form.dns_record_updated_datetime = request.zos.mysqlnow;

	ts=StructNew();
	ts.table='dns_record';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.dns_record_id = application.zcore.functions.zInsert(ts);
		if(form.dns_record_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save dns record.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/add?zsid=#request.zsid#&dns_zone_id=#form.dns_zone_id#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'DNS Record saved.');
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save dns record.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/edit?dns_record_id=#form.dns_record_id#&dns_zone_id=#form.dns_zone_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'DNS Record updated.');
		}
		
	}
	incrementZoneSerial(form.dns_zone_id);
	application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/autoCloseAndRefresh?zsid=#request.zsid#&dns_zone_id=#form.dns_zone_id#');
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var ts=0;
	var db=request.zos.queryObject;
	var qRoute=0;
	var currentMethod=form.method;
	var htmlEditor=0;	
	if(application.zcore.functions.zso(form,'dns_record_id') EQ ''){
		form.dns_record_id = -1;
	}
	application.zcore.functions.zSetModalWindow();
	db.sql="SELECT * FROM #db.table("dns_record", request.zos.zcoreDatasource)# dns_record 
	WHERE dns_record_id=#db.param(form.dns_record_id)#";
	qRoute=db.execute("qRoute");
	if(structkeyexists(form, 'dns_record_type')){
		application.zcore.functions.zQueryToStruct(qRoute, form, 'dns_zone_id,dns_record_type');
	}else{
		application.zcore.functions.zQueryToStruct(qRoute, form, 'dns_zone_id');
	}
	application.zcore.functions.zStatusHandler(request.zsid,true);
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
		DNS Record</h2>
	<form action="/z/server-manager/admin/dns-record/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?dns_record_id=#form.dns_record_id#&amp;dns_zone_id=#form.dns_zone_id#" method="post">
		<table style="width:100%;" class="table-list">
			<tr>
				<th>Name</th>
				<td><cfscript>
				ts = StructNew();
				ts.name = "dns_record_type";
				ts.queryValueField = "dns_zone_id";
				ts.listLabels = "A|AAAA|CNAME|MX|NS|SRV|TXT";
				ts.listValues = "A|AAAA|CNAME|MX|NS|SRV|TXT";
				ts.listLabelsDelimiter = "|"; 
				ts.listValuesDelimiter = "|";
				application.zcore.functions.zInputSelectBox(ts);
				</cfscript></td>
			</tr>
			<tr>
				<th style="width:1%;">Host</th>
				<td><cfscript>
				ts=StructNew();
				ts.name="dns_record_host";
				ts.multiline=false;
				ts.size=70;
				ts.style="width:90% !important;";
				application.zcore.functions.zInput_Text(ts);
				</cfscript></td>
			</tr>
			<tr>
				<th style="width:1%;">TTL</th>
				<td><cfscript>
				ts=StructNew();
				ts.name="dns_record_ttl";
				ts.multiline=false;
				ts.size=70;
				ts.style="width:90% !important;";
				application.zcore.functions.zInput_Text(ts);
				</cfscript></td>
			</tr>
			<tr>
				<td colspan="2">Select an IP or a valid value for this record type</td>
			</tr>
			<tr>
				<th style="width:1%;">IP</th>
				<td><cfscript>
					db.sql="SELECT * FROM #db.table("dns_ip", request.zos.zcoreDatasource)# 
					WHERE dns_ip_parent_id = #db.param(0)#
					ORDER BY dns_ip_address ASC";
					qGroups=db.execute("qGroups");
					selectStruct = StructNew();
					selectStruct.name = "dns_ip_id";
					selectStruct.query = qGroups;
					selectStruct.queryParseLabelVars=true;
					selectStruct.queryLabelField = "##dns_ip_address## (##dns_ip_comment##)";
					selectStruct.queryValueField = "dns_ip_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
			</tr>
			<tr>
				<th style="width:1%;">Value</th>
				<td><cfscript>
				ts=StructNew();
				ts.name="dns_record_value";
				ts.multiline=false;
				ts.onchange="document.getElementById('dns_ip_id').selectedIndex=0; ";
				ts.onkeyup="document.getElementById('dns_ip_id').selectedIndex=0; ";
				ts.size=70;
				ts.style="width:90% !important;";
				application.zcore.functions.zInput_Text(ts);
				</cfscript></td>
			</tr>
			<tr>
				<th style="width:1%;">Comment</th>
				<td><cfscript>
				ts=StructNew();
				ts.name="dns_record_comment";
				ts.multiline=false;
				ts.size=70;
				ts.style="width:90% !important;";
				application.zcore.functions.zInput_Text(ts);
				</cfscript></td>
			</tr>
			<!--- <tr>
				<th>Phone</th>
				<td><input type="text" name="dns_record_phone" value="#htmleditformat(form.dns_record_phone)#" /></td>
			</tr> --->
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>


<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qdns_record=0;
	var arrImages=0;
	var ts=0;
	var i=0;
	var rs=0;
	init();
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false){
		application.zcore.functions.zredirect('/member/');	
	}
	application.zcore.functions.zStatusHandler(request.zsid);

 
	db.sql="SELECT *
	FROM #db.table("dns_record", request.zos.zcoreDatasource)# dns_record 
	LEFT JOIN #db.table("dns_ip", request.zos.zcoreDatasource)# dns_ip 
	ON dns_record.dns_ip_id = dns_ip.dns_ip_id 
	WHERE
	dns_record.dns_zone_id = #db.param(form.dns_zone_id)# 
	order by dns_record_host asc, dns_record_type asc, dns_record_value ASC";
	qRecords=db.execute("qdns_record");
	</cfscript>
	<p><a href="/z/server-manager/admin/dns-group/index">DNS Groups</a> / <a href="/z/server-manager/admin/dns-zone/index?dns_group_id=#form.dns_group_id#">#form.dns_group_name#</a> / #form.dns_zone_name#</p>
	<h2>Manage dns records</h2>
	<script type="text/javascript">
	function openDNSModal(link){
		zShowModalStandard(link, Math.min(550, zWindowSize.width-100), Math.min(450, zWindowSize.height-100));
	}
	zArrDeferredFunctions.push(function(){
		$(".addButton").bind("click", function(){
			var zoneId=this.getAttribute("data-dns-zone-id");
			var type=this.innerHTML;
			var link='/z/server-manager/admin/dns-record/add?dns_zone_id='+zoneId+'&dns_record_type='+type;
			openDNSModal(link);
			return false;
		});
		$(".editButton").bind("click", function(){
			var zoneId=this.getAttribute("data-dns-zone-id");
			var recordId=this.getAttribute("data-dns-record-id");
			var link='/z/server-manager/admin/dns-record/edit?dns_zone_id='+zoneId+'&dns_record_id='+recordId;
			openDNSModal(link);
			return false;

		});
		$(".deleteButton").bind("click", function(){
			var zoneId=this.getAttribute("data-dns-zone-id");
			var recordId=this.getAttribute("data-dns-record-id");
			var link='/z/server-manager/admin/dns-record/delete?dns_zone_id='+zoneId+'&dns_record_id='+recordId;
			openDNSModal(link);
			return false;

		});
	});
	</script>
	<p>
		Add DNS Record: 
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">A</a>
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">AAAA</a>
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">CNAME</a>
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">MX</a>
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">NS</a>
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">SRV</a>
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">TXT</a>
		</p>
	<cfif qRecords.recordcount EQ 0>
		<p>No dns records have been added.</p>
	<cfelse>
		<table  class="table-list">
			<tr>
				<th>Record</th>
				<th>Admin</th>
			</tr>
			<cfscript>
			i=1;
			for(record in qRecords){
				echo('<tr ');
				if(i MOD 2 EQ 0){
					echo('class="row2"');
				}else{
					echo('class="row1"');
				}
				echo('>
					<td>#formatDNSRecord(record)#</td>
					<td>
						<a href="##" class="editButton" data-dns-record-id="#record.dns_record_id#" data-dns-zone-id="#form.dns_zone_id#">Edit</a> | 
						<a href="##" class="deleteButton" data-dns-record-id="#record.dns_record_id#" data-dns-zone-id="#form.dns_zone_id#">Delete</a></td>
				</tr>');
				i++;
			}
			</cfscript>
		</table>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>
