<?php
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

function startServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft start");
        echo $output;
        echo "<br />";
}

function stopServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft stop");
        echo $output;
        echo "<br />";
}

function updateServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft update");
        echo $output;
        echo "<br />";
}

function restartServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft restart");
        echo $output;
        echo "<br />";
}

function statusServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft status");
        echo $output;
        echo "<br />";
}

function backupServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft backup");
        echo $output;
        echo "<br />";
}


?>
