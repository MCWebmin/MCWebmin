<?php

include_once("../includes/rcon.class.php");

$r = new rcon("127.0.0.1",25500,"testme");
$r->Auth();

echo "Authenticated\n";

//Send a request
var_dump($r->rconCommand("cvarlist"));


?>
