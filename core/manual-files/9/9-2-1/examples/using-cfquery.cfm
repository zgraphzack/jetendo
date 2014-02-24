<cfquery name="q" datasource="db">
select * from `db`.`user` where 
id=<cfqueryparam value="##form.id##" cfsqltype="cf_sql_integer"> and 
site_id IN ('1','2','3')
</cfquery>