<!---
TODO: i can create all the scope cfcs onapplicationstart, and then just duplicate them when using newScope() function

use the new immutable component
	a large number of calls is about 50% slower, but with just a few, it is 100% slower.  This is acceptable for shared scope data / threaded only.
	
	test with cfc that isn't immutable passed to init.
scope.cfc MUST be duplicated for each scope so the scope doesn't have to be stored in the CFC.  This prevents session from being accidentally stored in application scope.
	instead of duplicating the code, I could generate all of the scope CFCs by setting scope as a ##scope## string, and replace them with the actual scope.  I would do this running an admin task on the cfc before uploading archive to production.
	
	You can ONLY pass immutable CFC or simple values to sessionScope.set().  This makes it safer whenever we pull data out with sessionScope.get()
	
	if I pass an instanceOf immutableCFC to sessionKeyScopeWrite, then I can use both sessionKeyScopeRead and sessionKeyScopeWrite to read/write it from the shared scope without needing to lock.
	
	make a read only version of sessionKeyScopeRead that doesn't have <cflock>, and also doesn't have the set/delete functions
	
	when the code MUST have write, then pass an instance of sessionKeyScopeWrite, which has cflock.
	
	don't allow storing complex objects with sessionKeyScopeWrite so that they can't be changed outside of the object.
	instead of storing a complex object, we should have a bulkSet function.  This will take a struct of strings as an argument, and set all the keys at once in one lock, but when you read it back, an immutable struct will be created with structappend(newStruct, session.struct); return newStruct;
	
	
	generate a second set of templates for the sub-scope so i can have read-only keys.

	function get(key, default){
		variables.key
	}
	
	in addition to scope.cfc, I must be able to limit a second cfc instance to just a key within the scope.
		s=createobject("component", "sessionKeyScope");
		// maybe a third:
		s=createobject("component", "sessionKeyKeyScope");
	
	s=createobject("component", "sessionScope");
	s.init();
	
	function newScope(key, readonly){
		var currentKeyScopeIndex=variables.keyScopeIndex;
		var keyScopeInstance=createobject("component", "sessionKeyScope");
		ts={
			key: arguments.key,
			readOnly: arguments.readOnly,
			keyScopeIndex: currentKeyScopeIndex,
			keyScopeInstance: keyScopeInstance,
			scopeInstance: this
		}
		variables.keyScopeStruct[currentKeyScopeIndex]=ts;
		var immutable=immutableFactory.struct(ts);
		keyScope.setImmutable(immutable);
		
	// keyScope get
	get(key, default){
		
		if(not structkeyexists(session, variables.key) or not structkeyexists(session[variables.key], arguments.key)){
			//throw('arguments.key, "#arguments.key#", is undefined in session["#variables.key#"]');
			return arguments.default;
		}else{
			return session[variables.key][arguments.key];
		}
	}
	set(key, value){
		if(not structkeyexists(session, variables.key)){
			session[variables.key]=structnew('linked');
		}
		if(isNull(arguments.value) or (isObject(arguments.value) and not structkeyexists(arguments.value, '$__isImmutableObject'))){ // isArray(arguments.value) or isStruct(arguments.value) or 
			throw("Only simple values and immutable objects can be passed as a value.");
		}
		session[variables.key][arguments.key]=arguments.value;
	}
	delete(key){
		structdelete(session[variables.key], arguments.key);
	}
	dump(){
		writedump(session[variables.key]);
	}
	
	
		session[variables.immutable.getKey()][arguments.key], variables.immutable);
		var key=variables.immutable.get("key");
		var key=variables.immutable.get("scopeInstance");
		if(structkeyexists(session, 
		
		variables.key='data';
		variables.readonly=true; // read only cfcs must use only simple values for all keys because array, struct, cfc would require duplicate() which is slower performance.
	
	append(struct of simple values)
		for(var i in arguments.struct){
			if(isSimpleValue(arguments.struct[i])){
				set..
			}
		}
	}
	
	init(struct ss){
		structappend(variables, arguments.ss, true); if(structkeyexists(arguments.ss, 'key')){
			variables.key=arguments.ss.key;
		}
		string key)
	
	addListener
		cfcInstance
		// will fire event onScopeKeyChange  onBeforeScopeKeyChange in the cfc after or before the change occurs- maybe other events...
	removeListener
		cfcInstance
	addKeyListener
		cfcInstance
	removeKeyListener
		cfcInstance
	flush (deletes all keys in current level of scope)
	
	keyExists(string required key)
	
	delete(string required key)
	get(string required key)
		return structget(variables.baseKey)[arguments.key];
		
	newScope(string required key, boolean readOnly)
		if(not this.keyExists(arguments.key)){
			this.set(key, {});
		}
		var s=createobject("component", "sessionKeyScope");
		s.init({
			key:arguments.key, 
			readOnly: arguments.readOnly
		});
		return s;
		
		s.newScope('data', true);
		key will be created as struct and passed to the init function of the new scope cfc
		no other scope can read/write data to the newScope once it is created.
		increment a uniqueId for each key and assign that id to the newScope init function.  This is used to verified the calling function matches the called function's id, and no other object in system is able to touch the data.
		
		must have be able to reference the parent scope?
		
		must reference a struct value in the scope or it throws an exception
	getAsReadOnlyScope
	set(string required key, any required value)
	allow disabling put function on a specific instance of the scope.cfc
	// private
		getAsScope must attach the child CFC to the key in a private lookup table, so we can determine if an object exists that is using that key.
	
wrap scope with cfc.  data is stored in variables
	test automatic getter/setter functions for cfc properties
	i.e. user session data wrapped by CFC object to prevent direct read access everywhere else.
	
	application.zcore.sessionScope=createObject("component", "scope");
	var s=application.zcore.sessionScope;
	s.init({
		key: "user"
	});
	s.
	variables.init
 
 --->
 <cfcomponent hint="This allows for dependency injection of any global scope including server,application,session,request,cookie,client,cluster.  It also provides the ability to register other components for onScopeStart and onScopeEnd events, which provides consistent locking mechanism when those events occur, example: onApplicationStart() will call onScopeStart for the instance of scope.cfc that was created for the server scope." accessors="yes">
	<!--- <cfproperty name="scope" type="struct" getter="yes" setter="yes"> --->
    <cfoutput><cfscript>
	variables.arrRegisteredComponents=arraynew(1);
	</cfscript>
<!--- 	<cfscript>
	variables.scope=false; // don't allow using this component directly.  Errors will be thrown intentionally when this is not set.
	</cfscript> --->
    
    <cffunction name="init" localmode="modern" access="public" output="no" returntype="scope" z:ioc:init="true">
    	<cfargument name="ioc" type="zcorerootmapping.com.zos.ioc" required="yes">
    	<cfargument name="scope" type="struct" required="yes">
    	<cfargument name="scopeName" type="string" required="yes">
    	<cfscript>
		variables.ioc=arguments.ioc;
		variables.scope=arguments.scope;
		variables.scopeName=arguments.scopeName;
		this.scope=arguments.scope;
		return this;
		</cfscript>
    </cffunction>
    
    
    
    <!--- component with the zcorerootmapping.interface.IScope interface are auto-registered. --->
    <cffunction name="registerEventListener" localmode="modern" output="no" returntype="any">
    	<cfargument name="component" type="string" required="yes">
<!---         <cfargument name="onScopeStartMethod" type="string" required="yes">
        <cfargument name="onScopeEndMethod" type="string" required="yes" default=""> --->
        <cfscript>
		arrayappend(variables.arrRegisteredComponents, arguments.component);
		</cfscript>
    </cffunction>
    
    <cffunction name="onScopeStart" localmode="modern" output="no" returntype="boolean">
    	<cfscript>
		var local=structnew();
		</cfscript>
        <cftry>
            <cflock type="exclusive" name="zcore-#variables.scopeName#-onScopeStart" timeout="1000" throwontimeout="yes">
            	<cfscript>
                for(local.i=1;local.i LTE arraylen(variables.arrRegisteredComponents);local.i++){
                    local.r=variables.ioc.resolve(variables.arrRegisteredComponents[local.i]);
			local.m=getcomponentmetadata(local.r);
			for(local.n=1;local.n LTE arraylen(local.m.functions);local.n++){
				if(structkeyexists(local.m.functions[local.n], "z:scope:onScopeStart")){	
					local.r[local.m.functions[local.n].name]();
				}
			}   
                }
                </cfscript>
            </cflock>
        <cfcatch type="lock"><cfreturn false></cfcatch>
        </cftry>
        <cfreturn true>
    </cffunction>
		
    <cffunction name="onScopeEnd" localmode="modern" output="no" returntype="boolean">
    	<cfscript>
		var local=structnew();
		</cfscript>
        <cftry>
            <cflock type="exclusive" name="zcore-#variables.scopeName#-onScopeEnd" timeout="1000" throwontimeout="yes">
				<cfscript>
                for(local.i=1;local.i LTE arraylen(variables.arrRegisteredComponents);local.i++){
                    local.r=variables.ioc.resolve(variables.arrRegisteredComponents[local.i]);
					local.m=getcomponentmetadata(local.r);
					for(local.n=1;local.n LTE arraylen(local.m.functions);local.n++){
						if(structkeyexists(local.m.functions[local.n], "z:scope:onScopeEnd")){	
							local.r[local.m.functions[local.n].name]();
						}
					}   
                }
                </cfscript>
            </cflock>
        <cfcatch type="lock"><cfreturn false></cfcatch>
        </cftry>
        <cfreturn true>
    </cffunction>
    
    
    <!--- <cffunction name="readNoLock2" localmode="modern" access="public" output="no" returntype="any">
        <cfargument name="key" type="string" required="yes">
        <cfscript>
		return evaluate(variables.scopeName&"."&arguments.key);
		</cfscript>
    </cffunction>
    
    <cffunction name="readNoLock" localmode="modern" access="public" output="no" returntype="any">
        <cfargument name="key" type="string" required="yes">
        <cfscript>
		return variables.scope[arguments.key];
		</cfscript>
    </cffunction>
    
    <cffunction name="read" localmode="modern" access="public" output="no" returntype="struct" hint="Usage example: result=scopeCom.read('key'); if(result.success){ result.value; }else{ writedump(result); }">
        <cfargument name="key" type="string" required="yes">
        <cfargument name="timeout" type="numeric" required="no" default="10">
        <cfargument name="forceNumber" type="boolean" required="no" default="#false#">
        <cfargument name="defaultValue" type="any" required="no" default="">
        <cfscript>
		var ts=structnew();
		</cfscript>
        <cftry>
            <cflock type="readonly" name="zcore-#variables.scopeName#-scope-#arguments.key#" timeout="#arguments.timeout#" throwontimeout="yes">
            <cfscript>
			ts.success=true;
            if(arguments.forceNumber){
                if(isNumeric(arguments.defaultValue) EQ false){
                    arguments.defaultValue=0;	
                }
                if(structkeyexists(server, arguments.key)){
                    if(isNumeric(server[arguments.key])){
                        ts.value=variables.scope[arguments.key];
                    }else{
                        ts.value=arguments.defaultValue;
                    }
                }else{
                    ts.value=arguments.defaultValue;
                }
            }else{
                if(structkeyexists(variables.scope, arguments.key)){
                    ts.value=variables.scope[arguments.key];
                }else{
                    ts.value=arguments.defaultValue;	
                }
            }
			return ts;
            </cfscript>
            </cflock>
            <cfcatch type="lock">
				<cfscript>
            	ts.success=false;
				ts.cfcatch=cfcatch;
				ts.errorMessage="Lock timeout";
				return ts;
                </cfscript>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="copy" localmode="modern" access="public" output="no" returntype="struct" hint="Returns a deep copy. if(result.success){ result.value; }else{ writedump(result); } Note: deep copies of CFCs are impossible if they use the variables scope internally.">
        <cfargument name="key" type="string" required="yes">
        <cfargument name="timeout" type="numeric" required="no" default="10">
        <cfargument name="forceNumber" type="boolean" required="no" default="#false#">
        <cfargument name="defaultValue" type="any" required="no" default="">
		<cfscript>
		var ts2=structnew();
		var ts=this.read(arguments.key, arguments.timeout, arguments.forceNumber, arguments.defaultValue);
		if(ts.success){
			ts2.success=true;
			ts2.value=duplicate(ts.value);
			return ts2;
		}else{
			return ts;
		}
		</cfscript>
    </cffunction> --->
    <!--- 
    <cffunction name="write" localmode="modern" access="public" output="no" returntype="boolean">
        <cfargument name="key" type="string" required="yes">
        <cfargument name="value" type="any" requires="yes">
        <cfargument name="timeout" type="numeric" required="no" default="10">
        <cftry>
        <cflock type="exclusive" name="zcore-#variables.scopeName#-scope-#arguments.key#" timeout="#arguments.timeout#" throwontimeout="yes">
            <cfscript>
            variables.scope[arguments.key]=arguments.value;
            </cfscript>
        </cflock>
        <cfcatch type="lock"><cfreturn false></cfcatch>
        </cftry>
        <cfreturn true>
    </cffunction>
    
    
    
    <cffunction name="writeOnce" localmode="modern" access="public" output="no" returntype="boolean" hint="Writes the key only if it doesn't exist. Returns false only when write fails.">
        <cfargument name="key" type="string" required="yes">
        <cfargument name="value" type="any" requires="yes">
        <cfargument name="timeout" type="numeric" required="no" default="10">
        <cfif structkeyexists(variables.scope, arguments.key) EQ false>
        	<cftry>
            <cflock type="exclusive" name="zcore-#variables.scopeName#-scope-#arguments.key#" timeout="#arguments.timeout#" throwontimeout="yes">
                <cfscript>
                if(structkeyexists(variables.scope, arguments.key) EQ false){
                    variables.scope[arguments.key]=arguments.value;
                }
                </cfscript>
            </cflock>
            <cfcatch type="lock"><cfreturn false></cfcatch>
            </cftry>
        </cfif>
        <cfreturn true>
    </cffunction>
    
    
    
    <cffunction name="exists" localmode="modern" access="public" output="no" returntype="boolean">
        <cfargument name="key" type="string" required="yes">
		<cfscript>
		if(structkeyexists(variables.scope, arguments.key)){
			return true;
		}else{
			return false;
		}
        </cfscript>
    </cffunction>
    
    <cffunction name="delete" localmode="modern" access="public" output="no" returntype="boolean">
        <cfargument name="key" type="string" required="yes">
		<cfscript>
		return structdelete(variables.scope, arguments.key, true);
        </cfscript>
    </cffunction>
    
    <cffunction name="deleteAll" localmode="modern" access="public" output="no" returntype="boolean">
		<cfscript>
		structclear(variables.scope);
		return true;
        </cfscript>
    </cffunction>
    
    
    <cffunction name="append" localmode="modern" access="public" output="no" returntype="any">
        <cfargument name="key" type="string" required="yes">
        <cfargument name="structToAppend" type="struct" required="yes">
        <cfargument name="overwrite" type="boolean" required="no" default="#false#">
        <cftry>
        <cflock type="exclusive" name="zcore-#variables.scopeName#-scope-#arguments.key#" timeout="#arguments.timeout#" throwontimeout="yes">
			<cfscript>
            structappend(variables.scope[arguments.key], arguments.structToAppend, arguments.overwrite);
            </cfscript>
        </cflock>
        <cfcatch type="lock"><cfreturn false></cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="keyList" localmode="modern" access="public" output="no" returntype="struct">
        <cfargument name="key" type="string" required="yes">
        <cfargument name="delimiter" type="string" required="no" default=",">
        <cfscript>
		var ts=structnew();
		</cfscript>
        <cftry>
            <cflock type="readonly" name="zcore-#variables.scopeName#-scope-#arguments.key#" timeout="#arguments.timeout#" throwontimeout="yes">
				<cfscript>
                ts.success=true;
                ts.list=structkeylist(variables.scope[arguments.key], arguments.delimiter);
                return ts;
                </cfscript>
            </cflock>
            <cfcatch type="lock">
				<cfscript>
            	ts.success=false;
				return ts;
                </cfscript>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="keyArray" localmode="modern" access="public" output="no" returntype="array">
        <cfargument name="key" type="string" required="yes">
        <cfscript>
		var ts=structnew();
		</cfscript>
        <cftry>
            <cflock type="readonly" name="zcore-#variables.scopeName#-scope-#arguments.key#" timeout="#arguments.timeout#" throwontimeout="yes">
				<cfscript>
                ts.success=true;
                ts.list=structkeyarray(variables.scope[arguments.key]);
                return ts;
                </cfscript>
            </cflock>
            <cfcatch type="lock">
				<cfscript>
            	ts.success=false;
				ts.cfcatch=cfcatch;
				ts.errorMessage="Lock timeout";
				return ts;
                </cfscript>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="count" localmode="modern" access="public" output="no" returntype="numeric">
        <cfargument name="key" type="string" required="yes">
        <cflock type="readonly" name="zcore-#variables.scopeName#-scope-#arguments.key#" timeout="#arguments.timeout#" throwontimeout="yes">
        <cfscript>
		return structcount(variables.scope[arguments.key]);
		</cfscript>
        </cflock>
    </cffunction> --->
    
    </cfoutput>
</cfcomponent>