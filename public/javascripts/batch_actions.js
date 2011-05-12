$(document).ready(function () {
	
  	// hover functions for batch action buttons - highlight selected entries for which action is possible 
  	$("#batch-edit").hover(
      function () { selected_items_highlight_on('.edit'); }, 
      function () { selected_items_highlight_off('.edit'); }
    );
  
    $("#batch-add-to-set").hover(
      function () { selected_items_highlight_on('.thumb_mini'); }, 
      function () { selected_items_highlight_off('.thumb_mini'); }
    );
    
    $("#batch-permissions").hover(
      function () { selected_items_highlight_on('.manage'); }, 
      function () { selected_items_highlight_off('.manage'); }
    );

	// batch edit meta data
    $("#batch-edit form").submit(function() {
      var editable_ids = new Array();
      $("#selected_items .edit").each(function(i, elem){
        editable_ids.push($(this).attr("rel"));
      });
      $(this).append("<input type='hidden' name='media_entry_ids' value='"+editable_ids+"'>");
    });
    
	// batch edit permissions
    $("#batch-permissions form").submit(function() {
      var managable_ids = new Array();
      $("#selected_items .manage").each(function(i, elem){
        managable_ids.push($(this).attr("rel"));
      });
      $(this).append("<input type='hidden' name='media_entry_ids' value='"+managable_ids+"'>");
    });
  
	// add to set
    $("#batch-add-to-set form").submit(function() {
      var editable_ids = new Array();
      $("#selected_items .thumb_mini").each(function(i, elem){
        editable_ids.push($(this).attr("rel"));
      });
      $(this).append("<input type='hidden' name='media_entry_ids' value='"+editable_ids+"'>");
    });

    $(".item_box:not(.tmp)").live({
      mouseenter: function() {
        $(this).find('.actions').show();
		$(this).stop(true, true).delay(400).animate({ backgroundColor: "#f1f1f1" }, 500);
       },
      mouseleave: function() {
        $(this).find('.actions').hide();
		// only remove bg color if not selected in batch context
		if (!($(this).hasClass('selected'))) $(this).stop(true, false).animate({ backgroundColor: "white" }, 1000);
       }
     });

});


/////////////////////////////////////////////////////////
// UTILITY ARRAY FUNCTIONS

/* destructively finds the intersection of 
 * two arrays in a simple fashion.  
 *
 * PARAMS
 *  a - first array
 *  b - second array
 *
 * NOTES
 *  State of input arrays is undefined when
 *  the function returns.  They should be 
 *  (prolly) be dumped.
 *
 *  Should have O(n) operations, where n is 
 *    n = MIN(a.length(), b.length())
 */
function intersection_destructive(a, b) {
  var a = a.sort();
  var b = b.sort();
  var result = new Array();
  while( a.length > 0 && b.length > 0 ) {  
     if      (a[0] < b[0] ){ a.shift(); }
     else if (a[0] > b[0] ){ b.shift(); }
     else { /* they're equal */
       result.push(a.shift());
       b.shift();
     }
  }
  return result;
}

function removeItems(array, item) {
	var i = 0;
	while (i < array.length) {
		if (array[i] == item) {
			array.splice(i, 1);
		} else {
			i++;
		}
	}
	return array;
}

/////////////////////////////////////////////////////

function setupBatch(json, media_set_id, media_entry_ids_in_set) {
	display_results(json);
    listSelected();
    displayCount();
	
	$("footer").css("margin-bottom", "130px");
	
	// when remove from set is hovered we only want to highlight those media_entries that are part of the current set
	if(media_set_id && media_entry_ids_in_set){
		var media_entry_ids = get_selected_media_entry_ids();
		var media_entries_in_set = intersection_destructive(media_entry_ids_in_set, media_entry_ids);
	}; //end if
	
	
	$('a.delete_me[data-method="delete"]').live('ajax:success', 
		function(e, data, textStatus, jqXHR){
			$('#thumb_' + data.id).remove();
		    
		    // remove also from sessionStorage and selectedItems
			var media_entries_json = get_media_entries_json();
			var media_entry_ids = $.map(media_entries_json, function(elem, i){ if (elem != null) return parseInt(elem.id); });
			var i = media_entry_ids.indexOf(data.id);
			if (i > -1){
				media_entries_json.splice(i, 1);
				$('#selected_items [rel="'+data.id+'"]').remove();
				if (media_entries_in_set != undefined){ removeItems(media_entries_in_set, data.id) };
				set_media_entries_json(JSON.stringify(media_entries_json));
			    displayCount();
			}
  		}
    );
	
	// make thumbnails removable from the selected items bar
    $('#selected_items .thumb_mini').live("hover", function() {
        $(this).children('img.thumb_remove').toggle();
    }).live("click", function() {
		var id = $(this).attr("rel");
		$(this).remove();
		toggleSelected(id);
    });

    $("span.check_box").live("click", function(){
		toggleSelected($(this).closest(".item_box").data("object"));
    });

	$("#select_deselect_all input:checkbox").click(function() {	
	  var media_entries_json = get_media_entries_json();		
	  if ($(this).is(":checked")) {
		// select all the visible and not already selected items
		$(".item_box").each(function(i, elem) { 
			var me = $(elem).data("object");
			var i = is_Selected(media_entries_json, me.id);
			// if not yet selected
			if((i == -1)) {
		        media_entries_json.push(me);
		        $(elem).addClass('selected').find('span.check_box img').attr('src', '/images/icons/button_checkbox_on.png');
		        $('#selected_items').append($("#thumbnail_mini").tmpl(me));
				if (media_entries_in_set != undefined){ media_entries_in_set.push(me.id) };
			};	
		});
		set_media_entries_json(JSON.stringify(media_entries_json));
	    displayCount();
	  } else {
		// remove everything from the action bar
		$.each(media_entries_json, function(i, me){
			$('#thumb_' + me.id).removeClass('selected').removeAttr("style").find('span.check_box img').attr('src', '/images/icons/button_checkbox_off.png');
			$('#selected_items [rel="'+me.id+'"]').remove();
			sessionStorage.removeItem("selected_media_entries");
			if (media_entries_in_set != undefined) media_entries_in_set = new Array();
		});
		displayCount();
	  };
	});

    $("#batch-remove").hover(
      function () { 
	 	$.each(media_entries_in_set, function(i, id){
		  $('#selected_items [rel="'+id+'"]').css("background-color", "#FEFFD7");
		});
	   }, 
      function () { 
		$.each(media_entries_in_set, function(i, id){
		  $('#selected_items [rel="'+id+'"]').css("background-color", "white");
		});
	  }
    );

	// remove from set
    $("#batch-remove form").submit(function() {
      $(this).append("<input type='hidden' name='media_entry_ids' value='"+media_entries_in_set+"'>");
    });

	function toggleSelected(me) {
		var media_entries_json = get_media_entries_json();
		var id = (typeof(me) == "object" ? me.id : parseInt(me));
		var i = is_Selected(media_entries_json, id);
		
		if(i > -1) {
			media_entries_json.splice(i, 1);
			$('#thumb_' + id).removeClass('selected').removeAttr("style").find('span.check_box img').attr('src', '/images/icons/button_checkbox_off.png');
			$('#selected_items [rel="'+id+'"]').remove();
			if (media_entries_in_set != undefined){ removeItems(media_entries_in_set, id) };
		} else {
	        media_entries_json.push(me);
	        $('#thumb_' + id).addClass('selected').find('span.check_box img').attr('src', '/images/icons/button_checkbox_on.png');
	        $('#selected_items').append($("#thumbnail_mini").tmpl(me));
			if (media_entries_in_set != undefined){ media_entries_in_set.push(id) };
		};

		set_media_entries_json(JSON.stringify(media_entries_json));
	    displayCount();
	};

}

function selected_items_highlight_on(selector){
  $('#selected_items '+selector).css("background-color", "#FEFFD7");
}
function selected_items_highlight_off(selector){
  $('#selected_items '+selector).css("background-color", "white");
}

function listSelected() {
	var media_entries_json = get_media_entries_json();
	// display all previously selected items under taskbar 
	// TODO: this method needs to make sure that all ME in sessionStorage still exist
	$('#selected_items').html($("#thumbnail_mini").tmpl(media_entries_json));
};


function displayCount() {
	var media_entries_json = get_media_entries_json();
	var count_checked = media_entries_json.length;
	var display_count = $('li#number_selected');
	//don't show action buttons until something is actually selected
	if (count_checked) {
		$('#selected_items').show();
		$('.task_bar .action_btn').show();
	    if (count_checked > 1) {
			display_count.html(count_checked + " Medieneinträge ausgewählt.");
		}else{
	        display_count.html("1 Medieneintrag ausgewählt.");
		}
	} else {
		$('.task_bar .action_btn').hide();
		display_count.html("Keine Medieneinträge ausgewählt.");
		$('#selected_items').hide();
	};
};

function display_results(json, container){
	var container = container ? $("#" + container) : $("#results");
	var loading = container.find(".loading");
	var pagination = json.pagination;
	var loaded_page = 1;
	
	function display_entries(entries){
		loading.fadeOut('slow', function(){ $(this).detach(); });
		container.append($("#pagination").tmpl(pagination).fadeIn('slow'));
		$.each(entries, function(i, elem) {
			$("#index").tmpl(elem).data('object', elem).appendTo(container).fadeIn('slow');
		});
		container.append("<div class='clear' />");
		//check all the previously selected checkboxes
		var selected_entries = get_selected_media_entry_ids();
		$.each(selected_entries, function(i, id) {
			$('#thumb_' + id).addClass('selected').find('span.check_box img').attr('src', '/images/icons/button_checkbox_on.png');
		});
	}
	
	$(window).scroll(function(){
	  var next_page = (pagination.total_pages > pagination.current_page ? pagination.current_page + 1 : 0);
	  if(next_page > loaded_page && $(window).height() + $(window).scrollTop() > $("footer").offset().top){
	    loaded_page = next_page;
			if(t = $('#detail_specification')){
				var h = {page: next_page, page_type: t.find("div:visible:first").attr("id")};
			}else{
				var h = {page: next_page};
			}
	    $.ajax({
	      data: h,
	    	dataType: 'json',
	      beforeSend: function(){
			  	loading.appendTo(container).fadeIn('slow');
	      }, 
	      success: function(response){
	        pagination = response.pagination;
					display_entries(response.entries);
					$('#select_all_toggle').attr('checked', false);
	      }
	    });
	  }
	});
	
	display_entries(json.entries);
	$(window).scrollTop(0).trigger('scroll');
};
