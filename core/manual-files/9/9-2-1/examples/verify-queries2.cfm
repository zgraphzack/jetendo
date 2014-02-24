<cfscript>
db=createobject("component","db").init();
q=db.newQuery({verifyQueriesEnabled:true});
q.sql="select * from "&q.table("user", "db")&" where id="&form.id;
r=q.execute("r");
</cfscript>