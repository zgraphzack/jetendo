<?php
require("library.php");
$debug=false; // set to true to allow non-destructive debugging of this script

function installJetendoCronTabs(){
	global $debug;
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

$dir=__DIR__;
if(!file_exists($dir."/jetendo.ini")){
	echo("Error: You must create ".$dir."/jetendo.ini and make a symbolic link using this command:\n/bin/ln -sf ".$dir."/jetendo.ini /etc/php5/mods-available/jetendo.ini\n");
	exit;
}
if(get_cfg_var("jetendo_scripts_path") == ""){
	echo("Error: You must create a symbolic link using this command: /bin/ln -sf ".$dir."/jetendo.ini /etc/php5/mods-available/jetendo.ini\n");
	exit;
}


$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"));

// verify existence of the database

$sql="SHOW DATABASES LIKE '".zGetDatasource()."'";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT);
if($r->num_rows == 0){
	$sql="CREATE DATABASE `".zGetDatasource()."`";
	$r=$cmysql->query($sql, MYSQLI_STORE_RESULT);

	$sql="SHOW DATABASES LIKE '".zGetDatasource()."'";
	$r=$cmysql->query($sql, MYSQLI_STORE_RESULT);
	if($r->num_rows == 0){
		echo 'Unable to create database, "'.zGetDatasource().'", make sure the user, "'.get_cfg_var("jetendo_mysql_default_user").
		'" has permission to create the database or create it manually and re-run this script.';
	}
}

// source code install & integrity checks

if(zIsTestServer()){
	$gitIntegrityCheck=get_cfg_var("jetendo_git_integrity_enabled");
}else{
	$gitIntegrityCheck=get_cfg_var("jetendo_test_git_integrity_enabled");
}
echo("Check git status\n");
$gitCloneURL=get_cfg_var("jetendo_git_clone_url");
$gitBranch=get_cfg_var("jetendo_git_branch");
chdir(get_cfg_var("jetendo_root_path"));
$status=`/usr/bin/git status`;
if(strpos($status, "fatal: Not a git repository") !== FALSE){
	echo("Git repo doesn't exist. Running git clone.\n");
	if(!$debug){
		$r=`/usr/bin/git clone $gitCloneURL`;
		$r=`/usr/bin/git checkout $gitBranch`;
	}
	$status=`/usr/bin/git status`;
}else{
	if(!$debug){
		$r=`/usr/bin/git checkout $gitBranch`;
		$r=`/usr/bin/git remote add origin $gitCloneURL`;
	}
}

if(strpos($status, "nothing to commit, working directory clean") !== FALSE){
	echo("Git repo is clean. All files match the ".$gitBranch." at ".$gitCloneURL.".\n");
}else{
	echo("Git repo is not clean: Ignore this if you are intentionally changing the Jetendo source code before installation.\n");
	if(!$debug && $gitIntegrityCheck == "1"){
		$r=`/usr/bin/git reset --hard origin/$gitBranch`;
		$r=`/usr/bin/git pull origin $gitBranch`;
		$r=`/usr/bin/git gc`;
		echo("Current directory was hard reset back to the git origin (".$gitCloneURL.") branch: ".$gitBranch.".\n");
	}
}


installJetendoCronTabs();

if(zIsTestServer()){
	$adminDomain=get_cfg_var("jetendo_test_admin_domain");
}else{
	$adminDomain=get_cfg_var("jetendo_admin_domain");
}
echo "Pre-installation complete.\n\nVisit the following URL in your browser to complete installation:\n\n".
$adminDomain."/z/server-manager/admin/server-home/index?zreset=app&zforce=1\n\n";

?>