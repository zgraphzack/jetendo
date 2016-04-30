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
        <cfsavecontent variable="theMeta"><script type="text/javascript" src="/z/a/scripts/tiny_mce/tinymce.min.js"></script></cfsavecontent><cfscript>application.zcore.template.appendtag("meta",theMeta);</cfscript>
	<cfsavecontent variable="theMeta">

<cfscript>
application.zcore.functions.zRequireFontFaceUrls();
arrExtraCode=[];
if(application.zcore.functions.zso(request.zos.globals, 'typekitURL') NEQ "" or application.zcore.functions.zso(request.zos.globals, 'fontsComURL') NEQ ""){
	arrayAppend(arrExtraCode, ' init_instance_callback: "forceCustomFontLoading",');
} 
fonts=application.zcore.functions.zso(request.zos.globals, 'editorFonts');
if(fonts NEQ ""){
	arrayAppend(arrExtraCode, ' font_formats : 
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
	"Wingdings=wingdings,zapf dingbats", ');
}
</cfscript>
<script type="text/javascript">
zArrDeferredFunctions.push(function(){

tinymce.init({
	fix_table_elements: 0, 
	document_base_url:'/',
	convert_urls: 0,
	browser_spellcheck: true,
	gecko_spellcheck :true,
	paste_remove_spans: 1,
	remove_script_host : 0,
	relative_urls : 0,
	#arrayToList(arrExtraCode, " ")#
  /*selector: 'textarea', 
  height: 500,*/
  theme: 'modern',
  plugins: [
    'advlist autolink lists link image zsaimage charmap print preview hr anchor pagebreak',
    'searchreplace wordcount visualblocks visualchars code fullscreen',
    'insertdatetime media nonbreaking save table contextmenu directionality',
    'emoticons paste textcolor colorpicker textpattern imagetools'
  ], // template
  toolbar1: 'insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image zsaimage',
  toolbar2: 'print preview media | forecolor backcolor emoticons',
  image_advtab: true, 
  content_css: [ 
    "#this.config.EditorAreaCSS#"
  ]
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
	
	<cfsavecontent variable="theScript"><script type="text/javascript">zArrDeferredFunctions.push(function(){tinymce.EditorManager.execCommand('mceAddEditor', true, "#this.instanceName#");});
	</script></cfsavecontent>
<cfscript>
application.zcore.template.appendTag("scripts",theScript);
</cfscript>
	#theReturn#
</cffunction>

</cfoutput>
</cfcomponent>
