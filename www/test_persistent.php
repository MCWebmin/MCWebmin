<?php
error_reporting(E_ALL);
include_once("connection.php");
$conn = new Connection("127.0.0.1",9001,"bobblefish");
echo $conn->getStatus();

?>
