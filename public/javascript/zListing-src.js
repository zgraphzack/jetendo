var zlsSearchCriteriaMap={
search_bathrooms_low:"a",
search_bathrooms_high:"b",
search_bedrooms_low:"c",
search_bedrooms_high:"d",
search_city_id:"e",
search_exact_match:"f",
search_map_coordinates_list:"g",
search_listing_type_id:"h",
search_listing_sub_type_id:"i",
search_condoname:"j",  
search_address:"k",  
search_zip:"l",  
search_rate_low:"m",  
search_rate_high:"n",  
search_sqfoot_high:"o",
search_result_limit:"p",
search_agent_always:"q",
search_sort_agent_first:"r",
search_office_always:"s",
search_sort_office_first:"t",
search_sqfoot_low:"u",
search_year_built_low:"v",
search_year_built_high:"w",
search_county:"x",
search_frontage:"y",
search_view:"z",
search_remarks:"aa",
search_style:"bb",
search_mls_number_list:"cc",
search_sort:"dd",
search_listdate:"ee",
search_near_address:"ff",
search_near_radius:"gg",
//search_sortppsqft:"",
//search_new_first:"",
search_remarks_negative:"hh",
//search_mls_number_list:"ii",
search_acreage_low:"jj",
search_acreage_high:"kk",
search_status:"ll",
search_surrounding_cities:'mm',
search_within_map:"nn",
search_with_photos:"oo",  
search_with_pool:"pp",   
search_agent_only:"qq",
search_office_only:"rr",
search_agent:"ss",
search_office:"tt",
search_subdivision:"uu",
search_result_layout:"vv",
//search_result_limit:"ww",
search_group_by:"xx",
search_region:"yy",
search_parking:"zz",
search_condition:"a1",
search_tenure:"b1",
search_liststatus:"c1"
};

var zSearchFormTimeoutId=0;
var zSearchFormCountTimeoutId=0;
var zSearchFormFloaterAbsoluteFix=false;
var zSearchFormFloaterDisplayed=false;
function updateCountPosition(e,r2){
	zScrollPosition.left = (document.all ? document.scrollLeft : window.pageXOffset);
	zScrollPosition.top = (document.all ? document.scrollTop : window.pageYOffset);
	
	r111=zModalLockPosition(e);
	if(1===0 && typeof r2 === "undefined"){
		clearTimeout(zSearchFormTimeoutId);
		zSearchFormTimeoutId=setTimeout("updateCountPosition(null,true);",300);	
		return;
	}
	var r9=document.getElementById("resultCountAbsolute");
	var r95=document.getElementById("searchFormTopDiv"); 
	if(r95===null || r9 === null) return; 
	var p2=zFindPosition(r95);
	var scrollP=$(window).scrollTop();
	scrollP=Math.max(scrollP,p2[1]);
	zSearchFormFloaterDisplayed=true;
		r9.style.top=(scrollP-zPositionObjSubtractPos[1])+"px";
		var r10=getWindowSize();
		r9.style.left=(p2[0]-zPositionObjSubtractPos[0])+'px';
	clearTimeout(zSearchFormTimeoutId);
	
	zSearchFormChanged=false;
	clearTimeout(zSearchFormCountTimeoutId);
	zSearchFormCountTimeoutId=setTimeout(updateCountPosition, 300);
	if(r111===false){
		return false;
	}else{
		return true;
	}
}
var GMap=false;
if(typeof zMLSSearchFormName==="undefined"){
	zMLSSearchFormName="zMLSSearchForm";
}
var pixelXLongOffset=0;
var pixelYLatOffset=0;
var mapLoadFunction=function(){};
var mapObj=false;
var mapProps=new Object();
//var arrMarkers=new Array();
var streetView=false;
var mapFullscreen=false;
var zGMapAbsPos=null;
var zHideMapControl=false;
var zOneLatitude=false;
var zOneLongitude=false;
var zMapOverlayDivObj=null;
var zMapOverlayDivObjAbsPos=null;
var zMapOverlayDivObjAbsPos2=null;
var zMapIgnoreMoveEnd=false;
var zMapCurrentListingLink=null;
//var mapProps.zArrMapTotalLat=[];
//var mapProps.zArrMapTotalLong=[];
//var mapProps.zArrMapText=[];
//var mapProps.mapCount=0;
var zBingAddress="";
function createMarker(point, htmlText) {
	var marker = new GMarker(point);
	google.maps.event.addListener(marker, "click", function() {
	  marker.openInfoWindowHtml(htmlText);
	});
	//arrMarkers.push(marker);
	
	return marker;
}
function zlsOpenResultsMap(formName){
	if(typeof formName == "undefined"){
		formName="zMLSSearchForm";
	}
	var arrQ=[];
	var d3=document.getElementById("resultCountAbsolute");
	if(d3 && d3.innerHTML.substr(0,1) === 0){
		alert('There are no matching listings, please revise your search before clicking to view the map');
		return;	
	}
	var obj=zFormSubmit(formName, false, true,false, true);
	for(var i in obj){
		if(typeof zlsSearchCriteriaMap[i] !== "undefined" && obj[i] !== ""){
			arrQ.push(zlsSearchCriteriaMap[i]+"="+obj[i]);
		}
	}
	//zlsSearchCriteriaMap[i];
	var d1=arrQ.join("&");
	if(d1.length >= 1950){
		alert("You've selected too many criteria. Please reduce the number of selections for the most accurate search results.");
	}
	var newLink="/z/listing/map-fullscreen/index?"+d1.substr(0,1950);
	//console.log(newLink);
	window.open(newLink);
}
var zMapFirstZoomChange=true;
var widthPerPixel=0.000011257672119140625;
var heightPerPixel=0.000010531174841353967;
var widthPerPixel=0.000021457672119140625;
var heightPerPixel=0.000018731174841353967;
var zMapCurrentZoom=0;
var zMapTimeoutUpdate=0;

if(typeof zMapFullscreen === "undefined"){
	zMapFullscreen=false;
}
function zlsGotoMapLink(url){
	if(zMapFullscreen){
		window.open(url);
	}else{
		window.top.location.href=url;
	}
}

function onGMAPLoad(force) {
	if(typeof zDisableOnGmapLoad !== "undefined" && zDisableOnGmapLoad) return;
	if((typeof force === "undefined" || !force) && (!zFunctionLoadStarted || typeof google === "undefined" || typeof google.maps === "undefined" || typeof google.maps.LatLng === "undefined")){// || typeof zMapGaLoaded === "undefined" || !zMapGaLoaded){
		return;
	}
	var arrC=zGetElementsByClassName("zMapLoadInputVarsClass");
	if(arrC.length === 0 || typeof arrC[0].value === "undefined" || arrC[0].value ===""){
		return;
	}
	var myObj=eval('('+arrC[0].value+')');
	mapProps=myObj;
	if(typeof google.maps.OverlayView === "undefined") return;
	if(zIsTouchscreen() && window.location.href.indexOf("/listing/search-form") !== -1){
		document.getElementById('map489273').style.display='none';
		return;
	}
	zLatLngControl.prototype = new google.maps.OverlayView();
	zLatLngControl.prototype.draw = function() {};
	zLatLngControl.prototype.createHtmlNode_ = function() {
		var divNode = document.createElement('div');
		divNode.id = 'latlng-control';
		divNode.index = 100;
		return divNode;
	};
	zLatLngControl.prototype.visible_changed = function() {
		this.node_.style.display = this.get('visible') ? '' : 'none';
	};
	zLatLngControl.prototype.updatePosition = function(latLng) {
		var projection = this.getProjection();
		var point = projection.fromLatLngToContainerPixel(latLng);
		zCurMapPixelV3=point;
	};
	zWindowSize=getWindowSize();
	if(typeof mapProps.stageWidth === "string" && mapProps.stageWidth.substr(mapProps.stageWidth.length-1) === "%"){
		mapProps.curStageWidth=zWindowSize.width+zScrollbarWidth;
	}else{
		mapProps.curStageWidth=parseInt(mapProps.stageWidth);
	}
	if(typeof mapProps.stageWidth === "string" && mapProps.stageHeight.substr(mapProps.stageHeight.length-1) === "%"){
		mapProps.curStageHeight=zWindowSize.height;
	}else{
		mapProps.curStageHeight=parseInt(mapProps.stageHeight);
	}
	mapProps.longBlockWidth=84;
	mapProps.latBlockWidth=91;
	mapProps.latBlocks=Math.ceil(mapProps.curStageHeight/mapProps.longBlockWidth);
	mapProps.longBlocks=Math.ceil(mapProps.curStageWidth/mapProps.latBlockWidth);
	zMapOverlayDivObjAbsPos=zGetAbsPosition(zMapOverlayDivObj);
	//setTimeout("loadBingMap();",200);
	mapLoadFunction();
	
	if(mapProps.avgLat===0 || mapProps.avgLong===0){
		var d383=document.getElementById("zMapAllDiv");
		d383.style.display="none";
		return;
	}
	// width/height per pixel at zoom 1
	minLat=0;
	maxLat=0;
	minLong=0;
	maxLong=0;
	if(mapProps.mapCount!==0 && typeof mapProps.zArrMapTotalLat !=="undefined" && mapProps.zArrMapTotalLat.length !== 0){
		minLat=mapProps.zArrMapTotalLat[0];
		maxLat=mapProps.zArrMapTotalLat[0];
		minLong=mapProps.zArrMapTotalLong[0];
		maxLong=mapProps.zArrMapTotalLong[0];
		for(i=0;i<mapProps.mapCount;i++){
			if(mapProps.zArrMapTotalLat[i]<minLat){
				minLat=mapProps.zArrMapTotalLat[i];
			}
			if(mapProps.zArrMapTotalLat[i]>maxLat){
				maxLat=mapProps.zArrMapTotalLat[i];
			}
			if(mapProps.zArrMapTotalLong[i]<minLong){
				minLong=mapProps.zArrMapTotalLong[i];
			}
			if(mapProps.zArrMapTotalLong[i]>maxLong){
				maxLong=mapProps.zArrMapTotalLong[i];
			}
		}
		avgLat=(maxLat+minLat)/2;
		avgLong=(maxLong+minLong)/2;
	}else{
		avgLat=mapProps.avgLat;
		avgLong=mapProps.avgLong;
	}
	margin=50;
	if(minLat===0){
		minLat=avgLat;
		maxLat=avgLat;	
		minLong=avgLong;
		maxLong=avgLong;	
	}
	mapProps.minLat=minLat;
	mapProps.maxLat=maxLat;
	mapProps.minLong=minLong;
	mapProps.maxLong=maxLong;
	/*minLat=Math.max(19.66328,minLat);
	maxLat=Math.min(34.22697,maxLat);
	minLong=Math.max(-83.803711,minLong);
	maxLong=Math.min(-76.641602,maxLong);*/
	avgLat=(maxLat+minLat)/2;
	avgLong=(maxLong+minLong)/2;
	// latitude = y   longitude = x
	// get the zoom level
	propHeight=Math.max(heightPerPixel*50,Math.abs(maxLat-minLat));
	propWidth=Math.max(widthPerPixel*50,Math.abs(maxLong-minLong));
	twp=widthPerPixel;
	thp=heightPerPixel;
	for(zoom=1;zoom<=20;zoom++){
		if(zoom !== 1){
			twp*=2;
			thp*=2;
		}
		maxWidth=mapProps.curStageWidth*twp;
		maxHeight=mapProps.curStageHeight*thp;
		// all properties must fit within zoom level
		if(maxWidth>propWidth+(twp*margin) && maxHeight>propHeight+(thp*margin)){
			break;
		}
	}
	if(!document.getElementById('search_within_map_name1') || document.getElementById('search_within_map_name1').checked===false){
		zoom++;	
	}
	// set zoom and center
	mapProps.avgLong=avgLong;
	mapProps.avgLat=avgLat;
	if(mapProps.forceZoom !== 0){
		mapProps.zoom=mapProps.forceZoom;
	}else{
		if(Math.abs(maxLat-minLat)===0){
			mapProps.zoom=20-zoom;
		}else{
			mapProps.zoom=18-zoom;
		}
	}
	streetView=false;
	
	onGMAPLoadV3();
}
zArrLoadFunctions.push({functionName:onGMAPLoad});
var zAjaxNearAddressMarker=false;
var zMapMarkerIdOff=0;

function toggleMapFullscreen(){
	var mapDiv=document.getElementById("myGoogleMap");
	var mapFloater=document.getElementById("mapFloater");
	
	if(mapFullscreen){
		mapFullscreen=false;
		mapProps.stageWidth=mapProps.curStageWidth;
		mapProps.stageHeight=mapProps.curStageHeight;
		mapDiv.style.width=mapProps.curStageWidth+'px';
		mapDiv.style.height=mapProps.curStageHeight+'px';
		mapFloater.style.marginLeft='10px'; 
		mapFloater.style.marginBottom='10px';
	}else{
		mapFullscreen=true;
		mapFloater.style.marginLeft='0px'; 
		mapFloater.style.marginBottom='10px';
		// find size of full screen and copy functionality from tiny mce or other source
		alert('not implemented');
		return;
	}
	onLoad();
}
function searchWithinMap(forceSubmit){
	var bounds =new Object();
	bounds.minY=mapObjV3.getBounds().getSouthWest().lat();
	bounds.minX=mapObjV3.getBounds().getSouthWest().lng();
	bounds.maxY=mapObjV3.getBounds().getNorthEast().lat();
	bounds.maxX=mapObjV3.getBounds().getNorthEast().lng();
	document.mapSearchForm.search_map_coordinates_list.value=bounds.minX+","+bounds.maxX+","+bounds.minY+","+bounds.maxY;
	document.mapSearchForm.submit();
}
/*
  var BingMap = null;
  var pinLocation = "";
  var bingid=null;
  var VEMap=null;
	function loadBingMap(){
	if(document.getElementById("zGStreetView")==null)return;
	var url = "http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=6.2&mkt=en-us";
	var e = document.createElement("script");
	e.src = url;
	e.type="text/javascript";
	document.getElementsByTagName("head")[0].appendChild(e);
	bingid=setInterval("GetBingMap()",1000);
	}
var zBingCheckId=null;
	
function GetBingMap() {
	return;
	if(typeof VEMap=="function" && bingid!=null){
		clearInterval(bingid);
		bingid=null;
		//setTimeout("GetBingMap()",3000);
		//return;
	} else if(bingid!=null) {
		return;
	}

	BingMap = new VEMap('myBingMap');
	BingMap.LoadMap(new VELatLong(zOneLatitude, zOneLongitude),17);
	BingMap.AddPushpin(new VELatLong(zOneLatitude, zOneLongitude));
	zBingCheckId=setTimeout("zBingHideMap();",500);
	BingMap.AttachEvent("onobliqueenter", OnObliqueEnterHandler);
	
}   
function zBingHideMap(){
	return;
	document.getElementById("myBingMapC").style.display="none";
	clearTimeout(zBingCheckId);
	zBingCheckId=null;
}

function OnObliqueEnterHandler() {
	if(BingMap.IsBirdseyeAvailable()) {
		clearTimeout(zBingCheckId);
		zBingCheckId=null;
		document.getElementById("myBingMapC").style.display="block";
		var TopOfProperty = new VELatLong(zOneLatitude, zOneLongitude); 
		BingMap.SetBirdseyeScene(TopOfProperty);
	}
}
*/

var myPano;	
if(typeof GClientGeocoder!=="undefined"){
	var geocoder = new GClientGeocoder();
}
var streetviewlatlong=0;
if(typeof GStreetviewClient!=="undefined"){
	var panoClient = new GStreetviewClient(); 
}
function gmsvShowAddress() { 
	if(document.getElementById("zGStreetView")===null)return;
	if(zOneLatitude !== ""){ 
		gmsvLoadGoogleMaps({y:zOneLatitude,x:zOneLongitude}); 
	}else if(zBingAddress !== ""){
		geocoder.getLatLng( zBingAddress   ,    function(point) {      if (!point) {    if(zOneLatitude !== ""){ gmsvLoadGoogleMaps({y:zOneLatitude,x:zOneLongitude}); }else{ handleGMSVErr(0); }    } else {  gmsvLoadGoogleMaps(point); }    }  );
	}else{ handleGMSVErr(0);}
}
var mapLoadFunction=gmsvShowAddress;
function gmsvLoadGoogleMaps(point){
	streetviewlatlong = new google.maps.LatLng(point.y,point.x);
	var panoramaOptions = { latlng:streetviewlatlong };
	myPano = new google.maps.StreetViewPanorama(document.getElementById("pano"), panoramaOptions);
      google.maps.event.addListener(myPano, "error", handleGMSVErr);
      // must be changed to: getPanoramaByLocation() instead of: panoClient.getNearestPanorama(streetviewlatlong, showPanoData);
}
function handleGMSVErr(errorCode) { //alert("errorCode:"+errorCode);
var d1=document.getElementById("zGStreetView");d1.style.display="none"; }  

function showPanoData(panoData) {
  if (panoData.code !== 200) {
   // GLog.write('showPanoData: Server rejected with code: ' + panoData.code);
   handleGMSVErr(0);
	return;
  }
  var d1=document.getElementById("zGStreetView");
  d1.style.display="block";
  var angle = computeAngle(streetviewlatlong, panoData.location.latlng);
  myPano.setLocationAndPOV(panoData.location.latlng, {yaw: angle});
}

function computeAngle(endLatLng, startLatLng) {
  var DEGREE_PER_RADIAN = 57.2957795;
  var RADIAN_PER_DEGREE = 0.017453;

  var dlat = endLatLng.lat() - startLatLng.lat();
  var dlng = endLatLng.lng() - startLatLng.lng();
  var yaw = Math.atan2(dlng * Math.cos(endLatLng.lat() * RADIAN_PER_DEGREE), dlat)
		 * DEGREE_PER_RADIAN;
  return wrapAngle(yaw);
}

function wrapAngle(angle) {
if (angle >= 360) {
  angle -= 360;
} else if (angle < 0) {
 angle += 360;
}
return angle;
}
function zSetNearAddress(v){
	if(v !== ""){
		zSetWithinMap(1);
		zSetWithinMap2(1);
	}else{
		zSetWithinMap(0);
		zSetWithinMap2(0);
	}
}

function zSetWithinMap(b){
	var d1=document.getElementById("setWithinMapRadio1");
	if(d1===null) return;
	var d2=document.getElementById("setWithinMapRadio2");
	var d3=document.getElementById("search_within_map_name1");
	if(b===1){
		d2.checked=false;
		d1.checked=true;
	}else{	
		d1.checked=false;
		d2.checked=true;
	}
}
function zSetWithinMap2(b){
	var d1=document.getElementById("setWithinMapRadio1");
	var d4=document.getElementById("setWithinMapRadio2");
	if(d1===null) return;
	var d3=document.getElementById("search_within_map_name1");
	var d2=document.getElementById("search_within_map");
	if(b===1){
		d1.checked=true; 
		d3.checked=true;
	}else{
		d4.checked=true;
		d3.checked=false;
	}
	d3.onclick();
}

var zArrPermanentMarker=new Array();
function zAjaxReturnNearAddress(r,skipParse){
	// throws an error when debugging is enabled.
	//r='{"success":true,"errorMsg":"","search_map_coordinates_list":"-81.1391101437,-81.1376618563,29.2753658556,29.2768141444"}';
	if(zDebugMLSAjax){
		document.write(r);	
		return;
	}
	var myObj=eval('('+r+')');
	if(!myObj.success){
		alert(myObj.errorMessage);
		return;
	}
	//alert("set:"+myObj.success);
	// set map coordinates
	var arrLatLong=myObj.search_map_coordinates_list.split(",");
	var minLat=parseFloat(arrLatLong[2]);
	var maxLat=parseFloat(arrLatLong[3]);
	var minLong=parseFloat(arrLatLong[0]);
	var maxLong=parseFloat(arrLatLong[1]);
	var avgLat=(minLat+maxLat)/2;
	var avgLong=(minLong+maxLong)/2;
	var zoom=0;
	var propHeight=Math.max(heightPerPixel*50,Math.abs(maxLat-minLat));
	var propWidth=Math.max(widthPerPixel*50,Math.abs(maxLong-minLong));
	var twp=widthPerPixel;
	var thp=heightPerPixel;
	margin=50;
	for(zoom=1;zoom<=20;zoom++){
		if(zoom !== 1){
			twp*=2;
			thp*=2;
		}
		maxWidth=mapProps.curStageWidth*twp;
		maxHeight=mapProps.curStageHeight*thp;
		// all properties must fit within zoom level
		if(maxWidth>propWidth+(twp*margin) && maxHeight>propHeight+(thp*margin)){
			break;
		}
	}
	// set zoom and center
	mapProps.avgLong=avgLong;
	mapProps.avgLat=avgLat;
	if(Math.abs(maxLat-minLat)===0){
		mapProps.zoom=20-zoom;
	}else{
		mapProps.zoom=18-zoom;
	}
	streetView=false;
	var d1=document.getElementById("searchNearAddress");
	var d2=document.getElementById("search_near_address");
	d2.value=d1.value;
	var d3=document.getElementById("zNearAddressDiv");
	d3.style.display="none";

	if(typeof mapObj === "undefined"){
		return;
	}
	mapObjV3.closeInfoWindow();
	mapObjV3.setCenter(new google.maps.LatLng(mapProps.avgLat, mapProps.avgLong), mapProps.zoom);
	
	zSetNearAddress(1);
	var pm=new Object();
	pm.point=new google.maps.LatLng(mapProps.avgLat, mapProps.avgLong);
	pm.title="zNearAddressMarker";
	arrAd=d2.value.split(",");
	var ad1=arrAd.shift()+"<br>"+arrAd.join(",");
	pm.htmlText='<table width="150"><tr><td>Location:<br>'+ad1+'</td></tr></table>';
	var marker=zAddPermanentMarker(pm);
	google.maps.event.trigger(marker,"click");
}
function zMLSUpdateResultLimit(n){
	var d=document.getElementById('search_result_limit');
	if(n === 2){
		var d2=[9,15,21,27,33,39,45,54];
	}else{
		var d2=[10,15,20,25,30,35,40,50];
	}
	for(var i=0;i<d.options.length;i++){
		d.options[i].value=d2[i];
		d.options[i].text=d2[i];
	}
}

function zAjaxMapRadiusChange(){
	var d3=document.getElementById("search_near_radius");
	if(d3.value !== ""){
		zAjaxSetNearAddress();
	}
}
function zAjaxFailNearAddress(){
	alert('There was a problem setting the address. Try again');
}
function zAjaxSetNearAddress(){
	var d1=document.getElementById("searchNearAddress");
	var d2=document.getElementById("search_near_radius");
	var d3="/z/listing/search-form/index?action=nearAddress&search_near_address="+escape(d1.value)+"&search_near_radius="+escape(d2.value);
	
	var tempObj={};
	tempObj.id="zMapNearAddress";
	tempObj.url=d3;
	tempObj.callback=zAjaxReturnNearAddress;
	tempObj.errorCallback=zAjaxFailNearAddress;
	tempObj.cache=false;
	tempObj.ignoreOldRequests=true;
	zAjax(tempObj);
}
function zAjaxCancelNearAddress(){
	var d1=document.getElementById("searchNearAddress");
	var d2=document.getElementById("search_near_radius");
	var d3=document.getElementById("zNearAddressDiv");
	d3.style.display="none";
	d1.value='';
	d2.value='0.1';
}
function zNearAddressChange(o){
	var d1=document.getElementById("zNearAddressDiv");
	var d3=document.getElementById("search_near_address");
	if(o.value === ""){
		d1.style.display="none";
		d3.value="";
	}else{
		d1.style.display="block";
	}
}


function zlsFixImageHeight(obj, width, height){
	if(typeof obj.naturalHeight !== "undefined" && obj.naturalHeight !== 0){
		if(obj.naturalHeight > height){
			obj.style.width="auto";
			obj.style.height=height+"px";
		}else if(obj.naturalHeight < height && obj.naturalHeight < width){
			obj.style.width=obj.naturalWidth+"px";
			obj.style.height=obj.naturalHeight+"px";
		}
	}else{
		var pos=zGetAbsPosition(obj);
		if(pos.height > height){
			obj.style.width="auto";
			obj.style.height=height+"px";
		}
	}
}

var mapObjV3=false;
var zGMapAbsPosV3=0;
var arrMapMarkersV3=new Array();
var debugTextarea;
var zMapOverlaysV3=new Array();
var zMapOverlaysIdsV3=new Array();
var zArrPermanentMarkerV3=new Array();
var zHighestMapCountV3=0;
var zMarkerMapCounterV3=0;
var zMapOverlayDivObjV3=0;
var zMapOverlayDivObjAbsPosV3=0;
var zCurrentMarkerMapCounterV3=0;
var zMapCurrentListingLinkV3="";
var zMapOverlayDivObjAbsPos2V3=0;
var zCurMapPixelV3;
var zCoorUpdateIntervalIdV3;
var zMarkerMapTypeTrack=new Array();
var zLatLngControlInstance;
//zMapMarkerV3.prototype = new google.maps.OverlayView();

var zLatLngControl=function(map) {
	if(typeof google === "undefined" || typeof google.maps === "undefined" || typeof google.maps.LatLng === "undefined"){
		return;
	}
	this.ANCHOR_OFFSET_ = new google.maps.Point(8, 8);
	this.node_ = this.createHtmlNode_();
	map.controls[google.maps.ControlPosition.TOP].push(this.node_);
	this.setMap(map);
	this.set('visible', false);
};
function gmapV3ClearMarkers() {   return;
	/*if (zMapOverlaysV3) {
		for (var i in zMapOverlaysV3) {
			zMapOverlaysV3[i].setMap(null);
		}
		//zMapOverlaysV3.length = 0;
	}*/
}

function zAddPermanentMarkerV3(pm){
	for(var i=0;i<zArrPermanentMarkerV3.length;i++){
		if(zArrPermanentMarkerV3[i].title === pm.title){
			zArrPermanentMarkerV3[i].point=pm.point;
			zArrPermanentMarkerV3[i].title=pm.title;
			zArrPermanentMarkerV3[i].htmlText=pm.htmlText;
			zArrPermanentMarkerV3[i].marker=zCreatePermanentMarkerV3(zArrPermanentMarkerV3[i]);
			return zArrPermanentMarkerV3[i].marker;
		}
	}
	
	zArrPermanentMarkerV3.push(pm);
	zArrPermanentMarkerV3[zArrPermanentMarkerV3.length-1].marker=zCreatePermanentMarkerV3(zArrPermanentMarkerV3[zArrPermanentMarkerV3.length-1]);
	return zArrPermanentMarkerV3[zArrPermanentMarkerV3.length-1].marker;
}
function zRemovePermanentMarkers(){
	for(var i=0;i<zArrPermanentMarkerV3.length;i++){
		zArrPermanentMarkerV3[i].marker.setMap(null);
	}
	zArrPermanentMarkerV3=[];
}
function zCreatePermanentMarkersV3(offset){
	for(var i=0;i<zArrPermanentMarkerV3.length;i++){
		zArrPermanentMarkerV3[i].marker=zCreatePermanentMarkerV3(zArrPermanentMarkerV3[i]);
	}
}
function zCreatePermanentMarkerV3(pm){
	var title="";
	if(pm.marker){
		pm.marker.setMap(null);
		pm.marker=false;
	}
	
	var infowindow = new google.maps.InfoWindow({
		content: pm.htmlText
	});
	var marker = new google.maps.Marker({
		position: pm.point,
		map: mapObjV3,
		title: pm.title
	});
	google.maps.event.addListener(marker, 'click', function() {
	  infowindow.open(mapObjV3,marker);
	});
	return marker;
}
zMapArrLoadFunctions=[];
function zlsUpdateMapSize(){
	var mid3=document.getElementById("myGoogleMapV3");
	mapProps.curStageWidth=zWindowSize.width+zScrollbarWidth;
	mapProps.curStageHeight=zWindowSize.height;
	mapProps.latBlocks=Math.ceil(mapProps.curStageHeight/mapProps.longBlockWidth);
	mapProps.longBlocks=Math.ceil(mapProps.curStageWidth/mapProps.latBlockWidth);
	myGoogleMapV3.style.width=mapProps.curStageWidth+"px";
	myGoogleMapV3.style.height=mapProps.curStageHeight+"px";
}
function onGMAPLoadV3(){
	zMapOverlayDivObjV3=document.getElementById("zMapOverlayDivV3");
	zMapOverlayDivObjAbsPosV3=zGetAbsPosition(zMapOverlayDivObjV3);
	var mid3=document.getElementById("myGoogleMapV3");
	if(mid3===null){
		return;
	}
	myGoogleMapV3.style.width=mapProps.curStageWidth+"px";
	myGoogleMapV3.style.height=mapProps.curStageHeight+"px";
	var myLatlng = new google.maps.LatLng(mapProps.avgLat,mapProps.avgLong);
	var myOptions = {
		streetViewControl: false,
		panControl:true, 
	  zoom: mapProps.zoom,
	  center: myLatlng,
	  mapTypeId: google.maps.MapTypeId.HYBRID
	};
	mapObjV3 = new google.maps.Map(mid3, myOptions);
	google.maps.event.addListener(mapObjV3, "click", function(){zMapMarkerRollOutV3(true); }); 
	
	
	
	zLatLngControlInstance = new zLatLngControl(mapObjV3);
 	zGMapAbsPosV3=zGetAbsPosition(mid3);
	//debugTextArea=document.getElementById('cojunasd83');
	
	 //debugTextArea.value="";
	 
	for(var n=0;n<zMapOverlaysIdsV3.length;n++){
		zMapOverlaysV3[n].setMap(null);
	}
	zMapOverlaysIdsGroupV3=[];
	zMapOverlaysIdsV3=[];
	zMapOverlaysV3=[];
	zRemovePermanentMarkers();
	 
	google.maps.event.addListener(mapObjV3, 'mouseover', function(mEvent) {
	  zLatLngControlInstance.set('visible', true);
	});
	google.maps.event.addListener(mapObjV3, 'mouseout', function(mEvent) {
	  zLatLngControlInstance.set('visible', false);
	});
	google.maps.event.addListener(mapObjV3, 'mousemove', function(mEvent) {
	  zLatLngControlInstance.updatePosition(mEvent.latLng); zMapMarkerMouseMoveV3(mEvent,this);
	});
	
	 
	 
		
	google.maps.event.addListener(mapObjV3, 'zoom_changed', function(){var oldZoom=-99;var newZoom = mapObjV3.getZoom();
	//debugTextArea.value+="zoom:"+newZoom+"\n";
	
	zMapOverlayDivObjV3.style.display="none"; zMapCurrentZoom=newZoom; if(oldZoom !== newZoom && !zMapFirstZoomChange){ gmapV3ClearMarkers();zCreatePermanentMarkersV3(); } zMapOverlaysIds=[];zMapOverlays=[]; zMapFirstZoomChange=false; clearTimeout(zMapTimeoutUpdate); /*zMapTimeoutUpdate=setTimeout('zMapCoorUpdateV3(true,zMLSSearchFormName);',10); */ if(newZoom>oldZoom){ streetView=false;}  });
	
	google.maps.event.addListener(mapObjV3, "bounds_changed", zMapBoundsChange);
	//google.maps.event.addListener(mapObjV3, "dragend", function(){/*debugTextArea.value+="dragend\n";*/zMapOverlayDivObjV3.style.display="none";if(!zMapIgnoreMoveEnd){ clearInterval(zMapTimeoutUpdate); zMapTimeoutUpdate=setTimeout('zMapCoorUpdateV3(true,zMLSSearchFormName);',10);} zMapIgnoreMoveEnd=false; });
	google.maps.event.addListener(mapObjV3,  "dragstart", function(){/*debugTextArea.value+="dragstart\n";*/zMapOverlayDivObjV3.style.display="none"; });
	
	google.maps.event.addListener(mapObjV3, "drag", function(){/*debugTextArea.value+="dragging\n";*/zMapOverlayDivObjV3.style.display="none";  });
	 
	google.maps.event.addListener(mapObjV3, "dragend", function(){ });
	for(var i=0;i<mapProps.mapCount;i++){
		if(mapProps.zArrMapText[i] !== false){
			var pm=new Object();
			pm.point=new google.maps.LatLng(mapProps.zArrMapTotalLat[i],mapProps.zArrMapTotalLong[i]);
			pm.title="zNearAddressMarker";
			pm.htmlText='<table width="150"><tr><td>'+mapProps.zArrMapText[i]+'</td></tr></table>';
			var marker=zAddPermanentMarkerV3(pm);
			zMapOverlaysV3.push(marker);
		}
	}
	if(zAjaxNearAddressMarker){
		var d2=document.getElementById("search_near_address");
		arrAd=d2.value.split(",");
		var ad1=arrAd.shift()+"<br>"+arrAd.join(",");
		//debugTextArea.value+="ad1:"+ad1+"\n";
		
		var pm=new Object();
		pm.point=new google.maps.LatLng(zAjaxNearAddressMarker[0], zAjaxNearAddressMarker[1]);
		pm.title="zNearAddressMarker";
		pm.htmlText='<table width="150"><tr><td>Location:<br>'+ad1+'</td></tr></table>';
		var marker=zAddPermanentMarker(pm);
		google.maps.event.trigger(marker,'click');
		zMapOverlaysV3.push(marker);
	}
	setTimeout("zMapTryUpdateV3();",1000);
	//zCoorUpdateIntervalIdV3=setInterval('zMapCoorUpdateV3(true,zMLSSearchFormName)',50);
	
}
function zMapBoundsChange(){/*debugTextArea.value+="dragend\n";*/if(typeof zMapOverlayDivObjV3.style !== "undefined") {zMapOverlayDivObjV3.style.display="none";}if(!zMapIgnoreMoveEnd){ clearInterval(zMapTimeoutUpdate); zMapTimeoutUpdate=setTimeout(zMapMapTimeoutUpdate,100);} zMapIgnoreMoveEnd=false; 
}
function zMapMapTimeoutUpdate(){
	zMapCoorUpdateV3(true,zMLSSearchFormName);
}
function zMapTryUpdateV3(){
	if(zMarkerMapTypeTrack.length===0){
		google.maps.event.trigger(mapObjV3,'zoom_changed');
	}
	for(var i=0;i<zMapArrLoadFunctions.length;i++){
		zMapArrLoadFunctions[i]();	
	}
}
			

function zMapCoorUpdateV3(fireAjax, formName) {
	var bounds =new Object(); 
	if(!mapObjV3.getBounds || typeof mapObjV3.getBounds() !== "object"){
		return; 
	}
	bounds.minY=mapObjV3.getBounds().getSouthWest().lat();
	bounds.minX=mapObjV3.getBounds().getSouthWest().lng();
	bounds.maxY=mapObjV3.getBounds().getNorthEast().lat();
	bounds.maxX=mapObjV3.getBounds().getNorthEast().lng();
	var fd=document.getElementById(formName);
	
	if(fd !==null && $("#search_map_coordinates_list").length) {
		$("#search_map_coordinates_list").val(bounds.minX+","+bounds.maxX+","+bounds.minY+","+bounds.maxY);
		//alert(fd.search_map_coordinates_list.value);
		//debugTextArea.value+="coor:"+fd.search_map_coordinates_list.value+"\n";
		$("#search_map_long_blocks").val(mapProps.longBlocks);
		$("#search_map_lat_blocks").val(mapProps.latBlocks);
		if(fireAjax) {
			if(typeof zFormData === "undefined" || typeof zFormData[formName] === "undefined"){
				zArrDeferredFunctions.push(function(){zFormData[formName].onChangeCallback(formName);});
			}else{
				zFormData[formName].onChangeCallback(formName);
			}
		}
	}
}
var zMapOverlaysIdsGroupV3=[];	
zUpdateMapMarkersV3First=true;	
function zUpdateMapMarkersV3(obj){
	if(typeof google === "undefined" || typeof google.maps === "undefined" || typeof google.maps.LatLng === "undefined"){
		return;
	}
	if(zArrPermanentMarker.length !== 0 || zArrPermanentMarkerV3.length !== 0) return;
	var arrOverlays=new Array();
	var arrOverlaysTemp=new Array();
	var arrOverlaysGroupTemp=new Array();
	var arrSkip=new Array();
	var found=false; 
	if(typeof obj.listing_id !== "undefined" && obj.listing_latitude !== ""){
		for(var n=0;n<zMapOverlaysIdsGroupV3.length;n++){
			if(zMapOverlaysIdsGroupV3[n] === true){
				//	console.log("group clear n2:"+n);
				zMapOverlaysV3[n].setMap(null);
			}
		}
		zHighestMapCountV3=0;
		if(zUpdateMapMarkersV3First && typeof obj.allMinLat !== "undefined" && window.location.href.indexOf("map-fullscreen") !== -1){
			var markerBounds = new google.maps.LatLngBounds(); 
			markerBounds.extend(new google.maps.LatLng(obj.allMinLat,obj.allMinLong)); 
			markerBounds.extend(new google.maps.LatLng(obj.allMinLat,obj.allMaxLong)); 
			markerBounds.extend(new google.maps.LatLng(obj.allMaxLat,obj.allMaxLong)); 
			markerBounds.extend(new google.maps.LatLng(obj.allMaxLat,obj.allMinLong)); 
			mapObjV3.fitBounds(markerBounds);
			zUpdateMapMarkersV3First=false;
		}
		for(var i2=0;i2<obj.listing_id.length;i2++){
			if(obj.listing_id[i2] === "0"){
				zHighestMapCountV3=Math.max(zHighestMapCountV3,obj.arrCount[i2]);
			}
		}
		
		for(var i2=0;i2<obj.arrColor.length;i2++){
			found=-1;
			if(obj.listing_id[i2] !== "0" && obj.listing_id[i2] !== ""){
				for(var n=0;n < zMapOverlaysIdsV3.length;n++){
					if(zMapOverlaysIdsV3[n]===obj.listing_id[i2]){
						found=zMapOverlaysIdsV3[n];	
						marker=zMapOverlaysV3[n];
						marker.setIcon("/z/a/listing/images/icon-home"+obj.arrColor[i2]+".jpg");
						if(typeof mapObjV3 === "object" && mapObjV3 !== null){
							marker.setMap(mapObjV3);
						}
						marker.myForceEasyClick=true;
						arrSkip.push(found);
						break;
					}
				}
				if(found===-1){
					var myLatlng = new google.maps.LatLng(obj.listing_latitude[i2],obj.listing_longitude[i2]);
					var marker=createMarkerListingAjaxV3(myLatlng, obj.listing_id[i2], obj.arrColor[i2]); 
					marker.listing_id = obj.listing_id[i2];
				}
				arrOverlaysGroupTemp.push(false);
			}else{
				//console.log("group"+(arrOverlaysTemp.length)+":"+obj.minLat[i2]+":"+obj.minLong[i2]);
				var myLatlng = new google.maps.LatLng(obj.minLat[i2],obj.minLong[i2]);
				var marker=createMarkerGroupBgAjaxV3(myLatlng, obj, i2, obj.arrColor[i2]); 
				//var marker=createMarkerGroupBgAjaxV3(myLatlng, obj, i2, obj.arrColor[i2]); 
				marker.listing_id = "0"+obj.minLat[i2]+":"+obj.minLong[i2];
				//console.log("marker"+obj.minLat[i2]+":"+obj.minLong[i2]+":"+obj.arrCount[i2]+":"+obj.avgPrice[i2]);
				arrOverlaysGroupTemp.push(true);
			}
			arrOverlaysTemp.push(obj.listing_id[i2]+":"+obj.minLat[i2]+":"+obj.minLong[i2]);
			arrOverlays.push(marker);
		}
	}
	var arrDelete=new Array();
	for(var n=0;n<zMapOverlaysIdsV3.length;n++){
		found=false;
		if(zMapOverlaysIdsGroupV3[n] === false){
			for(var i=0;i<arrSkip.length;i++){
				if(arrSkip[i]===zMapOverlaysIdsV3[n]){
					found=true;
					break;
				}
			}
			if(found===false){
				//	console.log("group clear n:"+n);
				zMapOverlaysV3[n].setMap(null);
			}
		}
	}
	zMapOverlaysIdsGroupV3=arrOverlaysGroupTemp;
	zMapOverlaysIdsV3=arrOverlaysTemp;
	zMapOverlaysV3=arrOverlays;
}
function zSetupCustomMarkerV3(marker){
	marker.zMarkerMapCounterV3=zMarkerMapCounterV3;
	marker.myRolloverCallbackObj=new Object();
	marker.myRolloverCallback=false;
	marker.myRolloverHTML=""; 
	if(typeof google === "undefined"){
		return;
	}
	google.maps.event.addListener(marker, "mouseover", function(o){zMapMarkerMouseOverV3(o,this); }); 
	google.maps.event.addListener(marker, "click", function(o){zMapMarkerMouseOverV3(o,this); }); 
	google.maps.event.addListener(marker, "mouseout", function(o){zMapMarkerRollOutV3Delay(); }); 
	
}
var zMapMarkerRollOutV3TimeoutId=0;
function zMapMarkerRollOutV3Delay(){
	clearTimeout(zMapMarkerRollOutV3TimeoutId);
	zMapMarkerRollOutV3TimeoutId=setTimeout(function(){zMapMarkerRollOutV3();}, 100);

}
function zMapLoadListingV3(obj){
	 zMapOverlayDivObjV3.style.width="300px";
	zMapOverlayDivObjV3.style.height="120px";
	//	document.getElementById("testdebug").value+="set to 100 height\n";
	 
//	 zMapOverlayDivObj.style.height="110px";
	var tempObj={};
	tempObj.id="zMapListing";
	tempObj.url="/z/listing/search-form/index?action=ajaxMapListing&listing_id="+obj.id;
	if(zDebugMLSAjax){
		tempObj.debug=true;
	}
	tempObj.cache=true;
	tempObj.callback=zMapShowListingV3;
	tempObj.ignoreOldRequests=true;
	zAjax(tempObj);	
}
function zMapShowListingV3(r){
	var myObj=eval('('+r+')');
	zMapCurrentListingLinkV3=myObj.link;
	zMapOverlayDivObjV3.innerHTML=myObj.html;
}
function createMarkerListingAjaxV3(point, id, iconcolor) {
	zMarkerMapCounterV3++;
	var marker = new google.maps.Marker({
		position: point,
		icon:"/z/a/listing/images/icon-home"+iconcolor+".jpg",
		map: mapObjV3,
		title: "zMapMarkerImage"+zMarkerMapCounterV3
	});
	marker.myForceEasyClick=true;
	zMarkerMapTypeTrack[zMarkerMapCounterV3]="marker";
	zSetupCustomMarkerV3(marker);
	var obj=new Object();
	obj.id=id;
	marker.myRolloverCallback=zMapLoadListingV3;
	marker.myRolloverCallbackObj=obj;
	// only for the home icon...
	google.maps.event.addListener(marker, "dblclick", function(o){
	  if(zMapCurrentListingLinkV3 !== null && zMapCurrentListingLinkV3 !== ""){
		 mapObjV3=null;
		window.top.location.href=zMapCurrentListingLinkV3;  
	  }
  });
	return marker; 
} 
function zlsGotoMultiunitResults(coordinateList){
	var arrQ=[];
	var obj=zFormSubmit(zMLSSearchFormName, false, true,false, true);
	obj.search_map_coordinates_list=coordinateList;
	obj.search_within_map=1;
	for(var i in obj){
		if(typeof zlsSearchCriteriaMap[i] !== "undefined" && obj[i] !== ""){
			arrQ.push(zlsSearchCriteriaMap[i]+"="+obj[i]);
		}
	}
	var d1=arrQ.join("&");
	if(d1.length >= 1950){
		alert("You've selected too many criteria. Please reduce the number of selections for the most accurate search results.");
	}
	if(window.location.href.indexOf("superiorpropertieshawaii.com") !== -1){
		window.open('/search-compare.cfc?method=index&'+d1.substr(0,1950));
	}else{
		window.open('/z/listing/search-form/index?searchaction=search&'+d1.substr(0,1950));
	}
}
function createMarkerGroupBgAjaxV3(point, obj, index, iconcolor) {
	if(obj.arrCountAtAddress[index]===1){
		point = new google.maps.LatLng(obj.listing_latitude[index],obj.listing_longitude[index]);
		
		zMarkerMapCounterV3++;
		var marker = new google.maps.Marker({
			position: point,
			icon:"/z/a/listing/images/icon-home"+iconcolor+".jpg",
			map: mapObjV3,
			title: "zSeeThroughMarkerId"+zMarkerMapCounterV3
		});
		zMarkerMapTypeTrack[zMarkerMapCounterV3]="seeThrough";
		marker.zMarkerMapCounterV3=zMarkerMapCounterV3;
		zSetupCustomMarkerV3(marker);
		
		marker.myForceEasyClick=true;
		marker.myRolloverHTML='<strong>'+obj.arrCount[index]+' listings at this address</strong><br />Average list price: '+obj.avgPrice[index]+'</span><br /><a href="##" onclick="zlsGotoMultiunitResults(\''+obj.listing_longitude[index]+","+obj.listing_longitude[index]+","+obj.listing_latitude[index]+","+obj.listing_latitude[index]+'\'); return false;">Click here to view all listings</a>';
		
		return marker;
	}else{
		var scale=obj.arrCount[index]/zHighestMapCountV3;
		var width= (32*scale)+24;
		var height= (25*scale)+20;
		//debugTextArea.value+="id:"+(index+1)+" | scale:"+scale+" | width:"+width+" | height:"+height+" | high:"+zHighestMapCountV3+"| count:"+obj.arrCount[index]+"\n";
		//width=42.40620155038759;
		//height=34.37984496124031;
		//var newAnchor=new google.maps.Point(Math.round(100-(58-(width/2))),Math.round(90-(45-(height/2))));//59, 62);
		var newAnchor=new google.maps.Point(Math.round(90-(58-(width/2))),Math.round(80-(45-(height/2))));//59, 62);
		var image2=new google.maps.MarkerImage('/z/a/listing/images/icon-multi'+iconcolor+'.png', new google.maps.Size(Math.round(width),Math.round(height)),new google.maps.Point(0, 0), newAnchor, new google.maps.Size(Math.round(width),Math.round(height)));
		/*if(index==2 || index === 1){
		//	console.log("index:"+index+" width:"+width+" height:"+height+" newAnchor:"+newAnchor+" point:"+point+" zMarkerMapCounterV3:"+zMarkerMapCounterV3);	
		//	console.log(image2);
		}*/
		zMarkerMapCounterV3++;
		//console.log(point);
		var marker = new google.maps.Marker({
			position: point,
			map: mapObjV3,
			icon: image2,
			title: "zSeeThroughMarkerId"+zMarkerMapCounterV3
		});
		//console.log(image2);
		zMarkerMapTypeTrack[zMarkerMapCounterV3]="seeThrough";
		zSetupCustomMarkerV3(marker);
		marker.myRolloverHTML='<strong>'+obj.arrCount[index]+' matching listings here</strong><br />Average list price: '+obj.avgPrice[index]+'</span><br />Double click to zoom in.';
		return marker;
		//alert(zHighestMapCountV3);
		/*
		var marker = new zMapMarkerV3(point,{"width":mapProps.longBlockWidth,"height":mapProps.latBlockWidth,"scale":scale,"iconcolor":iconcolor});
		marker.mySetRolloverHTML('<strong>'+obj.arrCount[index]+' matching listings here</strong><br />Average list price: '+obj.avgPrice[index]+'</span><br />Double click the red icon to zoom in.');
		*/
	}
	//arrMarkers.push(marker);
	//return marker;
}

function zMapMarkerMouseMoveV3(o){
	if(zCurrentMarkerMapCounterV3!==0 && typeof zMarkerMapTypeTrack[zCurrentMarkerMapCounterV3] !== "undefined"){
		if(zMarkerMapTypeTrack[zCurrentMarkerMapCounterV3]==="seeThrough"){
			var backupDiv=zMapOverlayDivObjV3;
			var tempPos={x:0,y:0};
			var tmpObj=false;
			if(window.parent !== null && window.parent.document.getElementById('zMapOverlayDivV3') !== null){
				zMapOverlayDivObjV3=window.parent.document.getElementById('zMapOverlayDivV3');
				tmpObj=zMapOverlayDivObjV3;
				tempPos=zGetAbsPosition(window.parent.document.getElementById('embeddedmapiframe'));
			}
			zMapOverlayDivObjV3.style.width="215px";
			zMapOverlayDivObjV3.style.height="65px";
	
			//alert(zGMapAbsPosV3.width+":"+px+":"+py+":"+zGMapAbsPosV3.x+"+"+tempPos.x+":"+zPositionObjSubtractPos[0]);
			//var projection=mapObjV3.getProjection();
			var pos=zCurMapPixelV3;//projection.fromLatLngToContainerPixel(obj.getPosition());
			if(tmpObj!== false){
				var pos={x:zMousePosition.x,y:zMousePosition.y};
				pos.x+=	tempPos.x;
				pos.y+=tempPos.y;
				zMapOverlayDivObjV3.style.top=(((zMousePosition.y+tempPos.y)-zPositionObjSubtractPos[1])+20)+"px";
				zMapOverlayDivObjV3.style.left=(((zMousePosition.x+tempPos.x)-zPositionObjSubtractPos[0])+20)+"px";
			}else{
				//debugTextArea.value='mousemove:'+zMousePosition.x+":"+zMousePosition.y+"\n";
				zMapOverlayDivObjV3.style.top=((zMousePosition.y-zPositionObjSubtractPos[1])+20)+"px";
				zMapOverlayDivObjV3.style.left=((zMousePosition.x-zPositionObjSubtractPos[0])+20)+"px";
			}
		
		}
	}
}


function goToStreetV3(lat,long2){
	streetView=true;
	zMapIgnoreMoveEnd=true;
	//mapObjV3.setZoom(mapProps.zoom);
	mapObjV3.setCenter(new google.maps.LatLng(lat, long2));
	zMapOverlayDivObjV3.style.left=(zGMapAbsPosV3.x+(zGMapAbsPosV3.width/2)+9)+"px";
	zMapOverlayDivObjV3.style.top=(zGMapAbsPosV3.y+(zGMapAbsPosV3.height/2)-9)+"px";
	//if(mapObj.getCurrentMapType() !== G_MAP_TYPE){
	if(mapObjV3.getMapTypeId() !== google.maps.MapTypeId.ROADMAP){
		mapObjV3.setZoom(21);
	}else{
		mapObjV3.setZoom(19);
	}
}

function zMapMarkerMouseOverV3(o,obj){
	//debugTextArea.value+='mouseover:'+obj.getTitle()+"\n";
	//return;
	var backupDiv=zMapOverlayDivObjV3;
	var tempPos={x:0,y:0};
	var tmpObj=false;
	if(window.parent !== null && window.parent.document.getElementById('zMapOverlayDivV3') !== null){
		zMapOverlayDivObjV3=window.parent.document.getElementById('zMapOverlayDivV3');
		tmpObj=zMapOverlayDivObjV3;
		tempPos=zGetAbsPosition(window.parent.document.getElementById('embeddedmapiframe'));
	}
	zMapOverlayDivObjV3.style.width="215px";
	zMapOverlayDivObjV3.style.height="65px";
	
	
	var p=30;
	/*if(zCurrentMarkerMapCounterV3!=0 && zCurrentMarkerMapCounterV3 !== obj.zMarkerMapCounterV3){
		//zMapMarkerRollOutV3(true);
	}*/
	
	var px=(zMousePosition.x-zGMapAbsPosV3.x);
	var py=zMousePosition.y-zGMapAbsPosV3.y;
	//alert(zGMapAbsPosV3.width+":"+px+":"+py+":"+zGMapAbsPosV3.x+"+"+tempPos.x+":"+zPositionObjSubtractPos[0]);
	//var projection=mapObjV3.getProjection();
	var pos=zCurMapPixelV3;//projection.fromLatLngToContainerPixel(obj.getPosition());
	if(tmpObj!== false){
		var pos={x:zMousePosition.x,y:zMousePosition.y};
		pos.x+=	tempPos.x;
		pos.y+=tempPos.y;
	}else{
		pos.x+=zGMapAbsPosV3.x;
		pos.y+=zGMapAbsPosV3.y;
	}
	
	pos.width=20;
	pos.height=17;
	//debugTextArea.value="divpoint:"+pos.x+":"+pos.y+" | subtractpos:"+zPositionObjSubtractPos[0]+":"+zPositionObjSubtractPos[1]+"\n";
	zMapOverlayDivObjAbsPos2V3=pos;
	zCurrentMarkerMapCounterV3=obj.zMarkerMapCounterV3;
	zMapOverlayDivObjV3.innerHTML=obj.myRolloverHTML;
	if(obj.myRolloverCallback!==false){
		obj.myRolloverCallback(obj.myRolloverCallbackObj);
	}
	
	if(zIsTouchscreen() && zTouchPosition.count){
		px=zTouchPosition.x[0];//-zGMapAbsPosV3.x;
		py=zTouchPosition.y[0];//-zGMapAbsPosV3.y;
		pos.x=zTouchPosition.x[0];
		pos.y=zTouchPosition.y[0];
		if(tmpObj!== false){
			pos.x+=tempPos.x;
			pos.y+=tempPos.y;
		}else{
			pos.x+=zGMapAbsPosV3.x;
			pos.y+=zGMapAbsPosV3.y;
		}
	}
	if(1===0){//obj.image_ === false){
		//alert('try fixmapmarkerdiv');
		return;
		//setTimeout("zFixMapMarkerDiv();",10);
		
	}else{
		
		//debugTextArea.value+="mappos:"+(zGMapAbsPosV3.width+":"+zGMapAbsPosV3.height+" | objpos:"+pos.x+":"+pos.y+"\n");
		if(px>zGMapAbsPosV3.width/2){
			if(typeof obj.myForceEasyClick !== "undefined"){
				zMapOverlayDivObjV3.style.left=(pos.x-zPositionObjSubtractPos[0])+"px";
			}else{
				zMapOverlayDivObjV3.style.left=((pos.x-zPositionObjSubtractPos[0])-(parseInt(zMapOverlayDivObjV3.style.width))+(10))+"px";//
			}
			//debugTextArea.value+="left1:"+((pos.x-zPositionObjSubtractPos[0])-(parseInt(zMapOverlayDivObjV3.style.width)+(9)))+":"+pos.x+":"+zPositionObjSubtractPos[0]+":"+parseInt(zMapOverlayDivObjV3.style.width)+"\n";
			if(py<zGMapAbsPosV3.height/2){ 
				zMapOverlayDivObjV3.style.top=((pos.y-zPositionObjSubtractPos[1])-25)+"px";
				//debugTextArea.value+="top1:"+(pos.y-zPositionObjSubtractPos[1])+":"+pos.y+":"+zPositionObjSubtractPos[1]+"\n";
			}else{
				//alert('t2');
				zMapOverlayDivObjV3.style.top=((pos.y+pos.height-zPositionObjSubtractPos[1])-(parseInt(zMapOverlayDivObjV3.style.height)+15))+"px";
				//debugTextArea.value+="top2:"+((pos.y+pos.height-zPositionObjSubtractPos[1])-(parseInt(zMapOverlayDivObjV3.style.height)+9))+":"+pos.y+":"+zMapOverlayDivObjV3.style.height+":"+parseInt(zMapOverlayDivObjV3.style.height)+"\n";
			}
		}else{
			//alert(pos.x+":"+(pos.x+pos.width));
			if(typeof obj.myForceEasyClick !== "undefined"){
				zMapOverlayDivObjV3.style.left=(pos.x-zPositionObjSubtractPos[0])+"px";
			}else{
				zMapOverlayDivObjV3.style.left=((pos.x+pos.width)-zPositionObjSubtractPos[0])+"px";//
			}
			//debugTextArea.value+="left2:"+(pos.x+pos.width-zPositionObjSubtractPos[0])+":"+pos.x+":"+pos.width+":"+zPositionObjSubtractPos[0]+"\n";
			if(py<zGMapAbsPosV3.height/2){
				zMapOverlayDivObjV3.style.top=((pos.y-zPositionObjSubtractPos[1])-25)+"px";
				//debugTextArea.value+="top3:"+(pos.y-zPositionObjSubtractPos[1])+":"+pos.y+":"+zPositionObjSubtractPos[1]+"\n";
			}else{
				zMapOverlayDivObjV3.style.top=((pos.y+pos.height-zPositionObjSubtractPos[1])-(parseInt(zMapOverlayDivObjV3.style.height)+15))+"px";
				//debugTextArea.value+="top4:"+((pos.y+pos.height-zPositionObjSubtractPos[1])-(parseInt(zMapOverlayDivObjV3.style.height)+9))+":"+pos.y+":"+zMapOverlayDivObjV3.style.height+":"+parseInt(zMapOverlayDivObjV3.style.height)+"\n";
			}
		} 
		zMapOverlayDivObjAbsPosV3={"x":parseInt(zMapOverlayDivObjV3.style.left)-tempPos.x,"y":parseInt(zMapOverlayDivObjV3.style.top)-tempPos.y,"width":parseInt(zMapOverlayDivObjV3.style.width),"height":parseInt(zMapOverlayDivObjV3.style.height)}; 
	}
			//alert(zMapOverlayDivObjV3.style.left+":"+zMapOverlayDivObjV3.style.top);
	
	/*
	var d2=document.getElementById("zSeeThroughMarkerId"+obj.zMarkerMapCounterV3);
	if(d2!=null){
		d2.style.opacity=0.5; d2.style.filter='alpha(opacity=50)';
	}*/
	
	zMapOverlayDivObjV3.style.display="block";
	/*if(tmpObj!== false){
		//tmpObj=zMapOverlayDivObjV3;	
	}*/
}
  
function zMapMarkerRollOutV3(force){
	//return;
	//alert('out'); 
	//debugTextArea.value="curMarker:"+zMousePosition.x+":"+zMousePosition.y+" | "+zMapOverlayDivObjAbsPosV3.x+":"+zMapOverlayDivObjAbsPosV3.y+":"+zMapOverlayDivObjAbsPosV3.width+":"+zMapOverlayDivObjAbsPosV3.height+"\n";
	var p=30; 
	if(zMapOverlayDivObjV3!==null && zCurrentMarkerMapCounterV3!==0){
		var image=false;
		if(typeof zMarkerMapTypeTrack[zCurrentMarkerMapCounterV3] !== "undefined"){
			if(zMarkerMapTypeTrack[zCurrentMarkerMapCounterV3]==="marker"){
				image=true;
			}
	  		if(!force && (zMousePosition.x-zPositionObjSubtractPos[0]>=zMapOverlayDivObjAbsPosV3.x-p && zMousePosition.x-zPositionObjSubtractPos[0]<=zMapOverlayDivObjAbsPosV3.x+zMapOverlayDivObjAbsPosV3.width+p && zMousePosition.y-zPositionObjSubtractPos[1]>=zMapOverlayDivObjAbsPosV3.y-p && zMousePosition.y-zPositionObjSubtractPos[1]<=zMapOverlayDivObjAbsPosV3.y+zMapOverlayDivObjAbsPosV3.height+p)){
				// in overlay tooltip
			}else if(!force && zMousePosition.x>=zMapOverlayDivObjAbsPos2V3.x-p && zMousePosition.x<=zMapOverlayDivObjAbsPos2V3.x+zMapOverlayDivObjAbsPos2V3.width+p && zMousePosition.y>=zMapOverlayDivObjAbsPos2V3.y-p && zMousePosition.y<=zMapOverlayDivObjAbsPos2V3.y+zMapOverlayDivObjAbsPos2V3.height+p){
				// in overlay
				//debugTextArea.value+="in overlay";
			}else if(!image){
				//debugTextArea.value+="out";
				//d2.style.opacity=0; d2.style.filter='alpha(opacity=0)';
				zCurrentMarkerMapCounterV3=0;
				zMapOverlayDivObjV3.innerHTML="";
				zMapOverlayDivObjV3.style.display="none"; 
			}else{
				zCurrentMarkerMapCounterV3=0;
				zMapOverlayDivObjV3.innerHTML="";
				zMapOverlayDivObjV3.style.display="none"; 
			}
		}
	}
}

function zlsEnableImageEnlarger(){
	var a=zGetElementsByClassName("zlsListingImage");	
	for(var i=0;i<a.length;i++){
		var id=a[i].id.substr(0,a[i].id.length-4);
		var d=document.getElementById(id+"_mlstempimagepaths");
		if(d !== null){
			zIArrMLink[id]="";
			zIArrM[id]=d.value.split("@");
			zIArrM2[id]=[];
			zIArrM3[id]=false;
			zImageMouseMove(id, false, true);
		}
	}
}
zArrLoadFunctions.push({functionName:zlsEnableImageEnlarger});


 var zIArrMLink=new Array();
var zIArrM=new Array();
var zIArrM2=new Array();
var zIArrM3=new Array();
  var zIArrMST=new Array();
  var zIArrOriginal=new Array();
function zImageMouseReset(id,mev){
	var d2=document.getElementById(id);
	if(d2===null) return;
	var dpos=zGetAbsPosition(d2);
	var dimg=document.getElementById(id+"_img");
	if(
		(zMousePosition.x > dpos.x)                &&
		(zMousePosition.x < (dpos.x + dpos.width))  &&
		(zMousePosition.y > dpos.y)                &&
		(zMousePosition.y < (dpos.y + dpos.height))){
		return;
	}
	if(typeof zIImageClickLoad!=="undefined" && zIImageClickLoad){
		var b1=document.getElementById('zlistingnextimagebutton');
		var b2=document.getElementById('zlistingprevimagebutton');
		b1.style.display="none";
		b2.style.display="none";	
		return;
	}
	zIArrMST[id]=false;
	zIArrM5[id]=-1;
	zIArrM2[id]=new Array();
	dimg.style.display="block";
	zImageForceCloseEnlarger();
	if(typeof zIArrOriginal[id] !== "undefined"){
		document.getElementById('zListingImageEnlargeImageParent').innerHTML='<img id="zListingImageEnlargeImage" alt="Image" src="'+zIArrOriginal[id]+'" onerror="zImageOnError(this);" />';
	}
}
function zImageOnError(o){
	o.onmousemove=null;
	o.onmouseout=null;
	o.src='/z/a/listing/images/image-not-available.gif';
}
function zClearSelection() {
    if(document.selection && document.selection.empty) {
        document.selection.empty();
    } else if(window.getSelection) {
        var sel = window.getSelection();
        sel.removeAllRanges();
    }
}
var zIArrMOffset=new Array();
  var zIArrMSize=new Array();
  var zIArrM5=new Array();
  var zIImageMaxWidth=540;
  var zIImageMaxHeight=420;
  var zICurrentImageIndex=0;
  var zICurrentImageXYPos=[0,0];
  //var zIImageClickLoad=false;
  var zILastLoaded="";
function zImageMouseMove(id,mev,forceResize){
	var d=document.getElementById(id);
	if(d===null) return;
	var dpos=zGetAbsPosition(d);
	
	var dimg=document.getElementById(id+"_img");
	if(dimg === null) return;
	var imageURL=dimg.getAttribute("data-imageurl");
	var b='/z/a/listing/images/image-not-available.gif';
	if(typeof dimg.src !== "undefined"){
		imageURL=dimg.src;
		if(dimg.src.substr(dimg.src.length-b.length, b.length) === b){
			return false;
		}
	}else if(imageURL !== ""){
		if(imageURL.indexOf(b) !== -1){
			return false;
		}
	}
	if(zILastLoaded === id){
		return;	
	}
	zIArrOriginal[id]=imageURL;
	if(typeof zIImageClickLoad !== "undefined" && zIImageClickLoad && typeof mev !== "boolean"){
		zILastLoaded=id;
		// show the prev/next buttons
		var b1=document.getElementById('zlistingnextimagebutton');
		var b2=document.getElementById('zlistingprevimagebutton');
		if(b1 !== null){
			if(zIArrM[id].length<=1){
				b1.style.display="none";
				b2.style.display="none";	
			}else{
				b1.style.display="block";
				b2.style.display="block";
				b1.style.paddingBottom=(dpos.height-19-45)+"px";
				b2.style.paddingBottom=(dpos.height-19)+"px";
			}
			if(zICurrentImageXYPos[0] === dpos.x && zICurrentImageXYPos[1] === dpos.y){
				return;
			}
			if(typeof zIArrMOffset[id] === "undefined"){
				zIArrMOffset[id]=0;
			}
			var b1pos=zGetAbsPosition(b1);
			zICurrentImageIndex=0;
			zICurrentImageXYPos[0]=dpos.x;
			zICurrentImageXYPos[1]=dpos.y;
			b1.ondblclick=function(){zClearSelection(); return false;};
			b2.ondblclick=function(){zClearSelection(); return false;};
			b1.onselectstart=function(){ zClearSelection(); return false;};
			b2.onselectstart=function(){ zClearSelection(); return false;};
			b2.style.top=((dpos.y)+10)+"px";//-dpos.height
			b2.style.left=dpos.x+"px";
			b1.style.top=((dpos.y)+10)+"px";//-dpos.height
			b1.style.left=((dpos.x+dpos.width)-b1pos.width)+"px";
			//b1.style.paddingTop=(dpos.height-b1pos.height)+"px";
			//b2.style.paddingTop=(dpos.height-b1pos.height)+"px";
			b1.curId=id;
			b1.curImageDiv=dimg;
			b2.curId=id;
			b2.curImageDiv=dimg;
			b1.unselectable=true;
			b2.unselectable=true;
			b1.onclick=function(){
				// next image
				//alert('next');
				var c=zIArrM[this.curId].length;
				var c2=zIArrMOffset[this.curId];
				c2++;
				if(c2 >=c){
					c2=0;	
				}
				this.curImageDiv.src=zIArrM[this.curId][c2];
				zIArrMOffset[this.curId]=c2;
				return false;
			};
			b2.onclick=function(){
				// prev image
				//alert('prev');	
				var c=zIArrM[this.curId].length;
				var c2=zIArrMOffset[this.curId];
				c2--;
				if(c2 <0){
					c2=c-1;	
				}
				this.curImageDiv.src=zIArrM[this.curId][c2];
				zIArrMOffset[this.curId]=c2;

				return false;
			};
		}
		dimg.onload=function(){
			var v1=zGetAbsPosition(this.parentNode); 
			if(v1.width === 0){
				var v1=zGetAbsPosition(this.parentNode.parentNode); 
			}
			//alert(this.parentNode.parentNode+":"+this.parentNode.parentNode.id+":"+v1.width+":"+this.width+":"+v1.height+":"+this.height);
			this.style.marginLeft=Math.max(0,Math.floor((v1.width-this.width)/2))+"px";
			//this.style.paddingRight=Math.max(0,Math.floor((v1.width-nw)/2))+"px";
			this.style.marginTop=Math.max(0,Math.floor((v1.height-this.height)/2))+"px";
			//this.style.paddingBottom=Math.max(0,Math.floor((v1.height-nh)/2))+"px";
		};
		return;	
	}
	if(forceResize!==true){
	  var offsetX =mev.clientX-dpos.x;
	  p=(offsetX/dpos.width);
	}else{
		p=0;	
	}
	if(typeof zIArrM === "undefined" || zIArrM === null || typeof zIArrM[id] === "undefined" || zIArrM[id] === null){
	  return;  
	}
	o=Math.min(Math.max(0,Math.floor(zIArrM[id].length*p)),zIArrM[id].length-1);
	if(zIArrM5[id]===o || zIArrM[id].length===0){
		if(typeof mev !== "boolean"){ 
			zImageShowEnlarger(id,dimg,dpos,zIArrM[id][o]);
		}
		return;
	}
  zIArrM5[id]=o;
  var lbl=zIArrM[id][o];
  if(zIArrM[id].length!==0 && o<zIArrM[id].length){
	  if(zIArrM3[id]===false){
		  for(var n=0;n<zIArrM[id].length;n++){
			  if(typeof mev !== "boolean" || n===0){
				zIArrMSize[zIArrM[id][n]]=[0,0];//nm.width,nm.height];
			  }
		  }
	  }
	if(zIArrM2[id][o]!==1){
		dimg.o222=dimg;
		dimg.o333=id;
		dimg.onload=function(){
			return;
		};
	}else{
		dimg.onload=null;
	}
		dimg.style.display="block";
	if(zIArrM[id][o] !== imageURL){
		if(typeof mev !== "boolean"){ 
			zImageShowEnlarger(id,dimg,dpos,zIArrM[id][o]);
		}
	}
  }
}
function zImageForceCloseEnlarger(){
	var d99=document.getElementById('zListingImageEnlargeDiv');
	if(d99 !== null){
		d99.style.display="none";
	}
}
zArrLoadFunctions.push({functionName:zImageForceCloseEnlarger});


function zImageShowEnlarger(id,dimg,dpos,src){
	var d=document.getElementById(id);
	if(d===null) return;
	zSetScrollPosition();
	//if(typeof zIArrMDead[id] === "undefined"){
		var ws=getWindowSize();
		var d99=document.getElementById('zListingImageEnlargeDiv');
		if(d99 !== null){
			if(d99.style.display==="none" || zCurEnlargeImageId !== id){
				zCurEnlargeImageId=id;
				//d99.style.left=((dpos.x+(dpos.width/2))-(540/2)+408)-zPositionObjSubtractPos[0]+"px";
				// detect which side of listing image has more room
				
				var newLeft=0;
				var newTop=0;
				if(dpos.x + (dpos.width/2) > ws.width / 2 || ws.width < 580 ){
					// left bigger
					
					newLeft=Math.max(20, dpos.x-580);//,((dpos.x+(dpos.width/2))-(zIImageMaxWidth/2)+398)-zPositionObjSubtractPos[0];
				}else{
					newLeft=Math.min(dpos.x+dpos.width+20, (ws.width-580)-zPositionObjSubtractPos[0]);
				}
				if(dpos.y + (dpos.height/2) > ws.height / 2 || ws.height < 470){
					// top bigger
					newTop=Math.max(dpos.y-470,zScrollPosition.top+20);//((dpos.y+(dpos.height/2))-(zIImageMaxHeight/2))-zPositionObjSubtractPos[1];
				}else{
					newTop=Math.min(dpos.y+dpos.height+20, zScrollPosition.top+(ws.height-470));
				}
				
				d99.style.left=newLeft+"px";//(Math.min(ws.width-600,((dpos.x+(dpos.width/2))-(zIImageMaxWidth/2)+398))-zPositionObjSubtractPos[0])+"px";
				d99.style.top=newTop+"px";//((dpos.y+(dpos.height/2))-(zIImageMaxHeight/2))-zPositionObjSubtractPos[1]+"px";
				/*d99.onmousemove=d.onmousemove;
				d99.onmouseout=d.onmouseout;
				d99.onmouseup=function(){ window.location.href=zIArrMLink[id];	}*/
			}
			d92=document.getElementById('zListingImageEnlargeImage');
			//d99.src='/z/a/listing/images/image-not-available.gif';//zIArrM[id][n];
			d92.onload=function(){
				
				var d99=document.getElementById('zListingImageEnlargeDiv');
				//zResizeWithRatio('zListingImageEnlargeImage',580,420);
				//d99.style.display="block";
				//var tWidth=this.width;
				//var tHeight=this.height;
				
				/*
				if(this.width>zIImageMaxWidth){
					this.width=zIImageMaxWidth;	
				}
				if(this.height>zIImageMaxHeight-20){
					this.height=zIImageMaxHeight-20;	
				}*/
				
				
				
				
				if(typeof zIArrMSize[this.src] === "undefined"){
					return;
				}
				/*if(zIArrMSize[this.src] && zIArrMSize[this.src][1]==0){
					zIArrMSize[this.src][1]=this.height;
					zIArrMSize[this.src][0]=this.width;
					setTimeout("zImageMouseLoadDelayed('"+this.id+"',true)",100);
					return;
				}*/
				//alert(zIArrMSize[this.src]);
				zIArrMSize[this.src]=[this.width,this.height];
				if(zIArrMSize[this.src][0]<=zIImageMaxWidth && zIArrMSize[this.src][1]<=zIImageMaxHeight-20){
					if(zIArrMSize[this.src][0] !== 0){
						this.width=zIArrMSize[this.src][0];
						this.height=zIArrMSize[this.src][1];
					}
				}else{
					if(zIArrMSize[this.src][0]>zIImageMaxWidth){
						var r1=zIImageMaxWidth/zIArrMSize[this.src][0];
						var nw=zIImageMaxWidth;
						var nh=r1*zIArrMSize[this.src][1]; 
					}else{
						var nw=0;
						var nh=zIImageMaxHeight; // force the height calculation below.
					}
					if(nh>zIImageMaxHeight-20){
						var r1=(zIImageMaxHeight-20)/zIArrMSize[this.src][1];
						var nw=Math.round(r1*zIArrMSize[this.src][0]);
						var nh=zIImageMaxHeight-20;
					}
					//alert(nw+":"+nh+":"+zIArrMSize[this.src][0]+":"+zIArrMSize[this.src][1]);
					if(nw===0){
						if(zIImageMaxWidth !== 0){
							this.width=zIImageMaxWidth;
							this.height=zIImageMaxHeight-20;
						}
					}else{
						if(Math.floor(nw) !== 0){
							this.width=Math.floor(nw);
							this.height=Math.floor(nh);
						}
					}
				}
				//alert(this.width+":"+nw+":"+this.height+":"+nh);
				
				//return;
				//alert(this.style.width+":"+this.style.height+":"+this.width+":"+this.height);
				this.style.cssFloat="left";
				this.style.marginLeft=Math.max(0,Math.floor((zIImageMaxWidth-this.width)/2))+"px";
				this.style.marginTop=Math.max(0,Math.floor((zIImageMaxHeight-this.height)/2))+"px";
				//d99.style.display="block";
			};
			//d99.style.width="auto";
			//d99.style.height="auto";
			//zResizeWithRatio('zListingImageEnlargeImage',580,420);
		}
		if(d92.src === '/z/a/images/s.gif' || d92.src !== src){
			//d92.style.width="auto";
			//d92.style.height="auto";
			//d92.src="";
		//	d99.style.display="none";
			d99.style.display="block";
			document.getElementById('zListingImageEnlargeImageParent').innerHTML='<img id="zListingImageEnlargeImage" alt="Image" src="'+src+'" onerror="zImageOnError(this);" />';
			//d92.src=src;//zIArrM[id][n];
		}else{
			d99.style.display="block";
		}
	//}
}

function zImageMouseLoadDelayed(id){
	var d=document.getElementById(id);	
	d.onload();
}
function zImageStoreLoaded(obj,id){
	obj.style.display="block";
	for(i=0;i<zIArrM[id].length;i++){
		if(zIArrM[id][i] === obj.src){
			zIArrM2[id][i]=1;
			return;
		}
	}
}
if(arrM===null){
	var arrM=[];
	var arrM2=[];
	var arrM3=[];
}

function zConvertSliderToSquareMeters(id1,id2, force){
	if(!force){
		setTimeout(function(){zConvertSliderToSquareMeters(id1,id2, true);},1);
		return;
	}
	var d0=document.getElementById("search_sqfoot_low_zvalue");
	if(d0===null) return;
	var d1=document.getElementById("zInputSliderBottomBox_"+d0.value);
	var f1=document.getElementById(id1);
	var f2=document.getElementById(id2);
	var sm1="";
	var sm2="";
	if(f1.value !== ""){
		var f1_2=parseInt(f1.value);
		if(!isNaN(f1_2)){
			sm1=Math.round(f1_2/10.7639);
		}
	}
	if(f2.value !== ""){
		var f2_2=parseInt(f2.value);
		if(!isNaN(f2_2)){
			sm2=Math.round(f2_2/10.7639);
		}
	}
	d1.innerHTML='<div style="width:50%; float:left; text-align:left;">'+sm1+'m&#178;</div><div style="width:50%; float:left; text-align:right;">'+sm2+'m&#178;</div>';
	d1.style.display="block";
}

function zInactiveCheckLoginStatus(f){
	if(zGetCookie("Z_USER_ID")==="" || zGetCookie("Z_USER_ID")==='""'){
		var found=false;
		if(f.type==="select" || f.type==="select-multiple"){
			var d1=document.getElementById("search_liststatus");
			for(var i=0;i<d1.options.length;i++){
				if(d1.options[i].value==="1"){
					d1.options[i].selected=true;
				}else{
					if(d1.options[i].selected){
						found=true;
						d1.options[i].selected=false;
					}
				}
			}
		}else if(f.type === "checkbox"){
			for(var i=1;i<30;i++){
				var d1=document.getElementById("search_liststatus_name"+i);
				if(d1){
					if(d1.value==="1"){
						d1.checked=true;
					}else{
						if(d1.checked){
							found=true;
							d1.checked=false;
						}
					}
				}else{
					break;
				}
			}
		}
		if(found){
			zShowModalStandard('/z/user/preference/register?modalpopforced=1&custommarketingmessage='+escape('Due to MLS Association Rules, you must register a free account to view inactive or sold listing data.  Use the form below to sign-up and view this data.')+'&reloadOnNewAccount=1', 640, 630);
				//alert('Only active listings can be displayed until you register a free account.');
		}
	}
}


function zInputPutIntoForm(linkSelected, valueSelected, formName, valueId, enableOnEnter){
	var arrP=linkSelected.split(", ");
	var arrCity=new Array();
	for(i=0;i<arrP.length;i++){
		if(i+1!==arrP.length){
			arrCity.push(arrP[i]);
		}
	}
	//alert(valueId+":"+formName+":"+linkSelected+":"+valueSelected+":"+document.getElementById(formName));
	var v1=document.getElementById(valueId);
	document.getElementById(formName).value = linkSelected;
	v1.value=valueSelected;
	//alert(document.getElementById(formName).id+":"+v1.id+":"+valueSelected);
	
	if(enableOnEnter){
		//zInputSetSelectedOptions(true,#zOffset#,'#arguments.ss.name#',null,#arguments.ss.allowAnyText#,#arguments.ss.onlyOneSelection#);document.getElementById('#arguments.ss.name#_zmanual').value='';
		zFormOnEnter(null,document.getElementById(formName),document.getElementById(formName));
	}
	return;
	/*v1.value="";
	document.getElementById(formName).value ="";
	selIndex=0;
	zCurrentCityLookupLabel='';*/
}
function zInputLinkBuildBox(obj, obj2,arrResults){
	selIndex=0;
	//alert(obj.name);
	var arrP=zFindPosition(obj);
	var b=document.getElementById("zTOB");
	b.style.position="absolute";
	b.style.left=(arrP[0]-zPositionObjSubtractPos[0])+"px";
	b.style.top=(arrP[1]+arrP[3]-zPositionObjSubtractPos[1])+"px";
	
	formName = obj2.id;
	var v="";
	var doc = document.getElementById("zTOB");
	doc.style.height=(60+(Math.min(10,arrResults.length)*23))+"px";
	class1='class="zTOB-selected" ';
	arrNewLink=[];
	v=v+'<div class="top">Click a city below or use the keyboard up and down arrow keys and press enter to select the city.</div>';
	for (j=0; j < arrResults.length; j++){
		var arrJ=arrResults[j].split("\t");
	v=v+'<a id="lid'+j+'" '+class1+' href="javascript:void(0);" onclick="zInputPutIntoForm(\''+arrJ[0]+'\',\''+arrJ[1]+'\',\''+obj.id+'\', \''+formName+'\',true); zInputHideDiv(\''+formName+'\');" >'+arrJ[0]+'</a>';
		class1='class="zTOB-link" ';	
		arrNewLink.push(j);
	}
	document.getElementById("zTOB").style.display="block";
	document.getElementById("zTOB").innerHTML=v;
	document.getElementById("zTOB").scrollTop="0px";
}


function zMlsCheckCityLookup(e, obj, obj2, type){
var keynum;
	if(e===null) return;
	if(window.event){
	keynum = e.keyCode;
	}else{
	keynum = e.which;	
	}
	if(obj.value.length > 2){
		if(keynum !==13 && keynum !==40 && keynum!==38){
		zMlsCallCityLookup(obj,obj2,type);
		}	
	}else{
		zInputHideDiv();
	}
}

var zArrCityLookup=[];
var arrNewLink=[];
var zCurrentCityLookupLabel="";
function zMlsCallCityLookup(obj,obj2,type){	
	var strValue="";
	arrNewLink=[];
	var suggCount=0;
	strValue=obj.value;
	strValue = zFixText(strValue);	
	if(strValue.length >= 3){
		var arrNew=[];
		var arrNew2=[];
		arrNewLink=[];
		var firstIndex=-1;
		var resetSelect=false;
		var m=zGetCityLookupObj();
		var d1=strValue.substr(0,1);
		var d2=strValue.substr(1,1);
		var d3=strValue.substr(2,1);
		var m2=false;
		try{
			var m2=eval("(m."+d1+"."+d2+"."+d3+")");
		}catch(e){
			zInputHideDiv();
			return;	
		}
		if(m2===null || m2===false){
			zInputHideDiv();
			return;	
		}
		zArrCityLookup=m2;
			zInputLinkBuildBox(obj, obj2,m2); 
			aN=[];
			var fb=null;
			var fbi=-1;
			var fixB=false;
			var foundB=false;
			zCurrentCityLookupLabel="";
			for(var i=0;i<m2.length;i++){
				var cb=document.getElementById('lid'+i);
				if(cb.innerHTML.substr(0, strValue.length).toLowerCase() !== strValue || strValue.length>cb.innerHTML.length){
					if(fb===null){
						fb=cb;
						fbi=i;
					}
					cb.style.display="none";
					if(cb.className==="zTOB-selected"){
						fixB=true;
						cb.className="box-link";
					}
				}else if(cb.className==="zTOB-selected"){
					var arrJ=m2[i].split("\t");
					obj2.value=arrJ[1];
					zCurrentCityLookupLabel=arrJ[0];
					foundB=true;
				}
			}
			if(fixB && fb!==null){
				fb.className="zTOB-selected";
				selIndex=fbi;
			}
			if(!foundB && m2.length>0){
				var cb=document.getElementById('lid0');
				cb.className="zTOB-selected";
				selIndex=0;
				
				
			}
		var ajaxArrCleanResults=zFormatTheArray(m2);	
		
		for(i=0;i<ajaxArrCleanResults.length;i++){
			var aib=document.getElementById("lid"+i);
			if(ajaxArrCleanResults[i].substr(0, strValue.length) === strValue){
				arrNew.push(m2[i]);
				arrNew2.push(i);
				if(aib!==null){
					arrNewLink.push(i);
					if(aib.className==="zTOB-selected"){
						selIndex=arrNewLink.length-1;
					}
					aib.style.display="block";
					if(firstIndex===-1){
						firstIndex=arrNewLink.length-1;
					}
				}
			}else{
				if(aib!==null){
					if(aib.className==="zTOB-selected"){
						resetSelect=true;
						aib.className="box-link";
					}
					aib.style.display="none";
				}
			}
		}
		if(resetSelect && firstIndex!==-1){
			selIndex=arrNew2[0];
			document.getElementById("lid"+arrNewLink[firstIndex]).className="zTOB-selected";
		}
		if(arrNew.length > 0){
			if(arrNewLink.length === 0){
				zInputLinkBuildBox(obj,obj2, arrNew);
			}else if(document.getElementById("zTOB").style.display==="none"){
				document.getElementById("zTOB").style.display="block";
				for(i=0;i<arrNewLink.length;i++){
					if(i===0){
						selIndex=arrNewLink[i];
						document.getElementById("lid"+arrNewLink[i]).className="zTOB-selected";
					}else{
						document.getElementById("lid"+arrNewLink[i]).className="box-link";
					}
				}
			}
		}else{
			zInputHideDiv();
		}
	}	
} 

var zExpArrMenuBox=new Array();
var zExpMenuBoxChecked=new Array();
var zExpMenuBoxData=new Array();
function zExpMenuToggleCheckBox(k,n,r,m,v){
	var o=document.getElementById("zExpMenuOption"+k+"_"+n);
	var o2=document.getElementById("zExpMenuOptionLink"+k+"_"+n);
	var i=0;
	var checkBoolean=true;
	if(m===1){
		checkBoolean=false;
	}
	n2=zExpArrMenuBox[zExpMenuLastIgnoreClick];
	for(var i=0;i<zExpArrMenuBox.length;i++){
		f=zExpArrMenuBox[i];
		if(f !== n2){
			var g1=document.getElementById(f+"_expmenu1");
			var g2=document.getElementById(f+"_expmenu2");
			var g4=document.getElementById(f+"_expmenu4");
			if(g4!==null){
				g2.style.display="none";
				g4.innerHTML="More Options &gt;&gt;";
				g4.className="zExpMenuOption";
			}
		}
	}
	if(r==='radio'){
		for(var i=0;i<zExpMenuBoxChecked[k].length;i++){
			var o=document.getElementById("zExpMenuOption"+k+"_"+zExpMenuBoxChecked[k][i]);
			var o2=document.getElementById("zExpMenuOptionLink"+k+"_"+zExpMenuBoxChecked[k][i]);
			o.checked=false;
			o2.className="zExpMenuOption";
		}
		var o=document.getElementById("zExpMenuOption"+k+"_"+n);
		var o2=document.getElementById("zExpMenuOptionLink"+k+"_"+n);
		var o_2=document.getElementById("zExpMenuOption"+k+"_"+n+"_2");
		var o2_2=document.getElementById("zExpMenuOptionLink"+k+"_"+n+"_2");
		o.checked=true;
		o2.className="zExpMenuOptionOver";
		zExpMenuBoxChecked[k]=new Array();
		zExpMenuBoxChecked[k][0]=n;
		if(o_2 !== null){
			o_2.checked=true;
			o2_2.className="zExpMenuOptionOver";
			zExpMenuBoxChecked[k][1]=n+"_2";
		}
	}else{
		var checkedNow=false;
		if(v===1){
			var o_2=document.getElementById("zExpMenuOption"+k+"_"+n+"_2");
			var o2_2=document.getElementById("zExpMenuOptionLink"+k+"_"+n+"_2");
			if(o_2.checked === checkBoolean){
				o.checked=false;
				o2.className="zExpMenuOption";
				o_2.checked=false;
				o2_2.className="zExpMenuOption";
			}else{
				checkedNow=true;
				o.checked=true;
				o2.className="zExpMenuOptionOver";
				o_2.checked=true;
				o2_2.className="zExpMenuOptionOver";
			}
		}else{
			var o_2=document.getElementById("zExpMenuOption"+k+"_"+n+"_2");
			var o2_2=document.getElementById("zExpMenuOptionLink"+k+"_"+n+"_2");
			if(o.checked === checkBoolean){
				o.checked=false;
				o2.className="zExpMenuOption";
				if(o_2 !== null){
					o_2.checked=false;
					o2_2.className="zExpMenuOption";
				}
			}else{
				checkedNow=true;
				o.checked=true;
				o2.className="zExpMenuOptionOver";
				if(o_2 !== null){
					o_2.checked=true;
					o2_2.className="zExpMenuOptionOver";
				}
			}
		}
		var arrC=new Array();
		for(var i=0;i<zExpMenuBoxChecked[k].length;i++){
			if(checkedNow || (!checkedNow && i!==n)){
				arrC.push(zExpMenuBoxChecked[k][i]);
			}
		}
		zExpMenuBoxChecked[k]=arrC;
	}
	if(o.onchange!==null){
		o.onchange();
	}
}
function zExpMenuSetPos(obj,left,top){
	obj.style.left=left+"px";
	obj.style.top=top+"px";
}
function zExpMenuToggleMenu(n){
	if(n!==null){
		var m1=document.getElementById(n+"_expmenu1");
		var m2=document.getElementById(n+"_expmenu2");
		var m4=document.getElementById(n+"_expmenu4");
		if(m1===null) return;
		if(m2.style.display==="block"){
			m2.style.display="none";
			m4.innerHTML="More Options &gt;&gt;";
			m4.className="zExpMenuOption";
		}else{
			m4.innerHTML="&lt;&lt; Hide Options";
			m4.className="zExpMenuOptionOver";
			m2.style.display="block";
			var arrPos=zFindPosition(m1);
			zExpMenuSetPos(m2,(arrPos[0]+arrPos[2]),arrPos[1]);
		}
	}
	for(var i=0;i<zExpArrMenuBox.length;i++){
		f=zExpArrMenuBox[i];
		if(f !== n){
			var g1=document.getElementById(f+"_expmenu1");
			var g2=document.getElementById(f+"_expmenu2");
			var g4=document.getElementById(f+"_expmenu4");
			if(g4===null) return;
			g2.style.display="none";
			g4.innerHTML="More Options &gt;&gt;";
			g4.className="zExpMenuOption";
		}
	}
}
var zExpMenuIgnoreClick=-1;
var zExpMenuLastIgnoreClick=-1;
function zExpMenuOnClick(){
	if(zExpMenuIgnoreClick!==-1){
		zExpMenuLastIgnoreClick=zExpMenuIgnoreClick;
		zExpMenuIgnoreClick=-1;
	}else{
		zExpMenuToggleMenu();
	}
	return true;
}
if(typeof document.onclick ==="function"){
	var zExpMenuOnClickBackup=document.onclick;
}else{
	var zExpMenuOnClickBackup=function(){};
}
$(document).bind("click", function(){
	zExpMenuOnClickBackup();
	zExpMenuOnClick();
});

function zExpShowUpdateBar(v, s){
	var d1=document.getElementById("zExpUpdateBar"+v);
	if(d1){
		d1.style.display=s;
	}
}

function getMLSTemplate(obj,row){
	var arrR=new Array();
	arrR.push('<table><tr><td valign="top" wid'+'th="110" style="font-size:10px; font-style:italic;"><div class="listing-l-img"><a href="#URL#"><img src="#PHOTO1#" alt="#TITLE#" width="100" height="78" class="listing-d-im'+'g"></a></div>ID##MLS_ID#-#LISTING_ID#</td><td valign="top"><h2><a href="#URL#" style="text-decoration:none; ">#TITLE#</a></h2><span>#DESCRIPTION#</span><span class="listing-l-l'+'inks" style="padding-bottom:0px; "><a href="#URL#">Read More</a><a href="/z/listing/inquiry/index?acti'+'on=form&mls_id=#MLS_ID#&listing_id=#LISTING_ID#" rel="nofollow">Send An Inquiry</a><a href="/z/listing/sl/index?save'+'Act=check&mls_id=#MLS_ID#&listing_id=#LISTING_ID#" rel="nofollow">Save Listing</a>');
	if(obj["VIRTUAL_TOUR"][row] !== ""){
		arrR.push('<a href="#VIRTUAL_TOUR#" target="_blank" rel="nofollow">View Virtual Tour</a>');
	}
	arrR.push('</span></td></tr><tr><td colspan="2" style="border-bottom:1px solid #999999;">&nbsp;</td></table><br />');
	return arrR.join("");
}
var zDebugMLSAjax=false;
function loadMLSResults(r){
	if(zDebugMLSAjax){
		document.write(r);
		return;
	}
	var myObj=eval('('+r+')');
	var m=myObj;
	arrD=new Array();
	setMLSCount(m.COUNT);
	//alert(m.SS[0].LABEL[0]);
  //          for(var g=0;g<zExpArrMenuBox.length;g++){
//            	if(zExpArrMenuBox[g]==f.id){
	// NOW I KNOW WHAT THIS WAS FOR! redraw from ajax results
					//zExpMenuRedraw(0,m.SS[0].LABEL,m.SS[0].VALUE);
	// loop listings
	//m.DATA["URL"]=new Array();
	m.DATA["TITLE"]=new Array();
	for(i=0;i<m.COUNT;i++){
		m.DATA["TITLE"][i]="Test title";
		var t=getMLSTemplate(m.DATA,i);
		for(g in m.DATA){
			t=zStringReplaceAll(t,"#"+g+"#",m.DATA[g][i]);
		}
		arrD.push(t);
	}
	var r2=document.getElementById("mlsResults");
	r2.innerHTML="";
	r2.innerHTML+=arrD.join('<hr />');
}
function displayMLSCount2(r,skipParse){
	displayMLSCount(r,skipParse,true);
}
function displayMLSCount(r,skipParse,newForm){
	// throws an error when debugging is enabled.
	if(zDebugMLSAjax){
		document.write(r);	
		return;
	}
	var myObj=eval('('+r+')');
	if(myObj.success){
		if(typeof myObj.disableSetCount === "undefined"){
			if(typeof newForm !=="undefined" && newForm){
				setMLSCount2(myObj.COUNT);
			}else{
				setMLSCount(myObj.COUNT);
			}
		}
		if(zUpdateMapMarkersV3!==null){
			zUpdateMapMarkersV3(myObj);	
		}
	}else{
		alert(myObj.errorMessage);
	}
	
}
var zSearchFormChanged=false;
//var zDisableSearchFormSubmit=false;
var firstSetMLSCount=true;
var zDisableSearchCountBox=false;
function setMLSCount2(c){
	if(zDisableSearchCountBox) return;
	var r92=document.getElementById("resultCountAbsolute");
	var r93=document.getElementById("searchFormTopDiv");
	if(typeof r93==="undefined" || r93===null || r92===null) return;
	//r93.style.height="110px";
	r92.style.display="block";
	var theHTML=c+' Listings';
	if(r92!==null){
		r92.innerHTML=theHTML;
	}
	if(firstSetMLSCount){
		firstSetMLSCount=false;
		//updateCountPosition();
	}
	updateCountPosition();
}
function setMLSCount(c){
	if(zDisableSearchCountBox) return;
	var theHTML='<span style="font-size:21px;line-height:26px;">'+c+'</span><br /><span style="font-size:12px;">listings match your <br />search criteria<br />&nbsp;</span></span>';
	var r92=document.getElementById("resultCountAbsolute");
	var r93=document.getElementById("searchFormTopDiv");
	if(typeof r93==="undefined" || r93===null) return;
	r93.style.height="110px";
	r92.style.display="block";
	var theHTML='<span style="font-size:21px;line-height:26px;">'+c+'</span><br /><span style="font-size:12px;">matching listings';
	//if(zSearchFormChanged && (typeof zDisableSearchFormSubmit === "undefined" || zDisableSearchFormSubmit === false)){
		theHTML+='<br /><button onclick="document.zMLSSearchForm.submit();" style="font-size:13px; font-weight:normal; background-image:url(/z/a/listing/images/mlsbg1.jpg); background-repeat:repeat-x; background-color:none; border:1px solid #999; margin-top:7px; width:130px; padding:3px; text-decoration:none; cursor:pointer;" name="sfbut1">Show Results</button>';
	//}
	theHTML+='</span></span>';
	if(r92!==null){
		r92.innerHTML=theHTML;
	}
	if(firstSetMLSCount){
		firstSetMLSCount=false;
		//updateCountPosition();
	}
	updateCountPosition();
}


function zSetJsNewDivHeight(){
	var h=zWindowSize.height - 0;
	var d=document.getElementById("zSearchJsNewDiv");
	if(d!==null){
		zListingInfiniteScrollDiv=document.getElementById("zListingInfinitePlaceHolder");
		if(zListingInfiniteScrollDiv){
			var p=zGetAbsPosition(zListingInfiniteScrollDiv);
			var oldHeight=parseInt(zListingInfiniteScrollDiv.style.height);
			zListingInfiniteScrollDiv.style.height=h+"px";
		}else{
			var p=zGetAbsPosition(zListingSearchJSDivPHLoaded);
			var oldHeight=parseInt(zListingSearchJSDivPHLoaded.style.height);
			zListingSearchJSDivPHLoaded.style.height=h+"px";
		}
		d.style.left=p.x+"px";
		d.style.top=p.y+"px";
		d.style.width=p.width+"px";//"100%";
		d.style.height=h+"px";
		d=document.getElementById("zSearchJsNewDivIframe");
		d.style.height=h+"px";
	
	/*
		if(h > oldHeight){
			// load more listings!
			var b=zScrollApp.disableNextScrollEvent;
			zScrollApp.disableNextScrollEvent=false;
			zScrollApp.scrollFunction();
			zScrollApp.disableNextScrollEvent=b;
		}*/
	}
	
}
function zForceSearchJsScrollTop(){
	var d=document.getElementById("zSearchJsNewDiv");
	if(d !== null){
		var p=zGetAbsPosition(d);
		if (zIsTouchscreen()) {
			//$(parent).scrollTop(p.y);
			zScrollTop(false, p.y);
		}else{
			zScrollTop(false, p.y);
		}
	}
	if(!d){
		d=parent.document.getElementById("zSearchJsNewDiv");
		if(d !== null){
			var p=parent.zGetAbsPosition(d);
			if (zIsTouchscreen()) {
				//$(parent).scrollTop(p.y);
				parent.zScrollTop(false, p.y);
			}else{
				parent.zScrollTop(false, p.y);
			}
		}
	}
}
var zListingSearchJSDivFirstTime=true;
var zListingSearchJSDivLoaded=null;
var zListingSearchJSToolDivLoaded=null;
var zListingSearchJSActivated=false;
var zListingSearchJSToolDivDisabled=false;
var zlsInstantPlaceholderDiv=false;
var zListingSearchJSDivPHLoaded=null;
function zListingSearchJsToolHide(){
	zListingSearchJSToolDivDisabled=true;
	if(zListingSearchJSToolDivLoaded){
		zListingSearchJSToolDivLoaded.style.display="none";
		zlsInstantPlaceholder.style.display="none";
	}
}
function zListingSearchJsToolPos(){
	if(typeof zlsInstantPlaceholder ==='boolean' || zListingSearchJSToolDivDisabled || !zListingSearchJSToolDivLoaded) return;
	var u=window.location.href;
	var p=u.indexOf("#");
	if(p !== -1){
		u=u.substr(p+1);
	}
	if(u.indexOf("/z/listing/search-form/index") !== -1 || u.indexOf("/z/listing/instant-search/index") !== -1){
		zListingSearchJSToolDivLoaded.style.display="none";
		zlsInstantPlaceholder.style.display="none";
	}else{
		zListingSearchJSToolDivLoaded.style.display="block";
		zlsInstantPlaceholder.style.display="block";
		var w=$("#zContentTransitionContentDiv").width();
		var p=$("#zContentTransitionContentDiv").position();
		var p2=$(zlsInstantPlaceholder).position();
		zListingSearchJSToolDivLoaded.style.top=Math.max(p2.top,$(window).scrollTop())+"px";
		zListingSearchJSToolDivLoaded.style.left=p.left+"px";
		zListingSearchJSToolDivLoaded.style.width=w+"px";
	}
}
function zListingShowSearchJsToolDiv(){
	var d22=document.getElementById('zListingSearchBarEnabledDiv');
	//console.log("tried:"+d22+":"+zListingSearchJSToolDivDisabled);
	if(!zListingSearchJSActivated && (!d22 ||  zListingSearchJSToolDivDisabled || (window.parent.location.href !== window.location.href && typeof window.parent !== "undefined" && typeof window.parent.zCloseModal !== "undefined"))){ return;}
	//console.log("got in");
	if(zListingSearchJSToolDivLoaded){
		if(zListingSearchJSActivated){
			zlsInstantPlaceholderDiv.style.display="block";
		}
		zListingSearchJSToolDivLoaded.style.display="block";
	}else{
		var w=$("#zContentTransitionContentDiv").width();
		var p=$("#zContentTransitionContentDiv").position();
		var c="window.location.href='/z/listing/search-form/index?showLastSearch=1'; return false;";
		if(zListingSearchJSActivated){
			c="zListingHideSearchJsToolDiv(); zContentTransition.gotoURL('/z/listing/instant-search/index'); return false;";
		}
		$("#zContentTransitionContentDiv").before('<div id="zlsInstantPlaceholder"></div><div id="zSearchJsToolNewDiv" class="zls-instantsearchtoolbar" style=" width:'+w+'px;z-index:1000; "><a href="/z/listing/instant-search/index" onclick="'+c+'" class="zNoContentTransition">&laquo; Back To Search Results</a></div>');
		zListingSearchJSToolDivLoaded=document.getElementById("zSearchJsToolNewDiv");
		zlsInstantPlaceholderDiv=document.getElementById("zlsInstantPlaceholder");
		zListingSearchJsToolPos();
		zArrResizeFunctions.push({functionName:zListingSearchJsToolPos});
		zArrScrollFunctions.push({functionName:zListingSearchJsToolPos});
		zArrLoadFunctions.push({functionName:zListingSearchJsToolPos});
	}
}

var zListingLastSearchJsURL="/z/listing/search-js/index";
function zListingShowSearchJsDiv(){
	zListingInfiniteScrollDiv=document.getElementById("zListingInfinitePlaceHolder");
	if(zListingInfiniteScrollDiv){
		var p=zGetAbsPosition(zListingInfiniteScrollDiv);
	}else{
		var p=zGetAbsPosition(document.getElementById("zContentTransitionContentDiv"));
	}
	var dut2=zGetCookie("zls-lsurl");
	var u=window.location.href;	var p=u.indexOf("#");	if(p !== -1){		u=u.substr(p+1);	}
	if(dut2 !== "" && u.indexOf("/z/listing/instant-search/index") !== -1){
		var du=dut2;
		
	}else{
		var d22=document.getElementById("zListingSearchJsURLHidden");
		if(d22){
			var du=d22.value;
			zListingLastSearchJsURL=d22.value;
			zSetCookie({key:"zls-lsurl",value:zListingLastSearchJsURL,futureSeconds:3600,enableSubdomains:false}); 
		}else{
			var du=zListingLastSearchJsURL;
		}
	}
	if(zListingSearchJSDivLoaded){
		var i=document.getElementById("zSearchJsNewDivIframe");
		if(i && i.src.substr(i.src.length-du.length) !== du){
			i.src=du;
		}
		//zListingSearchJSDivLoaded.style.display="block";
	}else{
		var h=$(window).height() - 0;
		$("#zContentTransitionContentDiv").before('<div id="zSearchJsNewDivPlaceholder" style="width:100%; float:left; height:'+Math.max(100,h)+'px;"></div><div id="zSearchJsNewDiv" style="overflow:auto;position:absolute; left:'+p.x+'px; top:'+p.y+'px; height:'+Math.max(100,h)+'px; width:'+p.width+'px;"><iframe id="zSearchJsNewDivIframe" frameborder="0" scrolling="auto" src="'+du+'" width="100%" height="'+h+'" /></div>');
		zListingSearchJSDivLoaded=document.getElementById("zSearchJsNewDiv");
		zListingSearchJSDivPHLoaded=document.getElementById("zSearchJsNewDivPlaceholder");
		zArrResizeFunctions.push({functionName:zSetJsNewDivHeight});
		zArrScrollFunctions.push({functionName:zSetJsNewDivHeight});
		zSetJsNewDivHeight();
	}
	$(zListingSearchJSDivLoaded).hide().fadeIn(200,function(){});
	if(zListingInfiniteScrollDiv){
		if(zListingSearchJSDivPHLoaded){
			zListingSearchJSDivPHLoaded.style.display="none";
		}
	}else{
		if(zListingSearchJSDivPHLoaded){
			zListingSearchJSDivPHLoaded.style.display="block";
		}
	}
}
function zListingHideSearchJsToolDiv(){
	if(zListingSearchJSToolDivLoaded){
		zListingSearchJSToolDivLoaded.style.display="none";
		zlsInstantPlaceholderDiv.style.display="none";
	}
}
function zListingHideSearchJsDiv(){
	if(zListingSearchJSDivPHLoaded){
		zListingSearchJSDivPHLoaded.style.display="none";	
	}
	if(zListingSearchJSDivLoaded){
		zListingSearchJSDivLoaded.style.display="none";
	}
}
var zListingInfiniteScrollDiv=false;
function zListingLoadSearchJsDiv(){
	var u=window.location.href;
	var p=u.indexOf("#");
	if(p !== -1){
		u=u.substr(p+1);
	}
	var c=u;
	zListingInfiniteScrollDiv=document.getElementById("zListingInfinitePlaceHolder");
	if(c.indexOf("/z/listing/search-js/index") !== -1) return;
	var d=document.getElementById("zListingEnableInstantSearch");
	if((d && d.value === "1") && (c.indexOf("/z/listing/instant-search/index") !== -1 || zListingInfiniteScrollDiv)){
		if(!zListingSearchJSDivFirstTime) return;
		zListingSearchJSDivFirstTime=false;
		zListingSearchJSActivated=true;
		zListingShowSearchJsDiv();
		zContentTransition.bind(function(newUrl){
			if(newUrl.indexOf("/z/listing/instant-search/index") !== -1){
				zContentTransition.disableNextAnimation=true;
				zListingShowSearchJsDiv();
				zListingHideSearchJsToolDiv();
				setTimeout(function(){zForceSearchJsScrollTop();
				if(window.parent.document.getElementById("zSearchJsNewDivPlaceholder")){
					window.parent.zScrollTop('html, body', $(window.parent.document.getElementById("zSearchJsNewDivPlaceholder")).position().top);
				}else if(document.getElementById("zSearchJsNewDivPlaceholder")){
					window.zScrollTop('html, body', $(document.getElementById("zSearchJsNewDivPlaceholder")).position().top);
				}
				},50);
			}else{
				zListingHideSearchJsDiv();
				zListingShowSearchJsToolDiv();
				setTimeout(zListingSearchJsToolPos,50);
			}
			zContentTransition.manuallyProcessTransition();
		});
	}else{
		zListingShowSearchJsToolDiv();
	}
}

zArrLoadFunctions.push({functionName:zListingLoadSearchJsDiv});

//var zMapCoorUpdateV3=null;
function getMLSCount2(formName){
	getMLSCount(formName, true);
}
function getMLSCount(formName,newForm){
	zSearchFormChanged=true; 
	//clearInterval(zCoorUpdateIntervalIdV3);
	//zCoorUpdateIntervalIdV3=0;
	var v1=document.getElementById("search_map_lat_blocks");
	/*if(zIsTouchscreen() === false && typeof zMapCoorUpdateV3 !== "undefined" && v1 && v1.value==""){ 
		 return "0";
	} */
	var ab=zFormData[formName].action;
	var cb=zFormData[formName].onLoadCallback;
	var aj=zFormData[formName].ajax;
	zFormData[formName].ajax=true;
	zFormData[formName].ignoreOldRequests=true;
	if(typeof newForm !== "undefined" && newForm){
		zFormData[formName].onLoadCallback=displayMLSCount2;
	}else{
		zFormData[formName].onLoadCallback=displayMLSCount;
	}
	zFormData[formName].successMessage=false;
	zFormData[formName].action='/z/listing/search-form/index?action=ajaxCount';
	if(zDisableSearchFilter===1){
		zFormData[formName].action+="&zDisableSearchFilter=1";
	}
	zFormSubmit(formName,false,true);
	zFormData[formName].ajax=aj;
	zFormData[formName].action=ab;
	zFormData[formName].onLoadCallback=cb;
	return "1";
}

var zMLSMessageBgColor="0x990000";
var zMLSMessageTextColor="0xFFFFFF";
var zMLSMessageOutputId=0;
function zMLSShowFlashMessage(){
	var a=zGetElementsByClassName("zFlashDiagonalStatusMessage");
	for(var i=0;i<a.length;i++){
		var message=a[i].innerHTML;
		zMLSMessageOutputId++;
		message=zStringReplaceAll(message,"\r","");
		if(message!=="" && message.indexOf("<object ") === -1){
			//a[i].innerHTML=('<img src="/z/a/images/s.gif" width="100%" height="100%">');
		//}else{
			a[i].innerHTML=('<object zswf="off" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0" width="221" height="161" id="zMLSMessage'+zMLSMessageOutputId+'"><param name="allowScriptAccess" value="sameDomain" /><param name="allowFullScreen" value="false" /><param name="movie" value="/z/a/listing/images/message.swf?messageText='+escape(message)+'&bgColor='+zMLSMessageBgColor+'&textColor='+zMLSMessageTextColor+'" /><param name="quality" value="high" /><param name="scale" value="noscale" /><param name="wmode" value="transparent" /><param name="salign" value="TL" /><param name="bgcolor" value="#ffffff" />	<embed src="/z/a/listing/images/message.swf?messageText='+escape(message)+'&bgColor='+zMLSMessageBgColor+'&textColor='+zMLSMessageTextColor+'" quality="high" scale="noscale" wmode="transparent" bgcolor="#ffffff" width="221" height="161" name="zMLSMessage'+zMLSMessageOutputId+'" style="pointer-events:none;" salign="TL" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.adobe.com/go/getflashplayer" /></object>');	
		}
		a[i].style.display="block";
	}
}
zArrLoadFunctions.push({functionName:zMLSShowFlashMessage});

function zAjaxWalkscore(obj){
	var tempObj={};
	tempObj.id="zAjaxWalkScore";
	tempObj.url="/z/misc/walkscore/index?latitude="+obj.latitude+"&longitude="+obj.longitude;
	tempObj.cache=false;
	tempObj.callback=zAjaxWalkscoreCallback;
	tempObj.ignoreOldRequests=false;
	zAjax(tempObj);	
}
var zWalkscoreIndex=0;
function zAjaxWalkscoreCallback(r){
	var d1=document.getElementById("walkscore-div");
	var json=eval('(' + r + ')');
	//if we got a score
	if (json && json.status === 41) {
		d1.innerHTML='Walkscore not available';
		return;
	}else if (json && json.status === 1) {
		var htmlStr = 'Walk Score&#8482;: ' + json.walkscore + " Description: "+json.description;//'<a target="_blank" href="' + json.ws_link + '">Walk Score</a>&#8482;: ' + json.walkscore + " Description: "+json.description;
	}
	//if no score was available
	else if (json && json.status === 2) {
		var htmlStr = '';//'<a target="_blank" href="http://www.wal'+'kscore.com" rel="nofollow">Walk Score</a>&#8482;: <a target="_blank" href="' + json.ws_link + '">Get Score</a>';
	}else{
		d1=false;	
	}
	zWalkscoreIndex++;
	//make sure we have a place to put it:
	if (d1) { //if you want to wrap P tags around the html, can do that here before inserting into page element
		htmlStr = htmlStr + getWalkScoreInfoHtml(zWalkscoreIndex);
		d1.innerHTML = htmlStr;
	}
}
//show/hide the walkscore info window
function toggleWalkScoreInfo(index) {
	var infoElem = document.getElementById("walkscore-api-info" + index);
	if (infoElem && infoElem.style.display === "block")
		infoElem.style.display = "none";
	else if (infoElem)
		infoElem.style.display = "block";
}
function getWalkScoreInfoHtml(index) {
	return '<span id="walkscore-api-info' + index + '" class="walkscore-api-info" style="font-size:12px; padding-top:10px; display:block; float:left; clear:both;">Walk Score measures how walkable an address is based on the distance to nearby amenities. A score of 100 represents the most walkable area compared to other areas.<hr /></span></span>';// <a href="http://www.walkscore.com" target="_blank">Learn more</a>. <hr /></span></span>';
}


function zModalSaveSearch(searchId){
	var modalContent1='<iframe src="/z/listing/property/save-search/index?searchId='+searchId+'" width="100%" height="95%"  style="margin:0px;overflow:auto; border:none;" seamless="seamless"></iframe>';
	zShowModal(modalContent1,{'width':520,'height':410,'disableResize':true});
}
/*
function zToggleSortFormBox(){
	var d1=document.getElementById("search_remarks");
	var d2=document.getElementById("search_remarks_negative");
	var d3=document.getElementById("zSortFormBox");
	var d5=document.getElementById("zSortFormBox2");
	var d4=document.getElementById("search_sort");
	if(d1.value !="" || d2.value !== ""){
		d3.style.display="none";
		d4.selectedIndex=0;
		d5.style.display="block";
	}else{
		d3.style.display="block";
		d5.style.display="none";
	}
}
*/

function zShowInquiryPop(){
	var modalContent1='<iframe src="/z/listing/inquiry-pop/index" width="100%" height="95%" style="margin:0px;overflow:auto; border:none;" seamless="seamless"></iframe>';
	zShowModal(modalContent1,{'width':520,'height':438,'disableResize':true});
}



var zScrollApp=new Object();
zScrollApp.forceSmallHeight=50000;
zScrollApp.newCount=0;
zScrollApp.maxItems=1000;
zScrollApp.firstNewBox=0;
zScrollApp.boxCount2=0;
zScrollApp.colCount=-1;
	//var rowHeight=100;
zScrollApp.itemMarginRight=30;
zScrollApp.itemMarginBottom=30;
zScrollApp.itemWidth=160;
zScrollApp.itemHeight=170;
zScrollApp.arrVisibleBoxes=new Array();
zScrollApp.bottomRowLoaded=0;
zScrollApp.scrollAreaDiv=false;
zScrollApp.scrollAreaPos=false;
zScrollApp.scrollAreaMapDiv=false;
zScrollApp.appDisabled=false;

zScrollApp.bottomRowLoadedBackup=0;
zScrollApp.resizeTimeoutId=false;
zScrollApp.scrollTimeoutId=false;

zScrollApp.lastScrollPosition=-1;
zScrollApp.totalListingCount=0;
zScrollApp.googleMapClass=false;
zScrollApp.loadedMapMarkers=new Array();
zScrollApp.scrollAreaWidth=0;
zScrollApp.veryFirstSearchLoad=true;
zScrollApp.curListingCount=0;
zScrollApp.curListingLoadedCount=0;
zScrollApp.bottomRowLimit=5;
zScrollApp.arrListingId=new Array();
zScrollApp.templateCache={};
zScrollApp.offset=0;
zScrollApp.firstAjaxRequest=true;
zScrollApp.disableNextScrollEvent=false;
zScrollApp.lastScreenWidth=0;

zScrollApp.drawVisibleRows=function(startRow, endRow){
	var arrH=new Array();
	var firstNew=true;
	var boxOffset=startRow*zScrollApp.colCount;
	tempEndRow=Math.min(zScrollApp.bottomRowLimit, endRow);
	for(var row=startRow;row<tempEndRow;row++){
		var tempItemMarginRight=zScrollApp.itemMarginRight;
		var itemTop=((row*zScrollApp.itemHeight)+(row*zScrollApp.itemMarginBottom))+50;
		for(var col=0;col<zScrollApp.colCount;col++){
			var itemLeft=((col*zScrollApp.itemWidth)+(col*zScrollApp.itemMarginRight))+10;
				tempCSS="";
				zScrollApp.boxCount2++;
				var d9=document.getElementById('row'+boxOffset);
				if(d9!==null){
					
				}else{
					if(firstNew){
						firstNew=false;
						zScrollApp.firstNewBox=boxOffset;
					}
					zScrollApp.arrVisibleBoxes["row"+boxOffset]=new Object();
					zScrollApp.arrVisibleBoxes["row"+boxOffset].offset=boxOffset;
					zScrollApp.arrVisibleBoxes["row"+boxOffset].visible=true;
					zScrollApp.newCount++;
					var tempTop=itemTop;
					var tempLeft=itemLeft;
					arrH.push('<div id="row'+boxOffset+'" style="position:absolute; background-color:#FFF; left:'+tempLeft+'px; top:'+tempTop+'px; width:'+zScrollApp.itemWidth+'px; height:'+zScrollApp.itemHeight+'px;  '+tempCSS+' "><\/div>');// margin-bottom:'+zScrollApp.itemMarginBottom+'px; margin-right:'+tempItemMarginRight+'px;
				}
				boxOffset++;
		}
		zScrollApp.bottomRowLoaded=row;
	}
	zScrollApp.scrollAreaDiv.append(arrH.join(""));
};
zScrollApp.hideRows=function(lessThen, greaterThen){
	var activated=0;
	var boxOffset=0;
	for(var i10 in zScrollApp.arrVisibleBoxes){
		var i=zScrollApp.arrVisibleBoxes[i10].offset;
		var i2=Math.floor(i/zScrollApp.colCount);
		var i22=i;
		var i3=zScrollApp.arrVisibleBoxes[i10].visible;
		if(i2 < lessThen || i2 >= greaterThen){
			if(i3){
				// hide it
				zScrollApp.arrVisibleBoxes[i10].visible=false;
				var itemTop=((i2*zScrollApp.itemHeight)+(i2*zScrollApp.itemMarginBottom));
				for(var col=0;col<zScrollApp.colCount;col++){
					var itemLeft=((col*zScrollApp.itemWidth)+(col*zScrollApp.itemMarginRight));
					$('#row'+(i22)).html("");
				}
			}
		}else{
			if(!i3){
				zScrollApp.arrVisibleBoxes[i10].visible=true;
				activated++;
				var itemTop=((i2*zScrollApp.itemHeight)+(i2*zScrollApp.itemMarginBottom));
				for(var col=0;col<zScrollApp.colCount;col++){
					var itemLeft=((col*zScrollApp.itemWidth)+(col*zScrollApp.itemMarginRight));
					if('row'+(i22) in zScrollApp.templateCache){
						$('#row'+(i22)).html(zScrollApp.templateCache['row'+(i22)]);
					}
				}
			}
		}
	}
};


zScrollApp.delayedResizeFunction=function(d){
	if(zlsHoverBox.panel && zlsHoverBox.panel.style.display==="block"){
		return;
	}
	if(zlsHoverBoxNew.panel && zlsHoverBoxNew.panel.style.display==="block"){
		return;
	}
	if(zScrollApp.resizeTimeoutId !==false){
		clearTimeout(zScrollApp.resizeTimeoutId);
	}
	zScrollApp.resizeTimeoutId=setTimeout('zScrollApp.resizeFunction();',50);
};
zScrollApp.resizeFunction=function(){
	var s=$(window).width();
	if(zScrollApp.lastScreenWidth !== s){
		zListingResetSearch();
	}
};
zScrollApp.lastScrollTop=0;

zScrollApp.delayedScrollFunction=function(){
	var docViewTop=$(window).scrollTop();
	zScrollApp.lastScrollTop=docViewTop;
	/*if(zIsTouchscreen()){
		if(zlsHoverBox.panel.style.display=="block"){
			zlsHoverBox.box.style.top="0px";	
		}else{
			if(zIsAppleIOS()){
				zlsHoverBox.box.style.top=docViewTop+"px";	
			}else{
				zlsHoverBox.box.style.top="0px";	
			}
		}
	}*/
	if(zlsHoverBox.panel && zlsHoverBox.panel.style.display==="block"){
		return;
	}
	if(zlsHoverBoxNew.panel && zlsHoverBoxNew.panel.style.display==="block"){
		return;
	}
	if(zScrollApp.scrollTimeoutId !==false){
		clearTimeout(zScrollApp.scrollTimeoutId);
	}
	zScrollApp.scrollTimeoutId=setTimeout('zScrollApp.scrollFunction();',100);
};
zScrollApp.scrollFunction=function(){
	if(zScrollApp.disableFirstAjaxLoad){ return;}
	if(zScrollApp.disableNextScrollEvent){
		zScrollApp.disableNextScrollEvent=false;
		return;
	}
	//console.log("storing:"+$(window.frames["zSearchJsNewDivIframe"]).scrollTop()+":"+$(window.parent.frames["zSearchJsNewDivIframe"]).scrollTop());
	//zSetCookie({key:"zls-lsos",value:$(window.parent.frames["zSearchJsNewDivIframe"]).scrollTop(),futureSeconds:3600,enableSubdomains:false}); 
	if(zScrollApp.appDisabled) return;
	//alert('scroll');
	var docViewTop=$(window).scrollTop();
	
	/*if(zIsTouchscreen()){
		if(zlsHoverBox.panel.style.display=="block"){
			zlsHoverBox.box.style.top="0px";	
		}else{
			if(zIsAppleIOS()){
				zlsHoverBox.box.style.top=docViewTop+"px";	
			}else{
				zlsHoverBox.box.style.top="0px";	
			}
		}
	}*/
	if(zScrollApp.lastScrollPosition-docViewTop > $(window).height()){
		if(window.stop !== "undefined"){
			 window.stop();
		}else if(document.execCommand !== "undefined"){
			 document.execCommand("Stop", false);
		}
	}
	if(zScrollApp.lastScrollPosition !== -1 && zScrollApp.lastScrollPosition >=5 && Math.abs(zScrollApp.lastScrollPosition-docViewTop) <= zScrollApp.itemHeight/2){
	//alert('wha:'+zScrollApp.lastScrollPosition+":"+zScrollApp.disableNextScrollEvent);
		//return;
	}
	//alert('scroll'+docViewTop);
	clearTimeout(zScrollApp.scrollTimeoutId);
	clearTimeout(zScrollApp.resizeTimeoutId);
	zScrollApp.scrollTimeoutId=false;
	zScrollApp.resizeTimeoutId=false;
	zScrollApp.setBoxSizes();
	backupColCount=zScrollApp.colCount;
	zScrollApp.colCount=Math.floor((zScrollApp.scrollAreaWidth)/(zScrollApp.itemWidth+zScrollApp.itemMarginRight));
	var oldTop=Math.floor(docViewTop / (zScrollApp.itemHeight+zScrollApp.itemMarginBottom));
	var newTop=Math.floor(((oldTop * backupColCount ) / zScrollApp.colCount) * (zScrollApp.itemHeight+zScrollApp.itemMarginBottom));
	if(backupColCount !== zScrollApp.colCount){
		zScrollApp.bottomRowLimit=Math.max(5,Math.round(zScrollApp.totalListingCount/zScrollApp.colCount));
		zScrollApp.scrollAreaDiv.css("width",zScrollApp.colCount*(zScrollApp.itemWidth+zScrollApp.itemMarginRight)+"px");
		zScrollApp.scrollAreaDiv.css("height",Math.round(zScrollApp.totalListingCount/zScrollApp.colCount)*(zScrollApp.itemHeight+zScrollApp.itemMarginBottom)+"px"); 
		if(docViewTop !== newTop){
			//alert("old:"+docViewTop+" new:"+newTop);
			window.scrollTo(0, newTop);
			zScrollApp.lastScrollPosition=-1;
			zScrollApp.scrollTimeoutId=setTimeout('zScrollApp.scrollFunction();',100);
			//return;
			//return;
			backupColCount=zScrollApp.colCount;
			return;
		}
	}
	if(zScrollApp.lastScrollPosition !== -1 && backupColCount !== -1 && backupColCount !== zScrollApp.colCount){
		// set the scrollTop based on the top row last displayed.
		if(zScrollApp.scrollTimeoutId !==false){
			clearTimeout(zScrollApp.scrollTimeoutId);
		}
		zScrollApp.scrollTimeoutId=setTimeout('zScrollApp.scrollFunction();',100);
	//alert('fail'+docViewTop);
		return;
	}else{
		tempForceRowRedraw=false;
	}
	zScrollApp.lastScrollPosition=docViewTop;
	var docViewBottom = docViewTop + ($(window).height()-40);
	var offset=100;
	docViewTop-=offset;
	docViewBottom+=offset;
	
	var topPos=docViewTop-zScrollApp.scrollAreaPos.top;
	zScrollApp.topRow=Math.floor((topPos+offset)/(zScrollApp.itemHeight+zScrollApp.itemMarginBottom))-1;
	var footerSize=0;
	zScrollApp.bottomRow=Math.floor(((docViewBottom+offset+footerSize)-zScrollApp.scrollAreaPos.top)/(zScrollApp.itemHeight+zScrollApp.itemMarginBottom))+1;
		
	zScrollApp.newCount=0;
	zScrollApp.bottomRowLoadedBackup=zScrollApp.bottomRowLoaded;
	/*var allLoaded=false;
	if((1+zScrollApp.bottomRowLoadedBackup)*zScrollApp.colCount >= zScrollApp.maxItems){
		allLoaded=true;
	}
	if(!allLoaded){*/
		var tempStartRow=Math.floor(Math.min(0,zScrollApp.boxCount2)/zScrollApp.colCount);
		zScrollApp.drawVisibleRows(Math.max(0,zScrollApp.topRow), Math.max(1,zScrollApp.bottomRow));
	//}
	//alert('beforedoajax'+zScrollApp.newCount);
	if(zScrollApp.newCount !== 0){
		zScrollApp.offset=zScrollApp.firstNewBox;
		zScrollApp.doAjax(zScrollApp.newCount);
	}
	zScrollApp.hideRows(zScrollApp.topRow, zScrollApp.bottomRow);
};
zScrollApp.disableFirstAjaxLoad=false;
zScrollApp.loadSearchMap=function() {
	return;
	/*
    var myLatlng = new google.maps.LatLng(25.363882,-91.044922);
    var myOptions = {
      zoom: 12,
      center: myLatlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    zScrollApp.googleMapClass = new google.maps.Map(document.getElementById("zMapCanvas2"), myOptions);
    myLatlng = new google.maps.LatLng(25.363882,-91.044922);
    myOptions = {
      zoom: 18,
      center: myLatlng,
      mapTypeId: google.maps.MapTypeId.HYBRID
    }
    zScrollApp.googleMapClass2 = new google.maps.Map(document.getElementById("zMapCanvas4"), myOptions);
	*/
};
zScrollApp.addListingMarker=function(d,n){
	if(d.latitude[n] ==="0" || d.longitude[n] ==="0" || d.latitude[n] ==="" || d.longitude[n] ===""){
		return;	
	}
    var myLatlng = new google.maps.LatLng(d.latitude[n],d.longitude[n]);
    var marker = new google.maps.Marker({
        position: myLatlng, 
        map: zScrollApp.googleMapClass,
        title:d.listing_id[n]
    }); 
    var marker2 = new google.maps.Marker({
        position: myLatlng, 
        map: zScrollApp.googleMapClass2,
        title:d.listing_id[n]
    }); 
	zScrollApp.loadedMapMarkers[d.listing_id[n]]=[marker,marker2];
	zScrollApp.googleMapClass.setCenter(myLatlng);
	zScrollApp.googleMapClass2.setCenter(myLatlng);
		
};
zScrollApp.removeListingMarker=function(d){
	if(typeof google === "undefined" || typeof google.maps === "undefined" || typeof google.maps.LatLng === "undefined"){
		return;
	}
	if(typeof zScrollApp.loadedMapMarkers[d] !== "undefined"){
		zScrollApp.loadedMapMarkers[d][0].setMap(null);	
		zScrollApp.loadedMapMarkers[d][1].setMap(null);	
		delete zScrollApp.loadedMapMarkers[d];
	}
};
zScrollApp.setBoxSizes=function(){
	var d3=$(window).width();
	var mapWidth=Math.max(300,Math.round(d3*.25));
	var mapX=d3-mapWidth;
	var hideMap=false;
	if(mapX<200){
		mapX=d3;
		hideMap=true;	
		if(zScrollApp.scrollAreaMapDiv2 && zScrollApp.scrollAreaMapDiv2.style.display==="block"){
			zScrollApp.scrollAreaMapDiv2.style.display="none";
			zScrollApp.scrollAreaMapDiv4.style.display="none";
		}
	}else{
		if(zScrollApp.scrollAreaMapDiv2.style.display==="none"){
			zScrollApp.scrollAreaMapDiv2.style.display="block";
			zScrollApp.scrollAreaMapDiv4.style.display="block";
		}
	}
	if(zScrollApp.scrollAreaWidth===mapX) return;
	zScrollApp.scrollAreaWidth=mapX;
	if(zScrollApp.scrollAreaMapDiv2){
		zScrollApp.scrollAreaDiv2.style.width=mapX+"px";
		zScrollApp.scrollAreaMapDiv2.style.backgroundColor="#900";
		zScrollApp.scrollAreaMapDiv2.style.width=mapWidth+"px";
		zScrollApp.scrollAreaMapDiv2.style.height=Math.round(($(window).height()-40)/2)+"px";
		zScrollApp.scrollAreaMapDiv2.style.left=mapX+"px";
		zScrollApp.scrollAreaMapDiv3.style.height=Math.round(($(window).height()-40)/2)+"px";
		zScrollApp.scrollAreaMapDiv4.style.backgroundColor="#009";
		zScrollApp.scrollAreaMapDiv4.style.left=mapX+"px";
		zScrollApp.scrollAreaMapDiv4.style.width=mapWidth+"px";
		zScrollApp.scrollAreaMapDiv4.style.top=Math.round((($(window).height()-40)/2)+40)+"px";
		zScrollApp.scrollAreaMapDiv4.style.height=Math.round(($(window).height()-40)/2)+"px";
		zScrollApp.scrollAreaMapDiv5.style.height=Math.round(($(window).height()-40)/2)+"px";
	}
};

zScrollApp.startYTouch = 0;
zScrollApp.startXTouch = 0;
zScrollApp.startTouchCount = 0;
zScrollApp.listingSearchLoad=function() {
	var u=window.location.href;
	var p=u.indexOf("#");
	if(p !== -1){
		u=u.substr(p+1);
	}
	if(u.indexOf("/z/listing/instant-search/index") !== -1){
		zForceSearchJsScrollTop();
	}
	zScrollApp.lastScreenWidth=$(window).width();
	zScrollApp.itemWidth=Math.round((zScrollApp.lastScreenWidth-110)/3);
	zScrollApp.itemNegativeHeight=90;
	zScrollApp.itemHeight=Math.round((zScrollApp.itemWidth*0.68)+zScrollApp.itemNegativeHeight);
				/*setTimeout(function(){
					var h3 = parent.document.getElementById("zSearchJsNewDivIframe");
					h3.contentWindow
					$(h3).scrollTop(200);
				},1000);*/
				//return;
	if(zIsTouchscreen()){
		//zForceSearchJsScrollTop();
		setTimeout(function () {
			var b = document.body;
			b.addEventListener('touchstart', function (event) {
				zScrollApp.startYTouch = event.targetTouches[0].pageY;
				zScrollApp.startXTouch = event.targetTouches[0].pageX;
				zScrollApp.startTouchCount=event.targetTouches.length;
			});
			b.addEventListener('touchmove', function (event) {
				if(zScrollApp.startTouchCount !== 1 || event.targetTouches.length !== 1){ return true;}
				event.preventDefault();
				
				var posy = event.targetTouches[0].pageY;
				var h = parent.document.getElementById("zSearchJsNewDiv");
				var h3 = parent.document.getElementById("zSearchJsNewDivIframe");
				var sty = $(h3).contents().scrollTop();
				$(h3).contents().scrollTop(sty-(posy - zScrollApp.startYTouch));
			});
		}, 500);
	}
	//window.scrollTo(0,1);
	setTimeout(function(){ 
		var s=$(window).scrollTop();
		if(s !== zScrollApp.lastScrollTop){
			zScrollApp.lastScrollTop=s;
			zScrollApp.delayedScrollFunction();
		}
	}, 100);
	
	
	
	$(window).bind('scroll', zScrollApp.delayedScrollFunction);
	$(window).bind('resize', zScrollApp.delayedResizeFunction);
	/*$(document.body).bind('touchmove', zScrollApp.delayedScrollFunction);
	$(document.body).bind('touchend', function(){zScrollApp.disableNextScrollEvent=false;zScrollApp.lastScrollPosition=1;zScrollApp.scrollFunction();});
	$(document.body).bind('touchstart', zScrollApp.delayedScrollFunction);
	$(window).bind('orientationchange', zScrollApp.delayedResizeFunction);*/
	zScrollApp.scrollAreaDiv=$("#zScrollArea");
	zScrollApp.scrollAreaMapDiv=$("#zMapCanvas");
	zScrollApp.scrollAreaMapDiv2=$("#zMapCanvas3");
	zScrollApp.scrollAreaDiv2=document.getElementById("zScrollArea");
	zScrollApp.scrollAreaMapDiv2=document.getElementById("zMapCanvas");
	zScrollApp.scrollAreaMapDiv3=document.getElementById("zMapCanvas2");
	zScrollApp.scrollAreaMapDiv4=document.getElementById("zMapCanvas3");
	zScrollApp.scrollAreaMapDiv5=document.getElementById("zMapCanvas4");
	zScrollApp.scrollAreaPos=zScrollApp.scrollAreaDiv.position();
	zScrollApp.loadSearchMap();
	
	
	
};
function zListingResetSearch(){
	var s=$(window).width();
	zScrollApp.lastScreenWidth=s;
	/*if($(window).scrollTop() > 5){
		//alert('scroll to 1');
		window.scrollTo(0,1);
		setTimeout("zListingResetSearch();",100);
		return;
	}*/
	var scrollFunctionBackup=zScrollApp.scrollFunction;
	var delayedResizeFunctionBackup=zScrollApp.delayedResizeFunction;
	zScrollApp.templateCache=[];
	zScrollApp.scrollFunction=function(){};
	zScrollApp.delayedResizeFunction=function(){};
	zScrollApp.scrollAreaDiv.html("");
	zScrollApp.forceSmallHeight=50000;
	zScrollApp.newCount=0;
	zScrollApp.maxItems=1000;
	zScrollApp.firstNewBox=0;
	zScrollApp.boxCount2=0;
	//zScrollApp.colCount=-1;
	zScrollApp.itemMarginRight=30;
	zScrollApp.itemMarginBottom=30;
	//zScrollApp.itemWidth=160;
	//zScrollApp.itemHeight=170;
	zScrollApp.itemWidth=Math.round((zScrollApp.lastScreenWidth-110)/3);
	zScrollApp.itemNegativeHeight=90;
	zScrollApp.itemHeight=Math.round((zScrollApp.itemWidth*0.68)+zScrollApp.itemNegativeHeight);
	//zScrollApp.lastScrollPosition=-1;
	zScrollApp.arrVisibleBoxes=new Array();
	zScrollApp.disableNextScrollEvent=false;
	zScrollApp.bottomRowLoaded=0;
	if(zScrollApp.firstAjaxRequest){
		window.scrollTo(0,1);
		zScrollApp.lastScrollPosition=-1;
		zScrollApp.colCount=-1;
	}
	/*
	zScrollApp.scrollAreaDiv=false;
	zScrollApp.scrollAreaPos=false;
	zScrollApp.scrollAreaMapDiv=false;
	*/
	zScrollApp.scrollFunction=scrollFunctionBackup;
	zScrollApp.delayedResizeFunction=delayedResizeFunctionBackup;
	zScrollApp.veryFirstSearchLoad=true;
	//zScrollApp.listingSearchLoad();
	zScrollApp.scrollFunction();
}
zScrollApp.ajaxProcessError=function(r){
	//alert("Failed to search listings. Please try again later.");
};
zScrollApp.showDebugger=function(m){
	document.getElementById("debugInfo").style.display="block";
	document.getElementById("debugInfoTextArea").value+=m;
	
};
zScrollApp.processAjax=function(r){
	//zScrollApp.showDebugger(r);
	var r=eval('(' + r + ')');
	var i2=0;
	if(r.offset>0){
		i2=(r.offset);
	}
	
	//document.getElementById("debugDivDiv").innerHTML="query:"+r.query+"\n\n";
	var itemTop=((i2*zScrollApp.itemHeight)+(i2*zScrollApp.itemMarginBottom));
	if(zScrollApp.firstAjaxRequest){
		setMLSCount2(r.count);
		zScrollApp.totalListingCount=Math.min(zScrollApp.maxItems, r.count);
		zScrollApp.bottomRowLimit=(Math.round(zScrollApp.totalListingCount/zScrollApp.colCount));
		zScrollApp.scrollAreaDiv.css("width",zScrollApp.colCount*(zScrollApp.itemWidth+zScrollApp.itemMarginRight)+"px");
		zScrollApp.scrollAreaDiv.css("height",Math.round(zScrollApp.totalListingCount/zScrollApp.colCount)*(zScrollApp.itemHeight+zScrollApp.itemMarginBottom)+"px");
		zScrollApp.curListingCount=r.count;
		zScrollApp.firstAjaxRequest=false;
		for(var i=0;i<zScrollApp.boxCount2;i++){
			if(i<r.count){
				if(typeof zScrollApp.arrVisibleBoxes["row"+i] === "object"){
					zScrollApp.arrVisibleBoxes["row"+i].visible=true;
				}
				if(document.getElementById("row"+i)){
					document.getElementById("row"+i).style.display="block";
				}
			}else{
				if(typeof zScrollApp.arrVisibleBoxes["row"+i] === "object"){
					zScrollApp.arrVisibleBoxes["row"+i].visible=false;
				}
				if(document.getElementById("row"+i)){
					document.getElementById("row"+i).style.display="none";
				}
			}
		}
	}
	
	var g=document.getElementById('zlsGrid');
	var d="";
	var f=0;
	for(var i=0;i<r.url.length;i++){
		if(r.url[i] === ""){
			 continue;
		}
		if(f>=zScrollApp.colCount){
			f=0;	
			i2++;
			itemTop=((i2*zScrollApp.itemHeight)+(i2*zScrollApp.itemMarginBottom));
		}
		var itemLeft=((f*zScrollApp.itemWidth)+(f*zScrollApp.itemMarginRight));
		var cc=(r.offset)+i;
		if('row'+cc in zScrollApp.templateCache){
			d=zScrollApp.templateCache['row'+cc];	
		}else{
			d=zScrollApp.buildTemplate(r, i);	
			zScrollApp.templateCache['row'+cc]=d;
		}
		//zScrollApp.addListingMarker(r,i);
		zScrollApp.arrListingId[cc]=r.listing_id[i];
		$('#row'+cc).html(d);
		
		var cc1=document.getElementById("row"+cc);
		if(cc1){
			cc1.listing_id=r.listing_id[i];
			cc1.zlsData=r;
			cc1.zlsIndex=i;
			cc1.boxOffset=cc;
		}
		$('#row'+cc).bind('mouseover', function(obj){ 
			//this.style.backgroundColor="#EEE";
			//zScrollApp.scrollAreaMapDiv2.style.display="block";
			//zScrollApp.scrollAreaMapDiv4.style.display="block";
			//zScrollApp.setBoxSizes();
			
			// map temp removed
			//zScrollApp.addListingMarker(this.zlsData,this.zlsIndex);
		});
	
		$('#row'+cc).bind('mouseout', function(obj){ 
			//this.style.backgroundColor="#FFF";
			// map temp removed
			//zScrollApp.removeListingMarker(this.zlsData.listing_id[this.zlsIndex]);
			
			// not used
			//zScrollApp.scrollAreaMapDiv2.style.display="none";
			//zScrollApp.scrollAreaMapDiv4.style.display="none";
		});
		f++;
	}
	var u=window.parent.location.href;	var p=u.indexOf("#");	if(p !== -1){		u=u.substr(p+1);	}
	if(u.indexOf("/z/listing/instant-search/index") !== -1){
		if("/z/listing/search-js/index?"+r.qs === zGetCookie("zls-lsurl")){
			if(zScrollApp.veryFirstSearchLoad){
				var offset=zGetCookie("zls-lsos");
				if(offset !== ""){
					//console.log("trying to move to:"+offset);
					$(window).scrollTop(parseInt(offset));
				}
			}else{
				var offset=$(window).scrollTop();	
				//console.log("unable to move - already loaded:"+offset);
			}
			zSetCookie({key:"zls-lsos",value:offset,futureSeconds:3600,enableSubdomains:false}); 
		}else{
			zSetCookie({key:"zls-lsos",value:0,futureSeconds:3600,enableSubdomains:false}); 
		}
	}else{
		var offset=$(window).scrollTop();
		zSetCookie({key:"zls-lsos",value:offset,futureSeconds:3600,enableSubdomains:false}); 
	}
	zSetCookie({key:"zls-lsurl",value:"/z/listing/search-js/index?"+r.qs,futureSeconds:3600,enableSubdomains:false}); 
	if(zScrollApp.veryFirstSearchLoad){
		zScrollApp.veryFirstSearchLoad=false;
		/*if(zIsTouchscreen()){
			setTimeout(function(){
			window.scrollTo(0,1);
			},500);
			zScrollApp.disableNextScrollEvent=true;
		}*/
	}
};
zScrollApp.imageWidth=0;
zScrollApp.imageHeight=0;
zScrollApp.doAjax=function(perpage, customCallback){
	zSearchFormChanged=true;
	var formName="zMLSSearchForm"; 
	var v1=document.getElementById("search_map_lat_blocks");
	/*if(typeof zMapCoorUpdateV3 !== "undefined"){// && v1 && v1.value==""){ 
		 return "0";
	} */
	if(typeof zFormData[formName] === "undefined") return;
	zFormData[formName].ajax=true;
	zFormData[formName].ignoreOldRequests=false;
	if(typeof customCallback !== "undefined"){
		zFormData[formName].onLoadCallback=customCallback;
	}else{
		zFormData[formName].onLoadCallback=zScrollApp.processAjax;
	}
	zFormData[formName].onErrorCallback=zScrollApp.ajaxProcessError;
	zFormData[formName].successMessage=false;
	
	var v="/z/listing/search/g?of="+zScrollApp.offset+"&perpage="+(perpage)+"&debugSearchForm=1&pw="+zScrollApp.itemWidth+"&ph="+(zScrollApp.itemHeight-zScrollApp.itemNegativeHeight)+"&pa=1&x_ajax_id="+zScrollApp.offset+"_"+Math.random();
	var v2=v;
	if(zScrollApp.firstAjaxRequest){
		v+="&first=1";	
	}
	zFormData[formName].action=v;
	zScrollApp.offset+=perpage;
	zFormSubmit(formName,false,true);
	zFormData[formName].action=v2;
	return false;
};
zScrollApp.buildTemplate=function(d, n){
	var t=[];
	t.push('<div class="zls-grid-1" style="width:'+zScrollApp.itemWidth+'px; height:'+(zScrollApp.itemHeight)+'px;"><div class="zls-grid-2">');
	if(d.photo1[n] !== ''){
		t.push('<img src="'+d.photo1[n]+'" onerror="zImageOnError(this);" width="'+zScrollApp.itemWidth+'" height="'+(zScrollApp.itemHeight-zScrollApp.itemNegativeHeight)+'" alt="Image1" />');
	}else{
		t.push('&nbsp;');	
	}
	t.push('<\/div><div class="zls-grid-3">');
	t.push('<div class="zls-buttonlink" style="float:right; position:relative; margin-top:-38px;"><a href="#" onclick="parent.zContentTransition.gotoURL(\''+d.url[n]+'\');">View</a></div>');
	if(d.price[n] !== "0"){
		t.push('<strong>'+d.price[n]+'<\/strong><br />');
	}
	var bset=false;
	if(d.bedrooms[n] !== "0" && d.bedrooms[n] !== ""){
		bset=true;
		t.push(d.bedrooms[n]+" bed");
	}
	if(d.bedrooms[n] !== "0" && d.bedrooms[n] !== ""){
		if(bset){
			t.push(", ");	
		}
		bset=true;
		t.push(d.bathrooms[n]+" bath");
	}
	if(bset){
		t.push('<br />');
	}else if(d.square_footage[n] !== "" && d.square_footage[n] !== "0"){
		t.push(d.square_footage[n]+' sqft<br />');	
	}
	if(d.type[n] !== ""){
		t.push(d.type[n]+'<br />');	
	}
	if(d.city[n] !== ""){
		t.push(d.city[n]+'<br />');	
	}
	return t.join("");
};

var zlsHoverBoxNew={
	box: false,
	boxPosition:false,
	panelPosition:false,
	button:{},
	displayType:"grid",
	changeDisplayType: function(g, g2){
		if(zlsHoverBoxNew.button.grid.id===g.target.id){
			zlsHoverBoxNew.displayType="grid";
			zlsHoverBoxNew.button.grid.className=g.target.id+"-selected";
			//zlsHoverBoxNew.button.map.className="";
			//zlsHoverBoxNew.button.list.className="";
		}else if(zlsHoverBoxNew.button.list.id===g.target.id){
			zlsHoverBoxNew.displayType="list";
			//zlsHoverBoxNew.button.list.className=g.target.id+"-selected";
			//zlsHoverBoxNew.button.map.className="";
			zlsHoverBoxNew.button.grid.className="";
		}else if(zlsHoverBoxNew.button.map.id===g.target.id){
			zlsHoverBoxNew.displayType="map";
			//zlsHoverBoxNew.button.map.className=g.target.id+"-selected";
			zlsHoverBoxNew.button.grid.className="";
			//zlsHoverBoxNew.button.list.className="";
		}
		var futureSeconds=3600*7;
		zSetCookie({key:"zlsHoverBoxNewDisplayType",value:zlsHoverBoxNew.displayType,futureSeconds:futureSeconds});
		if(!zScrollApp.disableFirstAjaxLoad){
			zlsHoverBoxNew.showListings();
		}
		return false;
	},
	loaded:false,
	debugInput:false,
	load:function(){
		if(zlsHoverBoxNew.loaded) return;
		zlsHoverBoxNew.loaded=true;
		zlsHoverBoxNew.debugInput=document.getElementById('dt21');
		zlsHoverBoxNew.box=document.getElementById("zls-hover-box");
		zlsHoverBoxNew.panel=document.getElementById("zls-hover-box-panel");
		zlsHoverBoxNew.panelInner=document.getElementById("zls-hover-box-panel-inner");
		zlsHoverBoxNew.button.refine=document.getElementById("zls-hover-box-refine-button");
		zlsHoverBoxNew.button.grid=document.getElementById("zls-hover-box-grid-button");
		//zlsHoverBoxNew.button.list=document.getElementById("zls-hover-box-list-button");
		//zlsHoverBoxNew.button.map=document.getElementById("zls-hover-box-map-button");
		zlsHoverBoxNew.button.refine.onclick=zlsHoverBoxNew.togglePanel;
		//zlsHoverBoxNew.button.grid.onclick=zlsHoverBoxNew.changeDisplayType;
		//zlsHoverBoxNew.button.list.onclick=zlsHoverBoxNew.changeDisplayType;
		//zlsHoverBoxNew.button.map.onclick=zlsHoverBoxNew.changeDisplayType;
		var t=zGetCookie("zlsHoverBoxNewDisplayType");
		if(t !== ""){
		zlsHoverBoxNew.displayType=t;
		}
		zlsHoverBoxNew.debugInput.value="";
		//zlsHoverBoxNew.debugInput.value+="CookieDisplayType:"+zGetCookie("zlsHoverBoxNewDisplayType")+"\n";
		zlsHoverBoxNew.changeDisplayType({target:zlsHoverBoxNew.button[zlsHoverBoxNew.displayType]});
	},
	showListings: function(){
		zScrollApp.firstAjaxRequest=true;
		zScrollApp.appDisabled=false;
		zlsHoverBoxNew.closePanel();
		zlsHoverBoxNew.button.refine.innerHTML="Refine Search";
		zListingResetSearch();
	},
	closePanel: function(){
		if(zlsHoverBoxNew.panel.style.display==="block"){
			//zScrollApp.forceSmallHeight=50000;
			//drawVisibleRows(0,0);
			zScrollApp.scrollAreaDiv2.style.display="block";
			document.getElementById('zMapCanvas').style.display="block";
			document.getElementById('zMapCanvas3').style.display="block";
			var tempObj={'margin-top':-(zlsHoverBoxNew.panelPosition.height)+zlsHoverBoxNew.boxPosition.height};
			$(zlsHoverBoxNew.panel).animate(tempObj,'fast','easeInExpo', function(){zlsHoverBoxNew.panel.style.display="none"; });
		}
	},
	togglePanel: function(){
		if(zlsHoverBoxNew.panel.style.display==="block" && !zScrollApp.disableFirstAjaxLoad){
			zlsHoverBoxNew.showListings();
		}else{
			if(zIsTouchscreen()){
				zlsHoverBoxNew.box.style.top="0px";	
			}
			zlsHoverBoxNew.button.refine.innerHTML="Show Listings";
			zlsHoverBoxNew.panel.style.display="block";
			zlsHoverBoxNew.resizePanel();
			
			// disable the listing display
			zScrollApp.appDisabled=true;
			zScrollApp.scrollAreaDiv2.style.display="none";
			document.getElementById('zMapCanvas').style.display="none";
			document.getElementById('zMapCanvas3').style.display="none";
			
			//zScrollApp.forceSmallHeight=zWindowSize.height-zlsHoverBoxNew.boxPosition.height-30;
			//drawVisibleRows(0,0);
			
			if(zIsTouchscreen() || zScrollApp.disableFirstAjaxLoad){
				zlsHoverBoxNew.panel.style.marginTop=zlsHoverBoxNew.boxPosition.height+"px";
				window.scrollTo(0,1);
			}else{/**/
				zlsHoverBoxNew.panel.style.marginTop=(-(zlsHoverBoxNew.panelPosition.height)+zlsHoverBoxNew.boxPosition.height)+"px";
				$(zlsHoverBoxNew.panel).animate({"margin-top":zlsHoverBoxNew.boxPosition.height},'fast','easeInExpo');
			}
		}
		return false;
	},
	lastBoxHeight:0,
	resizePanel: function(){
		if(!zlsHoverBoxNew.loaded) zlsHoverBoxNew.load();
		var nw=zWindowSize.width-10;
		var w=Math.min(1100,nw);
		var newLeft=Math.round((nw-w)/2);
		if(w>=1100){
			zlsHoverBoxNew.box.style.width=w+"px";
			zlsHoverBoxNew.box.style.marginLeft="-"+Math.floor(w/2)+"px";
		}else{
			zlsHoverBoxNew.box.style.width="97%";
			zlsHoverBoxNew.box.style.marginLeft="-49%";
		}
		//zlsHoverBoxNew.box.style.width=w+"px";
		zlsHoverBoxNew.box.style.display="block";
		zlsHoverBoxNew.boxPosition=zGetAbsPosition(zlsHoverBoxNew.box);
		if(zlsHoverBoxNew.panel.style.display==="block"){
			var nw=zWindowSize.width-10;
			var w=Math.min(1100,nw);
			var newLeft=Math.round((nw-w)/2);
			if(w>=1100){
				if(zlsHoverBoxNew.panel.style.width !== "1100px"){
					zlsHoverBoxNew.panel.style.width=w+"px";
					zlsHoverBoxNew.panel.style.marginLeft="-"+Math.floor(w/2)+"px";
				}
			}else{
				zlsHoverBoxNew.panel.style.width="97%";
				zlsHoverBoxNew.panel.style.marginLeft="-49%";
			}
			zlsHoverBoxNew.panelPosition=zGetAbsPosition(zlsHoverBoxNew.panel);
			//zlsHoverBoxNew.panelInnerPosition=zGetAbsPosition(zlsHoverBoxNew.panel);
			//var h=Math.min(zlsHoverBoxNew.panelInnerPosition.height,zWindowSize.height-zlsHoverBoxNew.boxPosition.height-30);
			if(zIsTouchscreen()){
				if(zIsAppleIOS()){
					zlsHoverBoxNew.box.style.position="absolute";
				}
				zlsHoverBoxNew.panel.style.position="absolute";
				zlsHoverBoxNew.panel.style.height="auto";
			}else{
				zlsHoverBoxNew.panel.style.height="90%";//h+"px";
			}
			if(zlsHoverBoxNew.lastBoxHeight !== 0 && zlsHoverBoxNew.lastBoxHeight !== zlsHoverBoxNew.boxPosition.height){
				zlsHoverBoxNew.panel.style.marginTop=(zlsHoverBoxNew.boxPosition.height)+"px";
			}
			zlsHoverBoxNew.lastBoxHeight=zlsHoverBoxNew.boxPosition.height;
				
			//alert(zlsHoverBoxNew.panelPosition.height+":"+zlsHoverBoxNew.boxPosition.height+":"+zlsHoverBoxNew.panel.style.marginTop);
		}
	}
};


var zSearchFormObj=new Object();
zSearchFormObj.colCount=-1;
zSearchFormObj.delayedResizeFunction2=function(){
	var d1=document.getElementById('formDiv99');
	var nh=$(window).height();
	var nw=Math.min(965,$(window).width())-5;
	//d1.style.height=nh+"px";
	//d1.style.width=nw+"px";
	if(typeof zSearchFormObj.colmain1 === "undefined" || zSearchFormObj.colmain1===null) return;
	if(nw>800){
		zSearchFormObj.colmain1.style.width=Math.floor((nw/2)-55)+"px";//"48%";
		zSearchFormObj.colmain2.style.width=Math.floor((nw/2)-60)+"px";//"48%";
		if(zSearchFormObj.colCount === 4) return;
		zSearchFormObj.colCount=4;
		zSearchFormObj.col1.style.width="45%";
		zSearchFormObj.col2.style.width="45%";
		zSearchFormObj.col3.style.width="45%";
		zSearchFormObj.col4.style.width="45%";
		zSearchFormObj.colr1.style.width="45%";
		zSearchFormObj.colr2.style.width="45%";
		zSearchFormObj.colr3.style.width="45%";
		zSearchFormObj.colr4.style.width="45%";
		zSearchFormObj.col1.style.paddingRight="5%";
		zSearchFormObj.colr1.style.paddingRight="5%";
		zSearchFormObj.col2.style.paddingRight="5%";
		zSearchFormObj.colr2.style.paddingRight="5%";
		zSearchFormObj.col3.style.paddingRight="5%";
		zSearchFormObj.colr3.style.paddingRight="5%";
		zSearchFormObj.col4.style.paddingRight="0%";
		zSearchFormObj.colr4.style.paddingRight="0%";
		
		$(zSearchFormObj.col6).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr1).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr2).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col7).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col5).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.col3).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.col4).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.colr3).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.colr4).appendTo(zSearchFormObj.colmain2);
	}else if(nw<=800 && nw >= 660){
		zSearchFormObj.colmain1.style.width=(Math.floor((nw/3)*2)-50)+"px";//"63%";
		zSearchFormObj.colmain2.style.width=Math.floor((nw/3)-50)+"px";//"30%";
		if(zSearchFormObj.colCount === 3) return;
		$(zSearchFormObj.col5).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.col3).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.col4).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.col6).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr1).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr2).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col7).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr3).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr4).appendTo(zSearchFormObj.colmain1);
		zSearchFormObj.colCount=3;
		zSearchFormObj.col1.style.width="45%";
		zSearchFormObj.col2.style.width="45%";
		zSearchFormObj.col3.style.width="95%";
		zSearchFormObj.col4.style.width="95%";
		zSearchFormObj.colr1.style.width="45%";
		zSearchFormObj.colr2.style.width="45%";
		zSearchFormObj.colr3.style.width="45%";
		zSearchFormObj.colr4.style.width="45%";
		zSearchFormObj.col3.style.paddingRight="0%";
		zSearchFormObj.colr3.style.paddingRight="5%";
		zSearchFormObj.col4.style.paddingRight="0%";
		zSearchFormObj.colr4.style.paddingRight="5%";
		
	}else if(nw<=659 && nw >= 410){
		if(zSearchFormObj.colCount === 2) return;
		$(zSearchFormObj.col5).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col3).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col4).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col6).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr1).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr2).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col7).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr3).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr4).appendTo(zSearchFormObj.colmain1);
		zSearchFormObj.colCount=2;
		zSearchFormObj.col1.style.width="45%";
		zSearchFormObj.col2.style.width="45%";
		zSearchFormObj.col3.style.width="45%";
		zSearchFormObj.col4.style.width="45%";
		zSearchFormObj.colr1.style.width="45%";
		zSearchFormObj.colr2.style.width="45%";
		zSearchFormObj.colr3.style.width="45%";
		zSearchFormObj.colr4.style.width="45%";
		zSearchFormObj.col1.style.paddingRight="5%";
		zSearchFormObj.colr1.style.paddingRight="5%";
		zSearchFormObj.col2.style.paddingRight="5%";
		zSearchFormObj.colr2.style.paddingRight="5%";
		zSearchFormObj.col3.style.paddingRight="5%";
		zSearchFormObj.colr3.style.paddingRight="5%";
		zSearchFormObj.col4.style.paddingRight="5%";
		zSearchFormObj.colr4.style.paddingRight="5%";
		
		zSearchFormObj.colmain1.style.width="100%";
		zSearchFormObj.colmain2.style.width="100%";
	}else if(nw<=409){
		if(zSearchFormObj.colCount === 1) return;
		$(zSearchFormObj.col5).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col3).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col4).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col6).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr1).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr2).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col7).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr3).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr4).appendTo(zSearchFormObj.colmain1);
		zSearchFormObj.colCount=1;
		zSearchFormObj.col1.style.width="95%";
		zSearchFormObj.col2.style.width="95%";
		zSearchFormObj.col3.style.width="100%";
		zSearchFormObj.col4.style.width="100%";
		zSearchFormObj.colr1.style.width="95%";
		zSearchFormObj.colr2.style.width="95%";
		zSearchFormObj.colr3.style.width="100%";
		zSearchFormObj.colr4.style.width="100%";
		zSearchFormObj.col1.style.paddingRight="5%";
		zSearchFormObj.colr1.style.paddingRight="5%";
		zSearchFormObj.col2.style.paddingRight="5%";
		zSearchFormObj.colr2.style.paddingRight="5%";
		zSearchFormObj.col3.style.paddingRight="0%";
		zSearchFormObj.colr3.style.paddingRight="0%";
		zSearchFormObj.col4.style.paddingRight="0%";
		zSearchFormObj.colr4.style.paddingRight="0%";
		
		zSearchFormObj.colmain1.style.width="100%";
		zSearchFormObj.colmain2.style.width="100%";
		
	}
	
	if ($.browser.msie  && parseInt($.browser.version, 10) === 7) {
		if(zSearchFormObj.col1.style.paddingRight!=="0%") zSearchFormObj.col1.style.paddingRight="1%";
		if(zSearchFormObj.colr1.style.paddingRight!=="0%") zSearchFormObj.colr1.style.paddingRight="1%";
		if(zSearchFormObj.col2.style.paddingRight!=="0%") zSearchFormObj.col2.style.paddingRight="1%";
		if(zSearchFormObj.colr2.style.paddingRight!=="0%") zSearchFormObj.colr2.style.paddingRight="1%";
		if(zSearchFormObj.col3.style.paddingRight!=="0%") zSearchFormObj.col3.style.paddingRight="1%";
		if(zSearchFormObj.colr3.style.paddingRight!=="0%") zSearchFormObj.colr3.style.paddingRight="1%";
		if(zSearchFormObj.col4.style.paddingRight!=="0%") zSearchFormObj.col4.style.paddingRight="1%";
		if(zSearchFormObj.colr4.style.paddingRight!=="0%") zSearchFormObj.colr4.style.paddingRight="1%";
	}
};
zSearchFormObj.loadForm=function(){
	if(document.getElementById('zMLSSearchFormLayout3') === null){
		return;
	}
	zSetFullScreenMobileApp();
	$('script').remove();
	zSearchFormObj.col1=document.getElementById('zMLSSearchFormLayout3');
	zSearchFormObj.col2=document.getElementById('zMLSSearchFormLayout9');
	zSearchFormObj.col3=document.getElementById('zMLSSearchFormLayout8');
	zSearchFormObj.col4=document.getElementById('zMLSSearchFormLayout10');	
	
	zSearchFormObj.colr1=document.getElementById('zMLSSearchFormLayout15');
	zSearchFormObj.colr2=document.getElementById('zMLSSearchFormLayout4');
	zSearchFormObj.colr3=document.getElementById('zMLSSearchFormLayout12');
	zSearchFormObj.colr4=document.getElementById('zMLSSearchFormLayout13');	
	zSearchFormObj.colmain1=document.getElementById('zMLSSearchFormLayout2');	
	zSearchFormObj.colmain2=document.getElementById('zMLSSearchFormLayout5');	
	zSearchFormObj.col5=document.getElementById('zMLSSearchFormLayout6');	
	//zSearchFormObj.col8=document.getElementById('zMLSSearchFormLayout7');	
	zSearchFormObj.col6=document.getElementById('zMLSSearchFormLayout16');	
	zSearchFormObj.col7=document.getElementById('zMLSSearchFormLayout17');	
	//$(window).bind('scroll', scrollFunction);
	zSearchFormObj.delayedResizeFunction2();
	$(window).bind('resize', zSearchFormObj.delayedResizeFunction2);
	
};

zArrLoadFunctions.push({functionName:zSearchFormObj.loadForm});

var zlsHoverBox={
	box: false,
	boxPosition:false,
	panelPosition:false,
	button:{},
	displayType:"detail",
	firstLoad:true,
	changeDisplayType: function(g, g2){
		if(zlsHoverBox.button.grid.id===g.target.id){
			zlsHoverBox.displayType="grid";
			zlsHoverBox.button.grid.className=g.target.id+"-selected";
			zlsHoverBox.button.map.className="";
			zlsHoverBox.button.detail.className="";
			zlsHoverBox.button.list.className="";
			if(!zFunctionLoadStarted){
				document.getElementById('search_result_layout').selectedIndex=2;
				document.zMLSSearchForm.submit();
			}
		}else if(zlsHoverBox.button.list.id===g.target.id){
			zlsHoverBox.displayType="list";
			zlsHoverBox.button.list.className=g.target.id+"-selected";
			zlsHoverBox.button.map.className="";
			zlsHoverBox.button.detail.className="";
			zlsHoverBox.button.grid.className="";
			if(!zFunctionLoadStarted){
				document.getElementById('search_result_layout').selectedIndex=1;
				document.zMLSSearchForm.submit();
			}
		}else if(zlsHoverBox.button.map.id===g.target.id){
			zlsHoverBox.displayType="map";
			zlsHoverBox.button.map.className=g.target.id+"-selected";
			zlsHoverBox.button.detail.className="";
			zlsHoverBox.button.grid.className="";
			zlsHoverBox.button.list.className="";
		}else if(zlsHoverBox.button.detail.id===g.target.id){
			zlsHoverBox.displayType="detail";
			zlsHoverBox.button.map.className="";
			zlsHoverBox.button.detail.className=g.target.id+"-selected";
			zlsHoverBox.button.grid.className="";
			zlsHoverBox.button.list.className="";
			if(!zFunctionLoadStarted){
				document.getElementById('search_result_layout').selectedIndex=0;
				document.zMLSSearchForm.submit();
			}
		}
		//zSetCookie({key:"zlsHoverBoxDisplayType",value:zlsHoverBox.displayType,futureSeconds:60*60*7});
		//zlsHoverBox.showListings();
		return false;
	},
	showListings: function(){
		zScrollApp.appDisabled=false;
		zListingResetSearch();
		zlsHoverBox.closePanel();
		//zlsHoverBox.button.refine.innerText="Refine Search";
	}
};
zlsHoverBox.load=function(){
	var d=document.getElementById('zlsHoverBoxDisplayType');
	if(d === null){ return;}
	zlsHoverBox.displayType=d.value;
	zlsHoverBox.loaded=true;
	zlsHoverBox.debugInput=document.getElementById('dt21');
	zlsHoverBox.box=document.getElementById("zls-hover-box");
	zlsHoverBox.panel=document.getElementById("zls-hover-box-panel");
	zlsHoverBox.panelInner=document.getElementById("zls-hover-box-panel-inner");
	//zlsHoverBox.button.refine=document.getElementById("zls-hover-box-refine-button");
	zlsHoverBox.button.grid=document.getElementById("zls-hover-box-grid-button");
	zlsHoverBox.button.list=document.getElementById("zls-hover-box-list-button");
	zlsHoverBox.button.detail=document.getElementById("zls-hover-box-detail-button");
	zlsHoverBox.button.map=document.getElementById("zls-hover-box-map-button");
	//zlsHoverBox.button.refine.onclick=zlsHoverBox.togglePanel;
	zlsHoverBox.button.grid.onclick=function(){zlsHoverBox.changeDisplayType({target:zlsHoverBox.button.grid}); return false;};
	zlsHoverBox.button.list.onclick=function(){zlsHoverBox.changeDisplayType({target:zlsHoverBox.button.list}); return false;};
	zlsHoverBox.button.detail.onclick=function(){zlsHoverBox.changeDisplayType({target:zlsHoverBox.button.detail}); return false;};
	zlsHoverBox.button.map.onclick=function(){zlsHoverBox.changeDisplayType({target:zlsHoverBox.button.map}); return false;};
	zlsHoverBox.changeDisplayType({target:zlsHoverBox.button[zlsHoverBox.displayType]});
};
zArrLoadFunctions.push({functionName:zlsHoverBox.load});
/*
function zListingDisplayHelpBox(){
	document.write('<a href="javascript:zToggleDisplay(\'zListingHelpDiv\');">Need help using search?</a><br />'+
	'<div id="zListingHelpDiv" style="display:none; border:1px solid #990000; padding:10px; padding-top:0px;">'+
	'<p style="font-size:14px; font-weight:bold;">Search Directions:</p>'+
	'<p>Click on one of the search options on the sidebar and use the text fields, sliders and check boxes to enter your search data.  After you are done, click "Search MLS" and the results will load on the right. </p>'+
	'<p><strong>City Search:</strong> Start typing a city into the box and our system will automatically show you a list of matching cities.  Select each city you wish to include in the search by using the arrow keys up and down.  Please the enter key or left click with your mouse to confirm the selection.  To remove a city, click the "X" button to the left of the city name. Only cities matching the ones in our system may be selected.</p>'+
	'<p>After typing an entry, click "Update Results" to update your search. </p>'+
	'<p>You can select or type as many options as you want.</p>'+
	'<p>Your search will automatically show the # of matching listings as you update each search field.</p>'+
	'<p>After searching, only the available options will appear.  To reveal more options again, try unselecting or extending the range for your next search.</p>'+
	'</div>');
}*/

if (typeof(Number.prototype.toRad) === "undefined") {
  Number.prototype.toRad = function() {
    return this * Math.PI / 180;
  }
}
function zGetMapDistance(lat1, lon1, lat2, lon2){
	var R = 6371; // km
	var dLat = (lat2-lat1).toRad();
	var dLon = (lon2-lon1).toRad();
	var lat1 = lat1.toRad();
	var lat2 = lat2.toRad();
	
	var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
			Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
	var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
	var d = R * c;	
	return d;
}
function zGeocodeAddress() {
	if(arrAddress.length <= curIndex) return;
	if(debugajaxgeocoder) f1.value+="run geocode: "+arrAddress[curIndex]+" for listing_id="+arrListingId[curIndex]+"\n";
		geocoder.geocode( { 'address': arrAddress[curIndex]+" "+arrAddressZip[curIndex]}, function(results, status) {
		var r="";
		if (status == google.maps.GeocoderStatus.OK) {
			var a1=new Array();
			for(var i=0;i<results.length;i++){
				var a2=new Array();
				a2[0]=results[i].types.join(",");
				if(a2[0]=="street_address"){// && arrAddressZipLat[curIndex] != 0 && arrAddressZipLong[curIndex] != 0){
					a2[1]=results[i].formatted_address;
					a2[2]=results[i].geometry.location.lat()
					a2[3]=results[i].geometry.location.lng();
					a2[4]=results[i].geometry.location_type;
					var a3=a2.join("\t");
					/*var k=zGetMapDistance(arrAddressZipLat[curIndex], arrAddressZipLong[curIndex], a2[2], a2[3]);
					if(k >= 50){
						// the distance is beyond reasonable - this one is invalid
					}else{*/
						a1.push(a3);  
					//}
					break;	
				}
			}
			r=a1.join("\n");
			if(debugajaxgeocoder) f1.value+="Result:"+r+"\n";
		} else if(status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT || status == google.maps.GeocoderStatus.REQUEST_DENIED){
			// serious error condition
			stopGeocoding=true; 
		}
		var curStatus="";
		if(status == google.maps.GeocoderStatus.OK){
			curStatus="OK";
		}else if(status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT){
			curStatus="OVER_QUERY_LIMIT";
		}else if(status == google.maps.GeocoderStatus.REQUEST_DENIED){
			curStatus="REQUEST_DENIED";
		}else if(status == google.maps.GeocoderStatus.ZERO_RESULTS){
			curStatus="ZERO_RESULTS";
		}else if(status == google.maps.GeocoderStatus.INVALID_REQUEST){
			curStatus="INVALID_REQUEST";
		}else if(status == 'ERROR'){
			stopGeocoding=true;
			// This is an undocumented problem with google's API. We must stop geocoding and wait for a new user with a fresh copy of google's API downloaded that hopefully works.
			return;
		}else{
			curStatus=status;
		}
		if(debugajaxgeocoder) f1.value+='geocode done for listing_id='+arrListingId[curIndex]+" with status="+curStatus+"\n";
		var debugurlstring="";
		if(debugajaxgeocoder){
			debugurlstring="&debugajaxgeocoder=1";
		}
		$.ajax({
			type: "post",
			url: "/z/listing/ajax-geocoder/save?"+debugurlstring,
			data:{ results: r, listing_id: arrListingId[curIndex], address: arrAddress[curIndex], zip: arrAddressZip[curIndex], status: curStatus },
			dataType:"text",
			success: function(data){
				if(debugajaxgeocoder) f1.value+="Data saved with status="+data+"\n";
			}
		}); 
		curIndex++;
		if(curIndex<arrAddress.length && !stopGeocoding){
			setTimeout('zTimeoutGeocode();',1500);
		}
	});
}
function zTimeoutGeocode(){
	if(stopGeocoding) return;
	zGeocodeAddress();
}

