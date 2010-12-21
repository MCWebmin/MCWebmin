<?php
function startServer(){
    $output = exec("sudo /etc/init.d/minecraft start");
}

function stopServer(){
    $output = exec("sudo /etc/init.d/minecraft stop");
}

function updateServer(){
    $output = exec("sudo /etc/init.d/minecraft update");
}

function restartServer(){
    $output = exec("sudo /etc/init.d/minecraft restart");
}

function statusServer(){
    $output = exec("sudo /etc/init.d/minecraft status");
}

function backupServer(){
    $output = exec("sudo /etc/init.d/minecraft backup");
}
?>
