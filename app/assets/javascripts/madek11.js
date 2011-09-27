jQuery.ajaxSetup({
	data: {'format':'js'}
});

$(document).ready(function () { 
	
	$(document).ajaxStart(function(){ $("body").css('cursor', 'progress'); });
	$(document).ajaxStop(function(){ $("body").css('cursor', ''); });
	
	// fading notice, error messages
    $(".notice, .error").delay(4000).fadeOut(500);
	
	// toggle favorites
	$("span.favorite_link a").live('ajax:complete', function(xhr, response){
      var media_entry_id = $(this).parent().attr("id").slice(4); // TODO $(this).closest(".item_box").attr("rel");
      $("span#fav_" + media_entry_id).html(response.responseText);
    });

	$("#menu").flickrmenu({ arrowPic: "/assets/icons/arrow.png",
							arrowPicA: "/assets/icons/arrow_select.png",
							arrowPicH: "/assets/icons/arrow_hover.png" });

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




