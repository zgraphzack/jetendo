var zArrMapFunctions=new Array();
var zArrScrollFunctions=new Array();
var zImageOnError=function(){};
var zFunctionLoadStarted=false;
var zArrResizeFunctions=new Array();
var zMSIEVersion=-1; 
var zMSIEBrowser=window.navigator.userAgent.indexOf("MSIE"); 
if(zMSIEBrowser != -1){	
	zMSIEVersion= (window.navigator.userAgent.substring (zMSIEBrowser+5, window.navigator.userAgent.indexOf (".", zMSIEBrowser ))); 
}
var zModernizrLoadedRan=false;
var zArrDeferredFunctions=[];
var zArrLoadFunctions=[];
zModernizrLoaded=function(){};
var zModernizr99=true;
function zOverEditDiv(){};
function zImageMouseMove(){};
function zImageMouseReset(){};
function onGMAPLoad(){};
zLoadMapID=false;
function zMapInit(){ 
	if(zModernizrLoadedRan){ 
		zLoadMapFunctions(); 
		onGMAPLoad(true); 
	}else{ 
		zArrDeferredFunctions.push(function(){ 
			zLoadMapFunctions(); 
			onGMAPLoad(true);  
		}); 
	} 
};
function zBindEvent(elem, evt, cb){
	if(elem.addEventListener){
		elem.addEventListener(evt,cb,false);
	}else if(elem.attachEvent){
		elem.attachEvent("on" + evt, function(){
			cb.call(event.srcElement,event);
		});
	}
}
var zStackTraceLoaded=false;
var zJavascriptErrorLogged=false;
function zLoadStackTrace(){
	if(zStackTraceLoaded){
		return;
	}
	zStackTraceLoaded=true;
	if(window.XMLHttpRequest){ 
		var xhr = new XMLHttpRequest();  
	}else if (window.ActiveXObject){ 
		var xhr = new ActiveXObject('Microsoft.XMLHTTP');  
	} 
	// open and send a synchronous request
	xhr.open('GET', '/z/javascript/javascript-stacktrace/stacktrace.js', false);
	xhr.send('');
	// add the returned content to a newly created script tag
	var se = document.createElement('script');
	se.type = "text/javascript";
	se.text = xhr.responseText;
	document.getElementsByTagName('head')[0].appendChild(se);
}
function zGlobalErrorHandler(message, url, lineNumber, columnOffset, errorObj) {
	try{
		if(message.substr(0, 17) === "Unspecified error" || message.substr(0, 12) === "Script error" || message.substr(0, 12) === "Syntax error" || message.substr(0, 18) ===  "Not enough storage"){
			return false; // ignore origin errors
		}
		if(zJavascriptErrorLogged || (zThisIsDeveloper && window.location.href.indexOf("zdebug=") === -1)){
			return false;
		}
		zJavascriptErrorLogged=true; // only log 1 error per page view
		zLoadStackTrace();
			
		arrStack=printStackTrace();  
		arrNewStack=[];
		if(typeof arrStack !== "undefined"){
			for(var i=0;i < arrStack.length;i++){
				// ignore internal calls
				if(arrStack[i].indexOf('printStackTrace') === -1){
					arrNewStack.push(arrStack[i]);
				}
				// ignore disqus, facebook, google, twitter, etc...
			}
		}
		postObj={};
		postObj.requestURL=window.location.href;
		postObj.errorStacktrace=arrNewStack.join("\n");
		postObj.errorMessage=message;
		postObj.errorUrl=url;
		if(typeof columnOffset !== "undefined"){
			postObj.errorColumnOffset=columnOffset;
		}
		postObj.errorLineNumber=lineNumber;
		if(typeof errorObj !== "undefined"){
			if(typeof JSON !== "undefined" && typeof JSON.stringify !== "undefined"){
				errorObj=JSON.stringify(errorObj, null, 4);
			}
			postObj.errorObj=errorObj;
		}
		if(window.XMLHttpRequest){ 
			var xhr = new XMLHttpRequest();  
		}else if (window.ActiveXObject){ 
			var xhr = new ActiveXObject('Microsoft.XMLHTTP');  
		} 
		xhr.open("POST", "/z/misc/system/logClientError", true);
		xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		var postData="";
		for(var i in postObj){
			postData+=i+"="+encodeURIComponent(postObj[i])+"&";
		}
		xhr.send(postData);
		// hide errors for real users
		if(typeof console != "undefined" && typeof console.log != "undefined"){
			console.log("A javascript error occured and the web developer was notified.");
		}
		return false; 
	}catch(e){
		// ignore errors.
	}
}
window.onerror=zGlobalErrorHandler;
var zLoader=function(){
	this.loaded=0;
	this.scriptLoaded=function(){
		this.loaded++;
		if(this.count==this.loaded){
			if(this.completeCallback){
				this.completeCallback();
			}else if(typeof zModernizrLoaded != "undefined"){
				zModernizrLoaded();
			}
		}
	};
	this.loadScripts=function(arr, c) {
		this.count=arr.length;
		var h = document.getElementsByTagName("head")[0];
		var a=[];
		this.completeCallback=c;
		for(var i=0;i<arr.length;i++){
			var s = document.createElement("script");
			s.type = "text/javascript";
			s.zLoader=this;
			s.setAttribute("data-scriptLoaded","0");
			s.onreadystatechange=function(){
				if(this.readyState=="loaded" || this.readyState=="complete"){
					if (this.getAttribute("data-scriptLoaded")=="0"){
						this.setAttribute("data-scriptLoaded","1");
						this.zLoader.scriptLoaded();
					}
				}
			};
			s.onload=function(){
				if (this.getAttribute("data-scriptLoaded")=="0"){
					this.setAttribute("data-scriptLoaded","1");
					this.zLoader.scriptLoaded();
				}
			};
			
			s.onerror=function(){
				//alert("error loading script:"+this.src+":"+this.readyState);
			}; 
			s.src = arr[i];
			
			h.appendChild(s);
		}
	}
}