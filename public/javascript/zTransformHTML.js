
(function($, window, document, undefined){
	"use strict";
var zTransformHTML=function(options){
	var self=this;
	var currentStylesheet=0;
	var styleIndex=1;	
	var ruleIndex=0;
	var arrRules=[];
	if(typeof options === undefined){
		options={};
	}
	options.container=zso(options, 'container', false, document.body);
	options.classPrefix=zso(options, 'classPrefix', false, "sh-");
	function extractStylesRecursively(node){ 
		//console.log(node);
		inlineToClass(node);
		if(node.childNodes.length){
			for(var i=0;i<node.childNodes.length;i++){
				extractStylesRecursively(node.childNodes[i]);
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
		return arrRules.join("\n");
		/*var classes = currentStylesheet.rules || currentStylesheet.cssRules;
		var arrRule=[];
		for(var x=0;x<classes.length;x++) {
			if(classes[x].cssText){
				arrRule.push(classes[x].cssText);//classes[x].selectorText+" { "+classes[x].cssText+" } ");
			}else{
				arrRule.push(classes[x].style.cssText);//classes[x].selectorText+" { "+classes[x].style.cssText+" } ");
			}
		}
		return arrRule.join("\n");*/
	}

	function addCSSRule(sheet, selector, rules, index) {
		if("insertRule" in sheet) {
			sheet.insertRule(selector + "{" + rules + "}", index);
		}
		else if("addRule" in sheet) {
			sheet.addRule(selector, rules, index);
		}
	}
	function inlineToClass(node){
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
			s.replace(/<.*?<\/.*?>/g, '');

			s=unescapeHTML(s);
			s=s.replace(/#([^:]+)#/, "");
			s=s.replace(/##/g, "#"); 
			s=s.replace(/<cf.*?<\/cf[a-z]*>/gmi, "");
			//s=zStringReplaceAll(zStringReplaceAll(s, '<', '/*'), '>', '*/');
			s=s.replace(/;/gm, ";\n\t");
			s=s.replace(/\s\s+/gm, "\n\t");
			console.log(s);
			s=s.trim();

			if(s.length == 0){
				return;
			}
			var selector="."+className;
			if(node.tagName.toLowerCase() == 'a'){
				selector=selector+":link, "+selector+":visited";
			}
			arrRules.push(selector+"{\n\t"+s+"\n}");
			//addCSSRule(currentStylesheet, selector, s, ruleIndex);
			ruleIndex++;
			$node.removeAttr('data-tempstyle');
			//$node.removeAttr('style');
			if(code.length){ 
				$node.attr('data-tempstyle', code);
			}
		}
	}
	function getNextClassName(){
		// TODO check if class exists first - and skip index if it does.

		var nextClass=options.classPrefix+styleIndex;
		styleIndex++;
		return nextClass;
	}

	function createNewStylesheet(){
		var style = document.createElement("style");
		style.id="newStylesheet1";
		document.head.appendChild(style); // must append before you can access sheet property
		currentStylesheet = style.sheet;

		//console.log(styleSheet instanceof CSSStyleSheet);
	}
	createNewStylesheet();

	function escapeCFML(contents){   
		contents=contents.replace(/##/g, "~~CFMLLITERALPOUND~~");
		var r="#([^\#^\n]+)\"([^\#^\n]+)#";
		while(contents.match(r)){ 
			contents=zStringReplaceAll(contents, r, "#$1~~CFMLQUOTE~~$2#\n");
			contents=zStringReplaceAll(contents, r, "~~CFMLPOUND~~$1~~CFMLQUOTE~~$2~~CFMLPOUND~~\n");
		} 
		contents=contents.replace(/([^\s]*)<cf/i, "$1\n<cf");
		contents=contents.replace(/([^\s]*)<\/(cf[a-z]*?)>/i, "$1\n</$2>");
		contents=contents.replace(/<\/(cf[a-z]*?)>([^\s]*)/i, "</$1>\n$2");
		contents=zStringReplaceAll(contents, '<cfscript>', '<!-- CFSCRIPTCODE ');
		contents=zStringReplaceAll(contents, '</cfscript>', ' ENDCFSCRIPTCODE -->'); 
		contents=contents.replace(/(.*<cf.*)/ig, '<!-- CFMLCODE $1 ENDCFMLCODE -->'); 
		contents=contents.replace(/(.*<\/cf.*)/ig, '<!-- CFMLCODE $1 ENDCFMLCODE -->');
		//contents=zStringReplaceAll(contents, "#\n", "#");
		//contents=contents.replace("#\n", "#");
		while(contents.match("~~CFMLPOUND~~\n")){
			contents=contents.replace("~~CFMLPOUND~~\n", "~~CFMLPOUND~~");
		}
		while(contents.match("~~CFMLLITERALPOUND~~")){
			contents=contents.replace("~~CFMLLITERALPOUND~~", "##");
		}
		console.log(contents);
		return contents;
	}
	function unescapeHTML(html){
		html=zStringReplaceAll(html, 'data-tempstyle="', 'style="');
		html=zStringReplaceAll(html, '<!-- CFSCRIPTCODE ', '<cfscript>');
		html=zStringReplaceAll(html, ' ENDCFSCRIPTCODE -->', '</cfscript>');
		html=zStringReplaceAll(html, '<!-- CFMLCODE ', ' ');
		html=zStringReplaceAll(html, ' ENDCFMLCODE -->', ' ');
		html=zStringReplaceAll(html, '~~CFMLQUOTE~~', '"');
		html=zStringReplaceAll(html, '~~cfmlquote~~', '"');
		html=zStringReplaceAll(html, '~~CFMLPOUND~~', '#');
		html=zStringReplaceAll(html, '~~cfmlpound~~', '#');
		return html;
	}
	function removeCFML(contents){

	}

	var contents=options.container.getAttribute("data-contents");
	var contents=$("#htmlContents").val();
	contents=escapeCFML(contents);
 
	contents=zStringReplaceAll(contents, 'style="', 'data-tempstyle="');
	options.container.removeAttribute("data-contents");
	options.container.innerHTML=(contents);
	extractStylesRecursively(options.container);
	var html=options.container.innerHTML;
	html=unescapeHTML(html);

	$("#htmlOutput").val(html);
	var css=getAllStyles();
	$("#cssOutput").val(css); 

}
	window.zTransformHTML=zTransformHTML;
})(jQuery, window, document, "undefined"); 
