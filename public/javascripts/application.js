$(document).ready(function () { 

	// Tabs
	$(".tabs").tabs({ //spinner: 'Retrieving data...', // requires <span>link</span>
					  cache: true,
					  // selected: -1,
					  // collapsible: true,
					  add: function(event, ui) {
				      	$(this).tabs('select', ui.index); //'#' + ui.panel.id
				      },
					  fx: { opacity: 'toggle' }
					});

//////////////////////////////

	$("a.description_toggler").live("mouseenter mouseleave click", function(event) {
		if (event.type == 'mouseenter') {
			$(this).next(".dialog").show();
		} else if (event.type == 'mouseleave') {
			$(this).next(".dialog").hide();
		} else {
			return false;
		}
	});

	$(".dialog").live("mouseenter mouseleave", function(event) {
		if (event.type == 'mouseenter') {
			$(this).show();
		} else {
			$(this).hide();
		}
	});

	
});