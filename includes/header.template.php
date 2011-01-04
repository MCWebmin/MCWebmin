<html>
<head>
<title>MCWebmin</title>
<!-- Include PHP Files -->
<?php 
include "config.php";
include "functions.php";
include "rcon.class.php"; 
?>

<!-- CSS Stylesheets -->
<link rel="stylesheet" href="css/style.css" type="text/css">
<link rel="stylesheet" href="css/greybox.css" type="text/css" media="all" />
<link rel="stylesheet" href="http://yui.yahooapis.com/2.8.0r4/build/reset-fonts-grids/reset-fonts-grids.css" type="text/css">
<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/base/base-min.css">

<!-- Javascript -->
<script type="text/javascript" src="js/greybox.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script>
<script type="text/javascript">
      var GB_ANIMATION = true;
      $(document).ready(function(){
        $("a.greybox").click(function(){
          var t = this.title || $(this).text() || this.href;
          GB_show(t,this.href,200,200);
          return false;
        });
      });
</script>
				
<div id="doc3" class="yui-t2">
	<div id="hd">
		<p class="theheader">
			<span class="alignleft"><span class="servicetitle">MCWebmin</span></span>
			<span class="alignright"><a href="">Settings</a> | <a href="">Sign out</a></span>
						
		</p>
	</div>