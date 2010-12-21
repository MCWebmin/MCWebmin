<?php
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
    $output = shell_ exec("sudo /etc/init.d/minecraft status");
}

function backupServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft backup");
}
?>
