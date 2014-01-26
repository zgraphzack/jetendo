<?php
// this script return the host date and time, so that virtual machine guest with the time drift problem can be auto-corrected.

$cmd="date ".date("n/j/Y");
echo $cmd."|";

$cmd="time ".date("g:i:s A");
echo $cmd;
//`$cmd`;

?>