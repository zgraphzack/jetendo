<cfcomponent>
	<cfoutput>
    <cffunction name="select" localmode="modern" access="remote" roles="member">
		<cfscript>
		this.index();
		</cfscript>
	</cffunction>
	
    <cffunction name="index" localmode="modern" access="remote" roles="member">
    	<cfscript>
		var local=structnew();
		var qinquiry=0;
		var qAgents=0;
		var selectStruct=0;
		var db=request.zos.queryObject;
		var userGroupCom = CreateObject("component","zcorerootmapping.com.user.user_group_admin");
		form.inquiries_id=application.zcore.functions.zso(form, 'inquiries_id');
		form.zPageId=application.zcore.functions.zso(form, 'zPageId');
		</cfscript>
        <cfsavecontent variable="db.sql">
            SELECT * FROM (#db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status
, #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
) 
            LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type
 ON inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and inquiries_type.site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))#
            WHERE inquiries.site_id = #db.param(request.zos.globals.id)#  and 		inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
            inquiries.inquiries_status_id NOT IN (#db.trustedSQL("4,5,0")#) and 
             inquiries_id = #db.param(form.inquiries_id)#  
        </cfsavecontent><cfscript>
		qinquiry=db.execute("qinquiry");
            if(qinquiry.recordcount EQ 0){		
                request.zsid = application.zcore.status.setStatus(Request.zsid, "This inquiry doesn't exist.", false,true);
                application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
            }else{
                application.zcore.functions.zQueryToStruct(qinquiry);
            }
            application.zcore.functions.zstatushandler(request.zsid,true);
        </cfscript>
        <span class="form-view">
        <h2>Selected Lead</h2>
		<p>Leads are matched by email and phone number to help you assign to the same agent if desired.</p>
            <table style="width:100%; border-spacing:0px;" class="table-list">
            <tr>
            <th style="width:150px;">Name</th>
            <th style="width:150px;">Email</th>
            <th>&nbsp;</th>
            <th>Date Received</th>
            <th>Previously Assigned To:</th>
            <th>Previous Lead Date:</th>
            </tr>
            <tr >
            <td style="width:150px;">#form.inquiries_first_name# #form.inquiries_last_name#</td>
            <td style="width:150px;"><cfif len(form.inquiries_email) NEQ 0>#form.inquiries_email#</cfif></td>
            <td></td>
            <td style="width:150px;">#DateFormat(form.inquiries_datetime,'m/d/yy')&' '&TimeFormat(form.inquiries_datetime,'h:mm tt')#</td> 
	    <cfscript>
	    db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# 
	    WHERE inquiries_id <> #db.param(form.inquiries_id)# and 
	    inquiries_email = #db.param(form.inquiries_email)# and
	    site_id = #db.param(request.zos.globals.id)# and 
	    (user_id <> #db.param(0)# or 
	    inquiries_assign_email <> #db.param('')#) 
	    ORDER BY inquiries_datetime DESC   ";
	    local.qPrevious=db.execute("qPrevious");
	    if(local.qPrevious.recordcount NEQ 0){
		writeoutput('<td>');
		if(local.qPrevious.user_id NEQ 0){
			db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# user
			WHERE user_id = #db.param(local.qPrevious.user_id)# and 
			site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL(local.qPrevious.user_id_siteIDType))#";
			local.qUserTemp=db.execute("qUserTemp");
			if(local.qUserTemp.recordcount NEQ 0){
				writeoutput(local.qUserTemp.user_first_name&" "&local.qUserTemp.user_last_name&" "&local.qUserTemp.user_username);
			}
		}else{
			writeoutput('#local.qPrevious.inquiries_assign_name# #local.qPrevious.inquiries_assign_email# ');
		} 
		writeoutput('</td><td>'&dateformat(local.qPrevious.inquiries_datetime, "m/d/yy ")&timeformat(local.qPrevious.inquiries_datetime, 'h:mm tt')&'</td>');
	    }else{
		writeoutput('<td>N/A</td><td>&nbsp;</td>');    
	    }
	    </cfscript>
            </tr>
            </table><br />
         
        
        <h2><cfif form.user_id NEQ 0>Re-</cfif>Assign Lead</h2>
        Note: The agents in the drop down menu are sorted in the sequence they are due to receive a lead. Agent will be notified of assignment by email.<br /><br />
        
        <table style="width:100%; border-spacing:0px;" class="table-list">
        <form action="/z/inquiries/admin/assign/assign?inquiries_id=#form.inquiries_id#&amp;zPageId=#form.zPageId#" method="post">
        <tr><th>Assign to:</th></tr>
        <tr>
        <td>
        <cfsavecontent variable="db.sql">
        SELECT *, user.site_id userSiteId FROM  #db.table("user", request.zos.zcoreDatasource)# user
 
        WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
	user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# 
         and (user_server_administrator=#db.param(0)#)
        ORDER BY member_first_name ASC, member_last_name ASC
        </cfsavecontent><cfscript>qAgents=db.execute("qAgents");</cfscript>
        <script type="text/javascript">
        /* <![CDATA[ */
		function showAgentPhoto(id){
            var d1=document.getElementById("agentPhotoDiv");
            if(id!="" && arrAgentPhoto[id]!=""){
                d1.innerHTML='<img src="'+arrAgentPhoto[id]+'" width="100">';
            }else{
                d1.innerHTML="";	
            }
        }
        var arrAgentPhoto=new Array();
        <cfloop query="qAgents">
        arrAgentPhoto["#qAgents.user_id#"]=<cfif qAgents.member_photo NEQ "">"#jsstringformat('#application.zcore.functions.zvar('domain',qAgents.userSiteId)##request.zos.memberImagePath##qAgents.member_photo#')#"<cfelse>""</cfif>;
        </cfloop>
		/* ]]> */
        </script>
        <cfscript>
        selectStruct = StructNew();
        selectStruct.name = "user_id";
        selectStruct.query = qAgents;
        selectStruct.queryLabelField = "##user_first_name## ##user_last_name## (##user_username##)";
        selectStruct.onchange="showAgentPhoto(this.options[this.selectedIndex].value);";
        selectStruct.queryParseLabelVars = true;
        selectStruct.queryValueField = 'user_id';
        application.zcore.functions.zInputSelectBox(selectStruct);
        </cfscript>
        or Type Name: <input type="text" name="assign_name" value="#application.zcore.functions.zso(form, 'assign_name')#" /> and Email: <input type="text" name="assign_email" value="#application.zcore.functions.zso(form, 'assign_email')#" />
        <br />
    <div id="agentPhotoDiv"></div>
        </td>
        </tr>
        <tr>
        <th>Administrative Comments (Optional)</th></tr>
        <tr>
        <td><textarea name="inquiries_admin_comments" style="width:100%; height:150px; ">#form.inquiries_admin_comments#</textarea></td></tr>
        <tr>
            <td><button type="submit" name="submitForm"><cfif form.user_id NEQ 0>Re-</cfif>Assign Lead</button> <button type="button" name="cancel" onclick="window.location.href = '/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#';">Cancel</button></td>
        </tr>
        </form>
        </table>
        </span>
        
    </cffunction>
    
    <!--- <cffunction name="group" localmode="modern" access="remote" roles="member">
    	<cfscript>
		var iemailcom=0;
		var qMember=0;
		var qFeedback=0;
		var qinquiry=0;
		var email=0;
		var db=request.zos.queryObject;
		form.zPageId=application.zcore.functions.zso(form, 'zPageId');
		</cfscript>
        <cfsavecontent variable="db.sql">
        SELECT * FROM #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
, #db.table("user", request.zos.zcoreDatasource)# user
 WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())#  
        and inquiries.user_id = user.user_id and inquiries_id = #db.param(inquiries_parent_id)# 
        </cfsavecontent><cfscript>qMember=db.execute("qMember");
        if(qMember.recordcount EQ 0){
            request.zsid = application.zcore.status.setStatus(Request.zsid, "Inquiry doesn't exist.", false,true);
            application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
        }
        </cfscript>
        <cfsavecontent variable="db.sql">
        SELECT count(inquiries_feedback_id) count from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback WHERE inquiries_id = #db.param(inquiries_id)#  and site_id = #db.param(request.zos.globals.id)#
        </cfsavecontent><cfscript>qFeedback=db.execute("qFeedback");</cfscript>
        <cfsavecontent variable="db.sql">
        UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# 
 SET inquiries_status_id = '<cfif qFeedback.count NEQ 0>3<cfelse>2</cfif>', user_id = #db.param(qMember.user_id)#, inquiries_parent_id = #db.param(inquiries_parent_id)#  WHERE inquiries_id = #db.param(inquiries_id)# and site_id = #db.param(request.zos.globals.id)#
        </cfsavecontent><cfscript>qinquiry=db.execute("qinquiry");</cfscript>
        <cfset form.groupEmail=true>
        <cfscript>
        email = qMember.member_email;
        //email = '#request.zos.developerEmailTo#';
        </cfscript>
        <cfmail  to="#email#" from="#request.fromemail#" subject="One of your leads have been updated by the client." type="html">
			<cfscript>
			iemailCom=createobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
			iemailCom.getEmailTemplate();
			</cfscript>
        </cfmail>
        <cfscript>
        request.zsid = application.zcore.status.setStatus(Request.zsid, "Inquiry grouped and the agent has been notified.");
        application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
        </cfscript>
    </cffunction> --->
    
    <cffunction name="assign" localmode="modern" access="remote" roles="member">
    	<cfscript>
		var qGetInquiry=0;
		var qFeedback=0;
		var qInquiry=0;
		var toEmail=0;
		var iEmailCom=0;
		var qMember=0;
		var db=request.zos.queryObject;
		form.zPageId=application.zcore.functions.zso(form, 'zPageId');
		</cfscript>
		<cfif application.zcore.functions.zso(form, 'user_id') EQ '' and application.zcore.functions.zso(form, 'assign_email') EQ ''>
            <cfscript>
            application.zcore.status.setStatus(request.zsid,"You forgot to type an email address or select a user from the drop down menu.",form,true);
            application.zcore.functions.zRedirect("/z/inquiries/admin/assign/select?inquiries_id=#form.inquiries_id#&zPageId=#form.zPageId#&zsid="&request.zsid);
            </cfscript>
        </cfif>
        <cfscript>
		local.assignUserId=form.user_id;
		</cfscript>
        <cfif application.zcore.functions.zso(form, 'assign_email') NEQ ''>
            <cfscript>
            if(application.zcore.functions.zEmailValidate(form.assign_email) EQ false){
                application.zcore.status.setStatus(request.zsid,"Invalid email address format: #form.assign_email#",form,true);
                application.zcore.functions.zRedirect("/z/inquiries/admin/assign/select?inquiries_id=#form.inquiries_id#&zPageId=#form.zPageId#&zsid=#request.zsid#");	
            }
            request.noleadsystemlinks=true;
	db.sql="SELECT inquiries_email from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	WHERE inquiries_id = #db.param(form.inquiries_id)#  and 
	site_id = #db.param(request.zos.globals.id)# ";
	qGetInquiry=db.execute("qGetInquiry");
	db.sql="SELECT count(inquiries_feedback_id) count 
	from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback 
	WHERE inquiries_id = #db.param(form.inquiries_id)#  and 
	site_id = #db.param(request.zos.globals.id)#";
	qFeedback=db.execute("qFeedback");
	</cfscript>
	<cfsavecontent variable="db.sql">
            UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	 SET inquiries_assign_email = #db.param(form.assign_email)#,  
	 <cfif isDefined('form.assign_name') and form.assign_name neq ''>inquiries_assign_name=#db.param(form.assign_name)#,</cfif>  
	 user_id = #db.param("")#, 
	 inquiries_admin_comments = #db.param(form.inquiries_admin_comments)#, 
	 <cfif qFeedback.count NEQ 0>inquiries_status_id = #db.param(3)#<cfelse>inquiries_status_id = #db.param(2)#</cfif> 
	 WHERE inquiries_id = #db.param(form.inquiries_id)# 
            </cfsavecontent><cfscript>qInquiry=db.execute("qInquiry");</cfscript>
            <cfset form.groupEmail=false>
            <cfscript>
            toEmail=form.assign_email;
			
            </cfscript>
            
            <cfmail  to="#toEmail#" from="#request.fromemail#" replyto="#qGetInquiry.inquiries_email#" subject="A new lead assigned to you" type="html">
                <cfscript>
		iemailCom=createobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
                iemailCom.getEmailTemplate();
                </cfscript>
            </cfmail>
            <cfscript>
            request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead assigned to #form.assign_email#, An email has been sent to notify them.");
            /*if(inquiries_reservation EQ 1){
                application.zcore.functions.zRedirect("/member/reservations.cfm?zPageId=#form.zPageId#&zsid="&request.zsid);
            }else{*/
                application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
            //}
            </cfscript>
        <cfelse>
            <cfsavecontent variable="db.sql">
            SELECT inquiries_email from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
 WHERE inquiries_id = #db.param(form.inquiries_id)#  and site_id = #db.param(request.zos.globals.id)# 
            </cfsavecontent><cfscript>qGetInquiry=db.execute("qGetInquiry");</cfscript> 
            <cfsavecontent variable="db.sql">
            SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user
 WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and user_id = #db.param(local.assignUserId)# 
            </cfsavecontent><cfscript>qMember=db.execute("qMember");</cfscript>
            <cfsavecontent variable="db.sql">
            SELECT count(inquiries_feedback_id) count 
	    from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback 
	    WHERE inquiries_id = #db.param(form.inquiries_id)#  and 
	    site_id = #db.param(request.zos.globals.id)# 
            </cfsavecontent><cfscript>qFeedback=db.execute("qFeedback");
            if(qMember.recordcount EQ 0){
                request.zsid = application.zcore.status.setStatus(Request.zsid, "Agent doesn't exist.",form,true);
                application.zcore.functions.zRedirect("/z/inquiries/admin/assign/select?inquiries_id=#inquiries_id#&zPageId=#form.zPageId#&zsid="&request.zsid);
            }
            form.inquiries_admin_comments = trim(application.zcore.functions.zso(form, 'inquiries_admin_comments'));
            </cfscript>
            <cfsavecontent variable="db.sql">
            UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	 SET inquiries_assign_email = #db.param("")#, 
	 user_id = #db.param(qMember.user_id)#, 
	 inquiries_admin_comments = #db.param(form.inquiries_admin_comments)#, 
	 <cfif qFeedback.count NEQ 0>inquiries_status_id = #db.param(3)#<cfelse>inquiries_status_id = #db.param(2)#</cfif> 
	 WHERE inquiries_id = #db.param(form.inquiries_id)#  and
	 site_id = #db.param(request.zos.globals.id)# 
            </cfsavecontent><cfscript>qInquiry=db.execute("qInquiry");</cfscript> 
            <cfset form.groupEmail=false>
            <cfscript>
            toEmail=qMember.member_email;
            </cfscript>
            <cfmail  to="#toEmail#" from="#request.fromemail#" replyto="#qGetInquiry.inquiries_email#" subject="A new lead assigned to you" type="html">
                <cfscript>
				iemailCom=createobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
                iemailCom.getEmailTemplate();
                </cfscript>
            </cfmail>
            <cfscript>
            request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead assigned to #qMember.member_first_name# #qMember.member_last_name#, An email has been sent to this agent to notify them.");
            /*if(inquiries_reservation EQ 1){
                application.zcore.functions.zRedirect("/member/reservations.cfm?zPageId=#form.zPageId#&zsid="&request.zsid);
            }else{*/
                application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
            //}
            </cfscript>
        </cfif>
    </cffunction>
    </cfoutput>
</cfcomponent>