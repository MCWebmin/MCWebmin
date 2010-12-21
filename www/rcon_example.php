<?php

include_once("rcon.class.php");

$r = new rcon("127.0.0.1",27015,"testme");
$r->Auth();

echo "Authenticated\n";

//Send a request
var_dump($r->rconCommand("cvarlist"));


?>