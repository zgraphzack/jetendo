<cfset sql="select 1">
<cfquery name="q" datasource="db">
#perserveSingleQuotes(sql)#
</cfquery>