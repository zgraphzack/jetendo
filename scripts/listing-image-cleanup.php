<?php
$debug=false;
$minutesToDelayProcessing=5;
$host=`hostname`;
error_reporting(E_ALL);

$testDomain=get_cfg_var("jetendo_test_domain");
set_time_limit(10000);

$timeStart = microtime(true);


if(str_replace($testDomain,"",$host) != $host || str_replace($testDomain,"",$host) != $host){
	// test server
	$testserver=true;
	$mlsDatasource=zGetDatasource();
	$mlsDataDatasource=zGetDatasource();
	$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), $mlsDatasource);
}else{
	$testserver=false;
	$mlsDatasource=zGetDatasource();
	$mlsDataDatasource=zGetDatasource();
	$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), $mlsDatasource);
}
$mysqldate = date("Y-m-d H:i:s");
$oldDate=mktime(0, 0, 0, date("m"),date("d")-60,date("Y")); // only delete images more then 60 days old
$deleteCount=0;
$fileCount=0;
$timeout=10000; // seconds
$queryCount=0;

function cleanImageFunction($arrSQL, &$arrId, &$arrPath, $force){
	global $cmysql, $oldDate, $timeStart, $deleteCount, $fileCount, $queryCount, $timeout;
	$arrNewId=array();
	$count=count($arrId);
	if($count == 0){
		return;
	}else if($force==false && $count < 500){
		return;
	}
	$cmysql->select_db($arrSQL[1]);
	// echo $arrSQL[0].implode("','", $arrId)."')";
	$result=$cmysql->query($arrSQL[0].implode("','", $arrId)."')", MYSQLI_USE_RESULT);
	if($cmysql->error != ""){
		echo "Failed to run query:";
		echo $cmysql->error."\n\n".$arrSQL[0].implode("','", $arrId)."')";
		exit;		
	}
	//echo "run\n";
	while($row=$result->fetch_array(MYSQLI_NUM)){
		$queryCount++;
		$arrNewId[$row[0]]=true;	
	}
	for($i=0;$i<$count;$i++){
		if(!isset($arrNewId[$arrId[$i]])){
			// missing in database delete the file if it is old enough
			if($arrPath[$i] == ""){
				var_dump($arrPath);
				echo "Path was blank";
				exit;
			}
			if(filemtime($arrPath[$i]) < $oldDate){
				$deleteCount++;
				echo "InClean-Delete file:".$arrPath[$i]."\n";
				//exit;
				unlink($arrPath[$i]);
				usleep(30000);
			}
		}
	}
	$arrId=array();
	$arrPath=array();
	echo "Time:".(microtime(true) - $timeStart)."\n";
	if(microtime(true) - $timeStart > $timeout){
		echo "Delete count:".$deleteCount." out of ".$fileCount." files | ".$queryCount." found in database.\n";
		echo "More then ".$timeout." seconds - exiting so the next run can start";
		exit;	
	}
	//usleep(200);
	//echo "donetest";
	//exit;
}
function getListingId($id){
	global $mlsDatasource;
	return array("select listing_id as id from `listing_track` WHERE listing_id IN ('", $mlsDatasource, $id, false);
}
function getRets7SysId($id){
	global $mlsDatasource, $mlsDataDatasource;
	return array("select listing_id as id from `listing_track` WHERE listing_id IN ('", $mlsDatasource, $id, true, "select SQL_NO_CACHE rets7_sysid as imageid, rets7_175 as listingid from rets7_property where rets7_sysid IN ('", $mlsDataDatasource);
}
function getRets12SysId($id){
	global $mlsDatasource, $mlsDataDatasource;
	return array("select listing_id as id from `listing_track` WHERE listing_id IN ('", $mlsDatasource, $id, true, "select SQL_NO_CACHE rets12_sysid as imageid, rets12_157 as listingid from rets12_property where rets12_sysid IN ('", $mlsDataDatasource);
}
function getRets16SysId($id){
	global $mlsDatasource, $mlsDataDatasource;
	return array("select listing_id as id from `listing_track` WHERE listing_id IN ('", $mlsDatasource, $id, true, "select SQL_NO_CACHE rets16_sysid as imageid, rets16_157 as listingid from rets16_property where rets16_sysid IN ('", $mlsDataDatasource);
}
function getRets19SysId($id){
	global $mlsDatasource, $mlsDataDatasource;
	return array("select listing_id as id from `listing_track` WHERE listing_id IN ('", $mlsDatasource, $id, true, "select SQL_NO_CACHE rets19_sysid as imageid, rets19_157 as listingid from rets19_property where rets19_sysid IN ('", $mlsDataDatasource);
}
function getRets20SysId($id){
	global $mlsDatasource, $mlsDataDatasource;
	return array("select listing_id as id from `listing_track` WHERE listing_id IN ('", $mlsDatasource, $id, true, "select SQL_NO_CACHE rets20_matrix_unique_id as imageid, rets20_mlsnumber as listingid from rets20_property where rets20_matrix_unique_id IN ('", $mlsDataDatasource);
}
function getRets22SysId($id){
	global $mlsDatasource, $mlsDataDatasource;
	return array("select listing_id as id from `listing_track` WHERE listing_id IN ('", $mlsDatasource, $id, true, "select SQL_NO_CACHE rets22_list_1 as imageid, rets22_list_105 as listingid from rets22_property where rets22_list_1 IN ('", $mlsDataDatasource);
}


	
$arrQueryFunction=array();
$arrQueryFunction["3"]="getListingId";
$arrQueryFunction["4"]="getListingId";
$arrQueryFunction["7"]="getRets7SysId";
//$arrQueryFunction["8"]="getListingId";
$arrQueryFunction["9"]="getListingId";
$arrQueryFunction["11"]="getListingId";
$arrQueryFunction["12"]="getRets12SysId";
$arrQueryFunction["13"]="getListingId";
//$arrQueryFunction["14"]="getListingId";
$arrQueryFunction["15"]="getListingId";
$arrQueryFunction["16"]="getRets16SysId";
$arrQueryFunction["17"]="getListingId";
//$arrQueryFunction["18"]="getRets18SysId";
$arrQueryFunction["19"]="getRets19SysId";
$arrQueryFunction["20"]="getRets20SysId";
$arrQueryFunction["22"]="getRets22SysId";

function checkForListingId($sql, $arrId, $database){
	global $cmysql, $queryCount;
	$cmysql->select_db($database);
	// echo $arrSQL[0].implode("','", $arrId)."')";
	$result=$cmysql->query($sql.implode("','", $arrId)."')", MYSQLI_USE_RESULT);
	if($cmysql->error != ""){
		echo "Failed to run query:";
		echo $cmysql->error."\n\n".$sql.implode("','", $arrId)."')";
		exit;		
	}
	$arrNewId=array();
	//echo "run\n";
	while($row=$result->fetch_array(MYSQLI_NUM)){
		$queryCount++;
		$arrNewId[$row[0]]=$row[1];	
	}
	return $arrNewId;
}

$mp=get_cfg_var("jetendo_share_path")."mls-images/";
$arrHex=array(0,1,2,3,4,5,6,7,8,9,"a","b","c","d","e","f");
$totalCount=0;
foreach($arrQueryFunction as $key=>$val){
	$keyPrefix=strlen($key."-");
	for($i7=0;$i7<16;$i7++){
		for($i8=0;$i8<16;$i8++){
			for($i9=0;$i9<16;$i9++){
				$curPath=$mp.$key."/".$arrHex[$i7].$arrHex[$i8]."/".$arrHex[$i9]."/";
				echo "Processing: ".$curPath."\n";
				if (is_dir($curPath) && $handle = opendir($curPath)) {
					$arrId=array();
					$arrPath=array();
					$arrSQL=$val($key);
					while (false !== ($entry = readdir($handle))) {
						$totalCount++;
						if($entry !="." && $entry !=".."){
							$fileCount++;
							$curFile=$curPath.$entry;
							$ext=substr($entry, strlen($entry)-4);
							if($ext == "jpeg" || $ext == ".pdf"){
								if($arrSQL[3]){
									// this file has the following file name format: mlsid-listingid-photonumber.jpeg
									
									$pos=strpos($entry, "-");
									if($pos===FALSE){
										echo "Invalid file:".$curFile."\n";
									}else{
										$pos2=strpos($entry, "-", $pos+2);
										if($pos2===FALSE){
											// check if this sysid exists in table and rename the file if it does.
											if(count($arrSQL) >= 4){
												// do query here
												$sysId=substr($entry, 0, $pos);
												$arrResult=checkForListingId($arrSQL[4], array($sysId), $arrSQL[5]);
												$resultCount=count($arrResult);
												for($i=0;$i<$resultCount;$i++){
													// rename file here	
													// rename($arrResult[$sysId]);
													$newFileName=$arrResult[$sysId].substr($entry, $pos);
													
													$md5name=md5($newFileName);
													$tempPath=$mp.$key."/".substr($md5name,0,2)."/".substr($md5name,2,1)."/";
													if(!is_dir($tempPath)){
														mkdir($tempPath, 0777, true);
													}
													//echo $curFile."\n\n".$tempPath.$newFileName."\n\n";
													echo "Rename to:".$newFileName."\n";
													rename($curFile, $tempPath.$newFileName);
													usleep(30000);
												}
												if($resultCount==0){
													// need to decide what to do with images that never match a listing in the database.
													echo "Skip inactive:".$entry."\n";
													continue;
												}
											}else{
												echo "Skip:".$entry."\n";
												continue;
											}
										}else{
											$tempId=substr($entry, 0, $pos2);
											if(strlen($tempId)!=0){
											//echo "id:".$tempId;
											//exit;
												array_push($arrId, $tempId);
												array_push($arrPath, $curFile);
												// echo "pushid:".$tempId."\n";
											}
										}
									}
								}else{
									// this file has the following file name format: listingid-photonumber.jpeg
									$pos=strpos($entry, "-");
									if($pos===FALSE){
										echo "Invalid file:".$curFile."\n";
									}else{
											//echo "id2:".$key."-".substr($entry, 0, $pos);
											//exit;
										//echo "pushnoid:".substr($entry, 0, $pos)."\n";
										if(substr_count($entry, "-") == 1){
											array_push($arrId, $key."-".substr($entry, 0, $pos));
										}else{
											array_push($arrId, substr($entry, 0, $pos));
										}
										array_push($arrPath, $curFile);
									}
								}
							}else{
								echo "Delete invalid: ".$curPath.$entry."\n";
								@unlink($curPath.$entry);
								usleep(40000);
							}
						}
					}
					closedir($handle);
					//cleanImageFunction($arrSQL, $arrId, $arrPath, true);
					
				}
			}
		}
	}
}
echo "Delete count:".$deleteCount." out of ".$totalCount." files | ".$queryCount." found in database.\n";
exit;
?>
