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

function create_multiselect_widget(dom_scope, all_options, selected_option_ids, selected_options) {
  
  $.each(selected_options, function(i, elem){
    add_to_selected_items(elem, dom_scope);
  });

  $("#"+ dom_scope +"_multiselect input[name='autocomplete_search']").autocomplete({
    source: function(request, response){
      var selected_option_ids = $("#"+ dom_scope +"_multiselect ul.holder li input[type='hidden']").map(function() { return parseInt(this.value); });
      var unselected_options = all_options.filter(function(elem){ if($.inArray(elem.id, selected_option_ids) < 0) return elem; });
      response($.ui.autocomplete.filter(unselected_options, request.term) );
    },
    minLength: 3,
    select: function(event, ui) {
      add_to_selected_items(ui.item, dom_scope);
    },
    close: function(event, ui) {
      $(this).val("");
    }
  });

  $("ul.holder li .closebutton").live('click', function(){
    remove_from_selected_items($(this).parent("li"));
  });
};

function add_to_selected_items(item, dom_scope){
  var template_id = "#"+ dom_scope + "_madek_multiselect_item";
  $("#"+ dom_scope +"_multiselect ul.holder").append($(template_id).tmpl(item).fadeIn('slow'));
};
function remove_from_selected_items(dom_item){
  dom_item.fadeOut('slow', function() {
    dom_item.remove();
  });
};