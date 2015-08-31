
(function($, window, document, undefined){
	"use strict";
	
var zResponsiveHTML=function(options){
	var self=this;
	var currentStylesheet=0;
	var styleIndex=1;	
	var ruleIndex=0;
	var containerPos=0;

	var nodeIdOffset=0;
	var arrNode=[];
	var arrRules=[];
	if(typeof options === undefined){
		options={};
	}
	options.container=zso(options, 'container', false, document.body); 
	options.resizeFonts=zso(options, 'resizeFonts', false, true);
	options.resizeBoxes=zso(options, 'resizeBoxes', false, true);
	options.resizeMargin=zso(options, 'resizeMargin', false, true);
	options.resizePadding=zso(options, 'resizePadding', false, true);
	options.primaryStylesheet=zso(options, 'primaryStylesheet', false, true);
	options.classPrefix=zso(options, 'classPrefix', false, "sh-");
	options.type=zso(options, 'type', false, "tablet");
	options.originalWidth=zso(options, 'originalWidth', false, 1200);
	options.newWidth=zso(options, 'newWidth', false, 960);
	options.boxObj=zso(options, 'boxObj', false,{
		maxVerticalPadding:25,
		maxHorizontalPadding:10,
		maxVerticalMargin:20,
		maxHorizontalMargin:0
	});
	options.fontObj=zso(options, 'fontObj', false, {
		maxFontSize:25,
		minFontSize:13,
		headingFontSizeThreshold:20,
		headingRatio:0.7, // percent amount to reduce heading font
		bodyRatio:0.9 // percent amount to reduce body text font
	});

function getStyleByNode(node) {
  var styles = {};
  var rules = node.ownerDocument.defaultView.getMatchedCSSRules(node, '');

  var i = rules.length;
  while (i--) {
    merge(styles, rules[i].style)
  }
  merge(styles, node.style);

  return styles;

  function merge(obj, style) {
    var i = style.length;
    while(i--) {
      var name = style[i];
      obj[name] = style.getPropertyCSSValue(name);
    }
  }
}

	function getElementStyleById(id) {
		return getElementStyle(document.getElementById(id));
	}
	function getElementStyle(node) {
		var styles = {}; 
		var rules = window.getComputedStyle(node, ''); 
		var arrFilter=["display", "margin", "max-width", "min-width", "min-height", "max-height", "padding", "width", "height", "background-color", "background-image", "float", "top", "left", "right", "bottom", "position", "margin-left", "margin-right", "margin-top", "margin-bottom", "padding-left", "padding-bottom", "padding-top", "padding-right", "border", "border-left", "border-top", "border-right", "border-bottom", "font-size", "line-height"];
		for(var i=0;i<rules.length;i++){ 
			for(var n=0;n<arrFilter.length;n++){
				if(typeof rules[arrFilter[n]] != "undefined"){
					var a=rules[arrFilter[n]];
					if(a != "" && a != "0px" && a != "none" && a != "auto" && a != "static"){
						styles[arrFilter[n]]=a;
					}
				}
			} 
		}
		var arrFilter2=["border", "padding", "margin"];
		var arrFilter3=["left", "right", "top", "bottom"];
		for(var n=0;n<arrFilter2.length;n++){
			var a=arrFilter2[n];
			var c=0;
			for(var i=0;i<arrFilter3.length;i++){
				var a2=a+"-"+arrFilter3[i]; 
				if(typeof styles[a2] != "undefined" && styles[a2].substr(0, 3) == "0px"){
					c++;
				}
			}
			if(c == 4){
				for(var i=0;i<arrFilter3.length;i++){
					delete styles[a+"-"+arrFilter3[i]];
				}
			}
			delete styles[a];
		}  
		return styles;

	}
	function getElementStyle2(elem) {
		if (!elem) return []; // Element does not exist, empty list.
		var win = document.defaultView || window, style, styleNode = [];
		if (win.getComputedStyle) { /* Modern browsers */
			style = win.getComputedStyle(elem, '');
			for (var i=0; i<style.length; i++) {
				styleNode.push( style[i] + ':' + style.getPropertyValue(style[i]) ); 
			}
		} else if (elem.currentStyle) { /* IE */
			style = elem.currentStyle;
			for (var name in currentStyle) {
				styleNode.push( name + ':' + currentStyle[name] );
			}
		} else { /* Ancient browser..*/
			style = elem.style;
			for (var i=0; i<style.length; i++) {
				styleNode.push( style[i] + ':' + style[style[i]] );
			}
		}
		return styleNode;
	}
	function findMinSize(arr){
		var size={
			minWidth:0,
			minHeight:0
		};

		for(var i=0;i<arr.length;i++){
			if(typeof arr[i].css["min-width"] !="undefined"){
				var w=parseFloat(arr[i].css["min-width"]);
				if(w>size.minWidth){
					size.minWidth=w;
				}
			}
			if(typeof arr[i].css["min-height"] !="undefined"){
				var h=parseFloat(arr[i].css["min-height"]);
				if(h>size.minHeight){
					size.minHeight=h;
				}
			}
		}
		return size;
	}
	function findNodeMinSize(m){
		if(typeof m.css["min-width"] !="undefined"){
			var w=parseFloat(m.css["min-width"]);
			if(w>m.minWidth){
				m.minWidth=w;
			}
		}
		if(typeof m.css["min-height"] !="undefined"){
			var h=parseFloat(m.css["min-height"]);
			if(h>m.minHeight){
				m.minHeight=h;
			}
		}
		/*
		// might need to resize image based on naturalWidth/naturalHeight someday.
		if(m.node.tagName.toLowerCase() == 'img'){
			m.naturalWidth=m.node.naturalWidth;
			if(m.naturalWidth>m.minWidth){
				m.minWidth=m.naturalWidth;
			}
			m.naturalHeight=m.node.naturalHeight;
			if(m.naturalHeight>m.minHeight){
				m.minHeight=m.naturalHeight;
			}
		}*/
	}

	function getBackgroundImageDimensions(node){
		var imageSrc = node.style.backgroundImage.replace(/url\((['"])?(.*?)\1\)/gi, '$2').split(',')[0];
		var image = new Image(); 
		image.src = imageSrc;
		// TODO: need the domain and path as variable to add to beginning of relative urls

		var width = image.width;
		var height = image.height;
		if(typeof image.naturalWidth == "undefined" || image.naturalWidth === 0) {
			return {width:0, height:0, colorAverageRGB:{r:0,g:0,b:0}};
		}

		var rgb=getAverageRGB(image);
		return {width:width, height:height, colorAverageRGB:rgb};
	}
	function componentToHex(c) {
		var hex = c.toString(16);
		return hex.length == 1 ? "0" + hex : hex;
	}

	function rgbToHex(r, g, b) {
		return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b);
	}

	function getNodeSelector(node){
		var selector="";
		if(node.className == ""){
			if(node.id==""){
				nodeIdOffset++;
				node.id="zautoid"+nodeIdOffset;
			}
			if(node.tagName.toLowerCase() == "a"){
				selector="#"+node.id.trim()+":link, #"+node.id.trim()+":visited";
			}else{
				selector="#"+node.id.trim();
			}
		}else{
			var a2=node.className.split(",");
			var arrSelector=[];
			for(var f=0;f<a2.length;f++){
				if(node.tagName.toLowerCase() == "a"){
					selector="."+a2[f].trim()+":link, ."+a2[f].trim()+":visited";
				}else{
					selector="."+a2[f].trim();
				}
				arrSelector.push(selector);
			}
			selector=arrSelector.join(", ");
		}
		return selector;
	}
	
	function removeDefaultStyles(node, css){
		var s=node.getAttribute('style');
		var c=node.getAttribute('class');
		if(s != null){
			node.setAttribute('style', '');
		}
		if(c != null){
			node.setAttribute('class', '');
		}
		var css3=getElementStyle(node);
		for(var i in css3){
			if(css3[i]== css[i]){
				//console.log("deleted:"+css3[i]);
				delete css[i];
			}
		}
		if(s != null){
			node.setAttribute('style', s);
		}
		if(c != null){
			node.setAttribute('class', c);
		}
		//console.log(node);
		//console.log(css);
	}

	function extractStylesRecursively(node, skip){
		var arrChildNode=[];
		var tempIndex=0;

		if(!skip){
			var css2=getElementStyle(node);
			var parentPos=zGetAbsPosition(node);
			var cssOriginal={}
			for(var i2 in css){
				cssOriginal[i2]=css[i2];
			}
			removeDefaultStyles(node, css2); 
			//return [];
			parentPos.x-=containerPos.x;
			parentPos.y-=containerPos.y;
			var m2={
				node:node,
				css: css2,
				cssOriginal: cssOriginal,
				pos: parentPos
			};
			//console.log(m2);
			tempIndex=arrNode.length
			arrNode.push(m2);
		}

		if(node.childNodes.length){
			for(var i=0;i<node.childNodes.length;i++){
				var c=node.childNodes[i]; 
				if(c.nodeType != 1){ 
					continue;
				}
				if(c.offsetWidth == 0 && c.offsetHeight == 0){ 
					continue;
				} 
				var cs=c.style;

				var css=getElementStyle(c);
				var cssOriginal={}
				for(var i2 in css){
					cssOriginal[i2]=css[i2];
				}
				var pos=zGetAbsPosition(c);
				removeDefaultStyles(c, css); 

				// force position to be relative to container
				pos.x-=containerPos.x;
				pos.y-=containerPos.y; 
				var arrChildNode2=extractStylesRecursively(c, false);
				var size=findMinSize(arrChildNode2);
				var m={
					node:c,
					css: css,
					cssOriginal: cssOriginal,
					pos: pos,
					minWidth: size.minWidth,
					minHeight: size.minHeight
				};
				findNodeMinSize(m); 
				arrChildNode.push(m); 
			}
		}
		// TODO: detect columns


		if(!skip){
			var size=findMinSize(arrChildNode);
			m2.minWidth=size.minWidth;
			m2.minHeight=size.minHeight;
			findNodeMinSize(m2);
			arrNode[tempIndex]=m2;
		}
		return arrChildNode;

	}

	function reduceValue(cssObj, node, name, ratio){
		if(zso(node.css, name) != ""){
			if(node.css[name].indexOf("%") != -1){
				//return value;
			}else{
				cssObj[name]=Math.round(parseFloat(node.css[name])*ratio)+"px";
			}
		}
	}

	function reduceAllToWidth(arrNode, originalWidth, newWidth){
		var ow=originalWidth;
		var nw=newWidth;

		var ratio=nw/ow; 

		// to reduce 1200 to 960
			// find all background image and img, and reduce their dimensions by 80%.
			// reduce all width/height dimensions by 80% on all classes - ignore ones that are 100%.
			// reduce font-size by 20%, with minimum font-size X

		applyFontSizeRules(arrNode);
		if(!options.resizeBoxes){
			return;
		}

		for(var i=0;i<arrNode.length;i++){
			var n=arrNode[i];
			var arrRule=[];
			var cssObj={}

			reduceValue(cssObj, n, "padding-left", ratio);
			reduceValue(cssObj, n, "padding-top", ratio);
			reduceValue(cssObj, n, "padding-right", ratio);
			reduceValue(cssObj, n, "padding-bottom", ratio);
			reduceValue(cssObj, n, "margin-left", ratio);
			reduceValue(cssObj, n, "margin-top", ratio);
			reduceValue(cssObj, n, "margin-right", ratio);
			reduceValue(cssObj, n, "margin-bottom", ratio);
			
			reduceValue(cssObj, n, "left", ratio);
			reduceValue(cssObj, n, "top", ratio);
			reduceValue(cssObj, n, "right", ratio);
			reduceValue(cssObj, n, "bottom", ratio);

			reduceValue(cssObj, n, "min-width", ratio);

			if(typeof n.node == "object" && zso(n.css, 'background-image') != ""){
				var d=getBackgroundImageDimensions(n.node);
				cssObj["background-size"]="80% 80%";
				var h=rgbToHex(d.colorAverageRGB.r, d.colorAverageRGB.g, d.colorAverageRGB.b); 
				if(zso(n.css, 'background-color') == ""){
					cssObj["background-color"]=h;
				}
			} 
			if(typeof n.node == "object" && n.node.tagName.toLowerCase()=='img'){
				reduceValue(cssObj, n, "height", ratio);
				reduceValue(cssObj, n, "min-height", ratio);
				if(zso(n.css, 'width') != ""){ 
					if(n.css["width"].indexOf("%") != -1){

					}else{
						cssObj["max-width"]=Math.round(parseFloat(n.css.width))+"px";
						cssObj["width"]="100% !important"; 
						cssObj["height"]="auto !important";
					}
				} 
			}else{
				reduceValue(cssObj, n, "width", ratio); 
				if(zso(n.css, 'height') != ""){
					if(n.css["height"].indexOf("%") != -1){

					}else{
						cssObj["height"]="auto !important";
					}
				}
			}

			cleanStyle(cssObj, n);

			if(typeof n.node == "object"){
				var selector=getNodeSelector(n.node);
			}else{
				var selector=n.selector;
			}
			setRule(selector, cssObj);
			/*for(var f in cssObj){
				arrRule.push(f+":"+cssObj[f]+";");
			}
			arrRules.push(selector+"{"+ arrRule.join(" ")+"}");*/ 
 
		} 
	}


	function reduceFontSize(cssObj, node, name){
		if(zso(node.css, name) != ""){
			if(node.css[name].indexOf("%") != -1){
				//return value;
			}else{
				var unit="px";
				if(node.css[name].indexOf("rem") != -1){
					unit="rem";
				}else if(node.css[name].indexOf("em") != -1){
					unit="em";
				}else if(node.css[name].indexOf("pt") != -1){
					unit="pt";
				}
				var v=parseFloat(node.css[name]);
				if(isNaN(v)){
					return;
				}
				if(v>=options.fontObj.headingFontSizeThreshold){
					// is heading
					var nv=Math.round(options.fontObj.headingRatio*v);
				}else{
					// is body text
					var nv=Math.round(options.fontObj.bodyRatio*v);
				}
				if(unit!="em"){
					if(nv<options.fontObj.minFontSize){
						nv=13;
					}
					if(nv>options.fontObj.maxFontSize){
						nv=40;
					}
				}
				cssObj[name]=nv+unit;
			}
		}
	}
	function setRule(selector, cssObj){
		var hasProperty=false;
		for(var i in cssObj){
			hasProperty=true;
			break;
		}
		if(!hasProperty){
			return;
		}
		if(typeof arrRules[selector]== "undefined"){
			arrRules[selector]=cssObj;
		}else{
			for(var i in cssObj){
				arrRules[selector][i]=cssObj[i];
			}
		}
	}

	function applyFontSizeRules(arrNode){
		if(!options.resizeFonts){
			return;
		}

		for(var i=0;i<arrNode.length;i++){
			var n=arrNode[i];
			var arrRule=[];
			var cssObj={}

			reduceFontSize(cssObj, n, 'font-size');
			reduceFontSize(cssObj, n, 'line-height');

			if(typeof n.node == "object"){
				var selector=getNodeSelector(n.node);
			}else{
				var selector=n.selector;
			}
			setRule(selector, cssObj);
			/*for(var f in cssObj){
				arrRule.push(f+":"+cssObj[f]+";");
			}
			arrRules.push(selector+"{"+ arrRule.join(" ")+"}");*/
			// apply font size rules
				// max font-size Y
				// min font-size Z
				// fonts above X, reduce by 30%  (for headings)
				// fonts below X, reduce by 10% (for body text)
		}
	}
	function reduceBoxValue(cssObj, node, name){
		if(zso(node.css, name) != ""){
			if(node.css[name].indexOf("%") != -1){
				//return value;
			}else{
				var v=parseFloat(node.css[name]);
				if((name == "padding-left" || name == "padding-right") && v > options.boxObj.maxHorizontalPadding){
					v=options.boxObj.maxHorizontalPadding;
				}else if((name == "padding-top" || name == "padding-bottom") && v > options.boxObj.maxVerticalPadding){
					v=options.boxObj.maxVerticalPadding;
				}else if((name == "margin-left" || name == "margin-right") && v > options.boxObj.maxHorizontalMargin){
					v=options.boxObj.maxHorizontalMargin;
				}else if((name == "margin-top" || name == "margin-bottom") && v > options.boxObj.maxVerticalMargin){
					v=options.boxObj.maxVerticalMargin;
				}
				cssObj[name]=v+"px";
			}
		}
	}

	function getAverageRGB(imgEl) {
		
		var blockSize = 5, // only visit every 5 pixels
			defaultRGB = {r:0,g:0,b:0}, // for non-supporting envs
			canvas = document.createElement('canvas'),
			context = canvas.getContext && canvas.getContext('2d'),
			data, width, height,
			i = -4,
			length,
			rgb = {r:0,g:0,b:0},
			count = 0;
			
		if (!context) {
			return defaultRGB;
		}
		
		height = canvas.height = imgEl.naturalHeight || imgEl.offsetHeight || imgEl.height;
		width = canvas.width = imgEl.naturalWidth || imgEl.offsetWidth || imgEl.width;
		
		context.drawImage(imgEl, 0, 0);
		
		try {
			data = context.getImageData(0, 0, width, height);
		} catch(e) {
			alert('security error, img on diff domain: '+imgEl.src);
			return defaultRGB;
		}
		
		length = data.data.length;
		
		while ( (i += blockSize * 4) < length ) {
			++count;
			rgb.r += data.data[i];
			rgb.g += data.data[i+1];
			rgb.b += data.data[i+2];
		}
		
		// ~~ used to floor values
		rgb.r = ~~(rgb.r/count);
		rgb.g = ~~(rgb.g/count);
		rgb.b = ~~(rgb.b/count);
		
		return rgb;
		
	}


	function reduceAllToSingleColumn(arrNode){

		// to generate 320 to X width responsive CSS:
			// find widths greater then breakpoint that are no excluded via special class name like "zDisableAutorespond"
				// if height is defined, set to min-height=height and height="auto" or just height:auto; instead
					// if there is background image with naturalWidth larger then breakpoint, might want to set background:none.   We could also determine average image color as an idea.

					// if img or has background image
						// height is defined, recalculate image height preserving ratio

				// else no height defined
					// set width to 100%.  Reduce margin to 0 on side / set padding to 5% or 5px on sides.   Limit top bottom margin to 40px, or some variable

		applyFontSizeRules(arrNode);

		if(!options.resizeBoxes){
			return;
		}
		for(var i=0;i<arrNode.length;i++){
			var n=arrNode[i];
			var arrRule=[];
			var cssObj={}

			if($(n.node).hasClass("zDisableAutorespond")){
				continue;
			}

			reduceBoxValue(cssObj, n, "padding-left");
			reduceBoxValue(cssObj, n, "padding-top");
			reduceBoxValue(cssObj, n, "padding-right");
			reduceBoxValue(cssObj, n, "padding-bottom");
			reduceBoxValue(cssObj, n, "margin-left");
			reduceBoxValue(cssObj, n, "margin-top");
			reduceBoxValue(cssObj, n, "margin-right");
			reduceBoxValue(cssObj, n, "margin-bottom");
			
			/*
			reduceValue(cssObj, n, "left", ratio);
			reduceValue(cssObj, n, "top", ratio);
			reduceValue(cssObj, n, "right", ratio);
			reduceValue(cssObj, n, "bottom", ratio);
			*/
			if(zso(n.css, 'min-width') != "" && zso(n.css, 'min-width') != "100%"){
				cssObj["min-width"]="100%";
			}
			if(typeof n.node == "object" && zso(n.css, 'background-image') != "" && zso(n.css, 'background-image') != "none"){
				var d=getBackgroundImageDimensions(n.node);
				var h=rgbToHex(d.colorAverageRGB.r, d.colorAverageRGB.g, d.colorAverageRGB.b); 
				if(d.width>960){
					cssObj["background-image"]="none";
					if(zso(n.css, 'background-color') == ""){
						cssObj["background-color"]=h;
					}
				}else{
					cssObj["width"]="100%";
					cssObj["background-size"]="100% auto";
				}
			}
			if(typeof n.node == "object" && n.node.tagName.toLowerCase()=='img'){ 
				if(zso(n.css, 'width') != ""){ 
					if(n.css["width"].indexOf("%") != -1){

					}else{
						cssObj["max-width"]=Math.round(parseFloat(n.css.width))+"px";
						cssObj["width"]="100% !important";
						cssObj["height"]="auto !important";
					}
				} 
			}else{
				if(zso(n.css, 'width') != ""){
					var width=n.css.width;
					var w=parseFloat(width);
					if(!isNaN(w)){
						if(w>280){
							cssObj["max-width"]=Math.round(parseFloat(width))+"px";
							cssObj["width"]="100%";
							cssObj["height"]="auto";
						}
					}

					if(zso(n.css, 'height') != ""){
						if(n.css["height"].indexOf("%") != -1){

						}else{
							cssObj["height"]="auto !important";
						}
					}
				}
			}

			cleanStyle(cssObj, n);

			if(typeof n.node == "object"){
				var selector=getNodeSelector(n.node);
			}else{
				var selector=n.selector;
			}
			setRule(selector, cssObj);
			//arrRules.push(selector+"{"+ arrRule.join(" ")+"}");
 
		}
	}
	function cleanStyle(cssObj, n){

		if(!options.resizeMargin){
			if(zso(cssObj, "margin-left") != ""){ delete cssObj["margin-left"]; }
			if(zso(cssObj, "margin-right") != ""){ delete cssObj["margin-right"]; }
			if(zso(cssObj, "margin-top") != ""){ delete cssObj["margin-top"]; }
			if(zso(cssObj, "margin-bottom") != ""){ delete cssObj["margin-bottom"]; }
		}
		if(!options.resizePadding){
			if(zso(cssObj, "padding-left") != ""){ delete cssObj["padding-left"]; }
			if(zso(cssObj, "padding-right") != ""){ delete cssObj["padding-right"]; }
			if(zso(cssObj, "padding-top") != ""){ delete cssObj["padding-top"]; }
			if(zso(cssObj, "padding-bottom") != ""){ delete cssObj["padding-bottom"]; }
		}
		for(var i2 in n.cssOriginal){
			if(typeof cssObj[i2] != "undefined"){
				if(cssObj[i2] == n.cssOriginal[i2]){
					//console.log("delete: "+i2);
					delete cssObj[i2];
				}else{
					//console.log(i2+":" + cssObj[i2]+" != "+n.cssOriginal[i2]);
				}
			}
		}
	}

	function getStyle(className) {
		var classes = currentStylesheet.rules || currentStylesheet.cssRules
		for(var x=0;x<classes.length;x++) {
			if(classes[x].selectorText==className) {
				if(classes[x].cssText){
					return classes[x].cssText;
				}else{
					return classes[x].style.cssText;
				}
			}
		}
	} 
	function getAllStyles() {
		var arrNewRules=[];
		for(var i in arrRules){
			var arrRule=[];
			for(var n in arrRules[i]){
				arrRule.push(n+":"+arrRules[i][n]+";");
			}
			arrNewRules.push(i+"{"+ arrRule.join(" ")+"}");
		}

		return arrNewRules.join("\n");
	}


	function addCSSRule(sheet, selector, rules, index) {
		if("insertRule" in sheet) {
			sheet.insertRule(selector + "{" + rules + "}", index);
		}
		else if("addRule" in sheet) {
			sheet.addRule(selector, rules, index);
		}
	}
	/*
	function inlineToClass(node){
		alert('not used on this one');
		var $node=$(node);
		var s=$node.attr('data-tempstyle');
		if(typeof s != "undefined"){
			var className=getNextClassName();
			$node.addClass(className);

			var arrCode=s.match(/<.*?<\/.*?>/g);
			var code=""; 
			if(arrCode != null && arrCode.length){ 
				code=arrCode.join(" ");
			}
			s.replace(/<.*?<\/.*?>/g);
			var selector="."+className;
			if(node.tagName.toLowerCase() == 'a'){
				selector=selector+":link, "+selector+":visited";
			}
			arrRules.push(selector+"{"+s+"}");
			ruleIndex++;
			$node.removeAttr('data-tempstyle');
			if(code.length){ 
				$node.attr('data-tempstyle', code);
			}
		}
	}*/
	function getNextClassName(){
		// TODO check if class exists first - and skip index if it does.

		var nextClass=options.classPrefix+styleIndex;
		styleIndex++;
		return nextClass;
	}

	function getPrimaryStylesheetStyles(){
		for(var i=0;i<document.styleSheets.length;i++){

			if(typeof document.styleSheets[i].href != "undefined" && document.styleSheets[i].href != null && document.styleSheets[i].href.indexOf(options.primaryStylesheet) != -1){
				// loop all of these, and add to cssObj
				var arrN=document.styleSheets[i].cssRules;	
				for(var i2=0;i2<arrN.length;i2++){
					var n=arrN[i2];
					
					var css={};
					var cssOriginal={};
					var empty=true; 
					if(typeof n.style != "undefined" && typeof n.style.length != "undefined"){
						for(var i3=0;i3<n.style.length;i3++){
							if(n.style[i3] != ""){
								var v=n.style[n.style[i3]];
								if(v != "" & v != "auto" && v != "static" && v != "0px" && v != "0"){
									css[n.style[i3]]=v;
									cssOriginal[n.style[i3]]=v;
									empty=false;
								}
							}
						}
					}
					if(empty){ 
						continue; 
					}
					var m={
						node:false,
						css: css,
						cssOriginal: cssOriginal,
						pos: {x:0, y:0},
						minWidth: 0,
						minHeight: 0,
						selector: n.selectorText
					};
					arrNode.push(m); 
				}
			}
		}
	}
		
	function createNewStylesheet(){
		var style = document.createElement("style");
		style.id="newStylesheet1";
		document.head.appendChild(style);
		currentStylesheet = style.sheet;
	}
	createNewStylesheet();

 
	var contents=$("#htmlContents").val();
	
	options.container.style.display="block";  
	containerPos=zGetAbsPosition(options.container);
	options.container.innerHTML=(contents);


	if(options.primaryStylesheet != ""){ 
		getPrimaryStylesheetStyles();
	}else{
		extractStylesRecursively(options.container, true);
	}

	//console.log('all nested node count:'+arrNode.length);
	//console.log(arrNode);
	//console.log(arrNode[3]);

	if(options.type == "tablet"){
		reduceAllToWidth(arrNode, options.originalWidth, options.newWidth);
	}else{

		reduceAllToSingleColumn(arrNode);
	}
	console.log("node count:"+arrNode.length);
	//options.container.style.display="none";
	//var html=options.container.innerHTML; 
	//$("#htmlOutput").val(html);
	var css=getAllStyles();

 	//console.log(contents);
	$("#cssOutput").val(css); 
	try{
		$("#newStyle1")[0].innerHTML = css;
	}catch(error){
		$("#newStyle1")[0].styleSheet.cssText = css;
	}/**/
	//options.container.style.display="none";  

}
	window.zResponsiveHTML=zResponsiveHTML;
})(jQuery, window, document, "undefined"); 
