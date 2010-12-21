<?php
if (isset($_GET['run'])) $linkchoice=$_GET['run'];
else $linkchoice=''; 
switch($linkchoice){
case 'start' :
    $output = shell_exec("/usr/bin/sudo -u mcwebmin /etc/init.d/minecraft start");
	echo "<pre>$output</pre>";
    break;

case 'stop' :
    $output = shell_exec("/usr/bin/sudo -u mcwebmin /etc/init.d/minecraft stop");
	echo $output;
	echo "<br />";
    break;

case 'update' :
    $output = shell_exec("/usr/bin/sudo -u mcwebmin /etc/init.d/minecraft update");
	echo $output;
	echo "<br />";
    break;

case 'restart' :
    $output = shell_exec("/usr/bin/sudo -u mcwebmin /etc/init.d/minecraft restart");
	echo $output;
	echo "<br />";
    break;

case 'status' :
    $output = shell_exec("/usr/bin/sudo -u mcwebmin /etc/init.d/minecraft status");
	echo $output;
	echo "<br />";
    break; 
     
case 'backup' :
    $output = shell_exec("/usr/bin/sudo -u mcwebmin /etc/init.d/minecraft backup");
	echo $output;
	echo "<br />";
    break;      
}
?>