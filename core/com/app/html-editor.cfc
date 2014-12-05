<cfcomponent output="false">
<cfoutput>
	
<!--- 
<cfscript>
htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
htmlEditor.instanceName= "content_summary";
htmlEditor.value= content_summary;
htmlEditor.basePath= '/';
htmlEditor.width= "100%";
htmlEditor.height= 250;
htmlEditor.create();
</cfscript>
 --->
<cffunction name="Create" localmode="modern"
	access="public"
	output="true"
	returntype="any"
	hint="Outputs the editor HTML in the place where the function is called"
>

	<cfparam name="this.instanceName" type="string" />
	<cfparam name="this.width" type="string" default="100%" />
	<cfparam name="this.height" type="string" default="200" />
	<cfparam name="this.toolbarSet" type="string" default="Default" />
	<cfparam name="this.value" type="string" default="" />
	<cfparam name="this.basePath" type="string" default="/" />
	<cfparam name="this.checkBrowser" type="boolean" default="true" />
	<cfparam name="this.config" type="struct" default="#structNew()#" />

	<cfscript>
	var theScript=0;
	var theMeta="";
	var theReturn="";
	this.config.fileImageGalleryScript='/z/admin/files/gallery';
	this.config.EditorAreaCSS=request.zos.globals.editorStylesheet;
	</cfscript>
    <cfif isDefined('request.zos.zTinyMceIncluded') EQ false>
    	<cfset request.zos.zTinyMceIncluded=true>
        <cfsavecontent variable="theMeta"><script type="text/javascript" src="/z/a/scripts/tiny_mce/tiny_mce.js"></script></cfsavecontent><cfscript>application.zcore.template.appendtag("meta",theMeta);</cfscript>
	<cfsavecontent variable="theMeta">

            <script type="text/javascript">
			<cfscript>application.zcore.functions.zRequireFontFaceUrls();
			</cfscript>
zArrDeferredFunctions.push(function(){
tinyMCE.init({
	fix_table_elements: 0,
	   //forced_root_block : false,
document_base_url:'/',
convert_urls: 0,
browser_spellcheck: true,
gecko_spellcheck :true,
paste_remove_spans: 1,
remove_script_host : 0,
relative_urls : 0,
	mode : "none",
	theme : "advanced",	
	<cfif application.zcore.functions.zso(request.zos.globals, 'typekitURL') NEQ "" or application.zcore.functions.zso(request.zos.globals, 'fontsComURL') NEQ "">
	init_instance_callback: "forceCustomFontLoading",
	</cfif>
	<cfif isDefined('request.zos.globals.editorFonts') and request.zos.globals.editorFonts NEQ "">
	theme_advanced_fonts : 
	#request.zos.globals.editorFonts#
	"Andale Mono=andale mono,times;"+ 
                "Arial=arial,helvetica,sans-serif;"+ 
                "Arial Black=arial black,avant garde;"+ 
                "Book Antiqua=book antiqua,palatino;"+ 
                "Comic Sans MS=comic sans ms,sans-serif;"+ 
                "Courier New=courier new,courier;"+ 
                "Georgia=georgia,palatino;"+ 
                "Helvetica=helvetica;"+ 
                "Impact=impact,chicago;"+ 
                "Symbol=symbol;"+ 
                "Tahoma=tahoma,arial,helvetica,sans-serif;"+ 
                "Terminal=terminal,monaco;"+ 
                "Times New Roman=times new roman,times;"+ 
                "Trebuchet MS=trebuchet ms,geneva;"+ 
                "Verdana=verdana,geneva;"+ 
                "Webdings=webdings;"+ 
                "Wingdings=wingdings,zapf dingbats", 

	</cfif>
	plugins : "safari,<!---spellchecker,  contextmenu,--->pagebreak,style,layer,table,save,advhr,advimage,emotions,iespell,inlinepopups,insertdatetime,preview,media,searchreplace,print,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template<!--- ,advlink,imagemanager,filemanager --->",
	theme_advanced_buttons1 : "bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,styleselect,formatselect,fontselect,fontsizeselect",
	theme_advanced_buttons2 : "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,zsaimage,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor",
	theme_advanced_buttons3 : "tablecontrols,|,hr,removeformat,visualaid,|,sub,sup,|,charmap,emotions,iespell,media,advhr,|,print,|,ltr,rtl,|,fullscreen",
	theme_advanced_buttons4 : "insertlayer,moveforward,movebackward,absolute,|,styleprops,<!---  spellchecker,--->|,cite,abbr,acronym,del,ins,attribs,|,visualchars,nonbreaking,template,blockquote,pagebreak,|,insertfile,insertimage",
	extended_valid_elements : "iframe[src|width|height|name|align]",
	theme_advanced_toolbar_location : <cfif isDefined('this.config.theme_advanced_toolbar_location')>"#this.config.theme_advanced_toolbar_location#"<cfelse>"top"</cfif>,
	theme_advanced_toolbar_align : "left",
	theme_advanced_statusbar_location : "bottom",
	theme_advanced_resizing : true,
	content_css : "#this.config.EditorAreaCSS#"
	<!--- template_external_list_url : "js/template_list.js",
	external_link_list_url : "js/link_list.js",
	media_external_list_url : "js/media_list.js" --->
});
});
</script>
</cfsavecontent>
<cfscript>
application.zcore.template.prependTag("scripts",theMeta);
if(structkeyexists(request,'zTinyMceIncludedCount') EQ false){
	request.zTinyMceIncludedCount=1;
}
request.zTinyMceIncludedCount++;
</cfscript>
</cfif>
	<cfsavecontent variable="theReturn"><textarea id="#this.instanceName#" name="#this.instanceName#" cols="10" rows="10" style="width:#this.width#<cfif this.width DOES NOT CONTAIN "%" and this.width DOES NOT CONTAIN "px">px</cfif>; height:#this.height#<cfif this.height DOES NOT CONTAIN "%" and this.height DOES NOT CONTAIN "px">px</cfif>;">#htmleditformat(this.value)#</textarea></cfsavecontent>
	
	<cfsavecontent variable="theScript"><script type="text/javascript">zArrDeferredFunctions.push(function(){tinyMCE.execCommand("mceAddControl", true, "#this.instanceName#");});
	</script></cfsavecontent>
<cfscript>
application.zcore.template.appendTag("scripts",theScript);
</cfscript>
	#theReturn#
</cffunction>

</cfoutput>
</cfcomponent>
