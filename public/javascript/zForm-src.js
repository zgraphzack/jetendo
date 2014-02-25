
if (typeof window.console === "undefined") { 
    window.console = {
        log: function(obj){ }
    };  
}
function zKeyExists(obj, key){
	return (key in obj);
}

function zHtmlEditFormat(s, preserveCR) {
    preserveCR = preserveCR ? '&#13;' : '\n';
    return ('' + s) /* Forces the conversion to string. */
        .replace(/&/g, '&amp;') /* This MUST be the 1st replacement. */
        .replace(/'/g, '&apos;') /* The 4 other predefined entities, required. */
        .replace(/"/g, '&quot;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;') 
        .replace(/\r\n/g, preserveCR) /* Must be before the next replacement. */
        .replace(/[\r\n]/g, preserveCR);
        ;
}

var zDisableSearchFilter=0;
var zValues=[];
var zFormData=new Object();
var zPositionObjSubtractId=false;
var zPositionObjSubtractPos=new Array(0,0);
var zArrScrollFunctions=new Array();
var zArrResizeFunctions=new Array();
/*
var zArrLoadFunctions=new Array();
*/
var zWindowSize=false;
function zInitZValues(v){
	for(var i=0;i<v;i++){
		zValues[i]=[];	
	}
}

var zModernizrLoadedRan=false;
 
 zArrDeferredFunctions.unshift(function(){
	 // gist Source: https://gist.github.com/brucekirkpatrick/7026682
	(function($){

		$.unserialize = function(serializedString){
			var str = decodeURI(serializedString); 
			var pairs = str.split('&');
			var obj = {}, p, idx;
			for (var i=0, n=pairs.length; i < n; i++) {
				p = pairs[i].split('=');
				idx = p[0]; 
				if (typeof obj[idx] === 'undefined') {
					obj[idx] = decodeURIComponent(p[1]);
				}else{
					if (typeof obj[idx] === "string") {
						obj[idx]=[obj[idx]];
					}
					obj[idx].push(decodeURIComponent(p[1]));
				}
			}
			return obj;
		};
		
	})($);
});

var zPageHelpId='';
function zGetHelpForThisPage(obj){
	obj.id="getHelpForThisPageLinkId";
	if(zPageHelpId==''){
		alert("No help resources exist for this page yet.\n\nFeel free to browse the documentation or contact the web developer for further assistance.");
		return false;
	}
	obj.href=zPageHelpId;
	return true;
}

var zCookieTrackingObj={};
var zCookieTrackingCount=0;
var zCookieTrackingEnabled=false;
function zTrackCookieChanges(){
	for(var i in zCookieTrackingObj){
		var t=zCookieTrackingObj[i];
		var value=zGetCookie(i);
		if(value !== t.value){
			t.value=value;
			t.callback(value);
		}
	}
}

function zWatchCookie(key, callback){
	zCookieTrackingObj[key]={
		callback:callback,
		value:zGetCookie(key)
	};
	zCookieTrackingCount++;
	if(!zCookieTrackingEnabled){
		zCookieTrackingEnabled=setInterval(zTrackCookieChanges, 1000);
	}
}
function zDeleteWatchCookie(key){
	delete zCookieTrackingObj[key];
	zCookieTrackingCount--;
	if(zCookieTrackingCount===0){
		clearInterval(zCookieTrackingEnabled);
		zCookieTrackingEnabled=false;
	}
}
function zIsLoggedIn(){
	var loggedIn=zGetCookie("ZLOGGEDIN");
	var d=zGetCookie("ZSESSIONEXPIREDATE");
	if(loggedIn === "1" && d !== ""){
		var n=new Date(d.toLocaleString()); 
		if(n < new Date()){
			zDeleteCookie("ZSESSIONEXPIREDATE");
			return false;
		}else{
			return true;
		}
	}else{
		return false;
	}
}
zLoggedInTimeoutID=false;
zArrDeferredFunctions.push(function(){
	zLoggedInTimeoutID=setInterval(function(){
		zLoggedIn=zIsLoggedIn();
	}, 1000);
});
function zCloseThisWindow(reload){
	if(typeof reload === 'undefined'){
		reload=false;
	}
	if(window.parent.zCloseModal){
		if(reload){
			var curURL=window.parent.location.href;
			window.parent.location.href = curURL;
		}else{
			window.parent.zCloseModal();
		}
	}else{
		if(reload){
			var curURL=window.parent.location.href;
			window.parent.location.href = curURL;
		}else{
			window.close();
		}
	}
}

function zModernizrLoaded(){ 
	if(zModernizrLoadedRan) return;
	zModernizrLoadedRan=true;
	if(!zWindowIsLoaded){
		zWindowOnLoad();	
	}
	if(typeof zArrDeferredFunctions !== "undefined"){
		var zATemp=zArrDeferredFunctions;
		for(var i=0;i<zATemp.length;i++){
			zATemp[i]();
		}
	}
}

function zSetScrollPosition(){
	var ScrollTop = document.body.scrollTop;
	if (ScrollTop === 0){
		if (window.pageYOffset){
			ScrollTop = window.pageYOffset;
		}else{
			ScrollTop = (document.body.parentElement) ? document.body.parentElement.scrollTop : 0;
		}
	}
	zScrollPosition.top=ScrollTop;
	var ScrollLeft = document.body.scrollLeft;
	if (ScrollLeft === 0){
		if (window.pageYOffset){
			ScrollLeft = window.pageYOffset;
		}else{
			ScrollLeft = (document.body.parentElement) ? document.body.parentElement.scrollLeft : 0;
		}
	}
	zScrollPosition.left=ScrollLeft;
}



function zCreateMap(mapDivId, optionsObj) {
	
	var mapOptions = { 
		mapTypeId: google.maps.MapTypeId.ROADMAP
	};
	for(var i in optionsObj){
		mapOptions[i]=optionsObj[i];
	}
	var eventObj={};
	if(typeof mapOptions.bindEvents !== "undefined"){
		eventObj=mapOptions.bindEvents;
		delete mapOptions.bindEvents;
	}
	document.getElementById(mapDivId).style.display="block";
	var map = new google.maps.Map(document.getElementById(mapDivId), mapOptions);
	for(var i in eventObj){
		google.maps.event.addListener(map, i, eventObj[i]);
	}
	return map;
}
var globalInfoWindow=null;
function zCreateMapMarker(markerObj){
	if(typeof markerObj === 'undefined'){
		markerObj={};
	}
	var eventObj={};
	var infoWindowHTML="";
	if(typeof markerObj.infoWindowHTML !== "undefined"){
		infoWindowHTML=markerObj.infoWindowHTML;
		delete markerObj.infoWindowHTML;
	}
	if(typeof markerObj.bindEvents !== "undefined"){
		eventObj=markerObj.bindEvents;
		delete markerObj.bindEvents;
	}
	var marker = new google.maps.Marker(markerObj);
	for(var i in eventObj){
		google.maps.event.addListener(marker	, i, eventObj[i]);
	} 
	if(!globalInfoWindow){
		globalInfoWindow = new google.maps.InfoWindow({
			content: ""
		});
	}
	if(infoWindowHTML !== ""){
		marker.infoWindowHTML=infoWindowHTML; 
		google.maps.event.addListener(marker	, 'click', function(){ 
			globalInfoWindow.close();
			globalInfoWindow.setPosition(marker.getPosition());
			globalInfoWindow.setContent(marker.infoWindowHTML);
			globalInfoWindow.open(marker.getMap(), marker);
		});
	}
	return marker;
}

function zGetFormDataByFormId(formId){
	var obj={};
	$("input, textarea, select", $("#"+formId)).each(function(){
		if(typeof obj[this.name] === 'undefined'){
			if(this.type === 'checkbox' || this.type === 'radio'){
				obj[this.name]=$("input[name="+this.name+"]:checked", $("#"+formId)).map(function() {return this.value;}).get().join(','); 
			}else if(this.type.substr(0, 6) === 'select'){
				obj[this.name]=$("select[name="+this.name+"]", $("#"+formId)).map(function() {return this.value;}).get().join(','); 
			}else if(this.type === 'textarea'){
				obj[this.name]=$("textarea[name="+this.name+"]", $("#"+formId)).map(function() {return this.value;}).get().join(','); 
			}else{
				obj[this.name]=$("input[name="+this.name+"]", $("#"+formId)).map(function() {return this.value;}).get().join(','); 
			}
		}
	});
	return obj;
} 
	
function zAddMapMarkerByLatLng(mapObj, markerObj, latitude, longitude){
	markerObj.position=new google.maps.LatLng( latitude, longitude);
	var marker=zCreateMapMarker(markerObj);
	marker.setMap(mapObj);
}
/*
marker.setPosition( new google.maps.LatLng( 0, 0 ) );
map.panTo( new google.maps.LatLng( 0, 0 ) );
*/

function zMapFitMarkers(mapObj, arrMarker){ 
	if(arrMarker.length === 0){
		return;
	}else if(arrMarker.length === 1){
		if(arrMarker[0].getPosition().lat() !== 0){
			mapObj.setCenter(arrMarker[0].getPosition());
			mapObj.setZoom(10);
		}
		return;
	}
	var bounds = new google.maps.LatLngBounds ();
	var extended=false;
	for (var i = 0, LtLgLen = arrMarker.length; i < LtLgLen; i++) {
		if(typeof arrMarker[i].getPosition() !== "undefined" && arrMarker[i].getPosition().lat() !== 0){
			bounds.extend(arrMarker[i].getPosition());
			extended=true;
		}
	} 
	if(extended){
		mapObj.fitBounds(bounds);
	} 
} 
function zAddMapMarkerByLatLng(mapObj, markerObj, latitude, longitude, successCallback){ 
	var marker=zCreateMapMarker(markerObj); 
	var location=new google.maps.LatLng( latitude, longitude);
	marker.setPosition(location);
	marker.setMap(mapObj);
	if(typeof successCallback !== "undefined"){
		setTimeout(function(){ successCallback(marker, location); }, 10);
	}
	return marker;
}
function zAddMapMarkerByAddress(mapObj, markerObj, address, successCallback, delayMilliseconds){ 
	var marker=zCreateMapMarker(markerObj);
	var geocoder = new google.maps.Geocoder(); 
	if(typeof delayMilliseconds === 'undefined'){
		delayMilliseconds=0;
	}
	setTimeout(function(){
		geocoder.geocode( { 'address': address}, function(results, status) {
			if (status === google.maps.GeocoderStatus.OK) { 
				marker.setPosition(results[0].geometry.location);
				marker.setMap(mapObj);
				if(typeof successCallback !== "undefined"){
					successCallback(marker, results[0].geometry.location);
				}
			} else {
				console.log('Geocode was not successful for address, "'+address+'", for the following reason: ' + status);
			}
		});
	}, delayMilliseconds);
	return marker;
}
function zCreateMapWithAddress(mapDivId, address, optionsObj, successCallback, markerObj) {
	var marker=zCreateMapMarker(markerObj); 
	var geocoder = new google.maps.Geocoder(); 
	if(address.length === ""){ 
		if(typeof optionsObj.defaultAddress !== "undefined"){
			address=optionsObj.defaultAddress;
		}else{
			return;
		}
	}
	var mapOptions = {
		zoom: 8,
   		center: new google.maps.LatLng(0, 0),
		mapTypeId: google.maps.MapTypeId.ROADMAP
	};
	for(var i in optionsObj){
		mapOptions[i]=optionsObj[i];
	} 
	var map=zCreateMap(mapDivId, mapOptions); 
	geocoder.geocode( { 'address': address}, function(results, status) {
		if (status === google.maps.GeocoderStatus.OK) {
			setTimeout(function(){
				google.maps.event.trigger(map, 'resize');
				map.setCenter(results[0].geometry.location); 
			}, 1);
			marker.setPosition(results[0].geometry.location);
			marker.setMap(map);
			if(typeof mapOptions.triggerEvents !== "undefined"){
				for(var i in mapOptions.triggerEvents){
					google.maps.event.trigger(map, i);
				}
			} 
			successCallback(marker); 
		} else {
			alert('Geocode was not successful for the following reason: ' + status);
		}
	});
	return { map: map, marker: marker};
}
function zCreateMapWithLatLng(mapDivId, latitude, longitude, optionsObj, successCallback, markerObj) {  
	var mapOptions = {
		zoom: 8,
   		center: new google.maps.LatLng(latitude, longitude),
		mapTypeId: google.maps.MapTypeId.ROADMAP
	};
	for(var i in optionsObj){
		mapOptions[i]=optionsObj[i];
	} 
	var map=zCreateMap(mapDivId, mapOptions); 
	if(typeof markerObj === "undefined"){
		markerObj={};
	}
	markerObj.position=mapOptions.center;
	markerObj.map=map;
	var marker=zCreateMapMarker(markerObj);  
	if(typeof mapOptions.triggerEvents !== "undefined"){
		for(var i in mapOptions.triggerEvents){
			google.maps.event.trigger(map, i);
		}
	} 
	successCallback(marker); 
	return { map: map, marker: marker};
}

var zLoadAndCropImagesIndex=0;
function zLoadAndCropImages(){
	var debug=false;
	var e=zGetElementsByClassName("zLoadAndCropImage");
	var time=new Date().getTime();
	for(var i=0;i<e.length;i++){
		if(e[i].getAttribute("data-imageloaded")==="1"){
			continue;
		}
		e[i].setAttribute("data-imageloaded", "1");
		var url=e[i].getAttribute("data-imageurl");
		var style=e[i].getAttribute("data-imagestyle");
		var width=parseInt(e[i].getAttribute("data-imagewidth"));
		var height=parseInt(e[i].getAttribute("data-imageheight"));
		var crop=false;
		if(e[i].getAttribute("data-imagecrop")==="1"){
			crop=true;
		}
		if(typeof e[i].style.maxWidth !== "undefined" && e[i].style.maxWidth !== ""){
			var tempWidth=parseInt(e[i].style.maxWidth);
			if(tempWidth<width){
				width=tempWidth;
				height=width;
			}
		}
		zLoadAndCropImage(e[i], url, debug, width, height, crop, style);
	}
}
function zLoadAndCropImagesDefer(){
	setTimeout(zLoadAndCropImages, 1);
}
zArrLoadFunctions.push({functionName:zLoadAndCropImagesDefer});
	
function zLoadAndCropImage(obj, imageURL, debug, width, height, crop, style){
	if(zMSIEBrowser!==-1 && zMSIEVersion<=9){
		if(height===10000){
			obj.innerHTML='<img src="'+imageURL+'" />';
		}else{
			obj.innerHTML='<img src="'+imageURL+'" width="'+width+'" height="'+height+'" />';
		}
		return;	
	}
	var canvas = document.createElement('canvas');
	zLoadAndCropImagesIndex++;
	canvas.id="zCropImageID"+zLoadAndCropImagesIndex+"_canvas";
	canvas.width=width;
	canvas.height=height;
	canvas.style.cssText=style;
	var context = canvas.getContext('2d');
	var imageObj = new Image();
	imageObj.startTime=new Date().getTime();
	imageObj.onerror=function(){
		this.src='/z/a/listing/images/image-not-available.gif';	
	};
	imageObj.onload = function() {
		var end = new Date().getTime();
		var time2 = end - this.startTime;
		//if(debug) 
		if(debug) console.log((time2/1000)+" seconds to load image");
		var time=new Date().getTime();
		if(this.width <= 10 || this.width >= 1000 || this.height <= 10 || this.height >= 1000){
			if(debug) console.log("Failed to draw canvas because computed width x height was invalid: "+this.width+"x"+this.height);
			return;
		}
		if(this.src.indexOf('/z/a/listing/images/image-not-available.gif') !== -1){
			canvas.width=this.width;
			canvas.height=this.height;
			context.drawImage(this, 0,0);//Math.floor((width-this.width)/2), Math.floor((height-this.height)/2));
			//context.drawImage(this, Math.floor((width-this.width)/2), Math.floor((height-this.height)/2));
			obj.appendChild(canvas);
			return;
		}
		if(debug) console.log("image loaded:"+this.src);
		var start=new Date();
		canvas.width=this.width;
		canvas.height=this.height;
		context.drawImage(this, 0, 0);
		var imageData=context.getImageData(0,0, this.width, this.height);
		var end = new Date().getTime();
		var time2 = end - time;
		//if(debug) 
		if(debug) console.log((time2/1000)+" seconds to getimagedata");
		var time=new Date().getTime();
		var xCheck=Math.round(this.width/5);
		var yCheck=Math.round(this.height/5);
		var xmiddle=Math.round(this.width/2);
		var ymiddle=Math.round(this.height/2);
		var xcrop=0;
		var xcrop2=0;
		var ycrop=0;
		var ycrop2=0;
		if(debug) console.log("top side");
		for (var y=0;y<this.height;y++){
			var p=(xmiddle*4)+(y*4*this.width);
			rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
			var curX=Math.max(1, xmiddle-xCheck);
			p=(curX*4)+(y*4*this.width);
			rgb2=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
			curX=Math.min(this.width, xmiddle+xCheck);
			p=(curX*4)+(y*4*this.width);
			rgb3=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
			//if(debug) console.log("finding y: "+rgb1+" | "+rgb2+" | "+rgb3);
			if((rgb1+rgb2+rgb3)/3 < 16400000){
				ycrop=y+6;
				newy=y;
				for(y=Math.max(0,y-9);y<=newy;y++){
					var p=(xmiddle*4)+(y*4*this.width);
					rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
					if(debug) console.log(y+" | refining y: "+rgb1+" | red: "+imageData.data[p]+" | green: "+imageData.data[p+1]+" | blue: "+imageData.data[p+2]);
					if(rgb1<16400000){
						if(debug) console.log("final y:"+y);
						ycrop=y+6;
						break;
					}
				}
				break;
			}
		}
		if(debug) console.log("bottom side");
		for (var y=0;y<this.height;y++){
			var curY=((this.height-1)*4*this.width)-(y*4*this.width);
			var p=(xmiddle*4)+(curY);
			rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
			var curX=Math.max(1, xmiddle-xCheck);
			p=(curX*4)+(curY);
			rgb2=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
			curX=Math.min(this.width, xmiddle+xCheck);
			p=(curX*4)+(curY);
			rgb3=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
			//if(debug) console.log("finding y: "+rgb1+" | "+rgb2+" | "+rgb3);
			if((rgb1+rgb2+rgb3)/3 < 16400000){
				ycrop2=y+6;
				newy=y;
				for(y=Math.max(0,y-9);y<=newy;y++){
					var p=(xmiddle*4)+(y*4*this.width);
					rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
					if(debug) console.log(y+" | refining y: "+rgb1+" | red: "+imageData.data[p]+" | green: "+imageData.data[p+1]+" | blue: "+imageData.data[p+2]);
					if(rgb1<16400000){
						if(debug) console.log("final y:"+y);
						ycrop2=y+6;
						break;
					}
				}
				break;
			}
		}
		
		
		if(debug) console.log("left side");
		for (var x=0;x<this.width;x++){
			var p=(x*4)+(ymiddle*4*this.width);
			rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
			var curY=Math.max(1, ymiddle-yCheck);
			p=(x*4)+(curY*4*this.width);
			rgb2=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
			curY=Math.min(this.height, ymiddle+yCheck);
			p=(x*4)+(curY*4*this.width);
			rgb3=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
			//if(debug) console.log("finding y: "+rgb1+" | "+rgb2+" | "+rgb3);
			if((rgb1+rgb2+rgb3)/3 < 16400000){
				xcrop=x+6;
				newx=x; 
				for(x=Math.max(0,x-9);x<=newx;x++){
					var p=(x*4)+(ymiddle*4*this.width);
					rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
					if(debug) console.log(x+" | refining x: "+rgb1+" | red: "+imageData.data[p]+" | green: "+imageData.data[p+1]+" | blue: "+imageData.data[p+2]);
					if(rgb1<16400000){
						if(debug) console.log("final x:"+x);
						xcrop=x+6;
						break;
					}
				}
				break;
			}
		}
		if(debug) console.log("right side");
		for (var x=0;x<this.width;x++){
			//var curX=((this.width-1)*4)-(ymiddle*4*this.width);
			var curX2=(((this.width-1)-x)*4);
			var curX=(((this.width-1)-x)*4)+(ymiddle*4*this.width);
			var p=(x*4)+(curX);
			rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
			var curY=Math.max(1, ymiddle-yCheck);
			p=(curX2)+(curY*4*this.width);
			rgb2=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
			curY=Math.min(this.height, ymiddle+yCheck);
			p=(curX2)+(curY*4*this.width);
			rgb3=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
			//if(debug) console.log("finding x: "+rgb1+" | "+rgb2+" | "+rgb3+" | x:"+curX+" x:"+(this.width-x)+" y:"+curY);
			if((rgb1+rgb2+rgb3)/3 < 16400000){
				xcrop2=x+6;
				newx=x;
				for(x=Math.max(0,x-9);x<=newx;x++){
					var p=(xmiddle*4)+(curY);
					rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
					if(debug) console.log(x+" | refining y: "+rgb1+" | red: "+imageData.data[p]+" | green: "+imageData.data[p+1]+" | blue: "+imageData.data[p+2]);
					if(rgb1<16400000){
						if(debug) console.log("final x:"+x);
						xcrop2=x+6;
						break;
					}
				}
				break;
			}
		}
		if(debug) console.log("left:"+xcrop+" | top:"+ycrop+" | right:"+xcrop2+" | bottom:"+ycrop2);
		
		var originalWidth=this.width;
		var originalHeight=this.height;
		if(debug) console.log("original size:"+this.width+"x"+this.height);
		var newWidth=this.width-(xcrop+xcrop2);
		var newHeight=this.height-(ycrop+ycrop2);
		if(newHeight < 10 || newWidth < 10){
			// prevent mistakes
			if(Math.abs(xcrop-xcrop2) > 50){
				xcrop=Math.min(xcrop, xcrop2);
			}else{
				xcrop=Math.max(xcrop, xcrop2);
			}
			if(Math.abs(ycrop-ycrop2) > 50){
				ycrop=Math.min(ycrop, ycrop2);
			}else{
				ycrop=Math.max(ycrop, ycrop2);
			}
			newWidth=(originalWidth-(xcrop*2));
			newHeight=(originalHeight-(ycrop*2));
			if(newHeight < 10 || newWidth < 10){
				// image can't be cropped correctly, show entire image
				newWidth=originalWidth;
				newHeight=originalHeight;
			}
			crop=false;
		}
		if(newWidth < this.width/2 || newHeight < this.height/2){
			// preventing incorrect cropping of images that are mostly white, by restoring them to display as full size
			newWidth=this.width;
			newHeight=this.height;
		}
		if(debug) console.log("size without whitespace:"+newWidth+"x"+newHeight);
		
		var x2crop=0;
		var x2crop2=0;
		var y2crop=0;
		var y2crop2=0;
		if(width === 10000 && height === 10000){
			nw=newWidth;
			nh=newHeight;
			width=newWidth;
			height=newHeight;
		}else{
			if(crop){
				// resize and crop
				var ratio=width/newWidth;
				var nw=width;
				var nh=(newHeight*ratio);
				if(nh < height){
					ratio=height/newHeight;
					nw=(newWidth*ratio);
					nh=height;
				}
				if(nw>width){
					x2crop=((nw-width)/2);
					x2crop2=((nw-width)/2);
				}
				if(nh>height){
					y2crop=((nh-height)/2);
					y2crop2=((nh-height)/2);
					
				}
				xcrop+=(x2crop/2)/ratio;
				ycrop+=(y2crop/2)/ratio;
				if(debug) console.log("crop | left:"+x2crop+" | top:"+y2crop+" | right:"+x2crop2+" | bottom:"+y2crop2);
			}else{
				// resize preserving scale	
				var ratio=width/newWidth;
				var nw=width;
				var nh=Math.ceil(newHeight*ratio);
				if(nh > height){
					ratio=height/newHeight;
					nw=Math.ceil(newWidth*ratio);
					nh=height;
				}
			}
		}
		
		if(this.width<nw){
			if(debug) console.log("width exceeded original");
			ratio=this.width/nw;
			width=this.width;
			nw=this.width;
			nh=this.height;//ratio*this.height;
			height=nh;
			xcrop=0;
			ycrop=0;
			x2crop=0;
			y2crop=0;
		}
		if(this.height<nh){
			if(debug) console.log("height exceeded original");
			ratio=this.height/nh;
			height=this.height;
			nh=this.height;
			nw=this.width;//ratio*this.width;
			xcrop=0;
			ycrop=0;
			x2crop=0;
			y2crop=0;
		}
		/*newWidth+=10;
		newHeight+=10;
		*/
		if(debug) console.log("final size:"+nw+"x"+nh);
		if(debug) console.log("sizes:"+width+"x"+height+":"+this.width+"x"+this.height);
		
		var end = new Date().getTime();
		var time2 = end - time;
		//if(debug) 
		if(debug) console.log((time2/1000)+" seconds to detect crop");
		var time=new Date().getTime();
		
		if(debug) console.log(Math.ceil(xcrop)+" | "+Math.ceil(ycrop)+" | "+Math.floor(newWidth-(x2crop))+" | "+Math.floor(newHeight-(y2crop))+" | "+-Math.ceil(x2crop/2)+" | "+-Math.ceil(y2crop/2)+" | "+Math.ceil(nw)+" | "+Math.ceil(nh));
		if(width <= 10 || width >= 1000 || height <= 10 || height >= 1000){
			if(debug) console.log("Failed to draw canvas because computed width x height was invalid: "+width+"x"+height);
			return;
		}
		canvas.width=width;
		canvas.height=height;
		if(debug) console.log(newWidth+":"+newHeight+":"+canvas.height+":"+Math.ceil(nh)+":"+Math.ceil(y2crop));
		context.drawImage(imageObj, Math.ceil(xcrop), Math.ceil(ycrop), Math.floor(newWidth-(xcrop*2)), Math.floor(newHeight-(ycrop*2)),-Math.ceil(x2crop/2), -Math.ceil(y2crop/2), Math.ceil(nw), Math.ceil(nh));
		obj.appendChild(canvas);
		var end = new Date().getTime();
		var time = end - start;
		//if(debug) 
		if(debug) console.log((time/1000)+" seconds to crop image");
	};
	imageObj.src = imageURL;
}


function zIsMobilePhone(){
	var a=navigator.userAgent||navigator.vendor||window.opera;
	if(/android.+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|meego.+mobile|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(di|rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))){
		return true;
	}else{
		return false;
	}
}

var zScrollTopComplete=true;
function zScrollTop(elem, y, forceAnimate){
	if(typeof elem === "undefined" || typeof elem === "boolean"){
		elem='html, body';	
	}
	if(zScrollTopComplete){
		if(typeof forceAnimate !== "undefined" && forceAnimate){
			$(elem).animate({scrollTop: y}, { 
				"duration":200, 
				"complete":function(){
					zScrollTopComplete=true;
				}
			});
			zScrollTopComplete=false;
		}else{
			$(window).scrollTop(y);
			zScrollTopComplete=true;
		}
	}
}

var zIsTouchscreenCache=3;
function zIsTouchscreen(){
	if(zIsTouchscreenCache!==3){
		return zIsTouchscreenCache;
	}
	var n=navigator.userAgent.toLowerCase();
	
	var patt=/(android|iphone|ipad|viewpad|tablet|bolt|xoom|touchpad|playbook|kindle|gt-p|gt-i|sch-i|sch-t|mz609|mz617|mid7015|tf101|g-v|ct1002|transformer|silk| tab)/g;
	if(n.replace(patt,"anything") !== n){
		zIsTouchscreenCache=true;
		return true;
	}else if(n.indexOf("MSIE 10") !== -1 && window.navigator && (typeof window.navigator.msPointerEnabled !== "undefined" && window.navigator.msPointerEnabled === false)) {
		// doesn't have pointer support, touch only tablet maybe.
		zIsTouchscreenCache=true;
		return true;
	}else{
		zIsTouchscreenCache=false;
		return false;
	}
}


function zGetChildElementCount(id){
	var c=0;
	for(var i=0;i<document.getElementById(id).childNodes.length;i++){
		if(document.getElementById(id).childNodes[i].nodeName !== "#text"){
			c++;
		}
	}
	return c;
}
function zLoadHomeSlides(id){
	var c=0;
	for(var i=0;i<zArrSlideshowIds.length;i++){
		if(zArrSlideshowIds[i].id === id){
			zArrSlideshowIds[i].rotateIndex=0;
			zArrSlideshowIds[i].rotateGroupIndex=0;
			zArrSlideshowIds[i].ignoreNextRotate=true;
			c=zArrSlideshowIds[i];	
			break;
		}
	}
	zSlideshowSetupSliderButtons(c);
	if(c.layout===2 || c.layout === 0){
		$('#zUniqueSlideshowLargeId'+c.id).cycle({
			before: zImageLazyLoadUpdate,
			fx: 'fade',
			startingSlide: 0,
			timeout: c.slideDelay
		});
	}
	if(c.layout === 1 || c.layout === 0){
		var d=c.slideDelay;
		var e1="slide";
		if(c.slideDirection==='y'){
			e1='verticalslide';//'fade';
		}
		if(c.layout===0){
			d=false;
			
		}
		// thumbnails	
		$('#zUniqueSlideshowId'+c.id).slides({
			newClassNames:true,
			newId: c.id,
			play: d,
			pause: d,
			effect:e1,
			next: 'zlistingslidernext'+c.id,
			prev: 'zlistingsliderprev'+c.id,
			hoverPause: false
		});
	}
	zLoadAndCropImages();
}
var zArrSlideshowIds=[];
function zGetSlideShowId(id){
	for(var i=0;i<zArrSlideshowIds.length;i++){
		if(zArrSlideshowIds[i].id === id){
			return i;
		}
	}
	return false;
}

function zUpdateListingSlides(id, theLink){
	var c=0;
	for(var i=0;i<zArrSlideshowIds.length;i++){
		if(zArrSlideshowIds[i].id === id){
			c=zArrSlideshowIds[i];	
			break;
		}
	}
	$.ajax({
		url: theLink,
		context: document.body,
		success: function(data){
			if(zArrSlideshowIds[i].layout === 0){
				// need to load both html and init both here
				var a1=data.split("~~~");
				$('#zUniqueSlideshowLargeId'+zArrSlideshowIds[i].id).html(a1[0]);
				var a2='';
				if(zArrSlideshowIds[i].slideDirection==='x'){
					a2+='<div id="zslideshowhomeslidenav'+zArrSlideshowIds[i].id+'">'+document.getElementById('zslideshowhomeslidenav'+zArrSlideshowIds[i].id).innerHTML+'<\/div>';
				}
				a2+='<div class="zslideshow'+zArrSlideshowIds[i].id+'-38-2">		<a href="#" class="zlistingsliderprev'+zArrSlideshowIds[i].id+'"><span class="zlistingsliderprevimg'+zArrSlideshowIds[i].id+'">&nbsp;<\/span><\/a><div id="zslideshowslides'+zArrSlideshowIds[i].id+'"><div id="zlistingcontainer'+zArrSlideshowIds[i].id+'" class="zslideshowslides_container'+zArrSlideshowIds[i].id+'"><div class="zslideshowslide'+zArrSlideshowIds[i].id+'">'+a1[1]+'<\/div><\/div><\/div>		<a href="#" class="zlistingslidernext'+zArrSlideshowIds[i].id+'"><span class="zlistingslidernextimg'+zArrSlideshowIds[i].id+'">&nbsp;<\/span><\/a><\/div>';
				$('#zUniqueSlideshowId'+zArrSlideshowIds[i].id).html(a2);
			}else if(c.layout === 2){
				$('#zUniqueSlideshowLargeId'+zArrSlideshowIds[i].id).html(data);
			}else{
				$('#zUniqueSlideshowId'+zArrSlideshowIds[i].id).html('<div id="zslideshowhomeslidenav'+zArrSlideshowIds[i].id+'">'+document.getElementById('zslideshowhomeslidenav'+zArrSlideshowIds[i].id).innerHTML+'<\/div><div class="zslideshow'+zArrSlideshowIds[i].id+'-38-2">		<a href="#" class="zlistingsliderprev'+zArrSlideshowIds[i].id+'"><span class="zlistingsliderprevimg'+zArrSlideshowIds[i].id+'">&nbsp;<\/span><\/a><div id="zslideshowslides'+zArrSlideshowIds[i].id+'"><div id="zlistingcontainer'+zArrSlideshowIds[i].id+'" class="zslideshowslides_container'+zArrSlideshowIds[i].id+'"><div class="zslideshowslide'+zArrSlideshowIds[i].id+'">'+data+'<\/div><\/div><\/div>		<a href="#" class="zlistingslidernext'+zArrSlideshowIds[i].id+'"><span class="zlistingslidernextimg'+zArrSlideshowIds[i].id+'">&nbsp;<\/span><\/a><\/div>');
			}
			if(window.location.href.indexOf('/z/misc/slideshow/embed') !== -1){
				$('a').attr('target', '_parent');
			}
			zLoadHomeSlides(id);
		}
	});
}
function zImageLazyLoadUpdate(currSlideElement, nextSlideElement, options, forwardFlag){
	var d='zUniqueSlideshowLargeId';
	var id=parseInt(nextSlideElement.parentNode.id.substr(d.length, nextSlideElement.parentNode.id.length-d.length));
	var i=zGetSlideShowId(id);
	if(zArrSlideshowIds[i].moveSliderId !== false){
		if(zArrSlideshowIds[i].ignoreNextRotate===false && zArrSlideshowIds[i].rotateIndex % zArrSlideshowIds[i].movedTileCount === 0){
			zArrSlideshowIds[i].ignoreNextRotate=true;
			$('.zlistingslidernext'+zArrSlideshowIds[i].id).trigger("click");
			if(zArrSlideshowIds[i].rotateGroupIndex+1===3){
				zArrSlideshowIds[i].rotateGroupIndex=0;
			}else{
				zArrSlideshowIds[i].rotateGroupIndex++;
			}
		}
		zArrSlideshowIds[i].ignoreNextRotate=false;
		if(zArrSlideshowIds[i].rotateIndex+1===zArrSlideshowIds[i].movedTileCount*3){
			zArrSlideshowIds[i].rotateIndex=0;
		}else{
			zArrSlideshowIds[i].rotateIndex++;
		}
	}
	var d1=document.getElementById(nextSlideElement.id+"_img");
	var d2=document.getElementById(currSlideElement.id+"_img");
	if(d1 && d1.src !== nextSlideElement.title){
		d1.src=nextSlideElement.title;
	}
	if(d2 && d2.src !== nextSlideElement.title){
		d2.src=currSlideElement.title;
	}
}
function zSlideshowSetupSliderButtons(c){
		$('.zlistingsliderprev'+c.id).bind('click',function(){
			var d='zlistingsliderprev';
			var id=parseInt(this.className.substr(d.length, this.className.length-d.length));
			var i=zGetSlideShowId(id);
			if(zArrSlideshowIds[i].rotateGroupIndex===0){
				zArrSlideshowIds[i].rotateGroupIndex=2;
			}else{
				zArrSlideshowIds[i].rotateGroupIndex--;
			}
			if(zArrSlideshowIds[i].layout === 0 && zArrSlideshowIds[i].rotateIndex !== zArrSlideshowIds[i].rotateGroupIndex * zArrSlideshowIds[i].movedTileCount){
				$('#zUniqueSlideshowLargeId'+zArrSlideshowIds[i].id).cycle('destroy');
				zArrSlideshowIds[i].rotateIndex=zArrSlideshowIds[i].rotateGroupIndex * zArrSlideshowIds[i].movedTileCount;
				zArrSlideshowIds[i].ignoreNextRotate=true;
				$('#zUniqueSlideshowLargeId'+zArrSlideshowIds[i].id).cycle({
					before: zImageLazyLoadUpdate,
					fx: 'fade',
					startingSlide: zArrSlideshowIds[i].rotateIndex,
					timeout: zArrSlideshowIds[i].slideDelay
				});
			}
		});
		$('.zlistingslidernext'+c.id).bind('click',function(){
			var d='zlistingslidernext';
			var id=parseInt(this.className.substr(d.length, this.className.length-d.length));
			var i=zGetSlideShowId(id);
			if(zArrSlideshowIds[i].ignoreNextRotate){
				return;
			}
			if(zArrSlideshowIds[i].rotateGroupIndex===2){
				zArrSlideshowIds[i].rotateGroupIndex=0;
			}else{
				zArrSlideshowIds[i].rotateGroupIndex++;
			}
			if(zArrSlideshowIds[i].layout === 0 && zArrSlideshowIds[i].rotateIndex !== zArrSlideshowIds[i].rotateGroupIndex * zArrSlideshowIds[i].movedTileCount){
				$('#zUniqueSlideshowLargeId'+zArrSlideshowIds[i].id).cycle('destroy');
				zArrSlideshowIds[i].rotateIndex=zArrSlideshowIds[i].rotateGroupIndex * zArrSlideshowIds[i].movedTileCount;
				zArrSlideshowIds[i].ignoreNextRotate=true;
				$('#zUniqueSlideshowLargeId'+zArrSlideshowIds[i].id).cycle({
					before: zImageLazyLoadUpdate,
					fx: 'fade',
					startingSlide: zArrSlideshowIds[i].rotateIndex,
					timeout: zArrSlideshowIds[i].slideDelay
				});
			}
		});
}
function zSlideshowInit(){
	for(var i=0;i<zArrSlideshowIds.length;i++){
		$('.zslideshowslides_container'+zArrSlideshowIds[i].id).css("display","block");
		var c=zArrSlideshowIds[i];
		zSlideshowSetupSliderButtons(c);
		//c.slideDelay=1000;
		//zArrSlideshowIds[i].slideDelay=1000;
		zArrSlideshowIds[i].ignoreNextRotate=true;
		if(c.layout === 0){
			zArrSlideshowIds[i].moveSliderId='#zUniqueSlideshowId'+c.id;
		}else{
			zArrSlideshowIds[i].moveSliderId=false;
		}
			//	zArrSlideshowIds[i].slideDelay=2000;
				//c.slideDelay=2000;
		if(c.layout===2){
			var slideCount=zGetChildElementCount('zUniqueSlideshowLargeId'+c.id);
			if(slideCount===0){
				document.getElementById("zUniqueSlideshowContainerId"+c.id).style.display="none";
			}else if(slideCount===1){
				var d0=document.getElementById("zUniqueSlideshowLargeId"+c.id);
				var d_0=0;
				if(d0.childNodes[0].nodeName==="#text"){
					d_0=1;
				}
				var d1=document.getElementById(d0.childNodes[d_0].id+"_img");
				if(d1 && d1.src !== d0.childNodes[d_0].title){
					d1.src=d0.childNodes[d_0].title;
				}	
			}
		}
		if(c.layout===2 || c.layout === 0){
			if(c.slideDelay === 0){
				c.slideDelay=4000;
				zArrSlideshowIds[i].slideDelay=4000;
			}
			$('#zUniqueSlideshowLargeId'+c.id).cycle({
				before: zImageLazyLoadUpdate,
				fx: 'fade',
				timeout: c.slideDelay
			});
		}
		if(c.layout === 1 || c.layout===0){
			var d=c.slideDelay;
			var e1="slide";
			if(c.slideDirection==='y'){
				e1='verticalslide';//'fade';
			}
			if(c.layout===0){
				d=false;//c.slideDelay*zGetChildElementCount('zUniqueSlideshowLargeId'+c.id);
				
			}
			// thumbnails	
			$('#zUniqueSlideshowId'+c.id).slides({
				newClassNames:true,
				newId: c.id,
				play: d,
				pause: d,
				effect:e1,
				next: 'zlistingslidernext'+c.id,
				prev: 'zlistingsliderprev'+c.id,
				hoverPause: false
			});
		}
			if(window.location.href.indexOf('/z/misc/slideshow/embed') !== -1){
				$('a', document.body).attr('target', '_parent');
			}
	}
}
function zSlideshowClickLink(u){
	if(window.location.href.indexOf('/z/misc/slideshow/embed') !== -1){
		top.location.href=u;
	}else{
		window.location.href=u;
	}
		
}

var zPopUnderURL="";
var zPopUnderFeatures="";
var zPopUnderLoaded=false;
function zLoadPopUnder(u, winfeatures){
	zPopUnderURL=u;
	zPopUnderFeatures=winfeatures;
	if (zPopUnderLoaded === false && zGetCookie('zpopunder')===''){
		zPopUnderLoaded=true;
		document.body.onclick = function(){
			zSetCookie({key:"zpopunder",value:"yes",futureSeconds:3600 * 12,enableSubdomains:false}); 
			win2=window.open(zPopUnderURL,"zpopunderwindow",zPopUnderFeatures);
			win2.blur();
			window.focus();	
		};
	} 
}
function zURLEscape(str){
	var s=encodeURIComponent(str.toString().trim());
	
	var g=new RegExp('/+/', 'g');
	s=s.replace(g,"+");
	g=new RegExp('/@/', 'g');
	s=s.replace(g,"@");
	g=new RegExp('///', 'g');
	s=s.replace(g,"/");
	g=new RegExp('/*/', 'g');
	s=s.replace(g,"*");
	return(s);
}
function zLoadVideoJSID(id, autoplay){
	VideoJS.setup(id);
	if(autoplay){
		document.getElementById(id).player.play();
	}
}
function zGetCookie(key){
    var currentcookie = document.cookie;
    if (currentcookie.length > 0)
    {
        var firstidx = currentcookie.indexOf(key + "=");
        if (firstidx !== -1)
        {
            firstidx = firstidx + key.length + 1;
            var lastidx = currentcookie.indexOf(";",firstidx);
            if (lastidx === -1)
            {
                lastidx = currentcookie.length;
            }
            return unescape(currentcookie.substring(firstidx, lastidx));
        }
    }
    return "";
}

function zDeleteCookie(key){
	zSetCookie({key:key, value:"", futureSeconds:-1, enableSubdomains:true});
}
/* zSetCookie({key:"cookie",value:"value",futureSeconds:3600,enableSubdomains:false}); */
function zSetCookie(obj){
	if(typeof obj !== "object"){
		throw("zSetCookie requires an obj like {key:'cookie'',value:'value',futureSeconds:60,enableSubdomains:false}.");
	}
	var dObj={futureSeconds:0,enableSubdomains:false};
	for(var i in obj){
		dObj[i]=obj[i];	
	}
	var newC=dObj.key+"="+escape(dObj.value);
	if(dObj.futureSeconds !== 0){
		var currtime=new Date();
		currtime = new Date(currtime.getTime() + dObj.futureSeconds*1000);
         newC+=";expires=" + currtime.toGMTString();
	}
	if(dObj.enableSubdomains){
		newC+=";domain=."+window.location.hostname.replace("www.","").replace("secure.",""); 
	}
	document.cookie=newC;
}
function walkTheDOM (node, func) {
	func(node);
	node = node.firstChild;
	while (node) {
		walkTheDOM(node, func);
		node = node.nextSibling;
	}
}
function zGetElementsByClassName(className) {
	if(typeof document.getElementsByClassName !== "undefined"){
		return document.getElementsByClassName(className);
	}else{
		var results = [];
		walkTheDOM(document.body, function (node) {
			var a, c = node.className, i;
			if (c) {
				a = c.split(' ');
				for (i=0; i<a.length; i++) {
					if (a[i] === className) {
						results.push(node);
						break;
					}
				}
			}
		});
		return results;
	}
}
var is_webkit = navigator.userAgent.toLowerCase().indexOf('webkit') > -1;
/*Author: Karina Steffens, www.neo-archaic.net*/
function zswfr(s,s1,s2){var t1pos=s.indexOf(s1);if(t1pos !== -1){var t1s=s.substr(0,t1pos);var t1e=s.substr(t1pos+s1.length,s.length-(t1pos+s1.length));return t1s+s2+t1e;}else{return s;}}function zswf(v){v=zswfr(v,'zswf="off"','zswf="off" style="display:block;"');document.write(v);};var ie=(document.defaultCharset&&document.getElementById&&!window.home);if(ie && !is_webkit)document.write('<style type="text/css" id="hideObject">object{display:none;}</style>');
function zswf2(){
	if(!document.getElementsByTagName)return;var x=[];var s=document.getElementsByTagName('object');
	for(var i=0;i<s.length;i++){
		var o=s[i];var h=o.outerHTML;
		if(h && h.indexOf('zswf="off"')!==-1){
			continue;
		}
		var params="";
		var q=true;
		for (var j=0;j<o.childNodes.length;j++){
			var p=o.childNodes[j];
			if(p.tagName==="PARAM"){
				if(p.name==="flashVersion"){
					q=zswfd(p.value);
					if(!q){
						o.id=(o.id==="")?("stripFlash"+i):o.id;x.push(o.id);break;
					}
				}
				params+=p.outerHTML;
			}
		}
		if(!q)continue;
		if(!ie)continue;
		if(o.className.toLowerCase().indexOf("noswap")!==-1)continue;
		var t=h.split(">")[0]+">";
		var j=t+params+o.innerHTML+"</OBJECT>";
		o.outerHTML=j;
	}
	if(x.length)stripFlash(x);
	if(ie && !is_webkit)var x2=document.getElementById("hideObject"); if(x2){ x2.disabled=true;}
}
function zswfd(v){
	if(navigator.plugins&&navigator.plugins.length){
		var plugin=navigator.plugins["Shockwave Flash"];
		if(plugin==="undefined")return false;
		var ver=navigator.plugins["Shockwave Flash"].description.split(" ")[2];
		return (Number(ver)>=Number(v));
	}else if(ie&&typeof(ActiveXObject)==="function"){
		try{
			var flash=new ActiveXObject("ShockwaveFlash.ShockwaveFlash."+v);
			return true;
		}catch(e){
			return false;
		}
	}
	return true;
}
function zswfs(x){
	if(!document.createElement)return;
	for(var i=0;i<x.length;i++){
		var o=document.getElementById(x[i]);
		var n=o.innerHTML;n=n.replace(/<!--\s/g,"");
		n=n.replace(/\s-->/g,"");
		n=n.replace(/<embed/gi,"<span");
		var d=document.createElement("div");
		d.innerHTML=n;
		d.className=o.className;
		d.id=o.id;
		o.parentNode.replaceChild(d,o);
	}
}

zswf2();
function zToggleDisplay(id){
	var d=document.getElementById(id);
	if(d.style.display==="none"){
		d.style.display="block";
	}else{
		d.style.display="none";
	}
}

var zArrBlink=new Array();
function zBlinkId(aname, blink_speed){
var dflash=document.getElementById(aname);
 if(typeof zArrBlink[aname] === "undefined"){
	zArrBlink[aname]=0; 
 }
 if(zArrBlink[aname]%2===0){
 dflash.style.visibility="visible";
 }else{
 dflash.style.visibility="hidden";
 }
 if(zArrBlink[aname]<1){
	zArrBlink[aname]=1;
 }else{
	zArrBlink[aname]=0;
 }
 setTimeout("zBlinkId('"+aname+"',"+blink_speed+")",blink_speed);
}



function zFindPosition(obj) {
	var curleft = curtop = curwidth = curheight = 0;
	if (obj.offsetParent) {
		curleft = obj.offsetLeft;
		curtop = obj.offsetTop;
		curwidth=obj.offsetWidth;
		curheight=obj.offsetHeight;
		while (true) {
			obj = obj.offsetParent;
			if(typeof obj === "undefined" || obj ===null){
				break;
			}else{
				curleft += obj.offsetLeft;
				curtop += obj.offsetTop;
			}
		}
	}
	return [curleft,curtop,curwidth,curheight];
}
// mls image rollovers and code for the zInputLinkBox suggestion box. - it is not compatible with other data sources yet.
function zGetAbsPosition(object) {
	var position = new Object();
	position.x = 0;
	position.y = 0;
	position.cx =0;
	position.cy =0;

	if( object ) {
		position.x = object.offsetLeft;
		position.y = object.offsetTop;

		if( object.offsetParent ) {
			var parentpos = zGetAbsPosition(object.offsetParent);
			position.x += parentpos.x;
			position.y += parentpos.y;
		}
		position.cx = object.offsetWidth;
		position.cy = object.offsetHeight;
	}
	position.width=position.cx;
	position.height=position.cy;
	return position;
}




var zIgnoreClickBackup=false;
function zRenable(){
	if(zIgnoreClickBackup){
		zIgnoreClickBackup=false;
	}else{
		zInputHideDiv();
	}
	return true;
}
if(typeof document.onclick === "function"){
	var zDocumentClickBackup=document.onclick;
}else{
	var zDocumentClickBackup=function(){};
}
$(document).bind("click", function(ev){
	zDocumentClickBackup(ev);
	zRenable(ev);
});


function zFixText(myString){
	myString = zMakeEnglish(myString);	
	myString = zIsAlphabet(myString);
	myString = myString.toLowerCase();
	return myString;
}


function zFormatTheArray(myArray){
	var useThisArray = [];
	for(i=0;i < myArray.length; i++){
	useThisArray[i] = zFixText(myArray[i]);
	}
	
return useThisArray;	
}


function zDisableEnter(e){
	var key;
     if(window.event) key = window.event.keyCode;     //IE
     else key = e.which;     //firefox
     if(key === 13 || key === 40 || key ===38){
          return false;
	 }else{
          return true;
	 }
}

var selIndex=0;
function zKeyboardEvent(e, obj,obj2,forceEnter){
	var keynum;
	if(e===null) return;
	var numcheck;
	if(!selIndex){
		selIndex=0;
	}
	if(window.event){
		keynum = e.keyCode;
	}else{
		keynum = e.which;
	}
	if(obj.value.length > 2){	
		var doc = document.getElementById("zTOB");
		//var allLinks = doc.getElementsByTagName('a');
		//arrNewLink
		if(keynum === 13 || forceEnter === true){
			// enter
			if(obj.value === "") return;
			if(doc.style.display==="block"){
				var textToForm = document.getElementById("lid"+arrNewLink[selIndex]).innerHTML;
				var textValue=textToForm;
				for(var i=0;i<zArrCityLookup.length;i++){
					var arrJ=zArrCityLookup[i].split("\t");
					if(arrJ[0]===textToForm){
						textValue=arrJ[1];
						break;
					}
				}
				obj.value=textToForm;
				obj2.value=textValue;
				//zInputPutIntoForm(textToForm,textValue, formName,obj2.id,false);
				zInputHideDiv(formName);
			}else{
				obj2.value=obj.value;
			}
			selIndex=-1;
		}else if(keynum === 40){
			//down
			selIndex++;
			selIndex=Math.min(selIndex,arrNewLink.length-1);
		}else if(keynum===38){
			// up	
			selIndex--;
			selIndex=Math.max(0,selIndex);
		}else{
			if(doc.style.display!=="block"){
				obj2.value=obj.value;
				selIndex=-1;
			}
			return;	
		}
		var firstBlock=-1;
		var matched=false;
		for(i=0;i<arrNewLink.length;i++){
			var c=document.getElementById('lid'+arrNewLink[i]);
			/*if(firstBlock==-1 && c.style.display=="block"){
			//	firstBlock=i;	
			}
			if(c.style.display=="none"){
			//	selIndex++;	
			}*/
			if(i===selIndex){
				matched=true;
				c.className="zTOB-selected";
				// set new value here
				var textToForm = c.innerHTML;
				var textValue=textToForm;
				for(var n=0;n<zArrCityLookup.length;n++){
					var arrJ=zArrCityLookup[n].split("\t");
					if(arrJ[0]===textToForm){
						textValue=arrJ[1];
						break;
					}
				}
				obj.value=textToForm;
				obj2.value=textValue;
			}else{
				c.className="zTOB-link";
			}
		}
	}
}	


function zInputHideDiv(name){
	var z=document.getElementById("zTOB");
	if(z!==null){z.style.display="none";}
}

	

function zIsAlphabet(elem){
	var alphaExp = /^[a-zA-Z0-9 ]+$/;
	if(elem.match(alphaExp)){
		return elem;
	}else{
		return elem;
	}
}


var daysToOffset=0;

function zMakeEnglish(elem){
	var elem1 = elem;
	var alphaExp = /^[a-zA-Z ]+$/;
	if(elem.match(alphaExp)){
		return elem;
	}else{
		var englishList = "A,A,A,A,A,A,AE,C,E,E,E,E,I,I,I,I,ETH,N,O,O,O,O,O,O,U,U,U,U,Y,THORN,s,a,a,a,a,a,a,ae,c,e,e,e,e,i,i,i,i,eth,n,o,o,o,o,o,o,u,u,u,u,y,thorn,y,OE,oe,S,s,Y,f";		 
		var foreignList="�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�";		
		var arrEnglish = englishList.split( "," );
		var arrForeign = foreignList.split( "," );
		for(e = 0; e < elem.length; e ++){
			for(f=0; f < arrForeign.length; f++){				
				if (elem1.charAt(e) === arrForeign[f]){
					myChar = elem1.charAt(e);
					if (!(myChar.match(alphaExp))){
						pattern = new RegExp(arrForeign[f]);
						elem1 = elem1.replace(pattern, arrEnglish[f]);
					}
				}
			}
		}
		return elem1;
	}
}

function zStringReplaceAll(str, strTarget, strSubString){
	return str.replace( new RegExp(strTarget,"g"), strSubString ); 
}

function zFormOnKeyUp(formName, fieldIndex){
	var f=zFormData[formName].arrFields[fieldIndex];
	var o=document.getElementById(f.id);
	if(zFormData[formName].error){
		zFormSubmit(formName,true,false);
	}
	
}
function zFormOnChange(formName, fieldIndex){
	var f=zFormData[formName].arrFields[fieldIndex];
	var o=document.getElementById(f.id);
	if(zFormData[formName].error){
		zFormSubmit(formName,true,false);
	}
	if(typeof zFormData[formName].onChangeCallback === "undefined") return;
	zFormData[formName].onChangeCallback(formName);
}
function zFormSetError(id,error){
	var tr=document.getElementById(id+'_container');
	if(tr !== null){
		if(error){
			tr.className="tr_error";
		}else{
			tr.className="";
		}
	}
}

var zAjaxData=[];
var zAjaxCounter=0;
/*
var tempObj={};
tempObj.id="zMapListing";
tempObj.url="/urlInQuotes.html";
tempObj.callback=functionNameNoQuotes;
tempObj.errorCallback=functionNameNoQuotes;
tempObj.cache=false; // set to true to disable ajax request when already downloaded same URL
tempObj.ignoreOldRequests=true; // causes only the most recent request to have its callback function called.
zAjax(tempObj);
*/
function zAjax(obj){
	var req = null;  
	if(window.XMLHttpRequest){ 
	  req = new XMLHttpRequest();  
	}else if (window.ActiveXObject){ 
	  req = new ActiveXObject('Microsoft.XMLHTTP');  
	}
	if(typeof zAjaxData[obj.id]==="undefined"){
		zAjaxData[obj.id]=new Object();
		zAjaxData[obj.id].requestCount=0;
		zAjaxData[obj.id].requestEndCount=0;
		zAjaxData[obj.id].cacheData=[];
	}
	if(typeof obj.postObj === "undefined"){
		obj.postObj={};	
	}
	var postData="";
	for(var i in obj.postObj){
		postData+=i+"="+encodeURIComponent(obj.postObj[i])+"&";
	}
	if(typeof obj.cache==="undefined"){
		obj.cache=false;	
	}
	if(typeof obj.method==="undefined"){
		obj.method="get";	
	}
	if(typeof obj.debug==="undefined"){
		obj.debug=false;	
	}
	if(typeof obj.errorCallback==="undefined"){
		obj.errorCallback=function(){};	
	}
	if(typeof obj.ignoreOldRequests==="undefined"){
		obj.ignoreOldRequests=false;	
	}
	if(typeof obj.url==="undefined" || typeof obj.callback==="undefined"){
		alert('zAjax() Error: obj.url and obj.callback are required');	
	}
	
	zAjaxData[obj.id].requestCount++;
	zAjaxData[obj.id].cache=obj.cache;
	zAjaxData[obj.id].debug=obj.debug;
	zAjaxData[obj.id].method=obj.method;
	zAjaxData[obj.id].url=obj.url;
	zAjaxData[obj.id].ignoreOldRequests=obj.ignoreOldRequests;
	zAjaxData[obj.id].callback=obj.callback;
	zAjaxData[obj.id].errorCallback=obj.errorCallback;
	if(zAjaxData[obj.id].cache && zAjaxData[obj.id].cacheData[obj.url] && zAjaxData[obj.id].cacheData[obj.url].success){
		zAjaxData[obj.id].callback(zAjaxData[obj.id].cacheData[obj.url].responseText);
	}
	req.onreadystatechange = function(){  
		if(req.readyState === 4 || req.readyState === "complete" || (zMSIEBrowser!==-1 && zMSIEVersion<=7 && this.readyState==="loaded")){
			var id=req.getResponseHeader("x_ajax_id");
			if(typeof id !== "undefined" && new String(id).indexOf(",") !== -1){
				id=id.split(",")[0];
			}
			if(req.status!==200 && req.status!==301 && req.status!==302){
				if(id===null || id===""){
					if(zAjaxLastRequestId !== false){
						id=zAjaxLastRequestId;
						zAjaxData[id].errorCallback(req);
					}else{
						alert("Sorry, but that page failed to load right now, please refresh your browser or come back later.");
					//document.write(req.responseText);
					}
				}else{
					if(zAjaxData[id].debug){
						document.write('AJAX SERVER ERROR - (Click back and refresh to continue):<br />'+req.responseText);
					}else{
						zAjaxData[id].errorCallback(req);
					}
				}
				//return;
			}else if(id===null || id===""){
				alert("Invalid ajax response - missing id");
				//alert("zAjax() Error: The ajax URL MUST output the x_ajax_id.\nColdfusion Example: <cf"+"header name=\"x_ajax_id\" value=\"#x_ajax_id#\">\nNote: x_ajax_id is passed via zAjax, do not put this in the url yourself!\n"+zAjaxData[obj.id].url);	
				return;
			}
			if(typeof zAjaxData[id] !== "undefined"){
				zAjaxData[id].requestEndCount++;
				if(!zAjaxData[id].ignoreOldRequests || zAjaxData[id].requestCount === zAjaxData[id].requestEndCount){
					if(req.status === 200 || req.status===301 || req.status===302){
						if(zAjaxData[id].cache){
							zAjaxData[id].cacheData[zAjaxData[id].url]=new Object();
							zAjaxData[id].cacheData[zAjaxData[id].url].responseText=req.responseText;
							zAjaxData[id].cacheData[zAjaxData[id].url].success=true;
						}
						zAjaxData[id].callback(req.responseText);
					/*}else{ 
						if(zAjaxData[id].debug){
							document.write('AJAX SERVER ERROR - (Click back and refresh to continue):<br />'+req.responseText);
						}else{
							zAjaxData[id].errorCallback(req);
						}
						zAjaxLastRequestId=false;*/
					}
				}
			}
			zAjaxLastRequestId=false;
		} 
	};
	var randomNumber = Math.random()*1000;
	var derrUrl="&zFPE=1";
	if(zAjaxData[obj.id].debug){
		derrUrl="";
	}
	zAjaxLastRequestId=obj.id;
	var action=zAjaxData[obj.id].url;
	/*if(action.indexOf("x_ajax_id=") !== -1){
		alert("zAjax() Error: Invalid URL.  \"x_ajax_id\" can only be added by the system.\nDo not put this CGI variable in the action URL.");
	}*/
	if(action.indexOf("?") === -1){
		action+='?'+derrUrl+'&ztmp='+randomNumber;
	}else{
		action+='&'+derrUrl+'&ztmp='+randomNumber;
	}
	action+="&x_ajax_id="+escape(obj.id);
	if(zAjaxData[obj.id].method.toLowerCase() === "get"){
		req.open(zAjaxData[obj.id].method,action,true);
		//req.setRequestHeader("Accept-Encoding","gzip,deflate;q=0.5");
		//req.setRequestHeader("TE","gzip,deflate;q=0.5");
		req.send("");  
	}else if(zAjaxData[obj.id].method.toLowerCase() === "post"){
		//alert('not implemented - use zForm() instead');
		req.open(zAjaxData[obj.id].method,action,true);
		req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

		req.send(postData);  
	}
}
var zAjaxLastRequestId=false;
var zAjaxLastFormName="";
var zAjaxOnLoadCallback=function(){};
var zAjaxOnErrorCallback=function(){};
function zFormSubmit(formName,validationOnly,onChange,debug, returnObject){	
	// validation for all fields...
	if(typeof zFormData[formName] === "undefined" || typeof zFormData[formName].arrFields === "undefined"){
		return;
	}
	if((validationOnly===null || !validationOnly) && onChange===false){
		if(zFormData[formName].submitContainer !== ""){
			var sc=document.getElementById(zFormData[formName].submitContainer);
			if(sc !== null){
				zFormData[formName].submitContainerBackup=sc.innerHTML;
				sc.innerHTML="Please wait...";
			}
		}
	}
	//addHistoryEvent();
	var arrQuery=new Array();
	var error=false;
	var anyError=false;
	var arrError=new Array();
	var obj=new Object();
	for(var i=0;i<zFormData[formName].arrFields.length;i++){
		error=false;
		var f=zFormData[formName].arrFields[i];
		if(typeof f === "undefined"){
			continue;
		}
		var value="";
		if(f.type === "file" && zFormData[formName].ajax){
			alert('File upload doesn\'t work with AJAX. Must use iframe and server-side progress bar (php for non-breaking uploads)');
			return false;
		}else if(f.type === "text" || f.type==="file" || f.type==="hidden"){
			var o=document.getElementById(f.id);
			value=o.value;
		}else if(f.type === "select"){
			var o=document.getElementById(f.id);
			if(typeof o.multiple !== "undefined" && o.multiple){
				for(var g=0;g<o.options.length;g++){
					if(o.options[g].selected){
						if(value.length !== 0){
							value+=",";
						}
						value+=o.options[g].value;
					}
				}
			}else{
				if(o.selectedIndex===-1){
					o.selectedIndex=0;
				}
				if(o.options[o.selectedIndex].value !== ""){
					value=o.options[o.selectedIndex].value;
				}
			}
		}else if(f.type === "radio"){
			var o=document.getElementById(f.id);
			var arrF=document[formName][f.id];
			for(var g=0;g<arrF.length;g++){
				if(arrF[g].checked){
					value=arrF[g].value;
				}
			}
		}else if(f.type === "checkbox"){
			var o=document.getElementById(f.id);
			if(o.checked){
				value=o.value;
			}
		}else if(f.type === "zExpandingBox"){
            arrV=new Array();
            for(var g=0;g<zExpArrMenuBox.length;g++){
            	if(zExpArrMenuBox[g]===f.id){
		            var c=document.getElementById('zExpMenuBoxCount'+g).value;
                    for(var n=0;n<c;n++){
                    	var cr=document.getElementById('zExpMenuOption'+g+'_'+n);
                        if(cr.checked){
                        	arrV.push(cr.value);
                        }
                    }
                }
            }
            value=arrV.join(",");
		}
		value=value.replace(/^\s+|\s+$/g,"");
		obj[f.id]=escape(value);
		arrQuery.push(f.id+"="+escape(value));
		if(value===""){
			if(f.allowNull !== null & f.allowNull){
				continue;
			}else if(f.required !== null && f.required){
				arrError.push(f.friendlyName+' is required.');
				zFormSetError(f.id,true);
				error=true;
				anyError=true;
				continue;
			}
		}
		if(f.number !== null & f.number){
			value2 = parseFloat(value);
			if(value !== value2){
				arrError.push(f.friendlyName+' must be a number.');
				zFormSetError(f.id,true);
				error=true;
				anyError=true;
				continue;
			}
		}
		if(f.email !== null & f.email){
			var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
			if (!filter.test(value)) {
				arrError.push(f.friendlyName+' must be a well formatted email address, (ex. johndoe@domain.com).');
				zFormSetError(f.id,true);
				error=true;
				anyError=true;
				continue;
			}
		}
		zFormSetError(f.id,false);
	}
	if(typeof returnObject !== "undefined" && returnObject){
		return obj;	
	}
	var queryString=arrQuery.join("&");
	var fm=document.getElementById("zFormMessage_"+formName);
	if(anyError){
		fm.innerHTML='<table style="width:100%;border-spacing:5px;"><tr><th>Please correct your entry and try again.</th></tr><tr><td>'+arrError.join("</td></tr><tr><td>")+'</td></tr></table>';
		fm.style.display="block";
		zFormData[formName].error=true;
	}else{
		zFormData[formName].error=false;
		fm.style.display="none";
	}
	if(validationOnly!==null && validationOnly){
		return false;
	}
	if(anyError){
		window.location.href='#anchor_'+formName;
		if(zFormData[formName].submitContainer !== ""){
			var sc=document.getElementById(zFormData[formName].submitContainer);
			if(sc !== null){
				sc.innerHTML=zFormData[formName].submitContainerBackup;
			}
		}
		return false;
	}
	// ignore double clicks / incomplete requests.
	if(zFormData[formName].ajax){
		if(zFormData[formName].ignoreOldRequests && zFormData[formName].ajaxStartCount !== zFormData[formName].ajaxEndCount){
			/*if(zFormData[formName].ajaxSuccess){
				// no new data needed
				//alert('already done');
			}*/
		}else{
			var req = null;  
			if(window.XMLHttpRequest){ 
			  req = new XMLHttpRequest();  
			}else if (window.ActiveXObject){ 
			  req = new ActiveXObject('Microsoft.XMLHTTP');  
			}
			zAjaxLastFormName=formName;
			zAjaxLastOnLoadCallback=zFormData[formName].onLoadCallback;
			zAjaxLastOnErrorCallback=zFormData[formName].onErrorCallback;
			//req.formName=formName;
			//req.onLoadCallback=zFormData[formName].onLoadCallback;
			//req.onErrorCallback=zFormData[formName].onErrorCallback;
			req.onreadystatechange = function(){  
				if(req.readyState === 4 || req.readyState === "complete" || (zMSIEBrowser!==-1 && zMSIEVersion<=7 && this.readyState==="loaded")){
					//alert(req.status+":complete"+req.responseText);
					if(typeof zFormData[zAjaxLastFormName] !== "undefined"){
						zFormData[zAjaxLastFormName].ajaxEndCount++;
						if(req.status === 200){
							zAjaxLastOnLoadCallback(req.responseText);
							//zFormData[zAjaxLastFormName].onLoadCallback(req.responseText);
							zFormData[zAjaxLastFormName].ajaxSuccess=true;
							if(zFormData[zAjaxLastFormName].successMessage !== false){
								var fm=document.getElementById("zFormMessage_"+zAjaxLastFormName);
								fm.style.display="block";
								fm.innerHTML='<div class="successBox">Form submitted successfully.<br />'+req.responseText+'</div>';
							}
						}else{ 
							zFormData[zAjaxLastFormName].ajaxStartCount=0;
							zFormData[zAjaxLastFormName].ajaxEndCount=0;
							zFormData[zAjaxLastFormName].ajaxSuccess = false;
							if(zFormData[zAjaxLastFormName].debug){
								document.write('AJAX SERVER ERROR - (Click back and refresh to continue):<br />'+req.responseText);
								//zAjaxLastOnLoadCallback(req.responseText);
							}else{
								zAjaxLastOnErrorCallback(req.status+": The server failed to process your request.\nPlease try again later.");
							}
						} 
						if(zFormData[zAjaxLastFormName].submitContainerBackup !== null && zFormData[zAjaxLastFormName].submitContainer !== ""){
							var sc=document.getElementById(zFormData[zAjaxLastFormName].submitContainer);
							if(sc !== null){
								sc.innerHTML=zFormData[zAjaxLastFormName].submitContainerBackup;
							}
						}
					}
				} 
			};		
			// reset the ajax request status variables
			zFormData[formName].ajaxSuccess=false;
			zFormData[formName].ajaxStartCount++;
			var randomNumber = Math.random()*1000;
			var action=zFormData[formName].action;
			
			var derrUrl="&zFPE=1";
			if(zFormData[formName].debug){
				derrUrl="";
			}
			if(zFormData[formName].method.toLowerCase() === "get"){
				if(action.indexOf("?") === -1){
					action+='?'+queryString+derrUrl+'&ztmp='+randomNumber;
				}else{
					action+='&'+queryString+derrUrl+'&ztmp='+randomNumber;
				}
				req.open(zFormData[formName].method,action,true);
				//req.setRequestHeader("Accept-Encoding","gzip,deflate;q=0.5");
				//req.setRequestHeader("TE","gzip,deflate;q=0.5");
				req.send("");  
			}else if(zFormData[formName].method.toLowerCase() === "post"){
				if(action.indexOf("?") === -1){
					action+=derrUrl+'&ztmp='+randomNumber;
				}else{
					action+=derrUrl+'&ztmp='+randomNumber;
				}
				queryString=encodeURI(queryString);
				req.open(zFormData[formName].method,action,true);
				// call open before sending headers
				//req.setRequestHeader("Accept-Encoding","gzip,deflate;q=0.5");
				//req.setRequestHeader("TE","gzip,deflate;q=0.5");
				req.setRequestHeader("Content-type", zFormData[formName].contentType);
				//req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
				req.send(queryString);  
			}
		}
		return false;
	}else{
		return true;
	}
}


function setPos(obj,left,top){
	obj.style.left=left+"px";
	obj.style.top=top+"px";
}



// dragging
var zMousePosition={x:0,y:0};

function zDrag_mouseCoords(e) {
	var sl=document.documentElement.scrollLeft;
	var st=document.documentElement.scrollTop;
	if(typeof sl === "undefined") sl=document.body.scrollLeft;
	if(typeof st === "undefined") st=document.body.scrollTop;
    if (document.layers) {
        var xMousePosMax = window.innerWidth+window.pageXOffset;
        var yMousePosMax = window.innerHeight+window.pageYOffset;
    } else if (document.all) {
		var cw=document.documentElement.clientWidth ? document.documentElement.clientWidth : document.body.clientWidth;
		var ch=document.documentElement.clientHeight ? document.documentElement.clientHeight : document.body.clientHeight;
        var xMousePosMax = cw+sl;
        var yMousePosMax = ch+st;
    } else if (document.getElementById) {
        var xMousePosMax = window.innerWidth+window.pageXOffset;
        var yMousePosMax = window.innerHeight+window.pageYOffset;
    }
	var xMousePos=0;
	var yMousePos=0;
	if (e.pageX){ xMousePos=e.pageX;
	}else if(e.clientX){ xMousePos=e.clientX + (sl);}
	if (e.pageY){ yMousePos=e.pageY;
	}else if (e.clientY){ yMousePos=e.clientY + (st);}
	return {x:xMousePos,y:yMousePos,pageWidth:xMousePosMax,pageHeight:yMousePosMax};	
}
function zDrag_makeClickable(object){
	object.onmousedown = function(){
		zDrag_dragObject = this;
	};
}
function zDragTableOnMouseUp(){};
function zDrag_mouseUp(ev){
	ev           = ev || window.event;
	zDragTableOnMouseUp(ev);
	var mousePos = zDrag_mouseCoords(ev);
	for(var i=0; i<zDrag_dropTargets.length; i++){
		var curTarget  = zDrag_dropTargets[i];
		var targPos    = zDrag_getPosition(curTarget);
		var targWidth  = parseInt(curTarget.offsetWidth);
		var targHeight = parseInt(curTarget.offsetHeight);

		/*if(
			(mousePos.x > targPos.x)                &&
			(mousePos.x < (targPos.x + targWidth))  &&
			(mousePos.y > targPos.y)                &&
			(mousePos.y < (targPos.y + targHeight))){
				// zDrag_dragObject was dropped onto curTarget!
		}*/
	}
	if(zDrag_dragObject!==null){
		var paramObj=zDrag_arrParam[zDrag_dragObject.id];
		if(typeof paramObj !== "undefined"){
			paramObj.callbackFunction(zDrag_dragObject,paramObj,true);
		}
	}
	zDrag_dragObject   = null;
}

function zDrag_getMouseOffset(target, ev){
	ev = ev || window.event;
	var docPos    = zDrag_getPosition(target);
	var mousePos  = zDrag_mouseCoords(ev);
	return {x:mousePos.x - docPos.x, y:mousePos.y - docPos.y};
}
function zDrag_getPosition(e){
	var left = 0;
	var top  = 0;
	while (e.offsetParent){
		left += e.offsetLeft;
		top  += e.offsetTop;
		e     = e.offsetParent;
	}
	left += e.offsetLeft;
	top  += e.offsetTop;
	return {x:left, y:top};
}

var zDragTableOnMouseMove=function(){};
var zMapMarkerRollOutV3=function(){};
var humanMovement=false;
function zDrag_mouseMove(ev){
	zDragTableOnMouseMove(ev);
	zOutEditDiv(ev);
	zMapMarkerRollOutV3(false);
	ev           = ev || window.event;
	var mousePos = zDrag_mouseCoords(ev); 
	zMousePosition=mousePos;
	if(zMousePosition.x+zMousePosition.y > 0){
		humanMovement=true;
	}
	if(zDrag_dragObject){
		var pObj=zDrag_arrParam[zDrag_dragObject.id];
		if(typeof pObj === "undefined" || typeof pObj.boxObj === "undefined"){
			return;
		}
		var bObj=document.getElementById(pObj.boxObj);
		var p1=zGetAbsPosition(bObj);
		if(navigator.userAgent.indexOf("MSIE 6.0") !== -1){
			if(zDrag_arrParam[zDrag_dragObject.id].zValue+3===zDrag_arrParam[zDrag_dragObject.id].zValueValue){
				zDrag_dragObject.style.marginRight=(((parseInt(p1.width)-((mousePos.x - zDrag_mouseOffset.x) - p1.x))-parseInt(zDrag_dragObject.style.width))/2)+"px";
			}else{
				zDrag_dragObject.style.marginLeft=(((mousePos.x - zDrag_mouseOffset.x) - p1.x)/2)+"px";
			}
		}else{
			if(zDrag_arrParam[zDrag_dragObject.id].zValue+3===zDrag_arrParam[zDrag_dragObject.id].zValueValue){
				zDrag_dragObject.style.marginRight=((parseInt(p1.width)-((mousePos.x - zDrag_mouseOffset.x) - p1.x))-parseInt(zDrag_dragObject.style.width))+"px";
			}else{
				zDrag_dragObject.style.marginLeft=Math.min(p1.width, Math.max(0,((mousePos.x - zDrag_mouseOffset.x) - p1.x)))+"px";
			}
		}
		zDrag_arrParam[zDrag_dragObject.id].callbackFunction(zDrag_dragObject,zDrag_arrParam[zDrag_dragObject.id]);
		return false;
	}
}
function zDrag_makeDraggable(obj,paramObj){
	if(!obj) return;
	zDrag_arrParam[obj.id]=paramObj;
	obj.ondragstart = function(ev){
		return false;
	};
	obj.onmousedown = function(ev){
		zDrag_dragObject  = this;
		zDrag_mouseOffset = zDrag_getMouseOffset(this, ev);
		return false;
	};
	paramObj.callbackFunction(obj,paramObj);
}

function zGoToURL(url) { 
	var a=document.getElementById("zOverEditATag");
	a.setAttribute("href",url);
	if(a.click){
		a.click();
	}else{
		window.top.location.href=url;
	}
}

var zCurOverEditLink="";
var zOverEditDisableMouseOut=false;
var zCurOverEditObj=null;
function zOverEditClick(){
	if(zCurOverEditLink!==""){
		zGoToURL(zCurOverEditLink);
	}
}
var zOverEditLastLink="";
var zOverEditLastPos={x:0,y:0};
function zOverEditDiv(o,theLink){
	var zOverEditDivTag1=document.getElementById("zOverEditDivTag");
	if(theLink !== zOverEditLastLink){
		zOverEditLastLink=theLink;
		zCurOverEditObj=document.getElementById(o);
		zCurOverEditLink=theLink;
		zOverEditDivTag1.style.left=(zMousePosition.x+10)+"px";
		zOverEditDivTag1.style.top=(zMousePosition.y+10)+"px";
		zOverEditLastPos={x:zMousePosition.x,y:zMousePosition.y};
		zOverEditDivTag1.style.display="block";
	}else{
		zOverEditDivTag1.style.display="block";
		var xChange=Math.abs((zMousePosition.x+10)-zOverEditLastPos.x);
		var yChange=Math.abs((zMousePosition.y+10)-zOverEditLastPos.y);
		if(xChange<=70 && yChange<=70){
			return;
		}else{
			zCurOverEditObj=document.getElementById(o);
			zCurOverEditLink=theLink;
			zOverEditDivTag1.style.left=(zMousePosition.x+10)+"px";
			zOverEditDivTag1.style.top=(zMousePosition.y+10)+"px";
			zOverEditLastPos={x:zMousePosition.x,y:zMousePosition.y};
		}
	}
}


function zOutEditDiv(){
	var zOverEditDivTag1=document.getElementById("zOverEditDivTag");
	if(zOverEditDivTag1 !== null && zOverEditDivTag1.style.display==="block"){
		var xChange=Math.abs((zMousePosition.x+10)-zOverEditLastPos.x);
		var yChange=Math.abs((zMousePosition.y+10)-zOverEditLastPos.y);
		if(xChange>300 || yChange>300){
			zOverEditDivTag1.style.display="none";
		}
	}
}
function zDrag_addDropTarget(dropTarget){
	zDrag_dropTargets.push(dropTarget);
}

if(typeof document.onmousemove === "function"){
	var zDragOnMouseMoveBackup=document.onmousemove;
}else{
	var zDragOnMouseMoveBackup=function(){};
}
$(document).bind("mousemove", function(ev){
	zDragOnMouseMoveBackup(ev);
	zDrag_mouseMove(ev);

});
if(typeof document.onmouseup === "function"){
	var zDragOnMouseUpBackup=document.onmouseup;
}else{
	var zDragOnMouseUpBackup=function(){};
}
$(document).bind("mouseup", function(ev){
	zDragOnMouseUpBackup(ev);
	zDrag_mouseUp(ev);

});



var zDrag_arrParam=new Array();
var zDrag_dragObject  = null;
var zDrag_mouseOffset = null;
var zDrag_dropTargets = [];









var zInputSlideOldValue="";
function zInputSlideOnChange(oid,v1,v2,zExpValue){
	var d1=document.getElementById(oid);
	if(v1==="") v1="min";
	if(v2==="") v2="max";
	var newValue=v1+"-"+v2;
	if(newValue !== zInputSlideOldValue){
		d1.value=newValue;
		zInputSlideOldValue=newValue;
		if(zExpValue!==null){
			zExpOptionSetValue(zExpValue,newValue);
		}
		d1.onchange();
	}
}

var zArrSetSliderInputArray=[];
var zArrSetSliderInputUniqueArray=[];
function zSetSliderInputArray(id){
	if(typeof zArrSetSliderInputUniqueArray[id] === "undefined"){
		zArrSetSliderInputUniqueArray[id]=true;
		d1=document.getElementById(id);
		zArrSetSliderInputArray.push(d1);
	}
}
function zSliderInputResize(){
	for(var i=0;i<zArrSetSliderInputArray.length;i++){
		zArrSetSliderInputArray[i].onclick();
		zArrSetSliderInputArray[i].onblur();
	}
}

zArrResizeFunctions.push({functionName:zSliderInputResize});

function zInputSliderSetValue(id, zV, zOff, v, zExpValue, sliderIndex){
	var d1=document.getElementById(id);
	var d2=document.getElementById(id+"_label");
	var f=false; 
	var alphaExp = /[^\+0-9\.]/;
	v=v.split(",").join("").split("$").join("");
	if(v.match(alphaExp) && v!=="min" && v!=="max"){
		if(zV+3===zOff){
			v=zValues[zV+5];
		}else{
			v=zValues[zV+4];
		}
		d2.value=v;
		f=true;
		alert('You may type only numbers 0-9.');
	}
	if(v==="min" || v==="max"){
		return;
	}
	var a1=zValues[zV];
	var lastV=a1[0];
	var curV=a1[0];
	var curPosition=0;
	var t1=document.getElementById("zInputSliderBox"+zV);
	var curPos=zGetAbsPosition(t1);
	var curSlider=document.getElementById("zInputDragBox"+sliderIndex+"_"+zV);
	var curValue=d2.value;
	curValue=parseFloat(curValue.split(",").join("").split("$").join(""));
	var found=false;
	for(var i=0;i<a1.length;i++){
		var curA=parseFloat(a1[i].split(",").join("").split("$").join(""));
		if(curValue < curA){
			if(i>0){
				found=true;
				tempLastV=parseFloat(lastV.split(",").join("").split("$").join(""));
				// somewhere between lastV and curV
				curPosition=(i+((curValue-tempLastV)/(curA-tempLastV)));
			}
			break;
		}
		lastV=a1[i];
	}
	if(id.indexOf("search_Rate_low") !==-1){
		//console.log(curPosition);
	}
	if(!found){
		curPosition=a1.length;	
	}
	
	v=v.split(",").join("").split("$").join("");
	d2.value=v;
	v=parseFloat(v);
	if(zV+3===zOff){
		if(parseFloat(zValues[zV+2])>parseFloat(v)){
			v=zValues[zV+2];
			if(d1.value===""){
				if(sliderIndex===2){
					d2.value=zValues[zV+3];
				}else{
					d2.value=zValues[zV+2];
				}
			}else{
				d2.value=d1.value;//zValues[zV+5];
			}
			alert('The first value must be smaller than the second value. Your data has been reset.');
			return;
		}
	}else{
		if(parseFloat(v)>parseFloat(zValues[zV+3])){
			v=zValues[zV+3];
			if(d1.value===""){
				if(sliderIndex===2){
					d2.value=zValues[zV+3];
				}else{
					d2.value=zValues[zV+2];
				}
			}else{
				d2.value=d1.value;//zValues[zV+4];
			}
			alert('The first value must be smaller than the second value. Your data has been reset.');
			return;
		}
	}
	// get width of the bar
	var tWidth=curPos.width-20;
	var newSliderPos=Math.round((curPosition/(a1.length))*tWidth);
	if(sliderIndex === 2){
		curSlider.style.marginRight=(tWidth-newSliderPos)+"px";
	}else{
		curSlider.style.marginLeft=newSliderPos+"px";
	}
	d1.value=v;
	zValues[zOff]=v;
	zInputSlideOnChange('zInputHiddenValues'+zV,zValues[zV+2],zValues[zV+3],zExpValue);
}

function zInputSlideLimit(obj,paramObj,forceOnChange){
	var dd1=document.getElementById(paramObj.valueId);
	var dd2=document.getElementById(paramObj.labelId);
	var firstLoad=false;
	if(zDrag_dragObject===null){
		firstLoad=true;
		if(dd2.value===""){
			if(paramObj.constrainLeft){
				dd2.value="max";
				dd1.value="";
			}else{
				dd2.value="min";
				dd1.value="";
			}
		}
	}
	// if(navigator.userAgent.indexOf("MSIE 6.0") !== -1){ - need to double or halve the value to force this to work on IE 6.
	if(!firstLoad){
		var rightSlider=false;
		if(paramObj.zValue+3===paramObj.zValueValue){
			rightSlider=true;
		}
		var d1=zDrag_getPosition(obj);
		var d2=document.getElementById("zInputSliderBox"+paramObj.zValue);
		var d2pos=zGetAbsPosition(d2);
		var d3=zDrag_getPosition(d2);
		if(paramObj.constrainObj){
			var sw=parseInt(d2pos.width)-parseInt(obj.style.width);
		}else{
			var sw=parseInt(d2pos.width);
		}
		var dw=parseInt(obj.style.width);
		if(navigator.userAgent.indexOf("MSIE 6.0") !== -1){
			dw/=2;
			sw/=2;
		}
		var y=d3.y;
		if(rightSlider){
			var x=parseInt(obj.style.marginRight);
		}else{
			var x=parseInt(obj.style.marginLeft);
		}
		var first=false;
		var last=false;
		if(paramObj.constrainObj){
			d4=document.getElementById(paramObj.constrainObj);
			d4.style.zIndex=1;
			obj.style.zIndex=3;
			if(rightSlider){
				var dx=sw-(dw+parseInt(d4.style.marginLeft));
			}else{
				var dx=sw-(dw+parseInt(d4.style.marginRight));
			}
			d5=zDrag_getPosition(d4);
			if(paramObj.constrainLeft){
				if(x>=dx){
					x=dx;
					if(x>=sw-dw){
						first=true;
					}
				}else if(x<=0){
					x=0;
					if(x<=0){
						last=true;
					}
				}
			}else{
				var sw2=dx-0;
				if(x<=0){
					x=0;
					first=true;
				}else if(x>=dx){
					x=dx;
					if(x+dw>=0+sw){
						last=true;
					}
				}
			}
		}else{
			if(x<=0){
				x=0;
				first=true;
			}else if(x+dw>=0+sw){
				x=((0+sw)-dw);
				last=true;
			}
		}
		if(paramObj.zValue+3===paramObj.zValueValue){
			obj.style.marginRight=x+"px";
			x=sw-(x+dw);
			percent=Math.max(0,(x)/(sw-dw));
		}else{
			obj.style.marginLeft=x+"px";
			percent=Math.min(1,Math.max(0,(x)/(sw-dw)));
		}
		var arrLabel=zValues[paramObj.zValue];
		var arrValue=zValues[paramObj.zValue+1];
		offset=Math.min(arrLabel.length-1,Math.round(percent*(arrLabel.length-0.5)));
		if(first){
			dd1.value="";
			dd2.value="min";
		}else if(last){
			dd1.value="";
			dd2.value="max";
		}else{
			dd1.value=arrValue[offset];
			dd2.value=arrLabel[offset];
		}
		zValues[paramObj.zValueLabel]=dd2.value;
		zValues[paramObj.zValueValue]=dd1.value;
	}
	if(forceOnChange!==null && forceOnChange){
		zInputSlideOnChange('zInputHiddenValues'+paramObj.zValue,zValues[paramObj.zValue+2],zValues[paramObj.zValue+3],paramObj.zExpOptionValue);
	}
}

var zExpOptionLabelHTML=[];
function zExpOptionSetValue(i,v,h){
	var d1=document.getElementById('zExpOption'+i+'_button');
	if(h===null) h="none";
	if(d1!==null) d1.innerHTML=zExpOptionLabelHTML[i]+" <span id=\"zExpOption"+i+"_value\" style=\"display:"+h+";\">"+zStringReplaceAll(v,",",", ")+"</span>";
}


function zCheckboxOnChange(obj,zv){
	var running=true;
	var n=0;
	var arrV=[];
	var arrL=[];
	while(running){
		n++;
		var d2=document.getElementById(obj.name+"label"+n);
		if(d2===null) break;
		var d1=document.getElementById(obj.name+n);
		if(d1.checked){
			arrL.push(d2.innerHTML);
			arrV.push(d1.value);
		}
	}
	var dn=obj.name.substr(0,obj.name.length-5);
	var d1=document.getElementById(dn);
	d1.value=arrV.join(",");
	if(zv!==-1){
		zExpOptionSetValue(zv,"<br />"+arrL.join("<br />"));
	}
	if(d1.onchange != null){
		d1.onchange();
	}
}

function zEnableTextSelection(target){
	target.onmousedown=function(){return true;};
	target.onselectstart=function(){return true;};
	target.style.MozUserSelect="text";
}
function zDisableTextSelection(target){
if (typeof target.onselectstart!=="undefined") //IE route
	target.onselectstart=function(){return false;};
else if (typeof target.style.MozUserSelect!=="undefined") //Firefox route
	target.style.MozUserSelect="none";
else if(target.onmousedown===null) //All other route (ie: Opera)
	target.onmousedown=function(){return false;};
}


var zMotiontimerlen = 10;
var zMotionslideAniLen = 150;
var zMotiontimerID = new Array();
var zMotionstartTime = new Array();
var zMotionobj = new Array();
var zMotionendHeight = new Array();
var zMotionmoving = new Array();
var zMotiondir = new Array();
var zMotionLabel=new Array();
var zMotionHOC=new Array();
var zMotionObjClicked="";
function zMotionOnMouseDown(objname){
	zMotionObjClicked=objname;
	return false;
}
function zMotiontoggleSlide(objname, label, hoc){
	zMotionLabel[objname]=document.getElementById(label);
	if(hoc!==""){
		zMotionHOC[objname]=document.getElementById(hoc);
	}else{
		zMotionHOC[objname]="";	
	}
	if(zMotionObjClicked!==objname) return;
	if(document.getElementById(objname).style.display === "none"){
		zMotionHOC[objname].style.display="none";
		zMotionslidedown(objname);
	}else{
		zMotionslideup(objname);
	}
}
function zMotionslidedown(objname){
	if(zMotionmoving[objname])
			return;

	if(document.getElementById(objname).style.display !== "none")
			return; // cannot slide down something that is already visible

	zMotionmoving[objname] = true;
	zMotiondir[objname] = "down";
	zMotionstartslide(objname);
}

function zMotionslideup(objname){
	if(zMotionmoving[objname])
			return;

	if(document.getElementById(objname).style.display === "none")
			return; // cannot slide up something that is already hidden

	zMotionmoving[objname] = true;
	zMotiondir[objname] = "up";
	zMotionstartslide(objname);
}

function zMotionstartslide(objname){
	zMotionobj[objname] = document.getElementById(objname);

	zMotionendHeight[objname] = parseInt(zMotionobj[objname].style.height);
	zMotionstartTime[objname] = (new Date()).getTime();

	if(zMotiondir[objname] === "down"){
		zMotionobj[objname].style.height = "1px";
	}
	zMotionobj[objname].style.overflow="hidden";
	zMotionobj[objname].style.display = "block";
	zMotiontimerID[objname] = setInterval('zMotionslidetick("' + objname + '");',zMotiontimerlen);
}

function zMotionslidetick(objname){
	var elapsed = (new Date()).getTime() - zMotionstartTime[objname];
	if (elapsed > zMotionslideAniLen){
		zMotionendSlide(objname);
	}else{
		var d =Math.round(elapsed / zMotionslideAniLen * zMotionendHeight[objname]);
		if(zMotiondir[objname] === "up") d = zMotionendHeight[objname] - d;
		zMotionobj[objname].style.height = d + "px";
	}
}

function zMotionendSlide(objname){
	clearInterval(zMotiontimerID[objname]);

	if(zMotiondir[objname] === "up"){
		zMotionobj[objname].style.display = "none";
		zMotionHOC[objname].style.display="inline";
	}else{
		zMotionobj[objname].style.overflow="auto";
	}
	zMotionobj[objname].style.height = zMotionendHeight[objname] + "px";

	delete(zMotionHOC[objname]);
	delete(zMotionLabel[objname]);
	delete(zMotionmoving[objname]);
	delete(zMotiontimerID[objname]);
	delete(zMotionstartTime[objname]);
	delete(zMotionendHeight[objname]);
	delete(zMotionobj[objname]);
	delete(zMotiondir[objname]);

	return;
}



function zCLink(d){d.href='javascript:void(0);';}
function zSetInput(id,v){
	var d=document.getElementById(id);d.value=v;
	if(d.onchange!==null){
		d.onchange();
	}
}
var zFormOnEnterValues=new Array();
function zFormOnEnterAdd(id,d){
	zFormOnEnterValues[id]=d;
}
function zFormOnEnter(e,obj){
	if(zFormOnEnterValues[obj.id]!==null){
		if(e===null){
			eval(zFormOnEnterValues[obj.id]);
		}else{
			if(window.event){
				var keynum= e.keyCode;
			}else{
				var keynum = e.which;
			}
			if(keynum===13){
				eval(zFormOnEnterValues[obj.id]);
			}
		}
	}
}
function zInputRemoveOption(id,zOffset){
    var ab=new Array();
    var ab2=new Array();
    var ab3=new Array();
    for(var i=0;i<zValues[zOffset].length;i++){
        if(id!==i){ 
			ab.push(zValues[zOffset+1][i]); ab2.push(zValues[zOffset][i]); ab3.push(zValues[zOffset+2][i]); 
		}else{
			if(zValues[zOffset+2][i] !== "" && zValues[zOffset+6] === false){
				var d=document.getElementById(zValues[zOffset+2][i]);
				d.style.display="block";
			}
		}
    }
    zValues[zOffset+2]=ab3;
    zValues[zOffset+1]=ab;
    zValues[zOffset]=ab2;
	var ofield=document.getElementById(zValues[zOffset+4]);
	var ofieldlabel=document.getElementById(zValues[zOffset+4]+"_zlabel");
	ofield.value=zValues[zOffset+1].join(",");
	ofieldlabel.value=zValues[zOffset].join(",");
	if(ofield.type !== "select-one" && ofield.onchange!==null){
		ofield.onchange();
	}
    zInputSetSelectedOptions(false,zOffset);
	if(ofield.type === "select-one"){
		ofield.selectedIndex=0;	
	}
}
function zHasInnerText(){
	return (document.getElementsByTagName("body")[0].innerText !== "undefined") ? true : false;	
}

var zInputBoxLinkValues=[];
function zInputSetSelectedOptions(checkField,zOffset,fieldName,linkId,allowAnyText,onlyOneSelection){
	if(checkField){
		var ofield=document.getElementById(fieldName);
		var ofieldlabel=document.getElementById(fieldName+"_zlabel");
		var ofL=document.getElementById(fieldName+"_zmanual");
		var ofV=document.getElementById(fieldName+"_zmanualv");
		var cid=ofV.value;
		var cname=ofL.value;
		var obj=ofL;
		var it=zHasInnerText() ? obj.innerText : obj.textContent;
		if(zValues[zOffset+6]===true && zValues[zOffset+1].length>0 && cname!==""){
			alert('Only one value can be selected for this field');
			ofV.value="";
			ofL.value="";
			return;	
		}
		if(allowAnyText && cname!==""){
			// ignore
		}else if(cid==="0"){
		    alert('Please make a selection before clicking the add button.');
		    return;
		}else if(cname===""){
			return;	
		}
		for(var i=0;i<zValues[zOffset].length;i++){
			if(zValues[zOffset+1][i] === cid){// && zValues[zOffset][i]==cname){
				alert('The option, '+zValues[zOffset][i]+', has already been selected.');
				return;
			}
		}
		// loop links here with the zOffset
		for(var i=0;i<zValues[zOffset+3].length;i++){
			if(zValues[zOffset+3][i] === cid){
				linkId="zInputLinkBox"+zOffset+"_link"+(i+1);
				var d1=document.getElementById(linkId);
				d1.style.display="none";
				break;
			}
		}
		if(!allowAnyText && cid===cname){
			alert('Only valid entries are accepted. Please type an entry that appears in the suggestion box and than select it or press enter.');
			return;
		}
		ofV.value="";
		ofL.value="";
		if(linkId===null) linkId="";
		zValues[zOffset+2].push(linkId);
		zValues[zOffset+1].push(cid);
		zValues[zOffset].push(cname);
		ofield.value=zValues[zOffset+1].join(",");
		ofieldlabel.value=zValues[zOffset].join(",");
		if(ofield.onchange!==null){
			ofield.onchange();
		}
		var arrM=[];
		for(var i=0;i<zValues[zOffset].length;i++){
			arrM[zValues[zOffset][i]]=i;
		}
		zValues[zOffset].sort();
		var arrN=[];
		var arrN2=[];
		for(var i=0;i<zValues[zOffset].length;i++){
			arrN[i]=zValues[zOffset+1][arrM[zValues[zOffset][i]]];
			arrN2[i]=zValues[zOffset+2][arrM[zValues[zOffset][i]]];
		}
		zValues[zOffset+1]=arrN;
		zValues[zOffset+2]=arrN2;
	}
	zExpOptionSetValue(zValues[zOffset+5],"<br />"+zValues[zOffset].join("<br />"));
	var cb=document.getElementById("zInputOptionBlock"+zOffset);
	var arrBlock2=new Array();
	if(zValues[zOffset].length!==0){
		arrBlock2.push('<div class="zInputLinkBoxSelected"><div class="zInputLinkBoxSelectedHead">SELECTED VALUES:<br /><span style="font-weight:normal">Click X to remove a value.</span></div>');
		for(var i=0;i<zValues[zOffset].length;i++){
			var s='zInputLinkBoxRow1';
			if(i%2===0){
				s="zInputLinkBoxRow2";
			}
			if(zValues[zOffset+2][i] !== ""){
				var d1=document.getElementById(zValues[zOffset+2][i]);
				if(d1){
					d1.style.display="none";
				}
			}
			arrBlock2.push('<div style="float:left;width:100%;" class="'+s+'"><a href="javascript:zInputRemoveOption('+(arrBlock2.length-1)+','+zOffset+');" style="float:left;text-decoration:none;display:block;" class="zInputLinkBoxSItem '+s+'"><span title="Click the X to remove this option." class="zTOB-closeBox">X</span>'+zValues[zOffset][i]+'</a></div>');
		}
		arrBlock2.push('</div><br style="clear:both;" />');
	}
	cb.innerHTML=arrBlock2.join('');
	if(arrBlock2.length===0){
		cb.style.display="inline";
	}else{
		cb.style.display="block";
	}
}

function zLoadFile(filename, filetype){
	if (filetype==="js"){
		var fileref=document.createElement('script');
		fileref.setAttribute("type","text/javascript");
		fileref.setAttribute("src", filename);
	}else if (filetype==="css"){
		var fileref=document.createElement("link");
		fileref.setAttribute("rel", "stylesheet");
		fileref.setAttribute("type", "text/css");
		fileref.setAttribute("href", filename);
	}
	if (typeof fileref!=="undefined"){
		document.getElementsByTagName("head")[0].appendChild(fileref);
	}
}
var zCacheSliderValues=[];
var zOpenMenuCache=[];
function zFixMenuOnTablets(){
	a=zGetElementsByClassName("trigger");
	for(var i=0;i<a.length;i++){
		a[i].onclick=function(){ 
			if(this.parentNode.childNodes.length>=3){
				if(this.parentNode.childNodes[2].style.display==="block"){
					for(var i2=0;i2<zOpenMenuCache.length;i2++){
						zOpenMenuCache[i2].style.display="none";	
					}
					return zContentTransition.doLinkOnClick(this);//this.parentNode.childNodes[2].style.display="none";
				}else{
					for(var i2=0;i2<zOpenMenuCache.length;i2++){
						zOpenMenuCache[i2].style.display="none";	
					}
					zOpenMenuCache=[];
					this.parentNode.childNodes[2].style.display="block";
					zOpenMenuCache.push(this.parentNode.childNodes[2]);
				}
				return false;
			}
		};
	}
	 lg=document.getElementsByTagName("UL");
	 if(lg){
		for(k=0;k<lg.length;k++){
			if(lg[k].id.indexOf("_mb_menu")!==-1){
				lg[k].onclick=function(){
					for(var i2=0;i2<zOpenMenuCache.length;i2++){
						zOpenMenuCache[i2].style.display="none";	
					}	
					zOpenMenuCache=[];
				};
			}
		}
	}
}
var zWindowIsLoaded=false;
var zScrollPosition={left:0,top:0};
function zJumpToId(id,offset){	
	var r94=document.getElementById(id);
	if(r94===null) return;
	var p=zFindPosition(r94);
	var isWebKit = navigator.userAgent.toLowerCase().indexOf('webkit') > -1;
	if(!offset || offset === null){
		offset=0;
	}
	if(isWebKit){
		document.body.scrollTop=p[1]+offset;
	}else{
		document.documentElement.scrollTop=p[1]+offset;
	}
}
function getWindowSize() {
  var myWidth = 0, myHeight = 0;
  if( typeof( window.innerWidth ) === 'number' ) {
    //Non-IE
    myWidth = window.innerWidth;
    myHeight = window.innerHeight;
  } else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
    //IE 6+ in 'standards compliant mode'
    myWidth = document.documentElement.clientWidth;
    myHeight = document.documentElement.clientHeight;
  } else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
    //IE 4 compatible
    myWidth = document.body.clientWidth;
    myHeight = document.body.clientHeight;
  }
  return {width:myWidth,height:myHeight};
}
function zSet9(id){
	var d1=document.getElementById(id);
	d1.value="9989";
	humanMovement=true;
}
function zWindowOnScroll(){
	humanMovement=true;
	if(typeof updateCountPosition !== "undefined"){
		r111=updateCountPosition();
	}else{
		r111=true;
	}
	for(var i=0;i<zArrScrollFunctions.length;i++){
		var f1=zArrScrollFunctions[i];
		if(typeof f1==="object"){
			if(typeof f1.arguments === "undefined" || f1.arguments.length === 0){
				f1.functionName();
			}else if(f1.arguments.length === 1){
				f1.functionName(f1.arguments[0]);
			}else if(f1.arguments.length === 2){
				f1.functionName(f1.arguments[0], f1.arguments[1]);
			}else if(f1.arguments.length === 3){
				f1.functionName(f1.arguments[0], f1.arguments[1], f1.arguments[2]);
			}else if(f1.arguments.length === 4){
				f1.functionName(f1.arguments[0], f1.arguments[1], f1.arguments[2], f1.arguments[3]);
			}
		}else{
			f1();
		}
			
	}
	return r111;
} 
if(typeof window.onscroll === "function"){
	var zMLSonScrollBackup=window.onscroll;
}else{
	var zMLSonScrollBackup=function(){};
}
$(window).bind("scroll", function(ev){
	zMLSonScrollBackup(ev);
	return zWindowOnScroll(ev);

});
if(typeof window.onmousewheel === "function"){
	var zMLSonScrollBackup2=window.onmousewheel;
}else{
	var zMLSonScrollBackup2=function(){};
} 
$(window).bind("mousewheel", function(ev){
	zMLSonScrollBackup2(ev);
	return zWindowOnScroll(ev);

});

function zWindowOnResize(){
	var windowSizeBackup=zWindowSize;
	zGetClientWindowSize();
	if(typeof windowSizeBackup === "function" && windowSizeBackup.width === zWindowSize.width && windowSizeBackup.height === zWindowSize.height){
		return;	
	}
	if(typeof updateCountPosition !== "undefined"){
		updateCountPosition();
	}
	for(var i=0;i<zArrResizeFunctions.length;i++){
		var f1=zArrResizeFunctions[i];
		if(typeof f1==="object"){
			if(typeof f1.arguments === "undefined" || f1.arguments.length === 0){
				f1.functionName();
			}else if(f1.arguments.length === 1){
				f1.functionName(f1.arguments[0]);
			}else if(f1.arguments.length === 2){
				f1.functionName(f1.arguments[0], f1.arguments[1]);
			}else if(f1.arguments.length === 3){
				f1.functionName(f1.arguments[0], f1.arguments[1], f1.arguments[2]);
			}else if(f1.arguments.length === 4){
				f1.functionName(f1.arguments[0], f1.arguments[1], f1.arguments[2], f1.arguments[3]);
			}
		}else{
			f1();
		}
	}
}

if(typeof window.onresize === "function"){
	var zMLSonResizeBackup=window.onresize;
}else{
	var zMLSonResizeBackup=function(){};
}
$(window).bind("resize", function(ev){
	zMLSonResizeBackup(ev);
	return zWindowOnResize(ev);

});
$(window).bind("clientresize", function(ev){
	zMLSonResizeBackup(ev);
	return zWindowOnResize(ev);

});
if(typeof String.prototype.trim === "undefined"){
	String.prototype.trim=function(){return this.replace(/^\s\s*/, '').replace(/\s\s*$/, '');};
}

var zFunctionLoadStarted=false;
function zLoadAllLoadFunctions(){
	zFunctionLoadStarted=true;
	for(var i=0;i<zArrLoadFunctions.length;i++){
		var f1=zArrLoadFunctions[i];
		if(typeof f1==="object"){
			if(typeof f1.arguments === "undefined" || f1.arguments.length === 0){
				f1.functionName();
			}else if(f1.arguments.length === 1){
				f1.functionName(f1.arguments[0]);
			}else if(f1.arguments.length === 2){
				f1.functionName(f1.arguments[0], f1.arguments[1]);
			}else if(f1.arguments.length === 3){
				f1.functionName(f1.arguments[0], f1.arguments[1], f1.arguments[2]);
			}else if(f1.arguments.length === 4){
				f1.functionName(f1.arguments[0], f1.arguments[1], f1.arguments[2], f1.arguments[3]);
			}
		}else{
			f1();
		}
	}
	zFunctionLoadStarted=false;
	
}
function zWindowOnLoad(){
	if(zWindowIsLoaded) return;
	zWindowIsLoaded=true;
	//alert(zArrLoadFunctions.length);
	if(typeof zModernizr99 === "undefined"){
		zModernizrLoaded();
	}
	if(typeof window.zCloseModal !== "undefined" || typeof window.parent.zCloseModal !== "undefined"){ var d1=document.getElementById("js3811");if(d1){d1.value="j219";}	}
	
	zLoadAllLoadFunctions();
	zWindowOnResize();
	if(zPositionObjSubtractId!==false){
		var d1=document.getElementById(zPositionObjSubtractId);
		//alert('load:'+d1.offsetLeft+":"+d1.offsetTop+":"+zFindPosition(d1));
		//zPositionObjSubtractPos=new Array(d1.offsetLeft,d1.offsetTop);
		zPositionObjSubtractPos=zFindPosition(d1);
		//zPositionObjSubtractPos[2]=d1.offsetTop;
//		zPositionObjSubtractPos=zFindPosition(d1);
//alert(zPositionObjSubtractPos[0]+":"+zPositionObjSubtractPos[1]);
	}
	zWindowIsLoaded=true; 
	//if(zTabletStylesheetLoaded === false && 
	if(zo('zMenuClearUniqueId') || zo('zMenuAdminClearUniqueId')){
		zMenuInit(); 
	}
	if(typeof updateCountPosition !== "undefined"){
		updateCountPosition();
	}
}
if(typeof window.onload === "function"){
	var zMLSonloadBackup=window.onload;
}else{
	var zMLSonloadBackup=function(){};
}
$(window).bind("onload", function(ev){
	zMLSonloadBackup(ev);
	zWindowOnLoad(ev);

});

var zMSIEVersion=-1;
var zMSIEBrowser=window.navigator.userAgent.indexOf("MSIE");
if(zMSIEBrowser !== -1){
	zMSIEVersion= (window.navigator.userAgent.substring (zMSIEBrowser+5, window.navigator.userAgent.indexOf (".", zMSIEBrowser )));
}
var zMenuButtonCache=new Array();
 var zMenuDivIndex=0;
var zTabletStylesheetLoaded=false;
var zTouchPosition={x:[0],y:[0],curX:[0],curY:[0],count:0,curCount:0};
zArrDeferredFunctions.push(function(){
	$(document.body).bind('touchstart', function (event) {
		zTouchPosition.x=[];
		zTouchPosition.y=[];
		if(typeof event.targetTouches === "undefined"){
			return;
		}
		zTouchPosition.count=event.targetTouches.length;
		for(var i=0;i<event.targetTouches.length;i++){
			zTouchPosition.x.push(event.targetTouches[i].pageX);
			zTouchPosition.y.push(event.targetTouches[i].pageY);
		}
	});
	$(document.body).bind('touchmove', function (event) {
		zTouchPosition.curX=[];
		zTouchPosition.curY=[];
		if(typeof event.targetTouches === "undefined"){
			return;
		}
		for(var i=0;i<event.targetTouches.length;i++){
			zTouchPosition.curX.push(event.targetTouches[i].pageX);
			zTouchPosition.curY.push(event.targetTouches[i].pageY);
		} 
	});  
	$(document.body).bind('touchend', function (event) {
		zTouchPosition.x=[];
		zTouchPosition.y=[];
		zTouchPosition.curX=[];
		zTouchPosition.curY=[];
		if(typeof event.targetTouches === "undefined"){
			return;
		}
		zTouchPosition.count=event.targetTouches.length;
		for(var i=0;i<event.targetTouches.length;i++){
			zTouchPosition.curX.push(event.targetTouches[i].pageX);
			zTouchPosition.curY.push(event.targetTouches[i].pageY);
			zTouchPosition.x.push(event.targetTouches[i].pageX);
			zTouchPosition.y.push(event.targetTouches[i].pageY);
		}
	}); 
	
	
});
if(typeof zMenuDisablePopups === "undefined"){
	zMenuDisablePopups=false;	
}
function zMenuInit(){ // modified version of v1.1.0.2 by PVII-www.projectseven.com 
	//if(zMSIEBrowser==-1){return;}
	//return;
	var i,k,g,lg,r=/\s*zMenuHvr/,nn='',c,bv='zMenuDiv';
	 lg=document.getElementsByTagName("LI"); 
	 $wrapper=$(".zMenuWrapper").show();

	var arrButtons=$(".trigger", $wrapper);
	arrButtons.each(function(){
		if(this.href==window.location.href){
			$(this).addClass("trigger-selected");
		}
	});
	 $(".zMenuWrapper").each(function(){ 
		 if(this.className.indexOf('zMenuEqualDiv') === -1){
			 return; 
		 } 
		var arrA=$(".zMenuWrapper > ul > li > a");
		var menuWidth=$(".zMenuBarDiv", this).width();
		var borderTotal=0; 
		$(this).width(menuWidth);
		if(arrA.length){
			var padding=($(arrA[0]).outerWidth()-$(arrA[0]).width())/2;
		}
		if(this.id === ''){
			this.id='zMenuContainerDiv'+zMenuDivIndex;
			zMenuDivIndex++;
		} 
		var buttonMargin=0;
		if(this.getAttribute("data-button-margin") !== ''){
			buttonMargin=parseInt(this.getAttribute("data-button-margin"));
		}
		 zSetEqualWidthMenuButtons(this.id, buttonMargin);
	 });
	 if(zMenuDisablePopups){
		 $(".zMenuBarDiv .trigger").each(function(){
			 $("ul", this.parentNode).detach();
		});
	 }else if(!zIsTouchscreen()){ 
		 if(lg){
			 for(k=0;k<lg.length;k++){
				if(lg[k].parentNode.id.indexOf("zMenuDiv")!==-1){ 
					zMenuButtonCache.push(lg[k]);
					 lg[k].onmouseover=function(){
						 var pos=zGetAbsPosition(this);
						 var pos2=$(this).position();
						 var c2=document.getElementById(this.id+"_menu"); 
						if(zContentTransition.firstLoad===false){
							$(this).children("ul").css("display","block");
						}
						if(c2){
							 c2.style.position="absolute";
							 var vertical=zo(this.id.split("_")[0]+"Vertical");
							 if(vertical){
								 c2.style.top=(pos2.top)+"px";c2.style.left=(pos2.left+pos.width)+"px";
							 }else{
								 c2.style.top=(pos2.top+pos.height)+"px";c2.style.left=pos2.left+"px";
							 }
							c2.style.zIndex=2000;
						 }
						if(this.className.indexOf('zMenuEqualUL') === -1){ 
							this.className="zMenuHvr";
						 }else{
							this.className="zMenuEqualLI zMenuHvr";
						 } 
					 };
					 lg[k].onmouseout=function(){
						c=this.className;
						if(this.className.indexOf('zMenuEqualUL') === -1){ 
							this.className="zMenuNoHvr";
						}else{ 
							this.className="zMenuEqualLI zMenuNoHvr";
						}
						if(zContentTransition.firstLoad===false){
							$(this).children("ul").css("display","none");
						} 
					 };
				}
			}
		}
	}
	nn=i+1;
	
	if((zTabletStylesheetLoaded===false && zIsTouchscreen())){
		zTabletStylesheetLoaded=true;
		zLoadFile("/z/stylesheets/tablet.css","css");
		zFixMenuOnTablets();
	}
}
function zo(variable){
	var a=document.getElementById(variable);
	if(a !== null){
		return a;
	}else if(typeof(window[variable]) === "undefined"){
		return false;	
	}else{
		return eval(variable);	
	}
}
function zso(obj, varName, isNumber, defaultValue){
	if(typeof isNumber==="undefined") isNumber=false;
	if(typeof defaultValue==="undefined") defaultValue=false;
	var tempVar = "";
	if(isNumber){
		if(zKeyExists(obj, varName)){
			tempVar = obj[varName];
			if(!isNaN(tempVar)){
				return tempVar;
			}else{
				if(defaultValue !== ""){
					return defaultValue;
				}else{
					return 0;
				}
			}
		}else{
			if(defaultValue !== ""){
				return defaultValue;
			}else{
				return 0;
			}
		}
	}else{
		if(zKeyExists(obj, varName)){
			return obj[varName];
		}else{
			return defaultValue;
		}
	}
}


var zModalObjectHidden=new Array();
var zModalScrollPosition=new Array();
function zModalLockPosition(e){
	var el = document.getElementById("zModalOverlayDiv"); 
	if(el && el.style.display==="block"){
		var yPos=$(window).scrollTop();
		el.style.top=yPos+"px";
		return false;
	}else{
		return true;
	}
}
zScrollBarWidthCached=-1;
function zGetScrollBarWidth () {
	if(zScrollBarWidthCached !== -1){
		return zScrollBarWidthCached;
	}
  var inner = document.createElement('p');
  inner.style.width = "100%";
  inner.style.height = "200px";

  var outer = document.createElement('div');
  outer.style.position = "absolute";
  outer.style.top = "0px";
  outer.style.left = "0px";
  outer.style.visibility = "hidden";
  outer.style.width = "200px";
  outer.style.height = "150px";
  outer.style.overflow = "hidden";
  outer.appendChild (inner);

  var b=document.documentElement || document.body;
  b.appendChild (outer);
  var w1 = inner.offsetWidth;
  outer.style.overflow = 'scroll';
  var w2 = inner.offsetWidth;
  if (w1 === w2) w2 = outer.clientWidth;

  b.removeChild (outer);
	zScrollBarWidthCached=(w1-w2);
  return zScrollBarWidthCached;
};
zScrollbarWidth=0;
function zGetClientWindowSize() {
  var myWidth = 0, myHeight = 0;
  if( typeof( window.innerWidth ) === 'number' ) {
    //Non-IE
    myWidth = window.innerWidth;
    myHeight = window.innerHeight;
  } else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
    //IE 6+ in 'standards compliant mode'
    myWidth = document.documentElement.clientWidth;
    myHeight = document.documentElement.clientHeight;
  } else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
    //IE 4 compatible
    myWidth = document.body.clientWidth;
    myHeight = document.body.clientHeight;
  }
  if(zScrollbarWidth===0){
	zScrollbarWidth=zGetScrollBarWidth();  
  }
  zWindowSize={
	  "width":myWidth-zScrollbarWidth,
			  "height":myHeight
  };
  return zWindowSize;
}

function zShowModalStandard(url, maxWidth, maxHeight){
	var windowSize=zGetClientWindowSize();
	if(url.indexOf("?") === -1){
		url+="?";
	}else{
		url+="&";
	}
	if(typeof maxWidth === "undefined"){
		maxWidth=3000;	
	}
	if(typeof maxHeight === "undefined"){
		maxHeight=3000;	
	}
	var modalContent1='<iframe src="'+url+'ztv='+Math.random()+'" frameborder="0"  style=" margin:0px; border:none; overflow:auto;" seamless="seamless" width="100%" height="98%" />';		
	zShowModal(modalContent1,{'width':Math.min(maxWidth, windowSize.width-50),'height':Math.min(maxHeight, windowSize.height-50),"maxWidth":maxWidth, "maxHeight":maxHeight});
}

var zModalDisableResize=false;
var zModalCancelFirst=false;
var zModalPosIntervalId=false;
var zModalMaxWidth=10000;
var zModalMaxHeight=10000;
var zModalWidth=10000;
var zModalHeight=10000;
function zFixModalPos(){
	var el = document.getElementById("zModalOverlayDiv");
	var el2 = document.getElementById("zModalOverlayDiv2");
    zModalScrollPosition = [
	self.pageXOffset ||
	document.documentElement.scrollLeft ||
	document.body.scrollLeft
	,
	self.pageYOffset ||
	document.documentElement.scrollTop ||
	document.body.scrollTop
	];
	zGetClientWindowSize();
	var windowSize=zWindowSize;
	el.style.top=zModalScrollPosition[1]+"px";
	el.style.left=zModalScrollPosition[0]+"px";
	var newWidth=Math.min(zModalWidth, Math.min(windowSize.width-100,((zModalMaxWidth))));
	var newHeight=Math.min(zModalHeight, Math.min(windowSize.height-100,((zModalMaxHeight))));
	var left=Math.round(Math.max(0, windowSize.width-newWidth)/2);
	var top=Math.round(Math.max(0, windowSize.height-newHeight)/2);
	el2.style.left=left+'px';
	el2.style.top=top+'px';
	el2.style.width=newWidth+"px";
	el2.style.height=newHeight+"px";
}

var zModalKeepOpen=false;
function zShowModal(content, obj){
	var d=document.body || document.documentElement;
	d.style.overflow="hidden";
	//if(zIsTouchscreen()) return;
	zGetClientWindowSize();
	if(typeof obj.disableResize !== "undefined"){
		zModalDisableResize=obj.disableResize;	
	}
	var disableClose=false;
	if(typeof obj.disableClose !== "undefined"){
		disableClose=obj.disableClose;	
	}
	var windowSize=zWindowSize;
	zModalWidth=obj.width;
	zModalHeight=obj.height;
	obj.width=Math.min(zModalMaxWidth, Math.min(obj.width, windowSize.width));
	obj.height=Math.min(zModalMaxHeight, Math.min(obj.height, windowSize.height));
	if(typeof obj.maxWidth !== "undefined"){
		zModalMaxWidth=obj.maxWidth;
	}
	if(typeof obj.maxHeight !== "undefined"){
		zModalMaxHeight=obj.maxHeight;
	}
    zModalScrollPosition = [
        self.pageXOffset ||
        document.documentElement.scrollLeft ||
        document.body.scrollLeft
        ,
        self.pageYOffset ||
        document.documentElement.scrollTop ||
        document.body.scrollTop
        ];
	var arr=document.getElementsByTagName("iframe");
	for(var i=0;i<arr.length;i++){
		if(arr[i].style.visibility==="" || arr[i].style.visibility === "visible"){
			arr[i].style.visibility="hidden";
			zModalObjectHidden.push(arr[i]);
		}
	}
	if(navigator.userAgent.indexOf("MSIE 6.0") !== -1){
		var arr=document.getElementsByTagName("select");
		for(var i=0;i<arr.length;i++){
			if(arr[i].style.visibility==="" || arr[i].style.visibility === "visible"){
				arr[i].style.visibility="hidden";
				zModalObjectHidden.push(arr[i]);
			}
		}
		arr=document.getElementsByTagName("object");
		for(var i=0;i<arr.length;i++){
			if(arr[i].style.visibility==="" || arr[i].style.visibility === "visible"){
				arr[i].style.visibility="hidden";
				zModalObjectHidden.push(arr[i]);
			}
		}
		// don't use the png here...
		var dover1=document.getElementById("zModalOverlayDiv");
		dover1.style.backgroundImage="url(/z/a/images/bg-checker.gif)";
	}
	var el = document.getElementById("zModalOverlayDiv");
	var el2 = document.getElementById("zModalOverlayDiv2");
	el.style.display = "block";
	el2.style.display = "block";
	if(content.indexOf("<iframe ") !== -1){
	//	el2.style.overflow="hidden";
	}
	el2.onclick=function(){zModalKeepOpen=true;setTimeout(function(){zModalKeepOpen=false;},100); return false;};
	if(disableClose){
		el2.innerHTML=content;  	
		el.onclick=function(){};
	}else{
		el.onclick=function(){
			if(zModalKeepOpen) return;
			zCloseModal();
		};
		el2.innerHTML='<div style="width:80px; text-align:right; font-weight:bold; float:right;"><a href="javascript:void(0);" onclick="zCloseModal();">X Close</a></div><br style="clear:both;" /> '+content+'<div>';  
	}
	el.style.top=zModalScrollPosition[1]+"px";
	el.style.left=zModalScrollPosition[0]+"px";
	el.style.height="100%";
	el.style.width="100%";
	var left=Math.round(Math.max(0,((windowSize.width)-obj.width))/2);
	var top=Math.round(Math.max(0, (windowSize.height-obj.height))/2);
	el2.style.left=left+'px';
	el2.style.top=top+'px';
	el2.style.width=(obj.width)+"px";
	el2.style.height=(obj.height)+"px";
	zModalPosIntervalId=setInterval(zFixModalPos,500);
}
var zArrModalCloseFunctions=[];
function zCloseModal(){
	clearInterval(zModalPosIntervalId);
	for(var i=0;i <zArrModalCloseFunctions.length;i++){
		zArrModalCloseFunctions[i]();
	}
	zArrModalCloseFunctions=[];
	zModalPosIntervalId=false;
	var d=document.body || document.documentElement;
	d.style.overflow="auto";
	var el = document.getElementById("zModalOverlayDiv");
	el.style.display= "none";
	var el2 = document.getElementById("zModalOverlayDiv2");
	el2.style.display = "none";
	for(var i=0;i<zModalObjectHidden.length;i++){
		zModalObjectHidden[i].style.visibility="visible";
	}
}

function forceCustomFontDesignModeOn(id){
	doc=tinyMCE.get(id).getDoc();
	doc.designMode="on";
	$("span", doc).each(function(){
		if(this.innerHTML==="BESbswy"){
			$(this).remove();
		}
	});
}
function forceCustomFontLoading(inst){
	doc=tinyMCE.get(inst.editorId).getDoc();
	if(navigator.userAgent.indexOf("MSIE ") === -1){
		doc.designMode="off";
	} 
	if(typeof zFontsComURL !== "undefined" && zFontsComURL !== ""){
		if(zFontsComURL.substr(zFontsComURL.length-4) === ".js"){
			head = doc.getElementsByTagName('head')[0];
			script = doc.createElement('script');
			script.src = zFontsComURL;
			script.type = 'text/javascript';
			head.appendChild(script);
		}else{
			head = doc.getElementsByTagName('head')[0];
			script = doc.createElement('link');
			script.href = zFontsComURL;
			script.rel = 'stylesheet';
			script.type = 'text/css';
			head.appendChild(script);
		}
	}
	if(typeof zTypeKitURL !== "undefined" && zTypeKitURL !== ""){
		head = doc.getElementsByTagName('head')[0];
		script = doc.createElement('script');
		script.src = zTypeKitURL;
		script.type = 'text/javascript';
		head.appendChild(script);
		script = doc.createElement('script');
		script.type = 'text/javascript';
		script.src='/z/javascript/zTypeKitOnLoad.js';
		head.appendChild(script);
	}
	if(navigator.userAgent.indexOf("MSIE ") === -1 && document.getElementById(inst.editorId)){
		setTimeout('forceCustomFontDesignModeOn("'+inst.editorId+'");',2000);
	}
}

function zIsAppleIOS(){
	if(navigator.userAgent.indexOf("iPhone") !== -1 || navigator.userAgent.indexOf("iPad") !== -1){
		return true;
	}else{
		return false;
	}
}


var zSetFullScreenMobileAppLoaded=false;
function zSetFullScreenMobileApp(){
	// this was disabled on purpose.
	console.log("zSetFullScreenMobileApp called");return;
	/*if(zSetFullScreenMobileAppLoaded) return;
	zSetFullScreenMobileAppLoaded=true;
	if(zIsTouchscreen()){
		$('head').append('<meta name="viewport" content="width=device-width; minimum-scale=1.0; maximum-scale=1.0; scale=1.0; user-scalable=no; " \/><meta name="apple-mobile-web-app-capable" content="yes" \/><meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" \/><style type="text/css"> a, area {-webkit-touch-callout: none;}*{ -webkit-text-size-adjust: none; }<\/style>');
	}*/
}

var zHelpTooltip=new Object();
zHelpTooltip.arrTrack=[];
zHelpTooltip.curId=false;
zHelpTooltip.curTimeoutId=false;
zHelpTooltip.helpDiv=false;
zHelpTooltip.helpInnerDiv=false;
zHelpTooltip.showTooltip=function(){
	clearTimeout(zHelpTooltip.curTimeoutId);
	zHelpTooltip.curTimeoutId=false;
	zHelpTooltip.arrTrack[this.id].hovering=false;
	var d=document.getElementById(this.id);
	var p=zGetAbsPosition(d);
	//alert(this.id+" tooltip "+p.x+":"+p.y+":"+p.width+":"+p.height);
	var ws=getWindowSize();	
	zHelpTooltip.helpDiv.style.display="block";
	zHelpTooltip.helpInnerDiv.innerHTML=zHelpTooltip.arrTrack[this.id].title;
	var p2=zGetAbsPosition(zHelpTooltip.helpDiv);
	zHelpTooltip.helpDiv.style.left=Math.min(ws.width-p2.width-10, p.x+p.width+5)+"px";
	zHelpTooltip.helpDiv.style.top=Math.max(10,(p.y)-p2.height)+"px";
	//alert(Math.min(ws.width-p.width, p.x+p.width+5)+" | "+(p.y-p.height-5));
	return false;
};
zHelpTooltip.hoverOut=function(e){
	clearTimeout(zHelpTooltip.curTimeoutId);
	zHelpTooltip.curTimeoutId=false;
	zHelpTooltip.curId=false;
	zHelpTooltip.arrTrack[this.id].hovering=false;
	zHelpTooltip.helpDiv.style.display="none";
	// hideTooltip
};
zHelpTooltip.hover=function(e){
	clearTimeout(zHelpTooltip.curTimeoutId);
	zHelpTooltip.curTimeoutId=false;
	zHelpTooltip.curId=this.id;
	if(zHelpTooltip.arrTrack[this.id].hovering){
		zHelpTooltip.arrTrack[this.id].hovering=false;
		document.getElementById(zHelpTooltip.curId).onclick();
	}else{
		zHelpTooltip.arrTrack[this.id].hovering=true;
		zHelpTooltip.curTimeoutId=setTimeout(function(){ document.getElementById(zHelpTooltip.curId).onmouseover(); }, 1000);	
	}
};
zHelpTooltip.setupHelpTooltip=function(){
	zHelpTooltip.helpDiv=document.getElementById("zHelpToolTipDiv");
	zHelpTooltip.helpInnerDiv=document.getElementById("zHelpToolTipInnerDiv");
	var a=zGetElementsByClassName("zHelpToolTip");
	for(var i=0;i<a.length;i++){
		if(a[i].title === ""){
			a[i].style.display="none";
			continue;
		}
		zHelpTooltip.arrTrack[a[i].id]={hovering:false,title:a[i].title};
		a[i].title="";
		a[i].onmouseover=zHelpTooltip.hover;
		a[i].onmouseout=zHelpTooltip.hoverOut;
		a[i].ondragout=zHelpTooltip.hoverOut;
		a[i].onclick=zHelpTooltip.showTooltip;
	}
};


var zContentTransition=new Object();
zContentTransition.transitionOverrideId=false;
zContentTransition.processManually=false;
zContentTransition.processManuallyResult="{}";
zContentTransition.processManuallyRan=false;
zContentTransition.manuallyProcessTransition=function(){
	zContentTransition.processManuallyRan=true;
	if(zContentTransition.processResultStored){
		zContentTransition.processResultStored=false;
		zContentTransition.processAjaxPageTransition(zContentTransition.processManuallyResult);
	}
};
// the problem is that animation is finishing before the ajax complete is called.
zContentTransition.processAjaxPageTransition=function(d){
	if(zContentTransition.processManually && zContentTransition.processManuallyRan === false){
		zContentTransition.processResultStored=true;
		zContentTransition.processManuallyResult=d;
		return;	
	}
	var d2=document.body || document.documentElement;
	d2.style.overflow="auto";
	var d1={};
	try{
		eval("var d1="+d);
		if(typeof d1.forceReload === "undefined" || d1.forceReload){
			window.location.href=zContentTransition.lastURL;
		}
		$("#zContentTransitionContentDiv").html(d1.content);
	}catch(e){
		
		window.location.href=zContentTransition.lastURL;
	}
	
	if(zContentTransition.transitionOverrideId !== false){
		var $target = $("#"+zContentTransition.transitionOverrideId);
	}else{
		var $target = $("#zContentTransitionTitleSpan");
	}
	var pageNavElement = $("#zContentTransitionPageNavSpan");
	if(d1.pagenav ===''){
		pageNavElement.html('');
		$("#zpagenav").hide();
	}else{
		$("#zpagenav").show();
		pageNavElement.html(d1.pagenav);
	}
	//n.innerHTML=d1.content;
	zContentTransition.load();
	//n.style.display="block";
	if(!zContentTransition.disableNextAnimation){
		if(zContentTransition.lastJumpHash!==""){
			$('#zContentTransitionContentDiv').css("display","block");
			var $target = $("#"+zContentTransition.lastJumpHash);
			//alert('test'+$target+"\n"+$target.offset().top);
			if ($target && $target.length) {
				var targetOffset = Math.max(0,Math.max(0,$target.offset().top-50));
					$(window).scrollTop(targetOffset);
				/*if (zIsTouchscreen()) {
					$(window).scrollTop(targetOffset);
				}else{
					if($("html").scrollTop() !== targetOffset){
						$('html,body').animate({scrollTop: targetOffset}, 200);
					}
				}*/
			}
			zContentTransition.lastJumpHash="";
		}else{
			var doingTheScrollAnimation=false;
			if ($target.length) {
				var targetOffset = Math.max(0,Math.max(0,$target.offset().top-50));
					$(window).scrollTop(targetOffset);
					/*
				if (zIsTouchscreen()) {
					$(window).scrollTop(targetOffset);
				}else{
					if($("html").scrollTop() !== targetOffset){
						doingTheScrollAnimation=true;
						$('html,body').animate({scrollTop: targetOffset}, 200);
					}
				}*/
			}
			if(doingTheScrollAnimation){
				setTimeout(function(){$('#zContentTransitionContentDiv').fadeIn(200,function(){});},200);
			}else{
				$('#zContentTransitionContentDiv').fadeIn(200,function(){});
			}
		}
	}
	zContentTransition.disableNextAnimation=false;
	var c=document.getElementById("zContentTransitionTitleSpan");
	if(c){
		c.innerHTML=d1.pagetitle;
	}
	if(zContentTransition.popNextStateChange){
		zContentTransition.popNextStateChange=false;
	}else{
		History.pushState({rand:Math.random()}, d1.title , zContentTransition.lastURL, false);//Math.random()
		History.Adapter.trigger(window,'statechange');
		History.busy(false);
	}
	if(zMSIEBrowser!==-1 && zMSIEVersion<=9){
	}else{
		zContentTransition.skipNextStateChange=false;
	}
	zLoadAllLoadFunctions();
			
};
zContentTransition.processFailedAjaxPageTransition=function(d){
	zContentTransition.processManuallyRan=true;
	zContentTransition.skipNextStateChange=false;
	zContentTransition.processResultStored=true;
	window.location.href=zContentTransition.lastURL;
	// alert("Failed to load url, please try again or contact the webmaster.");//+d);
};
zContentTransition.urlHistory=new Array();
zContentTransition.lastURL="";
zContentTransition.skipNextStateChange=true;
zContentTransition.requestAjaxPageTransition=function(theURL, dontPush){
	
	zContentTransition.skipNextStateChange=true;
	if(theURL.substr(0,4) === "http"){
		for(var n=0;n<zLocalDomains.length;n++){
			if(theURL.substr(0,zLocalDomains[n].length) === zLocalDomains[n]){
				theURL=theURL.replace(zLocalDomains[n],"");
				break;
			}
		}
	}
	var p=theURL.indexOf("#");
	if(p !== -1){
		var p2=theURL.indexOf("&_suid=");
		if(p2 !== -1){
			var n=theURL.substr(p+1, p2-(p+1));
			if(n.length>0){
				theURL=n;
			}
		}
	}
	zContentTransition.processManuallyRan=false;
	zContentTransition.processResultStored=false;
	zContentTransition.onPageChange(theURL);
	if(dontPush===false){
		zContentTransition.urlHistory.push(theURL);
	}
	zContentTransition.lastURL=theURL;
	var q=theURL.indexOf("?");
	if(q!==-1){
		theURL+="&";
	}else{
		theURL+="?";
	}
	theURL+="zajaxdownloadcontent=1";
	var tempObj={};
	tempObj.id="zAjaxPageTransition";
	tempObj.url=theURL;
	tempObj.callback=zContentTransition.processAjaxPageTransition;
	tempObj.errorCallback=zContentTransition.processFailedAjaxPageTransition;
	tempObj.cache=false; 
	tempObj.ignoreOldRequests=true; 
	zAjax(tempObj);
};
zContentTransition.checkHashChange=function(){
	// zContentTransitionLog.value+="\nhashchangeout url: "+window.location.href+"\n";
	if(!zContentTransition.skipNextStateChange){
		var u="";
		if(zContentTransition.urlHistory.length > 1){
			// zContentTransitionLog.value+="hashchangein \n";
			var u2=zContentTransition.urlHistory.pop();
			// zContentTransitionLog.value+=u2+" | cur \n";
			u=zContentTransition.urlHistory[zContentTransition.urlHistory.length-1];
			var p=u.indexOf("#");
			if(p !== -1){
				var p2=u.indexOf("&_suid=");
				if(p2 !== -1){
					var n=u.substr(p+1, p2-(p+1));
					if(n.length>0){
						u=n;
					}
				}
			}
			zContentTransition.popNextStateChange=true;
			zContentTransition.requestAjaxPageTransition(u, true);
			//zContentTransitionLog.value+=u+" | prev \n";
		}
	}
	zContentTransition.skipNextStateChange=false;
};
zContentTransition.stateChange=function(){ 

	// zContentTransitionLog.value+="\nstatechangeout ";
	if(!zContentTransition.skipNextStateChange){
		//zContentTransitionLog.value+=zContentTransition.urlHistory.join("\n");
		//var State = History.getState();
		if(zContentTransition.urlHistory.length > 1){
			// zContentTransitionLog.value+="statechangein \n";
			if(zMSIEBrowser!==-1 && zMSIEVersion<=9){
			}else{
				var u2=zContentTransition.urlHistory.pop();
				// zContentTransitionLog.value+=u2+" | cur \n";
			}
			var u=zContentTransition.urlHistory[zContentTransition.urlHistory.length-1];
			zContentTransition.popNextStateChange=true;
			//zContentTransition.skipNextStateChange=false;
			// zContentTransitionLog.value+=u+" | prev \n";
			zContentTransition.requestAjaxPageTransition(u, true);
		}
	}
};
zContentTransition.arrIgnoreURLs=["/z/listing/search-form/index"];
zContentTransition.arrIgnoreURLContains=["mailto:",
"/z/misc/system/redirect",
"/z/listing/sl/index",
"/z/_a/member/",
"/z/listing/search-js/index",
"/z/user/preference/",
".xml"];
function zHideMenuPopups(){
	//alert(zMenuButtonCache.length);
	for(var i=0;i<zMenuButtonCache.length;i++){
		$(zMenuButtonCache[i]).children("ul").css("display","none");
		//zMenuButtonCache[i].onmouseout();	
	}
	$(".zdc-sub").css("display","none");
	
}
zContentTransition.disable=function(){
	zContentTransition.enabled=false;
};

zContentTransition.gotoURL=function(url){
	var newA= document.createElement('a');
	newA.href=url;
	zContentTransition.linkOnClick(false, newA);
};
zContentTransition.doLinkOnClick=function(obj){
	if(zContentTransition.enabled){
		zContentTransition.linkOnClick(false, obj);
		return false;
	}else{
		return true;
	}
};
zContentTransition.linkOnClick=function(e, obj){
	var thisObj=false;
	if(typeof obj !== "undefined"){
		thisObj=obj;
	}else{
		thisObj=this;
	}
	if(thisObj.target==="_parent"){
		parent.zContentTransition.gotoURL(thisObj.href);
		return false;
	}else if(thisObj.target==="_top"){
		top.zContentTransition.gotoURL(thisObj.href);
		return false;	
	}
	zHideMenuPopups();
	var m=false;
	var shortUrl=thisObj.href;
	for(var n=0;n<zLocalDomains.length;n++){
		if(thisObj.href.substr(0,zLocalDomains[n].length) === zLocalDomains[n]){
			m=true;
			var shortUrl=thisObj.href.replace(zLocalDomains[n],"");
			var a9_2=shortUrl.split("#");
			if(a9_2.length > 1){
				shortUrl=a9_2[0];
			}
			for(var g=0;g<zContentTransition.arrIgnoreURLs.length;g++){
				if(shortUrl === zContentTransition.arrIgnoreURLs[g]){
					window.location.href=thisObj.href;
					return false;
				}
			}
			for(var g=0;g<zContentTransition.arrIgnoreURLContains.length;g++){
				if(shortUrl.indexOf(zContentTransition.arrIgnoreURLContains[g]) !== -1){
					window.location.href=thisObj.href;
					return false;
				}
			}
		}
	}
	if(!m){
		window.location.href=thisObj.href;
		return false;	
	}
	var a9=thisObj.href.split("#");
	if(a9.length > 1){
		var a92=window.location.href.split("#");
		if(a92[0] === a9[0]){
			if(a9.length > 1){
				var $target = $("#"+a9[1]);
				if ($target && $target.length) {
					var targetOffset = Math.max(0,Math.max(0,$target.offset().top-50));
					if(zIsTouchscreen()){
						$(window).scrollTop(targetOffset);
					}else{
						$('html,body').animate({scrollTop: targetOffset}, 200);
					}
				}
				zContentTransition.lastJumpHash="";
				/*History.pushState({rand:Math.random()}, document.title , a9[0], false);//Math.random()
				History.Adapter.trigger(window,'statechange');
				History.busy(false);*/
				//zContentTransition.stateChange();
				return false;
			}else{
				return true;	
			}
		}
		zContentTransition.lastJumpHash=a9[1];
		thisObj.href=a9[0];
	}else{
		zContentTransition.lastJumpHash="";
	}
	zContentTransition.skipNextStateChange=true;
	if(typeof _gaq !== "undefined"){
		_gaq.push(['_trackPageview', shortUrl]);
	}else if(typeof pageTracker !== "undefined"){
		pageTracker._trackPageview(shortUrl);
	}
	//console.log("link clicked:"+thisObj.href);
	zContentTransition.requestAjaxPageTransition(thisObj.href, false); 
	
	return false;	
};
//var zContentTransitionLog=false;
zContentTransition.disableNextAnimation=false;
zContentTransition.enabled=true;
zContentTransition.firstLoad=true;
zContentTransition.popNextStateChange=false;
zContentTransition.lastJumpHash="";
zContentTransition.load=function(){
	
	if(zContentTransition.enabled===false) return;
	//zContentTransitionLog=document.getElementById("log");
	if(zContentTransition.firstLoad){
		zContentTransition.firstLoad=false;
		if(zMSIEBrowser!==-1 && zMSIEVersion<=9){
			if(History !== "undefined" && History.Adapter !== "undefined"){
				History.Adapter.bind(window,'hashchange',zContentTransition.checkHashChange);
			}
			var p=window.location.href.indexOf("#");

			if(p !== -1){
				var p2=window.location.href.indexOf("&_suid=");
				if(p2 !== -1){
					var n=window.location.href.substr(p+1, p2-(p+1));
					var p3=window.location.href.indexOf("/",8);
					var n2=window.location.href.substr(p3, p-p3);
					//alert('me\n'+n2+"\n"+n);
					if(n2 !== n){
						zContentTransition.requestAjaxPageTransition(n, false);	
					}
				}
			}
		}else{
			History.Adapter.bind(window,'statechange',zContentTransition.stateChange);
			if(History.storedStates.length>1){
				var s=History.getState();
				zContentTransition.requestAjaxPageTransition(s.url, false);	
			}
		}
		var theURL=window.location.href;
		if(theURL.substr(0,4) === "http"){
			//alert(i+" | "+zContentTransition.lastURL);
			for(var n=0;n<zLocalDomains.length;n++){
				if(theURL.substr(0,zLocalDomains[n].length) === zLocalDomains[n]){
					theURL=theURL.replace(zLocalDomains[n],"");
					break;
				}
			}
		}
		zContentTransition.urlHistory.push(theURL);
	}
	var a=document.getElementsByTagName("a");//zGetElementsByClassName("zContentTransition");
	var clone =[]; // need clone because the array automatically changes when removing the class name
	for(var i=0;i<a.length;i++){
		var targetCheck=false;
		if(window.location.href+"#" === a[i].href){
			continue;
		}
		if(a[i].target !== ""){
			if(a[i].target==="_parent"){
				if(typeof parent.zContentTransition === "undefined"){
					targetCheck=true;
				}
			}else if(a[i].target==="_top"){
				if(typeof top.zContentTransition === "undefined"){
					targetCheck=true;
				}
			}else{
				targetCheck=true;
			}
		}
		try{
			if(typeof a[i].onclick !== "function" && !targetCheck){
				if(a[i].id === "" && a[i].name !== ""){
					a[i].id=a[i].name;
				}
				if(a[i].className.indexOf("zNoContentTransition")!==-1){
					continue;	
				}
				clone.push(a[i]);	
			}
		}catch(e){
			throw("The onclick code was invalid for a link on this page.  Onclick code:"+a[i].getAttribute("onclick"));
		}
	}
	for(var i=0;i<clone.length;i++){
		//clone[i].className=clone[i].className.replace("zContentTransition","");
		clone[i].onclick=zContentTransition.linkOnClick;
	}
	zLoadAndCropImagesDefer();
};

function zGetCurrentRootRelativeURL(theURL){
	var a=theURL.split("/");
	var a2="";
	for(var i=3;i<a.length;i++){
		a2+="/"+a[i];
	}
	a2=(a2).split("#");
	return a2[0];
} 
function zIsTestServer(){
	if(typeof zThisIsTestServer !== "undefined" && zThisIsTestServer){
		return true;
	}else{
		return false;
	}
}
function zIsDeveloper(){
	if(typeof zThisIsDeveloper !== "undefined" && zThisIsDeveloper){
		return true;
	}else{
		return false;
	}
}
var zAddThisLoaded=false;
function zLoadAddThisJs(){
	if(zIsTestServer()) return;
	var a1=[];
	/*if(!zAddThisLoaded){
		zAddThisLoaded=true;
		zLoadFile("//s7.addthis.com/js/250/addthis_widget.js#username=addthis&domready=1","js");
		setTimeout(function(){ zLoadAddThisJs(); }, 50);
		return;
	}
	if(typeof addthis === "undefined") return;
	addthis.init();
	*/
	for(var i=1;i<=5;i++){
		d1=document.getElementById("zaddthisbox"+i);
		if(d1){
			/*if(d1.className.indexOf("addthis_floating_style addthis_counter_style") !== -1){
				d1.innerHTML='<a class="addthis_button_facebook_like" fb:like:layout="box_count"></a><a class="addthis_button_tweet" tw:count="vertical"></a><a class="addthis_button_google_plusone" g:plusone:size="tall"></a><a class="addthis_pill_style"></a>';
			}else{
				d1.innerHTML='<a class="addthis_button_facebook_like" fb:like:layout="button_count"></a><a class="addthis_button_tweet"></a><a class="addthis_button_pinterest_pinit"></a><a class="addthis_button_google_plusone" g:plusone:size="medium"></a><a class="addthis_pill_style"></a>';
			}*/
			
			
			
			d1.innerHTML='<div style="float:left; padding-right:5px; padding-bottom:5px;"><iframe style="overflow: hidden; border: 0px none; width: 90px; height: 25px; " src="//www.facebook.com/plugins/like.php?href='+escape(window.location.href)+'&amp;layout=button_count&amp;show_faces=false&amp;width=90&amp;action=like&amp;font=arial&amp;layout=button_count"></iframe></div><div style="float:left; padding-right:5px;padding-bottom:5px;"><iframe allowtransparency="true" frameborder="0" scrolling="no" src="//platform.twitter.com/widgets/tweet_button.1347008535.html#_=1347061585575&amp;count=horizontal&amp;counturl='+escape(window.location.href)+'&amp;id=twitter-widget-0&amp;lang=en&amp;original_referer='+escape(window.location.href)+'&amp;url='+escape(window.location.href)+'" class="twitter-share-button twitter-count-horizontal" style="width: 110px; height: 20px; " title="Twitter Tweet Button" data-twttr-rendered="true"></iframe></div><div style="float:left; padding-right:5px;padding-bottom:5px;"><a href="https://plus.google.com/share?url='+escape(window.location.href)+'" target="_blank"><img src="/z/images/icons/google-plusone.png" width="33" height="20" alt="Share this on Google Plus" /></a></div>';
			
			d1.id="zaddthisbox"+i+"_loaded";// %23.UEqGHd2kgcw.twitter 
			a1.push(d1);
		}
	}
}
zArrLoadFunctions.push({functionName:zLoadAddThisJs});




function loadDetailGallery(){
	var c="zGalleryViewSlideshow";
	var a=zGetElementsByClassName(c);
	for(var i=0;i<a.length;i++){
		if($("li", a[i]).length){
			var d2=document.getElementById(a[i].id+"_data").value;
			eval("var myObj="+d2);
			$(a[i]).show().galleryView(myObj);
		}
	}
}
zArrLoadFunctions.push({functionName:loadDetailGallery});


if(typeof zLocalDomains === "undefined"){
	var zLocalDomains=[];
}
zContentTransition.bind=function(obj, func){
	if(typeof func !== "undefined"){
		zContentTransition.arrPageChangeObjs.push(obj);
		zContentTransition.arrPageChangeFunctions.push(func);
	}else{
		zContentTransition.arrPageChangeObjs.push(false);
		zContentTransition.arrPageChangeFunctions.push(obj);
	}
};
zContentTransition.arrPageChangeObjs=[];
zContentTransition.arrPageChangeFunctions=[];
zContentTransition.pageChangeUrl="";
zContentTransition.onPageChange=function(newUrl){
	
	if(newUrl === zContentTransition.pageChangeUrl) return;
	zContentTransition.pageChangeUrl=newUrl;
	for(var i=0;i<zContentTransition.arrPageChangeObjs.length;i++){
		if(typeof zContentTransition.arrPageChangeObjs[i] === "boolean"){
			zContentTransition.arrPageChangeFunctions[i](newUrl);
		}else{
			zContentTransition.arrPageChangeObjs[i][zContentTransition.arrPageChangeFunctions[i]](newUrl);
		}
	}
};
zContentTransition.checkLoad=function(){
	if(typeof zContentTransitionEnabled !== "undefined" && zContentTransitionEnabled && typeof zContentTransitionDisabled === "undefined"){
		if(zWindowIsLoaded){
			zContentTransition.load();
		}else{
			zArrLoadFunctions.push({functionName:zContentTransition.load});
		}
	}
};
window.zContentTransition=zContentTransition;
	
function zeeo(m,n,o,w,l,r,h,b,v,z,z2){
	var k='ai',g='lto',f='m',e=':';
	if(z){return o+n+w+m;}else{ if(l){var cr3=('<a href="'+f+k+g+e+o+n+w+m+'">');if(b+h+v+r!==''){cr3+=(b+h+v+r);}else{cr3+=(o+n+w+m);} cr3+=('<\/a>');}else{cr3+=(o+n+w+m);}document.getElementById('zencodeemailspan'+z2).innerHTML=cr3;}}
	

var zLogin={
	autoLoginValue:-1,
	autoLoginCallback:0,
	devLogin:false,
	devLoginURL:"",
	loginErrorCallback:function(r){
		console.log("Login service temporarily unavailable. Try again later.");
		zLogin.enableLoginButtons();
	},
	enterPressed:false,
	lastKeyPressed:0,
	loginCallback:function(r){
		var json=eval('(' + r + ')');
		// supplement ip developer security with cookie to identify a single computer from the IP.
		if(typeof json.developer !== "undefined"){
			// cookie expires one year in future
			zSetCookie({key:"zdeveloper",value:json.developer,futureSeconds:31536000,enableSubdomains:true}); 
		}
		if(json.success){
			zLogin.zShowLoginError("Logging in...");
			var d1=window.parent.document.getElementById("zRepostForm");
			if(d1){
				setTimeout('window.parent.document.zRepostForm.submit();',5000);
				d1.submit();
			}
		}else{
			zLogin.zShowLoginError('<strong>'+json.errorMessage+'<\/strong>');
			zLogin.enableLoginButtons();
		}
		zLogin.enableLoginButtons();
	},
	disableLoginButtons:function(){
		document.getElementById("submitForm").disabled=true;
		document.getElementById("submitForm2").disabled=true;
	},
	enableLoginButtons:function(){
		document.getElementById("submitForm").disabled=false;
		document.getElementById("submitForm2").disabled=false;
	},
	zAjaxResetPasswordCallback:function(r){
		var json=eval('(' + r + ')');
		if(typeof json === "object"){
			if(json.success){
				zLogin.zShowLoginError("Reset password email sent. Click the link in the email to complete the process.");
			}else{
				zLogin.zShowLoginError(json.errorMessage);
			}
		}else{
			zLogin.zShowLoginError("The username provided is not a valid user.");
		}
		zLogin.enableLoginButtons();
	},
	zAjaxResetPassword:function(){
		var tempObj={};
		tempObj.id="zAjaxUserResetPassword";
		tempObj.url="/z/user/preference/update";
		if(document.getElementById('z_tmpusername2').value.length===""){
			zLogin.zShowLoginError("Email and the new password are required before clicking \"Reset Password\".");
			return;
		}
		if(document.getElementById('z_tmppassword2').value.length===""){
			zLogin.zShowLoginError("You must enter a new password before clicking \"Reset Password\"");
			return;
		}
		tempObj.postObj={
			k:"",
			e:document.getElementById('z_tmpusername2').value,
			user_password:document.getElementById('z_tmppassword2').value,
			submitPref:"Reset Password"
		};
		tempObj.method="post";
		tempObj.cache=false;
		tempObj.errorCallback=zLogin.loginErrorCallback;
		tempObj.callback=zLogin.zAjaxResetPasswordCallback;
		tempObj.ignoreOldRequests=true;
		zAjax(tempObj);	
		return false;
	},
	zShowLoginError:function(message){
		var d2=document.getElementById('statusDiv');
		if(d2){
			d2.style.display="block";
			d2.innerHTML='<span style="color:#900;">'+message+'<\/span>';
			document.getElementById("submitForm2").style.display="block";
			document.getElementById("submitForm").style.display="block";
		}
	},
	setAutoLogin:function(r){ 
		if (r===true){
			zLogin.autoLoginValue="1";
			zSetCookie({key:"zautologin",value:"1",futureSeconds:60,enableSubdomains:false}); 
		}else{
			zLogin.autoLoginValue="0";
			zSetCookie({key:"zautologin",value:"0",futureSeconds:60,enableSubdomains:false}); 
		}
		zLogin.autoLoginCallback();
	},
	autoLoginPrompt:function(callback){
		zSetCookie({key:"zautologin",value:"",futureSeconds:60,enableSubdomains:false}); 
		// Avoid calling the model window again during this login session
		if(zLogin.autoLoginValue===-1 && zGetCookie("zautologin") === ""){
			zLogin.autoLoginCallback=callback;
			var modalContent1='<div class="zmember-autologin-heading">Do you want to<br />login automatically<br />in the future?<\/div><div><a class="zmember-autologin-button" style="border:1px solid #000;" href="#" onclick="zLogin.setAutoLogin(true);zCloseModal();return false;">Yes<\/a>   <a class="zmember-autologin-button" href="#" onclick="zLogin.enterPressed=false;zLogin.setAutoLogin(false);zCloseModal();return false;">No<\/a><\/div>';
			zShowModal(modalContent1,{'disableClose':true,'width':Math.min(350, zWindowSize.width-50),'height':Math.min(250, zWindowSize.height-50),"maxWidth":350, "maxHeight":250});
			$(window).keypress(function(event){
				if(event.keyCode === 13){
					if(zLogin.lastKeyPressed===13){
						return;
					}
					if(zLogin.enterPressed){
						zLogin.enterPressedTwice=true;
					}
					zLogin.enterPressed=true;
					zLogin.lastKeyPressed=13; 
				}
			});
			$(window).bind("keyup", function(event){
				zLogin.lastKeyPressed=0;
				if(zLogin.enterPressedTwice && event.keyCode === 13){
					zLogin.setAutoLogin(true);
					zCloseModal();
				}
			});
			$("#zModalOverlayDiv").focus();
		}else{
			callback();
		}
	},
	autoLoginConfirm:function(){
		zLogin.autoLoginPrompt(zLogin.zAjaxSubmitLogin);
		return false;
	},
	zAjaxSubmitLogin:function(){
		var tempObj={};
		tempObj.id="zAjaxUserLogin"; 
		tempObj.url="/z/user/login/process";
		zLogin.zShowLoginError("Processing login credentials...");
		if(document.getElementById('z_tmpusername2').value.length==="" || document.getElementById('z_tmppassword2').value.length===""){
			zLogin.zShowLoginError("Email and password are required.");
			return;
		}
		tempObj.postObj={
			z_tmpusername2:document.getElementById('z_tmpusername2').value,
			z_tmppassword2:document.getElementById('z_tmppassword2').value,
			zIsMemberArea:document.getElementById('zIsMemberArea').value,
			zautologin:zLogin.autoLoginValue
		};
		tempObj.method="post";
		tempObj.cache=false;
		tempObj.errorCallback=zLogin.loginErrorCallback;
		tempObj.callback=zLogin.loginCallback;
		tempObj.ignoreOldRequests=true;
		zAjax(tempObj);	
		return false;
	},
	openidAutoConfirm:function(dev){
		zLogin.autoLoginPrompt(zLogin.zOpenidLogin);
	},
	openidAutoConfirm2:function(theLink){
		zLogin.devLoginURL=theLink;
		zLogin.autoLoginPrompt(zLogin.zOpenidLogin2);
	},
	zOpenidLogin2:function(){
		window.location.href=zLogin.devLoginURL;
	},
	zOpenidLogin3:function(devLoginURL){
		window.location.href=devLoginURL;
	},
	zOpenidLogin:function(dev){
		var d1=0;
		if(dev){
			d1=document.getElementById("openidhiddenurl2");
		}else{
			d1=document.getElementById("openidhiddenurl");
		}
		d2=document.getElementById("openidurl");
		zSetCookie({key:"zopenidurl",value:d2.value,futureSeconds:315360000,enableSubdomains:false}); 
		if(d2.value === "" || (d2.value.substr(0,7) !== "http://" && d2.value.substr(0,8) !== "https://")){
			alert('You must enter an OpenID Provider URL or click one of the Google / Yahoo login buttons.');
			return;
		}
		window.location.href=d2.value+d1.value;
		return;
	},
	checkIfPasswordsMatch:function(){
		var d1=document.getElementById("passwordPwd");
		var d2=document.getElementById("passwordPwd2");
		var d3=document.getElementById("passwordMatchBox");
		if(d1.value===""){
			return true;
		}else if(d1.value !== d2.value){
			d3.style.display="block";
			return false;
		}else{
			d3.style.display="none";
			return true;
		}
	},
	confirmToken:function(){
		var tempObj={};
		tempObj.id="zAjaxConfirmToken";
		tempObj.method="post";
		tempObj.cache=false;
		tempObj.errorCallback=zLogin.loginErrorCallback;
		tempObj.callback=zLogin.confirmTokenCallback;
		tempObj.ignoreOldRequests=true;
		tempObj.url="/z/user/login/confirmToken";
		
		if(typeof zLoginServerToken !== "undefined" && zLoginServerToken.loggedIn){
			tempObj.postObj={
				tempToken:zLoginServerToken.token
			};
			if(typeof zLoginServerToken.developer !== "undefined"){
				zSetCookie({key:"zdeveloper",value:zLoginServerToken.developer,futureSeconds:31536000,enableSubdomains:true}); 
			};
			zAjax(tempObj);	
			return false;
		}else if(typeof zLoginParentToken !== "undefined" && zLoginParentToken.loggedIn){
			if(typeof zLoginParentToken.developer !== "undefined"){
				zSetCookie({key:"zdeveloper",value:zLoginParentToken.developer,futureSeconds:31536000,enableSubdomains:true}); 
			};
			tempObj.postObj={
				tempToken:zLoginParentToken.token
			};
			zAjax(tempObj);	
			return false;
		}else{
			/*
			// show message that you can login to parent domain
			var d1=document.getElementById('loginFooterMessage');
			var d2='Global login available for your sites: ';
			var d3=false;
			if(typeof zLoginParentToken !== "undefined"){
				d3=true;
				d2+='<a href="'+zLoginParentToken.loginURL+'" target="_blank">Parent Site Manager Login</a>';
			}
			if(typeof zLoginServerToken !== "undefined"){
				// show message you can login to server manager
				if(d3){
					d2+' or ';
				}
				d2+='<a href="'+zLoginServerToken.loginURL+'" target="_blank">Server Manager Login</a>';
			}
			d1.innerHTML=d2;
			*/
		}
	},
	confirmTokenCallback:function(r){
		var json=eval('(' + r + ')');
		if(typeof json === "object"){
			if(json.success){
				// do the repost form
				zLogin.zShowLoginError("Logging in...");
				var d1=window.parent.document.getElementById("zRepostForm");
				if(d1){
					setTimeout('window.parent.document.zRepostForm.submit();',5000);
					d1.submit();
				}
			}
		}
	},
	init:function(){
		var d1=document.getElementById("z_tmpusername2");
		var d2=zGetCookie("zparentlogincheck");
		if((d2 === "" || typeof d1 !== "undefined") && window.location.href.toLowerCase().indexOf("zlogout=") === -1){
			zSetCookie({key:"zparentlogincheck",value:"1",futureSeconds:0,enableSubdomains:false}); 
			zLogin.confirmToken();
		}
	}
	
};
zArrDeferredFunctions.push(zLogin.init);


function zSetEmailBody(c,t) {
	var ifrm = document.getElementById('zEmailBody'+c);
    var d=(ifrm.contentWindow) ? ifrm.contentWindow : (ifrm.contentDocument.document) ? ifrm.contentDocument.document : ifrm.contentDocument;
    d.document.open();
    d.document.write(t);
    d.document.close();
}

function zSetEmailBodyHeight(c){
    var ifrm = document.getElementById('zEmailBody'+c);
    var el=ifrm;
    ifrm.style.display="block";
    // this code is required to force the browser to set the correct heights after display:block is set
	var d=false;
    while (el.parentNode!==null){el=el.parentNode;d=el.scrollTop;d=el.offsetHeight;d=el.clientHeight;}
	d=false;
    if(ifrm.contentWindow){
        ifrm.style.height=((ifrm.contentWindow.document.body.scrollHeight+1))+'px';
    }else if(ifrm.contentDocument.document){
        ifrm.style.height=(ifrm.contentDocument.document.body.scrollHeight+1)+'px';
    }else{
        ifrm.style.height=(ifrm.contentDocument.body.scrollHeight+1)+'px';
    }
} 
 
function zCheckIfPageAlreadyLoadedOnce(){
	var once=document.getElementById('zPageLoadedOnceTracker');
	// if field was empty, the page was already loaded once and should be reloaded
	if(once.value.length ===""){
		var curURL=window.location.href;
		window.location.href=curURL;
	}
	once.value='';
}

function zShowImageUploadWindow(imageLibraryId, imageLibraryFieldId){
	var windowSize=zGetClientWindowSize();
	var modalContent1='<iframe src="/z/_com/app/image-library?method=imageform&image_library_id='+imageLibraryId+'&fieldId='+encodeURIComponent(imageLibraryFieldId)+'&ztv='+Math.random()+'"  style="margin:0px;border:none; overflow:auto;" seamless="seamless" width="100%" height="95%"><\/iframe>';		
	zShowModal(modalContent1,{'width':windowSize.width-100,'height':windowSize.height-100});
}


/*
example html:
<div id="menu" class="zMenuEqualDiv"><ul class="zMenuEqualUL"><li class="zMenuEqualLI"><a href="#" class="zMenuEqualA">test1</a></li><li class="zMenuEqualLI"><a href="#" class="zMenuEqualA">test2</a></li></ul></div>

example js:
zSetEqualWidthMenuButtons("menu");
*/
var arrOriginalMenuButtonWidth=[]; 
function zSetEqualWidthMenuButtons(containerDivId, marginSize){ 
	if(typeof arrOriginalMenuButtonWidth[containerDivId] === "undefined"){
		 zArrResizeFunctions.push(function(){ zSetEqualWidthMenuButtons(containerDivId, marginSize); });
		arrOriginalMenuButtonWidth[containerDivId]={
			ul:$("#"+containerDivId+" > ul "),
			arrLI:$("#"+containerDivId+" > ul > li"),
			arrItem:$("#"+containerDivId+" > ul > li > a"),
			arrItemWidth:[],
			arrItemBorderAndPadding:[],
			containerWidth:	0,
			navWidth:0,
			marginSize:marginSize
		};
		var currentMenu=arrOriginalMenuButtonWidth[containerDivId];
		for(var i=0;i<currentMenu.arrItem.length;i++){ 
			var jItem=$(currentMenu.arrItem[i]);
				/*$(currentMenu.arrItem[i]).css({ 
					"padding-left": "0px",
					"padding-right": "0px"
				});*/
			var curWidth=jItem.width();
			var borderLeft=parseInt(jItem.css("border-left-width"));
			var borderRight=parseInt(jItem.css("border-right-width"));
			if(isNaN(borderLeft)){
				borderLeft=1;
			}
			if(isNaN(borderRight)){
				borderRight=1;
			}
			var curBorderAndPadding=parseInt(jItem.css("padding-left"))+parseInt(jItem.css("padding-right"))+parseInt(borderLeft)+parseInt(borderRight);
			//console.log("borpad:"+curBorderAndPadding+":"+borderLeft+":"+borderRight+":"+curWidth+":"+jItem.width()+":"+(jItem.css("padding-left"))+":"+(jItem.css("padding-right"))+":"+jItem.css("border-left-width")); 
			if(i===currentMenu.arrItem.length-1){
				//curWidth-=0.5;
				$(jItem).css({
					"margin-right": "0px"
				});
				curWidth=$(jItem).width();
				//console.log("last:"+curWidth);
				$(jItem).css({ 
					"width": curWidth+"px"
				});
				currentMenu.navWidth+=curWidth+curBorderAndPadding;
			}else{
				$(jItem).css({
					"margin-right": currentMenu.marginSize+"px",
					"width": curWidth
				}); 
				currentMenu.navWidth+=curWidth+marginSize+curBorderAndPadding;
			}
			currentMenu.arrItemBorderAndPadding.push(curBorderAndPadding);
			currentMenu.arrItemWidth.push(curWidth);
		}
		//$("#"+containerDivId+" ul").css("min-width", currentMenu.navWidth);
	}
	var currentMenu=arrOriginalMenuButtonWidth[containerDivId];
	//console.log(currentMenu.marginSize);
	currentMenu.ul.detach(); 
	$("#"+containerDivId).width("100%");
	currentMenu.containerWidth=$("#"+containerDivId).width();
	var totalWidth = currentMenu.containerWidth-1;//-2;
	var navWidth = 0;
	var deltaWidth = totalWidth - (currentMenu.navWidth);// + currentMenu.marginSize);
	var padding = ((deltaWidth / currentMenu.arrItem.length) / 2);// - (currentMenu.marginSize/2); 
	var floatEnabled=false;
	if(totalWidth<currentMenu.navWidth + ((currentMenu.arrItem.length-1)*currentMenu.marginSize)){
		//padding=0;
		floatEnabled=true;
		$(currentMenu.arrLI).each(function(){ $(this).css("display", "block"); });
	}else{
		if($.browser.msie && $.browser.version <= 7){
			$(currentMenu.arrLI).each(function(){ $(this).css("display", "inline"); });
		}else{
			$(currentMenu.arrLI).each(function(){ $(this).css("display", "inline-block"); });
		} 
	}
	//console.log(containerDivId+":"+"marginSize:"+currentMenu.marginSize+" containerWidth:" +currentMenu.containerWidth+" totalWidth:"+totalWidth+" navWidth:"+currentMenu.navWidth+" deltaWidth:"+deltaWidth+" padding:"+padding);
	var totalWidth2=0;
	for(var i=0;i<currentMenu.arrItem.length;i++){ 
		var curWidth=currentMenu.arrItemWidth[i];
		//console.log(padding);
		//$(currentMenu.arrItem[i]).width(curWidth-20);
		var newWidth=curWidth+(padding*2); 
		if($.browser.msie && $.browser.version <= 7 && floatEnabled){
			$(currentMenu.arrItem[i]).css({
				"width": newWidth,
				"min-width":curWidth
				/*,
				"padding-left": "5px",
				"padding-right": "5px"*/
			});
		}else{
			$(currentMenu.arrItem[i]).css({
				"width": newWidth,
				"min-width":curWidth
				/*,
				"padding-left": "0px",
				"padding-right": "0px"*/
			});
				
		}
		//$(currentMenu.arrItem[i]).css("padding", "0 "+padding+"px 0 "+padding+"px");
	}
	$("#"+containerDivId).append(currentMenu.ul);
}
