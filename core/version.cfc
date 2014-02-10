<cfcomponent>
<cffunction name="getVersion" localmode="modern" access="public">
	<cfscript>
	// increment manually when database schema changes or source release version changes
	return {
		databaseVersion: 4,
		sourceVersion: "0.1.001"
	};
	</cfscript>
</cffunction>
</cfcomponent>