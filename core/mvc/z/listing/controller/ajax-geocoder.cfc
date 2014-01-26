 <cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any"><cfscript>
	var db=request.zos.queryObject;
	application.zcore.functions.zEndOfRunningScript();
	application.zcore.tracking.backOneHit();
	application.zcore.template.setTemplate("zcorerootmapping.templates.blank",true,true);
	application.zcore.functions.zrequirejquery();
	form.action=application.zcore.functions.zso(form, 'action',false,'run');
	
	if(request.zos.isdeveloper EQ false and request.zos.istestserver EQ false){
		structdelete(form,'debugajaxgeocoder');
	}
	if(form.action EQ 'save'){
		if(structkeyexists(form, 'status') EQ false or structkeyexists(form, 'results') EQ false or structkeyexists(form, 'listing_id') EQ false or structkeyexists(form, 'address') EQ false or structkeyexists(form, 'zip') EQ false){
			writeoutput('Access Denied');
			application.zcore.functions.zabort();	
		}
		if(form.status EQ ""){
			writeoutput('0');
			application.zcore.functions.zabort();
		}
		if(form.status NEQ "OK" or trim(form.results) EQ ""){
			arrR=arraynew(1);
			// The 5 count here must match arraylen(arrF)
			for(i=1;i LTE 5;i++){
				arrayappend(arrR,"");
			}
			form.results=arraytolist(arrR,chr(9));
		}
		arrResults=listtoarray(replace(form.results,chr(13),"","all"),chr(10));
		for(i=1;i LTE arraylen(arrResults);i++){
			arrF=listtoarray(arrResults[i],chr(9),true);
			//application.zcore.functions.zdump(arrF);
			if(arraylen(arrF) GTE 5){
				if(structkeyexists(form, 'originaladdress')){
					db.sql="REPLACE INTO #db.table("listing_latlong_original", request.zos.zcoreDatasource)#  
					SET listing_latlong_original_address=#db.param(form.originaladdress)#, 
					listing_latlong_original_zip=#db.param(form.zip)#  ";
					db.execute("q"); 
				}
				db.sql="REPLACE INTO #db.table("listing_latlong", request.zos.zcoreDatasource)#  
				SET listing_latlong_latitude=#db.param(arrF[3])#,
				listing_latlong_longitude=#db.param(arrF[4])#, 
				listing_latlong_address=#db.param(form.address)#, 
				listing_latlong_zip=#db.param(form.zip)#, 
				listing_latlong_accuracy=#db.param(trim(arrF[5]))#,
				listing_latlong_status=#db.param(trim(form.status))# ";
				//writeoutput(chr(10)&";"&sql&";"&chr(10));
				db.execute("q"); 
				if((trim(arrF[5]) EQ "ROOFTOP") and trim(form.status) EQ "OK"){// or arrF[5] EQ "RANGE_INTERPOLATED"
					db.sql="UPDATE #db.table("listing", request.zos.zcoreDatasource)# listing 
					SET listing_latitude=#db.param(arrF[3])#,
					listing_longitude=#db.param(arrF[4])# 
					WHERE listing_id=#db.param(form.listing_id)#";
					db.execute("q"); 
					db.sql="UPDATE #db.table("#request.zos.ramtableprefix#listing", request.zos.zcoreDatasource)# listing 
					SET listing_latitude=#db.param(arrF[3])#,
					listing_longitude=#db.param(arrF[4])# 
					WHERE listing_id=#db.param(form.listing_id)#";
					db.execute("q"); 
				}
				//application.zcore.functions.zdump(arrF);
				//application.zcore.functions.zdump(request.zos.arrQueryLog);
				if(structkeyexists(form, 'debugajaxgeocoder')){
					for(g=1;g LTE arraylen(request.zos.arrQueryLog);g++){
						writeoutput(chr(10)&request.zos.arrQueryLog[g]&chr(10));
					}
				}
				writeoutput('1');
				application.zcore.functions.zabort();
			}
		}
		writeoutput('0');
		application.zcore.functions.zabort();	
	}
	</cfscript>
	<cfif form.action EQ "fix">

		<cfsavecontent variable="db.sql">
		SELECT listing.listing_id, listing_address, listing_zip, listing_state FROM (#db.table("listing", request.zos.zcoreDatasource)# listing)
		LEFT JOIN #db.table("listing_latlong_original", request.zos.zcoreDatasource)# listing_latlong_original ON 
		listing_latlong_original.listing_latlong_original_address = listing_address AND 
		listing_latlong_original_zip = listing_zip 
		 WHERE listing_latlong_original.listing_latlong_original_address IS NOT NULL AND   
		 listing.listing_latitude =#db.param('')# AND 
		 listing_address <> #db.param('')# and 
		listing_zip <> #db.param('')# and 
		listing_address REGEXP #db.param('[0-9]')#  
		#db.trustedSQL(" AND listing_address NOT LIKE '% lot %' AND 
		listing_address NOT LIKE 'lt %'  AND 
		listing_address NOT LIKE 'lot %'  AND 
		listing_address NOT LIKE 'lt.%'")#
		ORDER BY listing_mls_id ASC   
		 </cfsavecontent>
		<cfscript>
		qF=db.execute("qF");
		</cfscript>
		 <Cfset c1=0>
		 <cfloop query="qF">
			<cfscript>
			originaladdress=listing_address;
			ad1=trim(listing_address);
			if(left(ad1,1) EQ "##"){
				ad1=trim(removechars(ad1,1,1));	
			}
			pos=findnocase(" unit",ad1);
			if(pos NEQ 0){
				ad1=left(ad1,pos);
			}
			pos=findnocase(" bldg",ad1);
			if(pos NEQ 0){
				ad1=left(ad1,pos);
			}
			pos=findnocase("##",ad1);
			if(pos GTE 2){
				ad1=left(ad1,pos-1);
			}
			if(trim(ad1) NEQ ""){
				address=replace(replace(replace(replace(lcase(trim(ad1)&", "&listing_state),'"',' ',"ALL"),chr(9)," ","all"),"  "," ","all"),"  "," ","all");
				db.sql="select * from #db.table("listing_latlong", request.zos.zcoreDatasource)# listing_latlong 
				where listing_latlong_zip=#db.param(listing_zip)# and 
				listing_latlong_address = #db.param(address)# and 
				listing_latlong_accuracy =#db.param('ROOFTOP')#";
				qC=db.execute("qC"); 
				if(qC.recordcount NEQ 0){
					c1++; 
					db.sql="UPDATE #db.table("listing", request.zos.zcoreDatasource)# listing 
					SET listing_latitude=#db.param(qC.listing_latlong_latitude)#,
					listing_longitude=#db.param(qC.listing_latlong_longitude)# 
					WHERE listing_id=#db.param(listing_id)#";
					db.execute("q");
					db.sql="UPDATE #db.table("#request.zos.ramtableprefix#listing", request.zos.zcoreDatasource)# listing 
					SET listing_latitude=#db.param(qC.listing_latlong_latitude)#,
					listing_longitude=#db.param(qC.listing_latlong_longitude)# 
					WHERE listing_id=#db.param(listing_id)#";
					db.execute("q"); 
				}
			}
			</cfscript>
		 </cfloop>
		 #c1# records fixed
		 <cfscript>
		 application.zcore.functions.zabort();
		 </cfscript>
	</cfif>
	<cfif form.action EQ "run">
		<cfsavecontent variable="db.sql">
		SELECT * FROM #db.table("listing_latlong", request.zos.zcoreDatasource)# listing_latlong 
		WHERE listing_latlong_status NOT IN (#db.param('OK')#,#db.param('ZERO_RESULTS')#) 
		</cfsavecontent>
		<cfscript>
		qCheck=db.execute("qCheck");
		</cfscript>
		<cfif qCheck.recordcount NEQ 0>
			<cfif structkeyexists(form, 'resetErrors')>
				<cfscript>
				structdelete(application,'updateLatLongError');
				</cfscript>
				<cfsavecontent variable="db.sql">
				DELETE FROM #db.table("listing_latlong", request.zos.zcoreDatasource)#  
				WHERE listing_latlong_status NOT IN (#db.param('OK')#,#db.param('ZERO_RESULTS')#) 
				</cfsavecontent>
				<cfscript>
				qCheck=db.execute("qCheck");
				</cfscript>
				Geocoding Reset.<br />
			<cfelse>
				<cfscript>
				if(not structkeyexists(application, 'updateLatLongError')){
					application.updateLatLongError=true;
				application.zcore.template.fail("#qCheck.recordcount# errors have occured. First error status code: #qcheck.listing_latlong_status# (note: 620 is google's 2500 per day per ip limit error) <a href=""#request.zos.globals.domain#/z/listing/ajax-geocoder/index?resetErrors=1"">Click here to remove errors and try again.</a>");
				}else{
					writeoutput("Waiting for error state to be cleared. #qCheck.recordcount# errors have occured. First error status code: #qcheck.listing_latlong_status# (note: 620 is google's 2500 per day per ip limit error) <a href=""#request.zos.globals.domain#/z/listing/ajax-geocoder/index?resetErrors=1"">Click here to remove errors and try again.</a>");
					application.zcore.functions.zabort();
				}
				</cfscript>
			</cfif>
		</cfif>



		<cfsavecontent variable="db.sql">
		SELECT listing_mls_id FROM #db.table("#request.zos.ramtableprefix#listing", request.zos.zcoreDatasource)# listing  
		GROUP BY listing_mls_id 
		</cfsavecontent>
		<cfscript>
		qC=db.execute("qC");
		
		arrT=arraynew(1);
		</cfscript>
		<cfloop query="qC"><cfscript>arrayappend(arrT,listing_mls_id);</cfscript></cfloop>
		<cfscript>
		mlsidlist=arraytolist(arrT,"','");
		</cfscript>
		
		<cfsavecontent variable="db.sql"> 
		 SELECT listing.listing_id, listing_address, listing_zip, listing_state, city_name, zipcode_latitude, zipcode_longitude FROM (
		 #db.table("#request.zos.ramtableprefix#listing", request.zos.zcoreDatasource)# listing)
		LEFT JOIN #db.table("listing_latlong_original", request.zos.zcoreDatasource)# listing_latlong_original 
		ON 
		listing_latlong_original.listing_latlong_original_address = #db.trustedSQL("REPLACE(REPLACE(listing_address,'  ',' '),'  ',' ')")# AND 
		listing_latlong_original_zip = listing_zip
		LEFT JOIN #db.table("zipcode", request.zos.zcoreDatasource)# zipcode ON 
		listing.listing_zip = zipcode_zip 
		 WHERE listing_latlong_original.listing_latlong_original_address IS NULL AND   
		 listing.listing_latitude =#db.param('')# AND 
		 listing_address <> #db.param('')# and 
		listing_zip <> #db.param('')# and 
		listing_address REGEXP #db.param('[0-9]')#  and listing_mls_id IN (#db.trustedSQL("'#(mlsidlist)#'")#)
		#db.trustedSQL(" AND listing_address NOT LIKE '% lot %' AND listing_address NOT LIKE 'lt %'  AND listing_address NOT LIKE 'lot %'  AND listing_address NOT LIKE 'lt.%' ")#
		
		LIMIT <cfif structkeyexists(form, 'debugajaxgeocoder')>#db.param(0)#<cfelse>#db.param(randrange(0,10)*10)#</cfif>,#db.param(10)#
		</cfsavecontent>
		<cfscript>
		qG=db.execute("qG");
		</cfscript>
		<cfif structkeyexists(form, 'debugajaxgeocoder')>
		#db.sql#
		</cfif> 
		<cfscript>
		request.ignoreSlowScript=true;
		arrAddress=arraynew(1);
		i=1;
		</cfscript>
		<cfif qG.recordcount EQ 0>
			<cfsavecontent variable="db.sql"> 
			SELECT listing.listing_id, listing_address, listing_zip, listing_state, city_name, zipcode_latitude, zipcode_longitude  FROM (
			#db.table("#request.zos.ramtableprefix#listing", request.zos.zcoreDatasource)# listing)
			LEFT JOIN #db.table("listing_latlong_original", request.zos.zcoreDatasource)# listing_latlong_original 
			ON listing_latlong_original.listing_latlong_original_address = #db.trustedSQL("REPLACE(REPLACE(listing_address,'  ',' '),'  ',' ')")# AND 
			listing_latlong_original_zip = listing_zip  
			LEFT JOIN #db.table("zipcode", request.zos.zcoreDatasource)# zipcode ON listing.listing_zip = zipcode_zip
			WHERE listing_latlong_original.listing_latlong_original_address IS NULL AND   
			listing.listing_latitude =#db.param('')# AND 
			listing_address <> #db.param('')# and 
			listing_zip <> #db.param('')# and 
			listing_address REGEXP #db.param('[0-9]')#  AND listing_mls_id IN (#db.trustedSQL("'#(mlsidlist)#'")#)
			#db.trustedSQL("AND listing_address NOT LIKE '% lot %' AND 
			listing_address NOT LIKE 'lt %'  AND 
			listing_address NOT LIKE 'lot %'  AND 
			listing_address NOT LIKE 'lt.%' ")#
			
			
			LIMIT <cfif structkeyexists(form, 'debugajaxgeocoder')>#db.param(0)#<cfelse>#db.param(randrange(0,10)*10)#</cfif>,#db.param(10)#
			
			</cfsavecontent>
			<cfscript>
			qG=db.execute("qG");
			</cfscript>
			<cfif qG.recordcount EQ 0><!-- complete --><cfscript>application.zcore.functions.zabort();</cfscript></cfif>
		</cfif>
		<cfloop query="qG">
			<cfscript>
			errorMsg="";
			originaladdress=listing_address;
			ad1=trim(listing_address);
			if(left(ad1,1) EQ "##"){
				ad1=trim(removechars(ad1,1,1));	
			}
			pos=findnocase(" unit",ad1);
			if(pos NEQ 0){
				ad1=left(ad1,pos);
			}
			pos=findnocase(" bldg",ad1);
			if(pos NEQ 0){
				ad1=left(ad1,pos);
			}
			pos=findnocase("##",ad1);
			if(pos GTE 2){
				ad1=left(ad1,pos-1);
			}
			if(trim(ad1) NEQ ""){
				address=replace(replace(replace(replace(lcase(trim(ad1)&", "&listing_state),'"',' ',"ALL"),chr(9)," ","all"),"  "," ","all"),"  "," ","all");
				db.sql="select * from #db.table("listing_latlong", request.zos.zcoreDatasource)# listing_latlong 
				where listing_latlong_zip=#db.param(listing_zip)# and 
				listing_latlong_address = #db.param(address)# and 
				listing_latlong_accuracy =#db.param('ROOFTOP')#";
				qC=db.execute("qC"); 
				if(qC.recordcount NEQ 0){
					// store it and skip furthur processing
					db.sql="UPDATE #db.table("listing", request.zos.zcoreDatasource)# listing 
					SET listing_latitude=#db.param(qC.listing_latlong_latitude)#,
					listing_longitude=#db.param(qC.listing_latlong_longitude)# 
					WHERE listing_id=#db.param(listing_id)#";
					db.execute("q"); 
					db.sql="UPDATE #db.table("#request.zos.ramtableprefix#listing", request.zos.zcoreDatasource)# listing 
					SET listing_latitude=#db.param(qC.listing_latlong_latitude)#,
					listing_longitude=#db.param(qC.listing_latlong_longitude)# 
					WHERE listing_id=#db.param(listing_id)#";
					db.execute("q"); 
				}else{
					arrayappend(arrAddress, 'arrListingId.push("'&jsstringformat(listing_id)&'");');
					arrayappend(arrAddress, 'arrAddress.push("'&jsstringformat(address)&'");');
					arrayappend(arrAddress, 'arrAddressOriginal.push("'&replace(replace(originaladdress,'\','\\','all'),'"','\"','all')&'");');
					arrayappend(arrAddress, 'arrAddressZip.push("'&jsstringformat(listing_zip)&'");');
					if(zipcode_latitude EQ "" or zipcode_latitude EQ "0"){
						arrayappend(arrAddress, 'arrAddressZipLat.push(0);');
						arrayappend(arrAddress, 'arrAddressZipLong.push(0);');
					}else{
						arrayappend(arrAddress, 'arrAddressZipLat.push('&jsstringformat(zipcode_latitude)&');');
						arrayappend(arrAddress, 'arrAddressZipLong.push('&jsstringformat(zipcode_longitude)&');');
					}
				}
			}
			</cfscript>
		</cfloop>
		<cfsavecontent variable="theMeta">
		#application.zcore.functions.zRequireGoogleMaps()#
		<script type="text/javascript">
		/* <![CDATA[ */ 
		if (typeof(Number.prototype.toRad) === "undefined") {
		  Number.prototype.toRad = function() {
		    return this * Math.PI / 180;
		  }
		}
		function getMapDistance(lat1, lon1, lat2, lon2){
			var R = 6371; // km
			var dLat = (lat2-lat1).toRad();
			var dLon = (lon2-lon1).toRad();
			var lat1 = lat1.toRad();
			var lat2 = lat2.toRad();
			
			var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
					Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
			var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
			var d = R * c;	
			return d;
		}
		var geocoder;
		var arrListingId=new Array();
		var arrAddress=new Array();
		var arrAddressOriginal=new Array();
		var arrAddressZip=new Array();
		var arrAddressZipLat=new Array();
		var arrAddressZipLong=new Array();
		var f1=0;
		var curIndex=0;
		var stopGeocoding=false;
		var debugajaxgeocoder=<cfif structkeyexists(form, 'debugajaxgeocoder')>true<cfelse>false</cfif>;
		<cfscript>writeoutput(arraytolist(arrAddress,chr(10)));</cfscript>
		function codeAddress() {
			if(arrAddress.length <= curIndex) return;
			if(debugajaxgeocoder) f1.value+="run geocode: "+arrAddress[curIndex]+" for listing_id="+arrListingId[curIndex]+"\n";
			// refer to v3 google geocode docs for the results data format
			//alert('try:'+arrAddressZipLat+"\n "+arrAddressZipLong);
			geocoder.geocode( { 'address': arrAddress[curIndex]+" "+arrAddressZip[curIndex]}, function(results, status) {
				var r="";
				if (status == google.maps.GeocoderStatus.OK) {
					var a1=new Array();
					for(var i=0;i<results.length;i++){
						var a2=new Array();
						a2[0]=results[i].types.join(",");
						if(a2[0]=="street_address" && arrAddressZipLat[curIndex] != 0 && arrAddressZipLong[curIndex] != 0){
							a2[1]=results[i].formatted_address;
							//a2[2]=address_components.join("\t");
							a2[2]=results[i].geometry.location.lat()
							a2[3]=results[i].geometry.location.lng();
							a2[4]=results[i].geometry.location_type;
							var a3=a2.join("\t");
							var k=getMapDistance(arrAddressZipLat[curIndex], arrAddressZipLong[curIndex], a2[2], a2[3]);
							if(k >= 50){
								// the distance is beyond reasonable - this one is invalid
							}else{
								a1.push(a3);  
							}
							// missing city zipcode lookup record
							//alert(arrAddressZipLat[curIndex]+"\n"+arrAddressZipLong[curIndex]+"\n\n"+a2[2]+"\n"+a2[3]+"\n"+ (typeof a2[2]));
							//alert(arrAddress[curIndex]+": "+);
							
							//if(a2[4]=='ROOFTOP'){
							//}
							break;	
						}
					}
					r=a1.join("\n");
					if(debugajaxgeocoder) f1.value+=r+"\n";
				} else if(status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT || status == google.maps.GeocoderStatus.REQUEST_DENIED){
					// serious error condition
					stopGeocoding=true; 
				}
				var curStatus="";
				if(status == google.maps.GeocoderStatus.OK){
					curStatus="OK";
				}else if(status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT){
					curStatus="OVER_QUERY_LIMIT";
				}else if(status == google.maps.GeocoderStatus.REQUEST_DENIED){
					curStatus="REQUEST_DENIED";
				}else if(status == google.maps.GeocoderStatus.ZERO_RESULTS){
					curStatus="ZERO_RESULTS";
				}else if(status == google.maps.GeocoderStatus.INVALID_REQUEST){
					curStatus="INVALID_REQUEST";
				}else{
					curStatus=status;
				}
				if(debugajaxgeocoder) f1.value+='geocode done for listing_id='+arrListingId[curIndex]+" with status="+curStatus+"\n";
				var debugurlstring="";
				if(debugajaxgeocoder){
					debugurlstring="&debugajaxgeocoder=1";
				}
				$.ajax({
					type: "post",
					url: "/z/listing/ajax-geocoder/index?action=save"+debugurlstring,
					data:{ results: r, listing_id: arrListingId[curIndex], address: arrAddress[curIndex], originaladdress: arrAddressOriginal[curIndex], zip: arrAddressZip[curIndex], status: curStatus },
					dataType:"text",
					success: function(data){
						if(debugajaxgeocoder) f1.value+="Data saved with status="+data+"\n";
					}
				}); 
				curIndex++;
				if(curIndex<arrAddress.length && !stopGeocoding){
					setTimeout('timeoutGeocode();',1500);
				}
			});
		}
		function timeoutGeocode(){
			if(stopGeocoding) return;
			codeAddress();
		}
		zArrDeferredFunctions.push(function(){
			if(typeof google === "undefined" || typeof google.maps === "undefined" || typeof google.maps.Geocoder === "undefined"){
				return;
			}
			if(debugajaxgeocoder){
				f1=document.getElementById("zajaxgeocoderdiv");
				f1.style.display="block";
				f1=document.getElementById("zajaxgeocodertextarea");
			}
			if(debugajaxgeocoder) f1.value+="loaded\n";
		    geocoder = new google.maps.Geocoder();
			setTimeout('timeoutGeocode();',1500);
		});
		 /* ]]> */
		</script>
		</cfsavecontent>

		<cfscript>
		application.zcore.template.appendTag("meta",theMeta);
		</cfscript>

		<div id="zajaxgeocoderdiv" style="display:none;"><textarea name="zajaxgeocodertextarea" id="zajaxgeocodertextarea" cols="100" rows="20"></textarea></div>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>