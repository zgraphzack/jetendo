<?php
// usage: php /opt/jetendo/scripts/git-bitbucket.php "username" "password"
$rootPath=get_cfg_var("jetendo_root_path");
if(!isset($argv) || count($argv) <= 2){
	echo "\nYou must specify a username and password for bitbucket.org. I.e. \n\nphp ".$rootPath."scripts/git-bitbucket.php \"username\" \"password\"\n\n";
	exit;
}

$handle = opendir($rootPath."sites/");
if($handle !== FALSE) {
    while (false !== ($entry = readdir($handle))) {
		if($entry !="." && $entry !=".." && is_dir($rootPath."sites/".$entry) && is_dir($rootPath."sites/".$entry.'/.git')){
			echo "Creating bitbucket repo: ".$entry."\n";
			chdir($rootPath."sites/".$entry."/");
			
			$repo=str_replace("_", ".", $entry);
			
			$cmd="/usr/bin/curl --user '".$argv[1].":".$argv[2]."' https://api.bitbucket.org/1.0/repositories/ --data name=".$repo." --data is_private='true'";
			echo $cmd."\n";
			echo `$cmd`; 
			
			$cmd="/usr/bin/git remote add origin https://".$argv[1]."@bitbucket.org/".$argv[1]."/".$repo.".git";
			echo $cmd."\n";
			echo `$cmd`; 
			
			/*$cmd="/usr/bin/git push -u origin --all";
			echo $cmd."\n";
			echo `$cmd`; */
			//exit;
		}
    }
	closedir($handle);
}

echo "created bitbucket repositories for all sites."
?>