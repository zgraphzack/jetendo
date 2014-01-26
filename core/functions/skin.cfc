<cfcomponent>
<cfoutput>
<cffunction name="zHTMLSetupGlobals" localmode="modern" output="no" returntype="any">
	<cfscript>
	var i=0;
	var arrT='';
	var n='';
	var zArrHTMLElementsDecreateIndenting=listtoarray("z_else,z_elseif,cfelse,cfelseif",",");
	
	var zArrHTMLBlockElements=listtoarray("p,div,h1,h2,h3,h4,h5,h6,blockquote,pre,",",");
	var zArrHTMLInlineElements=listtoarray("a,abbr,acronym,b,basefont,bdo,big,br,cite,code,dfn,em,font,i,img,input,kbd,label,q,s,samp,tiselect,small,span,strike,strong,sub,sup,textarea,tt,u,var,m,time,meter,progress",",");
	var zArrHTMLElementsWithoutNesting=listtoarray("br,meta,base,link,input,img,area,param,embed,z_else,z_elseif,cfelse,cfelseif",",");
	var zArrHTMLElementsWithoutInnerParsing=listtoarray("style,script,cfscript,?xml,?php,%,!",",");
	
	request.zHTMLSkinCompileObjectMap=structnew();
	request.zHTMLSkinCompileObjectMap["model"]="model";
	request.zHTMLSkinCompileObjectMap["cgi"]="request.zos.cgi";
	request.zHTMLElementsWithoutNestingStruct=structnew();
	request.zHTMLElementsWithoutInnerParsingStruct=structnew();
	request.zHTMLInlineElements=structnew();
	request.zHTMLBlockElements=structnew();
	request.zHTMLElementsDecreateIndenting=structnew();
	for(i=1;i LTE arraylen(zArrHTMLBlockElements);i++){
		request.zHTMLBlockElements[zArrHTMLBlockElements[i]]=true;
	}
	for(i=1;i LTE arraylen(zArrHTMLElementsWithoutNesting);i++){
		request.zHTMLElementsWithoutNestingStruct[zArrHTMLElementsWithoutNesting[i]]=true;
	}
	for(i=1;i LTE arraylen(zArrHTMLElementsWithoutInnerParsing);i++){
		request.zHTMLElementsWithoutInnerParsingStruct[zArrHTMLElementsWithoutInnerParsing[i]]=true;
	}
	for(i=1;i LTE arraylen(zArrHTMLInlineElements);i++){
		request.zHTMLInlineElements[zArrHTMLInlineElements[i]]=true;
	}
	for(i=1;i LTE arraylen(zArrHTMLElementsDecreateIndenting);i++){
		request.zHTMLElementsDecreateIndenting[zArrHTMLElementsDecreateIndenting[i]]=true;
	}
	request.zOPStruct=structnew();
	request.zOPStruct.arrValidOPRightHandRequired=listtoarray('EQUAL,NOT EQUAL,CONTAINS,DOES NOT CONTAIN,GREATER THEN,LESS THEN,GREATER THEN OR EQUAL TO,LESS THEN OR EQUAL TO');
	request.zOPStruct.arrValidOP=listtoarray('EQUAL,NOT EQUAL,CONTAINS,DOES NOT CONTAIN,IS EMPTY,IS NOT EMPTY,EXISTS,DOES NOT EXIST,GREATER THEN,LESS THEN,GREATER THEN OR EQUAL TO,LESS THEN OR EQUAL TO');
	request.zOPStruct.opStruct=structnew();
	request.zOPStruct.validOPStruct=structnew();
	request.zOPStruct.validOPRightHandStruct=structnew();
	for(i=1;i LTE arraylen(request.zOPStruct.arrValidOPRightHandRequired);i++){
		request.zOPStruct.validOPRightHandStruct[request.zOPStruct.arrValidOPRightHandRequired[i]]=true;
	}
	for(i=1;i LTE arraylen(request.zOPStruct.arrValidOP);i++){
		request.zOPStruct.validOPStruct[request.zOPStruct.arrValidOP[i]]=true;
		arrT=listtoarray(request.zOPStruct.arrValidOP[i]," ");
		for(n=1;n LTE arraylen(arrT);n++){ // for matching single words of the operators
			request.zOPStruct.opStruct[arrT[n]]=true;
		}
	}
	</cfscript>
</cffunction>


<!--- rs=zAnalyzeXHTMLNestingFromArray(arrDoc);  --->
<cffunction name="zAnalyzeXHTMLNestingFromArray" localmode="modern" output="yes" returntype="struct">
	<cfargument name="arrDoc" type="array" required="yes">
	<cfscript>
	var level='';
	var lastC='';
	var lastDocItem='';
	var lastInlineElement='';
	var arrT2='';
	var arrDoc=arraynew(1);
	var local=structnew();
	var i=0;
	var c=0;
	var rs=structnew();
	var arrParent=arraynew(1);
	var arrR=arraynew(1);
	var length=arraylen(arguments.arrDoc);
	var nextType=0;
	var parentIndex=0;
	var tempC=0;
	var curLevel=0;
	var arrT=arraynew(1);
	var uniqueIdStruct=structnew();
	var arrControl=arraynew(1);
	var inInlineElement=0;
	var arrLastInlineElement="";
	var cprevious=0;
	var tempCompareValue=0;
	var dataZattributeFound=false;
	var dataZattributeFoundLevel=0;
	local.controlLevel=0;
	local.arrControlParent=arraynew(1);
	rs.success=true;
	rs.arrErrorMessage=arraynew(1);
	for(i=1;i LTE length;i++){
		c=arguments.arrDoc[i];
		if(i+1 LTE length){
			nextType=arguments.arrDoc[i+1].type;
		}else{
			nextType="";
		}
		if(i-1 GT 0){
			cprevious=arguments.arrDoc[i-1];
		}else{
			cprevious=structnew();
			cprevious.type="";
		}
		// self contained control nesting checks:
		// for must close before outer if, else or elseif closes
		if(c.type EQ "for"){
			arrayAppend(local.arrControlParent,i);
			level=arraylen(local.arrControlParent)-1;
			arguments.arrDoc[i].level=level;
		}else if(c.type EQ "if"){
			arrayAppend(local.arrControlParent,i);
			level=arraylen(local.arrControlParent)-1;
			arguments.arrDoc[i].level=level;
		}else if(c.type EQ "else" or c.type EQ "elseif"){
			if(arraylen(local.arrControlParent) NEQ 0){
				// if previous parent is not if, it is invalid.
				lastC=local.arrControlParent[arraylen(local.arrControlParent)];
				lastDocItem=arguments.arrDoc[lastC];
				if(lastDocItem.type NEQ "if" and lastDocItem.type NEQ "elseif"){
					arrayappend(rs.arrErrorMessage, htmleditformat("There must be an if or elseif statement before the #c.type# statement. Line #c.line#, Column #c.column#"));
					rs.success=false;
					return rs;
				}
				arrayAppend(local.arrControlParent,i);
				level=arraylen(local.arrControlParent)-1;
				arguments.arrDoc[i].level=level;
			}else{
				arrayappend(rs.arrErrorMessage, htmleditformat("#c.type# is missing an opening if statement. Line #c.line#, Column #c.column#"));
				rs.success=false;
				return rs;
			}
		}else if(c.type EQ "endif"){
			if(arraylen(local.arrControlParent) NEQ 0){
				// detect an open for
				lastC=local.arrControlParent[arraylen(local.arrControlParent)];
				lastDocItem=arguments.arrDoc[lastC];
				if(lastDocItem.type EQ "for"){
					arrayappend(rs.arrErrorMessage, htmleditformat(lastDocItem.type&" must close before the endif statement. Line #lastDocItem.line#, Column #lastDocItem.column#"));
					rs.success=false;
					return rs;
				}else if(lastDocItem.type NEQ "else" and lastDocItem.type NEQ "elseif" and lastDocItem.type NEQ "if"){		
					// detect a missing else, elseif and if
					arrayappend(rs.arrErrorMessage, htmleditformat("These must be an if statement before the endif statement. Line #c.line#, Column #c.column#"));
					rs.success=false;
					return rs;
				}
				local.loopLimit=0;
				while(true){
					local.tempParent=arguments.arrDoc[local.arrControlParent[arraylen(local.arrControlParent)]];
					if(local.tempParent.type EQ "else" or local.tempParent.type EQ "elseif" or local.tempParent.type EQ "if"){
						arraydeleteat(local.arrControlParent, arraylen(local.arrControlParent));
					}
					if(local.tempParent.type EQ "if"){
						break;
					}
					local.loopLimit++;
					if(local.loopLimit GTE 100){
						arrayappend(rs.arrErrorMessage, htmleditformat("Invalid if, else, else if or for statement has caused an infinite loop. Line #c.line#, Column #c.column#"));
						rs.success=false;
						return rs;
					}
				}
			}else{
				arrayappend(rs.arrErrorMessage, htmleditformat("endif is missing an opening if statement. Line #c.line#, Column #c.column#"));
				rs.success=false;
				return rs;
			}
			
		}else if(c.type EQ "endfor"){
			// remove parent
			if(arraylen(local.arrControlParent) NEQ 0){
				lastC=local.arrControlParent[arraylen(local.arrControlParent)];
				lastDocItem=arguments.arrDoc[lastC];
				if(lastDocItem.type NEQ "for"){
					arrayappend(rs.arrErrorMessage, htmleditformat(lastDocItem.type&" must close before the endfor statement. Line #c.line#, Column #c.column#"));
					rs.success=false;
					return rs;
				}
				arraydeleteat(local.arrControlParent, arraylen(local.arrControlParent));
			}else{
				arrayappend(rs.arrErrorMessage, htmleditformat("endfor is missing an opening for statement. Line #c.line#, Column #c.column#"));
				rs.success=false;
				return rs;
			}
			
		}
		/*
		arrayappend(rs.arrErrorMessage, htmleditformat("Block element, <"&c.value&">, can't be nested inside the inline element, <"&lastInlineElement&">. Line #c.line#, Column #c.column#"));
		rs.success=false;
		return rs;
		*/
		
		
		
		if(c.type EQ "htmlTag"){
			if(structkeyexists(request.zHTMLInlineElements,c.value)){
				inInlineElement++;
				lastInlineElement=i;
			}
		}else if(c.type EQ "endHTMLTag"){
			dataZattributeFound=false;
			if(structkeyexists(request.zHTMLInlineElements,c.value) and arguments.arrDoc[lastInlineElement].type NEQ "openHTMLTag"){
				inInlineElement--;
			}
		}else if(c.type EQ "openHTMLTag" or c.type EQ "coldfusionTag" or c.type EQ "closeHTMLTag" or c.type EQ "closeColdfusionTag"){
			if(structkeyexists(request.zHTMLInlineElements,c.value)){
				if(c.type EQ "openHTMLTag"){
					inInlineElement++;
					lastInlineElement=i;
				}else{
					inInlineElement--;
				}
			}
		}
		if(c.type EQ "openHTMLTag" or c.type EQ "htmlTag"){
			if(structkeyexists(request.zHTMLBlockElements, c.value)){
				if(inInlineElement GT 0){
					arrayappend(rs.arrErrorMessage, htmleditformat("Block element, <"&c.value&">, can't be nested inside the inline element, <"&lastInlineElement&">. Line #c.line#, Column #c.column#"));
					rs.success=false;
					return rs;
				}
			}
		}
		if((c.type EQ "attributeValue") and cprevious.type EQ "attributeName" and cprevious.value EQ "id"){// or c.type EQ "attributeValueExpression"
			if(structkeyexists(uniqueIdStruct, c.value)){
				arrayappend(rs.arrErrorMessage, htmleditformat("ID, ""#c.value#"", already exists in the document and you can only use an id once. Line #c.line#, Column #c.column#"));
				rs.success=false;
				return rs;
			}
		}
		
		if(c.type EQ "attributeName" and left(c.value,6) EQ "data-z"){
			if(dataZattributeFound and dataZattributeFoundLevel EQ curLevel){
				arrayappend(rs.arrErrorMessage, htmleditformat('Expression parsing failed because you can''t have more then one "data-z..." attribute on an HTML Element. Line #c.line#, Column #c.column#'));
				rs.success=false;
				return rs;
			}else{
				dataZattributeFound=true;
				dataZattributeFoundLevel=curLevel;
			}
		}
		uniqueIdStruct[c.value]=true;
		if(c.type EQ "openHTMLTag"){
			arrayAppend(arrParent,i);
			level=arraylen(arrParent)-1;
			arguments.arrDoc[i].level=level;
			curLevel=level;
		}else if(c.type EQ "coldfusionTag"){
			arrT2=listtoarray(c.value," ");
			tempCompareValue=arrT2[1];
			if(structkeyexists(request.zHTMLElementsWithoutNestingStruct, tempCompareValue) EQ false){
				arrayAppend(arrParent,i);
				level=arraylen(arrParent)-1;
				arguments.arrDoc[i].level=level;
				curLevel=level;
			}
		}else if(c.type EQ "closeHTMLTag" or c.type EQ "closeColdfusionTag"){
			dataZattributeFound=false;
			if(arraylen(arrParent) NEQ 0){
				parentIndex=arrParent[arraylen(arrParent)];
				tempC=arguments.arrDoc[parentIndex];
				arrDoc[i].level=tempC.level;
				curLevel=tempC.level;
				if(left(tempC.value,2) EQ "cf"){
					arrT2=listtoarray(tempC.value," ");
					tempCompareValue=arrT2[1];
				}else{
					tempCompareValue=tempC.value;
				}
			}else{
				tempCompareValue="";
				curLevel--;
				arrDoc[i].level=curLevel;
			}
			if(arraylen(arrParent) EQ 0 or tempCompareValue NEQ c.value){
				if(arraylen(arrParent) NEQ 0){
					tempC=arguments.arrDoc[parentIndex];
					arrayappend(rs.arrErrorMessage, htmleditformat("Element <#tempCompareValue#> was not closed properly. Line #tempC.line#, Column #tempC.column#"));
				}else{
					arrayappend(rs.arrErrorMessage, htmleditformat("Element <#c.value#> was not closed properly. Line #c.line#, Column #c.column#"));
				}
				rs.success=false;
				return rs;
			}else{
				if(arraylen(arrParent) NEQ 0){
					arraydeleteat(arrParent, arraylen(arrParent));
				}
			}
			arguments.arrDoc[i].parentIndex=parentIndex;
		}
	}
	if(arraylen(local.arrControlParent) NEQ 0){
		for(i=arraylen(local.arrControlParent);i GTE 1;i--){
			parentIndex=local.arrControlParent[i];
			tempC=arguments.arrDoc[parentIndex];
			arrayappend(rs.arrErrorMessage, htmleditformat("This statement #tempC.value# was not closed properly. Line #tempC.line#, Column #tempC.column#"));
			rs.success=false;
			return rs;
		}
	}
	if(arraylen(arrParent) NEQ 0){
		for(i=arraylen(arrParent);i GTE 1;i--){
			parentIndex=arrParent[i];
			tempC=arguments.arrDoc[parentIndex];
			curLevel--;
			arrayappend(rs.arrErrorMessage, htmleditformat("Element <#tempC.value#> was not closed properly. Line #tempC.line#, Column #tempC.column#"));
			rs.success=false;
			return rs;
		}
	}
	if(curLevel LT 0){
		arrayappend(rs.arrErrorMessage, "There are more opening elements then closing elements.  Please review document structure.");
		rs.success=false;
		return rs;
	}
	rs.arrHTML=arguments.arrDoc;
	return rs;
	</cfscript>
</cffunction>



<!--- 
ts=structnew();
ts.theHTML="";
ts.allowColdfusion=false;
rs=zParseHTMLIntoArray(ts);
 --->
<cffunction name="zParseHTMLIntoArray" localmode="modern" output="yes" returntype="struct">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var local=structnew();
	var tempEndTag='';
	var tempEscape='';
	var tempCheck='';
	var rs=structnew();
	var tempTagName="";
	var endTagName="";
	var i=0;
	var n=0;
	var arrE=arraynew(1);
	var inTag=false;
	var htmlLength=0;
	var inAttr=false;
	var inComment=false;
	var inTagComment=false;
	var inClosingTag=false;
	var tagRead=false;
	var attrRead=false;
	var inSGMLAttr=false;
	var inSingleQuoteAttr=false;
	var curString="";
	var tagClosingPos=0;
	var curTagName="";
	var inColdfusionTag=false;
	var coldfusionTagPos=0;
	var c=0;
	var currentLine=1;
	var lineBeginPos=0;
	var cpp=0;
	var cn=0;
	var cp=0;
	var cnn=0;
	var cnnn=0;
	var tempEndTagLength=0;
	var tempInComment=false;
	var tempInCComment=false;
	var tempInSingleQuote=false;
	var tempInQuote=false;
	var pos=0;
	var tempC=0;
	var tempCn=0;
	var tempString=0;
	var tagOpenEnded=0;
	var tagEnded=0;
	var tempCp=0;
	var nestingDisabled=0;
	var ts=structnew();
	var lastLine=1;
	var lastColumn=1;
	var validControlString=",else,elseif,else,endif,if,for,endfor,dump,";
	var theHTML="";
	ts.allowColdfusion=false;
	rs.success=false;
	structappend(arguments.ss,ts,false);
	theHTML=arguments.ss.theHTML;
	theHTML=replace(theHTML, "##","####","all");
	htmlLength=len(theHTML);
	for(i=1;i LTE htmlLength;i++){
		c=mid(theHTML,i,1);
		if(i-2 GTE 1){
			cpp=mid(theHTML,i-2,1);
		}else{
			cpp="";
		}
		if(i-1 GTE 1){
			cp=mid(theHTML,i-1,1);
		}else{
			cp="";
		}
		if(i+1 LTE htmlLength){
			cn=mid(theHTML,i+1,1);
		}else{
			cn="";
		}
		if(i+2 LTE htmlLength){
			cnn=mid(theHTML,i+2,1);
		}else{
			cnn="";
		}
		if(i+3 LTE htmlLength){
			cnnn=mid(theHTML,i+3,1);
		}else{
			cnnn="";
		}
		if(c EQ chr(10)){
			lineBeginPos=i+1;
			lastLine=currentLine;
			lastColumn=1; 
			currentLine++;	
		}else if(c EQ chr(13)){
			lineBeginPos=i+1;
			lastLine=currentLine;
			lastColumn=1; 
		}
		if(inComment or inTagComment){
			if(c EQ ">"){// and cp EQ "-" and cpp EQ "-"){
				// end comment - store event
				if(inTagComment){
					// if this is a loop or logic, change the type.
					tempString=trim(removechars(curString, 1, 3));
					local.pos=find(" ", tempString);
					if(local.pos NEQ 0){
						tempString=lcase(left(tempString, local.pos-1));
					}
					if(local.pos NEQ 0 and replace(validControlString, ","&tempString&",", '') NEQ validControlString){
						ts=structnew();
						ts.type=tempString;
						ts.value="$"&trim(mid(curString, 4, len(curString)-6))&"$";//"<"&curString&">";
						ts.line=lastLine; 
						ts.column=lastColumn; 
						lastLine=currentLine;
						lastColumn=i-lineBeginPos; 
					}else{
						ts=structnew();
						ts.type="comment";
						ts.value="<"&curString&">";
						ts.line=lastLine; 
						ts.column=lastColumn; 
						lastLine=currentLine;
						lastColumn=i-lineBeginPos; 
					}
					arrayappend(arrE, ts);
					curString="";
					inComment=false;
					inTagComment=false;
					continue;
				}else if(cp EQ "-" and cpp EQ "-"){
					tempString=trim(removechars(curString, 1, 3));
					local.pos=find(" ", tempString);
					if(local.pos NEQ 0){
						tempString=lcase(left(tempString, local.pos-1));
					}
					if(local.pos NEQ 0 and replace(validControlString, ","&tempString&",", '') NEQ validControlString){
						ts=structnew();
						ts.type=tempString;
						ts.value="$"&trim(mid(curString, 4, len(curString)-6))&"$";//"<"&curString&">";
						ts.line=lastLine; 
						ts.column=lastColumn; 
						lastLine=currentLine;
						lastColumn=i-lineBeginPos; 
					}else{
						ts=structnew();
						ts.type="comment";
						ts.value="<"&curString&">";
						ts.line=lastLine; 
						ts.column=lastColumn; 
						lastLine=currentLine;
						lastColumn=i-lineBeginPos; 
					}
					arrayappend(arrE, ts);
					curString="";
					inComment=false;
					inTagComment=false;
					continue;
				}
			}
		}else if(inTag){
			if(inColdfusionTag and c EQ "##"){
				if(cn NEQ "##" and cp NEQ "##"){
					// this is a coldfusion
				}
			}
			if(inAttr){
				if(c EQ '"'){
					ts=structnew();
					if(curString CONTAINS "$"){
						local.a4=application.zcore.functions.zParseHtmlText(arrE, curString,currentLine, i-lineBeginPos, true);
						if(isstruct(local.a4)){
							return local.a4;
						}else{
							arrE=local.a4;
						}
					}else{
						/*if(left(local.ct2,1) EQ "$" and right(local.ct2,1) EQ "$"){
							// expression
							ts.type="attributeValueExpression";
							ts.value=mid(curString,2,len(curString)-2);
						}else{*/
							ts.type="attributeValue";
							ts.value=curString;
						//}
						ts.line=lastLine; 
						ts.column=lastColumn; 
						lastLine=currentLine;
						lastColumn=i-lineBeginPos; 
						arrayappend(arrE, ts);
					}
					curString="";
					// end attribute
					inAttr=false;
					inSGMLAttr=false;
					attrRead=false;
					continue;
				}
			}else if(inSingleQuoteAttr){
				if(c EQ "'"){
					ts=structnew();
					if(curString CONTAINS "$"){
						local.a4=application.zcore.functions.zParseHtmlText(arrE, curString,currentLine, i-lineBeginPos, true); 
						if(isstruct(local.a4)){
							return local.a4;
						}else{
							arrE=local.a4;
						}
					}else{
						/*if(left(local.ct2,1) EQ "$" and right(local.ct2,1) EQ "$"){
							// expression
							ts.type="attributeValueExpression";
							ts.value=mid(curString,2,len(curString)-2);
						}else{*/
							ts.type="attributeValue";
							ts.value=curString;
						//}
						ts.line=lastLine; 
						ts.column=lastColumn; 
						lastLine=currentLine;
						lastColumn=i-lineBeginPos; 
						arrayappend(arrE, ts);
					}
					curString="";
					// end attribute
					inSingleQuoteAttr=false;
					inSGMLAttr=false;
					attrRead=false;
					continue;
				}
			}else{
				if(c EQ "'"){
					if(attrRead){
						curString="";
						// start attribute
						inSingleQuoteAttr=true;
						continue;
					}else{
						// invalid html here
						ts=structnew();
						ts.type="invalidHTML";
						ts.value=trim(curString&'"');
						
							ts.line=lastLine; 
							ts.column=lastColumn; 
							lastLine=currentLine;
							lastColumn=i-lineBeginPos; 
						arrayappend(arrE, ts);
						curString="";
						continue;
					}
				}else if(c EQ '"'){
					if(attrRead){
						curString="";
						// start attribute
						inAttr=true;
						continue;
					}else{
						// invalid html here
						ts=structnew();
						ts.type="invalidHTML";
						ts.value=trim(curString&'"');
						
							ts.line=lastLine; 
							ts.column=lastColumn; 
							lastLine=currentLine;
							lastColumn=i-lineBeginPos; 
						arrayappend(arrE, ts);
						curString="";
						continue;
					}
				}else if(c EQ ">"){
					nestingDisabled=false;
					if(cp EQ "/"){
						nestingDisabled=true;
						curString=removeChars(curString,len(curString),1);	
					}
					// end tag
					tagOpenEnded=false;
					tagEnded=false;
					if(tagRead EQ false){
						tagEnded=true;
						ts=structnew();
						if(left(curString,2) EQ "cf"){
							if(arguments.ss.allowColdfusion EQ false){
								rs.error="Coldfusion tags are not allowed. Tag found: #curString#";
								rs.success=false;
								return rs;
							}
							if(inClosingTag){
								ts.type="closeColdfusionTag";
							}else{
								inColdfusionTag=true;
								ts.type="coldfusionTag";
							}
						}else if(inClosingTag){
							ts.type="closeHtmlTag";
							lastColumn--;
						}else if(nestingDisabled or structkeyexists(request.zHTMLElementsWithoutNestingStruct, trim(curString))){
							ts.type="htmlTag";
						}else{
							ts.type="openHtmlTag";
						}
						ts.value=trim(curString);
						curTagName=ts.value;
						
							ts.line=lastLine; 
							ts.column=lastColumn+1; 
							lastLine=currentLine;
							lastColumn=i-lineBeginPos; 
						arrayappend(arrE, ts);
						curString="";
					}else if(attrRead){
						if(trim(curString) NEQ ""){
							ts=structnew();
							ts.type="attributeName";
							ts.value=trim(curString);
							
							ts.line=lastLine; 
							ts.column=lastColumn; 
							lastLine=currentLine;
							lastColumn=i-lineBeginPos; 
							arrayappend(arrE, ts);
						}
						curString="";
						
					}else{
						if(trim(curString) NEQ ""){
							ts=structnew();
							ts.type="invalidHTML";
							ts.value=trim(curString);
							
							ts.line=lastLine; 
							ts.column=lastColumn; 
							lastLine=currentLine;
							lastColumn=i-lineBeginPos; 
							arrayappend(arrE, ts);
						}
						curString="";
					}
					if(inClosingTag EQ false){
						if(inColdfusionTag){
							inColdfusionTag=false;
							if(coldfusionTagPos NEQ 0){
								expression=trim(mid(theHTML,coldfusionTagPos,i-coldfusionTagPos));
								coldfusionTagPos=0;
								for(n=arraylen(arrE);n GTE 1;n--){
									if(arrE[n].type EQ "coldfusionTag"){
										arraydeleteat(arrE,n);
										break;
									}else{
										arraydeleteat(arrE,n);
									}
								}
								ts=structnew();
								ts.type="coldfusionTag";
								ts.value=curTagName&" "&expression;
								
							ts.line=lastLine; 
							ts.column=lastColumn; 
							lastLine=currentLine;
							lastColumn=i-lineBeginPos; 
								arrayappend(arrE, ts);
							}
						}else{
							if(curTagName EQ "?xml"){
								arraydeleteat(arrE, arraylen(arrE));
							}
							ts=structnew();
							ts.type="endHTMLTag";
							ts.value=curTagName;
							
							ts.line=lastLine; 
							ts.column=lastColumn; 
							lastLine=currentLine;
							lastColumn=i-lineBeginPos; 
							arrayappend(arrE, ts);
						}
						tagOpenEnded=true;
					}
					if((tagOpenEnded and left(curTagName,1) NEQ "?" and left(curTagName,1) NEQ "%") and inClosingTag EQ false and structkeyexists(request.zHTMLElementsWithoutInnerParsingStruct, trim(curTagName))){
						// do not parse inside these tags
						
						// parse to avoid c style comments /* */
						tempTagName=curTagName;
						tempEndTag="</"&curTagName&">";
						if(curTagName EQ "cfscript"){
							tempEscape='"';
						}else{
							tempEscape='\';
						}
						//zdump(arrE);
						tempEndTagLength=len(tempEndTag);
						tempInComment=false;
						tempInCComment=false;
						tempInSingleQuote=false;
						tempInQuote=false;
						
						pos=0;
						for(n=i;n LTE htmlLength;n++){
							tempCheck="";
							tempC=mid(theHTML,n,1);
							if(tempC EQ chr(10)){
								currentLine++;	
								lineBeginPos=n+1;
							}else if(tempC EQ chr(13)){
								lineBeginPos=n+1;
							}
							//writeoutput('tempC:'&tempC&'<br />');
							tempcn="";
							if(n+1 LTE htmlLength){
								tempcn=mid(theHTML,n+1,1);
							}
							tempcp="";
							if(n-1 GTE 1){
								tempcp=mid(theHTML,n-1,1);
							}
							//writeoutput(tempC&" "&tempcn&" | <br />");
							if(tempInCComment){
								if(tempC EQ "*" and tempcn EQ "/"){
									tempInCComment=false;
									n++;
									continue;
								}
							}else if(tempInComment and tempTagName EQ "cfscript"){
								if(tempC EQ chr(10) or tempC EQ chr(13)){
									tempInComment=false;
									continue;
								}
							}else if(tempInSingleQuote){
								if(tempC EQ "'" and tempcp NEQ tempEscape and n NEQ i){
									tempInSingleQuote=false;
									continue;
								}
							}else if(tempInQuote){
								if(tempC EQ '"' and tempcp NEQ tempEscape and n NEQ i){
									tempInQuote=false;
									continue;
								}
							}else{
								if(tempC EQ "'"){
									tempInSingleQuote=true;
									continue;	
								}
								if(tempC EQ '"'){
									//writeoutput('found quote');
									tempInQuote=true;
									continue;	
								}
								if(tempC EQ "/" and tempcn EQ "*"){
									tempInCComment=true;
									n++;
									continue;
								}
								if(tempTagName EQ "cfscript" and tempC EQ "/" and tempcn EQ "/"){
									tempInComment=true;
									n++;
									continue;
								}
								if(n+tempEndTagLength LTE htmlLength){
									tempCheck=mid(theHTML,n,tempEndTagLength);
								}
								if(tempInComment EQ false and tempInCComment EQ false and tempCheck EQ tempEndTag){
									// found the end!
									pos=n;	
									break;
								}
							}
						}
						//writeoutput('pos'&pos&'<br />');
						// skip to end and store right here
						if(pos NEQ 0){
							tagClosingPos=pos;
							curString=trim(mid(theHTML,i+1,(tagClosingPos-1)-(i)));
							//writeoutput("|"&curString&"|<br />");
							ts=structnew();
							if(curTagName EQ "cfscript"){
								ts.type="coldfusionScriptText";
							}else{
								ts.type="scriptText";
							}
							ts.value=trim(curString);
							
							ts.line=lastLine; 
							ts.column=lastColumn+1; 
							lastLine=currentLine;
							lastColumn=n-lineBeginPos; 
							arrayappend(arrE, ts);
							curString="";
						}else{
							rs.error=(curTagName&" was not closed properly. Starting tag began on Line #currentLine#, Column #i-lineBeginPos#");
							rs.success=false;
							return rs;
							break;	
						}
						i=tagClosingPos-1;
						
					}
					if(inClosingTag){
						inColdfusionTag=false;
					}
					curTagName="";
					tagRead=false;
					attrRead=false;
					inSGMLAttr=false;
					inSingleQuoteAttr=false;
					inAttr=false;
					inTag=false;
					inClosingTag=false;
					continue;
				}else if(tagRead EQ false and trim(c) EQ ""){
					// store previous string as tagName
					ts=structnew();
					if(left(curString,2) EQ "cf"){
						if(arguments.ss.allowColdfusion EQ false){
							rs.error="Coldfusion tags are not allowed. Tag found: #curString#";
							rs.success=false;
							return rs;
						}
						ts.type="coldfusionTag";
					}else if(structkeyexists(request.zHTMLElementsWithoutNestingStruct, trim(curString))){
						ts.type="htmlTag";
					}else{
						ts.type="openHtmlTag";
					}
					ts.value=trim(curString);
					curTagName=ts.value;
					
							ts.line=lastLine; 
							ts.column=lastColumn; 
							lastLine=currentLine;
							lastColumn=i-lineBeginPos; 
					arrayappend(arrE, ts);
					curString="";
					if(left(curTagName,2) EQ "cf"){
						inColdfusionTag=true;	
						coldfusionTagPos=i;
					}else if(curTagName NEQ "?xml" and (left(curTagName,1) EQ "?" or left(curTagName,1) EQ "%")){
						// parse to avoid c style comments /* */
						tempTagName=curTagName;
						tempEndTag=left(curTagName,1)&">";
						tempEscape='\';
						//zdump(arrE);
						tempEndTagLength=len(tempEndTag);
						tempInComment=false;
						tempInCComment=false;
						tempInSingleQuote=false;
						tempInQuote=false;
						
						pos=0;
						for(n=i;n LTE htmlLength;n++){
							tempCheck="";
							tempC=mid(theHTML,n,1);
							if(tempC EQ chr(10)){
								currentLine++;	
								lineBeginPos=n+1;
							}else if(tempC EQ chr(13)){
								lineBeginPos=n+1;
							}
							//writeoutput('tempC:'&tempC&'<br />');
							tempcn="";
							if(n+1 LTE htmlLength){
								tempcn=mid(theHTML,n+1,1);
							}
							tempcp="";
							if(n-1 GTE 1){
								tempcp=mid(theHTML,n-1,1);
							}
							//writeoutput(tempC&" "&tempcn&" | <br />");
							if(tempInCComment){
								if(tempC EQ "*" and tempcn EQ "/"){
									tempInCComment=false;
									n++;
									continue;
								}
							}else if(tempInComment and tempTagName EQ "cfscript"){
								if(tempC EQ chr(10) or tempC EQ chr(13)){
									tempInComment=false;
									continue;
								}
							}else if(tempInSingleQuote){
								if(tempC EQ "'" and tempcp NEQ tempEscape and n NEQ i){
									tempInSingleQuote=false;
									continue;
								}
							}else if(tempInQuote){
								if(tempC EQ '"' and tempcp NEQ tempEscape and n NEQ i){
									tempInQuote=false;
									continue;
								}
							}else{
								if(tempC EQ "'"){
									tempInSingleQuote=true;
									continue;	
								}
								if(tempC EQ '"'){
									//writeoutput('found quote');
									tempInQuote=true;
									continue;	
								}
								if(tempC EQ "/" and tempcn EQ "*"){
									tempInCComment=true;
									n++;
									continue;
								}
								if(tempTagName EQ "cfscript" and tempC EQ "/" and tempcn EQ "/"){
									tempInComment=true;
									n++;
									continue;
								}
								if(n+tempEndTagLength LTE htmlLength){
									tempCheck=mid(theHTML,n,tempEndTagLength);
								}
								if(tempInComment EQ false and tempInCComment EQ false and tempCheck EQ tempEndTag){
									// found the end!
									pos=n;	
									break;
								}
							}
						
						}
						tagClosingPos=pos;
						curString=trim(mid(theHTML,i+1,(tagClosingPos-1)-(i)));
						//writeoutput("|"&curString&"|<br />");
						ts=structnew();
						if(curTagName EQ "?xml"){
							ts.type="xmlText";
							ts.value="<?xml "&trim(curString)&" ?>";
						}else{
							ts.type="serverScriptText";
							ts.value=trim(curString);
						}
						
							ts.line=lastLine; 
							ts.column=lastColumn; 
							lastLine=currentLine;
							lastColumn=n-lineBeginPos; 
						arrayappend(arrE, ts);
						curString="";
						i=tagClosingPos;
						
						
					}
					tagRead=true;	
					continue;
				}else if(tagRead and c EQ "="){
					// store previous string as attrName
					if(attrRead EQ false or inSGMLAttr EQ false and trim(curString) NEQ ""){
						ts=structnew();
						ts.type="attributeName";
						ts.value=trim(curString);
						
							ts.line=lastLine; 
							ts.column=lastColumn; 
							lastLine=currentLine;
							lastColumn=i-lineBeginPos; 
						arrayappend(arrE, ts);
					}
					curString="";
					inSGMLAttr=true;
					attrRead=true;	
					continue;
				}else if(tagRead and trim(c) EQ ''){
					if(trim(curString) NEQ ""){
						if(inSGMLAttr){
							ts=structnew();
							if(curString CONTAINS "$"){
								local.a4=application.zcore.functions.zParseHtmlText(arrE, curString,currentLine, i-lineBeginPos, true); 
								if(isstruct(local.a4)){
									return local.a4;
								}else{
									arrE=local.a4;
								}
							}else{
								/*if(left(local.ct2,1) EQ "$" and right(local.ct2,1) EQ "$"){
									// expression
									ts.type="attributeValueExpression";
									ts.value=mid(curString,2,len(curString)-2);
								}else{*/
									ts.type="attributeValue";
									ts.value=curString;
								//}
								ts.line=lastLine; 
								ts.column=lastColumn; 
								lastLine=currentLine;
								lastColumn=i-lineBeginPos; 
								arrayappend(arrE, ts);
							}
							attrRead=false;
							inSGMLAttr=false;
							inAttr=false;
							inSingleQuoteAttr=false;
						}else{
							ts=structnew();
							ts.type="attributeName";
							ts.value=trim(curString);
							
							ts.line=lastLine; 
							ts.column=lastColumn; 
							lastLine=currentLine;
							lastColumn=i-lineBeginPos; 
							arrayappend(arrE, ts);
							attrRead=true;
						}
					}
					curString="";
					continue;
				}
			}
		}else{
			if(c EQ "<"){
				if(cn EQ "!"){
					if(cnn EQ "-" and cnnn EQ "-"){
						if(trim(curString) NEQ ""){
							local.a4=application.zcore.functions.zParseHtmlText(arrE, curString,currentLine, i-lineBeginPos);
							if(isstruct(local.a4)){
								return local.a4;
							}else{
								arrE=local.a4;
							}
								
							lastLine=currentLine;
							lastColumn=i-lineBeginPos;
						}
						curString="";
						// start comment
						inComment=true;
						continue;
					}else{
						// start tag comment like doctype
						curString="";
						inTagComment=true;
						continue;
					}
				}else{
					if(trim(cn) NEQ ""){
						// start tag
						if(cn EQ "/"){
							inClosingTag=true;
							i++;
						}
						if(trim(curString) NEQ ""){
							local.a4=application.zcore.functions.zParseHtmlText(arrE, curString,currentLine, i-lineBeginPos);
							if(isstruct(local.a4)){
								return local.a4;
							}else{
								arrE=local.a4;
							}
							lastLine=currentLine;
							lastColumn=i-lineBeginPos;
						}
						curString="";
						inTag=true;
						continue;
					}
				}
			}
		}
		curString&=c;
	}
	if(trim(curString) NEQ ""){
		local.a4=application.zcore.functions.zParseHtmlText(arrE, curString,currentLine, i-lineBeginPos);
		if(isstruct(local.a4)){
			return local.a4;
		}else{
			arrE=local.a4;
		}
		curString="";
	}
	rs.success=true;
	rs.error="";
	rs.arrHTML=arrE;
	return rs;
    </cfscript>
</cffunction>

<cffunction name="zParseHtmlText" localmode="modern" output="yes" returntype="any">
	<cfargument name="arrE" type="array" required="yes">
	<cfargument name="curString" type="string" required="yes">
	<cfargument name="lastLine" type="string" required="yes">
	<cfargument name="lastColumn" type="string" required="yes">
	<cfargument name="attributeValue" type="boolean" required="no" default="#false#">
	<cfscript>
	var ts=0;
	var rs={};
	local.matching3=true;
	local.curPos=1;
	local.curLen=len(arguments.curString);
	local.inVar3=false;
	local.lastStrPos=1;
	local.i3=1;
	//writeoutput("curString:"&arguments.curString&"<br />");
	if(arguments.attributeValue){
		ts=structnew()
		ts.type="text";
		ts.value='="';
		ts.line=arguments.lastLine; 
		ts.column=arguments.lastColumn; 
		arrayappend(arguments.arrE, ts);
	} 
	while(local.matching3){
		local.i3++;
		if(local.i3 GT 255){ 
			rs.error='Infinite loop occurred in skin template on last line: #lastLine#, last column: #lastColumn#';
			rs.success=false;
			return rs;
		}
		local.p4=find("$", arguments.curString, local.curPos);
		//writedump("pos:"&local.p4&"|"& arguments.curString<br />");
		if(local.p4 EQ 0) break;
		local.curPos=local.p4+1;
		if(local.curLen GTE local.p4){
			if(mid(arguments.curString, local.p4+1,1) EQ "$"){
				// literal $, keep going
				//writeoutput('found literal $<br />');
				arguments.curString=removechars(arguments.curString, local.p4+1,1);
				local.curPos=local.p4+1;
			}else{
				if(local.inVar3){
					// end of variable
					// extract it as a variable!
					local.inVar3=false;
					
					ts=structnew();
					ts.type="expression";
					ts.value="$"&replace(mid(arguments.curString, local.lastStrPos+1, local.p4-(local.lastStrPos+1)),"$$","$","all")&"$";
					local.lastStrPos=local.p4+1;
					ts.line=arguments.lastLine; 
					ts.column=arguments.lastColumn; 
					arrayappend(arguments.arrE, ts);
					
				}else{
					// start of a variable
					local.inVar3=true;
					
					// store the current string
					//writeoutput('cur len:'&(local.p4-local.lastStrPos)&'<br />');
					ts=structnew();
					ts.type="text";
					ts.value=trim(mid(arguments.curString, local.lastStrPos, local.p4-local.lastStrPos));
					local.lastStrPos=local.p4;
					if(ts.value NEQ ""){
						ts.line=arguments.lastLine; 
						ts.column=arguments.lastColumn; 
						arrayappend(arguments.arrE, ts);
					}
				}
			}
		}
	}
	arguments.curString=mid(arguments.curString, local.lastStrPos, (len(arguments.curString)+1)-local.lastStrPos);
	//writedump(arguments.arrE);
	if(local.inVar3){
		// error, variable never ended!	
		rs.error="""$"" is used for display variables and must be escaped by using two dollar signs instead like ""$$"".";
		rs.success=false;
		return rs;
	}
	if(trim(arguments.curString) NEQ ""){
		ts=structnew();
		ts.type="text";
		ts.value=arguments.curString;
		ts.line=arguments.lastLine; 
		ts.column=arguments.lastColumn; 
		arrayappend(arguments.arrE, ts);
	}
	if(arguments.attributeValue){
		ts=structnew()
		ts.type="text";
		ts.value='"';
		ts.line=arguments.lastLine; 
		ts.column=arguments.lastColumn; 
		arrayappend(arguments.arrE, ts);
	}
	return arguments.arrE;
	</cfscript>
</cffunction>

<!--- 
ts=structnew();
ts.arrHTML=rs.arrHTML;
ts.enableIndenting=true;
ts.enableXHTMLStrictOutput=true;
ts.enableUTF8=true;
ts.html5=true;
zRebuildXHTMLFromArray(ts); --->
<cffunction name="zRebuildXHTMLFromArray" localmode="modern" output="yes" returntype="struct">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var i=0;
	var previousType='';
	var arrT2='';
	var inMeta='';
	var c=0;
	var arrR=arraynew(1);
	var nextType=0;
	var curLevel=0;
	var indent="";
	var rs2=0;
	var n=0;
	var tempDisableIndenting=false;
	var lineBreakBackup=chr(10);
	var lastDisableIndentingState=false;
	var indentBackup="";
	var tempCompareValue=0;
	var indentString=chr(9);
	var inHTMLTag=false;
	var cdataString="";
	var cdataEndString="";
	var inBlockElement=false;
	var inPElement=false;
	var utf8enabled=false;
	var inMetaElement=false;
	var inHeadElement=false;
	var inTempBlockElement=false;
	var xmlsnsfound=false;
	var inTheHTMLElement=false;
	var inBodyElement=false;
	var inMetaCharsetTag=false;
	var curOpenRIndex=0;
	var curOpenIIndex=0;
	var tempFuncName=0;
	var lineBreak=0;
	var curIndent="";
	var tempFuncName2=0;
	var ts2=structnew();
	var rs=structnew();
	rs.success=true;
	rs.result="";
	rs.error="";
	rs.line=0;
	ts2.html5=true;
	ts2.enableIndenting=true;
	ts2.enableXHTMLStrictOutput=true;
	ts2.enableUTF8=true;
	structappend(arguments.ss,ts2,false);
	if(arguments.ss.enableIndenting EQ false){
		lineBreak="";
		indentString="";	
	}
	local.arrValue=[];
	local.isHTML=false; 
	//writedump(arguments.ss.arrHTML);
	local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, "", local.isHTML, true);
	for(i=1;i LTE arraylen(arguments.ss.arrHTML);i++){
		c=arguments.ss.arrHTML[i];
		if(i+1 LTE arraylen(arguments.ss.arrHTML)){
			nextType=arguments.ss.arrHTML[i+1].type;
		}else{
			nextType="";
		}
		if(i-1 GT 0){
			previousType=arguments.ss.arrHTML[i-1].type;
		}else{
			previousType="";
		}
		if(structkeyexists(c,'level')){
			curLevel=c.level;	
		}
		indentBackup="";
		if(left(c.value,2) EQ "cf"){
			arrT2=listtoarray(c.value," ");
			tempCompareValue=arrT2[1];
		}else{
			tempCompareValue=c.value;
		}
		for(n=1;n LTE curLevel;n++){
			if((c.type EQ "htmlTag" or c.type EQ "coldfusionTag") and n EQ 1 and structkeyexists(request.zHTMLElementsDecreateIndenting,tempCompareValue)){
				// skip
			}else{
				indentBackup&=indentString;
			}
		}
		if(c.type EQ "htmlTag"){
			inHTMLTag=true;
		}else if(c.type EQ "openHTMLTag" or c.type EQ "coldfusionTag" or c.type EQ "closeHTMLTag" or c.type EQ "closeColdfusionTag"){
			if(arguments.ss.enableUTF8 and c.type EQ "closeHTMLTag" and c.value EQ "head" and utf8enabled EQ false){
				if(arguments.ss.html5){
					local.tempValue=lineBreak&indent&'<meta charset="UTF-8" />';
				}else{
					local.tempValue=lineBreak&indent&'<meta charset="utf-8" />';
				}
				local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, local.tempValue, local.isHTML, true);
			}
		}
		if((c.type EQ "openHTMLTag" or c.type EQ "htmlTag" or c.type EQ "coldfusionTag" or c.type EQ "endHTMLTag" or c.type EQ "closeHTMLTag" or c.type EQ "closeColdfusionTag" or c.type EQ "comment") and structkeyexists(request.zHTMLInlineElements, tempCompareValue)){
			tempDisableIndenting=true;
		}else{
			tempDisableIndenting=false;
		}
		cdataString="";
		cdataEndString="";
		if(c.type EQ "htmlTag" or c.type EQ "openHTMLTag" or c.type EQ "for" or c.type EQ "if" or c.type EQ "else"){// or c.type EQ "elseif" or c.type EQ "endif" or c.type EQ "endfor"){ 
			curOpenRIndex=arraylen(arrR);
			curOpenIIndex=i;
		}
		if(arguments.ss.enableXHTMLStrictOutput){
			if(c.type EQ "htmlTag"){
				if(c.value EQ "meta"){
					inMetaElement=true;
				}
			}else if(c.type EQ "endHTMLTag"){
				if(c.value EQ "meta"){
					inMetaElement=false;
					if(inMetaCharsetTag){
						while(arraylen(arrR) GT curOpenRIndex){
							arraydeleteat(arrR,arraylen(arrR));	
						}
						inMetaCharsetTag=false;
						continue;
					}
				}else if(c.value EQ "body"){
					inBodyElement=true;
				}
			}else if(c.type EQ "openHTMLTag"){
				if(structkeyexists(request.zHTMLBlockElements, c.value)){
					inBlockElement=true;
				}
				if(c.value EQ "head"){
					inHeadElement=true;
				}else if(c.value EQ "p"){
					inPElement=true;
				}
			}else if(c.type EQ "closeHTMLTag"){
				if(structkeyexists(request.zHTMLBlockElements, c.value)){
					inBlockElement=false;
				}
				if(c.value EQ "head"){
					inHeadElement=false;
				}else if(c.value EQ "p"){
					inPElement=false;
				}else if(c.value EQ "body"){
					inBodyElement=false;
				} 
			}
			if(c.type EQ "openHTMLTag" or c.type EQ "htmlTag" or c.type EQ "endHTMLTag" or c.type EQ "coldfusionTag" or c.type EQ "closeHTMLTag" or c.type EQ "closeColdfusionTag"){
				if(arguments.ss.enableXHTMLStrictOutput and c.type NEQ "coldfusionTag" and left(c.value,2) EQ "z_"){
					cdataString="<![CDATA[";
					cdataEndString="]]>";
				}
			}
		}
		if((tempDisableIndenting EQ false and c.type NEQ "text" and c.type NEQ "expression") or (lastDisableIndentingState EQ false and previousType NEQ "text" and previousType NEQ "expression") or (tempDisableIndenting EQ false and inBlockElement EQ false)){
			lineBreak=lineBreakBackup;
			indent=indentBackup;
		}else{
			indent="";
			lineBreak="";	
		}
		if(c.type NEQ "endHTMLTag"){
			local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, cdataString, local.isHTML, true);
		}
		/*
		if(inBodyElement and arguments.ss.enableXHTMLStrictOutput){
			if(inBlockElement){
				if(inTempBlockElement){
					//arrayappend(local.arrValue,lineBreak&indent&'</div>');
					//inTempBlockElement=false;
				}
			}else if(inHeadElement EQ false and inBlockElement EQ false){
				if(inTempBlockElement EQ false){
					if(c.type EQ "text" or c.type EQ "expression"){
						//arrayappend(local.arrValue,lineBreak&indent&'<div>');
						//inTempBlockElement=true;
					}else if(c.type EQ "openHTMLTag" and structkeyexists(request.zHTMLBlockElements, c.value) EQ false){
						//arrayappend(local.arrValue,lineBreak&indent&'<div>');
						//inTempBlockElement=true;
						
					}
				}
			}
		}*/
		if(c.type EQ "openHTMLTag" or c.type EQ "htmlTag" or c.type EQ "coldfusionTag"){
			local.tempValue=lineBreak&indent&'<';
			local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, local.tempValue, local.isHTML, true);
		}else if(c.type EQ "comment"){
			if(arguments.ss.enableXHTMLStrictOutput and left(c.value,9) EQ '<!DOCTYPE'){
				c.value='<!DOCTYPE html>';
			}else if(left(c.value, 5) EQ '<'&'!---'){
				c.value='';
			}
			local.tempValue=lineBreak&indent;
			local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, local.tempValue, local.isHTML, true);
		}else if(c.type EQ "closeHTMLTag" or c.type EQ "closeColdfusionTag"){
			local.tempValue=lineBreak&indent&'</';
			local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, local.tempValue, local.isHTML, true);
		}
		if(lineBreak NEQ "" and (c.type EQ "scriptText" or c.type EQ "text" or c.type EQ "serverScriptText" or c.type EQ "expression")){
			if(previousType != "" and structkeyexists(request.zHTMLBlockElements, arguments.ss.arrHTML[i-1].value)){
				local.tempValue=lineBreak&indent;
				local.newState=true;
				if(c.type EQ "expression"){
					local.newState=false;
				}
				local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, local.tempValue, local.isHTML, local.newState);
			}
			c.value=replace(c.value,lineBreak,lineBreak&indent,"ALL");
			
		}
		
		if(c.type EQ "expression"){
			
			rs2=application.zcore.functions.zSkinProcessVars(c.value);
			if(rs2.success EQ false){
				rs2.error="Expression parsing failed because: "&rs2.error;
				return rs2;
			}
			c.value=rs2.result;
			local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, c.value, local.isHTML, false);
			c.value="";
		}
		if(c.type EQ "openHTMLTag" and c.value EQ "html"){
			inTheHTMLElement=true;
		}
		if(c.type EQ "attributeName"){
			local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, " ", local.isHTML, true);
			if(inTheHTMLElement and c.value EQ "xmlns"){
				xmlsnsfound=true;
			}
		}
		if(c.type EQ "endHTMLTag"){
			if(inHTMLTag){
				if(arguments.ss.enableXHTMLStrictOutput and xmlsnsfound EQ false and c.value EQ "html"){
					c.value='html xmlns="http://www.w3.org/1999/xhtml"';
				}
				if(not structkeyexists(request.zHTMLBlockElements, c.value)){
					arrayappend(local.arrValue," /");	
				}
				inHTMLTag=false;
			}else if(inMetaCharsetTag){
				inMetaCharsetTag=false;
				continue;	
			}
			if(left(c.value,1) EQ "?"){
				local.tempValue=" ?>";
			}else if(left(c.value,1) EQ "%"){
				local.tempValue=" %>";
			}else{
				local.tempValue=">";
			}
			local.tempValue&=cdataEndString;
			local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, local.tempValue, local.isHTML, true);
		}else if(structkeyexists(application.sitestruct[request.zos.globals.id].skinObj.widgetFunctions, "z"&c.type)){
			if(c.type EQ "for"){
				tempFuncName="zloop";
			}else if(c.type EQ "endfor"){
				tempFuncName="zendloop";
			}else{
				tempFuncName="z"&c.type;
			}
			if(tempFuncName EQ "zif" or tempFuncName EQ "zelseif" or tempFuncName EQ "zelse" or tempFuncName EQ "zloop"){
				if(tempFuncName EQ "zif"){
				}else if(tempFuncName EQ "zloop"){
					curLevel--;
				}
				curIndent="";
				for(n=1;n LTE curLevel;n++){
					curIndent&=indentString;
				}
				indentBackup=curIndent&indentString;
				indent=indentBackup;
				
			}else if(tempFuncName EQ "zendif" or tempFuncName EQ "zendloop"){
				//curLevel--;
				curIndent="";
				for(n=0;n LTE curLevel;n++){
					curIndent&=indentString;
				}
				indentBackup=curIndent;
				indent=indentBackup;
				curIndent&=indentString;
			}
			
			tempFuncName2=application.sitestruct[request.zos.globals.id].skinObj.widgetFunctions[tempFuncName];
			rs=tempFuncName2(arguments.ss.arrHTML, i, removechars(tempFuncName, 1,1));
			if(rs.success EQ false){
				rs.line=c.line;
				return rs;
			}
			arguments.ss.arrHTML=rs.result;
			
			local.tempValue=lineBreak&indent&arguments.ss.arrHTML[i].value;
			local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, local.tempValue, local.isHTML, false);
			inHTMLTag=false;
			inMetaCharsetTag=false;
			inMeta=false;
			inTheHTMLElement=false;
			inTempBlockElement=false;
			continue;
		}else if((c.type EQ "attributeValue")){
			if(previousType EQ "attributeName"){
				if(arguments.ss.arrHTML[i-1].value EQ "http-equiv" or arguments.ss.arrHTML[i-1].value EQ "charset"){
					if(inMetaElement){
						inMetaCharsetTag=true;
						
					}
				}else if(left(arguments.ss.arrHTML[i-1].value,6) EQ "data-z"){ 
					tempFuncName=removeChars(arguments.ss.arrHTML[i-1].value,1,5);
					if(structkeyexists(application.sitestruct[request.zos.globals.id].skinObj.widgetFunctions,tempFuncName) EQ false){
						rs.success=false;
						rs.error="""#tempFuncName#"" is not a valid skin widget.  Any attribute name starting with ""data-z"" must be in the documentation.";
						rs.line=c.line;
						return rs;
						//application.zcore.template.fail("""#tempFuncName#"" is an invalid function in template.");
					}else{
						if(tempFuncName EQ "zif" or tempFuncName EQ "zelseif" or tempFuncName EQ "zelse" or tempFuncName EQ "zloop"){
							if(tempFuncName EQ "zif"){
								//curLevel++;
							}else if(tempFuncName EQ "zloop"){
								curLevel--;
							}
							curIndent="";
							for(n=1;n LTE curLevel;n++){
								curIndent&=indentString;
							}
							//c.value=replace(c.value,lineBreak,lineBreak&indent,"ALL");
							indentBackup=curIndent&indentString;
							indent=indentBackup;
							
						}else if(tempFuncName EQ "zendif" or tempFuncName EQ "zendloop"){
							curIndent="";
							for(n=0;n LTE curLevel;n++){
								curIndent&=indentString;
							}
							indentBackup=curIndent;
							indent=indentBackup;
							curIndent&=indentString;
						}
						tempFuncName2=application.sitestruct[request.zos.globals.id].skinObj.widgetFunctions[tempFuncName];
						rs=tempFuncName2(arguments.ss.arrHTML, curOpenIIndex, removechars(tempFuncName, 1,1));
						if(rs.success EQ false){
							rs.line=c.line;
							return rs;
						}
						arguments.ss.arrHTML=rs.result;
						while(arraylen(arrR) GT curOpenRIndex+1){
							arraydeleteat(arrR,arraylen(arrR));	
						}
						i=curOpenIIndex;
						local.tempValue=lineBreak&indent&arguments.ss.arrHTML[curOpenIIndex].value;
						local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, local.tempValue, local.isHTML, false);
						inHTMLTag=false;
						inMetaCharsetTag=false;
						inMeta=false;
						inTheHTMLElement=false;
						inTempBlockElement=false;
						continue;
					}
				}
			}
			if(arguments.ss.enableUTF8 and inMetaElement and c.value CONTAINS 'text/html;'){
				utf8enabled=true;
				c.value='text/html; charset=utf-8';
			}
			
			local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, '="'&c.value&'"', local.isHTML, true);
		}else{
			
			if(arguments.ss.enableXHTMLStrictOutput and c.type EQ "scriptText" and c.type DOES NOT CONTAIN "<![CDATA["){
				local.tempValue="/* <![CDATA[ */"&c.value&"/* ]]> */";
			}else{
				local.tempValue=c.value;
			}
			local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, local.tempValue, local.isHTML, true);
		}
		if(c.type EQ "closeColdfusionTag" or c.type EQ "coldfusionTag" or c.type EQ "closeHTMLTag"){
			local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrValue, ">"&cdataEndString, local.isHTML, true);
		}
		lastDisableIndentingState=tempDisableIndenting;
		local.curValue=arrayToList(local.arrValue, '');
		arrayAppend(arrR, local.curValue);
		local.arrValue=[];
	}
	local.curValue=arrayToList(local.arrValue, '');
	local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrR, local.curValue, local.isHTML, local.isHTML);
	if(local.isHTML){
		arrayAppend(arrR, '");');
	}
	/*if(local.isHTML){
		local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrR, local.curValue, local.isHTML, false);
	}else{
		local.isHTML=application.zcore.functions.zSkinBarrierChange(local.arrR, local.curValue, local.isHTML, true);
	}*/
	
	//writedump(arrR);
	//abort;
	rs.result=replace(replace(arraytolist(arrR,""),"&","&amp;","ALL"),"&amp;amp;","&amp;","ALL");
	rs.result=replace(rs.result, 'writeoutput("#chr(10)#");', '', 'all');
	rs.result=replace(rs.result, 'writeoutput("");', '', 'all');
	rs.result=replace(rs.result, '");//writeoutput#chr(10)#writeoutput("', "", "all");
	rs.result='<cfscript>'&replace(rs.result, '");//writeoutput', "", "all")&'</cfscript>';
	//writeoutput('<textarea name="rrr" cols="100" rows="100">'&htmleditformat(rs.result)&'</textarea>');
	//abort;
	return rs;
	</cfscript>
</cffunction>

<cffunction name="zSkinBarrierChange" localmode="modern">
	<cfargument name="arrValue" type="array" required="yes">
	<cfargument name="newValue" type="string" required="yes">
	<cfargument name="isHTML" type="boolean" required="yes">
	<cfargument name="newState" type="boolean" required="yes">
	<cfscript>
	local.returnState=true;
	if(arguments.isHTML){
		if(arguments.newState){
			local.returnState=true;
			arrayAppend(arguments.arrValue, replace(arguments.newValue, '"', '""', 'all'));
		}else{
			arrayAppend(arguments.arrValue, '");'&chr(10));
			arrayAppend(arguments.arrValue, arguments.newValue);
			local.returnState=false;
		}
	}else{
		if(arguments.newState){
			arrayAppend(arguments.arrValue, chr(10)&'writeoutput("');
			local.returnState=true;
		}else{
			local.returnState=false;
		}
		arrayAppend(arguments.arrValue, arguments.newValue);
	}
	return local.returnState;
	</cfscript>
</cffunction>

<!--- zHtmlRemoveServerSideScriptsFromArray(arrDoc, allowColdfusion); --->
<cffunction name="zHtmlRemoveServerSideScriptsFromArray" localmode="modern" output="no" returntype="array">
	<cfargument name="arrDoc" type="array" required="yes">
    <cfargument name="allowColdfusion" type="boolean" required="no" default="#false#">
    <cfscript>
	var i=0;
	var c=0;
	var arrR=arraynew(1);
	var length=arraylen(arguments.arrDoc);
	var nextType=0;
	for(i=1;i LTE length;i++){
		c=arguments.arrDoc[i];
		if(arguments.allowColdfusion EQ false){
			if(c.type EQ "closeColdfusionTag" or c.type EQ "coldfusionTag" or c.type EQ "coldfusionScriptText"){
				continue;
			}
		}
		if(c.type NEQ "serverScriptText"){
			if((c.type EQ "openHtmlTag" or c.type EQ "endHTMLTag" or c.type EQ "closeHTMLTag")){
				if(c.value EQ "?xml" or (left(c.value,1) NEQ "?" and left(c.value,1) NEQ "%")){
					arrayAppend(arrR,c);
				}
			}else{
				arrayAppend(arrR,c);
			}
		}
	}
	return arrR;
	</cfscript>
</cffunction>


<cffunction name="zGetLineFromVariable" localmode="modern" output="no" returntype="any">
	<cfargument name="varName" type="string" required="yes">
    <cfargument name="line" type="numeric" required="yes">
    <cfscript>
	var i=0;
	var arrR=arraynew(1);
	var arrLines=listtoarray(replace(arguments.varName,chr(13),"","ALL"),chr(10),true);
	if(arguments.line EQ 0 or arguments.line GT arraylen(arrLines)){
		return "";
	}else{
		for(i=max(1,arguments.line-2);i LTE min(arguments.line+2,arraylen(arrLines));i++){
			if(i EQ arguments.line){
				arrayappend(arrR,'###i#: <strong style="color:##C00;">'&htmleditformat(arrLines[i])&'</strong>');
			}else{
				arrayappend(arrR,"###i#: "&htmleditformat(arrLines[i]));
			}
		}
	}
	return '<div style="border:1px solid ##B00; overflow:auto; padding:20px; margin-top:10px;">'&arraytolist(arrR,"<br />"&chr(10))&'</div>';
	</cfscript>
</cffunction>

<cffunction name="zParseSkinExpression" localmode="modern" returntype="any" output="yes">
	<cfargument name="e" type="string" required="yes">
	<cfargument name="line" type="numeric" required="yes">
	<cfargument name="zoutEnabled" type="boolean" required="no" default="#false#">
 	<cfscript>
	var arrCurOp=arraynew(1);
	var curCharCountBackup='';
	var rs2='';
	var curString='';
	var i=1;
	var parenthesisDepth=0;
	var rs=structnew();
	var arrCurOP=arraynew(1);
	var opMatch=false;
	var eBackup=arguments.e;
	var inDoubleQuote=false;
	var arrString=0;
	var newstring=0;
	var lastChar=0;
	var firstChar=0;
	var curChar=0;
	var nextChar=0;
	var previousType=0;
	var previouspreviousType=0;
	//var parenthesisDepth=0;
	var nextType=0;
	var curType=0;
	var i2=0;
	var arrF=0;
	var inSingleQuote=false;
	var wordCount=0;
	var stringType=0;
	var arrRebuild=0;
	var stringFound=0;
	//var zoutlastchar=0;
	var curCharCount=0;
	//var arrString=0;
	var mcc=0;
	var mcc2=0;
	var curF=0;
	var curFReplaceValue=0;
	var i3=0;
	var p=0;
	var endExpressionNow=false;
	var endParenthesisNow=0;
	var curPpos1=0;
	var len1=0;
	var len2=0;
	var len3=0;
	var currentLine=arguments.line;
	rs.error="";
	rs.arrTokenType=arraynew(1);
	rs.arrTokens=arraynew(1);
	rs.arrLength=arraynew(1);
	rs.success=true;
	rs.result=true;
	rs.currentline=0;
	//arguments.e=replace(replace(replace(arguments.e,chr(10),' ','ALL'),chr(13),' ','ALL'),chr(9),' ','ALL');
	//arguments.e=replace(replace(replace(replace(arguments.e,'\}',chr(9),'ALL'),'&quot;','"',"ALL"),"\'",chr(10),"ALL"),'\"',chr(13),"ALL");
	//arguments.e=replace(replace(replace(arguments.e,'&quot;','"',"ALL"),"\'",chr(10),"ALL"),'\"',chr(13),"ALL");
	if(arguments.zoutEnabled and left(arguments.e,1) EQ "$"){
		arguments.e=removeChars(arguments.e,1,1);
		curCharCount=curCharCount+1;
		//writeoutput("out enabled:"&e	&"<br />");
	}  
	/*if(right(arguments.e, 1) EQ "$"){
		arguments.e=left(arguments.e, len(arguments.e)-1);
	}*/ 
	arguments.e=replacenocase(arguments.e,'&gt;','>',"ALL");
	arguments.e=replacenocase(arguments.e,'&lt;','<',"ALL");
	arguments.e=replacenocase(arguments.e,'&quot;','"',"ALL");
	arguments.e=replacenocase(arguments.e,'&amp;','&',"ALL");
	arguments.e=trim(replace(arguments.e,"$"," $ ","ALL"));
	arguments.e=replace(replace(arguments.e,")"," ) ","ALL"),"("," ( ","ALL");
	arrF=listtoarray(arguments.e," ",true); 
	for(i=1;i LTE arraylen(arrF);i++){
		opMatch=false;
		//curCharCount+=len(arrF[i]);
		len1=len(arrF[i]);
		curCharCountBackup=curCharCount;
		len3=len(replace(arrF[i],chr(10),"","ALL"));
		if(len1-len3 GT 0){
			currentLine =currentline+(len1-len3);
		}
		arrF[i]=trim(arrF[i]);
		len2=len1-len(arrF[i]);
		if(i NEQ 1){
			curCharCount++;
		}
		if(len2 GT 0){
			curCharCount+=len2;
		} 
		if(arrF[i] EQ "" or (i EQ arraylen(arrF) and arrF[i] EQ "$")) continue;
		endParenthesisNow=false;
		firstChar=left(arrF[i],1);
		lastChar=right(arrF[i],1);
		if(arguments.zoutEnabled){
			if(arraylen(rs.arrTokenType) NEQ 0){
				previousType=rs.arrTokenType[arraylen(rs.arrTokenType)];
				if(previousType EQ "operator" or previousType EQ "and" or previousType EQ "or"){
					rs.error=('When outputing data, "$variable$", you can''t use "AND", "OR" or operators like "EQUALS", etc.');// Check your syntax on line ###arguments.line#');
					rs.success=false;
					rs.line=currentLine;
					return rs;
				}
			}
			if(arrF[i] CONTAINS "$"){
				if(arraylen(rs.arrTokenType) NEQ 0){
					previousType=rs.arrTokenType[arraylen(rs.arrTokenType)];
					if(previousType EQ "end parenthesis" or previousType EQ "variable"){
						//writeoutput('i here23:#i#<br />'); 
						/*
						p=find(":",arrF[i]);
						curCharCount=(curCharCount-len(arrF[i]))+(p+1);*/
						rs.curCharCount=curCharCount;
						rs.line=currentLine;
						//rs.zoutlastchar=0;//curCharCount;
						break;
					}
				}
			}
					//application.zcore.functions.zabort();
		}
		if(firstChar EQ "("){
			if(arraylen(rs.arrTokenType) NEQ 0){
				previousType=rs.arrTokenType[arraylen(rs.arrTokenType)];
				if(previousType EQ "end parenthesis"){
					rs.error=('You must use an operator or "AND" or "OR" between ending and starting parenthesis.');// Check your syntax on line ###arguments.line#');
					rs.success=false;
					rs.line=currentLine;
					return rs;
				}
			}
			
			if(arraylen(rs.arrTokenType) NEQ 0){
				previousType=rs.arrTokenType[arraylen(rs.arrTokenType)];
				if(previousType EQ "operator"){
					rs.error=('There can''t be an operator before a opening parenthesis.');//  Check your syntax on line ###arguments.line#.');
					rs.success=false;
					rs.line=currentLine;
					return rs;
				}
				if(arraylen(rs.arrTokenType)-1 GT 0){
					previouspreviousType=rs.arrTokenType[arraylen(rs.arrTokenType)-1];
					if(previousType EQ "start parenthesis" and previouspreviousType EQ "variable"){
						rs.error=('Missing "AND" or "OR" after variable and before the parenthesis. Functions are not allowed in expressions.');//  Check your syntax on line ###arguments.line#');
						rs.success=false;
						rs.line=currentLine;
						return rs;
					}
				}
			}
			parenthesisDepth++;
			arrayappend(rs.arrTokenType, "start parenthesis");	
			arrayappend(rs.arrTokens, "(");	
			arrayappend(rs.arrLength, 1);
			arrF[i]=removeChars(arrF[i],1,1); 
		}else if(firstChar EQ ")"){
			arrF[i]=removeChars(arrF[i],1,1);
			if(parenthesisDepth GT 0){
				arrayappend(rs.arrTokenType, "end parenthesis");	
				arrayappend(rs.arrTokens, ")");
				arrayappend(rs.arrLength, 1);	
				endParenthesisNow=true; 
				// evaluate previous logic and set entire parenthesis expression to true or false to simplify the result
				parenthesisDepth--;
			}else{
				rs.error=('Too many closing parenthesis ")".  Check for an equal number of opening "(" and closing ")" parenthesis in your logic.');// on line ###arguments.line#.');
				rs.success=false;
				rs.line=currentLine;
				return rs;
			}
		}
		
		if(arrF[i] EQ "") continue;
		
		if(lastChar EQ ")"){
			arrF[i]=removeChars(arrF[i],len(arrF[i]),1);
			if(parenthesisDepth GT 0){
				arrayappend(rs.arrTokenType, "end parenthesis");	
				arrayappend(rs.arrTokens, ")");	
				arrayappend(rs.arrLength, 1);
				endParenthesisNow=true; 
				// evaluate previous logic and set entire parenthesis expression to true or false to simplify the result
				parenthesisDepth--; 
			}else{
				rs.error=('Too many closing parenthesis ")".  Check for an equal number of opening "(" and closing ")" parenthesis in your logic');// on line ###arguments.line#.');
				rs.success=false;
				rs.line=currentLine;
				return rs;
			}
		}else if(lastChar EQ "(" and arrF[i] NEQ ""){
			arrF[i]=removeChars(arrF[i],len(arrF[i]),1);
			parenthesisDepth++;
			if(wordCount EQ i){
				rs.error=('Parenthesis opened without a closing parenthesis ")".  Check for an equal number of opening "(" and closing ")" parenthesis in your logic on line ###arguments.line#.');
			}else{
				if(arraylen(rs.arrTokenType) NEQ 0){
					previousType=rs.arrTokenType[arraylen(rs.arrTokenType)];
					if(previousType EQ "end parenthesis"){
						rs.error=('You must use an operator or "AND" or "OR" between ending and starting parenthesis.');// Check your syntax on line ###arguments.line#');
						rs.success=false;
						rs.line=currentLine;
						return rs;
					}
				}
				if(arraylen(rs.arrTokenType) NEQ 0){
					previousType=rs.arrTokenType[arraylen(rs.arrTokenType)];
					if(previousType EQ "operator"){
						rs.error=('There can''t be an operator before a opening parenthesis.');//  Check your syntax on line ###arguments.line#.');
						rs.success=false;
						rs.line=currentLine;
						return rs;
					}
					if(arraylen(rs.arrTokenType)-1 GT 0){
						previouspreviousType=rs.arrTokenType[arraylen(rs.arrTokenType)-1];
						if(previousType EQ "start parenthesis" and previouspreviousType EQ "variable"){
							rs.error=('Missing "AND" or "OR" after variable and before the parenthesis. Functions are not allowed in expressions.');//  Check your syntax on line ###arguments.line#');
							rs.success=false;
							rs.line=currentLine;
							return rs;
						}
					}
				}
				arrayappend(rs.arrTokenType, "start parenthesis");	
				arrayappend(rs.arrTokens, "(");	
				arrayappend(rs.arrLength, 1);
			}
		}
		
		if(arrF[i] EQ "") continue;
		
		if(left(arrF[i],1) EQ "("){
			rs.error=('You must use "AND" or "OR" between expressions or parenthesis groups.');//  Check your syntax on line ###arguments.line#.');
			rs.success=false;
			rs.line=currentLine;
			return rs;
		}else if(left(arrF[i],1) EQ ")"){
			rs.error=('You must use "AND" or "OR" between expressions or parenthesis groups.');//  Check your syntax on line ###arguments.line#.');
			rs.success=false;
			rs.line=currentLine;
			return rs;
		}
		stringType=left(arrF[i],1);
		if(stringType EQ "'" or stringType EQ '"' or stringType EQ '{'){
			if(stringType EQ "{"){
				if(arraylen(rs.arrTokenType) EQ 0){
					rs.error=('"{" can only be used inside parenthesis as a JSON string.');//  Check your syntax on line ###arguments.line#.');
					rs.success=false;
					rs.line=currentLine;
					return rs;
				}
				previousType=rs.arrTokenType[arraylen(rs.arrTokenType)];
				if(previousType NEQ "start parenthesis"){
					rs.error=('"{" can only be used inside parenthesis as a JSON string.');//  Check your syntax on line ###arguments.line#.');
					rs.success=false;
					rs.line=currentLine;
					return rs;
				}
				curCharCount=curCharCountBackup;
				//application.zcore.functions.zdump(arrF);
				for(i2=1;i2 LT i;i2++){
					//writeoutput('deleting:'&arrF[1]&'<br />');
					arraydeleteat(arrF,1);
				}
				newString=arrayToList(arrF," "); 
				//writeoutput('newStringbefore:'&newString&'<br /><br />');
				newString=replace(replace(replace(newString," $ ","$","ALL")," ( ","(","ALL")," ) ",")","ALL");
				rs2=application.zcore.functions.zParseJsonString(newString, arguments.line);
				
				if(rs2.success){ 
					curCharCount+=rs2.curCharCount;
					newString=removeChars(newString,1,rs2.lastCharPos+1);
					newString=replace(replace(replace(newString,"$"," $ ","ALL"),"("," ( ","ALL"),")"," ) ","ALL");
				//writeoutput('newStringafter:'&newString&'<br /><br />');
					arrF=listtoarray(newString," ",true);
					i=0;
					for(i2=1;i2 LTE arraylen(rs2.arrTokens);i2++){
						arrayappend(rs.arrTokenType, rs2.arrTokenType[i2]);
						arrayappend(rs.arrTokens, rs2.arrTokens[i2]);
						arrayappend(rs.arrLength, rs2.arrLength[i2]);
					} 
					continue;
					
				}else{
					rs.success=false;
					rs.error=rs2.error;
					rs.column=rs2.column;
					rs.line=currentLine;
					return rs; 
				}
				
			}else{ 
				for(i2=1;i2 LT i;i2++){
					//writeoutput(arrF[1]&"-deleted<br />");
					arraydeleteat(arrF,1);
				}
				
				stringFound=false;
				newString=arrayToList(arrF," ");
				//application.zcore.functions.zdump(arrF);
				//writeoutput("before|"&newString&"|"&mid(newString,i-1,1)&"|<br />");
				
				arrString=arraynew(1);
				for(i2=2;i2 LTE len(newString);i2++){
					curChar=mid(newString,i2,1);
					nextChar="";
					if(i+1 LTE len(newString)){
						nextChar=mid(newString,i2+1,1);
					}
					if(curChar EQ "\" and nextChar EQ "\"){
						arrayappend(arrString, "\");
						i2++;
						continue;
					}else if(curChar EQ "\" and nextChar EQ stringType){
						arrayappend(arrString, stringType);
						i2++;
						continue;
					}else if(curChar EQ stringType){
						curString=arraytolist(arrString,"");	
						curString=replace(replace(replace(curString," $ ","$","ALL")," ( ","(","ALL")," ) ",")","ALL"); 
						//writeoutput("curString:"&curString&"<br />");
						arrString=arraynew(1);
						if(arraylen(rs.arrTokenType) NEQ 0){
							previousType=rs.arrTokenType[arraylen(rs.arrTokenType)];
							if(previousType EQ "string" or previousType EQ "boolean" or previousType EQ "number" or previousType EQ "variable"){
								rs.error=('There can''t be a #previousType# value before a string.');//  Check your syntax on line ###arguments.line#.');
								rs.success=false;
								rs.line=currentLine;
								return rs;
							}
						}
						//writeoutput('curString:'&curString&'<br />');
						arrayappend(rs.arrTokenType,"string");
						arrayappend(rs.arrTokens,curString);
						arrayappend(rs.arrLength, len(replace(replace(curString,'\','\\','all'),stringType,"\"&stringType,"ALL"))+2);
						stringFound=true;
						//application.zcore.functions.zdump(arrF);
						newString=removeChars(newString,1,i2);
						//writeoutput("after|"&newString&"|<br />");
						arrF=listtoarray(newString," ",true);
						//application.zcore.functions.zdump(arrF);
						//application.zcore.functions.zabort();
						i=0;
						break;
					}else{
						arrayappend(arrString,curChar);	
					}
					
				}
				if(stringFound EQ false){
					rs.error=('A string was not closed.  Look for a missing single quote.');// on line ###arguments.line#.');
					rs.success=false;
					rs.line=currentLine;
					return rs;
				}
				continue; 
			}
		}
		if(refind("[a-zA-Z0-9_=]",left(arrF[i],1)) EQ 0){
			rs.error=('An expression, #arrayToList(arrF, '')# cannot start with "#left(arrF[i],1)#".');//  Check your syntax on line ###arguments.line#.');
			rs.success=false;
			rs.line=currentLine;
			return rs;
		}
		if(refind("[a-zA-Z0-9_]",right(arrF[i],1)) EQ 0){
			rs.error=('An expression, "#arrayToList(arrF, '')#", cannot end with "#right(arrF[i],1)#".');//  Check your syntax on line ###arguments.line#.');
			rs.success=false;
			rs.line=currentLine;
			return rs;
		}
		if(find(chr(10),arrF[i]) NEQ 0 or find(chr(13),arrF[i]) NEQ 0){
			rs.error=('An expression, '&arrayToList(arrF, '')&' cannot have a single or double quote in it.');//  Check your syntax on line ###arguments.line#.');
			rs.success=false;
			rs.line=currentLine;
			return rs;
		}
		if(refind("[a-zA-Z0-9_\.]*",arrF[i]) NEQ 1){
			rs.error=('An expression, "#arrayToList(arrF, '')#", is using an invalid character.  It must use only the following characters A-Z, 0-9, _ or . (period).');//  Check your syntax on line ###arguments.line#.');
			rs.success=false;
			rs.line=currentLine;
			return rs;
		}
		if(structkeyexists(request.zOPStruct.opStruct, arrF[i]) and arrF[i] NEQ "or" and arrF[i] NEQ "then" and arrF[i] NEQ "to"  and arrF[i] NEQ "exist"){//and arrF[i] NEQ "not"// and arrF[i] NEQ "equals"
			arrayappend(arrCurOP, arrF[i]);
			mcc=min(arraylen(arrF),i+5);
			for(i2=i+1;i2 LTE mcc;i2++){
				mcc2=false;
				curF=trim(arrF[i2]);
				curFReplaceValue="";
				if(left(curF,1) EQ "("){
					rs.error=('Missing "AND" or "OR" between expressions.');// on line ###arguments.line#.');
					rs.success=false;
					rs.line=currentLine;
					return rs;
				}
				if(right(curF,1) EQ ")"){
					if(len(curF) EQ 1){
						curF="";
					}else{
						curF=left(curF,len(curF)-1);
					}
					curFReplaceValue=")";
				}
				
				if(structkeyexists(request.zOPStruct.opStruct, curF)){
					arrayappend(arrCurOP, curF);
				}else{
					mcc2=true; 
					//writeoutput(curF&" | #i2#<br />");
				}
				if(curFReplaceValue EQ ")" or mcc2 or i2 EQ arraylen(arrF)){
					if(structkeyexists(request.zOPStruct.validOPStruct,arraytolist(arrCurOp," ")) EQ false){
						rs.error=('"#arraytolist(arrCurOp," ")#" is not a valid operator. It must be one of the following: #arraytolist(request.zOPStruct.arrValidOp,", ")#.');//  Check your syntax on line ###arguments.line#.');
						rs.success=false;
						rs.line=currentLine;
						return rs;
					}else{
						// move to next position
						//zdump(arrF);
						//	writeoutput('deleteing #arraylen(arrCurOp)#<br />');
						for(i3=1;i3 LTE arraylen(arrCurOp);i3++){
							//try{
							//writeoutput('deleteing wah'&arrF[i]&'<br />');
							arraydeleteat(arrF,i);
							//}catch(Any excpt){
							//writeoutput('fail: deleteing wah'&(i+(i3-1))&'<br />');
							//}
						}
						//zdump(arrF);
						//writeoutput(i2&"|"&i&"<br />");
						for(i3=1;i3 LT arraylen(arrCurOp)-2;i3++){
							arraydeleteat(rs.arrTokenType,arraylen(rs.arrTokenType));
							arraydeleteat(rs.arrTokens,arraylen(rs.arrTokens));	
						}
						/*if(i2 EQ arraylen(arrF)){
							i=i2+1; // this is the last word, so force it to stop looping.
						}else{
							i=i2-1;
						}*/
						//i=i2+1;
						//i=i2-(arraylen(arrCurOp)-2);
						if(i2-2 LT 1){
							rs.error=('These must be an expression before an operator occurs.');//  Check your syntax on line ###arguments.line#.');
							rs.success=false;
							rs.line=currentLine;
							return rs;
						}
						//arrF[i2-(arraylen(arrCurOp))]=arraytolist(arrCurOp," ");
						if(arraylen(arrF) LT i){
							
							arrayappend(arrF,arraytolist(arrCurOp," "));
						}else{
							arrayinsertat(arrF,i,arraytolist(arrCurOp," "));
						}
					}
					break;	
				}
			}
			if(arraylen(rs.arrTokenType) EQ 0){
				rs.error=('There must be an expression before an operator occurs.');//  Check your syntax on line ###arguments.line#.');
				rs.success=false;
				rs.line=currentLine;
				return rs;
			}else if(rs.arrTokenType[arraylen(rs.arrTokenType)] EQ "operator"){
				//zdump(rs);
				//zdump(arrF);
				rs.error=('There are 2 operators in a row without an expression in between.');//  Check your syntax on line ###arguments.line#.');
				rs.success=false;
				rs.line=currentLine;
				return rs;
			}
			
			if(arraylen(rs.arrTokenType) NEQ 0){
				previousType=rs.arrTokenType[arraylen(rs.arrTokenType)];
				if(previousType EQ "start parenthesis"){
					rs.error=('There can''t be an opening parenthesis before an operator.');//  Check your syntax on line ###arguments.line#.');
					rs.line=currentLine;
					rs.success=false;
					return rs;
				}else if(previousType EQ "end parenthesis"){
					if(arraylen(rs.arrTokenType)-1 NEQ 0){
						previousType=rs.arrTokenType[arraylen(rs.arrTokenType)-1];
						if(left(previousType,4) NEQ "json"){
							rs.error=('There can''t be a closing parenthesis before an operator unless it contained a JSON string.');//  Check your syntax on line ###arguments.line#.');
							rs.line=currentLine;
							rs.success=false;
							return rs;
						}
					}else{
						rs.error=('There can''t be a closing parenthesis before an operator unless it contained a JSON string.');//  Check your syntax on line ###arguments.line#.');
						rs.line=currentLine;
						rs.success=false;
						return rs;
					}
				}
			}
			arrayappend(rs.arrTokenType, "operator");	
			local.tempOperator=arraytolist(arrCurOp," ");
			if(local.tempOperator EQ "EQUALS"){
				local.tempOperator="EQ";
			}
			arrayappend(rs.arrTokens, local.tempOperator);	
			arrayappend(rs.arrLength, len(rs.arrTokens[arraylen(rs.arrTokens)]));
			arrCurOp=arraynew(1);
			//zdump(arrF);
			//opMatch=true;
			//writeoutput(i&' - fin i<br />');
			continue;
		}else{
			//opMatch=false;
		}
		
		//writeoutput('final:'&arrF[i]&'<br />');
		//if(opMatch EQ false){
		if(arrF[i] NEQ "()" and arrF[i] NEQ ""){
		//writeoutput('final2:'&arrF[i]&'<br />');
			if(endParenthesisNow){
				endParenthesisNow=false;
				arrayinsertat(rs.arrTokenType, arraylen(rs.arrTokenType), "variable");
				arrayinsertat(rs.arrTokens, arraylen(rs.arrTokens), arrF[i]);
			}else if(arrF[i] EQ "OR"){
				arrayappend(rs.arrTokenType, "OR");
				arrayappend(rs.arrTokens, "OR");
				arrayappend(rs.arrLength, 2);
			}else if(arrF[i] EQ "for"){
				arrayappend(rs.arrTokenType, "FOR");
				arrayappend(rs.arrTokens, "FOR");	
				arrayappend(rs.arrLength, 3);
			}else if(arrF[i] EQ "and"){
				arrayappend(rs.arrTokenType, "AND");
				arrayappend(rs.arrTokens, "AND");	
				arrayappend(rs.arrLength, 3);
			}else if(arrF[i] EQ "in"){
				arrayappend(rs.arrTokenType, "IN");
				arrayappend(rs.arrTokens, "IN");	
				arrayappend(rs.arrLength, 2);
			}else if(isnumeric(arrF[i])){
				arrayappend(rs.arrTokenType, "number");
				arrayappend(rs.arrTokens, arrF[i]);	
				arrayappend(rs.arrLength, len(arrF[i]));
			}else if(arrF[i] EQ "false"){
				arrayappend(rs.arrTokenType, "boolean");
				arrayappend(rs.arrTokens, false);
				arrayappend(rs.arrLength, 5);
			}else if(arrF[i] EQ "true"){
				arrayappend(rs.arrTokenType, "boolean");
				arrayappend(rs.arrTokens, true);		
				arrayappend(rs.arrLength, 4);
			}else{
				//writeoutput('final3:'&arrF[i]&"|"&rereplace(arrF[i],"([a-zA-Z0-9_\.]*)","")&'<br />');
				if(refind("[a-zA-Z_=]",left(arrF[i],1)) EQ 0){
					rs.error=('Variables can''t start with a number.  You can only use A to Z or an underscore "_".');// Check your syntax on line ###arguments.line#');
					rs.success=false;
					rs.line=currentLine;
					return rs;
				}else if(left(arrF[i],1) NEQ "=" and rereplace(arrF[i],"([a-zA-Z0-9_\.]*)","") NEQ ""){
					rs.error=('Variable names must only use the following characters: A to Z, 0 to 9, . (period), or an underscore "_" and they can''t start with a number.');// Check your syntax on line ###arguments.line#');
					rs.success=false;
					rs.line=currentLine;
					return rs;
				}
				arrayappend(rs.arrTokenType, "variable");
				arrayappend(rs.arrTokens, arrF[i]);	
				arrayappend(rs.arrLength, len(arrF[i]));
			}
			curType=rs.arrTokenType[arraylen(rs.arrTokenType)];
			if(arraylen(rs.arrTokenType)-1 GT 0){
				previousType=rs.arrTokenType[arraylen(rs.arrTokenType)-1];
				curPpos1=find(")",arrF[i]);
				if(curPpos1 NEQ 0 and curPpos1 LT len(arrF[i])){
					if(arguments.zoutEnabled){
						rs.error=('The expression should have ended after the closing parenthesis. When outputting data, ":variable:", you can''t use "AND", "OR" or operators like "EQUALS", etc.');// Check your syntax on line ###arguments.line#');
						rs.success=false;
						rs.line=currentLine;
						return rs;
					}else{
						rs.error=('You must use an operator or "AND" or "OR" between variables and parenthesis.'); // Check your syntax on line ###arguments.line#');
						rs.success=false;
						rs.line=currentLine;
						return rs;
					}
				}else if((curType EQ "variable" or curType EQ "string" or curType EQ "boolean" or curType EQ "number") and (previousType EQ "variable" or previousType EQ "string" or previousType EQ "boolean" or previousType EQ "number")){
					if(arguments.zoutEnabled){
						rs.error=('The expression should have ended after the closing parenthesis. When outputting data, "$variable$", you can''t use "AND", "OR" or operators like "EQUALS", etc.'); // Check your syntax on line ###arguments.line#');
						rs.success=false;
						rs.line=currentLine;
						return rs;
					}else{ 
						//writedump(curType&"|"&previousType);	writedump(request.zOPStruct.validOPStruct);writedump(arrF);abort;
						rs.error=('You must use an operator or "AND" or "OR" between variables.'); // Check your syntax on line ###arguments.line#');
						rs.success=false;
						rs.line=currentLine;
						return rs;
					}
				}else if((curType EQ "variable" or curType EQ "string" or curType EQ "boolean" or curType EQ "number") and previousType EQ "end parenthesis"){
					if(arguments.zoutEnabled){
						rs.error=('The expression should have ended after the closing parenthesis. When outputting data, "$variable$", you can''t use "AND", "OR" or operators like "EQUALS", etc.'); // Check your syntax on line ###arguments.line#');
						rs.success=false;
						rs.line=currentLine;
						return rs;
					}else{
						rs.error=('You must use an operator or "AND" or "OR" between variables and parenthesis.'); // Check your syntax on line ###arguments.line#');
						rs.success=false;
						rs.line=currentLine;
						return rs;
					}
				}else if((curType EQ "variable" or curType EQ "string" or curType EQ "boolean" or curType EQ "number") and left(previousType,4) EQ "json"){
					rs.error=('You can''t have additional values after a JSON statement.'); // Check your syntax on line ###arguments.line#');
					rs.success=false;
					rs.line=currentLine;
					return rs;
				}
				if(arraylen(rs.arrTokenType)-2 GT 0){
					previouspreviousType=rs.arrTokenType[arraylen(rs.arrTokenType)-2];
					//writeoutput('i try:'&curType&"|"&previousType&"|"&previouspreviousType&"<br />");
					if(curType NEQ "json" and previousType EQ "start parenthesis" and previouspreviousType EQ "variable"){
						rs.error=('Missing "AND" or "OR" after variable and before the parenthesis. Functions are not allowed in expressions.'); // Check your syntax on line ###arguments.line#');
						rs.success=false;
						rs.line=currentLine;
						return rs;
					}else if(curType NEQ "json" and previousType EQ "start parenthesis"){
						for(i2=arraylen(rs.arrTokenType)-1;i2 GTE 1;i2--){
							if(rs.arrTokenType[i2] NEQ "start parenthesis"){
								if(rs.arrTokenType[i2] EQ "variable"){//rs.arrTokenType[i2] EQ "boolean" or rs.arrTokenType[i2] EQ "number" or 
									rs.error=('Only a JSON string can be put inside the parenthesis directly after a variable.'); // Check your syntax on line ###arguments.line#');
									rs.success=false;
									rs.line=currentLine;
									return rs;
								}
								break;
							}
						}
					}
				}
				if(previousType EQ "operator"){
					if(structkeyexists(request.zOPStruct.validOPRightHandStruct,rs.arrTokens[arraylen(rs.arrTokens)-1])){
						// right hand value is required.
						if(curType NEQ "variable" and curType NEQ "boolean" and curType NEQ "number"){
							rs.error=('The operator, "#rs.arrTokens[arraylen(rs.arrTokens)-1]#", requires a variable, number or boolean value after it.'); // Check your syntax on line ###arguments.line#');
							rs.success=false;
							rs.line=currentLine;
							return rs;
						}
					}
				}
			}
		}
		//}
		
	}
	//writeoutput('final i:'&i&'<br />');
	//zdump(arrF);
	if(arraylen(rs.arrTokenType) GT 1){
		previousType=rs.arrTokenType[arraylen(rs.arrTokenType)];
		if(previousType EQ "operator"){
			//writeoutput('got here');
			if(structkeyexists(request.zOPStruct.validOPRightHandStruct,rs.arrTokens[arraylen(rs.arrTokens)])){
				// right hand value is required.
				rs.error=('The operator, "#rs.arrTokens[arraylen(rs.arrTokens)]#", requires a variable, number or boolean value after it.'); // Check your syntax on line ###arguments.line#');
				rs.success=false;
				rs.line=currentLine;
				return rs;
			}
		}
	}
	if(parenthesisDepth GT 0){
		rs.error=('Missing a closing parenthesis ")".  Check for an equal number of opening "(" and closing ")" parenthesis in your logic.'); // on line ###arguments.line#.');
		rs.success=false;
		rs.line=currentLine;
		return rs;
	}
	if(not structkeyexists(rs, 'curCharCount')){
		rs.curCharCount=curCharCount;
	}
	rs.line=currentLine; 
	return rs;
	</cfscript>
 </cffunction>
 
<cffunction name="zParseJsonString" localmode="modern" returntype="any" output="yes">
	<cfargument name="e" type="string" required="yes">
	<cfargument name="line" type="numeric" required="yes">
	<cfscript>
	var nextchar="";
	var rs=structnew();
	var arrP=0;
	var i=0;
	var varName=0;
	var varValue=0;
	var lastBoundary=1;
	var inVar=false;
	var inString=false;
	var arrString=arraynew(1);
	var curString="";
	var inNumber=false;
	var inGap=false;
	var oneDecimalPoint=false;
	var firstVarCheck=true;
	var i2=0;
	var curStringType="'";
	var len1=0;
	var len2=0;
	var curCharCount=0;
	rs.error="";
	rs.arrTokenType=arraynew(1);
	rs.arrTokens=arraynew(1);
	rs.arrLength=arraynew(1);
	rs.success=true;
	rs.lastCharPos=1;
	rs.column=1;
	rs.currentline=arguments.line;
	rs.result=true;
	arguments.e=mid(arguments.e,2,len(arguments.e)-2);
	arrP=listtoarray(arguments.e,",",true);
	//writeoutput("json:"&e&"<br />");
	for(i=1;i LTE len(arguments.e);i++){
		curChar=mid(arguments.e,i,1);
		len1=len(curChar);
		len2=len1-len(trim(curChar));
		//writeoutput(curChar&"<br />");
		nextChar="";
		if(i+1 LTE len(arguments.e)){
			nextChar=mid(arguments.e,i+1,1);
		}
		if(inGap){
			// skip all spaces
			if(trim(curChar) EQ ""){
				if(len2 GT 0){
					curCharCount+=len2;
				}
				lastBoundary=i+1;
				continue;	
			}else if(curChar EQ "}"){
				/*if(i LT len(arguments.e)){
					rs.error=('The JSON statement ended with a } on column #i#, but there was more information afterwards that is not allowed.  Check your JSON syntax on line ###arguments.line#.');
					rs.success=false;
					rs.column=i;
					return rs;
				}*/
				rs.lastCharPos=i;
				//curCharCount+=1;
				rs.curCharCount=curCharCount;
				return rs;
			}else if(curChar NEQ ","){
				rs.error=('Column #i#: A comma must separate each JSON variable/value combination.  You may have forgotten to escape backslash or single quote in the string or forgotten a comma.   Check your JSON syntax on line ###arguments.line#.');
				rs.success=false;
				rs.column=i;
				return rs;
			}else if(curChar EQ ","){
					lastBoundary=i+1;
				inGap=false;
				continue;	
			}
		}else if(inVar){
			if(inNumber){
				if(trim(curChar) EQ "" or curChar EQ ","){
					if(len2 GT 0){
						curCharCount+=len2;
					}
					// end of number, save it and go to gap
					curString=arraytolist(arrString,"");
					arrayappend(rs.arrTokenType,"json number");
					arrayappend(rs.arrTokens,curString);
					arrayappend(rs.arrLength, len(curString));
					inNumber=false;
					inGap=true;	
					firstVarCheck=true;
					inVar=false;
					oneDecimalPoint=false;
					i--;
					arrString=arraynew(1);
					continue;
				}else if(curChar EQ "."){
					if(oneDecimalPoint){
						rs.error=('A number can''t have more then one decimal point, ".". Check your JSON syntax on line ###arguments.line#.');
						rs.success=false;
						rs.column=i;
						return rs;
					}
					arrayappend(arrString, ".");
					oneDecimalPoint=true;
					continue;
				}else if(curChar EQ "}"){
					curString=arraytolist(arrString,"");
					arrString=arraynew(1);
					arrayappend(rs.arrTokenType,"json number");
					arrayappend(rs.arrTokens,curString);
					arrayappend(rs.arrLength, len(curString));
					inNumber=false;
					firstVarCheck=true;
					inVar=false;
					inGap=true;	
					oneDecimalPoint=false;
					rs.lastCharPos=i;
					//curCharCount+=1;
					/*if(i LT len(arguments.e)){
						rs.error=('The JSON statement ended with a } on column #i#, but there was more information afterwards that is not allowed.  Check your JSON syntax on line ###arguments.line#.');
						rs.success=false;
						rs.column=i;
						return rs;
					}*/
					rs.curCharCount=curCharCount;
					return rs;
					// the end
				}else if(refind("[0-9]",curChar) EQ 0){
					rs.error=('A number value had an invalid character in it. "#curChar#" is not allowed. Check your JSON syntax on line ###arguments.line#.');
					rs.success=false;
					rs.column=i;
					return rs;
				}else{
					arrayappend(arrString, curChar);
				}
			}else if(inString){
				if(curChar EQ "\" and nextChar EQ "\"){
					arrayappend(arrString, "\");
					i++;
					continue;
				}else if(curChar EQ "\" and nextChar EQ curStringType){
					arrayappend(arrString, curStringType);
					i++;
					continue;
				}else if(curChar EQ curStringType){
					curString=arraytolist(arrString,"");	
					curString=replace(replace(replace(curString," : ",":","ALL")," ( ","(","ALL")," ) ",")","ALL");
					arrString=arraynew(1);
					arrayappend(rs.arrTokenType,"json string");
					arrayappend(rs.arrTokens,curString);
					arrayappend(rs.arrLength, len(replace(replace(curString,"\","\\","ALL"),curStringType,"\"&curStringType,"ALL"))+2);
					inString=false;
					inVar=false;
					inGap=true;
					firstVarCheck=true;
					lastBoundary=i+1;
				}else{
					arrayappend(arrString,curChar);	
				}
			}else{
				//writeoutput(curChar&"<br />");
				if(curChar EQ "'" or curChar EQ '"'){
					inString=true;
					curStringType=curChar;
					continue;
				}else if(refind("[0-9]",curChar) NEQ 0){
					arrayappend(arrString, curChar);
					// look for more numbers and one or less periods and find the end of the json string or a COMMA
					inNumber=true;
				}else if(trim(curChar) EQ ""){
					if(len2 GT 0){
						curCharCount+=len2;
					}
					// skip until i reach a character
					continue;	
				}else if(curChar EQ "t" or curChar EQ "f"){
					if(i+3 lte len(arguments.e) and "true" EQ mid(arguments.e,i,4)){
						arrayappend(rs.arrTokenType,"json boolean");
						arrayappend(rs.arrTokens,"true");
						arrayappend(rs.arrLength, 4);
						inVar=false;
						firstVarCheck=true;
						inGap=true;
						i=i+3;
						continue;
					}else if(i+4 lte len(arguments.e) and "false" EQ mid(arguments.e,i,5)){
						arrayappend(rs.arrTokenType,"json boolean");
						arrayappend(rs.arrTokens,"false");
						arrayappend(rs.arrLength, 5);
						inVar=false;
						firstVarCheck=true;
						inGap=true;
						i=i+4;
						continue;
					}else{
						rs.error=('A JSON value must be true, false, a number or a string inside single quotes.  Check your JSON syntax on line ###arguments.line#.');
						rs.success=false;
						rs.column=i;
						return rs;
					}
				}else{
					rs.error=('A JSON value must be true, false, a number or a string inside single quotes.  Check your JSON syntax on line ###arguments.line#.');
					rs.success=false;
					rs.column=i;
					return rs;
				}
			}
			/*
				for(i2=1;i2 LTE arraylen(100);i2++){
					nChar=mid(arguments.e,i+i2,1);
					if(i2+1 LTE len(arguments.e)){
						nnChar=mid(arguments.e,i+(i2+1),1);
					}else{
						nnChar="";
					}
					if(nChar NEQ "\" and nnChar NEQ "\"){
						
					}
				}
			}*/
		}else{
			
			if(curChar EQ ":"){
				// end of variable name
				varName=mid(arguments.e,lastBoundary, i-lastBoundary);
				arrayappend(rs.arrTokenType,"json variable");
				arrayappend(rs.arrTokens,varName);
				arrayappend(rs.arrLength, len(varName));
				inVar=true;
				continue;
			}
			if(firstVarCheck){
				if(trim(curChar) EQ ""){
					if(len2 GT 0){
						curCharCount+=len2;
					}
					lastBoundary=i+1;
					continue;
				}else if(refind("[0-9]",curChar) NEQ 0){
					rs.error=('An JSON variable name can''t start with a number.  It must use only the following characters A-Z, _ or . (period).  Check your JSON syntax on line ###arguments.line#.');
					rs.success=false;
					rs.column=i;
					return rs;
				}else if(refind("[a-zA-Z_]",curChar) EQ 0 and trim(curChar) NEQ ""){
					rs.error=('An JSON variable name is using an invalid character, "#curChar#".  It must use only the following characters A-Z, 0-9, _ or . (period).  Check your JSON syntax on line ###arguments.line#.');
					rs.success=false;
					rs.column=i;
					return rs;
				}else{
					lastBoundary=i;
					firstVarCheck=false;
					continue;
				}
			}else{
				if(trim(curChar) EQ ""){
					if(len2 GT 0){
						curCharCount+=len2;
					}
					for(i2=i+1;i2 LTE len(arguments.e);i2++){
						curChar2=mid(arguments.e,i2,1);
						if(trim(curChar2) EQ ""){
							curCharCount+=1;
							continue;
						}else if(curChar2 EQ ":"){
							varName=mid(arguments.e,lastBoundary, i-lastBoundary);
							arrayappend(rs.arrTokenType,"json variable");
							arrayappend(rs.arrTokens,varName);
							arrayappend(rs.arrLength, len(varName));
							inVar=true;
							i=i2;
							break;
						}else{
							rs.error=('A JSON variable name is missing its value.  You must have a value for every json variable name with a colon between the variable and the value. Check your JSON syntax on line ###arguments.line#.');
							rs.success=false;
							rs.column=i;
							return rs;
						}
					}
					continue;
				}else if(refind("[a-zA-Z0-9_]",curChar) EQ 0){
					rs.error=('An JSON variable name is using an invalid character, "#curChar#".  It must use only the following characters A-Z, 0-9, _ or . (period).  Check your JSON syntax on line ###arguments.line#.');
					rs.success=false;
					rs.column=i;
					return rs;
				}
			}
		}
	}
	rs.curCharCount=curCharCount;
	return rs;
	</cfscript>
</cffunction>

<cffunction name="zSkinProcessVar" localmode="modern" output="yes" returntype="any">
	<cfargument name="curVar" type="any" required="yes">
    <cfargument name="ss" type="struct" required="no" default="#structnew()#">
    <cfscript>
	var local=structnew();
	if(structkeyexists(arguments.ss,'dateformat')){
		if(isdate(arguments.curVar)){
			arguments.curVar=dateformat(arguments.curVar, arguments.ss.dateformat);	
		}
	}
	if(structkeyexists(arguments.ss,'htmlescape')){
		if(arguments.ss.htmlescape){
			arguments.curVar=htmleditformat(arguments.curVar);	
		}
	}
	return arguments.curVar;
	</cfscript>
</cffunction>

<cffunction name="zSkinGetVar" localmode="modern" output="yes" returntype="any">
	<cfargument name="varName" type="string" required="yes">
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfscript>
	var local=structnew();
	var vd=request.zos.viewdata;
	var v="";
	// TODO: check if this variable is allowed (security scan)
	var arrF=listtoarray(arguments.varName,".");
	if(arraylen(arrF) EQ 2){
		if(arrF[1] EQ "zwidget"){
			// need to locate the real widget instead soon
			
			local.q=structnew();
			local.q[1].heading="Test Heading 1";
			local.q[1].date1="2012-07-02";
			local.q[2].heading="Test Heading 2";
			local.q[2].date1="2012-10-02";
			/*local.q=queryNew("heading","varchar");
			queryaddrow(local.q,2);
			querysetcell(local.q,"heading","Test Heading 1",1);
			querysetcell(local.q,"heading","Test Heading 2",2);*/
			return local.q;
			//return "widget get var:"&v;
		}else if(arguments.varName EQ "blog.populararticles"){
			
			local.q=queryNew("title,author,datetime","varchar,varchar,varchar");
			queryaddrow(local.q,2);
			querysetcell(local.q,"title","Test Title 1",1);
			querysetcell(local.q,"author","Test Author1",1);
			querysetcell(local.q,"datetime",now(),1);
			querysetcell(local.q,"title","Test Title 2",2);
			querysetcell(local.q,"author","Test Author2",2);
			querysetcell(local.q,"datetime",now(),1);	
			return local.q;
		}else if(structkeyexists(vd, arrF[1])){
			local.c=vd[arrF[1]];
			if(structkeyexists(local.c, arrF[2])){
				v=local.c[arrF[2]];	
			}else{
				v="";	
			}
		}
	}
	
	if(v NEQ ""){
		// TODO: customize the return value with the ss struct.
		if(structkeyexists(arguments.ss,'dateformat')){
			if(isdate(v)){
				v=dateformat(v, arguments.ss.dateformat);	
			}
		}
	}
	return v;
	</cfscript>
</cffunction>

<cffunction name="zTranslateSkinExpression" localmode="modern" output="yes" returntype="any">
	<cfargument name="rs" type="struct" required="yes">
	<cfargument name="output" type="boolean" required="no" default="#false#">
	<cfargument name="inControlFlow" type="boolean" required="no" default="#false#">
	<cfscript>
	var local=structnew();
	var i=0;
	var ct=0;
	var c=0;
	var pc=0;
	var pct=0;
	var nc=0;
	var nct=0;
	var extraParenthesis=false;
	var firstJSONCount=0;
	var arrString=arraynew(1);
	var lastVarName="";
	var forInStatement=false;
	arguments.rs.success=true;
	arguments.rs.objectName="";
	arguments.rs.struct=structnew();
	if(structkeyexists(request.zos.tempObj,'zSkinCompileJSONStructCount') EQ false){
		request.zos.tempObj.zSkinCompileJSONStructCount=0;
	} 
	firstJSONCount=request.zos.tempObj.zSkinCompileJSONStructCount+1;
	
	// detect for ... in statement
	if(arraylen(arguments.rs.arrTokenType) GTE 4 and arguments.rs.arrTokenType[1] EQ "FOR" and arguments.rs.arrTokenType[3] EQ "IN" and arguments.rs.arrTokenType[2] EQ "variable"){
		forInStatement=true;
		local.forItemName=arguments.rs.arrTokens[2];
		local.startI=4;
	}else{
		local.startI=1;
	}
	
	for(i=local.startI;i LTE arraylen(arguments.rs.arrTokens);i++){
		c=arguments.rs.arrTokens[i];
		ct=arguments.rs.arrTokenType[i];
		if(left(ct,4) EQ "json"){
			pct="";
			if(i GT 1){
				pc=arguments.rs.arrTokens[i-1];
				pct=arguments.rs.arrTokenType[i-1];
			}
			if(i+1 LTE arraylen(arguments.rs.arrTokens)){
				nc=arguments.rs.arrTokens[i+1];
				nct=arguments.rs.arrTokenType[i+1];
			}
			local.cStructValue=c;
			if(ct EQ "json string"){
				c='"'&replace(c,'"','""','ALL')&'"';
			}
			if(ct EQ "json variable" and pct EQ "start parenthesis"){
				request.zos.tempObj.zSkinCompileJSONStructCount++;
				lastVarName=c;
				c='zTempSkinStruct#request.zos.tempObj.zSkinCompileJSONStructCount#=structnew(); 
				zTempSkinStruct#request.zos.tempObj.zSkinCompileJSONStructCount#["'&c&'"]=';
			}else if(ct EQ "json variable"){
				lastVarName=c;
				c='zTempSkinStruct#request.zos.tempObj.zSkinCompileJSONStructCount#["'&c&'"]=';
			}else{
				arguments.rs.struct[lastVarName]=local.cStructValue;
				c=c&'; ';
				if(nct EQ "end parenthesis"){
					c&='';
				}
			}
			arrayappend(arrString, c);
		}
	}
	arguments.rs.structResult=arraytolist(arrString," ");
	arrString=arraynew(1);
	for(i=local.startI;i LTE arraylen(arguments.rs.arrTokens);i++){
		c=arguments.rs.arrTokens[i];
		ct=arguments.rs.arrTokenType[i];
		if(ct EQ "json variable"){
			arrayappend(arrString,'zTempSkinStruct#firstJSONCount#');
			firstJSONCount++;
			for(i2=i+1;i2 LTE arraylen(arguments.rs.arrTokens);i2++){
				if(left(arguments.rs.arrTokenType[i2],4) NEQ "json"){
					i=i2-1;
					break;	
				}
			}
		}else{
			if(i+1 LTE arraylen(arguments.rs.arrTokens)){
				nc=arguments.rs.arrTokens[i+1];
				nct=arguments.rs.arrTokenType[i+1];
			}
			if(ct EQ "variable"){
				extraParenthesis=false;
				local.escape1="htmleditformat(";
				local.escape2=")";
				if(left(c,1) EQ "="){
					c=removechars(c,1,1);
					local.escape1="";
					local.escape2="";
				}
				local.arr1=listtoarray(c,".");
				if(arraylen(local.arr1) EQ 2){
					if(structkeyexists(request.zHTMLSkinCompileObjectMap, local.arr1[1])){
						c=request.zHTMLSkinCompileObjectMap[local.arr1[1]]&"."&local.arr1[2];
					}
				}
				c="arguments.viewdata."&c;
				if(nct NEQ "start parenthesis"){
					if(arguments.output){
						c=local.escape1&c&local.escape2;//application.zcore.functions.zSkinGetVar
					}else if(arguments.inControlFlow){
						//c='application.zcore.functions.zSkinGetVar("'&c&'")';
					}else{
						//c='(isdefined("'&c&'") and '&c&')';
					}
				}else{
					if(arguments.output){
						c=''&local.escape1&'application.zcore.functions.zSkinProcessVar('&c&',';//application.zcore.functions.zSkinGetVar
					}else if(arguments.inControlFlow){
						c='application.zcore.functions.zSkinProcessVar('&c&',';
						arguments.rs.objectName="zTempSkinObject#firstJSONCount#";
					}else{
						c='zTempSkinObject#firstJSONCount#=application.zcore.functions.zSkinProcessVar('&c&',';//application.zcore.functions.zSkinGetVar
						arguments.rs.objectName="zTempSkinObject#firstJSONCount#";
						
					}
					extraParenthesis=true;	
					i++;
				}
			}else if(ct EQ "end parenthesis"){
				if(extraParenthesis){
					if(arguments.output){
						c=local.escape2&');';
					}else{
						c=")";
						if(inControlFlow EQ false){
							c&=";";
						}
					}
					extraParenthesis=false;
				}
			}
			/*
			pct="";
			if(i GT 1){
				pc=arguments.rs.arrTokens[i-1];
				pct=arguments.rs.arrTokenType[i-1];
			}*/
			if(ct EQ "string"){
				c='"'&replace(c,'"','""','ALL')&'"';
			}
			arrayappend(arrString, c);
		}
	}
	if(arguments.output){// and arraylen(arguments.rs.arrTokens) EQ 1){
	//if(arraylen(arrString) EQ 1 and (ct EQ "string" or ct EQ "number" or ct EQ "boolean" or ct EQ "variable")){
		arguments.rs.result='writeoutput('&arraytolist(arrString," ")&');';
	}else{
		arguments.rs.result=arraytolist(arrString," ");
	}
	if(forInStatement){
		// first variable can't be retrieved with zo and for in
		
		// for row in query can't be done unless both the start and end loop code is modified at runtime based on type.  This is only possible when using custom tag due to nesting.   OR all of the code has to be output as cfscript, which is a lot of rewriting. 
		arguments.rs.result='curColStruct'&request.zos.tempObj.zSkinCompileJSONStructCount&'='&arguments.rs.result&';
		for(#arguments.rs.arrTokens[2]#_index in curColStruct#request.zos.tempObj.zSkinCompileJSONStructCount#){
			arguments.viewdata["'&arguments.rs.arrTokens[2]&'"]=#arguments.rs.arrTokens[2]#_index;
			';
	}
	//application.zcore.functions.zdump(rs);
	
	//application.zcore.functions.zabort();
	return arguments.rs;
	</cfscript>
</cffunction>


<!--- this should inherit an interface and createobject gets stored in application scope --->
<cffunction name="zSkinWidget_if" localmode="modern" output="no" returntype="struct">
	<cfargument name="arrHTML" type="array" required="yes">
	<cfargument name="index" type="numeric" required="yes">
	<cfargument name="type" type="string" required="no" default="if">
	<cfscript>
	var i=0;
	var c=0;
	var n=0;
	var newString="";
	var rs=structnew();
	var newStruct="";
	var endIndex=arguments.index;
	arguments.type=lcase(arguments.type);
	rs.success=true;
	rs.result="";
	rs.error="";
	// translate <!-- if expression -->
	if(arguments.arrHTML[arguments.index].type EQ arguments.type){
		//n=mid(arguments.arrHTML[arguments.index].value, 2, len(arguments.arrHTML[arguments.index].value)-2);
		n=mid(arguments.arrHTML[arguments.index].value, len(arguments.type)+2, len(arguments.arrHTML[arguments.index].value)-(len(arguments.type)+2));
		//n=arguments.arrHTML[arguments.index].value; 
		rs=application.zcore.functions.zParseSkinExpression(n,1);
		if(rs.success EQ false){
			rs.error="Expression parsing failed because: "&rs.error;
			return rs;
		} 
		rs=application.zcore.functions.zTranslateSkinExpression(rs, false, true);
		if(rs.success EQ false){
			rs.error="Expression translation failed because: "&rs.error;
			return rs;
		}
		if(rs.structresult NEQ ""){
			newStruct=rs.structresult;
		}
		newString=rs.result;
		arguments.arrHTML[arguments.index].type="customTag";
		if(arguments.type EQ "elseif"){
			arguments.type="}else if";
		}
		arguments.arrHTML[arguments.index].value=newStruct&arguments.type&'('&newString&'){'&chr(10);
		rs.result=arguments.arrHTML;
		return rs;
	}
	throw("not supported");
	// translate <br data-zif="blog EQUALS true" />
	for(i=arguments.index;i LTE arraylen(arguments.arrHTML);i++){
		c=arguments.arrHTML[i];
		if(c.type EQ "attributeName" and c.value EQ "data-z#arguments.type#"){
			n=0;
			if(i+1 LTE arraylen(arguments.arrHTML)){
				n=arguments.arrHTML[i+1];
			}
			if(isstruct(n)){
				rs=application.zcore.functions.zParseSkinExpression(n.value,1);
				if(rs.success EQ false){
					rs.error="Expression parsing failed because: "&rs.error;
					return rs;
				}
				rs=application.zcore.functions.zTranslateSkinExpression(rs, false, true);
				if(rs.success EQ false){
					rs.error="Expression translation failed because: "&rs.error;
					return rs;
				}
				if(rs.structresult NEQ ""){
					newStruct=rs.structresult;
				}
				newString=rs.result;
			}
		}else if(c.type EQ "endHTMLTag"){
			endIndex=i;
			break;
		}
	}
	arguments.arrHTML[arguments.index].type="customTag";
	arguments.arrHTML[arguments.index].value=newStruct&arguments.type&'('&newString&'){'&chr(10);
	for(i=arguments.index+1;i LTE endIndex;i++){
		//writeoutput('deleting:'&arguments.arrHTML[i].type&"|"&arguments.arrHTML[i].value&'<br />');
		arraydeleteat(arguments.arrHTML,arguments.index+1);	
	}
	/*writeoutput("indexes:"&arguments.index&"|"&endIndex&"<br />");
	//application.zcore.functions.zdump(arrHTML);
	application.zcore.functions.zabort();*/
	rs.result=arguments.arrHTML;
	return rs;
	</cfscript>
</cffunction>


<cffunction name="zSkinWidget_elseif" localmode="modern" output="no" returntype="struct">
	<cfargument name="arrHTML" type="array" required="yes">
	<cfargument name="index" type="numeric" required="yes">
	<cfscript>
	var rs=application.zcore.functions.zSkinWidget_if(arguments.arrHTML, arguments.index, "elseif");
	return rs;
	</cfscript>
</cffunction>

<cffunction name="zSkinWidget_endif" localmode="modern" output="yes" returntype="struct">
	<cfargument name="arrHTML" type="array" required="yes">
	<cfargument name="index" type="numeric" required="yes">
	<cfscript>
	var i=0;
	var c=0;
	var rs=structnew();
	var endIndex=arguments.index;
	rs.success=true;
	rs.result="";
	rs.error="";
	// translate <!-- endif -->
	if(arguments.arrHTML[arguments.index].type EQ "endif"){
		arguments.arrHTML[arguments.index].type="customTag";
		arguments.arrHTML[arguments.index].value='}';
		rs.result=arguments.arrHTML;
		return rs;
	}
	// translate <br data-zendif="" />
	for(i=arguments.index;i LTE arraylen(arguments.arrHTML);i++){
		c=arguments.arrHTML[i];
		if(c.type EQ "endHTMLTag"){
			endIndex=i;
			break;
		}
	}
	arguments.arrHTML[arguments.index].type="customTag";
	arguments.arrHTML[arguments.index].value='|';
	//writeoutput("endif:"&arguments.index&"|"&endIndex&"|<br />");
	for(i=arguments.index+1;i LTE endIndex;i++){
		//writeoutput("deleting:"&arguments.arrHTML[arguments.index+1].type&"|"&arguments.arrHTML[arguments.index+1].value&"<br />");
		arraydeleteat(arguments.arrHTML,arguments.index+1);	
	}
	rs.result=arguments.arrHTML;
	//application.zcore.functions.zdump(arguments.arrHTML);
	return rs;
	</cfscript>
</cffunction>



<cffunction name="zSkinWidget_loop" localmode="modern" output="yes" returntype="struct">
	<cfargument name="arrHTML" type="array" required="yes">
	<cfargument name="index" type="numeric" required="yes">
	<cfscript>
	var i=0;
	var c=0;
	var n=0;
	var newStruct=0;
	var tagname="";
	var ts=0;
	var newString2=0;
	var newString=0;
	var rs=structnew();
	var endIndex=arguments.index;
	var rs2=0;
	var cp=0;
	var firstC=arguments.arrHTML[arguments.index];
	var arrString=arraynew(1);
	var objectName="";
	rs.success=true;
	rs.result="";
	rs.error="";
	
	// TODO
	if(firstC.type EQ "for"){
		// firstC is the expression
		c=firstC;
		rs2=application.zcore.functions.zParseSkinExpression(c.value,1,true);
		if(rs2.success EQ false){
			rs2.error="Expression parsing failed because: "&rs2.error;
			return rs2;
		}
		
		rs2=application.zcore.functions.zTranslateSkinExpression(rs2,false, true);
		
		//writedump(rs2);
		//application.zcore.functions.zabort();
		objectName=rs2.objectname;
		if(structkeyexists(rs2,'struct') and structkeyexists(rs2.struct,'name')){
			request.zHTMLSkinCompileObjectMap[rs2.struct.name]=rs2.objectName;
		}
		//application.zcore.functions.zdump(request.zHTMLSkinCompileObjectMap);
		if(rs2.success EQ false){
			rs2.error="Expression translation failed because: "&rs2.error;
			return rs2;
		}
		arguments.arrHTML[arguments.index].type="customTag";
		arguments.arrHTML[arguments.index].value=rs2.structresult&rs2.result;
		rs.result=arguments.arrHTML;
		return rs;
	}else{
		//application.zcore.template.fail("zSkinWidget_loop not implemented");
		// very complex one todo...
		//application.zcore.functions.zdump(arguments);
		//application.zcore.functions.zabort();
		for(i=arguments.index;i LTE arraylen(arguments.arrHTML);i++){
			c=arguments.arrHTML[i];
			if(i GT 1){
				cp=arguments.arrHTML[i-1];	
			}
			if(c.type EQ "attributeName" and c.value EQ "data-zloop"){
				continue;
			}else if((c.type EQ "attributeValue" and cp.type EQ "attributeName" and cp.value EQ "data-zloop")){//c.type EQ "attributeValueExpression" or 
				rs2=application.zcore.functions.zParseSkinExpression(c.value,1,true);
				if(rs2.success EQ false){
					rs2.error="Expression parsing failed because: "&rs2.error;
					return rs2;
				}
				rs2=application.zcore.functions.zTranslateSkinExpression(rs2,false);
				objectName=rs2.objectname;
				if(structkeyexists(rs2,'struct') and structkeyexists(rs2.struct,'name')){
					request.zHTMLSkinCompileObjectMap[rs2.struct.name]=rs2.objectName;
				/*}else{
					request.zHTMLSkinCompileObjectMap[objectName]=rs2;*/
				}
				//application.zcore.functions.zdump(request.zHTMLSkinCompileObjectMap);
				if(rs2.success EQ false){
					rs2.error="Expression translation failed because: "&rs2.error;
					return rs2;
				}
				if(rs2.structresult NEQ ""){
					newStruct=rs2.structresult;
				}
				newString=rs2.result;
				continue;
			}else if(c.type EQ "closeHTMLTag" and structkeyexists(c, 'level') and c.level EQ firstC.level and c.value EQ firstC.value){
				//endIndex=i;
				ts=structnew();
				ts.type="text";
				ts.value='}';
				ts.line=c.line;
				ts.level=c.level;
				ts.column=c.column;
				arrayinsertat(arguments.arrHTML,i+1,ts);
				break;/**/
			}else if(endIndex NEQ arguments.index){
				continue;
			}else if(c.type EQ "endHTMLTag"){
				endIndex=i;
				continue;
			}else{
				if(c.type EQ "attributeName"){
					c.value&="=";
				}else if(c.type EQ "attributeValue"){
					c.value='"'&htmleditformat(c.value)&'" ';	
				/*}else if(c.type EQ "attributeValueExpression")){
					c.value='"'&c.value&'" ';	*/
				}
				if(endIndex EQ arguments.index){
					arrayappend(arrString,c.value);
				}
			}
		}
		//application.zcore.functions.zdump(arrString);
		newString2=arraytolist(arrString,"");
		
		tagName=arrString[1]; 
		arraydeleteat(arrString,1);
		//application.zcore.functions.zdump(arrString);
		arguments.arrHTML[arguments.index].type="customTag";
		arguments.arrHTML[arguments.index].value='writeoutput("#replace(newStruct, '"', '""', 'all')#");
		for(row in #newString#){
		
			';//'&tagName&" "&arraytolist(arrString,"")&'>';
		//writeoutput("endif:"&arguments.index&"|"&endIndex&"|<br />");
		for(i=arguments.index+1;i LTE endIndex;i++){
			//writeoutput("deleting:"&arguments.arrHTML[arguments.index+1].type&"|"&arguments.arrHTML[arguments.index+1].value&"<br />");
			arraydeleteat(arguments.arrHTML,arguments.index+1);	
		}
		rs.result=arguments.arrHTML;
		/*application.zcore.functions.zdump(arguments.arrHTML);
		application.zcore.functions.zabort();*/
		return rs;
	}
	</cfscript>
</cffunction>


<cffunction name="zSkinWidget_endloop" localmode="modern" output="yes" returntype="struct">
	<cfargument name="arrHTML" type="array" required="yes">
	<cfargument name="index" type="numeric" required="yes">
	<cfscript>
	var i=0;
	var c=0;
	var rs=structnew();
	var endIndex=arguments.index;
	rs.success=true;
	rs.result="";
	rs.error="";
	//application.zcore.template.fail("zSkinWidget_loop not implemented");
	// very complex one todo...
	
	if(arguments.arrHTML[arguments.index].type EQ "endfor"){
		arguments.arrHTML[arguments.index].type="customTag";
		arguments.arrHTML[arguments.index].value='}';
		rs.result=arguments.arrHTML;
		return rs;
	}else{
		for(i=arguments.index;i LTE arraylen(arguments.arrHTML);i++){
			c=arguments.arrHTML[i];
			if(c.type EQ "endHTMLTag"){
				endIndex=i;
				break;
			}
		}
		arguments.arrHTML[arguments.index].type="customTag";
		arguments.arrHTML[arguments.index].value='}';
		//writeoutput("endif:"&arguments.index&"|"&endIndex&"|<br />");
		for(i=arguments.index+1;i LTE endIndex;i++){
			//writeoutput("deleting:"&arguments.arrHTML[arguments.index+1].type&"|"&arguments.arrHTML[arguments.index+1].value&"<br />");
			arraydeleteat(arguments.arrHTML,arguments.index+1);	
		}
		rs.result=arguments.arrHTML;
		//application.zcore.functions.zdump(arguments.arrHTML);
		return rs;
	}
	</cfscript>
</cffunction>


<cffunction name="zSkinWidget_out" localmode="modern" output="yes" returntype="struct">
	<cfargument name="arrHTML" type="array" required="yes">
	<cfargument name="index" type="numeric" required="yes">
	<cfscript>
	var i=0;
	var c=0;
	var tagname=0;
	var rs=structnew();
	var endIndex=arguments.index;
	var arrString=arraynew(1);
	var firstC=arguments.arrHTML[arguments.index];
	var rs2=0;
	var newStruct="";
	var newString="";
	var cp=0;
	rs.success=true;
	rs.result="";
	rs.error="";
	//application.zcore.template.fail("zSkinWidget_var not implemented");
	// need to find the end of the tag and insert the variable call there
	for(i=arguments.index;i LTE arraylen(arguments.arrHTML);i++){
		c=arguments.arrHTML[i];
		if(i GT 1){
			cp=arguments.arrHTML[i-1];	
		}
		if(c.type EQ "attributeName" and c.value EQ "data-zout"){
			continue;
		}else if((c.type EQ "attributeValue" and cp.type EQ "attributeName" and cp.value EQ "data-zout")){//c.type EQ "attributeValueExpression" or 
			rs2=application.zcore.functions.zParseSkinExpression(c.value,1,true);
			if(rs2.success EQ false){
				rs2.error="Expression parsing failed because: "&rs2.error;
				return rs2;
			}
			rs2=application.zcore.functions.zTranslateSkinExpression(rs2,true);
			if(rs2.success EQ false){
				rs2.error="Expression translation failed because: "&rs2.error;
				return rs2;
			}
			if(rs2.structresult NEQ ""){
				newStruct=rs2.structresult;
			}
			newString=rs2.result;
			continue;
		}else if(c.type EQ "closeHTMLTag" and c.level EQ firstC.level and c.value EQ firstC.value){
			endIndex=i;
			break;
		}else if(c.type EQ "endHTMLTag"){
			endIndex=i;
			continue;
		}else{
			if(c.type EQ "attributeName"){
				c.value&="=";
			}else if(c.type EQ "attributeValue"){
				c.value='"'&htmleditformat(c.value)&'" ';	
			}
			if(endIndex EQ arguments.index){
				arrayappend(arrString,c.value);
			}
		}
	}
	tagName=arrString[1];
	arraydeleteat(arrString,1);
	//application.zcore.functions.zdump(arrString);
	arguments.arrHTML[arguments.index].type="customTag";
	if(arraylen(arrString) EQ 0){
		arguments.arrHTML[arguments.index].value="<"&tagName&'>'&newStruct&'<cfscript> '&newString&' </cfscript>'&'</'&tagName&'>';
	}else{
		arguments.arrHTML[arguments.index].value="<"&tagName&" "&trim(arraytolist(arrString,""))&'>'&newStruct&'<cfscript> '&newString&' </cfscript>'&'</'&tagName&'>';
	}
	//writeoutput(htmleditformat(arguments.arrHTML[arguments.index].value)&'<br />');
	//writeoutput("endif:"&arguments.index&"|"&endIndex&"|<br />");
	for(i=arguments.index+1;i LTE endIndex;i++){
		//writeoutput("deleting:"&arguments.arrHTML[arguments.index+1].type&"|"&arguments.arrHTML[arguments.index+1].value&"<br />");
		arraydeleteat(arguments.arrHTML,arguments.index+1);	
	}
	rs.result=arguments.arrHTML;
	//application.zcore.functions.zdump(arguments.arrHTML);
	return rs;
	</cfscript>
</cffunction>


<!--- zSkinProcessVars(theHTML); --->
<cffunction name="zSkinProcessVars" localmode="modern" output="yes" returntype="struct">
	<cfargument name="theHTML" type="string" required="yes">
	<cfscript>
	var i=0;
	var c=0;
	var rs=structnew();
	var rs2=0;
	var rs3=0;
	var newStruct="";
	var newString="";
	var newStart=1;
	var lastCharCount=0;
	var currentline=0;
	var r=0;
	var i2=0;
	rs.success=true;
	//rs.result=arguments.theHTML;
	//return rs;
	rs.result="";
	rs.error="";
	
	//arguments.theHTML=replace(replace(arguments.theHTML,")"," ) ","ALL"),"("," ( ","ALL");
	arguments.theHTML=replacenocase(arguments.theHTML,'&quot;','"',"ALL");
	//arguments.theHTML=replace(arguments.theHTML,":"," : ","ALL");
	//arguments.theHTML=replace(replace(arguments.theHTML,")"," ) ","ALL"),"("," ( ","ALL");
	while(true){
		r=refindnocase("(\$[^\$](.*))", arguments.theHTML, newStart);
		if(r EQ 0){
			break;
		}else{
			//writeoutput("|"&mid(arguments.theHTML, r.pos[1]+5, r.len[1]-6)&'|<br /><br />');
			c=mid(arguments.theHTML,r,len(arguments.theHTML)-(r-1));
			//c=mid(arguments.theHTML, r.pos[1]+5, r.len[1]-6);//
			
			currentline=len(arguments.theHTML)-len(replace(arguments.theHTML,chr(10),"","all"));
			rs2=application.zcore.functions.zParseSkinExpression(c,currentline,true);
			if(rs2.success EQ false){
				rs2.error="Expression parsing failed because: "&rs2.error;
				return rs2;
			}
			/*
			lastCharCount=0;
			for(i2=1;i2 LTE arraylen(rs2.arrTokens);i2++){
				lastCharCount+=len(rs2.arrTokens[i2]);
			}*/
			//lastCharCount-=3;
			lastCharCount=rs2.curCharCount;
			for(i2=1;i2 LTE arraylen(rs2.arrTokens);i2++){
				lastCharCount+=rs2.arrLength[i2];
			}
			//application.zcore.functions.zdump(rs2);
			rs2=application.zcore.functions.zTranslateSkinExpression(rs2,true);
			if(rs2.success EQ false){
				rs2.error="Expression translation failed because: "&rs2.error;
				return rs2;
			}
			newStruct="";
			if(rs2.structresult NEQ ""){
				newStruct=rs2.structresult;
			}
			newString=rs2.result;
			arguments.theHTML=removeChars(arguments.theHTML,r,lastCharCount);
			//writeoutput('AFTER DELETED:'&htmleditformat(arguments.theHTML)&'<br /><br />');
			newString=newStruct&newString;
			newStart=len(newString)+(r);
			arguments.theHTML=insert(newString,arguments.theHTML, r-1);
			//writeoutput('newString:'&htmleditformat(newString)&'|'&lastCharCount&'|'&newStart&'|next one starts:'&mid(arguments.theHTML,newStart,10)&'<br /><br />');
			/*writeoutput(htmleditformat(arguments.theHTML)&'<br /><br />');
			application.zcore.functions.zdump(c);
			application.zcore.functions.zdump(rs2);*/
		}
	}
	//arguments.arguments.theHTML=replacenocase(arguments.arguments.theHTML,"zout::","zout:","all");
			//application.zcore.functions.zabort();
	rs.result=arguments.theHTML;
	return rs;
	</cfscript>
</cffunction>


<!--- this should inherit an interface and createobject gets stored in application scope --->
<cffunction name="zSkinWidget_dump" localmode="modern" output="no" returntype="struct">
	<cfargument name="arrHTML" type="array" required="yes">
	<cfargument name="index" type="numeric" required="yes">
	<cfargument name="type" type="string" required="no" default="if">
	<cfscript>
	var i=0;
	var c=0;
	var n=0;
	var newString="";
	var rs=structnew();
	var newStruct="";
	var endIndex=arguments.index;
	arguments.type=lcase(arguments.type);
	rs.success=true;
	rs.result="";
	rs.error="";
	// translate <!-- dump expression -->
	if(arguments.arrHTML[arguments.index].type EQ "dump"){
		n=mid(arguments.arrHTML[arguments.index].value, len(arguments.arrHTML[arguments.index].type)+2, len(arguments.arrHTML[arguments.index].value)-(len(arguments.arrHTML[arguments.index].type)+2));
		rs=application.zcore.functions.zParseSkinExpression(n,1);
		if(rs.success EQ false){
			rs.error="Expression parsing failed because: "&rs.error;
			return rs;
		} 
		rs=application.zcore.functions.zTranslateSkinExpression(rs, false, true);
		if(rs.success EQ false){
			rs.error="Expression translation failed because: "&rs.error;
			return rs;
		}
		if(rs.structresult NEQ ""){
			newStruct=rs.structresult;
		}
		newString=rs.result;
		arguments.arrHTML[arguments.index].type="customTag";
		arguments.arrHTML[arguments.index].value=newStruct&'writedump('&newString&');';
		rs.result=arguments.arrHTML;
		return rs;
	}
	throw("tag syntax not supported for dump widget");
	// translate <br data-zdump="blog" />
	local.arrHTML=[];
	for(i=arguments.index+1;i LTE arraylen(arguments.arrHTML);i++){
		c=arguments.arrHTML[i];
		if(c.type EQ "attributeName" and c.value EQ "data-z#arguments.type#"){
			n=0;
			if(i+1 LTE arraylen(arguments.arrHTML)){
				n=arguments.arrHTML[i+1];
			}
			if(isstruct(n)){
				rs=application.zcore.functions.zParseSkinExpression(n.value,1);
				if(rs.success EQ false){
					rs.error="Expression parsing failed because: "&rs.error;
					return rs;
				}
				rs=application.zcore.functions.zTranslateSkinExpression(rs, false, true);
				if(rs.success EQ false){
					rs.error="Expression translation failed because: "&rs.error;
					return rs;
				}
				if(rs.structresult NEQ ""){
					newStruct=rs.structresult;
				}
				newString=rs.result;
			}
			i++;
		}else if(c.type EQ "endHTMLTag"){
			if(not structkeyexists(request.zHTMLBlockElements, arguments.arrHTML[arguments.index].value)){
				arrayAppend(local.arrHTML, "/");
			}
			endIndex=i;
			break;
		}else{
			arrayAppend(local.arrHTML, c.value);	
		}
	}
	arguments.arrHTML[arguments.index].type="customTag";
	arguments.arrHTML[arguments.index].value=newStruct&'writedump('&newString&'##"); writeoutput(" #arrayToList(local.arrHTML, '')#>';
	for(i=arguments.index+1;i LTE endIndex;i++){
		arraydeleteat(arguments.arrHTML,arguments.index+1);	
	}
	rs.result=arguments.arrHTML;
	return rs;
	</cfscript>
</cffunction>


<cffunction name="zSkinWidget_else" localmode="modern" output="no" returntype="struct">
	<cfargument name="arrHTML" type="array" required="yes">
	<cfargument name="index" type="numeric" required="yes">
	<cfscript>
	var i=0;
	var c=0;
	var rs=structnew();
	var endIndex=arguments.index;
	rs.success=true;
	rs.result="";
	rs.error="";
	// translate <!-- else -->
	if(arguments.arrHTML[arguments.index].type EQ "else"){
		arguments.arrHTML[arguments.index].type="customTag";
		arguments.arrHTML[arguments.index].value='}else{';
		rs.result=arguments.arrHTML;
		return rs;
	}
	// translate <br data-zif="blog EQUALS true" />
	for(i=arguments.index;i LTE arraylen(arguments.arrHTML);i++){
		c=arguments.arrHTML[i];
		if(c.type EQ "endHTMLTag"){
			endIndex=i;
			break;
		}
	}
	arguments.arrHTML[arguments.index].type="customTag";
	arguments.arrHTML[arguments.index].value='}else{';
	for(i=arguments.index+1;i LTE endIndex;i++){
		arraydeleteat(arguments.arrHTML,arguments.index+1);	
	}
	rs.result=arguments.arrHTML;
	return rs;
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>