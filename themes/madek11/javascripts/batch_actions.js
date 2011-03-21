$(document).ready(function () {
	
    $('.pagination a').live('ajax:success', function(xhr, response){
      checkSelected();
      $('.actions').hide();
    });
	
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
        editable_ids.push($(this).attr("id").slice(3));
      });
      $(this).append("<input type='hidden' name='media_entry_ids' value='"+editable_ids+"'>");
    });
    
	// batch edit permissions
    $("#batch-permissions form").submit(function() {
      var managable_ids = new Array();
      $("#selected_items .manage").each(function(i, elem){
        managable_ids.push($(this).attr("id").slice(3));
      });
      $(this).append("<input type='hidden' name='media_entry_ids' value='"+managable_ids+"'>");
    });
  
	// add to set
    $("#batch-add-to-set form").submit(function() {
      var editable_ids = new Array();
      $("#selected_items .thumb_mini").each(function(i, elem){
        editable_ids.push($(this).attr("id").slice(3));
      });
      $(this).append("<input type='hidden' name='media_entry_ids' value='"+editable_ids+"'>");
    });
    
	
});


/////////////////////////////////////////////////////////
// UTILITY ARRAY FUNCTIONS

/* destructively finds the intersection of 
 * two arrays in a simple fashion.  
 *
 * PARAMS
 *  a - first array, must already be sorted
 *  b - second array, must already be sorted
 *
 * NOTES
 *  State of input arrays is undefined when
 *  the function returns.  They should be 
 *  (prolly) be dumped.
 *
 *  Should have O(n) operations, where n is 
 *    n = MIN(a.length(), b.length())
 */
function intersection_destructive(a, b)
{
  var result = new Array();
  while( a.length > 0 && b.length > 0 )
  {  
     if      (a[0] < b[0] ){ a.shift(); }
     else if (a[0] > b[0] ){ b.shift(); }
     else /* they're equal */
     {
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

function setupBatch(media_set_id) {
	checkSelected();
    listSelected();
    displayCount();

	// when remove from set is hovered we only want to highlight those media_entries that are part of the current set
	if(media_set_id){
		var media_entries_in_set = $("#batch-remove input[type='submit']").data('media_entry_ids');
		var media_entry_ids = get_selected_media_entry_ids();
		
		var media_entries_in_set = intersection_destructive(media_entries_in_set.sort(), media_entry_ids.sort());
	}; //end if
	
	// make thumbnails removable from the selected items bar
    $('#selected_items .thumb_mini').live("hover", function() {
        $(this).children('img.thumb_remove').toggle();
     });

	$('img.thumb_remove').live("click", function() {
      $(this).parents('.thumb_mini').remove();
      var id = $(this).attr("rel");
      toggleSelected(id);
    });

    $(":checkbox").live("click", function(){
	/*
      var curr_value = $(this).val();
      $.each(data, function(i, me) {
        if(me.id == curr_value){
          toggleSelected(me);
        }
      });
	*/	
		toggleSelected($(this).closest(".item_box").data("object"));
    });

    $("#batch-remove").hover(
      function () { 
	 	$.each(media_entries_in_set, function(i, id){
		  $('#selected_items #me_' + id).css("background-color", "#FEFFD7");
		});
	   }, 
      function () { 
		$.each(media_entries_in_set, function(i, id){
		  $('#selected_items #me_' + id).css("background-color", "white");
		});
	  }
    );

	// remove from set
    $("#batch-remove form").submit(function() {
      $(this).append("<input type='hidden' name='media_entry_ids' value='"+media_entries_in_set+"'>");
    });

	function toggleSelected(me) {
		var media_entries_json = get_media_entries_json();
		var media_entry_ids = $.map(media_entries_json, function(elem, i){ return parseInt(elem.id); });
		var id = (typeof(me) == "object" ? me.id : parseInt(me));
		var i = media_entry_ids.indexOf(id);

		if(i > -1) {
			media_entries_json.splice(i, 1);
			$('#thumb_' + id).removeClass('selected').removeAttr("style").find('input:checkbox').attr('checked', false);
			$('#selected_items #me_' + id).remove();
			if (media_entries_in_set != undefined){ removeItems(media_entries_in_set, id) };
		}else{
	        media_entries_json.push(me);
	        $('#thumb_' + id).addClass('selected');
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

function get_media_entries_json(){
	var media_entries_json = JSON.parse(sessionStorage.getItem("selected_media_entries"));
	if(media_entries_json == null) media_entries_json = new Array();
	return media_entries_json;
}

function set_media_entries_json(data){
	sessionStorage.setItem("selected_media_entries", data);
}

function get_selected_media_entry_ids() {
	var media_entries_json = get_media_entries_json();
	return $.map(media_entries_json, function(elem, i){ return parseInt(elem.id); });
}

function checkSelected() {
	var media_entry_ids = get_selected_media_entry_ids();
	//check all the previously selected checkboxes
	$("input.editable:checkbox").each(function () {
		if($.inArray(this.value, media_entry_ids) > -1) {
			$(this).attr('checked', true);
			$(this).parents('.item_box').addClass('selected');
		} else {
			// this seems necessary because of browser cache that keeps checkboxes checked
			$(this).attr('checked', false);
		};  
	});
};

function listSelected() {
	var media_entries_json = get_media_entries_json();
	// display all previously selected items under taskbar 
	$('#selected_items').html($("#thumbnail_mini").tmpl(media_entries_json));
	$.each(media_entries_json, function(i, me) {
		$('#thumb_' + me.id).addClass('selected').find('input:checkbox').attr('checked', true);
	});
};


function displayCount() {
	var media_entries_json = get_media_entries_json();
	var count_checked = media_entries_json.length;
	var display_count = $('li#number_selected');
	//don't show action buttons until something is actually selected
	if (count_checked) {
		$('.task_bar .action_btn').show();
	    if (count_checked > 1) {
			display_count.html(count_checked + " Medieneinträge ausgewählt.");
		}else{
	        display_count.html("1 Medieneintrag ausgewählt.");
		}
	} else {
		$('.task_bar .action_btn').hide();
		display_count.html("Keine Medieneinträge ausgewählt.");
	};
};