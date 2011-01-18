<?php 
include( "mc_interface.php" );

if( isset( $_POST['action'] ) ) {

	if( $_POST['action'] == 'post' && isset( $_POST['msg'] ) ) {
		echo run_cmd( $_POST['msg'] );
	} else if( $_POST['action'] == 'poll') {
		echo poll_server_msgs();
	} else if( $_POST['action'] == 'who' ) {
		echo run_cmd('list');
	} else if( $_POST['action'] == 'check' ) {
		if( $test = check_pwd() ) {
			echo "Logged in<br/>";
		} else {
			echo "<b style='color: red;'>ACCESS DENIED!</b><br/>\n";
			unset( $_SESSION['mineremote_password'] );
		}
	} else {
		echo "???<br/>";
	}
}
?>
