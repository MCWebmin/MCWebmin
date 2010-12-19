<html>
<?php
include 'functions.php';

//Stops the running server
stopServer();
//Download the new server file, backup the old one
upgrade();
//Start the server
startServer();
?>
<br><a href="../index.php">BACK</a>

</html>
