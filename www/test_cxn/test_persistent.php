<?php
error_reporting(E_ALL);
session_start();
echo "hello";
if (!isset($_SESSION['remote_sock']))
{
	$sock = pfsockopen("localhost",9001,$_SESSION['errno'],$_SESSION['errstr'],10);
} else
{
	$sock = $_SESSION['remote_sock'];
}
if (!$sock) {
    echo $_SESSION['errno'].": ".$_SESSION['errstr']."<br />\n";
} else {
	$_SESSION['remote_sock'] = $sock;
	echo fgets($sock,128);
	echo "entering password 'bobblefish'";
	fwrite($sock,"bobblefish");
	echo fgets($sock,1024);
	//fclose($sock);
}






?>
