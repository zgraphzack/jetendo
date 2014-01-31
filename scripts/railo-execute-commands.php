<?php
require("library.php");
function processContents($contents){
	$a=explode("\t", $contents);
	$contents=array_shift($a);
	if($contents == "getUserList"){
		return getUserList();
	}else if($contents =="getNewerCoreMVCFiles"){
		return getNewerCoreMVCFiles();
	}else if($contents =="getSystemIpList"){
		return getSystemIpList();
	}else if($contents =="getFileMD5Sum"){
		return getFileMD5Sum($a);
	}else if($contents =="getDiskUsage"){
		return getDiskUsage($a);
	}else if($contents =="tarZipFilePath"){
		return tarZipFilePath($a);
	}else if($contents =="gzipFilePath"){
		return gzipFilePath($a);
	}else if($contents =="getImageMagickIdentify"){
		return getImageMagickIdentify($a);
	}else if($contents =="getImageMagickConvertResize"){
		return getImageMagickConvertResize($a);
	}else if($contents =="getImageMagickConvertApplyMask"){
		return getImageMagickConvertApplyMask($a);
	}else if($contents =="getScryptCheck"){
		return getScryptCheck($a);
	}else if($contents =="getScryptEncrypt"){
		return getScryptEncrypt($a);
	}else if($contents =="verifySitePaths"){
		return verifySitePaths();
	}else if($contents =="installThemeToSite"){
		return installThemeToSite($a);
	}
	return "";
}
function verifySitePaths(){
	// forces site root directories to exist with correct permissions
	$fail=false;
	$cmysql2=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), zGetDatasource());
	if($cmysql2->error != ""){ 
		$fail=true;
		array_push($arrError, "db connect error:".$cmysql2->error);	
	}
	if(!$fail){
		$r=$cmysql2->query("select * from site where site_active='1' and site_short_domain <> '' ");
		if($cmysql2->error != ""){ 
			$fail=true;
			array_push($arrError, "db error:".$cmysql2->error);	
		}
		if(!$fail){

			while($row=$r->fetch_array(MYSQLI_ASSOC)){
				$sitePath=zGetDomainInstallPath($row["site_short_domain"]);
				if($sitePath != "" && !is_dir($sitePath)){
					mkdir($sitePath, 0550);
				}
				if(zIsTestServer()){
					chmod($sitePath, 0777);
				}else{
					chmod($sitePath, 0550);
				}
				chown($sitePath, get_cfg_var("jetendo_www_user"));
				chgrp($sitePath, get_cfg_var("jetendo_www_user"));
				$sitePath=zGetDomainWritableInstallPath($row["site_short_domain"]);
				if($sitePath != "" && !is_dir($sitePath)){
					mkdir($sitePath, 0770);
				}
				if(zIsTestServer()){
					chmod($sitePath, 0777);
				}else{
					chmod($sitePath, 0770);
				}
				chown($sitePath, get_cfg_var("jetendo_www_user"));
				chgrp($sitePath, get_cfg_var("jetendo_www_user"));
			}
		}
	}
}
function installThemeToSite($a){
	if(count($a) != 2){
		echo "2 arguments are required: themeName and siteAbsolutePath.\n";
		return "0";
	}
	$themeName=$a[0];
	$siteAbsolutePath=$a[1];
	$sp=get_cfg_var("jetendo_sites_path");
	if($siteAbsolutePath == ""){
		echo "The siteAbsolutePath is a required argument.\n";
		return "0";
	}

	$siteAbsolutePath=realpath($siteAbsolutePath);
	if($siteAbsolutePath == "" || !is_dir($siteAbsolutePath)){
		echo "The site absolute directory doesn't exist: ".$siteAbsolutePath."\n";
		return "0";
	}
	$found=false;
	if(substr($siteAbsolutePath, 0, strlen($p)) == $p){
		$found=true;
	}
	if(!$found){
		echo "An attempt to break out of the sites directory was detected: ".$siteAbsolutePath."\n";
		return "0";
	}

	$p=get_cfg_var("jetendo_root_path")."themes/";
	if($themeName == ""){
		echo "The themeName is a required argument.\n";
		return "0";
	}

	$themePath=realpath($p.$themeName."/");
	if($themePath == "" || !is_dir($themePath)){
		echo "The theme directory doesn't exist: ".$themePath."\n";
		return "0";
	}
	$found=false;
	if(substr($themePath, 0, strlen($p)) == $p){
		$found=true;
	}
	if(!$found){
		echo "An attempt to break out of the theme directory was detected: ".$themePath."\n";
		return "0";
	}
	if(substr($themePath, strlen($themePath)-1, 1) != "/"){
		$themePath.="/";
	}
	if(substr($siteAbsolutePath, strlen($siteAbsolutePath)-1, 1) != "/"){
		$siteAbsolutePath.="/";
	}
	$cmd='/bin/cp -rf '.escapeshellarg($themePath)."* ".escapeshellarg($siteAbsolutePath);
	$r=`$cmd`;
	$cmd='/bin/chown '.get_cfg_var("jetendo_www_user").':'.get_cfg_var("jetendo_www_user").' '.escapeshellarg($siteAbsolutePath);
	$r=`$cmd`;
	$isTestServer=zIsTestServer();
	$preview=false;
	$arrError=array();
	$result=zCheckDirectoryPermissions($siteAbsolutePath, get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "440", "550", true, $preview, $arrError, $isTestServer);
	return "1";
}
function getNewerCoreMVCFiles(){
	$p=get_cfg_var("jetendo_root_path");
	$cmd="/usr/bin/find ".$p."core/mvc -type f -newer ".$p."core/mvc-cache.cfc";
	return `$cmd`;
}
function getScryptEncrypt($a){
	$pw=implode("", $a);
	$p=get_cfg_var("jetendo_root_path");
	$cmd='/usr/bin/java -jar '.$p.'scripts/jetendo-scrypt.jar "encrypt" '.escapeshellarg($pw);
	$r=`$cmd`;
	return $r;
}
function getScryptCheck($a){
	if(count($a) != 2){
		return "0";
	}
	$pw=$a[0];
	$hash=$a[1];
	$p=get_cfg_var("jetendo_root_path");
	$cmd='/usr/bin/java -jar '.$p.'scripts/jetendo-scrypt.jar "check" '.escapeshellarg($pw).' '.escapeshellarg($hash);
	$r=`$cmd`;
	return $r;
}

function getSystemIpList(){
	$cmd="ip addr show";
	return `$cmd`;
}
function gzipFilePath($a){
	$path=implode("", $a);
	if(file_exists($path)){
		$path=realpath($path);
		$p=get_cfg_var("jetendo_root_path");
		$found=false;
		if(substr($path, 0, strlen($p)) == $p){
			$found=true;
		}
		$p=get_cfg_var("jetendo_backup_path");
		if(substr($path, 0, strlen($p)) == $p){
			$found=true;
		}
		if($found){
			$cmd="/bin/gzip -S .gz -f -9 ".escapeshellarg($path);
			`$cmd`;
			if(file_exists($path.".gz")){
				return "1";
			}
		}
	}
	return "0";
}
function getImageMagickConvertApplyMask($a){
	if(count($a) != 3){
		echo "Incorrect number of arguments to getImageMagickConvertApplyMask.\n";
		return "0";
	}
	$absImageInputPath=trim($a[0]);
	$absImageOutputPath=trim($a[1]);
	$absImageMaskPath=trim($a[2]);
	if($absImageInputPath == ""){
		echo "absImageInputPath was an empty string\n";
		return "0";
	}
	if($absImageOutputPath == ""){
		echo "absImageOutputPath was an empty string\n";
		return "0";
	}
	if($absImageMaskPath == ""){
		echo "absImageMaskPath was an empty string\n";
		return "0";
	}
	$absImageInputPath=realpath($absImageInputPath);
	$absImageOutputPath=getAbsolutePath($absImageOutputPath);
	$outputDir=realpath(dirname($absImageOutputPath));
	$$absImageMaskPath=realpath($absImageMaskPath);
	if($absImageInputPath == "" || !file_exists($absImageInputPath)){
		echo "The file for absImageInputPath doesn't exist: ".$absImageInputPath."\n";
		return "0";
	}
	if($outputDir == "" || !is_dir($outputDir)){
		echo "The parent directory for absImageOutputPath doesn't exist: ".$absImageOutputPath."\n";
		return "0";
	}
	if($absImageMaskPath == "" || !file_exists($absImageMaskPath)){
		echo "The file for absImageMaskPath doesn't exist: ".$absImageMaskPath."\n";
		return "0";
	}
	$absImageInputPathInfo=pathinfo($absImageInputPath);
	
	$outputExtension=getFileExt($absImageOutputPath);
	
	$absImageMaskPathInfo=pathinfo($absImageMaskPath);
	$validTypes=array();
	$validTypes["png"]=true;
	$validTypes["jpg"]=true;
	$validTypes["jpeg"]=true;
	$validTypes["gif"]=true;
	if(!isset($validTypes[strToLower($absImageInputPathInfo["extension"])])){
		echo "absImageInputPath must end with .jpg, .jpeg, .png or .gif.  It ended with: ".$absImageInputPathInfo["extension"]."\n";
		return "0";
	}
	if(!isset($validTypes[strToLower($outputExtension)])){
		echo "absImageOutputPath must end with .jpg, .jpeg, .png or .gif.  It ended with: ".$outputExtension."\n";
		return "0";
	}
	if(!isset($validTypes[strToLower($absImageMaskPathInfo["extension"])])){
		echo "absImageMaskPath must end with .jpg, .jpeg, .png or .gif.  It ended with: ".$absImageMaskPathInfo["extension"]."\n";
		return "0";
	}
	$path=$absImageInputPath;
	$p=get_cfg_var("jetendo_root_path");
	$found=false;
	if(substr($path, 0, strlen($p)) == $p){
		$found=true;
	}
	$p=get_cfg_var("jetendo_backup_path");
	if(substr($path, 0, strlen($p)) == $p){
		$found=true;
	}
	if(!$found){
		echo "absImageInputPath must be in the jetendo install or backup paths. Path:".$absImageInputPath."\n";
		return "0";
	}
	$path=$absImageOutputPath;
	$p=get_cfg_var("jetendo_root_path");
	$found=false;
	if(substr($path, 0, strlen($p)) == $p){
		$found=true;
	}
	$p=get_cfg_var("jetendo_backup_path");
	if(substr($path, 0, strlen($p)) == $p){
		$found=true;
	}
	if(!$found){
		echo "absImageOutputPath must be in the jetendo install or backup paths. Path:".$absImageOutputPath."\n";
		return "0";
	}
	$path=$absImageMaskPath;
	$p=get_cfg_var("jetendo_root_path");
	$found=false;
	if(substr($path, 0, strlen($p)) == $p){
		$found=true;
	}
	$p=get_cfg_var("jetendo_backup_path");
	if(substr($path, 0, strlen($p)) == $p){
		$found=true;
	}
	if(!$found){
		echo "absImageMaskPath must be in the jetendo install or backup paths. Path:".$absImageMaskPath."\n";
		return "0";
	}
	$cmd="/usr/bin/convert ".escapeshellarg($absImageInputPath)." ".escapeshellarg($absImageMaskPath)." -alpha Off -compose CopyOpacity -composite ".escapeshellarg($absImageOutputPath);
	$r=`$cmd`;
	echo $cmd."\n".$r."\n";
	if(file_exists($absImageOutputPath)){
		return "1";
	}
	echo "Failed to apply image to image\n";
	return "0";
}

function getImageMagickConvertResize($a){
	if(count($a) != 8){
		echo "Incorrect number of arguments to getImageMagickConvertResize.\n";
		return "0";
	}
	$resizeWidth=intval($a[0]);
	$resizeHeight=intval($a[1]);
	$cropWidth=intval($a[2]);
	$cropHeight=intval($a[3]);
	$cropXOffset=intval($a[4]);
	$cropYOffset=intval($a[5]);
	$sourceFilePath=trim($a[6]);
	$destinationFilePath=trim($a[7]);
	
	if($resizeWidth < 10 || $resizeHeight < 10){
		echo "resizeWidth and resizeHeight must be an integer greater then or equal 10.  Values: ".$resizeWidth."x".$resizeHeight."\n";
		return "0";
	}
	if($sourceFilePath == ""){
		echo "sourceFilePath was an empty string\n";
		return "0";
	}
	if($destinationFilePath == ""){
		echo "destinationFilePath was an empty string\n";
		return "0";
	}
	$sourceFilePath=realpath($sourceFilePath);
	$destinationFilePath=getAbsolutePath($destinationFilePath);
	$outputDir=realpath(dirname($destinationFilePath));
	if($sourceFilePath == "" || !file_exists($sourceFilePath)){
		echo "The file for sourceFilePath doesn't exist: ".$sourceFilePath."\n";
		return "0";
	}
	if($outputDir == "" || !is_dir($outputDir)){
		echo "The parent directory for destinationFilePath doesn't exist: ".$destinationFilePath."\n";
		return "0";
	}
	$sourceFilePathInfo=pathinfo($sourceFilePath);
	
	$outputExtension=getFileExt($destinationFilePath);
	
	$validTypes=array();
	$validTypes["png"]=true;
	$validTypes["jpg"]=true;
	$validTypes["jpeg"]=true;
	$validTypes["gif"]=true;
	if(!isset($validTypes[strToLower($sourceFilePathInfo["extension"])])){
		echo "sourceFilePath must end with .jpg, .jpeg, .png or .gif.  It ended with: ".$sourceFilePathInfo["extension"]."\n";
		return "0";
	}
	if(!isset($validTypes[strToLower($outputExtension)])){
		echo "destinationFilePath must end with .jpg, .jpeg, .png or .gif.  It ended with: ".$outputExtension."\n";
		return "0";
	}
	$path=$sourceFilePath;
	$p=get_cfg_var("jetendo_root_path");
	$found=false;
	if(substr($path, 0, strlen($p)) == $p){
		$found=true;
	}
	$p=get_cfg_var("jetendo_backup_path");
	if(substr($path, 0, strlen($p)) == $p){
		$found=true;
	}
	if(!$found){
		echo "sourceFilePath must be in the jetendo install or backup paths. Path:".$sourceFilePath."\n";
		return "0";
	}
	$path=$destinationFilePath;
	$p=get_cfg_var("jetendo_root_path");
	$found=false;
	if(substr($path, 0, strlen($p)) == $p){
		$found=true;
	}
	$p=get_cfg_var("jetendo_backup_path");
	if(substr($path, 0, strlen($p)) == $p){
		$found=true;
	}
	if(!$found){
		echo "destinationFilePath must be in the jetendo install or backup paths. Path:".$destinationFilePath."\n";
		return "0";
	}
	$cmd='/usr/bin/convert -resize "'.$resizeWidth.'x'.$resizeHeight.'>" ';
	if($cropWidth != 0){
		$cmd.=' -crop '.$cropWidth.'x'.$cropHeight.'+'.$cropXOffset.'+'.$cropYOffset;
	}
	$cmd.=' '.escapeshellarg($sourceFilePath).' '.escapeshellarg($destinationFilePath);
	$r=`$cmd`;
	echo $cmd."\n".$r."\n";
	if(file_exists($destinationFilePath)){
		return "1";
	}
	return "0";
}

function getImageMagickIdentify($a){
	$path=implode("", $a);
	if(file_exists($path)){
		$path=realpath($path);
		$p=get_cfg_var("jetendo_root_path");
		$found=false;
		if(substr($path, 0, strlen($p)) == $p){
			$found=true;
		}
		$p=get_cfg_var("jetendo_backup_path");
		if(substr($path, 0, strlen($p)) == $p){
			$found=true;
		}
		if($found){
			$cmd="/usr/bin/identify -format %wx%h ".escapeshellarg($path)." 2>&1";
			$r=`$cmd`;
			echo $cmd."\n".$r."\n";
			return $r;
		}
	}
	return "";
}

function tarZipFilePath($a){
	if(count($a) != 3){
		echo "incorrect number of arguments: ".implode(", ", $a)."\n";
		return "0";
	}
	$tarFilename=trim($a[0]);
	if($tarFilename==""){
		echo "tarFilename is invalid: ".$tarFilename."\n";
		return "0";
	}
	$tarDirectory=trim($a[1]);
	$pathToTar=trim($a[2]);
	$tarDirectory=realpath($tarDirectory);
	$pathToTar=realpath($pathToTar);
	if($pathToTar=="" || (!is_dir($pathToTar) && !file_exists($pathToTar))){
		echo "pathToTar is invalid: ".$pathToTar."\n";
		return "0";
	}
	if($tarDirectory=="" || !is_dir($tarDirectory)){
		echo "tarDirectory is invalid: ".$tarDirectory."\n";
		return "0";
	}
	$p=get_cfg_var("jetendo_root_path");
	$p2=get_cfg_var("jetendo_backup_path");
	$found=false;
	if(substr($tarDirectory, 0, strlen($p)) == $p || substr($tarDirectory, 0, strlen($p2)) == $p2){
		if(substr($pathToTar, 0, strlen($p)) == $p || substr($pathToTar, 0, strlen($p2)) == $p2){
			$found=true;
		}else{
			echo "pathToTar is not in jetendo install or backup paths.\n";
		}
	}else{
		echo "tarDirectory is not in jetendo install or backup paths.\n";
	}
	if($found){
		chdir($pathToTar);
		$cmd="/bin/tar -cvzf ".escapeshellarg($tarDirectory."/".$tarFilename)." *";
		`$cmd`;
		if(file_exists($tarDirectory."/".$tarFilename)){
			echo "Created tar/gzip successfully\n";
			return "1";
		}
	}
	echo "Failed to create tar/gzip\n";
	return "0";
}

function getDiskUsage($a){
	$path=implode("", $a);
	if(is_dir($path) || file_exists($path)){
		$path=realpath($path);
		$p=get_cfg_var("jetendo_root_path");
		$found=false;
		if(substr($path, 0, strlen($p)) == $p){
			$found=true;
		}
		$p=get_cfg_var("jetendo_backup_path");
		if(substr($path, 0, strlen($p)) == $p){
			$found=true;
		}
		if($found){
			$cmd="/usr/bin/du -sh ".escapeshellarg($path);
			return `$cmd`;
		}
	}
	return "";
}
function getFileMD5Sum($a){
	$path=implode("", $a);
	if(file_exists($path)){
		$path=realpath($path);
		$p=get_cfg_var("jetendo_root_path");
		if(substr($path, 0, strlen($p)) != $p){
			return "";
		}
		$cmd="/usr/bin/md5sum ".escapeshellarg($path);
		return `$cmd`;
	}else{
		return "";
	}
}
function getUserList(){
	$cmd="/bin/cat /etc/passwd";
	$result=trim(`$cmd`);
	$arrPasswd=explode("\n", $result);
	$arrUser=array();
	for($i=0;$i<count($arrPasswd);$i++){
		$arrTemp=explode(":", $arrPasswd[$i]);
		array_push($arrUser, $arrTemp[0]);
		
	}
	return implode(",", $arrUser);
}
function microtimeFloat()
{
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
}
$debug=false;
$timeout=60; // seconds
$timeStart=microtimeFloat();
$completePath="/opt/jetendo/execute/complete/";
$startPath="/opt/jetendo/execute/start/";

while(true){
	$handle=opendir($startPath);
	if($handle){
		while (false !== ($entry = readdir($handle))) {
			if(substr($entry, strlen($entry)-4, 4) !=".txt"){
				continue;
			}
			echo "Started: ".$entry."\n";
			$curPath=$startPath.$entry;
			$contents=file_get_contents($curPath);
			unlink($curPath);
			$results=processContents($contents);
			$fp=fopen($completePath.$entry, "w");
			echo "Completed: ".$entry."\n";
			fwrite($fp, $results);
			fclose($fp);
			
		}
		closedir($handle);
	}
	usleep(100000); // wait tenth of second

	if(microtimeFloat() - $timeStart > $timeout-3){
		echo "Timeout reached";
		exit;
	}
}
?>