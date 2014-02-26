<?php
require("library.php");
function getTasks(){
	$arrTask=array();
	if(zIsTestServer()){
		$adminDomain=get_cfg_var("jetendo_test_admin_domain");
	}else{
		$adminDomain=get_cfg_var("jetendo_admin_domain");
	}
	$t=new stdClass();
	$t->logName="listing-generatedata.html";
	$t->type="every";
	$t->interval=7200;
	$t->startTimeOffsetSeconds=1020;
	$t->url=$adminDomain."/z/listing/tasks/generateData/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="listing-lookup-builder.html";
	$t->interval=3600;
	$t->startTimeOffsetSeconds=1420;
	$t->url=$adminDomain."/z/listing/tasks/listingLookupBuilder/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->interval="daily";
	$t->logName="publish-missing.html";
	$t->startTimeOffsetSeconds=1000;
	$t->url=$adminDomain."/z/server-manager/tasks/publish-missing/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="delete-inactive-image-library.html";
	$t->interval=3600;
	$t->startTimeOffsetSeconds=2420;
	$t->url=$adminDomain."/z/_com/app/image-library?method=deleteInactiveImageLibraries";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="importMLSData.html";
	$t->interval=2400;
	$t->startTimeOffsetSeconds=0;
	$t->url=$adminDomain."/z/listing/tasks/importMLS/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="blog-pings.html";
	$t->interval=900;
	$t->startTimeOffsetSeconds=0;
	$t->url=$adminDomain."/z/blog/admin/ping/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="site-map-xml-publish.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=1400;
	$t->url=$adminDomain."/z/server-manager/tasks/update-sitemap/index?force=1";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="resend-autoresponders.html";
	$t->interval=7200;
	$t->startTimeOffsetSeconds=1020;
	$t->url=$adminDomain."/z/server-manager/tasks/resend-autoresponders/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="clear-old-skin-cache.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=2000;
	$t->url=$adminDomain."/z/_com/display/skin?method=deleteOldCache";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="publish-ssi-skin.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=2400;
	$t->url=$adminDomain."/z/server-manager/tasks/publish-ssi-skin/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="reindex-all-site-content.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=1000;
	$t->url=$adminDomain."/z/server-manager/tasks/search-index/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="send-listing-email-alerts.html";
	$t->interval=60;
	$t->startTimeOffsetSeconds=0;
	$t->url=$adminDomain."/z/listing/tasks/sendListingAlerts/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="listing-update-metadata.html";
	$t->interval=3600;
	$t->startTimeOffsetSeconds=100;
	$t->url=$adminDomain."/z/listing/tasks/update-metadata/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="password-expiration.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=2000;
	$t->url=$adminDomain."/z/server-manager/tasks/password-expiration/index";
	array_push($arrTask, $t);


	$t=new stdClass();
	$t->logName="verify-apps.html";
	$t->interval=60;
	$t->startTimeOffsetSeconds=0;
	$t->url=$adminDomain."/z/server-manager/tasks/verify-apps/index";
	array_push($arrTask, $t);
	return $arrTask;
}

set_time_limit(18000);
ini_set('default_socket_timeout', 18000);

$isTestServer=zIsTestServer();

if($isTestServer){
	echo "This is a test server - none of the tasks will actually be executed.\n";
}

$taskLogPath=get_cfg_var("jetendo_share_path")."task-log/";
$taskLogPathScheduler=get_cfg_var("jetendo_share_path")."task-log/scheduler.txt";

@mkdir($taskLogPath, 0700);
$arrTask=getTasks();
$arrSchedule=array();
$arrScheduleMap=array();
if(file_exists($taskLogPathScheduler)){
	$arrSchedule=explode("\n", trim(file_get_contents($taskLogPathScheduler)));
	for($i=0;$i<count($arrSchedule);$i++){
		$arr1=explode("\t", $arrSchedule[$i]);
		if(count($arr1) == 2){
			$arrScheduleMap[$arr1[0]]=$arr1[1];
		}
	}
}

$midnight = mktime(0, 0, 0);
$date = new DateTime(null);
$now=$date->getTimestamp();
$startOfTheHour = mktime(date("H"), 0, 0);
$arrRun=array();
$arrS=array();
for($i=0;$i<count($arrTask);$i++){
	$task=$arrTask[$i];
	$run=false;
	if($task->interval == "daily"){
		if(array_key_exists($task->logName, $arrScheduleMap)){
			$nextTime=$arrScheduleMap[$task->logName];
			if($nextTime <= $now){
				$run=true;
				$nextTime=$midnight + $task->startTimeOffsetSeconds + 86400;
			}
		}else{
			if($now-$midnight >= $task->startTimeOffsetSeconds){
				$run=true;
				$nextTime=$now + $task->interval;
			}else{
				$nextTime=$midnight + $task->startTimeOffsetSeconds + 86400;
			}
		}
	}else{
		if(array_key_exists($task->logName, $arrScheduleMap)){
			$nextTime=$arrScheduleMap[$task->logName];
			if($nextTime <= $now){
				$run=true;
				$nextTime=$now + $task->interval;
			}
		}else{
			if($now-$midnight >= $task->startTimeOffsetSeconds){
				$run=true;
				$nextTime=$now + $task->interval;
			}else{
				$nextTime=$midnight + $task->startTimeOffsetSeconds;
			}
		}
	}
	array_push($arrS, $task->logName."\t".$nextTime);
	if($run){
		array_push($arrRun, $task);
	}
}
function logEntry($message){
	global $taskLogPath;
	$fp=fopen($taskLogPath."cfml-tasks.log", "a");
	$m=date('l jS \of F Y h:i:s A').": ".$message."\n";
	$r=fwrite($fp, $m);
	fclose($fp);
}
if(count($arrRun) == 0){
	echo("No tasks needed to run, exiting.\n");
	exit;
}
$scheduleOutput=implode("\n", $arrS);
if(file_exists($taskLogPathScheduler)){
	unlink($taskLogPathScheduler);
}
file_put_contents($taskLogPathScheduler, $scheduleOutput);


for($i=0;$i<count($arrRun);$i++){
	$task=$arrRun[$i];
	echo "Running task: ".$task->url.": ";
	logEntry("Running task: ".$task->url);
	
	if($isTestServer){
		echo " this is test server, skipping task\n";
		logEntry("Test server, skipping task: ".$task->url);
	}else{
		$contents=file_get_contents($task->url);
		if($contents === FALSE){
			echo "failed\n";
			$contents="Connection failure";
			logEntry("Task connection failure: ".$task->url);
		}else{
			echo "success\n";
			logEntry("Task completed successfully: ".$task->url);
		}
		@unlink($taskLogPath.$task->logName);
		file_put_contents($taskLogPath.$task->logName, $contents);
	}
}

?>