/*
 * Selection Widget
 *
 * This script provides functionalities to create, open and
 * interact with a generic selection widget.
 *
*/

$(document).ready(function(){
  SelectionWidget.setup();
});

var SelectionWidget = new SelectionWidget();

function SelectionWidget() {
  
  this.setup = function() {
    $(window).bind("click", SelectionWidget.handle_click_on_window);
  }
  
  this.load_content = function(target) {
    // call ajax for index
    $.ajax($(target).data("index").path, {
      beforeSend: function(request, settings){
      },
      success: function(data, status, request) {
        if(data.length > 0) {
          $(target).data("items", JSON.parse(data));
        } else {
          $(target).data("items", null);
        }
        
        if($(target).data("linked_items") != undefined && $(target).data("items") != undefined && $(target).data("widget") != undefined) {
          SelectionWidget.setup_widget(target);
        }
      },
      error: function(request, status, error){
        if($(target).data("linked_items") != undefined && $(target).data("items") != undefined && $(target).data("widget") != undefined) {
          SelectionWidget.setup_widget(target);
        }
      },
      data: $(target).data("index").data,
      type: $(target).data("index").method
    });
    
    // call ajax for linked_index
    $.ajax($(target).data("linked_index").path, {
      beforeSend: function(request, settings){
      },
      success: function(data, status, request) {
        if(data.length > 0) {
          $(target).data("linked_items", JSON.parse(data));
        } else {
          $(target).data("linked_items", null);
        }
        
        if($(target).data("linked_items") != undefined && $(target).data("items") != undefined && $(target).data("widget") != undefined) {
          SelectionWidget.setup_widget(target);
        }
      },
      error: function(request, status, error){
        if($(target).data("linked_items") != undefined && $(target).data("items") != undefined && $(target).data("widget") != undefined) {
          SelectionWidget.setup_widget(target);
        }
      },
      data: $(target).data("linked_index").data,
      type: $(target).data("linked_index").method
    }); 
  }
  
  this.create_widget = function(target){
    var widget = $.tmpl("tmpl/widgets/selection", {title: target.attr("title")}).data("target", target);
    
    // add identifier to target and add to dom
    $(target).data("widget", widget);
    SelectionWidget.align_widget(target);
    $("body").append(widget);
    
    // prepare stacks
    $(target)
      .data("create_stack", [])
      .data("link_stack", [])
      .data("unlink_stack", []);
    
    // check if data is already there
    if($(target).data("items") != undefined && $(target).data("items") != null) {
      SelectionWidget.setup_widget(target);
    }
    
    // bind window events resize and scroll to align widget method
    $(window).bind("resize scroll",function(){
      SelectionWidget.align_widget(target);
    });
  }
  
  this.setup_selection_actions = function(target, elements) {
    $(elements).each(function(i, element){
      $(element).bind("change", function(){     
        if($(this).is(":checked")) { // checkbox was activated
          $(this).closest("li").addClass("selected");
          if($(this).data("unlinked")) {
            var item = $(this).closest("li").tmplItem().data;
            $(this).removeData("unlinked");
            // remove from stack
            for(var i = 0; i < $(target).data("unlink_stack").length; i++) {
              var link = $(target).data("unlink_stack")[i];
              if(link.id == item.id) {
                $(target).data("unlink_stack").splice(i, 1);
                break;
              }
            }
          } else {
            $(this).data("linked", true);
            // add to stack
            var item_data = $(this).closest("li").tmplItem().data;
            $(target).data("link_stack").push(item_data);
          }
        } else { // checkbox was deactivated
          $(this).closest("li").removeClass("selected");
          // check if current item was linked inside of the widget
          if($(this).data("linked")) {
            var item_data = $(this).closest("li").tmplItem().data;
            $(this).removeData("linked");
            // remove from stack
            for(var i = 0; i < $(target).data("link_stack").length; i++) {
              var link = $(target).data("link_stack")[i];
              // check id and uid for items not yet created
              if(link.uid == undefined ) {
                if(link.id == item_data.id) {
                  $(target).data("link_stack").splice(i, 1);
                  break;
                }
              } else {
                if(link.uid == item_data.uid) {
                  $(target).data("link_stack").splice(i, 1);
                  break;
                }
              }
            }
          } else { // the item was already linked
            $(this).data("unlinked", true);
            var item_data = $(this).closest("li").tmplItem().data;
            $(target).data("unlink_stack").push(item_data);
          }
        }
        
        SelectionWidget.check_stack_state(target);
      });
    });
  }
  
  this.setup_widget = function(target) {
    // remove start loading indicator
    $(target).data("widget").find(".loading").remove();
    
    // data
    var items = $(target).data("items");
    var widget = $(target).data("widget");
    
    // templating
    $(widget).append($.tmpl("tmpl/widgets/_search"));
    $(widget).append($.tmpl("tmpl/widgets/_list", {items: items}));
    $(widget).append($.tmpl("tmpl/widgets/_new"));
    $(widget).append($.tmpl("tmpl/widgets/_actions"));
    
    // setup the rest
    SelectionWidget.setup_list(target);
    SelectionWidget.focus_input(target);
    SelectionWidget.setup_search_field(target);
    SelectionWidget.setup_search_hint(target);
    SelectionWidget.setup_cancel(target);
    SelectionWidget.setup_create_new(target);
    SelectionWidget.setup_create_hint(target);
    SelectionWidget.setup_selection_actions(target, $(".list ul li input[type=checkbox]"));
    SelectionWidget.setup_submit(target);
  }
  
  this.setup_list = function(target) {
    // sort list alphabeticaly
    SelectionWidget.sort_list(target);
    
    $(target).data("widget").find(".list li").each(function(i_item, item){
      
      // detach the element of the list if the element is the current opened one
      if(parseInt($(target).data("id")) == $(this).tmplItem().data.id && $(target).data("detach_my_self") == true) {
        $(this).detach();
      }
      
      // check if there are already connected items
      $.each($(target).data("linked_items"), function(i_link, linked_item){
        // check if the ellement is already linked
        if(linked_item.id == $(item).tmplItem().data.id) {
          $(item).addClass("selected");
          $(item).find("input").attr("checked", "checked");
        }
      });
    });
  }
  
  this.setup_submit = function(target) {
    $(target).data("widget").find(".submit").click(function(){
      // show loading indicator
      $(this).data("text", $(this).html());
      $(this).css("width", $(this).outerWidth()).css("height", $(this).outerHeight()).html("").append("<img src='/assets/loading.gif'/>").addClass("loading");
      
      // disable click binding
      $(this).unbind("click");
      
      // hide cancle button
      $(this).next(".cancel").hide();
      
      // disable search
      $(target).data("widget").find("#widget_search").attr("disabled", true);
      $(target).data("widget").find(".search").addClass("disabled");
      
      // hide create new
      $(target).data("widget").find(".create_new").hide();
      
      // disable all checkboxes
      $(target).data("widget").find("input[type=checkbox]").attr("disabled", true);
      
      // start submitting
      SelectionWidget.submit_create_stack(target);
    });
  }
  
  this.disable_search = function(target) {
    $(target).data("widget").find(".seach").attr("disabled", true);
    $(target).data("widget").find(".seach input").attr("disabled", true);
    $(target).data("widget").find(".seach .hint").hide();
  }
  
  this.submit_create_stack = function(target) {
    
    // if create stack is empty go on with submiting the link stack
    if($(target).data("create_stack").length == 0){
      SelectionWidget.submit_link_stack(target);
      return false;     
    }
    
    var array = [];
    for(var i = 0; i < $(target).data("create_stack").length; i++) {
      var array_as_string = JSON.stringify($(target).data("create").array);
      array_as_string = array_as_string.replace(/\{:title\}/g, $(target).data("create_stack")[i].title)
      array.push(JSON.parse(array_as_string));
    }
    
    var data_as_string = JSON.stringify($(target).data("create").data);
    var data = JSON.parse(data_as_string.replace(/"\{:array\}"/g, JSON.stringify(array)));
    
    $.ajax($(target).data("create").path, {
      beforeSend: function(request, settings){
      },
      success: function(data, status, request) {
        
        var returned_items = JSON.parse(data);
        for(var i_returned = 0; i_returned < returned_items.length; i_returned++) {
          // add id to linked items in the link_stack which where created with the widget, because these just got ids after they are created on the server
          for(var i_linked = 0; i_linked < $(target).data("link_stack").length; i_linked++) {
            if($(target).data("link_stack")[i_linked].uid != undefined && $(target).data("link_stack")[i_linked].uid == i_returned) {
              $(target).data("link_stack")[i_linked].id = returned_items[i_returned].id;
            }
          }
          
          // add id to the created item, which is also inside of the dom
          for(var i_item = 0; i_item < $(target).data("widget").find(".list li").length; i_item++) {
            if($($(target).data("widget").find(".list li")[i_item]).tmplItem().data.uid ==  i_returned) {
              $($(target).data("widget").find(".list li")[i_item]).tmplItem().data.id = returned_items[i_returned].id;
              delete $($(target).data("widget").find(".list li")[i_item]).tmplItem().data.uid;
            }
          }
        }
        
        // clear stack
        $(target).data("create_stack", []);
        
        // clear all created items
        $(target).data("widget").find(".list li").each(function(){
          $(this).find("input").removeData("created");
          $(this).removeClass("created");
        });
        
        // go on with submit link stack
        SelectionWidget.submit_link_stack(target);
      },
      error: function(request, status, error){
      },
      data: data,
      type: $(target).data("create").method
    }); 
  }
  
  this.submit_link_stack = function(target) {
    
    // if link stack is empty go on with submiting the unlink stack
    if($(target).data("link_stack").length == 0){
      SelectionWidget.submit_unlink_stack(target); 
      return false;
    }     
    
    var array = [];
    for(var i = 0; i < $(target).data("link_stack").length; i++) {
      var array_as_string = JSON.stringify($(target).data("link").array);
      array_as_string = array_as_string.replace(/\{:id\}/g, $(target).data("link_stack")[i].id)
      array.push(JSON.parse(array_as_string));
    }

    var data_as_string = JSON.stringify($(target).data("link").data);
    var data = JSON.parse(data_as_string.replace(/"\{:array\}"/g, JSON.stringify(array)));
    
    $.ajax($(target).data("link").path, {
      beforeSend: function(request, settings){
      },
      success: function(data, status, request) {
        // clear stack
        $(target).data("link_stack", []);
        
        // clear all linked items
        $(target).data("widget").find(".list li").each(function(){
          $(this).find("input").removeData("linked");
        });
        
        // go on
        SelectionWidget.submit_unlink_stack(target);
      },
      error: function(request, status, error){
      },
      data: data,
      type: $(target).data("link").method,
      dataType: 'json'
    }); 
  }
  
  this.submit_unlink_stack = function(target) {
    
    // if unlink stack is empty go on with submiting the finish submiting
    if($(target).data("unlink_stack").length == 0) {
      SelectionWidget.finish_submitting(target);
      return false;
    }
        
    var array = [];
    for(var i = 0; i < $(target).data("unlink_stack").length; i++) {
      var array_as_string = JSON.stringify($(target).data("unlink").array);
      array_as_string = array_as_string.replace(/\{:id\}/g, $(target).data("unlink_stack")[i].id)
      array.push(JSON.parse(array_as_string));
    }
    
    var data_as_string = JSON.stringify($(target).data("unlink").data);
    var data = JSON.parse(data_as_string.replace(/"\{:array\}"/g, JSON.stringify(array)));
    
    $.ajax($(target).data("unlink").path, {
      beforeSend: function(request, settings){
      },
      success: function(data, status, request) {
        // clear stack
        $(target).data("unlink_stack", []);
        
        // clear all unlinked items
        $(target).data("widget").find(".list li").each(function(){
          $(this).find("input").removeData("unlinked");
        });
        
        // go on
        SelectionWidget.finish_submitting(target);
      },
      error: function(request, status, error){
      },
      data: data,
      type: $(target).data("unlink").method,
      dataType: 'json'
    }); 
  }
  
  this.finish_submitting = function(target) {
    // replace loading indicator with green submitted button
    $(target).data("widget").find(".loading img").remove();
    $(target).data("widget").find(".loading").append("<div class='success icon'></div>");
    
    // eval target after-submit
    eval($(target).data("after_submit"));
    
    // eval a after submit callback instead of fade out the widget, because we didnt take care about updating the complete view currently,
    // so we have a window.location.reload as callback
    /*
    // leave modal    
    SelectionWidget.disable_modal(target);
    // fade out
    $(target).data("widget").stop(true,true).delay(400).fadeOut(500, function(){
      // close/reset widget
      SelectionWidget.close_widget(target);
    });
    */
  }
  
  this.setup_create_new = function(target) {
    $(target).data("widget").find(".create_new a").click(function(event){
      event.preventDefault();
      SelectionWidget.show_create_input(target, $(target).data("widget").find(".search input").val());
    });
    
    $(target).data("widget").find(".create_new input").bind("blur", function(event) {
      if($(this).val() == "") {
        window.setTimeout(function(){
          if($(target).data("widget").find(".create_new input:focus").length < 1) {
            SelectionWidget.reset_create_new(target);
          }
        },200);
      }
    });
    
    $(target).data("widget").find(".create_new input").bind("keyup", function(event) {
      // hide or show depending on val
      if($(this).val() == "") {
        $(this).siblings(".create.button").hide();
      } else {
        $(this).siblings(".create.button").show();
      } 
      
      // create new on enter
      if(event.keyCode == 13) {
        SelectionWidget.create_new(target, $(this).val());
      }
    });
    
    $(target).data("widget").find(".create_new .create.button").bind("click", function(event) {
       SelectionWidget.create_new(target, $(target).data("widget").find(".create_new input").val());
    });
  }
  
  this.create_new = function(target, val) {
    var new_item = $.tmpl("tmpl/widgets/_line", {title: val});
    $(new_item).addClass("created");
    $(new_item).css("background-color", "#CCC");
    $(target).data("widget").find(".list ul").append(new_item);
    SelectionWidget.reset_create_new(target);
    
    // sort list
    SelectionWidget.sort_list(target);
    
    // scroll to new entry which is append to list
    $(target).data("widget").find(".list").animate({
      scrollTop: ($(new_item).offset().top-$(target).data("widget").find(".list li:first").offset().top)
    }, function(){
      $(new_item).animate({
        "background-color": "#EEE"
      }, function(){
        $(this).removeAttr("css");
      });
    });
    
    // new is activated per default
    $(new_item).find("input").attr("checked", true);
    $(new_item).find("input").data("linked", true);
    $(new_item).addClass("selected");
    SelectionWidget.setup_selection_actions(target, $(new_item).find("input"));
    
    // add new created to stack
    $(target).data("create_stack").push({title: val});
    
    // add new created to link stack
    $(target).data("link_stack").push({title: val, uid: ($(target).data("create_stack").length-1)}); // the uid is representing the create_stack id of the linked stack item. This item was created inside the widget
    
    // add uid to the item itselves for identifying this element, when the server responds with a valid id
    $(new_item).tmplItem().data.uid = ($(target).data("create_stack").length-1);
    
    // check stack state
    SelectionWidget.check_stack_state(target);
  }
  
  this.setup_create_hint = function(target) {
    $(target).data("widget").find(".create_new input").bind("keydown click", function(){
      $(target).data("widget").find(".create_new .hint").hide();
    });
    $(target).data("widget").find(".create_new .hint").bind("click", function(){
      SelectionWidget.show_create_input(target, "");
      $(target).data("widget").find(".create_new .hint").hide();
      $(target).data("widget").find(".create_new input").focus();
    });
  }
  
  this.check_stack_state = function(target) {
    var empty = true;
    
    if($(target).data("create_stack") != undefined && $(target).data("create_stack").length > 0) empty = false;
    if($(target).data("link_stack") != undefined && $(target).data("link_stack").length > 0) empty = false;
    if($(target).data("unlink_stack") != undefined && $(target).data("unlink_stack").length > 0) empty = false;
    
    if(empty == false) {
      SelectionWidget.activate_submit(target);
      SelectionWidget.enable_modal(target);
    } else {
      SelectionWidget.deactivate_submit(target);
      if($(target).data("widget").find(".search input").val() == "") SelectionWidget.disable_modal(target);
    }
  }
  
  this.show_create_input = function(target, val) {
    SelectionWidget.enable_modal(target);
    $(target).data("widget").find(".create_new a").hide();
    $(target).data("widget").find(".create_new .hint").show();
    $(target).data("widget").find(".create_new input").show().val(val).select().focus();
    if(val != "") {
      $(target).data("widget").find(".create_new .create.button").show();      
    }
  }
  
  this.sort_list = function(target) {
    var items = $(target).data("widget").find(".list li");
        items = items.sort(SelectionWidget.sort_title_alphabeticaly);
    $(target).data("widget").find(".list ul").append(items);
  }
  
  this.sort_title_alphabeticaly = function(a,b){
    return $(a).tmplItem().data.title.toUpperCase() > $(b).tmplItem().data.title.toUpperCase() ? 1 : -1;
  }
  
  this.reset_create_new = function(target) {
    $(target).data("widget").find(".create_new a").show();
    $(target).data("widget").find(".create_new .hint").hide();
    $(target).data("widget").find(".create_new input").hide().val("");
    $(target).data("widget").find(".create_new .create.button").hide();
  }
  
  this.setup_cancel = function(target) {
    $(target).data("widget").find(".actions .cancel").click(function(){
      SelectionWidget.destroy_modal_overlay(target);
      $(target).data("widget").removeClass("modal");
      SelectionWidget.deactivate_submit(target);
      SelectionWidget.close_widget(target);
    });
  }
  
  this.setup_search_field = function(target) {
    $(target).data("widget").find(".search input").bind("keyup", function() {
      if($(this).val().length != 0) {
        SelectionWidget.enable_modal(target);
      } 
      
      SelectionWidget.search(target, $(this).val());
    });
    
    $(target).data("widget").find(".search input").bind("blur", function(event) {
      if($(this).val() == "") {
       $(this).siblings(".hint").show();
       SelectionWidget.check_stack_state(target);
      }
    });
  }
  
  this.search = function(target, val) {
    $(target).data("widget").find(".list li label").each(function(i, element){
      var element = $(element).clone();
      var regexp = new RegExp(val, 'i');
      
      if($(element).html().search(regexp) > -1) {
        $(this).parent().show();
      } else {
        $(this).parent().hide();
      }
    });
  }
  
  this.setup_search_hint = function(target) {
    $(target).data("widget").find(".search input").bind("keydown click", function(){
      if(! $(this).closest(".search").hasClass("disabled")) {
        $(target).data("widget").find(".search .hint").hide();
      }
    });
    $(target).data("widget").find(".search .hint").bind("click", function(){
      if(! $(this).closest(".search").hasClass("disabled")) {
        $(target).data("widget").find(".search .hint").hide();
        $(target).data("widget").find(".search input").focus();
      }
    });
  }
  
  this.enable_modal = function(target) {
    if($("#modal_overlay").length == 0) {
      SelectionWidget.create_modal_overlay(target);
    } else {
      if($("#modal_overlay:visible").length == 0) $("#modal_overlay").stop(true,true).fadeIn();  
    }
    $(target).data("widget").addClass("modal");
  }
  
  this.disable_modal = function(target) {
    $(target).data("widget").removeClass("modal");
    $("#modal_overlay").stop(true,true).fadeOut();
  }
  
  this.create_modal_overlay = function(target) {
    var modal_container = $("<div id='modal_overlay'></div>")
    $(modal_container).hide();
    $(target).data("widget").before(modal_container);
    SelectionWidget.enable_modal(target);
  }
  
  this.destroy_modal_overlay = function(target) {
    $("#modal_overlay").remove();
  }
  
  this.activate_submit = function(target) {
    $(target).data("widget").find(".actions .submit").removeAttr("disabled");
  }
  
  this.deactivate_submit = function(target) {
    $(target).data("widget").find(".actions .submit").attr("disabled", true);
  }
  
  this.focus_input = function(target) {
    $(target).data("widget").find("input.autofocus").val("");
    $(target).data("widget").find("input.autofocus").focus();
  }
  
  this.open_widget = function(target) {
    $(target).data("widget").show();
    SelectionWidget.align_widget(target);
    $(target).addClass("open");
    SelectionWidget.focus_input(target);
    $(target).data("widget").find(".search .hint").show();
  }
  
  this.align_widget = function(target) {
    var widget = $(target).data("widget");
    $(widget).position({
      of: $(target),
      my: "center top",
      at: "center bottom",
      collision: "fit fit"
    });
  }
  
  this.close_widget = function(target) {
    if($(target).data("widget").hasClass("modal")) return false;
    
    // hide and close
    $(target).data("widget").hide();
    $(target).removeClass("open");
    
    // reset create new 
    SelectionWidget.reset_create_new(target);
    
    // remove all unsaved new items
    // unlink all elements from the link stack
    // link all elements from the unlink stack
    $(target).data("widget").find(".list li").each(function(i, line){
      if($(line).hasClass("created")) $(line).remove();
      if($(line).find("input").data("linked")) {
        $(line).find("input").removeData("linked");
        $(line).find("input").attr("checked", false); 
      }
      if($(line).find("input").data("unlinked")) {
        $(line).find("input").removeData("unlinked");
        $(line).find("input").attr("checked", true); 
      }
    });
    
    // show all items of the list again
    $(target).data("widget").find(".list li").show();
    
    // clear the stack
    $(target)
      .data("create_stack", [])
      .data("link_stack", [])
      .data("unlink_stack", []);
    
    // show submit button text again
    if($(target).data("widget").find(".submit").data("text") != undefined) $(target).data("widget").find(".submit").html($(target).data("widget").find(".submit").data("text"));
    
    // show cancle button again
    $(target).data("widget").find(".actions .cancel").show();
    
    // remove action based classes from submit button
    if($(target).data("widget").find(".actions .submit").hasClass("loading")) {
      $(target).data("widget").find(".actions .submit").removeClass("loading");
      // setup submit button again
      SelectionWidget.setup_submit(target);
    }
    
    // check stack state to disable button
    SelectionWidget.check_stack_state(target);
    
    // scrolltop
    $(target).data("widget").find(".list").scrollTop(0);
    
    // enable search
    $(target).data("widget").find("#widget_search").removeAttr("disabled");
    $(target).data("widget").find(".search").removeClass("disabled");
    
    // show create new
    $(target).data("widget").find(".create_new").show();
    
    // enable all checkboxes
    $(target).data("widget").find("input[type=checkbox]").removeAttr("disabled");
  }
  
  this.handle_click_on_window = function(event) {
    var trigger = event.target;
    
    // hide all selection widgets if target was not the selection widget or any childs
    if($(trigger).hasClass("has-selection-widget") || $(trigger).parents(".has-selection-widget").length) {
      var target = ($(trigger).hasClass("has-selection-widget")) ? $(trigger) : $(trigger).parents(".has-selection-widget");
      if($(target).hasClass("open")) {
        // prevent default click 
        event.preventDefault();
        
        SelectionWidget.close_widget(target);
      } else {
        // prevent default click 
        event.preventDefault();
        
        // create or open widget
        if($(target).hasClass("created")) {
          SelectionWidget.open_widget(target);
        } else {
          SelectionWidget.load_content(target);
          SelectionWidget.create_widget(target);
          $(target).addClass("created");
          $(target).addClass("open");
        }
      }
      
    } else if(($(trigger).hasClass("widget") && $(trigger).hasClass("selection")) || $(trigger).parents(".selection.widget").length) {
      // click on widget
    } else {
      // click on window (not widget not button wich has widget)
      $(".selection.widget:not(.modal)").each(function(){
        SelectionWidget.close_widget($(this).data("target"));        
      });
    }
  }
}