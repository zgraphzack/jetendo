<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>	<cfscript>
	this.retsVersion="1.1";
	
	this.mls_id=11;
	if(request.zos.istestserver){
		hqPhotoPath="#request.zos.sharedPath#mls-images/11/";
	}else{
		hqPhotoPath="#request.zos.sharedPath#mls-images/11/";
	}
	this.useRetsFieldName="system";
	this.arrTypeLoop=["CommercialProperty","IncomeProperty","Rental","ResidentialProperty","VacantLand"];
	this.arrColumns=listtoarray("accessorybuildings	acpercent	additionalrooms	addlfeeincludes	addlmarketingremarks	adjoiningproperty	agentstatus	animalspermitted	applicationfeeamount	area	areazonesort	arial	assessmentdesc	assocappfee	assocapprovalrequiredyn	assocfeeamount	assocfeeincludes	associationfee	associationfeeperiod	assumableloanyn	bathshalf	bathstotal	bedroom2length	bedroom2width	bedroom3length	bedroom3width	bedroom4length	bedroom4width	bedroommasterlength	bedroommasterwidth	bedrooms	bonus	bonusremarks	bookaddendum	buildingconstruction	buildingstotal	businessdesc	cable	carport	ceilingheight	ceilingheights	ceilingtype	city	clearedyn	colistagent2id	colistagentboard	colistagentfirmid	colistagentid	colistagentoffice	commercialpropertytype	community55yn	communityamenities	communityamenties	condominium	condounitnumber	construction	contact	county	currentadjacentuse	currentuse	dateavailable	datechange	datenewlisting	datephoto	daysonmarket	deedrestrictions	diningroomlength	diningroomwidth	directions	displayaddresslisting	displayflaglisting	docsonfile	door1width	doorfaces	dwellingstyle	dwellingview	eavesheight	efficiencyrent	efficiencyunits	electricservice	empowermentzone	equipmentandappliances	equitableinterestyn	expenses	expensesinclude	exteriorfeatures	exteriorfinish	exteriorsignage	familyroomlength	familyroomwidth	financing	fireplacesyn	floor	propertystatus	floornumber	floors	floridatodayyn	frontagedescription	furnishingstostay	garage	gates	grossincome	heatingandcooling	hoadues	hoayn	homeownersassocyn	homesteadyn	homewarrantyyn	hotwater	howsolddesc	idx	idxcontactname	idxcontactphone	idxcontacttype	interiorfeatures	interiorimprovements	kitchenlength	kitchenwidth	landdescription	leaseprice	leaseterms	leasetype	legaldescription	listdate	listingagentid	listingagentname	listingagentuid	listingarea	listingboard	listingfirmid	listingid	listingofficeid	listingofficeuid	listingstatus	listingtype	listprice	livingroomlength	livingroomwidth	loadingdock	locationdescription	lotfaces	lots	lotsizelength	lotsizewidth	lotsqft	management	mapcoordinate	masterbath	mlsnumberoriginal	modificationtimestamp	netincome	nonrep	occupancy	officeidx	officesqft	officestatus	onebedroomrent	onebedroomunits	originallistingfirmname	originallistprice	originalsellingfirmname	otherincome	otherroomlength	otherroomtype	otherroomwidth	overheaddoorheight	ownerbankcorporationyn	ownername	owneroccupiedyn	ownerwillconsider	parking	patiosize	petfeeamount	pets	photoadded	photocode	photocount	platbook	platbookpage	pooldescription	poolpresent	poolsize	porchsize	possession	possessiondesc	postalcode	previouslistprice	pricechangeyn	propertyformat	propertystyle	propertytype	propertyuse	publicremarks	pudyn	rentalpropertytype	rentincludes	residentialpropertytype	restrictions	roadfrontagedepth	roadsurface	roof	salelease	saleoption	secondownername	securityandsafety	securitydepositamount	securitysystem	servicesnotprovided	showing	showinginstructions	sitedescription	siteimprovements	sitelocation	slabthickness	smokingyn	source	sourceofmeasurement	splityn	sqftlivingarea	sqfttotal	stateorprovince	statusactualnumber	streetdirsuffix	streetname	streetnumber	streetsuffix	style	subagentcomm	subdivision	taxamount	taxid	taxid1	taxrange	taxsectioncode	taxyear	temporarilyoffmarketyn	threebathrent	threebathunits	threebedroomrent	threebedroomunits	totalparking	totalunits	trafficcount	transbrokercommamount	transportationaccess	twobathrent	twobathunits	twobedroomrent	twobedroomunits	unitlot	unitnumber	utilities	utilitiesandfuel	variableratecommyn	virtualtour2url	virtualtoururl	virtualtouryn	waterdescription	waterfrontage	waterfrontagedesc	waterfrontpresent	yearbuilt	zoning",chr(9));//taxpersqft	
	this.arrFieldLookupFields=listtoarray("Parking,AgentStatus,HomeOwnersAssocYN,SiteDescription,AssociationFee,PropertyUse,AssumableLoanYN,WaterFrontPresent,CommunityAmenties,ShortSaleYN,Financing,LeaseTerms,StreetDirSuffix,InteriorFeatures,ListingStatus,SaleLease,DocsOnFile,HOAYN,ExteriorSignage,EquitableInterestYN,SecurityAndSafety,ListingArea,DisplayAddressListing,SaleOption,Condominium,Floor,PropertyStatusCounty,PropertyStyle,HowSoldDesc,ShowingInstructions,ExteriorFeatures,SmokingYN,AddlFeeIncludes,CeilingType,ElectricService,WaterFrontageDesc,Community55YN,LeaseType,Contact,AnimalsPermitted,RentalPropertyType,ExteriorFinish,OwnerBankCorporationYN,AdditionalRooms,DwellingStyle,Construction,FurnishingstoStay,OwnerWillConsider,OwnerOccupiedYN,RoadSurface,SourceOfMeasurement,TrafficCount,CurrentAdjacentUse,HotWater,Possession,ListingType,CorpOwned,LotFaces,FireplacesYN,SlabThickness,SiteLocation,DwellingView,Restrictions,PriceChangeYN,HeatingAndCooling,ClearedYN,StateOrProvince,LocationDescription,DeedRestrictions,PUDYN,EmpowermentZone,SiteImprovements,Floors,PoolDescription,Pets,Utilities,RentIncludes,PossessionDesc,CommunityAmenities,AssociationFeePeriod,CeilingHeights,LandDescription,HomeWarrantyYN,PropertyType,Roof,AssocApprovalRequiredYN,VirtualTourYN,SecuritySystem,TemporarilyOffMarketYN,PoolPresent,EquipmentAndAppliances,Management,OfficeIDX,Subdivision,AssocFeeIncludes,SplitYN,MasterBath,TransportationAccess,InteriorImprovements,BuildingConstruction,DisplayFlagListing,UtilitiesAndFuel,AccessoryBuildings,WaterDescription,AssessmentDesc,Style,CommercialPropertyType,Showing,ServicesNotProvided,Occupancy,ExpensesInclude,LoadingDock,DoorFaces,IDX,ResidentialPropertyType,Gates,AdjoiningProperty,OfficeStatus,FrontageDescription,Source,CurrentUse,VariableRateCommYN,HomesteadYN,FloridaTodayYN",",");
	this.mls_provider="rets11";
	resourceStruct=structnew();
	resourceStruct["property"]=structnew();
	resourceStruct["property"].resource="property";
	resourceStruct["property"].id="ListingID";
	this.emptyStruct=structnew();
	resourceStruct["office"]=structnew();
	resourceStruct["office"].resource="office";
	resourceStruct["office"].id="firmid";
	resourceStruct["agent"]=structnew();
	resourceStruct["agent"].resource="agent";
	resourceStruct["agent"].id="AgentID";
	
		variables.tableLookup=structnew();
		variables.tableLookup["R"]="ResidentialProperty";
		variables.tableLookup["T"]="ResidentialProperty";
		variables.tableLookup["O"]="ResidentialProperty";
		variables.tableLookup["C"]="CommercialProperty";
		variables.tableLookup["M"]="IncomeProperty";
		variables.tableLookup["V"]="VacantLand";
		variables.tableLookup["E"]="Rental";
	
	
t5=structnew();

t5["county"]=structnew();

t5["countyreverse"]=structnew();
for(n in t5["county"]){
	t5["countyreverse"][t5["county"][n]]=n;
}



t5["style"]=structnew();


t5["frontage"]=structnew();



t5["subtypeid"]=structnew();


t5["typeid"]=structnew();

t5["view"]=structnew();


t5["county"].lookupfield="county";
t5["frontage"].lookupfield="frontage";
t5["subtypeid"].lookupfield="sub_type_id";
t5["typeid"].lookupfield="type_id";
t5["style"].lookupfield="style";
t5["view"].lookupfield="view";
this.remapFieldStruct=t5;

	</cfscript>
    
    <cffunction name="deleteListings" localmode="modern" output="no" returntype="any">
    	<cfargument name="idlist" type="string" required="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		var arrId=listtoarray(mid(replace(arguments.idlist," ","","ALL"),2,len(arguments.idlist)-2),"','");
		super.deleteListings(arguments.idlist);
		
		db.sql="DELETE FROM #db.table("rets11_property", request.zos.zcoreDatasource)#  
		WHERE rets11_listingid LIKE #db.param('#this.mls_id#-%')# and 
		rets11_listingid IN (#db.trustedSQL(arguments.idlist)#)";
		db.execute("q"); 
		</cfscript>
    </cffunction>
    
    <cffunction name="initImport" localmode="modern" output="no" returntype="any">
    	<cfargument name="resource" type="string" required="yes">
        <cfargument name="sharedStruct" type="struct" required="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		var local=structnew();
		var qZ=0;
		super.initImport(arguments.resource, arguments.sharedStruct);
		
		arguments.sharedStruct.lookupStruct.cityRenameStruct=structnew();
		</cfscript>
        <cfsavecontent variable="db.sql">
        select city_name, state_abbr, zipcode_zip 
		from #db.table("zipcode", request.zos.zcoreDatasource)# zipcode 
		where zipcode_zip IN 
		#db.trustedSQL("(32949,32937,32950,34947,32935,32940,32931,32904,32909,32951,32953,34744,32952,28467,32927,37752,34771,
		32903,34773,32905,32780,99999,92011,32948,21452,32958,32754,32976,32759,32934,34949,34983)")#
        </cfsavecontent><cfscript>qZ=db.execute("qZ");</cfscript>
        <cfloop query="qZ">
            <cfscript>arguments.sharedStruct.lookupStruct.cityRenameStruct[qZ.zipcode_zip]=qZ.city_name&"|"&qZ.state_abbr;</cfscript>
        </cfloop>
        
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
		var cityname=0;
		var cid=0;
		var a9=arraynew(1);
		var ts=0;
		var col=0;
		var tmp=0;
		var uns=0;
		var arrt3=0;
		var address=0;
		var arrt2=0;
		var datacom=0;
		var ad=0;
		var curlat=0;
		var curlong=0;
		var ts2=0;
		var s=0;
		var arrT=0;
		var rs=0;
		
		if(structcount(this.emptyStruct) EQ 0){
			for(i=1;i LTE arraylen(this.arrColumns);i++){
				this.emptyStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[this.arrColumns[i]].longname]="";
			}
		}
		
		for(i=1;i LTE arraylen(arguments.ss.arrData);i++){
			if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.idxSkipDataIndexStruct, i) EQ false){
				arrayappend(a9, arguments.ss.arrData[i]);	
			}
		}
		arguments.ss.arrData=a9;
		ts=duplicate(this.emptyStruct);
		if(arraylen(arguments.ss.arrData) NEQ arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.functions.zdump(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);
			application.zcore.functions.zdump(arguments.ss.arrData);
			application.zcore.functions.zabort();
		}  
		if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.template.fail("RETS#this.mls_id#: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
		}
		for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
			col=(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)].longname);
			ts["rets11_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
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
			//ts[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=ts[col];
			columnIndex[col]=i;
		}
		ts["list price"]=replace(ts["list price"],",","","ALL");
		// need to clean this data - remove not in subdivision, 0 , etc.
		
		// 2983=SW Subdv Community Name
		local.listing_subdivision="";
		if(local.listing_subdivision EQ ""){
			// 2316=Legal Subdivision Name
			if(findnocase(","&ts["Address Subdivision Name"]&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["Address Subdivision Name"]="";
			}else if(ts["Address Subdivision Name"] NEQ ""){
				ts["Address Subdivision Name"]=application.zcore.functions.zFirstLetterCaps(ts["Address Subdivision Name"]);
			}
			local.listing_subdivision=ts["Address Subdivision Name"];
		}
		
		
		
		this.price=ts["list price"];
		local.listing_price=ts["list price"];
		cityName="";
		cid=0;
		if(structkeyexists(request.zos.listing.cityStruct, ts["address city"]&"|"&ts["Address State"])){
			cid=request.zos.listing.cityStruct[ts["address city"]&"|"&ts["Address State"]];
		}
		if(cid EQ 0 and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct, ts['address zip code'])){
			cityName=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct[ts['address zip code']];
			ts["address city"]=listgetat(cityName,1,"|");
			if(structkeyexists(request.zos.listing.cityStruct, cityName&"|"&ts["Address State"])){
				cid=request.zos.listing.cityStruct[cityName&"|"&ts["Address State"]];
			}
		}
		local.listing_county=this.listingLookupNewId("county",ts['address county']);
		

		local.listing_sub_type_id="";
		
		local.listing_type_id=this.listingLookupNewId("listing_type",ts['property type']);

		
		if(ts["DisplayAddressListing"] EQ "N"){
			ts["street address"]="";
			ts["address street number"]="";
			ts["address street suffix"]="";
			ts["address street name"]="";
			ts["address street dir suffix"]="";
			ts["address unit number"]="";
		}
		
		ad=ts['address street number'];
		if(ad NEQ 0){
			address="#ad# ";
		}else{
			address="";	
		}
		address&=application.zcore.functions.zfirstlettercaps(ts['address street name']);
		curLat='';
		curLong='';
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,ts['Address State'],ts['address zip code']);
			curLat=rs5.latitude;
			curLong=rs5.longitude;
		}
		
		if(ts['address unit number'] NEQ ''){
			address&=" Unit: "&ts["address unit number"];	
		}
		
		ts2=structnew();
		ts2.field="";
		ts2.yearbuiltfield=ts['year built'];
		ts2.foreclosureField="";
		
		s=this.processRawStatus(ts2);
		
		if(ts['propertystatus'] CONTAINS 'FBO'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}
		if(ts['propertystatus'] CONTAINS 'SS'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}
		
		if(ts['property type'] EQ "E"){
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
		}else{
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
		}
		arrT3=[];
		local.listing_status=structkeylist(s,",");
		
		uns=structnew();
		tmp=ts['style'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("style",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT3,tmp);
				}
			}
		}
		tmp=ts['propertystyle'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("style",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT3,tmp);
				}
			}
		}
		tmp=ts['dwellingstyle'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("style",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT3,tmp);
				}
			}
		}
		local.listing_style=arraytolist(arrT3);
		
		// view & frontage
		arrT3=[];
		
		uns=structnew();
		tmp=ts['Water Frontage Description'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("frontage",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT3,tmp);
				}
			}
		}
		local.listing_frontage=arraytolist(arrT3);
		
		
		arrT2=[]; 
		uns=structnew();
		tmp=ts['DwellingView'];
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
		local.listing_view=arraytolist(arrT2);
		

		local.listing_pool=0;
		if(ts["Pool Y/N"] EQ "Y"){
			local.listing_pool=1;	
		}
				
		if(structkeyexists(variables.tableLookup,ts.rets11_propertytype)){
			ts=this.convertRawDataToLookupValues(ts, variables.tableLookup[ts.rets11_propertytype], ts.rets11_propertytype);
		}
		
		if(structkeyexists(ts, 'rets11_bedroommasterlength') and ts.rets11_bedroommasterlength NEQ "" and ts.rets11_bedroommasterlength NEQ "0"){
			ts.rets11_bedroommasterlength=ts.rets11_bedroommasterwidth&"x"&ts.rets11_bedroommasterlength;
		}
		if(structkeyexists(ts, 'rets11_bedroom2length') and ts.rets11_bedroom2length NEQ "" and ts.rets11_bedroom2length NEQ "0"){
			ts.rets11_bedroom2length=ts.rets11_bedroom2width&"x"&ts.rets11_bedroom2length;
		}
		if(structkeyexists(ts, 'rets11_bedroom3length') and ts.rets11_bedroom3length NEQ "" and ts.rets11_bedroom3length NEQ "0"){
			ts.rets11_bedroom3length=ts.rets11_bedroom3width&"x"&ts.rets11_bedroom3length;
		}
		if(structkeyexists(ts, 'rets11_bedroom4length') and ts.rets11_bedroom4length NEQ "" and ts.rets11_bedroom4length NEQ "0"){
			ts.rets11_bedroom4length=ts.rets11_bedroom4width&"x"&ts.rets11_bedroom4length;
		}
		if(structkeyexists(ts, 'rets11_diningroomlength') and ts.rets11_diningroomlength NEQ "" and ts.rets11_diningroomlength NEQ "0"){
			ts.rets11_diningroomlength=ts.rets11_diningroomwidth&"x"&ts.rets11_diningroomlength;
		}
		if(structkeyexists(ts, 'rets11_familyroomlength') and ts.rets11_familyroomlength NEQ "" and ts.rets11_familyroomlength NEQ "0"){
			ts.rets11_familyroomlength=ts.rets11_familyroomwidth&"x"&ts.rets11_familyroomlength;
		}
		if(structkeyexists(ts, 'rets11_livingroomlength') and ts.rets11_livingroomlength NEQ "" and ts.rets11_livingroomlength NEQ "0"){
			ts.rets11_livingroomlength=ts.rets11_livingroomwidth&"x"&ts.rets11_livingroomlength;
		}
		if(structkeyexists(ts, 'rets11_kitchenlength') and ts.rets11_kitchenlength NEQ "" and ts.rets11_kitchenlength NEQ "0"){
			ts.rets11_kitchenlength=ts.rets11_kitchenwidth&"x"&ts.rets11_kitchenlength;
		}
		if(structkeyexists(ts, 'rets11_otherroomlength') and ts.rets11_otherroomlength NEQ "" and ts.rets11_otherroomlength NEQ "0"){
			ts.rets11_otherroomlength=ts.rets11_otherroomwidth&"x"&ts.rets11_otherroomlength;
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
		rs.listing_acreage=ts["acres - total"];
		rs.listing_baths=ts["Baths"];
		rs.listing_halfbaths=ts["Half-Baths"];
		rs.listing_beds=ts["Bedrooms"];
		rs.listing_city=cid;
		rs.listing_county=local.listing_county;
		rs.listing_frontage=","&local.listing_frontage&",";
		rs.listing_frontage_name="";
		rs.listing_price=ts["list price"];
		rs.listing_status=","&local.listing_status&",";
		rs.listing_state=ts["Address State"];
		rs.listing_type_id=local.listing_type_id;
		rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
		rs.listing_style=","&local.listing_style&",";
		rs.listing_view=","&local.listing_view&",";
		rs.listing_lot_square_feet=ts["Lot SqFt"];
		rs.listing_square_feet=ts["SqFt Living Area"];
		rs.listing_subdivision=local.listing_subdivision;
		rs.listing_year_built=ts["year built"];
		rs.listing_office=ts["listing firm id"];
		rs.listing_agent=ts["Listing Agent ID"];
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=local.listing_pool;
		rs.listing_photocount=ts["Photo Count"];
		rs.listing_coded_features="";
		rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
		rs.listing_primary="0";
		rs.listing_mls_id=arguments.ss.listing_mls_id;
		rs.listing_address=trim(address);
		rs.listing_zip=ts["address zip code"];
		rs.listing_condition="";
		rs.listing_parking="";
		rs.listing_region="";
		rs.listing_tenure="";
		rs.listing_liststatus="1";
		rs.listing_data_remarks=ts["public remarks"];
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(ts["address zip code"]);
		rs.listing_data_detailcache1=local.listing_data_detailcache1;
		rs.listing_data_detailcache2=local.listing_data_detailcache2;
		rs.listing_data_detailcache3=local.listing_data_detailcache3;
		return rs;
		</cfscript>
    </cffunction>
    
    <cffunction name="getJoinSQL" localmode="modern" output="yes" returntype="any">
    	<cfscript>
		var db=request.zos.queryObject;
		</cfscript>
    	<cfreturn "INNER JOIN #db.table("rets11_property", request.zos.zcoreDatasource)# rets11_property ON rets11_property.rets11_listingid = listing.listing_id">
    </cffunction>
    <cffunction name="getDetails" localmode="modern" output="yes" returntype="any">
    	<cfargument name="query" type="query" required="yes">
        <cfargument name="row" type="numeric" required="no" default="#1#">
        <cfargument name="fulldetails" type="boolean" required="no" default="#false#">
    	<cfscript>
		var db=request.zos.queryObject;
		var q1=0;
		var t44444=0;
		var t99=0;
		var qOffice=0;
		var details=0;
		var i=0;
		var t1=0;
		var t3=0;
		var t2=0;
		var i10=0;
		var value=0;
		var n=0;
		var column=0;
		var arrV=0;
		var arrV2=0;
		var idx=this.baseGetDetails(arguments.query, arguments.row, arguments.fulldetails);
		t99=gettickcount();
		idx["features"]="";
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		t44444=0;
		request.lastPhotoId=idx.listing_id;
		if(idx.listing_photocount EQ 0){
			// check for permanent images or show not available image.
			if(fileexists(request.zos.globals.serverhomedir&"a/listings/images/images_permanent/#idx.urlMlsPid#.jpg")){
				idx["photo1"]='/z/a/listing/images/images_permanent/#idx.urlMlsPid#.jpg';
			}else{
				idx["photo1"]='/z/a/listing/images/image-not-available.gif';
			}
		}else{
			i=1;
			for(i=1;i LTE idx.listing_photocount;i++){
				local.fNameTemp1=idx.urlMlsPid&"-"&i&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				idx["photo"&i]=request.zos.currentHostName&'/zretsphotos/11/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
			}
		}
		db.sql="select * from #db.table("rets11_office", request.zos.zcoreDatasource)# rets11_office 
		where rets11_firmid=#db.param(arguments.query.rets11_listingfirmid)#";
		qOffice=db.execute("qOffice"); 
			idx["agentName"]=arguments.query["rets11_ListingAgentName"];
			idx["agentPhone"]="";
			idx["agentEmail"]="";
			idx["officeName"]="";
			if(qOffice.recordcount NEQ 0){
				idx["officeName"]=qOffice.rets11_name;
			}
			idx["officePhone"]="";
			idx["officeCity"]="";
			idx["officeAddress"]="";
			idx["officeZip"]="";
			idx["officeState"]="";
			idx["officeEmail"]="";
			
		idx["virtualtoururl"]=arguments.query["rets11_VirtualTourURL"];
		idx["zipcode"]=arguments.query["rets#this.mls_id#_PostalCode"][arguments.row];
		idx["maintfees"]="";
		if(arguments.query["rets#this.mls_id#_AssociationFee"][arguments.row] NEQ ""){
			idx["maintfees"]=arguments.query["rets#this.mls_id#_AssociationFee"][arguments.row];
		}
		
		</cfscript>
        <cfsavecontent variable="details"><table class="ztablepropertyinfo">
        #idx.listing_data_detailcache1#
        #idx.listing_data_detailcache2#
        #idx.listing_data_detailcache3#
		</table></cfsavecontent>
        <cfscript>
		idx.details=details;
		return idx;
		</cfscript>
    </cffunction>
    
    <cffunction name="getPhoto" localmode="modern" output="no" returntype="any">
    	<cfargument name="mls_pid" type="string" required="yes">
        <cfargument name="num" type="numeric" required="no" default="#1#">
    	<cfscript>
		
		request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
		local.fNameTemp1=arguments.mls_pid&"-"&arguments.num&".jpeg";
		local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
		return request.zos.currentHostName&'/zretsphotos/11/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		
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
		var g=0;
		for(g=1;g LTE arraylen(this.arrTypeLoop);g++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g], "county");
			for(i in fd){
				i2=i;
				arrayappend(arrSQL,"('#this.mls_provider#','county','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
			}
			
			
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"style");
			for(i in fd){
				i2=i;
				if(i2 NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"propertystyle");
			for(i in fd){
				i2=i;
				if(i2 NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"dwellingstyle");
			for(i in fd){
				i2=i;
				if(i2 NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#')");
				}
			}
			
			// frontage
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"WaterFrontageDesc");
			for(i in fd){
				tmp=i;
				arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#')");
			}
			
			
			// view
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"DwellingView");
			for(i in fd){
				tmp=i;
				arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#')");
			}
		}
		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>