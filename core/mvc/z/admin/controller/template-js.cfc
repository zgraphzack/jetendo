<cfcomponent>
<cffunction name="initSession" localmode="modern">
	<cfargument name="k" type="string" required="yes">
	<cfscript>
	// var c= grab from kv store(k);
	// loop the groups and set the struct or array:
	// set the group struct
	sessionGroups["member"]=true;
	sessionGroups["user"]=true;
	</cfscript>
</cffunction>

<cffunction name="initSession" localmode="modern">
	<cfargument name="k" type="string" required="yes">
	<cfargument name="v" type="any" required="yes">
	<cfscript>
	kvStore[arguments.k]=arguments.v;
	</cfscript>
</cffunction>

<cffunction name="getKvStoreValue" localmode="modern">
	<cfargument name="k" type="string" required="yes">
	<cfscript>
	if(structkeyexists(kvStore, k)){
		return kvStore[k];
	}else{
		return "";
	}
	</cfscript>
</cffunction>
	
<cffunction name="getAllKvStoreValues" localmode="modern">
	<cfscript>
	return kvStore;	
	</cfscript>
</cffunction>
	
<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	disabled until i work on it again.<cfscript>application.zcore.functions.zabort();application.zcore.template.setTemplate("zcorerootmapping.templates.blank",true,true);</cfscript><script type="text/javascript">
var zSkinApp={};

zSkinApp.javascriptTemplateCache=[];
zSkinApp.loadJavascriptCallback=function(r){
	var r2=eval("("+ r + ")");
	for(var i=0;i < r2.arrJS.length;i++){
		zSkinApp.javascriptTemplateCache[r2.arrJS[i].file]=true;
		zSkinApp.renderObj[r2.arrJS[i].renderObj].renderCallbackFunction=r2.arrJS[i].callbackFunction;
	}
	zSkinApp.loadIndex--;
	if(zSkinApp.loadIndex == 0){
		zSkinApp.onLoadComplete();	
	}
}
zSkinApp.loadJavascriptFiles=function(fileList){
	
	var tempObj={};
	tempObj.id="zAjaxLoadJavascript";
	tempObj.url="/z/_com/display/skin?method=loadJS";
	tempObj.postData="filelist="+escape(fileList);
	tempObj.cache=false;
	tempObj.method="post";
	tempObj.callback=zSkinApp.loadJavascriptCallback;
	tempObj.ignoreOldRequests=false;
	zAjax(tempObj);	
	//zLoadJavascriptCallback();
}

zSkinApp.renderObj=[];
// js file naming convention: _ is directory separator, - is file name word separator

// track the rendered template areas so I can compare when a new template will be render whether or not I need to reexecute the other templates
zSkinApp.pageState={
	pageTemplate:"layout_default",
	noSidebars:false /*,
	divid1:"sometemplate",
	divid2:"sometemplate2" */
}
zSkinApp.renderObj["layout_default"]={
	id:"layout_default",
	templateURL:"/z/static/skin/view/js/layout/default.js",
	arrRequest:["default"],
	dataURL:"/template.cfc?method=getLayout"
}

zSkinApp.renderObj["blog_article"]={
	id:"blog_article",
	templateURL:"/z/static/skin/view/js/blog/article.js",
	dataUsage:{
		query1:["title","date","user","email"],
		query2:["title"]
	},
	arrRequest:["blog_article","blog_comments"],//,"blog-related","blog_popular"], // allows parallel query building on the server-side
	dataURL:"/blog.cfc?method=article",
	regex:"-6-([0-9]*).html",
	target:"default"
}
zSkinApp.renderObj["blog_related"]={
}

zSkinApp.renderObj["blog_popular"]={
}
zSkinApp.renderObj["blog_comments"]={
	id:"blog_comments",
	templateURL:"/z/static/skin/view/js/blog/comments.js",
	dataUsage:{
		query1:["title","date","user","email"],
		query2:["title"]
	},
	arrRequest:["blog_comments"],
	dataURL:"/blog.cfc?method=comments",
	target:"zBlogArticleCommentsDiv", // not accessible until the parent template has rendered and been placed in the dom because it is part of the blog_article template.
	parentTemplate:"blogArticle",
	lazyLoad:true // eventually I need to implement this so that the div doesn't call the AJAX or render until it is within X pixels of being visible
}
/* if I override a template for a specific section, this creates additional zSkinApp.renderObj objects.
example:
zSkinApp.renderObj["blog_article_custom-2"]={
	// custom dataUsage and templateURL, etc
}
if i have a static js file for all custom urls, this would help a lot in mapping non-standard urls and urls with customized themes.
	think of an alternate method for letting javascript know how to render URLs that aren't given the className or standard url format.
zSkinApp.static={
	arrF:["filepath":datahere..];
	
}
			
			setup template so that onRenderComplete calls compareRenderedTemplateWithPrevious before attaching to the dom.
			
			
	need to think about how I handle the request url.  Do I convert it into parameters or do i just hit the server with it and append a ?zgetajaxdata=1 to it
		when zgetajaxdata is defined, i need to:
			disable template rendering
			disable the debugger
			disable other unnecessary components
	it might be better it one of the class names is linkdbid1-9324 so i can call the ajax request with the most minimal server-side configuration possible.
	for example:
		this is where I define the javascript query data structures so that I can generate blog article query on the client-side and then run a server side security filter against the query.
		javascript queries should be executed by a datasource defined with a user that has SELECT access only
*/
zSkinApp.arrRenderCache=[];
zSkinApp.arrReCache=[];
zSkinApp.arrResponseCache=[];
zSkinApp.loadRequest=function(){
	//alert(this.zLinkDataIndex);
		this.href="#";
		var cObj=zSkinApp.renderObj[this.zLinkDataIndex];
		var fileList="";
		for(var n=0;n<cObj.arrRequest.length;n++){
			var c=zSkinApp.renderObj[cObj.arrRequest[n]];
			if(typeof c.templateURL != "undefined" && typeof zSkinApp.javascriptTemplateCache[c.templateURL] == "undefined"){
				if(n != 0){
					fileList+=",";
				}
				fileList+=c.templateURL;
			}
		}
		if(fileList != ""){
			zSkinApp.loadIndex++;
			zSkinApp.loadJavascriptFiles(fileList);
		}
		// check if ajax response is cached for this request obj
		if(typeof zSkinApp.arrResponseCache[this.href] != "undefined"){
			// add to render template queue
			zSkinApp.renderResponseData(zSkinApp.arrResponseCache[this.href]);
		}else{
			// add the ajax calls to the queue
			zSkinApp.getSkinData(this);
		}
	try{
		// find which skins are needed to render request and download the static files as separate ajax requests so they are cached and eval them so i can call them as objects or functions
	} catch (e) {
		// prevents reloading page on errors
		this.href="#";
		throw e;
	}
	return false;
}
zSkinApp.loadIndex=0;
zSkinApp.dataObj=[];
zSkinApp.arrRequest=[];
zSkinApp.cacheIndex=0;
zSkinApp.getSkinData=function(obj){
	zSkinApp.loadIndex++;
	zSkinApp.arrRequest[zSkinApp.cacheIndex]={url:obj.href,zLinkDataIndex:obj.zLinkDataIndex};
	
	// enable the server to return just the data needed for the skin rendering
	var postObj={};
	postObj.cacheIndex=zSkinApp.cacheIndex;
	var qs="";
	var cObj=zSkinApp.renderObj[obj.zLinkDataIndex];
	for(var n=0;n<cObj.arrRequest.length;n++){
		var c=zSkinApp.renderObj[cObj.arrRequest[n]];
		if(typeof c.dataUsage != "undefined"){
			var c1=cObj.id;//"blog_comments"; // needs to be dynamic based on zLinkData later
			for(var i in c.dataUsage){
				c1+=" "+i+"~"+c.dataUsage[i].join(",");
			}
			c1+="\t";
			qs+=c1;
		}
	}
	postObj.queries=qs;
	// post was added to zAjax BUT not tested - must upload zForm.js too
	var tempObj={};
	tempObj.id="zAjaxGetSkinData";
	tempObj.url="/z/_com/display/skin?method=getSkinData";
	tempObj.postObj=postObj;
	tempObj.cache=false;
	tempObj.method="post";
	tempObj.callback=zSkinApp.getSkinDataCallback;
	tempObj.ignoreOldRequests=false;
	zSkinApp.cacheIndex++;
	zAjax(tempObj);	
	//zSkinApp.getSkinDataCallback();
}


zSkinApp.getSkinDataCallback=function(r){
	zSkinApp.loadIndex--;
	var r2=eval('(' + r + ')');
	zSkinApp.arrResponseCache[zSkinApp.arrRequest[r2.cacheIndex].url]=r2;
	zSkinApp.renderResponseData(r2);
	if(zSkinApp.loadIndex == 0){
		zSkinApp.onLoadComplete();	
	}
}
zSkinApp.arrRenderQueue=[];
zSkinApp.renderResponseData=function(obj){
	zSkinApp.arrRenderQueue.push(obj.cacheIndex);
}
zSkinApp.onLoadComplete=function(){
	//alert('renderQueue running:'+zSkinApp.arrRenderQueue.join("\n"));	
	for(var i=0;i<zSkinApp.arrRenderQueue.length;i++){
		var c=zSkinApp.arrRenderQueue[i];
		var r={
			requestObj: zSkinApp.arrRequest[c],
			responseObj: zSkinApp.arrResponseCache[zSkinApp.arrRequest[c].url],
			renderObj: zSkinApp.renderObj[zSkinApp.arrRequest[c].zLinkDataIndex]
		};
		var r2=r.renderObj.renderCallbackFunction(r);
		if(typeof zSkinApp.arrRenderCache[c] != "undefined" && r2 == zSkinApp.arrRenderCache[c]){
			// identical to last render - don't update dom
			continue;	
		}
		zSkinApp.arrRenderCache[c]=r2;
		alert(r2);
		// attach to dom elements based on renderObj data like full page, content, or set of divs, etc
	}
}

zSkinApp.onLoad=function(t){
	if(typeof t == "undefined"){
		t="a";
	}
	var a=document.getElementsByTagName(t);
	var c=[];
	for(var i=0;i<a.length;i++){
		a[i].href=a[i].href.trim();
		var p=a[i].href.indexOf("#");
		var noHash=a[i].href;
		if(p != -1){
			noHash=a[i].href.substr(0,p);
		}
		//alert(noHash+"\n"+window.location.href);
		
		
		if(noHash == "" || noHash == window.location.href || noHash.substr(0,11) == "javascript:"){
			continue; // ignore anchor links and javascript links
		}
		c.push(i+"="+a[i].href);
		// check if external link
		var external=false;
		if(external){
			// force new window behavior by setting onclick (only if it isn't already)
			if(a[i].onclick == null){
				a[i].onclick="window.open(this.href); return false;";
			}
			continue;
		}else{
			if(a[i].className.indexOf("zlink") != -1){
				var d=a[i].className.split(" ");
				var found=false;
				for(var n=0;n<d.length;n++){
					if(d[n]=="zlink" && d.length> n+1){
						a[i].zLinkDataIndex=d[n+1];
						found=true;
						break;
					}
				}
				if(found){
					a[i].onclick=zSkinApp.loadRequest;
				}
				//alert(' i did it:'+a[i].href);
			}else{
				// attempt to detect link via the url structure
				if(1 == 0){ // temporary
					// apply link data
				}else{
					// do nothing // i.e. a full page reload onclick because we can't control this one correctly otherwise
					continue;
				}
			}
		}
	}
	//alert(c.join("\n"));
	if(t != "area"){
		zSkinApp.onLoad("area");
	}
}
zArrDeferredFunctions.push(function(){zSkinApp.onLoad();});
</script>
<cfsavecontent variable="theCSS">
			<style type="text/css">
			#entirepage{width:1000px; height:500px; background-color:#666;}
			#header{width:960px; margin:0 auto; height:100px; background-color:#AAA;}
			#maincontent{width:960px; margin:0 auto; height:200px;  background-color:#999;}
			#specificdiv{width:300px; float:left; height:100px; background-color:#CCC;}
			</style>
            </cfsavecontent>
            <cfscript>
			application.zcore.template.appendTag("meta",theCSS);
			</cfscript>
			<a id="zLink1" href="/blog_article.html" class="zlink blog_article">Article</a>
            
            <div id="entirepage">
            <div id="header">Header</div>
            <div id="maincontent">
            
            <div id="specificdiv"></div>
            
            <br style="clear:both;" />
            </div>
            </div>
            
           <!---  
		   
 then i need to work on attaching the rendered templates to the dom.
 
 then i need to make the skin component generate .js functions in addition to the CFCs it already does (html 5 template language) request.zos.skin, etc.
 	it must detect which fields are used and generate the zSkinApp.renderObj data structures with dataUsage for each query
    
might want coldfusion to also generate compiled select queries for the views so that the query is executed by name as a prepared statement instead of dynamically compiled with the security filter over and over.  the compiled query names can be embedded in the renderObj data structure.

 <cfscript>application.zcore.functions.zabort();</cfscript> ---> 
<!--- 


pageTemplate:"default", // pageTemplate:"custom-template"

		need a way of defining the scope of what elements are going to be re-rendered. 
			i.e.
			entirepage (header, middle and footer)
			nosidebars - entire width of site (removal of sidebars)
			default - main content block (leaves sidebars unchanged)
			divid1,divid2,divid3 - a specific set of divs and variables (just updates a small box or boxes in the page)
			
			target=page|fullmiddle|div list|default(main content column)
			page destroys all body elements and reruns the window.onload events.
			fullmiddle destroys all elements inside the X element and renders
			div list & default render to specific IDs.
			
			attach templates to events that cause them to re-render if the data value changes.
				for example, call a function like
				var arrRender=[];
				for(i in checkDataObj){
					var c=checkDataObj[i];
					if(eval(c.dataField) != c.lastDataValue){
						arrRender.push(c.template);
					}
				}
				// render all of the templates in the arrRender array in addition to the new views that were called.
			
			i only need to do this for templates which access global variables like page or cgi because everything else is self-contained
				it must be able to detect global variables within nested includes.
			bad idea because md5 is hugely slower: store md5 hash for each rendered template - OR - store the logic coverage sequence that resulted from render like this (which eliminates changing data): if,elseif1,if,if,else or a numeric version of that
			loop blog { if( page.title EQUALS blog.title){ show nolink }else{ show link } } requires a full render to function, however if we re-render based on seeing that page.title changed, then we can verify render result string length.  if they are the same, then do a string comparison to be even more sure they are the same.
			
			
			how do we transition from home page to subpage.  Home page has a very different layout usually.  I'd have to fade out the entire thing and fade in the entire subpage.  this is perhaps less disruptive still, but the background may even change, making it somewhat pointless.   also other landing pages could be this dramatically different someday.  how to animate for them?
			
			
			
one problem is loading external js / css on ajax loaded skins and firing the onload event for JUST those elements to ensure they run

	<a id="link1" class="zblog_article zpop-up" href="/link-to-blog_article.html">Blog Article</a>
	
javascript ajax skin loading & rendering
	generate both .cfc and .js versions of skins.  The .js versions must be able to do ajax requests for the json data that populates them.
	let's finish blog story.cfm as a set of cfc and js views
		the main article is a blog query
		user comments form & the comments themselves (infinite scrolling someday)
		related articles
		most popular articles
	
		enabling login protected ajax page transitions:
			<cfscript>
			// the process url route for the CFC section - this only occurs when an ajax request is detected
			if(structkeyexists(form,  'x_ajax_id')){
				// check login without show the form
				groupFromCFCReflection="member";
				if(application.zcore.user.checkGroupAccess(groupFromCFCReflection)){
					writeoutput('{loginrequired:true,group:"#groupFromCFCReflection#"}');
					application.zcore.functions.zabort();
				}
			}
			
			// I need to protect specific compiled queries with group permissions - this would cause an ajax response which indicates the app to show the login form to continue (in a modal window perhaps) - upon login, I'd need to reexecute the last ajax request. - this will require caching ALL the ajax request data until the callback event has confirmed a login required response was NOT returned.  Usually eval() is done in the callback.  This will require running this check in the ajax callbacks: if(responseText.substr(0,19) == "{loginrequired:true"){ // show modal login and don't call the callback } - if user cancels the login window, then I can delete the previous cached request data.
		
		--->
		
		<!---
		if javascript must write the query so that my C/php can be very simple security filter ONLY.
			perhaps a CFML to C/php translator could help with this to make it less buggy on future updates to the security rules
				use struct / assoc array only with if logic and loops to handle security filter
			
			write the security filter in coldfusion first to verify functionality needed.
			--->
<cfscript>
// if the login process calls gwan behind the scenes "securely" then i could have gwan writing the session state to its KV store (do same for member updates)
// only grab the session if the current query has one or more fields requiring it - ie, use a boolean value to determine 

// ajax must use post vars

/*
// update example
q="update";
fieldList="table1~field1=value1,field2=value2";
whereFields="";
*/
form.requesttype="query"; // backup 
kvStore=structnew();
backupPath=request.zos.globals.homedir&"kvstorediskbackup.txt";
// periodically call A script to sync the kvstore to disk without blocking readers
if(form.requesttype EQ "backup"){
	var t=getAllKvStoreValues();
	tempBackupPath=backupPath&".temp";
	if(structcount(t) NEQ 0){
		f=fileopen(tempBackupPath,"w");
		for(i in t){
			filewriteline(f, i&"="&t[i]);	
		}
		fileclose(f);
		application.zcore.functions.zdeletefile(backupPath);
		application.zcore.functions.zrenamefile(tempBackupPath, backupPath);
	}
	writeoutput('done');
	application.zcore.functions.zabort();
}

// select example
//q="select";
fieldList="table1~field2,field3,field4
table2~field1";
whereFields=""; // where fields
from="table1"; // from table
leftJoin=""; // left join
groupBy="";// group by syntax
orderBy="";// order by syntax
offset=""; // offset syntax
limit=""; // limit syntax
// need to support match against, count, sum, group_concat, aliases, if and some other select syntax in rare cases
	// must make a SQL parser when these non-standard-fields are used

// lets have the filter only define which fields CAN'T be selected or updated in the "fields" struct.  Keep in mind that site_id and user_id can never be updated

// update is dangerous because we can't trust the where fields are correct - so we won't allow it.
	// to update blog hit counter, i need to either call a separate ajax event or change this validation script to have an incrementOnSelect or updateDateOnSelect or updateDateTimeOnSelect feature for specific fields.
	
// store a history of all known queries in the KV store with the query as the key name

// js hacking detection
/*
better way to handle query security is to make a coldfusion to C translation/compilation script.

turn cgi parameters into an ordered prepared statement.  no different then the compiled select query really.
	i need to track if C script is up to date
	make a working gwan mysql example


 check if query exists in kv store (query as key name)
 if(notexists){
	// if(session expired or 
	if(http_referer is missing){
		// trust this hit less
	}
	if(queryTime > 10 or query.recordcount GT 100){
		// might be an attack
	}
	if(ip changed or userAgent changed or duplicate queryToken usage detected){
		// send email alert	
		
		// return no results (fake that it was successful to confuse attacker)
		writeoutput('{success:true,data:""');
		application.zcore.functions.zabort();	
		
	}
	// return code that once eval'd , reloads the current page.
	
	compare the number of seconds since the last query token was generated with when it was used
	if i keep an open socket on the active user's browser, this would let me push down a new token constantly.
	
 }
*/
	
// I can't allow user to post: leftJoinFields, whereFields, from tables, order by, group by and for security concerns
// allow the user to post order by, offset and limit
// if i compile the queries server-side, i can reference them by name in the javascript / cfc skins so that I don't have to pass in the selectFields or anything else.
// this makes the security filter unnecessary.
/* 
javascript says, call X.cfc to get Y compiled select query with Z arguments

add parameter validation options to the compiled select query component.
	required
	numeric
	force max offset
	force max limit
compiled select query doesn't let you change the query based on the parameters being defined or not.

avoid extra roundtrip: don't use post ajax unless I know the request data is longer then 1800 chars.  if(postData.length > 1800){ method="post"; }else{ .action+=postData; .method="get"; }

*/
s=structnew();
s.table1.select=true;
//s.table1.update=true;
s.table1.insert=true;
s.table1.fields.field1.select=true; // no one can select this
s.table1.fields.field1.selectGroup="member"; // only members can select

// (t1.q = t2.q and t1.q='thing') or t2.q='that' 
// how do i represent the parenthesis in a secure way?


// need a way to enforce user_id in where clause

//s.table1.fields.field1.update=true; // no one can update this
//s.table1.fields.field1.updateGroup="member"; // requires member login for updating this field problem - C needs to know the login status of current user.  This would require sharing data with railo or mysql (an extra query on every hit)

sessionGroups=structnew();
groupRequired=false;

// send email alert for errors because its probably a hacker.


selectQuery=false;
//updateQuery=false;
/*
if(left(q, 6) EQ "SELECT"){
	selectQuery=true;
}else if(left(q,6) EQ "UPDATE"){
	updateQuery=true;
}else{
	writeoutput('{success:false,errorMessage:"Access denied."}');
	application.zcore.functions.zabort();	
}*/


v=getKvStoreValue("railo_session_loading");
if(v EQ ""){
	setKvStoreValue("railo_session_loading", "1");
	// sleep(10000); // emulate a slow first time load of the kvstore off the disk backup (if it exists)
	/* 
	if(fileexists(backupPath)){
		// stream the file contents back into the in-memory kvstore line by line
		f=fileopen(backupPath,"r");
		while(fileiseof(f) EQ false){
			fline=filereadline(f);
			a=listtoarray(fline, "=",true);
			if(fline NEQ "" and arraylen(a) EQ 2){
				setKvStoreValue(a[1],a[2]);
			}
		}
		fileclose(f);
	}
	*/
	setKvStoreValue("railo_session_loading", "0");
}
if(v NEQ "0"){
	// block all requests until the kvstore is done loading
	while(true){
		v=getKvStoreValue("railo_session_loading");
		if(v NEQ "0"){
			sleep(100);	// wait for kvStoreValue to populate	
		}else{
			break;
		}
		// might want to count and retry load if it exceeds x amount of time.
	}
}

// loop all the tables
stime=gettickcount();

arrT=listtoarray(fieldList, chr(10));
for(i=1;i LTE arraylen(arrT);i++){
	arrD=listToArray(arrT[i],"~",false);
	if(arraylen(arrD) NEQ 2){
		writeoutput('{success:false,errorMessage:"Invalid field list format."}');
		application.zcore.functions.zabort();	
	}
	if(structkeyexists(s, arrD[1]) EQ false){
		writeoutput('{success:false,errorMessage:"Invalid table."}');
		application.zcore.functions.zabort();	
	}
	arrF=listtoarray(arrD[2],",",false);
	// loop select fields
	for(i=1;i LTE arraylen(arrF);i++){
		/*if(updateQuery){
			if(structkeyexists(s[arrD[1]], 'update') EQ false){
				writeoutput('{success:false,errorMessage:"Update access denied for table: #arrD[1]#"}');
				application.zcore.functions.zabort();	
			}
			arrT2=listtoarray(arrF, "=",true);
			if(arraylen(arrT2) NEQ 2){
				writeoutput('{success:false,errorMessage:"Invalid update field format - missing value for key: #arrT2[1]#"}');
				application.zcore.functions.zabort();	
			}
			curField=arrT2[1];
			curValue=arrT2[2];
		}else{*/
			if(structkeyexists(s[arrD[1]], 'select') EQ false){
				writeoutput('{success:false,errorMessage:"Select access denied for table: #arrD[1]#"}');
				application.zcore.functions.zabort();	
			}
			curField=arrF[i];
			//curValue="";
		//}
		if(find(curField,"`") neq 0){
		//if(replacelist(curField,"@,`,',(,),$,!,%,^,&,*,=,+,;,:,""",",,,,,,,,,,,,,,,") neq curField){
			writeoutput('{success:false,errorMessage:"Field security check failed: #curField# - cannot contain a backtick ""`"""}');
			application.zcore.functions.zabort();	
		}
		if(structkeyexists(s[arrD[1]].fields, curField)){
			// check more detailed permissions
			//if(selectQuery){
				if(structkeyexists(s[arrD[1]].fields[curField], 'select')){
					writeoutput('{success:false,errorMessage:"Field may not be selected: #curField#"}');
					application.zcore.functions.zabort();	
				}
				if(structkeyexists(s[arrD[1]].fields[curField], 'selectGroup')){
					groupRequired=true;
					arrayAppend(arrGroup, c.selectGroup);
				}
			/*}else{
				if(structkeyexists(s[arrD[1]].fields[curField], 'update')){
					writeoutput('{success:false,errorMessage:"Field may not be updated: #curField#"}');
					application.zcore.functions.zabort();	
				}
				if(structkeyexists(s[arrD[1]].fields[curField], 'selectGroup')){
					groupRequired=true;
					arrayAppend(arrGroup, c.selectGroup);
				}
					
			}*/
		}
	}
}

if(groupRequired){
	if(structkeyexists(form,'cfid') and structkeyexists(form,'cftoken') and sessionInited EQ false){ 
		sessionInited=true; 
		initSession("railo_session_"&form.cfid&"_"&form.cftoken); 
	}
	if(sessionInited EQ false){
		writeoutput('{loginrequired:true,success:false,errorMessage:"Login required"}');
		application.zcore.functions.zabort();	
	}
	for(i=1;i LTE arraylen(arrGroup);i++){
		if(structkeyexists(sessionGroups, arrGroup[i]) EQ false){
			writeoutput('{loginrequired:true,success:false,errorMessage:"Login required"}');
			application.zcore.functions.zabort();	
		}
	}
}

// safe to run query
writeoutput(((gettickcount()-stime)/1000)&" seconds");

	// get session state from gwan KV store so I can determine groups this user belongs to. the KV store key name is  railo_session_id - if it doesn't exist, then this user is not logged in

</cfscript>
			<!---
figure out how to write test cases for each query (api call)
			
			also allow select fields to change based on API call instead of based on the skin usage only.
			
			
			
			gwan has better rewrite / lang support and here is a mysql C tutorial: http://zetcode.com/tutorials/mysqlcapitutorial/
		
	
	
		server-side compiled is better because
			prepared statement performance is 13% faster - but breaks query cache, which makes it twice as slow if it could otherwise be cached
			security is ensured due to required parameter escaping & validation
		i think a need a version of the select component which operates in javascript to build a query.  then it sends that to the server along with the unique query name
		
		
		
		// security filter notes for javascript query execution
		
		// model must be able to be customized by overriding the class to provide additional information beyond site_id security automation.
			max returned records
			other field names to compare against user session or application state
			hiding fields from being used in select statements
			
		// this must work with joins as well (from javascript)
		will javascript use the same compiled query syntax and have a copy of all the model data available on the client?
		
		 
	
	TOO COMPLEX? template compilation needs to maintain a list of all the logic routines used on the page.  However, with logic, they don't always run.
	
	to support logic like if(page.name EQUALS "contact us") in a different template, i have to reprocess the skins rendering the current page AFTER receiving all the ajax data back.
		to do this, i need to track which logic blocks I reached on the current page.  If those logic blocks change, then I need to load any associated data in the changed block and redraw the template.  all the subtemplates that haven't changed can be cached and reattached without reloading the entire page.  I might lose the scroll position doing this because it will be replacing the entire page probably.   unless i insert placeholder <br class="zlogicplaceholder" id="zlogic1" /> anywhere there is logic.  These will be hidden by using getElementsByClassName display:inline; 
			These placeholders will be auto-referenced by id, so I can hide the inactive blocks and display the content of the new blocks.
			
		if(true){
			<div><div>
		}else{
			<div>
		}
		test
		if(true){
			</div></div>
		}else{
			</div>
		}
		becomes this valid XHTML 1.0 strict:
						<br class="zlogicplaceholder" id="zlogic1" />
							<div><div>
						<br class="zlogicplaceholder" id="zlogic_end1" />
						<br class="zlogicplaceholder" id="zlogic2" />
							<div>
						
						<br class="zlogicplaceholder" id="zlogic_end2" />
						test
						<br class="zlogicplaceholder" id="zlogic3" />
							</div></div>
						
						<br class="zlogicplaceholder" id="zlogic_end3" />
						<br class="zlogicplaceholder" id="zlogic4" />
							</div>
						
						<br class="zlogicplaceholder" id="zlogic_end4" />
						
			
		force conventions on the html layout in order to prevent unknown templating situations
		i.e.
			1, 2 or 3 columns
			specify which one auto-stretches plus the max and min width of each.
			specify the background images in 1 background, 3 grid (top, bottom and middle repeating) or 9 grid style with an interface or json syntax
			allow nesting this data structure inside one of the columns
			if height is specified, then control floating?
			
			
		
		
		scroll position doesn't matter.  It's more important that I fade out the old content and fade in the new content and animate or jump to the top of the content.
		
		the code between BR logic can't be changed without redrawing all the other elements.  this would cause a flicker and loss of scroll position usually.
		
		other frameworks handle these changes by doing includes
			head
				stays the same, except for custom js etc sometimes
			header
			body
				body1 for home page
				body2 for subpages
				body3 for custom page
			footer
		however, that doesn't help when you want to change layout based on data values, such as when an image is missing to show an image n/a alternate, or when its a different property type (like condo unit number)
			however, if you only change layout based on LOCAL data values, then you don't have to redraw templates at all.
		consequences of forcing all data used in logic to be LOCAL to the template?
			I can't change the global template layout based on page title / content id / or by the URL
				unless its done by javascript
			harder to add/remove sidebars
			layout changes are usually related to the background and sides.
				the framework could provide javascript methods for altering the sides and backgrounds.  Like data that sets up number of columns with 9 grid or 3 grid background (top and middle repeat and bottom) options for each column.
			
		what if i control column heights with javascript and use position:absolute for all page layout.  This would allow layering divs around the inner content to force it to all flow - however this doesn't downsize to mobile as well - float was more performant.
			this also prevents text from wrapping around elements.
		
		
		a layout builder which lets you choose # of columns and keep adding rows with different predefined layout options.  like image left, text right,   image right, text left,  3 column image,  3 column text,  1 column text,  1 column image, 1 column slideshow,  etc
		
		
	if a template needs to know about 
	
	use class selectors because native performance is very good - use this functions on <=ie8 etc
		function getElementsByClassName(node, classname) {
			var a = [];
			var re = new RegExp('(^| )'+classname+'( |$)');
			var els = node.getElementsByTagName("*");
			for(var i=0,j=els.length; i<j; i++)
				if(re.test(els[i].className))a.push(els[i]);
			return a;
		}

		tabs = getElementsByClassName(document.body,'tab');
	
		 --->
		</cffunction>
</cfcomponent>