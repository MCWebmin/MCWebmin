<?php
function startServer(){
    $output = shell_exec("/etc/init.d/minecraft start");
	echo "$output";
}

function stopServer(){
    $output = shell_exec("/etc/init.d/minecraft stop");
	echo "$output";
}

function updateServer(){
    $output = shell_exec("/etc/init.d/minecraft update");
	echo "$output";
}

function restartServer(){
    $output = shell_exec("/etc/init.d/minecraft restart");
	echo "$output";
}

function statusServer(){
    $output = shell_exec("/etc/init.d/minecraft status");
	echo "$output";
}

function backupServer(){
    $output = shell_exec("/etc/init.d/minecraft backup");
	echo "$output";
}

function installHmod(){
    $output = shell_exec("sudo ../scripts/addmod hmod");
	echo "$output";
}

function uninstallHmod(){
    $output = shell_exec("sudo ../scripts/removemod hmod");
	echo "$output";
}

function installRunecraft(){
    $output = shell_exec("sudo ../scripts/addmod runecraft");
	echo "$output";
}

function uninstallRunecraft(){
    $output = shell_exec("sudo ../scripts/removemod runecraft");
	echo "$output";
}
?>
