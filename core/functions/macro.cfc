<cfcomponent>
<cfoutput>
<!--- 
ts={
	preClickLabel:"PreClick",// any html string | optional
	postClickValue:"PostClick", // any html string | optional
	eventCategory:"Category", // any string value
	eventAction:"Action", // any string value
	eventLabel:"Label",  // any string value | optional
	eventValue:"0", // must be an integer | optional
	style:"", // css for <a>
	attributeStruct: {} // optional - each key will become an attribute on the a tag
};
application.zcore.functions.zClickTrackDisplayValue(ts); --->
<cffunction name="zClickTrackDisplayValue" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts={
		preClickLabel:"",
		postClickValue:"",
		eventCategory:"button", 
		eventAction:"click", 
		eventLabel:"",
		eventValue:0,
		style:""
	};
	structappend(arguments.ss, ts, false); 
	attrib="";
	if(structkeyexists(arguments.ss, 'attributeStruct')){
		for(i in arguments.ss.attributeStruct){
			attrib&=' #i#="#arguments.ss.attributeStruct[i]#"';
		}
	}
	echo('<div class="zClickTrackDisplayDiv"><a href="##" #attrib# style="#arguments.ss.style#" class="zClickTrackDisplayValue" data-zclickpostvalue="#htmleditformat(arguments.ss.postClickValue)#" data-zclickeventcategory="#htmleditformat(arguments.ss.eventCategory)#" data-zclickeventaction="#htmleditformat(arguments.ss.eventAction)#" data-zclickeventlabel="#htmleditformat(arguments.ss.eventLabel)#" data-zclickeventvalue="#htmleditformat(arguments.ss.eventValue)#">#arguments.ss.preClickLabel#</a></div>');
	</cfscript>
	
</cffunction>

<!--- 
ts={
	eventCategory:"Category", // any string value
	eventAction:"Action", // any string value
	eventLabel:"Label",  // any string value | optional
	eventValue:"0" // must be an integer | optional
};
application.zcore.functions.zPageViewTrack(ts); --->
<cffunction name="zPageViewTrack" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts={
		eventCategory:"button", 
		eventAction:"click", 
		eventLabel:"",
		eventValue:0
	};
	structappend(arguments.ss, ts, false); 
	application.zcore.skin.addDeferredScript('zTrackEvent("#jsStringFormat(arguments.ss.eventCategory)#", "#jsStringFormat(arguments.ss.eventAction)#", "#jsStringFormat(arguments.ss.eventLabel)#", "#jsStringFormat(arguments.ss.eventValue)#", "", false);');
	</cfscript>
	
</cffunction>

<!--- 
ts={
	preClickLabel:"PreClick",// any html string | optional
	url:"/url.html", 
	target:"_blank", // _top, _self or _blank | optional
	eventCategory:"Category", // any string value
	eventAction:"Action", // any string value
	eventLabel:"Label",  // any string value | optional
	eventValue:"0", // must be an integer | optional
	style:"", // css for <a>
	attributeStruct: {} // optional - each key will become an attribute on the a tag
};
application.zcore.functions.zClickTrackDisplayURL(ts);
 --->
<cffunction name="zClickTrackDisplayURL" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts={
		preClickLabel:"",
		target:"",
		eventCategory:"button", 
		eventAction:"click", 
		eventValue:0,
		eventLabel:"",
		style:"",
		noFollow:false
	};
	structappend(arguments.ss, ts, false);
	if(not structkeyexists(arguments.ss, "url")){
		throw("arguments.ss.url is required");
	} 
	target="";
	if(arguments.ss.target NEQ ""){
		target=' target="'&arguments.ss.target&'"';
	}
	link=' href="#arguments.ss.url#"';
	if(arguments.ss.noFollow){
		link=' rel="nofollow" href="##" ';
	}
	attrib="";
	if(structkeyexists(arguments.ss, 'attributeStruct')){
		for(i in arguments.ss.attributeStruct){
			attrib&=' #i#="#arguments.ss.attributeStruct[i]#"';
		}
	}
	echo('<span class="zClickTrackDisplayDiv"><a #link# #target# #attrib# style="#arguments.ss.style#" class="zClickTrackDisplayURL" data-zclickpostvalue="#htmleditformat(arguments.ss.url)#" data-zclickeventcategory="#htmleditformat(arguments.ss.eventCategory)#" data-zclickeventaction="#htmleditformat(arguments.ss.eventAction)#" data-zclickeventlabel="#htmleditformat(arguments.ss.eventLabel)#" data-zclickeventvalue="#htmleditformat(arguments.ss.eventValue)#">#arguments.ss.preClickLabel#</a></span>');
	</cfscript>
</cffunction>


<cffunction name="zRequireFullCalendar" localmode="modern" access="public">
	<cfscript>
	application.zcore.functions.zRequireJqueryUI();
	application.zcore.skin.includeCSS("/z/javascript/fullcalendar/fullcalendar.css");
	savecontent variable="meta"{
		echo('<link href="/z/javascript/fullcalendar/fullcalendar.print.css" rel="stylesheet" media="print" />');
	}
	application.zcore.template.appendTag("stylesheets", meta);

	application.zcore.skin.includeJS("/z/javascript/fullcalendar/lib/moment.min.js", "", 2);
	application.zcore.skin.includeJS("/z/javascript/fullcalendar/fullcalendar.min.js", "", 3); 
	</cfscript>
</cffunction>

<cffunction name="zRemoveHostName" access="public" localmode="modern">
	<cfargument name="str" type="string" required="yes">
	<cfscript>
	return replace(arguments.str, request.zos.currentHostName&"/", '/', 'all');
	</cfscript>
</cffunction>

<cffunction name="zCheckIfPageAlreadyLoadedOnce" access="public" localmode="modern">
	<cfscript>
	if(structkeyexists(request.zos, 'zCheckIfPageAlreadyLoadedOnceRan')){
		return;
	}
	request.zos.zCheckIfPageAlreadyLoadedOnceRan=true;
	application.zcore.template.appendTag("content", '<input type="hidden" name="zPageLoadedOnceTracker" id="zPageLoadedOnceTracker" value="1" />');
	application.zcore.skin.addDeferredScript("
		zCheckIfPageAlreadyLoadedOnce();
	");
	</cfscript>
	
</cffunction>
 
<!--- application.zcore.functions.zIsMobileUserAgent(request.zos.cgi.http_user_agent); --->
<cffunction name="zIsMobileUserAgent" localmode="modern" output="no" returntype="boolean">
	<cfargument name="userAgent" type="string" required="yes">
	<cfscript>
	if(reFindNoCase("(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino", arguments.userAgent) GT 0 OR reFindNoCase("1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-",Left(arguments.userAgent,4)) GT 0){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="zSetModalWindow" localmode="modern" output="no" returntype="any">
	<cfscript> 
	request.zos.debuggerEnabled=false;
	application.zcore.functions.zModalCancel();
	application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);
	application.zcore.functions.zRequireJquery();
	application.zcore.template.appendTag("stylesheets", '<style type="text/css">body{background:none !important;} h1{color:##000 !important;} body, table{ background-color:##FFF !important; color:##000 !important;} a:link, a:visited{ color:##369 !important; } a:hover{ color:##F00 !important; } ##zSearchJsToolNewDiv, ##zlsInstantPlaceholder{display:none !important;} </style>');
	application.zcore.template.appendTag("scripts", '<script type="text/javascript">var zIsModalWindow=true;</script>');
	</cfscript>
</cffunction>



<cffunction name="zDisplayGoogleTranslate" localmode="modern" output="yes">
	<cfif request.zos.cgi.http_user_agent DOES NOT CONTAIN 'MSIE 8.0' and request.zos.cgi.http_user_agent DOES NOT CONTAIN 'MSIE 7.0' and request.zos.cgi.http_user_agent DOES NOT CONTAIN 'MSIE 9.0'>
		<div id="google_translate_element"></div>
		<script type="text/javascript">
		function googleTranslateElementInit() {
		new google.translate.TranslateElement({pageLanguage: 'en', layout: google.translate.TranslateElement.InlineLayout.SIMPLE}, 'google_translate_element');
		}
		zArrDeferredFunctions.push(function(){
			$("head").append('<meta name="google-translate-customization" content="8318d1ceea381a83-2a60f5eea54548f0-g68615e51ccfbcbfa-17" />');
			zLoadFile("//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit","js");
		});
		</script>
	</cfif>
</cffunction>

<!--- 
writeoutput(application.zcore.functions.zLoadAndCropImage({id:"",width:140,height:130, url:'', style:"", canvasStyle:"", crop:true}));
 --->
<cffunction name="zLoadAndCropImage" localmode="modern" output="no" returntype="string" access="public">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	var local=structnew();
	var ts={
		id="",
		url="",
		crop=false,
		width=0,
		height=0,
		style="",
		canvasStyle="",
		class=""	
	}
	structappend(ts, arguments.ss, true);
	arguments.ss.style="display:block;"&arguments.ss.style;
	if(ts.width LTE 0 or ts.height LTE 0){
		application.zcore.template.fail("zLoadAndCropImage(): arguments.ss.width and arguments.ss.height must be greater then 0.");	
	}
	if(trim(ts.url) EQ ""){
		ts.url="/z/a/listing/images/image-not-available.gif";
		//application.zcore.template.fail("zLoadAndCropImage(): arguments.ss.url is required.");	
	}
	if(trim(ts.id) EQ ""){
		application.zcore.template.fail("zLoadAndCropImage(): arguments.ss.id is required.");	
	}
	if(ts.crop){
		local.crop="1";
	}else{
		local.crop="0";
	}
	if(find(":",ts.url, 8) EQ 0 and left(ts.url,1) NEQ "/" and left(ts.url, len(request.zos.currentHostName)) NEQ request.zos.currentHostName){
		ts.url="/zimageproxy/"&replace(replace(ts.url,"http://",""),"https://","");
	}
	return ('<span id="'&ts.id&'" style="'&htmleditformat(ts.style)&'" class="'&trim('zLoadAndCropImage '&ts.class)&'" data-imagewidth="'&ts.width&'" data-imageheight="'&ts.height&'" data-imagestyle="'&htmleditformat(ts.canvasStyle)&'" data-imagecrop="'&local.crop&'" data-imageurl="'&htmleditformat(ts.url)&'"></span>');
	</cfscript>
    
</cffunction>

<cffunction name="zDisableExternalComments" localmode="modern" output="yes" returntype="any">
	<cfscript>
	request.zos.disableExternalComments=true;
	</cfscript>
</cffunction>

<cffunction name="zIsExternalCommentsEnabled" localmode="modern" output="yes" returntype="any">
	<cfscript>
	if(structkeyexists(request.zos, 'disableExternalComments') EQ false and structkeyexists(request.zos.globals, 'disqusShortName') and request.zos.globals.disqusShortName NEQ ""){
		return true;
	}else{
		return false;	
	}
	</cfscript>
</cffunction>

<cffunction name="zDisplayExternalComments" localmode="modern" output="yes" returntype="any">
	<cfargument name="pageId" type="string" required="yes">
    <cfargument name="pageTitle" type="string" required="yes">
    <cfargument name="pageAbsoluteURL" type="string" required="yes">
    <cfscript>
	var output="";
	if(request.zos.globals.disqusShortname EQ ""){
		return;
	}
	</cfscript>
    <cfsavecontent variable="output">
    <div id="disqus_thread" style="width:100%; float:left; min-height:360px;"></div>
    <script type="text/javascript">
        /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
		var disqus_shortname = '#jsstringformat(request.zos.globals.disqusShortname)#'; // required: replace example with your forum shortname
		var disqus_identifier = '#jsstringformat(arguments.pageId)#';
		var disqus_title = '#jsstringformat(arguments.pageTitle)#';
		var disqus_url = '#jsstringformat(arguments.pageAbsoluteURL)#';
		var disqus_developer = <cfif request.zos.istestserver>1<cfelse>0</cfif>;
        /* * * DON'T EDIT BELOW THIS LINE * * */
        (function() {
            var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
			<cfif request.zos.cgi.SERVER_PORT EQ "443">
            dsq.src = 'https://' + disqus_shortname + '.disqus.com/embed.js?https';
			<cfelse>
            dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
			</cfif>
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
    </script>
    <!--- <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
    <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a> --->
    </cfsavecontent>
    <cfreturn output>
</cffunction>


<cffunction name="zGetHumanFieldIndex" localmode="modern" output="no" returntype="any">
	<cfscript>
	if(structkeyexists(request.zos.tempobj,'zset9index') EQ false){
		request.zos.tempobj.zset9index=0;
	}
	request.zos.tempobj.zset9index++;
	return request.zos.tempobj.zset9index;
	</cfscript>
</cffunction>

<cffunction name="legacySetActions" localmode="modern" output="no" returntype="any">
</cffunction>
<cffunction name="legacySetDefaultAction" localmode="modern" output="no" returntype="any">
</cffunction>

<cffunction name="zXSendFile" localmode="modern" output="no" returntype="any">
	<cfargument name="p" type="string" required="yes">
	<cfscript>
	application.zcore.functions.zheader("Content-type", "");
	/*application.zcore.functions.zheader('Cache-Control', 'public, must-revalidate');
	application.zcore.functions.zheader('Pragma', 'no-cache');
	application.zcore.functions.zheader('Content-Disposition', 'attachment; filename='&getfilefrompath(arguments.p));
	application.zcore.functions.zheader('Content-Transfer-Encoding', 'binary');*/
	if(cgi.SERVER_SOFTWARE EQ "" or cgi.SERVER_SOFTWARE CONTAINS "nginx"){
		application.zcore.functions.zheader("X-Accel-Redirect",arguments.p);
	}else{
		application.zcore.functions.zheader("X-Sendfile",arguments.p);
	}	
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>


<!--- application.zcore.functions.zFullScreenMobileApp(); --->
<cffunction name="zFullScreenMobileApp" localmode="modern" output="no" returntype="any">
	<cfargument name="responsive" type="boolean" required="false" default="#false#">
	<cfargument name="scalable" type="boolean" required="false" default="#true#">
	<cfscript>
	var theMeta="";
	userAgent=lcase(request.zos.cgi.HTTP_USER_AGENT);
    if(arguments.responsive or userAgent CONTAINS "iphone" or userAgent CONTAINS "ipod" or  (userAgent CONTAINS "android" and userAgent CONTAINS "mobile")){
		
	}else{
		return;	
	}
    </cfscript>
    <cfsavecontent variable="theMeta">
    <meta name="viewport" content="width=device-width, minimum-scale=1, initial-scale=1, user-scalable=<cfif arguments.scalable>yes<cfelse>no</cfif>" /><meta name="apple-mobile-web-app-capable" content="yes" /><meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" /><style type="text/css">/* <![CDATA[ */ a, area {-webkit-touch-callout: none;}*{ -webkit-text-size-adjust: none; }/* ]]> */</style>
    </cfsavecontent>
    <cfscript>
    application.zcore.template.appendTag("meta",theMETA);
    </cfscript>
</cffunction>

<!--- application.zcore.functions.zRemoveHTMLForSearchIndexer(text); --->
<cffunction name="zRemoveHTMLForSearchIndexer" localmode="modern" returntype="any">
	<cfargument name="text" type="string" required="yes">
    <cfscript>
	var badTagList="script|embed|base|input|textarea|button|object|iframe|form";
	arguments.text=rereplacenocase(arguments.text,"<(#badTagList#).*?</\1>", " ", 'ALL');
	arguments.text=rereplacenocase(arguments.text,"(</|<)[^>]*>", " ", 'ALL');
	return arguments.text;
	</cfscript>
</cffunction>
<!--- 
<!--- application.zcore.functions.zIsTouchscreen(); --->
<cffunction name="zIsTouchscreen" localmode="modern" output="no" returntype="any">
	<cfscript>
	if(replacelist(cgi.HTTP_USER_AGENT,"ipad,iphone,android,tablet pc","1,1,1,1") NEQ cgi.HTTP_USER_AGENT){
		return true;	
	}else{
		return false;
	}
	</cfscript>
</cffunction> --->

<!--- application.zcore.functions.zHeader(name, value); --->
<cffunction name="zHeader" localmode="modern" output="no" returntype="any">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
    <cfheader name="#arguments.name#" value="#arguments.value#">
</cffunction>

<cffunction name="zEncodeDreamweaverPassword" localmode="modern" output="no" returntype="any">
	<cfargument name="s" type="string" required="yes">
    <cfscript>
	var local=structnew();
	local.output="";
	local.top=0;
	
	for(local.i=1;local.i LTE len(arguments.s);local.i++){
		local.c=mid(arguments.s,local.i,1);
        local.code = asc(local.c);
        if(local.code LT 0 OR local.code GT 65535){
			return false;
		}
        if(local.top NEQ 0){
            if(56320 LTE local.code and local.code LTE 57343){
                local.output &= (FormatBaseN(65536 + ((local.top - 55296) * 1024) + (local.code - 56320) + (local.i-1), 16)) & '';
                local.top = 0;
                continue;
                // Insert alert for below failure
            }else{
            	return false;
            }
        }
        if(55296 LTE local.code and local.code lte 56319){
        	local.top = local.code;
        }else{
        	local.output &= FormatBaseN(local.code + (local.i-1), 16) & '';
        }
	}
	return UCASE(local.output);
	</cfscript>
</cffunction>


<cffunction name="zRequireVideoJS" localmode="modern" output="no" returntype="any">
	
    <cfif structkeyexists(request,'zEmbedVideoJS') EQ false>
    	<cfscript>
		request.zEmbedVideoJS=true;
	  application.zcore.skin.includeJS("/z/javascript/video-js/video.js");
	  application.zcore.skin.includeCSS("/z/javascript/video-js/video-js.css");
	  application.zcore.template.appendTag('meta','<script type="text/javascript">/* <![CDATA[ */ zArrDeferredFunctions.push(function(){ VideoJS.setupAllWhenReady(); }); /* ]]> */</script>');
        </cfscript>
        
    </cfif>
</cffunction>

<!--- 
<cfscript>
ts=structnew();
ts.id = "VideoElement1"; // optional
// mp4 format is required.
ts.mp4AbsoluteUrl="#request.zos.currentHostName#/images/shell/Foster.mp4"; // mp4 codec
// optional html 5 video formats
ts.webmAbsoluteUrl=""; // webm codec
ts.ogvAbsoluteUrl=""; // ogg vorbis codec
ts.width="560";
ts.height="285";
ts.posterImageAbsoluteUrl="#request.zos.currentHostName#/images/shell/foster-care.jpg";
ts.description = "Video"; // for seo image alt tag.
zEmbedHTML5Video(ts);
</cfscript>
 --->
<cffunction name="zEmbedHTML5Video" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	var metaHTML="";
	var videoHTML="";
	var ts=structnew();
	ts.id="";
	ts.width="320";
	ts.height="240";
	ts.description="Video";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.mp4AbsoluteURL EQ ""){
		application.zcore.template.fail("zEmbedHTML5Video() - arguments.ss.mp4AbsoluteUrl is required.");
	}
	if(structkeyexists(request.zos.tempObj,'embedHTML5videoIndex') EQ false){
		request.zos.tempObj.embedHTML5videoIndex=0;
		application.zcore.functions.zRequireVideoJS();
	}
	request.zos.tempObj.embedHTML5videoIndex++;
	if(arguments.ss.id EQ ""){
		arguments.ss.id="zHTML5Video#request.zos.tempObj.embedHTML5videoIndex#";
	}
	</cfscript>
  <div id="#arguments.ss.id#_container" class="zHTML5Video-video-js-box"></div>
  <cfsavecontent variable="videoHTML"><video id="#arguments.ss.id#" class="zHTML5Video-video-js" width="#arguments.ss.width#" height="#arguments.ss.height#" controls="controls" preload="auto" poster="#arguments.ss.posterImageAbsoluteURL#">
    <cfif arguments.ss.mp4AbsoluteURL NEQ ""><source src="#arguments.ss.mp4AbsoluteURL#" type="video/mp4; codecs='avc1.42E01E, mp4a.40.2'" /></cfif>
    <cfif arguments.ss.webmAbsoluteURL NEQ ""><source src="#arguments.ss.webmAbsoluteURL#" type="video/webm; codecs='vp8, vorbis'" /></cfif>
    <cfif arguments.ss.ogvAbsoluteURL NEQ ""><source src="#arguments.ss.ogvAbsoluteURL#" type="video/ogg; codecs='theora, vorbis'" /></cfif>
      <object id="zHTML5VideoFlash#request.zos.tempObj.embedHTML5videoIndex#" class="zHTML5Video-vjs-flash-fallback" width="#arguments.ss.width#" height="#arguments.ss.height#" type="application/x-shockwave-flash" data="#request.zos.currentHostName#/z/javascript/flowplayer/flowplayer-3.2.7.swf">
        <param name="movie" value="#request.zos.currentHostName#/z/javascript/flowplayer/flowplayer-3.2.7.swf" />
        <param name="allowfullscreen" value="true" />
        <param name="flashvars" value="config={'playlist':['#arguments.ss.posterImageAbsoluteURL#', {'url': '#arguments.ss.mp4AbsoluteURL#','autoPlay':false,'autoBuffering':true}]}" />
        <img src="#arguments.ss.posterImageAbsoluteURL#" width="#arguments.ss.width#" height="#arguments.ss.height#" alt="#htmleditformat(arguments.ss.description)#" title="No video playback capabilities." />
      </object>
    </video></cfsavecontent>
    <script type="text/javascript">
	/* <![CDATA[ */ document.getElementById("#arguments.ss.id#_container").innerHTML="#jsstringformat(videoHTML)#"; /* ]]> */
	</script>
</cffunction>

<cffunction name="zRequireFontFaceUrls" localmode="modern" output="no" returntype="any">
	<cfscript>
	if(application.zcore.functions.zso(request.zos.globals, 'fontsComURL') NEQ ""){
		application.zcore.template.appendTag("meta",'<script type="text/javascript">/* <![CDATA[ */ var zFontsComURL="'&jsstringformat(application.zcore.functions.zso(request.zos.globals,'fontscomurl'))&'"; /* ]]> */</script>');
		
	}
	if(application.zcore.functions.zso(request.zos.globals, 'typekitURL') NEQ ""){
		application.zcore.template.appendTag("meta",'<script type="text/javascript">/* <![CDATA[ */ var zTypeKitURL="'&jsstringformat(application.zcore.functions.zso(request.zos.globals,'typekiturl'))&'"; /* ]]> */</script>');
		
	}
	</cfscript>
</cffunction>

<!--- zBlockURL(link); --->
<cffunction name="zBlockURL" localmode="modern" output="no" returntype="any">
	<cfargument name="link" type="string" required="yes">
	<cfscript>
	arguments.link=replacenocase(arguments.link, "zajaxdownloadcontent","zADCDisabled98","all");
	return "/z/misc/system/ext?n="&urlencodedformat(arguments.link)&"&k="&hash(request.zos.redirectSecretKey&arguments.link);
	</cfscript>
</cffunction>

<cffunction name="zIncludeJsColor" localmode="modern" returntype="any" output="no">
<cfscript>
application.zcore.template.appendTag("meta",'<script type="text/javascript" src="/z/javascript/jscolor.js"></script>');
</cfscript>
</cffunction>

<!--- 
application.zcore.functions.zCookie({ name:"name", value:"test", expires:"never", httponly:"false" });
 --->
<cffunction name="zCookie" localmode="modern" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	var ts=structnew();
	ts.expires="never";
	structappend(arguments.ss,ts,false);
	</cfscript>
	<cfif structkeyexists(arguments.ss, 'httponly')>
    	<cfcookie name="#arguments.ss.name#" value="#arguments.ss.value#" expires="#arguments.ss.expires#" httponly="#arguments.ss.httponly#">
	<cfelse>
    	<cfcookie name="#arguments.ss.name#" value="#arguments.ss.value#" expires="#arguments.ss.expires#">
	</cfif>
</cffunction>


<cffunction name="zSendUserAutoresponder" localmode="modern" output="no" returntype="any">
	<cfargument name="user_id" type="string" required="no" default="">
    <cfscript>
	if(application.zcore.functions.zvar('sendConfirmOptIn', request.zos.globals.id) NEQ 1){
		return;
	}
    var ts=0;
    var rCom=0;
    var qCheck=0;
	var db=request.zos.queryObject;
	var emailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.email");
	var previousDate=dateadd("d",-2,now());
	var previousDateFormatted=dateformat(previousDate,'yyyy-mm-dd')&' '&timeformat(previousDate,'HH:mm:ss');
	</cfscript>
    <cfsavecontent variable="db.sql">
    SELECT user_id, site.site_id, zemail_template_id, user_pref_html 
	FROM #request.zos.queryObject.table("user", request.zos.zcoreDatasource)# user, 
	#request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site WHERE  
    site_deleted = #db.param(0)# and 
    user_deleted = #db.param(0)# and 
    <cfif arguments.user_id NEQ "">
		user_id=#db.param(arguments.user_id)# and 
	<cfelse>
		user_sent_datetime BETWEEN #db.param('2008-02-12 00:09:00')# and 
		#db.param(previousDateFormatted)# and 
    </cfif>
	user.site_id = #db.param(request.zos.globals.id)# and 
    user_confirm_count < #db.param(3)# and 
	user_confirm = #db.param(0)# and 
	site.site_id = user.site_id and 
	site.site_active = #db.param(1)# and 
	site.site_send_confirm_opt_in=#db.param('1')# and 
	(user_pref_list = #db.param(1)# or 
	user_pref_email = #db.param('1')#)
    </cfsavecontent><cfscript>qCheck=db.execute("qCheck");</cfscript>
    <cfloop query="qCheck">
        <cfscript>			
        ts=StructNew();
        // optional
        ts.force=1; // force ignores opt-in status
        ts.site_id=request.zos.globals.id;
        ts.zemail_template_type_name="confirm opt-in";
        if(qCheck.zemail_template_id NEQ 0){
            ts.zemail_template_id=qCheck.zemail_template_id;
        }
        if(qCheck.user_pref_html EQ 1){
            ts.html=true;
        }else{
            ts.html=false;
        } 
        ts.user_id=qCheck.user_id;
		ts.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qCheck.site_id);
        rCom=emailCom.sendEmailTemplate(ts);
        //rs=rCom.getData();
        </cfscript>
        <cfif rCom.isOK() EQ false>
			<cfmail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="Failed to send autoresponder.">
			user_id:#qCheck.user_id#
			site_id:#qCheck.site_id#
			zemail_template_id:#qCheck.zemail_template_id#
			user_pref_html:#qCheck.user_pref_html#
			
			The following errors occured:
			#arraytolist(rCom.getErrors(),chr(10))#
			</cfmail><cfscript>application.zcore.functions.zabort();</cfscript>
        </cfif>
    </cfloop>
</cffunction>



    


<!--- zUserMapFormFields(StructNew()); --->
<cffunction name="zUserMapFormFields" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var i=0;
	var ts=StructNew();
	//StructAppend(arguments.ss,t2,false);
	ts.user_first_name='inquiries_name';
	ts.user_first_name='inquiries_first_name';
	ts.user_last_name='inquiries_last_name';
	ts.user_username='inquiries_email';
	ts.user_email='inquiries_email';
	ts.user_phone='inquiries_phone';
	ts.user_phone='inquiries_phone1';
	ts.user_fax='inquiries_fax';
	ts.user_street='inquiries_street';
	ts.user_street2='inquiries_street2';
	ts.user_street='inquiries_address';
	ts.user_street2='inquiries_address2';
	ts.user_city='inquiries_city';
	ts.user_state='inquiries_state';
	ts.user_country='inquiries_country';
	ts.user_zip='inquiries_zip';
	if(structkeyexists(form, 'inquiries_email_opt_in') and form.inquiries_email_opt_in EQ 0){
		arguments.ss.user_pref_list=0;
		request.userOptOut=true;
	}else{
		arguments.ss.user_pref_list=1;
	}
	for(i in ts){
		if(structkeyexists(form, ts[i])){
			arguments.ss[i]=form[ts[i]];
		}else if(isDefined(ts[i])){
			arguments.ss[i]=evaluate(ts[i]);
			if(isSimpleValue(ts[i]) EQ false or trim(ts[i]) EQ ''){
				StructDelete(arguments.ss,i);
			}
		}else{
			StructDelete(arguments.ss,i);
		}
	}
	return arguments.ss;
	</cfscript>
</cffunction>


<cffunction name="zSendMailUserAutoresponder" localmode="modern" output="no" returntype="any">
	<cfargument name="mail_user_id" type="string" required="no" default="">
    <cfscript>
	if(application.zcore.functions.zvar('sendConfirmOptIn', request.zos.globals.id) NEQ 1){
		return;
	}
	var qcheck=0;
	var ts=0;
	var rcom=0;
	var theSQL=0;
	var previousDate=dateadd("d",-2,now());
	var previousDateFormatted=dateformat(previousDate,'yyyy-mm-dd')&' '&timeformat(previousDate,'HH:mm:ss');
	var emailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.email");
	var db=request.zos.queryObject;
	</cfscript>
    <cfsavecontent variable="db.sql">
    SELECT mail_user_id, mail_user_key, site.site_id  
    FROM #request.zos.queryObject.table("mail_user", request.zos.zcoreDatasource)# mail_user, 
	#request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
    WHERE  mail_user_confirm_count < #db.param(3)# and 
    site_deleted = #db.param(0)# and 
	mail_user_deleted = #db.param(0)# and 
	mail_user_confirm = #db.param(0)# and 
	site.site_id = mail_user.site_id and 
	site.site_id = #db.param(request.zos.globals.id)#  and 
	site_active=#db.param('1')# 
    <cfif arguments.mail_user_id NEQ "">
     and mail_user_id=#db.param(arguments.mail_user_id)#
	<cfelse> 
	 and mail_user_sent_datetime BETWEEN #db.param('2008-02-12 00:09:00')# and #db.param(previousDateFormatted)#
	</cfif>
    </cfsavecontent>
    <cfscript>qCheck=db.execute("qCheck");
    </cfscript>
    <cfloop query="qCheck">
        <cfscript>			
        ts=StructNew();
		ts.force=1;
        ts.site_id=qCheck.site_id;
        ts.zemail_template_type_name="confirm opt-in";
		//ts.debug=1;
        ts.mail_user_id=qCheck.mail_user_id;
		ts.mail_user_key=qCheck.mail_user_key;
        rCom=emailCom.sendEmailTemplate(ts);
        </cfscript>
        <cfif rCom.isOK() EQ false>
    <cfmail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="Failed to send autoresponder.">
    mail_user_id:#qCheck.mail_user_id#
    site_id:#qCheck.site_id#
    
    The following errors occured:
    #arraytolist(rCom.getErrors(),chr(10))#
    </cfmail><cfscript>application.zcore.functions.zabort();</cfscript>
        </cfif>
    </cfloop>
</cffunction>

<cffunction name="z503" localmode="modern" output="yes" returntype="any">
	
	<cfargument name="debugMessage" type="string" required="no" default="">
	<cfscript>
	if(request.zos.isdeveloper){
		application.zcore.functions.zerror('503 with Reason:'&arguments.debugMessage);
		application.zcore.functions.zabort();
	}
	</cfscript>
    <cfheader statuscode="503" statustext="HTTP Error 503 - Service Unavailable">
    <h1>HTTP Error 503 - Service unavailable</h1>
    <cfscript>application.zcore.functions.zabort();</cfscript>
</cffunction>

<cffunction name="zRandomizeArray" localmode="modern" output="no" returntype="array">
	<cfargument name="arrK" type="array" required="yes">
	<cfscript>
	local.count=arraylen(arguments.arrK);
	local.arrNewK=[];
	for(local.i=1;local.i LTE local.count;local.i++){
		local.curIndex=randrange(1, arraylen(arguments.arrK));
		arrayappend(local.arrNewK, arguments.arrK[local.curIndex]);
		arraydeleteat(arguments.arrK, local.curIndex);
	}
	return local.arrNewK;
	</cfscript>
</cffunction>

<cffunction name="z404" localmode="modern" output="yes" returntype="any">
	<cfargument name="debugMessage" type="string" required="no" default="">
	<cfscript> 
	if(request.zos.isdeveloper and structkeyexists(form,'force404') EQ false){
		application.zcore.functions.zerror('404 with Reason:'&arguments.debugMessage);
		application.zcore.functions.zabort();
	}
	application.zcore.functions.zEndOfRunningScript();
	server["zcore_"&request.zos.installPath&"_functionscache"].onMissingTemplate(request.zos.originalURL);
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<!--- zEncodeEmail(email,link,label,output,noscript,returnlink); ---->
<cffunction name="zEncodeEmail" localmode="modern" output="true" returntype="any">
	<cfargument name="email" required="yes" type="string">
	<cfargument name="link" required="no" type="boolean" default="#false#">
	<cfargument name="label" required="no" type="string" default="">
	<cfargument name="output" required="no" type="boolean" default="#true#">
	<cfargument name="noscript" required="no" type="boolean" default="#false#">
	<cfargument name="returnlink" required="no" type="boolean" default="#false#">
	<cfscript>
	var i=0;
	var count=len(arguments.email)/4;
	var offset=1;
	var chars=0;
	var arrEmail=ArrayNew(1);
	var arrLabel=ArrayNew(1);
	var j="";
	if(isDefined('request.zos.encodedEmailInit') EQ false){
		request.zos.encodedEmailInit=1;
	}
	request.zos.encodedEmailInit++;
	if(len(arguments.label) NEQ 0){
		chars=ceiling(len(arguments.label)/4);
		for(i=1;i LTE 4;i=i+1){
			arrayAppend(arrLabel, jsstringformat(mid(arguments.label, offset, chars)));
			offset=offset+chars;
		}
	}
	offset=1;
	for(i=1;i LTE 4;i=i+1){
		chars=ceiling(count);
		arrayAppend(arrEmail, jsstringformat(mid(arguments.email, offset, chars)));
		offset=offset+chars;
	}
	if(arguments.noscript){
		if(arrayLen(arrLabel) NEQ 0){
			j="zeeo('#arrEmail[4]#','#arrEmail[2]#','#arrEmail[1]#','#arrEmail[3]#',#arguments.link#,'#arrLabel[4]#','#arrLabel[2]#','#arrLabel[1]#','#arrLabel[3]#',#arguments.returnlink#);";
		}else{
			j="zeeo('#arrEmail[4]#','#arrEmail[2]#','#arrEmail[1]#','#arrEmail[3]#',#arguments.link#,'','','','',#arguments.returnlink#);";
		}
	}else{
		if(structkeyexists(form, 'zajaxdownloadcontent')){
			if(arrayLen(arrLabel) NEQ 0){
				j='<a href="mailto:#arguments.email#">#arguments.label#</a>';
			}else{
				j='<a href="mailto:#arguments.email#">#arguments.email#</a>';
			}
		}else{
			if(arrayLen(arrLabel) NEQ 0){
				j="<span id=""zencodeemailspan#request.zos.encodedEmailInit#""></span>";
				application.zcore.template.appendTag("scripts","<script type=""text/javascript"">/* <![CDATA[ */zArrDeferredFunctions.push(function(){zeeo('#arrEmail[4]#','#arrEmail[2]#','#arrEmail[1]#','#arrEmail[3]#',#arguments.link#,'#arrLabel[4]#','#arrLabel[2]#','#arrLabel[1]#','#arrLabel[3]#',#arguments.returnlink#,#request.zos.encodedEmailInit#);});/* ]]> */</script>");
			}else{
				j="<span id=""zencodeemailspan#request.zos.encodedEmailInit#""></span>";
				application.zcore.template.appendTag("scripts","<script type=""text/javascript"">/* <![CDATA[ */zArrDeferredFunctions.push(function(){zeeo('#arrEmail[4]#','#arrEmail[2]#','#arrEmail[1]#','#arrEmail[3]#',#arguments.link#,'','','','',#arguments.returnlink#,#request.zos.encodedEmailInit#);});/* ]]> */</script>");
			}
		}
	}
	if(arguments.output){
		writeoutput(j);
	}else{
		return j;
	}
	</cfscript>
</cffunction>


<cffunction name="zEncodeAllEmails" localmode="modern" output="true" returntype="any">
	<cfargument name="content" type="string" required="yes">
	<cfscript>
	var endmt='';
	var end='';
	var aend='';
	var tempTag='';
	var words='';
	var reg='';
	var at="";
	var h="";
	var matching = true;
	var arrMatches = ArrayNew(1);
	var result = StructNew();
	var index = 1;
	var tempStruct = StructNew();
	var i=1;
	var mt=0;
	while(matching){
		// ignore attrib="val""ue"
		// reg = "[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]";
		//result=REFindnocase(reg, arguments.content,index,true);
		result = refindnocase('<a[^>]*mailto:[^>]*>', arguments.content, index, true);
		if(result.pos[1] EQ 0){
			matching = false;
		}
		for(i=1;i LTE ArrayLen(result.pos);i=i+1){
			if(result.pos[i] NEQ 0){
				//at=findnocase('"', arguments.content,result.pos[i]);
				at=findnocase("@", arguments.content,result.pos[i]);
				mt=findnocase('mailto:', arguments.content,result.pos[i]);
				tempStruct = StructNew();
				if(mt NEQ 0){
					endmt=findnocase('"', arguments.content,mt);
					tempStruct.href=mid(arguments.content, mt+7, endmt-(mt+7));
				}
				h=findnocase("://", arguments.content,result.pos[i]);
				end=findnocase("</a>", arguments.content,result.pos[i]);
					
				aend=result.pos[i]+result.len[i];
				tempStruct.label=mid(arguments.content,aend, end-aend);
				if((h EQ 0 or h GT end) and at NEQ 0 and at LT end){
					//tempStruct.string = mid(arguments.content, index, result.pos[i]-index);
					tempStruct.anchor=mid(arguments.content, result.pos[i], (end-result.pos[i])+4);
				}else{
					tempStruct.anchor="";
					//tempStruct.string = mid(arguments.content, index, (end+4)-index);
				}
	
				//tempTag = mid(arguments.content, result.pos[i]+3, result.len[i]-4);
				tempStruct.position = result.pos[i];
				tempStruct.length = result.len[i];
				ArrayAppend(arrMatches, tempStruct);
				index = end+4;
			}else{
				matching = false;
			}
		}
	}
	// find 
	for(i=1;i LTE ArrayLen(arrMatches);i=i+1){
		if(arrMatches[i].anchor NEQ ""){
			arguments.content=replace(arguments.content, arrMatches[i].anchor, application.zcore.functions.zEncodeEmail(arrMatches[i].href, true,arrMatches[i].label,false));
		}
	}
	
	at="";
	h="";
	matching = true;
	arrMatches = ArrayNew(1);
	result = StructNew();
	index = 1;
	tempStruct = StructNew();
	i=1;
	mt=0;
	words=listToArray(arguments.content,' ');
	for(i=1;i LTE arrayLen(words);i=i+1){
		at=find('@',words[i]);
		if(at NEQ 0){
			reg = "^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$";
			if(REFind(reg, words[i]) EQ 1){
				ArrayAppend(arrMatches, words[i]);			
			}		
		}
	}
	for(i=1;i LTE ArrayLen(arrMatches);i=i+1){
		arguments.content=replace(arguments.content, arrMatches[i], application.zcore.functions.zEncodeEmail(arrMatches[i], true,'',false));
	}
	
	return arguments.content;
	</cfscript>
</cffunction>

<cffunction name="zInvoke" localmode="modern" output="true" returntype="any">
	<cfargument name="component" type="any" required="yes">
	<cfargument name="method" type="string" required="yes">
	<cfargument name="inputStruct" type="struct" required="no" default="#StructNew()#">
	<cfscript>
	var returnVar = "";
	</cfscript><cfinvoke component="#arguments.component#" method="#arguments.method#" argumentcollection="#arguments.inputStruct#" returnvariable="returnVar"><cfif isDefined('returnVar')><cfreturn returnVar><cfelse><cfreturn false></cfif>
</cffunction>

<!--- zExecute(app, args, timeout); --->
<cffunction name="zExecute" localmode="modern" returntype="any" output="true">
	<cfargument name="app" type="string" required="yes">
	<cfargument name="args" type="string" required="yes">
	<cfargument name="timeout" type="numeric" required="yes">
	<cfscript>
	var cfcatch=0;
	var output = "";
	if(not request.zos.isExecuteEnabled){
		throw("Execute is disabled in application.cfc", "custom");
	}
	</cfscript>
	<cftry>
		<cfexecute name="#arguments.app#" arguments="#arguments.args#"  timeout="#arguments.timeout#" variable="output"></cfexecute>
		<cfreturn output>
		<cfcatch type="any"><cfreturn false></cfcatch>
	</cftry>
</cffunction>

<!--- zo(varName, isNumber, default); // force a default value for undefined variables or return variable --->
<cffunction name="zo" localmode="modern" returntype="any" output="false">
	<cfargument name="varName" type="string" required="yes">
	<cfargument name="isNumber" type="boolean" required="no" default="#false#">
	<cfargument name="default" type="any" required="no" default="">
	<cfscript>
	var tempVar = "";
	if(arguments.isNumber){
		if(isDefined(arguments.varName)){
			tempVar = evaluate(arguments.varName);
			if(isNumeric(tempVar)){
				return tempVar;
			}else{
				if(arguments.default NEQ ""){
					return arguments.default;
				}else{
					return 0;
				}
			}
		}else{
			if(arguments.default NEQ ""){
				return arguments.default;
			}else{
				return 0;
			}
		}
	}else{
		if(isDefined(arguments.varName)){
			return evaluate(arguments.varName);
		}else{
			return arguments.default;
		}
	}
	</cfscript>	
</cffunction>

<cffunction name="zso" localmode="modern" returntype="any" output="false" hint="Returns a struct variable or default value">
	<cfargument name="structObject" type="struct" required="yes">
	<cfargument name="varName" type="string" required="yes">
	<cfargument name="isNumber" type="boolean" required="no" default="#false#">
	<cfargument name="default" type="any" required="no" default="">
	<cfscript>
	var tempVar = "";
	if(arguments.isNumber){
		if(structkeyexists(arguments.structObject, arguments.varName)){
			tempVar = arguments.structObject[arguments.varName];
			if(isNumeric(tempVar)){
				return tempVar;
			}else{
				if(arguments.default NEQ ""){
					return arguments.default;
				}else{
					return 0;
				}
			}
		}else{
			if(arguments.default NEQ ""){
				return arguments.default;
			}else{
				return 0;
			}
		}
	}else{
		if(structkeyexists(arguments.structObject, arguments.varName)){
			return arguments.structObject[arguments.varName];
		}else{
			return arguments.default;
		}
	}
	</cfscript>	
</cffunction>


<cffunction name="zKillVar" localmode="modern" output="false">
	<cfargument name="varName" type="string" required="yes">
	<cfscript>
	StructDelete(variables, varName, true);
	StructDelete(form,  varName, true);
	StructDelete(form, varName, true);
	</cfscript>
</cffunction>

<cffunction name="zEndOfRunningScript" localmode="modern" output="yes" returntype="any">
	<cfscript>
	request.zos.scriptAborted=true;
	if(isDefined('application.zcore.runningScriptStruct') and structkeyexists(request.zos,'trackingRunningScriptIndex')){
		structdelete(application.zcore.runningScriptStruct,'r'&request.zos.trackingRunningScriptIndex);
	}
	if(structkeyexists(application.zcore,'user') and application.zcore.user.checkGroupAccess("user") EQ false){
		if(structkeyexists(form, 'zajaxdownloadcontent')){
			application.zcore.cache.storeJsonCache();
		}else{
			application.zcore.cache.storeCache();	
		}
	}
	</cfscript>
</cffunction>

<cffunction name="zAbort" localmode="modern" output="yes" returntype="void"><cfargument name="skipBack" type="boolean" required="no" default="#false#"><cfscript>
	var local=structnew();
	var r=0; 
	var n=0;
	var i=0;
	var d=0;
	var fd=0;
	if(structkeyexists(request.zos, 'zAbortRan')){
		return;
	}
	if(structkeyexists(request, 'zsession')){
		application.zcore.session.put(request.zsession);
	}
	request.zos.zAbortRan=true;
	if(arguments.skipBack EQ false and structkeyexists(application.zcore,'tracking')){
		application.zcore.tracking.backOneHit();
	} 
	application.zcore.functions.zEndOfRunningScript();
	request.zos.scriptAborted=true; 
	request.zOS.templateData.notemplate=true;
	application.zcore.functions.zThrowIfImplicitVariableAccessDetected();
</cfscript><cfabort></cffunction>


<cffunction name="zThrowIfImplicitVariableAccessDetected" localmode="modern" output="no">
	<cfscript>
	var q=0;
	var row=0;
	var count=0;
	var jsoutput=0;
	var output=0;
	var uniqueStruct={};
	var ts=0;
	var i=0;
	var i2=0;
	var i3=0;
	if(structkeyexists(form, 'zab') or not isdebugmode() or not request.zos.isImplicitScopeCheckEnabled or left(request.zos.originalURL, 8) EQ "/z/test/" or structkeyexists(request.zos, 'isImplicitScopeCheckRun')){
		return;
	}
	request.zos.isImplicitScopeCheckRun=true;
	savecontent variable="output"{
		if(request.zOS.cfmlAdminReadEnabled){
			admin action="getDebug"	type="web" password="#request.zos.zcoreTestAdminCFMLPassword#"	returnVariable="ts";
			if(not ts.implicitAccess){
				return;
			}
			admin action="getDebugData" returnVariable="q";
			writeoutput('<table style="border-spacing:0px;" class="table-list"><tr><th>Template</th><th>Line</th><th>Scope</th><th>Count</th><th>Name</th></tr>');
			for(row in q.implicitAccess){
				if(row.template NEQ "/Dump.cfc" and row.scope NEQ "thread" and row.name NEQ "cfthread"){
					count++;
					uniqueStruct[row.template][row.scope][row.name]=true;
					writeoutput('<tr><td>'&row.template&'</td><td>'&row.line&'</td><td>'&row.scope&'</td><td>'&row.count&'</td><td>'&row.name&'</td></tr>');
				}
			}
			writeoutput('</table><br />');
			savecontent variable="jsoutput"{
				for(i in uniqueStruct){
					writeoutput(i&chr(10));
					for(i2 in uniqueStruct[i]){
						writeoutput(i2&chr(10));
						for(i3 in uniqueStruct[i][i2]){
							writeoutput('var '&i3&'=0;'&chr(10));
						}
						writeoutput(chr(10));
					}
				}
			}
			writeoutput('<textarea id="zScopeDebugTextArea99" cols="100" rows="10"></textarea><script type="text/javascript">/* <![CDATA[ */document.getElementById("zScopeDebugTextArea99").value="'&jsStringFormat(jsoutput)&'";/* ]]> */</script>');
		}
	}
	if(not count){
		return;
	}
	if(structkeyexists(request, 'zos') and structkeyexists(request.zos, 'inOnErrorFunction')){
		writeoutput("Implicit Variable Access Detected. "&output);
	}else{
		throw("Implicit Variable Access Detected. "&output, "custom");
	}
	</cfscript>
</cffunction>

<cffunction name="zDisableRedirects" localmode="modern" returntype="any" output="no">
	<cfscript>
	request.zos.znoredirect=true;
    </cfscript>
</cffunction>


<cffunction name="z301Redirect" localmode="modern" returntype="any" output="true">
	<cfargument name="url" type="string" required="yes">
	<cfargument name="jsonly" type="boolean" required="no" default="#false#">
	<cfscript>
	var local=structnew();
	var qU="";
	arguments.url=replace(replace(arguments.url, chr(10), '', 'all'), chr(13), '', 'all');
	</cfscript>
    <cfif structkeyexists(request.zos,'znoredirect')>
    <cfthrow type="z301Redirect" message="Redirecting to #arguments.url#">
    </cfif>
	<cfscript>
	application.zcore.functions.zEndOfRunningScript(); 
	if(arguments.url CONTAINS "php://input"){
		application.zcore.functions.z404("This may be a security flaw robot, so we're 404ing the request to avoid error log.");
	}
	if(structkeyexists(form, 'zajaxdownloadcontent') and structkeyexists(form, 'x_ajax_id')){
		if(arguments.url DOES NOT CONTAIN 'zajaxdownloadcontent'){
			arguments.url=application.zcore.functions.zURLAppend(arguments.url, 'zajaxdownloadcontent=1&x_ajax_id='&form.x_ajax_id);
		}
	}
	if(request.zos.isTestServer){
		arguments.url=application.zcore.functions.zURLAppend(arguments.url, "ztv="&randrange(1000000,2000000));	
	}
	application.zcore.functions.zThrowIfImplicitVariableAccessDetected();
	</cfscript>
	<cfif arguments.jsonly>
		<script type="text/javascript">/* <![CDATA[ */window.location.href = '#arguments.url#';/* ]]> */</script>
	<cfelse>
		<cflocation url="#arguments.url#" statuscode="301" addtoken="no">
	</cfif>
</cffunction>

<cffunction name="zRedirect" localmode="modern" returntype="any" output="true">
	<cfargument name="url" type="string" required="yes">
	<cfscript>
	var local=structnew();
	var qU="";
	arguments.url=replace(replace(arguments.url, chr(10), '', 'all'), chr(13), '', 'all');
	if(trim(arguments.url) EQ ""){
		arguments.url="/";
	}
	</cfscript>
    <cfif structkeyexists(request.zos,'znoredirect')>
    <cfthrow type="zRedirect" message="Redirecting to #arguments.url#">
    </cfif>
	<cfscript>
	application.zcore.functions.zEndOfRunningScript();
	if(structkeyexists(form, 'zajaxdownloadcontent') and structkeyexists(form, 'x_ajax_id')){
		if(arguments.url DOES NOT CONTAIN 'zajaxdownloadcontent'){
			arguments.url=application.zcore.functions.zURLAppend(arguments.url, 'zajaxdownloadcontent=1&x_ajax_id='&form.x_ajax_id);
		}
	}
	if(request.zos.isTestServer){
		arguments.url=application.zcore.functions.zURLAppend(arguments.url, "ztv="&randrange(1000000,2000000));	
	}
	application.zcore.functions.zThrowIfImplicitVariableAccessDetected();
	</cfscript>
	<script type="text/javascript">/* <![CDATA[ */window.location.href = '#arguments.url#';/* ]]> */</script>
	<cflocation url="#arguments.url#" addtoken="no">
</cffunction>

<cffunction name="z302Redirect" localmode="modern" returntype="any" output="true" hint="alias for zRedirect">
	<cfargument name="url" type="string" required="yes">
	<cfscript>
	application.zcore.functions.zRedirect(arguments.url);
	</cfscript>
</cffunction>

<!--- zArrayNew(); // set multiple values in one line --->
<cffunction name="zArrayNew" localmode="modern" returntype="array" output="false">
	<cfscript>
	var arrTemp = ArrayNew(1);
	var i=0;
	for(i=1;i LTE ArrayLen(arguments);i=i+1){
		ArrayAppend(arrTemp, arguments[i]);
	}
	return arrTemp;
	</cfscript>
</cffunction> 

<!--- zArrayFind(array, value); --->
<cffunction name="zArrayFind" localmode="modern" returntype="any" output="true">
	<cfargument name="array" type="array" required="yes">
	<cfargument name="value" type="any" required="yes">
	<cfscript>
	var i = 1;
	for(i=1;i LTE ArrayLen(arguments.array);i=i+1){
		if(arguments.array[i] EQ arguments.value){
			return i;
		}
	}
	return -1;
	</cfscript>
</cffunction>

<!--- zGetRootDomain(link); --->
<cffunction name="zGetRootDomain" localmode="modern" output="no" returntype="any">
	<cfargument name="link" type="string" required="yes">
    <cfscript>
	var rootdomain="";
	arguments.link=lcase(trim(arguments.link));
	rootdomain=rereplace(arguments.link,"^(?:https|http)\://(.*?\.([^/^\.]*)|(.*?))\.((aero|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|co|org|pro|tel|travel|ak|al|ar|az|ca|co|ct|de|fl|ga|hi|ia|id|il|in|ks|ky|la|ma|md|me|mi|mn|mo|ms|mt|nc|nd|ne|nh|nj|nm|nv|ny|oh|ok|or|pa|ri|sc|sd|tn|tx|ut|va|vt|wa|wi|wv|wy|as|dc|gu|pr|vi|dni|fed|isa|kids|nsn)\.(ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cx|cy|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw)|(aero|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|co|tel|travel|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cx|cy|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw))(/.*|)$","\2\3.\4");
	if(arguments.link EQ '' or arguments.link EQ rootdomain){
		return false;
	}
	return rootdomain;
	</cfscript>
</cffunction> 

<cffunction name="zDisableContentTransition" localmode="modern">
	<cfscript>
	if(not structkeyexists(request.zos.tempObj, 'zDisableContentTransitionCalled')){
		request.zos.tempObj.zDisableContentTransitionCalled=true;
		application.zcore.template.appendTag("meta", '<script type="text/javascript">zContentTransitionDisabled=true;</script>');
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>