<cfcomponent>
<cfoutput>
<!--- <!--- application.zcore.functions.zVerifyRecaptcha() --->
<cffunction name="zVerifyRecaptcha" localmode="modern" output="no" returntype="boolean">
	<cfscript>
	var cfhttp=0;
	</cfscript>
	<cfif application.zcore.functions.zso(form, 'recaptcha_response_field') EQ "">
        <cfreturn false>
    </cfif>
    <!--- 
recaptcha key was for this global domain:
This is a global key. It will work across all domains. --->
        <cfhttp url="https://www.google.com/recaptcha/api/verify" method="post" timeout="10">
        <cfhttpparam type="formfield" name="privatekey" value="#request.zos.recaptchaPrivateKey#">
        <cfhttpparam type="formfield" name="challenge" value="#application.zcore.functions.zso(form, 'recaptcha_challenge_field')#">
        <cfhttpparam type="formfield" name="remoteip" value="#request.zos.cgi.remote_addr#">
        <cfhttpparam type="formfield" name="response" value="#application.zcore.functions.zso(form, 'recaptcha_response_field')#">
        </cfhttp>
        <cfif structkeyexists(CFHTTP,'statuscode') and left(CFHTTP.statusCode,3) EQ '200' and (isBinary(cfhttp.FileContent) or trim(CFHTTP.FileContent) NEQ "CFMXConnectionFailure" and trim(CFHTTP.FileContent) NEQ "Connection Failure")>
            <cfif left(trim(CFHTTP.FileContent),4) EQ "true">
                <cfreturn true>
            </cfif>
        </cfif>
    <cftry>
    <cfcatch type="any"></cfcatch>
    </cftry>
    <cfreturn false>
</cffunction>


<cffunction name="zCheckFormHashValue" localmode="modern" output="no" returntype="string">
    <cfargument name="hashValue" type="string" required="yes">
    <cfscript>
    if(structkeyexists(request.zsession,'formHashUniqueStruct') EQ false or structkeyexists(request.zsession.formHashUniqueStruct, arguments.hashValue) EQ false){
        return false;
    }else{
        structdelete(request.zsession.formHashUniqueStruct, arguments.hashValue);
        return true;
    }
    </cfscript>
</cffunction>
<cffunction name="zGetFormHashValue" localmode="modern" output="no" returntype="string">
    <cfscript>
    var hashValue=hash(randrange(13101231,1201230120)&request.zos.mysqlnow,'sha-256');
    if(isDefined('request.zsession') EQ false or structkeyexists(request.zsession,'formHashUniqueStruct') EQ false){
        request.zsession.formHashUniqueStruct=structnew();
    }
    request.zsession.formHashUniqueStruct[hashValue]=true;
    return hashValue;
    </cfscript>
</cffunction>

<!--- #application.zcore.functions.zDisplayRecaptcha()# --->
<cffunction name="zDisplayRecaptcha" localmode="modern" output="yes" returntype="any">
	<cfscript>
	var theC=0;
    </cfscript>
	<cfsavecontent variable="theC"><script type="text/javascript">
	var RecaptchaOptions = {   theme : 'white' };
	</script><script type="text/javascript" src="https://www.google.com/recaptcha/api/challenge?k=6Letq9QSAAAAAN524uNL0_hQLk1Ws2YTcvOQZAw5"></script>
    <noscript>
     <iframe src="https://www.google.com/recaptcha/api/noscript?k=6Letq9QSAAAAAN524uNL0_hQLk1Ws2YTcvOQZAw5"
         height="300" width="500" style="border:none;"></iframe><br />
     <textarea name="recaptcha_challenge_field" rows="3" cols="40"></textarea>
     <input type="hidden" name="recaptcha_response_field" value="manual_challenge" />
    </noscript></cfsavecontent>
    <cfreturn theC>
</cffunction>

<!--- application.zcore.functions.zOutputToolTip(); --->
<cffunction name="zOutputToolTip" localmode="modern" returntype="any" output="no">
	<cfargument name="label" type="string" required="yes">
	<cfargument name="helpHTML" type="string" required="yes">
	<cfscript>
	if(structkeyexists(request.zos.tempObj,"zOutputHelpToolTipIndex") EQ false){
		request.zos.tempObj.zOutputHelpToolTipIndex=0;
		application.zcore.functions.zIncludeZOSFORMS();
		application.zcore.template.prependtag("content",'<div id="zHelpToolTipDiv"><div id="zHelpToolTipInnerDiv"></div></div>');
		application.zcore.template.appendTag("meta",'<script type="text/javascript">/* <![CDATA[ */ zArrDeferredFunctions.push(function(){zHelpTooltip.setupHelpTooltip();}); /* ]]> */</script>');
	} 
	request.zos.tempObj.zOutputHelpToolTipIndex++;
	return '<span class="zHelpToolTipContainer"><span class="zHelpToolTipLabel">'&arguments.label&'</span> <span title="'&htmleditformat(arguments.helpHTML)&'" id="zHelpToolTip'&request.zos.tempObj.zOutputHelpToolTipIndex&'" class="zHelpToolTip"></span></span>';
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zOutputHelpToolTip(helpId); --->
<cffunction name="zOutputHelpToolTip" localmode="modern" returntype="any" output="no">
	<cfargument name="defaultLabel" type="string" required="yes">
	<cfargument name="helpId" type="string" required="yes">
    <cfscript>
	var dbclick='';
	var a2=0;
	var qid=0;
	var defaultLabel=0;
	var db=request.zos.queryObject;
	var qid2=0;
	var ts=structnew();
	if(structkeyexists(application.zcore,'helpStruct') and structkeyexists(application.zcore.helpStruct.tooltip, arguments.helpId)){
		if(structkeyexists(request.zos.tempObj,"zOutputHelpToolTipIndex") EQ false){
			request.zos.tempObj.zOutputHelpToolTipIndex=0;
			application.zcore.functions.zIncludeZOSFORMS();
			application.zcore.template.prependtag("content",'<div id="zHelpToolTipDiv"><div id="zHelpToolTipInnerDiv"></div></div>');
			application.zcore.template.appendTag("meta",'<script type="text/javascript">/* <![CDATA[ */zArrDeferredFunctions.push(function(){zHelpTooltip.setupHelpTooltip();}); /* ]]> */</script>');
		}
		request.zos.tempObj.zOutputHelpToolTipIndex++;
		if(application.zcore.helpStruct.tooltip[arguments.helpId].html EQ ""){
			return '<span class="zHelpToolTipContainer"><span class="zHelpToolTipLabel">'&application.zcore.helpStruct.tooltip[arguments.helpId].label&'</span> </span>';
		}else{
			return '<span class="zHelpToolTipContainer"><span class="zHelpToolTipLabel">'&application.zcore.helpStruct.tooltip[arguments.helpId].label&'</span> <span title="'&htmleditformat(application.zcore.helpStruct.tooltip[arguments.helpId].html)&'" id="zHelpToolTip'&request.zos.tempObj.zOutputHelpToolTipIndex&'" class="zHelpToolTip"></span></span>';
		}
	}else{
		return defaultLabel;
	}
	</cfscript>
</cffunction> --->



<!---
FUNCTION
	zInputSelectBox(ss);
DESCRIPTION
	This function generates a selectBox. 
	name and (queryLabel or listLabels) are required.
USAGE
	ts = StructNew();
	ts.name = "name";
	ts.label="Name: ";
	ts.labelStyle="";
	ts.size = 1; // more for multiple select
	ts.multiple = false; // allow multiple selections (hold CTRL)
	ts.enumerate = 1; // for editing multiple records
	ts.output = true; // set to false to save to variable
	ts.style = "normal"; // stylesheet class
	ts.inlineStyle="";
	ts.hideSelect = true; // hide first element
	ts.selectLabel = "Any"; // override default first element text
	ts.selectedValues = "value1"; // send list if there are multiple values.
	ts.selectedDelimiter = ","; // change if comma conflicts...
	ts.required=false;
	ts.friendlyName="";
	ts.onChange = "zFunction();";
	ts.defaultValue = "value1";
	ts.dollarFormatLabels = true;
	// options for query data
	ts.query = qQuery;
	ts.queryLabelField = "table_label";
	ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
	ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
	ts.queryValueField = "table_value";
	// options for list data
	ts.listLabels = "value1,value2,value3";
	ts.listValues = "1,2,3";
	ts.listLabelsDelimiter = chr(9); // tab delimiter
	ts.listValuesDelimiter = chr(9);
	
	zInputSelectBox(ts);
 --->
<cffunction name="select" localmode="modern" returntype="any" output="true">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var selectedValues = "";
	var selectBox = "";
	var ds=0;
	var noData = true;
	var i = 0;
	var isSelected=false;
	var v2=0;
	var v=0;
	var ts =StructNew();	
	var arrLabel=arraynew(1);
	var arrValue=arraynew(1);
	application.zcore.functions.zIncludeZOSFORMS();
	// set defaults
	ts.size = 1;
	ts.label="";
	ts.friendlyName="";
	ts.onchange="";
	ts.disableAjaxFieldData=false;
	ts.multiple = false;
	ts.enumerate = "";
	ts.inlineStyle="";
	ts.labelStyle="";
	ts.output = true;
	ts.required=false;
	ts.notranslate=false;
	ts.queryParseLabelVars = false;
	ts.queryParseValueVars = false;
	ts.listLabelsDelimiter = ","; // tab delimiter
	ts.listValuesDelimiter = ",";
	ts.selectedDelimiter=",";
	ts.dollarFormatLabels = false;
	// override defaults
	StructAppend(arguments.ss, ts, false);
	</cfscript>
	<cfif isDefined('arguments.ss.name') EQ false>
		<cfthrow type="exception" message="zInputSelectBox: Requires a name">
	</cfif>
	<cfsavecontent variable="selectBox">
	
	<cfscript>
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ "" and arguments.ss.disableAjaxFieldData EQ false){
		ds=structNew();
		ds.required=arguments.ss.required;
		
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		arguments.ss.onchange&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[ */');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="select";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	if(structkeyexists(arguments.ss,'selectedValues') and arguments.ss.selectedValues NEQ ""){
		selectedValues = arguments.ss.selectedValues;
	}else if(structkeyexists(form, arguments.ss.name)){
		selectedValues = form[arguments.ss.name];
	}else if(structkeyexists(arguments.ss,'defaultValue')){
		selectedValues = arguments.ss.defaultValue;
	}else{
		selectedValues = "";
	} 
	if(structkeyexists(arguments.ss,'listValues')){
		arrValue=listtoarray(arguments.ss.listValues,arguments.ss.listValuesDelimiter,true);
	}
	if(structkeyexists(arguments.ss,'listLabels')){
		arrLabel=listtoarray(arguments.ss.listLabels,arguments.ss.listLabelsDelimiter,true);
	}else{
		arrLabel=arrValue;	
	}
	</cfscript>
    <cfif arguments.ss.label NEQ ""><label for="#arguments.ss.name##arguments.ss.enumerate#" style="#arguments.ss.labelStyle#">#arguments.ss.label#</label> </cfif>
	<select <cfif arguments.ss.onChange NEQ "">onchange="#arguments.ss.onChange#"</cfif> <cfif structkeyexists(arguments.ss,'style')>class="#arguments.ss.style#"</cfif> <cfif arguments.ss.inlineStyle NEQ "">style="#arguments.ss.inlineStyle#"</cfif> name="#arguments.ss.name##arguments.ss.enumerate#" id="#arguments.ss.name##arguments.ss.enumerate#" size="#arguments.ss.size#" <cfif arguments.ss.multiple>multiple="multiple"><cfelse>><cfif structkeyexists(arguments.ss,'hideSelect') EQ false><option value=""><cfif structkeyexists(arguments.ss,'selectLabel')>#htmleditformat(arguments.ss.selectLabel)#<cfelse>-- Select --</cfif></option></cfif></cfif>
	
	<!--- list data --->	
	<cfif structkeyexists(arguments.ss, 'listValues')>
		<cfloop from="1" to="#arraylen(arrValue)#" index="i">
			<option value="#htmleditformat(arrValue[i])#" <cfif arguments.ss.notranslate>class="notranslate"</cfif> <cfif selectedValues EQ arrValue[i] or (selectedValues NEQ "" and listFind(selectedValues, arrValue[i], arguments.ss.selectedDelimiter) NEQ 0)>selected="selected"</cfif>><cfif structkeyexists(arguments.ss, 'listLabels')><cfif arguments.ss.dollarFormatLabels and isNumeric(arrLabel[i])>$#NumberFormat(arrLabel[i])#<cfelse>#replace(htmleditformat(arrLabel[i]),"&amp;##","&##","all")#</cfif><cfelse><cfif arguments.ss.dollarFormatLabels and isNumeric(arrValue[i])>$#NumberFormat(arrValue[i])#<cfelse>#replace(htmleditformat(arrValue[i]),"&amp;##","&##","all")#</cfif></cfif></option>			
		</cfloop>		
		<cfset noData = false>
	</cfif>
	
	<!--- query data --->
	<cfif structkeyexists(arguments.ss, 'query') and structkeyexists(arguments.ss,'queryLabelField') and structkeyexists(arguments.ss,'queryValueField')>
		<cfloop query="arguments.ss.query">
        	<cfscript>
			if(structkeyexists(arguments.ss,'queryValueField')){
				if(arguments.ss.queryParseValueVars){
					v=htmleditformat(application.zcore.functions.zParseVariables(arguments.ss.queryValueField, false, arguments.ss.query));
				}else{
					v=htmleditformat(arguments.ss.query[arguments.ss.queryValueField]);
				}
			}else{
				v=htmleditformat(arguments.ss.query[arguments.ss.queryLabelField]);
			}
			if(structkeyexists(arguments.ss,'queryLabelField')){
				if(arguments.ss.dollarFormatLabels and isNumeric(arguments.ss.query[arguments.ss.queryLabelField])){
					v2="$"&NumberFormat(arguments.ss.query[arguments.ss.queryLabelField]);
				}else{
					if(arguments.ss.queryParseLabelVars){
						v2=htmleditformat(application.zcore.functions.zParseVariables(arguments.ss.queryLabelField, false, arguments.ss.query));
					}else{
						v2=replace(htmleditformat(arguments.ss.query[arguments.ss.queryLabelField]),"&amp;##","&##","all")
					}
				}
			}else{
				if(arguments.ss.dollarFormatLabels and isNumeric(arguments.ss.query[arguments.ss.queryValueField])){
					v2="$"&NumberFormat(arguments.ss.query[arguments.ss.queryValueField]);
				}else{
					v2=replace(htmleditformat(arguments.ss.queryValueField),"&amp;##","&##","all");
				}
			}
			isSelected=false;
			if(arguments.ss.queryParseValueVars){
				if(selectedValues NEQ "" and listFind(selectedValues, application.zcore.functions.zParseVariables(arguments.ss.queryValueField, false, arguments.ss.query), arguments.ss.selectedDelimiter) NEQ 0){
					isSelected=true;
				}
			}else if(selectedValues NEQ "" and listFind(selectedValues, arguments.ss.query[arguments.ss.queryValueField], arguments.ss.selectedDelimiter) NEQ 0){
				isSelected=true;
			}
			</cfscript>
        	<option value="#v#" <cfif arguments.ss.notranslate>class="notranslate"</cfif> <cfif isSelected>selected="selected"</cfif>>#v2#</option>
        </cfloop>
		<cfset noData = false>
	</cfif>
	
	
	<!--- no data, throw error --->	
	<cfif noData>
		<cfthrow type="exception" message="zSelectBox: arguments.ss.listLabels or (arguments.ss.query and arguments.ss.queryValueField) are required.">
	</cfif>
		
	</select>
	</cfsavecontent>
    <cfscript>
	if(arguments.ss.output){
		writeoutput(selectBox);
	}
	</cfscript>
	<cfreturn selectBox>
</cffunction>


<cffunction name="ssn" localmode="modern" output="false" returntype="any">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="formName" type="string" required="yes">
	<cfscript>
	var output="";
	var ssn1='';
	var ssn2='';
	var ssn3='';
	application.zcore.functions.zIncludeZOSFORMS();
	if(structkeyexists(form, fieldName)){
		ssn1=left(form[arguments.fieldName],3);
		ssn2=mid(form[arguments.fieldName],3,2);
		ssn3=right(form[arguments.fieldName],4);
	}
	if(structkeyexists(form, arguments.fieldName&'_ssn1')){
		ssn1=form[arguments.fieldName&'_ssn1'];
	}
	if(structkeyexists(form, arguments.fieldName&'_ssn2')){
		ssn2=form[arguments.fieldName&'_ssn2'];
	}
	if(structkeyexists(form, arguments.fieldName&'_ssn3')){
		ssn3=form[arguments.fieldName&'_ssn3'];
	}
	</cfscript>
	<cfsavecontent variable="output">
	<script type="text/javascript">
	/* <![CDATA[ */
	function #fieldName#_checkSSN(fieldNum){
		if(fieldNum==1){
			if(document.#arguments.formName#.#fieldName#_ssn1.value.length==3){
				document.#arguments.formName#.#fieldName#_ssn2.focus();
			}
		}else if(fieldNum==2){
			if(document.#arguments.formName#.#fieldName#_ssn2.value.length==2){
				document.#arguments.formName#.#fieldName#_ssn3.focus();
			}
		}
	}
	/* ]]> */
	</script>
	<input type="text" name="#fieldName#_ssn1" id="#fieldName#_ssn1" value="#htmleditformat(ssn1)#" size="3" maxlength="3" onkeyup="#fieldName#_checkSSN(1);" />-<input type="text" name="#fieldName#_ssn2" id="#fieldName#_ssn2" value="#htmleditformat(ssn2)#" onkeyup="#fieldName#_checkSSN(2);" size="2" maxlength="2"/>-<input type="text" name="#fieldName#_ssn3" id="#fieldName#_ssn3" value="#htmleditformat(ssn3)#" onkeyup="#fieldName#_checkSSN(2);" size="4" maxlength="4" />
	</cfsavecontent>
	<cfreturn output>
</cffunction>

<cffunction name="image" localmode="modern" returntype="any" output="false">
	<cfargument name="field" type="string" required="yes">
	<cfargument name="abspath" type="string" required="yes">
	<cfargument name="path" type="string" required="yes">
	<cfargument name="maxwidth" type="numeric" required="no" default="#0#">
	<cfscript>
	var output='';
	var currentWidth='';
	var currentHeight='';
	var tempImage="";
	var tempText="";
	application.zcore.functions.zIncludeZOSFORMS();
	</cfscript>
	<cfsavecontent variable="tempText">
	<cfif structkeyexists(form, arguments.field) and form[arguments.field] NEQ '' and fileexists(arguments.abspath&form[arguments.field])>
		<cfif arguments.maxwidth NEQ 0>
            <Cfscript>
		local.imageSize=application.zcore.functions.zGetImageSize(arguments.abspath&form[arguments.field]);    
            arguments.maxwidth=min(local.imageSize.width,arguments.maxwidth);
            </Cfscript>
        </cfif>
        <img src="#arguments.path##form[arguments.field]#" alt="Uploaded Image" <cfif arguments.maxwidth NEQ 0>width="#arguments.maxwidth#"</cfif> /><br />
		<input type="checkbox" name="#arguments.field#_delete" value="1" style="background:none; border:none;height:15px; " /> Check to delete image and then submit form.<br />
	</cfif>	
	<input type="file" name="#arguments.field#" />	
	</cfsavecontent>
	<cfscript>
	return tempText;
	</cfscript>
</cffunction>



<!--- FUNCTION: zInput_Boolean(fieldName); --->
<cffunction name="boolean" localmode="modern" returntype="any" output="false">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	var yes = '<input name="#arguments.fieldName#" id="#arguments.fieldName#1" style="border:none; background:none;" type="radio" value="1"';
	var no = '<input name="#arguments.fieldName#" id="#arguments.fieldName#0" style="border:none; background:none;" type="radio" value="0"';
	application.zcore.functions.zIncludeZOSFORMS();
	if(structkeyexists(form, arguments.fieldName) and form[arguments.fieldName] NEQ "" and form[arguments.fieldName]){
		yes = yes&' checked';
	}else{
		no = no&' checked';
	}
	yes=yes&' /> Yes ';
	no=no&' /> No ';
	return yes&no;
	</cfscript>
</cffunction>





<!--- 
<cfscript>
ts = StructNew();
ts.name = "field_name";
ts.friendlyName="";
ts.labelList = "";
ts.valueList = "";
ts.defaultValue = "";
ts.style = "";
ts.className = "";
ts.required=false;
ts.statusbar = "";
ts.onclick="";
writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
</cfscript>
 --->
<cffunction name="radio" localmode="modern" returntype="any" output="true">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ds=0;
	var ts = StructNew();
	var label = "";
	var i = "";
	var output = '';
	var selected = "";
	application.zcore.functions.zIncludeZOSFORMS();
	ts.friendlyName="";
	ts.labelList = "";
	ts.style = "";
	ts.defaultValue = "";
	ts.className = "";
	ts.statusbar = "";
	ts.onclick="";
	ts.required=false;
	StructAppend(arguments.ss, ts, false);
	</cfscript>
	<cfif isDefined('arguments.ss.name') EQ false>
		<cfthrow type="exception" message="Error: FUNCTION: zInput_RadioGroup: arguments.ss.name is required.">
	</cfif>
	<cfif isDefined('arguments.ss.valueList') EQ false>
		<cfthrow type="exception" message="Error: FUNCTION: zInput_RadioGroup: arguments.ss.valueList is required.">
	</cfif>
	<cfif len(arguments.ss.labelList) NEQ 0 and listLen(arguments.ss.labelList) NEQ listLen(arguments.ss.valueList)>
		<cfthrow type="exception" message="Error: FUNCTION: zInput_RadioGroup: arguments.ss.valueList list length is not the same as arguments.ss.labelList.">
	</cfif>
	<cfif len(arguments.ss.statusbar) NEQ 0 and listLen(arguments.ss.statusbar) NEQ listLen(arguments.ss.valueList)>
		<cfthrow type="exception" message="Error: FUNCTION: zInput_RadioGroup: arguments.ss.valueList list length is not the same as arguments.ss.statusbar.">
	</cfif>
	<cfscript>
	if(structkeyexists(form, arguments.ss.name)){
		selected = form[arguments.ss.name];
	/*}else if(isDefined(arguments.ss.name)){
		selected = evaluate(arguments.ss.name);*/
	}else{
		selected = arguments.ss.defaultValue;
	}
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		arguments.ss.onclick&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[ */');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="radio";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	label = "";
	for(i=1;i LTE listlen(arguments.ss.valueList);i=i+1){
		if(len(arguments.ss.labelList) NEQ 0){
			label = listGetAt(arguments.ss.labelList, i);			
		}
		output = output&'<input ';
		if(len(arguments.ss.statusbar) NEQ 0){
			output = output&'onmouseover="window.status = ''#listGetAt(arguments.ss.statusbar,i)#'';" onmouseout="window.status = '''';" title="#listGetAt(arguments.ss.statusbar,i)#" ';
		}
		output = output&' type="radio" name="#arguments.ss.name#" id="#arguments.ss.name#" value="#htmleditformat(listGetAt(arguments.ss.valueList,i))#"';
		if(arguments.ss.style NEQ ''){
			output = output&' style="#arguments.ss.style#"';
		}
		if(arguments.ss.className NEQ ''){
			output = output&' class="#arguments.ss.className#"';
		}
		if(arguments.ss.onclick NEQ ""){
			output&=' onclick="#arguments.ss.onclick#"';
		}
		if(selected EQ listGetAt(arguments.ss.valueList,i)){
			output = output&' checked="checked" /> ';
		}else{
			output = output&' /> ';
		}
		output = output&label&" ";
	}
	if(arguments.ss.style NEQ ''){
		output = output&'</span>';
	}
	writeoutput(output);
	</cfscript>
	
</cffunction>


<!--- 
<cfscript>
ts = StructNew();
ts.name = "field_name";
ts.friendlyName="";
// options for query data
ts.query = qQuery;
ts.queryLabelField = "table_label";
ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
ts.queryParseStatusVars = false;
ts.queryValueField = "table_value";
// options for list data
ts.listLabels = "value1|value2|value3";
ts.listValues = "1|2|3";
ts.listLabelsDelimiter = "|"; // tab delimiter
ts.listValuesDelimiter = "|";
ts.listStatusDelimiter = "|";
ts.defaultValue = "";
ts.style = "";
ts.separate=" ";
ts.className = "";
ts.required=false;
ts.onclick="";
ts.onchange="";
writeoutput(application.zcore.functions.zInput_Checkbox(ts));
</cfscript>
 --->
<cffunction name="checkbox" localmode="modern" returntype="any" output="true">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ds=0;
	var arrSelected2='';
	var arrV2='';
	var curChecked='';
	var ts = StructNew();
	var rs = StructNew();
	var arrV=arraynew(1);
	var arrL=0;
	var arrS=0;
	var i = "";
	var i2=0;
	var n=0;
	var curSt=0;
	var curV=0;
	var curL=0;
	var arrLOut=arraynew(1);
	var ex="";
	var output = '';
	var arrSelected=[];
	var zExpOptionValue=0;
	var selected = "";
	local.tempRS=application.zcore.functions.zFormJSNewZValue(1);
	zExpOptionValue=local.tempRS.zValue;
	application.zcore.functions.zIncludeZOSFORMS();
	ts.friendlyName="";
	ts.radio=false;
	ts.labelList = "";// options for query data
	ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
	ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
	ts.queryParseStatusVars = false;
	ts.listSelectedDelimiter=",";
	ts.listLabelsDelimiter = chr(9); // tab delimiter
	ts.listValuesDelimiter = chr(9);
	ts.listStatusDelimiter = chr(9);
	ts.disableExpOptionValue=false;
	ts.style = "";
	ts.separator="<br />";
	ts.defaultValue = "";
	ts.className = "";
	ts.output=true;
	ts.onchange="";
	ts.onclick="";
	ts.required=false;
	StructAppend(arguments.ss, ts, false);
	</cfscript>
	<cfif isDefined('arguments.ss.name') EQ false>
		<cfthrow type="exception" message="Error: FUNCTION: zInput_Checkbox: arguments.ss.name is required.">
	</cfif>
	<cfscript>
	if(structkeyexists(form, arguments.ss.name)){
		selected = form[arguments.ss.name];
	}else{
		selected = arguments.ss.defaultValue;
	}
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		arguments.ss.onclick&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[*/');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="text";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	if(structkeyexists(arguments.ss,'listValues')){
		arrV=listtoarray(arguments.ss.listValues, arguments.ss.listValuesDelimiter,true);
		if(structkeyexists(arguments.ss,'listLabels')){
			arrL=listtoarray(arguments.ss.listLabels, arguments.ss.listLabelsDelimiter,true);
		}else{
			arrL=arrV;
		}
	}
	if(arguments.ss.disableExpOptionValue){
		ex=-1;	
	}else{
		ex=zExpOptionValue;
	}
	arrSelected2=listtoarray(selected,arguments.ss.listSelectedDelimiter,true);
	arguments.ss.onclick="zCheckboxOnChange(this,#ex#);"&arguments.ss.onclick;
	</cfscript>
    <cfsavecontent variable="output">
    #local.tempRS.output#
    <cfif structkeyexists(arguments.ss,'listValues')>
    <cfloop from="1" to="#arraylen(arrV)#" index="i">
    <cfscript>
	curL=arrL[i];
	arrV2=listtoarray(arrV[i],arguments.ss.listSelectedDelimiter,true);
	curChecked=false;
	for(i2=1;i2 LTE arraylen(arrV2);i2++){
		for(n=1;n LTE arraylen(arrSelected2);n++){
			if(compare(arrV2[i2],arrSelected2[n]) EQ 0){
				curChecked=true;
				arrayappend(arrSelected, arrSelected2[n]);
			}
		}
	}
	</cfscript>
    <input type="<cfif arguments.ss.radio>radio<cfelse>checkbox</cfif>" name="#arguments.ss.name#_name" id="#arguments.ss.name#_name#i#" value="#htmleditformat(arrV[i])#"  style="border:none;background:none;<cfif arguments.ss.style NEQ ''>#arguments.ss.style#</cfif> " <cfif arguments.ss.className NEQ ''>class="#arguments.ss.className#"</cfif> <cfif arguments.ss.onclick NEQ ""> onclick="#arguments.ss.onclick#" </cfif> <cfif curChecked><cfset arrayappend(arrLOut, curL)>checked="checked"</cfif> /> <label style="cursor:pointer;" for="#arguments.ss.name#_name#i#" id="#arguments.ss.name#_namelabel#i#">#htmleditformat(curL)#</label>#arguments.ss.separator#
    </cfloop>
    </cfif>
    
	<!--- query data --->
	<cfif structkeyexists(arguments.ss,'query') and structkeyexists(arguments.ss,'queryLabelField')>
		<cfloop query="arguments.ss.query">
			<cfscript>
            if(structkeyexists(arguments.ss,'queryValueField')){
                if(arguments.ss.queryParseValueVars){
                    curV=application.zcore.functions.zParseVariables(arguments.ss.queryValueField, false, arguments.ss.query);
                }else{
                    curV=arguments.ss.query[arguments.ss.queryValueField];
                }
            }else{
                curV=arguments.ss.query[arguments.ss.queryLabelField];
            }
            if(arguments.ss.queryParseLabelVars){
                curL=application.zcore.functions.zParseVariables(arguments.ss.queryLabelField, false, arguments.ss.query);
            }else{
                curL=arguments.ss.query[arguments.ss.queryLabelField];
            }
			curChecked=false;
			if(find(","&curV&",",","&selected&",") NEQ 0){
				curChecked=true;
				arrayappend(arrSelected, curV);
			}
            </cfscript>
    <input  
    type="<cfif arguments.ss.radio>radio<cfelse>checkbox</cfif>" name="#arguments.ss.name#_name" id="#arguments.ss.name#_name#arguments.ss.query.currentrow+arrayLen(arrV)#" value="#curV#"  
    style="border:none;background:none;height:15px;<cfif arguments.ss.style NEQ ''>#arguments.ss.style#</cfif> " <cfif arguments.ss.className NEQ ''>class="#arguments.ss.className#"</cfif> <cfif arguments.ss.onclick NEQ ""> onclick="#arguments.ss.onclick#" </cfif> <cfif curChecked><cfset arrayappend(arrLOut, curL)>checked="checked"</cfif> /> <label style="cursor:pointer;" for="#arguments.ss.name#_name#arguments.ss.query.currentrow+arrayLen(arrV)#" id="#arguments.ss.name#_namelabel#arguments.ss.query.currentrow+arrayLen(arrV)#">#htmleditformat(curL)#</label>#arguments.ss.separator#
		</cfloop>
        </cfif>
    <input type="hidden" name="#arguments.ss.name#" id="#arguments.ss.name#" onchange="#arguments.ss.onchange#" value="#htmleditformat(arraytolist(arrSelected, ','))#" />
        </cfsavecontent>
    <cfscript>
	if(arguments.ss.output){
		writeoutput(output);
	}else{
		rs.output=output;
		rs.zExpOptionValue=zExpOptionValue;
		rs.value="<br />"&arraytolist(arrLOut,"<br />");
		return rs;	
	}
	</cfscript>
	
</cffunction>


<cffunction name="submit" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	arguments.ss.type='submit';
	this.button(arguments.ss);
	</cfscript>
</cffunction>

<!--- 
ts=StructNew();
// required
ts.name="formSubmit";
// optional
ts.useAnchorTag=false; // set to true to use <a> instead of <input> so we can do :hover css
ts.useAnchorTagFormName=""; // required if not using zForm system and using useAnchorTag=true. Form name is needed so that the submit() function can be called onclick()
ts.friendlyName="";
ts.style="";
ts.onclick="";
ts.className="";
zInput_submit(ts);
 --->
<cffunction name="button" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=StructNew();
	var out='<input type="submit"';
	application.zcore.functions.zIncludeZOSFORMS();
	ts.name="";
	ts.imageInput=false;
	ts.imageUrl="";
	ts.value="Submit";
	ts.useAnchorTag=false;
	ts.useAnchorTagFormName="";
	ts.style="";
	ts.className="";
	ts.friendlyName="";
	ts.onclick="";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.imageInput){
		out='<input type="image" src="#arguments.ss.imageUrl#"';
	}
	if(arguments.ss.useAnchorTag){
		if(application.zcore.functions.zso(request.zos, "zFormCurrentName") EQ "" and arguments.ss.useAnchorTagFormName EQ ""){
			application.zcore.template.fail("arguments.ss.useAnchorTagFormName is required if you're not using the zForm system and have set arguments.ss.useAnchorTag=true. Form name is needed so that the submit() function can be called in the onclick attribute.");	
		}
		out='<a href="##"';// #request.zos.zFormCurrentName#";
	}
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		writeoutput('<script type="text/javascript">/* <![CDATA[ */ zArrDeferredFunctions.push(function(){zFormData["#request.zos.zFormCurrentName#"].submitContainer="#arguments.ss.name#_container";});/* ]]> */</script>');
    }
	if(arguments.ss.name EQ ""){
		application.zcore.template.fail("arguments.ss.name is required.");
	}
	out&=' name="#arguments.ss.name#" id="#arguments.ss.name#"';
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	if(arguments.ss.useAnchorTag){
		if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
			out&=' onclick="#arguments.ss.onclick#document.#request.zos.zFormCurrentName#.submit(); return false;"';
		}else{
			out&=' onclick="#arguments.ss.onclick#document.#arguments.ss.useAnchorTagFormName#.submit(); return false;"';
		}
	}else if(arguments.ss.onclick NEQ ""){
		out&=' onclick="#arguments.ss.onclick# return false;"';
	}
	if(arguments.ss.className NEQ ""){
		out&=' class="#arguments.ss.className#"';
	}
	if(arguments.ss.style NEQ ""){
		out&=' style="#arguments.ss.style#"';
	}
	if(arguments.ss.value NEQ ""){
		if(arguments.ss.useAnchorTag){
			out&='>#arguments.ss.value#</a>';
		}else if(arguments.ss.imageInput){
			out&=' />';
		}else{
			out&=' value="#htmleditformat(arguments.ss.value)#" />';
		}
	}
	writeoutput(out);
	</cfscript>
</cffunction>




<!--- 
ts=StructNew();
ts.label="";
ts.name="";
ts.style="";
ts.className="";
ts.multiline=false;
ts.size=20;
ts.maxlength=0;
ts.allowNull=false;
ts.email=false;
ts.required=false;
ts.number=false;
ts.output=true;
ts.onchange="alert('neat');";
ts.defaultValue="";
zInput_Text(ts);
 --->
<cffunction name="text" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ds=0;
	var ts=StructNew();
	var labelStyles="";
	var out='<input type="text"';
	application.zcore.functions.zIncludeZOSFORMS();
	ts.label="";
	ts.name="";
	ts.friendlyName="";
	ts.style="";
	ts.labelStyle="";
	ts.labelClassName="";
	ts.size=20;
	ts.output=true;
	ts.maxlength=0;
	ts.defaultValue="";
	ts.multiline=false;
	ts.allowNull=false;
	ts.className="";
	ts.email=false;
	ts.required=false;
	ts.number=false;
	ts.onchange="";
	ts.onkeyup="";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.labelClassName NEQ ""){
		labelStyles&=' class="#arguments.ss.labelClassName#"';
	}
	if(arguments.ss.labelStyle NEQ ""){
		labelStyles&=' style="#arguments.ss.labelStyle#"';
	}
	if(arguments.ss.label NEQ ""){
		out='<label for="#arguments.ss.name#" #labelStyles#>#arguments.ss.label#</label> '&out;
	}
	if(arguments.ss.multiline){
		out="<textarea";	
	}
	if(arguments.ss.name EQ ""){
		application.zcore.template.fail("arguments.ss.name is required.");
	}
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	out&=' name="#arguments.ss.name#" id="#arguments.ss.name#"';
	if(arguments.ss.size NEQ 0){
		out&=' size="#arguments.ss.size#"';
	}
	if(arguments.ss.maxlength NEQ 0){
		out&=' maxlength="#arguments.ss.maxlength#"';
	}
	if(arguments.ss.className NEQ ""){
		out&=' class="#arguments.ss.className#"';
	}
	if(arguments.ss.style NEQ ""){
		out&=' style="#arguments.ss.style#"';
	}
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		ds.allowNull=arguments.ss.allowNull;
		ds.email=arguments.ss.email;
		ds.number=arguments.ss.number;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		local.tempJS="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arguments.ss.onkeyup&=local.tempJS;
		arguments.ss.onchange&=local.tempJS;
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[*/');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="text";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.allowNull=#arguments.ss.allowNull#;');
		writeoutput('ts.email=#arguments.ss.email#;');
		writeoutput('ts.number=#arguments.ss.number#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	if(arguments.ss.onchange NEQ ""){
		out&=' onchange="#arguments.ss.onchange#"';
	}
	if(arguments.ss.onkeyup NEQ ""){
		out&=' onkeyup="#arguments.ss.onkeyup#"';
	}
	if(arguments.ss.multiline){
		if(structkeyexists(form, arguments.ss.name)){
			out&='>#htmleditformat(form[arguments.ss.name])#</textarea';
		}else{
			out&='>#htmleditformat(arguments.ss.defaultValue)#</textarea';
		}
		out&=">";
	}else{
		if(structkeyexists(form, arguments.ss.name)){
			out&=' value="#htmleditformat(form[arguments.ss.name])#"';
		}else{
			out&=' value="#htmleditformat(arguments.ss.defaultValue)#"';
		}
		out&=" />";
	}
	if(arguments.ss.output){
		writeoutput(out);
	}else{
		return out;
	}
	</cfscript>
</cffunction>




<!--- 
ts=StructNew();
ts.name="";
ts.allowNull=false;
ts.email=false;
ts.required=false;
ts.number=false;
ts.onchange="alert('neat');";
ts.defaultValue="";
zInput_hidden(ts);
 --->
<cffunction name="hidden" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=StructNew();
	var ds=0;
	var labelStyles="";
	var out='<input type="hidden"';
	application.zcore.functions.zIncludeZOSFORMS();
	ts.name="";
	ts.friendlyName="";
	ts.defaultValue="";
	ts.allowNull=false;
	ts.email=false;
	ts.required=false;
	ts.number=false;
	ts.onchange="";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.name EQ ""){
		application.zcore.template.fail("arguments.ss.name is required.");
	}
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	out&=' name="#arguments.ss.name#" id="#arguments.ss.name#"';
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		ds.allowNull=arguments.ss.allowNull;
		ds.email=arguments.ss.email;
		ds.number=arguments.ss.number;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		arguments.ss.onchange&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[  */');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="hidden";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.allowNull=#arguments.ss.allowNull#;');
		writeoutput('ts.email=#arguments.ss.email#;');
		writeoutput('ts.number=#arguments.ss.number#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	if(arguments.ss.onchange NEQ ""){
		out&=' onchange="#arguments.ss.onchange#"';
	}
	if(structkeyexists(form, arguments.ss.name)){
		out&=' value="#htmleditformat(form[arguments.ss.name])#"';
	}else{
		out&=' value="#htmleditformat(arguments.ss.defaultValue)#"';
	}
	out&=" />";
	writeoutput(out);
	</cfscript>
</cffunction>








<!--- 
ts=StructNew();
ts.name="";
ts.style="";
ts.className="";
ts.size=20;
ts.required=false;
ts.onchange="alert('neat');";
zInput_file(ts); --->
<cffunction name="file" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ds=0;
	var value=0;
	var ts=StructNew();
	var out='<input type="file"';
	application.zcore.functions.zIncludeZOSFORMS();
	ts.name="";
	ts.friendlyName="";
	ts.style="";
	ts.className="";
	ts.size=20;
	ts.required=false;
	ts.number=false;
	ts.onchange="";
	ts.onkeyup="";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.name EQ ""){
		application.zcore.template.fail("arguments.ss.name is required.");
	}
    if(structkeyexists(form, arguments.ss.name)){
    	value= form[arguments.ss.name];
    }else{
        value="";
    }
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	out&=' name="#arguments.ss.name#" id="#arguments.ss.name#"';
	if(arguments.ss.size NEQ 0){
		out&=' size="#arguments.ss.size#"';
	}
	if(arguments.ss.className NEQ ""){
		out&=' class="#arguments.ss.className#"';
	}
	if(arguments.ss.style NEQ ""){
		out&=' style="#arguments.ss.style#"';
	}
	if(value NEQ ""){
		writeoutput('<input name="#arguments.ss.name#_delete" id="#arguments.ss.name#_delete" style="border:none; background:none; height:15px;" type="checkbox" value="true"> Check to delete and then submit form<br />');
	}
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		writeoutput('<script type="text/javascript">/* <![CDATA[ */
		zFormData["#request.zos.zFormCurrentName#"].contentType="multipart/form-data";zFormData["#request.zos.zFormCurrentName#"].method="post";document.#request.zos.zFormCurrentName#.enctype="multipart/form-data";document.#request.zos.zFormCurrentName#.method="post";
		/* ]]> */</script>');
    }
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		local.tempJS="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arguments.ss.onkeyup&=local.tempJS;
		arguments.ss.onchange&=local.tempJS;
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[ */');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="file";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	if(arguments.ss.onchange NEQ ""){
		out&=' onchange="#arguments.ss.onchange#"';
	}
	out&=" />";
	writeoutput(out);
	</cfscript>
</cffunction>

<!---
	ts = StructNew();
	ts.groupLabel = "group name";
	ts.name = "name";
	ts.type="checkbox";
	ts.menuSize=10;
	ts.colspan=3;
	ts.enumerate = 1; // for editing multiple records
	ts.output = true; // set to false to save to variable
	ts.style = "normal"; // stylesheet class
	ts.checkedValues = "value1"; // send list if there are multiple values.
	ts.checkedDelimiter = ","; // change if comma conflicts...
	ts.onChange = "zFunction();";
	ts.defaultValue = "value1";
	ts.dollarFormatLabels = true;
	// options for query data
	ts.query = qQuery;
	ts.queryLabelField = "table_label";
	ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
	ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
	ts.queryValueField = "table_value";
	// options for list data
	ts.listLabels = "value1,value2,value3";
	ts.listValues = "1,2,3";
	ts.listLabelsDelimiter = chr(9); // tab delimiter
	ts.listValuesDelimiter = chr(9);
	
	zInputExpandingBox(ts);
 --->
<cffunction name="zInputExpandingBox" localmode="modern" returntype="any" output="true">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ds=0;
	var tempStruct=0;
	var checkedValues = "";
	var selectBox = "";
	var noData = true;
	var i = 0;
	var leftLabel="";
	var myColumnOutput="";
	var rightLabel="";
	var arrBox=arraynew(1);
	var arrMenuBox=arraynew(1);
	var count=0;
	var currentBox=0;
	var boxCount=0;
	var template="";
	var arrChecked = 0;
	var label = 0;
	var checked = 0;
	var value = 0;
	var n = 0;
	var box = 0;
	var inputStruct = 0;
	
	// set defaults
	var tempStruct = StructNew();
	application.zcore.functions.zIncludeZOSFORMS();
	tempStruct.name="";
	tempStruct.friendlyName="";
	tempStruct.required=false;
	tempStruct.onchange="";
	tempStruct.enumerate = "";
	tempStruct.type="checkbox";
	tempStruct.groupLabel = "";
	tempStruct.output = true;
	tempStruct.colspan=3;
	tempStruct.className="";
	tempStruct.menuSize=0;
	tempStruct.labelSide="right";
	tempStruct.queryParseLabelVars = false;
	tempStruct.queryParseValueVars = false;
	tempStruct.listLabelsDelimiter = ","; // tab delimiter
	tempStruct.listValuesDelimiter = ",";
	tempStruct.checkedDelimiter=",";
	tempStruct.dollarFormatLabels = false;
	// override defaults
	StructAppend(arguments.ss, tempStruct, false);
	if(arguments.ss.groupLabel NEQ ""){
		arguments.ss.groupLabel&="<br />";
	}
	arguments.ss.menuSize=max(0,min(arguments.ss.menuSize,10000));
	if(arguments.ss.name EQ ''){
		application.zcore.template.fail("arguments.ss.name is required");
	}
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	</cfscript>
	<cfsavecontent variable="selectBox">
        <cfif isDefined('request.zos.zInputExpandingBoxScript') EQ false>
            <cfset request.zos.zInputExpandingBoxScript=true>
            <cfset request.zInputExpandingBoxCount=0>
            <cfscript>
			application.zcore.functions.zIncludeZOSFORMS();
			</cfscript>
        </cfif>
        	<script type="text/javascript">/* <![CDATA[ */
			zExpArrMenuBox.push("#arguments.ss.name#");
			/* ]]> */
			</script>
	
	<cfscript>
	if(structkeyexists(arguments.ss, 'checkedValues') and arguments.ss.checkedValues NEQ ""){
		checkedValues = arguments.ss.checkedValues;
	}else if(structkeyexists(form, arguments.ss.name)){
		checkedValues = form[arguments.ss.name];
	}else if(structkeyexists(arguments.ss, 'defaultValue')){
		checkedValues = arguments.ss.defaultValue;
	}else{
		checkedValues = "";
	}
	if(arguments.ss.type EQ "radio"){
		// force only one selected value
		if(checkedValues NEQ ""){
			checkedValues=listGetAt(checkedValues,listLen(checkedValues,arguments.ss.checkedDelimiter),arguments.ss.checkedDelimiter);
		}
	}
	
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		arguments.ss.onchange&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[ 1 */');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="zExpandingBox";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	arrChecked=arraynew(1);
	
	if(arguments.ss.labelSide EQ "right"){
		rightLabel=" $w";
		leftLabel="";
	}else{
		rightLabel="";
		leftLabel="$w ";
	}
	template='<a href="##" onclick="zExpMenuToggleCheckBox(#request.zInputExpandingBoxCount#,$y,''#arguments.ss.type#'',0,$z); return false;" id="zExpMenuOptionLink#request.zInputExpandingBoxCount#_$y$z2" class="zExpMenuOption">#leftLabel#<input type="radio" class="zExpMenuInput" onclick="zExpMenuToggleCheckBox(#request.zInputExpandingBoxCount#,$y,''#arguments.ss.type#'',1,$z);" onchange="#arguments.ss.onChange#" name="#arguments.ss.name##arguments.ss.enumerate#$z2" id="zExpMenuOption#request.zInputExpandingBoxCount#_$y$z2" value="$v" />#rightLabel#</a><br />';
	</cfscript>
	
	<!--- list data --->	
	<cfif structkeyexists(arguments.ss, 'listValues')>
    	<cfset count=listLen(arguments.ss.listValues,arguments.ss.listValuesDelimiter)>
		<cfloop index="i" from="1" to="#count#">
            <cfscript>
			value=listGetAt(arguments.ss.listValues, i, arguments.ss.listValuesDelimiter);
			if(isDefined('checkedValues') and checkedValues NEQ "" and listFind(checkedValues, value, arguments.ss.checkedDelimiter) NEQ 0){
				checked='checked="checked"';
				arrayappend(arrChecked, currentBox);
			}else{
				checked='';
			}
			if(structkeyexists(arguments.ss, 'listLabels')){
				label=listGetAt(arguments.ss.listLabels, i, arguments.ss.listLabelsDelimiter);
				if(arguments.ss.dollarFormatLabels and isNumeric(label)){
					label="$#NumberFormat(label)#";
				}
			}else{
				if(arguments.ss.dollarFormatLabels and isNumeric(value)){
					label="$#NumberFormat(value)#";
				}else{
					label=value;
				}
			}
			if(arguments.ss.labelSide EQ "right"){
				rightLabel=label;
				leftLabel="";
			}else{
				rightLabel="";
				leftLabel=label;
			}
			if(currentBox LT arguments.ss.menuSize){
				boxCount=2;
				if(checked NEQ ""){
					arrayappend(arrChecked, currentBox&"_2");	
				}
			}else{
				boxCount=1;
			}
			</cfscript>
            <cfloop from="1" to="#boxCount#" index="n">
            <cfsavecontent variable="box">
        	<a href="##" onclick="zExpMenuToggleCheckBox(#request.zInputExpandingBoxCount#,#currentBox#,'#arguments.ss.type#',0<cfif boxCount EQ 2 and n EQ 1>,1<cfelse>,0</cfif>); return false;" id="zExpMenuOptionLink#request.zInputExpandingBoxCount#_#currentBox#<cfif boxCount EQ 2 and n EQ 1>_2</cfif>" class="zExpMenuOption<cfif checked NEQ "">Over</cfif>">#leftLabel# <input type="#arguments.ss.type#" class="zExpMenuInput" onclick="javascript:zExpMenuToggleCheckBox(#request.zInputExpandingBoxCount#,#currentBox#,'#arguments.ss.type#',1<cfif boxCount EQ 2 and n EQ 1>,1<cfelse>,0</cfif>);" <cfif structkeyexists(arguments.ss, 'onChange')>onchange="#arguments.ss.onChange#"</cfif> <cfif structkeyexists(arguments.ss, 'style')>class="#arguments.ss.style#"</cfif> name="#arguments.ss.name##arguments.ss.enumerate#<cfif boxCount EQ 2 and n EQ 1>_2</cfif>" id="zExpMenuOption#request.zInputExpandingBoxCount#_#currentBox#<cfif boxCount EQ 2 and n EQ 1>_2</cfif>" value="#htmleditformat(value)#" #checked# /> #rightLabel#</a></cfsavecontent>
			<cfscript>if(boxCount EQ 2 and n EQ 1){ arrayAppend(arrMenuBox,box); }</cfscript>
            </cfloop>
            <cfscript>
			arrayAppend(arrBox, box);
			currentBox++;
			</cfscript>            
		</cfloop>		
		<cfset noData = false>
	</cfif>
	<!--- query data --->
	<cfif structkeyexists(arguments.ss, 'query') and structkeyexists(arguments.ss, 'queryLabelField') and structkeyexists(arguments.ss, 'queryValueField')>
    	<cfset count=arguments.ss.query.recordcount>
		<cfloop query="arguments.ss.query">
            <cfscript>
			if(structkeyexists(arguments.ss, 'queryValueField')){
				if(arguments.ss.queryParseValueVars){
					value=application.zcore.functions.zParseVariables(arguments.ss.queryValueField, false, arguments.ss.query);
				}else{
					value=arguments.ss.query[arguments.ss.queryValueField];
				}
			}else{
				value=arguments.ss.query[arguments.ss.queryLabelField];
			} 
			if(arguments.ss.queryParseValueVars and checkedValues NEQ "" and listFind(checkedValues, application.zcore.functions.zParseVariables(arguments.ss.queryValueField, false, arguments.ss.query), arguments.ss.checkedDelimiter) NEQ 0){
				checked='checked="checked"';
				arrayappend(arrChecked, currentBox);
			}else{
				if(checkedValues NEQ "" and listFind(checkedValues, arguments.ss.query[arguments.ss.queryValueField], arguments.ss.checkedDelimiter) NEQ 0){
					checked='checked="checked"';
					arrayappend(arrChecked, currentBox);
				}else{
					checked='';
				}
			}
			if(structkeyexists(arguments.ss, 'queryLabelField')){
			  if(arguments.ss.dollarFormatLabels and isNumeric(arguments.ss.query[arguments.ss.queryLabelField])){
				label="$"&NumberFormat(arguments.ss.query[arguments.ss.queryLabelField]);
			  }else{
					if(arguments.ss.queryParseLabelVars){
						label=application.zcore.functions.zParseVariables(arguments.ss.queryLabelField, false, arguments.ss.query);
					}else{
						label=arguments.ss.query[arguments.ss.queryLabelField];
					}
			  }
			}else{
			  if(arguments.ss.dollarFormatLabels and isNumeric(arguments.ss.query[arguments.ss.queryValueField])){
					label="$"&NumberFormat(arguments.ss.query[arguments.ss.queryValueField]);
			   }else{
					label=arguments.ss.query[arguments.ss.queryValueField];
			  }
			}
			if(arguments.ss.labelSide EQ "right"){
				rightLabel=label;
				leftLabel="";
			}else{
				rightLabel="";
				leftLabel=label;
			}
			if(currentBox LT arguments.ss.menuSize){
				boxCount=2;
				if(checked NEQ ""){
					arrayappend(arrChecked, currentBox&"_2");	
				}
			}else{
				boxCount=1;
			}
			</cfscript>
            <cfloop from="1" to="#boxCount#" index="n">
            <cfsavecontent variable="box">
        	<a href="##" onclick="zExpMenuToggleCheckBox(#request.zInputExpandingBoxCount#,#currentBox#,'#arguments.ss.type#',0<cfif boxCount EQ 2 and n EQ 1>,1<cfelse>,0</cfif>); return false;" id="zExpMenuOptionLink#request.zInputExpandingBoxCount#_#currentBox#<cfif boxCount EQ 2 and n EQ 1>_2</cfif>" class="zExpMenuOption<cfif checked NEQ "">Over</cfif>">#leftLabel# <input type="#arguments.ss.type#" class="zExpMenuInput" onclick="zExpMenuToggleCheckBox(#request.zInputExpandingBoxCount#,#currentBox#,'#arguments.ss.type#',1<cfif boxCount EQ 2 and n EQ 1>,1<cfelse>,0</cfif>);" <cfif structkeyexists(arguments.ss, 'onChange')>onchange="#arguments.ss.onChange#"</cfif> name="#arguments.ss.name##arguments.ss.enumerate#<cfif boxCount EQ 2 and n EQ 1>_2</cfif>" id="zExpMenuOption#request.zInputExpandingBoxCount#_#currentBox#<cfif boxCount EQ 2 and n EQ 1>_2</cfif>" value="#htmleditformat(value)#" #checked# /> #rightLabel#</a></cfsavecontent>
			<cfscript>if(boxCount EQ 2 and n EQ 1){ arrayAppend(arrMenuBox,box); }</cfscript>
            </cfloop>
            <cfscript>
			arrayAppend(arrBox, box);
			currentBox++;
			</cfscript> 
		</cfloop>
		<cfset noData = false>
	</cfif>
    	<span class="#arguments.ss.className#">
    	<div id="#arguments.ss.name#_expmenu1" class="zExpMenuBox" onclick="zExpMenuIgnoreClick=#request.zInputExpandingBoxCount#;">
        <cfif arguments.ss.groupLabel NEQ ""><span class="zExpMenuGroupLabel">#arguments.ss.groupLabel#</span></cfif>
        <div id="#arguments.ss.name#_expmenu3" class="zExpMenuBoxOptions">
		<cfscript>
		writeoutput(arraytolist(arrMenuBox,"<br />")&'</div>');
		if(arguments.ss.menuSize LT arraylen(arrBox)){
			writeoutput('<a href="##" onclick="zExpMenuToggleMenu(''#arguments.ss.name#''); return false;" id="#arguments.ss.name#_expmenu4">More Options &gt;&gt;</a><br />');
		}
        </cfscript></div>
    
    <!--- <link href="/z/a/stylesheets/zExpandingBox.css" rel="stylesheet" type="text/css"> --->
        <div id="#arguments.ss.name#_expmenu2" class="zExpandingBox" onclick="zExpMenuIgnoreClick=#request.zInputExpandingBoxCount#;" style=" display:none;left:0px; top:0px; position:absolute;">
        <input type="hidden" name="zExpMenuBoxCount#request.zInputExpandingBoxCount#" id="zExpMenuBoxCount#request.zInputExpandingBoxCount#" onchange="#arguments.ss.onchange#" value="#arraylen(arrBox)#" />
        <table style="width:100%;"><tr><td><span class="zExpMenuGroupLabel">#arguments.ss.groupLabel#</span></td></tr><tr><td id="#arguments.ss.name#_expmenu5"><table style="width:100%;"><cfscript>	
        inputStruct = StructNew();
        inputStruct.colspan = arguments.ss.colspan;
        inputStruct.rowspan = count;
        inputStruct.vertical = true;
        myColumnOutput = CreateObject("component", "zcorerootmapping.com.display.loopOutput");
        myColumnOutput.init(inputStruct);
        for(i=1;i LTE arraylen(arrBox);i++){
            writeoutput(myColumnOutput.check(i)&arrBox[i]&"<br />"&myColumnOutput.ifLastRow(i));
        }
        </cfscript></table></td>
        </tr>
        <tr><td colspan="#inputStruct.colspan#" class="zExpandingBoxSubmitLinks" style="text-align:right;">
        <a href="##" onclick="zExpMenuToggleMenu('#arguments.ss.name#'); return false;">OK</a></td></tr>
        </table></div></span>
        <script type="text/javascript">
		/* <![CDATA[ */
		zArrDeferredFunctions.push(function(){
	 	zExpMenuBoxData[#request.zInputExpandingBoxCount#]=new Object();
	 	zExpMenuBoxData[#request.zInputExpandingBoxCount#].menuSize=parseInt("#arguments.ss.menuSize#");
	 	zExpMenuBoxData[#request.zInputExpandingBoxCount#].colspan=parseInt("#arguments.ss.colspan#");
	 	zExpMenuBoxData[#request.zInputExpandingBoxCount#].type=parseInt("#arguments.ss.type#");
	 	zExpMenuBoxData[#request.zInputExpandingBoxCount#].template="#jsstringformat(template)#";
		zExpMenuBoxChecked[#request.zInputExpandingBoxCount#]=<cfif arraylen(arrChecked) EQ 0>new Array();<cfelse>new Array('#arraytolist(arrChecked,"','")#');</cfif>
		});
		/* ]]> */
		</script>
	<!--- no data, throw error --->	
	<cfif noData>
		<cfthrow type="exception" message="zSelectBox: listLabels or (query and queryLabel) are required.">
	</cfif>
		
	</cfsavecontent>
			<cfscript>
            request.zInputExpandingBoxCount++;
            
	if(arguments.ss.output){
		writeoutput(selectBox);
	}
	</cfscript>
	<cfreturn selectBox>
</cffunction>



<!--- 
ts=StructNew();
ts.name="formName";
ts.action=request.cgi_script_name&"?action=submit";
ts.ajax=true;
ts.debug=false;
ts.method="get";
ts.onLoadCallback="";
ts.onChangeCallback="";
ts.successMessage=true;
zForm(ts);
 --->
<cffunction name="zForm" localmode="modern" returntype="any" output="true">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=StructNew();	
	// set defaults
	ts.name = "formName"; // must be unique
	ts.ajax=false;
	ts.debug=false;
	ts.enctype="";
	ts.ignoreOldRequests=false;
	ts.onLoadCallback="function(){};";
	if(request.zos.istestserver){
		ts.onErrorCallback="function(r){alert(r);};";
	}else{
		ts.onErrorCallback="function(r){};";
	}
	ts.onChangeCallback="function(){};";
	ts.action=request.cgi_script_name&"?"&cgi.QUERY_STRING&"&zFormAction=submit";
	ts.successMessage=true;
	ts.method="post";
	// override defaults
	StructAppend(arguments.ss, ts, false);
	if(application.zcore.functions.zEndFormCheckEnabled() and application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		application.zcore.template.fail("You must call zEndForm() before calling zForm() again.");
	}
	request.zos.zFormCurrentName=arguments.ss.name;
	</cfscript>
    <cfif structkeyexists(request.zos,"zFormGlobalInit") EQ false>
		<cfscript>
		request.zos.zForm=structnew();
		request.zos.zForm.globalInit=true;
        request.zos.zForm.formStruct=structnew();
		application.zcore.functions.zIncludeZOSFORMS();
        </cfscript>
    </cfif>
    
    
    <cfif structkeyexists(request.zos.zForm.formStruct,arguments.ss.name) EQ false>
    	<cfscript>
		request.zos.zForm.formStruct[arguments.ss.name]=structnew();
		request.zos.zForm.formStruct[arguments.ss.name].arrFields=arraynew(1);
		</cfscript>
<script type="text/javascript">
/* <![CDATA[ */
zArrDeferredFunctions.push(function(){
zFormData["#arguments.ss.name#"]=new Object();
zFormData["#arguments.ss.name#"].ignoreOldRequests=#arguments.ss.ignoreOldRequests#;
zFormData["#arguments.ss.name#"].onLoadCallback=#arguments.ss.onLoadCallback#;
zFormData["#arguments.ss.name#"].onErrorCallback=#arguments.ss.onErrorCallback#;
zFormData["#arguments.ss.name#"].onChangeCallback=#arguments.ss.onChangeCallback#;
zFormData["#arguments.ss.name#"].submitId="";
zFormData["#arguments.ss.name#"].error=false;
zFormData["#arguments.ss.name#"].debug=#arguments.ss.debug#;
zFormData["#arguments.ss.name#"].action="#arguments.ss.action#";
zFormData["#arguments.ss.name#"].method="#arguments.ss.method#";
zFormData["#arguments.ss.name#"].ajaxSuccess = true;
zFormData["#arguments.ss.name#"].successMessage=#arguments.ss.successMessage#;
zFormData["#arguments.ss.name#"].arrFields = new Array();
zFormData["#arguments.ss.name#"].ajax=#arguments.ss.ajax#;
zFormData["#arguments.ss.name#"].ajaxStartCount=0;
zFormData["#arguments.ss.name#"].ajaxEndCount=0;
zFormData["#arguments.ss.name#"].contentType="application/x-www-form-urlencoded";
});
/* ]]> */
	</script>
    </cfif>
    <a id="anchor_#arguments.ss.name#"></a>
    <form name="#arguments.ss.name#" id="#arguments.ss.name#" action="#htmleditformat(arguments.ss.action)#" method="post" onsubmit="return zFormSubmit('#arguments.ss.name#',false,false);" <cfif arguments.ss.enctype NEQ "">enctype="#arguments.ss.enctype#"</cfif>>
    <div id="zFormMessage_#arguments.ss.name#" class="zFormMessageBox"></div>
</cffunction>
<cffunction name="zEndForm" localmode="modern" returntype="any" output="true"></form><!--- <script type="text/javascript">/* <![CDATA[ */zDisableTextSelection(document.getElementById("#request.zos.zFormCurrentName#"));/* ]]> */</script> --->
	<cfscript>
	request.zos.zFormCurrentName="";
	</cfscript>
</cffunction>


<cffunction name="zDisbleEndFormCheck" localmode="modern" returntype="any" output="no">
	<cfscript>
	request.zos.zDisableEndFormCheckRule=true;
	</cfscript>
</cffunction>
<cffunction name="zEndFormCheckEnabled" localmode="modern" returntype="any" output="no">
	<cfscript>
	if(structkeyexists(request.zos,'zDisableEndFormCheckRule')){
		return false;	
	}else{
		return true;	
	}
	</cfscript>
</cffunction>










<!--- 
this is not accurate
	ts = StructNew();
	ts.groupLabel = "group name";
	ts.name = "name";
	ts.type="checkbox";
	ts.menuSize=10;
	ts.colspan=3;
	ts.enumerate = 1; // for editing multiple records
	ts.output = true; // set to false to save to variable
	ts.style = "normal"; // stylesheet class
	ts.checkedValues = "value1"; // send list if there are multiple values.
	ts.checkedDelimiter = ","; // change if comma conflicts...
	ts.onChange = "zFunction();";
	ts.defaultValue = "value1";
	ts.dollarFormatLabels = true;
	ts.onlyOneSelection=false; // set to true to limit select count to one
	// options for query data
	ts.query = qQuery;
	ts.queryLabelField = "table_label";
	ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
	ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
	ts.queryValueField = "table_value";
	// options for list data
	ts.listLabels = "value1,value2,value3";
	ts.listValues = "1,2,3";
	ts.listLabelsDelimiter = chr(9); // tab delimiter
	ts.listValuesDelimiter = chr(9);
	ts.selectedValues="";
	zInputLinkBox(ts);

 --->
<cffunction name="linkBox" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var arrURL='';
	var ds='';
	var stylesBackup='';
	var z1='';
	var nameBackup='';
	var rs=structnew();
	var out=0;
	var arrOut=arraynew(1);
	var i=0;
	var arrL=0;
	var arrV=0;
	var ts=structnew();
	var styles="";
	var inputStyles="";
	var scripts="";
	var tempValue=0;
	var selectedValue=0;
	var arrValues=0;
	var arrSelected=0;
	var arrSelectedV=0;
	var arrSelectedLink=0;
	var selectedStruct=0;
	var zOffset=0;
	var arrOut9=arraynew(1);
	var out2="";
	var ds1='<script type="text/javascript">/* <![CDATA[ */document.write("';
	var ds2=' ';
	var ds3='';
	var ds4='");/* ]]> */</script>';
	var dss1="";
	var dss2="";
	var dss3="";
	var id="";
	var dss4="";
	var escape="";
	var t9=structnew();
	var link="";
	application.zcore.functions.zIncludeZOSFORMS();
	ts.output=true;
	ts.listLabelsDelimiter=chr(9);
	ts.listValuesDelimiter=chr(9);
	ts.listURLsDelimiter=chr(9);
	ts.friendlyName="";
	ts.enableTyping=false;
	ts.overrideOnKeyUp=false;
	ts.disableSpiderAfter=0;
	ts.disableSpider=false;
	ts.allowAnyText=true;
	ts.onlyOneSelection=false;
	ts.notranslate=false;
	ts.listURLs="";
	ts.selectedOnTop=true;
	ts.required=false;
	ts.enableClickSelect=true;
	ts.onchange="";
	ts.onkeyup="";
	ts.onEnterJS="";
	ts.selectLabel="-- Select --";
	ts.onKeyPress="";
	ts.onbuttonclick="";
	ts.inputStyle="";
	ts.range=false;
	ts.onclick="";
	ts.style="display:block;clear:both;";
	ts.inputClass="";
	ts.class="";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.listLabels EQ ""){
		arguments.ss.listLabels=arguments.ss.listValues;
	}
	if(arguments.ss.listValues EQ ""){
		//application.zcore.template.fail("arguments.ss.listValues is required and cannot be an empty string.");	
	}
    arguments.ss.listLabels=htmleditformat(arguments.ss.listLabels);
    arguments.ss.listValues=htmleditformat(arguments.ss.listValues);
    arguments.ss.listURLs=htmleditformat(arguments.ss.listURLs);
    arrL=listtoarray(arguments.ss.listLabels, arguments.ss.listLabelsDelimiter, true);
    arrV=listtoarray(arguments.ss.listValues, arguments.ss.listValuesDelimiter, true);
    arrURL=listtoarray(arguments.ss.listURLs, arguments.ss.listURLsDelimiter, true);
	if(arguments.ss.inputclass NEQ ""){
		inputstyles&=' class="#arguments.ss.inputclass#"';
	}
		styles&=' style="white-space:nowrap;#arguments.ss.style#"';
	if(arguments.ss.style NEQ ""){
	}
	if(arguments.ss.class NEQ ""){
		styles&=' class="#arguments.ss.class#"';
	}
	if(arguments.ss.onclick NEQ ""){
		scripts&=arguments.ss.onclick;
	}
	
	if(isDefined('request.zos.zFormLinkBoxCreated') EQ false){
		request.zos.zFormLinkBoxCreated=true;
		application.zcore.template.appendtag('content','<div id="zTOB" style="display:none; position:absolute; background-color:##FFFFFF; z-index:110; width:276px; height:250px; overflow:auto; float:left; border:1px solid ##CCCCCC;"></div>');
	}
	
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		arguments.ss.onchange&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[ */');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="text";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	local.tempRS=application.zcore.functions.zFormJSNewZValue(8);
	zOffset=local.tempRS.zValue;
	arguments.ss.onEnterJS&="zInputSetSelectedOptions(true,#zOffset#,'#arguments.ss.name#',null,#arguments.ss.allowAnyText#);obj.value='';document.getElementById(obj.id+'v').value='';";
	if(arguments.ss.overrideOnKeyUp EQ false){
		arguments.ss.onkeyup&="document.getElementById(this.id+'v').value=this.value;";
	}
	arguments.ss.onKeyPress&="return zDisableEnter(event);";
	if(structkeyexists(arguments.ss, 'selectedValues')){
		selectedValue=arguments.ss.selectedValues;
	}else{
		if(structkeyexists(variables, arguments.ss.name)){
			selectedValue=variables[arguments.ss.name];
		}else if(structkeyexists(form, arguments.ss.name)){
			selectedValue=form[arguments.ss.name];
		}else{
			selectedValue="";
		}
	}
	if(trim(selectedValue) EQ ""){
		arrValues=arraynew(1);
	}else{
		arrValues=listtoarray(selectedValue,",", true);
	}
	selectedStruct=structnew();
	for(i=1;i LTE arraylen(arrValues);i++){
		selectedStruct[arrValues[i]]=true;
	}
	arrSelected=arraynew(1);
	arrSelectedV=arraynew(1);
	arrSelectedLink=arraynew(1);
	link="javascript:void(0);";
	if(arguments.ss.disableSpider){
		dss1=ds1;
		dss2=ds2;
		dss3=ds3;
		dss4=ds4;
		escape="\";
	}
	arrayappend(arrOut,'<input type="hidden" name="'&arguments.ss.name&'_zlabel" id="'&arguments.ss.name&'_zlabel" value="" />');
	arrayappend(arrOut,'<input type="hidden" name="'&arguments.ss.name&'" onchange="#arguments.ss.onchange#" id="'&arguments.ss.name&'" value="#htmleditformat(selectedValue)#" />');
	
	stylesBackup=styles;
	if(arguments.ss.enableClickSelect EQ false){
		styles=replacenocase(styles,'style="','style="display:none !important;','all');
	}
	//arrayappend(arrOut, dss1);
	for(i=1;i LTE arraylen(arrL);i++){
		if(arraylen(arrV) LT i) continue;
		id="zInputLinkBox#zOffset#_link#i#";
		
		if(structkeyexists(selectedStruct, arrV[i])){
			arrayappend(arrSelected,jsstringformat(arrL[i]));	
			arrayappend(arrSelectedV,jsstringformat(arrV[i]));	
			arrayappend(arrSelectedLink,jsstringformat(id));	
			structdelete(selectedStruct,arrV[i]);
		}
		if(arraylen(arrURL) GTE i){
			link=arrURL[i];
		}
		if(arguments.ss.disableSpider EQ false and arguments.ss.disableSpiderAfter EQ i-1){
			dss1=ds1;
			dss2=ds2;
			dss3=ds3;
			dss4=ds4;
			escape="\";
		}
		arrayappend(arrOut, ('<a id="#id#" hre'&dss3&'f="'&link&'" '&dss2&' onclick="zSetInput(''#arguments.ss.name#_zmanual'', zHasInnerText() ? this.innerText : this.textContent);zSetInput(''#arguments.ss.name#_zmanualv'',''#arrV[i]#'');zInputSetSelectedOptions(true,#zOffset#,''#arguments.ss.name#'',''#id#'',#arguments.ss.allowAnyText#,#arguments.ss.onlyOneSelection#);#scripts#zCLink(this);this.style.display=''none'';'&'" #styles#>'&arrL[i]&'</'&dss3&'a>'));	
		arrayappend(arrOut9,arrV[i]);
	}
	styles=stylesBackup;
	</cfscript><cfsavecontent variable="out2">
	#local.tempRS.output#
<cfif arguments.ss.selectedOnTop><div id="zInputOptionBlock#zOffset#" style="width:100%;"></div><br style="clear:both;" /></cfif>
    <input type="hidden" name="#arguments.ss.name#_zmanualv" id="#arguments.ss.name#_zmanualv" value="" />
<cfif arguments.ss.enableTyping>



 Type: <input type="text" name="#arguments.ss.name#_zmanual" id="#arguments.ss.name#_zmanual" onkeyup="#arguments.ss.onkeyup# 
	zFormOnEnter(event,this);" onkeypress="#arguments.ss.onkeypress#" value="" style="width:40%; #arguments.ss.inputstyle#" #inputstyles# />
    <script type="text/javascript">
	/* <![CDATA[ */
	document.getElementById("#arguments.ss.name#_zmanual").setAttribute("autocomplete","off");
	/* ]]> */
	</script>
 
<input type="button" name="zInputAddCat#zOffset#" onclick="<cfif arguments.ss.onButtonClick NEQ "">#arguments.ss.onButtonClick#</cfif>zInputSetSelectedOptions(true,#zOffset#,'#arguments.ss.name#',null,#arguments.ss.allowAnyText#,#arguments.ss.onlyOneSelection#);document.getElementById('#arguments.ss.name#_zmanual').value='';" value="Enter" style="#arguments.ss.inputstyle#" #inputstyles# /> 
<cfelse>
    <input type="hidden" name="#arguments.ss.name#_zmanual" id="#arguments.ss.name#_zmanual" value="" />

	<cfscript>
	t9=duplicate(arguments.ss);
	t9.selectedValues="~~noselection~~";
	t9.onchange="if(this.selectedIndex!=0){zSetInput('#arguments.ss.name#_zmanual', this.options[this.selectedIndex].text, true); zSetInput('#arguments.ss.name#_zmanualv',this.options[this.selectedIndex].value, true);this.selectedIndex=0; zInputSetSelectedOptions(true,#zOffset#,'#arguments.ss.name#','#id#',#arguments.ss.allowAnyText#,#arguments.ss.onlyOneSelection#);#scripts#zCLink(this);zSetInput('#arguments.ss.name#_zmanual','');zSetInput('#arguments.ss.name#_zmanualv','');} var z1=document.getElementById('zExpOption#zOffset+7#_contents'); if(z1){ z1.style.height='auto';  var z=zGetAbsPosition(z1);z1.style.height=z.height+'px';}";
	nameBackup=arguments.ss.name;
	t9.selectLabel=arguments.ss.selectLabel;
	t9.inlineStyle=" width:100%;";
	t9.name="zLinkBoxSelectBox"&zOffset;
	t9.disableAjaxFieldData=true;
	t9.output=true;
    application.zcore.functions.zInputSelectBox(t9);
	//arguments.ss.name=nameBackup;
    </cfscript>
</cfif>
<cfif arguments.ss.enableClickSelect>
<cfif arraylen(arrL) NEQ 0 and arguments.ss.onlyOneSelection EQ false><br />
or 
Click to select:<br style="clear:both;" /></cfif>
</cfif></cfsavecontent>
<cfscript>
arrayprepend(arrOut,out2);
</cfscript>

<cfsavecontent variable="out2">
<cfif arguments.ss.selectedOnTop EQ false><div id="zInputOptionBlock#zOffset#" style="width:100%;"></div></cfif>
<script type="text/javascript">/* <![CDATA[ */
zArrDeferredFunctions.push(function(){
<cfif arraylen(arrSelected) NEQ 0>zValues[#zOffset#]=["#arraytolist(arrSelected,'","')#"];zValues[#zOffset+1#]=["#arraytolist(arrSelectedV,'","')#"];;zValues[#zOffset+2#]=["#arraytolist(arrSelectedLink,'","')#"];</cfif>
zValues[#zOffset+3#]=new Array("#arraytolist(arrOut9,'","')#");
zValues[#zOffset+4#]="#arguments.ss.name#";
zValues[#zOffset+5#]=#zOffset+7#;
zValues[#zOffset+6#]=#arguments.ss.onlyOneSelection#;
<cfif arguments.ss.enableTyping>
zFormOnEnterAdd("#arguments.ss.name#_zmanual","#arguments.ss.onEnterJS#");
</cfif>
zInputSetSelectedOptions(false,#zOffset#);
});
/* ]]> */
</script></cfsavecontent>
     <cfscript>
	 out=arraytolist(arrOut,"")&out2;
	 if(arguments.ss.output){
	 	writeoutput(out);
	 }else{
		 rs.output=out;
		 rs.zExpOptionValue=zOffset+7;
		rs.value="<br />"&arraytolist(arrSelected,"<br />");
		return rs;
	 }
	 </cfscript>
</cffunction>







<!--- 

 --->
<cffunction name="zMotion" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var topC="";
	var arrO=0;
	var ts=StructNew();	
	application.zcore.functions.zIncludeZOSFORMS();
	// set defaults
	// ts.labelId="";
	// ts.id = "formName";
	ts.hideOnCloseId="";
	ts.open=false;
	ts.direction="down";
	ts.rollover=false;
	ts.click=false;
	// override defaults
	StructAppend(arguments.ss, ts, false);
	
	arrO=arraynew(1);
	arrayAppend(arrO,"<script type=""text/javascript"">/* <![CDATA[ */
zArrDeferredFunctions.push(function(){");
	arrayAppend(arrO,"var zd1=document.getElementById('#arguments.ss.labelId#');var zd2=new Function('zMotiontoggleSlide(""#arguments.ss.id#"",""#arguments.ss.labelId#"",""#arguments.ss.hideOnCloseId#"");');");
	if(arguments.ss.click){
		arrayAppend(arrO,"zd1.onmousedown=new Function('zMotionOnMouseDown(""#arguments.ss.id#"");');");
		arrayAppend(arrO,"zd1.onmouseup=zd2;");
		arrayAppend(arrO,"zDisableTextSelection(zd1);");
		 
	}
	if(arguments.ss.open EQ false){
		arrayAppend(arrO,"document.getElementById('#arguments.ss.id#').style.display='none';");
	}else{
		arrayAppend(arrO,"document.getElementById('#arguments.ss.hideOnCloseId#').style.display='none';");
	}
	if(arguments.ss.rollover){
		arrayAppend(arrO,"zd1.onmouseover=zd2;zd1.onmouseout=zd2;");
	}
	writeoutput(arraytolist(arrO," ")&" });/* ]]> */</script>");
	</cfscript>    
</cffunction>

<cffunction name="zFormJSNewZValue" localmode="modern" output="yes" returntype="any">
	<cfargument name="count" type="numeric" required="yes"><cfscript>
	var i=0;
	var rs={};
	var theHTML="";
	var returnCount=0;
	if(structkeyexists(request, 'zValueOffset') EQ false){
		request.zValueOffset=-1;
	}
	rs.zValue=request.zValueOffset+1;
	savecontent variable="rs.output"{
		writeoutput('<script type="text/javascript">/* <![CDATA[ */
		zArrDeferredFunctions.push(function(){');
		for(i=1;i LTE arguments.count;i++){
			request.zValueOffset++;
			writeoutput('zValues[#request.zValueOffset#]=[];');
		}
		writeoutput('}); 
		/* ]]> */</script>');
	}
	return rs;
	</cfscript>
</cffunction>
    
    
<!--- 
ts=StructNew();
ts.label="Price:";
ts.contents="Stuff here";
ts.height="70";
ts.width="150";
ts.zMotionOpen=false;
ts.zMotionEnabled=false;
zExpOption(ts);
 --->
<cffunction name="zExpOption" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	var ns=0;
	var ts=structnew();
	application.zcore.functions.zIncludeZOSFORMS();
	ts.zMotionEnabled=false;
	ts.zMotionOpen=false;
	ts.disableOverflow=false;
	ts.value="";
	ts.height=0;
	StructAppend(arguments.ss, ts, false);
	if(structkeyexists(arguments.ss,'zExpOptionValue') EQ false){
		local.tempRS=application.zcore.functions.zFormJSNewZValue(1);
		arguments.ss.zExpOptionValue=local.tempRS.zValue;
		writeoutput(local.tempRS.output);
	}
	</cfscript>
<div id="zExpOption#arguments.ss.zExpOptionValue#_container" style="z-index:#arguments.ss.zExpOptionValue+10#;width:#arguments.ss.width#px;" class="zExpOption_container"><div class="zExpOption_button" id="zExpOption#arguments.ss.zExpOptionValue#_button"><a  href="##" onclick="return false;" style=" width:#arguments.ss.width-12#px; "></a></div><div id="zExpOption#arguments.ss.zExpOptionValue#_contents" class="zExpOption_contents" style=" <cfif arguments.ss.height NEQ 0>height:#arguments.ss.height-22#px; </cfif> width:#arguments.ss.width-12#px; white-space:nowrap;<cfif arguments.ss.disableOverflow>overflow:visible !important;</cfif> ">#arguments.ss.contents#</div>
        <!--- <div id="zExpUpdateBar#arguments.ss.zExpOptionValue#" style=" width:#arguments.ss.width-12#px; " class="zExpOption_update">Click to Update</div> ---></div>
	
    <script type="text/javascript">/* <![CDATA[ 12 */
zArrDeferredFunctions.push(function(){
	zExpOptionLabelHTML[#arguments.ss.zExpOptionValue#]="<span class=\"zExpOption_label\">#jsstringformat(arguments.ss.label)#<\/span>";zExpOptionSetValue(#arguments.ss.zExpOptionValue#,"#jsstringformat(arguments.ss.value)#","<cfif arguments.ss.zMotionOpen>none<cfelse>inline</cfif>");
});
    /* ]]> */</script>
	<cfscript>
	if(arguments.ss.zMotionEnabled){
		ns=StructNew();
		ns.labelId="zExpOption#arguments.ss.zExpOptionValue#_button";
		ns.id="zExpOption#arguments.ss.zExpOptionValue#_contents";
		ns.hideOnCloseId="zExpOption#arguments.ss.zExpOptionValue#_value";
		ns.direction="down";
		ns.open=arguments.ss.zMotionOpen;
		ns.click=true;
		application.zcore.functions.zMotion(ns);
	}
	</cfscript>
</cffunction>









<!--- 
<cfscript>
ts=StructNew();
ts.name="price_low";
ts.name2="price_high";
ts.range=true;
ts.listLabels="";
ts.listValues="";
ts.listLabelsDelimiter = ","; // tab delimiter
ts.listValuesDelimiter = ",";
// query
ts.query=qQuery;
ts.queryParseLabelVars = false;
ts.queryParseValueVars = false;
ts.queryValueField="";
ts.queryLabelField="";

zInputSlider(ts);
</cfscript>
 --->
<cffunction name="zInputSlider" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ds=0;
	var rs=structnew();
	var arrValues=arraynew(1);
	var arrLabels=arraynew(1);
	var selectedValue1 = "";
	var selectedValue2 = "";
	var label1value="";
	var label2value="";
	var marginLeft=0;
	var marginRight=0;
	var sliderWidthSubtract=10;
	var output="";
	var percent=0;
	var zValue="";
	var pixels=0;
	var i = 0;
	var ts =StructNew();	
	application.zcore.functions.zIncludeZOSFORMS();
	// set defaults
	ts.width=150;
	ts.leftLabel="";
	ts.rightLabel="";
	ts.middleLabel="";
	ts.friendlyName="";
	ts.fieldWidth="50";
	ts.range=false;
	ts.onchange="";
	ts.multiple = false;
	ts.enumerate = "";
	ts.output = true;
	ts.required=false;
	ts.queryParseLabelVars = false;
	ts.queryParseValueVars = false;
	ts.listLabelsDelimiter = ","; // tab delimiter
	ts.listValuesDelimiter = ",";
	ts.dollarFormatLabels = false;
	// override defaults
	StructAppend(arguments.ss, ts, false);
	if(arguments.ss.range and structkeyexists(arguments.ss,"name2") EQ false){
		application.zcore.template.fail("arguments.ss.name2 is required when arguments.ss.range is true.");
	}
	
	if(structkeyexists(arguments.ss,"listValues")){
		if(structkeyexists(arguments.ss,"listLabels") EQ false){
			arguments.ss.listLabels=arguments.ss.listValues;
		}
		arrValues=listtoarray(replace(arguments.ss.listValues,chr(10)," ",'all'), arguments.ss.listValuesDelimiter,true);
		arrLabels=listtoarray(replace(arguments.ss.listLabels,chr(10)," ",'all'), arguments.ss.listLabelsDelimiter,true);
	}
	local.tempRS=application.zcore.functions.zFormJSNewZValue(7);
	zValue=local.tempRS.zValue;
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		arguments.ss.onchange&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[ */');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="text";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		if(arguments.ss.range){
			local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
			arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
			writeoutput('var ts=new Object();');
			writeoutput('ts.type="text";');
			writeoutput('ts.id="#arguments.ss.name2#";');
			writeoutput('ts.required=#arguments.ss.required#;');
			writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
			writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		}
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	</cfscript>
    <cfif structkeyexists(arguments.ss,"query")><cfloop query="arguments.ss.query"><cfscript>
		if(arguments.ss.queryParseLabelVars){
			arrayappend(arrLabels,replace(application.zcore.functions.zParseVariables(arguments.ss.queryLabelField, false, arguments.ss.query),chr(10)," ",'all'));
		}else{
			arrayappend(arrLabels,replace(arguments.ss.query[arguments.ss.queryLabelField],chr(10)," ",'all'));
		}
		if(arguments.ss.queryParseValueVars){
			arrayappend(arrValues,replace(application.zcore.functions.zParseVariables(arguments.ss.queryValueField, false, arguments.ss.query),chr(10)," ",'all'));
		}else{
			arrayappend(arrValues,replace(arguments.ss.query[arguments.ss.queryValueField],chr(10)," ",'all'));
		}
		</cfscript></cfloop></cfif>
        <cfscript>
		if(arguments.ss.range){
			sliderWidthSubtract=20;	
		}
		pixels=(arguments.ss.width-sliderWidthSubtract)/(arraylen(arrValues));
		//writeoutput("pixels:"&pixels&"| count: #arraylen(arrValues)#<br />");
		if(application.zcore.functions.zso(form, arguments.ss.name) NEQ ""){
			selectedValue1 = form[arguments.ss.name];
			label1value=selectedValue1;
			if(isNumeric(left(selectedValue1,1))){
				selectedValue1=replace(replace(selectedValue1,",","","ALL"),"$","","ALL");
			}
			for(i=1;i LTE arraylen(arrValues);i++){
				if(arrValues[i] == selectedValue1){
					label1value=arrLabels[i];
					marginLeft=round(pixels*(i-0.5));
					break;	
				}else if(arrValues[i] GT selectedValue1){
					marginLeft=round(pixels*(i-1.0));
					break;
				}
			}
		}
		if(application.zcore.functions.zso(form, arguments.ss.name2) NEQ ""){
			selectedValue2 = form[arguments.ss.name2];
			label2value=selectedValue2;
			if(isNumeric(left(selectedValue2,1))){
				selectedValue2=replace(replace(selectedValue2,",","","ALL"),"$","","ALL");
			}
			for(i=1;i LTE arraylen(arrValues);i++){
				if(arrValues[i] == selectedValue2){
					label2value=arrLabels[i];
					marginRight=round((arguments.ss.width-sliderWidthSubtract)-(pixels*(i-0.5)));
					break;	
				}else if(arrValues[i] GT selectedValue2){
					marginRight=round((arguments.ss.width-sliderWidthSubtract)-(pixels*(i-1.0)));
					break;
				}
			}
		}
		if(cgi.HTTP_USER_AGENT CONTAINS 'MSIE 6.0'){
			marginLeft/=2;
			marginRight/=2;	
		}
		//writeoutput(arraytolist(arrLabels)&"<br />");
		//writeoutput("#selectedValue1#|marginLeft: #marginLeft# of #arguments.ss.width-sliderWidthSubtract#<br />");
		//writeoutput("marginRight: #marginRight# of #arguments.ss.width-sliderWidthSubtract#<br />");
		</cfscript>
<cfsavecontent variable="output">
#local.tempRS.output#
<div style="float:left; width:50%;"><input type="hidden" name="zInputHiddenValues#zValue#" id="zInputHiddenValues#zValue#" onchange="#arguments.ss.onchange#" value="" />
<cfif arguments.ss.leftLabel NEQ "">#arguments.ss.leftLabel#</cfif><input type="text" style="width:#arguments.ss.fieldWidth#px;" name="#arguments.ss.name#_label" id="#arguments.ss.name#_label" value="#htmleditformat(label1value)#" onkeyup="zExpShowUpdateBar(#zValue+6#, 'block');" onclick="zCacheSliderValues[this.id]=this.value;this.value='';" onblur="if(this.value==''){this.value=zCacheSliderValues[this.id];} zExpShowUpdateBar(#zValue+6#, 'none');zInputSliderSetValue('#arguments.ss.name#',#zValue#,#zValue+2#,this.value,#zValue+6#, 1);" /><input type="hidden" name="#arguments.ss.name#" id="#arguments.ss.name#" value="#htmleditformat(selectedValue1)#" /> </div><div style="float:right; text-align:right; width:50%;"><cfif arguments.ss.range><cfif arguments.ss.middleLabel NEQ "">#arguments.ss.middleLabel#</cfif><input type="text" onkeyup="zExpShowUpdateBar(#zValue+6#, 'block');" onclick="zCacheSliderValues[this.id]=this.value;this.value='';" onblur="if(this.value==''){this.value=zCacheSliderValues[this.id];} zExpShowUpdateBar(#zValue+6#, 'none');zInputSliderSetValue('#arguments.ss.name2#',#zValue#,#zValue+3#,this.value,#zValue+6#, 2);" style="width:#arguments.ss.fieldWidth#px;" name="#arguments.ss.name2#_label" value="#htmleditformat(label2value)#" id="#arguments.ss.name2#_label" /><input type="hidden" name="#arguments.ss.name2#" id="#arguments.ss.name2#" value="#htmleditformat(selectedValue2)#" /><cfif arguments.ss.rightLabel NEQ "">#arguments.ss.rightLabel#</cfif></cfif></div><br style="clear:both;" />
<div id="zInputSliderBox#zValue#" class="zSliderBgDiv" style="width:100%<!--- #arguments.ss.width#px --->; overflow:hidden;">
<div id="zInputDragBox1_#zValue#" style="z-index:1;width:10px; height:15px; cursor:pointer; text-align:center; float:left;margin-left:#marginLeft#px; "><img src="/z/a/images/slider.jpg" alt="Click and drag this slider" width="10" height="15" style="float:left;" /></div>
<cfif arguments.ss.range>
<div id="zInputDragBox2_#zValue#" onmouseup="this.style.position='';" style="z-index:2; float:right; margin-right:#marginRight#px; width:10px; height:15px; cursor:pointer;text-align:center; "><img src="/z/a/images/slider.jpg" alt="Click and drag this slider" width="10" height="15" style="float:left;" /></div></cfif>
</div>
<div id="zInputSliderBottomBox_#zValue#" style="display:none;width:100%; float:left; clear:both;"></div>
<script type="text/javascript">
/* <![CDATA[ */
zArrDeferredFunctions.push(function(){
zValues[#zValue#]="#JSStringFormat(arraytolist(arrLabels,chr(10)))#".split("\n");
zValues[#zValue+1#]="#JSStringFormat(arraytolist(arrValues,chr(10)))#".split("\n");
zValues[#zValue+2#]="<cfif selectedValue1 NEQ "">#selectedValue1#<cfelse>min</cfif>";
zValues[#zValue+3#]="<cfif selectedValue2 NEQ "">#selectedValue2#<cfelse>max</cfif>";
zValues[#zValue+4#]="<cfif label1value NEQ "">#label1value#<cfelse></cfif>";
zValues[#zValue+5#]="<cfif label2value NEQ "">#label2value#<cfelse></cfif>";
<cfif arguments.ss.range>
zSetSliderInputArray("#arguments.ss.name#_label");
zSetSliderInputArray("#arguments.ss.name2#_label");
zDrag_makeDraggable(document.getElementById("zInputDragBox1_#zValue#"),{callbackFunction:zInputSlideLimit,boxObj:"zInputSliderBox#zValue#",constrainObj:"zInputDragBox2_#zValue#",constrainLeft:false,labelId:"#arguments.ss.name#_label",valueId:"#arguments.ss.name#",zValue:#zValue#,zValueValue:#zValue+2#,zValueLabel:#zValue+4#,zExpOptionValue:#zValue+6#,range:#arguments.ss.range#});
zDrag_makeDraggable(document.getElementById("zInputDragBox2_#zValue#"),{callbackFunction:zInputSlideLimit,boxObj:"zInputSliderBox#zValue#",constrainObj:"zInputDragBox1_#zValue#",constrainLeft:true,labelId:"#arguments.ss.name2#_label",valueId:"#arguments.ss.name2#",zValue:#zValue#,zValueValue:#zValue+3#,zValueLabel:#zValue+5#,zExpOptionValue:#zValue+6#,range:#arguments.ss.range#});
<cfelse>
zDrag_makeDraggable(document.getElementById("zInputDragBox1_#zValue#"),{callbackFunction:zInputSlideLimit,boxObj:"zInputSliderBox#zValue#",labelId:"#arguments.ss.name#_label",valueId:"#arguments.ss.name#",zValue:#zValue#,zValueValue:#zValue+2#,zValueLabel:#zValue+4#,zExpOptionValue:#zValue+6#,range:#arguments.ss.range#});
</cfif>
});
/* ]]> */
</script>
</cfsavecontent>
	<cfscript>
	if(arguments.ss.output){
		writeoutput(output);
	}else{
		rs=structnew();
		rs.zValue=zValue;
		rs.zExpOptionValue=zValue+6;
		rs.output=output;
		if(selectedValue1 NEQ ""){
			rs.value=selectedValue1;
		}else{
			rs.value="min";	
		}
		if(arguments.ss.range){
			if(selectedValue2 NEQ ""){
				rs.value&="-"&selectedValue2;
			}else{
				rs.value&="-max";
			}
		}
		return rs;	
	}
	</cfscript>
</cffunction>
    
    
    
    
    
    
    <cffunction name="selectCountry" localmode="modern" returntype="any" output="false">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var tempString = "";
	arguments.ss.data.delimiter=chr(9);
	arguments.ss.data.labels="afghanistan	albania	algeria	american samoa	andorra	angola	anguilla	antarctica	antigua and barbuda	argentina	armenia	aruba	ashmore and cartier isl	australia	austria	azerbaijan	bahamas, the	bahrain	baker island	bangladesh	barbados	bassas da india	belarus	belgium	belize	benin	bermuda	bhutan	bolivia	bosnia and herzegovina	botswana	bouvet island	br indian ocean terr	brazil	british virgin is.	brunei	bulgaria	burkina	burma	burundi	cambodia	cameroon	canada	cape verde	cayman islands	central african rep.	chad	chile	china	christmas island	clipperton island	cocos (keeling) islands	colombia	comoros	congo	congo, democratic republic of the	cook islands	coral sea islands	costa rica	cote d'ivoire	croatia	cuba	cyprus	czech republic	denmark	djibouti	dominica	dominican republic	ecuador	egypt	el salvador	equatorial guinea	eritrea	estonia	ethiopia	europa island	falkland (is malvinas)	faroe islands	fed states micronesia	fiji	finland	fr so & antarctic lnds	france	french guiana	french polynesia	gabon	gambia, the	gaza strip	georgia	germany	ghana	gibraltar	glorioso islands	greece	greenland	grenada	guadeloupe	guam	guatemala	guernsey	guinea	guinea-bissau	guyana	haiti	heard is&mcdonald isls	honduras	hong kong	howland island	hungary	iceland	india	indonesia	iran	iraq	ireland	israel	italy	jamaica	jan mayen	japan	jarvis island	jersey	johnston atoll	jordan	juan de nova island	kazakhstan	kenya	kingman reef	kiribati	korea, republic of	korea,dem peoples rep	kosovo	kuwait	kyrgyzstan	laos	latvia	lebanon	lesotho	liberia	libya	liechtenstein	lithuania	luxembourg	macau	macedonia	madagascar	malawi	malaysia	maldives	mali	malta	man, isle of	marshall islands	martinique	mauritania	mauritius	mayotte	mexico	midway island	moldova	monaco	mongolia	montenegro	montserrat	morocco	mozambique	namibia	nauru	navassa island	nepal	netherlands	netherlands antilles	new caledonia	new zealand	nicaragua	niger	nigeria	niue	norfolk island	northern mariana is	norway	oman	pakistan	palmyra atoll	panama	papua new guinea	paracel islands	paraguay	paulau republic of	peru	philippines	pitcairn islands	poland	portugal	puerto rico	qatar	reunion	romania	russia	rwanda	s.georgia/s.sandwic is	san marino	sao tome and principe	saudi arabia	senegal	serbia	seychelles	sierra leone	singapore	slovakia	slovenia	solomon islands	somalia	south africa	south sudan	spain	spratly islands	sri lanka	st lucia	st. helena	st. kitts and nevis	st. pierre and miquelon	st. vincent/grenadines	sudan	suriname	svalbard	swaziland	sweden	switzerland	syria	taiwan	tajikistan	tanzania, united rep of	thailand	timor-leste	togo	tokelau	tonga	trinidad and tobago	tromelin island	tunisia	turkey	turkmenistan	turks and caicos isl	tuvalu	u.s. minor outlying isl	uganda	ukraine	united arab emirates	united kingdom	united states	uruguay	uzbekistan	vanuatu	vatican city	venezuela	vietnam	virgin islands	wake island	wallis and futuna	west bank	western sahara	western samoa	yemen	yugoslavia	zambia	zimbabwe";
	arguments.ss.data.values="AF	AL	AG	AQ	AN	AO	AV	AY	AC	AR	AM	AA	AT	AS	AU	AJ	BF	BA	FQ	BG	BB	BS	BO	BE	BH	BN	BD	BT	BL	BK	BC	BV	IO	BR	VI	BX	BU	UV	BM	BY	CB	CM	CA	CV	CJ	CT	CD	CI	CH	KT	IP	CK	CO	CN	CF	CG	CW	CR	CS	IV	HR	CU	CY	EZ	DA	DJ	DO	DR	EC	EG	ES	EK	ER	EN	ET	EU	FK	FO	FM	FJ	FI	FS	FR	FG	FP	GB	GA	GZ	GG	GM	GH	GI	GO	GR	GL	GJ	GP	GQ	GT	GK	GV	PU	GY	HA	HM	HO	HK	HQ	HU	IC	IN	ID	IR	IZ	EI	IS	IT	JM	SJ	JA	DQ	JE	JQ	JO	JU	KZ	KE	KQ	KR	KS	KN	KV	KU	KG	LA	LG	LE	LT	LI	LY	LS	LH	LU	MC	MK	MA	MI	MY	MV	ML	MT	IM	RM	MB	MR	MP	MF	MX	MQ	MD	MN	MG	MJ	MS	MO	MZ	WA	NR	BQ	NP	NL	NT	NC	NZ	NU	NG	NI	NE	NF	CQ	NO	MU	PK	LQ	PM	PP	PF	PA	PS	PE	RP	PC	PL	PO	RQ	QA	RE	RO	RS	RW	SX	SM	TP	SA	SG	RI	SE	SL	SN	LO	SI	BP	SO	SF	OD	SP	PG	CE	ST	SH	SC	SB	VC	SU	NS	SV	WZ	SW	SZ	SY	TW	TI	TZ	TH	TT	TO	TL	TN	TD	TE	TS	TU	TX	TK	TV	UM	UG	UP	AE	UK	US	UY	UZ	NH	VT	VE	VM	VQ	WQ	WF	WE	WI	WS	YM	YI	ZA	ZI";
	this.select(argument.ss);
	</cfscript>
</cffunction>

<cffunction name="selectState" localmode="modern" returntype="any" output="false">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var tempString = "";
	arguments.ss.data.values="AL,AK,AZ,AR,CA,CO,CT,DE,DC,FL,GA,HI,ID,IL,IN,IA,KS,KY,LA,ME,MD,MA,MI,MN,MS,MO,MT,NE,NV,NH,NJ,NM,NY,NC,ND,OH,OK,OR,PA,RI,SC,SD,TN,TX,UT,VT,VA,WA,WV,WI,WY";
	arguments.ss.data.labels="Alabama,Alaska ,Arizona,Arkansas ,California,Colorado,Connecticut,Delaware,District of Columbia,Florida,Georgia,Hawaii,Idaho,Illinois,Indiana,Iowa,Kansas,Kentucky,Louisiana,Maine ,Maryland,Massachusetts,Michigan,Minnesota,Mississippi,Missouri,Montana,Nebraska,Nevada ,New Hampshire,New Jersey,New Mexico,New York ,North Carolina,North Dakota ,Ohio,Oklahoma,Oregon,Pennsylvania,Rhode Island,South Carolina,South Dakota,Tennessee,Texas,Utah,Vermont,Virginia,Washington,West Virginia,Wisconsin,Wyoming";
	this.select(argument.ss);
	</cfscript>
</cffunction>
    
    
<cffunction name="zFakeFormFieldsNotEmpty" localmode="modern" output="yes" access="public" returntype="any">
	<cfscript>
	if(trim(application.zcore.functions.zso(form, 'form_first_name')&application.zcore.functions.zso(form, 'form_last_name')&application.zcore.functions.zso(form, 'form_comments')) NEQ ""){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="zFakeFormFields" localmode="modern" output="yes" access="public" returntype="any">
	<cfset local.tick=gettickcount()>
	<table id="zInqTheFormNames#local.tick#">
        <tr>
            <td>First Name</td>
            <td><input name="form_first_name" type="text"  autocomplete="off" maxlength="50" value="" /><span class="highlight"> * Required</span></td>
        </tr>
        <tr>
            <td>Last Name</td>
            <td><input name="form_last_name" type="text"  autocomplete="off" maxlength="50" value="" /></td>
        </tr>
        <tr>
            <td>Comments</td>
            <td><textarea name="form_comments" cols="50" autocomplete="off" rows="5"></textarea></td>
        </tr>
    </table>
    <script type="text/javascript">
    var tFN32=document.getElementById("zInqTheF"+"ormNames#local.tick#");tFN34="ne";tFN32.style.display="no"+tFN34;
    </script>
</cffunction>
    

</cfoutput>
</cfcomponent>