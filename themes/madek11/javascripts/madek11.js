jQuery.ajaxSetup({
	data: {'format':'js'}
});

$(document).ready(function () { 
	
	$(document).ajaxStart(function(){ $("*").css('cursor', 'progress'); });
	$(document).ajaxStop(function(){ $("*").css('cursor', ''); });
	
	// fading notice, error messages
    $(".notice, .error").delay(4000).fadeOut(500);
	
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




