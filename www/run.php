<?php
error_reporting(E_ALL);
ini_set('display_errors', '1');

include "../includes/functions.php";
if (isset($_GET['run'])) $linkchoice=$_GET['run'];
else $linkchoice='';

switch($linkchoice){

case 'start' :
    startServer();
    break;

case 'stop' :
    stopServer();
    break;

case 'update' :	
    updateServer();
    break;

case 'restart' :
    restartServer();
    break;

case 'status' :
    statusServer();
    break; 
     
case 'backup' :
    backupServer();
    break;      
}
?>