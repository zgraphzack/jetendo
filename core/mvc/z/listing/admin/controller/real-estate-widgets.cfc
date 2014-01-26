<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="member">
<cfscript>
application.zcore.template.settag("title","Widgets for other web sites");
</cfscript>
<h1>Widgets for other web sites</h1>
<p>Sometimes you have a profile on another web site such as facebook, where adding a custom page is desirable to draw customers to your web site.  Feel free to insert one of the widget code snippets below in order to achieve dynamic features that integrate with your web site.</p>
<h1>Quick Search</h1>
<p>HTML CODE</p>
<textarea name="quicksearch1" cols="80" rows="5"  onclick="this.select();" style="width:100%; height:30px;">
#htmleditformat('<script type="text/javascript" src="#request.zos.globals.domain#/z/listing/quick-search/index"></script>')#
</textarea>
<p>Widget Example</p>
<script type="text/javascript" src="#request.zos.globals.domain#/z/listing/quick-search/index"></script>
<hr />
<!--- <p>More widgets will be available in the future.</p> --->
</cffunction>
</cfoutput>
</cfcomponent>