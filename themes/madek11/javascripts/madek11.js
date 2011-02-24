jQuery.ajaxSetup({
	data: {'format':'js'}
});

$(document).ready(function () { 
	
	$(document).ajaxStart(function() { $("#ajaxLoading").fadeIn(); });
	$(document).ajaxStop(function() { $("#ajaxLoading").fadeOut(); });

	// OPTIMIZE data-remote direct for pagination links
	$('.pagination a').live('ajax:success', function(xhr, response){
		$("#results").html(response);
		$("#results .pagination a").attr('data-remote', 'true');
	}).attr('data-remote', 'true');
	
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
	//alert("checkSelected called");
	var key = "media_sets/"+ media_set_id +"/media_entry_ids";
	var media_entry_ids = JSON.parse(sessionStorage.getItem(key));
	console.log("media_entry_ids in checkSelected: " + media_entry_ids);
	if (media_entry_ids != null) {
		//check all the previously selected checkboxes
		$("input.editable:checkbox").each(function () {
			if($.inArray(this.value, media_entry_ids) > -1) {
				$(this).attr('checked', true);
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
	console.log("media_entry_ids in listSelected: " + media_entry_ids);
	if (media_entry_ids != null) {
		// display all previously selected items under taskbar 
		$.each(media_entry_ids, function(i, me_id) {
			$.each(data, function(i, elem){
			  if (me_id == elem.id) $('#selected_items').append($("#mini_thumbnails").tmpl(elem));
			});
		});
	};
};