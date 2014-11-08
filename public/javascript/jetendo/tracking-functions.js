
(function($, window, document, undefined){
	"use strict";


	function zSetupClickTrackDisplay(){
		$(".zClickTrackDisplayValue").bind("click", zClickTrackDisplayValue);
		$(".zClickTrackDisplayURL").bind("click", zClickTrackDisplayURL);
	}		
	function zClickTrackDisplayValue(){
		var postValue=this.getAttribute("data-zclickpostvalue");
		var eventCategory=this.getAttribute("data-zclickeventcategory");
		var eventLabel=this.getAttribute("data-zclickeventlabel");
		var eventAction=this.getAttribute("data-zclickeventaction");
		var eventValue=this.getAttribute("data-zclickeventvalue");
		
		zTrackEvent(eventCategory, eventAction, eventLabel, eventValue, '', false);
		if(postValue != ""){
			this.parentNode.innerHTML=postValue;
		}
		return false;
	}
	function zClickTrackDisplayURL(){
		var postValue=this.getAttribute("data-zclickpostvalue");
		var eventCategory=this.getAttribute("data-zclickeventcategory");
		var eventLabel=this.getAttribute("data-zclickeventlabel");
		var eventAction=this.getAttribute("data-zclickeventaction");
		var eventValue=this.getAttribute("data-zclickeventvalue");
		var newWindow=false;
		if(this.target == "_blank"){
			newWindow=true;
		}
		zTrackEvent(eventCategory, eventAction, eventLabel, eventValue, postValue, newWindow);
		if(this.target == "_blank"){
			return true;
		}else{
			return false;
		}
	}
	function zTrackEvent(eventCategory,eventAction, eventLabel, eventValue, gotoToURLAfterEvent, newWindow){
		// detect when google analytics is disabled on purpose to avoid running this.
		if(typeof zVisitorTrackingDisabled != "undefined"){
			if(gotoToURLAfterEvent != ""){
				setTimeout(function(){
					if(!newWindow){
						window.location.href = gotoToURLAfterEvent;
					}
				}, 100);
			}
			return; 
		}
			if(typeof window['GoogleAnalyticsObject'] != "undefined"){
				var b=eval(window['GoogleAnalyticsObject']);
				if(gotoToURLAfterEvent != ""){
					if(eventLabel != ""){
						b('send', 'event', eventCategory, eventAction, eventLabel, eventValue, {'hitCallback': function(){if(!newWindow){window.location.href = gotoToURLAfterEvent;}}});
					}else{
						b('send', 'event', eventCategory, eventAction, {'hitCallback': function(){if(!newWindow){window.location.href = gotoToURLAfterEvent;}}});
					}
				}else{
					if(eventLabel != ""){
						b('send', 'event', eventCategory, eventAction, eventLabel, eventValue);
					}else{
						b('send', 'event', eventCategory, eventAction);
					}
				}
			}else if(typeof pageTracker != "undefined" && typeof pageTracker._trackPageview != "undefined"){
				if(eventLabel != ""){
					pageTracker._trackEvent(eventCategory, eventAction, eventLabel, eventValue);
				}else{
					pageTracker._trackEvent(eventCategory, eventAction);
				}
				if(gotoToURLAfterEvent != ""){
					setTimeout(function(){ 
						if(!newWindow){
							window.location.href = gotoToURLAfterEvent;
						}
					}, 500);
				}
			}else if(typeof _gaq != "undefined" && typeof _gaq.push != "undefined"){
				if(gotoToURLAfterEvent != ""){
					_gaq.push(['_set','hitCallback',function(){
						if(!newWindow){
							window.location.href = gotoToURLAfterEvent;
						}
					}]);
				}
				if(eventLabel != ""){
					_gaq.push(['_trackEvent', eventCategory, eventAction, eventLabel, eventValue]);
				}else{
					_gaq.push(['_trackEvent', eventCategory, eventAction]);
				}
			}else{
				if(zIsLoggedIn()){
					if(!newWindow){
						window.location.href = gotoToURLAfterEvent;
					}
				}else{
					throw("Google analytics tracking code is not installed, or is using different syntax. Event tracking will not work until this is correct.");
				}
				//alert("Google analytics tracking code is not installed, or is using different syntax. Event tracking will not work until this is correct.");
			}
		/*try{
		}catch(e){
			if(zIsLoggedIn()){
				if(!newWindow){
					window.location.href = gotoToURLAfterEvent;
				}
			}else{
				//throw("Google analytics tracking code is not installed, or is using different syntax. Event tracking will not work until this is correct.");
			}
		}*/
	}
	zArrLoadFunctions.push({functionName:zSetupClickTrackDisplay});
	window.zSetupClickTrackDisplay=zSetupClickTrackDisplay;
	window.zTrackEvent=zTrackEvent;
	window.zClickTrackDisplayURL=zClickTrackDisplayURL;
	window.zClickTrackDisplayValue=zClickTrackDisplayValue;
	window.zSetupClickTrackDisplay=zSetupClickTrackDisplay;
})(jQuery, window, document, "undefined"); 