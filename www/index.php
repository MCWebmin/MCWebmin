<?php include "../includes/header.template.php"
?>

<table align="center" border="1" bgcolor="#ffffff">

<tr><td>Server Name</font></td><td bgcolor=\"red\">Status</td><td>Port</td></tr>

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