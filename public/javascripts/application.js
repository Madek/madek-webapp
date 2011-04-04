function document_ready(){
	$("textarea").elastic();

	//////////////////////////////

	$(".madek_multiselect_container").each(function(){
		var that = $(this);
		if(!that.data("ready")){
			var search_field = that.closest("[data-meta_key]").find("input[name='autocomplete_search']");
			create_multiselect_widget(search_field, that.data("is_extensible"), that.data("with_toggle"));
			that.data("ready", true);                     
		}
	});
}

$(document).ajaxComplete(document_ready);

$(document).ready(function () { 

	document_ready();
	
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
// placeholder

	function hasPlaceholderSupport() {
		var i = document.createElement('input');
		return 'placeholder' in i;
	}
	
	if(!Modernizr.input.placeholder && !hasPlaceholderSupport()){
		$("form").placeholder();
	};
	
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

	//////////////////////////////
	// TODO move to keywords.js
	
		$(".holder.all .bit-box").live('click', function(){
			var item = {label: $(this).attr("title"), id: $(this).attr("rel")};
	        var parent_block = $(this).closest("[data-meta_key]");
	        var search_field = parent_block.find("input[name='autocomplete_search']");
			add_to_selected_items(item, search_field, false);
			hide_keyword(parent_block, $(this).attr("rel"));
		});
	
		$("[data-meta_key='keywords'] input[name='autocomplete_search']").bind("autocompleteselect", function(event, ui) {
			var parent_block = $(this).closest("[data-meta_key]");
	  		hide_keyword(parent_block, ui.item.id);
		});
	
		$("ul.holder li .closebutton").live('click', function(){
			remove_from_selected_items($(this).parent("li"));
			return false;
	  	});
	//////////////////////////////
	
});

//////////////////////////////
// TODO move to keywords.js

	function hide_keyword(parent_block, rel){
		parent_block.find('.holder.all .bit-box[rel="'+rel+'"]').hide();
	}

	function hide_selected_keywords(holder){
		holder.find("li.bit-box input[type=hidden]").each(function(){
			var parent_block = $(this).closest("[data-meta_key]");
			hide_keyword(parent_block, $(this).attr("value"));
		});
	}

//////////////////////////////


function create_multiselect_widget(search_field, is_extensible, with_toggler){
  var all_options = search_field.data("all_options");
  if (with_toggler) {
  	search_field.closest(".madek_multiselect_container").append("<a class='search_toggler' href='#'><img src='/images/icons/toggler-arrow-closed.png'></a>");
	var toggler = search_field.closest(".madek_multiselect_container").find("a.search_toggler");
  }
  $.each(all_options, function(i, elem){
  	if(elem.selected){
	    add_to_selected_items(elem, search_field, false);
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
	        add_to_selected_items(item, search_field, true);
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
      add_to_selected_items(ui.item, search_field, false);
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

};

function remove_from_selected_items(dom_item){
	var parent_block = dom_item.closest('[data-meta_key]');
	var search_field = parent_block.find("input[name='autocomplete_search']");
	var all_options = search_field.data("all_options");
  	var meta_term_id = dom_item.find('input[type=hidden]:first').val();
	all_options.forEach(function(element){ if(element.id == meta_term_id) element.selected = false; });

	// remove from pre-sorted keyword tabs
	parent_block.find('.tabs ul.holder.all .bit-box[rel="'+meta_term_id+'"]').show();

	dom_item.fadeOut('slow', function() {
		dom_item.remove();
	});   
};

function add_to_selected_items(item, search_field, add_to_options){
	if(add_to_options || !item.selected){
		var all_options = search_field.data("all_options");
		if(add_to_options){
			item.selected = true;
			all_options.push(item);
		}else if(!item.selected){
			all_options.forEach(function(element){ if(element.id == item.id) element.selected = true; });  	
		}
	}
	item.field_name_prefix = search_field.data("field_name_prefix");
	$("#madek_multiselect_item").tmpl(item).insertBefore(search_field.parent()).fadeIn('slow');
	search_field.val("");
};
