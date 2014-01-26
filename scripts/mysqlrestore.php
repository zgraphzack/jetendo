<?php
/*
usage: php /opt/jetendo/scripts/mysqlrestore.php /zbackup/mysql/backup/mysql_backup_2013-07-10/ root rootpassword
*/
//echo "path:".$argv[1]."\nuser:".$argv[2]."\npass:".$argv[3]."\n";
//exit;

set_time_limit(20000);
if(count($argv)==0 || $argv[1] == ""){
	echo "invalid parameters.";
	exit;
}

$mp=$argv[1];//"/home/mysqlbackup/";
$user=$argv[2];//"root";
$pw=$argv[3];//"123";
chdir($mp);
echo "Restoring all files in ".$mp."\n\n";
if ($handle = opendir($mp)) {
    while (false !== ($entry = readdir($handle))) {
		echo $entry."\n";
		if(strstr($entry, ".7z") !== FALSE && strstr($entry, "mysql.7z") === FALSE){
			// sql file, do import:
			$db=substr($entry, 0, strlen($entry)-7);
			$f=$db.".sql";
			if(!file_exists($mp.$f)){
				$cmd="7za e ".$mp.$entry;
				$r=`$cmd`;
				echo $cmd."\n\n";
				echo "Uncompressed: ".$entry." | ".$r."\n\n";
			}
			$cmd="echo \"DROP DATABASE ".$db.";\"|mysql -h 127.0.0.1 -u ".$user." --password=\"".$pw."\"";
			echo $cmd."\n\n";
			$r=`$cmd`;
			$cmd="echo \"CREATE DATABASE ".$db.";\"|mysql -h 127.0.0.1 -u ".$user." --password=\"".$pw."\"";
			echo $cmd."\n\n";
			$r=`$cmd`;
			$cmd="mysql -h 127.0.0.1 -u ".$user." --password=\"".$pw."\" -D ".$db." < ".$f;
			echo $cmd."\n\n";
			$r=`$cmd`;
			echo "Restored: ".$entry." | ".$r."\n\n";
			@unlink($mp.$f);
		}
		//echo "done";
		//exit;
    }

    closedir($handle);
}
?>