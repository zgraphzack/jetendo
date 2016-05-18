<cfcomponent>
<cffunction name="storeGitStatus" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");

	if(not structkeyexists(application, 'gitStatusCache')){
		application.gitStatusCache={};
	}
	ts={
		email:form.email,
		data:form.data,
		date: now()
	};
	application.gitStatusCache[email]=ts;

	echo('1');
	abort;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	echo('<h2>Developer Git Status Report</h2>');
	echo('<p>Updated hourly when developer virtual machine is running and connected to the internet. Projects are not listed if they are up to date and synced.</p>');
	ts=application.zcore.functions.zso(application, 'gitStatusCache');
	for(i in ts){
		c=ts[i];
		echo('<hr />');
		echo('<h2><a href="mailto:#c.email#">'&c.email&'</a></h2>');
		echo('<p>Last updated:'&dateformat(c.date, 'm/d/yyyy')&" at "&timeformat(c.date, "h:mm tt")&'</p>');
		arrData=listToArray(c.data, chr(10));
		arraySort(arrData, 'text', 'asc');
		echo('<p>'&arrayToList(arrData, '</p><p>')&'</p>');
	} 
	 
	</cfscript>
</cffunction>
</cfcomponent>