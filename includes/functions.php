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

function startServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft start");
}

function stopServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft stop");
}

function updateServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft update");
}

function restartServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft restart");
}

function statusServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft status");
}

function backupServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft backup");
}
?>
