<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>   
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `landing_page`  DROP INDEX `NewIndex1`")){
		return false;
	}   
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO `section_content_type` 
	(`section_content_type_name`, `section_content_type_cfc_path`, `section_content_type_cfc_method`, `section_content_type_updated_datetime`, `section_content_type_deleted`) 
	VALUES 
	('Custom Landing Page', 'zcorerootmapping.com.content-type.landingPageContentType', 'index', '#request.zos.mysqlnow#', 0),
	('Blog Section', 'zcorerootmapping.com.content-type.blogSectionContentType', 'index', '#request.zos.mysqlnow#', 0),
	('Blog Category', 'zcorerootmapping.com.content-type.blogCategoryContentType', 'index', '#request.zos.mysqlnow#', 0),
	('Page Section', 'zcorerootmapping.com.content-type.pageSectionContentType', 'index', '#request.zos.mysqlnow#', 0),
	('Page', 'zcorerootmapping.com.content-type.pageContentType', 'index', '#request.zos.mysqlnow#', 0)")){
		return false;
	}   

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>