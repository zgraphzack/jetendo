<cfcomponent>
<cfoutput>  
	 
<cffunction name="compressSitePrivateHomedirImages" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
 	form.sid=application.zcore.functions.zso(form, 'sid');
 	form.confirm=application.zcore.functions.zso(form, 'confirm', true, 0);
 	d=application.zcore.functions.zvar('privatehomedir', form.sid);

 	echo('<h2>Compress all user writable images for this site</h2>');
 	if(form.confirm EQ 1){

 		compressImages(d);
 	}else{
 		arrFiles=directoryList(d, true, 'path', '*.jpg|*.jpeg');

 		echo('
 			<p><strong>Warning: Clicking yes will recompress #arrayLen(arrFiles)# JPEG image files</strong></p>
 			<p>Do not run this task more then once simultaneously, or you may cause file corruption.</p>
 			<p id="pleaseWait1" style="display:none;">Please wait for the task to complete.</p>
 			<p id="confirmP1"><a href="/z/server-manager/admin/compress-images/compressSitePrivateHomedirImages?sid=#form.sid#&confirm=1" onclick="document.getElementById(''confirmP1'').style.display=''none''; document.getElementById(''pleaseWait1'').style.display=''block''; ">Yes, compress all images</a></p>');
 	}
 	</cfscript>
</cffunction>

<cffunction name="compressSiteHomedirImages" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	if(not request.zos.isTestServer){
		throw("compressSiteHomedirImages should only be run on the test server so that version control matches production.");
	}
 	form.sid=application.zcore.functions.zso(form, 'sid');
 	d=application.zcore.functions.zvar('homedir', form.sid);
 	form.confirm=application.zcore.functions.zso(form, 'confirm', true, 0);

 	echo('<h2>Compress all homedir images for this site on the test server</h2>');
 	if(form.confirm EQ 1){
 		compressImages(d);
 	}else{
 		arrFiles=directoryList(d, true, 'path', '*.jpg|*.jpeg');

 		echo('
 			<p><strong>Warning: Clicking yes will recompress #arrayLen(arrFiles)# JPEG image files</strong></p>
 			<p>Do not run this task more then once simultaneously, or you may cause file corruption.</p>
 			<p id="pleaseWait1" style="display:none;">Please wait for the task to complete.</p>
 			<p id="confirmP1"><a href="/z/server-manager/admin/compress-images/compressSiteHomedirImages?sid=#form.sid#&confirm=1" onclick="document.getElementById(''confirmP1'').style.display=''none''; document.getElementById(''pleaseWait1'').style.display=''block''; ">Yes, compress all images</a></p>');
 	}
 	</cfscript>
</cffunction>


<cffunction name="compressImages" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>  
 	setting requesttimeout="1000000";
 	arrFiles=directoryList(arguments.path, true, 'path', '*.jpg|*.jpeg');
 	//writedump(arguments.path);writedump(arrFiles);abort;
 	lock type="exclusive" timeout="1000000" name="#request.zos.installPath#-compressImages"{
	 	fileCount=0;
	 	for(i=1;i<=arrayLen(arrFiles);i++){
	 		f=arrFiles[i];
			a=application.zcore.functions.zCompressImage(f);   
			fileCount++;
	 	}  
	 	echo(fileCount&' images compressed');
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>