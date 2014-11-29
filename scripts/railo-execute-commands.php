<?php
//require("library.php");
set_time_limit(70);
function microtimeFloat()
{
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
}

$debug=true;
$timeout=60; // seconds
$timeStart=microtimeFloat();
$completePath=get_cfg_var("jetendo_root_path")."execute/complete/";
$startPath=get_cfg_var("jetendo_root_path")."execute/start/";

//$processorCount=`/bin/cat /proc/cpuinfo | /bin/grep processor | /usr/bin/wc -l`;

$runningThreads=0;

$script='/usr/bin/php "'.get_cfg_var("jetendo_scripts_path").'railo-execute-commands-process.php" ';
if($debug){
	$background=' ';
}else{
	$background=" > /dev/null 2>/dev/null &";
}
$arrEntry=array();
while(true){
	$handle=opendir($startPath);
	if($handle){
		while (false !== ($entry = readdir($handle))) {
			if(array_key_exists($entry, $arrEntry)){
				continue;
			}
			if(substr($entry, strlen($entry)-4, 4) !=".txt"){
				continue;
			}
			$phpCmd=$script.escapeshellarg($entry).$background;
			if($debug){
			//	echo $phpCmd."\n";
			}
			echo `$phpCmd`;
			$arrEntry[$entry]=true;
		}
		closedir($handle);
	}
	usleep(30000); // wait 30 milliseconds

	if(microtimeFloat() - $timeStart > $timeout){
		echo "Timeout reached";
		exit;
	}
}
?>