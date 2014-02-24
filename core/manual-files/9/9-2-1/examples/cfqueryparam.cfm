<cfquery name="q" datasource="db">
select * from user where id=<cfqueryparam value="#form.id#" cfsqltype="cf_sql_integer">
</cfquery>