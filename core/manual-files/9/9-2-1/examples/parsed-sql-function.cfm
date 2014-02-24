<cfscript>
function myFunction(parsedSQLStruct){
	// uncomment to see all the variables available
	// writedump(arguments.parseSQLStruct); abort;
	
	// modify the SQL to do anything you want with it.
	arguments.parseSQLStruct.sql=replace(arguments.parseSQLStruct.sql,"~somethingbad~","","all"); 
	return arguments.parseSQLStruct;
}
db=createobject("component","db");
db.init();
q=db.newQuery({parseSQLFunctionStruct:{myFunction:myFunction}});
q.sql="select * 1=~somethingbad~1";
q.datasource="datasource";
r=q.execute("r");
</cfscript>