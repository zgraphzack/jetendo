<cfcomponent>
<cfoutput>
	<cfscript>
    variables.idxExclude=structnew();
variables.allfields=structnew();
    </cfscript>
	<cffunction name="findFieldsInDatabaseNotBeingOutput" localmode="modern" output="yes" returntype="any">
		<cfscript>
		var db=request.zos.queryObject;
		</cfscript>
    	not implemented - see rets7 for how to implement.<cfscript>application.zcore.functions.zabort();</cfscript>
	</cffunction>

    <cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
      <cfargument name="idx" type="struct" required="yes">
      <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["rets11_accessorybuildings"]="Accessory Buildings:";
		idxTemp2["rets11_acpercent"]="A/C %:";
		idxTemp2["rets11_additionalrooms"]="Additional Rooms:";
		//idxTemp2["rets11_addlmarketingremarks"]="Additional Marketing Remarks:";
		idxTemp2["rets11_adjoiningproperty"]="Adjoining Property:";
		//idxTemp2["rets11_agentstatus"]="AgentStatus:";
		//idxTemp2["rets11_animalspermitted"]="Pets Y/N:";
		idxTemp2["rets11_area"]="Acres - Total:";
		idxTemp2["rets11_areazonesort"]="Area / Zone Sort:";
		idxTemp2["rets11_arial"]="Aerial:";
		//idxTemp2["rets11_bathshalf"]="Half-Baths:";
		//idxTemp2["rets11_bathstotal"]="Baths:";
		//idxTemp2["rets11_bedrooms"]="Bedrooms:";
		//idxTemp2["rets11_bonus"]="Bonus:";
		//idxTemp2["rets11_bonusremarks"]="Bonus Remarks:";
		idxTemp2["rets11_bookaddendum"]="Book Addendum:";
		idxTemp2["rets11_buildingconstruction"]="Building Construction:";
		idxTemp2["rets11_buildingstotal"]="Buildings Total:";
		idxTemp2["rets11_businessdesc"]="Business Description:";
		idxTemp2["rets11_cable"]="Cable:";
		idxTemp2["rets11_carport"]="Carport Spaces:";
		//idxTemp2["rets11_city"]="Address City:";
		idxTemp2["rets11_clearedyn"]="Cleared Y/N:";
		/*idxTemp2["rets11_colistagent2id"]="Co-List Agent 2 ID:";
		idxTemp2["rets11_colistagentboard"]="Co-List Agent Board:";
		idxTemp2["rets11_colistagentfirmid"]="Co-List Agent Firm ID:";
		idxTemp2["rets11_colistagentid"]="Co-List Agent ID:";
		idxTemp2["rets11_colistagentoffice"]="Co-List Agent Office:";
		*/
		idxTemp2["rets11_commercialpropertytype"]="Commercial Property Type:";
		idxTemp2["rets11_community55yn"]="55+ Community Y/N:";
		idxTemp2["rets11_communityamenities"]="Community Amenities:";
		//idxTemp2["rets11_communityamenties"]="Community Amenties:";
		idxTemp2["rets11_condominium"]="Condo Y/N:";
		idxTemp2["rets11_condounitnumber"]="Condo Unit Number:";
		idxTemp2["rets11_construction"]="Construction:";
		idxTemp2["rets11_contact"]="Contact 1:";
		idxTemp2["rets11_corpowned"]="Corp Owned:";
		//idxTemp2["rets11_county"]="Address County:";
		idxTemp2["rets11_currentadjacentuse"]="Current Adjacent Use:";
		idxTemp2["rets11_currentuse"]="CurrentUse:";
		/*idxTemp2["rets11_dateavailable"]="Date Available:";
		idxTemp2["rets11_datechange"]="Date Change:";
		idxTemp2["rets11_datenewlisting"]="Date New Listing:";
		idxTemp2["rets11_datephoto"]="Date Photo:";
		*/
		idxTemp2["rets11_daysonmarket"]="Days on Market:";
		idxTemp2["rets11_directions"]="Directions:";
		//idxTemp2["rets11_displayaddresslisting"]="Display Address Listing:";
		//idxTemp2["rets11_displayflaglisting"]="Property on Internet Y/N:";
		idxTemp2["rets11_dwellingstyle"]="Dwelling Style:";
		idxTemp2["rets11_dwellingview"]="Dwelling View:";
		idxTemp2["rets11_eavesheight"]="Eaves Height:";
		idxTemp2["rets11_efficiencyrent"]="Efficiency Rent:";
		idxTemp2["rets11_efficiencyunits"]="Efficiency Units:";
		idxTemp2["rets11_electricservice"]="Electric Service:";
		idxTemp2["rets11_empowermentzone"]="Empowerment Zone:";
		idxTemp2["rets11_equipmentandappliances"]="Equipment And Appliances:";
		idxTemp2["rets11_equitableinterestyn"]="Equitable Interest Y/N:";
		idxTemp2["rets11_exteriorfeatures"]="Exterior Features:";
		idxTemp2["rets11_exteriorfinish"]="Exterior Finish:";
		idxTemp2["rets11_exteriorsignage"]="Exterior Signage:";
		//idxTemp2["rets11_floridatodayyn"]="Florida Today Y/N:";
		idxTemp2["rets11_frontagedescription"]="Frontage Description:";
		idxTemp2["rets11_furnishingstostay"]="Furnishings to Stay:";
		idxTemp2["rets11_garage"]="Garage Spaces:";
		idxTemp2["rets11_gates"]="Gates:";
		idxTemp2["rets11_heatingandcooling"]="Heating And Cooling:";
		idxTemp2["rets11_hotwater"]="Hot Water:";
		idxTemp2["rets11_howsolddesc"]="How Sold Description:";
		//idxTemp2["rets11_idx"]="IDX Y/N:";
		//idxTemp2["rets11_idxcontactname"]="IDX Contact Name:";
		//idxTemp2["rets11_idxcontactphone"]="IDX Contact Phone:";
		//idxTemp2["rets11_idxcontacttype"]="IDX Contact Type:";
		idxTemp2["rets11_interiorfeatures"]="Interior Features:";
		idxTemp2["rets11_interiorimprovements"]="Interior Improvements:";
		idxTemp2["rets11_landdescription"]="Land Description:";
		//idxTemp2["rets11_listdate"]="Date Listed:";
		//idxTemp2["rets11_listingagentid"]="Listing Agent ID:";
		//idxTemp2["rets11_listingagentname"]="Listing Agent Name:";
		//idxTemp2["rets11_listingagentuid"]="Listing Agent UID:";
		//idxTemp2["rets11_listingarea"]="Area / Zone Code:";
		//idxTemp2["rets11_listingboard"]="Listing Board:";
		//idxTemp2["rets11_listingfirmid"]="Listing Firm ID:";
		//idxTemp2["rets11_listingid"]="MLS Number:";
		//idxTemp2["rets11_listingofficeid"]="Listing Office:";
		//idxTemp2["rets11_listingofficeuid"]="Listing Office UID:";
		//idxTemp2["rets11_listingstatus"]="ListingStatus:";
		//idxTemp2["rets11_listingtype"]="Listing Type:";
		//idxTemp2["rets11_listprice"]="List Price:";
		idxTemp2["rets11_loadingdock"]="Loading Dock:";
		idxTemp2["rets11_lotfaces"]="Lot Faces:";
		idxTemp2["rets11_lots"]="Lots:";
		idxTemp2["rets11_lotsizelength"]="Lot Length:";
		idxTemp2["rets11_lotsizewidth"]="Lot Width:";
		idxTemp2["rets11_lotsqft"]="Lot SqFt:";
		//idxTemp2["rets11_mapcoordinate"]="Map Coordinates:";
		idxTemp2["rets11_masterbath"]="MasterBath:";
		//idxTemp2["rets11_mlsnumberoriginal"]="MLS Number Original:";
		//idxTemp2["rets11_modificationtimestamp"]="Date Recap:";
		//idxTemp2["rets11_officeidx"]="OfficeIDX:";
		idxTemp2["rets11_officesqft"]="Office SqFt:";
		//idxTemp2["rets11_officestatus"]="Office Status:";
		idxTemp2["rets11_onebedroomrent"]="1 Bedroom Rent:";
		idxTemp2["rets11_onebedroomunits"]="1 Bedroom Units:";
		//idxTemp2["rets11_originallistingfirmname"]="Original Listing Firm Name:";
		idxTemp2["rets11_originallistprice"]="Original Price:";
		//idxTemp2["rets11_originalsellingfirmname"]="Original Selling Firm Name:";
		idxTemp2["rets11_overheaddoorheight"]="Overhead Door Height:";
		idxTemp2["rets11_ownerbankcorporationyn"]="Bank Owned:";
		//idxTemp2["rets11_ownername"]="Owner Name:";
		idxTemp2["rets11_parking"]="Parking:";
		idxTemp2["rets11_petfeeamount"]="Pet Fee Amount:";
		idxTemp2["rets11_pets"]="Pets:";
		//idxTemp2["rets11_photoadded"]="Photo Added:";
		//idxTemp2["rets11_photocode"]="Photo Code:";
		//idxTemp2["rets11_photocount"]="Photo Count:";
		idxTemp2["rets11_platbook"]="Plat Book:";
		idxTemp2["rets11_platbookpage"]="Plat Book Page:";
		idxTemp2["rets11_pooldescription"]="Pool Description:";
		idxTemp2["rets11_poolpresent"]="Pool Y/N:";
		idxTemp2["rets11_possession"]="Possession:";
		idxTemp2["rets11_possessiondesc"]="Possession Description:";
		//idxTemp2["rets11_postalcode"]="Address Zip Code:";
		idxTemp2["rets11_previouslistprice"]="Previous List Price:";
		idxTemp2["rets11_pricechangeyn"]="Price Change Y/N:";
		idxTemp2["rets11_propertyformat"]="Property Format:";
		//idxTemp2["rets11_propertystyle"]="Property Style:";
		//idxTemp2["rets11_propertytype"]="Property Type:";
		idxTemp2["rets11_propertyuse"]="PropertyUse:";
		//idxTemp2["rets11_publicremarks"]="Public Remarks:";
		idxTemp2["rets11_pudyn"]="PUD Y/N:";
		idxTemp2["rets11_rentalpropertytype"]="Rental Property Type:";
		idxTemp2["rets11_rentincludes"]="RentIncludes:";
		idxTemp2["rets11_residentialpropertytype"]="Residential Property Type:";
		idxTemp2["rets11_restrictions"]="Restrictions:";
		idxTemp2["rets11_roadfrontagedepth"]="Road Frontage Depth:";
		idxTemp2["rets11_roadsurface"]="RoadSurface:";
		idxTemp2["rets11_roof"]="Roof:";
		//idxTemp2["rets11_secondownername"]="Second Owner Name:";
		idxTemp2["rets11_securitysystem"]="SecuritySystem:";
		idxTemp2["rets11_servicesnotprovided"]="ServicesNotProvided:";
		idxTemp2["rets11_shortsaleyn"]="Short Sale Y/N:";
		//idxTemp2["rets11_showing"]="Showing:";
		//idxTemp2["rets11_showinginstructions"]="Showing Instructions:";
		idxTemp2["rets11_sitedescription"]="SiteDescription:";
		idxTemp2["rets11_siteimprovements"]="SiteImprovements:";
		idxTemp2["rets11_sitelocation"]="SiteLocation:";
		idxTemp2["rets11_slabthickness"]="Slab Thickness:";
		idxTemp2["rets11_smokingyn"]="Smoking Y/N:";
		idxTemp2["rets11_source"]="Source:";
		idxTemp2["rets11_sourceofmeasurement"]="Source of Measurement:";
		idxTemp2["rets11_splityn"]="Split Y/N:";
		idxTemp2["rets11_sqftlivingarea"]="SqFt Living Area:";
		idxTemp2["rets11_sqfttotal"]="SqFt Total:";
		//idxTemp2["rets11_stateorprovince"]="Address State:";
		//idxTemp2["rets11_statusactualnumber"]="Status Actual Number:";
		//idxTemp2["rets11_streetdirsuffix"]="Address Street Direction:";
		//idxTemp2["rets11_streetname"]="Address Street Name:";
		//idxTemp2["rets11_streetnumber"]="Address Street Number:";
		//idxTemp2["rets11_streetsuffix"]="Address Street Suffix:";
		idxTemp2["rets11_style"]="Style:";
		//idxTemp2["rets11_subagentcomm"]="Sub Agent Comm:";
		//idxTemp2["rets11_subdivision"]="Address Subdivision Name:";
		//idxTemp2["rets11_temporarilyoffmarketyn"]="Temporarily Off Market Y/N:";
		idxTemp2["rets11_threebathrent"]="3 Bath Rent Range:";
		idxTemp2["rets11_threebathunits"]="3 Bath Units:";
		idxTemp2["rets11_threebedroomrent"]="3 Bedroom Rent Range:";
		idxTemp2["rets11_threebedroomunits"]="3 Bedroom Units:";
		idxTemp2["rets11_totalparking"]="## Parking Spaces:";
		idxTemp2["rets11_totalunits"]="Units:";
		idxTemp2["rets11_trafficcount"]="TrafficCount:";
		idxTemp2["rets11_transbrokercommamount"]="Transaction Broker Commission Am:";
		idxTemp2["rets11_transportationaccess"]="TransportationAccess:";
		idxTemp2["rets11_twobathrent"]="2 Bath Rent Range:";
		idxTemp2["rets11_twobathunits"]="2 Bath Units:";
		idxTemp2["rets11_twobedroomrent"]="2 Bedroom Rent Range:";
		idxTemp2["rets11_twobedroomunits"]="2 Bedroom Units:";
		idxTemp2["rets11_unitlot"]="Unit / Lot:";
		idxTemp2["rets11_unitnumber"]="Address Unit Number:";
		idxTemp2["rets11_utilities"]="Utilities:";
		idxTemp2["rets11_utilitiesandfuel"]="UtilitiesAndFuel:";
		idxTemp2["rets11_variableratecommyn"]="Variable Rate Commission Y/N:";
		//idxTemp2["rets11_virtualtour2url"]="Virtual Tour URL:";
		//idxTemp2["rets11_virtualtoururl"]="Virtual Tour URL:";
		//idxTemp2["rets11_virtualtouryn"]="Virtual Tour Y/N:";
		idxTemp2["rets11_waterdescription"]="WaterDescription:";
		idxTemp2["rets11_waterfrontage"]="Water Frontage:";
		idxTemp2["rets11_waterfrontagedesc"]="Water Frontage Description:";
		idxTemp2["rets11_waterfrontpresent"]="Water Frontage Y/N:";
		//idxTemp2["rets11_yearbuilt"]="Year Built:";
		idxTemp2["rets11_zoning"]="Zoning:";
		

		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Property Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));

		return arraytolist(arrR,'');
		
		</cfscript>
	</cffunction>
	<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		
		idxTemp2["rets11_bedroommasterlength"]="Master Bedroom Size:";
		idxTemp2["rets11_bedroom2length"]="Bedroom 2 Size:";
		idxTemp2["rets11_bedroom3length"]="Bedroom 3 Size:";
		idxTemp2["rets11_bedroom4length"]="Bedroom 4 Size:";
		idxTemp2["rets11_diningroomlength"]="Dining Room Size:";
		idxTemp2["rets11_familyroomlength"]="Family Room Size:";
		idxTemp2["rets11_livingroomlength"]="Living Room Size:";
		idxTemp2["rets11_kitchenlength"]="Kitchen Size:";
		idxTemp2["rets11_otherroomlength"]="Other Room Size:";
		idxTemp2["rets11_ceilingheight"]="Ceiling Height:";
		idxTemp2["rets11_ceilingheights"]="Ceiling Heights:";
		idxTemp2["rets11_ceilingtype"]="CeilingType:";
		idxTemp2["rets11_door1width"]="Door 1 Width:";
		idxTemp2["rets11_doorfaces"]="Door Faces:";
		idxTemp2["rets11_poolsize"]="Pool Size:";
		idxTemp2["rets11_porchsize"]="Porch Size:";
		idxTemp2["rets11_fireplacesyn"]="Fireplaces Y/N:";
		idxTemp2["rets11_floor"]="Floor:";
		idxTemp2["rets11_patiosize"]="Patio Size:";
		idxTemp2["rets11_floornumber"]="Floor Number:";
		idxTemp2["rets11_floors"]="Floors:";
		idxTemp2["rets11_grossincome"]="Gross Income:";
		idxTemp2["rets11_hoadues"]="HOA Dues:";
		idxTemp2["rets11_hoayn"]="HOA Y/N:";
		idxTemp2["rets11_homeownersassocyn"]="Home Owners Association Y/N:";
		idxTemp2["rets11_homesteadyn"]="Homestead Y/N:";
		idxTemp2["rets11_homewarrantyyn"]="Home Warranty Y/N:";

		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Room Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		
		
		</cfscript>
    </cffunction>
    <cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["rets11_addlfeeincludes"]="Additional Fee Includes:";
		idxTemp2["rets11_applicationfeeamount"]="Application Fee Amount:";
		idxTemp2["rets11_assessmentdesc"]="Assessment Description:";
		idxTemp2["rets11_assocapprovalrequiredyn"]="Association Approval Required Y/N:";
		idxTemp2["rets11_assocfeeamount"]="Association Fee Amount:";
		idxTemp2["rets11_assocfeeincludes"]="AssocFeeIncludes:";
		idxTemp2["rets11_associationfee"]="Association Fee:";
		idxTemp2["rets11_associationfeeperiod"]="HOA Dues Paid M/A:";
		idxTemp2["rets11_assumableloanyn"]="Assumable Loan Y/N:";
		idxTemp2["rets11_taxamount"]="Tax Amount:";
		idxTemp2["rets11_taxid"]="Tax ID:";
		idxTemp2["rets11_taxid1"]="Tax ID 1:";
		idxTemp2["rets11_taxpersqft"]="Tax Per SqFt:";
		idxTemp2["rets11_taxrange"]="Tax Range:";
		idxTemp2["rets11_taxsectioncode"]="Tax Section Code:";
		idxTemp2["rets11_taxyear"]="Tax Year:";
		idxTemp2["rets11_locationdescription"]="Location Description:";
		
		idxTemp2["rets11_leaseprice"]="Lease Price:";
		idxTemp2["rets11_leaseterms"]="LeaseTerms:";
		idxTemp2["rets11_leasetype"]="Lease Type:";
		idxTemp2["rets11_legaldescription"]="Legal Description:";
		idxTemp2["rets11_management"]="Management:";
		idxTemp2["rets11_netincome"]="Net Income:";
		idxTemp2["rets11_otherincome"]="Other Income:";
		idxTemp2["rets11_owneroccupiedyn"]="Owner Occupied Y/N:";
		idxTemp2["rets11_ownerwillconsider"]="Owner Will Consider:";
		idxTemp2["rets11_nonrep"]="Non-Representative:";
		idxTemp2["rets11_occupancy"]="Occupancy:";
		idxTemp2["rets11_salelease"]="Sale / Lease:";
		idxTemp2["rets11_saleoption"]="Sale Option:";
		idxTemp2["rets11_securityandsafety"]="SecurityAndSafety:";
		idxTemp2["rets11_securitydepositamount"]="Security Deposit Amount:";
		idxTemp2["rets11_deedrestrictions"]="Deed Restrictions:";
		idxTemp2["rets11_docsonfile"]="DocsOnFile:";
		idxTemp2["rets11_financing"]="Financing:";
		idxTemp2["rets11_expenses"]="Operating Expenses:";
		idxTemp2["rets11_expensesinclude"]="Expenses Include:";

		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Financial &amp; Legal Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>