<?php
include_once "../includes/functions.php";
if (isset($_GET['run'])) $linkchoice=$_GET['run'];
switch($linkchoice){

case 'start' :
    startServer();
	$output;
	echo $output;
	echo "$output";
	echo "Starting Server";
	echo "<br />";
    break;

case 'stop' :
    stopServer();
	$output;
	echo $output;
	echo "<br />";
    break;

case 'update' :
    updateServer();
	$output;
	echo $output;
	echo "<br />";
    break;

case 'restart' :
    restartServer();
	$output;
	echo $output;
	echo "<br />";
    break;

case 'status' :
    statusServer();
	$output;
	echo $output;
	echo "<br />";
    break; 
     
case 'backup' :
    backupServer();
	$output;
	echo $output;
	echo "<br />";
    break;      
}
?>