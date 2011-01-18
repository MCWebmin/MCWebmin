var auto_scroll = true;
var poll_timer;

function poll() {
	$.post('mcterm.php', { action: "poll" }, function( data ) {
		$("#response_window").append( data );
		do_scroll(document.getElementById("response_window"));
		$("#who_list").load( "mcterm.php", { action: "who" }, function() {
			poll_timer = setTimeout( "poll()", 1 );
		});
	});
}

function load() {
	$("#response_window").load( "mcterm.php", {action: "check"}, function() {
		$("#who_list").load( "mcterm.php", { action: "who" } );
		poll();
	});
}

function handle_scroll(event) {
	auto_scroll = false;
}

function do_scroll(frame) {
	if( auto_scroll ) {
		$("#response_window").unbind('scroll', handle_scroll );
		frame.scrollTop = frame.scrollHeight;
		$("#response_window").bind('scroll', handle_scroll );
	}
}

$( function() {
	$("#input_field")
	.keydown( function(e) {
		if( e.which == 13 ) {
			$.post('mcterm.php', { id: $("#id").val(), msg: this.value, action: "post" }, function( data ) {
				$("#response_window").append( data );
				auto_scroll = true;
				do_scroll(document.getElementById("resposne_window"));
			});
			$(this).val(""); //value="";
		}
	});

	poll_timer = setTimeout( "load()", 100 );

	$("#input_field").focus();
	
	$("#logout_btn").click( function() {
		clearTimeout( poll_timer );
		window.location = window.location+"?logout=1";
	});
});
