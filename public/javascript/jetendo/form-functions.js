
var zSiteOptionGroupLastFormID="";
var zAjaxSortURLCache=[];
var zCacheSliderValues=[];
var selIndex=0;
var zAjaxData=[];
var zAjaxCounter=0;
var zAjaxLastRequestId=false;
var zAjaxLastFormName="";
var zAjaxOnLoadCallback=function(){};
var zAjaxOnErrorCallback=function(){};
var zAjaxLastOnErrorCallback=function(){};
var zInputSlideOldValue="";
var zArrSetSliderInputArray=[];
var zArrSetSliderInputUniqueArray=[];
var zExpOptionLabelHTML=[];
var zAjaxLastOnLoadCallback=false;
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
var zFormOnEnterValues=new Array();
var zInputBoxLinkValues=[];
/*var zLastAjaxTableId="";
var zLastAjaxURL="";
var zLastAjaxVarName=""; */

(function($, window, document, undefined){
	"use strict";
	function zUpdateImageLibraryCount(){
		var d=document.getElementById("sortable");
		$("#imageLibraryDivCount", window.parent.document).html($("li", d).length+" images in library");
	}
	function ajaxSaveSorting(){
		var arrId=$( "#sortable" ).sortable("toArray");
		for(var i=0;i<arrId.length;i++){
			arrId[i]=arrId[i].substr(5);
		}
		var link="/z/_com/app/image-library?method=saveSortingPositions&image_library_id="+currentImageLibraryId+"&image_id_list="+arrId.join(",");
		$.get(link, "",     function(data) { 
			if(debugImageLibrary){
				document.getElementById("forimagedata").value+="\n\nAJAX RESULT:\n"+data+"\n"; 
			}
			zUpdateImageLibraryCount();
		}, "html");  

		if(debugImageLibrary) document.getElementById("forimagedata").value+="ajaxSaveSorting(): array of image_id:\n"+arrId+"\nLINK:"+link;
	}
	function ajaxSaveImage(id){
		if(debugImageLibrary) document.getElementById("forimagedata").value+="ajaxSaveImage(): image_id:"+id+"\n";
		var link="/z/_com/app/image-library?method=saveImageId&action=update&image_library_id="+currentImageLibraryId+"&image_id="+id+"&image_caption="+escape(document.getElementById('caption'+id).value);
		if(debugImageLibrary) document.getElementById("forimagedata").value+="\n\n"+link+"\n\n";
		$.get(link, "",     function(data) { 
			if(debugImageLibrary){
				document.getElementById("forimagedata").value+="\n\nAJAX SAVE IMAGE RESULT:\n"+data+"\n"; 
			}
			zUpdateImageLibraryCount();
		},     "html");  
	}

	function toggleImageCaptionUpdate(id,state,skipUpdate){
		var d=document.getElementById(id);
		var ajaxCall=false;
		if(d.style.display==="block" && state ==="none"){
			ajaxCall=true;	
		}
		var image_id=id.substr("imagecaptionupdate".length);
		d.style.display=state; 
		if(ajaxCall && typeof arrImageLibraryCaptions[image_id] !== "undefined" && arrImageLibraryCaptions[image_id] !== document.getElementById("caption"+image_id).value){
			ajaxSaveImage(image_id);
			arrImageLibraryCaptions[image_id]=document.getElementById("caption"+image_id).value;
		}
	}
	function confirmDeleteImageId(id){
		if(window.confirm("Are you sure you want to PERMANENTLY DELETE this image?")){
			deleteImageId(id);	
		}
	}
	function deleteImageId(id){
		var d = document.getElementById('sortable');
		var olddiv = document.getElementById("image"+id);
		d.removeChild(olddiv);
		var link="/z/_com/app/image-library?method=remoteDeleteImageId&image_id="+id;
		if(debugImageLibrary) document.getElementById("forimagedata").value+="\nDelete Image ID:"+id+"\n\n"+link+"\n\n";
		$.get(link, "",     function(data) { 
			if(debugImageLibrary){
				document.getElementById("forimagedata").value+="\n\nAJAX DELETE IMAGE RESULT:\n"+data+"\n"; 
			}
			zUpdateImageLibraryCount();
		},     "html"); 
		ajaxSaveSorting();
	}
	function setUploadField(){
		var hasFlash = false;
		return;
		/*try {
			var fo = new ActiveXObject('ShockwaveFlash.ShockwaveFlash');
			if(fo) hasFlash = true;
		}catch(e){
			if(navigator.mimeTypes ["application/x-shockwave-flash"] !== "undefined") hasFlash = true;
		}
		var d = document.getElementById("imagefiles");
		// temporarily disable html 5 multiple file upload until Railo has fixed the bug with it.
		if(1===0){// typeof d.multiple === "boolean" || !hasFlash){
			document.getElementById("flashFileUpload").style.display="none";
		}else{
			document.getElementById("htmlFileUpload").style.display="none";
			document.getElementById("flashFileUpload").style.display="block";
		}*/
	}
	function zSiteOptionGroupAutoMap(){
		var matchCount=0;
		$("#siteOptionGroupMapForm .fieldLabelDiv").each(function(){
			var id=$(this).attr("data-id");
			var text=this.innerHTML.toLowerCase();
			text=text.replace(/ /, "_");

			var matched=false;
			var s=document.getElementById("mapField"+id);
			if(s.selectedIndex != 0){
				return;
			}
			var custom=0;
			for(var i=0;i<s.options.length;i++){
				if(s.options[i].value == 'inquiries_custom_json'){
					custom=i;
					break;
				}
			}
			for(var i=0;i<s.options.length;i++){
				var v=s.options[i].value.replace(/inquiries_/, '');
				if(v==text){
					//console.log('Matched: '+v);
					s.selectedIndex=i;
					matched=true;
						matchCount++;
					break;
				}
			}
			if(!matched){
				for(var i=0;i<s.options.length;i++){
					var v=s.options[i].value.replace(/inquiries_/, '');
					if(v.indexOf(text) != -1){
						//console.log('Partial match: '+v);
						s.selectedIndex=i;
						matched=true;
						matchCount++;
						break;
					}
				}
			}
			if(!matched){
				//console.log('no match found for '+text, 'should be custom_json now.');
				s.selectedIndex=custom;
			}
		});
		return matchCount;
	}
	 
	$(".zSiteOptionGroupAutoMap").bind("click", function(){
		var matchCount=zSiteOptionGroupAutoMap();
		alert(matchCount+" fields were automatically mapped.");
	}); 

	function zSiteOptionGroupErrorCallback(){
		alert("There was a problem with the submission. Please try again later.");
		$(".zSiteOptionGroupSubmitButton", $("#"+zSiteOptionGroupLastFormID)).show();
		$(".zSiteOptionGroupWaitDiv", $("#"+zSiteOptionGroupLastFormID)).hide();
	}
	function zSiteOptionGroupCallback(d){
		var rs=eval("("+d+")");
		$(".zSiteOptionGroupSubmitButton", $("#"+zSiteOptionGroupLastFormID)).show();
		$(".zSiteOptionGroupWaitDiv", $("#"+zSiteOptionGroupLastFormID)).hide();
		if(zSiteOptionGroupLastFormID != ""){
			$("#"+zSiteOptionGroupLastFormID+" input, #"+zSiteOptionGroupLastFormID+" textarea, #"+zSiteOptionGroupLastFormID+" select").bind("change", function(){
				if(zGetFormFieldDataById(this.id) != ""){
					$(this).closest("tr").removeClass("zFieldError");
				}
			}).bind("keyup", function(){
				if(zGetFormFieldDataById(this.id) != ""){
					$(this).closest("tr").removeClass("zFieldError");
				}
			}).bind("paste", function(){
				if(zGetFormFieldDataById(this.id) != ""){
					$(this).closest("tr").removeClass("zFieldError");
				}
			});
			zJumpToId(zSiteOptionGroupLastFormID, -50);
		}
		if(rs.success){
			var link=$("#"+zSiteOptionGroupLastFormID).attr("data-thank-you-url");
			if(link != ""){
				window.location.href=link;
			}else{
				alert("Your submission was received.");
			}
		}else{
			for(var i=0;i<rs.arrErrorField.length;i++){
				$("#"+rs.arrErrorField[i]).closest("tr").addClass("zFieldError");
			}
			alert("Please correct the following errors and submit the form again\n"+rs.errorMessage);
		}
	}
	function zSiteOptionGroupPostForm(formId){
		zSiteOptionGroupLastFormID=formId;
		$(".zSiteOptionGroupSubmitButton", $("#"+zSiteOptionGroupLastFormID)).hide();
		$(".zSiteOptionGroupWaitDiv", $("#"+zSiteOptionGroupLastFormID)).show();
		var postObj=zGetFormDataByFormId(formId);
		var obj={
			id:"ajaxSiteOptionGroup",
			method:"post",
			postObj:postObj,
			ignoreOldRequests:false,
			callback:zSiteOptionGroupCallback,
			errorCallback:zSiteOptionGroupErrorCallback,
			url:'/z/misc/display-site-option-group/ajaxInsert'
		}; 
		zAjax(obj);
	}
	/*
	function zSetupAjaxTableSortAgain(){
		if(zLastAjaxTableId !=""){
			//zSetupAjaxTableSort(zLastAjaxTableId, zLastAjaxURL, zLastAjaxVarName);
		}
	}*/
	function zSetupAjaxTableSort(tableId, ajaxURL, ajaxVarName){
		/*zLastAjaxTableId=tableId;
		zLastAjaxURL=ajaxURL;
		zLastAjaxVarName=ajaxVarName;*/

		var validated=true;
		var arrError=[];
		zAjaxSortURLCache[tableId]={
			url:ajaxURL
			/*,
			cache:$("#"+tableId).html()*/
		};
		if($( '#'+tableId).length == 0){
			validated=false; 
			return;
		}
		if($( '#'+tableId+' thead' ).length == 0){
			validated=false;
			arrError.push('queueSortCom.ajaxTableId is set to "'+tableId+'", but this table is missing the <thead> tag around the header rows, which is required for table row sorting to function.');
		}
		if($( '#'+tableId+' tbody' ).length == 0){
			validated=false;
			arrError.push('queueSortCom.ajaxTableId is set to "'+tableId+'", but this table is missing the <tbody> tag around the body rows, which is required for table row sorting to function.');
		}
		$( '#'+tableId+' tbody tr' ).each(function(){
			if(this.id == '' || ($("."+tableId+"_handle").length && $("."+tableId+"_handle")[0].getAttribute('data-ztable-sort-primary-key-id') == '')){
				validated=false;
			}
		}); 
		if(validated){
			$('#'+tableId+' tbody' ).sortable({
				handle: '.'+tableId+'_handle',
				stop:function(e, e2){
					var arrId=$("#"+tableId+" tbody").sortable("toArray");
					var arrId2=[]; 
					for(var i=0;i<arrId.length;i++){
						var v=$("#"+arrId[i]+" ."+tableId+"_handle").attr("data-ztable-sort-primary-key-id");
						if(!isNaN(v)){
							var id=parseInt(v);
							arrId2.push(id);
						}
					}
					var sortOrderList=arrId2.join("|");
					//console.log("sorted list:"+sortOrderList);
					var tempObj={};
					tempObj.id="zAjaxChangeSortOrder";
					var u=zAjaxSortURLCache[tableId].url;
					if(u.indexOf("?") != -1){
						tempObj.url=u+"&"+ajaxVarName+"="+escape(sortOrderList);
					}else{
						tempObj.url=u+"?"+ajaxVarName+"="+escape(sortOrderList);
					}
					tempObj.callback=function(r){
						var d=eval('('+r+')');
						if(!d.success){
							//$("#"+tableId).html(zAjaxSortURLCache[tableId].cache);
							alert("Failed to sort records.");
						}else{
							zAjaxSortURLCache[tableId].cache=$("#"+tableId).html();
						}
					};
					tempObj.errorCallback=function(){
						//$("#"+tableId).html(zAjaxSortURLCache[tableId].cache);
						alert("Failed to sort records.");
					};
					tempObj.cache=false; 
					tempObj.ignoreOldRequests=false;
					zAjax(tempObj);
				}
			});
		}else{
			arrError.push('Each <tr> row must have a unique id attribute and a data-ztable-sort-primary-key-id attribute with the value set to the primary key id for the current record.');
		}
		if(arrError.length){
			alert(arrError.join("\n"));
		}
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
	function zGetFormFieldDataById(id){
		var field=$("#"+id);
		if(field.length){
			var f=field[0];
			if(f.type === 'checkbox' || f.type === 'radio'){
				return $("input[name="+f.name+"]:checked").map(function() {return f.value;}).get().join(','); 
			}else if(field[0].type.substr(0, 6) === 'select'){
				return $("select[name="+f.name+"]").map(function() {return f.value;}).get().join(','); 
			}else if(f.type === 'textarea'){
				return $("textarea[name="+f.name+"]").map(function() {return f.value;}).get().join(','); 
			}else{
				return $("input[name="+f.name+"]").map(function() {return f.value;}).get().join(','); 
			}
		}else{
			return "";
		}
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
					if(!zIsDeveloper()){
						alert("Invalid response.  You may need to login again or refresh the page.");
					}else{
						alert("zAjax() Error: The following ajax URL MUST output the x_ajax_id as an http header.\n"+zAjaxData[obj.id].url);	
					}
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
					var tempLastV=parseFloat(lastV.split(",").join("").split("$").join(""));
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
				var d4=document.getElementById(paramObj.constrainObj);
				d4.style.zIndex=1;
				obj.style.zIndex=3;
				if(rightSlider){
					var dx=sw-(dw+parseInt(d4.style.marginLeft));
				}else{
					var dx=sw-(dw+parseInt(d4.style.marginRight));
				}
				var d5=zDrag_getPosition(d4);
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
			var percent=0;
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
			var offset=Math.min(arrLabel.length-1,Math.round(percent*(arrLabel.length-0.5)));
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


	function zOS_mode_check(){
		if(document.zOS_mode_form.zOS_modeVarDumpName){
			if(document.zOS_mode_form.zOS_modeVarDumpName.value.length !== 0){
				document.zOS_mode_form.zOS_mode.value = 'varDump';
				document.zOS_mode_form.zOS_modeValue.value = 'true';					
			}
		}
		return true;
	}
	function zOS_mode_submit(mode, value, value2, value3){
		var theform=document.getElementById("zOS_mode_form");
		var theaction=theform.getAttribute("action");
		if(mode === 'viewMeta'){
			document.getElementById("zOS_modeVarDumpName").value = 'request.zos.templateData.tagContent';
			mode = 'varDump';
		}
		if(typeof value3 === "undefined"){ value3=""; }
		document.getElementById("zOS_mode").setAttribute("value", mode);
		document.getElementById("zOS_modeValue").setAttribute("value", value);
		if(mode === 'viewAsXML'){
			theaction=zURLAppend(theaction, 'zOS_viewAsXML=1'+value3);
		}
		if(mode === 'validateXHTML' && value2 !== "undefined"){
			theaction=zURLAppend(theaction, 'zOS_viewXHTMLError=1'+value3);
		}
		if(mode === 'reset'){
			theaction=zURLAppend(theaction, 'zReset='+value2+value3);
		}
		theform.setAttribute("action", theaction);
		theform.submit();
	}
	function zOS_mode_status(){
		window.status = 'Warning: All variables will be reposted.';
	}
	function zOS_mode_status_off(){
		window.status = '';
	}
	function zOS_mode_hide(){
		var el = document.getElementById("zOS_mode_table_tag");
		el.style.display='none';
	}
	function zOS_mode_show(){
		var el = document.getElementById("zOS_mode_table_tag");
		el.style.display='block';
	}
	window.zUpdateImageLibraryCount=zUpdateImageLibraryCount;
	window.ajaxSaveSorting=ajaxSaveSorting;
	window.ajaxSaveImage=ajaxSaveImage;
	window.toggleImageCaptionUpdate=toggleImageCaptionUpdate;
	window.confirmDeleteImageId=confirmDeleteImageId;
	window.deleteImageId=deleteImageId;
	window.setUploadField=setUploadField;
	window.zSiteOptionGroupErrorCallback=zSiteOptionGroupErrorCallback;
	window.zSiteOptionGroupCallback=zSiteOptionGroupCallback;
	window.zSiteOptionGroupPostForm=zSiteOptionGroupPostForm;
	window.zSetupAjaxTableSort=zSetupAjaxTableSort;
	window.zGetFormDataByFormId=zGetFormDataByFormId;
	window.zGetFormFieldDataById=zGetFormFieldDataById;
	window.zDisableEnter=zDisableEnter;
	window.zKeyboardEvent=zKeyboardEvent;
	window.zInputHideDiv=zInputHideDiv;
	window.zFormOnKeyUp=zFormOnKeyUp;
	window.zFormOnChange=zFormOnChange;
	window.zFormSetError=zFormSetError;
	window.zAjax=zAjax;
	window.zFormSubmit=zFormSubmit;
	window.zInputSlideOnChange=zInputSlideOnChange;
	window.zSetSliderInputArray=zSetSliderInputArray;
	window.zSliderInputResize=zSliderInputResize;
	window.zInputSliderSetValue=zInputSliderSetValue;
	window.zInputSlideLimit=zInputSlideLimit;
	window.zExpOptionSetValue=zExpOptionSetValue;
	window.zCheckboxOnChange=zCheckboxOnChange;
	window.zMotionOnMouseDown=zMotionOnMouseDown;
	window.zMotiontoggleSlide=zMotiontoggleSlide;
	window.zMotionslidedown=zMotionslidedown;
	window.zMotionslideup=zMotionslideup;
	window.zMotionstartslide=zMotionstartslide;
	window.zMotionslidetick=zMotionslidetick;
	window.zMotionendSlide=zMotionendSlide;
	window.zCLink=zCLink;
	window.zSetInput=zSetInput;
	window.zFormOnEnterAdd=zFormOnEnterAdd;
	window.zFormOnEnter=zFormOnEnter;
	window.zInputRemoveOption=zInputRemoveOption;
	window.zHasInnerText=zHasInnerText;
	window.zInputSetSelectedOptions=zInputSetSelectedOptions;
	window.zOS_mode_check=zOS_mode_check;
	window.zOS_mode_submit=zOS_mode_submit;
	window.zOS_mode_status=zOS_mode_status;
	window.zOS_mode_status_off=zOS_mode_status_off;
	window.zOS_mode_hide=zOS_mode_hide;
	window.zOS_mode_show=zOS_mode_show;
	//window.zSetupAjaxTableSortAgain=zSetupAjaxTableSortAgain;

})(jQuery, window, document, "undefined"); 