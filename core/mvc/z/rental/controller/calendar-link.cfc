<cfcomponent><!--- <cfoutput>
<cfscript>
arrAmen=arraynew(1);
if(rental_pool EQ 1){
	arrayappend(arrAmen,'&middot; Pool');	
}
if(rental_mountainview EQ 1){
	arrayappend(arrAmen,'&middot; Mountain View');	
}
if(rental_waterview EQ 1){
	arrayappend(arrAmen,'&middot; Water View');	
}
if(rental_gameroom EQ 1){
	arrayappend(arrAmen,'&middot; Game Room');	
}
if(rental_cabletv EQ 1){
	arrayappend(arrAmen,'&middot; Satellite/Cable TV');	
}
if(rental_highspeedinternet EQ 1){
	arrayappend(arrAmen,'&middot; High Speed Internet');	
}
if(rental_fireplace EQ 1){
	arrayappend(arrAmen,'&middot; Fireplace');	
}
if(rental_petfriendly EQ 1){
	arrayappend(arrAmen,'&middot; Pet Friendly');	
}
if(rental_oceanview EQ 1){
	arrayappend(arrAmen,'&middot; Ocean View');	
}
if(rental_riverview EQ 1){
	arrayappend(arrAmen,'&middot; River View');	
}
db.sql="select * from #db.table("rental_x_amenity", request.zos.zcoreDatasource)# rental_x_amenity, 
#db.table("rental_amenity", request.zos.zcoreDatasource)# rental_amenity 
where rental_x_amenity.site_id = rental_amenity.site_id and 
rental_amenity.rental_amenity_id = rental_x_amenity.rental_amenity_id and 
rental_x_amenity.site_id = #db.param(request.zos.globals.id)# and 
rental_id = #db.param(rental_id)# and 
rental_amenity_deleted = #db.param(0)# and 
rental_x_amenity_deleted = #db.param(0)#";
qXAmenity=db.execute("qXAmenity");
</cfscript>
<cfloop query="qXAmenity"><cfscript>
	arrayappend(arrAmen,'&middot; '&rental_amenity_name);	</cfscript></cfloop>
    <cfscript>
	arraysort(arrAmen, "text","asc");
	</cfscript>
<cfif rental_amenities_text NEQ "" or arraylen(arrAmen) NEQ 0>
<a id="zrental-amenities"></a>
<div class="zrental-box">
<div class="zrental-subtitle"><div style="width:300px; text-align:right; float:right;"><a href="/Compare-Rental-Amenities-#application.zcore.app.getAppData("rental").optionstruct.rental_config_misc_url_id#-2.html" style="font-size:14px; font-weight:bold;">Click here to compare all rentals</a></div><h2 style="margin:0px; padding:0px;">Featured Amenities</h2></div>
<div class="zrental-box-inner">
<cfif rental_amenities_text NEQ "">#rental_amenities_text#</cfif>
<table style="width:100%; border-spacing:5px;">
	<cfscript>	
	inputStruct = StructNew();
	inputStruct.colspan = 3;
	inputStruct.rowspan = arraylen(arramen);
	inputStruct.vertical = true;
	myColumnOutput = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.loopOutput");
	myColumnOutput.init(inputStruct);
	
for(i=1;i LTE arraylen(ArrAmen);i++){
	writeoutput(myColumnOutput.check(i));
	writeoutput(arrAmen[i]&'<br />');
	writeoutput(myColumnOutput.ifLastRow(i));
}
</cfscript>
</table><br />
</div>
</div><br style="clear:both;" />
</cfif>
</cfoutput> --->
</cfcomponent>