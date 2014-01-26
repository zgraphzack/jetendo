<cfcomponent>
    <cfoutput>
    <cffunction name="init" localmode="modern" access="private">
    	<cfscript>
		form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',false,0);
        if(form.modalpopforced EQ 1){
			application.zcore.functions.zSetModalWindow();
        }
		</cfscript>
    </cffunction>
     
	<cffunction name="index" localmode="modern" access="remote">
    	<cfscript>
		var local=structnew();
		this.init();
		</cfscript>
		<cfif application.zcore.app.siteHasApp("content")>
			<cfscript>
            local.inquiryTextMissing=false;
            local.ts=structnew();
			if(form.modalpopforced EQ 1){
				local.ts.editLinksEnabled=false;
			}
            local.ts.content_unique_name='/z/misc/mailing-list/index';
            local.r1=application.zcore.app.getAppCFC("content").includePageContentByName(local.ts);
            if(local.r1 EQ false){
                local.inquiryTextMissing=true;
            }
            </cfscript>
            <cfif local.inquiryTextMissing>
                
				<cfscript>
				application.zcore.template.setTag("title","Join Our Mailing List");
				application.zcore.template.setTag("pagetitle","Join Our Mailing List");
                </cfscript>
            </cfif>
		</cfif>
        <cfscript>
		application.zcore.functions.zStatusHandler(request.zsid,true);
		
            form.set9=application.zcore.functions.zGetHumanFieldIndex();
            </cfscript>
        <form action="/z/misc/mailing-list/process" onsubmit="zSet9('zset9_#form.set9#');" method="get">
            <input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
			<cfif form.modalpopforced EQ 1>
            <input type="hidden" name="modalpopforced" value="1" />
            <input type="hidden" name="js3811" id="js3811" value="" />
            <input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" />
            </cfif>
            #application.zcore.functions.zFakeFormFields()#
          <p>Your Email Address: 
            <input type="text" name="user_username" size="40" value="#htmleditformat(application.zcore.functions.zso(form, 'email'))#" />
            </p>
            <p>
            <input type="submit" name="submit1" value="Subscribe" />
            </p>
        <p>By submitting this form, you agree to receive mailing list emails from us. #application.zcore.functions.zvarso("Form Privacy Message")# <a href="/z/user/privacy/index" target="_blank">Privacy Policy</a>.</p>
        </form>
        
        
    </cffunction>
    
    <cffunction name="process" localmode="modern" access="remote">
    	<cfscript>
	var a=0;
		this.init();
		
        if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
            application.zcore.functions.zRedirect("/z/misc/mailing-list/thankyou?modalpopforced=#form.modalpopforced#");
        }
		
        if(form.modalpopforced EQ 1){
            if(application.zcore.functions.zso(form, 'js3811') NEQ "j219"){
                writeoutput('~n~');application.zcore.functions.zabort();
            }
            if(application.zcore.functions.zCheckFormHashValue(application.zcore.functions.zso(form, 'js3812')) EQ false){
                application.zcore.status.setStatus(request.zsid, "Your session has expired.  Please submit the form again.",form,true);
                application.zcore.functions.zRedirect("/z/misc/mailing-list/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#");
            }
		}
        if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
            application.zcore.functions.zredirect('/');
        }
		// add to mail_user and send email.
		form.user_pref_list=1;
		form.user_username=application.zcore.functions.zso(form, 'user_username');
		if(form.user_username EQ "" or application.zcore.functions.zEmailValidate(form.user_username) EQ false){
			application.zcore.status.setStatus(request.zsid, "A valid email address is required.", true);
			application.zcore.functions.zRedirect("/z/misc/mailing-list/index?zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");	
		}
		form.mail_user_id=application.zcore.user.automaticAddUser(form);
		//a=application.zcore.user.automaticAddUser(form);
		application.zcore.functions.zRedirect("/z/misc/mailing-list/thankyou?modalpopforced=#form.modalpopforced#");	
		</cfscript>
    </cffunction>
    
    <cffunction name="thankyou" localmode="modern" access="remote">
    	<cfscript>
		var local=structnew();
		this.init();
		</cfscript>
		<cfif application.zcore.app.siteHasApp("content")>
			<cfscript>
            local.inquiryTextMissing=false;
            local.ts=structnew();
            local.ts.content_unique_name='/z/misc/mailing-list/thankyou';
            local.r1=application.zcore.app.getAppCFC("content").includePageContentByName(local.ts);
            if(local.r1 EQ false){
                local.inquiryTextMissing=true;
            }
            </cfscript>
            <cfif local.inquiryTextMissing>
                
				<cfscript>
				application.zcore.template.setTag("title","Thank You For Joining Our Mailing List");
				application.zcore.template.setTag("pagetitle","Thank You For Joining Our Mailing List");
                </cfscript>
            </cfif>
		</cfif>
    	
		  <cfif structkeyexists(form,'modalpopforced') and form.modalpopforced EQ 1>
            <p>Closing window in 3 seconds.</p>
            <script type="text/javascript">/* <![CDATA[ */ 
		setTimeout(function(){ zCloseThisWindow(); },3000);
            /* ]]> */
            </script>
        </cfif>
        #application.zcore.functions.zVarSO("Lead Conversion Tracking Code")#
    </cffunction>
    
    </cfoutput>
</cfcomponent>