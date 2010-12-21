<?php
function startServer(){
    $output = shell_exec("/etc/init.d/minecraft start");
	echo "Starting Server";
	echo "$output";
}

function stopServer(){
    $output = shell_exec("/etc/init.d/minecraft stop");
	echo "Stopping Server";
	echo "$output";
}

function updateServer(){
    $output = shell_exec("/etc/init.d/minecraft update");
	echo "Updating Server";
	echo "$output";
}

function restartServer(){
    $output = shell_exec("/etc/init.d/minecraft restart");
	echo "Restarting Server";
	echo "$output";
}

function statusServer(){
    $output = shell_exec("/etc/init.d/minecraft status");
	echo "Server Status";
	echo "$output";
}

function backupServer(){
    $output = shell_exec("/etc/init.d/minecraft backup");
	echo "Backing Up Server";
	echo "$output";
}
?>