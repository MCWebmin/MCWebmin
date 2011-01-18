<?php 
include "../includes/header.template.php"
// test cowguru
?>
	<div id="bd">
			
			<div id="yui-main">
				<div class="yui-b">
					<div class="yui-g">
						<div class="main_content">

<table align="center" border="1" bgcolor="#ffffff">

<tr><td><?php echo $ip ?></font></td><td bgcolor="red">Status</td><td><?php echo $port ?></td></tr>

<tr>
	<td><a href="run.php?run=start" class="greybox">START</a></td>
	<td><a href="run.php?run=stop" class="greybox">STOP</a></td>
	<td><a href="run.php?run=update" class="greybox">UPDATE</a></td>
<tr>
<tr>
	<td><a href="run.php?run=backup" class="greybox">BACKUP</a></td>
	<td><a href="run.php?run=restart" class="greybox">RESTART</a></td>
	<td><a href="run.php?run=status" class="greybox">STATUS</a></td>
<tr>
</table>

						</div>
					</div>
				</div>
			</div>
<?php 
include "../includes/footer.template.php"
?>
