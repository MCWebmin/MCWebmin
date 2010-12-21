<?php
include_once "../includes/functions.php";
if (isset($_GET[''])) $linkchoice=$_GET[''];
switch($linkchoice){

case 'start' :
    startServer();
	echo $output;
	echo "$output";
	echo "Starting Server";
	echo "<br />";
    break;

case 'stop' :
    stopServer();
	echo $output;
	echo "<br />";
    break;

case 'update' :
    updateServer();
	echo $output;
	echo "<br />";
    break;

case 'restart' :
    restartServer();
	echo $output;
	echo "<br />";
    break;

case 'status' :
    statusServer();
	echo $output;
	echo "<br />";
    break; 
     
case 'backup' :
    backupServer();
	echo $output;
	echo "<br />";
    break;      
}
?>