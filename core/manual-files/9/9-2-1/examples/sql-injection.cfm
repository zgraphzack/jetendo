<cfset form.id="1' or id <> '1">
<cfquery name="q" datasource="db">
select * from user where id='#structget('form.id')#'
</cfquery>