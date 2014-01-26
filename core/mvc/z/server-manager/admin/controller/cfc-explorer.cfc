<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
<cfscript>
form.action=application.zcore.functions.zso(form, 'action',false,'list');
//request.zos.page.setactions(structnew());
Request.zPageDebugDisabled=1;
compath=application.zcore.functions.zso(form, 'compath');
if(structkeyexists(form, 'hideheader')){
	application.zcore.template.setTemplate("zcorerootmapping.templates.plain", true, true);
	application.zcore.template.abort(application.zcore.functions.zso(session, 'lastcfccomvalue'));
} 
</cfscript><!--- 
auto-doc ideas
what if i make a function that documents the structure by either reading the cfcomment and displaying that with cffile  or we create functions that define the structure arguments

 --->
 <cfif structkeyexists(form, 'expand')>
 <cfset session.expand=expand>
 <cfelseif isDefined('session.expand') eq false>
 <cfset session.expand="toggle">
 </cfif>
 <cfif structkeyexists(form, 'enableclipboard')>
 <cfset session.explorerenableclipboard=enableclipboard>
 <cfelseif isDefined('session.explorerenableclipboard') eq false>
 <cfset session.explorerenableclipboard="enabled">
 </cfif>
 <cfif structkeyexists(form, 'enablefullcode')>
 <cfset session.explorerenablefullcode=enablefullcode>
 <cfelseif isDefined('session.explorerenablefullcode') eq false>
 <cfset session.explorerenablefullcode="disabled">
 </cfif>
 <cfif structkeyexists(form, 'hideheader') eq false>
 <cfscript>application.zcore.functions.zstatushandler(request.zsid);</cfscript>
<table style="border-spacing:0px;width:100%;" class="table-white">
<tr>
<td><h2>CFC Explorer</h2>
<!--- | <cfif session.expand eq 'toggle'><a href="#request.cgi_script_name#?expand=always&compath=#urlencodedformat(compath)#">Expand Comments</a><cfelse><a href="#request.cgi_script_name#?expand=toggle&compath=#urlencodedformat(compath)#">Hide Comments</a></cfif> | <cfif session.explorerenableclipboard eq 'disabled'><a href="#request.cgi_script_name#?enableclipboard=enabled&compath=#urlencodedformat(compath)#">Enable Clipboard</a><cfelse><a href="#request.cgi_script_name#?enableclipboard=disabled&compath=#urlencodedformat(compath)#">Disable Clipboard</a></cfif>
 | <cfif session.explorerenablefullcode eq 'disabled'><a href="#request.cgi_script_name#?enablefullcode=enabled&compath=#urlencodedformat(compath)#">Enable Full Code</a><cfelse><a href="#request.cgi_script_name#?enablefullcode=disabled&compath=#urlencodedformat(compath)#">Disable Full Code</a></cfif>
--->
</td></tr>
</cfif>
 <cfscript>
	arrPage = application.zcore.functions.zOS_recurseSiteDir(application.zcore.functions.zvar('serverhomedir'), '/zcorerootmapping/', '/', false,1,true,"",true);
	//application.zcore.functions.zdump(arrpage);
	arrc=arraynew(1);
	for(i=1;i lte arraylen(arrpage);i++){
		if(right(arrpage[i].coldfusionroot,4) eq '.cfc'){
			arrayappend(arrc,arrpage[i].coldfusionroot);
			//writeoutput('<a href="#request.cgi_script_name#?compath=#arrpage[i].coldfusionroot#">#arrpage[i].coldfusionroot#</a><br />');
		}
	}
	</cfscript>
    
 <cfif structkeyexists(form, 'hideheader') eq false>
<tr><td> 
<!---<p>CLIPBOARD FEATURE IS BROKEN: Clicking on a function prototype will expand its comments and copy
 them to the clipboard. Note: IE 7 users: To permanently allow clipboard access, 
 go to Tools / Internet Options / Security / Custom Level / Allow Programmatic Clipboard Access / 
 Set to Enabled</p>--->
Component: 
    <script type="text/javascript">
	function gotoCom(id){
		if(id !=''){
			window.location.href='#request.cgi_script_name#?compath='+escape(id);
		}
	}
	</script>
    <style type="text/css">
	.monostyle{
		font-size:13px; font-family:monospace;
	}
	</style>
			zcorerootmapping.<cfscript>
			selectStruct = StructNew();
			selectStruct.name = "compath";
			selectStruct.selectLabel = "-- No Selection --"; // override default first element text
			selectStruct.onChange="gotoCom(this.value);";
			// options for query data
			selectStruct.listLabels = replace(replace(replace(arraytolist(arrc),'/zcorerootmapping/','','all'),"/",".","all"),".cfc","","all");
			selectStruct.listValues = arraytolist(arrc);	
			//selectStruct.style="monostyle";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
            </cfif>
 <cfif application.zcore.functions.zso(form, 'compath') neq ''>
            <cfscript>
abspath=request.zos.globals.serverHomedir;
component=replace(replacenocase(replace(compath,'/z/','zcorerootmapping/'),'.cfc',''),'/','.','ALL');


try{
	d=getcomponentmetadata(component);
}catch(Any excpt){
	application.zcore.status.setStatus(request.zsid,'<a href="/'&replace(component,".","/","all")&'.cfc" style="color:##FF0000;" target="_blank">#component#</a> failed to compile, please correct the errors before continuing.');
	application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#request.zsid#");
}

fc=application.zcore.functions.zreadfile(abspath&replace(removechars(component,1,5),".","/","all")&'.cfc');
arrname=listtoarray(replace(removechars(component,1,5),".","/","all"),'/');
comname=application.zcore.functions.zurlencode(arrname[arraylen(arrname)],'_')&'Com';
s=true;
tc=fc;
fc=rereplacenocase(fc,"(<cffunction  [^>]*>).*?(</cffunction>)","\1\2","ALL");

fc=rereplacenocase(fc,"(.*</cfcomponent>).*","\1","ALL");
arr=rematch("<"&"\!---(?:.(?!<\!---))*?--->[^<]*(<cffunction [^>]*>).*?(</cffunction>)",fc);
//application.zcore.functions.zdump(arr);
//application.zcore.functions.zabort();
// loop find all function's line numbers
//writeoutput(htmlcodeformat(fc));
//application.zcore.functions.zabort();
/*while(s){
	pos=findnocase("<cffunction localmode="modern" ",fc);
	if(pos EQ 0){
		s=false;
		break;
	}
	//pos2=findnocase("<"&"!---",reverse(fc),pos);
	//if(pos2
}*/
//application.zcore.functions.zdump(d);
funcstruct=structnew();
func2=structnew();
//application.zcore.functions.zdump(d);
if(structkeyexists(d,'functions')){
for(i=1;i lte arraylen(d.functions);i++){
	funcpos=refindnocase(' name\s*=\s*(''|")'&d.functions[i].name&'\1 ',tc);
	if(funcpos eq 0){
		linenumber=0;
	}else{
	ts=left(tc,funcpos);
	lineNumber=len(ts)-len(replace(ts,chr(10),'','ALL'))+1;
	}
	t2=structnew();
	t2.label=d.functions[i].name;
	t2.value=lineNumber;
	t2.i=i;
	func2[i]=t2;
	arrp=arraynew(1);
	for(n=1;n lte arraylen(d.functions[i].parameters);n++){
		str=d.functions[i].parameters[n].name;
		if(structkeyexists(d.functions[i].parameters[n],'type')){
			str&="_"&ucase(d.functions[i].parameters[n].type);
		}
		if(structkeyexists(d.functions[i].parameters[n],'required') and d.functions[i].parameters[n].required eq 'yes'){
			str&="_REQUIRED";
		}
		arrayappend(arrp, str);
	}
	comments="";
	for(n=1;n lte arraylen(arr);n++){
		if(refindnocase(' name\s*=\s*"'&d.functions[i].name&'" ',arr[n]) NEQ 0){
			comments=trim(rereplacenocase(arr[n],'<\!---(.*)--->?(.*)?<cffunction localmode="modern" .*</cffunction>','\1'));
			break;
		}
	}
	str="";
	if(structkeyexists(d.functions[i],'roles')){
		str&='<span style="color:##990000;font-weight:bold;">roles:</span> '&d.functions[i].roles&' | ';
	}
	if(structkeyexists(d.functions[i],'access')){
		str&='<span style="color:##990000;font-weight:bold;">access:</span> '&d.functions[i].access&' | ';
	
	}
	if(structkeyexists(d.functions[i],'hint')){
		str&='<span style="color:##990000;font-weight:bold;">hint:</span> '&d.functions[i].hint&' ';
	}
	if(str neq ''){
		str='</tr><tr><td style=" ##bg##">&nbsp</td><td colspan="2" style="font-size:12px; ##bg##">'&str;			
	}
	funcstruct[d.functions[i].name]=StructNew();
	funcstruct[d.functions[i].name].lineNumber=lineNumber;
	funcstruct[d.functions[i].name].str="";
	if(comments eq ''){
		funcstruct[d.functions[i].name].str&='<a name="func_#i#"></a><a href="##" onclick="togglecomment(#i#); copycomments(#i#); return false;"><span id="rowp#i#">#comname#.<span style="font-size:14px;font-weight:bold;">'&d.functions[i].name&"</span>("&arraytolist(arrp,", ")&");"&'</span><span id="row#i#"></span></a><TEXTAREA name="holdtext#i#" ID="holdtext#i#" style="width:1px; height:1px;display:none;"></TEXTAREA></td>'&str;
	}else{
		displaystate="none";
		if(session.expand neq 'toggle'){
			displaystate="block";
		}
		funcstruct[d.functions[i].name].str&='<a name="func_#i#"></a><a href="##" onclick="togglecomment(#i#); copycomments(#i#); return false;"><span id="rowp#i#">#comname#.<span style="font-size:14px;font-weight:bold;">'&d.functions[i].name&"</span>("&arraytolist(arrp,", ")&");"&'</span></a><TEXTAREA name="holdtext#i#" ID="holdtext#i#" style="width:1px; height:1px;display:none;"></TEXTAREA></td>'&str;
		funcstruct[d.functions[i].name].str&='</tr><tr id="row#i#" style="display:#displaystate#;"><td style=" ##bg##">&nbsp;</td><td colspan="2" style="font-size:12px; ##bg##">'&htmlcodeformat(replace(comments,chr(10)&chr(9),chr(10),'all'));
	}
}
}
//application.zcore.functions.zdump(func2);
			
			arrkey=structsort(func2,"text","asc","label");
			arrfunc=arraynew(1);
			arrfuncvalue=arraynew(1);
			for(i=1;i lte arraylen(arrkey);i++){
				arrayappend(arrfunc,func2[arrkey[i]].label);
				arrayappend(arrfuncvalue,func2[arrkey[i]].i);
			}
			</cfscript>
            
 <cfif structkeyexists(form, 'hideheader') eq false>
             Function: 
    <script type="text/javascript">
	function gotoCom(id){
		if(id !=''){
			window.location.href='#request.cgi_script_name#?compath='+escape(id);
		}
	}
	var rootsrc='#request.cgi_script_name#?hideheader=1';
	function gotoLine(num){
		var d=document.getElementById("comframe"); 
		if(num ==''){
			d.src=rootsrc+'##top';
		}else if(num.substr(0,1) != '##'){
			//d.window.copycomments(num);	
			d.src=rootsrc+'##func_'+num;
		}else{
			//d.window.copycomments(num);	
			d.src=rootsrc+num;
		}
	}
	</script><!--- 
    <textarea name="holdtext" id="holdtext" --->
			<cfscript>
			selectStruct = StructNew();
			selectStruct.name = "function";
			selectStruct.selectLabel = "-- No Selection --"; // override default first element text
			selectStruct.onChange="gotoLine(this.value);";//document.frames['comframe'].togglecomment(this.value,'block');";
			// options for query data
			selectStruct.listLabels = arraytolist(arrfunc);
			selectStruct.listValues = arraytolist(arrfuncvalue);	
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
            
            </cfif>
            </cfif>
            
            
 <cfif structkeyexists(form, 'hideheader') eq false>
</td>
</table> 
<iframe  name="comframe" id="comframe" src="#request.cgi_script_name#?hideheader=1" style="width:100%; height:600px;border:none; overflow:auto;" seamless="seamless"></iframe>
<script type="text/javascript">
/* <![CDATA[ */
zArrDeferredFunctions.push(function(){
	$(window).bind("resize", resize_iframe);
	$(window).bind("clientresize", resize_iframe);
	zIntervalIdForCFCExplorer=setInterval(function(){ resize_iframe(); },100);
});
/* ]]> */
</script> 
</cfif>
<cfsavecontent variable="session.lastcfccomvalue">
<a name="top"></a>
 <table class="small" style="border-spacing:0px;line-height:18px; background-color:##efefef;">
<tr>
<td>

 <cfif form.action EQ "list">
 <cfif application.zcore.functions.zso(form, 'compath') neq ''>
<cfscript>
writeoutput('<p>#comname#=createObject("component","#removechars(component,1,1)#");</p>');

			
extending=true;
g=0;
dcur=d;
arrInherit=arraynew(1);
while(extending){
	g++;
	if(structkeyexists(dcur,'extends')){
		dcur=dcur.extends;
		arrayappend(arrInherit, '<a href="#request.cgi_script_name#?compath='&urlencodedformat(dcur.fullname)&'" target="_blank">'&dcur.name&'</a>');
	}else{
		extending=false;
	}
	if(g GT 200){
		break;
	}
}
arraydeleteat(arrInherit,arraylen(arrInherit));
if(arraylen(arrInherit) NEQ 0){
	writeoutput('<strong>Inheritance:</strong> '&arraytolist(arrInherit,", ")&"<br /><br />");
}
if(structkeyexists(d,'implements')){
	writeoutput('<strong>Interface:</strong> '&structkeylist(d.implements)&'<br /><br />');
}

if(structkeyexists(d,'hint')){
	writeoutput('<p>Component Description: #application.zcore.functions.zparagraphformat(trim(d.hint))#</p>');
}
arrkeys=listtoarray(structkeylist(funcstruct));
writeoutput('<table style="border-spacing:0px;font-size:11px;">');
if(arraylen(arrkeys) NEQ 0){
	writeoutput('<tr><td>Line</td><td>Function</td></tr>');
}
arraysort(arrkeys,"text","asc");
for(i=1;i lte arraylen(arrkeys);i++){
	bgcolor="background-color:##DFDFDF;";
	if(i mod 2 eq 0){
		bgcolor="background-color:##E5E5E5";
	}
	writeoutput('<tr><td style="border-top:1px solid ##cccccc; #bgcolor# text-align:right; ">');
	if(session.explorerenablefullcode eq 'enabled'){
		writeoutput('<a href="##line#funcstruct[arrkeys[i]].lineNumber#">#funcstruct[arrkeys[i]].lineNumber#</a>');
	}else{
		writeoutput(funcstruct[arrkeys[i]].lineNumber);
	}
	writeoutput('</td><td style="border-top:1px solid ##cccccc; #bgcolor#">'&replace(funcstruct[arrkeys[i]].str,'##bg##',bgcolor,'all')&"</td></tr>");
}
writeoutput('</table>');
if(session.explorerenablefullcode eq 'enabled'){
	arrlines=listtoarray(replace(replace(htmlcodeformat(tc),chr(9),"&nbsp;&nbsp;&nbsp;&nbsp;","ALL")," ","&nbsp;","all"),chr(10),true);
	writeoutput('<br /><hr /><table style="width:100%;font-family:monospace; font-size:11px; margin-bottom:1000px;">');
	
	for(i=1;i lte arraylen(arrlines);i++){
		writeoutput('<tr><td style="vertical-align:top; text-align:right; background-color:##cccccc; white-space:nowrap;"><a name="line#i#"></a>&nbsp;###i#&nbsp;</td><td style="vertical-align:top;padding-left:5px;">'&arrlines[i]&'</td></tr>');
	}
	writeoutput('</table>');
}
</cfscript>
<table style=" margin-bottom:1000px;">
<tr>
<td>&nbsp;</td>
</tr>
</table>
<script type="text/javascript">
	function copycomments(id){ 
		var i=document.getElementById("row"+id);
		var ip=document.getElementById("rowp"+id);
		var i2=document.getElementById("holdtext"+id);
		i2.innerText = ip.innerText+"\n"+i.innerText;
		i2.focus();
		i2.select();
		<!---<cfif session.explorerenableclipboard eq 'enabled'>
		Copied = i2.createTextRange();
		Copied.execCommand("Copy");
		</cfif>--->
	}
	window.copycomments=copycomments;
function togglecomment(id,s){
<cfif session.expand eq 'toggle'>
	var i=document.getElementById("row"+id);
	if(i.style.display=="none" || (s && s=="block")){
		i.style.display="block";
	}else{
		i.style.display="none";
	}
	</cfif>
}
</script>
</cfif>
</cfif>
</td>
</tr>
</table>
</cfsavecontent>
</cffunction>
</cfoutput>
</cfcomponent>