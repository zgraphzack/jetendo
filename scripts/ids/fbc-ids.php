<?php
/*
procedure for executing this script

pull the fbc-ids.7z to my home machine
compare the md5 hash to the one in the 7z
md5 -c /root/fbc-ids/fbc-ids.php
if it fails, email myself to investigate and upload the correct version of the script again. - may have been attacked!

all the logs should be dated.  the previous newest log is used to compare.  loop with scandir and use the last one.



*/
echo "This script is not up to date with the current state of Jetendo.  It will be used for file integrity automation later.";
exit;

// define excluded files & folders
$arrExcludeDir=array();
$arrExcludeDir["/var/jetendo-server/jetendo/share/hotstays-temp-data/"]=true;
$arrExcludeDir["/home/newbackup/"]=true;
$arrExcludeDir["/home/remote-mls-images/"]=true;
$arrExcludeDir["/var/lib/samba/"]=true;
$arrExcludeDir["/root/fbc-ids/"]=true;
$arrExcludeDir["/home/privatesambashare/mls-data/"]=true;
$arrExcludeDir["/home/privatesambashare/mls-images/"]=true;
$arrExcludeDir["/home/privatesambashare/mls-cached-images/"]=true;
$arrExcludeDir["/var/jetendo-server/railovhosts/"]=true;
$arrExcludeDir["/var/log/"]=true;
$arrExcludeDir["/dev/.udev/links/"]=true;
$arrExcludeDir["/etc/httpd/logs/"]=true;
$arrExcludeDir["/proc/"]=true;
$arrExcludeDir["/usr/src/"]=true;
$arrExcludeDir["/sys/"]=true;
//$arrExcludeDir["/sys/bus/"]=true;
//$arrExcludeDir["/sys/module/"]=true;
$arrExcludeDir["/usr/include/"]=true;
$arrExcludeDir["/usr/local/src/"]=true;
$arrExcludeDir["/var/jetendo-server/railo/tomcat/logs/"]=true;
$arrExcludeDir["/usr/java/jdk1.6.0_29/demo/"]=true;
$arrExcludeDir["/usr/share/"]=true;
$arrExcludeDir["/var/spool/postfix/public/"]=true;
$arrExcludeDir["/var/spool/postfix/private/"]=true;
$arrExcludeDir["/var/lib/yum/yumdb/"]=true;
$arrExcludeDir["/var/lib/mysql/"]=true;
$arrExcludeDir["/var/jetendo-server/backup/"]=true;
$arrExcludeDir["/tmp/"]=true;

$arrMD5AlwaysCheckDir=array("/etc/","/home/vhosts/");
$arrMD5AlwaysCheckDirCount=count($arrMD5AlwaysCheckDir);

umask(0077);

$logDir=get_cfg_var("jetendo_log_path");

$newLog=false;
if($newLog==false){
	if(file_exists($logDir."ids/fbc-ids.log")){
		$logReadHandle=fopen($logDir."ids/fbc-ids.log","r");
		$logReadIndexHandle=fopen($logDir."ids/fbc-ids-index.log","r");
		$arrDirIndex2=explode("\n",fread($logReadIndexHandle, filesize($logDir."ids/fbc-ids-index.log")));
		fclose($logReadIndexHandle);
		$arrDirIndex=array();
		for($i=0;$i<count($arrDirIndex2);$i++){
			if($arrDirIndex2[$i] != ""){
				$a=explode("\\",$arrDirIndex2[$i]);
				$arrDirIndex[$a[0]]=array($a[1],$a[2]);
			}
		}
		$arrDirIndex2=array();
	}else{
		$newLog=true;
	}
}
//@unlink("/root/fbc-ids/fbc-ids2.log");
// loop filesystem
$logWriteHandle=fopen($logDir."ids/fbc-ids2.log","w");
$logIndexHandle=fopen($logDir."ids/fbc-ids-index2.log","w");
$logChangedHandle=fopen($logDir."ids/fbc-ids-changed.log","w");
$logDeletedHandle=fopen($logDir."ids/fbc-ids-deleted.log","w");
$logNewHandle=fopen($logDir."ids/fbc-ids-new.log","w");

$g99=0;

$arrScriptTypes=array();
$a10=explode(",","asp,aspx,asa,ini,htaccess,cfm,cfc,php,php3,vbs,bat,exe,js,shtml,reg,inc,perl,pl,cgi,php5,php4,php1,php2,phtml,ssi,xhtm,htm,html,shtm,msi,bin,rpm,sh,css");
for($i=0;$i<count($a10);$i++){
	$arrScriptTypes[$a10[$i]]=true;
}
$arrIgnoreFiles=array();
$a10=explode(",",".,..,zsystem.css");
for($i=0;$i<count($a10);$i++){
	$arrIgnoreFiles[$a10[$i]]=true;
}
$curSeek=0;

function logDir($curDir){
	global $curSeek, $newLog, $logReadHandle, $logWriteHandle, $arrExcludeDir, $logChangedHandle, $logNewHandle, $logIndexHandle, $arrDirIndex, $logDeletedHandle, $arrIgnoreFiles, $arrMD5AlwaysCheckDir, $arrMD5AlwaysCheckDirCount, $g99, $arrScriptTypes;
	if(substr($curDir,strlen($curDir)-1,1) != "/"){
		$curDir.="/";
	}
	// check if current folder is excluded
	if(isset($arrExcludeDir[$curDir])){
		// echo "excluded ".$curDir."\n";
		return;
	}
	$forceMD5Recheck=false;
	for($i=0;$i<$arrMD5AlwaysCheckDirCount;$i++){
		if($arrMD5AlwaysCheckDir[$i] == substr($curDir,0, strlen($arrMD5AlwaysCheckDir[$i]))){
			$forceMD5Recheck=true;
		}
	}
	if($newLog==false){
		if(isset($arrDirIndex[$curDir]) && $arrDirIndex[$curDir][1] != 0){
			fseek($logReadHandle, $arrDirIndex[$curDir][0]);
			$arrLog2=explode("\n",fread($logReadHandle, $arrDirIndex[$curDir][1]));
			$arrLog=array();
			for($i=0;$i<count($arrLog2);$i++){
				if($arrLog2[$i] != ""){
					$a=explode("\\",$arrLog2[$i]);
					$arrLog[$a[0]]=trim($a[1]);
				}
			}
		}else{
			$arrLog=array();
		}
	}
	$startSeek=$curSeek;
	//if($dh=opendir($curDir)){
	$arrDir=array();
	$arrFiles = scandir($curDir);
	$arrFilesMatch=array();
	
	$arrWriteCache=array();
	$writeCacheCount=0;
	
	
	
	for($g=0;$g<count($arrFiles);$g++){
		$curFile=$arrFiles[$g];
		$filepath=$curDir.$curFile;
		if (isset($arrIgnoreFiles[$curFile]) == false) {
			$isDir=false;
			$isFile=false;
			$isLink=false;
			if(is_file($filepath)){
				$isFile=true;
			}else if(is_dir($filepath)){
				$isDir=true;
				if(isset($arrExcludeDir[$filepath."/"])){
					// echo "excluded ".$curDir."\n";
					continue;
				}
			}
			if(is_link($filepath)){
				$isLink=true;
			}
			if($isDir == false && $isLink==false && substr($filepath,0,13) == "/home/vhosts/"){
				$p=strrpos($curFile,".");
				if($p!==false){
					$np=substr($curFile, $p+1, strlen($curFile)-($p+1));
					if(isset($arrScriptTypes[$np]) == false){
						//echo "skipping: ".$filepath."\n";
						continue;
					}
				}
			}
			if($isDir){
				if($isLink == false){
					array_push($arrDir,$filepath);
				}
			}
			$fuid="";
			$fgid="";
			$fsize="";
			$fdate="";
			$fchmod="";
			if($isFile || $isDir || $isLink){
				$s=`stat '$filepath'`;
				//echo $s;
				$s=str_replace(" ","", $s);
				$s=str_replace("\t","\n", $s);
				$s=str_replace(")","", $s);
				$s=str_replace("(","", $s);
				$a=explode("\n", $s);
				//echo "\n\n";
				for($i=0;$i<count($a);$i++){
					// grab chmod, user, group, date, size, md5sum
					if($fchmod=="" && substr($a[$i],0,7) == "Access:"){
						$a[$i]=str_replace("Access:","", $a[$i]);
						$a2=explode("Uid:",$a[$i]);
						$a3=explode("/",$a2[1]);
						$a3[1]=str_replace("Access:","", $a3[1]);
						$a4=explode("/",$a3[1]);
						$p=strpos($a4[0],":");
						$a4[0]=substr($a4[0], $p+1,strlen($a4[0])-($p+1));
						$fchmod=$a2[0];
						$fuid=$a3[0];
						$fgid=$a4[0];
					}else if(substr($a[$i],0,4) == "Size"){
						$fsize=substr($a[$i],5,strlen($a[$i])-5);
					}else if(substr($a[$i],0,6) == "Modify"){
						$fdate=substr($a[$i],8,strlen($a[$i])-8);
					}
					//echo $a[$i]."\n";
				}
			//}else{
				// echo $filepath." is not a file or dir\n";
			}
			if($isLink){
				$realPath="|".realpath($filepath);
			}else{
				$realPath="|";
			}
			$curLogStat="";
			if($newLog==false){
				if(isset($arrLog[$filepath])){
					$curLogStat=$arrLog[$filepath];
					$backupCurLogStat=$curLogStat;
				}
			}
			$md5Required=false;
			$md5Done=false;
			if($fsize != 0 && $isDir==false && $isLink == false && substr($filepath,0,5) != "/dev/"){
				$md5Required=true;
				if($forceMD5Recheck || $curLogStat==""){
					$md5Done=true;
					$m=`md5sum '$filepath'`;
					$m=explode(" ",$m);
					$m=$m[0];
				}else{
					$m="";
				}
				$curCompareString=$fuid."|".$fgid."|".$fdate."|".$fsize."|".$fchmod."|".$realPath."|".$m;
			}else{
				if($isDir || $isLink){
					$curCompareString=$fuid."|".$fgid."|"."|".$fsize."|".$fchmod."|".$realPath."|";
				}else{
					$curCompareString=$fuid."|".$fgid."|".$fdate."|".$fsize."|".$fchmod."|".$realPath."|";
				}
			}
			if($newLog==false){
				if($curLogStat!=""){
					if($forceMD5Recheck == false){
						$p=strrpos($curLogStat,"|");
						$curLogStat=substr($curLogStat, 0, $p+1);
					}
					// test if changed
					if($curLogStat != $curCompareString){
						// changed
						$curLogStat=$backupCurLogStat;
						if($md5Required && $md5Done==false){
							$m=`md5sum '$filepath'`;
							$m=explode(" ",$m);
							$m=$m[0];
							$curCompareString.=$m;
						}
						fwrite($logChangedHandle, "old: ".$filepath."\\".$curLogStat."\nnew: ".$filepath."\\".$curCompareString."\n");
					}else{
						// not changed
						$curCompareString=$backupCurLogStat;
					}
					unset($arrLog[$filepath]);
				}else{
					// new file
					if($md5Required && $md5Done==false){
						$m=`md5sum '$filepath'`;
						$m=explode(" ",$m);
						$m=$m[0];
						$curCompareString.=$m;
					}
					fwrite($logNewHandle, $filepath."\\".$curCompareString."\n");
				}
			}else{
				if($md5Required && $md5Done==false){
					$m=`md5sum '$filepath'`;
					$m=explode(" ",$m);
					$m=$m[0];
					$curCompareString.=$m;
				}
			}
			
			
			$c=$filepath."\\".$curCompareString."\n";
			$curSeek+=strlen($c);
			array_push($arrWriteCache, $c);
			$writeCacheCount++;
			if($writeCacheCount > 100){
				fwrite($logWriteHandle, implode("",$arrWriteCache));
				$arrWriteCache=array();
				$writeCacheCount=0;
			}
		}
	}
	if($newLog==false){
		foreach($arrLog as $key=>$val){
			fwrite($logDeletedHandle, $key."\\".$val."\n");
		}
	}
	$g99++;
	if($g99 % 1000 == 0){
		echo "currently at ".$filepath."\n";
	}
	fwrite($logIndexHandle, $curDir."\\".$startSeek."\\".($curSeek-$startSeek)."\n");
	if(count($arrWriteCache) > 0){
		fwrite($logWriteHandle, implode("",$arrWriteCache));
		$arrWriteCache=array();
	}
	for($i=0;$i<count($arrDir);$i++){
		logDir($arrDir[$i]);
	}
}
logDir("/");
fclose($logIndexHandle);
fclose($logWriteHandle);
fclose($logChangedHandle);
fclose($logNewHandle);
fclose($logDeletedHandle);
if($newLog==false){
	fclose($logReadHandle);
}
@unlink($logDir."ids/fbc-ids.log");
rename($logDir."ids/fbc-ids2.log", $logDir."ids/fbc-ids.log");
@unlink($logDir."ids-index.log");
rename($logDir."ids-index2.log", $logDir."ids-index.log");

system("7za a -t7z /root/fbc-ids/fbc-ids.7z ".escapeshellarg($logDir."ids/*"));


?>