<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>
	<cfscript>
	this.retsVersion="1.5";
	
	this.mls_id=7;
	if(request.zos.istestserver){
		hqPhotoPath="#request.zos.sharedPath#mls-images/7/";
	}else{
		hqPhotoPath="#request.zos.sharedPath#mls-images/7/";
	}
	this.useRetsFieldName="system";
	this.arrColumns=listtoarray("1,1005,1010,104,595,1055,106,3221,3220,3265,3131,108,3222,109,11,1117,112,3244,1213,2883,904,903,1215,1231,3283,1248,1296,1302,913,1303,1307,816,709,3264,1310,1314,1316,1317,1321,1328,1335,1349,3190,505,1350,1354,906,905,902,901,1368,2771,1374,1375,2777,3247,138,3262,1381,1384,1397,3161,140,1405,853,855,858,1415,1418,1420,3281,1425,1426,143,1432,1437,1455,1466,1495,15,151,1514,879,2352,1518,3211,3210,3218,3219,1522,165,1660,3179,1670,3198,3193,3191,17,1709,1711,1716,1717,1718,1720,1722,1723,607,1724,1725,1726,1727,1728,1729,1731,1732,1733,1734,62,1735,1736,1737,1739,174,1743,3256,175,1750,176,2836,1764,178,1790,919,18,3226,1812,1815,182,1823,1825,602,1833,907,520,3282,1835,2887,1840,1847,1852,1857,654,19,1968,1457,2075,2085,2124,3258,2126,3259,2128,3257,2133,3263,2134,2135,504,2137,564,2158,676,3203,3204,216,2292,2294,2296,2298,888,2300,2302,2304,2306,2308,2314,1139,2316,2320,2322,627,2326,2328,2334,3081,2338,2340,2344,2346,2350,2362,2364,2368,2386,2390,2429,2455,2497,2698,2606,649,2620,3216,3217,300,3214,3215,3212,2622,2624,3213,2632,890,2644,2646,2648,2650,886,3248,887,681,2652,673,3206,3207,2654,3208,3209,2664,2666,1827,2678,2704,2708,2759,2763,2765,2779,2781,2789,2791,2793,2795,2797,2801,507,2803,410,2805,3186,3187,3189,2809,2811,2813,641,2819,2823,2826,3008,2828,283,1334,2838,2844,2846,2848,2850,2852,2854,2856,2879,2893,2895,2899,2901,2935,1872,662,3168,2945,2889,2951,2952,2953,2955,2834,2956,2981,3245,588,3249,2983,2984,3246,2991,3255,1749,3253,2992,3234,3106,2993,2995,2996,2999,830,3250,3251,3254,3,3000,3001,3002,3005,3010,3011,918,3013,3014,3015,3020,893,894,3233,892,897,898,1826,895,3156,896,3021,899,3022,3026,3194,3027,3036,3044,668,3048,646,3062,3063,3064,2769,3065,3066,3067,3068,3074,3075,657,3076,3077,3078,3079,3080,3084,3085,2842,3086,3109,3146,3147,3285,3148,3149,3152,881,883,3153,3157,3158,3162,3163,32,33,35,3266,2612,384,391,3223,3224,4,406,519,421,425,840,432,443,46,2694,2688,465,466,468,566,567,47,473,475,486,487,488,49,490,590,491,499,5,545,55,1042,59,63,2840,77,79,80,86,3165,3167,9,927,931,934,982,sysid", ",");
	this.arrFieldLookupFields=arraynew(1);
	this.mls_provider="rets7";
	this.sysidfield="rets7_sysid";
	resourceStruct=structnew();
	resourceStruct["property"]=structnew();
	resourceStruct["property"].resource="property";
	resourceStruct["property"].id="175";
	this.emptyStruct=structnew();
	
	
	
		variables.tableLookup=structnew();

		variables.tableLookup["RES"]="4";//Residential";
		variables.tableLookup["COM"]="1"//Commercial";
		variables.tableLookup["VAC"]="5";//Vacant-Land";
		variables.tableLookup["REN"]="3";//Rental";
		//variables.tableLookup["INC"]="2";//Income";
		variables.tableLookup["CP"]="6";//Cross Property";
	
variables.t5=structnew();

variables.t5["county"]=structnew();
variables.t5["county"]["524"]="VL"; // Volusia
variables.t5["county"]["526"]="WL"; // Walton
variables.t5["county"]["490"]="IR"; // Indian River
variables.t5["county"]["492"]="JE"; // Jefferson
variables.t5["county"]["493"]="LA"; // Lafayette
variables.t5["county"]["494"]="LK"; // Lake
variables.t5["county"]["463"]="BY"; // Bay
variables.t5["county"]["496"]="LN"; // Leon
variables.t5["county"]["465"]="BR"; // Brevard
variables.t5["county"]["466"]="BW"; // Broward
variables.t5["county"]["499"]="MD"; // Madison
variables.t5["county"]["468"]="CH"; // Charlotte
variables.t5["county"]["469"]="CI"; // Citrus
variables.t5["county"]["501"]="MA"; // Marion
variables.t5["county"]["504"]="MO"; // Monroe
variables.t5["county"]["505"]="NA"; // Nassau
variables.t5["county"]["507"]="OK"; // Okeechobee
variables.t5["county"]["508"]="OC"; // Orange
variables.t5["county"]["509"]="OS"; // Osceola
variables.t5["county"]["471"]="CO"; // Collier
variables.t5["county"]["472"]="CM"; // Columbia
variables.t5["county"]["473"]="DE"; // De Soto
variables.t5["county"]["474"]="DI"; // Dixie
variables.t5["county"]["498"]="LI"; // Liberty
variables.t5["county"]["476"]="ES"; // Escambia
variables.t5["county"]["477"]="FL"; // Flagler
variables.t5["county"]["479"]="FR"; // Gadsden
variables.t5["county"]["495"]="LE"; // Lee
variables.t5["county"]["497"]="LY"; // Levy
variables.t5["county"]["510"]="PB"; // Palm Beach
variables.t5["county"]["511"]="PO"; // Pasco
variables.t5["county"]["512"]="PN"; // Pinellas
variables.t5["county"]["513"]="PK"; // Polk
variables.t5["county"]["514"]="PU"; // Putnam
variables.t5["county"]["515"]="SJ"; // Saint Johns
variables.t5["county"]["516"]="SL"; // Saint Lucie
variables.t5["county"]["518"]="SA"; // Sarasota
variables.t5["county"]["519"]="SM"; // Seminole
variables.t5["county"]["480"]="GI"; // Gilchrist
variables.t5["county"]["484"]="HD"; // Hardee
variables.t5["county"]["485"]="HE"; // Hendry
variables.t5["county"]["486"]="HC"; // Hernando
variables.t5["county"]["487"]="HL"; // Highlands
variables.t5["county"]["488"]="HB"; // Hillsborough
variables.t5["county"]["500"]="MT"; // Manatee
variables.t5["county"]["461"]="AL"; // Alachua
variables.t5["county"]["462"]="BK"; // Baker
variables.t5["county"]["520"]="SU"; // Sumter
variables.t5["county"]["521"]="SW"; // Suwannee
variables.t5["county"]["522"]="TA"; // Taylor
variables.t5["county"]["523"]="UN"; // Union
variables.t5["countyreverse"]=structnew();
for(n in variables.t5["county"]){
	variables.t5["countyreverse"][variables.t5["county"][n]]=n;
}
this.remapFieldStruct=variables.t5;

	
	</cfscript>

    <cffunction name="deleteListings" localmode="modern" output="no" returntype="any">
    	<cfargument name="idlist" type="string" required="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		var arrId=listtoarray(mid(replace(arguments.idlist," ","","ALL"),2,len(arguments.idlist)-2),"','");
		super.deleteListings(arguments.idlist);
		db.sql="DELETE FROM #db.table("rets7_property", request.zos.zcoreDatasource)#  
		WHERE rets7_175 LIKE #db.param('#this.mls_id#-%')# and 
		rets7_175 IN (#db.trustedSQL(arguments.idlist)#)";
		db.execute("q"); 
		</cfscript>
    </cffunction>
    
    
    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		var rs5=0;
		var r222=0;
		var values="";
		var newlist="";
		var i=0;
		var columnIndex=structnew();
		var cityName=0;
		var address=0;
		var cid=0;
		var curLat=0;
		var curLong=0;
		var s=0;
		var cityStruct222=0;
		var arrt3=0;
		var uns=0;
		var tmp=0;
		var arrt=0;
		var arrt2=0;
		var ts2=0;
		var datacom=0;
		var values=0;
		var ts=0;
		var col=0;
		var rs=0;
		var s2=0;
		var sub=0;
		var arrS=0; 
		var c=0;
		var liststatus=0;
		var ad=0;
		if(structcount(this.emptyStruct) EQ 0){
			for(i=1;i LTE arraylen(this.arrColumns);i++){
				if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields, this.arrColumns[i])){
					this.emptyStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[this.arrColumns[i]].longname]="";
				}else{
					application.zcore.template.fail("I must update the arrColumns list with show fields from rets7_property");	
				}
			}
		}
		ts=duplicate(this.emptyStruct);
		/*
		
		wipe out the listings to reimport them again...
DELETE FROM `#request.zos.zcoreDatasource#`.listing_track WHERE listing_id LIKE '7-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing WHERE listing_id LIKE '7-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing_data WHERE listing_id LIKE '7-%';
DELETE FROM `#request.zos.zcoreDatasource#`.`zram#listing` WHERE listing_id LIKE '7-%';
DELETE FROM `#request.zos.zcoreDatasource#`.rets7_property where rets7_175 LIKE '7-%';
		
		
		*/
		if(arraylen(arguments.ss.arrData) NEQ arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.functions.zdump(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);
			application.zcore.functions.zdump(arguments.ss.arrData);
			application.zcore.functions.zabort();
		}  
		if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.template.fail("RETS#this.mls_id#: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
		}
		for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
			col=(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,6)].longname);
			ts["rets7_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,6)]=arguments.ss.arrData[i];
			if(arguments.ss.arrData[i] EQ '0'){
				arguments.ss.arrData[i]="";	
			}
			if(structkeyexists(ts,col)){
				if(ts[col] NEQ ""){
					ts[col]=ts[col]&","&application.zcore.functions.zescape(arguments.ss.arrData[i]);
				}else{
					ts[col]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
				}
			}else{ 
				ts[col]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
			}
			columnIndex[col]=i;
		}
		
		
		ts["list price"]=replace(ts["list price"],",","","ALL");
		
		// 2983=SW Subdv Community Name
		local.listing_subdivision="";
		if(local.listing_subdivision EQ ""){
			// 2316=Legal Subdivision Name
			if(findnocase(","&ts["Legal Subdivision Name"]&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["Legal Subdivision Name"]="";
			}else if(ts["Legal Subdivision Name"] NEQ ""){
				ts["Legal Subdivision Name"]=application.zcore.functions.zFirstLetterCaps(ts["Legal Subdivision Name"]);
			}
			local.listing_subdivision=ts["Legal Subdivision Name"];
		}
		if(local.listing_subdivision EQ ""){
			if(findnocase(","&ts["SW Subdv Community Name"]&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["SW Subdv Community Name"]="";
			}
			if(ts["SW Subdv Community Name"] NEQ ""){
				sub=this.getRETSValue("property", "", "2983",ts["SW Subdv Community Name"]);//," ","","ALL"));
				if(sub NEQ ""){
					ts["SW Subdv Community Name"]=sub;
				}
			}
			local.listing_subdivision=ts["SW Subdv Community Name"];
		}
		if(local.listing_subdivision EQ ""){
			// 2316=Complex/Community Name/NCCB
			if(findnocase(","&ts["Complex/Community Name/NCCB"]&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["Complex/Community Name/NCCB"]="";
			}else if(ts["Complex/Community Name/NCCB"] NEQ ""){
				ts["Complex/Community Name/NCCB"]=application.zcore.functions.zFirstLetterCaps(ts["Complex/Community Name/NCCB"]);
			}
			local.listing_subdivision=ts["Complex/Community Name/NCCB"];
		}
		
		if(ts["Property Type"] EQ "REN"){
			ts["list price"]=ts["Rent Price"];
		}
		
		this.price=ts["list price"];
		local.listing_price=ts["list price"];
		cityName="";
		cid=0;
		if(structkeyexists(request.zos.listing.cityStruct, ts["city"]&"|FL")){
			cid=request.zos.listing.cityStruct[ts["city"]&"|FL"];
		}
		local.listing_county="";
		if(structkeyexists(variables.t5["countyreverse"],ts['county'])){
			local.listing_county=variables.t5["countyreverse"][ts['county']];
		}
		if(local.listing_county EQ ""){
			local.listing_county=this.listingLookupNewId("county",ts['county']);
		}
		
	
		local.listing_sub_type_id=this.listingLookupNewId("listing_sub_type",ts['property style']);
		if(ts["Property Style"] CONTAINS "Subdivided Vacant Land"){
			local.listing_sub_type_id=358;
		}else if(ts["Property Style"] CONTAINS "Dude Ranch"){
			local.listing_sub_type_id=395;
		}else if(ts["Property Style"] CONTAINS "Farmland"){
			local.listing_sub_type_id=290;
		}else if(ts["Property Style"] CONTAINS "Timberland"){
			local.listing_sub_type_id=292;
		}else if(ts["Property Style"] CONTAINS "Ranchland"){
			local.listing_sub_type_id=299;
		}else if(ts["Property Style"] CONTAINS "Single Family Home"){
			local.listing_sub_type_id=273;
		}else if(ts["Property Style"] CONTAINS "Single Family Home"){
			local.listing_sub_type_id=276;
		}else if(ts["Property Style"] CONTAINS "Tree Farm"){
			local.listing_sub_type_id=404;
		}else if(ts["Property Style"] CONTAINS "Crop Producing Farm"){
			local.listing_sub_type_id=300;
		}else if(ts["Property Style"] CONTAINS "Working Ranch"){
			local.listing_sub_type_id=392;
		}else if(ts["Property Style"] CONTAINS "Residential Development"){
			local.listing_sub_type_id=286;
		}


		local.listing_type_id="";
		if(local.listing_type_id EQ "" and ts["Property Type"] EQ "COM"){
			local.listing_type_id=177;
		}else if(local.listing_type_id EQ "" and ts["Property Type"] EQ "REN"){
			local.listing_type_id=179;
		}else if(local.listing_type_id EQ "" and ts["Property Type"] EQ "VAC"){
			local.listing_type_id=181;
		}else if(local.listing_type_id EQ "" and ts["Property Use"] CONTAINS "MULTIFAMILY"){
			local.listing_type_id=178;
		}else if(local.listing_type_id EQ "" and ts["Property Style"] CONTAINS "Single Family Home"){
			local.listing_type_id=180;
		}else if(local.listing_type_id EQ "" and ts["Property Style"] CONTAINS "Condo"){
			local.listing_type_id=183;
		}else if(local.listing_type_id EQ "" and ts["Property Style"] CONTAINS "Condo-Hotel"){
			local.listing_type_id=183;
		}else if(local.listing_type_id EQ "" and ts["Property Style"] CONTAINS "Townhouse"){
			local.listing_type_id=183;
		}else if(local.listing_type_id EQ "" and ts["Property Style"] CONTAINS "Manufactured/Mobile Home"){
			local.listing_type_id=182;
		}else if(local.listing_type_id EQ "" and ts["Property Style"] CONTAINS "Multi-Family"){
			local.listing_type_id=178;
		} 
		if(local.listing_type_id EQ ""){
			local.listing_type_id=this.listingLookupNewId("listing_type",ts['property type']);
		}
		

		rs=getListingTypeWithCode(ts["property type"]);
		
		if(ts["Show Prop Address on Internet"] EQ "N"){
			ts["street ##"]="";
			ts["street name"]="";
			ts["street type"]="";
			ts["Unit ##"]="";
		}
		
		ts["property type"]=rs.id;
		ad=ts['street ##'];
		if(ad NEQ 0){
			address="#ad# ";
		}else{
			address="";	
		}
		address&=trim(ts['street name']&" "&ts['street type']);
		curLat='';
		curLong='';
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,ts['state id'],ts['zip code']);
			curLat=rs5.latitude;
			curLong=rs5.longitude;
		}
		address=application.zcore.functions.zfirstlettercaps(address);
		
		if(ts['Unit ##'] NEQ ''){
			address&=" Unit: "&ts["Unit ##"];	
		}
		
		ts2=structnew();
		ts2.field="";
		ts2.yearbuiltfield=ts['year built'];
		ts2.foreclosureField="";
		
		s=this.processRawStatus(ts2);
		
		arrS=listtoarray(ts['Special Sale Provision'],",");
		for(i=1;i LTE arraylen(arrS);i++){
			c=trim(arrS[i]);
			if(c EQ "Short Sale"){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
				break;
			}
			if(c EQ "REO/Bank Owned"){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
				break;
			}
		}
		if(ts['Realtor Info'] CONTAINS "In foreclosure"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		}
		if(ts['Realtor Info'] CONTAINS "Pre-foreclosure"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["pre-foreclosure"]]=true;
		}
		if(ts['New Construction'] EQ "Y"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
		}
		if(ts['property type'] EQ "REN"){
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
		}else{
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
		}
		arrT3=[];
		local.listing_status=structkeylist(s,",");
		
		uns=structnew();
		tmp=ts['Architectural Style'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				if(arrT[i] EQ "Traditional"){
					tmp=233;
				}else if(arrT[i] EQ "Spanish"){
					tmp=231;
				}else if(arrT[i] EQ "Colonial"){
					tmp=212;
				}else if(arrT[i] EQ "Contemporary"){
					tmp=213;
				}else if(arrT[i] EQ "Ranch"){
					tmp=229;
				}else{
					tmp=this.listingLookupNewId("style",arrT[i]);
				}
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT3,tmp);
				}
			}
		}
		local.listing_style=arraytolist(arrT3);
		


		arrT2=[];
		tmp=ts['garage/carport'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("parking",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT2,tmp);
				}
			}
		}
		tmp=ts['parking'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("parking",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT2,tmp);
				}
			}
		}
		local.listing_parking=arraytolist(arrT2, ",");
		
		if(structkeyexists(ts,'list date')){
			arguments.ss.listing_track_datetime=dateformat(ts["list date"],"yyyy-mm-dd")&" "&timeformat(ts["list date"], "HH:mm:ss");
		}
		arguments.ss.listing_track_updated_datetime=dateformat(ts["Last Update Date"],"yyyy-mm-dd")&" "&timeformat(ts["Last Update Date"], "HH:mm:ss");
		arguments.ss.listing_track_price=ts["Original List Price"];
		if(arguments.ss.listing_track_price EQ "" or arguments.ss.listing_track_price EQ "0" or arguments.ss.listing_track_price LT 100){
			arguments.ss.listing_track_price=ts["List Price"];
		}
		arguments.ss.listing_track_price_change=ts["List Price"];
		liststatus=ts["Status"];
		
		s2=structnew();
		if(liststatus EQ "ACT"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active"]]=true;
		}
		if(liststatus EQ "AWC"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active continue to show"]]=true;
		}
		if(liststatus EQ "WDN"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["withdrawn"]]=true;
		}
		if(liststatus EQ "TOM"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["temporarily withdrawn"]]=true;
		}
		if(liststatus EQ "PNC"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["pending"]]=true;
		}
		if(liststatus EQ "EXP"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["expired"]]=true;
		}
		if(liststatus EQ "SLD"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["sold"]]=true;
		}
		if(liststatus EQ "LSE"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["leased"]]=true;
		}
		if(liststatus EQ "LSO"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["lease option"]]=true;
		}
		if(liststatus EQ "RNT"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["rented"]]=true;
		}
		local.listing_liststatus=structkeylist(s2,",");
		if(local.listing_liststatus EQ ""){
			local.listing_liststatus=1;
		}
		
		// view & frontage
		arrT3=[];
		
		uns=structnew();
		if(ts['Water Frontage Y/N'] EQ "Y"){
			arrayappend(arrT3, 266);	
		}
		tmp=ts['water frontage'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				if(arrT[i] EQ "Gulf/Ocean"){
					tmp=268;
				}else if(arrT[i] EQ "ICW"){
					tmp=269;
				}else if(arrT[i] EQ "Lake" or arrT[i] EQ "Lake/Chain"){
					tmp=272;
				}else if(arrT[i] EQ "Ocean2Bay" or arrT[i] EQ "Bay/Harbor"){
					tmp=264;
				}else if(arrT[i] EQ "Gulf/Ocean"){
					tmp=265;
				}else if(arrT[i] EQ "Canal-Fresh" or arrT[i] EQ "Canal-Salt"){
					tmp=267;
				}else{
					tmp=this.listingLookupNewId("frontage",arrT[i]);
				}
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT3,tmp);
				}
			}
		}
		if(ts["location"] CONTAINS "Golf Course Frontage"){
			arrayappend(arrT3,270);
		}
		local.listing_frontage=arraytolist(arrT3);
		
		
		arrT2=[];
		uns=structnew();

		if(ts["location"] CONTAINS "Greenbelt View"){
			arrayappend(arrT2,257);
		}
		if(ts["location"] CONTAINS "Golf Course View"){
			arrayappend(arrT2,255);
		}
		if(ts["location"] CONTAINS "Tennis Ct View"){
			arrayappend(arrT2,254);
		}
		if(ts["location"] CONTAINS "Pool View"){
			arrayappend(arrT2,241);
		}
		if(ts["location"] CONTAINS "Park View"){
			arrayappend(arrT2,244);
		}
		if(ts["Water Access"] CONTAINS "Lake"){
			arrayappend(arrT2,262);
		}
		if(ts["Water Access"] CONTAINS "Gulf/Ocean"){
			arrayappend(arrT2,239);
		}
		if(ts["Water Access"] CONTAINS "River"){
			arrayappend(arrT2,250);
		}
		if(ts["Water Access"] CONTAINS "Gulf/Ocean"){
			arrayappend(arrT2,253);
		}
		if(ts["Water View"] CONTAINS "Bay/Harbor"){
			arrayappend(arrT2,263);
		}
		if(ts["Water View Y/N"] EQ "Y"){
			arrayappend(arrT2,243);
		}
		if(ts["Water View"] CONTAINS "Lagoon"){
			arrayappend(arrT2,243);
		}
		
		tmp=ts['water view'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("view",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT2,tmp);
				}
			}
		}
		tmp=ts['water access'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("view",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT2,tmp);
				}
			}
		}
		if(ts["location"] CONTAINS "Pool View"){
			tmp=this.listingLookupNewId("view","Pool View");
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT2,tmp);
			}
		}
		if(ts["location"] CONTAINS "Park View"){
			tmp=this.listingLookupNewId("view","Park View");
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT2,tmp);
			}
		}
		local.listing_view=arraytolist(arrT2);
		

		local.listing_pool=0;
		if((structkeyexists(ts, "pool type") and ts["pool type"] NEQ "") or (structkeyexists(ts, "community features") and ts["community features"] CONTAINS "pool" and ts["community features"] DOES NOT CONTAIN "no pool")){			local.listing_pool=1;	
		}
		
		if(structkeyexists(variables.tableLookup,ts.rets7_1)){
			ts=this.convertRawDataToLookupValues(ts, variables.tableLookup[ts.rets7_1], ts.rets7_1);
		}
		dataCom=this.getRetsDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		
		
		newList=replace(application.zcore.functions.zescape(arraytolist(arguments.ss.arrData,chr(9))),chr(9),"','","ALL");
		values="('"&newList&"')";  
		arrayappend(request.zos.importMlsStruct[this.mls_id].arrImportIDXRows,values);
		
		rs=structnew();
		rs.listing_id=arguments.ss.listing_id;
		rs.listing_acreage=ts["Lot Size [Acres]"];
		rs.listing_baths=ts["Full Baths"];
		rs.listing_halfbaths=ts["Half Baths"];
		rs.listing_beds=ts["beds"];
		rs.listing_city=cid;
		rs.listing_county=local.listing_county;
		rs.listing_frontage=","&local.listing_frontage&",";
		rs.listing_frontage_name="";
		rs.listing_price=ts["list price"];
		rs.listing_status=","&local.listing_status&",";
		rs.listing_state=ts["state id"];
		rs.listing_type_id=local.listing_type_id;
		rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
		rs.listing_style=","&local.listing_style&",";
		rs.listing_view=","&local.listing_view&",";
		rs.listing_lot_square_feet=ts["Lot Size [SqFt]"];
		rs.listing_square_feet=ts["Sq Ft Heated"];
		rs.listing_subdivision=local.listing_subdivision;
		rs.listing_year_built=ts["year built"];
		rs.listing_office=ts["Office ID ##"];
		rs.listing_agent=ts["Agent ID"];
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=local.listing_pool;
		rs.listing_photocount=ts["Photos, Number of"];
		rs.listing_coded_features="";
		rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
		rs.listing_primary="0";
		rs.listing_mls_id=arguments.ss.listing_mls_id;
		rs.listing_address=trim(address);
		rs.listing_zip=ts["zip code"];
		rs.listing_condition="";
		rs.listing_parking=local.listing_parking;
		rs.listing_region="";
		rs.listing_tenure="";
		rs.listing_liststatus=local.listing_liststatus;
		rs.listing_data_remarks=ts["public remarks new"];
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(ts["zip code"]);
		rs.listing_data_detailcache1=listing_data_detailcache1;
		rs.listing_data_detailcache2=listing_data_detailcache2;
		rs.listing_data_detailcache3=listing_data_detailcache3;
		return rs;
		</cfscript>
    </cffunction>
    
    <cffunction name="getJoinSQL" localmode="modern" output="yes" returntype="any">
		<cfscript>
		var db=request.zos.queryObject;
		</cfscript>
    	<cfreturn "INNER JOIN #db.table("rets7_property", request.zos.zcoreDatasource)# rets7_property ON rets7_property.rets7_175 = listing.listing_id">
    </cffunction>
    <cffunction name="getDetails" localmode="modern" output="yes" returntype="any">
    	<cfargument name="query" type="query" required="yes">
        <cfargument name="row" type="numeric" required="no" default="#1#">
        <cfargument name="fulldetails" type="boolean" required="no" default="#false#">
    	<cfscript>
		var q1=0;
		var t1=0;
		var t3=0;
		var t2=0;
		var i10=0;
		var value=0;
		var shortColumn=0;
		var curTableData=0;
		var t4=0;
		var i=0;
		var n=0;
		var column=0;
		var arrV=0;
		var t44444=0;
		var t99=0;
		var details=0;
		var arrV2=0;
		var idx=this.baseGetDetails(arguments.query, arguments.row, arguments.fulldetails);
		t99=gettickcount();
		idx["features"]="";
		t44444=0;
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		request.lastPhotoId="";
		if(arguments.query.listing_photocount EQ 0){
			// check for permanent images or show not available image.
			if(fileexists(request.zos.globals.serverhomedir&"a/listings/images/images_permanent/#idx.urlMlsPid#.jpg")){
				idx["photo1"]='/z/a/listing/images/images_permanent/#idx.urlMlsPid#.jpg';
			}else{
				idx["photo1"]='/z/a/listing/images/image-not-available.gif';
			}
		}else{
			i=1;
			
			for(i=1;i LTE arguments.query.listing_photocount;i++){
				
				local.fNameTemp1=arguments.query.listing_id&"-"&i&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				local.absPath='#request.zos.sharedPath#mls-images/7/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				if(fileexists(local.absPath)){
					if(i EQ 1){
						request.lastPhotoId=arguments.query.listing_id;
					}
					idx["photo"&i]=request.zos.currentHostName&'/zretsphotos/7/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				}else{
					idx["photo"&i]='/z/a/listing/images/image-not-available.gif';
					if(i EQ 1){
						request.lastPhotoId="";
					}
					/*
					if(i EQ 1){
						request.lastPhotoId=this.mls_id&"-"&arguments.query.rets7_sysid;
					}
					local.fNameTemp1=arguments.query.rets7_sysid&"-"&i&".jpeg";
					local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
					idx["photo"&i]=request.zos.currentHostName&'/zretsphotos/7/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
					*/
				}
			}
		}
			idx["agentName"]=arguments.query["rets7_35"];
			idx["agentPhone"]="";
			idx["agentEmail"]="";
			idx["officeName"]=arguments.query["rets7_2368"];
			idx["officePhone"]="";
			idx["officeCity"]="";
			idx["officeAddress"]="";
			idx["officeZip"]="";
			idx["officeState"]="";
			idx["officeEmail"]="";
			
		idx["virtualtoururl"]=arguments.query["rets7_2497"];
		idx["zipcode"]=arguments.query["rets#this.mls_id#_46"][arguments.row];
		if(arguments.query["rets#this.mls_id#_1418"][arguments.row] NEQ ""){
			idx["maintfees"]=arguments.query["rets#this.mls_id#_1418"][arguments.row];
		}else{
			idx["maintfees"]=arguments.query["rets#this.mls_id#_1833"][arguments.row];
		}
		
		
		</cfscript>
        <cfsavecontent variable="details">
        <table class="ztablepropertyinfo">
        #idx.listing_data_detailcache1#
        #idx.listing_data_detailcache2#
        #idx.listing_data_detailcache3#
        </table>
        </cfsavecontent>
        <cfscript>
		idx.details=details;
		
		return idx;
		</cfscript>
    </cffunction>
    
    
    <cffunction name="getPhoto" localmode="modern" output="no" returntype="any">
    	<cfargument name="mls_pid" type="string" required="yes">
        <cfargument name="num" type="numeric" required="no" default="#1#">
        <cfargument name="sysid" type="string" required="no" default="0">
    	<cfscript>
		var qId=0;
		var db=request.zos.queryObject;
		var local=structnew();
		request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
		local.fNameTemp1=this.mls_id&"-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
		local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
		local.absPath='#request.zos.sharedPath#mls-images/7/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		if(fileexists(local.absPath)){
			return request.zos.currentHostName&'/zretsphotos/7/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		}else{
			request.lastPhotoId="";
			return "";
		}
		/*else{
			if(arguments.sysid EQ 0){
				db.sql="select SQL_NO_CACHE rets7_sysid 
				from #db.table("rets7_property", request.zos.zcoreDatasource)# rets7_property 
				where rets7_175=#db.param('7-#arguments.mls_pid#')#";
				qId=db.execute("qId"); 
				if(qId.recordcount NEQ 0){
					arguments.sysid=qId.rets7_sysid;
				}
			}
			request.lastPhotoId="";
			if(arguments.sysid NEQ 0){
				request.lastPhotoId=this.mls_id&"-"&arguments.sysid;
				local.fNameTemp1=arguments.sysid&"-"&arguments.num&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				return request.zos.currentHostName&'/zretsphotos/7/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
			}else{
				request.lastPhotoId="";
				return "";
			}
		}*/
		</cfscript>
    </cffunction>
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript>
		var i=0;
		var s=0;
		var arrSQL=[];
		var fd=0;
		var arrError=[];
		var i2=0;
		var tmp=0;

		// 19=county
		fd=this.getRETSValues("property", "","19");
		for(i in fd){
			if(structkeyexists(this.remapFieldStruct["countyreverse"],i)){
				i2=this.remapFieldStruct["countyreverse"][i];	
			}else{
				i2=i;
			}
			arrayappend(arrSQL,"('#this.mls_provider#','county','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
		}
		
		
		fd=this.getRETSValues("property", "","491");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','parking','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#')");
		}
		fd=this.getRETSValues("property", "","2805");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','parking','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#')");
		}
		
		// property style
		fd=this.getRETSValues("property", "","77");
		for(i in fd){
			if(i EQ "Subdivided Vacant Land"){		i2=358;
			}else if(i EQ "Dude Ranch"){		i2=395;
			}else if(i EQ "Farmland"){		i2=290;
			}else if(i EQ "Timberland"){		i2=292;
			}else if(i EQ "Ranchland"){		i2=299;
			}else if(i EQ "Single Family Home"){		i2=273;
			}else if(i EQ "Tree Farm"){		i2=404;
			}else if(i EQ "Crop Producing Farm"){		i2=300;
			}else if(i EQ "Working Ranch"){		i2=392;
			}else if(i EQ "Residential Development"){		i2=286;
			}else{
				i2=i;
			}
			arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
		}
		
		fd=this.getRETSValues("property", "","519");
		for(i in fd){
			if(i EQ "Subdivided Vacant Land"){		i2=358;
			}else if(i EQ "Dude Ranch"){		i2=395;
			}else if(i EQ "Farmland"){		i2=290;
			}else if(i EQ "Timberland"){		i2=292;
			}else if(i EQ "Ranchland"){		i2=299;
			}else if(i EQ "Single Family Home"){		i2=273;
			}else if(i EQ "Tree Farm"){		i2=404;
			}else if(i EQ "Crop Producing Farm"){		i2=300;
			}else if(i EQ "Working Ranch"){		i2=392;
			}else if(i EQ "Residential Development"){		i2=286;
			}else{
				i2=i;
			}
			arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
		}
		
		fd=this.getRETSValues("property", "","934");
		for(i in fd){
			if(i EQ "Subdivided Vacant Land"){		i2=358;
			}else if(i EQ "Dude Ranch"){		i2=395;
			}else if(i EQ "Farmland"){		i2=290;
			}else if(i EQ "Timberland"){		i2=292;
			}else if(i EQ "Ranchland"){		i2=299;
			}else if(i EQ "Single Family Home"){		i2=273;
			}else if(i EQ "Tree Farm"){		i2=404;
			}else if(i EQ "Crop Producing Farm"){		i2=300;
			}else if(i EQ "Working Ranch"){		i2=392;
			}else if(i EQ "Residential Development"){		i2=286;
			}else{
				i2=i;
			}
			arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
		}
		
		fd=this.getRETSValues("property", "","1349");
		for(i in fd){
			if(i EQ "Subdivided Vacant Land"){		i2=358;
			}else if(i EQ "Dude Ranch"){		i2=395;
			}else if(i EQ "Farmland"){		i2=290;
			}else if(i EQ "Timberland"){		i2=292;
			}else if(i EQ "Ranchland"){		i2=299;
			}else if(i EQ "Single Family Home"){		i2=273;
			}else if(i EQ "Tree Farm"){		i2=404;
			}else if(i EQ "Crop Producing Farm"){		i2=300;
			}else if(i EQ "Working Ranch"){		i2=392;
			}else if(i EQ "Residential Development"){		i2=286;
			}else{
				i2=i;
			}
			arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
		}
		
		fd=this.getRETSValues("property", "","1764");
		for(i in fd){
			if(i EQ "Subdivided Vacant Land"){		i2=358;
			}else if(i EQ "Dude Ranch"){		i2=395;
			}else if(i EQ "Farmland"){		i2=290;
			}else if(i EQ "Timberland"){		i2=292;
			}else if(i EQ "Ranchland"){		i2=299;
			}else if(i EQ "Single Family Home"){		i2=273;
			}else if(i EQ "Tree Farm"){		i2=404;
			}else if(i EQ "Crop Producing Farm"){		i2=300;
			}else if(i EQ "Working Ranch"){		i2=392;
			}else if(i EQ "Residential Development"){		i2=286;
			}else{
				i2=i;
			}
			arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
		}
		arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','Single Family Home','276','#request.zos.mysqlnow#','Single Family Home')");
		
		
				
				
				
				
		// property style lookups
		fd=this.getRETSValues("property", "","77");
		for(i in fd){
			if(i EQ "Condo"){		i2=183;
			}else if(i EQ "Condo-Hotel"){		i2=183;
			}else if(i EQ "Townhouse"){		i2=183;
			}else if(i EQ "Manufactured/Mobile Home"){		i2=182;
			}else if(i EQ "Multi-Family"){		i2=178;
			}else if(i EQ "Single Family Home"){		i2=180;
			}else{
				i2="";
			}
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
			}
		}
		fd=this.getRETSValues("property", "","519");
		for(i in fd){
			if(i EQ "Condo"){		i2=183;
			}else if(i EQ "Condo-Hotel"){		i2=183;
			}else if(i EQ "Townhouse"){		i2=183;
			}else if(i EQ "Manufactured/Mobile Home"){		i2=182;
			}else if(i EQ "Multi-Family"){		i2=178;
			}else if(i EQ "Single Family Home"){		i2=180;
			}else{
				i2="";
			}
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
			}
		}
		fd=this.getRETSValues("property", "","934");
		for(i in fd){
			if(i EQ "Condo"){		i2=183;
			}else if(i EQ "Condo-Hotel"){		i2=183;
			}else if(i EQ "Townhouse"){		i2=183;
			}else if(i EQ "Manufactured/Mobile Home"){		i2=182;
			}else if(i EQ "Multi-Family"){		i2=178;
			}else if(i EQ "Single Family Home"){		i2=180;
			}else{
				i2="";
			}
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
			}
		}
		fd=this.getRETSValues("property", "","1349");
		for(i in fd){
			if(i EQ "Condo"){		i2=183;
			}else if(i EQ "Condo-Hotel"){		i2=183;
			}else if(i EQ "Townhouse"){		i2=183;
			}else if(i EQ "Manufactured/Mobile Home"){		i2=182;
			}else if(i EQ "Multi-Family"){		i2=178;
			}else if(i EQ "Single Family Home"){		i2=180;
			}else{
				i2="";
			}
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
			}
		}
		fd=this.getRETSValues("property", "","1764");
		for(i in fd){
			if(i EQ "Condo"){		i2=183;
			}else if(i EQ "Condo-Hotel"){		i2=183;
			}else if(i EQ "Townhouse"){		i2=183;
			}else if(i EQ "Manufactured/Mobile Home"){		i2=182;
			}else if(i EQ "Multi-Family"){		i2=178;
			}else if(i EQ "Single Family Home"){		i2=180;
			}else{
				i2="";
			}
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
			}
		}
		
		// 86=property use
		fd=this.getRETSValues("property", "","86");
		for(i in fd){
			if(i EQ "MULTIFAMILY"){
				i2=178;
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
			}
		}
		// 1=property type
		fd=this.getRETSValues("property", "","1");
		//fd["M"]="Multi-Family";
		for(i in fd){
			if(i EQ "COM"){
				i2=177;
			}else if(i EQ "REN"){
				i2=179;
			}else if(i EQ "VAC"){
				i2=181;
			}else{
				i2=i;
			}
			arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
		}
		
		
		
		// frontage
		fd=this.getRETSValues("property", "","3067");
		for(i in fd){
			if(i EQ "Gulf/Ocean"){
				tmp=268;
			}else if(i EQ "ICW"){
				tmp=269;
			}else if(i EQ "Lake" or i EQ "Lake/Chain"){
				tmp=272;
			}else if(i EQ "Ocean2Bay" or i EQ "Bay/Harbor"){
				tmp=264;
			}else if(i EQ "Gulf/Ocean"){
				tmp=265;
			}else if(i EQ "Canal-Fresh" or i EQ "Canal-Salt"){
				tmp=267;
			}else{
				tmp=i;
			}
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#')");
		}
		// Water Frontage Y/N
		arrayappend(arrSQL,"('#this.mls_provider#','frontage','Waterfront','266','#request.zos.mysqlnow#','266')");
		
		// Location:Golf Course Frontage
		arrayappend(arrSQL,"('#this.mls_provider#','frontage','Golf Course Frontage','270','#request.zos.mysqlnow#','270')");
		
		
		
		// view
		
		fd=this.getRETSValues("property", "","3068");
		for(i in fd){
			if(i EQ "Lake"){
				tmp=262;
			}else if(i EQ "Bay/Harbor"){
				tmp=263;
			}else if(i EQ "Lagoon"){
				tmp=238;
			}else if(i EQ "River"){
				tmp=250;
			}else if(i EQ "Gulf/Ocean"){
				tmp=253;
			}else{
				tmp=i;
			}
			arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#')");
		}
		arrayappend(arrSQL,"('#this.mls_provider#','view','Gulf/Ocean','239','#request.zos.mysqlnow#','Gulf/Ocean')");
		// Location:Pool View
		arrayappend(arrSQL,"('#this.mls_provider#','view','Pool View','241','#request.zos.mysqlnow#','241')");
		
		// Location:Park View
		arrayappend(arrSQL,"('#this.mls_provider#','view','Park View','244','#request.zos.mysqlnow#','244')");
		
		// Water View Y/N
		arrayappend(arrSQL,"('#this.mls_provider#','view','Waterview','243','#request.zos.mysqlnow#','243')");
		
		
		// 1716=architectural style
		// 886=architectural style
		fd=this.getRETSValues("property", "","1716");
		for(i in fd){
			if(i EQ "Traditional"){
				tmp=233;
			}else if(i EQ "Spanish"){
				tmp=231;
			}else if(i EQ "Colonial"){
				tmp=212;
			}else if(i EQ "Contemporary"){
				tmp=213;
			}else if(i EQ "Ranch"){
				tmp=229;
			}else{
				tmp=i;
			}
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#')");
		}
		
		fd=this.getRETSValues("property", "","886");
		for(i in fd){
			if(i EQ "Traditional"){
				tmp=233;
			}else if(i EQ "Spanish"){
				tmp=231;
			}else if(i EQ "Colonial"){
				tmp=212;
			}else if(i EQ "Contemporary"){
				tmp=213;
			}else if(i EQ "Ranch"){
				tmp=229;
			}else{
				tmp=i;
			}
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#')");
		}
		

		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>