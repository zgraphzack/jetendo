<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" output="yes">
	<cfscript>
	if(left(form.fp, 15) EQ "/zuploadsecure/" and not application.zcore.user.checkGroupAccess("administrator")){
		application.zcore.user.requireLogin("administrator");
	} 
	downloadFile(application.zcore.functions.zso(form, 'fp')); 
	</cfscript> 
</cffunction>

<cffunction name="downloadFile" localmode="modern" access="public" output="yes">
	<cfargument name="rootRelativeURL" type="string" required="yes">
	<cfscript>
	var filepath=0;
	var fp=arguments.rootRelativeURL;
	var fp_backup=fp;
	var ext=application.zcore.functions.zGetFileExt(fp);
	ext=replacelist(ext,"cfm,php,cfc,ini,xml,htm,html,asp,aspx,cgi,pl,htaccess,httpd","");
	fp=replacenocase(fp,"../","","ALL");
	fp=replacenocase(fp,"..\","","ALL");
	fp=replacenocase(fp,":","","ALL"); 
	if(fp EQ "" or ext EQ "" or fp NEQ fp_backup or (left(fp, 9) NEQ "/zupload/" and left(fp, 15) NEQ "/zuploadsecure/")){
		application.zcore.functions.z404("File location was insecure");
	}
	filepath=application.zcore.functions.zvar('privatehomedir')&removechars(fp,1,1);
	if(fileexists(filepath)){
		header name="Content-Disposition" value="attachment; filename=#getfilefrompath(fp)#" charset="utf-8";
		content type="application/binary" deletefile="no" file="#filepath#";
		abort;
	}else{
		application.zcore.functions.z404("File doesn't exist");
	}
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>