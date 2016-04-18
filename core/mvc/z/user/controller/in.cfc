<cfcomponent>
 <cfoutput>

<cffunction name="confirmed" localmode="modern" access="remote" output="yes">
	<cfscript>
	var zpagenav='<a href="#request.zos.currentHostName#/">Home</a> /';
	if(structkeyexists(form, 'e') EQ false or structkeyexists(form, 'k') EQ false){
		application.zcore.functions.zRedirect(request.zos.currentHostName&'/z/user/preference/index');
	}
	application.zcore.template.setTag("title","Our Mailing List");
	application.zcore.template.setTag("pagetitle","Our Mailing List");
	application.zcore.template.setTag("pagenav",zpagenav);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	<h2>Thank you for confirming your email address.</h2>
	
	<p>In the future, you may change your communication preferences here: 
	<a href="#request.zos.currentHostName#/z/user/preference/index?e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&action=form">#request.zos.currentHostName#/z/user/preference/index</a></p>
	<p><a href="#request.zos.currentHostName#/z/user/privacy/index" class="zPrivacyPolicyLink">View our privacy policy</a></p>
 
</cffunction>



<cffunction name="simple_confirmed" localmode="modern" access="remote" output="yes">
	<cfscript>
	var zpagenav='<a href="#request.zos.currentHostName#/">Home</a> /';
	application.zcore.template.setTag("title","Our Mailing List");
	application.zcore.template.setTag("pagetitle","Our Mailing List");
	application.zcore.template.setTag("pagenav",zpagenav);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	<h2>Thank you for confirming your email address.</h2>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" output="yes">
        <cfscript>
	var userAdminCom=0;
	var ts=0;
	var rs=0;
	if(structkeyexists(form, 'e') and structkeyexists(form, 'k')){
		userAdminCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_admin");
		ts=StructNew();
		ts.email=form.e;
		ts.key=form.k;
		writedump(form.k);
		ts.redirectURL=request.zos.currentHostName&"/z/user/in/confirmed?e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#";
		rs=userAdminCom.confirm(ts);
		if(rs.success EQ false){
			application.zcore.status.setStatus(request.zsid, "Your email address was not confirmed for the following reasons:");
			application.zcore.functions.zStatusHandler(request.zsid);
		}
	}else{
		application.zcore.functions.zRedirect(request.zos.currentHostName&'/z/user/preference/index');
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>