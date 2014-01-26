<cfcomponent>
<cffunction name="init" localmode="modern" access="public">
	<cfargument name="configStruct" type="struct" required="yes">
	<cfscript>
	variables.configStruct=arguments.configStruct; 
	structAppend(variables.configStruct, {
		threadTimeout: 1000,
		threadDuration: 1000,
		threadNamePrefix: 'asyncThread',
		enableGlobalThreadLimit: true,
		maxThreads: 8,
		debug: false,
		enableJava: false
	}, false);
	if(variables.configStruct.enableGlobalThreadLimit){
		if(not structkeyexists(application, 'globalThreadCount')){
			application.globalThreadCount={};
		}
		if(not structkeyexists(application.globalThreadCount, variables.configStruct.threadNamePrefix)){
			application.globalThreadCount[variables.configStruct.threadNamePrefix]={};
		}
	}
	// uncomment this line to force the count to be reset if there is a bug that prevents the threads from clearing themselves from the application scope.
	// application.globalThreadCount[variables.configStruct.threadNamePrefix]={};
	
	variables.groupIndex=1;
	if(variables.configStruct.enableJava){ 
		variables.atomicInteger=createObject( "java", "java.util.concurrent.atomic.AtomicInteger" ).init();
		variables.threadIndex =variables.atomicInteger.incrementAndGet();
	}else{
		variables.threadIndex=1;
	}
	variables.arrWorkUnitQueue=[];
	variables.arrWorkUnit=[];
	variables.groupStruct={};
	variables.arrComplete=[];
	return this;
	</cfscript>
</cffunction>

<cffunction name="createWorkUnit" localmode="modern" access="public">
	<cfargument name="workInstance" type="component" required="yes">
	<cfargument name="workMethod" type="string" required="yes">
	<cfargument name="callbackInstance" type="component" required="no">
	<cfargument name="callbackMethod" type="string" required="no">
	<cfargument name="data" type="struct" required="no" default="#{}#" hint="Warning: all threads will share this data if you don't pass in separate structs for each work unit.">
	<cfscript>
	arguments.groupId=0;
	return arguments;
	</cfscript>
</cffunction>

<cffunction name="executeWorkUnit" localmode="modern" access="public">
	<cfargument name="workUnit" type="struct" required="yes">
	<cfscript>
	if(variables.configStruct.enableGlobalThreadLimit){ 
		if(structcount(application.globalThreadCount[variables.configStruct.threadNamePrefix]) GTE variables.configStruct.maxThreads){
			// too many threads are running for this threadNamePrefix, queue the workUnit and wait for hasWork to run.
			arrayAppend(variables.arrWorkUnitQueue, arguments.workUnit);
			return;
		}
		if(variables.configStruct.enableJava){ 
			arguments.workUnit.threadName=variables.configStruct.threadNamePrefix&variables.threadIndex; 
		}else{
			arguments.workUnit.threadName=variables.configStruct.threadNamePrefix&createuuid()&variables.threadIndex; 
		}
		application.globalThreadCount[variables.configStruct.threadNamePrefix][arguments.workUnit.threadName]=true;
	}else{
		if(variables.configStruct.enableJava){ 
			arguments.workUnit.threadName=variables.configStruct.threadNamePrefix&variables.threadIndex; 
		}else{
			arguments.workUnit.threadName=variables.configStruct.threadNamePrefix&createuuid()&variables.threadIndex; 
		}
	}
	if(variables.configStruct.enableJava){ 
		variables.threadIndex=variables.atomicInteger.incrementAndGet();
	}else{
		variables.threadIndex++;
	}
	arrayAppend(variables.arrWorkUnit, arguments.workUnit);
	thread name="#arguments.workUnit.threadName#" duration="#variables.configStruct.threadDuration#" timeout="#variables.configStruct.threadTimeout#" 
	globalThreadLimit="#variables.configStruct.enableGlobalThreadLimit#" 
	threadNamePrefix="#variables.configStruct.threadNamePrefix#" 
	workUnit="#arguments.workUnit#"{
		var cfcatch=0;
		try{
			workUnit.workInstance[workUnit.workMethod](thread, workUnit.data);
		}catch(Any local.excpt){
			if(globalThreadLimit){
				structdelete(application.globalThreadCount[threadNamePrefix], workUnit.threadName);
			}
			rethrow;
		}
		if(globalThreadLimit){
			structdelete(application.globalThreadCount[threadNamePrefix], workUnit.threadName);
		}
	}
	</cfscript>
</cffunction>

<cffunction name="executeWorkUnitGroup" localmode="modern" access="public">
	<cfargument name="arrWorkUnit" type="array" required="yes">
	<cfargument name="callbackInstance" type="component" required="yes">
	<cfargument name="callbackMethod" type="string" required="yes">
	<cfscript>
	arguments.completeCount=0;
	variables.groupStruct[variables.groupIndex]=arguments;
	for(var i=1;i LTE arraylen(arguments.arrWorkUnit);i++){
		arguments.arrWorkUnit[i].groupId=variables.groupIndex;
		this.executeWorkUnit(arguments.arrWorkUnit[i]);
	}
	variables.groupIndex++;
	</cfscript>
</cffunction>

<cffunction name="hasWork" localmode="modern" access="public">
	<cfscript>
	if(variables.configStruct.enableGlobalThreadLimit){  
		// execute work units if there are available threads
		var availableThreads=min(arrayLen(variables.arrWorkUnitQueue), variables.configStruct.maxThreads-structcount(application.globalThreadCount[variables.configStruct.threadNamePrefix]));
		if(variables.configStruct.debug){
			writeoutput("Available threads: "&availableThreads&" queued workUnits: "&arrayLen(variables.arrWorkUnitQueue)&" Active threads: "& structcount(application.globalThreadCount[variables.configStruct.threadNamePrefix])&"<br />");
		}
		for(var i=1;i LTE availableThreads;i++){
			this.executeWorkUnit(variables.arrWorkUnitQueue[i]);
			arrayDeleteAt(variables.arrWorkUnitQueue, 1);
			i--;
			availableThreads--;
		}
	}
	
	// find threads that aren't running anymore
	var count=arrayLen(variables.arrWorkUnit); 
	for(var i=1;i LTE count;i++){
		var thread=cfthread[variables.arrWorkUnit[i].threadName];
		if(thread.status NEQ "running" and thread.status NEQ "not_started"){
			var workUnit=variables.arrWorkUnit[i];
			workUnit.thread=thread;
			// remove completed work from complete queue
			arrayDeleteAt(variables.arrWorkUnit, i);
			i--;
			count--;
			
			// pass the complete work unit to the callback function.  WorkUnit now contains a thread key with the complete data from the cfthread[theadName] struct.
			if(structkeyexists(workUnit, 'callbackInstance') and structkeyexists(workUnit, 'callbackMethod')){
				workUnit.callbackInstance[workUnit.callbackMethod](workUnit);
			}
			if(workUnit.groupId NEQ 0){
				var group=variables.groupStruct[workUnit.groupId];
				group.completeCount++;
				if(arrayLen(group.arrWorkUnit) EQ group.completeCount){
					group.callbackInstance[group.callbackMethod](group.arrWorkUnit);
					structdelete(variables.groupStruct, workUnit.groupId);
				}
			}
		}
	} 
	if(arrayLen(variables.arrWorkUnit)){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>
</cfcomponent>