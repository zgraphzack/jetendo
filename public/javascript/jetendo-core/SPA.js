
/*
if (!Object.create) {
	Object.create = function(proto, props) {
		if (typeof props !== "undefined") {
			throw "The multiple-argument version of Object.create is not provided by this browser and cannot be shimmed.";
		}
		function ctor() { }
		ctor.prototype = proto;
		return new ctor();
	};
}*/
Function.prototype.inheritsFrom = function( parentClassOrObject ){ 
	if ( parentClassOrObject.constructor == Function ) { 
		//Normal Inheritance 
		this.prototype = new parentClassOrObject;
		this.prototype.constructor = this;
		this.prototype.parent = parentClassOrObject.prototype;
	}else{ 
		//Pure Virtual Inheritance 
		this.prototype = parentClassOrObject;
		this.prototype.constructor = this;
		this.prototype.parent = parentClassOrObject;
	} 
	return this;
};

(function(Jetendo, $, window, document, undefined){
"use strict";  


Jetendo.SPA=function(options){
	window.jetendoSPA=this;
	var self=this;
	var objectCache={};
	var loadCount=0;
	var totalCount=0;
	var loadCallbackCache={};
	var javascriptFileCache=[];
	var jetendoHandlebarTemplateCache={};
	var currentLinkObj={};

	HandlebarsFormHelpers.register(Handlebars);

	options.prefixPath=zso(options, 'prefixPath', false, "/client/");
	options.viewSuffix=zso(options, 'viewSuffix', false, ".html");
	options.forceAjaxCrawl=zso(options, 'forceAjaxCrawl', false, false);
	options.content=zso(options, 'content', false, "");
	options.title=zso(options, 'title', false, "");
	options.defaultHash=zso(options, 'defaultHash', false, "");
	options.arrRegisterBuildFunctions=zso(options, 'arrRegisterBuildFunctions', false, []);
	
	if(options.defaultHash==""){
		throw("JetendoSPA() -> options.defaultHash is required");
	}
	if(options.content==""){
		throw("JetendoSPA() -> options.content is required");
	}
	if(options.title==""){
		throw("JetendoSPA() -> options.title is required");
	} 

	function loadController(){
		//console.log("load controller:"+currentLinkObj.controllerPath);
		var currentController=self.getObject(currentLinkObj.controllerPath);
		currentController.startRequest();
		currentController[currentLinkObj.method](currentLinkObj.params);

	} 
	function parseLink(link){ 
		var r={};
		var link=link.substr(2);

		var arrPart=link.split("/");
		if(arrPart.length <= 1){
			throw("Invalid url, controller/method format required: "+link);
		}
		r.method=arrPart[arrPart.length-1];
		r.controllerPath=arrPart.slice(0, arrPart.length-1).join("/")+"Controller";

		var a=r.method.split("?");
		r.method=a[0];
		r.params={};
		if(a.length>1){
			var arrParam=a[1].split("&");
			for(var i=0;i<arrParam.length;i++){
				var b=arrParam[i].split("=");
				if(b[0] in r.params){
					r.params[b[0]]+=","+unescape(b[1]);
				}else{
					r.params[b[0]]=unescape(b[1]);
				}
			}
		}
		//console.log(r);
		return r;
	}

	function convertHashToEscapedFragment(link){
		
	} 

	function hashRoute(){  
		var hash=window.location.hash;
		if(typeof forceAjaxCrawl != undefined && forceAjaxCrawl){
			//window.location.replace("/listing/manage-providers/index?_escaped_fragment_="+hash.substr(2));
			//return false;
		}
		console.log('hashRoute:'+hash);
		var isURL=false;
		if(hash == ''){
			return false;
		}
		if(hash.indexOf('#!') != -1){
			isURL=true;
			currentLinkObj=parseLink(hash);
			if(self.isCached(currentLinkObj.controllerPath)){
				loadController(); 
			}else{
				self.registerDefinedCallback(currentLinkObj.controllerPath, loadController);
				self.loadJavaScriptFile(currentLinkObj.controllerPath, function(){});
			}
		}

		if(isURL){
			// prevent default behavior when this is url route
			return false;
		}
	}
	function executeLoadCallbacks(obj){
		//console.log("define -> executeLoadCallbacks -> "+obj.classPath);
		objectCache[obj.classPath]=obj.callback(obj.classPath); 
		if(obj.classPath in loadCallbackCache){
			var c=loadCallbackCache[obj.classPath];
			for(var n=0;n<c.length;n++){
				c[n]();
			}
		}
	}
	self.define=function(obj){ 
		//console.log('define class:'+obj.classPath); 
		if(obj.arrDepend.length==0){
			executeLoadCallbacks(obj); 
			return;
		}
		console.log(obj);
		loadCount=0;
		totalCount=obj.arrDepend.length;
		for(var i=0;i<obj.arrDepend.length;i++){
			self.loadJavaScriptFile(obj.arrDepend[i], function(){
				loadCount++;
				if(loadCount==totalCount){
					//console.log('all loaded for '+obj.classPath);
					executeLoadCallbacks(obj); 
				}
			});
		}
	};
	self.registerDefinedCallback=function(objectPath, callback){
		if(typeof loadCallbackCache[objectPath] == undefined){
			loadCallbackCache[objectPath]=[];
		}
		loadCallbackCache[objectPath].push(callback);
	};
	self.getObject=function(objectPath){
		if(objectPath in objectCache){
			return objectCache[objectPath];
		}else{
			throw(objectPath+" is missing in jetendoSPA. It must be loaded first.");
		}
	};
	self.isCached=function(objectPath){
		if(objectPath in objectCache){
			return true;
		}else{
			return false;
		}
	}  
	self.registerController=function(obj){
		obj.inheritsFrom(BaseController); 
		obj.prototype.jetendoSPA=self;
	}
	self.registerModel=function(obj){
		obj.inheritsFrom(BaseModel);  
	}
	self.getViewURL=function(viewArg){
		return options.prefixPath+viewArg+options.viewSuffix;
	}
	self.loadJavaScriptFile=function(link, callback){
		var fullLink=options.prefixPath+link+".js";
		//console.log('load js file:'+link);
		if(link in javascriptFileCache){
			//console.log('already loaded js file:'+link);
			callback();
			return;
		}
		var a=document.createElement('script');
		a.async=1;
		a.loadCallback=callback;
		a.src=fullLink;
		a.setAttribute("data-scriptLoaded","0");
		a.onreadystatechange=function(){
			if(this.readyState=="loaded" || this.readyState=="complete"){
				if (this.getAttribute("data-scriptLoaded")=="0"){
					this.setAttribute("data-scriptLoaded","1");
					javascriptFileCache[link]=true;
					//console.log('loaded js file:'+link);
					a.loadCallback();
				}
			}
		};
		a.onload=function(){
			if (this.getAttribute("data-scriptLoaded")=="0"){
				this.setAttribute("data-scriptLoaded","1");
				javascriptFileCache[link]=true;
				//console.log('loaded js file:'+link);
				a.loadCallback();
			}
		}; 
		a.onerror=function(){
			var m="error loading script:"+this.src+"\nreadyState:"+this.readyState;
			alert(m);
			throw(m);
		}; 
		var h = document.getElementsByTagName("head")[0];
		h.appendChild(a);
	};

	self.getHandlebarTemplate=function(viewArg){
		return jetendoHandlebarTemplateCache[viewArg];
	}
	self.setHandlebarTemplate=function(viewArg, templateArg){
		jetendoHandlebarTemplateCache[viewArg]=templateArg;
	}
	
	function checkForModalLink(linkObj){
		if($(linkObj).hasClass("zModalLink")){ 
			// TODO: finish implementing rendering of hashbang routes to a modal window to allow zero reload modal navigation via hashbang urls that have their output redirected to the topmost modal window.
			var modalContent1='test';
			zShowModal(modalContent1, {'width':500,'height':300});
			return false;
		} 
	}
	function enableReloadingSameHashbangURL(linkObj){ 

		if(linkObj.href && linkObj.href.indexOf('#!') != -1){
			if(linkObj.href == window.location.href){ 
				window.location.hash=""; 
				window.location.hash=linkObj.hash; 
			}
		}
	}
	$(document).bind("click", "a", function(){  
		checkForModalLink(this);
		enableReloadingSameHashbangURL(this);
	});
	for(var i=0;i<options.arrRegisterBuildFunctions.length;i++){ 
		var r=window[options.arrRegisterBuildFunctions[i]]();
		for(var n in r){
			javascriptFileCache[n]=true;
		}
	}
	$(window).bind('hashchange', hashRoute); 
	if(window.location.hash==""){
		window.location.hash=options.defaultHash;
	}else{
		hashRoute();
	}
}; 



function BaseModel(){
}
function BaseController(){
	var self=this;
	var view;
	var viewData={}
	var redirectLink="";
	var returnString="";
	var returnType="string";
	var callback=function(){};
	self.startRequest=function(){
		redirectLink="";
		returnString="";
		returnType="string";
		callback=function(){};
	}
	self.setViewTemplate=function(viewArg, viewDataArg, callbackArg){
		view=viewArg;
		viewData=viewDataArg;
		returnType="viewTemplate";
		if(typeof callbackArg != undefined){
			callback=callbackArg;
		}
		self.endRequest();
	}
	self.setViewString=function(viewArg, viewDataArg, callbackArg){
		view=viewArg;
		viewData=viewDataArg;
		returnType="view";
		if(typeof callbackArg != undefined){
			callback=callbackArg;
		}
		self.endRequest();
	}
	self.setViewPath=function(viewArg, viewDataArg, callbackArg){
		view=viewArg;
		viewData=viewDataArg;
		returnType="viewPath";
		if(typeof callbackArg != undefined){
			callback=callbackArg;
		}
		self.endRequest();
	}
	self.setReturnString=function(s, callbackArg){ 
		returnString=s;
		returnType="string";
		if(typeof callbackArg != undefined){
			callback=callbackArg;
		}
		self.endRequest();
	}
	self.setRedirectLink=function(link){
		redirectLink=link;
		returnType="redirect";
		self.endRequest();
	}
	self.registerEndRequestCallback=function(link){
		redirectLink=link;
		returnType="redirect";
		self.endRequest();
	}
	self.endRequest=function(){ 
		if(returnType =="redirect"){
			if(redirectLink.substr(0, 2) == '#!'){
				window.location.hash=redirectLink;
			}else{
				window.location.href=redirectLink;
			}
			return;
		}else if(returnType == "string"){ 
			$("#mainContentArea").html(returnString);
			callback();
		}else if(returnType == "viewTemplate"){
			var html=view(viewData);
			$("#mainContentArea").html(html);
			callback();
		}else if(returnType == "viewPath"){
			renderView(view, viewData, function(html){
				$("#mainContentArea").html(html);
				callback();
			});
		}else if(returnType == "view"){ 
			var template=Handlebars.compile(view);
			var html=template(viewData);
			$("#mainContentArea").html(html);
			callback();
		}
	} 
	function renderView(viewArg, viewDataArg, callback){ 
		if(typeof Handlebars.templates != undefined && typeof Handlebars.templates[viewArg] != undefined){
			var html=Handlebars.templates[viewArg](viewDataArg);
			callback(html);
		/*}else if(jetendoSPA.isCached(viewArg)){
			var html=jetendoSPA.getHandlebarTemplate(viewArg)(viewDataArg);
			callback(html);*/
		}else {  
			var fullLink=self.jetendoSPA.getViewURL(viewArg); 
			$.get(fullLink, function(data){  
				var templateSpec = Handlebars.precompile(data);
				//console.log(templateSpec);
				templateSpec=eval("("+templateSpec+")");
				var template=Handlebars.template(templateSpec);
				//console.log(template);

				jetendoSPA.setHandlebarTemplate(viewArg, template);
				var html=template(viewDataArg);
				callback(html);

			}).fail(function(){
				throw("Failed to load view: "+viewArg);
			});
		}
	}
} 


})(Jetendo, jQuery, window, document, "undefined"); 