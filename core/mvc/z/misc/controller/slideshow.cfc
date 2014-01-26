<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" output="yes">
	<cfscript>
	var slideshowCom=createobject("component", "zcorerootmapping.com.display.slideshow");
	slideshowCom.getData();
	</cfscript>
</cffunction>

<cffunction name="embed" localmode="modern" access="remote" output="yes">
	<cfscript>
	var ts=0;
	Request.zOS.debuggerEnabled=false;
	if(structkeyexists(form, 'slideshow_id') EQ false){
		application.zcore.functions.z404("form.slideshow_id was not defined.");//301redirect("/");	
	}
	application.zcore.functions.zSetModalWindow();
	application.zcore.template.setTemplate("zcorerootmapping.templates.simple",true,true);
	ts=structnew();
	ts.slideshow_id=form.slideshow_id;
	application.zcore.functions.zSlideShow(ts);
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
