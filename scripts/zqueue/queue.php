<?php
require(get_cfg_var("jetendo_scripts_path")."library.php");
$host=`hostname`;
set_time_limit (60); // 1 hour timeout for video encoding task

$timeout=60; // seconds
$time_start = microtime_float();

if(strpos($host, get_cfg_var("jetendo_test_domain")) !== FALSE){
	// test server
	$testserver=true;
}else{
	$testserver=false;
}
mysql_connect(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"),get_cfg_var("jetendo_mysql_default_password"));

mysql_select_db(zGetDatasource());

$sitesWritablePath=get_cfg_var("jetendo_sites_writable_path");
/*
queue_status error codes:
	2 = error - check queue_error for the reason
	1 = running
	0 = not started
	3 = complete
*/

for($i101=0;$i101<70;$i101++){

	// get a running queue entry
	$sql="select * from queue where queue_status = '1' and queue_deleted = '0' ";//queue_id='".$queue_id."' and
	$r=mysql_query($sql);
	$c=mysql_num_rows($r);
	if($c==0){
		sleep(1);
		// wait 1 second and check again
		continue;
	}
	// one is running now, check progress
	$row=mysql_fetch_object($r);
	echo $row->queue_id." is running\n";
	if($row->queue_cancelled=="1"){
		// kill linux process matching name HandBrakeCLI or Nice maybe...
		echo "cancelling\n";
		$sql2="update queue set queue_deleted='1', queue_updated_datetime='".date('Y-m-d H:i:s')."' where queue_id='".$row->queue_id."'";
		mysql_query($sql2);
		$r=`pidof HandBrakeCLI`;
		if($r != ""){
			`kill -9 $r`;	
		}
		$sql="select * from site where site_active = '1' and site_id = '".$row->site_id."'";
		$qSite=mysql_query($sql);
		$count=mysql_num_rows($qSite);
		if($count == 0){
			continue;
		}
		$siteRow=mysql_fetch_object($qSite);
		$thedomainpath=str_replace("www.", "", str_replace(".".$testDomain, "", $siteRow->site_short_domain));
		$siteInstallPath=$sitesWritablePath.str_replace(".","_",$thedomainpath)."/";
		
		$originalPath=get_cfg_var("jetendo_root_path").$row->queue_original_file;
		
		if(substr($originalPath, 0, strlen($siteInstallPath."zupload/video/")) != $siteInstallPath."zupload/video/"){
			continue;
		}
		if(strpos(substr($originalPath, strlen($siteInstallPath."zupload/video/")), "/") !== FALSE){
			continue; 
		}
		@unlink(get_cfg_var("jetendo_root_path").$row->queue_original_file);
		@unlink(get_cfg_var("jetendo_log_path")."zqueue/complete/".$row->queue_file); 
		continue;
	}
	$md=preg_replace("/ /","-", preg_replace("/:/","-", $row->queue_updated_datetime));

	$d = explode('-', $md); 
	$updatedDate = mktime($d[3],$d[4],$d[5],$d[1],$d[2],$d[0]);
	$thirtyMinuteAgo= strtotime('-1800 seconds');
	if ($updatedDate < $thirtyMinuteAgo) {
		echo "Check if handbrake is still running.";
		if(`pidof HandBrakeCLI` == ""){
			// it isn't.  restart this queue.
			$to      = get_cfg_var("jetendo_developer_email_to");
			$subject = 'PHP handbrakecli 30 minute timeout exceeded on '.$host;
			$headers = 'From: '.get_cfg_var("jetendo_developer_email_from") . "\r\n" .
			$message = 'PHP handbrakecli 30 minute timeout exceeded on '.$host.".  The queue entry was reset to be tried again.";
				'Reply-To: '.get_cfg_var("jetendo_developer_email_from") . "\r\n" .
				'X-Mailer: PHP/' . phpversion();

			mail($to, $subject, $message, $headers);
			$sql="update queue set queue_progress='0', queue_status='0', queue_updated_datetime='".date('Y-m-d H:i:s')."' where queue_id='".$row->queue_id."'";
			mysql_query($sql);
		}
	}
	$logDir=get_cfg_var("jetendo_log_path").'zqueue/';
	$logPath=$logDir.$row->queue_file."-handbrakecli-log.txt";
	$line = '';

	$f = fopen($logPath, 'r');
	$cursor = -1;

	fseek($f, $cursor, SEEK_END);
	$char = fgetc($f);

	/**
	 * Trim trailing newline chars of the file
	 */
	while ($char === "\n" || $char === "\r") {
		fseek($f, $cursor--, SEEK_END);
		$char = fgetc($f);
	}

	/**
	 * Read until the start of file or first newline char
	 */
	while ($char !== false && $char !== "\n" && $char !== "\r") {
		/**
		 * Prepend the new char
		 */
		$line = $char . $line;
		fseek($f, $cursor--, SEEK_END);
		$char = fgetc($f);
	}

	fclose($f);
	 
	if(strpos($line, "Encoding:") !== FALSE){
		//task 1 of 1, 0.00 %
		$p=strpos($line, ",");	
		$p2=strpos($line, "%");	
		$l2=$line;
		if($p!==FALSE && $p2 !==FALSE){
			$percent=substr($l2, $p+1, $p2-($p+1)-1);
			echo $percent."% complete\n";
			$sql="update queue set queue_progress='".$percent."', queue_updated_datetime='".date('Y-m-d H:i:s')."' where queue_id='".$row->queue_id."'";

			mysql_query($sql);
			echo mysql_error();
		}
	}

	sleep(1);
	if(microtime_float() - $time_start > $timeout-3){
		echo "Timeout reached";
		exit;
	}
}
?>