<cfcomponent>
<cfoutput>
	<cfscript>
    variables.idxExclude=structnew();
variables.allfields=structnew();
    </cfscript>
	<cffunction name="findFieldsInDatabaseNotBeingOutput" localmode="modern" output="yes" returntype="any">
    	not implemented - see rets7 for how to implement.
		<cfscript>application.zcore.functions.zabort();</cfscript>
	</cffunction>


    <cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
      <cfargument name="idx" type="struct" required="yes">
      <cfscript>
	  var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["rets4_ceilingheight"]="ceiling height:";
		idxTemp2["rets4_inside"]="inside:";
		idxTemp2["rets4_insidefeatures"]="inside features:";
		idxTemp2["rets4_interiorimprovements"]="interior improvements:";
		idxTemp2["rets4_firstfloor"]="first floor:";
		idxTemp2["rets4_floorcovering"]="floor covering:";
		idxTemp2["rets4_kitchensize"]="kitchen size:";
		idxTemp2["rets4_livingroomsize"]="living room size:";
		idxTemp2["rets4_bedroom1size"]="bedroom 1 size:";
		idxTemp2["rets4_bedroom2size"]="bedroom 2 size:";
		idxTemp2["rets4_bedroom3size"]="bedroom 3 size:";
		idxTemp2["rets4_bedroom4size"]="bedroom 4 size:";
		idxTemp2["rets4_bedroombaths1"]="bedroom baths 1:";
		idxTemp2["rets4_bedroombaths2"]="bedroom baths 2:";
		idxTemp2["rets4_bedroombaths3"]="bedroom baths 3:";
		idxTemp2["rets4_bedroomdesc1"]="bedroom desc 1:";
		idxTemp2["rets4_bedroomdesc2"]="bedroom desc 2:";
		idxTemp2["rets4_bedroomdesc3"]="bedroom desc 3:";
		idxTemp2["rets4_bedroomfurnishings1"]="bedroom furnishings 1:";
		idxTemp2["rets4_bedroomfurnishings2"]="bedroom furnishings 2:";
		idxTemp2["rets4_bedroomfurnishings3"]="bedroom furnishings 3:";
		idxTemp2["rets4_bedroomhalfbaths1"]="bedroom halfbaths 1:";
		idxTemp2["rets4_bedroomhalfbaths2"]="bedroom halfbaths 2:";
		idxTemp2["rets4_bedroomhalfbaths3"]="bedroom halfbaths 3:";
		idxTemp2["rets4_bedroomrent1"]="bedroom rent 1:";
		idxTemp2["rets4_bedroomrent2"]="bedroom rent 2:";
		idxTemp2["rets4_bedroomrent3"]="bedroom rent 3:";
		idxTemp2["rets4_bedroomrooms1"]="bedroom rooms 1:";
		idxTemp2["rets4_bedroomrooms2"]="bedroom rooms 2:";
		idxTemp2["rets4_bedroomrooms3"]="bedroom rooms 3:";
		idxTemp2["rets4_bedroomunits1"]="bedroom units 1:";
		idxTemp2["rets4_bedroomunits2"]="bedroom units 2:";
		idxTemp2["rets4_bedroomunits3"]="bedroom units 3:";
		idxTemp2["rets4_diningroomsize"]="dining room size:";
		idxTemp2["rets4_docksize"]="dock size:";
		idxTemp2["rets4_efficiencybaths"]="efficiency baths:";
		idxTemp2["rets4_efficiencydesc"]="efficiency desc:";
		idxTemp2["rets4_efficiencyfurnishings"]="efficiency furnishings:";
		idxTemp2["rets4_efficiencyhalfbaths"]="efficiency halfbaths:";
		idxTemp2["rets4_efficiencyrentals"]="efficiency rentals:";
		idxTemp2["rets4_efficiencyrooms"]="efficiency rooms:";
		idxTemp2["rets4_efficiencyunits"]="efficiency units:";
		idxTemp2["rets4_familyroomsize"]="family room size:";
		idxTemp2["rets4_patiosize"]="patio size:";
		idxTemp2["rets4_porch"]="porch:";
		idxTemp2["rets4_porchsize"]="porch size:";
		idxTemp2["rets4_rooms"]="rooms:";
		idxTemp2["rets4_unitnumber"]="unit number:";
		idxTemp2["rets4_units"]="units:";
		idxTemp2["rets4_totalunits"]="total units:";

		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Unit &amp; Room Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		idxTemp2=structnew();
		idxTemp2["rets4_apxbuildingsqft"]="apx building sqft:";
		idxTemp2["rets4_efficiencysqft"]="efficiency sqft:";
		idxTemp2["rets4_lotdepth"]="lot depth:";
		idxTemp2["rets4_lotsize"]="lot size:";
		idxTemp2["rets4_otherroom1size"]="other room 1 size:";
		idxTemp2["rets4_sqft1bedroomunit"]="sqft 1 bedroom unit:";
		idxTemp2["rets4_sqft2bedroomunit"]="sqft 2 bedroom unit:";
		idxTemp2["rets4_sqft3bedroomunit"]="sqft 3 bedroom unit:";
		idxTemp2["rets4_sqftlivingarea"]="sqft living area:";
		idxTemp2["rets4_sqftlivingareamlt"]="sqft living area mlt:";
		idxTemp2["rets4_sqftlot"]="sqft lot:";
		idxTemp2["rets4_sqfttotal"]="sqft total:";


		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("SQFT &amp; Dimensions", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));

		
		return arraytolist(arrR,'');
		
		</cfscript>
	</cffunction>
	<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["rets4_unit1parkingspaces"]="unit 1 parking spaces:";
		idxTemp2["rets4_unit2parkingspaces"]="unit 2 parking spaces:";
		idxTemp2["rets4_unit3parkingspaces"]="unit 3 parking spaces:";
		idxTemp2["rets4_unit4parkingspaces"]="unit 4 parking spaces:";
		//idxTemp2["rets4_garage"]="garage:";
		idxTemp2["rets4_parking"]="parking:";
		idxTemp2["rets4_parkingspaces"]="parking spaces:";
		idxTemp2["rets4_parkingspaceyn"]="parking space:";


		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Parking Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		idxTemp2=structnew();
		idxTemp2["rets4_annualnoi"]="annual noi:";
		idxTemp2["rets4_annualrent"]="annual rent:";
		idxTemp2["rets4_otherincome"]="other income:";
		idxTemp2["rets4_grossincome"]="gross income:";
		idxTemp2["rets4_currentoccupancyrate"]="current occupancy rate:";
		idxTemp2["rets4_dateleased"]="date leased:";
		idxTemp2["rets4_existingzoning"]="existing zoning:";
		idxTemp2["rets4_governingbody"]="governing body:";
		idxTemp2["rets4_homesteadexemptionyn"]="homestead exemptionyn:";
		idxTemp2["rets4_parcelnumber"]="parcel number:";
		idxTemp2["rets4_saleorlease"]="sale or lease:";
		idxTemp2["rets4_financialpackageyn"]="financial package:";
		idxTemp2["rets4_financing"]="financing:";
		idxTemp2["rets4_financingtype"]="financing type:";
		idxTemp2["rets4_monthlyleasepayment"]="monthly lease payment:";
		idxTemp2["rets4_mortgagedownpayment"]="mortgage down payment:";
		idxTemp2["rets4_leaseoptionpresent"]="lease option present:";
		idxTemp2["rets4_leaseprovisions"]="lease provisions:";
		idxTemp2["rets4_leasetype"]="lease type:";
		idxTemp2["rets4_includedinlease"]="included in lease:";
		idxTemp2["rets4_includeinsale"]="include in sale:";
		idxTemp2["rets4_ownerpays"]="owner pays:";
		idxTemp2["rets4_tenantpays"]="tenant pays:";
		idxTemp2["rets4_subordinateyn"]="subordinate:";


		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Financing &amp; Sale Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		return arraytolist(arrR,'');

		
		
		</cfscript>
    </cffunction>
    <cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["rets4_sewer"]="sewer:";
		idxTemp2["rets4_sewertype"]="sewer type:";
		idxTemp2["rets4_utilitiesatsite"]="utilities at site:";
		idxTemp2["rets4_utilitiesavail"]="utilities avail:";
		idxTemp2["rets4_utilitiesonsite"]="utilities on site:";
		idxTemp2["rets4_utilityroomsize"]="utility room size:";
		idxTemp2["rets4_wastepumpyn"]="waste pump:";
		idxTemp2["rets4_water"]="water:";
		idxTemp2["rets4_watercompany"]="water company:";
		idxTemp2["rets4_gasmeters"]="gas meters:";
		idxTemp2["rets4_electricitymeters"]="electricity meters:";
		idxTemp2["rets4_watermeters"]="water meters:";



		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Utilities Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));

		idxTemp2=structnew();
		idxTemp2["rets4_petsyn"]="pets allowed:";
		idxTemp2["rets4_terms"]="terms:";
		idxTemp2["rets4_asisconditionyn"]="as is condition:";
		idxTemp2["rets4_assessmentsyn"]="assessments:";
		idxTemp2["rets4_cansubdivideyn"]="can subdivide:";
		idxTemp2["rets4_conformingyn"]="conforming:";
		idxTemp2["rets4_disputeresolutionyn"]="dispute resolution:";
		idxTemp2["rets4_documents"]="documents:";
		idxTemp2["rets4_easements"]="easements:";
		idxTemp2["rets4_possibleuse"]="possible use:";
		idxTemp2["rets4_multaccyn"]="multacc:";
		idxTemp2["rets4_findersfee"]="finders fee:";
		idxTemp2["rets4_ownership"]="ownership:";
		idxTemp2["rets4_ownershipinfo"]="ownership info:";
		idxTemp2["rets4_parcel1"]="parcel 1:";
		idxTemp2["rets4_recordedplatyn"]="recorded plat:";
		idxTemp2["rets4_restrictionsdesc"]="restrictions desc:";
		idxTemp2["rets4_restrictionsovernight"]="restrictions overnight:";
		idxTemp2["rets4_restrictionsyn"]="restrictions:";
		idxTemp2["rets4_soilreportyn"]="soil report:";
		idxTemp2["rets4_specialcontingencyyn"]="special contingency:";
		idxTemp2["rets4_surveyyn"]="survey:";
		idxTemp2["rets4_zoning"]="zoning:";
		idxTemp2["rets4_zoningcompliesyn"]="zoning complies:";
		idxTemp2["rets4_legaldesc"]="legal desc:";
		idxTemp2["rets4_directions"]="directions:";
		idxTemp2["rets4_maintfeecovers"]="Maintenance Fee Covers:";


		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Legal &amp; Zoning Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));

		return arraytolist(arrR,'');
		
		
		
		</cfscript>
	</cffunction>
</cfoutput>
</cfcomponent>