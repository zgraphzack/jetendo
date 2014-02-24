<cfscript>
db=createobject("component","db").init();
q=db.newQuery();
q.sql="select * from #q.table("user", "db")# where 
id=#q.param(form.id)# and 
site_id IN (#q.trustedSQL('1','2','3')#)";
r=q.execute("r");
</cfscript>