jQuery.ajaxSetup({
	//dataType: 'html', //'script',
  	//ifModified: true,
	data: {'format':'js'}
});


function spin_flash() {
	$('#flash').html('<img src="/images/spinner.gif" />');	
}

function flash(type, msg) {
	$('#flash').html('<div class="'+type+'">'+msg+'</div>');
}

$(document).ready(function () {

	// Ajax Pagination with jQuery
	$('.pagination a').live("click", function() {
		$.ajax({
			url: $(this).attr("href"),
		    success: function(response){
		      //old// $("#content").html(response);
		      $("#results").replaceWith(response);
		    }
		});
		return false;
	});
	
	$(document).ajaxStart(function() { $("#ajaxLoading").fadeIn(); });
	$(document).ajaxStop(function() { $("#ajaxLoading").fadeOut(); });

	$("li[media_entry_id]").hide().fadeIn("slow");

//////////////////////////////
	
	// BUTTONS
	/*
	$('.fg-button').hover(
		function(){ $(this).removeClass('ui-state-default').addClass('ui-state-focus'); },
		function(){ $(this).removeClass('ui-state-focus').addClass('ui-state-default'); }
	);
	*/
	
	// MENUS    	
	$('#flat').menu({ 
		content: $('#flat').next().html(), // grab content from this page
		showSpeed: 400 
	});

    $("#menu").flickrmenu({ arrowPic: "/images/icons/arrow.png",
							arrowPicA: "/images/icons/arrow_select.png",
							arrowPicH: "/images/icons/arrow_hover.png" });
		
	// Advanced Search
	$("#open-advanced-search").click(function(){
		$("div#advanced-search-panel").slideDown("slow");

	});	

	$("#close-advanced-search").click(function(){
		$("div#advanced-search-panel").slideUp("slow");	
	});		

	$("#toggle a").click(function () {
		$("#toggle a").toggle();
	});

//////////////////////////////	
	// Metadata Box
	$("#open-metadata-container").click(function(){
		$("#metadata-container").toggle();
		$("#metadata-container-minimized").hide();

	});	

	$("#close-metadata-container").click(function(){
		$("#metadata-container").toggle();
		$("#metadata-container-minimized").show();
	});
	
	// Settings Box
	$("#open-settings-container").click(function(){
		$("#settings-container").toggle();
		$("#settings-container-minimized").hide();

	});	

	$("#close-settings-container").click(function(){
		$("#settings-container").toggle();
		$("#settings-container-minimized").show();
	});
//////////////////////////////	
		
	// Action Bar
	$("a[panel]").click(function(){
		to_open = !$(this).hasClass("active");
		
		$("a.active[panel]").each(function () {
			$(this).removeClass("active");
			$(this).css("background", "");
			$("div#"+$(this).attr("panel")+"-panel").slideUp("slow");
		});

		if(to_open){
			$(this).addClass("active");
			$(this).css("background", "transparent url('/images/icons/arrow-up-04.png') 50% bottom no-repeat");
			$("div#"+$(this).attr("panel")+"-panel").slideDown("slow");
		}
	});
		
//////////////////////////////

	$("textarea").elastic();

//////////////////////////////

	var actions_parent_containers = $("tr:has(td.with_actions), ul[data-meta_key]:has(.with_actions)"); 
	actions_parent_containers.live('mouseover', function(){
		$(this).find(".with_actions").css('visibility', 'visible');
	});
	actions_parent_containers.live('mouseout', function(){
		$(this).find(".with_actions").css('visibility', 'hidden');
	});

//////////////////////////////
// placeholder

	function hasPlaceholderSupport() {
		var i = document.createElement('input');
		return 'placeholder' in i;
	}
	
	if(!hasPlaceholderSupport()){
		$("form").placeholder();
	};

//////////////////////////////
// extending jQuery
(function($) {
		$.widget("ui.combobox", {
			_create: function() {
				var self = this;
				var select = this.element.hide();
				var input = $("<input>")
					.insertAfter(select)
					.autocomplete({
						source: function(request, response) {
							var matcher = new RegExp(request.term, "i");
							response(select.children("option").map(function() {
								var text = $(this).text();
								if (!request.term || matcher.test(text))
									return {
										id: $(this).val(),
										label: text.replace(new RegExp("(?![^&;]+;)(?!<[^<>]*)(" + request.term.replace(/([\^\$\(\)\[\]\{\}\*\.\+\?\|\\])/gi, "\\$1") + ")(?![^<>]*>)(?![^&;]+;)", "gi"), "<strong>$1</strong>"),
										value: text
									};
							}));
						},
						delay: 0,
						select: function(e, ui) {
							if (!ui.item) {
								// remove invalid value, as it didn't match anything
								$(this).val("");
								return false;
							}
							$(this).focus();
							select.val(ui.item.id);
							self._trigger("selected", null, {
								item: select.find("[value='" + ui.item.id + "']")
							});
							
						},
						minLength: 0
					})
					.addClass("ui-widget ui-widget-content ui-corner-left");
				$("<button>&nbsp;</button>")
				.insertAfter(input)
				.button({
					icons: {
						primary: "ui-icon-triangle-1-s"
					},
					text: false
				}).removeClass("ui-corner-all")
				.addClass("ui-corner-right ui-button-icon")
				.position({
					my: "left center",
					at: "right center",
					of: input,
					offset: "-1 0"
				}).css("top", "")
				.click(function() {
					// close if already visible
					if (input.autocomplete("widget").is(":visible")) {
						input.autocomplete("close");
						return;
					}
					// pass empty string as value to search for, displaying all results
					input.autocomplete("search", "");
					input.focus();
				});
			}
		});

	})(jQuery);


});
