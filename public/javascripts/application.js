$(document).ready(function () { 

	// Tabs
	$(".tabs").tabs({ //spinner: 'Retrieving data...', // requires <span>link</span>
					  cache: true,
					  // selected: -1,
					  // collapsible: true,
					  add: function(event, ui) {
				      	$(this).tabs('select', ui.index); //'#' + ui.panel.id
				      },
					  fx: { opacity: 'toggle' },
					  ajaxOptions: { dataType: 'html' }
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

//////////////////////////////

	$("[data-meta_key] div.expander a").live("click", function() {
		var parent = $(this).closest("[data-meta_key]");
		var children = parent.nextAll("[data-parent_meta_key='" + parent.attr("data-meta_key") + "']");

		// NOTE doesn't work with toggler because copyright custom behavior
		if($(this).hasClass("expanded")){
			$(this).removeClass("expanded");
			children.slideUp(); 
		}else{
			$(this).addClass("expanded");
			children.slideDown();
		}

		// NOTE copyright custom behavior
		children.find("select.nested_options:visible, select.options_root").trigger('change');

		return false;
	});


//////////////////////////////

	$("textarea").elastic();
	
});


function create_multiselect_widget(dom_scope, is_extensible, with_toggler){
  var search_field = $("#"+ dom_scope +"_multiselect input[name='autocomplete_search']");
  var all_options = search_field.data("all_options");
  if (with_toggler) {
	$("#"+ dom_scope +"_multiselect").append("<a class='search_toggler' href='#'><img src='/images/icons/toggler-arrow-closed.png'></a>");
	var toggler = $("#"+ dom_scope +"_multiselect a.search_toggler");
  }
  $.each(all_options, function(i, elem){
  	if(elem.selected){
	    add_to_selected_items(elem, dom_scope, false);
	}
  });

  var new_term = is_extensible;
  var just_selected = false;

  search_field.keypress(function( event ) {
    if ( event.keyCode === $.ui.keyCode.ENTER || event.keyCode === $.ui.keyCode.TAB) {
      if(new_term){
	  	var v = $(this).val();
	    if ($.trim(v).length){
		  	var item = {label: v, id: v};
	        add_to_selected_items(item, dom_scope, true);
			$(this).autocomplete( "close" );
		}
      }
      event.preventDefault();
    }else{
      new_term = is_extensible;
    }
  }).autocomplete({
    source: function(request, response){
      var unselected_options = all_options.filter(function(elem){ if(!elem.selected) return elem; });
      response($.ui.autocomplete.filter(unselected_options, request.term) );
    },
    minLength: 3,
    select: function(event, ui) {
	  new_term = false;
      add_to_selected_items(ui.item, dom_scope, false);
	  just_selected = true;
    },
    close: function(event, ui) {
	  search_field.autocomplete("option", "minLength", 3);
		if(just_selected){
			$(this).val("");
			just_selected = false;
		}
	  if (toggler != undefined) toggler.removeClass("active").find("img").attr("src", "/images/icons/toggler-arrow-closed.png");
    }
  });
  
  if (toggler != undefined) {
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
    };

	$("ul.holder li .closebutton").live('click', function(){
		remove_from_selected_items($(this).parent("li"));
		return false;
  	});


	function remove_from_selected_items(dom_item){
	  	var meta_term_id = dom_item.find('input[type=hidden]:first').val();
		all_options.forEach(function(element){ if(element.id == meta_term_id) element.selected = false; });

		// remove from pre-sorted keyoword tabs
		var keyword_holder = dom_item.closest('#keywords_multiselect');
		if (keyword_holder.length > -1){
			$('.holder.all .bit-box[rel="'+meta_term_id+'"]').show();
		}
		
		dom_item.fadeOut('slow', function() {
			dom_item.remove();
		});   
	};
};

function add_to_selected_items(item, dom_scope, add_to_options){
	var search_field = $("#"+ dom_scope +"_multiselect input[name='autocomplete_search']");
	if(add_to_options || !item.selected){
		var all_options = search_field.data("all_options");
		if(add_to_options){
			item.selected = true;
			all_options.push(item);
		}else if(!item.selected){
			all_options.forEach(function(element){ if(element.id == item.id) element.selected = true; });  	
		}
	}
	$("#"+ dom_scope + "_madek_multiselect_item").tmpl(item).insertBefore($("#"+ dom_scope +"_multiselect ul.holder li.input_holder")).fadeIn('slow');
	search_field.val("");
};
