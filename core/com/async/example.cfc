<cfcomponent>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var asyncInitStruct={
		threadTimeout: 1000,
		threadDuration: 1000,
		threadNamePrefix: 'asyncThread',
		enableGlobalThreadLimit: true, 
		maxThreads: 4,
		debug: false,
		enableJava: false
	}
	var asyncInstance=createobject("component", "async").init(asyncInitStruct);
	
	// create many workUnits to be executed together as a group
	var arrWorkUnit=[];
	// this will add all numbers between 1 and 100 together and output the total
	for(var i=1;i LTE 100;i++){
		var data={ "test": i };
		arrayAppend(arrWorkUnit, asyncInstance.createWorkUnit(this, "workMethod", this, "callbackMethod", data));
	}
	asyncInstance.executeWorkUnitGroup(arrWorkUnit, this, "groupCallbackMethod");
	while(asyncInstance.hasWork()){
		// do other work
		sleep(0); // wait for 1 millisecond or less before polling again
	}
	</cfscript>
</cffunction>
	
<cffunction name="workMethod" localmode="modern" access="public">
	<cfargument name="threadStruct" type="struct" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	// do some slower work - using sleep to fake it
	arguments.threadStruct.test=arguments.dataStruct.test; 
	//sleep(100);
	</cfscript>
</cffunction>

<cffunction name="callbackMethod" localmode="modern" access="public">
	<cfargument name="workUnit" type="struct" required="yes">
	<cfscript> 
	if(arguments.workUnit.thread.status EQ "terminated"){
		// handle error
		savecontent variable="local.output"{
			writedump(arguments.workUnit.thread);
		}
		throw("Thread #arguments.workUnit.thread.name# failed. Thread scope data below:<br /><br />"&local.output);
	}
	writeoutput("workUnit callbackMethod was executed. data key test = "&arguments.workUnit.thread.test&"<br />");
	</cfscript>
</cffunction>

<cffunction name="groupCallbackMethod" localmode="modern" access="public">
	<cfargument name="arrWorkUnit" type="array" required="yes">
	<cfscript>
	var total=0; 
	for(var i=1;i LTE arrayLen(arguments.arrWorkUnit);i++){
		if(arguments.arrWorkUnit[i].thread.status EQ "terminated"){
			// handle error
			savecontent variable="local.output"{
				writedump(arguments.arrWorkUnit[i].thread);
			}
			throw("Thread #arguments.arrWorkUnit[i].thread.name# failed. Thread scope data below:<br /><br />"&local.output);
		} 
		total+=arguments.arrWorkUnit[i].thread.test; 
	}
	writeoutput('Total:'&total);
	</cfscript>
</cffunction>
</cfcomponent>