<?php
session_start();
if( isset( $_GET['logout'] ) ) {
	unset($_SESSION['mineremote_password']);
} else if( isset( $_POST['pwd'] ) ){ 
	$_SESSION['mineremote_password'] = $_POST['pwd'];
}
include( "header.php" );
?>
<title>Minecraft Web Terminal</title>
<link rel="stylesheet" type="text/css" href="mcterm.css" />
<?php if( !isset( $_SESSION['mineremote_password'] ) ): ?>
<script type="text/javascript">
//<![CDATA[
$( function() {
	$("#submit_btn").click( function() {
		this.form.submit();
	});
});
//]]>
</script>
</head>
<body>
<h3>Minecraft Web Terminal</h3>
<form action="index.php" method="POST">
<b>Sever Password:</b>
<input type="password" name="pwd" /><button type="button" id="submit_btn">OK</button><br/>
</form>
<?php else: ?>
<script type="text/javascript" src="mcterm.js"></script>
</head>
<body>
<h3>Minecraft Web Terminal</h3>
<div id="chat_page">
	<div id="chat_frame">
		<div id="response_window">
			<div><b>Welcome to the Minecraft Web Terminal.</b><br/>Connecting...</div>
		</div>
		<div id="input_window">
			<input type="text" id="input_field" />
		</div>
	</div>
	<div id="who_frame">
<!--		<div id="who_title">Users Online</div> -->
		<div id="who_list"></div>
	</div>
</div>
<div style="clear: both;">
<button type="button" id="logout_btn">Logout</button>
</div>
<?php endif; ?>

</body>
</html>