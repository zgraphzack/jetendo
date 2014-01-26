<?php
require('library.php');

function exitWithLogNotification(){
	global $arrError, $logDir, $preview;
	$host=`hostname`;
	$serverSecurePath=get_cfg_var("jetendo_root_private_path"); 
	if(count($arrError)){
		$arrNewError=array();
		if($serverSecurePath !=""){
			if(substr($serverSecurePath, strlen($serverSecurePath)-1, 1) != "/"){
				$serverSecurePath.="/";
			}
			if(file_exists($serverSecurePath."verifySitesLog.txt")){
				$contents=file_get_contents($serverSecurePath."verifySitesLog.txt");
				$arrCurrentLog=explode("\n", trim($contents));
				for($i=0;$i<count($arrError);$i++){
					$found=false;
					for($i2=0;$i2<count($arrCurrentLog);$i2++){
						if(trim($arrCurrentLog[$i2]) == trim($arrError[$i])){
							$found=true;
							break;
						}
					}
					if(!$found){
						array_push($arrNewError, $arrError[$i]);
					}
				}
			}else{
				$arrNewError=$arrError;
			}
			$fp=fopen($serverSecurePath.'verifySitesLog.txt', "w");
			fwrite($fp, implode("\n", $arrError));
			fclose($fp);
			chown($serverSecurePath.'verifySitesLog.txt', get_cfg_var("jetendo_www_user"));
			chgrp($serverSecurePath.'verifySitesLog.txt', get_cfg_var("jetendo_www_user"));
			chmod($serverSecurePath.'verifySitesLog.txt', 0660);
		}
		if(count($arrNewError)){

			$to      = get_cfg_var('jetendo_developer_email_to');
			$subject = 'Verify sites had new errors on '.$host;

			$headers = 'From: '.get_cfg_var('jetendo_developer_email_from')."\r\n" .
				'Reply-To: '.get_cfg_var('jetendo_developer_email_from')."\r\n" .
				'X-Mailer: PHP/' . phpversion();
			$message = "Errors found when running the verify sites task.\n\nPlease note that items with \"seal-healing notice\" require no further action, but items with \"Attention required\" must be reviewed and fixed manually.\n\n".implode("\n", $arrNewError);

			mail($to, $subject, $message, $headers);
		}
		echo count($arrNewError)." new errors.\n\n";
		for($i=0;$i<count($arrError);$i++){
			echo($arrError[$i]."\n");
		}
	}else{
		if($serverSecurePath != ""){
			@unlink($serverSecurePath.'verifySitesLog.txt');
		}
		echo('No errors found');	
	} 
	exit;
}
function verifySite($row){
	global $cmysql2, $forcePermissions, $userStruct, $preview, $verifyHomePage, $userUnusedStruct, $isTestServer, $pathStruct, $checkDNS, $dnsServer, $wwwUser, $sitesPath, $ftpEnabled;
	$siteHomedir=zGetDomainInstallPath($row["site_short_domain"]);
	$siteHomedirWritable=zGetDomainWritableInstallPath($row["site_short_domain"]);
	$siteHasError=false;
	$found=false;
	$arrError=array();
	$debug=false;
	if($row["site_active"] == 1){ 
		$time_start = microtime_float();
		echo "Verifying: ".$siteHomedir.": ";
		unset($pathStruct[$siteHomedir]);
		if(substr($siteHomedir, 0, strlen($sitesPath)) != $sitesPath){
			$siteHasError=true;
			array_push($arrError, $siteHomedir." is not inside the installPath: ".$sitesPath." and it must be.");	
		}else if(!is_dir($siteHomedir)){
			$siteHasError=true;
			array_push($arrError, "Self-healing notice: ".$siteHomedir." didn't exist, and was created now. ");	
			if(!$preview){
				mkdir($siteHomedir);
			}
		}
		$result=zCheckDirectoryPermissions($siteHomedir, get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "440", "550", true, $preview, $arrError, $isTestServer);
		if(!$result){
			$siteHasError=true;
		}
		$result=zCheckDirectoryPermissions($siteHomedirWritable, get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", false, $preview, $arrError, $isTestServer);
		if(!$result){
			$siteHasError=true;
		}
		$result=zCheckDirectoryPermissions($siteHomedirWritable."zcache/", get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", false, $preview, $arrError, $isTestServer);
		if(!$result){
			$siteHasError=true;
		}
		$result=zCheckDirectoryPermissions($siteHomedirWritable."_cache/", get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", false, $preview, $arrError, $isTestServer);
		if(!$result){
			$siteHasError=true;
		}
		$result=zCheckDirectoryPermissions($siteHomedirWritable."zupload/", get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", false, $preview, $arrError, $isTestServer);
		if(!$result){
			$siteHasError=true;
		}
		$result=zCheckDirectoryPermissions($siteHomedirWritable, get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", true, $preview, $arrError, $isTestServer);
		if(!$result){
			$siteHasError=true;
		}
		$found=true;
	}else{
		if(is_dir($siteHomedir)){
			array_push($arrError, "Attention required: ".$siteHomedir." exists, but site is inactive. You should remove these files from the server.");	
		}
		if(is_dir($siteHomedirWritable)){
			array_push($arrError, "Attention required: ".$siteHomedirWritable." exists, but site is inactive. You should remove these files from the server.");	
		}
	}
	if($debug) echo (microtime_float()-$time_start)." seconds for directory structure\n"; $time_start=microtime_float();
	$domain=str_replace("https://", "", str_replace("http://", "", $row["site_domain"]));
	$curDomain=str_replace("www.", "", $domain);
	if($checkDNS){
		if($row["site_ip_address"] == ""){
			$siteHasError=true;
			array_push($arrError, "Attention required: IP address not set for ".$row["site_short_domain"]." in the server manager.  Please set it now for DNS monitoring to function correctly.");	
		}else if($found){
			$cmd="/usr/bin/dig a +short $dnsServer $curDomain";
			$output1=trim(`$cmd`);
			$dnsLookupFailed=false;
			if($output1 == ""){
				sleep(1); // retry after 1 second because dns server FREQUENTLY failed to return a reply.
				$cmd="/usr/bin/dig a +short $dnsServer $curDomain";
				$output1=trim(`$cmd`);
				if($output1 == ""){
					$siteHasError=true;
					array_push($arrError, "Attention required: DNS for ".$row["site_short_domain"]." is missing.");	
					$dnsLookupFailed=true;
				}
			}
			if(!$dnsLookupFailed){
				$arrTemp=explode("\n", $output1);
				$ipmatch=false;
				for($i=0;$i<count($arrTemp);$i++){
					if(substr($arrTemp[$i], strlen($arrTemp[$i])-1, 1) == "."){
						// cname is ok - ignore it
					}else if($arrTemp[$i] == $row["site_ip_address"]){
						// ip matches - ignore it
						$ipmatch=true;
					}else{
						$siteHasError=true;
						array_push($arrError, "Attention required: DNS for ".$curDomain." didn't match with the site's assigned IP address or had additional records, ".$row["site_ip_address"].".  Full response:".$output1."<br />");
						break;
					}
				}
			}
			$output2="";
			if(strpos($domain, "www.") !== FALSE){

				$cmd="/usr/bin/dig a +short $dnsServer $domain";
				$output2=trim(`$cmd`);
				$dnsLookupFailed=false;
				if($output2 == ""){
					sleep(1); // retry after 1 second because dns server FREQUENTLY failed to return a reply.
					$cmd="/usr/bin/dig a +short $dnsServer $domain";
					$output2=trim(`$cmd`);
					if($output2 == ""){
						$siteHasError=true;
						array_push($arrError, "Attention required: DNS for ".$domain." is missing.");	
						$dnsLookupFailed=true;
					}
				}
				if(!$dnsLookupFailed){
					$arrTemp=explode("\n", $output2);
					$ipmatch=false;
					for($i=0;$i<count($arrTemp);$i++){
						if($arrTemp[$i] == $curDomain."."){
							// cname is ok, ignore it
						}else if($arrTemp[$i] == $row["site_ip_address"]){
							// ip matches, ignore it
							$ipmatch=true;
						}else{
							$siteHasError=true;
							array_push($arrError, "Attention required: DNS for ".$curDomain." didn't match with the site's assigned IP address or had additional records, ".$row["site_ip_address"].".  Full response:".$output2."<br />");
							break;
						}
					}
				}
			}
		}
	}
	if($debug) echo (microtime_float()-$time_start)." seconds for dns\n"; $time_start=microtime_float();
	if($debug) echo (microtime_float()-$time_start)." seconds for permissions\n"; $time_start=microtime_float();
	if($verifyHomePage){
		if($found){
			$rs=file_get_contents($row["site_domain"]."/");
			if($rs === FALSE){
				if(substr($row["site_domain"], 0, 5) == "https"){
					$rs=file_get_contents(str_replace("http:", "https:", $row["site_domain"])."/");
					if($rs === FALSE){
						array_push($arrError, "Requires attention: Failed to download home page: ".$row["site_domain"]."/");
						$siteHasError=true;
					}
				}
			}
			if($debug) echo (microtime_float()-$time_start)." seconds for home page download\n"; $time_start=microtime_float();
		}
	}
	if($siteHasError){
		echo "invalid\n";
		for($i=0;$i<count($arrError);$i++){
			echo $arrError[$i]."\n";
		}
		echo "\n";
	}else{
		if(!$preview){
			$cmysql2->query("update site set 
			site_verified_datetime=now()
			WHERE 
			site_id = '".$cmysql2->real_escape_string($row["site_id"])."'");
		}
		echo "valid\n";
	}
	return $arrError;
}


function checkFilesystem(){
	global $arrError, $wwwUser, $isTestServer, $preview;

	$dir=get_cfg_var("jetendo_root_path");
	$result=zCheckDirectoryPermissions($dir, "root", "root", "755", "755", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."core/", $wwwUser, $wwwUser, "440", "550", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."public/", $wwwUser, $wwwUser, "440", "550", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."execute/", $wwwUser, $wwwUser, "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."execute/start/", $wwwUser, $wwwUser, "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."execute/complete/", $wwwUser, $wwwUser, "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."railovhosts/", $wwwUser, $wwwUser, "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."themes/", $wwwUser, $wwwUser, "440", "550", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."phptemp/", $wwwUser, $wwwUser, "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."scripts/", $wwwUser, $wwwUser, "440", "550", true, $preview, $arrError, $isTestServer);

	$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_sites_path"), $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_sites_writable_path"), $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);

	$sharePath=get_cfg_var("jetendo_share_path");
	$result=zCheckDirectoryPermissions($sharePath, $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($sharePath."mls-images/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($sharePath."mls-images-temp/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($sharePath."mls-scripts/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($sharePath."task-log/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($sharePath."mls-data/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);

	$logDir=get_cfg_var("jetendo_log_path");
	$result=zCheckDirectoryPermissions($logDir, "root", "root", "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($logDir."deploy/", "root", "root", "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($logDir."mysql-backup/", "root", "root", "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($logDir."zqueue/", "root", "root", "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($logDir."ids/", "root", "root", "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($logDir."sites/", $wwwUser, "root", "660", "770", true, $preview, $arrError, $isTestServer);

	// search for 777 directories/files and other world-writable files later and report them...

	$dir=get_cfg_var("jetendo_backup_path");
	$result=zCheckDirectoryPermissions($dir, $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."jetendo/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);

	$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_nginx_ssl_path"), "root", "root", "400", "400", false, $preview, $arrError, $isTestServer);

	$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_root_private_path"), $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	return true;
}

ini_set('default_socket_timeout', 5);
$arrError=array();

// when debugging, enable preview to prevent any permanent changes.
$preview=false;

set_time_limit(2000);
$host=`hostname`;
if(!zCheckJetendoIniConfig($arrError)){
	// prevent more checks until corrected...
	exitWithLogNotification();
}
$wwwUser=get_cfg_var("jetendo_www_user");

$testDomain=get_cfg_var("jetendo_test_domain"); 
if(strpos($host, $testDomain) !== FALSE){
	$isTestServer=true;
	$checkDNS=false;
	$isInstalledOnSambaMount=get_cfg_var("jetendo_test_server_uses_samba");
}else{
	$isTestServer=false;
	$checkDNS=true;
	$isInstalledOnSambaMount=get_cfg_var("jetendo_server_uses_samba");
}
$ftpEnabled=zIsFtpEnabled();
$result=checkFilesystem();
if(!$result){
	// prevent more checks until corrected...
	exitWithLogNotification();
}

$sitesPath=get_cfg_var("jetendo_sites_path");


$forcePermissions=false; 
$userUnusedStruct=array();
$pathStruct=array();
if($forcePermissions==false){
} 
$handle = opendir($sitesPath);
if($handle !== FALSE) {
    while (false !== ($entry = readdir($handle))) {
		if($entry !="." && $entry !=".." && is_dir($sitesPath.$entry)){
			$pathStruct[$sitesPath.$entry."/"]=true;
		}
    }
	closedir($handle);
}
if($isTestServer){
	$dnsServer=""; // use local dns
}else{
	$dnsServer="@66.96.80.43"; // dns1.hivelocity.com
}
$cmd="/bin/cat /etc/passwd";
$result=trim(`$cmd`);
$arrPasswd=explode("\n", $result);
$userStruct=array();
for($i=0;$i<count($arrPasswd);$i++){
	$arrTemp=explode(":", $arrPasswd[$i]);
	$userStruct[$arrTemp[0]]=$arrTemp;
	if(count($arrTemp) < 6){
		array_push($arrError, "Failed to read one or more users from system.");
		break;
	}else if(substr($arrTemp[5], 0, strlen($sitesPath)-1) != $sitesPath){
		$userUnusedStruct[$arrTemp[0]]=true;
	}
}
$mp=get_cfg_var("jetendo_nginx_ssl_path");
$handle2 = opendir($mp);
if($handle2 !== FALSE) {
    while (false !== ($entry = readdir($handle2))) {
		$curPath=$mp.$entry;
		if($entry =="." || $entry ==".." || is_dir($curPath)){
			continue;
		}
		if(substr($curPath, strlen($curPath)-4, 4) == ".crt"){
			$out=trim(`/usr/bin/openssl x509 -in $curPath -noout -enddate`);
			if($out === FALSE || $out == ""){
				array_push($arrError, "Attention required:openssl certificate expiration check failed for ".$curPath.".");	
			}else{
				if(strpos($out, "notAfter=") === FALSE){
					array_push($arrError, "Unexpected output with OpenSSL expiration date check ".$curPath.". Output: ".$out.".");
				}else{
					$out=str_replace("notAfter=", "", $out);
					if(time()-(60*60*24*7) > strtotime($out)){
						array_push($arrError, "OpenSSL Certificate for ".$curPath." expires on ".$out.".");	
					}
				}
			}
		}
	}
	closedir($handle2);
}

$fail=false;
$cmysql2=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), zGetDatasource());
if($cmysql2->error != ""){ 
	$fail=true;
	array_push($arrError, "db connect error:".$cmysql2->error);	
}
if(!$fail){
	$r=$cmysql2->query("select * from site where site_active='1' ORDER BY site_verified_datetime ASC, site_short_domain asc");
	if($cmysql2->error != ""){ 
		$fail=true;
		array_push($arrError, "db error:".$cmysql2->error);	
	}
	if(!$fail){
		$arrRow=array();
		while($row=$r->fetch_array(MYSQLI_ASSOC)){
			$arrError2=verifySite($row);
			for($i=0;$i<count($arrError2);$i++){
				array_push($arrError, $arrError2[$i]);
			}
			array_push($arrRow, $row);
		}
		if(!$isTestServer){
			// fix /etc/hosts
			$arrHosts=array();
			for($i=0;$i<count($arrRow);$i++){
				$row=$arrRow[$i];
				if($row["site_ip_address"] == ""){
					continue;
				}
				$domain=str_replace(".".get_cfg_var("jetendo_test_domain"), "", $row["site_short_domain"]);
				$shortDomain=$domain;
				$c=substr_count($domain, ".");
				if($c==1){
					$domain="www.".$domain;
				}

				if($shortDomain != $domain){
					array_push($arrHosts, $row["site_ip_address"]." ".$shortDomain);
				}
				array_push($arrHosts, $row["site_ip_address"]." ".$domain);

			}
			$hostContents=implode("\n", $arrHosts);
			$cmd="/bin/cat /etc/hosts";
			$contents=`$cmd`;
			$beginString="\n#jetendo-begin-hosts\n";
			$endString="\n#jetendo-end-hosts\n";
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
			if($fileContentsHosts != $hostContents){
				$newFileContents=$fileBeginContents.$hostContents.$fileEndContents;

				if(!$preview){
					@unlink("/etc/hostsTemp");
					$r1="/etc/hostsTemp";
					$fp=fopen($r1, "w");
					fwrite($fp, $newFileContents);
					fclose($fp);
					chmod("/etc/hostsTemp", 644);
					@unlink("/etc/hosts");
					rename($r1, "/etc/hosts");

					$dnsMasqPath=`/usr/bin/which dnsmasq`;
					$servicePath=`/usr/bin/which service`;
					if(trim($dnsMasqPath) != ""){
						$cmd=$servicePath." dnsmasq reload";
						echo $cmd."\n";
						`$cmd`;
					}
				}
				array_push($arrError, "/etc/hosts was automatically corrected.");
			}
		}
	}
}
// EXTRA paths in $sitesPath
unset($pathStruct[get_cfg_var("jetendo_root_path")."themes/"]);
unset($pathStruct[$sitesPath.'WEB-INF/']);
foreach($pathStruct as $key=>$val){
	array_push($arrError, "Requires attention: Extra directory in installPath: ".$key.". It is recommended you remove these files from the server or add this site using the server manager.");
}
if(!$isTestServer){
	// detect EXTRA users in /etc/passwd
	
	$arrValidUsers=array('root', 'daemon', 'bin', 'sys', 'sync', 'games', 'man', 'lp', 'mail', 'news', 'uucp', 'proxy', 'www-data', 'backup', 'list', 'irc', 'gnats', 'nobody', 'libuuid', 'syslog', 'messagebus', 'whoopsie', 'landscape', 'sshd', 'postfix', 'dnsmasq', 'nginx', 'mysql', 'ftp', 'zftpsecure', 'pulse', 'usbmux', 'rtkit', 'libvirt-qemu', 'libvirt-dnsmasq', 'ntp');
	for($i=0;$i<count($arrValidUsers);$i++){
		unset($userUnusedStruct[$arrValidUsers[$i]]);
	}
	foreach($userUnusedStruct as $key=>$val){
		array_push($arrError, "Requires attention: Extra user in /etc/passwd: ".$key.". You should delete unused linux users.");	
	}
}
exitWithLogNotification();
?>