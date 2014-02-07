<cfcomponent output="yes">
<cfoutput>
<cffunction name="init" access="public" localmode="modern" output="no">
	<cfscript>
	var local=structnew();
	var s=0;
	var ts=structnew();
	//application.zcore.skin.includeCSS("/stylesheets/fontkit/stylesheet.css");
	application.zcore.skin.includeCSS("/z/javascript/prettify/src/sons-of-oblivion.css");
	application.zcore.skin.includeCSS("/z/stylesheets/zdoc.css"); 
	application.zcore.skin.includeJS("/z/javascript/jquery/response.0.6.0.min.js");
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery.rwdImages.min.js");
	application.zcore.skin.includeJS("/z/javascript/iscroll-lite.js");
	application.zcore.skin.includeJS("/z/javascript/prettify/src/prettify.js");
	application.zcore.skin.includeJS("/z/javascript/zDocumentation.js");

	/*if(request.zos.zreset NEQ "site" and request.zos.zreset NEQ "all" and structkeyexists(application.siteStruct[request.zos.globals.id], 'manual')){
		return;	
	}*/
	</cfscript>
	<!--- This component will store the structure of all document files and their heirarchy by using meaningful whitespace to organize the docs
	each project should have it's own navigation structure
format is title(tab)url


zdoc css style documentation
.zdoc-container
.zdoc-sidebar
	section navigation ul/li for jump links within page

.zdoc-main-column	
	child page navigation box:
	.zdoc-contents-box with ul/li links
	
 li
.zdoc-main-column ul, .zdoc-main-column ol
.zdoc-sidebar a:link, .zdoc-sidebar a:visited
.zdoc-sidebar a:hover
.zdoc-main-column
.zdoc-section-box
.zdoc-section-box ul
.zdoc-contents-box
.zdoc-important
.zdoc-important h3
.zdoc-tip
.zdoc-tip h3
.zdoc-caution
.zdoc-caution h3
.zdoc-warning
.zdoc-warning h3
.zdoc-container pre
.zdoc-container .prettyprint
.zdoc-container a:link, .zdoc-container a:visited
.zdoc-codetext

.zdoc-search-box
.zdoc-container strong
.zdoc-buttontext
.zdoc-menutext
.zdoc-rightarrowbox 
	position: relative;
	margin-right:2px;
	border:none;
	padding: 3px;
	padding-bottom: 1px;
	padding-right:12px;
	background-image:url(/images/doc/rightarrow.jpg);
	background-position:top right;
	background-repeat:no-repeat;
}
.zdoc-console
		 --->
         
	<cfsavecontent variable="s">
	0 /index.html Full Documentation
	_1 /intro.html Introduction
	__1.1 /documentation-template.html Documentation Template
	_2 /content-manager.html Content Manager
	__2.1 /manage-pages.html Manage Pages
	</cfsavecontent>
	<cfscript>
	ts={original:s, parentIdStruct:{}, idStruct:{}};
	</cfscript>
    <cfscript>
	arrParent=arraynew(1);
	arrLines=listtoarray(trim(replace(replace(ts.original, chr(9), "", "all"), chr(13),"","all")), chr(10));
	for(i=1;i LTE arraylen(arrLines);i++){
		spaceCount=refind("[0-9]", arrLines[i]);
		arrC=listtoarray(removechars(arrLines[i],1, max(0,spaceCount-1)), " ");
		if(arraylen(arrC) LT 3){
			throw("Manual links must be tab separated and contain the document ID, url, and title.", "custom");	
		}
		ns={};
		if(spaceCount-1){ 
			ns.parentId=arrParent[spaceCount-1];
		}else{
			ns.parentId="";
		} 
		ns.id=arrC[1];
		arraydeleteat(arrC, 1);
		ns.url=arrC[1];
		arraydeleteat(arrC, 1);
		if(arrC[arraylen(arrC)] EQ "_blank"){
			ns.target=arrC[arraylen(arrC)];
			arraydeleteat(arrC, arraylen(arrC));
		}else{
			ns.target="_self";
		}
		ns.title=arraytolist(arrC, " ");
		ts.idStruct[ns.id]=ns;
		arrParent[spaceCount]=ns.id;
		if(not structkeyexists(ts.parentIdStruct, ns.parentId)){
			ts.parentIdStruct[ns.parentId]=[];
		}
		arrayappend(ts.parentIdStruct[ns.parentId], ns.id);
	} 
	//application.siteStruct[request.zos.globals.id].manual=ts;
	request.zos.siteManagerManual=ts;
	
	</cfscript>
</cffunction>


<cffunction name="getSiteMap" access="public" localmode="modern">
	<cfargument name="arrURL" type="array" required="yes">
	<cfscript>
	init();
    arrKey=structkeyarray(request.zos.siteManagerManual);
    arraysort(arrKey, "text");
    for(n2=1;n2 LTE arraylen(arrKey);n2++){
        n=arrKey[n2];
        arrKey2=structkeyarray(request.zos.siteManagerManual.idStruct);
        arraysort(arrKey2, "text");
        for(i2=1;i2 LTE arraylen(arrKey2);i2++){
            i=arrKey2[i2];
            cs=request.zos.siteManagerManual.idStruct[i];
            if(cs.id EQ 0){
                curTitle=cs.title;
            }else{
                curTitle=cs.id&". "&cs.title;
            }
			indentCount=(len(i) - len(replace(i,".","","all")))*4;
			
            t2=StructNew();
            t2.groupName="Documentation";
            t2.url=request.zos.globals.domain&'/z/admin/manual/view/'&cs.id&cs.url;
            t2.title=curTitle;
			if(indentCount){
				t2.indent=ljustify("", indentCount);
			}
            arrayappend(arguments.arrUrl,t2);
        }
    }
	return arguments.arrURL;
	</cfscript>
</cffunction>

<cffunction name="getDocLink" access="public" localmode="modern" returntype="struct">
    <cfargument name="id" type="string" required="yes">
    <cfscript>
	if(not structkeyexists(request.zos.siteManagerManual.idStruct, arguments.id)){
		return { success:false, errorMessage:"This documentation page doesn't exist yet." };
	}else{
		cs=request.zos.siteManagerManual.idStruct[arguments.id];
		return { success:true, link:'/z/admin/manual/view/'&cs.id&cs.url };
	}
	</cfscript>
</cffunction>
	
<cffunction name="findDoc" access="private" localmode="modern">
    <cfargument name="id" type="string" required="yes">
	<cfargument name="docLink" type="string" required="yes"><cfscript>
	if(arguments.id EQ ""){
		arguments.id=0;
	}
	if(not structkeyexists(request.zos.siteManagerManual.idStruct, arguments.id)){
		request.zos.functions.z404(arguments.id&" is not a valid id in request.zos.siteManagerManual.");
	}
	rs={ docStruct:request.zos.siteManagerManual.idStruct[arguments.id] };
	p=find(".", arguments.id);
	if(p EQ 0){
		dir=arguments.id;
	}else{
		dir=left(arguments.id, p-1);
	}
	tempIdFS=replace(arguments.id,".","-","all");
	dirFS=replace(dir,".","-","all");
	
	request.examplePath=request.zos.globals.homedir&"manual-files/"&dirFS&"/"&tempIdFS&"/examples/";
	if(fileexists(request.zos.globals.homedir&"manual-files/"&dirFS&"/"&tempIdFS&"/"&tempIdFS&".cfc")){
		temppath=request.zRootCFCPath&"manual-files."&dirFS&"."&tempIdFS&"."&tempIdFS;
		savecontent variable="rs.html"{
			tempCom=createobject("component", tempPath);
			request.manual=this;
			tempCom.index();
		}
	}else{
		rs.html="<p>There is nothing written for this page yet.</p>"
	}
	if(structkeyexists(request.zos.siteManagerManual.parentIdStruct, arguments.id)){
		rs.arrChild = request.zos.siteManagerManual.parentIdStruct[arguments.id];
	}else{
		rs.arrChild=[];
	}
	rs.arrSectionLinks=[];
	rs.arrParent=[];
	cs=rs.docStruct;
	for(i=1;i LTE 100;i++){
		if(cs.parentID EQ ""){
			break;
		}else if(i EQ 100){
			throw("There is an infinite loop in the parent ID configuration for the manual.","custom");	
		}
		arrayappend(rs.arrParent, cs.parentID);
		cs=request.zos.siteManagerManual.idStruct[cs.parentID];
	}
	if(compare("/"&arguments.docLink, rs.docStruct.url) NEQ 0){
		request.zos.functions.z301redirect('/z/admin/manual/view/'&arguments.id&rs.docStruct.url);	
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getParentLinks" access="private" output="yes" localmode="modern">
	<cfargument name="manualStruct" type="struct" required="yes">
    <cfscript>
	if(arguments.manualStruct.docStruct.id EQ 0){
		return;
	}
	for(i=arraylen(arguments.manualStruct.arrParent);i GTE 1;i--){
		cs=request.zos.siteManagerManual.idStruct[arguments.manualStruct.arrParent[i]];
		if(cs.id EQ 0){
			curTitle=cs.title;
		}else{
			curTitle=cs.id&". "&cs.title;
		}
		writeoutput('<a href="/z/admin/manual/view/'&cs.id&cs.url&'">'&curTitle&'</a> / ');
	}
	</cfscript>
</cffunction>

<cffunction name="getContentsBox" access="private" output="yes" localmode="modern">
	<cfargument name="manualStruct" type="struct" required="yes">
	<cfscript>
	var local=structnew();
	childCount=arraylen(arguments.manualStruct.arrChild);
	</cfscript>
    <cfif childCount>
        <div class="zdoc-contents-box">
        <h3>Table of Contents</h3>
        <ul>
        <cfscript>
        for(i=1;i LTE childCount;i++){
            cs=request.zos.siteManagerManual.idStruct[arguments.manualStruct.arrChild[i]];
            writeoutput('<li><a href="/z/admin/manual/view/'&cs.id&cs.url&'" target="'&cs.target&'">'&cs.id&". "&cs.title&'</a> ');
			arrayappend(arguments.manualStruct.arrSectionLinks, '<li><a href="/z/admin/manual/view/'&cs.id&cs.url&'" target="'&cs.target&'">'&cs.id&". "&cs.title&'</a></li>');
            if(structkeyexists(request.zos.siteManagerManual.parentIdStruct, cs.id)){
                arrChild = request.zos.siteManagerManual.parentIdStruct[cs.id];
                writeoutput('&nbsp;<a href="##" class="zdoc-toggle-ul">+-</a> <ul>');
                for(n=1;n LTE arraylen(arrChild);n++){
                    cs2=request.zos.siteManagerManual.idStruct[arrChild[n]];
                    writeoutput('<li><a href="/z/admin/manual/view/'&cs2.id&cs2.url&'" target="'&cs2.target&'">'&cs2.id&". "&cs2.title&'</a></li>');
                }
                writeoutput('</ul>');
            }
            writeoutput('</li>');
        }
        </cfscript>
        </ul>
        </div>
    </cfif>
</cffunction>

<cffunction name="codeExample" output="yes" access="public" localmode="modern">
	<cfargument name="filePath" type="string" required="yes">
    <cfscript>
	var ext=request.zos.functions.zgetfileext(arguments.filePath);
	var absPath=request.examplePath&arguments.filePath;
	var t=0;
	if(not fileexists(absPath)){
		throw("The file, "&absPath&", doesn't exist.", "custom");
	}
	t=request.zos.functions.zreadfile(absPath);
	writeoutput('<div style="width:100%; float:left; margin-top:-25px;"><div style="float:right; width:100px; background-color:##FFF; font-size:70%; text-align:right;"><a href="##" data-codeexample="'&htmleditformat(t)&'" onclick="copyToClipboard(this.getAttribute(''data-codeexample'')); return false;">Copy '&ucase(ext)&' Example</a></div>');
	if(ext EQ 'cfm' or ext EQ 'cfc'){
		writeoutput('<pre class="prettyprint lang-html linenums prettyprinted"><code>');
	}else if(ext EQ 'php'){
		writeoutput('<pre class="prettyprint lang-php linenums prettyprinted"><code>');
	}else if(ext EQ 'sql'){
		writeoutput('<pre class="prettyprint lang-sql linenums prettyprinted"><code>');
	}else if(ext EQ 'js'){
		writeoutput('<pre class="prettyprint lang-js linenums prettyprinted"><code>');
	}else if(ext EQ 'css'){
		writeoutput('<pre class="prettyprint lang-css linenums prettyprinted"><code>');
	}else if(ext EQ 'html' or ext EQ "txt"){
		writeoutput('<pre class="prettyprint lang-html linenums prettyprinted"><code>');
    }
	writeoutput(htmleditformat(t)&'</code></pre></div>');
	</cfscript>
</cffunction>

<cffunction name="getSectionBox" access="private" output="yes" localmode="modern">
	<cfargument name="manualStruct" type="struct" required="yes">
    <cfscript>
	var local=structnew();
	</cfscript>
    <div class="zdoc-section-box">
        <h3>Full Documentation</h3>
        
        <!--- <h3>Search Our Site</h3>
        <div class="zdoc-search-box">
            <form action="##" method="get" onsubmit="zContentTransition.gotoURL('/search/index?q='+escape(document.getElementById('googlesearchtext832').value)); return false;"><input type="text" name="googlesearchtext" id="googlesearchtext832" value="" style="width:145px;padding:3px; font-size:1.0em; margin-right:5px;" /> <input type="submit" name="submit3822" value="Go" style="padding:3px; padding-bottom:1px; font-size:1.0em; border:1px solid ##136;cursor:pointer;  background-color:##369; border-radius:5px; color:##FFF;" /> 
            </form>
        </div> --->
        <cfscript>
		arrSectionLinks=[];
		sectionCount=arraylen(arguments.manualStruct.arrSectionLinks);
		if(sectionCount){
			arrayappend(arrSectionLinks, '<ul>');
			for(i=1;i LTE sectionCount;i++){
				arrayappend(arrSectionLinks, arguments.manualStruct.arrSectionLinks[i]);
			}
			arrayappend(arrSectionLinks, '</ul>');
		}
		writeoutput('<h3>Section Navigation</h3>');
		if(structkeyexists(request.zos.siteManagerManual.parentIdStruct, arguments.manualStruct.docStruct.parentId)){
			arrChild = request.zos.siteManagerManual.parentIdStruct[arguments.manualStruct.docStruct.parentId];
			if(arguments.manualStruct.docStruct.parentId NEQ ""){
				cs=request.zos.siteManagerManual.idStruct[arguments.manualStruct.docStruct.parentId];
				if(cs.id EQ 0){
					writeoutput('<a href="/z/admin/manual/view/'&cs.id&cs.url&'" target="'&cs.target&'">'&cs.title&'</a>');
				}else{
					writeoutput('<a href="/z/admin/manual/view/'&cs.id&cs.url&'" target="'&cs.target&'">'&cs.id&". "&cs.title&'</a>');
				}
			}
			writeoutput('<ul>');
			for(n=1;n LTE arraylen(arrChild);n++){
				cs2=request.zos.siteManagerManual.idStruct[arrChild[n]];
				if(arguments.manualStruct.docStruct.id EQ cs2.id){
					writeoutput('<li>');
					if(cs2.id EQ 0){
						writeoutput(cs2.title);
					}else{
						writeoutput(cs2.id&". "&cs2.title);
					}
					writeoutput(arraytolist(arrSectionLinks, ""));
					writeoutput('</li>');
				}else{
					writeoutput('<li><a href="/z/admin/manual/view/'&cs2.id&cs2.url&'" target="'&cs2.target&'">'&cs2.id&". "&cs2.title&'</a></li>');
				}
			}
			writeoutput('</ul>');
		}else{
			writeoutput(arraytolist(arrSectionLinks, ""));
		}
		</cfscript>
    </div>
</cffunction>

 <cffunction name="renderTable" access="public" output="yes" localmode="modern">
 	<cfargument name="arrColumn" type="array" required="yes">
 	<cfargument name="arrRow" type="array" required="yes">
    <cfscript>
	var local=structnew();
	rowCount=arraylen(arguments.arrRow);
	columnCount=arraylen(arguments.arrColumn);
	writeoutput('<table class="zdoc-table">');
	writeoutput('<tr>');
	for(n=1;n LTE columnCount;n++){
		writeoutput('<th>'&arguments.arrColumn[n]&'</th>');
	}
	writeoutput('</tr>');
	for(i=1;i LTE rowCount;i++){
		if(i MOD 2 EQ 0){
			writeoutput('<tr class="zdoc-table-row-even">');
		}else{
			writeoutput('<tr class="zdoc-table-row-odd">');
		}
		for(n=1;n LTE columnCount;n++){
			writeoutput('<td>'&arguments.arrRow[i][arguments.arrColumn[n]]&'</td>');
		}
		writeoutput('</tr>');
	}
	writeoutput('</table>');
	</cfscript>
 </cffunction>

<cffunction name="view" access="remote" output="yes" roles="member" localmode="modern">
    <cfargument name="id" type="string" required="no" default="">
    <cfargument name="docLink" type="string" required="no" default=""><cfscript>
	var manualStruct=0;
	var curTitle=0;
	var curTitle2=0;
	var theParent=0;
	init();
	manualStruct=this.findDoc(arguments.id, arguments.docLink);
	curTitle=manualStruct.docStruct.id&". "&manualStruct.docStruct.title;
	curTitle2=manualStruct.docStruct.id&". "&manualStruct.docStruct.title;
	if(manualStruct.docStruct.id EQ 0){
		curTitle=manualStruct.docStruct.title;
		curTitle2=manualStruct.docStruct.title;
	}
	request.zos.template.setTag("title", curTitle);
	request.zos.template.setTag("pagetitle", curTitle2);
	</cfscript>
    <cfif manualStruct.docStruct.target EQ "_blank">
        #manualStruct.html#
    <cfelse>
        <div class="zdoc-container ieWidthDivClass">
        <!--- <div class="zdoc-sidebar"> --->
        <!--- </div> --->
        <div class="zdoc-main-column ieWidthDivClass4">
            <cfsavecontent variable="theParent"><a href="/z/admin/help/index">Home</a> / #this.getParentLinks(manualStruct)#</cfsavecontent>
            <cfscript>request.zos.template.setTag("pagenav", theParent);</cfscript>
            
            #this.getContentsBox(manualStruct)#
            
            #manualStruct.html#
            <cfif structkeyexists(form, 'generateDocs')>
            <p>For the latest info, vist this page on the web: <a href="#request.zos.globals.domain##form[request.zos.urlRoutingParameter]#">#request.zos.globals.domain##form[request.zos.urlRoutingParameter]#</a></p>
            </cfif><!--- 
	        <cfscript>
	        if(request.zos.functions.zIsExternalCommentsEnabled()){
	            writeoutput('<div style="width:100%; float:left;border-top:1px dotted ##CCC; margin-top:10px; padding-top:10px;">'&request.zos.functions.zDisplayExternalComments(form[request.zos.urlRoutingParameter], curTitle, request.zos.globals.domain&form[request.zos.urlRoutingParameter])&'</div>');
	        }
	        </cfscript> --->
        </div>
        #this.getSectionBox(manualStruct)#
        </div>
	</cfif>
</cffunction>


    </cfoutput>
</cfcomponent>