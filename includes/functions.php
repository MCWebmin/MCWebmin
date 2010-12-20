<?php
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

function upgrade(){
    $output = shell_exec("sudo /etc/init.d/minecraft upgrade");
        echo $output;
        echo "<br />";
}

function status(){
    $output = shell_exec("sudo /etc/init.d/minecraft status");
        echo $output;
        echo "<br />";
}



?>
