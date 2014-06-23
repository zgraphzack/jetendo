<cfcomponent>
<cffunction name="getVersion" localmode="modern" access="public">
	<cfscript>
	// increment manually when database schema changes or source release version changes
	return {
		databaseVersion: 21,
		sourceVersion: "0.1.006"
	};
	</cfscript>
</cffunction>
</cfcomponent>