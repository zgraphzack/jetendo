<cfcomponent>
<cffunction name="setImmutable" localmode="modern" access="public" output="yes">
	<cfargument name="immutable" type="component" required="yes">
	<cfscript>
	variables.immutable=arguments.immutable;
	variables.immutable.setImmutableFactory(this);
	</cfscript>
</cffunction>
<cffunction name="struct" localmode="modern" access="public" output="yes" returntype="immutable">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	return duplicate(variables.immutable).init(argumentCollection: arguments.struct); 
	</cfscript>
</cffunction>

<cffunction name="array" localmode="modern" output="yes">
	<cfargument name="array" type="array" required="yes">
	<cfscript>
	var count=arraylen(arguments.array);
	var a=arguments.array;
	var struct=structnew('linked'); 
	for(var i=1;i LTE count;i++){ 
		var v=a[i];
		if(isArray(v)){ 
			struct[i]=this.array(v); 
		}else if(isStruct(v)){
			struct[i]=duplicate(variables.immutable).init(argumentCollection: v);
		}else if(isNull(v)){
			struct[i]=v;
		}else if(isObject(v) and not structkeyexists(v, '$__isImmutableObject')){
			throw("The array must contain only string, number, date, boolean values or other immutable objects created with immutableFactory. Index ###i# was the wrong type.");
		}else{
			struct[i]=v;
		}
	}    
	return duplicate(variables.immutable).init(argumentCollection: struct);
	</cfscript>
</cffunction>

<cffunction name="query" localmode="modern" access="public" output="no">
	<cfargument name="query" type="query" required="yes">
	<cfscript>
	var m=structnew('linked');
	var i=1;
	for(var row in arguments.query){ 
		/*
		// convert byte array to string (blobs)
		for(var n in row){
			if(isArray(row[n])){
				row[n]=toString(row[n]);
			}
		}*/
		m[i]=row;
		i++;
	}
	return duplicate(variables.immutable).init(argumentCollection: m); 
	</cfscript>
</cffunction>
</cfcomponent>