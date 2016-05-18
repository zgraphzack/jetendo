
(function($, window, document, undefined){
	"use strict";
 
	/*

	*/
	function zSetupBreakpointClasses(){
		$(".z-breakpoint").each(function(e){ 
			if(typeof this.arrBreakCache!="undefined"){
				var arrBreak=this.arrBreakCache;
			}else{
				var breakpoints=$(this).attr("data-breakpoints");
				if(breakpoints == null || breakpoints==""){
					return;
				}
				var arrBreak=breakpoints.split(","); 
				for(var i=0;i<arrBreak.length;i++){
					arrBreak[i]=parseInt(arrBreak[i]);
				}
				this.arrBreakCache=arrBreak;
			}
			var a=zGetAbsPosition(this.parentNode); 
			var b=10000; 
			for(var i=0;i<arrBreak.length;i++){ 
				if(arrBreak[i]>a.width){
					b=arrBreak[i];
				}
			}
			if(b!=10000){
				$(this).addClass("z-breakpoint-"+b);
				for(var i=0;i<arrBreak.length;i++){
					if(b!=arrBreak[i]){
						$(this).removeClass("z-breakpoint-"+arrBreak[i]);
					}
				}
			}
		}); 
	}
	zArrResizeFunctions.push({functionName:zSetupBreakpointClasses}); 

	/*

	*/
	function zRunNegativeMarginFit(obj, direction){
		var image;
		if(obj.tagName=="IMG"){
			if(obj.complete!=1){
				return;
			}
			image=$(obj);
		}else{
			image=$("img", obj);
			if(image.length==0){
				console.log("zForceNegativeMarginLeft and zForceNegativeMarginRight only works with images");
			}
		}
		image.width("100%");
		var width=image[0].naturalWidth;
		var parentPosition=zGetAbsPosition(obj.parentNode);
	 
		var parentWidth=Math.round($(obj.parentNode).width()); 
		if(direction=='right'){
			if(zWindowSize.width < parentPosition.x+width){
				var extraWidth=(parentPosition.x+width)-zWindowSize.width;
				width-=extraWidth+zScrollbarWidth+2; 
			}
		}else{
			if(width>parentPosition.x+parentWidth){
				var extraWidth=width-(parentPosition.x+parentWidth); 
				width-=extraWidth;  
			} 
		}
		var overflowWidth=width-parentWidth; 
	 
		image.width(width+"px"); 
		$(obj).css("margin-"+direction, -overflowWidth+"px");
	}
	function zSetupNegativeMarginFit(){
		$(".zForceNegativeMarginRight").show().bind("load", function(){
			zRunNegativeMarginFit(this, "right");
		});
		$(".zForceNegativeMarginRight").each(function(){
			if(this.complete){
				zRunNegativeMarginFit(this, "right");
			}
		});
		$(".zForceNegativeMarginLeft").show().bind("load", function(){
			zRunNegativeMarginFit(this, "left");
		});
		$(".zForceNegativeMarginLeft").each(function(){
			if(this.complete){
				zRunNegativeMarginFit(this, "left");
			}
		});
	};
	zArrResizeFunctions.push({functionName:zSetupNegativeMarginFit});

	function sortNumber(a,b) {
		return a - b;
	}
	/*

	*/
	function zSetupLazyLoadImages(){
		function setLazyLoadCache(obj){
			if(typeof obj.arrLazyLoadCache == "undefined"){
				var src=$(obj).attr("data-lazy-src");
				if(src == null){
					throw("img tag is missing data-lazy-src attribute");
				}
				var a=src.split(":");
				var arrSrc=[];
				var arrBreakpoint=[];
				var lastValue="";
				for(var i=0;i<=a.length;i++){
					if(lastValue==""){
						lastValue=a[i];
					}else{
						arrSrc[lastValue]=a[i];
						if(lastValue!="default"){
							arrBreakpoint.push(parseInt(lastValue));
						}
						lastValue="";
					}
				}
				arrBreakpoint.sort(sortNumber);
				obj.arrLazyLoadCache={arrSrc:arrSrc, arrBreakpoint:arrBreakpoint}; 
			}

		}
		/*

		backgrounds:{
			"default":[{ 
				size: "auto", 
				url: "/images/topImage.png", 
				color: "", // rgba(255,255,255,0.8) or #FFFFFF
				position: "right center", // left|right|center and/or top|center|bottom, i.e. center top or width/height values: 100px 50px
				repeat: "no-repeat", repeat (default) | repeat-x | repeat-y | no-repeat
				attachment: "scroll" scroll (default) | fixed (background stays still when main window scrolls) | local (background moves with overflow:scroll content)
			},{
				size:"cover",
				url:"/images/bottomImage.jpg",
				repeat:"repeat",
				attachment: "fixed" 
			}],
			"980":[{
				size:"auto",
				url:"/images/resize-image-test-mobile.jpg",
				color:"#666",
				position:"center top"
				repeat:"repeat"
			}]
		}
		*/ 
		var lazyBackgroundImages=$(".zLazyLoadBackgroundImage"); 
		lazyBackgroundImages.each(function(){
			if(typeof this.arrLazyLoadCache == "undefined"){
				var src=$(this).attr("data-lazy-json");
				if(src == null){
					throw("img tag is missing data-lazy-json attribute");
				}
				var j=JSON.parse(src);
				var arrSrc=[];
				var arrBreakpoint=[]; 
				for(var i in j){
					arrSrc[i]=j[i];
					if(i!="default"){
						arrBreakpoint.push(parseInt(i));
					}
				} 
				arrBreakpoint.sort(sortNumber);
				this.arrLazyLoadCache={arrSrc:arrSrc, arrBreakpoint:arrBreakpoint}; 
				this.lazyLoadLastOffset=-2;
			}
			var b=this.arrLazyLoadCache.arrBreakpoint; 
			var lastBreakpoint="default";
			var offset=-1;
			for(var i=0;i<b.length;i++){
				var bp=b[i];  
				if(zWindowSize.width<bp){
					lastBreakpoint=bp;
					offset=i;
					break;
				}
			}
			var src=this.arrLazyLoadCache.arrSrc[lastBreakpoint];
			if(typeof this.zLazyLoaded == "undefined"){ 
				$(this).css("background", "");
				this.setAttribute("data-lazy-original", src["background-image"]);
				this.zLazyLoaded=true;
				$(this).lazyload({
					threshold : 200,
					load:function(e){  
						$(this).css({
							"background-position": src["background-position"],
							"background-repeat": src["background-repeat"],
							"background-attachment": src["background-attachment"],
							"background-size": src["background-size"],
							"background-color": src["background-color"]
						});  

					}
				}); 
			}else{
				if(this.lazyLoadLastOffset != offset){
					this.lazyLoadLastOffset=offset; 
					this.style.background=src["background-image"];
					$(this).css({  
						"background-position": src["background-position"],
						"background-repeat": src["background-repeat"],
						"background-attachment": src["background-attachment"],
						"background-size": src["background-size"],
						"background-color": src["background-color"]
					}); 
				}
			}
		}); 
		var lazyImages=$("img.zLazyLoadImage"); 
		lazyImages.each(function(){
			setLazyLoadCache(this);
			var b=this.arrLazyLoadCache.arrBreakpoint; 
			var lastBreakpoint="default";
			for(var i=0;i<b.length;i++){
				var bp=b[i];  
				if(zWindowSize.width<bp){
					lastBreakpoint=bp;
					break;
				}
			}
			var src=this.arrLazyLoadCache.arrSrc[lastBreakpoint];
			if(typeof this.zLazyLoaded == "undefined"){
				this.setAttribute("data-original", src);
				this.zLazyLoaded=true;
				$(this).lazyload({
					threshold : 200,
					effect:"fadeIn"
				}); 
			}else{
				if(src==""){
					if(this.style.display=="block"){
						this.style.display="none";
					}
				}else{
					this.style.display="block";
					if(this.src!=src){
						this.src=src;
					}
				}
			}
		
		}); 
	}
	zArrResizeFunctions.push({functionName:zSetupLazyLoadImages});


	// add class="zForceChildEqualHeights" data-column-count="2" to any element and all the children will have heights made equal for each row. You can change 480 to something else with this optional attribute: data-single-column-width="768"
	function zForceChildEqualHeights(children){  
		var lastHeight=0; 
		$(children).height("auto");
		$(children).each(function(){ 
			var position=zGetAbsPosition(this);
			var height=position.height;   
			if(height>lastHeight){
				lastHeight=height;
			}
		});
		if(lastHeight == 0){
			lastHeight="auto";
		} 
		$(children).height(lastHeight); 
	} 
	function forceChildAutoHeightFix(){  
		var containers=$(".z-equal-heights");
		// if data-column-count is not specified, then we force all children to have the same height
		// we need to determine when all images are done loading and then run equal heights again for each row to ensure equal heights works correctly.
		containers.each(function(){
			var singleColumnWidth=$(this).attr("data-single-column-width");
			if(singleColumnWidth==null || singleColumnWidth == ""){
				singleColumnWidth=480;
			}
			var columnCount=$(this).attr("data-column-count");
			if(columnCount==null || columnCount == ""){
				columnCount=0;
			}
			columnCount=parseInt(columnCount);

			var children=$(this).children();
			if($(this).width()<=singleColumnWidth){
				$(children).height("auto");
				return;
			}
			var columnChildren=[];
			var columnChildrenImages=[];
			if(columnCount==0){
				columnChildren[0]={
					children:children,
					images:[],
					imagesLoaded:0
				}
				$("img", children).each(function(){
					columnChildren[currentOffset].images.push(this);
					if(this.complete){
						columnChildren[currentOffset].imagesLoaded++;
					}
				});
			}else{
				var count=0;
				var currentOffset=0;
				console.log(children);
				for(var i=0;i<children.length;i++){
					if(count==0){
						columnChildren[currentOffset]={
							children:[],
							images:[],
							imagesLoaded:0
						} 
					}
					columnChildren[currentOffset].children.push(children[i]);
					$("img", children[i]).each(function(){
						columnChildren[currentOffset].images.push(this);
						if(this.complete){
							columnChildren[currentOffset].imagesLoaded++;
						}
					});
					count++;
					if(count>=columnCount){
						count=0;
						currentOffset++;
					}
				}  
			} 
			for(var i=0;i<columnChildren.length;i++){
				var c=columnChildren[i]; 
				if(c.images.length){  
					var images=$(c.images); 
					if(c.imagesLoaded != images.length){
						images.bind("load", function(e){
							c.imagesLoaded++;
							if(c.imagesLoaded>images.length){ 
								zForceChildEqualHeights(c.children);  
							}
						});
					}
				}
				zForceChildEqualHeights(c.children); 
			}
		}); 
		if($(".z-equal-height").length > 0){
			console.log("The class name should be z-equal-heights, not z-equal-height");
		}
	}
	zArrResizeFunctions.push({functionName:forceChildAutoHeightFix });
 
})(jQuery, window, document, "undefined"); 
