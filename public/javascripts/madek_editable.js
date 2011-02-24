$(document).ready(function(){
	$(".editable a").live("click", function() {
		var source = $(this);
		$.ajax({
			url: source.attr("href"),
		    success: function(response){
		      parent = source.parent("[content='value']");
			  parent.hide();
		      parent.after(response);
		    }
		});
		return false;
	});


	$(".editable form").live("submit", function() {
		var source = $(this);
		$.ajax({
			url: source.attr("action"),
			type: source.attr("method"),
			data: source.serialize(), 
		    success: function(response){
			  meta_key_id = source.parent(".editable").attr("meta_key_id");
			  $("[meta_key_id='"+meta_key_id+"']").html(response); // NOTE replacing all related elements
		    }
		});
		return false;
	});

	$(".editable form").live("reset", function() {
		var source = $(this);
		source.parent(".editable").find("[content='value']").show();
		source.remove();
		return false;
	});
});
