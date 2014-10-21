<cfcomponent>
<cfoutput>
<!--- schedule this daily to ensure any bad records are cleared. --->
<cffunction name="index" localmode="modern" access="remote">
	<cfsetting requesttimeout="2000">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	request.ignoreSlowScript=true;

	local.searchIndexCom=createobject("component", "zcorerootmapping.com.app.site-option");
	local.searchIndexCom.searchReindex();

	blogCom=createobject("component", "zcorerootmapping.mvc.z.blog.controller.blog");
	blogCom.searchReindexBlogArticles(false, true);
	blogCom.searchReindexBlogCategories(false, true);
	blogCom.searchReindexBlogTags(false, true);
	
	rentalCom=createobject("component", "zcorerootmapping.mvc.z.rental.controller.rental");
	rentalCom.searchReindexRental(false, true);
	rentalCom.searchReindexRentalCategory(false, true);
	
	contentCom=createobject("component", "zcorerootmapping.mvc.z.content.controller.content");
	contentCom.searchReindexContent(false, true);
	
	
	
	echo('Done.');
	abort;
	</cfscript>
</cffunction>
</cfoutput>

</cfcomponent>