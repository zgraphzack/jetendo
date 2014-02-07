<cfcomponent output="yes" hint="Used to standardize the way data is returned from a function or component method.">
<cfoutput>	<cfscript>
	this._errorCount=0;
	/*
	if(request.zos.istestserver and structkeyexists(form, 'disableStackTrace') EQ false){
		stack=application.zcore.functions.zGetStackTrace();
		// determine if parent is a component and check it for no code errors using this.checkComponentErrors(componentPath);
		//application.zcore.functions.zdump(stack);
		if(structkeyexists(request.zos,'createdComponentStruct') EQ false){
			request.zos.createdComponentStruct=structnew();
		}
		for(i=3;i lte arraylen(stack.tagcontext);i++){
			if(right(stack.tagcontext[i].template,4) EQ '.cfc'){
				if(structkeyexists(request.zos.createdComponentStruct,stack.tagcontext[i].template) EQ false){
					request.zos.createdComponentStruct[stack.tagcontext[i].template]=0;
				}
				request.zos.createdComponentStruct[stack.tagcontext[i].template]++;
				
			}
		}
	}*/
	</cfscript>
	<cffunction name="setError" localmode="modern" output="no" returntype="any" hint="Use to set a descriptive error in the return data.">
		<cfargument name="str" type="string" required="yes">
        <cfargument name="id" type="numeric" required="yes" hint="The error number assigned to this error for this function. Don't use the same id more then once per function or it will result in incorrect errors to be displayed.">
        <cfscript>
		if(this._errorCount eq 0){
			variables.arrErrors=arraynew(1);
			variables.arrErrorIds=arraynew(1);
		}
		this._errorCount++;
		arrayappend(variables.arrErrors,arguments.str);
		arrayappend(variables.arrErrorIds,arguments.id);
		</cfscript>
	</cffunction>
    <cffunction name="setData" localmode="modern" output="no" returntype="any" hint="Append struct to the internal data struct.">
    	<cfargument name="struct" type="struct" required="yes">
        <cfscript>
		if(structkeyexists(this,'data') eq false){
			variables.data=structnew();
		}
		structappend(variables.data,arguments.struct,true);
		</cfscript>
    </cffunction>
    <cffunction name="isOK" localmode="modern" output="no" returntype="boolean" hint="Used to check for error status">
    	<cfscript>if(this._errorCount eq 0){return true;}else{return false;}</cfscript>
    </cffunction>
    <cffunction name="setStatusErrors" localmode="modern" returntype="any" output="no" hint="Add all errors to a application.zcore.status.cfc id.">
    	<cfargument name="zsid" type="numeric" required="no" default="#request.zsid#">
        <cfscript>
		var i=0;
		var b=this.getErrors();
		for(i=1;i lte arraylen(b);i++){
			application.zcore.status.setStatus(arguments.zsid,b[i],false,true);
		}
		</cfscript>
    </cffunction>
    
    <cffunction name="copyErrorsToReturnCom" localmode="modern" output="no" returntype="void" hint="Copies errors to the return component specified as an argument.">
    	<cfargument name="rcom" type="zcorerootmapping.com.zos.return" required="yes">
        <cfscript>
		var i=0;
		for(i=1;i lte arraylen(variables.arrErrors);i++){
			arguments.rcom.setError(variables.arrErrors[i],variables.arrErrorIds[i]);
		}
		</cfscript>
    </cffunction>
    
    <cffunction name="mapErrors" localmode="modern" output="no" returntype="void" hint="Map your own error messages to the error ids by sending in a partial or complete structure">
    	<cfargument name="ss" type="struct" required="yes">
        <cfscript>
		if(structkeyexists(variables,'userErrorMap') EQ false){
			variables.userErrorMap=structnew();
		}
		structappend(variables.userErrorMap,arguments.ss,true);
		</cfscript>
    </cffunction>
    
    <cffunction name="getErrors" localmode="modern" output="yes" returntype="array" hint="Return the error messages so you can use them.">
    	<cfscript>
		var a=arraynew(1);
		var b=arraynew(1);
		var i=0;
		if(structkeyexists(variables,"arrErrorIds") EQ false){
			return a;
		}
		if(structkeyexists(variables,'userErrorMap')){
			for(i=1;i lte arraylen(a);i++){
				if(structkeyexists(variables.userErrorMap,a[i])){
					arrayAppend(b,variables.userErrorMap[a[i]]);
				}else{
					arrayAppend(b,variables.arrErrors[i]);
				}
			}
		}else{
			b=variables.arrErrors;
		}
		return b;
		</cfscript>
    </cffunction>
    <cffunction name="getErrorIds" localmode="modern" output="no" returntype="array" hint="Return the error ids so you can write your own error messages for them.">
    	<cfreturn variables.arrErrorIds>
    </cffunction>
    <cffunction name="getData" localmode="modern" output="no" returntype="struct" hint="Return the internal data struct.">
    	<cfif structkeyexists(variables,'data')>
    		<cfreturn variables.data>
        <cfelse>
	        <cfreturn structnew()>
        </cfif>
    </cffunction>
    <cffunction name="fail" localmode="modern" output="no" returntype="any" hint="Throws a coldfusion error and aborts the request.">
		<cfargument name="str" type="string" required="yes">
    	<cfscript>application.zcore.template.fail(arguments.str);</cfscript>
    </cffunction>
    
    <!--- 
	    <cffunction name="convertToHtml" localmode="modern" output="no" returntype="any">
    	<cfargument name="text" type="string" required="yes">
        <cfscript>
		var arrWord=0;
		var n=1;
		var ns="";
		var i=1;
		var np=0;
		var body=arguments.text;
		var body2=rereplacenocase(body,'([\s''"\[\]<>])',' \1 ','all');
		body2=rereplacenocase(body2,'([^http|https]):','\1: ','all');
		/*body2=replacenocase(body2,':',': ','all');
		body2=replacenocase(body2,'http: ','http:','all');
		body2=replacenocase(body2,'https: ','https:','all');*/

	 --->
    
    <!--- 
	// verify the component's error ids are unique
	ts=StructNew();
	ts.filePath="";
	ts.function="";
	rs=returnCom.getErrorsFromFunctionFile(ts);
	//zdump(rs); // structure or error ids and their error message.
	 --->
     <cffunction name="getErrorsFromFunctionFile" localmode="modern" output="yes" returntype="struct" hint="extracts error messages and their ids from a function's source code and returns a structure so you can create a new mapping to override the built-in error messages with your own.">
     	<cfargument name="ss" type="struct" required="yes">
        <cfscript>
		var rs=structnew();
		var length=0;
		var arr=0;
		var fc=application.zcore.functions.zreadfile(arguments.ss.filePath); // read function file
		var id=0;
		var start=0;
		var line=0;
		var p=0;
		var fc2=fc;
		// parse out function
		fc=rereplace(fc,"(?s)<\!---.*?--->","","ALL"); 
		fc=rereplace(fc,"/\*.*?\*/","","ALL");
		fc=rereplace(fc,"//[^\n]*?\n",chr(10),"ALL"); 
		arr=rematchnocase('(?s)<cffunction localmode="modern" [^>]*?name\s*=\s*(''|")'&arguments.ss.function&'\1[^>]*?>.*?</cffunction>',fc); 
		if(arraylen(arr) eq 0){
			// function not found
			application.zcore.template.fail("The function, #arguments.ss.function#, in file, #arguments.ss.filepath#, failed to be parsed.");
		}
		fc=arr[1];
		start=1;
		// loop and parse string and id to build structure
		while(true){
			p=refindnocase('\.setError\s*\(\s*"([^"]("{2,2}|[^"])*)?"\s*?,\s*?([0-9]*)?\);',fc,start,true);
			if(arraylen(p.pos) lt 4){
				break;
			}
			id=mid(fc,p.pos[4], p.len[4]);		
			if(structkeyexists(rs, id)){
				// duplicate found
				s=left(fc2,max(1,find(mid(fc,p.pos[1],p.len[1]),fc2)));
				line=((len(s)-len(replace(s,chr(10),"","ALL")))-1);
				application.zcore.template.fail("The function, #arguments.ss.function#, in file, #arguments.ss.filepath#, has a duplicate returnCom.setError() id, #id#, and all error ids must be unique. The first setError() call occurs on line "&line);
			}
			rs[id]=replace(mid(fc,p.pos[2], p.len[2]),'""','"',"ALL");
			start=p.pos[1]+p.len[1];
		}
		start=1;
		while(true){
			p=refindnocase('\.setError\s*\(\s*''([^''](''{2,2}|[^''])*)?''\s*?,\s*?([0-9]*)?\);',fc,start,true);
			if(arraylen(p.pos) lt 4){
				break;
			}
			id=mid(fc,p.pos[4], p.len[4]);
			if(structkeyexists(rs, id)){
				// duplicate found
				s=left(fc2,max(1,find(mid(fc,p.pos[1],p.len[1]),fc2)));
				line=((len(s)-len(replace(s,chr(10),"","ALL")))-1);
				application.zcore.template.fail("The function, #arguments.ss.function#, in file, #arguments.ss.filepath#, has a duplicate returnCom.setError() id, #id#, and all error ids must be unique. The first setError() call occurs on line "&line);
			}
			rs[id]=replace(mid(fc,p.pos[2], p.len[2]),"''","'","ALL");
			start=p.pos[1]+p.len[1];
		}
		start=1;
		while(true){
			p=refindnocase('\.setError\s*\(\s*''([^''](''{2,2}|[^''])*)?''\s*\);',fc,start,true);
			if(arraylen(p.pos) eq 0 or p.pos[1] eq 0){
				break;
			}
			s=left(fc2,max(1,find(mid(fc,p.pos[1],p.len[1]),fc2)));
			line=((len(s)-len(replace(s,chr(10),"","ALL")))+1);
			application.zcore.template.fail("arguments.id is required when using zcorerootmapping.com.zos.return.setError(). The incorrect setError() call occurs on line "&line);
		}
		start=1;
		while(true){
			p=refindnocase('\.setError\s*\(\s*"([^"]("{2,2}|[^"])*)?"\s*\);',fc,start,true);
			if(arraylen(p.pos) eq 0 or p.pos[1] eq 0){
				break;
			}
			s=left(fc2,max(1,find(mid(fc,p.pos[1],p.len[1]),fc2)));
			line=((len(s)-len(replace(s,chr(10),"","ALL")))+1);
			application.zcore.template.fail("arguments.id is required when using zcorerootmapping.com.zos.return.setError(). The incorrect setError() call occurs on line "&line);
		}
		return rs;
		</cfscript>
     </cffunction>
     
     <!--- a function that store in server scope whether a component has been check for unique error ids yet. --->
     <cffunction name="checkComponentErrors" localmode="modern" output="yes" returntype="any">
     	<cfargument name="filePath" type="string" required="yes">
     	<!--- detect used components and compare datetime to server scope to prevent unnecessary checks - run this.getErrorsFromFunctionFile() if file has changed.  --->
        <cfscript>
		var ts="";
		var ed=0;
		var newfilepath=replacenocase(replace(arguments.filepath,'\','/','ALL'), left(request.zos.globals.serverhomedir,len(request.zos.globals.serverhomedir)-1), "/zcorerootmapping");
		return; // disabled - unnecessary bloat
		newfilepath=replacenocase(newfilepath, left(request.zos.globals.homedir,len(request.zos.globals.homedir)-1), request.zos.globals.siteroot);
		ed=getcomponentmetadata(replace(mid(newfilePath,2,len(newfilePath)-5),'/','.','ALL'));
		for(i=1;i lte arraylen(ed.functions);i++){
			ts=StructNew();
			ts.filePath=arguments.filePath;
			ts.function=ed.functions[i].name;
			this.getErrorsFromFunctionFile(ts);
		}
		</cfscript>
     </cffunction>
     </cfoutput>
</cfcomponent>