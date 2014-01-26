<cfcomponent hint="You can pass in simple values or arrays and structs of simple values, and they will be converted into an immutable (read-only) object.">
<cffunction name="setImmutableFactory" localmode="modern" access="package">
	<cfargument name="immutableFactory" type="component" required="yes">
	<cfscript>
	variables.immutableFactory=arguments.immutableFactory;
	variables.iterator=application.zcore.functions.zcreateobject("component", "immutableIterator");
	return this;
	</cfscript>
</cffunction> 
<cffunction name="init" localmode="modern" access="public" output="yes">
	<cfscript> 
	var cfcatch=0;
	var i=0;
	var element=0;
	//variables.data=structnew('linked');
	if(structkeyexists(variables, '$__immutableInitRanOnce')){
		throw("You can only run the init function once on this object to ensure its private data is immutable.");
	}
	loop index="i" item="element" array="#arguments#"{
		if(isSimpleValue(element) or isNull(element) or (isObject(element) and structkeyexists(element, '$__isImmutableObject'))){
		}else if(isArray(element)){
			if(isbinary(element)){
				arrayset(arguments, i, i, toString(element));
			}else{
				arrayset(arguments, i, i, variables.immutableFactory.array(element));
			} 
		}else if(isStruct(element)){ 
			arrayset(arguments, i, i, duplicate(this).init(argumentCollection: element));
		}else{// if(not isNull(element) and isObject(element) and not structkeyexists(element, '$__isImmutableObject')){
			throw("You can't pass a complex object, ""#i#"", to the immutable CFC construct. Only string, number, date, boolean values or other immutable objects created with immutableFactory are accepted unless you implement the immutable interface (which doesn't exist yet).");
		}
	}  
	variables.data=arguments; 
	variables["$__immutableInitRanOnce"]=true; 
	return this;
	</cfscript>
</cffunction>

<cffunction name="$__isImmutableObject" localmode="modern" access="public" output="false">
	<cfreturn true>
</cffunction>

<cffunction name="get" localmode="modern" access="public" returntype="any" output="false">
	<cfargument name="index" type="string" required="yes">
	<cfscript>
	return variables.data[arguments.index]; 
	</cfscript>
</cffunction>

 <cffunction name="iterator" localmode="modern" access="public" output="no">
	<cfscript>
	var i=0;
	var element=0;
	var arrData=[];
	loop index="i" item="element" array="#variables.data#"{
		arrData[i]={key:i, value:element};
	}
	return duplicate(variables.iterator).init(arrData);
	</cfscript>
</cffunction>

<cffunction name="count" localmode="modern" access="public" returntype="number" output="false">
	<cfreturn structcount(variables.data)>
</cffunction>

<cffunction name="dump" localmode="modern" access="public" output="yes">
	<cfscript> 
	variables.privateDump(level:1);
	</cfscript>
</cffunction>

<cffunction name="privateDump" localmode="modern" access="package" output="yes">
	<cfargument name="level" type="numeric" required="yes">
	<cfscript> 
	var element=0; 
	var pad="";
	for(var n=2;n LTE arguments.level;n++){
		pad&="&nbsp;&nbsp;&nbsp;&nbsp;";
	} 
	for(var i3 in variables.data){
		if(not isNull(variables.data[i3]) and isObject(variables.data[i3]) and structkeyexists(variables.data[i3], "$__isImmutableObject")){
			writeoutput(pad&i3&" = (object){<br />");
			variables.data[i3].privateDump(level+1);  
			writeoutput(pad&"}<br />");
		}else{
			writeoutput(pad&i3&" = "&variables.data[i3]&"<br />");
		}
	}
	</cfscript>
</cffunction>

<!--- 
<cffunction name="onMissingMethod" localmode="modern" access="public" returnType="any" output="false">
	<cfargument name="missingMethodName" type="string" required="true">
	<cfargument name="missingMethodArguments" type="struct" required="true">
	<cfscript>
	var c=removeChars(arguments.missingMethodName, 1, 3);
	//if(left(arguments.missingMethodName, 3) EQ "get"){
	if(not structkeyexists(variables.data, c)){
		throw(arguments.missingMethodName&" is not a valid method or private variable name.");
	}
	return variables.data[c];
	</cfscript>
</cffunction> --->


</cfcomponent>