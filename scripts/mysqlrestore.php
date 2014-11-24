<?php
/*
usage: php /var/jetendo-server/jetendo/scripts/mysqlrestore.php
*/
$debug=false;

set_time_limit(20000);
$mp=get_cfg_var("jetendo_backup_path").'mysql/backup';
$host=get_cfg_var("jetendo_mysql_default_host");
$user=get_cfg_var("jetendo_mysql_default_user");
$pw=get_cfg_var("jetendo_mysql_default_password");
echo "Restoring all files in ".$mp."\n\n";
if ($handle = opendir($mp)) {
    while (false !== ($entry = readdir($handle))) {
		if($entry != "." && $entry != ".." && is_dir($mp."/".$entry) && $entry != "mysql"){
			if ($handle2 = opendir($mp."/".$entry)) {
	
				$db=$entry;
				// this is safe, since it doesn't drop the user privileges
				$cmd="echo \"DROP DATABASE IF EXISTS \`".$db."\`;\"|mysql -h ".escapeshellarg($host)." -u ".escapeshellarg($user)." --password=".escapeshellarg($pw)."";
				echo $cmd."\n\n";
				if(!$debug){
					$r=`$cmd`;
				}
				$cmd="echo \"CREATE DATABASE \`".$db."\`;\"|mysql -h ".escapeshellarg($host)." -u ".escapeshellarg($user)." --password=".escapeshellarg($pw)."";
				echo $cmd."\n\n";
				if(!$debug){
					$r=`$cmd`;
				}
				$schema=$mp."/".$entry."/schema.sql";
				if(file_exists($schema)){
						$cmd="mysql -h ".escapeshellarg($host)." -u ".escapeshellarg($user)." --password=".escapeshellarg($pw)." -D ".escapeshellarg($db)." < ".escapeshellarg($schema);
						echo $cmd."\n\n";
						if(!$debug){
							$r=`$cmd`;
						}
				}else{
					continue;
				}
					
				while (false !== ($entry2 = readdir($handle2))) {
					echo $entry."/".$entry2."\n";
					if(strstr($entry2, ".sql") !== FALSE && $entry2 != "schema.sql"){
						// sql file, do import:
						$r="";
						$f=$mp."/".$entry."/".$entry2;
						echo "------\n".$f."\n\n";
						$cmd="mysql -h ".escapeshellarg($host)." -u ".escapeshellarg($user)." --password=".escapeshellarg($pw)." -D ".escapeshellarg($db)." < ".escapeshellarg($f);
						echo $cmd."\n\n";
						if(!$debug){
							$r=`$cmd`;
						}
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