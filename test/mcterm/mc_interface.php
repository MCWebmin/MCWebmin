<?php
include( "mcterm_cfg.php" );

@session_start();

//get password
if( isset( $_SESSION['mineremote_password'] ) ) {
	$password = $_SESSION['mineremote_password'];
} else {
	$password = "";
}

//checks to see if the password is valid
function check_pwd() {
	global $server, $port, $password;
	$rval = FALSE;
	
	$socket = socket_create( AF_INET, SOCK_STREAM, SOL_TCP );
	if( socket_connect( $socket, $server, $port ) === FALSE ) {
		exit( socket_strerror( socket_last_error( $socket ) ) );
	}
	
	//check the prompt line
	$line = socket_read( $socket, 1024 );
	if( preg_match( '/no password/i', $line ) ) {
		//no password set
		$rval = TRUE;
	} else {
		//send the password and check the resposne
		socket_write( $socket, $password );
		$line = socket_read( $socket, 1024 );
		if( substr_compare( '+ Access granted', $line, 0, 16 ) == 0 ) {
			$rval = TRUE;
		}
	}
	
	socket_close( $socket );
	
	return $rval;
}


//runs a cmd and returns the response
function run_cmd( $cmd ) {
	global $server, $port, $password, $response_delay;
	
	$socket = socket_create( AF_INET, SOCK_STREAM, SOL_TCP );
	if( socket_connect( $socket, "localhost", $port ) === FALSE ) {
		exit( socket_strerror( socket_last_error( $socket ) ) );
	}

	//check the prompt
	$line = socket_read( $socket, 1024 );
	if( !preg_match( '/no password/i', $line ) ) {
		//sign in with the password and check to see if it worked
		socket_write( $socket, $password );
		$line = socket_read( $socket, 1024 );
		if( substr_compare( '+ Access granted', $line, 0, 16 ) != 0 ) {
			
			return "<b style='color: red;'>ACCESS DENIED!</b><br/>\n";
		}
	}
	
	//do the command
	socket_write( $socket, $cmd );

	$socket_list = Array( $socket );
	$null = NULL;

	//read the response allowing $response_delay seconds between lines before closing the connection
	$line = "";
	while( socket_select( $socket_list, $null, $null, $response_delay ) != FALSE ) {
		$line .= socket_read( $socket, 1024 )."<br/>";
		$socket_list = Array( $socket );
	}
	
	//close the connection
	socket_close( $socket );
	
	//return the response
	return $line;
}

//This just checks for msgs on the server and returns the first that it finds
//This is following the long-poll model for persistent ajax connections
function poll_server_msgs() {
	global $server, $port, $password, $poll_timer;
	
	$socket = socket_create( AF_INET, SOCK_STREAM, SOL_TCP );
	if( socket_connect( $socket, "localhost", $port ) === FALSE ) {
		exit( socket_strerror( socket_last_error( $socket ) ) );
	}

	//check the prompt
	$line = socket_read( $socket, 1024 );
	if( !preg_match( '/no password/i', $line ) ) {
		//sign in with the password and check to see if it worked
		socket_write( $socket, $password );
		$line = socket_read( $socket, 1024 );
		if( substr_compare( '+ Access granted', $line, 0, 16 ) != 0 ) {
			
			return "<b style='color: red;'>ACCESS DENIED!</b><br/>\n";
		}
	}
	
	$socket_list = Array( $socket );
	$null = NULL;

	//check for any msgs 
	$line = "";
	if( socket_select( $socket_list, $null, $null, $poll_timer ) != FALSE ) {
		$line .= socket_read( $socket, 1024 )."<br/>";
		$socket_list = Array( $socket );
	}
	
	//close the connection
	socket_close( $socket );
	
	//return the response
	return $line;
}
?>
