<?php
function startServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft start");
        echo $output;
        echo "<br>";
}

function stopServer(){
    $output = shell_exec("sudo /etc/init.d/minecraft stop");
        echo $output;
        echo "<br>";
}

function upgrade(){
    if(copy('http://www.minecraft.net/download/minecraft_server.jar', '../server_files/update/minecraft_server.jar')){
        copy('../server_files/minecraft-server/minecraft_server.jar','../server_files/minecraft-server/minecraft_server.jar.bak');
        stopServer();
        copy('../server_files/update/minecraft_server.jar', '../server_files/minecraft-server/minecraft_server.jar');
        startServer();
        echo "Upgrade succesfull <br>";
    } else {
        return false;
    }
}


?>