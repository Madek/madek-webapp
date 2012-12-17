
/* This is to defend against a strange bug that destroys the page when an iframe is rendered inline in HAML */
$(document).ready(function(){
    $(".iframe").each(function(){
	var iframe = $("<iframe></iframe>");
	$(iframe).attr("src", $(this).attr("src"));
	$(iframe).attr("width", $(this).attr("width"));
	$(iframe).attr("height", $(this).attr("height"));
	$(iframe).attr("type", $(this).attr("type"));
	$(this).append(iframe);
    });
});