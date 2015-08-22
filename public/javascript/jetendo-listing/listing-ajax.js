
(function($, window, document, undefined){
"use strict";
function zLoadListingSavedSearches(){
	var arrMap=[];
	$(".zls-listingSavedSearchMapSummaryDiv").each(function(){
		var ssid=$(this).attr("data-ssid");
		if(ssid == ""){
			return;
		}
		arrMap[ssid]=this;
	});

	$(".zls-listingSavedSearchDiv").each(function(){
		var currentDiv=this;
		var ssid=$(this).attr("data-ssid");
		if(ssid == ""){
			return;
		}
		var tempObj={};
		tempObj.id="zListingSavedSearchAjax"+ssid;
		tempObj.cache=false;
		tempObj.method="get"; 
		tempObj.callback=function(d){  
			console.log(ssid+":"+currentDiv);
			try{
				var r=eval("("+d+")");
				if(r.success){ 
					$(currentDiv).html(r.listingOutput);
					if(ssid in arrMap){
						$(".contentPropertySummaryDiv", arrMap[ssid]).html(r.mapSummaryOutput);
						$(".mapContentDiv", arrMap[ssid]).html('<iframe id="embeddedmapiframe" src="/z/listing/map-embedded/index?ssid='+ssid+'" width="100%" height="340" style="border:none; overflow:auto;" seamless="seamless"></iframe>');
					}
					zlsEnableImageEnlarger();
					zLoadAndCropImages();
				}else{
					$(currentDiv).html("Listings not available at this time. Please try again later. Error Code ##1");
				}
			}catch(e){
				$(currentDiv).html("Listings not available at this time. Please try again later. Error Code ##2");
				throw e;
				return;
			} 
		};

		tempObj.errorCallback=function(d){
			$(currentDiv).html("Listings not available at this time. Please try again later.");
		};
		tempObj.ignoreOldRequests=false;
		tempObj.url="/z/listing/ajax-listing/index?ssid="+ssid; 
		if(ssid in arrMap){
			tempObj.url+="&getMapSummary=1";
		}
		zAjax(tempObj); 
	});
}
zArrLoadFunctions.push({functionName:zLoadListingSavedSearches});


})(jQuery, window, document, "undefined"); 