// used on curriproperties.net and windermerehomes.net new design
(function($, window, document){
	var arrListingTab=[];
	var itemCount=0;
	var curOffset=0;
	var curTimeout=0;
	var startSlide=0;
	var cycleOptions=0;
	var slidePanel0=0;
	var slidePanel1=0;
	var curTabURL="";
	var curTabOffset=0;
	var curFX='scrollLeft';
	var slideIsAnimating=false;
	function zUpdateAjaxSlides(tabOffset){
		if(slideIsAnimating){
			setTimeout(function(){ 
				zUpdateAjaxSlides(tabOffset); 
			}, 200);
			return;
		}
		curTabOffset=tabOffset;
		curTabURL=arrListingTab[curTabOffset];
		curOffset=0;
		//startSlide=0;
		clearTimeout(curTimeout);
		$.ajax({
			url: curTabURL,
			context: document.body,
			success: function(data){
				var curSlidePanel=0;
				if(startSlide===0){
					curSlidePanel=slidePanel1;
					startSlide=1;
				}else{
					curSlidePanel=slidePanel0;
					startSlide=0;
				}
				curSlidePanel.html(data);
				cycleOptions.fx='fade';
				$("#homePageListingCycleContainer").cycle("next");
				curTimeout=setTimeout(loadNextPanel, 5000);
			}
		});
	}
	function loadNextPanel(){ 
		loadListingPanel(5);
	}
	function slideAnimationDone(){
		slideIsAnimating=false;	
	}
	function zSetupAjaxCycle(newItemCount, arrNewListingTab){
		if(typeof newItemCount !== "undefined"){
			itemCount=newItemCount;
			arrListingTab=arrNewListingTab;
			slidePanel0=$("#sliderPanel0");
			slidePanel1=$("#sliderPanel1");
			$("#listingslidernext").bind("click", function(){
				console.log("next:"+slideIsAnimating);
				if(slideIsAnimating){
					return false;
				}
				loadListingPanel(5);
				return false;
			});
			$("#listingsliderprev").bind("click", function(){
				if(slideIsAnimating){
					return false;
				}
				loadListingPanel(-5);
				return false;
			});
		}
		$("#homePageListingCycleContainer").cycle({
			fx:'scrollLeft',
			timeout:0,
			pause:1,
			after: slideAnimationDone,
			before:slideAnimationBegin
		});
		//clearInterval(loadNextPanel);
		curTimeout=setTimeout(loadNextPanel, 5000);
	}
	function slideAnimationBegin(a,b,c){
		c.fx='scrollLeft';
		cycleOptions=c;
		slideIsAnimating=true;	
	}
	function listingPanelLoaded(r){
		var curSlidePanel=0;
		if(startSlide===0){
			curSlidePanel=slidePanel0;
		}else{
			curSlidePanel=slidePanel1;
		}
		curSlidePanel.html(r);
		cycleOptions.fx=curFX;
		cycleOptions.speed=300;
		if(curFX === 'scrollLeft'){
			$("#homePageListingCycleContainer").cycle("next");
		}else{
			$("#homePageListingCycleContainer").cycle("prev");
		}
		cycleOptions.speed=1000;
		curTimeout=setTimeout(loadNextPanel, 5000);
	}
	function loadListingPanel(offset){
		if(curOffset+offset < 0 || curOffset+offset >= itemCount){
			// can't go negative or above the listing count!
			return;
		}
		if(startSlide === 0){
			startSlide=1;
		}else{
			startSlide=0;
		}
		clearTimeout(curTimeout);
		curOffset+=offset;
		if(offset > 0){
			curFX='scrollLeft';	
		}else{
			curFX='scrollRight';
		}
		curTabURL=arrListingTab[curTabOffset];
		var tempObj={};
		tempObj.id="listingSlidePanelAjax";
		tempObj.url=curTabURL+"&offset="+curOffset;
		tempObj.cache=false;
		tempObj.callback=listingPanelLoaded;
		tempObj.ignoreOldRequests=false;
		zAjax(tempObj);		
	}
	window.zSetupAjaxCycle=zSetupAjaxCycle;
	window.zUpdateAjaxSlides=zUpdateAjaxSlides;
	/*
	 $.fn.ajaxCycle = function(initObject){
		 return this.each(function(){
			 
			 initObject.container=this;
			 this.zAjaxCycle=new zAjaxCycle(initObject);
		 });
	 }*/
})(jQuery, window, document);
