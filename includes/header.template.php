<html>
<head>
<title>MCWebmin</title>
<-- Include PHP Files -->
<?php 
include "config.php";
include "functions.php";
include "rcon.class.php"; 
?>
<-- Background -->
<body background="http://www.minecraft.net/img/bg.gif">

<-- CSS Stylesheets -->
<link rel="stylesheet" href="/css/style.css" type="text/css">
<link rel="stylesheet" href="/css/greybox.css" type="text/css" media="all" />

<!-- Javascript -->
<script type="text/javascript" src="/gs/greybox.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script>
<script type="text/javascript">
      var GB_ANIMATION = true;
      $(document).ready(function(){
        $("a.greybox").click(function(){
          var t = this.title || $(this).text() || this.href;
          GB_show(t,this.href,470,600);
          return false;
        });
      });
</script>
	
<!-- Header Image -->
<center><img src="http://www.minecraft.net/img/logo_small.gif" alt="minecraft"></center>
