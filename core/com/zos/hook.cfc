<cfcomponent>
	<!--- 
	addListener
	removeListener
	runEvent
	endHook
	hasListeners
	 --->
	<cfscript>
	variables.eventStruct=structnew();
	//variables.arrSubscriber=arraynew(1);
	//variables.arrSubscriberListeners=arraynew(1);
    </cfscript>
    <cffunction name="getVariables" localmode="modern" access="public">
    <cfreturn variables>
    </cffunction>
	<cffunction name="add" localmode="modern" access="public" returntype="string">
		<cfargument name="module" type="string" required="yes">
		<cfargument name="event" type="string" required="yes">
		<cfargument name="object" type="struct" required="yes" hint="{object=objectName, functionName='udfFunction'} or {function=udfFunction}">
        <cfscript>
		var moduleEventStruct=0;
		if(structkeyexists(variables.eventStruct, arguments.module) EQ false){
			variables.eventStruct[arguments.module]={};
		}
		moduleEventStruct=variables.eventStruct[arguments.module]
		if(structkeyexists(moduleEventStruct, arguments.event) EQ false){
			moduleEventStruct[arguments.event]={
				arrListener=[]
			}
		}
		if(arrayfind(moduleEventStruct[arguments.event].arrListener, arguments.object) NEQ 0){
			Throw(type="DuplicateListener",message="The object method or function has already been assign to this event: """&arguments.event&""".");
		}
		if(structkeyexists(arguments.object, 'object')){
			if(structkeyexists(arguments.object, 'functionName') EQ false){
				arguments.object.functionName="on"&arguments.event;
			}
		}
		arrayappend(moduleEventStruct[arguments.event].arrListener, arguments.object);
		return true;
		</cfscript>
	</cffunction>
    
    
	<cffunction name="remove" localmode="modern" access="public" returntype="string">
		<cfargument name="module" type="string" required="yes">
		<cfargument name="event" type="string" required="yes">
		<cfargument name="object" type="any" required="yes">
        <cfscript>
		var listenerPosition=arrayfind(variables.eventStruct[arguments.module][arguments.event].arrListener, arguments.object);
		if(listenerPosition NEQ 0){
			arraydeleteat(variables.eventStruct[arguments.module][arguments.event].arrListener, listenerPosition);
			return true;
		}else{
			return false;
		}
		</cfscript>
        
	</cffunction>
    
	<cffunction name="trigger" localmode="modern" access="public" returntype="string">
		<cfargument name="event" type="string" required="yes">
		<cfargument name="argumentCollection" type="struct" required="yes">
        <cfscript>
		var i=1;
		var n=0;
		var d=0;
		var d2=0;
		var currentListener=0;
		arguments.argumentCollection.dataStruct={};
		/*for(i=1;i LTE arraylen(variables.arrSubscriber);i++){
			if(structkeyexists(variables.arrSubscriber[i], 'on'&arguments.event)){
				variables.arrSubscriber[i]["on"&arguments.event](argumentCollection=arguments.argumentCollection);
			}
		}*/
		for(n in application.sitestruct[request.zos.globals.id].app.appCache){
			if(structkeyexists(variables.eventStruct, application.zcore.appComPathStruct[n].name)){
				d=variables.eventStruct[application.zcore.appComPathStruct[n].name];
				if(structkeyexists(d, arguments.event)){
					d2=d[arguments.event];
					for(i=1;i LTE arraylen(d2.arrListener);i++){
						currentListener=d2.arrListener[i];
						if(structkeyexists(currentListener, 'dataStruct')){
							arguments.argumentCollection.dataStruct=currentListener.dataStruct;
						}else{
							arguments.argumentCollection.dataStruct={};
						}
						if(structkeyexists(currentListener, 'object')){
							if(structkeyexists(currentListener.object, currentListener.functionName)){
								currentListener.object[currentListener.functionName](argumentCollection=arguments.argumentCollection);
							}else{
								// listener doesn't implement currentListener.functionName
							}
						}else{
							currentListener.function(argumentCollection=arguments.argumentCollection);
						}
					}
				}
			}
		}
		</cfscript>
	</cffunction>
    
    <cffunction name="onTestEvent" localmode="modern" access="public">
    	<cfargument name="param1" type="string" required="yes">
        <cfscript>
		writedump(arguments);
		</cfscript>
    </cffunction>
    
    
    <cffunction name="hookTest" localmode="modern" access="remote">
    	<cfscript>
		var a={param1="test"};
		var b=false;
		var result=this.add("content", "event", {object=this, functionName="onTestEvent"});
		writeoutput('add result:'&result&'<br />');
		if(b){
			trace text="true";
		}else{
			trace text="false";
		}
			
		this.trigger("event", a);
		result=this.remove("content", "event", {object=this, functionName="onTestEvent"});
		writeoutput('remove result:'&result&'<br />');
		this.trigger("event", a);
		result=this.add("content", "event", {function=this.onTestEvent});
		writeoutput('add result:'&result&'<br />');
		this.trigger("event", a);
		result=this.remove("content", "event", {function=this.onTestEvent});
		writeoutput('remove result:'&result&'<br />');
		this.trigger("event", a);
		
		result=this.add("content", "event", {function=this.onTestEvent, dataStruct={value1="value1"}});
		writeoutput('add result:'&result&'<br />');
		this.trigger("event", a);
		
		/*
		result=this.addSubscriber(this);
		writeoutput('addSubscriber result:'&result&'<br />');
		this.trigger("testEvent", a);
		result=this.removeSubscriber(this);
		writeoutput('removeSubscriber result:'&result&'<br />');
		this.trigger("testEvent", a);
		*/
		</cfscript>
        <br />Done.
    </cffunction>
    
<!--- 
Hooks:
blog.articleEditCustomFields
blog.articleSave
blog.articleSaveComplete
blog.articleDelete
blog.categorySave
blog.categorySaveComplete
blog.categoryDelete
blog.tagSave
blog.tagSaveComplete
blog.tagDelete

--->
    
    <!--- 
	<cffunction name="addSubscriber" localmode="modern" access="public" returntype="string">
		<cfargument name="listenerObject" type="component" required="yes" hint="Register an object that implements some or all of the events.">
        <cfscript>
		var listenerPosition=arrayfind(variables.arrSubscriber, arguments.listenerObject);
		if(listenerPosition NEQ 0){
			Throw(type="DuplicateListener",message="The object method or function has already been assign to this event: """&arguments.event&""".");
		}else{
			arrayappend(variables.arrSubscriber, arguments.listenerObject);
		}
		return true;
		</cfscript>
	</cffunction>
    
    
	<cffunction name="removeSubscriber" localmode="modern" access="public" returntype="string">
		<cfargument name="listenerObject" type="component" required="yes" hint="Register an object that implements some or all of the events.">
        <cfscript>
		var listenerPosition=arrayfind(variables.arrSubscriber, arguments.listenerObject);
		if(listenerPosition NEQ 0){
			arraydeleteat(variables.arrSubscriber, listenerPosition);
			return true;
		}else{
			return false;
		}
		</cfscript>
	</cffunction> --->
    <!--- 
	<cffunction name="addSubscriber" localmode="modern" access="public" returntype="string">
		<cfargument name="object" type="component" required="yes" hint="Object that triggers events.">
		<cfargument name="listenerObject" type="component" required="yes" hint="Register an separate object that implements some or all of the object's events.">
        <cfscript>
		var listenerPosition=0;
		var objectPosition=arrayfind(variables.arrSubscriber, arguments.object);
		if(objectPosition NEQ 0){
			listenerPosition=arrayfind(variables.arrSubscriberListener[objectPosition], arguments.object);
			if(listenerPosition NEQ 0){
				Throw(type="DuplicateListener",message="The object method or function has already been assign to this event: """&arguments.event&""".");
			}else{
				arrayappend(variables.arrSubscriberListener[objectPosition], arguments.listenerObject);
			}
		}else{
			arrayappend(variables.arrSubscriber, arguments.object);
			variables.arrSubscriberListener[arraylen(variables.arrSubscriber)]=[arguments.listenerObject];
		}
		</cfscript>
	</cffunction>
    
    
	<cffunction name="removeSubscriber" localmode="modern" access="public" returntype="string">
		<cfargument name="object" type="component" required="yes" hint="Object that triggers events.">
		<cfargument name="listenerObject" type="component" required="yes" hint="Register an separate object that implements some or all of the object's events.">
        <cfscript>
		var listenerPosition=0;
		var objectPosition=arrayfind(variables.arrSubscriber, arguments.object);
		if(objectPosition NEQ 0){
			listenerPosition=arrayfind(variables.arrSubscriberListener[objectPosition], arguments.object);
			if(listenerPosition NEQ 0){
				arraydeleteat(variables.arrSubscriberListener[objectPosition], listenerPosition);
				if(arraylen(variables.arrSubscriberListener[objectPosition]) EQ 0){
					arraydeleteat(variables.arrSubscriber, objectPosition);
				}
				return true;
			}else{
				return true;
			}
		}else{
			return false;
		}
		</cfscript>
	</cffunction> --->
</cfcomponent>