<cfcomponent displayname="Property Display" output="no">
<cfoutput>
<cfscript>
this.isPropertyDisplayCom=true;
</cfscript>

<!--- 
	ts = StructNew();
	ts.property_landing_type_id = property_landing_type_id;
	ts.baseCity = city_name; 
	ts.query = qProperties;
	ts.searchScript=false;
	propertyDisplayCom.init(ts);
	 --->
<cffunction name="init" localmode="modern" output="false" returntype="any">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	this.optionStruct=StructNew();
	this.optionStruct.compact=false;
	this.optionStruct.contentDetailView=false;
	this.optionStruct.getDetails=true;
	this.optionStruct.groupBedrooms=false;
	this.optionStruct.oneLineLayout=false;
	this.optionStruct.thumbnailLayout=false;
	this.optionStruct.mapFormat=false;
	this.optionStruct.emailFormat=false;
	this.optionStruct.classifiedFlyerAds=false;
	this.optionstruct.search_result_layout=-1;
	this.optionStruct.descriptionLink=false;
	this.optionStruct.descriptionLinkRemarks=false;
	this.optionStruct.rss=false;
	this.optionStruct.output=true;
	this.optionStruct.plainText=false;
	this.optionstruct.storeCopy=false;
	this.optionStruct.featuredFormat=false;
	this.optionStruct.compactWithLinks=false;
	// cookie holds the old date - set to session
	if(isDefined('request.zsession.lastVisitDate') EQ false){
		if(isDefined('cookie.lastVisitDate') and isdate(cookie.lastVisitDate)){
			request.zsession.lastVisitDate=cookie.lastVisitDate;
		}else{
			request.zsession.lastVisitDate=request.zos.mysqlnow;
		}
		// cookie holds the current date
		cookie.lastVisitDate=DateFormat(request.zsession.lastVisitDate,'yyyy-mm-dd')&' '&TimeFormat(request.zsession.lastVisitDate,'HH:mm:ss');		
	}
	// use session old date for everything until session expires
	this.optionStruct.lastVisitDate=request.zsession.lastVisitDate;
	StructAppend(this.optionStruct, arguments.optionStruct,true);
	this.optionStruct.lastVisitDate=parsedatetime(DateFormat(this.optionStruct.lastVisitDate,'yyyy-mm-dd')&' 00:00:00');
	if(isDefined('this.optionStruct.dataStruct') EQ false){
		application.zcore.template.fail("propertyDisplay.cfc: init: optionStruct.dataStruct is required.");
	}else{
		this.dataStruct = this.optionStruct.dataStruct;
	}
	if(isDefined('arguments.optionStruct.navStruct') and isStruct(arguments.optionStruct.navStruct) EQ false){
		StructDelete(this.optionStruct, 'navStruct');
	}
	// show alternate display for search pages
	if(isDefined('this.optionStruct.searchScript') and this.optionStruct.searchScript){
		variables.searchScript=true;
	}
	</cfscript>
</cffunction>

<cffunction name="checkInit" localmode="modern" output="false" returntype="any">
	<cfscript>
		if(isDefined('this.optionStruct') EQ false){
			application.zcore.template.fail("propertyDisplay.cfc: display: you must run propertyDisplay.init() with the correct optionStruct arguments.");
		}
		</cfscript>
</cffunction>


<cffunction name="getArray" localmode="modern" output="no" returntype="any">
	<cfargument name="skipLastRecord" type="boolean" default="#false#" required="no">
	<cfscript>
	var i=0;
	var arrNewList=0;
	var arrNewList2=0;
	var i4=0;
	var rs=structnew();
	var photo1=0;
	var titleStruct=0;
	var propertyLink=0;
	var g=0;
	var curQuery=0;
	var i4=0;
	var argtype=0;
	var arglist=0;
	var t2=0;
	var t3=0;
	var arrV=0;
	var arrV2=0;
	var n=0;
	var t1=0;
	var value=0;
	var idx=0;
	var tempText=0;
	var theEnd=0;
	var tempText2=0;
	var pos=0;
	rs.count=this.datastruct.query.recordcount;
	rs.arrData=[];
	ts={};
	ts.url="";
	ts.mls_id="";
	ts.listing_id="";
	ts.city="";
	ts.city_id="";
	ts.view="";
	ts.type="";
	ts.bedrooms="";
	ts.bathrooms="";
	ts.halfbaths="";
	ts.square_footage="";
	ts.pool="";
	ts.price="";
	ts.subdivision="";
	ts.photo1="";
	ts.description="";
	ts.virtual_tour="";
	ts.condoname="";
	ts.address="";
	ts.style="";
	ts.frontage="";
	ts.tenure="";
	ts.zip="";
	ts.condition="";
	ts.parking="";
	ts.region="";
	ts.status="";
	ts.yearbuilt="";
	ts.photocount="";
	ts.pool="";
	ts.listdate="";
	ts.liststatus="";
	ts.lot_square_footage="";

	ts.latitude="";
	ts.longitude="";
	ts.price="";
	if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct, 20)){
		ts.zoning="";
		ts.taxamount="";
		ts.listdate="";
		ts.priceoriginal="";
		ts.pricesold="";
		ts.solddate="";
		ts.daysonmarket="";
		ts.schoolelem="";
		ts.schooljunior="";
		ts.schoolhigh="";
		ts.assessamountimprove="";
		ts.assessamountland="";
		ts.assessedvalue="";
		ts.occupancy="";
		ts.remodelyear="";
		ts.taxparcelid="";
		
	}
	
	if(arguments.skipLastRecord){
		skipIndex=rs.count;
	}else{
		skipIndex=-1;
	}

	for(g=1;g LTE arraylen(this.dataStruct.arrQuery);g++){
		curQuery=this.dataStruct.arrQuery[g];
		for(row in curQuery){
			idx=structnew();
			idx.arrayindex=this.dataStruct.orderStruct[curQuery.listing_id];
			if(idx.arrayIndex EQ skipIndex){
				continue;
			}
			i=curQuery.currentrow;
			idx.mls_id=listgetat(curQuery.listing_id,1,"-");
			idx.listing_id=curQuery.listing_id;
			request.lastPhotoId=curQuery.listing_id;
			if(this.optionStruct.getDetails){
				structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].getDetails(curQuery,curQuery.currentrow), true);
			}else{
				structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].baseGetDetails(curQuery,curQuery.currentrow), true);
				if(structkeyexists(request.zos.listingMlsComObjects[idx.mls_id], 'sysidfield2')){
					photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1, idx.sysidfield, idx.sysidfield2);
				}else if(structkeyexists(request.zos.listingMlsComObjects[idx.mls_id], 'sysidfield')){
					photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1, idx.sysidfield);
				}else{
					photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1);
				}
			}
			if(photo1 NEQ ""){	
				photo1=application.zcore.listingCom.getThumbnail(photo1, request.lastPhotoId, 1, form.pw, form.ph, form.pa);
			}
			titleStruct = request.zos.listing.functions.zListinggetTitle(idx);
			propertyLink = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#idx.urlMlsId#-#idx.urlMLSPId#.html';
			if(isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive){
				propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1");
			}
			t2=duplicate(ts);
			t2.tenure=idx.listingTenure;
			if(curQuery.listing_square_feet neq '' and curQuery.listing_square_feet NEQ 0){
				t2.square_footage=curQuery.listing_square_feet;
			}else if(curQuery.listing_lot_square_feet neq '' and curQuery.listing_lot_square_feet NEQ 0){
				t2.square_footage=curQuery.listing_lot_square_feet;
			}else{
				t2.square_footage="";
			}
			t2.listdate=dateformat(curQuery.listing_track_datetime,'m/d/yyyy'); 
			t2.yearbuilt=curQuery.listing_year_built;
			t2.zip=curQuery.listing_zip;
			t2.condition=idx.listingCondition;
			t2.parking=idx.listingParking;
			t2.region=idx.listingRegion;
			t2.status=idx.listingstatus;
			t2.lot_square_footage=curQuery.listing_lot_square_feet;
			
			t2.pool=curQuery.listing_pool;
			t2.photocount=curQuery.listing_photocount;
			t2.url=propertyLink;
			t2.mls_id=idx.mls_id;
			t2.listing_id=curQuery.listing_id;
			t2.city_id=curQuery.listing_city;
			t2.city=idx.cityName;
			t2.condoname=curQuery.listing_condoname;
			t2.address=curQuery.listing_address;
			
			t2.longitude=curQuery.listing_longitude;
			t2.latitude=curQuery.listing_latitude;
			t2.price=curQuery.listing_price;
			
			t2.view=idx.listingView;
			t2.style=idx.listingStyle;
			t2.frontage=idx.listingFrontage;
			t2.type=idx.listingPropertyType;
			
			if(curQuery.listing_beds neq '' and curQuery.listing_beds NEQ 0){
				t2.bedrooms=curQuery.listing_beds;
			}else{
				t2.bedrooms="";
			}
			if(curQuery.listing_baths neq '' and curQuery.listing_baths NEQ 0){
				t2.bathrooms=curQuery.listing_baths;
			}else{
				t2.bathrooms="";
			}
			if(curQuery.listing_halfbaths neq '' and curQuery.listing_halfbaths NEQ 0){
				t2.halfbaths=curQuery.listing_halfbaths;
			}else{
				t2.halfbaths="";
			}
			if(curQuery.listing_pool EQ 1){
				t2.pool="Pool";
			}else{
				t2.pool="";
			}
			if(curQuery.listing_price neq '' and curQuery.listing_price neq 0){
				if(curQuery.listing_price LT 20){
					t2.price='$#numberformat(curQuery.listing_price)# per sqft ';
				}else{
					t2.price='$#numberformat(curQuery.listing_price)#';
				}
			}else{
				t2.price='';
			}
			if(curQuery.listing_subdivision neq 'Not In Subdivision' AND curQuery.listing_subdivision neq 'Not On The List' AND curQuery.listing_subdivision neq 'n/a' and curQuery.listing_subdivision neq ''){
				t2.subdivision=curQuery.listing_subdivision;
			}else{
				t2.subdivision="";	
			}
			
			t2.photo1=photo1;
			
			if(curQuery.listing_data_remarks NEQ '' and this.optionStruct.compactWithLinks EQ false){
				tempText = rereplace(curQuery.listing_data_remarks, "<.*?>","","ALL");
				tempText2=left(tempText, 280);
				theEnd = mid(tempText, 281, len(tempText));
				pos = find(' ', theEnd);
				if(pos NEQ 0){
					tempText2=tempText2&left(theEnd, pos);
				}
				t2.description=application.zcore.functions.zFixAbusiveCaps(tempText2);
			}else{
				t2.description="";
			}
			if(isDefined('idx.virtualtoururl') and idx.virtualtoururl neq ''){
				t2.virtual_tour=idx.virtualtoururl;
			}else{
				t2.virtual_tour="";
			}
			rs.arrData[idx.arrayindex]=t2;
		}
	}
	arrNew=[];
	for(i=1;i LTE arraylen(rs.arrData);i++){
		if(isstruct(rs.arrData[i])){
			arrayAppend(arrNew, rs.arrData[i]);
		}
	}
	rs.count=arraylen(arrNew);
	rs.arrData=arrNew;
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getAjaxObject" localmode="modern" output="no" returntype="any">
	<cfargument name="skipLastRecord" type="boolean" default="#false#" required="no">
	<cfscript>
	var i=0;
	var arrNewList=0;
	var arrNewList2=0;
	var i4=0;
	var rs=structnew();
	var photo1=0;
	var titleStruct=0;
	var propertyLink=0;
	var g=0;
	var curQuery=0;
	var i4=0;
	var argtype=0;
	var arglist=0;
	var t2=0;
	var t3=0;
	var arrV=0;
	var arrV2=0;
	var n=0;
	var t1=0;
	var value=0;
	var idx=0;
	var tempText=0;
	var theEnd=0;
	var tempText2=0;
	var pos=0;
	rs.count=this.datastruct.query.recordcount;
	rs.data=structnew();
	rs.data.url=arrayNew(1);
	rs.data.mls_id=arrayNew(1);
	rs.data.listing_id=arrayNew(1);
	rs.data.city=arrayNew(1);
	rs.data.city_id=arrayNew(1);
	rs.data.view=arrayNew(1);
	rs.data.type=arrayNew(1);
	rs.data.bedrooms=arrayNew(1);
	rs.data.bathrooms=arrayNew(1);
	rs.data.halfbaths=arrayNew(1);
	rs.data.square_footage=arrayNew(1);
	rs.data.pool=arrayNew(1);
	rs.data.price=arrayNew(1);
	rs.data.subdivision=arrayNew(1);
	rs.data.photo1=arrayNew(1);
	rs.data.description=arrayNew(1);
	rs.data.virtual_tour=arrayNew(1);
	rs.data.condoname=arrayNew(1);
	rs.data.address=arrayNew(1);
	rs.data.style=arrayNew(1);
	rs.data.frontage=arrayNew(1);
	rs.data.tenure=arrayNew(1);
	rs.data.zip=arrayNew(1);
	rs.data.condition=arrayNew(1);
	rs.data.parking=arrayNew(1);
	rs.data.region=arrayNew(1);
	rs.data.status=arrayNew(1);
	rs.data.yearbuilt=arrayNew(1);
	rs.data.photocount=arrayNew(1);
	rs.data.pool=arrayNew(1);
	rs.data.listdate=arrayNew(1);
	rs.data.liststatus=arrayNew(1);
	rs.data.lot_square_footage=arrayNew(1);

	rs.data.latitude=arrayNew(1);
	rs.data.longitude=arrayNew(1);
	rs.data.price=arrayNew(1);
	
	if(arguments.skipLastRecord){
		skipIndex=rs.count;
	}else{
		skipIndex=-1;
	}

	for(g=1;g LTE arraylen(this.dataStruct.arrQuery);g++){
		curQuery=this.dataStruct.arrQuery[g];
		for(row in curQuery){ 
			idx=structnew();
			idx.arrayindex=this.dataStruct.orderStruct[curQuery.listing_id];
			if(idx.arrayIndex EQ skipIndex){
				continue;
			}
			i=curQuery.currentrow;
			idx.mls_id=listgetat(curQuery.listing_id,1,"-");
			idx.listing_id=curQuery.listing_id;
			request.lastPhotoId=curQuery.listing_id;
			if(this.optionStruct.getDetails){
				structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].getDetails(curQuery,curQuery.currentrow), true);
			}else{
				structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].baseGetDetails(curQuery,curQuery.currentrow), true);
			}
			if(structkeyexists(request.zos.listingMlsComObjects[idx.mls_id], 'sysidfield2')){
				photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1, idx.sysidfield, idx.sysidfield2);
			}else if(structkeyexists(request.zos.listingMlsComObjects[idx.mls_id], 'sysidfield')){
				photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1, idx.sysidfield);
			}else{
				photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1);
			}
			if(photo1 NEQ ""){	
				photo1=application.zcore.listingCom.getThumbnail(photo1, request.lastPhotoId, 1, form.pw, form.ph, form.pa);
			}
			titleStruct = request.zos.listing.functions.zListinggetTitle(idx);
			propertyLink = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#idx.urlMlsId#-#idx.urlMLSPId#.html';
			if(isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive){
				propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1");
			}
			rs.data.tenure[idx.arrayindex]=idx.listingTenure;
			if(curQuery.listing_square_feet neq '' and curQuery.listing_square_feet NEQ 0){
				rs.data.square_footage[idx.arrayindex]=curQuery.listing_square_feet;
			}else if(curQuery.listing_lot_square_feet neq '' and curQuery.listing_lot_square_feet NEQ 0){
				rs.data.square_footage[idx.arrayindex]=curQuery.listing_lot_square_feet;
			}else{
				rs.data.square_footage[idx.arrayindex]="";
			}
			rs.data.listdate[idx.arrayindex]=dateformat(curQuery.listing_track_datetime,'m/d/yyyy'); 
			rs.data.yearbuilt[idx.arrayindex]=curQuery.listing_year_built;
			rs.data.zip[idx.arrayindex]=curQuery.listing_zip;
			rs.data.condition[idx.arrayindex]=idx.listingCondition;
			rs.data.parking[idx.arrayindex]=idx.listingParking;
			rs.data.region[idx.arrayindex]=idx.listingRegion;
			rs.data.status[idx.arrayindex]=idx.listingstatus;
			rs.data.lot_square_footage[idx.arrayindex]=curQuery.listing_lot_square_feet;
			
			rs.data.pool[idx.arrayindex]=curQuery.listing_pool;
			rs.data.photocount[idx.arrayindex]=curQuery.listing_photocount;
			rs.data.url[idx.arrayindex]=propertyLink;
			rs.data.mls_id[idx.arrayindex]=idx.mls_id;
			rs.data.listing_id[idx.arrayindex]=curQuery.listing_id;
			rs.data.city_id[idx.arrayindex]=curQuery.listing_city;
			rs.data.city[idx.arrayindex]=idx.cityName;
			rs.data.condoname[idx.arrayindex]=curQuery.listing_condoname;
			rs.data.address[idx.arrayindex]=curQuery.listing_address;
			
			rs.data.longitude[idx.arrayindex]=curQuery.listing_longitude;
			rs.data.latitude[idx.arrayindex]=curQuery.listing_latitude;
			rs.data.price[idx.arrayindex]=curQuery.listing_price;
			
			rs.data.view[idx.arrayindex]=idx.listingView;
			rs.data.style[idx.arrayindex]=idx.listingStyle;
			rs.data.frontage[idx.arrayindex]=idx.listingFrontage;
			rs.data.type[idx.arrayindex]=idx.listingPropertyType;
			
			if(curQuery.listing_beds neq '' and curQuery.listing_beds NEQ 0){
				rs.data.bedrooms[idx.arrayindex]=curQuery.listing_beds;
			}else{
				rs.data.bedrooms[idx.arrayindex]="";
			}
			if(curQuery.listing_baths neq '' and curQuery.listing_baths NEQ 0){
				rs.data.bathrooms[idx.arrayindex]=curQuery.listing_baths;
			}else{
				rs.data.bathrooms[idx.arrayindex]="";
			}
			if(curQuery.listing_halfbaths neq '' and curQuery.listing_halfbaths NEQ 0){
				rs.data.halfbaths[idx.arrayindex]=curQuery.listing_halfbaths;
			}else{
				rs.data.halfbaths[idx.arrayindex]="";
			}
			if(curQuery.listing_pool EQ 1){
				rs.data.pool[idx.arrayindex]="Pool";
			}else{
				rs.data.pool[idx.arrayindex]="";
			}
			if(curQuery.listing_price neq '' and curQuery.listing_price neq 0){
				if(curQuery.listing_price LT 20){
					rs.data.price[idx.arrayindex]='$#numberformat(curQuery.listing_price)# per sqft ';
				}else{
					rs.data.price[idx.arrayindex]='$#numberformat(curQuery.listing_price)#';
				}
			}else{
				rs.data.price[idx.arrayindex]='';
			}
			if(curQuery.listing_subdivision neq 'Not In Subdivision' AND curQuery.listing_subdivision neq 'Not On The List' AND curQuery.listing_subdivision neq 'n/a' and curQuery.listing_subdivision neq ''){
				rs.data.subdivision[idx.arrayindex]=curQuery.listing_subdivision;
			}else{
				rs.data.subdivision[idx.arrayindex]="";	
			}
			
			rs.data.photo1[idx.arrayindex]=photo1;
			
			if(curQuery.listing_data_remarks NEQ '' and this.optionStruct.compactWithLinks EQ false){
				tempText = rereplace(curQuery.listing_data_remarks, "<.*?>","","ALL");
				tempText2=left(tempText, 280);
				theEnd = mid(tempText, 281, len(tempText));
				pos = find(' ', theEnd);
				if(pos NEQ 0){
					tempText2=tempText2&left(theEnd, pos);
				}
				rs.data.description[idx.arrayindex]=application.zcore.functions.zFixAbusiveCaps(tempText2);
			}else{
				rs.data.description[idx.arrayindex]="";
			}
			if(isDefined('idx.virtualtoururl') and idx.virtualtoururl neq ''){
				rs.data.virtual_tour[idx.arrayindex]=idx.virtualtoururl;
			}else{
				rs.data.virtual_tour[idx.arrayindex]="";
			}
		}
	}
	return rs;
	</cfscript>
</cffunction>

<!--- propertyDisplayCom.display(); --->
<cffunction name="display" localmode="modern" output="true" returntype="any">
	<cfscript>
	var g2="";
	var i2=0;
	var db=request.zos.queryObject;
	var local=structnew();
	var arrOutput=ArrayNew(1);
	var curOffset=1;
	var idx=0;
	var t493=structnew();
	var output = "";
	var i=0;
	var tempText=0;
	var ts=0;
	var curQuery=0;
	var tempText2=0;
	local.curTemplate="";
	local.curTemplateOutput=false;
	if(isDefined('request.arrEmailPhoto') EQ false){
		request.arrEmailPhoto=ArrayNew(1);
	}
	ArrayAppend(arrOutput,this.checkNav());
	//t493.contentForceOutput=true;
	application.zcore.app.getAppCFC("content").setContentIncludeConfig(t493); 
	if(this.optionstruct.search_result_layout EQ 0){
		// default detail layout
	}else if(this.optionstruct.search_result_layout EQ 1){
		this.optionStruct.oneLineLayout=true;
		variables.trackBedroomStruct=structnew();
	}else if(this.optionstruct.search_result_layout EQ 2){
		this.optionStruct.thumbnailLayout=true;
	}
	request.zos.requestLogEntry('propertyDisplay.cfc before display() loop');
	</cfscript>
	<cfloop from="1" to="#arraylen(this.dataStruct.arrQuery)#" index="g2">
		<cfset curQuery=this.dataStruct.arrQuery[g2]>
		<cfloop query="curQuery">
			<cfif structkeyexists(this.dataStruct.orderStruct, curQuery.listing_id) and this.dataStruct.orderStruct[curQuery.listing_id] LTE this.dataStruct.perpage>
			
				<cfscript>
				idx=structnew();
				idx.listing_id=curQuery.listing_id;
				idx.arrayIndex=this.dataStruct.orderStruct[curQuery.listing_id];
				i=idx.arrayIndex;
				idx.mls_id=listgetat(curQuery.listing_id,1,"-");
				if(this.optionStruct.getDetails){
					structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].getDetails(this.dataStruct.arrQuery[g2],curQuery.currentrow), true);
					request.zos.requestLogEntry('propertyDisplay.cfc after getDetails() for listing_id = #curQuery.listing_id#');
				}else{
					structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].baseGetDetails(this.dataStruct.arrQuery[g2],curQuery.currentrow), true);
					request.zos.requestLogEntry('propertyDisplay.cfc after baseGetDetails() for listing_id = #curQuery.listing_id#');
				}
				tempText2="";
				</cfscript>
				<cfif this.optionStruct.storeCopy>
					<cfscript>
					application.zcore.template.fail("storeCopy listing_saved is disabled");
					</cfscript>
				<cfelseif this.optionStruct.oneLineLayout>
					<cfif structkeyexists(form, 'debugsearchresults') and form.debugsearchresults>
						<cfset local.curTemplate="template: one-line<br />">
					</cfif>
					<cfsavecontent variable="tempText">
					<cfscript>
					this.oneLineTemplate(idx);
					</cfscript>
					</cfsavecontent>
				<cfelseif this.optionStruct.thumbnailLayout>
					<cfif structkeyexists(form, 'debugsearchresults') and form.debugsearchresults>
						<cfset local.curTemplate="template: thumbnail<br />">
					</cfif>
					<cfsavecontent variable="tempText">
					<cfscript>
					this.thumbnailTemplate(idx);
					</cfscript>
					</cfsavecontent>
				<cfelseif this.optionStruct.descriptionLink>
					<cfif structkeyexists(form, 'debugsearchresults') and form.debugsearchresults>
						<cfset local.curTemplate="template: description-link<br />">
					</cfif>
					<cfsavecontent variable="tempText">
					<cfscript>
					this.descriptionLinkTemplate(idx);
					</cfscript>
					</cfsavecontent>
				<cfelseif this.optionStruct.classifiedflyerads>
					<cfif structkeyexists(form, 'debugsearchresults') and form.debugsearchresults>
						<cfset local.curTemplate="template: classifiedflyerads<br />">
					</cfif>
					<cfsavecontent variable="tempText">
					<cfscript>
					this.classifiedFlyerAdsTemplate(idx);
					</cfscript>
					</cfsavecontent>
				<cfelseif this.optionStruct.rss>
					<cfif structkeyexists(form, 'debugsearchresults') and form.debugsearchresults>
						<cfset local.curTemplate="template: rss<br />">
					</cfif>
					<cfsavecontent variable="tempText">
					<cfscript>
					this.rssTemplate(idx);
					</cfscript>
					</cfsavecontent>
					<cfscript>
					    ts=StructNew();
					    ts.name='listing'&(StructCount(Request.rssListingStruct)+1);
					    ts.date=DateFormat(far_vrdb_list_date,'yyyymmdd')&'000001';
					    ts.text=tempText;
					    request.rssListingStruct[ts.name]=ts;
					    
					    </cfscript>
				<cfelseif this.optionStruct.emailFormat>
					<cfif structkeyexists(form, 'debugsearchresults') and form.debugsearchresults>
						<cfset local.curTemplate="template: email<br />">
					</cfif>
					<cfsavecontent variable="tempText">
					<cfscript>
					this.emailTemplate(idx);
					</cfscript>
					</cfsavecontent>
				<cfelseif this.optionStruct.plainText>
					<cfif structkeyexists(form, 'debugsearchresults') and form.debugsearchresults>
						<cfset local.curTemplate="template: emailPlain<br />">
					</cfif>
					<cfsavecontent variable="tempText">
					<cfscript>
					this.emailPlainTemplate(idx);
					</cfscript>
					</cfsavecontent> 
				<cfelseif isdefined('this.optionStruct.listNew') and this.optionStruct.listNew>
					<cfif structkeyexists(form, 'debugsearchresults') and form.debugsearchresults>
						<cfset local.curTemplate="template: list (new)<br />">
					</cfif>
					<cfsavecontent variable="tempText">
					<cfscript>
					this.listTemplate(idx);
					</cfscript>
					</cfsavecontent>
				<cfelse>
					<cfif structkeyexists(form, 'debugsearchresults') and form.debugsearchresults>
						<cfset local.curTemplate="template: list<br />">
					</cfif>
					<cfsavecontent variable="tempText">
					<cfscript>
					this.listTemplate(idx);
					</cfscript>
					</cfsavecontent>
				</cfif>
				<cfif len(local.curTemplate) and local.curTemplateOutput EQ false>
					<cfset local.curTemplateOutput=true>
					#local.curTemplate#
				</cfif>
				<cfif this.optionStruct.output>
					<cfscript>
				    arrOutput[idx.arrayIndex]=tempText2&tempText;
				    </cfscript>
				<cfelse>
					<cfscript>
					if(structkeyexists(request,'cOutStruct')){
						// add content
						request.contentCount++;
						ts=StructNew();
						ts.output=tempText;
						if(idx.listing_price EQ 0){
							ts.price=1000000000;
						}else{
							ts.price=idx.listing_price;
						}
						ts.id=listgetat(idx.listing_id,2,"-");
						ts.sort=idx.listing_id;
						request.cOutStruct[request.contentCount]=ts;
					}
				    </cfscript>
				</cfif>
			</cfif>
			<cfscript>
			request.zos.requestLogEntry('propertyDisplay.cfc end of display loop for listing_id = #curQuery.listing_id#');
			</cfscript>
		</cfloop>
	</cfloop>

	<cfscript>
	request.zos.requestLogEntry('propertyDisplay.cfc after display() loop');
	</cfscript>
	<cfif this.optionStruct.thumbnailLayout>
		<cfscript>
			arrayprepend(arrOutput,'<div style="width:100%; float:left;"><div id="zmls-thumbnailboxid">');
			arrayappend(arrOutput,'</div></div>');
			</cfscript>
	<cfelseif this.optionStruct.oneLineLayout>
		<cfscript>
				var arrNew=arraynew(1);
				//this.optionStruct.groupBedrooms=true;
				var startTable='
                        <table style="border-spacing:0px; width:100%; padding:5px;">
				<tr class="zls-onelinerow">
				<td style="vertical-align:top;">Unit##</td>
				<td style="vertical-align:top;">Address/Price</td>
				<td style="vertical-align:top;"><a style="text-decoration:none;" title="Bedrooms, Bathrooms and Half Bathrooms">BR/BA/HBA</a><br />List Status</td>
				<td style="vertical-align:top;">Living Area<br />(SQFT)</td>
				<td style="vertical-align:top;">Price Change</td>
				<td style="vertical-align:top;">Date<br />Listed</td>
				<td style="vertical-align:top;">&nbsp;</td>
				</tr>';
				var endTable='</table>';
				if(this.optionStruct.groupBedrooms){
					arrK=structkeyarray(variables.trackBedroomStruct);
					arraysort(arrK,"numeric","asc");
					
					for(i=1;i LTE arraylen(arrK);i++){
						arrayappend(arrNew, '<h2>#i# Bedroom</h2>');
						// all the listings now
						arrayappend(arrNew, startTable);
						curRow=0;
						for(i2=1;i2 LTE arraylen(variables.trackBedroomStruct[arrK[i]]);i2++){
							curRow++;
							if(curRow MOD 2 EQ 1){
								arrayappend(arrNew, '<tr class="zls-onelinerowodd">');	
							}else{
								arrayappend(arrNew, '<tr class="zls-onelineroweven">');
							}
							arrayappend(arrNew, arrOutput[variables.trackBedroomStruct[arrK[i]][i2]]);
							arrayappend(arrNew,'</tr>');
						}
						arrayappend(arrNew, endTable&'<br />');
					}
					arrOutput=arrNew;
				}else{
					for(i2=1;i2 LTE arraylen(arrOutput);i2++){
						if(isDefined('arrOutput[#i2#]')){
							if(i2 MOD 2 EQ 1){
								arrOutput[i2]='<tr class="zls-onelinerowodd">'&arrOutput[i2]&'</tr>';
							}else{
								arrOutput[i2]='<tr class="zls-onelineroweven">'&arrOutput[i2]&'</tr>';
							}
						}
					}
                	ArrayPrepend(arrOutput,startTable);
					ArrayAppend(arrOutput,endTable);
                }
                </cfscript>
	</cfif>
	<cfscript>
	ArrayAppend(arrOutput,this.checkNav(true));
	if(this.optionStruct.plainText EQ false and this.optionStruct.classifiedFlyerAds EQ false and this.optionStruct.rss EQ false){
		ArrayAppend(arrOutput,'<br style="clear:both;" />');
	}
	
	output=arraytolist(arrOutput,'');
	if(structkeyexists(this.optionStruct, 'permanentImages') and this.optionStruct.permanentImages){
		output=replace(output, '/images/','/images_permanent/','ALL');
	} 
	</cfscript>
	<cfreturn output>
</cffunction>

<!--- propertyDisplayCom.displayTop(); --->
<cffunction name="displayTop" localmode="modern" output="false" returntype="any">
	<cfscript>
	var arrOrder=arraynew(1);
	var arrOut=arraynew(1);
	var output=0;
	var outnow=0;
	var idx=structnew();
	var g2=0;
	var curQuery=0;
	arrayappend(arrOut,this.checkNav());
	</cfscript>
	<cfif this.dataStruct.query.recordcount NEQ 0>
		<cfloop from="1" to="#arraylen(this.dataStruct.arrQuery)#" index="g2">
			<cfset curQuery=this.dataStruct.arrQuery[g2]>
			<cfloop query="curQuery">
				<cfsavecontent variable="outNow">
				<cfscript>
				idx.arrayIndex=this.dataStruct.orderStruct[curQuery.listing_id];
				idx.mls_id=listgetat(curQuery.listing_id,1,"-");
				if(this.optionStruct.getDetails){
					structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].getDetails(this.dataStruct.arrQuery[g2],curQuery.currentrow), true);
				}else{
					structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].baseGetDetails(this.dataStruct.arrQuery[g2],curQuery.currentrow), true);
				}
				</cfscript>
				<cfif this.optionStruct.mapFormat>
					<cfscript>
					this.mapTemplate(idx, idx.arrayIndex);
					</cfscript>
				<cfelseif this.optionStruct.emailFormat>
					<cfscript>
					this.emailTemplate(idx, idx.arrayIndex);
					</cfscript>
				<cfelse>
					<cfscript>
					this.savedTemplate(idx, idx.arrayIndex);
					</cfscript>
				</cfif>
				</cfsavecontent>
				<cfscript>
				arrOrder[idx.arrayIndex]=outNow;
				writeoutput(curQuery.listing_id);
				</cfscript>
			</cfloop>
		</cfloop>
	</cfif>
	<cfscript>
		arrayappend(arrOut,arraytolist(arrOrder,""));
		arrayappend(arrOut,this.checkNav(true));
		output=arraytolist(ArrOut,"");
		</cfscript>
	<cfreturn output>
</cffunction>

<!--- FUNCTIONS BELOW ARE FOR INTERNAL USE ONLY --->

<cffunction name="checkNav" localmode="modern" output="false" returntype="any">
	<cfargument name="bottom" type="boolean" required="no" default="#false#">
	<cfscript>
	var searchNav="";
	var tempOutput="";
	var i=0;
	</cfscript>
	<cfif this.optionStruct.rss EQ false>
		<cfscript>
		if(structkeyexists(this.optionStruct,'navStruct')){
			if(structkeyexists(request.zos, 'propertyDisplayNavProcessed') EQ false){
				this.optionStruct.navStruct.returnDataOnly=true;
				request.zos.propertyDisplayNavProcessed=true;
				this.navOutput=application.zcore.functions.zSearchResultsNav(this.optionStruct.navStruct);
			}
		}else{
			return '';
		}
		if(this.optionStruct.plainText){
			if(arguments.bottom EQ false or ArrayLen(this.navOutput.arrData) LTE 1){
				return '';
			}else if(isDefined('this.optionStruct.saved_search_email') and isDefined('this.optionStruct.saved_search_id') and isDefined('this.optionStruct.saved_search_key')){
				return '---------------------------------------------------------'&chr(10)&'View More Results: #request.zos.currentHostName#/property/your-saved-searches.cfm?action=viewsearch&saved_search_email=#this.optionStruct.saved_search_email#&saved_search_key=#this.optionStruct.saved_search_key#&saved_search_id=#this.optionStruct.saved_search_id#&zindex=2'&chr(10);
			}else{
				return '';
			}
		}
		</cfscript>
		<cfsavecontent variable="tempOutput">
		<cfif this.optionStruct.navStruct.count GT this.optionStruct.navStruct.perPage>
			<cfif this.optionStruct.emailFormat>
				<span style="display:block; font-weight:bold; padding-bottom:5px;">
			<cfelse>
				<cfif arguments.bottom EQ false>
					<span style="font-weight:bold; padding-bottom:5px; display:block; ">Showing #this.navOutput.textPosition# listings that matched your search criteria.</span>
				</cfif>
				<cfif arguments.bottom>
					<span class="search-nav-bottom">
				<cfelse>
					<span class="search-nav">
				</cfif>
			</cfif>
			<cfscript>
			if(this.optionStruct.emailFormat){
				if(arguments.bottom){
					writeoutput('<a href="'&htmleditformat(request.zos.currentHostName&'/property/your-saved-searches.cfm?action=viewsearch&saved_search_email=#this.optionStruct.saved_search_email#&saved_search_key=#this.optionStruct.saved_search_key#&saved_search_id=#this.optionStruct.saved_search_id#&zindex=2')&'" rel="nofollow">See More Results</a>');
				}
			}else{
				for(i=1;i LTE ArrayLen(this.navOutput.arrData);i=i+1){
					if(this.navOutput.arrData[i].url EQ ''){
						writeoutput('<span class="search-nav-t">Page '&this.navOutput.arrData[i].label&'</span>');
					}else{
						writeoutput('<a rel="nofollow" href="'&htmleditformat(this.navOutput.arrData[i].url)&'">'&this.navOutput.arrData[i].label&'</a>');
					}
				}
			}
			</cfscript>
			</span>
		</cfif>
		</cfsavecontent>
	</cfif>
	<cfreturn tempOutput>
</cffunction>

<cffunction name="thumbnailTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var showbr=0;
	var p=0;
	var thePaths=0;
	var i=0;
	var priceChange=0;
	var iheight=0;
	var titleStruct=0;
	var propertyLink=0;
	var iwidth=0;
		
	request.lastphotoid=arguments.idx.listing_id;
	if(structkeyexists(arguments.idx, 'sysidfield2')){
		arguments.idx.photo1=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1, arguments.idx.sysidfield, arguments.idx.sysidfield2);
	}else if(structkeyexists(arguments.idx, 'sysidfield')){
		arguments.idx.photo1=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1, arguments.idx.sysidfield);
	}else{
		arguments.idx.photo1=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1);
	}
	var iwidth=int(request.zos.globals.maximagewidth/3)-30;
	var iheight=int(iwidth*0.68);
	titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	propertyLink = '/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html';
	if(isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive){
		propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1");
	}
	propertyLink=htmleditformat(propertyLink);
	priceChange=0; 
	savecontent variable="thePaths"{
		loop from="1" to="#arguments.idx.listing_photocount#" index="i"{
			if(structkeyexists(arguments.idx, 'photo'&i)){
				if(i NEQ 1){
					echo('@');
				}
				if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_image_enlarge',false,0) EQ 2){
					echo(application.zcore.listingCom.getThumbnail(arguments.idx['photo'&i], request.lastPhotoId, i, iwidth, iheight, 0));
				}else{
					echo(application.zcore.listingCom.getThumbnail(arguments.idx['photo'&i], request.lastPhotoId, i, 10000,10000, 0));
				}
			}
		}
	}
	</cfscript>
	<div class="zls-list-grid-listingdiv" style="width:#iwidth#px; ">
		<input type="hidden" name="m#arguments.idx.listing_id#_mlstempimagepaths" id="m#arguments.idx.listing_id#_mlstempimagepaths" value="#htmleditformat(replace(thePaths,'&amp;','&','all'))#" />
		<cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_image_enlarge',false,0) EQ 0>
			<div id="m#arguments.idx.listing_id#" class="zls-list-grid-imagediv" style="overflow:hidden; height:#iheight#px; float:left; width:100%;" onmousemove="zImageMouseMove('m#arguments.idx.listing_id#',event);" onmouseout="setTimeout('zImageMouseReset(\'m#arguments.idx.listing_id#\')',100);"><a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>
			#application.zcore.functions.zLoadAndCropImage({id:"m#arguments.idx.listing_id#_img",width:iwidth,height:iheight, url:arguments.idx.photo1, style:"", canvasStyle:"", crop:true})# 				</a></div>
			<cfelse>
			<div id="m#arguments.idx.listing_id#" class="zls-list-grid-imagediv"><a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>> #application.zcore.functions.zLoadAndCropImage({id:"m#arguments.idx.listing_id#_img",width:iwidth,height:iheight, url:arguments.idx.photo1, style:"", canvasStyle:"", crop:true})# 
				</a></div>
		</cfif>
		<div class="zls-grid-summary-text">
		<div class="zls-buttonlink" style="float:right; position:relative; margin-top:-33px;"> <a href="#request.zos.currentHostName##propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>View</a> </div>
		<cfif arguments.idx.listing_price NEQ "" and arguments.idx.listing_price NEQ "0">
			<div class="zls-grid-price">
			$#numberformat(arguments.idx.listing_price)#
			<cfif arguments.idx.listing_price LT 20>
				per sqft
			</cfif>
		</cfif>
		<cfif arguments.idx.listing_price NEQ "" and arguments.idx.listing_price NEQ "0">
			</div>
		</cfif>
		<cfif arguments.idx.listing_data_address NEQ "">
			#arguments.idx.listing_data_address#<br />
		</cfif>
		#arguments.idx.cityName# 		<br />
		<cfif arguments.idx.listing_condoname NEQ "">
			#arguments.idx.listing_condoname#<br />
		</cfif>
		<cfset showbr=false>
		<cfif arguments.idx.listing_beds NEQ 0>
			<cfset showbr=true>
			#arguments.idx.listing_beds#BR/#arguments.idx.listing_baths#BA<cfif arguments.idx.listing_halfbaths NEQ "" and arguments.idx.listing_halfbaths NEQ 0>/#arguments.idx.listing_halfbaths#HBA</cfif>
			<cfelseif arguments.idx.listing_square_feet neq '0' and arguments.idx.listing_square_feet neq ''>
			<cfset showbr=true>
			#arguments.idx.listing_square_feet# sqft
		</cfif>
		<!--- <cfif arguments.idx.listing_address CONTAINS "unit:">
			<cfscript>
			p=findnocase("unit:",arguments.idx.listing_address);
			writeoutput("unit: "&trim(removechars(arguments.idx.listing_address,1, p+5)));
			</cfscript>
		</cfif> --->
		<cfif showbr>
			<br />
		</cfif>
		<cfif arguments.idx.listingstatus EQ "for rent">
			For Rent/Lease
		<cfelseif titleStruct.propertyType NEQ 'rental'>
			For Sale
		<cfelse>
			Rental
		</cfif>
		| #arguments.idx.listingListStatus# </div>
	</div>
</cffunction>

<cffunction name="oneLineTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var titleStruct=0;
	var propertyLink=0;
	var priceChange=0;
	var p=0;
	if(structkeyexists(variables.trackBedroomStruct, arguments.idx.listing_beds) EQ false){
		variables.trackBedroomStruct[arguments.idx.listing_beds]=arraynew(1);
	}
	arrayappend(variables.trackBedroomStruct[arguments.idx.listing_beds], arguments.idx.arrayindex);
	
	titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	propertyLink = '/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html';
	if(isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive){
		propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1");
	}
	propertyLink=htmleditformat(propertyLink);
	priceChange=0;
	if(arguments.idx.listing_track_datetime NEQ ""){
		priceChange=application.zcore.functions.zso(arguments.idx, 'listing_track_price',true)-application.zcore.functions.zso(arguments.idx, 'listing_track_price_change',true);
	}
	</cfscript>
	<td style="vertical-align:top;"><cfif arguments.idx.listing_address CONTAINS "unit:">
			<cfscript>
			p=findnocase("unit:" ,arguments.idx.listing_address);
			writeoutput(trim(removechars(arguments.idx.listing_address,1, p+5)));
			</cfscript>
		</cfif></td>
	<td style="vertical-align:top;">#arguments.idx.listing_address#<br />
		<cfif arguments.idx.listing_price NEQ "" and arguments.idx.listing_price NEQ "0">
			$#numberformat(arguments.idx.listing_price)#
			<cfif arguments.idx.listing_price LT 20>
				per sqft
			</cfif>
		</cfif></td>
	<td style="vertical-align:top;">#arguments.idx.listing_beds#/#arguments.idx.listing_baths#/#arguments.idx.listing_halfbaths#<br />
#arguments.idx.listingListStatus# 		</td>
	<td style="vertical-align:top;"><cfif arguments.idx.listing_square_feet neq '0' and arguments.idx.listing_square_feet neq ''>
			#arguments.idx.listing_square_feet#<br />
		</cfif>
		<cfif arguments.idx.pricepersqft NEQ "" and arguments.idx.pricepersqft NEQ 0>
			($#numberformat(arguments.idx.pricepersqft)#/sqft)
		</cfif></td>
	<td style="vertical-align:top;"><cfscript>
    /*if(priceChange GT 0){
        writeoutput('-$#numberformat(pricechange)#'); 	
    }else if(priceChange LT 0){
        writeoutput('+$#numberformat(abs(pricechange))#');
    }else{
		writeoutput('&nbsp;');	
	}*/
		writeoutput('&nbsp;');	
    </cfscript></td>
	<td style="vertical-align:top; white-space:nowrap;">#dateformat(arguments.idx.listing_track_datetime,'m/d/yy')#<br />
		<cfif arguments.idx.listingstatus EQ "for rent">
			For Rent/Lease
		<cfelseif titleStruct.propertyType NEQ 'rental'>
			For Sale
		<cfelse>
			Rental
		</cfif></td>
	<td style="vertical-align:top;"><a target="_parent" href="#request.zos.currentHostName##propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>View</a></td>
</cffunction>

<cffunction name="listTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript> 
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx); 
	</cfscript>
	<cfif structkeyexists(arguments.idx, 'arrayindex') and arguments.idx.arrayindex MOD 2 EQ 0>
		<cfset bgClass="listing-l-box1">
		<cfelse>
		<cfset bgClass="listing-l-box2">
	</cfif>
	<cfset propertyLink = '/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html'>
	<cfif isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive>
		<cfset propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1")>
	</cfif>
	<cfscript>
	   propertyLink=htmleditformat(propertyLink);

	savecontent variable="thePaths"{
		loop from="1" to="#arguments.idx.listing_photocount#" index="i"{
			if(structkeyexists(arguments.idx, 'photo'&i)){
				if(i NEQ 1){
					echo('@');
				}
				if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_image_enlarge',false,0) EQ 2){
					echo(application.zcore.listingCom.getThumbnail(arguments.idx['photo'&i], request.lastPhotoId, i, 221, 165, 0));
				}else{
					echo(application.zcore.listingCom.getThumbnail(arguments.idx['photo'&i], request.lastPhotoId, i, 10000,10000, 0));
				}
			}
		}
	}
	</cfscript> 
	<input type="hidden" name="m#arguments.idx.listing_id#_mlstempimagepaths" id="m#arguments.idx.listing_id#_mlstempimagepaths" value="#htmleditformat(replace(thePaths,'&amp;','&','all'))#" />
	<cfscript> 
	tempText = rereplace(arguments.idx.listing_data_remarks, "<.*?>","","ALL");
	fullTextBackup=tempText;
	tempText = left(tempText, 240);
	theEnd = mid(arguments.idx.listing_data_remarks, 241, len(arguments.idx.listing_data_remarks));
	pos = find(' ', theEnd);
	if(pos NEQ 0){
	    tempText=tempText&left(theEnd, pos);
	}
	if(len(tempText) LT len(arguments.idx.listing_data_remarks)){
		tempText&="...";	
	}
	tempText=application.zcore.functions.zFixAbusiveCaps(replace(tempText,",",", ","all"));
	rowSpan1=6;
	if(arguments.idx.listing_beds eq '' or arguments.idx.listing_beds EQ 0){
		rowSpan1--;
	}
	priceChange=0;
	if(arguments.idx.listing_track_datetime NEQ ""){
		//priceChange=application.zcore.functions.zso(arguments.idx, 'listing_track_price',true)-application.zcore.functions.zso(arguments.idx, 'listing_track_price_change',true);
	}
	if(arguments.idx.listing_pool NEQ 1 and arguments.idx.listingFrontage EQ "" and arguments.idx.listing_subdivision EQ ""){
		rowSpan1--;
	}
	if((arguments.idx.listing_lot_square_feet neq '0' and arguments.idx.listing_lot_square_feet neq '') or (arguments.idx.listing_square_feet neq '0' and arguments.idx.listing_square_feet neq '') or arguments.idx.maintfees NEQ "0"){
	}else{
		rowSpan1--;
	}
	if(arguments.idx.listingview NEQ "" or arguments.idx.listing_year_built NEQ "" or arguments.idx.listingStyle NEQ ""){
	}else{
		rowSpan1--;
	}
	if(isDefined('this.isPropertyDisplayCom') EQ false or this.optionStruct.compact EQ false or this.optionStruct.compactWithLinks){
	}else{
		rowSpan1--;
	} 
	</cfscript>
	<table class="zls2-1">
		<tr>
			<td class="zls2-15" colspan="3" style="padding-right:0px;"><table class="zls2-8" style="border-spacing:0px;">
					<tr>
						<td class="zls2-9"><span class="zls2-10">
							<cfif arguments.idx.listing_price NEQ "" and arguments.idx.listing_price NEQ "0">
								$#numberformat(arguments.idx.listing_price)#
								<cfif arguments.idx.listing_price LT 20>
									per sqft
								</cfif>
							</cfif>
							<br />
							#arguments.idx.listingListStatus#</span><br />
							<cfif arguments.idx.pricepersqft NEQ "" and arguments.idx.pricepersqft NEQ 0>
								($#numberformat(arguments.idx.pricepersqft)#/sqft)
							</cfif></td>
						<cfif arguments.idx.listing_address CONTAINS "unit:">
							<td class="zls2-9-3">UNIT ##
								<cfscript>
								p=findnocase("unit:", arguments.idx.listing_address);
								writeoutput(trim(removechars(arguments.idx.listing_address,1, p+5)));
								</cfscript></td>
						</cfif>
						<td class="zls2-9-2"><strong>#arguments.idx.cityName#
							<cfif arguments.idx.listingstatus EQ "for rent">
								For Rent/Lease
							<cfelseif titleStruct.propertyType NEQ 'rental'>
								#titleStruct.propertyType# For Sale
							<cfelse>
								Rental
							</cfif>
							</strong><br />
							<cfif arguments.idx.listing_beds NEQ 0>
								#arguments.idx.listing_beds# beds,
							</cfif>
							<cfif arguments.idx.listing_baths NEQ 0>
								#arguments.idx.listing_baths# baths,
							</cfif>
							<cfif arguments.idx.listing_halfbaths NEQ 0>
								#application.zcore.functions.zso(arguments.idx, 'listing_halfbaths',true)# half baths,
							</cfif>
							<cfif arguments.idx.listing_square_feet neq '0' and arguments.idx.listing_square_feet neq ''>
								#arguments.idx.listing_square_feet# living sqft
							</cfif></td>
					</tr>
				</table>
				<br style="clear:both;" />
				<div class="zls-buttonlink">
					<cfif request.cgi_script_name NEQ '/z/listing/property/detail/index'>
						<a href="#request.zos.currentHostName##propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>View Full Details</a>
					</cfif>
					<cfif request.cgi_script_name NEQ '/z/listing/inquiry/index'>
						<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 0>
							<cfelse>
							<a href="##" onclick="zShowModalStandard('/z/listing/inquiry/index?action=form&amp;modalpopforced=1&amp;listing_id=#arguments.idx.listing_id#&amp;inquiries_comments=#urlencodedformat('I''d like to apply to rent this property')#', 540, 630);return false;" rel="nofollow">Apply Now</a>
						</cfif>
					</cfif> 
					<cfif request.cgi_script_name NEQ '/z/listing/inquiry/index'>
						<a href="##" class="zls-saveListingButton" data-listing-id="#arguments.idx.listing_id#" rel="nofollow" class="zNoContentTransition">Save Listing</a>
					</cfif>
					<cfif arguments.idx.virtualtoururl neq '' and findnocase("http://",arguments.idx.virtualtoururl) NEQ 0>
						<a href="#application.zcore.functions.zBlockURL(arguments.idx.virtualtoururl)#" rel="nofollow" onclick="window.open(this.href); return false;">Virtual Tour</a>
					</cfif>
					<cfif arguments.idx.listingHasMap>
						<a href="#request.zos.currentHostName##propertyLink###googlemap" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>Map</a>
					</cfif>
					<cfif request.cgi_script_name NEQ '/z/listing/inquiry/index'>
						<a href="##" onclick="zShowModalStandard('/z/listing/inquiry/index?action=form&amp;modalpopforced=1&amp;listing_id=#arguments.idx.listing_id#', 540, 630);return false;" rel="nofollow">Ask Question</a>
					</cfif>
				</div></td>
		</tr>
		<tr>
			<td class="zls2-3" colspan="2"><table class="zls2-16">
					<tr>
						<td class="zls2-4" rowspan="3"><cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_image_enlarge',false,0)  EQ 0>
								<div id="m#arguments.idx.listing_id#" class="zls2-5" onmousemove="zImageMouseMove('m#arguments.idx.listing_id#',event);" onmouseout="setTimeout('zImageMouseReset(\'m#arguments.idx.listing_id#\')',100);"><a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>> 
									
									
									<img id="m#arguments.idx.listing_id#_img" src="#application.zcore.listingCom.getThumbnail(arguments.idx.photo1, request.lastPhotoId, 1, 221, 165, 1)#"  class="zlsListingImage"  alt="Listing Image" width="221" />
									</a></div>
								<cfif arguments.idx.listing_photocount LTE 1 or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_image_enlarge',false,0) EQ 2>
									<div class="zls2-6"></div>
									<cfelse>
									<div class="zls2-7">
										<cfif arguments.idx.listing_photocount NEQ 0>
											ROLLOVER TO VIEW #arguments.idx.listing_photocount# PHOTO<cfif arguments.idx.listing_photocount GT 1>S</cfif>
										</cfif>
									</div>
								</cfif>
								<cfelse>
								<div id="m#arguments.idx.listing_id#" class="zls2-5"><a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>> #application.zcore.functions.zLoadAndCropImage({id:"m#arguments.idx.listing_id#_img",width:221,height:165, url:arguments.idx.photo1, style:"", canvasStyle:"", crop:true})# 
									</a></div>
							</cfif></td>
						<td class="zls2-17" style="vertical-align:top;padding:0px;"><table style="width:100%;">
								<tr>
									<td class="zls2-2"> MLS ###listgetat(arguments.idx.listing_id,2,'-')# Source: #arguments.idx.listingSource# | <a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>#htmleditformat(titleStruct.title)#</a><br />
										#arguments.idx.listing_data_address#, #arguments.idx.cityName#, #arguments.idx.listing_state# #arguments.idx.listing_data_zip#</td>
								</tr>
								<tr>
									<td colspan="2"><div class="zls2-11">
											<cfscript>
										    /*if(priceChange GT 0){
											writeoutput('<span class="zls2-12 zPriceChangeMessage">Price reduced $#numberformat(pricechange)# since #dateformat(arguments.idx.listing_track_datetime,'m/d/yy')#, NOW $#numberformat(arguments.idx.listing_price)#</span> | '); 	
										    }else if(priceChange LT 0){
											writeoutput('<span class="zls2-12 zPriceChangeMessage">Price increased $#numberformat(abs(pricechange))# since #dateformat(arguments.idx.listing_track_datetime,'m/d/yy')#, NOW $#numberformat(arguments.idx.listing_price)#</span> | ');
										    }*/
											if(request.cgi_script_name EQ "/z/listing/property/detail/index"){
												writeoutput(htmleditformat(fullTextBackup));
											}else{
												writeoutput(htmleditformat(tempText));
											}
										    </cfscript>
										</div>
										<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 0 and application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_enable_mortgage_quote',true,1) EQ 1>
											<table class="zls2-13">
												<tr>
													<td>Low interest financing available. <a href="##" onclick="zShowModalStandard('/z/misc/mortgage-quote/index?modalpopforced=1', 540, 630);return false;" rel="nofollow"><strong>Get Pre-Qualified</strong></a></td>
												</tr>
											</table>
										</cfif>
										<table class="zls2-14">
											<tr>
												<td> Top Features:
													<cfif titleStruct.propertyType EQ "rental">
														For Rent
													<cfelse>
														#arguments.idx.listingstatus#
													</cfif>
													<cfif arguments.idx.listingFrontage NEQ "">
														, Frontage: #arguments.idx.listingFrontage#
													</cfif>
													<cfif arguments.idx.listingView NEQ "">
														, View: #arguments.idx.listingView#
													</cfif>
													<cfif arguments.idx.listing_pool EQ 1>
														Has a pool
													</cfif>
													<cfif arguments.idx.listing_subdivision neq ''>
														, Subdivision:&nbsp;#htmleditformat(arguments.idx.listing_subdivision)#
													</cfif>
													<cfif arguments.idx.listing_lot_square_feet neq '0' and arguments.idx.listing_lot_square_feet neq ''>
														, Lot SQFT: #arguments.idx.listing_lot_square_feet#sqft
													</cfif>
													<cfif arguments.idx.listing_year_built NEQ "">
														, Built in &nbsp;#arguments.idx.listing_year_built#
													</cfif>
													<cfif arguments.idx.listingStyle NEQ "">
														, Style: #arguments.idx.listingStyle#
													</cfif>
													<cfif arguments.idx.maintfees NEQ "" and arguments.idx.maintfees NEQ 0>
														, Maint Fees: $#numberformat(arguments.idx.maintfees)#
													</cfif></td>
											</tr>
										</table></td>
								</tr>
							</table></td>
						<cfscript>
						tempAgent=arguments.idx.listing_agent;
						</cfscript>
						<cfif structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[arguments.idx.mls_id], "agentIdStruct") and 
structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[arguments.idx.mls_id].agentIdStruct, tempAgent)>
							<cfscript>
							agentStruct=application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[arguments.idx.mls_id].agentIdStruct[tempAgent];
							userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
							userusergroupid = userGroupCom.getGroupId('user',request.zos.globals.id);
							</cfscript>
							<td class="zls2-agentPanel"> LISTING AGENT<br />
								<cfif fileexists(application.zcore.functions.zVar('privatehomedir',agentStruct.userSiteId)&removechars(request.zos.memberImagePath,1,1)&agentStruct.member_photo)>
									<img src="#application.zcore.functions.zvar('domain',agentStruct.userSiteId)##request.zos.memberImagePath##agentStruct.member_photo#" alt="Listing Agent" width="90"/><br />
								</cfif>
								<cfif agentStruct.member_first_name NEQ ''>
									#agentStruct.member_first_name#
								</cfif>
								<cfif agentStruct.member_last_name NEQ ''>
									#agentStruct.member_last_name#<br />
								</cfif>
								<cfif agentStruct.member_phone NEQ ''>
									<strong>#agentStruct.member_phone#</strong><br />
								</cfif>
								<cfif application.zcore.app.getAppData("content").optionstruct.content_config_url_listing_user_id NEQ "0" and agentStruct.member_public_profile EQ 1>
									<cfscript>
	tempName=application.zcore.functions.zurlencode(lcase("#agentStruct.member_first_name# #agentStruct.member_last_name# "),'-');
	</cfscript>
									<a href="/#tempName#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_listing_user_id#-#agentStruct.user_id#.html">Bio &amp; Listings</a>
								</cfif></td>
						</cfif>
					</tr>
				</table></td>
		</tr>
	</table>
	<div class="zls2-divider"></div>
</cffunction>

<cffunction name="ajaxTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	var propertyLink=0;
	var tempText=0;
	var tempText2=0;
	var theEnd=0;
	var pos=0;
	var rs={data:{}};
	//propertyLink = '#request.zos.globals.siteroot#/real-estate-#arguments.idx.listing_id#.html';
	propertyLink = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html';
	if(isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive){
		propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1");
	}
	rs.data.url[arguments.idx.arrayindex]=propertyLink;
	rs.data.mls_id[arguments.idx.arrayindex]=arguments.idx.mls_id;
	rs.data.listing_id[arguments.idx.arrayindex]=arguments.idx.listing_id;
	rs.data.city_id[arguments.idx.arrayindex]=arguments.idx.listing_city;
	rs.data.city[arguments.idx.arrayindex]=arguments.idx.cityName;
	rs.data.condoname[arguments.idx.arrayindex]=arguments.idx.listing_condoname;
	rs.data.address[arguments.idx.arrayindex]=arguments.idx.listing_address;
	
	rs.data.longitude[arguments.idx.arrayindex]=arguments.idx.listing_longitude;
	rs.data.latitude[arguments.idx.arrayindex]=arguments.idx.listing_latitude;
	rs.data.price[arguments.idx.arrayindex]=arguments.idx.listing_price;
	
	rs.data.view[arguments.idx.arrayindex]=arguments.idx.listingView;
	rs.data.style[arguments.idx.arrayindex]=arguments.idx.listingStyle;
	rs.data.frontage[arguments.idx.arrayindex]=arguments.idx.listingFrontage;
	rs.data.type[arguments.idx.arrayindex]=arguments.idx.listingPropertyType;
	if(arguments.idx.listing_beds neq '' and arguments.idx.listing_beds NEQ 0){
		rs.data.bedrooms[arguments.idx.arrayindex]=arguments.idx.listing_beds;
	}else{
		rs.data.bedrooms[arguments.idx.arrayindex]="";
	}
	if(arguments.idx.listing_baths neq '' and arguments.idx.listing_baths NEQ 0){
		rs.data.bathrooms[arguments.idx.arrayindex]=arguments.idx.listing_baths;
	}else{
		rs.data.bathrooms[arguments.idx.arrayindex]="";
	}
	if(arguments.idx.listing_halfbaths neq '' and arguments.idx.listing_halfbaths NEQ 0){
		rs.data.halfbaths[arguments.idx.arrayindex]=arguments.idx.listing_halfbaths;
	}else{
		rs.data.halfbaths[arguments.idx.arrayindex]="";
	}
	if(arguments.idx.listing_square_feet neq '' and arguments.idx.listing_square_feet NEQ 0){
		rs.data.square_footage[arguments.idx.arrayindex]=arguments.idx.listing_square_feet;
	}else if(arguments.idx.listing_lot_square_feet NEQ '' and arguments.idx.listing_lot_square_feet NEQ '0'){
		rs.data.square_footage[arguments.idx.arrayindex]=arguments.idx.listing_lot_square_feet;
	}else{
		rs.data.square_footage[arguments.idx.arrayindex]="";
	}
	if(arguments.idx.listing_pool EQ 1){
		rs.data.pool[arguments.idx.arrayindex]="Pool";
	}else{
		rs.data.pool[arguments.idx.arrayindex]="";
	}
	if(isDefined('arguments.idx.listing_price') and arguments.idx.listing_price neq '' and arguments.idx.listing_price neq 0){
		if(arguments.idx.listing_price LT 20){
			rs.data.price[arguments.idx.arrayindex]='$#numberformat(arguments.idx.listing_price)# per sqft ';
		}else{
			rs.data.price[arguments.idx.arrayindex]='$#numberformat(arguments.idx.listing_price)#';
		}
	}else{
		rs.data.price[arguments.idx.arrayindex]='';
	}
	if(arguments.idx.listing_subdivision neq 'Not In Subdivision' AND arguments.idx.listing_subdivision neq 'Not On The List' AND arguments.idx.listing_subdivision neq 'n/a' and isDefined('arguments.idx.listing_subdivision') and arguments.idx.listing_subdivision neq ''){
		rs.data.subdivision[arguments.idx.arrayindex]=arguments.idx.listing_subdivision;
	}else{
		rs.data.subdivision[arguments.idx.arrayindex]="";	
	}
	
	rs.data.photo1[arguments.idx.arrayindex]=arguments.idx.photo1;
	if(isDefined('arguments.idx.listing_data_remarks') and arguments.idx.listing_data_remarks NEQ '' and this.optionStruct.compactWithLinks EQ false){
		tempText = rereplace(arguments.idx.listing_data_remarks, "<.*?>","","ALL");
		tempText2=left(tempText, 280);
		theEnd = mid(tempText, 281, len(tempText));
		pos = find(' ', theEnd);
		if(pos NEQ 0){
			tempText2=tempText2&left(theEnd, pos);
		}
		rs.data.description[arguments.idx.arrayindex]=application.zcore.functions.zFixAbusiveCaps(tempText2);
	}else{
		rs.data.description[arguments.idx.arrayindex]="";
	}
	if(isDefined('arguments.idx.listing_virtual_tour_url') and arguments.idx.listing_virtual_tour_url neq ''){
		rs.data.virtual_tour[arguments.idx.arrayindex]=arguments.idx.listing_virtual_tour_url;
	}else{
		rs.data.virtual_tour[arguments.idx.arrayindex]="";
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="contentEmailTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="query" type="any" required="yes">
	<cfscript>
	var tempMLSId=0;
	var tempMLSPID=0;
	var tempMLSStruct=0;
	var contentConfig=application.zcore.app.getAppCFC("content").getContentIncludeConfig();
	if(contentConfig.showmlsnumber and application.zcore.app.siteHasApp("listing")){
		tempMlsId=arguments.query.content_mls_provider;
		tempMlsPId=arguments.query.content_mls_number;
		if(tempMLSId NEQ "" and tempMlsPId NEQ ""){
		    tempMLSStruct=application.zcore.listingCom.getMLSStruct(tempMLSId);
		    if(isStruct(tempMLSStruct)){
			if(tempMLSStruct.mls_login_url NEQ ''){
			    writeoutput('MLS ###tempMLSPid# found in #tempMLSStruct.mls_name# MLS, <a href="#tempMLSStruct.mls_login_url#" target="_blank">click here to login to MLS</a><br />');
			}else{
			    writeoutput('MLS ###tempMLSPid# found in #tempMLSStruct.mls_name# MLS<br />');
			}
		    }
		}
	}
	</cfscript>
	<table style="width:100%; border-spacing:0px;">
		<tr>
			<td style="vertical-align:top;padding:5px;width:100px;"><a target="_parent" href="<cfif arguments.query.content_url_only NEQ ''>#application.zcore.functions.zForceAbsoluteUrl(request.zos.currentHostName,arguments.query.content_url_only)#<cfelse>#request.zos.currentHostName#<cfif arguments.query.content_unique_name NEQ ''>#arguments.query.content_unique_name#<cfelse>/#application.zcore.functions.zURLEncode(arguments.query.content_name,'-')#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_article_id#-#arguments.query.content_id#.html</cfif></cfif>" style="   font-weight:normal;  ">
				<cfif fileexists(request.zos.globals.homedir&'images/content/'&arguments.query.content_thumbnail)>
					<img src="#request.zos.currentHostName&'/images/content/'##arguments.query.content_thumbnail#" class="listing-d-img" id="zclistingdimg#arguments.query.content_id#" width="100" height="78">
				<cfelse>
					Image N/A
				</cfif>
				</a><br />
				<cfif contentConfig.showmlsnumber EQ false and arguments.query.content_mls_number NEQ "">
					ID ###listgetat(arguments.query.content_mls_number,2,'-')#
				</cfif></td>
			<td style="vertical-align:top;padding:5px;text-align:left;"><h2><a target="_parent" href="<cfif arguments.query.content_url_only NEQ ''>#application.zcore.functions.zForceAbsoluteUrl(request.zos.currentHostName,arguments.query.content_url_only)#<cfelse>#request.zos.currentHostName#<cfif arguments.query.content_unique_name NEQ ''>#arguments.query.content_unique_name#<cfelse>/#application.zcore.functions.zURLEncode(arguments.query.content_name,'-')#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_article_id#-#arguments.query.content_id#.html</cfif></cfif>" style="text-decoration:none;">#arguments.query.content_name#</a>
					<cfif arguments.query.content_price NEQ 0>
						<br />
						$#numberformat(arguments.query.content_price)#
					</cfif>
				</h2>
				<a target="_parent" href="<cfif arguments.query.content_url_only NEQ ''>#application.zcore.functions.zForceAbsoluteUrl(request.zos.currentHostName,arguments.query.content_url_only)#<cfelse>#request.zos.currentHostName#<cfif arguments.query.content_unique_name NEQ ''>#arguments.query.content_unique_name#<cfelse>/#application.zcore.functions.zURLEncode(arguments.query.content_name,'-')#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_article_id#-#arguments.query.content_id#.html</cfif></cfif>" style="margin-right:3px; display:block;  font-weight:bold; float:left; padding:4px; line-height:20px; text-decoration:none; 	border-bottom:1px solid ##CCCCCC; " class="zcontent-readmore-link">Read More</a></td>
		</tr>
	</table>
	<hr />
</cffunction>

<cffunction name="descriptionLinkTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	var str1=0;
	var pos=0;
	var pos2=0;
	var rr=0;
	var sr=0;
	var mr=arguments.idx.listing_data_remarks;
	mr=rereplacenocase(mr,"[^A-Za-z0-9]+"," ","ALL");
	mr=replacenocase(mr,"  "," ","ALL");
	mr=replacenocase(mr,"must see property","","ALL");
	mr=replacenocase(mr,"is sold in as is condition","","ALL");
	mr=replacenocase(mr,"AS-IS SALE","","ALL");
	mr=replacenocase(mr,"AS IS SALE","","ALL");
	mr=replacenocase(mr,"All offers are subject to third party approval","","ALL");
	mr=replacenocase(mr,"all offers are subject to 3rd party approval","","ALL");
	mr=replacenocase(mr,"Contracts are subject to third party approval","","ALL");
	mr=replacenocase(mr,"bring offers","","ALL");
	pos=findnocase("foreclosure",mr);
	str1=randrange(20,50);
	if(pos EQ 0){
		pos=max(1,randrange(1,len(mr)-str1));
	}
	pos2=find(" ", mr, pos+str1);
	rr=randrange(10,30);
	if(pos2 EQ 0){
		sr=mid(mr,max(pos-rr,1), (len(mr)-pos)+rr);
	}else{
		sr=mid(mr,max(pos-rr,1), (pos2-pos)+rr);
	}
	pos2=find(" ", sr);
	if(pos2 NEQ 0){
		sr=removechars(sr,1,pos2);
	}
	</cfscript>
	<a href="#request.zos.currentHostName#/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html" target="_parent" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>
	<cfif sr EQ "">
		#htmleditformat(titleStruct.title)#
	<cfelse>
		#htmleditformat(trim(lcase(sr&' '&arguments.idx.cityName&' '&titleStruct.propertyType)))#
		<cfif arguments.idx.listing_subdivision NEQ "">
			in #htmleditformat(arguments.idx.listing_subdivision)#
		</cfif>
	</cfif>
	</a><br />
</cffunction>

<cffunction name="emailTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	var tempTitle = titleStruct.title;
	var urlTempTitle = titleStruct.urlTitle;
	var bgstyle=0;
	var propertyLink=0;
	if(arguments.idx.arrayindex MOD 2 EQ 0){
		bgstyle=" padding-bottom:5px; margin-bottom:15px; float:left; border-bottom:0px solid ##CCCCCC; background-image:url(#request.zos.currentHostName#/images/property-gradient.jpg); background-repeat:repeat-x; width:99%;";
	}else{
		bgstyle=" padding-bottom:5px; margin-bottom:15px; float:left; border-bottom:0px solid ##CCCCCC; background-image:url(#request.zos.currentHostName#/images/property-gradient.jpg); background-repeat:repeat-x; width:99%;";
	}
	propertyLink = request.zos.currentHostName&'/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html';
	if(isDefined('request.temp_saved_search_id')){
		propertyLink&='?saved_search_id=#request.temp_saved_search_id#&saved_search_email=#request.temp_saved_search_email#';
	}
	if(isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive){
		propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1");
	}
	</cfscript>
	<table style="border-spacing:0px;">
		<tr>
			<td style="vertical-align:top;padding:5px;"><a href="#propertyLink#" target="_parent" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>> #application.zcore.functions.zLoadAndCropImage({id:"m#arguments.idx.listing_id#_img",width:100,height:70, url:arguments.idx.photo1, style:"", canvasStyle:"", crop:true})# 
				<!--- <img id="m#arguments.idx.listing_id#_img" src="#application.zcore.listingCom.getThumbnail(arguments.idx.photo1, request.lastPhotoId, 1, 100, 70, 1)#" alt="Listing Photo" width="100" /> ---></a><br />
				<cfif isDefined('this.optionStruct.hideMLSNumber') EQ false or this.optionStruct.hideMLSNumber EQ false>
					ID###listgetat(arguments.idx.listing_id,2,'-')#
				</cfif>
				<cfif isDefined('request.temp_saved_search_id') and arguments.idx.listing_track_datetime NEQ "" and DateCompare(arguments.idx.listing_track_datetime,this.optionStruct.lastVisitDate) LTE 0>
					<br />
					<span style="color:##FF0000; font-weight:bold; ">New Listing!</span>
				</cfif></td>
			<td style="vertical-align:top;padding:5px;"><h2 style="font-size:14px; font-style:normal; line-height:normal; margin:0px; padding:0px; padding-bottom:5px; "><a href="#propertyLink#" target="_parent" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> style="text-decoration:none; ">#tempTitle#</a>
					<cfif isDefined('arguments.idx.content_mls_price') and arguments.idx.content_mls_price EQ 0 and arguments.idx.content_price NEQ "0">
						<br />
						$#numberformat(arguments.idx.content_price)#
					<cfelse>
						<cfif arguments.idx.listing_price NEQ "0">
							<br />
							$#numberformat(arguments.idx.listing_price)# <br />
							#arguments.idx.listingListStatus#
						</cfif>
					</cfif>
				</h2>
				<a href="#propertyLink#" target="_parent" style="margin-right:3px; display:block; font-weight:bold; float:left; padding:4px; line-height:20px; text-decoration:none; 	border-bottom:1px solid ##CCCCCC; " <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> class="zcontent-readmore-link">Read More</a></td>
		</tr>
	</table>
	<hr />
</cffunction>

<cffunction name="emailPlainTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	var tempTitle = titleStruct.title;
	var urlTempTitle = titleStruct.urlTitle;
	var propertyLink = '#request.zos.currentHostName#/#urlTempTitle#-#arguments.idx.listing_id#.html';
	if(isDefined('request.temp_saved_search_id')){
		propertyLink=propertyLink&'?saved_search_id=#request.temp_saved_search_id#&saved_search_email=#request.temp_saved_search_email#';
	}
	writeoutput('---------------------------------#chr(10)# MLS ###arguments.idx.listing_id##chr(10)# #replace(tempTitle,'<br />',chr(10),'ALL')##chr(10)# #propertyLink##chr(10)#');
	return;
	</cfscript>
</cffunction>

<cffunction name="mapTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var zdindex=0;
	var propertyLink=0;
	var image=0;
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	
	if(structkeyexists(request.zos, 'customListingMapLinkJSTemplate')){
		propertyLink=replacenocase(request.zos.customListingMapLinkJSTemplate, "##listing_id##", arguments.idx.listing_id, "one");
	}else{
		var propertyLink = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html';
		if(isDefined('this.optionStruct.searchID')){
			zdIndex = ((application.zcore.status.getField(this.optionStruct.searchId, "zIndex",0)-1)*application.zcore.status.getField(this.optionStruct.searchId, "perpage",0))+i;
			propertyLink=application.zcore.functions.zURLAppend(propertyLink,"searchID=#this.optionStruct.searchID#&zdIndex=#zdIndex#");
		}
		propertyLink=htmleditformat("zlsGotoMapLink('#propertyLink#'); return false;");
	}
	request.currentmappropertylink=propertyLink;
	if(structkeyexists(arguments.idx, 'sysidfield2')){
		image=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1, arguments.idx.sysidfield, arguments.idx.sysidfield2);
	}else if(structkeyexists(arguments.idx, 'sysidfield')){
		image=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1, arguments.idx.sysidfield);
	}else{
		image=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1);
	}
	</cfscript>
	<table style="width:100%; border-spacing:0px;">
		<tr>
			<td style="width:100px;padding:5px; vertical-align:top; padding-right:10px;border-right:1px solid ##999;"><cfif image neq false>
					<a href="##" onclick="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> target="_top"><img src="#application.zcore.listingCom.getThumbnail(image, request.lastPhotoId, 1, 100, 78, 1)#" width="100" height="78" onerror="this.style.display='none';document.getElementById('zmaptemplateimagena').style.display='block';" /></a>
					<cfelse>
					Image N/A
				</cfif>
				<div id="zmaptemplateimagena" style="display:none;">Image N/A</div></td>
			<td style="vertical-align:top; padding:5px; font-weight:normal;  "><a href="##" onclick="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> target="_top">
				<cfscript>
				if(arguments.idx.listing_beds neq '' and arguments.idx.listing_beds NEQ 0){
					writeoutput('#arguments.idx.listing_beds#bd, ');
				}
				if(arguments.idx.listing_halfbaths neq '' and arguments.idx.listing_halfbaths neq '0' and arguments.idx.listing_baths neq ''and arguments.idx.listing_baths neq '0'){
					writeoutput('#(arguments.idx.listing_halfbaths / 2) + arguments.idx.listing_baths#ba, ');
				}
				writeoutput('#arguments.idx.listingPropertyType#<br />');
				writeoutput('#arguments.idx.cityName#');
				
				if(arguments.idx.listing_price NEQ '0') {
					writeoutput('<br /><strong style="font-size:14px; line-height:18px;">$#numberformat(arguments.idx.listing_price)#</strong>');
				}
				writeoutput('<br /><strong style="font-size:13px; line-height:18px;">'&arguments.idx.listingListStatus&'</strong>');
				</cfscript>
				</a>
				<hr />
				<a href="##" onclick="goToStreetV3(#arguments.idx.listing_latitude#,#arguments.idx.listing_longitude#); return false;" rel="nofollow">Zoom to Street Level</a><br />
				<a href="##" onclick="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> target="_top"><strong>Click here for details</strong></a></td>
		</tr>
	</table>
</cffunction>

<cffunction name="rssTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var tempText=0;
	var theEnd=0;
	var pos=0;
	var date=0;
	var time=0;
	var imageLink=0;
	var propertyLink=0;
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	var tempTitle = titleStruct.title;
	var urlTempTitle = titleStruct.urlTitle;
	var commentlink="#request.zos.currentHostName##request.cgi_script_name#?action=form&mls_id=#arguments.idx.mls_id#&listing_id=#arguments.idx.listing_id#";
	
	imagelink=request.zos.currentHostName&application.zcore.listingCom.getThumbnail(arguments.idx.photo1, request.lastPhotoId, 1, 221, 165, 1);
	propertyLink = '#request.zos.currentHostName#/#urlTempTitle#-#arguments.idx.listing_id#.html';
	date = dateformat(arguments.idx.listing_track_updated_datetime, "ddd, dd mmm yyyy");
	time = timeformat(arguments.idx.listing_track_updated_datetime, "HH:mm:ss") & " EST";
	</cfscript>
	<item>
	<title>#xmlFormat(replace(tempTitle,'<br />',chr(10),'ALL'))#</title>
	<link>
	#xmlFormat(propertyLink)#
	</link>
	<cfscript> 
	tempText = rereplace(arguments.idx.listing_data_remarks, "<.*?>","","ALL");
	tempText = left(tempText, 280);
	theEnd = mid(arguments.idx.listing_data_remarks, 281, len(arguments.idx.listing_data_remarks));
	pos = find(' ', theEnd);
	if(pos NEQ 0){
		tempText=tempText&left(theEnd, pos);
	}
	tempText=application.zcore.functions.zFixAbusiveCaps(tempText);
	</cfscript>
	<description>
		<![CDATA[<p><cfif imagelink neq false><img src="#xmlFormat(imagelink)#" style="float:left; padding-right:10px; padding-bottom:10px;"/></cfif>#xmlFormat(tempText)#</p>]]>
	</description>
	<pubDate>#date# #time#</pubDate>
	<comments>#xmlformat(commentlink)#</comments>
	</item>
</cffunction>

<cffunction name="savedTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var propertyLink=0;
	var image=0;
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	propertyLink = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html';
	propertyLink=htmleditformat(propertyLink);
   
	if(structkeyexists(arguments.idx, 'sysidfield2')){
		image=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1, arguments.idx.sysidfield, arguments.idx.sysidfield2);
	}else if(structkeyexists(arguments.idx, 'sysidfield')){
		image=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1, arguments.idx.sysidfield);
	}else{
		image=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1);
	}
	</cfscript>
	<td style="text-align:center; border-right:1px solid ##999;">
	<cfif image neq false>
		<a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> target="_top" title="#htmleditformat(left(arguments.idx.listing_data_remarks,100))#"><img src="#application.zcore.listingCom.getThumbnail(image, request.lastPhotoId, 1, 100, 78, 1)#" style="max-width:100%;" class="listing-d-img" id="zlistingdimg#arguments.idx.listing_id#" alt="Listing Photo" /></a>
	<cfelse>
		Image N/A
	</cfif>
	<br />
	<a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> target="_top" style="  font-weight:normal;  ">
	<cfscript>
	if(isDefined('arguments.idx.listing_beds') and arguments.idx.listing_beds neq '' and arguments.idx.listing_beds NEQ 0){
		writeoutput('#arguments.idx.listing_beds#bd, ');
	}
	
	writeoutput('#titleStruct.propertyType#, ');
	
	if(isDefined('arguments.idx.listing_halfbaths') and arguments.idx.listing_halfbaths neq '' and arguments.idx.listing_halfbaths neq '0' and isDefined('arguments.idx.listing_baths') and arguments.idx.listing_baths neq ''and arguments.idx.listing_baths neq '0'){
		writeoutput('#(arguments.idx.listing_halfbaths / 2) + arguments.idx.listing_baths#ba, ');
	}
	if(isDefined('arguments.idx.content_mls_price') and arguments.idx.content_mls_price EQ 0 and arguments.idx.content_price NEQ "0"){
		writeoutput("$"&numberformat(arguments.idx.content_price));
	}else{
		if(arguments.idx.listing_price NEQ '0') {
			writeoutput('$#numberformat(arguments.idx.listing_price)#');
		}
	}
	writeoutput(", "&arguments.idx.listingListStatus);
	</cfscript>
	</a><br />
	<a href="##" class="zls-removeListingButton" data-listing-id="#arguments.idx.listing_id#" style=" font-weight:bold;  " title="Delete This Property From Your List" rel="nofollow" target="_top">Remove</a></td>
</cffunction>

<!--- 
    <cffunction name="classifiedFlyerAdsTemplate" localmode="modern" output="yes" returntype="any">
    	<cfargument name="idx" type="struct" required="yes">
        
    	
<cfscript>
		var db=request.zos.queryObject;
		var local=structnew();
titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
</cfscript>
<item>
<!--- required --->
<unique_id>#arguments.idx.listing_id#<!--- unique id for my server ---></unique_id>
<contact_company>#xmlformat(officeName)#<!--- Remax South ---></contact_company>
<contact_name>#xmlformat("")#<!--- Janet Williams ---></contact_name>
<cfif isDefined('officeAddress')><company_address>#xmlformat(officeAddress)#<!--- 1234 Agent company address ---></company_address>
<company_city>#xmlformat(officeCity)#<!--- Sarasota ---></company_city>
<company_state>#xmlformat(officeState)#<!--- FL ---></company_state>
<company_zip>#xmlformat(officeZip)#<!--- 54134 ---></company_zip>
<contact_phone1>#xmlformat(officePhone)#<!--- 800-555-1111 ---></contact_phone1>
<contact_email><cfif trim(officeEmail) EQ ''>#request.officeEmail#<cfelse>#xmlformat(officeEmail)#</cfif><!--- janet@someemail.com ---></contact_email></cfif>
<property_address>#arguments.idx.listing_data_address#<!--- 54321 Address of property ---></property_address>
<property_city>#xmlformat(arguments.idx.cityName)#<!--- Sarasota ---></property_city>
<property_state>#xmlformat(arguments.idx.listing_state)#<!--- FL ---></property_state>
<property_zip>#xmlformat(arguments.idx.listing_data_zip)#<!--- 54131 ---></property_zip>
<tagline><cfif arguments.idx.content_name NEQ ''>#xmlformat(arguments.idx.content_name)#<cfelse>#xmlformat(arguments.idx.listing_data_address)#</cfif><!--- limit 50 characters or street address ---></tagline>
<list_price>#xmlformat(arguments.idx.listing_price)#<!--- 450000 ---></list_price>
<arguments.idx.listing_type><cfif arguments.idx.listingstatus CONTAINS "lease">lease<cfelseif arguments.idx.listingStatus CONTAINS "rent">rent<cfelse>sale</cfif><!--- use one of : sale, rent, lease ---></listing_type>
<cfscript>
// code to determine property type
if(arguments.idx.listingPropertyType CONTAINS 'multi'){
	pt1="multi-family";
}else if(arguments.idx.listingPropertyType CONTAINS 'Acreage' or arguments.idx.listingPropertyType CONTAINS 'land'){
	pt1="land";
}else if(arguments.idx.listingPropertyType CONTAINS 'condo'){
	pt1="condo";
}else if(arguments.idx.listingPropertyType CONTAINS 'rental'){
	pt1="vacation";
}else if(arguments.idx.listingPropertyType CONTAINS 'commercial'){
	pt1="business";
	/*
}else if(arguments.idx.listingPropertyType CONTAINS 'multi'){
	pt1="office";
}else if(arguments.idx.listingPropertyType CONTAINS 'multi'){
	pt1="apartment";
	*/
}else if(arguments.idx.listingPropertyType CONTAINS 'residential' or arguments.idx.listingPropertyType CONTAINS 'single family' or arguments.idx.listingPropertyType CONTAINS 'mobile' or arguments.idx.listingPropertyType CONTAINS 'boat'){
	pt1="home";
}else{
	application.zcore.template.fail("Unknown property type: "&arguments.idx.listingPropertyType&" for listing_id: #arguments.idx.listing_id#");
}
</cfscript>
<property_type>#pt1#<!--- use one of these: home, office, condo, land, business, apartment, vacation, multi-family ---></property_type>

<!--- optional --->
<company_logo>#request.zos.currentHostName#/images/exit-classifiedflyerads-logo.jpg<!--- http://www.fullpathtologo/logofile.jpg ---></company_logo>
<!--- query member for agent photo, phone --->
<cfsavecontent variable="db.sql">
SELECT member_photo, user.site_id userSiteId 
FROM #request.zos.queryObject.table("user", request.zos.zcoreDatasource)# user 
WHERE member_mlsagentid=#db.param('#arguments.idx.urlMLSId#-#arguments.idx.listing_agent#')# and 
user_deleted = #db.param(0)# and
user.site_id = #db.param(request.zos.globals.id)# 
</cfsavecontent><cfscript>qM=db.execute("qM");</cfscript>
<cfif qm.recordcount NEQ 0 and qm.member_photo NEQ ''><agent_photo>#application.zcore.functions.zvar('domain',userSiteId)##request.zos.memberImagePath##qm.member_photo#</agent_photo></cfif>
<cfif isDefined('agentphone')><contact_phone2>#agentphone#<!--- 800-555-1111 ---></contact_phone2></cfif>
<mls>#listgetat(arguments.idx.listing_id,2,"-")#<!--- 2133441 ---></mls>
<cfif arguments.idx.listing_beds NEQ '0' and arguments.idx.listing_beds NEQ ''><bedrooms>#xmlformat(arguments.idx.listing_beds)#</bedrooms></cfif>
<cfif arguments.idx.listing_baths NEQ '0' and arguments.idx.listing_baths NEQ ''><bathrooms>#xmlformat(arguments.idx.listing_baths)#</bathrooms></cfif>
<cfif arguments.idx.listing_lot_square_feet NEQ '0' and arguments.idx.listing_lot_square_feet NEQ ''><lot_size>#xmlformat(arguments.idx.listing_lot_square_feet)#<!--- 6000 ---></lot_size></cfif>
<cfif arguments.idx.listing_data_remarks NEQ ''><description>#xmlformat(arguments.idx.listing_data_remarks)#</description> </cfif>
<cfif arguments.idx.listing_year_built NEQ '0' and arguments.idx.listing_year_built NEQ ''><year_built>#arguments.idx.listing_year_built#</year_built></cfif>
<cfif arguments.idx.listing_square_feet NEQ '0' and arguments.idx.listing_square_feet NEQ ''><sqfeet>#arguments.idx.listing_square_feet#<!--- 2000 ---></sqfeet></cfif>
<website>#xmlformat(request.zos.currentHostName&'/'&titleStruct.urlTitle&'-'&arguments.idx.urlMlsId&'-'&arguments.idx.urlMLSPId&'.html')#<!--- http://www.linktolistingdetails.com ---></website>
<website_title>#xmlformat(titleStruct.title)#<!--- http://www.linktolistingdetails.com ---></website_title>
<cfif arguments.idx.virtualtoururl NEQ '' and findnocase("http://",arguments.idx.virtualtoururl) NEQ 0><virtual_tour>#xmlformat(arguments.idx.virtualtoururl)#<!--- http://www.linktovirtualtour.com ---></virtual_tour> </cfif>
<other_link1>#xmlformat(request.zos.currentHostName&'/')#<!--- http://www.otherlinkurl.com ---></other_link1>
<other_link1_title>#xmlformat(request.zos.globals.homelinktext)#</other_link1_title>
<!--- <other_link2>other_link2</other_link2> 
<other_link2_title>other_link2_title</other_link2_title> --->
<!--- <video_link1>video_link1</video_link1> <!--- .wmv format --->
<video_link2>video_link2</video_link2>  --->
<cfloop from="1" to="#min(6,arguments.idx.listing_photocount)#" index="i"><cfif structkeyexists(variables, 'photo#i#')>
<image_path#i#>#xmlformat(application.zcore.functions.zso(variables, 'photo#i#'))#</image_path#i#>
</cfif>
</cfloop>

<!--- INCOMPLETE: --->
<!--- 
parking spaces: 
		FAR select * from far_feature where far_feature_type like '%parking%'
		rets4_property has rets4_parkingspaces
floors:		
	select * from far_feature where far_feature_description like '%story%'
	rets4 is building (some of the codes)
how to pull amenities?
how to pull features?

<parking_spaces>#rets4_parkingspaces<!--- 2 ---></parking_spaces>
<amenities>amenities</amenities>
<cfif 1 EQ 0><floors>floors<!--- 2 ---></floors></cfif> --->
<!--- <cfloop features  LIMIT OF 15
<feature#arguments.idx.arrayindex#>Newer Construction</feature#arguments.idx.arrayindex#>
</cfloop> --->



<!--- 
238 for a blue/grey colored template 
334 for a black/grey colored template 
335 for a red/grey colored template 
336 for a green/grey colored template 
337 for a silver/white colored template 
338 for a orange/grey colored template 
339 for a yellow/grey colored template 
 --->
 <!--- make a zsa variable - i can make my own custom and send to them too --->
<flyer_template_id>238<!--- 238 ---></flyer_template_id>
</item>

    </cffunction> ---> 

</cfoutput>
</cfcomponent>
