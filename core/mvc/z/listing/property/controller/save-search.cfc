<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
	<cfscript>
	var ss=0;
	var db=request.zos.queryObject;
	Request.zPageDebugDisabled=true;
	application.zcore.functions.zSetModalWindow();
	application.zcore.template.setTag("title","Save Search");
	application.zcore.template.setTag("pagetitle","Save Search");
	
	form.action=application.zcore.functions.zso(form, 'action',false,'list');
	</cfscript>
	
	<cfif form.action EQ 'save'>
		<cfscript>
		if(application.zcore.functions.zso(form,'saved_search_email') EQ '' or application.zcore.functions.zemailvalidate(form.saved_search_email) EQ false){
			
			if(structkeyexists(form, 'returnJson')){
				rs={
					success:false,
					errorMessage:"Invalid email address. Please type a valid email address.",
					searchId:form.searchId
				};
				application.zcore.functions.zReturnJson(rs);
			}else{
				application.zcore.status.setStatus(request.zsid,"Invalid email address. Please type a valid email address.");
				application.zcore.functions.zRedirect(request.cgi_script_name&"?method=index&searchId=#form.searchid#&zsid=#request.zsid#");	
			}
		}
		application.zcore.status.setField(form.searchid,"saved_search_email",form.saved_search_email);
		application.zcore.status.setField(form.searchid,"saved_search_format",form.saved_search_format);
		application.zcore.status.setField(form.searchid,"saved_search_frequency",form.saved_search_frequency);
		form.saved_search_format=application.zcore.functions.zso(form, 'saved_search_format', true, 1);
		form.saved_search_frequency=application.zcore.functions.zso(form, 'saved_search_frequency', true, 0);
		ss=application.zcore.status.getStruct(form.searchid);
		if(isNumeric(application.zcore.functions.zso(form,'searchId')) EQ false or structkeyexists(ss,'varstruct') EQ false){// or structkeyexists(ss.varstruct,'search_city_id') EQ false){
			if(structkeyexists(form, 'returnJson')){
				rs={
					success:false,
					errorMessage:"This search has expired. Please search and try again.",
					searchId:form.searchId
				};
				application.zcore.functions.zReturnJson(rs);
			}else{
				writeoutput('<h2>This search has expired. Please search again and the click "SAVE THIS SEARCH" link again.<p>Closing window in 3 seconds.</p>		<script type="text/javascript">    /* <![CDATA[ */ setTimeout(''window.parent.zCloseModal();'',3000);     /* ]]> */    </script>');
				application.zcore.functions.zabort();
			}
		}
		structappend(form,ss.varstruct);
		if(isDefined('request.zsession.user.id')){
			form.user_id=request.zsession.user.id;
			form.user_id_siteIDType=application.zcore.user.getSiteIdTypeFromLoggedOnUser();
		}else{
			form.user_id=0;
			form.user_id_siteIDType=4;
		}
		request.zsession.inquiries_email=form.saved_search_email;
		form.saved_search_format=application.zcore.functions.zso(form, 'saved_search_format', true, 1);
		form.saved_search_last_sent_date=request.zos.mysqlnow;
		form.mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', 0, form.saved_search_email, form); 
		form.inquiries_email=form.saved_search_email;
		application.zcore.tracking.setUserEmail(form.inquiries_email);
		application.zcore.tracking.setConversion('saved search');
		
		local.tempEmail=application.zcore.functions.zvarso('zofficeemail');
		
		</cfscript>
		<cfmail  to="#local.tempEmail#" from="#request.fromemail#" replyto="#form.inquiries_email#" subject="New Saved Search on #request.zos.globals.shortdomain#" type="html">
		#application.zcore.functions.zHTMLDoctype()#
		<head><title>Saved Search</title></head><body>
		<p><span style="font-size:18px; font-weight:bold;">#request.zos.globals.shortdomain# saved search.</span></p>
		<p style="font-size:14px; font-weight:normal;">
		Email: <a href="mailto:#form.inquiries_email#">#form.inquiries_email#</a></p>
		<p>This person signed up for a new listing email alert with the following criteria: <br />
		#arraytolist(request.zos.listing.functions.getSearchCriteriaDisplay(form),", ")#
		</p>
		<p>You may want to contact the person as if they are a lead, but they didn't directly ask a question yet, so they may be unlikely to respond.</p>
		<p><a href="#request.zos.currentHostName#/z/listing/admin/saved-searches/index">Login and view all saved searches</a></p>
		</body></html>
		</cfmail>
		<cfscript>
		form.mail_user_id=application.zcore.user.automaticAddUser(application.zcore.functions.zUserMapFormFields(structnew()));
		
		if(structkeyexists(form, 'returnJson')){
			rs={
				success:true,
				searchId:form.searchId
			};
			application.zcore.functions.zReturnJson(rs);
		}else{
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=index&action=saved");
		}
		</cfscript>
	</cfif>
	
	<cfif form.action EQ 'saved'>
		<script type="text/javascript">
		/* <![CDATA[ */ setTimeout('window.parent.zCloseModal();',2000); /* ]]> */
		</script>
		<h2>Search saved successfully</h2>
	    
	<p>Closing window in 2 seconds...</p>
	</cfif>
	
	<cfif form.action EQ 'list'> 
		<cfscript>
		application.zcore.functions.zStatusHandler(request.zsid); 
		</cfscript>
		<cfif isNumeric(application.zcore.functions.zso(form, 'searchId')) EQ false or structcount(application.zcore.status.getStruct(form.searchid)) EQ 0>    
			<h2>This search has expired. Please search again and click "save search".</h2>
			<p>Closing window in 3 seconds.</p>
				<script type="text/javascript">
			/* <![CDATA[ */ setTimeout('window.parent.zCloseModal();',3000); /* ]]> */
			</script>
		<cfelse>
		
			<p>Please enter your email address, select delivery options and click save search to begin receiving email alerts when new listings match your search criteria.</p>
			    
			    <form action="#request.cgi_script_name#?method=index&action=save&searchId=#form.searchid#" method="post">
			    <table style="border-spacing:0px;width:100%;">
			<tr><td>Email Address:</td>
			<td><cfif isDefined('request.zsession.user.id')>Logged in as #request.zsession.user.email#<br />
			Want to use a different account? <a href="#request.cgi_script_name#?zlogout=1&searchId=#urlencodedformat(form.searchid)#">Click Here to Logout</a>
			<input type="hidden" name="saved_search_email" value="#request.zsession.user.email#" />
			<cfelse><input type="text" name="saved_search_email" style="width:400px;" value="<cfif isDefined('request.zsession.saved_search_email')>#request.zsession.saved_search_email#<cfelse>#application.zcore.functions.zso(request.zsession, 'inquiries_email')#</cfif>" /></cfif> </td>
			</tr>
			<tr>
			<td>Format:</td>
			<td><input type="radio" name="saved_search_format" value="1" style="background:none; border:0px; " <cfif application.zcore.functions.zso(form, 'saved_search_format') EQ '1' or application.zcore.functions.zso(form, 'saved_search_format') EQ ''>checked="checked"</cfif> /> HTML Text w/Photos 
				<input type="radio" name="saved_search_format" value="0" <cfif application.zcore.functions.zso(form, 'saved_search_format') EQ '0'>checked="checked"</cfif> style="background:none; border:0px; " /> Plain Text</td>
			</tr>
			<tr>
			<td>Frequency:</td>
			<td><input type="radio" name="saved_search_frequency" value="0" style="background:none; border:0px; " <cfif application.zcore.functions.zso(form, 'saved_search_frequency') EQ '0' or application.zcore.functions.zso(form, 'saved_search_frequency') EQ ''>checked="checked"</cfif> /> Every Day 
				<input type="radio" name="saved_search_frequency" value="1" <cfif application.zcore.functions.zso(form, 'saved_search_frequency') EQ '1'>checked="checked"</cfif> style="background:none; border:0px; " /> Fridays</td>
			</tr>
			<tr><td>&nbsp;</td><td><button type="submit" name="submit1" value="Save Search">Save Search</button> <button type="button" name="cancel1" value="Cancel" onClick="window.parent.zCloseModal();">Cancel</button> | <a href="/z/user/privacy/index"  rel="external" onClick="window.open('/z/user/privacy/index');return false;" class="zPrivacyPolicyLink">Privacy Policy</a></td></tr>
			<tr><td colspan="4">
			#application.zcore.functions.zvarso("Form Privacy Message")#</td></tr>
			</table>
			</form>
		</cfif>
			
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>