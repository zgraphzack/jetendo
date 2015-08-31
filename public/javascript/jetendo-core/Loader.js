Jetendo.Loader=(function(Jetendo, window, document, undefined){
"use strict";
	var self=this; 
	var loadedPackages={};
	var loadingFiles={}; 
	var packageCallbacks={};
	var loadPackageCount={};
	var loadPackageCallback={};
	var loadingPackages={};
	var loadPackageLevel={};
	var onloadCallback=[];
	var loadComplete=false;

	var debug=true; 

	function loadFile(name, callback){ 
		if(typeof loadingFiles[name] != undefined){
			return;
		}
		if(debug){
			log("loadFile:"+name);
		}
		loadingFiles[name]=true;
		var a=document.createElement("script");
		a.async=true;
		a.loadCallback=callback; 
		a.src=name;
		a.setAttribute("data-scriptLoaded","0");
		a.onreadystatechange=function(){
			if(this.readyState=="loaded" || this.readyState=="complete"){
				if (this.getAttribute("data-scriptLoaded")=="0"){
					this.setAttribute("data-scriptLoaded","1");
					Jetendo.loadedFiles[name]=true; 
					a.loadCallback();
				}
			}
		};
		a.onload=function(){
			if (this.getAttribute("data-scriptLoaded")=="0"){
				this.setAttribute("data-scriptLoaded","1");
				Jetendo.loadedFiles[name]=true; 
				a.loadCallback();
			}
		}; 
		a.onerror=function(){
			var m="error loading script:"+this.src+"\nreadyState:"+this.readyState; 
			throw(m);
		}; 

		document.getElementsByTagName("head")[0].appendChild(a);
	}
	function loadCSS(name){ 
		if(typeof Jetendo.loadedFiles[name] != undefined){
			return;
		}
		Jetendo.loadedFiles[name]=true;
		var a=document.createElement("link"); 
		a.rel="stylesheet";
		a.type="text/css";
		a.href=name;
		document.getElementsByTagName("head")[0].appendChild(a);
	}
	function runPackageCallbacks(name){
		if(typeof loadedPackages[name] != undefined){
			return;
		}
		if(debug){
			log("package loaded:"+name);
			log('callback count:'+loadPackageCallback[name].length);
		}
		loadedPackages[name]=true;
		for(var i=0,n=loadPackageCallback[name].length;i<n;i++){
			loadPackageCallback[name][i]();
		}
		loadPackageCallback[name]=[];
	}

	function loadPackage(arrDepend, name, callback, levelArg){ 
		if(typeof loadingPackages[name] != undefined && levelArg <= loadPackageLevel[name]){
			if(levelArg==0){
				loadPackageCallback[name].push(callback);
			}
			return;
		}else{
			loadPackageCount[name]=0;
			loadPackageLevel[name]=levelArg;
			if(levelArg==0){
				loadPackageCallback[name]=[];
				loadPackageCallback[name].push(callback);
			}
		}
		if(typeof loadedPackages[jsFile] != undefined){
			return;
		}
		loadingPackages[name]=true; 
		if(debug){
			log("loadPackage:"+name);
		}
		var loadFiles=arrDepend.arrFile[name];
		//for(var n=0;n<loadFiles.length;n++){ 
		var n2=loadFiles[levelArg];
		var notLoaded=false;
		for(var n3=0;n3<n2.length;n3++){
			var jsFile=n2[n3];
			if(jsFile.substr(jsFile.length-4) == ".css"){
				loadPackageCount[name]++;
				// verify that css is loaded, if not, load it here
				if(typeof Jetendo.loadedFiles[jsFile] == undefined){
					loadCSS(jsFile); 
				}
				//throw("Loading css this way is not implemented.");
			}else if(jsFile.substr(jsFile.length-3) == ".js"){
				// load js file
				if(typeof Jetendo.loadedFiles[jsFile] == undefined){
					loadFile(jsFile, function(){
						loadPackageCount[name]++;
						if(loadPackageCount[name] == n2.length){
							if(levelArg+1 < loadFiles.length){
								loadPackage(arrDepend, name, function(){}, levelArg+1);
							}else{
								runPackageCallbacks(name);
							}
						}
					});
					notLoaded=true;
				}
			}else{
				// package name
				if(typeof loadedPackages[jsFile] == undefined){
					loadPackage(arrDepend, jsFile, function(){
						loadPackageCount[name]++;
						if(loadPackageCount[name] == n2.length){
							if(levelArg+1 < loadFiles.length){
								loadPackage(arrDepend, name, function(){}, levelArg+1);
							}else{
								runPackageCallbacks(name);
							}
						}
					}, 0); 
					notLoaded=true;
				}
			}
		}
		if(!notLoaded){
			if(levelArg+1 < loadFiles.length){
				loadPackage(arrDepend, name, function(){}, levelArg+1);
			}else{
				runPackageCallbacks(name);
			}
		} 
	}
	function log(m){
		console.log('Loader.js: '+m);
	}
	function runLoadFunctions(){
		loadComplete=true;
		if(debug){
			log('everything was loaded - running callbacks');
		}
		for(var i=0;i<onloadCallback.length;i++){
			onloadCallback[i]();
		}
	}

	function loadSynchronousPackage(arrDepend, name, sequenceObj){  
		if(debug){
			log("loadPackage:"+name);
		}
		if(typeof sequenceObj.uniqueObj[name] != undefined){
			if(debug){
				log(name+" already loaded");
			}
			return;
		} 
		var loadFiles=arrDepend.arrFile[name];
		for(var n=0,loadLen=loadFiles.length;n<loadLen;n++){ 
			var n2=loadFiles[n]; 
			for(var n3=0,loadLen2=n2.length;n3<loadLen2;n3++){
				var jsFile=n2[n3];
				if(typeof Jetendo.loadedFiles[jsFile] != undefined || typeof sequenceObj.uniqueObj[jsFile] != undefined){ 
					continue;
				}
				if(debug){
					log('adding file to sequence:'+jsFile);
				}
				if(jsFile.substr(jsFile.length-4) == ".css"){ 
					//throw("Loading css this way is not implemented.");
					sequenceObj.arrCSS.push(jsFile); 
				}else if(jsFile.substr(jsFile.length-3) == ".js"){
					// load js file
					sequenceObj.arrJS.push(jsFile);  
				}else{ 
					loadSynchronousPackage(arrDepend, jsFile, sequenceObj);  
				}
				sequenceObj.uniqueObj[jsFile]=true;
			}
		}
	}
	function loadWithAjax(arrDepend, files){
		// this is for browser ajax loading 
		var loadCount=0;

		for(var i=0;i<files.length;i++){
			var f=files[i];
			if(typeof arrDepend.arrFile[f] == undefined){
				throw("Invalid js package name:"+f);
			} 
			loadPackage(arrDepend, f, function(){ 
				loadCount++;
				if(loadCount==files.length){
					runLoadFunctions();
				}
			}, 0); 
		}

	}

	function buildSequentialArray(arrDepend, files){
		// this is for getting a list of files that can be loaded synchronously in the correct sequence - not used yet but it works
		var sequenceObj={
			arrJS:[],
			arrCSS:[],
			uniqueObj:{}
		};

		for(var i=0;i<files.length;i++){
			var name=files[i];
			if(typeof arrDepend.arrFile[name] == undefined){
				throw("Invalid js package name:"+name);
			} 
			loadSynchronousPackage(arrDepend, name, sequenceObj); 
		}
		if(debug){
			log('everything was loaded');
		}
		return sequenceObj;
	} 
	function addLoadFunction(callback){
		if(loadComplete){
			callback();
		}else{
			onloadCallback.push(callback);
		}
	} 
	function load(){ 
		return;
		var d=document.getElementById("JetendoDependJS");
		var count=parseInt(d.getAttribute("data-count"));
		var loadedFiles=d.getAttribute("data-loaded").split(",");
		for(var i=0;i<loadedFiles.length;i++){
			Jetendo.loadedFiles[loadedFiles[i]]=true;
		}
		var files=d.value.split(","); 
		loadWithAjax(Jetendo.Dependencies, files); 
		return; 
		/*
		var sequenceObj=buildSequentialArray(Jetendo.Dependencies, files);
		log(sequenceObj);
		runLoadFunctions();
		*/
	} 
	function addLoadEvent(func) {
		var oldonload = window.onload;
		if (typeof window.onload != "function") {
			window.onload = func;
		}
		else {
			window.onload = function() {
				if (oldonload) {
					oldonload();
				}
				func();
			};
		}
	}
	return {
		load:load,
		buildSequentialArray:buildSequentialArray,
		loadWithAjax:loadWithAjax,
		addLoadFunction:addLoadFunction,
		addLoadEvent:addLoadEvent
	}

})(Jetendo, window, document, "undefined");
Jetendo.Loader.addLoadEvent(Jetendo.Loader.load);