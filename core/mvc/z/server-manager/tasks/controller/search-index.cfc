<cfcomponent>
<cfoutput>
<!--- schedule this daily to ensure any bad records are cleared. --->
<cffunction name="index" localmode="modern" access="remote">
	<cfsetting requesttimeout="2000">
	<cfscript>
	request.ignoreSlowScript=true;
	blogCom=createobject("component", "zcorerootmapping.mvc.z.blog.controller.blog");
	blogCom.searchReindexBlogArticles(false, true);
	blogCom.searchReindexBlogCategories(false, true);
	blogCom.searchReindexBlogTags(false, true);
	
	rentalCom=createobject("component", "zcorerootmapping.mvc.z.rental.controller.rental");
	rentalCom.searchReindexRental(false, true);
	rentalCom.searchReindexRentalCategory(false, true);
	
	contentCom=createobject("component", "zcorerootmapping.mvc.z.content.controller.content");
	contentCom.searchReindexContent(false, true);
	
	
	local.searchIndexCom=createobject("component", "zcorerootmapping.com.app.site-option");
	local.searchIndexCom.searchReindex();
	
	</cfscript>
	Done.
</cffunction>
</cfoutput>

</cfcomponent>