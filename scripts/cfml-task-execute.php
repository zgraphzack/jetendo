<?php

set_time_limit(18000);
ini_set('default_socket_timeout', 18000);
$taskLogPath=get_cfg_var("jetendo_share_path")."task-log/";

if(count($argv) != 3){
	echo "Invalid number of arguments.";
	exit;
}
$taskURL=$argv[1];
$logName=$argv[2];

function logEntry($message){
	global $taskLogPath;
	$fp=fopen($taskLogPath."cfml-tasks.log", "a");
	$m=date('l jS \of F Y h:i:s A').": ".$message."\n";
	$r=fwrite($fp, $m);
	fclose($fp);
}

logEntry("Running task: ".$taskURL);

$contents=file_get_contents($taskURL);
if($contents === FALSE){
	echo "failed\n";
	$contents="Connection failure";
	logEntry("Task connection failure: ".$taskURL);
}else{
	echo "success\n";
	logEntry("Task completed successfully: ".$taskURL);
}
@unlink($taskLogPath.$logName);
file_put_contents($taskLogPath.$logName, $contents);

?>