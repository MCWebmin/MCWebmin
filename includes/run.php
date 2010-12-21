<?php
if (isset($_GET['run'])) $linkchoice=$_GET['run'];
else $linkchoice='';

switch($linkchoice){

case 'start' :
    startServer();
	echo $output;
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