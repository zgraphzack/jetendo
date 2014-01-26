<cfcomponent hint="Allows looping and dumping values in an immutable object.">
	<!--- <cfscript>
	while(myIterator.hasNext()){
		var current=myIterator.next();
	}
	while(myIterator.hasPrevious()){
		var current=myIterator.previous();
	}
	
immutableObj.iterator(){
}
	</cfscript> --->
<cffunction name="init" localmode="modern" access="public">
	<cfargument name="arrData" type="array" required="yes">
	<cfscript>
	variables.arrData=arguments.arrData;
	variables.count=arraylen(arguments.arrData);
	variables.index=1;
	return this;
	</cfscript>
</cffunction>

<cffunction name="setIndex" localmode="modern" access="public">
	<cfargument name="index" type="numeric" required="yes">
	<cfscript>
	if(arguments.index GT variables.count or arguments.index LT 1){
		throw("The index must not be greater then the array length, #variables.count#, or less then 1");
	}
	variables.index=arguments.index;
	</cfscript>
</cffunction>

<cffunction name="count" localmode="modern" access="public">
	<cfscript>
	return variables.count;
	</cfscript>
</cffunction>
 
<cffunction name="hasNext" localmode="modern" access="public">
	<cfscript> 
	if(variables.index LTE variables.count){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="hasPrevious" localmode="modern" access="public">
	<cfscript>
	if(variables.index GTE 1){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="get" localmode="modern" access="public">
	<cfargument name="index" type="numeric" required="yes">
	<cfscript>
	return variables.arrData[arguments.index];
	</cfscript>
</cffunction>

<cffunction name="next" localmode="modern" access="public">
	<cfscript>
	var tempIndex=variables.index;
	variables.index=variables.index+1;
	return variables.arrData[tempIndex];
	</cfscript>
</cffunction>

<cffunction name="previous" localmode="modern" access="public">
	<cfscript>
	var tempIndex=variables.index;
	variables.index=variables.index-1;
	return variables.arrData[tempIndex];
	</cfscript>
</cffunction>

</cfcomponent>