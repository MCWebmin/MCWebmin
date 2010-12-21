<?php
function startServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft start");
	echo "Starting Server";
}

function stopServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft stop");
	echo "Stopping Server";
}

function updateServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft update");
	echo "Updating Server";
}

function restartServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft restart");
	echo "Restarting Server";
}

function statusServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft status");
	echo "Server Status";
}

function backupServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft backup");
	echo "Backing Up Server";
}
?>