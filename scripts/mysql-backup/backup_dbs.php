<?php
// use: "C:\Program Files (x86)\PHP\php.exe" "D:\ServerData\Sites\backup_dbs.php"
######################################################################
## MySQL Backup Script v2.1 - May 3, 2007
######################################################################
## For more documentation and new versions, please visit:
## http://www.dagondesign.com/articles/automatic-mysql-backup-script/
## -------------------------------------------------------------------
## Created by Dagon Design (www.dagondesign.com).
## Much credit goes to Oliver Mueller (oliver@teqneers.de)
## for contributing additional features, fixes, and testing.
######################################################################

######################################################################
## Usage Instructions
######################################################################
## This script requires two files to run:
##     backup_dbs.php        - Main script file
##     backup_dbs_config.php - Configuration file
## Be sure they are in the same directory.
## -------------------------------------------------------------------
## Do not edit the variables in the main file. Use the configuration
## file to change your settings. The settings are explained there.
## -------------------------------------------------------------------
## A few methods to run this script:
## - php /PATH/backup_dbs.php
## - BROWSER: http://domain/PATH/backup_dbs.php
## - ApacheBench: ab "http://domain/PATH/backup_dbs.php"
## - lynx http://domain/PATH/backup_dbs.php
## - wget http://domain/PATH/backup_dbs.php
## - crontab: 0 3  * * *     root  php /PATH/backup_dbs.php
## -------------------------------------------------------------------
## For more information, visit the website given above.
######################################################################

error_reporting( E_ALL );

// Initialize default settings
$MYSQL_PATH = '/usr/bin';
$MYSQL_HOST = 'localhost';
$MYSQL_USER = 'root';
$MYSQL_PASSWD = 'password';
$BACKUP_DEST = '/db_backups';
$BACKUP_TEMP = '/tmp/backup_temp';
$VERBOSE = true;
$BACKUP_NAME = 'mysql_backup_' . date('Y-m-d');
$LOG_FILE = $BACKUP_NAME . '.log';
$ERR_FILE = $BACKUP_NAME . '.err';
$COMPRESSOR = 'bzip2';
$EMAIL_BACKUP = false;
$DEL_AFTER = false;
$EMAIL_FROM = 'Backup Script';
$EMAIL_SUBJECT = 'SQL Backup for ' . date('Y-m-d') . ' at ' . date('H:i');
$EMAIL_ADDR = 'user@domain.com';
$ERROR_EMAIL = 'user@domain.com';
$ERROR_SUBJECT = 'ERROR: ' . $EMAIL_SUBJECT;
$EXCLUDE_DB = 'information_schema';
$MAX_EXECUTION_TIME = 18000;
$USE_NICE = 'nice -n 19';
$FLUSH = false;
$OPTIMIZE = false;

// Load configuration file
$current_path = dirname(__FILE__); 
if( file_exists( $current_path.'/backup_dbs_config.php' ) ) {
	require( $current_path.'/backup_dbs_config.php' );
} else {
	echo 'No configuration file [backup_dbs_config.php] found. Please check your installation.';
	exit;
}

################################
# functions
################################
/**
 * Write normal/error log to a file and output if $VERBOSE is active
 * @param string	$msg
 * @param boolean	$error
 */
function writeLog( $msg, $error = false ) {
	global $f_err, $f_log;
	// add current time and linebreak to message
	$fileMsg = date( 'Y-m-d H:i:s: ') . trim($msg) . "\n";

	// switch between normal or error log
	if($error){
	 	$log = $f_err;
	}else{
		$log=$f_log;
	}

	if ( !empty( $log ) ) {
		// write message to log
		fwrite($log, $fileMsg);
	}

	if ( $GLOBALS['VERBOSE'] ) {
		// output to screen
		echo $msg . "\n";
		flush();
	}
} // function

/**
 * Checks the $error and writes output to normal and error log.
 * If critical flag is set, execution will be terminated immediately
 * on error.
 * @param boolean	$error
 * @param string	$msg
 * @param boolean	$critical
 */
function error( $error, $msg, $critical = false ) {

	if ( $error ) {
		// write error to both log files
		writeLog( $msg );
		writeLog( $msg, true );

		// terminate script if this error is critical
		if ( $critical ) {
			die( $msg );
		}

		$GLOBALS['error']	= true;
	}
} // function


function mymail($to,$subject,$message,$headers)
{
mail($to,$subject,$message,$headers);
return true;
}

################################
# main
################################

// set header to text/plain in order to see result correctly in a browser
header( 'Content-Type: text/plain; charset="UTF-8"' );
header( 'Content-disposition: inline' );

// set execution time limit
if( ini_get( 'max_execution_time' ) < $MAX_EXECUTION_TIME ) {
	set_time_limit( $MAX_EXECUTION_TIME );
}

// initialize error control
$error = false;

// guess and set host operating system
if( strtoupper(substr(PHP_OS, 0, 3)) !== 'WIN' ) {
	$os			= 'unix';
	$backup_mime	= 'application/x-tar';
	$BACKUP_NAME	.= '.tar';
} else {
	$os			= 'windows';
	$backup_mime	= 'application/zip';
	$BACKUP_NAME	.= '.zip';
}


// create directories if they do not exist
if( !is_dir( $BACKUP_DEST ) ) {
	$success = mkdir( $BACKUP_DEST );
	error( !$success, 'Backup directory could not be created in ' . $BACKUP_DEST, true );
}
if( !is_dir( $BACKUP_TEMP ) ) {
	$success = mkdir( $BACKUP_TEMP );
	error( !$success, 'Backup temp directory could not be created in ' . $BACKUP_TEMP, true );
}

// prepare standard log file
$log_path = $LOG_FILE;
($f_log = fopen($log_path, 'w')) || error( true, 'Cannot create log file: ' . $log_path, true );

// prepare error log file
$err_path = $ERR_FILE;
($f_err = fopen($err_path, 'w')) || error( true, 'Cannot create error log file: ' . $err_path, true );

// Start logging
writeLog( "Executing MySQL Backup Script v1.4" );
writeLog( "Processing Databases.." );


################################
# DB dumps
################################
$excludes	= array();
if( trim($EXCLUDE_DB) != '' ) {
	$excludes	= array_map( 'trim', explode( ',', $EXCLUDE_DB ) );
} 


# remove expired backups
/*
$curDays=$retension_days;
for($i=30;$i>=0;$i--){
	$date = date('Y-m-d');
	$date = new DateTime();
	$date->sub(new DateInterval('P'.($retension_days+$i).'D'));
	$curDate=$date->format('Y-m-d');
	$cDir="mysql_backup_".$curDate;
	if(is_dir($BACKUP_DEST."/".$cDir)){
		echo $BACKUP_DEST."/".$cDir;
		if ($dir = @opendir($BACKUP_DEST."/".$cDir)) {
			while (($file = readdir($dir)) !== false) {
				if (is_dir($file)) {
					@rmdir($BACKUP_DEST."/".$cDir."/".$file);
				}else{
					@unlink($BACKUP_DEST."/".$cDir."/".$file);
				}
			}
		}
		$r=@rmdir($BACKUP_DEST."/".$cDir);
		if($r===FALSE){
			echo ": expired backup delete failed\n";
			error( true, "Expired backup deletion failed on this folder: ".$BACKUP_DEST."/".$cDir);
		}else{
			echo ": expired backup deleted\n";
			writeLog( "Expired backup deleted: ".$BACKUP_DEST."/".$cDir );
		}
	}else{
		//echo ": no\n";
	}
}
*/


// Loop through databases
$db_conn	= mysql_connect( $MYSQL_HOST, $MYSQL_USER, $MYSQL_PASSWD ) or error( true, mysql_error(), true );

$db_result	= mysql_query('show databases', $db_conn);
$db_auth	= " --host=\"$MYSQL_HOST\" --user=\"$MYSQL_USER\" --password=\"$MYSQL_PASSWD\"";
while ($db_row = mysql_fetch_object($db_result)) {
 
	$db = $db_row->Database;

	if( in_array( $db, $excludes ) ) {
		// excluded DB, go to next one
		continue;
	}

	$cmd="/bin/rm -rf ".escapeshellarg($BACKUP_TEMP."/".$db);
	echo $cmd."\n";
	`$cmd`;
	@mkdir($BACKUP_TEMP."/".$db, 0600);
	unset( $output ); 
	// dump db schema
	$cmd = "/usr/bin/mysqldump --no-data --triggers $db_auth ".escapeshellarg($db)." 2>&1 >$BACKUP_TEMP/$db/schema.sql";
	echo $cmd."\n";
	exec($cmd, $output, $res);
	if( $res > 0 ) {
		error( true, "Schema dump failed for $db\n".implode( "\n", $output) );
	}
	
	$result= mysql_query('show tables in `'.$db.'`', $db_conn);
	while ($row2 = mysql_fetch_array($result)) {
		$table=$row2['Tables_in_'.$db];
		$tableFileName=preg_replace('/[^A-Za-z0-9_\-]/', '_', $table);
		unset( $output ); 
		$cmd="/usr/bin/mysqldump $db_auth --quick --no-create-db --no-create-info --single-transaction --opt --skip-lock-tables  ".escapeshellarg($db)." ".escapeshellarg($table)." 2>&1 >$BACKUP_TEMP/$db/$tableFileName.sql";
		echo $cmd."\n";
		writeLog( "Dumping DB: " . $db." Table: ".$table );
		exec($cmd, $output, $res);
		if( $res > 0 ) {
			error( true, "Failed: ".implode( "\n", $output) );
		} else {
			writeLog( "Success\n" );
		} // if
	}

	if( $OPTIMIZE ) {
		unset( $output );
		exec( "/usr/bin/mysqlcheck $db_auth --optimize ".escapeshellarg($db)." 2>&1", $output, $res);
		if( $res > 0 ) {
			error( true, "OPTIMIZATION FAILED\n".implode( "\n", $output) );
		} else {
			writeLog( "Optimized DB: " . $db );
		}
	} // if
		
	unset( $output );
	/*if( $os == 'unix' ) {
		exec( "$USE_NICE $COMPRESSOR $BACKUP_TEMP/$db.sql 2>&1" , $output, $res );
	} else {*/
		//exec("7za a -t7z $BACKUP_TEMP/$db.sql.7z $BACKUP_TEMP/$db.sql", $output, $res);
		//exec( "zip -mj $BACKUP_TEMP/$db.sql.zip $BACKUP_TEMP/$db.sql 2>&1" , $output, $res );
	//}
	//var_dump($output); 
	/*if($output[count($output)-1] != "Everything is Ok" || $res > 0 ) {
		error( true, "COMPRESSION FAILED\n".implode( "\n", $output) );
	} else {
		writeLog( "Compressed DB: " . $db );
		@unlink("$BACKUP_TEMP/$db.sql");
	}*/

	if( $FLUSH ) {
		unset( $output );
		exec("mysqladmin $db_auth flush-tables 2>&1", $output, $res );
		
		if( $res > 0 ) {
			error( true, "Flushing tables failed\n".implode( "\n", $output) );
		} else {
			writeLog( "Flushed Tables" );
		}
	} // if
} // while

mysql_free_result($db_result);
mysql_close($db_conn);

// first error check, so we can add a message to the backup email in case of error
if ( $error ) {
	$msg	= "\n*** ERRORS DETECTED! ***";
	if( $ERROR_EMAIL ) {
		$msg	.= "\nCheck your email account $ERROR_EMAIL for more information!\n\n";
	} else {
		$msg	.= "\nCheck the error log {$err_path} for more information!\n\n";
	}

	writeLog( $msg );
}



// see if there were any errors to email
if ( ($ERROR_EMAIL) && ($error) ) {
	writeLog( "\nThere were errors!" );
	writeLog( "Emailing error log to " . $ERROR_EMAIL . " .. " );
	$body = "Please check the log in this folder for details: ".$BACKUP_TEMP." \n".file_get_contents($err_path)."\n";
	$res=mymail($EMAIL_ADDR,$ERROR_SUBJECT, $body, "From: \"Coldfusion Error\" <coldfusion_error@farbeyondcode.com>\nX-Mailer: php" );
	if($res!==TRUE) {
		error( true, 'FAILED to email error log.' );
	}
}else{
	$ERROR_SUBJECT="Mysql backup complete";
	$hostname=`hostname`;
	$body = "Mysql backup on {$hostname} completed successfully.\n";
	$res=mymail($EMAIL_ADDR,$ERROR_SUBJECT, $body, "From: \"Coldfusion Error\" <coldfusion_error@farbeyondcode.com>\nX-Mailer: php" );
}

################################
# cleanup / mr proper
################################

// close log files
fclose($f_log);
fclose($f_err);

// if error log is empty, delete it
if( !$error ) {
	unlink( $err_path );
}


?>
