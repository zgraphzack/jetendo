<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="administrator">
	<cfscript>
	if(application.zcore.functions.zso(request.zos.globals, 'lockTheme', true, 1) EQ 1){
		application.zcore.status.setStatus(request.zsid, "The theme is locked on this site.  You must contact the developer to make changes to the site design.", form, true);
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	</cfscript>
</cffunction>


<cffunction name="getThemeStruct" localmode="modern" access="public" roles="administrator" returntype="struct">
	<cfscript>
	directory action="list" type="dir" directory="#request.zos.installPath#themes/" name="qDir" sort="name asc";
	themeStruct=structnew("linked");
	themeStruct['custom']=true;
	for(row in qDir){
		themeStruct[row.name]=true;
		if(row.name EQ "custom"){
			throw("""custom"" is a reserved theme name.  Please rename the theme to something unique.");
		}
	}
	return themeStruct;
	</cfscript>
</cffunction>

<cffunction name="apply" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	db=request.zos.queryObject;
	form.preview=application.zcore.functions.zso(form, 'preview', true, 0);
	form.name=application.zcore.functions.zso(form, 'name');
	
	themeStruct=this.getThemeStruct();
	if(not structkeyexists(themeStruct, form.name)){
		application.zcore.status.setStatus(request.zsid, """#form.name#"" is not a valid theme name.", form, true);
		application.zcore.functions.zRedirect("/z/admin/theme/index?zsid=#request.zsid#");	
	}
	if(form.preview EQ 0){
		// apply theme permanently
		db.sql="update 
		#db.table("site", application.zcore.zcoreDatasource)#
		set site_theme_name=#db.param(form.name)# 
		where site_id = #db.param(request.zos.globals.id)#";
		db.execute("qUpdate");
		structdelete(session, 'zCurrentTheme');
		application.zcore.functions.zOS_cacheSiteAndUserGroups();
		application.zcore.status.setStatus(request.zsid, "The theme, ""#form.name#"", has been permanently applied as the default theme.  All users will see the new theme.  Please make sure your web site is working correctly with the new theme.");
	}else{
		session.zCurrentTheme=form.name;
		application.zcore.status.setStatus(request.zsid, "The theme, ""#form.name#"", has been set for your session.  Other users will not see the change.  If you log out or your session expires, the theme will revert to the permanent theme that is applied.");
	}
	application.zcore.functions.zRedirect("/z/admin/theme/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="disablePreview" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	structdelete(session, 'zCurrentTheme');
	application.zcore.status.setStatus(request.zsid, "Preview theme mode disabled.");
	application.zcore.functions.zRedirect("/z/admin/theme/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	application.zcore.functions.zStatusHandler(request.zsid);
	
	if(structkeyexists(session, 'zCurrentTheme')){
		currentTheme=session.zCurrentTheme;
	}else{
		currentTheme=application.zcore.functions.zso(request.zos.globals, 'themeName', false, "custom");
	}
	if(currentTheme EQ ""){
		currentTheme="custom";
	}
	themeStruct=getThemeStruct();
	
	// apply a theme for current session only
	// apply permenantly
	echo('<h2>Select A Theme</h2>');
	echo('<p>Important: each theme comes with it''s own set of custom features in addition to what the core application offers.</p>');
	echo('<table class="table-list">
	<tr>
	<th>Theme Name</th>
	<th>Admin</th>
	</tr>
	<tr>');
	for(i in themeStruct){
		echo('<tr>
		<td>'&application.zcore.functions.zFirstLetterCaps(i)&'</td>
		<td>');
			
		if(currentTheme EQ i){
			if(structkeyexists(session, 'zCurrentTheme')){
				echo('Preview Enabled, <a href="/z/admin/theme/disablePreview">Click To Disable</a> | 
				<a href="/z/admin/theme/apply?name=#urlencodedformat(i)#">Apply</a>');
			}else{
				echo('<a href="/z/admin/theme/apply?name=#urlencodedformat(i)#&preview=1">Preview</a> | Applied Permanently');
			}
		}else{
			echo('<a href="/z/admin/theme/apply?name=#urlencodedformat(i)#&preview=1">Preview</a> | 
			<a href="/z/admin/theme/apply?name=#urlencodedformat(i)#">Apply</a>');
		}
		echo('</td>
		</tr>
		<tr>');
	}
	echo('</table>');
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>