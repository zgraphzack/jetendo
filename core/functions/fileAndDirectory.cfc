<cfcomponent>
<cfoutput>

<!--- isGzipped=application.zcore.functions.zGzipFilePath("/absolute/path/to/file.txt", 20); --->
<cffunction name="zGzipFilePath" localmode="modern" access="public" returntype="boolean">
	<cfargument name="filePath" type="string" required="yes">
	<cfargument name="timeoutInSeconds" type="numeric" required="yes">
	<cfscript>
	if(not directoryexists(arguments.filePath) and not fileexists(arguments.filePath)){
		throw(arguments.filePath&" doesn't exist.  arguments.filePath must be a valid absolute path to a file.");
	}
	result=application.zcore.functions.zSecureCommand("gzipFilePath"&chr(9)&arguments.filePath, arguments.timeoutInSeconds);
	if(result EQ "1" and fileexists(arguments.filePath&".gz")){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="zMd5HashFile" localmode="modern" returntype="struct" output="no">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	var result=0;
	var arrP=0;
	// fileexists ensures the path is within sandbox before cfexecute is run, because cfexecute can't be sandboxed
	if(fileexists(arguments.path)){
		result=application.zcore.functions.zSecureCommand("getFileMD5Sum"&chr(9)&arguments.path, 10);
		if(result EQ false){
			return {success:false, hash:"" };
		} 
		arrP=listToArray(result, " ", false);
		return {success:true, hash:arrP[1] };
	}else{
		return {success:false, hash:""};
	}
	</cfscript>
</cffunction>
<cffunction name="zMd5HashFile" localmode="modern" returntype="struct" output="no">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	var result=0;
	var arrP=0;
	// fileexists ensures the path is within sandbox before cfexecute is run, because cfexecute can't be sandboxed
	if(fileexists(arguments.path)){
		result=application.zcore.functions.zSecureCommand("getFileMD5Sum"&chr(9)&arguments.path, 10);
		if(result EQ false){
			return {success:false, hash:"" };
		} 
		arrP=listToArray(result, " ", false);
		return {success:true, hash:arrP[1] };
	}else{
		return {success:false, hash:""};
	}
	</cfscript>
</cffunction>

<!--- isTarred=application.zcore.functions.zTarZipFilePath("myTarball.tar.gz", "/var/jetendo-server/jetendo/sites/", "/var/jetendo-server/jetendo/sites/site_com/", 20); --->
<cffunction name="zTarZipFilePath" localmode="modern" access="public" returntype="boolean">
	<cfargument name="tarFilename" type="string" required="yes" hint="A unique filename for the tar/gzip file. It must not already exist.">
	<cfargument name="changeToDirectory" type="string" required="yes" hint="The absolute path that you want to store the tar/gzip file in.">
	<cfargument name="pathToTar" type="string" required="yes" hint="A directory or file that you want to tar/gzip">
	<cfargument name="timeoutInSeconds" type="numeric" required="yes">
	<cfscript>
	if(not directoryexists(arguments.pathToTar) and not fileexists(arguments.pathToTar)){
		throw(arguments.pathToTar&" doesn't exist.  arguments.pathToTar must be a valid absolute path to file or directory.");
	}
	if(not directoryexists(arguments.changeToDirectory)){
		throw(arguments.changeToDirectory&" doesn't exist. arguments.changeToDirectory must be a valid absolute path to a directory.");
	}
	if(fileexists(arguments.changeToDirectory&arguments.tarFilename)){
		throw(arguments.changeToDirectory&arguments.tarFilename&" already exists.  arguments.tarFilename must be a unique filename in the changeToDirectory.");
	}
	result=application.zcore.functions.zSecureCommand("tarZipFilePath"&chr(9)&arguments.tarFilename&chr(9)&arguments.changeToDirectory&chr(9)&arguments.pathToTar, arguments.timeoutInSeconds);
	if(result EQ "1" and fileexists(arguments.changeToDirectory&arguments.tarFilename)){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<!--- FUNCTION: zCreateDirectory(dirName) --->
<cffunction name="zCreateDirectory" localmode="modern" returntype="any" output="false">
	<cfargument name="dirName" required="true" type="string">
	<cfscript>
	var cfcatch=0;
	</cfscript>
	<cfif directoryExists(arguments.dirName) EQ false>
		<cftry>
			<cfdirectory action="create" directory="#arguments.dirName#" mode="770">
			<cfcatch type="any"><cfreturn false></cfcatch>
		</cftry>
	</cfif>
	<cfreturn true>
</cffunction>

<!--- zConvertStylesheetImagesToDataURI(s, debug); --->
<cffunction name="zConvertStylesheetImagesToDataURI" localmode="modern" output="no" returntype="any">
	<cfargument name="s" type="string" required="yes">
	<cfargument name="debug" type="boolean" required="no" default="#false#">
	<cfscript>
    var local=structnew();
	local.d=application.zcore.functions.zreadfile(arguments.s);
    // extract image urls
    local.arrR=rematchnocase("url([^\(]*)\(([^\)]*)\)",local.d);
	local.u=structnew();
	local.arrC=arraynew(1);
	local.uc=structnew();
	if(arguments.debug) writedump(local.arrR, true, 'simple');
    for(local.i=1;local.i LTE arraylen(local.arrR);local.i++){
		if(structkeyexists(local.u, local.arrR[local.i]) EQ false){
			local.u[local.arrR[local.i]]=true;	
		}else{
			continue;	
		}
		local.p=find("(",local.arrR[local.i]);
    	local.c=trim(mid(local.arrR[local.i],local.p+1,len(local.arrR[local.i])-(local.p+1)));
		if(left(local.c,5) EQ "http:" or left(local.c,6) EQ "https:"){
			continue; // skip absolute references
		}else if(left(local.c,3) EQ "/z/"){
			// zcore path
			local.cpath=request.zos.globals.serverHomeDir&removechars(local.c,1,3);
		}else if(local.c CONTAINS "../"){
			// relative path needs to be translated more
			if(arguments.debug) writeoutput('relative using stylesheet path plus translation<br />')
			local.arrPath=listtoarray(getdirectoryfrompath(arguments.s)&local.c,"/","true");
			local.arrNew=arraynew(1);
			for(local.i2=1;local.i2 LTE arraylen(local.arrPath);local.i2++){
				if(trim(local.arrPath[local.i2]) EQ "."){
					continue;	
				}else if(local.arrPath[local.i2] EQ ".."){
					if(arraylen(local.arrNew) GT 0){
						arraydeleteat(local.arrNew, arraylen(local.arrNew));	
					}
					continue;
				}else{
					arrayappend(local.arrNew, local.arrPath[local.i2]);	
				}
			}
			local.cpath=arraytolist(local.arrNew,"/");
			if(left(local.cpath, len(request.zos.globals.homedir)) NEQ request.zos.globals.homedir){
				application.zcore.template.fail("CSS File, ""#arguments.s#"", has a security flaw. This url, ""#local.c#"", tries to access a file below the document root.  This must be corrected before continuing.");	
			}
		}else if(left(local.c,1) NEQ "/"){
			// relative - use stylesheet path info
			if(arguments.debug) writeoutput('relative using stylesheet path<br />')
			local.cpath=getdirectoryfrompath(arguments.s)&local.c;
		}else{
			// normal path
			if(arguments.debug) writeoutput('root relative path<br />')
			local.cpath=request.zos.globals.homeDir&removechars(local.c,1,1);
		}
		if(fileexists(local.cpath) EQ false){
			// skip missing files
			continue;
		}
		if(structkeyexists(local.uc, local.cpath) EQ false){
			local.uc[local.cpath]=application.zcore.functions.zGetDataURIForFile(local.cpath);
		}
		local.ts=structnew();
		local.ts.abspath=local.cpath;
		local.ts.csspath=local.arrR[local.i];
		local.ts.datauri="url("&local.uc[local.cpath]&"); *background-image:"&local.arrR[local.i]&"";
		arrayappend(local.arrC, ts);
		if(arguments.debug) writeoutput(local.cpath&'<br />');
		
    }
	for(local.i=1;local.i LTE arraylen(local.arrC);local.i++){
		local.d=replace(local.d,local.arrC[local.i].csspath,local.arrC[local.i].datauri,"all");
	}
	if(arguments.debug) application.zcore.functions.zabort();
    return local.d;
    </cfscript>
</cffunction>

<!--- zGetDataURIForFile(filepath, mimetype); --->
<cffunction name="zGetDataURIForFile" localmode="modern" output="no" returntype="any">
	<cfargument name="filepath" type="string" required="yes">
    <cfargument name="mimetype" type="string" required="no" default="">
    <cfscript>
	var local=structnew();
	if(arguments.mimetype EQ ""){
		// autodetect from file extension
		local.ext=application.zcore.functions.zGetFileExt(arguments.filepath);
		if(local.ext EQ	"jpg" or local.ext EQ	"jpeg"){
			arguments.mimetype = "image/jpeg";
		}else if(local.ext EQ	"gif"){
			arguments.mimetype = "image/gif";
		}else if(local.ext EQ	"png"){
			arguments.mimetype = "image/png";
		}else{
			application.zcore.template.fail("#arguments.filepath# is not a valid mime type for image data uri yet.");
		}
	}
	if(fileexists(arguments.filepath) EQ false){
		application.zcore.template.fail("#arguments.filepath# is missing");
	}
	local.f=filereadbinary(arguments.filepath);
	return "data:"&arguments.mimetype&";base64,"&binaryencode(local.f,"Base64");
	</cfscript>
</cffunction>


<cffunction name="zGetFileAttrib" localmode="modern" output="false" returntype="any">
	<cfargument name="filePath" required="yes" type="string">
	<cfscript>
	var qdir=0;
	if(fileexists(arguments.filePath) EQ false){
		application.zcore.functions.zError('zGetFileAttrib: filePath, #filePath#, doesn''t exist');
	}
	</cfscript>
	<cfdirectory name="qDir" directory="#getDirectoryFromPath(arguments.filePath)#" filter="#getFileFromPath(arguments.filePath)#" action="list">
	<cfscript>
	return qDir;
	</cfscript>
</cffunction>

<!--- zReadDirectory(path); --->
<cffunction name="zReadDirectory" localmode="modern" output="no" returntype="any">
	<cfargument name="path" required="yes" type="string">
	<cfargument name="filter" required="no" type="string" default="">
	<cfscript>
	var qdir=0;
	if(directoryexists(arguments.path) EQ false){
		application.zcore.template.fail('zReadDirectory: arguments.path, #arguments.path#, doesn''t exist');
	}
	</cfscript>
	<cfdirectory name="qDir" directory="#getDirectoryFromPath(arguments.path)#" filter="#arguments.filter#" action="list">
	<cfscript>
	return qDir;
	</cfscript>
</cffunction>

<!--- 
// specify the hash path root dir and the unique id that determines the path for the files
rs=zGetHashPath(dir, id);
 --->
<cffunction name="zGetHashPath" localmode="modern" output="no" returntype="string">
	<cfargument name="dir" type="string" required="yes">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	var np=lcase(hash(arguments.id));
	np=arguments.dir&mid(np,1,1)&'/'&mid(np,2,1)&'/'&mid(np,3,1)&'/';
	if(directoryexists(np)){
		return np;
	}
	if(directoryexists(arguments.dir)){
		arguments.dir=replace(arguments.dir,'\','/','ALL');
		if(right(arguments.dir,1) NEQ '/'){
			application.zcore.template.fail("FUNCTION: zGetHashPath() - arguments.dir must have a trailing slash.");
		}
		if(not directoryexists(arguments.dir&mid(np,1,1))){
			directorycreate(arguments.dir&mid(np,1,1));
		}
		if(not directoryexists(arguments.dir&mid(np,1,1)&'/'&mid(np,2,1))){
			directorycreate(arguments.dir&mid(np,1,1)&'/'&mid(np,2,1));
		}
		if(not directoryexists(arguments.dir&mid(np,1,1)&'/'&mid(np,2,1)&'/'&mid(np,3,1)&'/')){
			directorycreate(arguments.dir&mid(np,1,1)&'/'&mid(np,2,1)&'/'&mid(np,3,1)&'/');
		}
	}else{
		application.zcore.template.fail("FUNCTION: zGetHashPath() - arguments.dir must be an existing directory with a trailing slash.");
	}
	if(not directoryexists(np)){
		application.zcore.template.fail("FUNCTION: zGetHashPath() - failed to create directory: "&np);
	}
	return np;
	</cfscript>    
</cffunction>

<!--- FUNCTION: zRenameFile(fileName, newFileName) --->
<!--- always clean filepath before using this, otherwise system may be damaged. ---->
<cffunction name="zRenameFile" localmode="modern" returntype="any" output="true">
	<cfargument name="fileName" required="true" type="string">
	<cfargument name="newFileName" required="true" type="string">
	<cfscript>
	var cfcatch=0;
	if(fileExists(arguments.fileName)){
		if(fileExists(arguments.newFileName) EQ false){
			try{
				filemove(arguments.fileName, arguments.newFileName);
			}catch(Any local.e){
				return false;
			}
			return true;
		}else{
			return false;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<!--- FUNCTION: zRenameDirectory(dirName, newDirName) --->
<cffunction name="zRenameDirectory" localmode="modern" returntype="any" output="true">
	<cfargument name="dirName" required="true" type="string">
	<cfargument name="newDirName" required="true" type="string">
	<cfscript>
	var cfcatch=0;
	if(directoryExists(arguments.dirName)){
		if(directoryExists(arguments.newDirName) EQ false){
			try{
				directoryrename(arguments.dirName, arguments.newDirName);
			}catch(Any local.e){
				return "Directory could not be moved from: "&arguments.dirName&" to: " & arguments.newDirName & "<br /><br />Set parent directory permissions to chmod 770"
			}
			return true;
		}else{
			return false;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<!--- FUNCTION: zDeleteDirectory(dirName) --->
<cffunction name="zDeleteDirectory" localmode="modern" returntype="any" output="false">
	<cfargument name="dirName" required="true" type="string">
	<cfscript>
	var dirContents = "";
	var result=0;
	var cfcatch=0;
	var e=0;
	if(directoryExists(arguments.dirName)){
		directorydelete(arguments.dirName, true);
	}
	return true;
	</cfscript>
</cffunction>



<!--- FUNCTION: zFileStringFormat(fileName) --->
<cffunction name="zFileStringFormat" localmode="modern" returntype="any" output="false">
	<cfargument name="fileName" required="true" type="string"> 
    <cfscript>
	var fileNameOriginal=arguments.fileName;
	arguments.fileName=replace(trim(rereplacenocase(arguments.fileName,"[^a-z^0-9^\-^\.]+"," ","all"))," ","-","all");
	</cfscript>
	<cfif arguments.fileName EQ ""><cfthrow detail="Invalid file name after being formatted.  Original filename: #fileNameOriginal#"></cfif>
	<cfreturn arguments.fileName>
</cffunction>

<!--- FUNCTION: zDirectoryStringFormat(fileName) --->
<cffunction name="zDirectoryStringFormat" localmode="modern" returntype="any" output="false">
	<cfargument name="dirName" required="true" type="string">
    <cfscript>
	var dirNameOriginal=arguments.dirName;
	arguments.dirName=replace(trim(rereplacenocase(arguments.dirName,"[^a-z^0-9^\-^\.]+"," ","all"))," ","-","all");
	</cfscript>
	<cfif arguments.dirName EQ ""><cfthrow detail="Invalid directory name after being formatted.  Original dirname: #dirNameOriginal#"></cfif>
	<cfreturn arguments.dirName>
</cffunction>

<cffunction name="zIsSafeFileExt" localmode="modern" returntype="boolean" output="no">
	<cfargument name="filePath" type="string" required="yes">
	<cfscript>
	var badTypeList=",asp,aspx,asa,ini,htaccess,cfm,cfc,php,php3,vbs,bat,exe,js,shtml,reg,inc,perl,pl,cgi,php5,php4,php1,php2,phtml,ssi,xhtm,";
	request.zUploadFileErrorCause="";
	ext=application.zcore.functions.zGetFileExt(arguments.filePath);
	if(isDefined('request.zsession.user') EQ false or (structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and application.zcore.user.checkServerAccess() EQ false)){
		badTypeList&='html,htm,';
	}
	if(findnocase(","&ext&",", badTypeList) NEQ 0){
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zFileUploadAll(fieldName, destination, overwrite); --->
<cffunction name="zFileUploadAll" localmode="modern" returntype="struct" output="yes">
	<cfargument name="fieldName" required="true" type="string">
	<cfargument name="destination" required="true" type="string">
	<cfargument name="overwrite" required="false" type="boolean" default="#false#" hint="true/false value">
	<cfscript>
	if(arguments.overwrite){
		nameconflict="overwrite";
	}else{
		nameconflict="makeunique";
	}
	if(not directoryexists(arguments.destination)){
		throw("Directory doesn't exist: "&arguments.destination);
	}
	rs={
		arrError:[],
		arrFile:[]
	};
	file action="uploadAll" result="cffileresult" destination="#arguments.destination#" nameconflict="#nameconflict#" filefield="#arguments.fieldName#";
	for(n=1;n LTE arraylen(cffileresult);n++){
		currentFile=cffileresult[n].serverDirectory&"/"&cffileresult[n].clientfile;
		if(not application.zcore.functions.zIsSafeFileExt(currentFile)){
			arrayAppend(rs.arrError, "Security filter deleted "&cffileresult[n].clientfile&".  You can't upload this file type.");
			application.zcore.functions.zdeletefile(currentFile);
		}else{
			arrayAppend(rs.arrFile, currentFile);
		}
	}
	return rs;
	</cfscript>
</cffunction>

<!--- FUNCTION: zUploadFile(fieldName, destination[, overwrite]) --->
<cffunction name="zUploadFile" localmode="modern" returntype="any" output="yes">
	<cfargument name="fieldName" required="true" type="string">
	<cfargument name="destination" required="true" type="string">
	<cfargument name="overwrite" required="false" type="boolean" default="#false#" hint="true/false value">
	<cfscript>
	var fileName = "";
	var i = 0;	
	var cfcatch=0;
	var cffileresult=0;
	var backupfilename="";
	request.zUploadFileErrorCause="";
	application.zcore.functions.zCreateDirectory(arguments.destination);
	if(structkeyexists(form, arguments.fieldName) and trim(form[arguments.fieldName]) NEQ ""){
		tempDir=getTempDirectory();
		if(left(form[arguments.fieldName], len(tempDir)) EQ tempDir){
			if(arguments.overwrite){
				arguments.overwrite = "overwrite";
			}else{
				arguments.overwrite = "makeunique";
			}
			try{
				file action="upload" result="cffileresult" destination="#arguments.destination#" nameconflict="#arguments.overwrite#" filefield="#form[arguments.fieldName]#" charset="utf-8";
				request.zos.lastCFFileResult=cffileresult;
			}catch(Any e){
				request.zUploadFileErrorCause="cffile upload exception: "&e.message;
				return false;
			}
		}else{
			try{
				result=application.zcore.functions.zcopyfile(form[arguments.fieldName], arguments.destination, arguments.overwrite);
				if(result EQ false){
					if(structkeyexists(Request, 'zCopyFileError')){
						throw(Request.zCopyFileError);
					}else{
						throw("Failed to copy file for unknown reason.");
					}
				}else{
					fullFileName = GetFileFromPath(result);
					if(not application.zcore.functions.zIsSafeFileExt(fullFileName)){
						application.zcore.functions.zdeletefile("#arguments.destination##fullFileName#");
						application.zcore.template.fail("Extremely dangerous file upload attempted with name: #fullFileName#<br /><br />It has been automatically deleted with a 500 error displayed to the user.");
					}
					request.zos.lastUploadFileName=getfilefrompath(result);
					return fullFileName;
				}
			}catch(Any e){
				request.zUploadFileErrorCause="cffile upload exception: "&e.message;
				return false;
			}

		}
	}else{
		request.zUploadFileErrorCause="Error: FieldName was not set.";
		return false;
	}
	if(not application.zcore.functions.zIsSafeFileExt(cffileresult.clientfile)){
		application.zcore.functions.zdeletefile("#arguments.destination##cffileresult.serverfile#");
		application.zcore.template.fail("Extremely dangerous file upload attempted with name: #cffileresult.serverfile#<br /><br />It has been automatically deleted with a 500 error displayed to the user.");
		return false;
	}

	fileName=application.zcore.functions.zURLEncode(application.zcore.functions.zGetFileName(cffileresult.serverfile), "-");
	pathName=getdirectoryfrompath(arguments.destination);
	fileExtension=application.zcore.functions.zGetFileExt(cffileresult.serverfile);
	count=1;
	if(compare(cffileresult.serverfile, fileName&"."&fileExtension) NEQ 0){
		if(directoryexists(arguments.destination)){
			pathName=arguments.destination;
			if(right(pathName, 1) NEQ "/"){
				pathName&="/";
			}
			arguments.destination = pathName&fileName&count&"."&fileExtension;
		} 
		exists=true;
		while(exists){
			if(fileexists(arguments.destination)){
				count = count + 1;
				arguments.destination = pathName&fileName&count&"."&fileExtension;
			}else{
				exists = false;
			}
			if(count GT 100){
				Request.zCopyFileError = "Rename File failed: Possible infinite loop";
				return cffileresult.serverfile;
			}
		}
		conflict="error";
		result=application.zcore.functions.zrenamefile(pathName&cffileresult.serverfile, arguments.destination);

		if(result EQ false){
			request.zos.lastUploadFileName=cffileresult.serverfile;
			return cffileresult.serverfile;
		}else{
			request.zos.lastUploadFileName=fileName&count&"."&fileExtension;
			return fileName&count&"."&fileExtension;
		}
	}else{
		request.zos.lastUploadFileName=cffileresult.serverfile;
		return cffileresult.serverfile;
	}
	</cfscript>
</cffunction>


<!--- FUNCTION: zWriteFile(filePath, srcString) --->
<cffunction name="zWriteFile" localmode="modern" returntype="boolean" output="false">
	<cfargument name="filePath" required="yes" type="string">
	<cfargument name="srcString" required="yes" type="string">
	<cfargument name="mode" required="no" type="string" default="660">
	<cfargument name="throwError" required="no" type="boolean" default="#false#">
    <cfscript>
    var cfcatch=0;
	var tempUnique='###getTickCount()#';
	</cfscript>
	<cfif arguments.filePath NEQ "">
		<cftry><!--- mode="#arguments.mode#" --->
            <cffile  addnewline="no" action="write" nameconflict="overwrite" charset="utf-8" file="#arguments.filePath##tempUnique#" output="#arguments.srcString#">
            <cfif compare(arguments.filePath&tempUnique , arguments.filePath) NEQ 0>
                <cflock name="#request.zos.installPath#|file|#arguments.filePath#" timeout="60" type="exclusive">
                    <cffile action="rename" nameconflict="overwrite" source="#arguments.filePath##tempUnique#" destination="#arguments.filePath#">
                </cflock>
            </cfif>
		 	<cfcatch type="any">
			 	<cfif arguments.throwError>
					<cfrethrow>
				</cfif>
				<cfreturn false>
			</cfcatch>
		</cftry>
	<cfelse>
		<cfscript>
		throw('zWriteFile: filePath cannot be an empty string.');
		</cfscript>
	</cfif>
	<cfreturn true>
</cffunction>

<!--- FUNCTION: zDeleteFile(fileName) --->
<cffunction name="zDeleteFile" localmode="modern" returntype="any" output="false">
	<cfargument name="fileName" required="true" type="string">
	<cfscript>
	var cfcatch=0;
	</cfscript>
	<cfif fileExists(arguments.fileName)>
		<cftry>
			<cffile action="delete" file="#arguments.fileName#">
			<cfcatch type="any"><cfreturn false></cfcatch>
		</cftry>
	<cfelse>
		<!--- file doesn't exist. --->
		<cfreturn false>
	</cfif>
	<cfreturn true>
</cffunction>

<!--- zUploadFileToDb(fieldName, destination, [tableName], [primary_key_id], [delete], [datasource]); 
notes: optionally delete an existing image that has a field in the specified database ---> 
<cffunction name="zUploadFileToDb" localmode="modern" returntype="any" output="true">
	<cfargument name="fieldName" required="true" type="string">
	<cfargument name="destination" required="true" type="string">
	<cfargument name="tableName" required="false" type="string">
	<cfargument name="primary_key_id" required="false" type="string">
	<cfargument name="delete" required="false" type="string">
	<cfargument name="datasource" required="false" type="string" default="#request.zos.globals.datasource#">
	<cfargument name="fieldNameOverride" required="false" type="string" default="">
	<cfscript>
	var local=structnew();
	var qImage = "";
	var fileNewName = "";
	var db=request.zos.queryObject;
	var fileName = "";
	application.zcore.functions.zCreateDirectory(arguments.destination);
	if(structkeyexists(arguments, 'tableName') and trim(arguments.tableName) NEQ "" and  structkeyexists(arguments, 'primary_key_id') and structkeyexists(form, arguments.primary_key_id)){
		if(arguments.fieldNameOverride EQ ""){
			arguments.fieldNameOverride=arguments.fieldName;
		}
		db.sql="SHOW FIELDS FROM #db.table(arguments.tableName, arguments.datasource)# LIKE #db.param('site_id')#";
		local.qC=db.execute("qC");
    	db.sql="SHOW FIELDS FROM #db.table(arguments.tableName, arguments.datasource)# LIKE #db.param(arguments.tableName&'_deleted')#";
		local.qC2=db.execute("qC");
		db.sql="SELECT #arguments.fieldNameOverride# FROM #db.table(arguments.tableName, arguments.datasource)# #arguments.tableName# 
		WHERE #arguments.primary_key_id# = #db.param(form[arguments.primary_key_id])# ";
		if(local.qC2.recordcount){
			db.sql&=" and #arguments.tableName#_deleted = #db.param(0)# ";
		}
		if(local.qC.recordcount NEQ 0){
			db.sql&=" and site_id = #db.param(request.zos.globals.id)# ";
		}
		qImage=db.execute("qImage");
		if(structkeyexists(arguments, 'delete') and structkeyexists(form, arguments.delete) and qImage[arguments.fieldNameOverride] NEQ ""){
			application.zcore.functions.zDeleteFile(arguments.destination & qImage[arguments.fieldNameOverride]);
			fileNewName = "";
		}else if(qImage.recordcount NEQ 0){
			fileNewName = qImage[arguments.fieldNameOverride];	
		}else{
			fileNewName='';
		}
		if(structkeyexists(form, arguments.fieldName) and form[arguments.fieldName] NEQ ""){
			fileName = application.zcore.functions.zUploadFile(arguments.fieldName, arguments.destination, false);
			if(fileName NEQ false){
				if(qImage[arguments.fieldNameOverride] NEQ ""){
					application.zcore.functions.zDeleteFile(arguments.destination & qImage[arguments.fieldNameOverride]);
				}
				return fileName;
			}else{
				return fileNewName;
			}
		}else{
			return fileNewName;
		}
	}else{
		if(structkeyexists(form, arguments.fieldName) and form[arguments.fieldName] NEQ ""){
			fileName = application.zcore.functions.zUploadFile(arguments.fieldName, arguments.destination, false);
			if(fileName NEQ false){
				return fileName;
			}else{
				return "";
			}
		}else{
			return "";
		}
	}
	</cfscript>
</cffunction>

<!--- zUploadResizedImagesToDb(fieldName, destination, resizeList, [tableName], [primary_key_id], [delete], [datasource], [autocroplist], [site_id], [deleteOriginal]); 
notes: optionally delete an existing image that has a field in the specified database ---> 
<cffunction name="zUploadResizedImagesToDb" localmode="modern" returntype="any" output="true">
	<cfargument name="fieldName" required="yes" type="string">
	<cfargument name="destination" required="yes" type="string">
	<cfargument name="resizeList" required="no" type="string" default="">
	<cfargument name="tableName" required="no" type="string" default="">
	<cfargument name="primary_key_id" required="no" type="string" default="">
	<cfargument name="delete" required="no" type="string" default="">
	<cfargument name="datasource" required="no" type="string" default="#request.zos.globals.datasource#">
	<cfargument name="autocropList" required="no" type="string" default="">
	<cfargument name="site_id" required="no" type="string" default="#request.zos.globals.id#">
	<cfargument name="deleteOriginal" required="no" type="boolean" default="#true#">
	<cfscript>
	var local=structnew();
	var arrFiles = ArrayNew(1);
	var qimage="";
	var i=0;
	var filePath = "";
	var db=request.zos.queryObject;
	request.zImageErrorCause="";
	if(arguments.tableName NEQ "" and trim(arguments.tableName) NEQ "" and arguments.primary_key_id NEQ "" and structkeyexists(form, arguments.primary_key_id)){
    	db.sql="SHOW FIELDS FROM #db.table(arguments.tableName, arguments.datasource)# LIKE #db.param('site_id')#";
		local.qC=db.execute("qC");
    	db.sql="SHOW FIELDS FROM #db.table(arguments.tableName, arguments.datasource)# LIKE #db.param(arguments.tableName&'_deleted')#";
		local.qC2=db.execute("qC");
		db.sql="SELECT #arguments.fieldName# FROM #db.table(arguments.tableName, arguments.datasource)# #arguments.tableName# 
		WHERE #arguments.primary_key_id# = #db.param(form[arguments.primary_key_id])#";
		if(local.qC.recordcount NEQ 0){
			db.sql&=" and site_id = #db.param(arguments.site_id)# ";
		}
		if(local.qC2.recordcount NEQ 0){
			db.sql&=" and `#arguments.tableName#_deleted` = #db.param(0)# ";
		}
		qImage=db.execute("qImage");
		if(arguments.delete NEQ "" and structkeyexists(form, arguments.delete)){
			for(i=1;i LTE listLen(arguments.fieldName);i=i+1){
				application.zcore.functions.zDeleteFile(arguments.destination & qImage[listGetAt(arguments.fieldName, i)]);
			}	
			arrFiles = ArrayNew(1);
			arrayAppend(arrFiles,"");
		}else{
			arrFiles = ArrayNew(1);
			for(i=1;i LTE listLen(arguments.fieldName);i=i+1){
				arrFiles[i] = qImage[listGetAt(arguments.fieldName, i)];
			}
		}
		if(arguments.fieldName NEQ "" and structkeyexists(form, listGetAt(arguments.fieldName, 1)) and fileexists(form[listGetAt(arguments.fieldName, 1)])){
			filePath=application.zcore.functions.zUploadFile(listGetAt(arguments.fieldName, 1), arguments.destination);
			if(filePath EQ false){ 
				request.zImageErrorCause="Error: FieldName was not set.";
				return false;
			}
			filePath=arguments.destination&filePath;
			local.ext=application.zcore.functions.zGetFileExt(filePath); 
			if(local.ext NEQ "jpeg" and local.ext NEQ "jpg" and local.ext NEQ "png" and local.ext NEQ "gif"){
				application.zcore.functions.zDeleteFile(filePath);
				return false;
			}
			try{
				arrFiles = application.zcore.functions.zResizeImage(filePath,arguments.destination,arguments.resizeList,arguments.autocropList);
				if(arguments.deleteOriginal){
					application.zcore.functions.zDeleteFile(filePath);
				}
			}catch(Any local.excpt){ 
				if(arguments.deleteOriginal){
					application.zcore.functions.zDeleteFile(filePath);
				}
				request.zImageErrorCause="galleryCom.resizeImage exception: #local.excpt.message#";
				return false;
			}
			for(i=1;i LTE listLen(arguments.fieldName);i=i+1){
				application.zcore.functions.zDeleteFile(arguments.destination & qImage[listGetAt(arguments.fieldName, i)]);
			}
			return arrFiles;
		}else{
			return arrFiles;
		}
	}else{
		if(arguments.fieldName NEQ "" and structkeyexists(form, listGetAt(arguments.fieldName, 1)) and fileexists(form[listGetAt(arguments.fieldName, 1)])){
			filePath=application.zcore.functions.zUploadFile(listGetAt(arguments.fieldName, 1), arguments.destination);
			if(filePath EQ false){ 
				request.zImageErrorCause="Error: FieldName was not set.";
				return false;
			} 
			filePath=arguments.destination&filePath;
			local.ext=application.zcore.functions.zGetFileExt(filePath);
			if(local.ext NEQ "jpeg" and local.ext NEQ "jpg" and local.ext NEQ "png" and local.ext NEQ "gif"){
				application.zcore.functions.zDeleteFile(filePath);
				return false;
			}
			try{
				arrFiles = application.zcore.functions.zResizeImage(filePath,arguments.destination,arguments.resizeList,arguments.autocropList);
				if(arguments.deleteOriginal){
					application.zcore.functions.zDeleteFile(filePath);
				}
			}catch(Any local.excpt){ 
				if(arguments.deleteOriginal){
					application.zcore.functions.zDeleteFile(filePath);
				}
				request.zImageErrorCause="galleryCom.resizeImage exception: #local.excpt.message#";
				return false;
			}
			return arrFiles;
		}else{
			return ArrayNew(1);
		}
	}
	</cfscript>
</cffunction>

<cffunction name="zGetImageSize" localmode="modern" returntype="struct">
	<cfargument name="source" required="yes" type="string">
	<cfscript>
	var output = 0;
	secureCommand="getImageMagickIdentify"&chr(9)&arguments.source;
	output=trim(application.zcore.functions.zSecureCommand(secureCommand, 10));
	if(output CONTAINS "," and listlen(output,",") GTE 4){
		arrOut=listtoarray(output, ",");
		ext=application.zcore.functions.zGetFileExt(arguments.source);
		if(ext NEQ "gif" and ext NEQ "png" and lcase(arrOut[3]) NEQ "srgb"){
			form.invalidImagePath=arguments.source;
			return{ success: false, errorMessage:"The image must be converted to the sRGB color profile.  It is currently: "&arrOut[3] };
		}
		return { success:true, width:arrOut[1], height:arrOut[2], quality:arrOut[4] };
	}else{
		return{ success: false, errorMessage:"Unable to read image dimensions. Output:""#output#"".  The image may be corrupted or an unsupported format.  Please try again with a RGB jpg, png or gif." };
		//application.zcore.template.fail("resizeImage: failed to get source image dimensions with zSecureCommand: "&secureCommand&" | Output: "&output,true);
	}
	</cfscript>
</cffunction>


<!--- zResizeImage(source,destination,sizeList,autoCrop,overwrite,newFileName); --->
<cffunction name="zResizeImage" localmode="modern" returntype="any" output="true">
    <cfargument name="source" required="yes" type="string">
    <cfargument name="destination" required="yes" type="string">
    <cfargument name="sizeList" required="yes" type="string">
    <cfargument name="autoCropList" required="no" type="string" default="">
    <cfargument name="overwrite" required="no" type="boolean" default="#false#">
    <cfargument name="newFileName" required="no" type="string" default="">
    <cfscript>
    var tempImage="";
    var fileName = GetFileFromPath(arguments.source);
    var output = "";
    var arrSizes = ListToArray(arguments.sizeList);
    var tempDestination = arguments.destination;
    var filePath = "";
    var crop = "";
    var newWidth = 0;
    var newHeight = 0;
    var currentWidth = 0;
    var currentHeight = 0;
    var i=0;
    var n=0;
    var myImage="";
    var arrSize = "";
    var autocrop=false;
	var cfcatch=0;
    var arrFiles = ArrayNew(1); 
    var arrCrop=arraynew(1);
    var cropY=true;
    var backupWidth=0;
    var backupHeight=0;
    var qtype=0;
    var finalExt=".jpg";
    var dooffset=0;
	var nw2=0;
	var nw=0;
	var ratio=0;
	var resizeCMD=0;
	var nhBackup=0;
	var nh=0;
    this.arrImageWidth=arraynew(1);
    this.arrImageHeight=arraynew(1);
    // prevent hacking the command line
    arguments.source = replace(arguments.source, '"',"","ALL"); 
    // throw critical errors
    if(ArrayLen(arrSizes) EQ 0){
        application.zcore.template.fail("resizeImage: sizeList must contain one of more sizes (i.e. 150x120) as comma seperated values.",true); 
    }
    tempDestination = replace(tempDestination, '\','/',"ALL");
    if(directoryexists(tempDestination) EQ false){
        application.zcore.template.fail("resizeImage: destination directory doesn't exist.",true);
    }
    if(right(tempDestination,1) NEQ '/'){
        tempDestination = tempDestination&"/";
    }
    if(fileexists(arguments.source) EQ false){
        throw("resizeImage: source file doesn't exist. Path: #arguments.source#");
        // start writing trace message that show up in debugger, but don't force errors.
        return false;
    }
    // remove file extension
    fileName = application.zcore.functions.zURLEncode(application.zcore.functions.zGetFileName(fileName), "-");
    // fail when fileName is an empty string
    if(len(fileName) EQ 0){
        return false;
    } 
	local.imageSize=application.zcore.functions.zGetImageSize(arguments.source);         
	if(not local.imageSize.success){
		throw(local.imageSize.errorMessage);
	}
	if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){ 
		writeoutput("identify: #local.imageSize.width#x#local.imageSize.height# | quality:#local.imageSize.quality#<br />"); 
	} 
    
    if(right(arguments.source,4) EQ ".png"){
        finalExt=".png";
    }
    
    backupWidth=local.imageSize.width;
    backupHeight=local.imageSize.height; 
    // loop size array
    if(arguments.autoCropList NEQ ""){
        arrCrop=listtoarray(arguments.autoCropList);	
        if(arraylen(arrCrop) NEQ arraylen(arrSizes)){
            application.zcore.template.fail("resizeImage: sizeList and autocrop lists must be the same length.",true);
            // start writing trace message that show up in debugger, but don't force errors.
            return false;
        }
    }
    if(arguments.newFileName NEQ ""){
        fileName=application.zcore.functions.zURLEncode(application.zcore.functions.zGetFileName(arguments.newFileName), "-");
    }
    request.arrLastImageWidth=arraynew(1);
    request.arrLastImageHeight=arraynew(1);
    for(n=1;n LTE arraylen(arrSizes);n++){
        currentWidth=backupWidth;
        currentHeight=backupHeight;
        if(arguments.autocropList NEQ "" and arrCrop[n] NEQ "0"){
            autocrop=true;	
        }else{
            autocrop=false;
        }
        // force a unique file name for each size
        if(arguments.overwrite){
            if(n EQ 1){
                filePath = tempDestination&fileName&finalExt;		
            }else{
                filePath = tempDestination&fileName&n&finalExt;		
            }
        }else{
            if(fileexists(tempDestination&fileName&finalExt)){
                for(i=1;i LTE 1000;i=i+1){
                    filePath = tempDestination&fileName&i&finalExt;
                    if(fileexists(filePath) EQ false){
                        break;
                    }
                }
                if(i EQ 1000){
                	throw("Unable to make filename unique");
                }
            }else{
                filePath = tempDestination&fileName&finalExt;
            }
        } 
        try{ 
            newWidth = listGetAt(arrSizes[n],1,"x");
            newHeight = listGetAt(arrSizes[n],2,"x");
        }catch(Any excpt){
            application.zcore.template.fail("resizeImage: size, `#arrSizes[n]#`, is an invalid format.  You must specify your sizes like 140x120 (widthxheight).",true);
        } 
        ratio=newWidth/currentWidth;
        nw=round(currentWidth*ratio);
        nh=round(currentHeight*ratio);
        if(autocrop EQ false and nh GT newHeight){
            ratio=newHeight/currentHeight;
            nw=round(currentWidth*ratio);
            nh=round(currentHeight*ratio);
        }
		if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){ 
			writeoutput(backupWidth&"<br />"); 
			writeoutput("#nw#x#nh#<br />"); 
		}
		
		resizeCMD='-resize "#nw#x#nh#>" ';
		cs={};
		cs.resizeWidth=nw;
		cs.resizeHeight=nh;
		cs.cropWidth=0;
		cs.cropHeight=0;
		cs.cropXOffset=0;
		cs.cropYOffset=0;
		cs.destinationFilePath="";
		cs.sourceFilePath="";
		
		if(currentWidth GT nw){
			qtype="highQuality";
			currentHeight=nh;
		}
		if(autocrop){
			nhBackup=nh;
			nh=currentHeight;
			dooffset=false;
			if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){ 
				writeoutput('nw-newWidth: '&(nw-newWidth)&'<br />');
				writeoutput('nh-newHeight: '&(nh-newHeight)&'<br />');
			}
			if(nh-newHeight GTE 0){
				nw=0;
				nh=round((nh-newHeight)/2);	 
				dooffset=true;
				if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){ 
					writeoutput("height crop updated: #nh#<br />"); 
				}
			}else{
				resizeCMD='-resize "#currentWidth#x#newHeight#>" ';
				cs.resizeWidth=currentWidth;
				cs.resizeHeight=newHeight;
				nw=0;
				nh=0;
				if(currentWidth GT newWidth){
					// convert to the new small width, before calculating below 
					tempWidth=round((newHeight/backupHeight)*backupWidth);
					if(tempWidth-newWidth GT 0){
						resizeCMD='-resize "#tempWidth#x#newHeight#>" ';
						cs.resizeWidth=tempWidth;
						cs.resizeHeight=newHeight;
						if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){ 
							writeoutput("tempWidth: #tempWidth#<br />"); 
						}
						nw=round((tempWidth-newWidth)/2);
						dooffset=true;
						if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){ 
							writeoutput("width crop updated: #nw#<br />"); 
						}
					}
				}
			}
			if(dooffset){
				resizeCMD&="-crop #newWidth#x#newHeight#+#nw#+#nh# ";
				cs.cropWidth=newWidth;
				cs.cropHeight=newHeight;
				cs.cropXOffset=nw;
				cs.cropYOffset=nh;
				if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){ 
					writeoutput("autocrop final<br />"); 
					writeoutput("#newWidth#x#newHeight#<br />");  
					//application.zcore.functions.zabort();
				}
			}
		}
		resizeCMD&=' "#arguments.source#" "#filePath#"';
		cs.sourceFilePath=arguments.source;
		cs.destinationFilePath=filePath;
		/*tempFile="##"&gettickcount();
		tempDest=cs.destinationFilePath&tempFile&"."&application.zcore.functions.zgetFileExt(cs.destinationFilePath);
		application.zcore.functions.zCopyFile(cs.sourceFilePath, tempDest);

		cs.sourceFilePath=tempDest;*/
		if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){ 
			writeoutput(resizeCMD&"<br />");
		}
		secureCommand="getImageMagickConvertResize"&chr(9)&cs.resizeWidth&chr(9)&cs.resizeHeight&chr(9)&cs.cropWidth&chr(9)&cs.cropHeight&chr(9)&cs.cropXOffset&chr(9)&cs.cropYOffset&chr(9)&cs.sourceFilePath&chr(9)&cs.destinationFilePath;
		output=application.zcore.functions.zSecureCommand(secureCommand, 10); 
		if(output NEQ "1"){
			if(request.zos.isDeveloper){
				throw("Failed to resize image with zSecureCommand: "&secureCommand&" | Output: "&output);
			}
			return false;
		}
		local.imageSize=application.zcore.functions.zGetImageSize(filePath);        
		if(not local.imageSize.success){
			throw(local.imageSize.errorMessage);
		}
		arrayAppend(request.arrLastImageWidth,local.imageSize.width);
		arrayAppend(request.arrLastImageHeight,local.imageSize.height); 
        if(fileexists(filePath) EQ false){
            return false;
        }  
        if(output EQ false){
            // failed to execute command for resizing image
            return false;
        }else{
            // save filename
            ArrayAppend(arrFiles, GetFileFromPath(filePath));
        }
    }
    return arrFiles;
    </cfscript>
</cffunction>


<cffunction name="zApplyMaskToImage" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var result=0;
	application.zcore.functions.zdeletefile(arguments.ss.absImageOutputPath);
	arguments.ss.absImageInputPath=(replace(arguments.ss.absImageInputPath, chr(9), "", "all")); 
	if(not fileexists(arguments.ss.absImageMaskPath)){
		throw("arguments.ss.absImageInputPath, ""#arguments.ss.absImageInputPath#"", doesn't exist.");
	}
	arguments.ss.absImageOutputPath=(replace(arguments.ss.absImageOutputPath, chr(9), "", "all")); 
	outputDir=getdirectoryfrompath(arguments.ss.absImageOutputPath);
	if(not directoryexists(outputDir)){
		throw("arguments.ss.absImageOutputPath's parent directory, ""#outputDir#"", doesn't exist.");
	}
	arguments.ss.absImageMaskPath=(replace(arguments.ss.absImageMaskPath, chr(9), "", "all")); 
	if(not fileexists(arguments.ss.absImageMaskPath)){
		throw("arguments.ss.absImageMaskPath, ""#arguments.ss.absImageMaskPath#"", doesn't exist.");
	}
	result=application.zcore.functions.zSecureCommand("getImageMagickConvertApplyMask"&chr(9)&arguments.ss.absImageInputPath&chr(9)&arguments.ss.absImageOutputPath&chr(9)&arguments.ss.absImageMaskPath, 20);
	if(result NEQ "" and result EQ false){
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<cffunction name="zGetDiskUsage" localmode="modern" output="no" returntype="string">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	if(fileexists(arguments.path) || directoryExists(arguments.path)){
		return listgetat(application.zcore.functions.zSecureCommand("getDiskUsage"&chr(9)&arguments.path, 10), 1, chr(9));
	}else{
		return 0;
	}
	</cfscript>
</cffunction>


<!--- zUploadResizedImage(fieldName, destination, resizeList); 
notes: optionally delete an existing image that has a field in the specified database ---> 
<cffunction name="zUploadResizedImage" localmode="modern" returntype="any" output="true">
	<cfargument name="fieldName" required="true" type="string">
	<cfargument name="destination" required="true" type="string">
	<cfargument name="resizeList" required="false" type="string">
    <cfscript>
	var arrFiles=[];
	var filePath=""; 
	var tpath=replace(gettempdirectory(),"\","/","ALL");
	var curPath="";
	var doUpload=false;
	var firstField=listGetAt(arguments.fieldName, 1);
	if(structkeyexists(form, firstField) and fileexists(form[firstField])){
		if(structkeyexists(form, firstField)){
			curPath=replace(form[firstField],"\","/","ALL");
			if(tpath EQ left(curPath, len(tpath))){
				doUpload=true;
			}
		}
		if(doUpload){
			filePath=arguments.destination&application.zcore.functions.zUploadFile(firstField, arguments.destination);
		}else{
			filePath=curPath;
		}
		if(filePath EQ false){ 
			return false;
		} 
		arrFiles = application.zcore.functions.zResizeImage(filePath,arguments.destination,arguments.resizeList,false);
		application.zcore.functions.zDeleteFile(filePath);
	}
	return arrFiles;
	</cfscript>
</cffunction>

<cffunction name="zReadFile" localmode="modern" output="false" returntype="any">
	<cfargument name="filePath" required="yes" type="string">
	<cfscript>
	var returnString = "";
	var cfcatch=0;
	</cfscript>
	<cfif fileexists(arguments.filePath)>
		<cftry>
        	<cflock name="#request.zos.installPath#|file|#arguments.filePath#" timeout="30" throwontimeout="yes" type="readonly">
			<cffile charset="utf-8" action="read" file="#arguments.filePath#" variable="returnString">
            </cflock>
			<cfcatch type="any">
				<cfif request.zos.isdeveloper>
					<cfdump var="#cfcatch#">
					<cfscript>application.zcore.functions.zabort();</cfscript>
				</cfif>
				<cfrethrow>
			</cfcatch>
		</cftry>
	<cfelse>
		<cfreturn false>
	</cfif>
	<cfreturn returnString>
</cffunction>

<cffunction name="zGetFileExt" localmode="modern" output="false" returntype="any">
	<cfargument name="filePath" required="yes" type="string">
    <cfscript>
	var pos=find(".", reverse(arguments.filePath));
	if(pos LTE 1){
		return "";
	}else{
		return right(arguments.filePath, pos-1);
	}
	</cfscript>
</cffunction>

<cffunction name="zGetFileName" localmode="modern" output="false" returntype="any">
	<cfargument name="filePath" required="yes" type="string">
    <cfscript>
	var pos=find(".", reverse(arguments.filePath));
	if(pos EQ 0){
		return "";
	}else{
		if(len(arguments.filepath)-pos EQ 0){
			return "";
		}else{
			return left(arguments.filePath, len(arguments.filepath)-pos);
		}
	}
	</cfscript>
</cffunction>

 
 

<!--- zCopyFile(filePath, newPath, overwrite) --->
<cffunction name="zcopyfile" localmode="modern" returntype="any" output="true">
	<cfargument name="filePath" required="yes" type="any">	
	<cfargument name="newPath" required="no" type="any" default="">	
	<cfargument name="overwrite" required="no" type="boolean" default="#false#">	
	<cfscript>	
	var exists = true;
	var count = 1;
	var cfcatch=0;
	var fullFileName = GetFileFromPath(arguments.filePath);
	var fileName=application.zcore.functions.zURLEncode(application.zcore.functions.zGetFileName(fullFileName), "-");
	var fileExtension = application.zcore.functions.zGetFileExt(fullFileName);
	var conflict="overwrite";
	var pathName = GetDirectoryFromPath(arguments.filePath);
	if(arguments.newPath EQ ""){
		arguments.newPath = pathName&fileName&count&"."&fileExtension;
	}
	if(arguments.overwrite EQ false){
		if(directoryexists(arguments.newPath)){
			pathName=arguments.newPath;
			if(right(pathName, 1) NEQ "/"){
				pathName&="/";
			}
			arguments.newPath = pathName&fileName&count&"."&fileExtension;
		}
		while(exists){
			if(fileexists(arguments.newPath)){
				count = count + 1;
				arguments.newPath = pathName&fileName&count&"."&fileExtension;
			}else{
				exists = false;
			}
			if(count GT 200){
				Request.zCopyFileError = "Copy File failed: Possible infinite loop";
				return false;
			}
		}
		conflict="error";
	}
	try{
		file action="copy" source="#arguments.filePath#" nameconflict="#conflict#" destination="#arguments.newPath#";
	}catch(Any e){
		Request.zCopyFileError = "File Path = "&arguments.filePath&"<br />New Path = "&arguments.newPath&"<br /><br />Coldfusion couldn't copy file to destination, check permissions";
		return false;
	}
	return arguments.newPath;
	</cfscript>
	
</cffunction>


<!--- 
ts=StructNew();
ts.sourceFileName="";
ts.sourceDirectory="";
ts.destinationFilePath="";
ts.overwrite=false;
 --->
<cffunction name="zZipFile" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=StructNew();
	var cfcatch=0;
	ts.overwrite=false;
	StructAppend(arguments.ss,ts,false);
	if(find("/",arguments.ss.sourceFileName) NEQ 0 or find("\",arguments.ss.sourceFileName) NEQ 0){
		return false; // invalid sourceFileName
	}
	if(right(arguments.ss.sourceDirectory,1) EQ '/'){
		arguments.ss.sourceDirectory=left(arguments.ss.sourceDirectory,len(arguments.ss.sourceDirectory)-1);
	}
	if(fileexists(arguments.ss.sourceDirectory&'/'&arguments.ss.sourceFileName) EQ false){
		return false;
	}
	if(directoryexists(getdirectoryfrompath(arguments.ss.destinationFilePath)) EQ false or right(arguments.ss.destinationFilePath,4) NEQ '.zip'){
		return false;
	}
	</cfscript>
	<cftry>
		<cfzip overwrite="#arguments.ss.overwrite#" action="zip" file="#arguments.ss.destinationFilePath#" source="#arguments.ss.sourceDirectory#" filter="#arguments.ss.sourceFileName#"	></cfzip>
	<cfcatch type="any">
		<cfreturn false>
	</cfcatch>
	</cftry>
	<cfreturn true>
</cffunction>
<!--- 
ts=StructNew();
ts.output="";
ts.destinationFilePath="";
ts.overwrite=false;
 --->
<cffunction name="zWriteFileAndZip" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var p="";
	var ts=StructNew();
	var hashName='##'&hash(dateformat(now(),'yyyymmdd')&timeformat(now(),'HHmmss')&'-'&gettickcount());
	var tp="";
	ts.overwrite=false;
	StructAppend(arguments.ss,ts,false);
	if(arguments.ss.overwrite EQ false and fileexists(arguments.ss.destinationFilePath)){
		return false;
	}
	if(directoryexists(getdirectoryfrompath(arguments.ss.destinationFilePath)) EQ false or right(arguments.ss.destinationFilePath,4) NEQ '.zip'){
		return false;
	}
	tp=getdirectoryfrompath(arguments.ss.destinationFilePath)&hashName;
	p=application.zcore.functions.zWriteFile(tp, arguments.ss.output);
	if(p EQ false){
		return false;
	}
	ts=StructNew();
	ts.sourceFileName=hashName;
	ts.sourceDirectory=getdirectoryfrompath(arguments.ss.destinationFilePath);
	ts.destinationFilePath=arguments.ss.destinationFilePath;
	ts.overwrite=arguments.ss.overwrite;
	p=application.zcore.functions.zZipFile(ts);
	application.zcore.functions.zDeleteFile(tp);
	if(p EQ false){
		return false;
	}
	return true;
	</cfscript>
</cffunction>

<!--- 
contents=zReadFileFromZip(zipPath,fileInZipPath,readbinary);
 --->
<cffunction name="zReadFileFromZip" localmode="modern" output="no" returntype="any">
	<cfargument name="zipPath" type="string" required="yes">
    <cfargument name="fileInZipPath" type="string" hint="If fileInZipPath is false, it automatically reads the first file" required="yes">
    <cfargument name="readbinary" type="boolean" required="no" default="#false#">
    <cfscript>
	var c="";
	var qDir="";
	var a="read";
	var cfcatch=0;
	if(arguments.readBinary){
		a="readbinary";
	}
	if(fileexists(arguments.zipPath) EQ false){
		return false;
	}
	</cfscript>
    <cfif arguments.fileInZipPath EQ false>
        <cfzip action="list" file="#arguments.zipPath#" name="qDir"></cfzip>
        <cfscript>
		if(qDir.recordcount EQ 0){
			return false;
		}
		arguments.fileInZipPath=qdir.name;
		</cfscript>
    </cfif>
    <cftry>
        <cfzip action="#a#" file="#arguments.zipPath#" entrypath="#arguments.fileInZipPath#" variable="c"></cfzip>
        <cfcatch type="any">
            <cfreturn false>
        </cfcatch>
    </cftry>
    <cfscript>
	return c;
	</cfscript>
</cffunction>

<!--- zFileExistsInZip(zipPath,fileInZipPath); --->
<cffunction name="zFileExistsInZip" localmode="modern" output="yes" returntype="boolean">
	<cfargument name="zipPath" type="string" required="yes">
    <cfargument name="fileInZipPath" type="string" required="yes">
    <cfscript>
	var qdir=0;
	var mD=replace(getdirectoryfrompath(arguments.fileInZipPath),"\","/","ALL");
	</cfscript>
    <cfif fileexists(arguments.zipPath)>
        <cfzip action="list" file="#arguments.zipPath#" recurse="yes" showdirectory="yes"   filter="#getfilefrompath(arguments.fileInZipPath)#" name="qDir"></cfzip>
        <cfloop query="qDir"><cfif qdir.directory&"/" EQ md><cfreturn true></cfif></cfloop>
    </cfif>
    <cfreturn false>
</cffunction>


<!--- 
// string, number of kilobytes, boolean
application.zcore.functions.zSplitFile(path,kblength,line);
 --->
<cffunction name="zSplitFile" localmode="modern" output="yes" returntype="boolean">
	<cfargument name="path" type="string" required="yes">
	<cfargument name="kblength" type="string" required="yes">
	<cfargument name="line" type="boolean" required="no" default="#true#">
    <cfscript>
	var c="";
	var old="";
	var new="";
	var wfp="";
	var pos=0;
	var dontclose=0;
	var fp=0;
	var offset=0;
	var fileOffset=1;
	var arrFiles=arraynew(1);
	var f1=getfilefrompath(arguments.path);
	var p2=getdirectoryfrompath(arguments.path);
	var fn=application.zcore.functions.zGetFileName(f1);
	var fext=application.zcore.functions.zGetFileExt(f1);
	var np=p2&fn&"_"&(arraylen(arrFiles)+1)&"."&fext;
	var g=1;
	var open=true;
	var error=false;
	if(fileexists(arguments.path) EQ false or directoryexists(p2) EQ false){
		application.zcore.template.fail("zSplitFile: arguments.path, #arguments.path#, does not exist.");	
	}
	try{
		fp=fileopen(arguments.path,"read");
		arrayappend(arrFiles,np);
		wfp=fileopen(np,"write");
		arguments.kblength=arguments.kblength*1024;
		g=2;
		np=p2&fn&"_"&g&"."&fext;
		while(fileexists(np)){
			filedelete(np);
			g++;
			np=p2&fn&"_"&g&"."&fext;
			if(g GT 1000){
				break; // infinite loop?	
			}
		}
		g=1;
		while(FileIsEOF(fp) EQ false){
			g++;
			c=fileread(fp,65536);//32768);
			offset=offset+65536;//32768;
			if(offset GT arguments.kblength){
				dontclose=false;
				old=c;
				new="";
				if(arguments.line){
					pos=find(chr(10),c);
					if(pos NEQ 0){
						old=left(c,pos);
						if(len(c) GT pos){
							new=mid(c,pos+1,len(c)-(pos+1));
						}
						offset=0;
					}else{
						dontclose=true;
					}
				}else{
					offset=0;
					old=left(c,offset-arguments.kblength);
					if(len(c) GT offset-arguments.kblength){
						new=mid(c,(offset-arguments.kblength)+1,len(c)-((offset-arguments.kblength)+1));
					}else{
						new="";	
					}
				}
				if(dontclose EQ false){
					filewrite(wfp, old);
					fileclose(wfp);
					open=false;
					if(FileIsEOF(fp) EQ false){
						np=p2&fn&"_"&(arraylen(arrFiles)+1)&"."&fext;
						arrayappend(arrFiles,np);
						if(arraylen(arrFiles) GT 500){
							error="zSplitFile: Too many files created.  Limit of 500.";	
							break;
						}
						wfp=fileopen(np,"write");
						filewrite(wfp, new);	
						open=true;
					}else{
						c=new;
						break;
					}
				}else{
					filewrite(wfp, c);
				}
			}else{
				filewrite(wfp, c);	
			}
			c="";
		}
		if(open){
			filewrite(wfp, c);
			fileclose(wfp);
		}
		fileclose(fp);
	}catch(Any excpt){
		if(isSimpleValue(fp) EQ false){
			fileclose(fp);
		}
		if(isSimpleValue(wfp) EQ false){
			fileclose(wfp);
		}
	}
	if(error NEQ false){
		application.zcore.template.fail(error);	
	}
	return arrFiles;
	</cfscript>
</cffunction>


<!--- application.zcore.functions.zCopyDirectory(sourceDir, destDir, true); --->
<cffunction name="zCopyDirectory" localmode="modern" output="no" returntype="any">
	<cfargument name="sourceDir" type="string" required="yes">
	<cfargument name="destDir" type="string" required="yes">
	<cfargument name="overwrite" type="boolean" required="no" default="#true#">
	<cfscript>
	var local=structnew();
	var qdir=0;
	arguments.sourceDir=replace(trim(arguments.sourceDir),"\","/","all");
	arguments.destDir=replace(trim(arguments.destDir),"\","/","all");
	if(directoryexists(arguments.sourceDir) EQ false){
		application.zcore.template.fail("arguments.sourceDir and arguments.destDir must exist before running zCopyDirectory();");
	}
	if(directoryexists(arguments.destDir) EQ false){
		application.zcore.template.fail("arguments.sourceDir and arguments.destDir must exist before running zCopyDirectory();");
	}
	if(right(arguments.sourceDir,1) EQ "/"){
		arguments.sourceDir=removechars(arguments.sourceDir,len(arguments.sourceDir),1);
	}
	if(right(arguments.destDir,1) EQ "/"){
		arguments.destDir=removechars(arguments.destDir,len(arguments.destDir),1);
	}
	directory action="list" directory="#arguments.sourceDir#" name="qDir" recurse="yes";
	loop query="qdir"{
		local.tdir=replacenocase(replace(qdir.directory,"\","/","all"),arguments.sourceDir,arguments.destDir);
		if(qdir.type EQ "Dir"){
			writeoutput("create directory: "&local.tdir&"/"&qdir.name&'<br />');
			if(directoryexists(local.tdir&"/"&qdir.name) EQ false){
				directory action="create" directory="#local.tdir#/#qdir.name#" mode="#request.zos.directoryMode#";
			}
		}else{
			if(arguments.overwrite or fileexists(local.tdir&"/"&qdir.name) EQ false){
				writeoutput("copy file from "&qdir.directory&"/"&qdir.name&" to "&local.tdir&"/"&qdir.name&'<br />');
				file action="copy" source="#qdir.directory#/#qdir.name#" destination="#local.tdir#/#qdir.name#" nameconflict="overwrite" mode="#request.zos.fileMode#";
			}
		}
	}
	return true;
	</cfscript>
</cffunction>

<!--- zCompressImage(source); --->
<cffunction name="zCompressImage" localmode="modern" returntype="any" output="true">
    <cfargument name="source" required="yes" type="string"> 
    <cfscript>
    ext=lcase(application.zcore.functions.zGetFileExt(arguments.source));
    if(ext NEQ "jpg" and ext NEQ "jpeg"){
    	return true; // ignore other file types
    } 
	secureCommand="getImageMagickConvertResize"&chr(9)&10000&chr(9)&10000&chr(9)&0&chr(9)&0&chr(9)&0&chr(9)&0&chr(9)&arguments.source&chr(9)&arguments.source;
	output=application.zcore.functions.zSecureCommand(secureCommand, 30);
	if(output NEQ "1"){
		if(request.zos.isDeveloper){
			throw("Failed to resize image with zSecureCommand: "&secureCommand&" | Output: "&output);
		}
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>