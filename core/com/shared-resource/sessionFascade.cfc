<!--- 
example of using IOC for automatic scope cfc dependency injection:

// user.cfc with read/write access to session:
<cfcomponent accessors="true" ioc:enabled="true" ioc:singleton="true" ioc:init="init">
<cfproperty name="sessionKeyInstance" type="zcorerootmapping.com.shared-resource.SessionKey" setter="true" ioc:argumentCollection="#{ key: 'user'}#">
<cfscript> 
// IDE hack for code completion to work
if(1==0){
	variables.sessionKeyInstance=createobject("component", "zcorerootmapping.com.shared-resource.SessionKey"); 
}
</cfscript>
<cffunction name="login" localmode="modern">
	<cfargument name="password" type="string" required="yes">
	<cfscript>
	if(arguments.password EQ "secret"){
		variables.sessionKeyInstance.set("loggedIn", true);
	}
	</cfscript>
</cffunction>
</cfcomponent>
decorator pattern should be used on the user.cfc to reduce it to the functionality that email is actually using (i.e. readonly, not doing logins, etc)

// email.cfc with only read access to session
<cfcomponent ioc:singleton="true" ioc:init="init">
<cfproperty name="usersessionKeyInstance" type="zcorerootmapping.com.shared-resource.SessionKeyReadOnly" ioc:enabled="true" ioc:init="init" ioc:readonly="true" ioc:singleton="true">
<cffunction name="send" localmode="modern">
	<cfscript>
	variables.user.getName();
	
	if(arguments.password EQ "secret"){
		variables.sessionKeyInstance.set("loggedIn", true);
	}
	</cfscript>
</cffunction>
</cfcomponent>
 --->
<cfcomponent displayname="Status Message System" hint="" output="no">
<cfoutput>   
<!--- <cffunction name="init" localmode="modern" access="public" output="no">
<cfargument name="config" type="struct" required="no" default="#{}#">
<cfscript>
	var root=expandPath("/");
	var configDefault={
		sessionKey:"zStatusStruct"
	};
	structappend(variables, configDefault, true);
	structappend(variables, arguments.config, true);
	variables.initRun=true;
</cfscript>
</cffunction>

<cffunction name="initSession" localmode="modern" access="private" returntype="any" output="no">
<cfscript>
	if(not structkeyexists(variables,'initRun')){
		this.init();
	}
	if(not structkeyexists(session, variables.sessionKey)){
		session[variables.sessionKey] = {
			count = 0,
			id = 0,
			dataCount = 0
		};
	}
	</cfscript>
</cffunction>

<!--- statusCom.getStruct(id); --->
<cffunction name="getStruct" localmode="modern" access="public" returntype="any" output="false">
	<cfargument name="id" type="string" required="yes">
<cfscript>
	var local={};
	if(not structkeyexists(variables, 'initRun') or not structkeyexists(session, variables.sessionKey)) variables.initSession();
	</cfscript>
	<cfif isNumeric(arguments.id) EQ false>
		<cfif find("@",arguments.id) NEQ 0>
			Invalid Request
			<cfscript>
			application.zcore.functions.zabort();
			</cfscript>
		</cfif>
	</cfif>
	<cfscript>
	if(structkeyexists(session[variables.sessionKey], arguments.id)){// and structkeyexists(session[variables.sessionKey][arguments.id], 'varStruct')){
		return session[variables.sessionKey][arguments.id];
	
	}else{
		// force it to exist and then return it
		session[variables.sessionKey][arguments.id]={
			arrMessages = ArrayNew(1),
			arrErrors = ArrayNew(1),
			errorStruct = StructNew(),
			varStruct = StructNew(),
			errorFieldStruct = StructNew()
		};
		if(structkeyexists(session[variables.sessionKey],'count') EQ false or arguments.id GT session[variables.sessionKey].count){
			session[variables.sessionKey].count = arguments.id;
		}
		return session[variables.sessionKey][arguments.id];
	}
	</cfscript>
</cffunction>

<!--- statusCom.getNewId(); --->
<cffunction name="getNewId" localmode="modern" access="public" returntype="any" output="false" hint="Create new id">
	<cfscript>
	if(not structkeyexists(variables, 'initRun') or not structkeyexists(session, variables.sessionKey)) variables.initSession();
	if(isnumeric(session[variables.sessionKey].count) EQ false){
		session[variables.sessionKey].count=0;
	}
	session[variables.sessionKey].id = session[variables.sessionKey].count+1;
	session[variables.sessionKey].count = session[variables.sessionKey].id;
	return session[variables.sessionKey].id;
	</cfscript>
</cffunction>


<!--- statusCom.deleteId(id); --->
<cffunction name="deleteId" localmode="modern" access="public" returntype="any" output="false" hint="Delete status id">
	<cfargument name="id" type="numeric" required="yes">
	<cfscript>
	if(structkeyexists(session, variables.sessionKey) and structkeyexists(session[variables.sessionKey], arguments.id)){
		structdelete(session[variables.sessionKey], arguments.id);
	}
	</cfscript>
</cffunction>

<!--- statusCom.deleteSessionData(); --->
<cffunction name="deleteSessionData" localmode="modern" access="public" returntype="any" output="false" hint="Delete status id">
	<cfscript>
	structdelete(session, variables.sessionKey);
	structdelete(variables, 'statusStruct');
	</cfscript>
</cffunction>
	 
	
<!--- statusCom.setStatus(id, status, varStruct, error); --->
<cffunction name="setStatus" localmode="modern" access="public" returntype="any" output="false">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="status" type="any" required="no" default="#false#">
	<cfargument name="varStruct" type="any" required="no" default="#StructNew()#">
	<cfargument name="error" type="boolean" required="no" default="#false#">
<cfscript>
	var local=structnew();
	var statusStruct=0;
	if(not structkeyexists(variables, 'initRun') or not structkeyexists(session, variables.sessionKey)) variables.initSession();
	</cfscript>
	<cfif isNumeric(arguments.id) EQ false>
		<cfif find("@",arguments.id) NEQ 0>
			Invalid Request
			<cfscript>
			application.zcore.functions.zabort();
			</cfscript>
		<cfelse>
			<cfscript>
			application.zcore.template.fail("zcorerootmapping.com.zos.status.cfc: setStatus: id must be numeric");
			</cfscript>
		</cfif>
	</cfif>
	<cfscript>
	statusStruct = this.getStruct(arguments.id);
	if(arguments.status NEQ false){
		session[variables.sessionKey].dataCount++;
		if(arguments.error){
			local.exists=false;
			for(local.i=1;local.i LTE arraylen(statusStruct.arrErrors);local.i++){
				if(statusStruct.arrErrors[local.i] EQ arguments.status){
					local.exists=true;	
					break;
				}
			}
			if(local.exists EQ false){
				ArrayAppend(statusStruct.arrErrors, arguments.status);	
			}
		}else{
			local.exists=false;
			for(local.i=1;local.i LTE arraylen(statusStruct.arrMessages);local.i++){
				if(statusStruct.arrMessages[local.i] EQ arguments.status){
					local.exists=true;	
					break;
				}
			}
			if(local.exists EQ false){
				ArrayAppend(statusStruct.arrMessages, arguments.status);
			}
		}
	} 
	if(structkeyexists(session[variables.sessionKey],'dataStruct') EQ false){
		session[variables.sessionKey].dataStruct=0;
	}
	if(isStruct(arguments.varStruct)){
		session[variables.sessionKey].dataCount++;
		StructAppend(statusStruct.varStruct, arguments.varStruct, true);
	}
	return arguments.id;
	</cfscript>
</cffunction>

<!--- statusCom.get(id, fieldName, defaultValue); --->
<cffunction name="get" localmode="modern" access="public" returntype="any" output="false">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="defaultValue" type="any" required="no" default="">
	<cfargument name="forceToExist" type="boolean" required="no" default="#false#">
	<cfscript>
	if(not structkeyexists(variables, 'initRun') or not structkeyexists(session, variables.sessionKey)) variables.initSession();
	if(isDefined('session.zos') and structkeyexists(session[variables.sessionKey],arguments.id) and structkeyexists(session[variables.sessionKey][arguments.id].varStruct, arguments.fieldName)){
		return session[variables.sessionKey][arguments.id].varStruct[arguments.fieldName];
	}else{
		if(arguments.forceToExist){
			var statusStruct = this.getStruct(arguments.id);
			statusStruct[arguments.fieldName]=arguments.defaultValue;
		}
		return arguments.defaultValue;
	}
	</cfscript>
</cffunction>



<!--- statusCom.set(id, fieldName, value); --->
<cffunction name="set" localmode="modern" access="public" returntype="any" output="false">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="value" type="any" required="yes">
	
	<cfscript>
	var statusStruct=0;
	if(not structkeyexists(variables, 'initRun') or not structkeyexists(session, variables.sessionKey)) variables.initSession();
	statusStruct = this.getStruct(arguments.id);
	StructInsert(statusStruct.varStruct, arguments.fieldName, arguments.value, true);
	</cfscript>
</cffunction>

     --->
</cfoutput>
</cfcomponent>