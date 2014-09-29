<cfcomponent extends="zcorerootmapping.com.zos.controller">
	<cfproperty name="sectionModel" type="zcorerootmapping.mvc.z.admin.model.sectionModel">
<cfoutput>

<cffunction name="init" localmode="modern" access="private" roles="member">
	
</cffunction>
	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	form.section_parent_id=application.zcore.functions.zso(form, 'section_parent_id', true, 0);

	viewData={};
	viewData.qSection=variables.sectionModel.getChildren(form.section_parent_id);

	//writedump(viewData);


	</cfscript>
</cffunction>
	
</cfoutput>
</cfcomponent>