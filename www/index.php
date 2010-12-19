<html>
<head>
<title>MCWebmin</title>

<body background="http://www.minecraft.net/img/bg.gif">

<center><img src="http://www.minecraft.net/img/logo_small.gif" alt="minecraft"></center>
<table align="center" border="1" bgcolor="#ffffff">
<?php

$servers = array (
     array('stef.si', 25565, 30, 'Survival MultiPlayer - Minecraft'),
     array('stef.si', 25566, 30, 'Classic Minecraft Multiplyer')
);


foreach ($servers as $port) {

     $fp = @fsockopen($port[0], $port[1], $errno, $errstr, $port[2]);



     if (!$fp) {
          echo "<tr><td><font color=\"red\">{$port[0]}:{$port[1]}: $errstr ($errno)</font></td><td bgcolor=\"red\">DOWN</td><td>{$port[3]}</td></tr>";


     } else {
          echo "<tr><td><font color=\"green\">{$port[0]}:{$port[1]} is up</font></td><td bgcolor=\"#00ff00\">OK</td><td>{$port[3]}</td></tr>";
     }
}
?>
<tr>
	<td><a href="scripts/start.php">START</a></td>
	<td><a href="scripts/stop.php">STOP</a></td>
	<td><a href="scripts/restart.php">RESTART</a></td>
<tr>
</table>

</body>
</html>
