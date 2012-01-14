// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.

/////////// Gem /////////////
//= require jquery.min
//= require jquery-ui.min
//= require jquery_ujs
//= require jquery-tmpl

/////////// App /////////////
//= require batch_actions
//= require madek_ajax_upload
//= require madek11
//= require jquery/browser-check/browser-check
//= require jquery/highlight/highlight
//= require jquery/video-js/video
//= require jquery/department-selection/department-selection
//= require_tree ./jquery/widgets/ 
//= require resources/item-box

/////////// Tmpl /////////////
//= require_tree ./tmpl/

/////////// Lib /////////////
//= require jquery/browser-detection/browser-detection

/////////// Vendor /////////////
//= require_tree ../../../vendor/assets/javascripts/jquery/.
//= require modernizr.min
//= require video

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

	//////////////////////////////

	$(".description_toggler").qtip({
		position: {
			my: 'bottom left',
			at: 'top right',
			viewport: $(window)
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
					
	// For closing all open autocompletes in old tabs
	$('#detail_specification').bind('tabsselect', function(event, ui) {
		$('a.search_toggler').removeClass('active').find("img").attr("src", "/assets/icons/toggler-arrow-closed.png");
		$('input.ui-autocomplete-input').autocomplete("close");
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

/////////////////////////////////////////////////////////////
// Utility functions to read from or write to sessionStorage

function get_media_entries_json(){
	var media_entries_json = JSON.parse(sessionStorage.getItem("selected_media_entries"));
	if(media_entries_json == null) media_entries_json = new Array();
	return media_entries_json;
}

function set_media_entries_json(data){
	//1+n http-requests//
	$.each(data, function(i, elem){
		elem.thumb_base64 = "/media_entries/"+elem.id+"/image?size=small_125";
	});

	sessionStorage.setItem("selected_media_entries", JSON.stringify(data));
}

function get_selected_media_entry_ids() {
	var media_entries_json = get_media_entries_json();
	return $.map(media_entries_json, function(elem, i){ if (elem != null) return parseInt(elem.id); });
}

function is_Selected(media_entries_json, id) {
    var media_entry_ids = $.map(media_entries_json, function(elem, i){ if (elem != null) return parseInt(elem.id); });
    return media_entry_ids.indexOf(id);
}

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
	var toggler_id = search_field.attr("id").replace('autocomplete_search', 'toggler');
  	search_field.closest(".madek_multiselect_container").append("<a class='search_toggler' href='#' id='" + toggler_id + "'><img src='/assets/icons/toggler-arrow-closed.png'></a>");
	var toggler = search_field.closest(".madek_multiselect_container").find("a.search_toggler");
	
	$('body').bind('click', function(e) {
	    if($(e.target).closest('ul.ui-autocomplete').length == 0) {
        	// click happened outside of autocomplete select menu, hide any visible menu items
			toggler.removeClass("active").find("img").attr("src", "/assets/icons/toggler-arrow-closed.png");
			search_field.autocomplete("close");
	    }
	});
	
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
      var unselected_options = $(search_field).data("all_options").filter(function(elem){ if(!elem.selected) return elem; });
      response($.ui.autocomplete.filter(unselected_options, request.term) );
    },
    minLength: 3,
    select: function(event, ui) {
      if($(event.target).hasClass("department-selection")) {
        return false;
      } else {
    	  new_term = false;
        add_to_selected_items(ui.item, search_field, false);
    	  just_selected = true;
      }
    },
    close: function(event, ui) {
	  search_field.autocomplete("option", "minLength", 3);
		if(just_selected){
			$(this).val("");
			just_selected = false;
		}
	  if (toggler != undefined) toggler.removeClass("active").find("img").attr("src", "/assets/icons/toggler-arrow-closed.png");
    }
  });
  
  if (toggler != undefined) {
	toggler.click(function(){
		var elem = $(this); 
		if (elem.hasClass('active')) {
			elem.removeClass('active').find("img").attr("src", "/assets/icons/toggler-arrow-closed.png");
			search_field.autocomplete("close");
		} else {
			elem.addClass('active').find("img").attr("src", "/assets/icons/toggler-arrow-opened.png");
			close_any_open_autocompletes(elem);
			search_field.autocomplete("option", "minLength", 0);
			search_field.autocomplete("search", "");
		}
		return false;
	 });
    };

};

function close_any_open_autocompletes(elem) {
	var current_id = elem.attr("id");
	var current_search_field_id = current_id.replace('toggler', 'autocomplete_search');
	$('a.search_toggler:not(#'+ current_id +')').removeClass('active').find("img").attr("src", "/assets/icons/toggler-arrow-closed.png");
	$('input.ui-autocomplete-input:not(#' + current_search_field_id + ')').autocomplete("close");
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

// **************************************************************************
// Copyright 2007 - 2009 Tavs Dokkedahl
// Contact: http://www.jslab.dk/contact.php
//
// This file is part of the JSLab Standard Library (JSL) Program.
//
// JSL is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// any later version.
//
// JSL is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
// ***************************************************************************

// Compute the intersection of n arrays
Array.prototype.intersect =
  function() {
    if (!arguments.length)
      return [];
    var a1 = this;
    var a = a2 = null;
    var n = 0;
    while(n < arguments.length) {
      a = [];
      a2 = arguments[n];
      var l = a1.length;
      var l2 = a2.length;
      for(var i=0; i<l; i++) {
        for(var j=0; j<l2; j++) {
          if (a1[i] === a2[j])
            a.push(a1[i]);
        }
      }
      a1 = a;
      n++;
    }
    return $.unique(a); //sellittf// a.unique();
  };
// **************************************************************************
