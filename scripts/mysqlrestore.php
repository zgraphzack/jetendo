<?php
/*
usage: php /var/jetendo-server/jetendo/scripts/mysqlrestore.php
*/

set_time_limit(20000);
$mp=get_cfg_var("jetendo_backup_path").'mysql/backup';
$host=get_cfg_var("jetendo_mysql_default_host");
$user=get_cfg_var("jetendo_mysql_default_user");
$pw=get_cfg_var("jetendo_mysql_default_password");
echo "Restoring all files in ".$mp."\n\n";
if ($handle = opendir($mp)) {
    while (false !== ($entry = readdir($handle))) {
		if($entry != "." && $entry != ".." && is_dir($mp."/".$entry)){
			if ($handle2 = opendir($mp."/".$entry)) {
				while (false !== ($entry2 = readdir($handle2))) {
					echo $entry."/".$entry2."\n";
					if(strstr($entry2, ".sql") !== FALSE){
						// sql file, do import:
						$r="";
						$db=$entry;
						$f=$mp."/".$entry."/".$entry2;
						// this is safe, since it doesn't drop the user privileges
						$cmd="echo \"DROP DATABASE ".$db.";\"|mysql -h ".$host." -u ".$user." --password=\"".$pw."\"";
						echo $cmd."\n\n";
						$r=`$cmd`;
						$cmd="echo \"CREATE DATABASE ".$db.";\"|mysql -h ".$host." -u ".$user." --password=\"".$pw."\"";
						echo $cmd."\n\n";
						$r=`$cmd`;
						$cmd="mysql -h ".$host." -u ".$user." --password=\"".$pw."\" -D ".$db." < ".$f;
						echo $cmd."\n\n";
						$r=`$cmd`;
						echo "Restored: ".$entry."/".$entry2." | ".$r."\n\n";
						//@unlink($f);
					}
				}
				closedir($handle2);
			}
		}
	}
	closedir($handle);
}
?>