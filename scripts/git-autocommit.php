<?php

$rootPath=get_cfg_var("jetendo_root_path");
if(!isset($argv) || count($argv) <= 1){
	echo "\nYou must specify a commit message. I.e. \n\nphp ".$rootPath."scripts/git-autocommit.php \"Autocommit\"\n\n";
	exit;
}

$handle = opendir($rootPath."sites/");
if($handle !== FALSE) {
    while (false !== ($entry = readdir($handle))) {
		if($entry !="." && $entry !=".." && is_dir($rootPath."sites/".$entry)){
			echo "Running autocommit on ".$entry."\n";
			chdir($rootPath."sites/".$entry."/");
			$cmd="git commit -am '".$argv[1]."'";
			`$cmd`; 
		}
    }
	closedir($handle);
}

echo "auto commit completed on all sites."
?>