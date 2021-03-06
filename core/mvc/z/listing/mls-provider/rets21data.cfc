<cfcomponent>
<cfoutput>
	<cfscript>
  variables.idxExclude=structnew();
	variables.allfields=structnew();
  </cfscript>
	<cffunction name="findFieldsInDatabaseNotBeingOutput" localmode="modern" access="remote" output="yes" returntype="any">
  	<cfscript>
		var db=request.zos.queryObject;
		var local=structnew();
		var curField=0;
		var db.sql=0;
		var qT=0;
		var f2=0;
		var idxExclude=structnew();
		</cfscript>
    <cfsavecontent variable="db.sql"> SHOW FIELDS FROM #request.zos.queryObject.table("rets21_property", request.zos.zcoreDatasource)#  </cfsavecontent>
    <cfscript>
    qT=db.execute("qT");
    
    variables.allfields=structnew();
    </cfscript>
    <cfloop query="qT">
			<cfscript>
      curField=replacenocase(field, "rets21_","");
      if(structkeyexists(application.zcore.listingStruct.mlsStruct["21"].sharedStruct.metaStruct["property"].tableFields, curField)){
      	f2=application.zcore.listingStruct.mlsStruct["21"].sharedStruct.metaStruct["property"].tableFields[curField].longname;
      }else{
      	f2=curField;
      }
      variables.allfields[field]=f2;
      </cfscript>
    </cfloop>
		<cfscript>
idxExclude["rets21_city"]="City";
idxExclude["rets21_cola_board"]="Cola_primaryboard";
idxExclude["rets21_cola_carphone"]="Cola_carphone";
idxExclude["rets21_cola_cellphone"]="Cola_cellphone";
idxExclude["rets21_cola_directphone"]="Cola_directphone";
idxExclude["rets21_cola_directphoneext"]="Cola_directphoneext";
idxExclude["rets21_cola_drelicensenumber"]="Co La Dre License Number";
idxExclude["rets21_cola_fax"]="Cola_fax";
idxExclude["rets21_cola_firstname"]="Cola_fname";
idxExclude["rets21_cola_homephone"]="Cola_phone";
idxExclude["rets21_cola_homephoneext"]="Cola_homephoneext";
idxExclude["rets21_cola_languages"]="Co La Languages";
idxExclude["rets21_cola_lastname"]="Cola_lname";
idxExclude["rets21_cola_mui"]="Cola_mui";
idxExclude["rets21_cola_pager"]="Cola_pager";
idxExclude["rets21_cola_publicid"]="Cola_publicid";
idxExclude["rets21_cola_tollfreephone"]="Cola_tollfreephone";
idxExclude["rets21_cola_tollfreephoneext"]="Cola_tollfreephoneext";
idxExclude["rets21_cola_voicemail"]="Cola_voice";
idxExclude["rets21_cola_voicemailext"]="Cola_voicex";
idxExclude["rets21_colo_board"]="Colo_primaryboard";
idxExclude["rets21_colo_code"]="Colo_code";
idxExclude["rets21_colo_drelicensenumber"]="Colo_drelicensenumber";
idxExclude["rets21_colo_fax"]="Colo_fax";
idxExclude["rets21_colo_mui"]="Colo_mui";
idxExclude["rets21_colo_name"]="Colo_name";
idxExclude["rets21_colo_phone"]="Colo_phone";
idxExclude["rets21_colo_phoneext"]="Colo_phoneext";
idxExclude["rets21_cosa_board"]="Cosa_board";
idxExclude["rets21_cosa_drelicensenumber"]="Co Sa Dre License Number";
idxExclude["rets21_cosa_firstname"]="Cosa_firstname";
idxExclude["rets21_cosa_lastname"]="Cosa_lastname";
idxExclude["rets21_cosa_mui"]="Cosa_mui";
idxExclude["rets21_cosa_publicid"]="Cosa_publicid";
idxExclude["rets21_coso_board"]="Coso_board";
idxExclude["rets21_coso_code"]="Coso_code";
idxExclude["rets21_coso_drelicensenumber"]="Coso_drelicensenumber";
idxExclude["rets21_coso_mui"]="Coso_mui";
idxExclude["rets21_coso_name"]="Coso_name";
idxExclude["rets21_internetsendaddressyn"]="Send Address To The Internet";
idxExclude["rets21_internetsendlistingyn"]="Free Internet Ad";
idxExclude["rets21_la_board"]="Laprimaryboard";
idxExclude["rets21_la_carphone"]="La_carphone";
idxExclude["rets21_la_cellphone"]="List Agent Cell Phone ##";
idxExclude["rets21_la_directphone"]="La_directphone";
idxExclude["rets21_la_directphoneext"]="La_directphoneext";
idxExclude["rets21_la_drelicensenumber"]="La Dre License Number";
idxExclude["rets21_la_fax"]="Listing Agent's Fax Number";
idxExclude["rets21_la_firstname"]="Lafname";
idxExclude["rets21_la_homephone"]="List Agent Residental Phone ##";
idxExclude["rets21_la_homephoneext"]="La_homephoneext";
idxExclude["rets21_la_languages"]="La Languages";
idxExclude["rets21_la_lastname"]="Lalname";
idxExclude["rets21_la_mui"]="Lamui";
idxExclude["rets21_la_pager"]="Listing Agent's Pager Number";
idxExclude["rets21_la_publicid"]="Listing Agent's Public Id";
idxExclude["rets21_la_tollfreephone"]="La_tollfreephone";
idxExclude["rets21_la_tollfreephoneext"]="La_tollfreephoneext";
idxExclude["rets21_la_voicemail"]="Voice Mail Number";
idxExclude["rets21_la_voicemailext"]="Voice Mail Number Extension";
idxExclude["rets21_keysafedescription"]="Key Safe Description";
idxExclude["rets21_keysafelocation"]="Key Safe Location";
idxExclude["rets21_adnumber"]="Adnumber";
idxExclude["rets21_bathsfull"]="Baths (full)";
idxExclude["rets21_bathshalf"]="Bath (half)";
idxExclude["rets21_bedrooms"]="Bedroom";
idxExclude["rets21_lo_board"]="Lo primary board";
idxExclude["rets21_lo_code"]="Listing Office's Number";
idxExclude["rets21_lo_drelicensenumber"]="Lo_drelicensenumber";
idxExclude["rets21_lo_fax"]="Listing Office's Fax Number";
idxExclude["rets21_lo_mui"]="Lomui";
idxExclude["rets21_lo_name"]="Listing Office's Name";
idxExclude["rets21_lo_phone"]="Listing Office's Phone Number";
idxExclude["rets21_lo_phoneext"]="Lo_phoneext";
idxExclude["rets21_managementco"]="Management Company";
idxExclude["rets21_managementcophone"]="Management Company Phone";
idxExclude["rets21_managementcophoneext"]="Managementcophoneext";
idxExclude["rets21_managementexpense"]="Manager";
idxExclude["rets21_managerapprovalyn"]="Manager's Approval";
idxExclude["rets21_managername"]="Manager's Name";
idxExclude["rets21_managersfax"]="Managersfax";
idxExclude["rets21_managersphone"]="Manager's Phone Number";
idxExclude["rets21_managersphoneext"]="Managersphoneext";
idxExclude["rets21_matrix_unique_id"]="Matrix_unique_id";
idxExclude["rets21_otherphonedescription"]="Otherphonedescription";
idxExclude["rets21_otherphoneext"]="Otherphoneext";
idxExclude["rets21_otherphonenumber"]="Otherphonenumber";
idxExclude["rets21_ownersname"]="Ownersname";
idxExclude["rets21_property_id"]="Property_id";
idxExclude["rets21_sa_board"]="Saprimaryboard";
idxExclude["rets21_sa_drelicensenumber"]="Sa Dre License Number";
idxExclude["rets21_sa_firstname"]="Safname";
idxExclude["rets21_sa_lastname"]="Salname";
idxExclude["rets21_sa_mui"]="Samui";
idxExclude["rets21_sa_publicid"]="Selling Agent's Public Id";
idxExclude["rets21_sellingofficecompensation"]="Selling Office Compensation";
idxExclude["rets21_sellingofficecompensationremarks"]="Sellingofficecompensationremarks";
idxExclude["rets21_so_board"]="Soprimary board";
idxExclude["rets21_so_code"]="Selling Office Code";
idxExclude["rets21_so_drelicensenumber"]="So_drelicensenumber";
idxExclude["rets21_so_mui"]="Somui";
idxExclude["rets21_so_name"]="Selling Office Name";
idxExclude["rets21_socompper"]="Socomper";
idxExclude["rets21_socomptype"]="So_comp_type";
idxExclude["rets21_soldterms"]="Soldterms";
idxExclude["rets21_longitude"]="Longitude";
idxExclude["rets21_latitude"]="Latitude";
idxExclude["rets21_showingcontactname"]="Showing contact name";
idxExclude["rets21_showingcontactphone"]="Showing contact phone";
idxExclude["rets21_showingcontactphoneext"]="Showing contact phone ext";
idxExclude["rets21_showingcontacttype"]="Showing contact type";
idxExclude["rets21_signonpropertyyn"]="Sign";
idxExclude["rets21_contactorder1"]="Contact order 1";
idxExclude["rets21_contactorder2"]="Contact order 2";
idxExclude["rets21_contactorder3"]="Contact order 3";
idxExclude["rets21_contactorder4"]="Contact order 4";
idxExclude["rets21_contactorder5"]="Contact order 5";
idxExclude["rets21_contactorder6"]="Contact order 6";
idxExclude["rets21_show"]="Showing Instructions";
idxExclude["rets21_streetdirection"]="Street Direction";
idxExclude["rets21_streetdirectionsuffix"]="Street Direction Suffix";
idxExclude["rets21_streetname"]="Street Name";
idxExclude["rets21_streetnumber"]="Street Number";
idxExclude["rets21_streetnumbermodifier"]="Street number modifier";
idxExclude["rets21_streetsuffix"]="Street Suffix";
idxExclude["rets21_streetsuffixmodifier"]="Street suffix modifier";
idxExclude["rets21_agentremarks"]="Office Remarks";
idxExclude["rets21_piccount"]="Number Of Images";
idxExclude["rets21_listing_board"]="Listing primary board";
idxExclude["rets21_serialu"]="U Serial Number";
idxExclude["rets21_serialx"]="X Serial Number";
idxExclude["rets21_serialxx"]="XX serial";
idxExclude["rets21_cleared"]="Cleared";
idxExclude["rets21_concessionsamount"]="Concessions amount";
idxExclude["rets21_concessionscomments"]="Concessions comments";
idxExclude["rets21_dualvariablecompensation"]="Dual/Variable Rate Of Compensation";
idxExclude["rets21_propertydescription"]="Property Description";
idxExclude["rets21_mlnumber"]="Multiple Listing Number";
idxExclude["rets21_mls_id"]="Mls Id";
idxExclude["rets21_timestampmodified"]="Timestamp modified";
idxExclude["rets21_timestampoffmarket"]="Timestamp off market";
idxExclude["rets21_timestamporiginalentry"]="Timestamp original entry";
idxExclude["rets21_timestampphotomodified"]="Timestamp photo modified";
idxExclude["rets21_timestampstatuschange"]="Timestamp status change";
idxExclude["rets21_datecanceled"]="Date canceled";
idxExclude["rets21_renewalpurchasecomp"]="Renewal Purchase Comp";
		// force allfields to not have the fields that already used
		this.getDetailCache1(structnew());
		this.getDetailCache2(structnew());
		this.getDetailCache3(structnew());
		
		if(structcount(variables.allfields) NEQ 0){
			writeoutput('<h2>// Fields not output:</h2>');
			local.arrKey=structkeyarray(variables.allfields);
			arraysort(local.arrKey, "text", "asc");
			for(local.i2=1;local.i2 LTE arraylen(local.arrKey);local.i2++){
				local.i=local.arrKey[local.i2];
				if(structkeyexists(idxExclude, local.i) EQ false){
					writeoutput('idxTemp2["'&local.i&'"]="'&replace(application.zcore.functions.zfirstlettercaps(variables.allfields[local.i]),"##","####")&'";<br />');
				}
			}
		}
		application.zcore.functions.zabort();
		</cfscript>
	</cffunction>

  <cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
   <cfargument name="idx" type="struct" required="yes">
   <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew(); 




idxTemp2["rets21_doh1"]="Doh 1";
idxTemp2["rets21_doh2"]="Doh 2";
idxTemp2["rets21_doh3"]="Doh 3";
idxTemp2["rets21_drivingdirections"]="Driving Directions";
idxTemp2["rets21_entrylocation"]="Entry location";
idxTemp2["rets21_firstrepairs"]="First Repairs";
idxTemp2["rets21_have"]="Have";
idxTemp2["rets21_landleaseamount"]="Space Rent";
idxTemp2["rets21_length"]="Length";
idxTemp2["rets21_make"]="Mobile Home Make";
idxTemp2["rets21_model"]="Mobile Home Model";
idxTemp2["rets21_modelcode"]="Model Code";
idxTemp2["rets21_modelname"]="Model Name";
idxTemp2["rets21_notincluded"]="Not included";
idxTemp2["rets21_occupanttype"]="Occupant Type";
idxTemp2["rets21_pestexpense"]="Pest Expense";
idxTemp2["rets21_petsallowed"]="Pets Allowed";
idxTemp2["rets21_photonotes"]="Photo Notes";
idxTemp2["rets21_points"]="Points";
idxTemp2["rets21_possession"]="Possession";
idxTemp2["rets21_postalcode"]="Postal code";
idxTemp2["rets21_postalcodeplus4"]="Postal code plus 4";
idxTemp2["rets21_potentialusage"]="Potential Use";
idxTemp2["rets21_presentloans"]="Loans";
idxTemp2["rets21_presentuse"]="Present Use";
idxTemp2["rets21_professionalmanagement"]="Professional Management";

idxTemp2["rets21_propertysubtype"]="Type";
idxTemp2["rets21_rentcontrolyn"]="Rent Control";
idxTemp2["rets21_rentincludes"]="Rent includes";
idxTemp2["rets21_rvaccessdimensions"]="RV Access Dimensions";
idxTemp2["rets21_securityexpense"]="Security expense";
idxTemp2["rets21_senioryn"]="Is senior housing y/n";
idxTemp2["rets21_servicetype"]="Service Type";
idxTemp2["rets21_skirt"]="Skirt";
idxTemp2["rets21_spacenumber"]="Space Number";
idxTemp2["rets21_state"]="State";
idxTemp2["rets21_status"]="Status";
idxTemp2["rets21_supplementcount"]="Supplements count";
idxTemp2["rets21_suppliesexpense"]="Supplies";
idxTemp2["rets21_thomasguide"]="Thomas Guide Number";
idxTemp2["rets21_typeofmobilehome"]="Type Of Mobile Home";
idxTemp2["rets21_unitnumber"]="Aptnum";
idxTemp2["rets21_view"]="View";
idxTemp2["rets21_virtualtour"]="Virtual Tour";
idxTemp2["rets21_vowconsumercomment"]="Vow Consumer Comment";
idxTemp2["rets21_width"]="Width";
idxTemp2["rets21_yearbuilt"]="Year Built";
idxTemp2["rets21_yearbuiltsource"]="Yearbuiltsource";
//idxTemp2["rets21_zipcode"]="Zip Code";
//idxTemp2["rets21_zipcodeplus4"]="Zipcodeplus4";
		
		arrayappend(arrR, application.zcore.listingStruct.configCom.getListingDetailRowOutput("Property Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		idxTemp2=structnew();
		
idxTemp2["rets21_cooling"]="Air Conditioning Description";
idxTemp2["rets21_appliances"]="Kitchen Applicances";
idxTemp2["rets21_basementsqft"]="Basement sqft";
idxTemp2["rets21_bath2"]="Bath 2";
idxTemp2["rets21_bathsoqtr"]="Bathoqtr";
idxTemp2["rets21_bathstotal"]="Bathroom";
idxTemp2["rets21_bathstqtr"]="Bathtqtr";
idxTemp2["rets21_cabletvexpense"]="Cable Tv";
idxTemp2["rets21_electricexpense"]="Electric Expense";
idxTemp2["rets21_eatingarea"]="Eating Area";
idxTemp2["rets21_spa"]="Spa";
idxTemp2["rets21_fireplace"]="Fireplace";
idxTemp2["rets21_heating"]="Heating";
idxTemp2["rets21_floor"]="Floor";
idxTemp2["rets21_furnished"]="Furnished";
idxTemp2["rets21_interiorfeatures"]="Interior features";
idxTemp2["rets21_laundry"]="Laundry";
idxTemp2["rets21_laundryequipment"]="Laundry Equipment";
		
		
		arrayappend(arrR, application.zcore.listingStruct.configCom.getListingDetailRowOutput("Interior Features", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		idxTemp2=structnew();
		
		arrayappend(arrR, application.zcore.listingStruct.configCom.getListingDetailRowOutput("Rental Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		
		idxTemp2=structnew();
idxTemp2["rets21_type10actualrent"]="Type 10 Actual Rent";
idxTemp2["rets21_type10baths"]="Unit 10 Bathrooms";
idxTemp2["rets21_type10bedrooms"]="Unit 10 Bedrooms";
idxTemp2["rets21_type10furnished"]="Type 10 ## Of Furnished/unfurnished";
idxTemp2["rets21_type10garageattached"]="Type 10 garage attached";
idxTemp2["rets21_type10garagespaces"]="Type 10 garage spaces";
idxTemp2["rets21_type10proformarent"]="Type 10 proforma rent";
idxTemp2["rets21_type10totalrent"]="Type 10 Total Rent";
idxTemp2["rets21_type10units"]="Number Of Units Type 10";
idxTemp2["rets21_type11actualrent"]="Type 11 Actual Rent";
idxTemp2["rets21_type11baths"]="Unit 11 Bathrooms";
idxTemp2["rets21_type11bedrooms"]="Unit 11 Bedrooms";
idxTemp2["rets21_type11furnished"]="Type 11 ## Of Furnished/unfurnished";
idxTemp2["rets21_type11garageattached"]="Type 11 garage attached";
idxTemp2["rets21_type11garagespaces"]="Type 11 garage spaces";
idxTemp2["rets21_type11proformarent"]="Type 11 proforma rent";
idxTemp2["rets21_type11totalrent"]="Type 11 Total Rent";
idxTemp2["rets21_type11units"]="Number Of Units Type 11";
idxTemp2["rets21_type12actualrent"]="Type 12 Actual Rent";
idxTemp2["rets21_type12baths"]="Unit 12 Bathrooms";
idxTemp2["rets21_type12bedrooms"]="Unit 12 Bedrooms";
idxTemp2["rets21_type12furnished"]="Type 12 ## Of Furnished/unfurnished";
idxTemp2["rets21_type12garageattached"]="Type 12 garage attached";
idxTemp2["rets21_type12garagespaces"]="Type 12 garage spaces";
idxTemp2["rets21_type12proformarent"]="Type 12 proforma rent";
idxTemp2["rets21_type12totalrent"]="Type 12 Total Rent";
idxTemp2["rets21_type12units"]="Number Of Units Type 12";
idxTemp2["rets21_type13actualrent"]="Type 13 Actual Rent";
idxTemp2["rets21_type13baths"]="Unit 13 Bathrooms";
idxTemp2["rets21_type13bedrooms"]="Unit 13 Bedrooms";
idxTemp2["rets21_type13furnished"]="Type 13 ## Of Furnished/unfurnished";
idxTemp2["rets21_type13garageattached"]="Type 13 garage attached";
idxTemp2["rets21_type13garagespaces"]="Type 13 garage spaces";
idxTemp2["rets21_type13proformarent"]="Type 13 proforma rent";
idxTemp2["rets21_type13totalrent"]="Type 13 Total Rent";
idxTemp2["rets21_type13units"]="Number Of Units Type 13";
idxTemp2["rets21_type1actualrent"]="Type 1 Actual Rent";
idxTemp2["rets21_type1baths"]="Unit 1 Bathrooms";
idxTemp2["rets21_type1bedrooms"]="Unit 1 Bedrooms";
idxTemp2["rets21_type1furnished"]="Type 1 ## Of Furnished/unfurnished";
idxTemp2["rets21_type1garageattached"]="Type 1 garage attached";
idxTemp2["rets21_type1garagespaces"]="Type 1 garage spaces";
idxTemp2["rets21_type1proformarent"]="Type 1 proforma rent";
idxTemp2["rets21_type1totalrent"]="Type 1 Total Rent";
idxTemp2["rets21_type1units"]="Number Of Units Type 1";
idxTemp2["rets21_type2actualrent"]="Type 2 Actual Rent";
idxTemp2["rets21_type2baths"]="Unit 2 Bathrooms";
idxTemp2["rets21_type2bedrooms"]="Unit 2 Bedrooms";
idxTemp2["rets21_type2furnished"]="Type 2 ## Of Furnished/unfurnished";
idxTemp2["rets21_type2garageattached"]="Type 2 garage attached";
idxTemp2["rets21_type2garagespaces"]="Type 2 garage spaces";
idxTemp2["rets21_type2proformarent"]="Type 2 proforma rent";
idxTemp2["rets21_type2totalrent"]="Type 2 Total Rent";
idxTemp2["rets21_type2units"]="Number Of Units Type 2";
idxTemp2["rets21_type3actualrent"]="Type 3 Actual Rent";
idxTemp2["rets21_type3baths"]="Unit 3 Bathrooms";
idxTemp2["rets21_type3bedrooms"]="Unit 3 Bedrooms";
idxTemp2["rets21_type3furnished"]="Type 3 ## Of Furnished/unfurnished";
idxTemp2["rets21_type3garageattached"]="Type 3 garage attached";
idxTemp2["rets21_type3garagespaces"]="Type 3 garage spaces";
idxTemp2["rets21_type3proformarent"]="Type 3 proforma rent";
idxTemp2["rets21_type3totalrent"]="Type 3 Total Rent";
idxTemp2["rets21_type3units"]="Number Of Units Type 3";
idxTemp2["rets21_type4actualrent"]="Type 4 Actual Rent";
idxTemp2["rets21_type4baths"]="Unit 4 Bathrooms";
idxTemp2["rets21_type4bedrooms"]="Unit 4 Bedrooms";
idxTemp2["rets21_type4furnished"]="Type 4 ## Of Furnished/unfurnished";
idxTemp2["rets21_type4garageattached"]="Type 4 garage attached";
idxTemp2["rets21_type4garagespaces"]="Type 4 garage spaces";
idxTemp2["rets21_type4proformarent"]="Type 4 proforma rent";
idxTemp2["rets21_type4totalrent"]="Type 4 Total Rent";
idxTemp2["rets21_type4units"]="Number Of Units Type 4";
idxTemp2["rets21_type5actualrent"]="Type 5 Actual Rent";
idxTemp2["rets21_type5baths"]="Unit 5 Bathrooms";
idxTemp2["rets21_type5bedrooms"]="Unit 5 Bedrooms";
idxTemp2["rets21_type5furnished"]="Type 5 ## Of Furnished/unfurnished";
idxTemp2["rets21_type5garageattached"]="Type 5 garage attached";
idxTemp2["rets21_type5garagespaces"]="Type 5 garage spaces";
idxTemp2["rets21_type5proformarent"]="Type 5 proforma rent";
idxTemp2["rets21_type5totalrent"]="Type 5 Total Rent";
idxTemp2["rets21_type5units"]="Number Of Units Type 5";
idxTemp2["rets21_type6actualrent"]="Type 6 Actual Rent";
idxTemp2["rets21_type6baths"]="Unit 6 Bathrooms";
idxTemp2["rets21_type6bedrooms"]="Unit 6 Bedrooms";
idxTemp2["rets21_type6furnished"]="Type 6 ## Of Furnished/unfurnished";
idxTemp2["rets21_type6garageattached"]="Type 6 garage attached";
idxTemp2["rets21_type6garagespaces"]="Type 6 garage spaces";
idxTemp2["rets21_type6proformarent"]="Type 6 proforma rent";
idxTemp2["rets21_type6totalrent"]="Type 6 Total Rent";
idxTemp2["rets21_type6units"]="Number Of Units Type 6";
idxTemp2["rets21_type7actualrent"]="Type 7 Actual Rent";
idxTemp2["rets21_type7baths"]="Unit 7 Bathrooms";
idxTemp2["rets21_type7bedrooms"]="Unit 7 Bedrooms";
idxTemp2["rets21_type7furnished"]="Type 7 ## Of Furnished/unfurnished";
idxTemp2["rets21_type7garageattached"]="Type 7 garage attached";
idxTemp2["rets21_type7garagespaces"]="Type 7 garage spaces";
idxTemp2["rets21_type7proformarent"]="Type 7 proforma rent";
idxTemp2["rets21_type7totalrent"]="Type 7 Total Rent";
idxTemp2["rets21_type7units"]="Number Of Units Type 7";
idxTemp2["rets21_type8actualrent"]="Type 8 Actual Rent";
idxTemp2["rets21_type8baths"]="Unit 8 Bathrooms";
idxTemp2["rets21_type8bedrooms"]="Unit 8 Bedrooms";
idxTemp2["rets21_type8furnished"]="Type 8 ## Of Furnished/unfurnished";
idxTemp2["rets21_type8garageattached"]="Type 8 garage attached";
idxTemp2["rets21_type8garagespaces"]="Type 8 garage spaces";
idxTemp2["rets21_type8proformarent"]="Type 8 proforma rent";
idxTemp2["rets21_type8totalrent"]="Type 8 Total Rent";
idxTemp2["rets21_type8units"]="Number Of Units Type 8";
idxTemp2["rets21_type9actualrent"]="Type 9 Actual Rent";
idxTemp2["rets21_type9baths"]="Unit 9 Bathrooms";
idxTemp2["rets21_type9bedrooms"]="Unit 9 Bedrooms";
idxTemp2["rets21_type9furnished"]="Type 9 ## Of Furnished/unfurnished";
idxTemp2["rets21_type9garageattached"]="Type 9 garage attached";
idxTemp2["rets21_type9garagespaces"]="Type 9 garage spaces";
idxTemp2["rets21_type9proformarent"]="Type 9 proforma rent";
idxTemp2["rets21_type9totalrent"]="Type 9 Total Rent";
idxTemp2["rets21_type9units"]="Number Of Units Type 9";
		arrayappend(arrR, application.zcore.listingStruct.configCom.getListingDetailRowOutput("Unit Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		</cfscript>
	</cffunction>
	<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
    <cfargument name="idx" type="struct" required="yes">
    <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		
idxTemp2["rets21_acres"]="Lot Size In Acres";
idxTemp2["rets21_blocknumber"]="Block Number";
idxTemp2["rets21_builderstractcode"]="Builders Tract Code";
idxTemp2["rets21_builderstractname"]="Builders Tract Name";
idxTemp2["rets21_crossstreets"]="Cross Streets";
idxTemp2["rets21_currentgeologicalyn"]="Current Geological y/n";
idxTemp2["rets21_distancetobus"]="Distance To Bus";
idxTemp2["rets21_distancetochurches"]="Distance To Churches";
idxTemp2["rets21_distancetoelectric"]="Distance To Electric";
idxTemp2["rets21_distancetofreeway"]="Distance To Freeway";
idxTemp2["rets21_distancetogas"]="Distance To Gas";
idxTemp2["rets21_distancetophoneservice"]="Distance To Phone Service";
idxTemp2["rets21_distancetoschools"]="Distance To Schools";
idxTemp2["rets21_distancetosewer"]="Distance To Sewer";
idxTemp2["rets21_distancetostores"]="Distance To Stores";
idxTemp2["rets21_distancetostreet"]="Street Frontage";
idxTemp2["rets21_distancetowater"]="Distance To Water";
idxTemp2["rets21_lotdimensions"]="Lot Size Dimensions";
idxTemp2["rets21_lotnumber"]="Lot Number";
idxTemp2["rets21_lotsquarefootage"]="Lot Square Footage";
idxTemp2["rets21_usablelandpercent"]="Total Percent Usable Land";
idxTemp2["rets21_utilities"]="Water Source";
idxTemp2["rets21_waterdistrictname"]="Water District Name";
idxTemp2["rets21_watersewerexpense"]="Water/sewer";
idxTemp2["rets21_watertabledepth"]="Estimated Depth Of Water Table";
idxTemp2["rets21_waterwellyn"]="Water Well";
idxTemp2["rets21_welldepth"]="Well Depth";
idxTemp2["rets21_wellgallonsperminute"]="Gallons Of Water Per Minute";
idxTemp2["rets21_wellholesize"]="Est. Size Of Well Hole/casting";
idxTemp2["rets21_wellpumphorsepower"]="Pump Motor Horsepower";
idxTemp2["rets21_wellreportyn"]="Well report y/n";
idxTemp2["rets21_parcelmapnumber"]="Parcel Map Number";
idxTemp2["rets21_parcelnumber"]="Parcel Number";
idxTemp2["rets21_parkname"]="Park Name";
idxTemp2["rets21_parktype"]="Park Type";
idxTemp2["rets21_possiblenewzone"]="Possible New Zone";
idxTemp2["rets21_schooldistrict"]="School District";
idxTemp2["rets21_schoolelementary"]="Elementary School";
idxTemp2["rets21_schoolhigh"]="High School";
idxTemp2["rets21_schooljuniorhigh"]="Junior High School";
idxTemp2["rets21_sqftsourcelot"]="Lot Square Footage Source";
idxTemp2["rets21_topography"]="Topography";
idxTemp2["rets21_tractmap"]="Tract map";
idxTemp2["rets21_tractname"]="Tract Name";
idxTemp2["rets21_tractnumber"]="Tract Number";
idxTemp2["rets21_tractsubareacode"]="Tract subarea code";
idxTemp2["rets21_zone"]="Zone";
idxTemp2["rets21_country"]="Country";
idxTemp2["rets21_elevation"]="Elevation Above Sea Level";
idxTemp2["rets21_county"]="County";
idxTemp2["rets21_area"]="Area";
idxTemp2["rets21_soiltype"]="Type Of Soil";

idxTemp2["rets21_trees"]="Trees";
		arrayappend(arrR, application.zcore.listingStruct.configCom.getListingDetailRowOutput("Land Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		idxTemp2=structnew();
		
idxTemp2["rets21_stories"]="Stories";
idxTemp2["rets21_numbercarpet"]="Number Of Units With Carpet";
idxTemp2["rets21_numbercarportspaces"]="Number Of Carport Spaces";
idxTemp2["rets21_numberdishwasher"]="Number Of Units With Dishwashers";
idxTemp2["rets21_numberdisposal"]="Number Of Units With Disposals";
idxTemp2["rets21_numberdrapes"]="Number Of Units With Drapes";
idxTemp2["rets21_numberelectricmeters"]="## Of Separate Electric Meters";
idxTemp2["rets21_numbergaragespaces"]="Garage Spaces";
idxTemp2["rets21_numbergasmeters"]="Number Of Separate Gas Meters";
idxTemp2["rets21_numberleased"]="Number Of Units Leased";
idxTemp2["rets21_numberofbuildings"]="Total Number Of Buildings";
idxTemp2["rets21_numberparkingspaces"]="Number Of Parking Spaces";
idxTemp2["rets21_numberpatio"]="Number Of Patios";
idxTemp2["rets21_numberrange"]="Number Of Units With Ranges";
idxTemp2["rets21_numberrefrigerator"]="## Of Units With Refrigerators";
idxTemp2["rets21_numberremotes"]="Number of Remotes";
idxTemp2["rets21_numberrentedgarages"]="Number Of Rented Garages";
idxTemp2["rets21_numbersheds"]="Number Of Sheds";
idxTemp2["rets21_patio"]="Patio";
idxTemp2["rets21_pool"]="Pool";
idxTemp2["rets21_poolyn"]="Pool Y/N";
idxTemp2["rets21_roofing"]="Roofing Materials";
idxTemp2["rets21_sqftsourcestructure"]="Area Square Footage Source";
idxTemp2["rets21_squarefootage1bedroom"]="Approx Avg Of 1 Bedroom Sqft";
idxTemp2["rets21_squarefootage2bedroom"]="Approx Avg Of 2 Bedroom Sqft";
idxTemp2["rets21_squarefootage3bedroom"]="Approx Avg Of 3 Bedroom Sqft";
idxTemp2["rets21_squarefootagebuilding"]="Total Building Square Footage";
idxTemp2["rets21_squarefootagestructure"]="Square Footage";
idxTemp2["rets21_squarefootagestudio"]="Approx Avg Of Studio Sqft";
idxTemp2["rets21_style"]="Style";
idxTemp2["rets21_rooms"]="Rooms";
idxTemp2["rets21_numberspaces"]="Number Of Spaces";
idxTemp2["rets21_parking"]="Parking Space Description";
idxTemp2["rets21_parkingspacestotal"]="Total Parking Spaces";
idxTemp2["rets21_numberunits"]="Units";
idxTemp2["rets21_numberwallac"]="Number Of Wall Air Conditioners";
idxTemp2["rets21_numberwatermeters"]="Number Of Separate Water Meters";


idxTemp2["rets21_fencing"]="Fencing";
idxTemp2["rets21_additionaldimensions"]="Addition Dimensions";
idxTemp2["rets21_attachedstructure"]="Attached Structure";
idxTemp2["rets21_foundation"]="Foundation";
idxTemp2["rets21_garageattached"]="Garage Description";
idxTemp2["rets21_garageincome"]="Garage Rental Income";
idxTemp2["rets21_garagerentalrate"]="Garage Rental Rate";
idxTemp2["rets21_garagespaces"]=" garage spaces";
idxTemp2["rets21_constructionmaterials"]="Construction materials";
idxTemp2["rets21_gasexpense"]="Gas Expense";
idxTemp2["rets21_improvements"]="Improvements";
idxTemp2["rets21_ingressegress"]="Ingress/egress";
		arrayappend(arrR, application.zcore.listingStruct.configCom.getListingDetailRowOutput("Room &amp; Building Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		
		
		</cfscript>
  </cffunction>
  <cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
    <cfargument name="idx" type="struct" required="yes">
    <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		

idxTemp2["rets21_associationdues1"]="Association dues 1";
idxTemp2["rets21_associationdues1frequency"]="Association dues 1 frequency";
idxTemp2["rets21_associationdues2"]="Association dues 2";
idxTemp2["rets21_associationdues2frequency"]="Association dues 2 frequency";
idxTemp2["rets21_associationname1"]="Association name 1";
idxTemp2["rets21_associationname2"]="Association name 2";
idxTemp2["rets21_associationphone1"]="Association phone 1";
idxTemp2["rets21_associationphone1ext"]="Association phone1 ext";
idxTemp2["rets21_associationphone2"]="Association phone 2";
idxTemp2["rets21_associationphone2ext"]="Association phone 2 ext";
idxTemp2["rets21_associationyn"]="Association y/n";
idxTemp2["rets21_association"]="Association";
idxTemp2["rets21_creditcheckpaidby"]="Credit Check Paid By";
idxTemp2["rets21_creditcheckyn"]="Credit Check y/n";

idxTemp2["rets21_dateclosedsale"]="Date closed sale";
idxTemp2["rets21_dateending"]="Date ending";
idxTemp2["rets21_dateholdactivation"]="Date hold activation";
idxTemp2["rets21_datelandleaseexp"]="Lease Expiration Year";
idxTemp2["rets21_datelandleaserenew"]="Land Lease Renew Date";
idxTemp2["rets21_dateleasebegins"]="Sold date";
idxTemp2["rets21_dateleased"]="Leased date";
idxTemp2["rets21_datelistingcontract"]="Date listing contract";
idxTemp2["rets21_datepurchasecontract"]="Date purchase contract";
idxTemp2["rets21_datestatuschange"]="Status date";
idxTemp2["rets21_deletedyn"]="Is deleted";
idxTemp2["rets21_depositkey"]="Deposit Key";
idxTemp2["rets21_depositother"]="Other Deposit";
idxTemp2["rets21_depositpets"]="Pet Deposit";
idxTemp2["rets21_depositsecurity"]="Security deposit";
idxTemp2["rets21_disclosures"]="Disclosures";
idxTemp2["rets21_grossequity"]="Gross Equity";
idxTemp2["rets21_grossmultiplier"]="Gross Multiplier";
idxTemp2["rets21_grossoperatingincome"]="Gross Operating Income";
idxTemp2["rets21_grossscheduledincome"]="Gross Scheduled Income";
idxTemp2["rets21_grossspendableincome"]="Gross Spendable Income";
idxTemp2["rets21_improvementsamount"]="Dollar Value Of Improvements";
idxTemp2["rets21_improvementspercent"]="Percent Total Value Improvement";
idxTemp2["rets21_incomeotherdesc"]="Description Of Other Income";
idxTemp2["rets21_insurancewaterfurnitureyn"]="Insurance water furniture y/n";
idxTemp2["rets21_landfeelease"]="Land Fee/lease";
idxTemp2["rets21_landleasepurchaseyn"]="Land Lease Purchase";
idxTemp2["rets21_landleasetransferfee"]="Land Lease Transfer Fee";
idxTemp2["rets21_landvalue"]="Land Fee/lease";
idxTemp2["rets21_landvaluepercent"]="Lease Per Month/year";
idxTemp2["rets21_laundryincome"]="Laundry Income";
idxTemp2["rets21_leaseconsideredyn"]="Offered For Lease";
idxTemp2["rets21_leasepermonthyear"]="Lease per month year";
idxTemp2["rets21_listingchangetype"]="Listing change type";
idxTemp2["rets21_listingpaidyn"]="Listing Paid";
idxTemp2["rets21_listingtype"]="List Type";
idxTemp2["rets21_listprice"]="List Price";
idxTemp2["rets21_listpriceexcludes"]="List Price Excludes";
idxTemp2["rets21_listpriceincludes"]="List price includes";
idxTemp2["rets21_listpricelow"]="List price l";
idxTemp2["rets21_listpriceoriginal"]="List Price original";
idxTemp2["rets21_loanpayment"]="Annual Loan Payment Amount";
idxTemp2["rets21_maintenanceexpense"]="Maintenance Dollars";
idxTemp2["rets21_maintenancepercent"]="Maintenance Percent";
idxTemp2["rets21_monthlygrossincome"]="Monthly Gross Scheduled Income";
idxTemp2["rets21_netoperatingincome"]="Net Operating Income Percent";
idxTemp2["rets21_newtaxesexpense"]="New Taxes Expense";
idxTemp2["rets21_operatingexpense"]="Operating Expense Dollar Amount";
idxTemp2["rets21_operatingexpensepercent"]="Operating Expense Percentage";
idxTemp2["rets21_otherexpense"]="Other Expense Amount";
idxTemp2["rets21_otherexpensedescription"]="Other Expense Description";
idxTemp2["rets21_otherincome1"]="Other Income";
idxTemp2["rets21_otherincome2"]="Second Other Income";
idxTemp2["rets21_personalpropertyamount"]="Personal Property Dollars";
idxTemp2["rets21_personalpropertypercent"]="Personal Property Percent";
idxTemp2["rets21_poolexpense"]="Pool Expense";
idxTemp2["rets21_pricepersqft"]="Price per sqft";
idxTemp2["rets21_priceperunit"]="Price Per Unit";
idxTemp2["rets21_proformarenttotal"]="Proforma rent total";
idxTemp2["rets21_rvparkingfee"]="Rv Parking Fee";
idxTemp2["rets21_saletype"]="Saletype";
idxTemp2["rets21_saleyn"]="Sale";
idxTemp2["rets21_sellingprice"]="Selling Price";
idxTemp2["rets21_survey"]="Survey";
idxTemp2["rets21_taxarea"]="Tax Area";
idxTemp2["rets21_taxespercent"]="Taxes Percent";
idxTemp2["rets21_taxestotal"]="Total Taxes";
idxTemp2["rets21_taxrate"]="Tax Rate";
idxTemp2["rets21_taxratetotal"]="Total Tax Rate";
idxTemp2["rets21_taxrateyear"]="Tax Rate Year";
idxTemp2["rets21_taxtotal"]="Total Taxes";
idxTemp2["rets21_tenantpays"]="Tennant pays";
idxTemp2["rets21_terms"]="Terms";
idxTemp2["rets21_totalexpenses"]="Total Expenses";
idxTemp2["rets21_financialinfoasof"]="Financial Info As Of";
idxTemp2["rets21_financialremarks"]="Financing Type";
idxTemp2["rets21_creditamount"]="Credit Amount";
idxTemp2["rets21_cashierscheck"]="Cashiers Check";
idxTemp2["rets21_financing"]="Financing Type";
idxTemp2["rets21_caprate"]="Cap Rate";
idxTemp2["rets21_actualrenttotal"]="Total Actual Rent";
idxTemp2["rets21_totalmoveincosts"]="Total move in costs";
idxTemp2["rets21_transferfee"]="Transfer fee";
idxTemp2["rets21_transferfeepaidby"]="Transfer fee paid by";
idxTemp2["rets21_vacancyallowdollar"]="Vacancy Allowance Dollar Amount";
idxTemp2["rets21_vacancyallowpercent"]="Vacancy Allowance Percentage";
idxTemp2["rets21_vowautomatedvaluationdisplay"]="Vow Automated Valuation Display";
idxTemp2["rets21_workerscompensation"]="Workman's Compensation";
idxTemp2["rets21_apn"]="Assessor's Parcel Number";
idxTemp2["rets21_furnitureexpense"]="Furniture Replacement Expense";
idxTemp2["rets21_gardenerexpense"]="Gardener Expense";
idxTemp2["rets21_greenbuildingcertification"]="Green building certification";
idxTemp2["rets21_greencertificationrating"]="Green certification rating";
idxTemp2["rets21_greencertifyingbody"]="Green certifying body";
idxTemp2["rets21_greenenergyefficient"]="Green energy efficient";
idxTemp2["rets21_greenenergygeneration"]="Green energy generation";
idxTemp2["rets21_greenhtaindex"]="Green hta index";
idxTemp2["rets21_greenindoorairquality"]="Green indoor air quality";
idxTemp2["rets21_greenlocation"]="Green location";
idxTemp2["rets21_greensustainability"]="Green sustainability";
idxTemp2["rets21_greenwalkscore"]="Green walkscore";
idxTemp2["rets21_greenwaterconservation"]="Green water conservation";
idxTemp2["rets21_greenyearcertified"]="Green year certified";
idxTemp2["rets21_soldcaprate"]="Sold Cap Rate";
idxTemp2["rets21_insuranceexpense"]="Insurance Expense";
idxTemp2["rets21_assessments"]="Assessments";
idxTemp2["rets21_cdom"]="Cumulative Days On Market";
idxTemp2["rets21_cdomresetyn"]="Cumulative Days On Market reset yn";
idxTemp2["rets21_documentnumber"]="Document number";
idxTemp2["rets21_license1"]="License 1";
idxTemp2["rets21_license2"]="License 2";
idxTemp2["rets21_license3"]="License 3";
idxTemp2["rets21_licensesexpense"]="Licenses";
idxTemp2["rets21_dom"]="Active Days On Market";
idxTemp2["rets21_mobiletoremain"]="Permit For Mobile Home To Remain";
idxTemp2["rets21_specialassessments"]="Special Assessments";
idxTemp2["rets21_trashexpense"]="Trash Expense";
idxTemp2["rets21_listingterms"]="Terms";
		arrayappend(arrR, application.zcore.listingStruct.configCom.getListingDetailRowOutput("Financial &amp; Legal Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		</cfscript>
	</cffunction>
  </cfoutput>
</cfcomponent>