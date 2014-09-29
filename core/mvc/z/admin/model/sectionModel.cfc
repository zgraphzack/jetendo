<cfcomponent>
<cfoutput>
	
<cffunction name="deleteById" localmode="modern" access="public">
	<cfargument name="section_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="delete from #db.table("section", request.zos.zcoreDatasource)# 
	WHERE section_id = #db.param(arguments.section_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	section_deleted = #db.param(0)# ";
	db.execute("qSection");
	return true;
	</cfscript>
</cffunction>

<cffunction name="getChildren" localmode="modern" access="public">
	<cfargument name="section_parent_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("section", request.zos.zcoreDatasource)# 
	WHERE section_parent_id = #db.param(arguments.section_parent_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	section_deleted = #db.param(0)# 
	ORDER BY section_name ASC ";
	return db.execute("qSection");
	</cfscript>
</cffunction>

<cffunction name="getById" localmode="modern" access="public">
	<cfargument name="section_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("section", request.zos.zcoreDatasource)# 
	WHERE section_id = #db.param(arguments.section_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	section_deleted = #db.param(0)# 
	ORDER BY section_name ASC ";
	return db.execute("qSection");
	</cfscript>
</cffunction>
	
</cfoutput>
</cfcomponent>