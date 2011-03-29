(function ($) {

var DEFAULT_SETTINGS = {
    hintText: "Start to type ...",
    minChars: 1,
    tokenDelimiter: ",",
    preventDuplicates: false,
    prePopulate: null,
    onResult: null,
    onAdd: null,
    onDelete: null
};

// Input box position "enum"
var POSITION = {
    BEFORE: 0,
    AFTER: 1,
    END: 2
};

// Keys "enum"
var KEY = {
    BACKSPACE: 8,
    TAB: 9,
    RETURN: 13,
    ESC: 27,
    LEFT: 37,
    UP: 38,
    RIGHT: 39,
    DOWN: 40,
    COMMA: 188
};

// Expose the .tokenInput function to jQuery as a plugin
$.fn.madekMultiselect = function (source, options) {
    var settings = $.extend({}, DEFAULT_SETTINGS, options || {}, {source: source});

    return this.each(function () {
        new $.MultiSelect(this, settings);
    });
};

$.MultiSelect = function (input, settings) { 
	var token_count = 0;
	
	// Keep track of the timeout, old vals
    var timeout;
    var input_val;

    // Create a new text input an attach keyup events
    var input_box = $("<input type=\"text\" autocomplete=\"off\">")
		.css({
            outline: "none"
        })
		.keydown(function (event) {
		            var previous_token;
		            var next_token;

		            switch(event.keyCode) {
			            case KEY.TAB:
		                case KEY.RETURN:
		                case KEY.COMMA:
		                  if(selected_dropdown_item) {
		                    add_token($(selected_dropdown_item));
		                    return false;
		                  }
		                  break;

		                case KEY.ESC:
		                  hide_dropdown();
		                  return true;

		                default:
		                    if(is_printable_character(event.keyCode)) {
		                      // set a timeout just long enough to let this function finish.
		                      setTimeout(function(){do_search(false);}, 5);
		                    }
		                    break;
		}
		
		// The list to store the token items in
	    var token_list = $("<ul />")
	        .addClass(settings.classes.tokenList)
	        .click(function (event) {
	            var li = $(event.target).closest("li");
	            if(li && li.get(0) && $.data(li.get(0), "tokeninput")) {
	                toggle_select_token(li);
	            } else {
	                // Deselect selected token
	                if(selected_token) {
	                    deselect_token($(selected_token), POSITION.END);
	                }

	                // Focus input box
	                input_box.focus();
	            }
	        })
	        .mouseover(function (event) {
	            var li = $(event.target).closest("li");
	            if(li && selected_token !== this) {
	                li.addClass(settings.classes.highlightedToken);
	            }
	        })
	        .mouseout(function (event) {
	            var li = $(event.target).closest("li");
	            if(li && selected_token !== this) {
	                li.removeClass(settings.classes.highlightedToken);
	            }
	        })
	        .insertBefore(hidden_input);
	
	   // Pre-populate list if items exist
	   hidden_input.val("");
	   li_data = settings.prePopulate;
	   if(li_data && li_data.length) {
	       $.each(li_data, function (index, value) {
	           insert_token(value.id, value.name);
	       });
	   }

	

};// end MultiSelect

});// end document ready function