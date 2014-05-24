#no execute - use as /usr/bin/perl /path/to/rsync_backup.pl
# Filename: rsync_backup.pl
# Will back things up from one computer to another over SSH using rsync.
# Use in conjunction with a rotate script on the destination machine for
# time-machine-like incremental backups.
# Note: SSH SSL auth keys must be installed on each end to avoid passwd prompt
# Assumes a user named "backup-$THIS_COMPUTER" on remote machine.
# All output will go to Logfile
#
# (c) 2009 eddie@eddieoneverything.com 
# JETENDO USAGE DESCRIPTION: NEEDS TO BE UPDATED / TESTED | This script does a local archive rsync backup of one 1 filesystem at a time and excludes system folders that you wouldn't want to restore.  
# /home must be mounted separately on restore from the other LVM partition.

# cron job syntax: crontab -e
# 15 0 * * * /home/rsync_backup.pl

use Data::Dumper;

print "Hello\n";
exit 0;
# This computer's name.  Used to name the backup files.
$THIS_COMPUTER = "localhost";

# The remote machine's URL or IP address.
$REMOTE_MACHINE = "localhost";

# The backup directory on the remote machine
$REMOTE_BACKUP_LOCATION="/zbackup/full-system-backup";

# Log things
$LOGFILE = get_cfg_var("jetendo_scripts_path")."rsync_backup.log";

# Directories to backup.
@BACKUP_DIRS=(
   #'/home',
   '/'
   #'/root',
   #'/etc',
   #'/var/log',
   #'/var/lib/mysql',
   #'/var/spool/cron'
);

# Directories to ignore.
@IGNORE_DIRS=(
	'/boot',
   '/home',
   '/opt',
   '/proc',
   '/lost+found',
   '/media',
   '/mnt',
   '/dev',
   '/sys'
);

#####################################################
########### END Configuration options ###############
#####################################################

open hLOG, ">$LOGFILE";
$now = `date`;
print hLOG "-" x 80, "\n";
print hLOG "START BACKUP $THIS_COMPUTER at $now\n" ;
print hLOG "-" x 80, "\n";
# Get a list of dirs to back up
foreach (@BACKUP_DIRS){
   $dir = $_;
   opendir(DIR, $dir) || alert ("cant opendir $dir: $!");
   while ($file = readdir(DIR)){
      if ($file ne '.' && $file ne '..'){
		#print "dir:". $dir."|".$my_file."\n";
		if ($dir eq '/'){
			 $my_file = "/" .  $file;
		}else{
			 $my_file = $dir . "/" .  $file;
		}
         if ( -d $my_file){
            if ($my_file eq "/lost+found" || grep {/$my_file/} @IGNORE_DIRS){
               print hLOG "Ignore Dir: $my_file\n";
            }else{
               print hLOG "Dir: $my_file\n";
               push @BACKUP_LIST, {'dir' => $dir, 'name'=>$file};
            }
         }else{
            print hLOG "file is $my_file -- \n";
            @arr_temp =  ($dir, $my_file);
            push @BACKUP_LIST, {'dir' => $dir, 'name'=>$file};
         }
      }
   }
   closedir DIR;
}

#print Dumper(@BACKUP_LIST);

#Back up each dir in the backup list
foreach $my_entry (@BACKUP_LIST){
   $dir = $my_entry->{'dir'};
   $b = $my_entry->{'name'};

   #backup-$THIS_COMPUTER\@$REMOTE_MACHINE:
   # removed v and --progress -e ssh now...
   $cmd = "rsync -axz --force --exclude \"mysqldata\" --delete-after  \"$dir$b\" \"/$REMOTE_BACKUP_LOCATION\"";
   #/$THIS_COMPUTER$dir\"";
   $now=`date`;
   print hLOG "\n$now\t$cmd ";
   #print "$cmd\n";
   `$cmd >> $LOGFILE 2>&1`;
}

$now = `date`;
print hLOG "-" x 80, "\n";
print hLOG "END BACKUP of $THIS_COMPUTER at $now\n" ;
print hLOG "-" x 80, "\n";
close hLOG;

###################### Subs #########################
sub alert(){
   $a=shift(@_);
   print hLOG "#############################\n";
   print hLOG "#############################\n";
   print hLOG "#############################\n";
   print hLOG "Cannot backup $a $!\n";
   print hLOG "#############################\n";
   print hLOG "#############################\n";
   print hLOG "#############################\n";
}