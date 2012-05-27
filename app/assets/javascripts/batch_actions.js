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
});


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

function setupBatch(json) {
	if(json != undefined) display_results(json);
  listSelected();
  displayCount();

	// display the task_bar only whether there is something selectable or something is already selected
	if(get_media_entries_json().length == 0 && $(".item_box").has(".check_box").length == 0){
		$('.task_bar').hide();
		return false;
	}else{
	  $('.task_bar').show();
	}
	// hide the select_deselect_all checkbox on the browse page
	if($(".item_box .check_box").length < 2) {
		$("#batch-select-all").hide();
		$("#batch-deselect-all").hide().next().hide();
	}

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
      if($(this).closest(".set_popup").length) {
        // if target is a popup forward original
        toggleSelected($(this).closest(".set_popup").data("target").tmplItem().data);
      } else if($(this).closest(".entry_popup").length) {
        // if target is a popup forward original
        toggleSelected($(this).closest(".entry_popup").data("target").tmplItem().data);
      } else {
        toggleSelected($(this).closest(".item_box").tmplItem().data);
      }
    });

  // select all function
  $("#batch-select-all").click(function(event){
    event.preventDefault();
    var media_entries_json = get_media_entries_json();
    // select all the visible and not already selected items
    $(".item_box:visible").has(".check_box").each(function(i, elem) { 
      var me = $(elem).tmplItem().data;
      var i = is_Selected(media_entries_json, me.id);
      // if not yet selected
      if((i == -1)) {
            media_entries_json.push(me);
            $(elem).addClass('selected');
            $('#selected_items').append($("#thumbnail_mini").tmpl(me));
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
    });
    displayCount();
    return false;
  });
  
	function toggleSelected(me) {
		var media_entries_json = get_media_entries_json();
		var id = (typeof(me) == "object" ? me.id : parseInt(me));
		var i = is_Selected(media_entries_json, id);
		
		if(i > -1) {
			media_entries_json.splice(i, 1);
			$(".item_box[data-id="+id+"]").each(function(i, el){
			  $(el).removeClass('selected').css("background", "transparent");
			});
			$('#selected_items [rel="'+id+'"]').remove();
			$("#positionable").fadeOut(); // only on browse page
		} else {
      media_entries_json.push(me);
      $(".item_box[data-id="+id+"]").each(function(i, el){
        $(el).addClass('selected');
      });
      $('#selected_items').append($("#thumbnail_mini").tmpl(me));
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
	
	// count media entries
	var count_checked_media_entries = 0;
	$.each(media_entries_json, function(i_resource, resource){
    if(!resource.is_set) count_checked_media_entries++;	  
	});
	
	// count media sets
	var count_checked_media_sets = 0;
  $.each(media_entries_json, function(i_resource, resource){
    if(resource.is_set) count_checked_media_sets++;   
  });
	
	var display_count = $('li#number_selected');
	//don't show action buttons until something is actually selected
	if (count_checked_media_entries) {
		$('#selected_items').show();
		$('.task_bar .action_btn').show();
    if (count_checked_media_entries > 1) {
			display_count.html(count_checked_media_entries + " Medieneinträge ausgewählt");
		}else{
	        display_count.html("1 Medieneintrag ausgewählt");
		}
		
		// add media sets count
		if (count_checked_media_sets > 1) {
		  display_count.html(display_count.html().replace("ausgewählt", ""));
		  display_count.append(" und "+ count_checked_media_sets + " Sets ausgewählt");
		} else if(count_checked_media_sets == 1) {
		  display_count.html(display_count.html().replace("ausgewählt", ""));
		  display_count.append(" und 1 Set ausgewählt");
		}
		
	} else {
		$('.task_bar .action_btn').hide();
		$('.task_bar .seperator').hide();
		display_count.html("Keine Medieneinträge ausgewählt");
		$('#selected_items').hide();
	};

	if($('#selected_items .edit').length && !$('#selected_items > .set').length){ $("#batch-edit").show(); }else{ $("#batch-edit").hide(); }
	if($('#selected_items .manage').length && !$('#selected_items > .set').length){ $("#batch-permissions").show(); }else{ $("#batch-permissions").hide(); }
	if(($("#batch-edit:visible").length || $("#batch-permissions:visible").length) && !$('#selected_items > .set').length) { $(".task_bar .seperator.edit").show(); }else{ $(".task_bar .seperator.edit").hide(); }
	if($('#selected_items .thumb_mini').length){ 
	  $("#batch-add-to-set").show(); 
	  if($("#batch-select-all:visible").length) $('.task_bar .seperator:first').show(); 
	} else { 
	  $("#batch-add-to-set").hide(); 
	  if($("#batch-select-all:visible").length) $('.task_bar .seperator:first').hide(); 
	}
	
	update_selection(); // needed for set widget
};

function display_page(json, container){
	var rp = $("#result_page").tmpl(json);
	if(container.hasClass("page")){
		container.replaceWith(rp.show());
	}else{
		container.append(rp.show());
		//var $max_pages = page.pagination.page + 4;
		//while(page.pagination.page < Math.min(pagination.total_pages, $max_pages)){
		while(json.pagination.page < json.pagination.total_pages){
			json.pagination.page++;
			container.append($("#empty_result_page").tmpl(json, {empty: true}).show());
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
	display_page(json, container);
};

///////////////////////////////////////////////////////// SELECTION UPDATE FOR SET WIDGET

function update_selection(){
  var selected_ids = [];
  $.each(get_media_entries_json(), function(i, element){
    selected_ids.push(element.id);
  });
  $($(".task_bar .has-set-widget").data("widget")).remove();
  $(".task_bar .has-set-widget").removeClass("open created");
  $(".task_bar .has-set-widget").removeData();
  $(".task_bar .has-set-widget").data("selected_ids", selected_ids);
}
