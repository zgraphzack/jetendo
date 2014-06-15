<cfcomponent>
<cfoutput>
    <cffunction name="index" localmode="modern" access="remote">
        <cfscript>application.zcore.tracking.backOneHit();</cfscript>
        <cfif structkeyexists(form, 'vid') EQ false>
            Missing Identifier<cfscript>
        application.zcore.functions.zabort();
        </cfscript>
        </cfif>
        <cfdirectory name="qImages" directory="#request.zos.globals.serverprivatehomedir#validate_images/">
        
        <cfset maxer = #qImages.recordcount#>
        
        <cfset temp = #RandRange(1, maxer, "SHA1PRNG")#>
        
        <cfloop query="qImages" startrow="#temp#" maxrows="1">
        
        <cfscript>
            validate_length = (len(qImages.name) - 4);
            validate_name = left(qImages.name, validate_length);
            StructInsert(request.zsession, "vid"&form.vid, ucase(validate_name), true);
        </cfscript>
        
        <CFCONTENT type="image/jpeg" FILE="#request.zos.globals.serverprivatehomedir#validate_images/#qImages.name#">
        
        </cfloop>
    </cffunction>
</cfoutput>
</cfcomponent>