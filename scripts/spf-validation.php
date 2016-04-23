<?php 

require("library.php");
set_time_limit(7000);
function microtimeFloat()
{
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
}
 
$dnsServer=""; // use local dns
$dnsServer2=""; // use local dns
if($isTestServer){
	$d=get_cfg_var("jetendo_test_dns_server");
	if($d !=""){
		$dnsServer="@".$d; 
	}
	$d=get_cfg_var("jetendo_test_dns_server2");
	if($d !=""){
		$dnsServer2="@".$d; 
	}
}else{
	$d=get_cfg_var("jetendo_dns_server");
	if($d !=""){
		$dnsServer="@".$d; 
	}
	$d=get_cfg_var("jetendo_dns_server2");
	if($d !=""){
		$dnsServer2="@".$d; 
	}
}



function checkDNSForSPFPhrases($dnsString, $arrSPFPhrase){
	$arrLine=explode("\n", trim($dnsString));

	$phraseCount=0;
	$arrError=array();
	$foundSPF=false;
	for($i=0;$i<count($arrLine);$i++){
		$line=trim($arrLine[$i]);
		// remove quotes
		if(substr($line, 0, 1) == '"'){
			$line=substr($line, 1, strlen($line)-2);
		}
		if(substr($line, strlen($line)-1, 1) == '"'){
			$line=substr($line, 0, strlen($line)-2);
		}
		// split record
		$a=explode(" ", $line);
		if(count($a) > 1){
			if(substr($a[0], 0, 5) == 'v=spf'){
				// this is an spf record
				$foundSPF=true;
				break;
			}
		} 
	}
	if($foundSPF){
		for($n=0;$n<count($arrSPFPhrase);$n++){
			$match=strstr($line, $arrSPFPhrase[$n]);
			if($match===FALSE){
				array_push($arrError, '"'.$arrSPFPhrase[$n].'" not found');
			}else{
				$phraseCount++;
			}
		}
	}else{
		$line="";
	}  
	if($phraseCount == count($arrSPFPhrase)){
		return array("success"=>true, "spfRecord"=>$line);
	}else{
		return array("success"=>false, "spfRecord"=>$line, "errorMessage"=>count($arrError)." errors. Details:".implode(", ", $arrError));
	} 
}

$arrVendorPhrase=array(
	"sendgrid" => "include:sendgrid.net", 
	"mailchimp" => "include:servers.mcsv.net",
	"mailgun" => "include:mailgun.org",
	"google" => "include:_spf.google.com",
	"yahoo" => "include:_spf.mail.yahoo.com",
	"outlook" => "include:spf.protection.outlook.com",
	"rackspace" => "include:emailsrvr.com" 
);
$arrError=array();

// get all domains to validate from cfml db
$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), zGetDatasource());
$sql="select * FROM spf_domain WHERE spf_domain_deleted='0' ";
for($i=0;$i<count($argv);$i++){
	if($argv[$i] == 'onlyinvalid=1'){
		$sql.=" and spf_domain_valid='0' ";
	}
}
$sql.=" ORDER BY spf_domain_name asc "; 
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
// loop the domains  
while($row=$r->fetch_assoc()){ 
	$domain=$row["spf_domain_name"];

	$arrVendor=explode(",", $row["spf_domain_vendor_list"]);
	$arrPhrase=array(); 
	for($i=0;$i<count($arrVendor);$i++){
		$arrVendor[$i]=trim($arrVendor[$i]);
		if(isset($arrVendorPhrase[$arrVendor[$i]])){
			array_push($arrPhrase, $arrVendorPhrase[$arrVendor[$i]]);
		}else if($arrVendor[$i] != ""){
			array_push($arrPhrase, $arrVendor[$i]);
		}
	} 
	if(count($arrPhrase)==0){
		$cmysql->query("UPDATE spf_domain SET spf_domain_dns_record='', spf_domain_valid='0', spf_domain_updated_datetime='".date('Y-m-d H:i:s')."' WHERE spf_domain_id='".$row["spf_domain_id"]."'", MYSQLI_STORE_RESULT);  
		array_push($arrError, "dig txt/spf failed for domain: ".$domain." | there are no mail vendors or custom phrases defined in the server manager for this domain yet.");
		continue;
	} 
	// dig mx domain.com
	$cmd="/usr/bin/dig mx +short $dnsServer $domain";
	$output1=trim(`$cmd`); 
	if($output1 != ""){ 
		$cmysql->query("UPDATE spf_domain SET spf_domain_mx_dns_record='".$cmysql->real_escape_string($output1)."', spf_domain_updated_datetime='".date('Y-m-d H:i:s')."' WHERE spf_domain_id='".$row["spf_domain_id"]."'", MYSQLI_STORE_RESULT);   
	}else{ 
		$cmysql->query("UPDATE spf_domain SET spf_domain_mx_dns_record='no mx record', spf_domain_updated_datetime='".date('Y-m-d H:i:s')."' WHERE spf_domain_id='".$row["spf_domain_id"]."'", MYSQLI_STORE_RESULT);   
		continue;
	}
	// sleep 1 second to avoid abusive dns checks/limits
	sleep(1); 

	// dig spf domain.com
	$cmd="/usr/bin/dig spf +short $dnsServer $domain";
	$output1=trim(`$cmd`); 
	if($output1 != ""){
		if($row["spf_domain_valid"]=="1"){
			$cmysql->query("UPDATE spf_domain SET spf_domain_dns_record='', spf_domain_valid='0', spf_domain_updated_datetime='".date('Y-m-d H:i:s')."' WHERE spf_domain_id='".$row["spf_domain_id"]."'", MYSQLI_STORE_RESULT);  
		}
		array_push($arrError, "dig txt/spf failed for domain: ".$domain." | the domain has an \"SPF\" type dns record, which is not valid and must be changed to \"TXT\" type for SPF to work across all ISPs.  If both records exist, delete the SPF type dns record to fix this error.");
		continue;
	}
	// sleep 1 second to avoid abusive dns checks/limits
	sleep(1); 

	// dig txt domain.com
	$cmd="/usr/bin/dig txt +short $dnsServer $domain";
	$output1=trim(`$cmd`);   
	if($output1 == ""){
		if($row["spf_domain_valid"]=="1"){
			$cmysql->query("UPDATE spf_domain SET spf_domain_dns_record='', spf_domain_valid='0', spf_domain_updated_datetime='".date('Y-m-d H:i:s')."' WHERE spf_domain_id='".$row["spf_domain_id"]."'", MYSQLI_STORE_RESULT);  
		}
		array_push($arrError, "dig txt/spf failed for domain: ".$domain." | the domain may no longer exist, has changed vendors or is needing to be renewed.");
		continue;
	}
	// parse spf
	$arrReturn=checkDNSForSPFPhrases($output1, $arrPhrase);
 
	// if not found
	if($arrReturn["success"]==false){
		// add domain to array of spf check failures 
		$cmysql->query("UPDATE spf_domain SET spf_domain_dns_record='".$cmysql->real_escape_string($arrReturn['spfRecord'])."', spf_domain_valid='0', spf_domain_updated_datetime='".date('Y-m-d H:i:s')."' WHERE spf_domain_id='".$row["spf_domain_id"]."'", MYSQLI_STORE_RESULT);   
		array_push($arrError, "dig txt/spf failed for domain: ".$domain." | the domain doesn't match all SPF phrases. Details: ".$arrReturn["errorMessage"]);
		continue;
	}
 
	$cmysql->query("UPDATE spf_domain SET spf_domain_dns_record='".$cmysql->real_escape_string($arrReturn['spfRecord'])."', spf_domain_valid='1', spf_domain_updated_datetime='".date('Y-m-d H:i:s')."' WHERE spf_domain_id='".$row["spf_domain_id"]."'", MYSQLI_STORE_RESULT);   
	// sleep 1 second to avoid abusive dns checks/limits
	sleep(1); 
} 
// check if any errors logged
if(count($arrError)>0){
	// send email
	$message="The following spf validation errors occured.\n\n".implode("\n\n", $arrError);
	zEmail("SPF configuration errors detected for ".count($arrError)." domains", $message);
}
?>