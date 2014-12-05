<cfcomponent>
<cfoutput>

<cffunction name="zCreateObject" localmode="modern" output="no" returntype="any">
    <cfargument name="c" type="string" required="yes">
    <cfargument name="cpath" type="string" required="yes">
    <cfargument name="forceNew" type="boolean" required="no" default="#false#">
    <cfscript>
    var c=0;
	var i=0;
	var t9=0;
	var t7=0;
	var e=0;
	var e2=0;
    if(structkeyexists(application.zcore,'allcomponentcache') EQ false){
        application.zcore.allcomponentcache=structnew();
    }
	t7=application.zcore.allcomponentcache;
    if(structkeyexists(t7,arguments.cpath) EQ false or arguments.forceNew){
		try{
			t9=createobject("component",arguments.cpath);
		}catch(Any e){
			savecontent variable="local.e2"{
				writedump(e, true, 'simple');	
			}
			if(not fileexists(expandpath(replace(arguments.cpath, ".","/","all")&".cfc"))){
				application.zcore.functions.z404("zCreateObject() c:"&arguments.c&"<br />cpath:"&arguments.cpath&"<br />forceNew:"&arguments.forceNew&"<br />request.zos.cgi.SCRIPT_NAME:"&request.zos.cgi.SCRIPT_NAME&"<br />catch error:"&local.e2);
			}else{
				rethrow;
			}
		}
        application.zcore.allcomponentcache[arguments.cpath]=t9;
    }
	t7=application.zcore.allcomponentcache[arguments.cpath];
    c=duplicate(t7);
    for(i in c){
        if(isstruct(c[i])){
            c[i]=structnew();
            structappend(c[i],duplicate(t7[i]),true);
        }
    }
    return c;
    </cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
