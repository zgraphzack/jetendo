<?php
require(get_cfg_var("jetendo_scripts_path")."library.php");
set_time_limit (3500); // 1 hour timeout | schedule task to run hourly.
error_reporting(E_ALL);
echo "\n";

/*
$imageURL="http://cdn.resize.flexmls.com/dab/1024x768/true/20150226044611544232000000-o.jpg";
$p="/var/jetendo-server/jetendo/sites/test.jpg.temp";
if(file_exists($p)){
	unlink($p);
}
$fp = fopen ($p, 'w+');//This is the file where we save the    information
$ch = curl_init(str_replace(" ","%20",$imageURL));//Here is the file we are downloading, replace spaces with %20
curl_setopt($ch, CURLOPT_TIMEOUT, 20); // seconds
curl_setopt($ch, CURLOPT_FILE, $fp); // write curl response to file
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_exec($ch); // get curl response
curl_close($ch);
fclose($fp);

	$source = imagecreatefromjpeg($p);
	if($source===FALSE){
		echo("dead");
	}
	var_dump(gettype($source));
exit;
*/
function downloadImageFile($path, $mlsId, $listingId, $imageURL, $imageNumber, $force){ 
	//echo($listingId."\n");
	//echo($imageURL);exit;  
	$fname=$mlsId."-".$listingId."-".$imageNumber.".jpeg";//
	$md5name=md5($fname);

	$fpath=$path.$mlsId."/".substr($md5name,0,2)."/".substr($md5name,2,1)."/";
	if(!is_dir($fpath)){
		mkdir($fpath, 0777, true);
	} 
	if(file_exists($fpath.$fname)){
		if($force){
			unlink($fpath.$fname);
		}else{
			echo "Exists:".$fpath.$fname."\n";
		}
	}else{
		$force=true;
	}

	if($force){
		echo "Downloading to:".$fpath.$fname."\n";

// http://cdn.resize.flexmls.com/dab/1024x768/true/20150308162308967640000000-o.jpg
// http://cdn.resize.flexmls.com/dab/1024x768/true/20150308162309203767000000-o.jpg

		$retryCount=0;
		while(true){
	 		if(file_exists($fpath.$fname.".temp.jpg")){
	 			unlink($fpath.$fname.".temp.jpg");
	 		} 
	 		/*

	 		$fp=fopen($imageURL, "r");
			$r2 = stream_get_contents($fp);
			fclose($fp);
	 		if($r2 !== FALSE){
				$r=file_put_contents($fpath.$fname.".temp.jpg", $r2);
				if(filesize($fpath.$fname.".temp.jpg") != 0){
					break;
				}else{
					sleep(1);
				}
			}else{
				sleep(1);
			}
			*/
			$fp = fopen ($fpath.$fname.".temp.jpg", 'w');//This is the file where we save the    information
			$ch = curl_init();//Here is the file we are downloading, replace spaces with %20
			curl_setopt($ch, CURLOPT_TIMEOUT, 20); // seconds
			curl_setopt($ch, CURLOPT_HEADER, false);

 
			echo "Image URL: ".$imageURL."\n";
			curl_setopt($ch, CURLOPT_URL, $imageURL);
			if($retryCount >0){
				curl_setopt($ch, CURLOPT_VERBOSE, true);
				//curl_setopt($ch, CURLOPT_STDERR, STDOUT);
			}
			//curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
			curl_setopt($ch, CURLOPT_FILE, $fp); // write curl response to file
			curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true); 
			$r2=curl_exec($ch); // get curl response 
			$r="";
			if($errno = curl_errno($ch)) {
			    $error_message = curl_strerror($errno);
			    $r= "cURL error ({$errno}):\n {$error_message}";
			} 
			curl_close($ch);
			fclose($fp);  
			echo " done.\n";
			$retryCount++;
			$r="";
			if(filesize($fpath.$fname.".temp.jpg") != 0){
				break;
			}else{
				sleep(1);
			}
			if($retryCount==3){
				$s="Failed to download image 3 times in a row: ".$imageURL. "\n result: ".$r;
				echo $s;
				zEmailErrorAndExit("Failed to download image 3 times in a row", $s);
			}
		}
		cropWhiteEdgesFromImage($fpath.$fname.".temp.jpg", $fpath.$fname);
		//rename($fpath.$fname.".temp", $fpath.$fname); 
	}
	//exit;
}

function processImageFile($path, $mlsId, $fileName){
	$newPath=$path.$mlsId."/".$fileName;
	$handle = fopen($newPath, "r");
	$first=true;
	$lineNumber=0;
	$skipToLineNumber=0;
	$force=false;
	if(file_exists($newPath."-tracking")){
		$skipToLineNumber=file_get_contents($newPath."-tracking");
		$force=true;
	}
	if ($handle) {
		echo "Processing ".$newPath."\n";
		while (($buffer = fgets($handle, 38096)) !== false) {
			$lineNumber++;
			if($first || $skipToLineNumber>$lineNumber){
				if($first){
					$a=explode("\t", $buffer);
					if(count($a) != 2){  
						$s="Break was early because row was not 2 columns: ".$buffer;
						zEmailErrorAndExit($s, $s." in ".$newPath); 
						break;
					}
				}
				$first=false;
				continue;
			}
			$a=explode("\t", $buffer);
			if(count($a) != 2){  
				$s="Break was early because row was not 2 columns: ".$buffer;
				zEmailErrorAndExit($s, $s." in ".$newPath);  
				break;
			}
			$listingId=$a[0];
			$arrImage=explode(",", $a[1]);  
			$imageNumber=1;
			for($n=0;$n<count($arrImage);$n++){
				$i=trim($arrImage[$n]);
				if($i != ""){
					downloadImageFile($path, $mlsId, $listingId, $i, $imageNumber, $force);
					$imageNumber++;
				}
			}
			if($lineNumber % 10 == 0){
				file_put_contents($newPath."-tracking", $lineNumber);
			}
			//break;
		}
		fclose($handle);
		if(file_exists($newPath."-imported")){
			unlink($newPath."-imported");
		}
		if(file_exists($newPath."-tracking")){
			unlink($newPath."-tracking");
		}
		rename($newPath, str_replace("-processing", "", $newPath."-imported"));

	} 
}

function processImageFiles(){
	$path=get_cfg_var("jetendo_share_path")."mls-images/";

	$validMLS=array( 
		"26"=>true,
		"27"=>true,
		"22"=>true,
		"24"=>true
	);
	if ($handle = opendir($path)) {
	    while (false !== ($entry = readdir($handle))) {
			if($entry !="." && $entry !=".." && isset($validMLS[$entry])){
				$path2=$path.$entry."/";
				//echo $path2."\n";
				if (is_dir($path2) && $handle2 = opendir($path2)) {
				    while (false !== ($entry2 = readdir($handle2))) {
						if($entry2 !="." && $entry2 !=".." && strpos($entry2, "-tracking") === FALSE && strpos($entry2, "-imported") === FALSE && is_file($path2.$entry2)){
							if(strpos($entry2, "-processing") === FALSE){
								if(file_exists($path2.$entry2."-processing")){
									// finish the current file before processing the new one.
									continue;
								}
								rename($path2.$entry2, $path2.$entry2."-processing");
								processImageFile($path, $entry, $entry2."-processing");
							}else{
								processImageFile($path, $entry, $entry2);
							}
						}
					}

					closedir($handle2);
				}
			}
		}

		closedir($handle);
	}
} 
function resetImageFiles(){
	$path=get_cfg_var("jetendo_share_path")."mls-images/";
	if ($handle = opendir($path)) {
	    while (false !== ($entry = readdir($handle))) {
			if($entry !="." && $entry !=".."){
				$path2=$path.$entry."/"; 
				if (is_dir($path2) && $handle2 = opendir($path2)) {
				    while (false !== ($entry2 = readdir($handle2))) {
				    	$newPath=$path2.$entry2;
				    	$newPath2=str_replace("-processing", "", str_replace("-imported", "", $newPath));
				    	if($newPath != $newPath2){
				    		echo "Reset file: ".$newPath2."\n";
							rename($newPath, $newPath2);
						}
				    }
					closedir($handle2);
				}
			}
		}
		closedir($handle);
	}
	echo "Files reset";
}
// uncomment when debugging to rename files back to original state
//resetImageFiles(); 
processImageFiles();


?>