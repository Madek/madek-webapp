jQuery.ajaxSetup({
	data: {'format':'js'}
});

$(document).ready(function () { 
	
	$(document).ajaxStart(function() { $("#ajaxLoading").fadeIn(); });
	$(document).ajaxStop(function() { $("#ajaxLoading").fadeOut(); });
	
	// fading notice, error messages
    $(".notice, .error").delay(4000).fadeOut(500);

	// OPTIMIZE data-remote direct for pagination links
	$('.pagination a').live('ajax:success', function(xhr, response){
		$("#results").html(response);
		$("#results .pagination a").attr('data-remote', 'true');
		var paginator_container = $("#pagination_container");
		if(paginator_container.length) paginator_container.html($("#results div.pagination").detach());
	}).attr('data-remote', 'true');
	
	
	// toggle favorites
	$("span.favorite_link a").live('ajax:complete', function(xhr, response){
      var media_entry_id = $(this).parent().attr("id").slice(4);
    	$("span#fav_" + media_entry_id).html(response.responseText);
    });

    // hide icons by default 
    $('.actions').hide();
    $(".item_box").live({
      mouseenter: function() {
        $(this).find('.actions').show();
		var color = $(this).css("background-color");
		$(this).stop(true, true).delay(400).animate({ backgroundColor: "#f1f1f1" }, 500);
       },
      mouseleave: function() {
        $(this).find('.actions').hide();
		// only remove bg color if not selected in batch context
		if (!($(this).hasClass('selected'))) $(this).stop(true, false).animate({ backgroundColor: "white" }, 1000);
       }
     });
	
	$("#menu").flickrmenu({ arrowPic: "/images/icons/arrow.png",
							arrowPicA: "/images/icons/arrow_select.png",
							arrowPicH: "/images/icons/arrow_hover.png" });
							
							
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
	
	
});

/*
// TODO .uniq_on("id")
Array.prototype.getUnique = function () {
	var o = new Object();
	var i, e;
	for (i = 0; e = this[i]; i++) {o[e] = 1};
	var a = new Array();
	for (e in o) {a.push (e)};
	return a;
};
*/
	
function isArray(a) {
  return Object.prototype.toString.apply(a) === '[object Array]';
}

////////////////////////////////////////
// media_set's media_entries_json sessionStorage

function get_key_for_media_set(media_set_id){
	return "media_sets/"+ media_set_id +"/media_entries_json";
}

function get_media_entries_json(media_set_id){
	var key = get_key_for_media_set(media_set_id);
	var media_entries_json = JSON.parse(sessionStorage.getItem(key));
	if(media_entries_json == null) media_entries_json = new Array();
	return media_entries_json;
}

function set_media_entries_json(media_set_id, data){
	var key = get_key_for_media_set(media_set_id);
	sessionStorage.setItem(key, data);
}

function checkSelected(media_set_id) {
	var media_entries_json = get_media_entries_json(media_set_id);
	var media_entry_ids = $.map(media_entries_json, function(elem, i){ return parseInt(elem.id); });
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

function listSelected(media_set_id) {
	var media_entries_json = get_media_entries_json(media_set_id);
	// display all previously selected items under taskbar 
	$('#selected_items').html($("#thumbnail_mini").tmpl(media_entries_json));
	$.each(media_entries_json, function(i, me) {
		$('#thumb_' + me.id).addClass('selected').find('input:checkbox').attr('checked', true);
	});
};

function toggleSelected(media_set_id, me) {
	var media_entries_json = get_media_entries_json(media_set_id);
	var media_entry_ids = $.map(media_entries_json, function(elem, i){ return parseInt(elem.id); });
	var id = (typeof(me) == "object" ? me.id : parseInt(me));
	var i = media_entry_ids.indexOf(id);

	if(i > -1) {
		media_entries_json.splice(i, 1)
		$('#thumb_' + id).removeClass('selected').find('input:checkbox').attr('checked', false);
		$('#selected_items #me_' + id).remove();
	}else{
        media_entries_json.push(me);
        $('#thumb_' + id).addClass('selected');
        $('#selected_items').append($("#thumbnail_mini").tmpl(me));
	};

	//old// set_media_entries_json(media_set_id, JSON.stringify(media_entries_json.getUnique()));
	set_media_entries_json(media_set_id, JSON.stringify(media_entries_json));
    displayCount(media_set_id);
};

function displayCount(media_set_id) {
	var media_entries_json = get_media_entries_json(media_set_id);
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



