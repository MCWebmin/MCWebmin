<?php
$file = 'http://www.minecraft.net/download/minecraft_server.jar';
$newfile = 'minecraft_server.jar';

if (!copy($file, $newfile)) {
    echo "failed to copy $file...\n";
}
?>