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

function create_multiselect_widget(dom_scope, selected_option_ids, selected_options) {
  var search_field = $("#"+ dom_scope +"_multiselect input[name='autocomplete_search']");
  var toggler = search_field.next(".search_toggler");
  var all_options = search_field.data("all_options");

  $.each(selected_options, function(i, elem){
    add_to_selected_items(elem, dom_scope);
  });

  search_field.autocomplete({
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
	  var elem = $(this);
	  search_field.autocomplete("option", "minLength", 3);
  	  if(elem.val().length > 2) elem.val("");
	  toggler.removeClass("active").find("img").attr("src", "/images/icons/toggler-arrow-closed.png");
    }
  });
  
  toggler.click(function(){
  	var elem = $(this); 
	if (elem.hasClass('active')) {
		elem.removeClass('active').find("img").attr("src", "/images/icons/toggler-arrow-closed.png");
		search_field.autocomplete("close");
	} else {
		elem.addClass('active').find("img").attr("src", "/images/icons/toggler-arrow-opened.png");
		search_field.autocomplete("option", "minLength", 0);
		search_field.autocomplete("search", "");
	}
	
	return false;
  });

  $("ul.holder li .closebutton").live('click', function(){
    remove_from_selected_items($(this).parent("li"));
	return false;
  });
};

function add_to_selected_items(item, dom_scope){
  var template_id = "#"+ dom_scope + "_madek_multiselect_item";
  $("#"+ dom_scope +"_multiselect ul.holder").append($(template_id).tmpl(item)); //.fadeIn('slow'));
};

function remove_from_selected_items(dom_item){
  // remove from pre-sorted keyoword tabs
  var keyword_holder = dom_item.closest('#keywords_multiselect');
  if (keyword_holder.length > -1){
   var meta_term_id = dom_item.find('input[type=hidden]:first').val();
   $('.holder.all .bit-box[rel="'+meta_term_id+'"]').show();
  }
  dom_item.fadeOut('slow', function() {
    dom_item.remove();
  });   
};