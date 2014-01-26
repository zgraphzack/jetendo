<cfcomponent>
<cfoutput>
	<cfscript>
    variables.idxExclude=structnew();
variables.allfields=structnew();
    </cfscript>
	<cffunction name="findFieldsInDatabaseNotBeingOutput" localmode="modern" access="remote" roles="member" output="yes" returntype="any">
    	<cfscript>
		var db=request.zos.queryObject;
		var qT=0;
		var f2=0;
		var idxExclude=structnew();
		var i=0;
		</cfscript>
        <cfsavecontent variable="db.sql"> SHOW FIELDS FROM #request.zos.queryObject.table("rets7_property", request.zos.zcoreDatasource)#  </cfsavecontent>
        <cfscript>
        qT=db.execute("qT");
        
        variables.allfields=structnew();
        </cfscript>
        <cfloop query="qT">
			<cfscript>
            curField=replacenocase(qT.field, "rets7_","");
            if(structkeyexists(application.zcore.listingStruct.mlsStruct["7"].sharedStruct.metaStruct["property"].tableFields, curField)){
            	f2=application.zcore.listingStruct.mlsStruct["7"].sharedStruct.metaStruct["property"].tableFields[curField].longname;
            }else{
            	f2=curField;
            }
            variables.allfields[qT.field]=f2;
            </cfscript>
        </cfloop>
		<cfscript>
		idxExclude["rets7_3206"]="Leased Agent ID:";
		idxExclude["rets7_3207"]="Leased Agent Name:";
		idxExclude["rets7_3208"]="Leased Office ID:";
		idxExclude["rets7_3209"]="Leased Office Name:";
		idxExclude["rets7_3187"]="Public Remarks New";
		idxExclude["rets7_1042"]="Public Remarks:";
		idxExclude["rets7_2608"]="List Agent 2 Phone";
		idxExclude["rets7_28"]="Previous Expire Date";
		idxExclude["rets7_2997"]="Recip Sell Agent Name";
		idxExclude["rets7_3046"]="Idx/vow Display Comments Y/n";
		idxExclude["rets7_3179"]="Dpr Url 2";
		idxExclude["rets7_3009"]="Listing W Photo Approved";
		idxExclude["rets7_3168"]="Dpr Url";
		idxExclude["rets7_2979"]="Ladom";
		idxExclude["rets7_2380"]="Agent Home Page";
		idxExclude["rets7_106"]="Entry Date:";
		idxExclude["rets7_108"]="Listing Date:";
		idxExclude["rets7_109"]="Expiration Date:";
		idxExclude["rets7_112"]="Last Update Date:";
		idxExclude["rets7_1296"]="Realtor Info:";
		idxExclude["rets7_property_id"]="property id:";
		idxExclude["rets7_140"]="Sold Office ID:";
		idxExclude["rets7_1"]="Property Type:";
		idxExclude["rets7_138"]="Office ID ##:";
		idxExclude["rets7_1457"]="Public Remarks:";
		idxExclude["rets7_165"]="Street ##:";
		idxExclude["rets7_17"]="Agent ID:";
		idxExclude["rets7_176"]="List Price:";
		idxExclude["rets7_1711"]="Realtor Info:";
		idxExclude["rets7_175"]="ML## (w/Board ID):";
		idxExclude["rets7_18"]="Selling Agent ID:";
		idxExclude["rets7_1872"]="Public Remarks:";
		idxExclude["rets7_204"]="Public Remarks:";
		idxExclude["rets7_2126"]="Realtor Info:";
		idxExclude["rets7_2294"]="Full Baths:";
		idxExclude["rets7_2296"]="Half Baths:";
		idxExclude["rets7_2298"]="Price Change Date:";
		idxExclude["rets7_2304"]="State ID:";
		idxExclude["rets7_2306"]="Street Type:";
		idxExclude["rets7_2338"]="Trans Broker Comp:";
		idxExclude["rets7_2340"]="Buyer Agent Comp:";
		idxExclude["rets7_2344"]="Non-Rep Comp:";
		idxExclude["rets7_2368"]="Office Name:";
		idxExclude["rets7_2386"]="Sell Agent Name:";
		idxExclude["rets7_2390"]="Sell Office Name:";
		idxExclude["rets7_2429"]="IDX Y/N:";
		idxExclude["rets7_2455"]="List Agent 2 ID:";
		idxExclude["rets7_2497"]="Virtual Tour Link:";
		idxExclude["rets7_2606"]="List Agent 2 Name:";
		idxExclude["rets7_2612"]="Virtual Tour:";
		idxExclude["rets7_2620"]="Office Primary Board ID :";
		idxExclude["rets7_2708"]="MLS Area - Zip:";
		idxExclude["rets7_2759"]="LastImgTransDate:";
		idxExclude["rets7_2781"]="Sales Team Name:";
		idxExclude["rets7_2852"]="Temporary Off-Market Date:";
		idxExclude["rets7_2887"]="Withdrawn Date:";
		idxExclude["rets7_2935"]="LSC List Side:";
		idxExclude["rets7_2991"]="Selling Agent 2 ID:";
		idxExclude["rets7_2992"]="Listing Office 2 ID ##:";
		idxExclude["rets7_2993"]="Selling Office 2 ID:";
		idxExclude["rets7_2995"]="Listing Office 2 Name:";
		idxExclude["rets7_2996"]="Selling Office 2 Name:";
		idxExclude["rets7_3"]="Record Delete Flag:";
		idxExclude["rets7_300"]="Contract Date:";
		idxExclude["rets7_3010"]="Show Prop Address on Internet:";
		idxExclude["rets7_3020"]="Selling Agent 2 Name:";
		idxExclude["rets7_3044"]="Internet Y/N:";
		idxExclude["rets7_3062"]="Special Sale Provision:";
		idxExclude["rets7_35"]="Agent Name:";
		idxExclude["rets7_391"]="Sold Price:";
		idxExclude["rets7_4"]="Record Delete Date:";
		idxExclude["rets7_406"]="Sold Date:";
		idxExclude["rets7_410"]="Sold Agent ID:";
		idxExclude["rets7_421"]="Street Name:";
		idxExclude["rets7_466"]="Realtor Info:";
		idxExclude["rets7_47"]="Zip Plus 4:";
		idxExclude["rets7_49"]="Address:";
		idxExclude["rets7_59"]="Status Change Date:";
		idxExclude["rets7_627"]="Public Remarks:";
		idxExclude["rets7_5"]="Last Transaction Code:";
		idxExclude["rets7_881"]="Realtor Info:";
		idxExclude["rets7_918"]="Active Status Date:";
		idxExclude["rets7_sysid"]="sysid:";
		idxExclude["rets7_9"]="Photos, Number of:";
		idxExclude["rets7_504"]="Additional Public Remarks:";
		idxExclude["rets7_3209"]="Leased Office Name";
		idxExclude["rets7_3207"]="Leased Agent Name";
		idxExclude["rets7_3208"]="Leased Office Id";
		idxExclude["rets7_3206"]="Leased Agent Id";
		idxExclude["rets7_2777"]="Agent Office Ext.";
		idxExclude["rets7_2889"]="Ml## (no Board Id)";
		idxExclude["rets7_2771"]="Referral Fee";
		
		application.zcore.listingCom=createobject("component", "zcorerootmapping.mvc.z.listing.controller.listing");
		// force allfields to not have the fields that already used
		this.getDetailCache1(structnew());
		this.getDetailCache2(structnew());
		this.getDetailCache3(structnew());
		
		if(structcount(variables.allfields) NEQ 0){
			writeoutput('<h2>All Fields:</h2>');
			for(i in variables.allfields){
				if(structkeyexists(idxExclude, i) EQ false){
					writeoutput('idxTemp2["'&i&'"]="'&replace(application.zcore.functions.zfirstlettercaps(variables.allfields[i]),"##","####")&'";<br />');
				}
			}
		}
		application.zcore.functions.zabort();</cfscript>
	</cffunction>

	<!--- <table class="ztablepropertyinfo"> --->
    <cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
      <cfargument name="idx" type="struct" required="yes">
      <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["rets7_3083"]="Garage Dimensions";
		idxTemp2["rets7_3198"]="Indoor Air Quality";
		idxTemp2["rets7_3191"]="Indoor Air Quality";
		idxTemp2["rets7_3127"]="Living Room";
		idxTemp2["rets7_3129"]="Family Room";
		idxTemp2["rets7_3128"]="Dining Room";
		idxTemp2["rets7_3119"]="Warehouse Space(total)";
		idxTemp2["rets7_3136"]="5th Bedroom";
		idxTemp2["rets7_3135"]="4th Bedroom";
		idxTemp2["rets7_3134"]="3rd Bedroom";
		idxTemp2["rets7_3133"]="2nd Bedroom";
		idxTemp2["rets7_3139"]="Bonus Room";
		idxTemp2["rets7_3138"]="Dinette";
		idxTemp2["rets7_3137"]="Balcony/porch/lanai";
		idxTemp2["rets7_3132"]="Master Bedroom";
		idxTemp2["rets7_3131"]="Kitchen";
		idxTemp2["rets7_3130"]="Great Room";
		idxTemp2["rets7_3118"]="Warehouse Space(heated)";
		idxTemp2["rets7_1310"]="Interior Layout:";
		idxTemp2["rets7_1317"]="Air Conditioning:";
		idxTemp2["rets7_1321"]="Garage Features:";
		idxTemp2["rets7_1314"]="Floor Covering:";
		idxTemp2["rets7_1302"]="Additional Rooms:";
		idxTemp2["rets7_1316"]="Heating and Fuel:";
		idxTemp2["rets7_1354"]="Bonus Room (Approx.):";
		idxTemp2["rets7_1381"]="Dining Room (Approx.):";
		idxTemp2["rets7_1384"]="Dinette (Approx.):";
		idxTemp2["rets7_887"]="Additional Rooms:";
		idxTemp2["rets7_893"]="Fireplace Description:";
		idxTemp2["rets7_894"]="Master Bath Features:";
		idxTemp2["rets7_895"]="Interior Layout:";
		idxTemp2["rets7_896"]="Interior Features:";
		idxTemp2["rets7_897"]="Kitchen Features:";
		idxTemp2["rets7_898"]="Appliances Included:";
		idxTemp2["rets7_899"]="Floor Covering:";
		idxTemp2["rets7_901"]="Heating and Fuel:";
		idxTemp2["rets7_902"]="Air Conditioning:";
		idxTemp2["rets7_906"]="Garage Features:";
		idxTemp2["rets7_3224"]="Furnishings:";
		idxTemp2["rets7_3218"]="Kitchen Features:";
		idxTemp2["rets7_3216"]="Interior Features:";
		idxTemp2["rets7_1405"]="Family Room (Approx.):";
		idxTemp2["rets7_1415"]="Living Room (Approx.):";
		idxTemp2["rets7_1426"]="Kitchen (Approx.):";
		idxTemp2["rets7_1466"]="Master Bedroom (Approx.):";
		idxTemp2["rets7_1495"]="2nd Bedroom (Approx.):";
		idxTemp2["rets7_1514"]="3rd Bedroom (Approx.):";
		idxTemp2["rets7_1518"]="4th Bedroom (Approx.):";
		idxTemp2["rets7_1522"]="5th Bedroom (Approx.):";
		idxTemp2["rets7_1716"]="Architectural Style:";
		idxTemp2["rets7_1717"]="Additional Rooms:";
		idxTemp2["rets7_1723"]="Fireplace Description:";
		idxTemp2["rets7_1724"]="Master Bath Features:";
		idxTemp2["rets7_1725"]="Interior Layout:";
		idxTemp2["rets7_1726"]="Interior Features:";
		idxTemp2["rets7_1727"]="Kitchen Features:";
		idxTemp2["rets7_1728"]="Appliances Included:";
		idxTemp2["rets7_1729"]="Floor Covering:";
		idxTemp2["rets7_1731"]="Heating and Fuel:";
		idxTemp2["rets7_1732"]="Air Conditioning:";
		idxTemp2["rets7_1736"]="Garage Features:";
		idxTemp2["rets7_216"]="Ceiling Height:";
		idxTemp2["rets7_2346"]="Sq Ft Heated:";
		idxTemp2["rets7_2654"]="Freezer Space Y/N:";
		idxTemp2["rets7_2840"]="Appliances Included:";
		idxTemp2["rets7_2893"]="Fireplace Y/N:";
		idxTemp2["rets7_2895"]="Fireplace Description:";
		idxTemp2["rets7_2945"]="Studio Dimensions:";
		idxTemp2["rets7_3077"]="Study/Den Dimensions:";
		idxTemp2["rets7_3021"]="Great Room (Approx.):";
		idxTemp2["rets7_3157"]="Master Bed Size:";
		idxTemp2["rets7_3158"]="Window Coverings:";
		idxTemp2["rets7_32"]="Beds:";
		idxTemp2["rets7_486"]="Heating and Fuel:";
		idxTemp2["rets7_2648"]="## of Restrooms:";
		idxTemp2["rets7_2650"]="## of Offices:";
		idxTemp2["rets7_487"]="Air Conditioning:";
		idxTemp2["rets7_2803"]="Floors in Unit:";
		idxTemp2["rets7_2644"]="## of Hotel/Motel Rms:";
		idxTemp2["rets7_2646"]="## of Bays:";
		idxTemp2["rets7_3250"]="Door Height";
		idxTemp2["rets7_3251"]="Door Width";
		idxTemp2["rets7_3257"]="Floor Coverings";
		idxTemp2["rets7_3258"]="Ceiling Type";
		idxTemp2["rets7_3249"]="Garage Door Height";
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Interior Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		return arraytolist(arrR,'');
		
		</cfscript>
	</cffunction>
    
    
	<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		// exterior features
		idxTemp2["rets7_3182"]="Green Energy Features";
		idxTemp2["rets7_3183"]="Green Water Features";
		idxTemp2["rets7_3195"]="Green Site Improvements";
		idxTemp2["rets7_3196"]="Green Water Features";
		idxTemp2["rets7_3197"]="Green Energy Features";
		idxTemp2["rets7_3121"]="## Of Bays(grade Level)";
		idxTemp2["rets7_3120"]="## Of Bays(dock High)";
		idxTemp2["rets7_3115"]="Flex Space(sq Ft)";
		idxTemp2["rets7_3192"]="Green Landscaping";
		idxTemp2["rets7_3116"]="Office/retail Space(sq Ft)";
		idxTemp2["rets7_1718"]="Location:";
		idxTemp2["rets7_1720"]="Utilities Data:";
		idxTemp2["rets7_1722"]="Water Extras:";
		idxTemp2["rets7_1733"]="Exterior Construction:";
		idxTemp2["rets7_1734"]="Exterior Features:";
		idxTemp2["rets7_1764"]="Property Style:";
		idxTemp2["rets7_1735"]="Roof:";
		idxTemp2["rets7_1737"]="Pool Type:";
		idxTemp2["rets7_1739"]="Foundation:";
		idxTemp2["rets7_1852"]="Lot ##:";
		idxTemp2["rets7_2134"]="Fences:";
		idxTemp2["rets7_2135"]="Utilities Data:";
		idxTemp2["rets7_2137"]="Water Extras:";
		idxTemp2["rets7_2158"]="Community Features:";
		idxTemp2["rets7_2322"]="Lot Dimensions:";
		idxTemp2["rets7_2328"]="Total Acreage:";
		idxTemp2["rets7_2352"]="Private Pool Y/N:";
		idxTemp2["rets7_2362"]="Lot Size:";
		idxTemp2["rets7_2622"]="Lot Size [SqFt]:";
		idxTemp2["rets7_2624"]="Lot Size [Acres]:";
		idxTemp2["rets7_2632"]="## of Add Parcels:";
		idxTemp2["rets7_2678"]="Site Improvements:";
		idxTemp2["rets7_2698"]="Property Description:";
		idxTemp2["rets7_2805"]="Garage/Carport:";
		idxTemp2["rets7_2797"]="Condo Floor ##:";
		idxTemp2["rets7_2791"]="Building ## Floors:";
		idxTemp2["rets7_2819"]="Property Description:";
		idxTemp2["rets7_2838"]="Road Frontage:";
		idxTemp2["rets7_2828"]="Easements:";
		idxTemp2["rets7_2836"]="Sidewalk Y/N:";
		idxTemp2["rets7_2981"]="Pool Type:";
		idxTemp2["rets7_490"]="Roof:";
		idxTemp2["rets7_3011"]="Water View:";
		idxTemp2["rets7_3022"]="Waterfront Feet:";
		idxTemp2["rets7_3015"]="Home Features:";
		idxTemp2["rets7_488"]="Exterior Construction:";
		idxTemp2["rets7_491"]="Parking:";
		idxTemp2["rets7_55"]="Year Built:";
		idxTemp2["rets7_519"]="Property Style:";
		idxTemp2["rets7_3067"]="Water Frontage:";
		idxTemp2["rets7_3063"]="Water Access Y/N:";
		idxTemp2["rets7_3064"]="Water View Y/N:";
		idxTemp2["rets7_3065"]="Water Frontage Y/N:";
		idxTemp2["rets7_499"]="Electrical Service:";
		idxTemp2["rets7_3027"]="Total Building SF:";
		idxTemp2["rets7_886"]="Architectural Style:";
		idxTemp2["rets7_907"]="Pool Type:";
		idxTemp2["rets7_905"]="Roof:";
		idxTemp2["rets7_890"]="Utilities Data:";
		idxTemp2["rets7_892"]="Water Extras:";
		idxTemp2["rets7_903"]="Exterior Construction:";
		idxTemp2["rets7_904"]="Exterior Features:";
		idxTemp2["rets7_3222"]="Property Description:";
		idxTemp2["rets7_3217"]="Exterior Features:";
		idxTemp2["rets7_1139"]="Garage/Carport:";
		idxTemp2["rets7_1349"]="Property Style:";
		idxTemp2["rets7_1437"]="Lot ##:";
		idxTemp2["rets7_3186"]="Pool";
		idxTemp2["rets7_3233"]="Pool Dimensions";
		idxTemp2["rets7_3264"]="Frontage Description";
		idxTemp2["rets7_2834"]="Porches";
		idxTemp2["rets7_1826"]="Front Exposure";
				
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Exterior Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		
		
		</cfscript>
    </cffunction>
    <cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["rets7_3212"]="Last Months Rent";
		idxTemp2["rets7_3228"]="Weeks Available 2013";
		idxTemp2["rets7_3193"]="Disaster Mitigation";
		idxTemp2["rets7_3166"]="Weeks Available 2011";
		idxTemp2["rets7_3176"]="Weeks Available 2012";
		idxTemp2["rets7_3165"]="Dpr Y/n";
		idxTemp2["rets7_1005"]="High School:";
		idxTemp2["rets7_1010"]="Middle or Junior School:";
		idxTemp2["rets7_1055"]="Max Pet Weight:";
		idxTemp2["rets7_1303"]="Location:";
		idxTemp2["rets7_1307"]="Water Extras:";
		idxTemp2["rets7_1328"]="Community Features:";
		//idxTemp2["rets7_1334"]="Additional Public Remarks:";
		idxTemp2["rets7_1350"]="Building Name/Number:";
		idxTemp2["rets7_1374"]="## Times per Year:";
		idxTemp2["rets7_1397"]="Elementary School:";
		idxTemp2["rets7_1420"]="High School:";
		idxTemp2["rets7_1425"]="Middle or Junior School:";
		idxTemp2["rets7_143"]="Str. Dir. Pre:";
		idxTemp2["rets7_1455"]="Model/Make:";
		idxTemp2["rets7_151"]="Front Footage:";
		idxTemp2["rets7_1660"]="Special Listing Type:";
		idxTemp2["rets7_1670"]="Subdivision ##:";
		idxTemp2["rets7_1743"]="Community Features:";
		//idxTemp2["rets7_1749"]="Additional Public Remarks:";
		idxTemp2["rets7_178"]="Status:";
		idxTemp2["rets7_1812"]="Elementary School:";
		idxTemp2["rets7_1815"]="Easements:";
		idxTemp2["rets7_182"]="Lot ##:";
		idxTemp2["rets7_1825"]="Front Footage:";
		idxTemp2["rets7_1835"]="High School:";
		idxTemp2["rets7_1840"]="Middle or Junior School:";
		idxTemp2["rets7_19"]="County:";
		idxTemp2["rets7_2075"]="Special Listing Type:";
		idxTemp2["rets7_2085"]="Subdivision ##:";
		idxTemp2["rets7_2133"]="Location:";
		idxTemp2["rets7_2292"]="Str. Dir. Post:";
		idxTemp2["rets7_2300"]="Driving Directions:";
		idxTemp2["rets7_2302"]="City:";
		idxTemp2["rets7_2314"]="Legal Subdivision Name:";
		idxTemp2["rets7_2316"]="Complex/Community Name/NCCB:";
		idxTemp2["rets7_2320"]="Zoning:";
		idxTemp2["rets7_2326"]="Square Foot Source:";
		idxTemp2["rets7_2334"]="Listing Type:";
		idxTemp2["rets7_2350"]="Water Name:";
		idxTemp2["rets7_2364"]="Rent Price Per Month:";
		idxTemp2["rets7_2652"]="Converted Residence Y/N:";
		idxTemp2["rets7_2763"]="LP/SqFt:";
		idxTemp2["rets7_2765"]="SP/SqFt:";
		idxTemp2["rets7_2769"]="ADOM:";
		idxTemp2["rets7_2779"]="Area (Range):";
		idxTemp2["rets7_2789"]="Balcony/Porch/Lanai (Approx):";
		idxTemp2["rets7_2795"]="CDD Y/N:";
		idxTemp2["rets7_2801"]="Fireplace Y/N:";
		idxTemp2["rets7_2813"]="Max Pet Weight:";
		idxTemp2["rets7_2826"]="Availability:";
		idxTemp2["rets7_2842"]="Floor ## of Unit:";
		idxTemp2["rets7_2850"]="Services Include:";
		idxTemp2["rets7_2854"]="Unit ##:";
		idxTemp2["rets7_2856"]="Total Units:";
		idxTemp2["rets7_2879"]="MH Width:";
		idxTemp2["rets7_2951"]="Property Status:";
		idxTemp2["rets7_2952"]="Class of Space:";
		idxTemp2["rets7_2953"]="Space Type:";
		idxTemp2["rets7_2955"]="Rent Concession:";
		idxTemp2["rets7_2956"]="Existing Lease Buyout Allow:";
		idxTemp2["rets7_2983"]="SW Subdv Community Name:";
		idxTemp2["rets7_2984"]="SW Subdv Condo ##:";
		idxTemp2["rets7_2999"]="Lease Price per SF:";
		idxTemp2["rets7_3008"]="Rented Furnish Info:";
		idxTemp2["rets7_3013"]="## of Pets:";
		idxTemp2["rets7_3014"]="Pet Size:";
		idxTemp2["rets7_3026"]="Subdivision Section Number:";
		idxTemp2["rets7_3036"]="Housing for Older Persons:";
		idxTemp2["rets7_3066"]="Water Extras Y/N:";
		
		idxTemp2["rets7_3068"]="Water Access:";
		idxTemp2["rets7_3078"]="Country:";
		idxTemp2["rets7_3079"]="Max Pet Weight:";
		idxTemp2["rets7_3080"]="## of Pets:";
		idxTemp2["rets7_3081"]="## of Pets:";
		idxTemp2["rets7_3084"]="New Construction:";
		idxTemp2["rets7_3085"]="Construction Status:";
		idxTemp2["rets7_3086"]="Projected Completion Date:";
		idxTemp2["rets7_3109"]="Complex/Development Name:";
		idxTemp2["rets7_33"]="CDOM:";
		idxTemp2["rets7_384"]="Road Frontage:";
		idxTemp2["rets7_425"]="Subdivision ##:";
		idxTemp2["rets7_432"]="Floors ##:";
		idxTemp2["rets7_443"]="Total Num Bldg:";
		idxTemp2["rets7_46"]="Zip Code:";
		idxTemp2["rets7_465"]="Contract Status:";
		idxTemp2["rets7_473"]="Location:";
		idxTemp2["rets7_475"]="Utilities Data:";
		idxTemp2["rets7_520"]="Building Name/Number:";
		idxTemp2["rets7_564"]="Efficiency Avg Rent:";
		idxTemp2["rets7_566"]="Efficiencies-Number Of:";
		idxTemp2["rets7_567"]="Elementary School:";
		
		idxTemp2["rets7_590"]="High School:";
		idxTemp2["rets7_595"]="Middle or Junior School:";
		idxTemp2["rets7_602"]="Legal Description:";
		idxTemp2["rets7_607"]="Lot ##:";
		//idxTemp2["rets7_62"]="Additional Public Remarks:";
		idxTemp2["rets7_641"]="1 Bed/1 Bath Avg Rent:";
		idxTemp2["rets7_646"]="1 Bed/1 Bath ##:";
		idxTemp2["rets7_649"]="2 Bed/1 Bath Avg Rent:";
		idxTemp2["rets7_654"]="2 Bed/1 Bath ##:";
		idxTemp2["rets7_657"]="2 Bed/2 Bath Avg Rent:";
		idxTemp2["rets7_662"]="2 Bed/2 Bath ##:";
		idxTemp2["rets7_668"]="3 Bed/1 Bath Avg Rent:";
		idxTemp2["rets7_673"]="3 Bed/1 Bath ##:";
		idxTemp2["rets7_676"]="3 Bed/2 Bath Avg Rent:";
		idxTemp2["rets7_681"]="3 Bed/2 Bath ##:";
		idxTemp2["rets7_709"]="Total Units:";
		idxTemp2["rets7_77"]="Property Style:";
		idxTemp2["rets7_80"]="Sq.Ft. Gross:";
		idxTemp2["rets7_830"]="Special Listing Type:";
		idxTemp2["rets7_840"]="Subdivision ##:";
		idxTemp2["rets7_858"]="Total ## Buildings:";
		idxTemp2["rets7_86"]="Property Use:";
		idxTemp2["rets7_888"]="Location:";
		idxTemp2["rets7_913"]="Community Features:";
		//idxTemp2["rets7_919"]="Additional Public Remarks:";
		idxTemp2["rets7_931"]="Date Available:";
		idxTemp2["rets7_934"]="Property Style:";
		idxTemp2["rets7_982"]="Elementary School:";
		idxTemp2["rets7_3223"]="Utilities Data:";
		idxTemp2["rets7_500"]="Miscellaneous";
		idxTemp2["rets7_3234"]="Virtual Tour Url 2";
		idxTemp2["rets7_3252"]="Eaves Height";
		idxTemp2["rets7_3253"]="Condo Environment Y/n";
		idxTemp2["rets7_3254"]="Condo Fees";
		idxTemp2["rets7_3255"]="Condo Fees Term";
		idxTemp2["rets7_3259"]="Adjoining Property";
		idxTemp2["rets7_3244"]="Pet Size";
		idxTemp2["rets7_3245"]="Transportation Access";
		idxTemp2["rets7_3246"]="Use Code";
		idxTemp2["rets7_3262"]="Management";
		idxTemp2["rets7_3263"]="Financial Source";
		idxTemp2["rets7_3260"]="Miscellaneous2";
		idxTemp2["rets7_3106"]="Pet Restrictions Y/n";
		
		
		idxTemp2["rets7_3161"]="Actual";
		idxTemp2["rets7_3194"]="Green Certifications";
		idxTemp2["rets7_62"]="Additional Public Remarks";
		idxTemp2["rets7_1749"]="Additional Public Remarks";
		idxTemp2["rets7_3283"]="Special Listing Type";
		idxTemp2["rets7_3265"]="Current Adjacent Use";
		idxTemp2["rets7_919"]="Additional Public Remarks";
		idxTemp2["rets7_3285"]="Awc Remarks";
		idxTemp2["rets7_3248"]="Units";
		idxTemp2["rets7_3256"]="Accessory Buildings";
		idxTemp2["rets7_1334"]="Additional Public Remarks";
		idxTemp2["rets7_3247"]="Road Frontage Ft";
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Additional Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		
		
		idxTemp2=structnew();
		idxTemp2["rets7_3266"]="Association Fee Includes";
		idxTemp2["rets7_3282"]="Monthly Condo Fee Amount";
		idxTemp2["rets7_3281"]="Monthly Hoa Amount";
		idxTemp2["rets7_3226"]="Additional Membership Avail";
		idxTemp2["rets7_104"]="Taxes:";
		idxTemp2["rets7_11"]="Original List Price:";
		idxTemp2["rets7_1117"]="Minimum Days Leased:";
		idxTemp2["rets7_1213"]="Pet Deposit:";
		idxTemp2["rets7_1215"]="Pet Fee:";
		idxTemp2["rets7_1231"]="Security Deposit:";
		idxTemp2["rets7_1248"]="Long Term Y/N:";
		idxTemp2["rets7_1335"]="Additional Parcel Y/N:";
		idxTemp2["rets7_1368"]="Minimum Lease:";
		idxTemp2["rets7_1375"]="Taxes:";
		idxTemp2["rets7_1418"]="HOA Fee:";
		idxTemp2["rets7_1432"]="Legal Description:";
		idxTemp2["rets7_15"]="Tax ID:";
		idxTemp2["rets7_1709"]="Financing Available:";
		idxTemp2["rets7_174"]="Legal Description:";
		idxTemp2["rets7_1750"]="Additional Parcel Y/N:";
		idxTemp2["rets7_1790"]="Taxes:";
		idxTemp2["rets7_1823"]="For Lease Y/N:";
		idxTemp2["rets7_1827"]="For Sale Y/N:";
		idxTemp2["rets7_1833"]="HOA Fee:";
		idxTemp2["rets7_1847"]="Legal Description:";
		idxTemp2["rets7_1857"]="Lease Price Per Acre:";
		idxTemp2["rets7_1968"]="Price Per Acre:";
		idxTemp2["rets7_2124"]="Financing Available:";
		idxTemp2["rets7_2128"]="Lease Terms:";
		idxTemp2["rets7_2308"]="Lease Rate:";
		idxTemp2["rets7_2664"]="Leased Amount:";
		idxTemp2["rets7_2666"]="Num of Add Parcels:";
		idxTemp2["rets7_2688"]="Annual Net Income:";
		idxTemp2["rets7_2694"]="Number of Additional Parcels:";
		idxTemp2["rets7_2704"]="Association Approval Required Y/N:";
		idxTemp2["rets7_2793"]="Annual CDD Fee:";
		idxTemp2["rets7_3000"]="Lease Price Per Yr:";
		idxTemp2["rets7_3001"]="Length of Lease:";
		idxTemp2["rets7_3002"]="CAM Per Sq Ft:";
		idxTemp2["rets7_3005"]="Lease Remarks:";
		idxTemp2["rets7_3048"]="LSC Sell Side:";
		idxTemp2["rets7_3074"]="HOA/Comm Assn:";
		idxTemp2["rets7_3146"]="Planned Unit Development:";
		idxTemp2["rets7_3147"]="HERS Index:";
		idxTemp2["rets7_3148"]="Flood Zone Code:";
		idxTemp2["rets7_3149"]="Land Lease Fee:";
		idxTemp2["rets7_3152"]="Association Application Fee:";
		idxTemp2["rets7_3153"]="Mandatory Fees:";
		idxTemp2["rets7_3156"]="Disclosures:";
		idxTemp2["rets7_3159"]="Lease Information:";
		idxTemp2["rets7_3162"]="Financing Terms:";
		idxTemp2["rets7_3163"]="Net Operating Income Type:";
		idxTemp2["rets7_468"]="Lease Terms:";
		idxTemp2["rets7_505"]="Additional Parcel Y/N:";
		idxTemp2["rets7_507"]="Annual Gross Income:";
		idxTemp2["rets7_545"]="Taxes:";
		idxTemp2["rets7_588"]="HOA Fee:";
		idxTemp2["rets7_63"]="Additional Parcel Y/N:";
		idxTemp2["rets7_79"]="Net Leasable Sq.Ft.:";
		idxTemp2["rets7_816"]="Security Deposit:";
		idxTemp2["rets7_853"]="Total Monthly Rent:";
		idxTemp2["rets7_855"]="Total Monthly Expenses:";
		idxTemp2["rets7_879"]="Financing Available:";
		idxTemp2["rets7_883"]="Lease Terms:";
		idxTemp2["rets7_927"]="Application Fee Per Person:";
		idxTemp2["rets7_3075"]="Pets Allowed Y/N:";
		idxTemp2["rets7_3076"]="Pet Restrictions:";
		idxTemp2["rets7_2809"]="Homestead Y/N:";
		idxTemp2["rets7_2811"]="Maintenance Includes:";
		idxTemp2["rets7_2823"]="Special Tax Dist.Y/N (Tampa):";
		idxTemp2["rets7_283"]="Net Operating Income:";
		idxTemp2["rets7_2844"]="Lease Fee:";
		idxTemp2["rets7_2846"]="Lease Paid:";
		idxTemp2["rets7_2848"]="Lease Terms:";
		idxTemp2["rets7_2883"]="Availability:";
		idxTemp2["rets7_2899"]="Mo.Maint.$(addition to HOA):";
		idxTemp2["rets7_2901"]="HOA Payment Schedule:";
		idxTemp2["rets7_3203"]="Leased Price:";
		idxTemp2["rets7_3204"]="Leased Date:";
		idxTemp2["rets7_3211"]="Annual Rent:";
		idxTemp2["rets7_3210"]="Additional Pet Fees:";
		idxTemp2["rets7_3219"]="Association Approval Fee:";
		idxTemp2["rets7_3214"]="Off Season Rent:";
		idxTemp2["rets7_3215"]="Weekly Rent:";
		idxTemp2["rets7_3213"]="Seasonal Rent:";
		idxTemp2["rets7_3221"]="Other Fees:";
		idxTemp2["rets7_3220"]="Additional Applicant Fee:";
		idxTemp2["rets7_3190"]="Condo Maint. Fee Schedule:";
		idxTemp2["rets7_3189"]="Condo Maintenance Fee:";
		idxTemp2["rets7_3167"]="Last Date Available:";
		idxTemp2["rets7_2767"]="Sp/lp Ratio";
		idxTemp2["rets7_2626"]="Range Pricing Y/n";
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Financial &amp; Legal Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		return arraytolist(arrR,'');
		</cfscript>
	</cffunction>
</cfoutput>
</cfcomponent>