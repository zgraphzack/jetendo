<?php
// Add this task to crontab manually if you want the server to download missing rets images automatically.  This will run it every 2 hours.
// 10 */2 * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/rets-download-missing-images.php >/dev/null 2>&1
require("library.php");
error_reporting(E_ALL);

$debug=false;
$time_start = microtime_float();
ini_set("memory_limit","256M");
$timeoutInSeconds=6900; 
set_time_limit($timeoutInSeconds+250);

$host=`hostname`;

$testserver=zIsTestServer();

$mlsDatasource=get_cfg_var("jetendo_datasource");
$mlsDataDatasource=get_cfg_var("jetendo_datasource");
$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"),get_cfg_var("jetendo_mysql_default_password"), get_cfg_var("jetendo_datasource"));

if($cmysql->error != ""){
	echo "Mysql error:".$cmysql."\n";
	exit;
}
$mysqldate = date("Y-m-d H:i:s");


$perloop=30;
$destinationPath=get_cfg_var("jetendo_share_path")."mls-images/";
$result=$cmysql->query("SELECT * FROM mls WHERE 
mls_status = '1' and 
mls_provider LIKE 'rets%' 
and mls_id NOT IN ('12', '19', '20')
ORDER BY mls_update_date desc", MYSQLI_STORE_RESULT);
// errors:
// 12 = User Agent not registered or denied.
// 19 = password is not working yet - need to test when it does
// 20 = Authorization failed - need to test in the morning hours in case that it is why.

while($mlsRow=$result->fetch_array(MYSQLI_ASSOC)){
	$offset=0;
	$type=getRetsImageType($mlsRow["mls_id"]);
	if(!isset($arrRetsConfig[$mlsRow["mls_id"]]) || $arrRetsConfig[$mlsRow["mls_id"]]['username'] == ""){
		echo "Skipping mls_id=".$mlsRow["mls_id"]." because there is no login information specified.\n";
		continue;
	}
	if($type==false){
		echo "Skipping mls_id=".$mlsRow["mls_id"]." because we don't store images for this RETS server yet.\n";
		continue;
	}
	while(true){
		$result=$cmysql->query("select listing_id, listing_photocount, listing_liststatus from `zram#listing` listing where listing_id like '".$mlsRow["mls_id"]."-%' LIMIT ".$offset.", ".$perloop." ", MYSQLI_STORE_RESULT);
		if($result->num_rows == 0){
			break;
		}
		while($row=$result->fetch_array(MYSQLI_ASSOC)){
			// verify existence of all images.
			if($row['listing_liststatus'] != 1){
				$c=1;
			}else{
				$c=$row['listing_photocount'];
			}
			$arrId=explode("-", $row["listing_id"]);
			$mls_id=$arrId[0];
			for($i=1;$i<=$c;$i++){
				$fname=$row["listing_id"]."-".$i.".jpeg";
				$md5name=md5($fname);
				$fpath=$destinationPath.$mls_id."/".substr($md5name,0,2)."/".substr($md5name,2,1)."/";
				if(!file_exists($fpath.$fname)){
					ob_start();
					$r=zDownloadRetsImages($row["listing_id"], "", $i);
					$out=ob_get_clean();
					echo $out;
					if($r===false){
						zEmailErrorAndExit("Failed to download rets images for listing_id=".$row["listing_id"], "Failed to download rets images for listing_id=".$row["listing_id"]."\n\nLast messages output:\n".$out);
					}
				}
			}
		}
		if(microtime_float() - $time_start > $timeoutInSeconds){
			echo "Timeout reached - aborting\n";
			exit;
		}
		$offset+=$perloop;
	}
}
//$r=zDownloadRetsImages("25-A3980519", "", "1");

exit;

/*
if(microtime_float()-$time_start > 290){
	// take a break
	echo "Timeout reached\n";
	exit;
}
echo "after temp move\n";


echo "start image processing\n";

$mp="".get_cfg_var("jetendo_share_path")."mls-images/temp/";
$destinationPath="".get_cfg_var("jetendo_share_path")."mls-images/";
chdir($mp);
if($debug) echo "Moving mls-images from windows to linux local\n\n";
$iCount1=0;
$arrFID=array();
$arrFID2=array();
$arrF=array();
$arrFD=array();
$arrFN=array();
$stopProcessing=false;

$lastMessage2="";
$lastMessage="";
//$oneMinuteAgo=mktime(date("H"), date("i")-1, date("s"), date("m"),date("d"),date("Y"));
if ($handle = opendir($mp)) {
    while (false !== ($entry = readdir($handle))) {
		if($entry !="." && $entry !=".."){
			$mp2=$mp.$entry."/";
			if(isset($arrQueryFunction[$entry])){
				$arrSQL=$arrQueryFunction[$entry]();
			}else{
				$arrSQL="";
			}
			echo "process:".$mp2."\n";
			if ($handle2 = opendir($mp2)) {
				while (false !== ($entry2 = readdir($handle2))) {
					if(substr($entry2, strlen($entry2)-5,5) == ".jpeg" || substr($entry2, strlen($entry2)-4,4) == ".jpg" || substr($entry2, strlen($entry2)-4,4) == ".pdf"){// !="." && $entry2 !=".."){
						$pos=strpos($entry2, "-");
						$cur=$mp.$entry."/".$entry2;
						$idname=$entry."-".$entry2;
						$idonlyname=substr($entry2, 0, $pos);
						if($iCount1 % 100 == 0){
							if($iCount1 !=0){
								echo "process ".$iCount1."\n";
								$r=processFiles($arrSQL, $arrF, $arrFID, $arrFID2, $arrFD, $arrFN);
								if($r===FALSE){
									$stopProcessing=true;
									break;
								}
							}
							$arrFID=array();
							$arrFID2=array();
							$arrF=array();
							$arrFD=array();
							$arrFN=array();
							$fiveMinuteAgo=mktime(date("H"), date("i")-$minutesToDelayProcessing, date("s"), date("m"),date("d"),date("Y"));
							if(microtime_float()-$time_start > 290){
								// take a break
								echo "Timeout reached\n";
								exit;
							}
						}
						$cmtime=@filemtime($cur);
						if($cmtime !== FALSE && $cmtime < $fiveMinuteAgo){
							$csize=@filesize($cur);
							if($csize !== FALSE && $csize != 0){
								$iCount1++;
								// add
								array_push($arrFID2, $idonlyname);
								array_push($arrFID, $idname);
								array_push($arrF, $cur);
								array_push($arrFD, $destinationPath.$entry."/".$entry2);
								array_push($arrFN, $entry2);
							}
						}
					}
				}
				closedir($handle2);
			}
			if($stopProcessing){
				break;
			}
		}
    }
	if($stopProcessing){
		
		$to      = get_cfg_var('jetendo_developer_email_to');
		$subject = 'PHP move-mls-images.php stopped processing on '.$host;
		$headers = 'From: ' .get_cfg_var('jetendo_developer_email_from'). "\r\n" .
			'Reply-To: '.get_cfg_var('jetendo_developer_email_from') . "\r\n" .
			'X-Mailer: PHP/' . phpversion();
		$message = 'PHP move-mls-images.php stopped processing'."\nLast Image Message:".$lastMessage."\nLast Process Files Message:".$lastMessage2;

		mail($to, $subject, $message, $headers);
	}else if(count($arrF) != 0){
		processFiles($arrSQL, $arrF, $arrFID, $arrFID2, $arrFD, $arrFN);
	}
    closedir($handle);
}

echo "\ndelete:".$runningFilePath."\n";
@unlink($runningFilePath);

*/

?>