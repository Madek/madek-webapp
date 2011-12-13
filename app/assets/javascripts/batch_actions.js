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
	 $("#batch-add-to-set form select").change(function() {
	   $("#batch-add-to-set form").submit();
	 });
	
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

	$(".page[data-page]").live("inview", function() {
		var $this = $(this);
		var next_page = $this.data('page');
		$this.removeAttr("data-page");

		var options = {
				dataType: 'json',
				//data: {page: next_page},
				success: function(response){
					display_page(response, $this);
				}
			}; 
		var f = $(".filter_content form:first");
		if(f.length){
			options.url = f.attr('action');
			options.type = f.attr('method');
			options.data = f.serializeArray();
			options.data.push({name: 'page', value: next_page});
		}else{
			options.data = {page: next_page};
		}
	    $.ajax(options);
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
	if(json != undefined) display_results(json);
    listSelected();
    displayCount();

	// display the task_bar only whether there is something selectable or something is already selected
	if(get_media_entries_json().length == 0 && $(".item_box").has(".check_box").length == 0){
		$('.task_bar').hide();
		return false;
	}
	// hide the select_deselect_all checkbox on the browse page
	if($(".item_box .check_box").length < 2) {
		$("#batch-select-all").hide();
		$("#batch-deselect-all").hide();
		$("#batch-deselect-all").next().hide();
	}

	// when remove from set is hovered we only want to highlight those media_entries that are part of the current set
	if(media_set_id && media_entry_ids_in_set){
		var media_entry_ids = get_selected_media_entry_ids();
		var media_entries_in_set = intersection_destructive(media_entry_ids_in_set, media_entry_ids);
	}
	
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
				set_media_entries_json(media_entries_json);
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
		
		//TODO dry// display the task_bar only whether there is something selectable or something is already selected
	    if(get_media_entries_json().length == 0 && $(".item_box").has(".check_box").length == 0){
	      $('.task_bar').hide();
	    }
    });

    $(".check_box").live("click", function(){
		toggleSelected($(this).closest(".item_box").tmplItem().data);
    });

  // select all function
  $("#batch-select-all").click(function(event){
    event.preventDefault();
    var media_entries_json = get_media_entries_json();
    // select all the visible and not already selected items
    $(".item_box").has(".check_box").each(function(i, elem) { 
      var me = $(elem).tmplItem().data;
      var i = is_Selected(media_entries_json, me.id);
      // if not yet selected
      if((i == -1)) {
            media_entries_json.push(me);
            $(elem).addClass('selected');
            $('#selected_items').append($("#thumbnail_mini").tmpl(me));
        if (media_entries_in_set != undefined){ media_entries_in_set.push(me.id) };
      };  
    });
    set_media_entries_json(media_entries_json);
    displayCount();
    return false;
  });
  
  // deselect all function
  $("#batch-deselect-all").click(function(event){
    event.preventDefault();
    var media_entries_json = get_media_entries_json();
    // remove everything from the action bar
    $.each(media_entries_json, function(i, me){
      $('#thumb_' + me.id).removeClass('selected').removeAttr("style");
      $('#selected_items [rel="'+me.id+'"]').remove();
      sessionStorage.removeItem("selected_media_entries");
      if (media_entries_in_set != undefined) media_entries_in_set = new Array();
    });
    displayCount();
    return false;
  });
  
	////

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
			$('#thumb_' + id).removeClass('selected').removeAttr("style");
			$('#selected_items [rel="'+id+'"]').remove();
			if (media_entries_in_set != undefined){ removeItems(media_entries_in_set, id) };
			$("#positionable").fadeOut(); // only on browse page
		} else {
	        media_entries_json.push(me);
	        $('#thumb_' + id).addClass('selected');
	        $('#selected_items').append($("#thumbnail_mini").tmpl(me));
			if (media_entries_in_set != undefined){ media_entries_in_set.push(id) };
		};

		set_media_entries_json(media_entries_json);
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
			display_count.html(count_checked + " Medieneinträge ausgewählt");
		}else{
	        display_count.html("1 Medieneintrag ausgewählt");
		}
	} else {
		$('.task_bar .action_btn').hide();
		$('.task_bar .seperator').hide();
		display_count.html("Keine Medieneinträge ausgewählt");
		$('#selected_items').hide();
	};

	if($('#selected_items .edit').length){ $("#batch-edit").show(); }else{ $("#batch-edit").hide(); }
	if($('#selected_items .manage').length){ $("#batch-permissions").show(); }else{ $("#batch-permissions").hide(); }
	if($("#batch-edit:visible").length || $("#batch-permissions:visible").length) { $(".task_bar .seperator.edit").show(); }else{ $(".task_bar .seperator.edit").hide(); }
	if($('#selected_items .thumb_mini').length){ 
	  $("#batch-add-to-set").show(); 
	  if($("#batch-select-all:visible").length) $('.task_bar .seperator:first').show(); 
	} else { 
	  $("#batch-add-to-set").hide(); 
	  if($("#batch-select-all:visible").length) $('.task_bar .seperator:first').hide(); 
	}
};

function display_page(json, container){
	var rp = $("#result_page").tmpl(json);
	if(container.hasClass("page")){
		container.replaceWith(rp.fadeIn('slow'));
	}else{
		container.append(rp.fadeIn('slow'));
		//var $max_pages = page.pagination.current_page + 4;
		//while(page.pagination.current_page < Math.min(pagination.total_pages, $max_pages)){
		while(json.pagination.current_page < json.pagination.total_pages){
			json.pagination.current_page++;
			container.append($("#empty_result_page").tmpl(json, {empty: true}).fadeIn('slow'));
		}
	}

	//check all the previously selected checkboxes
	var selected_entries = get_selected_media_entry_ids();
	$.each(selected_entries, function(i, id) {
		$('#thumb_' + id).addClass('selected');
	});
}

function display_results(json, container){
	var container = container ? (typeof(container) === "string" ? $("#" + container) : container) : $("#results");
	var pagination = json.pagination;
	var loaded_page = 1;
  		
	display_page(json, container);
};
