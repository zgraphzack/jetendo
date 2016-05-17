<?php
set_time_limit(3000);
// usage: php /var/jetendo-server/jetendo/scripts/git-autocommit.php "Site structure changed" "0"
$rootPath=get_cfg_var("jetendo_root_path");
if(!isset($argv) || count($argv) <= 2){
	echo "\nYou must specify a commit message. I.e. \n\nphp ".$rootPath."scripts/git-autocommit.php \"Autocommit\"\n\n";
	exit;
}
$sshKey=get_cfg_var("jetendo_git_ssh_key_path");

$handle = opendir($rootPath."sites/");
if($handle !== FALSE) {
    while (false !== ($entry = readdir($handle))) {
		if($entry !="." && $entry !=".." && is_dir($rootPath."sites/".$entry) && is_dir($rootPath."sites/".$entry.'/.git')){
			echo "Running autocommit on ".$entry."\n";
			chdir($rootPath."sites/".$entry."/");
			$cmd="/usr/bin/git add .";
			`$cmd`; 
			
			$cmd="/usr/bin/git commit -am '".$argv[1]."'";
			`$cmd`; 
			
			if(count($argv) == 3){
				if($argv[2]=="1"){
					$cmd="/usr/bin/git push -u origin --all";
					$sshCMD="/usr/bin/ssh-agent bash -c '/usr/bin/ssh-add $sshKey; ".$cmd."'";
					$s2=`$sshCMD`; 
					echo $cmd."\n";
					echo `$cmd`;
				}
			}
		}
    }
	closedir($handle);
}

echo "auto commit completed on all sites."
?>