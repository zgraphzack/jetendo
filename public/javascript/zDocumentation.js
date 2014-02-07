function copyToClipboard (text) {
	zShowModal('<div style="width:100%; float:left;"><h3>Copy the textarea below by pressing Ctrl+C or Command+C on Mac, then close this popup window.</h3><p><textarea name="copyClipboardTextarea1" id="copyClipboardTextarea1" cols="60" rows="10">'+text+'</textarea></p></div>',{'width':509,'height':331});
	document.getElementById('copyClipboardTextarea1').select();
}
function doResponsiveCheck() {		
	/*if(Response.band(0,620) || zIsTouchscreen()){
		//console.log("620 touch");
	}*/
	//return;
	if(zMSIEVersion != -1 && zMSIEVersion <= 8){
		return;	
	}
	if(Response.band(0,740)){
		//console.log("<620");
		/*	var h=d1.height();
			var d=$(".sh-31").css("margin-top",(h+20)+"px").position();
			d1.css("position","absolute").css("top",(d.top)+"px");
			
		zMegaMenuMobileDisabled=true;*/
		$("#github-fork-link").css("display","none");	
		$("#header-tagline").css("display","none");	
		$(".zdoc-section-box").css({"width": "95%", "margin-top": "0px", "margin-left":"0px"});
		$(".main-content-inner").css("padding-top", "70px");
		$(".zdoc-main-column").css("width", "95%");
		//$("h1 #zContentTransitionTitleSpan").css("padding-top", "65px");
		
	}else if(Response.band(741,960)){
		$("#github-fork-link").css("display","block");
		$("#jmainmenu ul a ul").css("visibility","visible");
		$("#header-tagline").css("display","none");	
			
			
		//$("h1 #zContentTransitionTitleSpan").css("padding-top", "35px");
		$(".main-content-inner").css("padding-top", "35px");
		$(".zdoc-section-box").css({"width": "95%", "margin-top": "0px", "margin-left":"0px"});
		$(".zdoc-main-column").css("width", "95%");
	}else{
		//$("h1 #zContentTransitionTitleSpan").css("padding-top", "35px");
		$("#github-fork-link").css("display","block");
		$("#header-tagline").css("display","block");	
		$(".main-content-inner").css("padding-top", "35px");
		$(".zdoc-section-box").css({"width": "200px", "margin-top": "0px", "margin-left":"20px"});
		$(".zdoc-main-column").css("width", (Math.min(1190,zWindowSize.width)-295)+"px");
		//console.log(">=620");
		/*zMegaMenuMobileDisabled=false;
		$(".sh-31").css("margin-top","0px");
		d1.css("position","relative").css("top","0px");
		*/
	}
}  


function pageChangeCallback(newUrl){
	if(zMSIEVersion != -1 && zMSIEVersion <= 8){
		window.location.href=newUrl;
		return;	
	}
	if(zMSIEVersion != -1 && zMSIEVersion <= 7){
		$("#disqus_thread").hide();
	}else{
		if(newUrl == "/support/forum/index" || newUrl =="/z/misc/inquiry/index" || newUrl == "/"){
			$("#disqus_thread").hide();
		}else{
			$("#disqus_thread").show();
			try{
				var d=window.location.href.substr(0, window.location.href.substr(10).indexOf("/")+10);
				//console.log(newUrl+":"+window.location.href);
				if(typeof DISQUS != "undefined"){
					DISQUS.reset({
					  reload: true,
					  config: function () {  
						  if(typeof console != "undefined"){
							console.log("Disqus reloaded: "+newUrl);
						  }
						this.page.identifier = newUrl;  
						this.page.url = d+newUrl;
					  }
					});
				}
			}catch(e){
				console.log(e);	
			}
		}
	}
	zContentTransition.manuallyProcessTransition();
}

function makeCodePretty(){
	$(".zdoc-toggle-ul").bind("click", function(e){ $('ul', e.target.parentNode).toggle(200);return false; });
	if(zMSIEVersion != -1 && zMSIEVersion <= 8){
		return;
	}
	var codeElements = document.getElementsByTagName('code');
	codeElementCount = codeElements.length;
	//console.log(codeElementCount);
	e = document.createElement('i');
	if(e.style.tabSize !== '' && e.style.mozTabSize !== '' && e.style.oTabSize !== '') {
		for(var i = 0; i < codeElementCount; i++) {
			codeElements[i].innerHTML = codeElements[i].innerHTML.replace(/\t/g,'<span class="zdoc-tab">&##9;</span>');
		}
	}
	if(typeof prettyPrint != "undefined"){
		prettyPrint(); 
	}
} 
zArrDeferredFunctions.push(function(){
	var newUrl=window.location.href.substr(window.location.href.substr(10).indexOf("/")+10);
	if(zMSIEVersion != -1 && zMSIEVersion <= 7){
		$("#disqus_thread").hide();
	}else{
		if(newUrl == "/support/forum/index" || newUrl =="/z/misc/inquiry/index" || newUrl == "/"){
			$("#disqus_thread").hide();
		}else{
			$("#disqus_thread").show();
		}
	}
	if(zMSIEBrowser != -1 && zMSIEVersion <= 7){
		setTimeout(zContentTransition.disable,500);
		//zContentTransition.arrIgnoreURLs=["/"];
	}else{
		//zContentTransition.arrIgnoreURLs=["/"];
		zContentTransition.processManually=true;
		zContentTransition.bind(pageChangeCallback);
	}
	if(zMSIEVersion != -1 && zMSIEVersion <= 8){
		return;
	}
	$(window).bind("clientresize",doResponsiveCheck);
	$(window).bind("resize",doResponsiveCheck);
	Response.crossover(doResponsiveCheck, 'width');
	Response.create({ mode: 'markup', prefix: 'r', breakpoints: [0,621,861] });
	doResponsiveCheck();
	$(".zdoc-section-box").show();
	setTimeout(doResponsiveCheck, 20);
});
zArrLoadFunctions.push({"functionName":doResponsiveCheck});
zArrLoadFunctions.push({"functionName":makeCodePretty});
