<cfcomponent>
<cfoutput>
<!--- 
TODO: make long running tasks easier to visualize / manage via by applying this component to them which:
	provides ajax progress bar
	controls status messages
	simplifies support for canceling
	avoid duplicate requests of same task by using a name
	
	maybe:
		pause/resume support
	

 --->
<cffunction name="init" access="remote" localmode="modern">
	<cfargument name="name" type="string" required="yes">
	<cfscript>
	if(not structkeyexists(application.zcore, 'progressStruct')){
		application.zcore.progressStruct={};
	}
	// constants
	variables.RUNNING=1;
	variables.COMPLETED=2;
	variables.ERROR=3;
	variables.CANCELLED=4;
	
	variables.name=arguments.name;
	if(not structkeyexists(application.zcore.progressStruct, arguments.name)){
		ts={
			newStatus:1,
			currentMessage: 'Task started',
			startTime=now(),
			status: VARIABLES.RUNNING
		};
		application.zcore.progressStruct[arguments.name]=ts;
	}
	</cfscript>
</cffunction>

<cffunction name="ajaxGetProgress" access="remote" localmode="modern">
	<cfscript>
	application.zcore.progressStruct[form.name];
	</cfscript>
</cffunction>

<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	application.zcore.progressStruct[variables.name]
	</cfscript>
</cffunction>

<cffunction name="isCancelled" access="public" localmode="modern">
	<cfscript>
		
	if(application.zcore.progressStruct[variables.name] EQ variables.CANCELLED){
		
	}
	</cfscript>
</cffunction>

<cffunction name="index" access="remote" localmode="modern">
	test.
</cffunction>
</cfoutput>
</cfcomponent>