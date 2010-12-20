<?php include "../includes/header.template.php"
?>

<table align="center" border="1" bgcolor="#ffffff">
<?php

$servers = array (
     array('Test Server', 25565, 30, 'Survival MultiPlayer - Minecraft'),
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
	<td><a href="?run=start">START</a></td>
	<td><a href="?run=stop">STOP</a></td>
	<td><a href="?run=update">UPDATE</a></td>
<tr>
<tr>
	<td><a href="?run=backup">BACKUP</a></td>
	<td><a href="?run=restart">RESTART</a></td>
	<td><a href="?run=status">STATUS</a></td>
<tr>
</table>
<?php include "../includes/footer.template.php"
?>