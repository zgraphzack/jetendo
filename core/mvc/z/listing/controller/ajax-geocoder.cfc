 <cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any"><cfscript>
	var db=request.zos.queryObject;
	if(request.zos.isdeveloper EQ false and request.zos.istestserver EQ false){
		structdelete(form,'debugajaxgeocoder');
	}
	if(request.zos.originalURL CONTAINS "/z/listing/ajax-geocoder/"){
		form.action=application.zcore.functions.zso(form, 'action',false,'run');
		if(form.action EQ 'save'){
			if(structkeyexists(form, 'status') EQ false or 
				structkeyexists(form, 'results') EQ false or 
				structkeyexists(form, 'listing_id') EQ false or 
				structkeyexists(form, 'address') EQ false or 
				structkeyexists(form, 'zip') EQ false){
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
				if(arraylen(arrF) GTE 5){
					db.sql="REPLACE INTO #db.table("listing_coordinates", request.zos.zcoreDatasource)#  
					SET listing_coordinates_latitude=#db.param(arrF[3])#,
					listing_coordinates_longitude=#db.param(arrF[4])#, 
					listing_id=#db.param(form.listing_id)#, 
					listing_coordinates_address=#db.param(trim(form.address))#,
					listing_coordinates_zip=#db.param(trim(form.zip))#,
					listing_coordinates_accuracy=#db.param(trim(arrF[5]))#,
					listing_coordinates_status=#db.param(trim(form.status))# ";
					db.execute("q"); 
					if((trim(arrF[5]) EQ "ROOFTOP") and trim(form.status) EQ "OK"){
						db.sql="UPDATE #db.table("listing", request.zos.zcoreDatasource)# listing 
						SET listing_latitude=#db.param(arrF[3])#,
						listing_longitude=#db.param(arrF[4])# 
						WHERE listing_id=#db.param(form.listing_id)# and 
						listing_latitude=#db.param('0')# ";
						db.execute("q"); 
						db.sql="UPDATE #db.table("#request.zos.ramtableprefix#listing", request.zos.zcoreDatasource)# listing 
						SET listing_latitude=#db.param(arrF[3])#,
						listing_longitude=#db.param(arrF[4])# 
						WHERE listing_id=#db.param(form.listing_id)# and 
						listing_latitude=#db.param('0')#";
						db.execute("q"); 
					}
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
	}else{
		if(request.zos.isDeveloper or request.zos.isServer){
			db.sql="SELECT * FROM #db.table("listing_coordinates", request.zos.zcoreDatasource)# listing_coordinates 
			WHERE listing_coordinates_status NOT IN (#db.param('OK')#,#db.param('ZERO_RESULTS')#) ";
			qCheck=db.execute("qCheck");
			if(qCheck.recordcount NEQ 0){
				if(structkeyexists(form, 'resetErrors')){
					structdelete(application,'updateLatLongError');
					db.sql="DELETE FROM #db.table("listing_coordinates", request.zos.zcoreDatasource)#  
					WHERE listing_coordinates_status NOT IN (#db.param('OK')#,#db.param('ZERO_RESULTS')#) ";
					qCheck=db.execute("qCheck");
					echo("Geocoding Reset.<br />");
				}else{
					if(not structkeyexists(application, 'updateLatLongError')){
						application.updateLatLongError=true;

						ts={
							type:"Custom",
							errorHTML:"#qCheck.recordcount# errors have occured. First error status code: #qcheck.listing_coordinates_status# 
							(note: 620 is google's 2500 per day per ip limit error) 
							<a href=""#request.zos.currentHostName#/z/listing/ajax-geocoder/index?resetErrors=1"">Click here to remove errors and try again.</a>",
							scriptName:request.zos.currentHostName&'/z/listing/ajax-geocoder/index',
							url:request.zos.currentHostName&'/z/listing/ajax-geocoder/index',
							exceptionMessage:'Geocoder failed.',
							// optional
							lineNumber:'0'
						}
						application.zcore.functions.zLogError(ts);
					}else{
						return;
					}
				}
			}
		}
		db.sql="SELECT listing.listing_id, listing_address, listing_city, listing_state, listing_zip, listing_latitude, listing_longitude FROM 
		#db.table("#request.zos.ramtableprefix#listing", request.zos.zcoreDatasource)# listing
 		WHERE
		listing.listing_latitude =#db.param(0)# AND 
		listing_address <> #db.param('')# and 
		listing_zip <> #db.param('')# and 
		listing_address REGEXP #db.param('[0-9]')# AND 
		listing_address NOT LIKE #db.param('% lot %')# AND 
		listing_address NOT LIKE #db.param('lt %')#  AND 
		listing_address NOT LIKE #db.param('lot %')#  AND 
		listing_address NOT LIKE #db.param('lt.%')#
		LIMIT ";
		if(structkeyexists(form, 'debugajaxgeocoder')){
			db.sql&=db.param(0);
		}else{
			db.sql&=db.param(randrange(0,10)*10);
		}
		db.sql&=","&db.param(10);
		qG=db.execute("qG");
		if(structkeyexists(form, 'debugajaxgeocoder')){
			echo(db.sql);
		}
		request.ignoreSlowScript=true;
		arrAddress=arraynew(1);
		i=1;
		if(not structkeyexists(application.zcore, 'listingStruct')){
			application.zcore.functions.z404('application.zcore.listingStruct is not defined');
		}
		request.zos.listing=application.zcore.listingStruct;
		for(row in qG){
			cityName="";
			if(structkeyexists(request.zos.listing.cityNameStruct, row.listing_city)){
				cityName=request.zos.listing.cityNameStruct[row.listing_city];
			}
			errorMsg="";
			ad1=trim(row.listing_address);
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
			if(cityName NEQ ""){
				ad1&=", "&cityname;
			}
			if(trim(ad1) NEQ ""){
				address=replace(replace(replace(replace(lcase(trim(ad1)&", "&row.listing_state),'"',' ',"ALL"),chr(9)," ","all"),"  "," ","all"),"  "," ","all");
				arrayappend(arrAddress, 'arrListingId.push("'&jsstringformat(row.listing_id)&'");');
				arrayappend(arrAddress, 'arrAddress.push("'&jsstringformat(address)&'");');
				arrayappend(arrAddress, 'arrAddressZip.push("'&jsstringformat(row.listing_zip)&'");');
				arrayappend(arrAddress, 'arrAddressZipLat.push('&jsstringformat(row.listing_latitude)&');');
				arrayappend(arrAddress, 'arrAddressZipLong.push('&jsstringformat(row.listing_longitude)&');');
			}
		}
		echo('#application.zcore.functions.zRequireGoogleMaps()#
		<script type="text/javascript">
		/* <![CDATA[ */ 
		var geocoder;
		var arrListingId=new Array();
		var arrAddress=new Array();
		var arrAddressZip=new Array();
		var arrAddressZipLat=new Array();
		var arrAddressZipLong=new Array();
		var f1=0;
		var curIndex=0;
		var stopGeocoding=false;
		var debugajaxgeocoder=');
		if(structkeyexists(form, 'debugajaxgeocoder')){
			echo('true');
		}else{
			echo('false');
		}
		echo(';'&arraytolist(arrAddress,chr(10))&'
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
			setTimeout(''zTimeoutGeocode();'',1500);
		});
		 /* ]]> */
		</script> 
		<div id="zajaxgeocoderdiv" style="display:none;"><textarea name="zajaxgeocodertextarea" id="zajaxgeocodertextarea" cols="100" rows="20"></textarea></div>');
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>