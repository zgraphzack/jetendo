<?php

require(get_cfg_var("jetendo_scripts_path")."library.php");
set_time_limit (60 * 60); // 1 hour timeout for video encoding task

$testDomain=get_cfg_var("jetendo_test_domain"); 
$sitesWritablePath=get_cfg_var("jetendo_sites_writable_path");

$timeout=60; // seconds
$time_start = microtime_float();

$host=`hostname`;
if(strpos($host, get_cfg_var("jetendo_test_domain")) !== FALSE){
	// test server
	$testserver=true;
}else{
	$testserver=false;
}
mysql_connect(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"),get_cfg_var("jetendo_mysql_default_password"));

mysql_select_db(zGetDatasource());
			
$logDir=get_cfg_var("jetendo_log_path");
if($logDir !== FALSE && $logDir != ""){
	$logDir=get_cfg_var("jetendo_log_path").'zqueue/';
	if(!is_dir($logDir)){
		mkdir($logDir, 0700);
	}
	if(!is_dir($logDir.'complete/')){
		mkdir($logDir.'complete/', 0700);
	}
	if(!is_dir($logDir.'original/')){
		mkdir($logDir.'original/', 0700);
	}
}

for($i101=0;$i101<70;$i101++){

	// get a running queue entry
	$sql="select * from queue where queue_status = '1' and queue_deleted = '0' ";
	$r=mysql_query($sql);
	$c=mysql_num_rows($r);
	if($c==0){
		// none running, find a new one to run	
		$sql="select * from queue where  queue_status='0' and queue_deleted = '0'  order by queue_id asc limit 0,1";
		$r=mysql_query($sql);
		$c=mysql_num_rows($r);
	}
	if($c==0){
		// all done, do nothing
		sleep(1);
		continue;
	}else{
		$row=mysql_fetch_object($r);
		$sql="select * from site where site_active = '1' and site_id = '".$row->site_id."'";
		$qSite=mysql_query($sql);
		$count=mysql_num_rows($qSite);
		if($count == 0){
			$sql="update queue set queue_progress='0',queue_status='2', queue_updated_datetime='".date('Y-m-d H:i:s')."', queue_error='site_id is not an active site.' where site_id ='".$row->site_id."' and queue_id='".$row->queue_id."'";
			mysql_query($sql);
			fclose($fp);
			continue;
		}
		$siteRow=mysql_fetch_object($qSite);
		$thedomainpath=str_replace("www.", "", str_replace(".".$testDomain, "", $siteRow->site_short_domain));
		$siteInstallPath=$sitesWritablePath.str_replace(".","_",$thedomainpath)."/";
		
		$originalPath=get_cfg_var("jetendo_root_path").$row->queue_original_file;
		
		if(substr($originalPath, 0, strlen($siteInstallPath."zupload/video/")) != $siteInstallPath."zupload/video/"){
			fwrite($fp, "Error: queue_original_file must be in ".$siteInstallPath."zupload/video/ - security breach attempt.\n");
			$sql="update queue set queue_progress='0',queue_status='2', queue_updated_datetime='".date('Y-m-d H:i:s')."', queue_error='queue_original_file must be in ".mysql_real_escape_string($siteInstallPath)."zupload/video/ - security breach attempt' where site_id ='".$row->site_id."' and queue_id='".$row->queue_id."'";
			mysql_query($sql);
			fclose($fp);
			continue;
		}
		if(strpos(substr($originalPath, strlen($siteInstallPath."zupload/video/")), "/") !== FALSE){
			fwrite($fp, "Error: queue_original_file must be in ".$siteInstallPath."zupload/video/, not in a subfolder - security breach attempt.\n");
			$sql="update queue set queue_progress='0',queue_status='2', queue_updated_datetime='".date('Y-m-d H:i:s')."', queue_error='queue_original_file must be in ".mysql_real_escape_string($siteInstallPath)."zupload/video/, not in a subfolder - security breach attempt' where site_id ='".$row->site_id."' and queue_id='".$row->queue_id."'";
			mysql_query($sql);
			fclose($fp);
			continue; 
		}
		$outputPath=$logDir.'complete/'.$row->queue_file;
		$logPhpPath=$logDir.$row->queue_file."-php-log.txt";
		$logPath=$logDir.$row->queue_file."-handbrakecli-log.txt";
		$fp=fopen($logPhpPath, "w");
		
		if(!file_exists($originalPath)){ 
			fwrite($fp, "queue_original_file doesn't exist.\n");
			$sql="update queue set queue_progress='0',queue_status='2', queue_updated_datetime='".date('Y-m-d H:i:s')."', queue_error='queue_original_file doesn\'t exist.' where site_id ='".$row->site_id."' and queue_id='".$row->queue_id."'";
			mysql_query($sql);
			fclose($fp);
			continue;
		}
		if($row->queue_file==""){
			fwrite($fp, "Queue_file can't be empty and it must be a unique filename.\n");
			$sql="update queue set queue_status='2', queue_updated_datetime='".date('Y-m-d H:i:s')."', queue_error='queue_file can\'t be empty and it must be a unique filename' where site_id ='".$row->site_id."' and queue_id='".$row->queue_id."'";
			mysql_query($sql);
			fclose($fp);
			continue;
		}
		if(file_exists($outputPath)){
			$r=`pidof HandBrakeCLI`;
			if($r != ""){
				`kill -9 $r`;	
				fwrite($fp, "HandBrakeCLI was found running with pid $r, and the process was killed.\n");
			}
			@unlink($outputPath);
			fwrite($fp, "queue_file already existed,and the file was automatically deleted so that it can be re-processed again now.\n");
		}
		if(!is_numeric($row->queue_width) || !is_numeric($row->queue_height) || $row->queue_width < 100 || $row->queue_height < 100){
			fwrite($fp, "Error: queue_width and queue_height must be a valid number greater or equal to 100 x 100.\n");
			$sql="update queue set queue_progress='0',queue_status='2', queue_updated_datetime='".date('Y-m-d H:i:s')."', queue_error='queue_width and queue_height must be a valid number greater or equal to 100 x 100.' where site_id ='".$row->site_id."' and queue_id='".$row->queue_id."'";
			mysql_query($sql);
			fclose($fp);
			continue;
		}
		fwrite($fp, "Running queue id #".$row->queue_id."\n");
		$sql="update queue set queue_progress='0',queue_status='1', queue_updated_datetime='".date('Y-m-d H:i:s')."', queue_run_datetime='".date('Y-m-d H:i:s')."' where site_id ='".$row->site_id."' and queue_id='".$row->queue_id."'";
		mysql_query($sql);
		// do the long command
		// -B is audio biterate
		
		
		// this can be used for cropping: --crop <T:B:L:R>  - but i'd have to take image previews to calculate this correctly.
		// https://trac.handbrake.fr/wiki/CLIGuide
		$encodeCmd='nice -n 15 /usr/bin/HandBrakeCLI -i '.escapeshellarg($originalPath).' -o '.escapeshellarg($outputPath).'  -e x264 -O -q 20.0 -a 1,1 -E faac,copy:ac3 -B 160,160 -6 dpl2,auto -R Auto,Auto -D 0.0,0.0 -f mp4 -X '.$row->queue_width.' -Y '.$row->queue_height.' --loose-anamorphic -m -x cabac=0:ref=2:me=umh:bframes=0:weightp=0:8x8dct=0:trellis=0:subme=6  2>&1 > '.escapeshellarg($logPath);
		
		fwrite($fp, $encodeCmd."\n\n");
		$r=`$encodeCmd`;
		fwrite($fp, $r."\n");
		$sql2="select * from queue where site_id ='".$row->site_id."' and queue_id ='".$row->queue_id."' and queue_deleted = '0' ";
		$r2=mysql_query($sql2);
		$c2=mysql_num_rows($r2);
		if($c2 == 0){
			continue;
		}else if(preg_replace("/Rip done!/","",$r) != $r){
			// failed with error	
			fwrite($fp, "Error: \"rip done\" not found after running HandBrakeCLI video encoding command line. \n");
			$sql="update queue set queue_status='2', queue_error='\"rip done\" not found after running HandBrakeCLI video encoding command line.  Result:".mysql_real_escape_string($r)."' where site_id ='".$row->site_id."' and queue_id='".$row->queue_id."'";
			mysql_query($sql);
		}else{
			$r2=explode("/",get_cfg_var("jetendo_root_path").$row->queue_original_file);
			
			if(file_exists($outputPath) === FALSE){
				fwrite($fp, "Error: The encoder was run, but failed without publishing a file.  The uploaded video may be an unsupported format.\n");
				$sql="update queue set queue_status='2', queue_updated_datetime='".date('Y-m-d H:i:s')."', queue_error='The encoder was run, but failed without publishing a file.  The uploaded video may be an unsupported format.' where site_id ='".$row->site_id."' and queue_id='".$row->queue_id."'";
				mysql_query($sql);
				fclose($fp);
				continue;
			}
			array_pop($r2);
			$newFilePath=implode("/",$r2)."/";
			$newFileName=$row->queue_id."-".$row->queue_hash.".mp4";
			echo $newFileName."\n";
			$i9=1;
			while(file_exists($newFilePath.$newFileName)){
				$newFileName=$row->queue_id."-".$row->queue_hash."-".$i9.".mp4";
				$i9++;
			}
			fwrite($fp, "Running ffmpeg for queue_id = '.$row->queue_id.");
			$cmd="/usr/bin/ffmpeg -i ".escapeshellarg($outputPath)." -r 0.05 -f image2 ".escapeshellarg($newFilePath.$newFileName."-%05d.jpg")." 2>&1";
			fwrite($fp, $cmd."\n");
			$r99=`$cmd`;
			fwrite($fp, $r99."\n");
			$cmd="/bin/mv ".escapeshellarg($outputPath)." ".escapeshellarg($newFilePath.$newFileName)."";
			fwrite($fp, $cmd."\n");
			$r5=`$cmd`;
			fwrite($fp, $r5."\n");
			//$cmd="chcon -t httpd_user_content_t ".escapeshellarg($newFilePath.$newFileName)."";
			//$r5=`$cmd`; 
			
			$p=$newFilePath;
			$f=$newFileName;
			$queue_id=$row->queue_id;
			$g1=1;
			//echo "color checker and thumb count<br>";
			$a=array();
			$queue_thumb_count=0;
			$queue_seconds_length=0;
			$queue_width="0";
			$queue_height="0";
			while(true){

				$curF=$p.$f."-".str_pad($g1, 5, "0", STR_PAD_LEFT).".jpg";
				if(file_exists($curF) == false){
					$g1--;
					$i2=1;
					for($i=1;$i<=$g1;$i++){
						// remove monochrome images - rename the rest to have no number gap
						$curF2=$p.$f."-".str_pad($i, 5, "0", STR_PAD_LEFT).".jpg";
						$curF3=$p.$f."-".str_pad($i2, 5, "0", STR_PAD_LEFT).".jpg";
						if(isset($a[$i])){
							//echo "deleting: ".$curF2."<br>";
							fwrite($fp, "deleting existing image: ".$curF2."\n");
							@unlink($curF2);
						}else{
							if($i != $g1){
								$i2++;	
							}
							if($curF2 != $curF3){
								$cmd="mv \"$curF2\" \"$curF3\"";
								`$cmd`;
							}
						}
					}
					$cmd="/usr/bin/ffmpeg -i ".escapeshellarg($p.$f)." 2>&1 | grep \"Stream #0.0(und): Video:\""; 
					fwrite($fp, $cmd."\n");
					$r=`$cmd`;
					fwrite($fp, $r."\n");
					if($r != ""){
						$p1=strpos($r, "p, ");
						$p2=strpos($r, "[PAR", $p1);
						if($p!==FALSE && $p2 !==FALSE){
							$widthHeight=substr($r, $p1+3, $p2-($p1+1)-3);
							$a9=explode("x",$widthHeight);
							$queue_width=$a9[0];
							$queue_height=$a9[1];
						}
					}
					// echo "queue_width='".$queue_width."', queue_height='".$queue_height."'";
					$cmd="/usr/bin/ffmpeg -i ".escapeshellarg($p.$f)." 2>&1 | grep \"Duration\" | cut -d ' ' -f 4 | sed s/,//";
					fwrite($fp, $cmd."\n"); 
					$r=`$cmd`;
					fwrite($fp, $r."\n");
					$queue_seconds_length=0;
					if($r != ""){
						$a1=explode(".", $r);	
						$a1=explode(":",$a1[0]);
						$queue_seconds_length=($a1[0]*60*60)+($a1[1]*60)+($a1[2]);
					}
					$queue_thumb_count=$i2; 
					break;
				}
				
				list($width, $height) = getimagesize($curF);
				$source = imagecreatefromjpeg($curF);
				
				$checkSize=15;
				
				$thumb = imagecreatetruecolor($checkSize,$checkSize);
				
				imagecopyresampled($thumb, $source, 0, 0, 0,0, $checkSize, $checkSize, $width, $height);
				$b=-1;
				$t=-1;
				
				for($i=1;$i<$checkSize-1;$i++){
					for($i2=1;$i2<$checkSize-1;$i2++){
						$c=imagecolorat($thumb, $i, $i2);
						if($b==-1){
							$b=$c;
							$t=$c;
						}
						if($c < $b){
							$b=$c;
						}
						if($c > $t){
							$t=$c;
						}
					}
				}
				if($t-$b < 150000){ 
					$a[$g1]=true;
				}
				$g1++;
			}
			$cmd="chown -R nginx. $newFilePath*";
			$r=`$cmd`;
			fwrite($fp, $cmd."\n"); 
			fwrite($fp, $r."\n"); 
			if($testserver){
				$cmd="chmod -R 777 $newFilePath*"; 
			}else{
				$cmd="chmod -R 660 $newFilePath*";
			}
			$r=`$cmd`;
			fwrite($fp, $cmd."\n"); 
			fwrite($fp, $r."\n"); 
			$sql="update queue set queue_width='".$queue_width."', queue_height='".$queue_height."', queue_thumb_count='".$queue_thumb_count."', queue_seconds_length='".$queue_seconds_length."', queue_progress='100', queue_status='3', queue_updated_datetime='".date('Y-m-d H:i:s')."', queue_error='' where site_id ='".$row->site_id."' and queue_id='".$row->queue_id."'";
			mysql_query($sql);
			fwrite($fp, "Video encoding completed\n");
			fclose($fp);
		}
	}
	if(microtime_float() - $time_start > $timeout-3){
		echo "Timeout reached";
		exit;
	}
}
?>