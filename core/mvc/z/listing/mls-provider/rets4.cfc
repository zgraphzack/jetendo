<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>	<cfscript>
	this.mls_id=4;
	this.useRetsFieldName="system";
	this.mls_provider="rets4";
	if(request.zos.istestserver){
		hqPhotoPath="#request.zos.sharedPath#mls-images/4/";
	}else{
		hqPhotoPath="#request.zos.sharedPath#mls-images/4/";
	}
	resourceStruct=structnew();
	resourceStruct["property"]=structnew();
	resourceStruct["property"].resource="property";
	resourceStruct["property"].id="listingid";
	resourceStruct["office"]=structnew();
	resourceStruct["office"].resource="office";
	resourceStruct["office"].id="firmid";
	resourceStruct["agent"]=structnew();
	resourceStruct["agent"].resource="agent";
	resourceStruct["agent"].id="agentid";
	this.arrFieldLookupFields=listtoarray("maintexpenses,architecture,appliances,asisconditionyn,city,condo,condoname,county,avmyn,displayaddresslisting,blogyn,houseorientation,inside,listingstatus,listingtype,maintfeecovers,miscellaneous,multaccyn,newconstructionyn,petsyn,pool,porch,propertyoninternetyn,propertytype,sewertype,showing,style,watercompany,waterfront",",");
	if(request.zos.istestserver){
		hqPhotoPath="#request.zos.sharedPath#mls-images/4/";
	}else{
		hqPhotoPath="#request.zos.sharedPath#mls-images/4/";
	}
	
	this.arrTypeLoop=["ResidentialProperty","CommercialProperty","VacantLand","BoatDock","MultiFamilyProperty"];
	
	variables.tableLookup=structnew();

	variables.tableLookup["R"]="ResidentialProperty";
	variables.tableLookup["C"]="CommercialProperty";
	variables.tableLookup["V"]="VacantLand";
	variables.tableLookup["D"]="BoatDock";
	variables.tableLookup["M"]="MultiFamilyProperty";
	</cfscript>


    <cffunction name="deleteListings" localmode="modern" output="no" returntype="any">
    	<cfargument name="idlist" type="string" required="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		var arrId=listtoarray(mid(replace(arguments.idlist," ","","ALL"),2,len(arguments.idlist)-2),"','");
		super.deleteListings(arguments.idlist);
		
		db.sql="DELETE FROM #db.table("rets4_property", request.zos.zcoreDatasource)#  
		WHERE rets4_listingid LIKE #db.param('4-%')# and 
		rets4_listingid IN (#db.trustedSQL(arguments.idlist)#)";
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
		var arrT2=0;
		var curLong=0;
		var s=0;
		var typePrefix2=0;
		var typePrefix=0;
		var ad=0;
		var curLat=0;
		var sub=0;
		var tmp=0;
		var arrT3=0;
		var ts2=0;
		var arrT=0;
		var typePrefix3=0;
		var address=0;
		var dataCom=0;
		var ts=0;
		var cityname=0;
		var cid=0;
		var rs=0;
		ts=structnew();
		if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.template.fail("RETS4: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
		}
		for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
			if(arguments.ss.arrData[i] EQ '0'){
				arguments.ss.arrData[i]="";	
			}
			ts[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
			columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=i;
		}  
		
		local.propertyType=variables.tableLookup[application.zcore.functions.zso(ts, 'rets4_propertytype')];
		
		if(not structkeyexists(ts, "rets4_subdivision")){ 
			ts['rets4_subdivision']="";
		}
		if(findnocase(","&ts["rets4_subdivision"]&",", ",none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
			ts["rets4_subdivision"]="";
		}else{ 
			if(ts["rets4_subdivision"] NEQ ""){
				sub=this.getRETSValue("property", "","subdivision",ts["rets4_subdivision"]);//," ","","ALL"));
				if(sub NEQ ""){
					ts["rets4_subdivision"]=sub;
				}
			}
			if(ts["rets4_subdivision"] NEQ ""){
				ts["rets4_subdivision"]=application.zcore.functions.zFirstLetterCaps(ts["rets4_subdivision"]);
			}
		} 
		this.price=ts["rets4_listprice"];
		cityName="";
		local.cityBackup=ts["rets4_city"];
		cid=0;
		if(ts["rets4_city"] NEQ ""){
			ts["rets4_city"]=this.getRETSValue("property", local.propertyType,"city",ts["rets4_city"]);
			cityName=ts["rets4_city"]&"|"&ts["rets4_stateorprovince"];
			if(structkeyexists(request.zos.listing.cityStruct, cityName)){
				cid=request.zos.listing.cityStruct[cityName];
			}
			cityName=ts["rets4_city"];
		}
		/*if(cid EQ 0){
			writeoutput(local.cityBackup&"|"&ts["rets4_city"]&"|"&ts["rets4_stateorprovince"]);
			writedump(request.zos.listing.cityStruct);
			abort;
		}*/
		local.listing_county=this.listingLookupNewId("county",application.zcore.functions.zso(ts, 'rets4_county'));
		if(ts["rets4_county"] NEQ ""){
			ts["rets4_county"]=this.getRETSValue("property", "","county",ts["rets4_county"]);
		}
		local.listing_type_id=this.listingLookupNewId("listing_type",application.zcore.functions.zso(ts, 'rets4_propertytype'));
		rs=getListingTypeWithCode(ts["rets4_propertytype"]);
		//ts["rets4_propertytype"]=rs.id;
		ad=application.zcore.functions.zso(ts, 'rets4_streetnumber');
		if(ad NEQ 0){
			address="#ad# ";
		}else{
			address="";	
		}
		address&=application.zcore.functions.zso(ts, 'rets4_streetname');
		curLat="";
		curLong="";
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,application.zcore.functions.zso(ts, 'rets4_stateorprovince'),application.zcore.functions.zso(ts, 'rets4_postalcode'));
			curLat=rs5.latitude;
			curLong=rs5.longitude;
		}
		if(application.zcore.functions.zso(ts, 'rets4_unitnumber') NEQ ''){
			address&=" Unit: "&ts["rets4_unitnumber"];	
		}
		
		
		ts2=structnew();
		ts2.field="";
		ts2.yearbuiltfield=application.zcore.functions.zso(ts, 'rets4_yearbuilt');
		ts2.foreclosureField="";
		s=this.processRawStatus(ts2);
		if(application.zcore.functions.zso(ts, 'rets4_newconstructionyn') EQ "Y"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
		}
		
		// special conditions
		if(application.zcore.functions.zso(ts, 'rets4_ownership') CONTAINS "02"){	
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		}
		if(application.zcore.functions.zso(ts, 'rets4_ownership') CONTAINS "01"){	
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}
		if(application.zcore.functions.zso(ts, 'rets4_ownership') CONTAINS "04"){	
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}
		
		if(application.zcore.functions.zso(ts, 'rets4_saleorlease') EQ "Sale"){
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
		}
		 

		
		local.listing_status=structkeylist(s,",");
		local.listing_style=this.listingLookupNewId("style", local.propertyType&"_"&application.zcore.functions.zso(ts, 'rets4_style'));
		
		// listing_sub_type 
		 
		arrT2=[];
		tmp=application.zcore.functions.zso(ts, 'rets4_buildingtype');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("listing_sub_type", local.propertyType&"_buildingtype_"&arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT2,tmp);
				}
			}
		}
		tmp=application.zcore.functions.zso(ts, 'rets4_landtypecom');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("listing_sub_type", local.propertyType&"_landtypecom_"&arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT2,tmp);
				}
			}
		}
		tmp=application.zcore.functions.zso(ts, 'rets4_landtype');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("listing_sub_type", local.propertyType&"_landtype_"&arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT2,tmp);
				}
			}
		}
		local.listing_sub_type_id=arraytolist(arrT2);
		/*
		// view & frontage
		arrT2=[];
		arrT3=[];
		tmp=application.zcore.functions.zso(ts, 'rets4_siteimprovements');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("frontage","siteimprovements_"&arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT2,tmp);
				}
				tmp=this.listingLookupNewId("view","siteimprovements_"&arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT3,tmp);
				}
			}
		}*/
		tmp=application.zcore.functions.zso(ts, 'rets4_waterfront');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("frontage",local.propertyType&"_"&arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT2,tmp);
				}
				/*
				tmp=this.listingLookupNewId("view",local.propertyType&"_waterfront_"&arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT3,tmp);
				}*/
			}
		}
		/*
		tmp=application.zcore.functions.zso(ts, 'rets4_landtype');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("frontage","landtype_"&arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT2,tmp);
				}
			}
		}*/
		local.listing_frontage=arraytolist(arrT2);
		local.listing_view="";//arraytolist(arrT3);
		/*typePrefix="siteimprovements";// siteimprovements
		typePrefix2="waterfront";// waterfront
		typePrefix3="landtype";// landtype
		*/
		tmp=this.listingLookupNewId("acreage",application.zcore.functions.zso(ts, 'rets4_acreage'));
		local.listing_acreage=this.listingLookupValue("acreage",tmp);
		

		local.listing_pool=0;
		r222=application.zcore.functions.zso(ts, 'rets4_publicremarks');
		var arrPool=listToArray(application.zcore.functions.zso(ts, 'rets4_pool'), ",");
		for(var i=1;i LTE arrayLen(arrPool);i++){
			tmp=this.listingLookupNewId("pool", local.propertyType&"_"&arrPool[i]);
			if(tmp NEQ ""){
				local.listing_pool=1;
				break;
			}
		}
		 
		if(structkeyexists(variables.tableLookup,ts.rets4_propertytype)){
			ts=this.convertRawDataToLookupValues(ts, variables.tableLookup[ts.rets4_propertytype], ts.rets4_propertytype);
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
		rs.listing_acreage=local.listing_acreage;
		rs.listing_baths=application.zcore.functions.zso(ts, 'rets4_bathstotal');
		rs.listing_halfbaths=application.zcore.functions.zso(ts, 'rets4_halfbaths');
		rs.listing_beds=application.zcore.functions.zso(ts, 'rets4_bedrooms');
		rs.listing_city=cid;
		rs.listing_county=local.listing_county;
		rs.listing_frontage=","&local.listing_frontage&",";
		rs.listing_frontage_name="";
		rs.listing_price=application.zcore.functions.zso(ts, 'rets4_listprice');
		rs.listing_status=","&local.listing_status&",";
		rs.listing_state=application.zcore.functions.zso(ts, 'rets4_stateorprovince');
		rs.listing_type_id=local.listing_type_id;
		rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
		rs.listing_style=","&local.listing_style&",";
		rs.listing_view=","&local.listing_view&",";
		rs.listing_lot_square_feet=application.zcore.functions.zso(ts, 'rets4_sqfttotal');
		rs.listing_square_feet=application.zcore.functions.zso(ts, 'rets4_sqftlivingarea');
		rs.listing_subdivision=application.zcore.functions.zso(ts, 'rets4_subdivision');
		rs.listing_year_built=application.zcore.functions.zso(ts, 'rets4_yearbuilt');
		rs.listing_office=application.zcore.functions.zso(ts, 'rets4_listingfirmid');
		rs.listing_agent=application.zcore.functions.zso(ts, 'rets4_listingagentid');
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=local.listing_pool;
		rs.listing_photocount=application.zcore.functions.zso(ts, 'rets4_photocount');
		rs.listing_coded_features="";
		rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
		rs.listing_primary="0";
		rs.listing_mls_id=arguments.ss.listing_mls_id;
		rs.listing_condoname=application.zcore.functions.zso(ts, 'rets4_condoname');
		rs.listing_address=trim(address);
		rs.listing_zip=trim(application.zcore.functions.zso(ts, 'rets4_postalcode'));
		rs.listing_condition="";
		rs.listing_parking="";
		rs.listing_region="";
		rs.listing_tenure="";
		rs.listing_liststatus="1";
		rs.listing_data_remarks=application.zcore.functions.zso(ts, 'rets4_publicremarks');
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(application.zcore.functions.zso(ts,'rets4_postalcode'));
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
    	<cfreturn "INNER JOIN #db.table("rets4_property", request.zos.zcoreDatasource)# rets4_property ON rets4_property.rets4_listingid = listing.listing_id">
    </cffunction>
    <cffunction name="getDetails" localmode="modern" output="yes" returntype="any">
    	<cfargument name="query" type="query" required="yes">
        <cfargument name="row" type="numeric" required="no" default="#1#">
        <cfargument name="fulldetails" type="boolean" required="no" default="#false#">
    	<cfscript>
		var db=request.zos.queryObject;
		var local=structnew();
		var q1=0;
		var t1=0;
		var t3=0;
		var t2=0;
		var i10=0;
		var value=0;
		var n=0;
		var d44=0;
		var t9=structnew();
		var column=0;
		var arrV=0;
		var arrV2=0;
		var a2=0;
		var i=0;
		var oid1=0;
		var idx=this.baseGetDetails(arguments.query, arguments.row, arguments.fulldetails);
		idx["features"]="";
		a2=listtoarray(trim(lcase(arguments.query.columnlist)),',',false);
		request.lastPhotoId=arguments.query.listing_id;
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		
		if(arguments.query.listing_photocount EQ 0){
				idx["photo1"]='/z/a/listing/images/image-not-available.gif';
			
		}else{
				i=1;
				
				for(i=1;i LTE arguments.query.listing_photocount;i++){
					local.fNameTemp1=idx.urlMlsPid&"-"&i&".jpeg";
					local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
					idx["photo"&i]=request.zos.currentHostName&'/zretsphotos/4/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				}
		}
		oid1="0";
		d44=dateformat(now(),"yyyymmdd");
		if(structkeyexists(application.zcore,'rets4officelookup') EQ false or application.zcore.rets4officelookupdate NEQ d44){
			t9=structnew();
			db.sql="SELECT rets4_name, rets4_firmid 
			FROM #db.table("rets4_office", request.zos.zcoreDatasource)# rets4_office";
			q1=db.execute("q1"); 
			for(i10=1;i10 LTE q1.recordcount;i10++){
				t9[q1.rets4_firmid[i10]]=q1.rets4_name[i10];
			}
			application.zcore.rets4officelookupdate=d44;
			application.zcore.rets4officelookup=t9;
		}
		
		if(structkeyexists(application.zcore.rets4officelookup, arguments.query.rets4_listingfirmid[arguments.row])){
			idx.officeName=application.zcore.rets4officelookup[arguments.query.rets4_listingfirmid[arguments.row]];	
		}else{
			idx.officeName="Firm Name Not Available";
		}
		idx["virtualtoururl"]=arguments.query["rets4_virtualtoururl"][arguments.row];
		
		idx["virtualtoururl"]=replace(idx["virtualtoururl"],"htttp:","http:");
		if(idx["virtualtoururl"] NEQ "" and find("http://",idx["virtualtoururl"]) EQ 0 and (find(".",idx["virtualtoururl"]) NEQ 0 and find("/",idx["virtualtoururl"]) NEQ 0)){
			idx["virtualtoururl"]&="http://"&idx["virtualtoururl"];
		}
		idx["zipcode"]=arguments.query["rets4_postalcode"][arguments.row];
		idx["maintfees"]=arguments.query["rets4_maintexpenses"][arguments.row];
		
		
		</cfscript>
        <cfsavecontent variable="idx.details">
        <table class="ztablepropertyinfo">
        #idx.listing_data_detailcache1#
        #idx.listing_data_detailcache2#
        #idx.listing_data_detailcache3#
         </table>
        </cfsavecontent>
        <cfscript>
		return idx;
		</cfscript>
    </cffunction>
    
    <cffunction name="getPhoto" localmode="modern" output="no" returntype="any">
    	<cfargument name="mls_pid" type="string" required="yes">
        <cfargument name="num" type="numeric" required="no" default="#1#">
    	<cfscript>
		var local=structnew();
		request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
		local.fNameTemp1=arguments.mls_pid&"-"&arguments.num&".jpeg";
		local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
		return request.zos.currentHostName&'/zretsphotos/4/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		</cfscript>
    </cffunction>
	
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript>
		var i=0;
		var s=0;
		var arrSQL=[];
		var fd=0;
		var arrError=[];
		var tp=0;
		var p=0;
		var fd2=0;
		var front=0;
		var typePrefix=0;
		var typePrefix2=0;
		var typePrefix3=0;
		var g=0;
		//  (listing_lookup_mls_provider, listing_lookup_type, listing_lookup_value, listing_lookup_oldid, listing_lookup_datetime, listing_lookup_oldid_unchanged) 
		for(g=1;g LTE arraylen(this.arrTypeLoop);g++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g], "propertytype");
			fd["M"]="Multi-Family";
			for(i in fd){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#')");
			} 
			
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"county");
			for(i in fd){
				arrayappend(arrSQL,"('#this.mls_provider#','county','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#')");
			}
			
			
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"acreage");
			fd2=structnew();
			for(i in fd){
				tp=fd[i];
				p=find(" ",tp);
				if(p NEQ 0){
					tp=left(tp,p-1);
				}
				if(tp CONTAINS "/"){
					tp=0.5;	
				}else if(tp CONTAINS "+"){
					tp=20;
				}
				fd2[i]=tp;
				arrayappend(arrSQL,"('#this.mls_provider#','acreage','#tp#','#i#','#request.zos.mysqlnow#','#i#')");
			}
			 
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"buildingtype");
			if(isstruct(fd)){
				for(i in fd){
					arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#', '#this.arrTypeLoop[g]&'_buildingtype_'&i#','#request.zos.mysqlnow#','#i#')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"landtypecom");
			if(isstruct(fd)){
				for(i in fd){
					arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#', '#this.arrTypeLoop[g]&'_landtypecom_'&i#','#request.zos.mysqlnow#','#i#')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"landtype");
			if(isstruct(fd)){
				for(i in fd){
					arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#', '#this.arrTypeLoop[g]&'_landtype_'&i#','#request.zos.mysqlnow#','#i#')");
				}
			}
			
			fd=this.getRETSValues("property", this.arrTypeLoop[g], "waterfront");  
			for(i in fd){
				arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#', '#this.arrTypeLoop[g]&'_'&i#','#request.zos.mysqlnow#','#i#')");
			}
			 
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"style");
			if(isstruct(fd)){
				for(i in fd){
					arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#', '#this.arrTypeLoop[g]&'_'&i#','#request.zos.mysqlnow#','#i#')");
				}
			}
			
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"pool");
			if(isstruct(fd)){ 
				for(i in fd){
					arrayappend(arrSQL,"('#this.mls_provider#','pool','#fd[i]#', '#this.arrTypeLoop[g]&'_'&i#','#request.zos.mysqlnow#','#i#')");
				}
			}
		}
		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>