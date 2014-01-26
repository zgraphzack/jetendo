<?php
require("library.php");
error_reporting(E_ALL);

$runningFilePath=get_cfg_var("jetendo_scripts_path")."move-mls-images-running.txt";
if(file_exists($runningFilePath)){
	$d=filemtime($runningFilePath);
	if($d > strtotime("-1 hour")){	
		echo "/root/move-mls-images.php is already running.";
		exit;
	}else{
		echo "This task must have crashed - removing ".$runningFilePath." and continuing.";
		unlink($runningFilePath);
		//exit;
	}
}
$fRunningHandle=fopen($runningFilePath, "w");
fwrite($fRunningHandle, "1");
fclose($fRunningHandle);
/**/
$debug=false;
$minutesToDelayProcessing=3;
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

$apache=false;
if(isset($_SERVER['SERVER_SOFTWARE'])){
	if(str_replace("Apache","",$_SERVER['SERVER_SOFTWARE']) != $_SERVER['SERVER_SOFTWARE']){
		$apache=true;
	}
}


set_time_limit(20000);
$mp="".get_cfg_var("jetendo_share_path")."mls-images-temp/";
$today=date("Y").'-'.date("m")."-".date("d");
if ($handle = opendir($mp)) {
    while (false !== ($entry = readdir($handle))) {
		if($entry !="." && $entry !=".."){
			if($entry != $today){
				$cmd="rm -rf ".get_cfg_var("jetendo_share_path")."mls-images-temp/".$entry."/";
				//echo $cmd."\n";
				echo "deleting ".get_cfg_var("jetendo_share_path")."mls-images-temp/".$entry."/\n";
				`$cmd`;
			}else{
				echo "NOT deleting ".get_cfg_var("jetendo_share_path")."mls-images-temp/".$entry."/\n";
			}
		}
    }

    closedir($handle);
}

echo "before temp move\n";
$mp=get_cfg_var("jetendo_share_path")."mls-data/temp/";
if ($handle = opendir($mp)) {
    while (false !== ($entry = readdir($handle))) {
		if($entry !="." && $entry !=".." && $entry != "mls-scripts"){
			if ($handle2 = opendir($mp.$entry)) {
				while (false !== ($entry2 = readdir($handle2))) {
					if($entry2 !="." && $entry2 !=".."){
						if(strpos($entry2, "-sold-") === FALSE || $entry=="20"){
							$updatedDate = filemtime($mp.$entry."/".$entry2);
							$sixtySecondsAgo= strtotime('-'.$minutesToDelayProcessing.' minutes');
							// echo $entry2." | ".$updatedDate." < ".$sixtySecondsAgo."\n";
							if ($updatedDate < $sixtySecondsAgo) {
								//$source="/home/remote-mls-data/".$entry."/".$entry2;
								$tempdest=$mp.$entry."/".$entry2;
								$dest="".get_cfg_var("jetendo_share_path")."mls-data/".$entry."/".$entry2;
								//echo file_exists($tempdest)." == ".false." || ".filesize($source)." != ".filesize($tempdest)." || ".filemtime($source)." != ".filemtime($tempdest)."\n";
								if(filesize($tempdest) == 0){// || file_exists($tempdest) == false || filesize($source) != filesize($tempdest)){// || filemtime($source) != filemtime($tempdest)){
									if(file_exists($tempdest)){
										echo "deleting: ".$tempdest."\n";
										@unlink($tempdest);
									} 
								}else{
								
									system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($tempdest));
									system("/bin/chmod 777 ".escapeshellarg($tempdest));
									$cmd="mv -f ".escapeshellarg($tempdest)." ".escapeshellarg($dest);
									echo $cmd."\n";
									`$cmd`;
									//@unlink($source);
								}
							}
						}
					}
				}
				closedir($handle2);
			}
		}
	}
    closedir($handle);
}

echo "after temp move\n";

function imagecreatefrombmp( $filename ){
 //Ouverture du fichier en mode binaire
   if (! $f1 = fopen($filename,"rb")) return FALSE;

 //1 : Chargement des ent?tes FICHIER
   $FILE = unpack("vfile_type/Vfile_size/Vreserved/Vbitmap_offset", fread($f1,14));
   if ($FILE['file_type'] != 19778) return FALSE;

 //2 : Chargement des ent?tes BMP
   $BMP = unpack('Vheader_size/Vwidth/Vheight/vplanes/vbits_per_pixel'.
                 '/Vcompression/Vsize_bitmap/Vhoriz_resolution'.
                 '/Vvert_resolution/Vcolors_used/Vcolors_important', fread($f1,40));
   $BMP['colors'] = pow(2,$BMP['bits_per_pixel']);
   if ($BMP['size_bitmap'] == 0) $BMP['size_bitmap'] = $FILE['file_size'] - $FILE['bitmap_offset'];
   $BMP['bytes_per_pixel'] = $BMP['bits_per_pixel']/8;
   $BMP['bytes_per_pixel2'] = ceil($BMP['bytes_per_pixel']);
   $BMP['decal'] = ($BMP['width']*$BMP['bytes_per_pixel']/4);
   $BMP['decal'] -= floor($BMP['width']*$BMP['bytes_per_pixel']/4);
   $BMP['decal'] = 4-(4*$BMP['decal']);
   if ($BMP['decal'] == 4) $BMP['decal'] = 0;

 //3 : Chargement des couleurs de la palette
   $PALETTE = array();
   if ($BMP['colors'] < 16777216)
   {
    $PALETTE = unpack('V'.$BMP['colors'], fread($f1,$BMP['colors']*4));
   }

 //4 : Cr?ation de l'image
   $IMG = fread($f1,$BMP['size_bitmap']);
   $VIDE = chr(0);

   $res = imagecreatetruecolor($BMP['width'],$BMP['height']);
   $P = 0;
   $Y = $BMP['height']-1;
   while ($Y >= 0)
   {
    $X=0;
    while ($X < $BMP['width'])
    {
     if ($BMP['bits_per_pixel'] == 24)
        $COLOR = unpack("V",substr($IMG,$P,3).$VIDE);
     elseif ($BMP['bits_per_pixel'] == 16)
     {  
        $COLOR = unpack("n",substr($IMG,$P,2));
        $COLOR[1] = $PALETTE[$COLOR[1]+1];
     }
     elseif ($BMP['bits_per_pixel'] == 8)
     {  
        $COLOR = unpack("n",$VIDE.substr($IMG,$P,1));
        $COLOR[1] = $PALETTE[$COLOR[1]+1];
     }
     elseif ($BMP['bits_per_pixel'] == 4)
     {
        $COLOR = unpack("n",$VIDE.substr($IMG,floor($P),1));
        if (($P*2)%2 == 0) $COLOR[1] = ($COLOR[1] >> 4) ; else $COLOR[1] = ($COLOR[1] & 0x0F);
        $COLOR[1] = $PALETTE[$COLOR[1]+1];
     }
     elseif ($BMP['bits_per_pixel'] == 1)
     {
        $COLOR = unpack("n",$VIDE.substr($IMG,floor($P),1));
        if     (($P*8)%8 == 0) $COLOR[1] =  $COLOR[1]        >>7;
        elseif (($P*8)%8 == 1) $COLOR[1] = ($COLOR[1] & 0x40)>>6;
        elseif (($P*8)%8 == 2) $COLOR[1] = ($COLOR[1] & 0x20)>>5;
        elseif (($P*8)%8 == 3) $COLOR[1] = ($COLOR[1] & 0x10)>>4;
        elseif (($P*8)%8 == 4) $COLOR[1] = ($COLOR[1] & 0x8)>>3;
        elseif (($P*8)%8 == 5) $COLOR[1] = ($COLOR[1] & 0x4)>>2;
        elseif (($P*8)%8 == 6) $COLOR[1] = ($COLOR[1] & 0x2)>>1;
        elseif (($P*8)%8 == 7) $COLOR[1] = ($COLOR[1] & 0x1);
        $COLOR[1] = $PALETTE[$COLOR[1]+1];
     }
     else
        return FALSE;
     imagesetpixel($res,$X,$Y,$COLOR[1]);
     $X++;
     $P += $BMP['bytes_per_pixel'];
    }
    $Y--;
    $P+=$BMP['decal'];
   }

 //Fermeture du fichier
   fclose($f1);

 return $res;
}


function processImage($filesource, $filedestination){
	global $debug;
	$source = @imagecreatefromjpeg($filesource);
	if($source===FALSE){
		$source=@imagecreatefrombmp($filesource);
		if($source===FALSE){
			echo "Deleting invalid image.";
			unlink($filesource);
			return false;
		}
	}
	if($source===FALSE){
		echo "Failed without exception, deleting source image.";
		@unlink($filesource);
		return;
	}
	$temp=".".rand(1,100000);
	
	
	$width=imagesx($source);
	if($source===FALSE && $width===FALSE){
		// don't bother cropping this file - it's not going to work well
		$temp=".".rand(1,100000);
		// imagejpeg($newImage, $filedestination.$temp,80);
		if($debug) echo "file copied instead of cropped\n";
		
		if(file_exists($filedestination)){
			unlink($filedestination);
		}
		$r=copy($filesource, $filedestination.$temp);
		if($r===FALSE){
			echo "file copied failed\n";
			return false;
		}else{
			$r=moveFile($filedestination.$temp, $filedestination);
			chmod($filedestination, 0777);
			system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($filedestination));
			if(file_exists($filesource)){
				unlink($filesource);
			}
			return true;
		}
	}
	$height=imagesy($source);
	if($width===FALSE){
		$r2=getimagesize($filesource);
		if($r2===FALSE){
			if($debug) echo "invalid image:".$filesource."\n";
			unlink($filesource);
		}
		list($width, $height)=$r2;
		if($debug) echo "fixed width:".$width."x".$height."\n";
	}
	
	$xCheck1=round($width/5);
	$yCheck1=round($height/5);
	
	if($debug) echo "\nx & y check 1:".$xCheck1."x".$yCheck1."\n";
	$xcrop=0;
	$xcrop2=0;
	$ycrop=0;
	$ycrop2=0;

	// get 
	$xmiddle=round($width/2);
	$ymiddle=round($height/2);
	if($debug) echo "\ntop search\n";
	$inc=3;
	for($i=0;$i<=$height;$i+=$inc){
		if($i==3) $inc=10;
		$rgb=@imagecolorat($source, $xmiddle, $i);
		$r = ($rgb >> 16) & 0xFF;
		$g = ($rgb >> 8) & 0xFF;
		$b = $rgb & 0xFF;
		//if($debug) echo "finding y: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
		$rgb2=@imagecolorat($source, max(1,$xmiddle-$xCheck1), $i);
		$rgb3=@imagecolorat($source, min($width,$xmiddle+$xCheck1), $i);
		$rgb4=@imagecolorat($source, max(1,$xmiddle-$xCheck1), $i);
		$rgb5=@imagecolorat($source, min($width,$xmiddle+$xCheck1), $i);
		
		if($debug) echo "finding y: ".$rgb." | ".$rgb2." | ".$rgb3." | ".$rgb4." | ".$rgb5."\n";
		if(($rgb+$rgb2+$rgb3+$rgb4+$rgb5)/5 < 16400000){
		//if($rgb<16600000 || $rgb2<16600000 || $rgb3<16600000 || $rgb4<16600000 || $rgb5<16600000){
			$ycrop=$i+6;
			$newi=$i;
			$i=max(0,$i-9);
			for($i;$i<=$newi;$i++){
				if($debug) echo $i." | refining y: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
				$rgb=@imagecolorat($source, $xmiddle, $i);
				if($rgb<16600000){
					if($debug) echo "final i:".$i."\n";
					$ycrop=$i+6;
					break;
				}
			}
			break;
		}
	}
	
	if($debug) echo "ycrop:".$ycrop."\n";
	if($debug) echo "\nleft search\n";
	$inc=3;
	for($i=0;$i<=$width;$i+=$inc){
		if($i==3) $inc=10;
		$rgb=@imagecolorat($source, $i, $ymiddle);
		$r = ($rgb >> 16) & 0xFF;
		$g = ($rgb >> 8) & 0xFF;
		$b = $rgb & 0xFF;
		//if($debug) echo "finding x: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
		$rgb2=@imagecolorat($source, $i, max(1,$ymiddle-$yCheck1));
		$rgb3=@imagecolorat($source, $i, min($height,$ymiddle+$yCheck1));
		$rgb4=@imagecolorat($source, $i, max(1,$ymiddle-$yCheck1));
		$rgb5=@imagecolorat($source, $i,min($height,$ymiddle+$yCheck1));
		if($debug) echo "finding x: ".$rgb." | ".$rgb2." | ".$rgb3." | ".$rgb4." | ".$rgb5."\n";
		if(($rgb+$rgb2+$rgb3+$rgb4+$rgb5)/5 < 16400000){
		//if($rgb<16600000 || $rgb2<16600000 || $rgb3<16600000 || $rgb4<16600000 || $rgb5<16600000){
			$xcrop=$i+6;
			$newi=$i;
			$i=max(0,$i-9);
			for($i;$i<=$newi;$i++){
				if($debug) echo $i." | refining x: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
				$rgb=@imagecolorat($source, $i, $ymiddle);
				if($rgb<16600000){
					if($debug) echo "final i:".$i."\n";
					$xcrop=$i+6;
					break;
				}
			}
			break;
		}
	}
	
	if($debug) echo "xcrop:".$xcrop."\n";
	
	if($debug) echo "\nbottom search\n";
	$inc=3;
	$i=1;
	/*if($ycrop > 50){
		$i=50;
		$inc=10;	
	}*/
	for(;$i<=$height;$i+=$inc){
		if($i==3) $inc=10;
		$rgb=@imagecolorat($source, $width-$xmiddle, $height-$i);
		$r = ($rgb >> 16) & 0xFF;
		$g = ($rgb >> 8) & 0xFF;
		$b = $rgb & 0xFF;
		//if($debug) echo "finding y: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
		$rgb2=@imagecolorat($source, max(1,($width-$xmiddle)-$xCheck1), $height-$i);
		$rgb3=@imagecolorat($source, min($width,($width-$xmiddle)+$xCheck1), $height-$i);
		$rgb4=@imagecolorat($source, max(1,$xmiddle-$xCheck1), $height-$i);
		$rgb5=@imagecolorat($source, min($width,$xmiddle+$xCheck1), $height-$i);
		if($debug) echo "finding y: ".$rgb." | ".$rgb2." | ".$rgb3." | ".$rgb4." | ".$rgb5."\n";
		if(($rgb+$rgb2+$rgb3+$rgb4+$rgb5)/5 < 16400000){
		//if($rgb<16600000 || $rgb2<16600000 || $rgb3<16600000 || $rgb4<16600000 || $rgb5<16600000){
			$ycrop2=$i+6;
			$newi=$i;
			$i=max(1,$i-9);
			for($i;$i<$newi;$i++){
				if($debug) echo $i." | refining y: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
				$rgb=@imagecolorat($source, $width-$xmiddle, $height-$i);
				if($rgb<16600000){
					if($debug) echo "final i:".$i."\n";
					$ycrop2=$i+6;
					break;
				}
			}
			break;
		}
	}
	if($debug) echo "ycrop2:".$ycrop2."\n";
	
	if($debug) echo "\nright search\n";
	$inc=3;
	for($i=1;$i<=$width;$i+=$inc){
		if($i==3) $inc=10;
		$rgb=@imagecolorat($source, $width-$i, $height-$ymiddle);
		$r = ($rgb >> 16) & 0xFF;
		$g = ($rgb >> 8) & 0xFF;
		$b = $rgb & 0xFF;
		//if($debug) echo "finding x: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
		$rgb2=@imagecolorat($source, $width-$i, max(1,($height-$ymiddle)-$yCheck1));
		$rgb3=@imagecolorat($source, $width-$i, min($height,($height-$ymiddle)+$yCheck1));
		$rgb4=@imagecolorat($source, $width-$i, max(1,($height-$ymiddle)-$yCheck1));
		$rgb5=@imagecolorat($source, $width-$i, min($height,($height-$ymiddle)+$yCheck1));
		if($debug) echo "finding x: ".$rgb." | ".$rgb2." | ".$rgb3." | ".$rgb4." | ".$rgb5."\n";
		if(($rgb+$rgb2+$rgb3+$rgb4+$rgb5)/5 < 16400000){
		//if($rgb<16600000 || $rgb2<16600000 || $rgb3<16600000 || $rgb4<16600000 || $rgb5<16600000){
			$xcrop2=$i+6;
			$newi=$i;
			$i=max(1,$i-9);
			for($i;$i<=$newi;$i++){
				if($debug) echo $i." | refining x: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
				$rgb=@imagecolorat($source, $width-$i, $height-$ymiddle);
				if($rgb<16600000){
					if($debug) echo "final i:".$i."\n";
					$xcrop2=$i+6;
					break;
				}
			}
			break;
		}
	}
	if($debug) echo "xcrop2:".$xcrop2."\n";
	if($debug) echo "Crop coordinates: left:".$xcrop." top:".$ycrop." right:".$xcrop2." bottom:".$ycrop2."\n";
	
	
	$originalheight=$height;
	$originalwidth=$width;
	if($debug) echo "original size:".$width."x".$height."\n";
	$width=$width-$xcrop-$xcrop2;
	$height=$height-$ycrop-$ycrop2;
	if($height < 10 || $width < 10){
		// prevent mistakes
		if(abs($xcrop-$xcrop2) > 50){
			$xcrop=min($xcrop, $xcrop2);
		}else{
			$xcrop=max($xcrop, $xcrop2);
		}
		if(abs($ycrop-$ycrop2) > 50){
			$ycrop=min($ycrop, $ycrop2);
		}else{
			$ycrop=max($ycrop, $ycrop2);
		}
		$width=($originalwidth-($xcrop*2));
		$height=($originalheight-($ycrop*2));
		if($width < 10 || $height < 10){
			// don't bother cropping this file - it's not going to work well
			
			if($debug) echo "width is wrong:".$width."x".$height."\n";
			if($debug) echo $filedestination.$temp.":".file_exists($filedestination.$temp)."\n";
			
			$r3=imagejpeg($source, $filedestination.$temp,80);
			
			$r=moveFile($filedestination.$temp, $filedestination);
			if($r===FALSE){
				echo "r3:".$r3."\nexists:".file_exists($filedestination.$temp)."\n";
				echo "unable to copy file even without cropping it\n";
				return false;
			}else{
				chmod($filedestination, 0777);
				system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($filedestination));
				if(file_exists($filesource)){
					unlink($filesource);
				}
				return true;
			}
		}
			
	}
	if($debug) echo "cropped original size:".$width."x".$height."\n";
		
	$newImage= imagecreatetruecolor($width, $height);
	
	imagecopy ( $newImage , $source, 0,0, $xcrop, $ycrop, $width , $height );
	
	imagejpeg($newImage, $filedestination.$temp,80);
	
	$r=moveFile($filedestination.$temp, $filedestination);
	if($r===FALSE){
		return false;
	}else{
		chmod($filedestination, 0777);
		system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($filedestination));
		if(file_exists($filesource)){
			unlink($filesource);
		}
		return true;
	}
}


function moveFile($source, $destination){
	if(file_exists($destination)){
		unlink($destination);
	}
	return rename($source, $destination);
}

function processFiles($arrSQL, $arrF, $arrFID, $arrFID2, $arrFD, $arrFN){
	global $cmysql, $debug, $mysqldate, $mlsDatasource;
	$sql="select mls_image_hash_mlsid, mls_image_hash_value FROM mls_image_hash WHERE mls_image_hash_mlsid IN ('".implode("','", $arrFID)."') ";//and mls_image_hash_datetime < '2012-10-19 15:00:00' ";
	
	$arrIdNew=array();
	$renameEnabled=false;
	if(is_array($arrSQL)){
		$renameEnabled=true;
		// get the 
		// echo "renaming\n";
		if(!$cmysql->select_db($arrSQL[1])){
			echo "failed to select db:".$arrSQL[1]."\n";
			return false;
		}
		$sql2=$arrSQL[0].implode("','", $arrFID2)."') ";
		// echo $sql2."\n";
		$r=$cmysql->query($sql2, MYSQLI_USE_RESULT);
		if($cmysql->error != ""){ 
			echo "db error:".$cmysql->error."\n";
			return false;
		}
		while($row=$r->fetch_array(MYSQLI_NUM)){
			$arrIdNew[$row[0]]=$row[1];
		}
		if(!$cmysql->select_db($mlsDatasource)){
			echo "failed to select db:".$mlsDatasource."\n";
			return false;
		}
	}else{
		// echo "not renaming\n";
	}
	$r=$cmysql->query($sql, MYSQLI_USE_RESULT);
	if($cmysql->error != ""){ 
		echo "db error:".$cmysql->error."\n";
		return false;
	}
	$arrNew=array();
	while($row=$r->fetch_array(MYSQLI_NUM)){
		$arrNew[$row[0]]=$row[1];
	}
	$c=count($arrF);
	$arrV=array();
	
	
	for($i=0;$i<$c;$i++){
		if($renameEnabled){
			if(!isset($arrIdNew[$arrFID2[$i]])){
				// record doesn't exist in database, leave it in the temporary folder
				continue;
			}
		}
		$filedestination=$arrFD[$i];
		$filesource=$arrF[$i];
		$newHash=@md5_file($filesource);
		if($newHash===FALSE){
			continue;
		}
		$crop=false;
		
		$temp=".".rand(1,100000);
				
		
		$rpos=strrpos($filedestination, "/")+1;
		$fname=substr($filedestination, $rpos);
		if($renameEnabled){
			if(substr_count($fname, "-") == 1){
				$fname=$arrIdNew[$arrFID2[$i]].substr($fname, strpos($fname, "-"));
			}
		}
		$md5name=md5($fname);
		$fpath=substr($filedestination, 0, $rpos).substr($md5name,0,2)."/".substr($md5name,2,1)."/";
		if(!is_dir($fpath)){
			mkdir($fpath, 0777, true);
		}
		$filedestination=$fpath.$fname;
		
		//substr($newHash,0,2)."/".substr($newHash,2,1)."/";
		if(isset($arrNew[$arrFID[$i]])){
			// we have an existing hash	
			$oldHash=$arrNew[$arrFID[$i]];
			if($oldHash != $newHash){
				// must update database and crop the new image.
				$crop=true;
				echo 'hash don\'t match, crop and store: '.$arrFID[$i]."\n";
			}else{
				if(file_exists($filedestination)){
					/*if(md5_file($filedestination) != $newHash){
						echo 'existed but has to crop and store again:'.$arrFID[$i]."\n";
						$crop=true;
					}else{*/
						echo "deleting from remote-images: ".$arrFID[$i]."\n";
						unlink($filesource);
					//}
				}else{
					echo 'not exist - crop and store: '.$filedestination." | ".$arrFID[$i]."\n";
					$crop=true;
				}
			}
		}else{
			// new file, crop and store it!
			echo 'new file crop and store: '.$arrFID[$i]."\n";
			$crop=true;
		}
		//echo " | did i crop: ". $filesource."\noldHash:".$arrNew[$arrFID[$i]]."\nnewHash:".$newHash."\n";
		//var_dump($crop);
		//exit;
		/*if($arrFID[$i] == "4-cropme.jpg"){
			$crop=true;
		}*/
		if($crop){
			// read image, crop and store
			if(substr($filedestination, strlen($filedestination)-4, 4) == ".pdf"){
				echo "moving: ".$arrFID[$i]."\n";
				
				$r=moveFile($filesource, $filedestination);
				if($r===FALSE){
					echo "non image copy failed.  Source: ".$filesource." Source ID: ".$arrFID[$i]." Destination: ".$filedestination;
					return false;
				}else{
					chmod($filedestination, 0777);
					system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($filedestination));
					array_push($arrV, "('".$arrFID[$i]."','".$newHash."', '".$mysqldate."')");
				}
				
			}else{
				echo "cropping: ".$arrFID[$i]."\n";
				$r=processImage($filesource, $filedestination);
				usleep(40000);
				if($r===FALSE){
					echo "processImage() failed.  Source: ".$filesource." Source ID: ".$arrFID[$i]." Destination: ".$filedestination;
					return false;
				}else{
					array_push($arrV, "('".$arrFID[$i]."','".$newHash."', '".$mysqldate."')");
				}
			}
		}
	}
	if(count($arrV) != 0){
		$sql2="INSERT INTO mls_image_hash (mls_image_hash_mlsid, mls_image_hash_value, mls_image_hash_datetime) VALUES ".implode(", ", $arrV)." ON DUPLICATE KEY UPDATE mls_image_hash_value=VALUES(mls_image_hash_value), mls_image_hash_datetime=VALUES(mls_image_hash_datetime)";
		$r=$cmysql->query($sql2);
		if($r===FALSE){
			echo "Critical mysql failure:".$cmysql->error;
			return false;
		}
	}
	return true;
}



function getRets7SysId(){
	global $mlsDataDatasource;
	return array("select SQL_NO_CACHE rets7_sysid as imageid, rets7_175 as listingid from rets7_property where rets7_sysid IN ('", $mlsDataDatasource);
}
function getRets12SysId(){
	global $mlsDataDatasource;
	return array("select SQL_NO_CACHE rets12_sysid as imageid, rets12_157 as listingid from rets12_property where rets12_sysid IN ('", $mlsDataDatasource);
}
function getRets16SysId(){
	global $mlsDataDatasource;
	return array("select SQL_NO_CACHE rets16_sysid as imageid, rets16_157 as listingid from rets16_property where rets16_sysid IN ('", $mlsDataDatasource);
}
function getRets18SysId(){
	global $mlsDataDatasource;
	echo "18 is not tested.";
	exit;
	//return array("select rets18_media.rets18_mediasource as id from rets18_property, rets18_media WHERE rets18_mediatype='pic' and rets18_media.rets18_tableuid = rets18_property.rets18_uid and concat('18-',rets18_property.rets18_mlsnum) IN ('", $mlsDataDatasource);
}
function getRets20SysId(){
	global $mlsDataDatasource;
	return array("select SQL_NO_CACHE rets20_matrix_unique_id as imageid, rets20_mlsnumber as listingid from rets20_property where rets20_matrix_unique_id IN ('", $mlsDataDatasource);
}
function getRets22SysId(){
	global $mlsDataDatasource;
	return array("select SQL_NO_CACHE rets22_list_1 as imageid, rets22_list_105 as listingid from rets22_property where rets22_list_1 IN ('", $mlsDataDatasource);
}

$arrQueryFunction=array();
$arrQueryFunction["7"]="getRets7SysId";
$arrQueryFunction["12"]="getRets12SysId";
$arrQueryFunction["16"]="getRets16SysId";
//$arrQueryFunction["18"]="getRets18SysId";
$arrQueryFunction["20"]="getRets20SysId";
$arrQueryFunction["22"]="getRets22SysId";


echo "\ndelete runningFilePath before image processing:".$runningFilePath."\n";
unlink($runningFilePath);

//exit;

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
							/*if($iCount1 > 200){
								// take a break
								$stopProcessing=true;
								echo "Stopping early\n";
								break;
							}*/
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
		$message = 'PHP move-mls-images.php stopped processing';

		mail($to, $subject, $message, $headers);
	}else if(count($arrF) != 0){
		processFiles($arrSQL, $arrF, $arrFID, $arrFID2, $arrFD, $arrFN);
	}
    closedir($handle);
}

echo "\ndelete:".$runningFilePath."\n";
@unlink($runningFilePath);

?>