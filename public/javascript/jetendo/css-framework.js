
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
			"992":[{
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
	// if data-children-class is specified, the equal heights will be performed on the elements matching the class instead of the children of the container.
	function zForceChildEqualHeights(children){  
		var lastHeight=0; 
		$(children).height("auto");
		$(children).each(function(){  
			var height=$(this).height(); 
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
			var childrenClass=$(this).attr("data-children-class");
			if(childrenClass==null || childrenClass == ""){
				childrenClass="";
			}
			var singleColumnWidth=$(this).attr("data-single-column-width");
			if(singleColumnWidth==null || singleColumnWidth == ""){
				singleColumnWidth=479;
			}
			var columnCount=$(this).attr("data-column-count");
			if(columnCount==null || columnCount == ""){
				columnCount=0;
			}
			columnCount=parseInt(columnCount);
			if(childrenClass!=""){
				var children=$(childrenClass, this);
			}else{
				var children=$(this).children();
			} 
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
					columnChildren[0].images.push(this);
					if(this.complete){
						columnChildren[0].imagesLoaded++;
					}
				});
			}else{
				var count=0;
				var currentOffset=0; 
				for(var i=0;i<children.length;i++){
					if(typeof columnChildren[currentOffset] == "undefined"){
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
 

	function setupMobileMenu() {
		if($(".z-mobileMenuButton").length==0){
			return;
		}
		function toggleMenu(e){  
			e.preventDefault();
			var className=$(".z-mobileMenuDiv").attr("data-open-class"); 
			if(className != null){  
				$(".z-mobileMenuDiv").toggleClass(className);
			}else{
				$(".z-mobileMenuDiv").slideToggle("fast");
			}
			return false;
		}
		function hideMenu(){
			var isVisible=false;
			var className=$(".z-mobileMenuDiv").attr("data-open-class"); 
			if(className != null){  
				if($(".z-mobileMenuDiv").hasClass(className)){
					$(".z-mobileMenuDiv").removeClass(className);
					$(".z-mobileMenuDiv").hide();
				}
			}else{
				if($(".z-mobileMenuDiv").is(":visible")){
					$(".z-mobileMenuDiv").hide();
				}
			}
		}
		$(".z-mobileMenuButton").bind("click", toggleMenu);
		$(document).bind("click", function(e){
			if(!zMouseHitTest($(".z-mobileMenuDiv")[0], 0)){
				var isVisible=false;
				var className=$(".z-mobileMenuDiv").attr("data-open-class"); 
				if(className != null){  
					if($(".z-mobileMenuDiv").hasClass(className)){
						e.preventDefault();
						$(".z-mobileMenuDiv").removeClass(className);
					}
				}else{
					if($(".z-mobileMenuDiv").is(":visible")){
						e.preventDefault();
						$(".z-mobileMenuDiv").hide();
					}
				}
			}
		});
		function fixMenu(){
			var w=zWindowSize.width+zScrollbarWidth;
			if(w>=992){

				$(".z-mobileMenuDiv").removeClass("z-transition-all");
				$(".z-mobileMenuDiv").hide();
				hideMenu();
			}else if(w>=768 && w<=992){
				$(".z-mobileMenuDiv").removeClass("z-transition-all");
				hideMenu();
				$(".z-mobileMenuDiv").show();
			}else{
				$(".z-mobileMenuDiv").addClass("z-transition-all");
			}
		}
		zArrResizeFunctions.push({functionName: fixMenu});
		fixMenu();

	}
	zArrDeferredFunctions.push(setupMobileMenu);
 

	zArrDeferredFunctions.push(function(){
		var arrOriginalMenuButtonWidth=[];
		function setEqualWidthMobileMenuButtons(containerDivId, marginSize){ 
			$("#"+containerDivId+" nav").css("visibility", "visible");  
			if(typeof arrOriginalMenuButtonWidth[containerDivId] === "undefined"){
				zArrResizeFunctions.push(function(){ setEqualWidthMobileMenuButtons(containerDivId, marginSize); });
			}
			arrOriginalMenuButtonWidth[containerDivId]={
				ul:$("#"+containerDivId+" > nav "),
				arrLI:$("#"+containerDivId+" > nav > div"),
				arrItem:$("#"+containerDivId+" > nav > div > a"),
				arrItemWidth:[],
				arrItemBorderAndPadding:[],
				containerWidth:	0,
				navWidth:0,
				marginSize:marginSize
			};
			var columnGap=$("#"+containerDivId).attr("data-column-gap");
			if(columnGap==null){
				columnGap=20;
			}else{
				columnGap=parseInt(columnGap);
			}
			var equalDisabled=false;
			var currentMenu=arrOriginalMenuButtonWidth[containerDivId]; 
			for(var i=0;i<currentMenu.arrItem.length;i++){ 
				if(zWindowSize.width+zScrollbarWidth <768){
					equalDisabled=true;
					$("#"+containerDivId).width("auto");
					$(currentMenu.arrItem[i]).parent().css({
						"width":"auto",
						"min-width":"auto",
						"float":"left",
						"display":"block",
						"text-align":"left"
					});
					$(currentMenu.arrItem[i]).css({
						"width":"auto",
						"min-width":"auto",
						"display":"inline-block",
						"text-align":"left"
					});

					continue;
				}else{
					$(currentMenu.arrItem[i]).parent().css({
						"width":"auto",
						"min-width":"auto",
						"float":"none",
						"display":"inline-block",
						"text-align":"center"
					});
					$(currentMenu.arrItem[i]).css({
						"width": "auto",
						"min-width":"1px", 
						"float":"left",
						"text-align":"center"
					});
				}
				$(currentMenu.arrItem[i]).css({
					"margin-right": "0px"
				});
			}
			$(currentMenu.arrLI).each(function(){ $(this).css("margin-right", "0px"); });

			var sLen=currentMenu.arrItem.length;
			for(var i=0;i<sLen;i++){ 
				var jItem=$(currentMenu.arrItem[i]);
	 			jItem.width("auto");
	 			//console.log("new auto width:"+jItem.width());
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
				if(jItem.css("box-sizing") == "border-box"){
					curBorderAndPadding=0;
				}
				//console.log("borpad:"+curBorderAndPadding+":"+borderLeft+":"+borderRight+":"+curWidth+":"+jItem.width()+":"+(jItem.css("padding-left"))+":"+(jItem.css("padding-right"))+":"+jItem.css("border-left-width")); 
				$(jItem).css({
					"padding-left":"0px",
					"padding-right":"0px"
				}); 
				if(i===sLen-1){
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
					//console.log(curWidth+marginSize+curBorderAndPadding);
				}else{
					$(jItem).css({
						"margin-right": currentMenu.marginSize+"px",
						"width": curWidth
					}); 
					currentMenu.navWidth+=curWidth+marginSize+curBorderAndPadding+columnGap;
					//console.log(curWidth+marginSize+curBorderAndPadding);
				}
				currentMenu.arrItemBorderAndPadding.push(curBorderAndPadding);
				currentMenu.arrItemWidth.push(curWidth);
			} 
			if(equalDisabled){
				$("#"+containerDivId+" nav").css("visibility", "visible");
				return;
			} 
			//console.log(currentMenu.navWidth);
	 
			//console.log(currentMenu.marginSize);
			//currentMenu.ul.detach(); 
			//console.log(containerDivId+":"+"containerWidth:"+$("#"+containerDivId).width());
			$("#"+containerDivId).width("100%");
			currentMenu.containerWidth=$("#"+containerDivId).width()-1;
			//console.log(currentMenu.containerWidth+":"+currentMenu.navWidth+":"+currentMenu.marginSize);
			//return;
			var totalWidth = currentMenu.containerWidth;//-2;
			var navWidth = 0;
			var deltaWidth = totalWidth - (currentMenu.navWidth);// + currentMenu.marginSize);
			var padding = Math.floor((deltaWidth / currentMenu.arrItem.length) / 2);// - (currentMenu.marginSize/2); 
			var floatEnabled=false;
			/*if(totalWidth<currentMenu.navWidth + ((currentMenu.arrItem.length-1)*currentMenu.marginSize)){
				//padding=0;
				floatEnabled=true;
				$(currentMenu.arrLI).each(function(){ $(this).css("display", "block"); });
			}else{
				if($.browser.msie && $.browser.version <= 7){
					$(currentMenu.arrLI).each(function(){ $(this).css("display", "inline"); });
				}else{
					$(currentMenu.arrLI).each(function(){ $(this).css("display", "inline-block"); });
				} 
			} */
			//console.log(containerDivId+":"+"marginSize:"+currentMenu.marginSize+" containerWidth:" +currentMenu.containerWidth+" totalWidth:"+totalWidth+" navWidth:"+currentMenu.navWidth+" deltaWidth:"+deltaWidth+" padding:"+padding);
			var totalWidth2=0;
			var sLen=currentMenu.arrItem.length;

			for(var i=0;i<sLen;i++){ 
				
				if(currentMenu.navWidth> zWindowSize.width+zScrollbarWidth){
					var curWidth=currentMenu.arrItemWidth[i]+columnGap;
				}else{
					var curWidth=currentMenu.arrItemWidth[i];//+columnGap;
				}
				//console.log(padding);
				//$(currentMenu.arrItem[i]).width(curWidth-20);
				var newWidth=Math.floor(curWidth+(padding*2)); 
	 
				var addWidth=Math.max(curWidth, newWidth);
				newWidth=(newWidth/currentMenu.containerWidth);
				curWidth=(curWidth/currentMenu.containerWidth);
	 			newWidth=(Math.round(newWidth*100000)/1000)-0.001;
	 			curWidth=(Math.round(curWidth*100000)/1000)-0.001; 
				if(sLen-1 == i){
					
					newWidth=(currentMenu.containerWidth-totalWidth2);
		 			addWidth=newWidth;
		 			newWidth=newWidth/currentMenu.containerWidth;
		 			newWidth=(Math.round(newWidth*100000)/1000)-0.001;
		 			if(newWidth<curWidth){
		 			//	newWidth=curWidth;
		 			}
		 			curWidth=newWidth;


					$(currentMenu.arrItem[i]).parent().css({
						"width": (newWidth)+"%",
						"min-width":(curWidth)+"%"
					});
					$(currentMenu.arrItem[i]).css({
						"width": (100)+"%",
						"min-width":(100)+"%" 
					});
				}else{
					$(currentMenu.arrItem[i]).parent().css({
						"width": (newWidth)+"%",
						"min-width":(curWidth)+"%", 
						"margin-right":marginSize+"px"
					});
					$(currentMenu.arrItem[i]).css({
						"width": (100)+"%",
						"min-width":(100)+"%" 
					});
						
				}
				totalWidth2+=Math.round(addWidth+marginSize);
			} 
			$("#"+containerDivId).append(currentMenu.ul);
			$("#"+containerDivId+" nav").css("visibility", "visible");
		}
		var uniqueMenuId=1;
		$(".z-mobileMenuDiv").each(function(){
			if(this.id == null || this.id == ""){
				this.id="zMobileMenuDiv"+uniqueMenuId;
				uniqueMenuId++;
			}
			setEqualWidthMobileMenuButtons(this.id, 0);
		});
		
	});

})(jQuery, window, document, "undefined"); 
