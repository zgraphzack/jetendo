<cfcomponent implements="zcorerootmapping.interface.view">
<cfoutput>
<cffunction name="init" access="public" returntype="string" localmode="modern">
	<cfscript>
	application.zcore.functions.zIncludeZOSFORMS();
	application.zcore.skin.includeCSS("/zthemes/default/stylesheets/style.css");
	request.disablesharethis=true;
	</cfscript>
</cffunction>

<cffunction name="render" access="public" returntype="string" localmode="modern">
	<cfargument name="tagStruct" type="struct" required="yes">
	<cfscript>
	var tagStruct=arguments.tagStruct;
	</cfscript>
	<cfsavecontent variable="output">
	<cfscript>
	// use this code to generate the div and img element css code for all the theme images
	// local.output=request.zos.functions.zGetImageCSSCode("#request.zos.globals.homedir#images/shell/", "/images/shell/");
	// writeoutput('<textarea name="test" cols="100" rows="10">'&local.output&'</textarea>');
	// request.zos.functions.zabort();
	</cfscript>
<!DOCTYPE html>
	<!--[if lt IE 7]>	  <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
	<!--[if IE 7]>		 <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
	<!--[if IE 8]>		 <html class="no-js lt-ie9"> <![endif]-->
	<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
	<head>
		<meta charset="utf-8" />
	<title>#tagStruct.title ?: ""#</title>
	#tagStruct.stylesheets ?: ""#
	#tagStruct.meta ?: ""#
</head>

<body>
<div id="wrapper">
  <div id="cont_area">
	<div style="background-color:##990000; color:##FFF; font-size:18px; line-height:24px; width:934px; padding:20px;">#request.zos.globals.sitename#</div>
	<div style="width:974px; float:left;">
	  <cfscript>
	ts=structnew();
	ts.menu_name="Main Menu";
	rs=request.zos.functions.zMenuInclude(ts);
	writeoutput(rs.output);
	</cfscript>
	</div>
	<div id="left_block">
	  <cfif isdefined('request.zos.tempObj.rentalInstance') EQ false or request.zos.tempObj.rentalInstance.configCom.isRentalPage() EQ false>
		<div class="sidebartext">
		  <cfif structkeyexists(request.zos,'listingCom')>
			<h2>LISTING SEARCH</h2>
			<cfscript>
			ts=structnew();
			ts.output=true;
			ts.searchFormLabelOnInput=true;
			ts.searchFormEnabledDropDownMenus=true;
			ts.searchFormHideCriteria=structnew();
			ts.searchFormHideCriteria["more_options"]=true;
			request.zos.listingCom.includeSearchForm(ts);
			</cfscript>
		  </cfif>
		</div>
	  </cfif>
	  <div class="sidebartext">
		<h2>SITE SEARCH</h2>
		<form action="/z/misc/search-site/results" method="get" class="search_form" id="sideQuestionForm">
		  <input type="text" name="searchtext" value="Type Keyword Here" onclick="if(this.value == 'Type Keyword Here'){this.value='';}" onblur="if(this.value==''){this.value='Type Keyword Here';}" size="15" />
		  <input type="submit" name="searchsubmit" value="Search" />
		</form>
	  </div>
	  <div class="sidebartext" style="padding:0px;">
		#tagStruct.menu ?: ""#
		<cfif structkeyexists(request.zos.tempObj,'blogInstance')>
#request.zos.tempObj.blogInstance.configCom.menuTemplate()#
		</cfif>
	  </div>
	</div>
	<div id="center_block">
	  <div class="cont_block">
		<cfif form[request.zos.urlRoutingParameter] EQ "/">
			<cfscript>
			ts=structnew();ts.slideshow_codename="Slideshow";request.zos.functions.zSlideShow(ts);
			</cfscript>
			<br style="clear:both;" />
			<cfscript>
			ts=structnew();ts.slideshow_codename="Listing Slideshow";request.zos.functions.zSlideShow(ts);
			</cfscript>
		</cfif>
		<a id="contenttop"></a>
		#tagStruct.topcontent ?: ""#
		<cfif request.zos.template.getTagContent('pagetitle') NEQ ''>
		  <h1>#tagStruct.pagetitle ?: ""#</h1>
		</cfif>
		#tagStruct.content ?: ""#
		<cfif structkeyexists(request.zos, 'listingCom')>
		  <hr />
			#request.zos.listingCom.getDisclaimerText()#
		</cfif>
	  </div>
	</div>
	<div class="crights">
	  &copy;#year(now())#
	  <cfif form[request.zos.urlRoutingParameter] NEQ "/">
		<a href="/">
	  </cfif>
#request.zos.globals.shortdomain#
	  <cfif form[request.zos.urlRoutingParameter] NEQ "/">
		</a>
	  </cfif>
	  - all rights reserved.
	  | <a href="/z/misc/site-map/index">Site Map</a></div>
  </div>
</div>
#tagStruct.scripts ?: ""#
#request.zos.functions.zvarso('Visitor Tracking Code')#
</body>
</html>
	</cfsavecontent>
	<cfreturn output>
</cffunction>
</cfoutput>
</cfcomponent>