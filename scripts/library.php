<?php

function zRemoveEmptyValuesFromArray($arr){
	$arrNew=array();
	for($n=0;$n<count($arr);$n++){
		if($arr[$n] != ""){
			array_push($arrNew, $arr[$n]);
		}
	}
	return $arrNew;
}

function installJetendoCronTabs($debug){
	$isTestServer=zIsTestServer();
	$rootCronPath="/var/spool/cron/crontabs/root";
	$scriptsPath=get_cfg_var("jetendo_scripts_path");
	echo("Installing crontab\n");
$crontabs="#every minute
*/1 * * * * /usr/bin/php ".$scriptsPath."newsite.php >/dev/null 2>&1
*/1 * * * * /usr/bin/php ".$scriptsPath."railo-execute-commands.php >/dev/null 2>&1
*/1 * * * * /usr/bin/php ".$scriptsPath."zqueue/queue.php >/dev/null 2>&1
*/1 * * * * /usr/bin/php ".$scriptsPath."zqueue/queue-check-running.php >/dev/null 2>&1
*/1 * * * * /usr/bin/php ".$scriptsPath."cfml-tasks.php >/dev/null 2>&1

# every hour at :00
0 * * * * /usr/bin/php ".$scriptsPath."verify-sites.php >/dev/null 2>&1
";
if(!$isTestServer){
$crontabs.="#every 5 minutes
0-59/20 * * * * /usr/bin/php ".$scriptsPath."move-mls-images.php > /dev/null 2>&1

# every day at 12:15am
15 0 * * * /usr/bin/perl ".$scriptsPath."rsync_backup.pl >/dev/null 2>&1

# every day at 1:30am
30 1 * * * /usr/bin/php ".$scriptsPath."mysql-backup/backup_dbs.php >/dev/null 2>&1

# every day at 12:20am
20 0 * * * /usr/bin/php ".$scriptsPath."listing-image-cleanup.php > /dev/null 2>&1";
}

	$arr1=explode("\n", file_get_contents($rootCronPath));
	for($i=0;$i<count($arr1);$i++){
		if(trim($arr1[$i]) == "" || substr($arr1[$i], 0, 1) != "#"){
			$arr1=array_slice($arr1, $i);
			break;
		}
	}
	$contents=implode("\n", $arr1);
	$beginString="\n#jetendo-root-crontabs-begin\n";
	$endString="\n#jetendo-root-crontabs-end\n";
	$begin=strpos($contents, $beginString);
	if($begin===FALSE){
		$contents.=$beginString;
		$begin=strpos($contents, $beginString);
	}
	$end=strpos($contents, $endString, $begin);
	if($end===FALSE){
		$contents.=$endString;
		$end=strpos($contents, $endString);
	}
	$fileBeginContents=substr($contents, 0, $begin+strlen($beginString));
	$fileContentsHosts=trim(substr($contents, $begin+strlen($beginString), $end-($begin+strlen($beginString))));
	$fileEndContents=substr($contents, $end);
	
	$newFileContents=str_replace("\r", "", $fileBeginContents.$crontabs.$fileEndContents);
	if(!$debug){
		$fp=fopen($rootCronPath, "w");
		fwrite($fp, $newFileContents);
		fclose($fp);
		chown($rootCronPath, "root");
		chgrp($rootCronPath, "crontab");
		chmod($rootCronPath, 0600);
		// update cron with the new file
		`/usr/bin/crontab /var/spool/cron/crontabs/root`;
	}
	echo("Crontab install complete\n");

}

function checkMySQLPrivileges(){
	$cmysql2=@new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), "mysql");
	if($cmysql2->connect_error != ""){ 
		echo "Connect error: ".$cmysql2->connect_error."\n";
		echo "The mysql user, \"".get_cfg_var("jetendo_mysql_default_user")."\" must have access to SELECT on the \"mysql\" database and ".
		"global SUPER privilege to enable restoring triggers.";
		return false;
	}
	$r=$cmysql2->query("SELECT * FROM mysql.user WHERE Super_priv = 'Y' and User = '".get_cfg_var("jetendo_mysql_default_user")."'");
	if($cmysql2->error != ""){ 
		echo "MySQL Error: ".$cmysql2->error."\n";
		echo "The mysql user, \"".get_cfg_var("jetendo_mysql_default_user")."\" must have access to SELECT on the \"mysql\" database and global SUPER privilege to enable restoring triggers.";
		return false;
	}
	if($r->num_rows == 0){
		echo "User not found: ".get_cfg_var("jetendo_mysql_default_user").". The mysql user, \"".get_cfg_var("jetendo_mysql_default_user")."\" must have SUPER privilege to enable restoring triggers.";
		return false;
	}
	$db=zGetDatasource();
	// check for global privileges for user
	$r=$cmysql2->query("select * from mysql.user WHERE 
	User = '".$cmysql2->real_escape_string(get_cfg_var("jetendo_mysql_default_user"))."' and 
	Select_priv='Y' and  Insert_priv='Y' and  Update_priv='Y' and  Delete_priv='Y' and  
	Create_priv='Y' and  Drop_priv  ='Y' and  Grant_priv ='Y' and  References_priv       ='Y' and  
	Index_priv ='Y' and  Alter_priv ='Y' and  Create_tmp_table_priv ='Y' and  
	Lock_tables_priv      ='Y' and  Create_view_priv      ='Y' and  Show_view_priv        ='Y' and  
	Create_routine_priv   ='Y' and  Alter_routine_priv    ='Y' and  Execute_priv          ='Y' and  
	Event_priv ='Y' and  Trigger_priv     ='Y' ");
	if($cmysql2->error != ""){ 
		echo "MySQL Error: ".$cmysql2->error."\n";
		echo "The mysql user, \"".get_cfg_var("jetendo_mysql_default_user")."\" must have access to SELECT on the \"mysql\" database and global SUPER privilege to enable restoring triggers.";
		return false;
	}
	if($r->num_rows == 0){
		// check db privileges
		$r=$cmysql2->query("select * from mysql.db WHERE 
		Db='".$cmysql2->real_escape_string($db)."' and 
		User = '".$cmysql2->real_escape_string(get_cfg_var("jetendo_mysql_default_user"))."' and 
		Select_priv='Y' and  Insert_priv='Y' and  Update_priv='Y' and  Delete_priv='Y' and  
		Create_priv='Y' and  Drop_priv  ='Y' and  Grant_priv ='Y' and  References_priv       ='Y' and  
		Index_priv ='Y' and  Alter_priv ='Y' and  Create_tmp_table_priv ='Y' and  
		Lock_tables_priv      ='Y' and  Create_view_priv      ='Y' and  Show_view_priv        ='Y' and  
		Create_routine_priv   ='Y' and  Alter_routine_priv    ='Y' and  Execute_priv          ='Y' and  
		Event_priv ='Y' and  Trigger_priv     ='Y' ");
		if($cmysql2->error != ""){ 
			echo "MySQL Error: ".$cmysql2->error."\n";
			echo "The mysql user, \"".get_cfg_var("jetendo_mysql_default_user")."\" must have access to SELECT on the \"mysql\" database and global SUPER privilege to enable restoring triggers.";
			return false;
		}
		if($r->num_rows == 0){
			echo "User not found: ".get_cfg_var("jetendo_mysql_default_user").".The mysql user, \"".get_cfg_var("jetendo_mysql_default_user")."\" must have ALL PRIVILEGES GRANTED for database, \"".$db."\" or GLOBAL PRIVILEGES to all databases.";
			return false;
		}
	}
	return true;
}

function zGetSSHConnectCommand($remoteHost, $privateKeyPath){
	$cmd='/usr/bin/ssh -O check -S "/root/.ssh/ctl/%L-%r@%h:%p" '.$remoteHost." 2>&1";
	echo "\n\n\n\n".$cmd."\n";
	$result=`$cmd`;
	echo "Result: ".$result."\n";
	$p=strpos($result, "Master running");
	if($p === FALSE){
		if(file_exists($privateKeyPath)){
			echo "Switching to private key path for ssh connection\n";
			$sshCommand='ssh -i '.$privateKeyPath;
		}else{
			echo "No private key or ssh connection exists\n";
			return false;
		}
	}else{
		echo "Reusing master ssh connection\n";
		$sshCommand='ssh -o "ControlPath=/root/.ssh/ctl/%L-%r@%h:%p"';
	}
	return $sshCommand;
}

function zGetDatasource(){
	if(zIsTestServer()){
		return get_cfg_var("jetendo_test_datasource");
	}else{
		return get_cfg_var("jetendo_datasource");
	}
}

$host=`hostname`;
$testDomain=get_cfg_var("jetendo_test_domain"); 
if(strpos($host, $testDomain) !== FALSE){
	$isTestServer=true;
	$isInstalledOnSambaMount=get_cfg_var("jetendo_test_server_uses_samba");
}else{
	$isTestServer=false;
	$isInstalledOnSambaMount=get_cfg_var("jetendo_server_uses_samba");
}

function zIsTestServer(){
	global $isTestServer;
	return $isTestServer;
}
function zIsFtpEnabled(){
	$r=`/usr/sbin/service vsftpd status`;
	echo $r;
	if(strpos($r, 'unrecognized') !== FALSE || strpos($r, 'stop') !== FALSE){
		return false;
	}else{
		return true;
	}
}
function zCheckJetendoIniConfig($arrLog){
	$arrVar=array(
		"upload_max_filesize", 
		"max_input_time", 
		"post_max_size", 
		"jetendo_developer_email_from", 
		"jetendo_developer_email_to", 
		"jetendo_test_domain", 
		"jetendo_mysql_default_host", 
		"jetendo_mysql_default_user", 
		"jetendo_mysql_default_password", 
		"jetendo_datasource", 
		"jetendo_test_datasource", 
		"jetendo_test_server_uses_samba", 
		"jetendo_server_uses_samba", 
		"jetendo_admin_domain", 
		"jetendo_test_admin_domain", 
		"jetendo_sites_path", 
		"jetendo_sites_writable_path", 
		"jetendo_log_path", 
		"jetendo_root_path", 
		"jetendo_root_private_path", 
		"jetendo_share_path", 
		"jetendo_scripts_path", 
		"jetendo_backup_path", 
		"jetendo_nginx_ssl_path", 
		"jetendo_www_user");
	$correct=true;
	for($i=0;$i<count($arrVar);$i++){
		$v=get_cfg_var($arrVar[$i]);
		if($v == ""){
			$correct=false;
			echo $arrVar[$i]." missing \n";
			array_push($arrLog, "PHP configuration is missing ".$arrVar[$i].".  
			You must install the jetendo scripts directory and configure jetendo.ini to the php conf.d directory.");
		}
	}
	return $correct;
}

function zCheckDirectoryPermissions($dir, $user, $group, $fileChmodWithNoZeroPrefix, $dirChmodWithNoZeroPrefix, $recursive, $preview, $arrLog=array(), $isTestServer){
	if($dir === ""){
		array_push($arrLog, "dir variable was not defined, and it is required.");
		return false;
	}
	if(substr($dir, strlen($dir)-1, 1) != "/"){
		$dir.="/";
	}
	if(!is_dir($dir)){
		array_push($arrLog, "Self-healing notice: missing directory was created: ".$dir);
		if(!$preview){
			mkdir($dir, "0".$dirChmodWithNoZeroPrefix, true);
		}
	}
	$correct=true;
	if($recursive){
		if(!$isTestServer){
			$r=system("find ".escapeshellarg($dir)." -type f \! -perm 0".$fileChmodWithNoZeroPrefix." -print -quit");
			if($r!==""){
				array_push($arrLog, "Self-healing notice: chmod permissions reset to ".$fileChmodWithNoZeroPrefix." for files in ".$dir);
				if(!$preview){
					system("find ".escapeshellarg($dir)." -type f -exec chmod ".$fileChmodWithNoZeroPrefix." {} +");
				}
				$correct=false;
			}
			$r=system("find ".escapeshellarg($dir)." -type d \! -perm 2".$dirChmodWithNoZeroPrefix." -print -quit");
			if($r!==""){
				array_push($arrLog, "Self-healing notice: chmod permissions reset to ".$dirChmodWithNoZeroPrefix." for directories in ".$dir);
				if(!$preview){
					system("find ".escapeshellarg($dir)." -type d -exec chmod 2".$dirChmodWithNoZeroPrefix." {} +");
				}
				$correct=false;
			}
			$r=system("find ".escapeshellarg($dir)." \! -user ".$user." -print -quit");
			if($r!==""){
				array_push($arrLog, "Self-healing notice: ownership reset recursively to ".$user.":".$group." for: ".$dir);
				if(!$preview){
					system("/bin/chown -R ".$user.":".$group." ".escapeshellarg($dir));
				}
				$correct=false;
			}else{
				$r=system("find ".escapeshellarg($dir)." \! -group ".$group." -print -quit");
				if($r!==""){
					array_push($arrLog, "Self-healing notice: ownership reset recursively to ".$user.":".$group." for: ".$dir);
					if(!$preview){
						system("/bin/chown -R ".$user.":".$group." ".escapeshellarg($dir));
					}
					$correct=false;
				}
			}
		}
	}else{
		if(!$isTestServer){
			if(fileperms($dir) != "2".$dirChmodWithNoZeroPrefix){
				array_push($arrLog, "Self-healing notice: permissions reset to ".$dirChmodWithNoZeroPrefix." for: ".$dir);
				if(!$preview){
					chmod($dir, octdec("2".$dirChmodWithNoZeroPrefix));
				}
			}
			if(filegroup($dir) != $group){
				array_push($arrLog, "Self-healing notice: ownership reset to group: ".$group." for: ".$dir);
				if(!$preview){
					chgrp($dir, $group);
				}
			}
			if(fileowner($dir) != $user){
				array_push($arrLog, "Self-healing notice: ownership reset to user: ".$user." for: ".$dir);
				if(!$preview){
					chown($dir, $user);
				}
			}
		}

	}
	return $correct;
}
function zGetDomainInstallPath($p){
	$testDomain=get_cfg_var("jetendo_test_domain");
	return get_cfg_var("jetendo_sites_path").str_replace(".", "_", str_replace("www.", "", str_replace(".".$testDomain, "", str_replace("/", "", str_replace("\\", "", $p)))))."/";
}
function zGetDomainWritableInstallPath($p){
	$testDomain=get_cfg_var("jetendo_test_domain");
	return get_cfg_var("jetendo_sites_writable_path").str_replace(".", "_", str_replace("www.", "", str_replace(".".$testDomain, "", str_replace("/", "", str_replace("\\", "", $p)))))."/";
}
function zGenerateStrongPassword($minLength, $maxLength){
	$d='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_=!@##$%^&*()[]{}|;:,.<>/?`~ \'"+-';
	$d1=strlen($d);
	$plen=rand(1, $maxLength-$minLength)+$minLength;
	$i=0;
	$p=""; 
	for($i=0;$i<$plen;$i++){
		$p.=substr($d, rand(0, $d1-1),1);
	}
	return $p;
}
function getFilesInDirectoryAsArray($directory, $recursive, $arrFilter=array()) {
    $arrItems = array();
	if(substr($directory, strlen($directory)-1, 1) != "/"){
		$directory.="/";
	}
	if(count($arrFilter)){
		$filterMap=array();
		for($i=0;$i<count($arrFilter);$i++){
			$filterMap[$arrFilter[$i]]=true;
		}
		recurseDirectoryWithFilter($arrItems, $directory, $recursive, $filterMap);
	}else{
		recurseDirectory($arrItems, $directory, $recursive);
	}
    return $arrItems;
}
function recurseDirectory(&$arrItems, $directory, $recursive) {
	if ($handle = opendir($directory)) {
		while (false !== ($file = readdir($handle))) {
			if ($file != "." && $file != "..") {
				if(is_dir($directory.$file)) {
					if($recursive){
						recurseDirectory($arrItems, $directory.$file."/", $recursive);
					}
				}else{
					$arrItems[] = $directory . $file;
				}
			}
		}
		closedir($handle);
	}
    return $arrItems;
}
function recurseDirectoryWithFilter(&$arrItems, $directory, $recursive, &$filterMap) {
	if ($handle = opendir($directory)) {
		while (false !== ($file = readdir($handle))) {
			if ($file != "." && $file != "..") {
				if(is_dir($directory.$file)) {
					if($recursive){
						recurseDirectoryWithFilter($arrItems, $directory.$file."/", $recursive, $filterMap);
					}
				}else{
					if(isset($filterMap[getFileExt($file)])){
						$arrItems[] = $directory . $file;
					}
				}
			}
		}
		closedir($handle);
	}
    return $arrItems;
}
function getFileExt($path){
	$pos=strrpos($path, ".");
	if($pos===FALSE){
		return "";
	}else{
		return substr($path, $pos+1);
	}
}
function microtime_float(){
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
}
function getAbsolutePath($path) {
	$path = str_replace(array('/', '\\'), DIRECTORY_SEPARATOR, $path);
	$parts = array_filter(explode(DIRECTORY_SEPARATOR, $path), 'strlen');
	$absolutes = array();
	foreach ($parts as $part) {
		if ('.' == $part) continue;
		if ('..' == $part) {
			array_pop($absolutes);
		} else {
			$absolutes[] = $part;
		}
	}
	$result=implode(DIRECTORY_SEPARATOR, $absolutes);
	if(DIRECTORY_SEPARATOR == "/"){
		return "/".$result;
	}else{
		return $result;
	}
}
?>