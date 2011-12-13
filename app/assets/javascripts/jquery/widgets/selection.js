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
  
  this.create_widget = function(target){
    var widget = $.tmpl("tmpl/widgets/selection").data("target", target);
    
    widget.position({
      of: $(target),
      my: "center top",
      at: "center bottom"
    });
    $("body").append(widget);
    
    // add identifier to target
    $(target).data("widget", widget);
    
    SelectionWidget.focus_input(target);
    SelectionWidget.setup_search_field(target);
    SelectionWidget.setup_search_hint(target);
    SelectionWidget.setup_cancel(target);
    SelectionWidget.setup_create_new(target);
    SelectionWidget.setup_create_new_hint(target);
  }
  
  this.setup_create_new = function(target) {
    $(target).data("widget").find(".create_new a").click(function(event){
      event.preventDefault();
      SelectionWidget.show_create_input(target, $(target).data("widget").find(".search input").val());
    });
  }
  
  this.show_create_input = function(target, val) {
    SelectionWidget.enable_modal(target);
    $(target).data("widget").find(".create_new a").hide();
    $(target).data("widget").find(".create_new input").show().val(val).select().focus();
    if(val == "") $(target).data("widget").find(".create_new .hint").show();
    
    $(target).data("widget").find(".create_new input").bind("blur", function() {
      if($(this).val() == "") {
        SelectionWidget.reset_create_new(target);
      }
    });
  }
  
  this.reset_create_new = function(target) {
    $(target).data("widget").find(".create_new a").show();
    $(target).data("widget").find(".create_new input").hide().val("");
    $(target).data("widget").find(".create_new .hint").hide();
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
      if($(this).val().length > 0) {
        SelectionWidget.enable_modal(target);        
      }
    });
    
    $(target).data("widget").find(".search input").bind("blur", function() {
      if($(this).val() == "") {
       $(this).next(".hint").fadeIn(); 
      }
    });
  }
  
  this.setup_search_hint = function(target) {
    $(target).data("widget").find(".search input").bind("keydown click", function(){
      $(target).data("widget").find(".search .hint").fadeOut();
    });
    $(target).data("widget").find(".search .hint").bind("click", function(){
      $(target).data("widget").find(".search .hint").fadeOut();
      $(target).data("widget").find(".search input").focus();
    });
  }
  
  this.setup_create_new_hint = function(target) {
    $(target).data("widget").find(".create_new input").bind("keydown click", function(){
      $(target).data("widget").find(".create_new .hint").fadeOut();
    });
    
    $(target).data("widget").find(".create_new .hint").bind("click", function(){
      $(target).data("widget").find(".create_new .hint").fadeOut();
      $(target).data("widget").find(".create_new input").focus();
    });
  }
  
  this.enable_modal = function(target) {
    if($("#modal_overlay").length == 0) SelectionWidget.create_modal_overlay(target);
    $(target).data("widget").addClass("modal");
  }
  
  this.create_modal_overlay = function(target) {
    var modal_container = $("<div id='modal_overlay'></div>")
    $(modal_container).hide();
    $(target).data("widget").before(modal_container);
    $(modal_container).fadeIn(1500);
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
    $(target).addClass("open");
    SelectionWidget.focus_input(target);
    $(target).data("widget").find(".search .hint").show();
  }
  
  this.close_widget = function(target) {
    if($(target).data("widget").hasClass("modal")) return false;
    $(target).data("widget").hide();
    $(target).removeClass("open"); 
    SelectionWidget.reset_create_new(target);
  }
  
  this.handle_click_on_window = function(event) {
    var trigger = event.target;
    // hide all selection widgets if target was not the selection widget or any childs
    if($(trigger).hasClass("has-selection-widget") || $(trigger).parents(".has-selection-widget").length) {
      var target = ($(trigger).hasClass("has-selection-widget")) ? $(trigger) : $(trigger).parents(".has-selection-widget");
      if($(target).hasClass("open")) {
        SelectionWidget.close_widget(target);
      } else {
        if($(target).hasClass("created")) {
          SelectionWidget.open_widget(target);
        } else {
          SelectionWidget.create_widget(target);
          $(target).addClass("created");
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