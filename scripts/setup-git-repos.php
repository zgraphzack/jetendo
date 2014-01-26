<?php
// run this script to setup git repos for all jetendo sites first time.   newsite.php sets up sites individually as they are created / modified.

$rootPath=get_cfg_var('jetendo_root_path');
$cmd="ls ".$rootPath."sites/";
$arrPath=explode("\n", trim(`$cmd`)); 
for($i=0;$i < count($arrPath);$i++){
	$currentPath=$rootPath."sites/".$arrPath[$i];
	if($arrPath[$i] == '' || $arrPath[$i] == "WEB-INF" || is_file($currentPath) || is_dir($currentPath."/.git")){
		continue;
	}
	$currentPath.="/"; 
	$cmd="cp ".$rootPath."scripts/git-ignore-template.txt ".$currentPath.".gitignore";
	`$cmd`;
	echo $cmd."\n";
	
	chdir($currentPath."/");
	echo `/usr/bin/git init`;
	echo `/usr/bin/git add .`;
	echo `/usr/bin/git commit -m 'First commit'`;
	//exit;
}
?>