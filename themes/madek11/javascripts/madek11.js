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

Array.prototype.getUnique = function () {
	var o = new Object();
	var i, e;
	for (i = 0; e = this[i]; i++) {o[e] = 1};
	var a = new Array();
	for (e in o) {a.push (e)};
	return a;
	};
	
function isArray(a) {
  return Object.prototype.toString.apply(a) === '[object Array]';
}

function checkSelected(media_set_id) {
	var key = "media_sets/"+ media_set_id +"/media_entry_ids";
	var media_entry_ids = JSON.parse(sessionStorage.getItem(key));
	//console.log("media_entry_ids in checkSelected: " + media_entry_ids);
	if (media_entry_ids != null) {
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
	}
};

function listSelected(media_set_id, data) {
	//alert("listSelected called");
	var key = "media_sets/"+ media_set_id +"/media_entry_ids";
	var media_entry_ids = JSON.parse(sessionStorage.getItem(key));
	//console.log("media_entry_ids in listSelected: " + media_entry_ids);
	if (media_entry_ids != null) {
		// display all previously selected items under taskbar 
		$.each(media_entry_ids, function(i, me_id) {
			$.each(data, function(i, elem){
			  if (me_id == elem.id) $('#selected_items').append($("#mini_thumbnails").tmpl(elem));
			});
		});
	};
};

function removeFromSelected(key, id) {
   var media_entry_ids = JSON.parse(sessionStorage.getItem(key));
   var i = media_entry_ids.indexOf(id);
   var selected_box = $('#thumb_' + id);
   
   if(i > -1) {
	media_entry_ids.splice(i, 1)
	$('#selected_items #me_' + id).remove();
	selected_box.css('background', 'white');
	selected_box.find('input:checkbox').attr('checked', false);
	
	sessionStorage.setItem(key, JSON.stringify(media_entry_ids.getUnique()));
	displayCount(key);
   };
};

function displayCount(key) {
  var media_entry_ids = JSON.parse(sessionStorage.getItem(key));

  if (media_entry_ids != null) {
    var count_checked = media_entry_ids.length;
    var display_count = $('li#number_selected');
	if (count_checked > 0) {
	  $('.task_bar .action_btn').show();
	} else {
	  $('.task_bar .action_btn').hide();
	};
    switch (count_checked){
      case 0:
        display_count.html("Keine Medieneinträge ausgewählt.");
      break;
      case 1:
        display_count.html("1 Medieneintrag ausgewählt.");
      break;
      default : 
        display_count.html(count_checked + " Medieneinträge ausgewählt.");
    }
  }
};



