// TODO REMOVE THIS WHEN FORMAT JSON BECOMES DEFAULT
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

    // OPTIMIZE Action Bar for media_entry and media_set templates
    $("a[panel]").click(function(){
      to_open = !$(this).hasClass("active");
      $("a.active[panel]").each(function () {
        $(this).removeClass("active");
        $(this).css("background", "");
        $("div#"+$(this).attr("panel")+"-panel").slideUp("slow");
      });
      if(to_open){
        $(this).addClass("active");
        $(this).css("background", "transparent url('/assets/icons/arrow-up-04.png') 50% bottom no-repeat");
        $("div#"+$(this).attr("panel")+"-panel").slideDown("slow");
      }
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




