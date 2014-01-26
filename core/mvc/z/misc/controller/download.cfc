<cfcomponent>
	<cfoutput>
	<cffunction name="index" localmode="modern" access="remote" output="yes">
		<cfscript>
        var filepath=0;
        var fp=application.zcore.functions.zso(form, 'fp');
        var fp_backup=fp;
        var ext=application.zcore.functions.zGetFileExt(fp);
        ext=replacelist(ext,"cfm,php,cfc,ini,xml,htm,html,asp,aspx,cgi,pl,htaccess,httpd","");
        fp=replacenocase(fp,"../","","ALL");
        fp=replacenocase(fp,"..\","","ALL");
        fp=replacenocase(fp,":","","ALL");
        if(fp EQ "" or ext EQ "" or fp NEQ fp_backup or left(fp, 9) NEQ "/zupload/"){
            application.zcore.functions.z404();
        }
        filepath=application.zcore.functions.zvar('privatehomedir')&removechars(fp,1,1);
        </cfscript>
        <cfif fileexists(filepath)>
            <cfheader name="Content-Disposition" value="attachment; filename=#getfilefrompath(fp)#" charset="utf-8">
            <cfcontent type="application/binary" deletefile="no" file="#filepath#">
            <cfscript>application.zcore.functions.zabort();</cfscript>
        <cfelse>
        	<cfscript>
			application.zcore.functions.z404();
			</cfscript>
        </cfif>
	</cffunction>
	
    </cfoutput>
</cfcomponent>