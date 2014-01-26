<!--- /z/test/runAllTests/index --->
<cfcomponent>
	<cfoutput>
        <cffunction name="index" localmode="modern" access="remote"> 
	<p>Reminder: All CFC Test files must start or end with "Test" in the file name for them to be processed by the mxunit directoryTestSuite run method.</p>
        <cfinvoke component="mxunit.runner.DirectoryTestSuite"
          method="run"
          directory="#request.zos.globals.serverhomedir#mvc/z/test/"
          componentPath="zcorerootmapping.mvc.z.test"
          recurse="true"
          excludes="runAllTests"
          returnvariable="results" />
		#results.getResultsOutput()#
        </cffunction>
	</cfoutput>
</cfcomponent>