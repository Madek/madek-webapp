/*
 * Department Selection
 *
 * This script provides functionalities for the extended
 * autocomplete field especialy for department selection
 *
*/

$(document).ready(function(){
  DepartmentSelection.setup();
});

var DepartmentSelection = new DepartmentSelection();

function DepartmentSelection() {
 
  this.current_search_results = [];
  this.current_search_term;
  this.ignore_list = ["verteilerliste"]; // ldap prefixes case insensetive e.g. verteilerliste will remove ldap groups like "Verteilerliste.123"
 
 
  this.setup = function(){
    this.setup_extended_autocomplete();
  }
 
  this.setup_extended_autocomplete = function() {
    var target = $("#institutional_affiliation_autocomplete_search");
   
   // setup inputfield
    target
      .live("focus", this.open_on_focus)
      .live("autocompletecreate", this.create_extendend_autocomplete)
      .live("autocompletesearch", this.search_department)
      .live("autocompleteopen", this.open_extended_autocomplete);
    
    // setup selection navigation (navigate deeper)
    $(".department-autocomplete .ui-menu-item-department:not(.opened) .ui-corner-navigator")
      .live("click", this.navigate_deeper);
      
    // setup selection navigation (navigate higher)
    $(".department-autocomplete .ui-menu-item-department.opened .ui-corner-navigator")
      .live("click", this.navigate_higher);
      
    // setup selection
    $(".department-autocomplete .ui-menu-item-department:not(.selected) a").live("click", this.select_department);
  }
  
  this.open_on_focus = function(event) {
    var target = event.target;
    window.setTimeout(function(){
      $(target).closest("div").find(".search_toggler").click();
    }, 150);
  }
  
  this.create_extendend_autocomplete = function(event, ui) {
    var target = event.target;
    DepartmentSelection.group_all_options(target);
    $(target).addClass("department-selection");
  }
    
  this.group_all_options = function(target) {
    var all_options = $(target).data("all_options");
    var groups = {};
    
    // first split the ldap name and save as ldap_name
    $.each(all_options, function(index, option){
      var group_elements = [];
      // match ldap with regexp
      option.ldap = option.label.match(/\w*?\.\w*?\)$/)[0].replace("(", "").replace(")", "");
      
      // before touching check if current element is on ignore list
      var ldap_prefix = option.ldap.split(".")[0].toLowerCase();
      if($.inArray(ldap_prefix, DepartmentSelection.ignore_list) > -1) {
        return; // continue loop
      }
          
      // split (department_subunit_subunit)
      var department_unit = option.ldap.split(".")[0].split("_");
      $.each(department_unit, function(index, element){
        // if department unit string size is smaller then 1 char append it to the last value
        if(element.length == 1 && group_elements.length){
          group_elements[group_elements.length-1] = group_elements[group_elements.length-1]+""+element;
        } else {
          group_elements.push(element);      
        }
      });
      
      // split (.typeOfPersons)
      var title = option.label.replace(/\(\w*\..*?\)$/, "");
      group_elements.push(option.ldap.split(".")[1]);
      var unit = option.ldap.split(".")[1];
      
      // initialize first element
      var first_element = group_elements.shift();
      if(groups[first_element] == undefined) groups[first_element] = {};
      var parent = groups[first_element];
      
      // iterate children
      for(var i = 0; i < group_elements.length; i++) {
        // set parent
        if(parent[group_elements[i]] == undefined) parent[group_elements[i]] = {};
        parent = parent[group_elements[i]];
      }
      
      // set deepest info
      parent["_info"] = {};
      parent["_info"]["id"] = option.id;
      parent["_info"]["title"] = title + "(" + unit + ")";
      parent["_info"]["ldap"] = option.ldap; 
    });
    
    // recursive fill up of group nodes
    DepartmentSelection.recursive_fill_up(groups);
    
    // prepare groups for autocomplete (create autocomplete options)
    all_options = [];
    $.each(groups, function(index, group){
      if(group["_info"] != undefined) {
        var children = [];
        for(var child in group) {
          if(child == "_info") continue;
          children.push(group[child]);
          delete group[child];
        }
        // prepare autocomplete atributes
        group.ids = group["_info"]["_ids"];
        group.label = group["_info"]["_title"];
        group.ldap = "";
        group.selected = false;
        group.children = children;
        delete group["_info"];
      }
      
      // when label is ampty dont add to options
      if(group.label != ""){
        all_options.push(group);
      }
    });
   
   // save the computed infos on the target
   $(target).data("all_options", all_options);
  }
  
  this.recursive_fill_up = function(current_element) {
    $.each(current_element, function(index, elements){
      if(elements["_info"] == undefined) {
        // recursive full up computed groups
        DepartmentSelection.recursive_fill_up(elements);
      } else {
        // depest element till here
        if(current_element["_info"] == undefined) current_element["_info"] = {};
        // prepare ids
        if(current_element["_info"]["_ids"] == undefined) current_element["_info"]["_ids"] = [];
        if(elements["_info"]["id"] != undefined) {
          current_element["_info"]["_ids"].push(elements["_info"]["id"]);
        }
        
        // push current title to possible titles of parent
        if(current_element["_info"]["_titles"] == undefined) current_element["_info"]["_titles"] = [];
        current_element["_info"]["_titles"].push(elements["_info"]["title"]);
      }
    });
    
    // push ids
    if(current_element["_info"] != undefined) {
      $.each(current_element, function(index, elements){
        if(elements["_info"] != undefined && elements["_info"]["_ids"] != undefined) {
          if(current_element["_info"]["_ids"] == undefined) current_element["_info"]["_ids"] = [];
          $.each(elements["_info"]["_ids"], function(index, id){
            current_element["_info"]["_ids"].push(id);
          });
        }
      });
    }
   
    // compute one single title of list of childrens titles
    if(current_element["_info"] && current_element["_info"]["_titles"]) {
      // replace parenthesis on each element first
      $.each(current_element["_info"]["_titles"], function(index, current_title){
        current_element["_info"]["_titles"][index] = DepartmentSelection.strip_units_in_parenthesis(current_title);
      });
      
      // fill title
      var _title = DepartmentSelection.fill_up_title(current_element["_info"]["_titles"]);
      
      current_element["_info"]["_title"] = DepartmentSelection.strip_units_in_parenthesis(_title);
      delete current_element["_info"]["_titles"];
    }
  }
  
  this.strip_units_in_parenthesis = function(title) {
    return title.replace(/\s\(.*?\)/, "");
  }
  
  this.fill_up_title = function(titles) {
    var matched_title;
    for(var i = 0; i < titles.length; i++) {
      if(matched_title == undefined || matched_title.length == 0) {
        matched_title = titles[i];
        // if there are not more then 1 element break insted of continue
        if(titles.length == 1) {
          _title = matched_title;
          break;
        } else {
          continue;
        }
      } else if(matched_title == titles[i]) {
        _title = matched_title;
        break;
      }
    }
    
    return matched_title;
  }
  
  this.open_extended_autocomplete = function(event, ui) {
    $(".ui-autocomplete:visible").addClass("department-autocomplete");
    
    // add id computed to menu items
    $(".ui-autocomplete:visible .ui-menu-item").addClass("ui-menu-item-department").removeClass("ui-menu-item");
    
    // add navigation    
    DepartmentSelection.prepare_menu_elements_dom(event.target);
    
    // remove empty li
    $(".ui-autocomplete:visible li").each(function(index, item){
      if($(item).html().length == 0) {
        $(item).remove();
      }
    });
  }
  
  this.prepare_menu_elements_dom = function(target) {
    var autocomplete = $(".ui-autocomplete:visible");
    $(autocomplete).find(".ui-menu-item-department").each(function(i_item, item){
      // continue loop if corner all already has department class
      if(! $(item).find(".ui-corner-all").hasClass("department")) {
        
        // add department class
        $(item).find(".ui-corner-all").addClass("department");
        
        // search if current element is currently selected
        var selected = DepartmentSelection.check_if_item_is_selected(item);
        
        // if current elemetn is selected mark as selected        
        if(!selected) {
          // check for any child
          var any_child = DepartmentSelection.has_any_children($(item).data("item.autocomplete").children);
          
          // if any child add navigation
          if(any_child){
            $(item).find(".ui-corner-all").addClass("with-navigator");
            $(item).find(".ui-corner-all").after($("<div class='ui-corner-navigator'><div class='arrow'></div></div>"));
            
            // set corner navigation hight
            $(item).find(".ui-corner-all").next(".ui-corner-navigator").each(function(){
              $(this).height($(item).closest(".ui-menu-item-department").height());          
            });
            
            // positioning arrows
            $(item).find(".ui-corner-navigator .arrow").each(function(){
              var height = $(this).closest(".ui-corner-navigator").outerHeight();
              $(this).css("top", height/2 - $(this).outerHeight()/2);     
            });
          }
        }
      }
    });
  }
  
  this.check_if_item_is_selected = function(item) {
    var is_selected = false;
    var selected_items = $("#institutional_affiliation_autocomplete_search").closest("li").prevAll(".bit-box"); 
    $.each(selected_items, function(i_s_item, selected_item){
      if(JSON.stringify($(selected_item).data().ids) == JSON.stringify($(item).data("item.autocomplete").ids)) {
        is_selected = true;
      }
    });      
    
    if(is_selected) {
      $(item).addClass("selected");
      $(item).find(".ui-corner-all").addClass("with-navigator").addClass("department");
      $(item).find(".ui-corner-all").after($("<div class='selected-marker'><div class='icon'></div></div>"));
    }
    
    return is_selected;  
  }
  
  this.has_any_children = function(children) {
    var result = false;
    $.each(children, function(i_child, child){
      if(child["_info"] != undefined) {
        $.each(child, function(i_value, value){
          if(i_value != "_info") result = true;
        });
      }
    });
    return result;
  }
  
  this.navigate_deeper = function(event) {
    var target = event.target;
    
    // moveout and remove not selected items
    var _width = $(target).closest(".ui-menu-item-department").outerWidth();
    $(target).closest(".ui-menu-item-department").addClass("opened");
    $(".ui-menu-item-department:not(.opened)").each(function(){
      $(this).animate({
        left: -_width
      }, 500, function(){
        $(this).remove();
      });
    });
    
    window.setTimeout(function(){
      // add children of selected item
      var item = $(target).closest(".ui-menu-item-department");
      DepartmentSelection.add_children($(item).closest(".ui-autocomplete"), $(item).data("item.autocomplete").children);
      // add navigation after adding childs
      DepartmentSelection.prepare_menu_elements_dom(target);
    }, 500);
  }
  
  this.add_children = function(autocomplete, children) {
    $.each(children, function(index, child){
      // check if info is present
      if(child["_info"] != undefined) {
        // add only items with childrens
        if(child["_info"]["id"] == undefined) {
          var new_item = $('<li class="ui-menu-item-department"><a class="ui-corner-all" tabindex="-1"></a></li>');
          var label = child["_info"]["_title"];
          $(new_item).find("a").html(label);
          $(autocomplete).append(new_item); 
          
          // prepare for autocomplete
          var autocomplete_object = {};
          autocomplete_object.label = label;
          autocomplete_object.ids = child["_info"]["_ids"];
          
          // compute children for autocomplete object
          var children = [];
          $.each(child, function(i_value, value){
            children.push(value);
          });
          autocomplete_object.children = children;
          
          // set autocomplete object
          $(new_item).data("item.autocomplete", autocomplete_object);
        }
      }
    });
  }
  
  this.navigate_higher = function(event) {
    var target = $(event.target).closest("li");
    
    // moveout and remove not selected items
    var _width = $(target).outerWidth();
    var items_to_removed = $(target).nextAll("li");
     
    $(items_to_removed).each(function(){
      $(this).animate({
        left: +_width
      }, 500, function(){
        $(this).remove();
      });
    });
    
    // remove selected and all after
    $(target).removeClass("selected");
    window.setTimeout(function(){
      $(target).remove();
    }, 400);
    
    // add children of the next higher seleceted item
    var item = $(target).closest(".ui-menu-item-department").prev();
    if(item.length == 0) {
      DepartmentSelection.reset();
    } else {
      window.setTimeout(function(){
        DepartmentSelection.add_children($(item).closest(".ui-autocomplete"), $(item).data("item.autocomplete").children);
      }, 500);
    }
    // add navigation after adding childs
    window.setTimeout(function(){
      DepartmentSelection.prepare_menu_elements_dom(target);
    }, 500);
  }
  
  this.reset = function() {
    var target = $("#institutional_affiliation_autocomplete_search");  
    $(target).blur();
    $(target).autocomplete("close");
    window.setTimeout(function(){
      $(target).closest("div").find(".search_toggler").click();
    }, 150);
  }
  
  this.select_department = function(event) {
    var target = $(event.target).closest(".ui-menu-item-department");
    var autocomplete = $(target).closest(".ui-autocomplete");
    var search_field = $("#institutional_affiliation_autocomplete_search");
    var object = {};
        object.label = $(target).find("a").html();
        object.field_name_prefix = search_field.data("field_name_prefix");
            
    // create multiselect template
    var tmpl = $("#madek_multiselect_item").tmpl(object);
    $(tmpl).data("ids", $(target).data("item.autocomplete").ids);
    
    // add form values
    var input_clone = $(tmpl).find("input").clone();
    $(tmpl).find("input").remove();
    $.each($(target).data("item.autocomplete").ids, function(index, id){
      var input = $(input_clone).clone();
      $(input).val(id);
      $(tmpl).append(input);
    });
    
    // insert template to dom
    $(tmpl).insertBefore(search_field.parent()).fadeIn('slow');
    
    // reset autocomplete
    search_field.val("");
    $(search_field).autocomplete("close");
  }
  
  this.search_department = function(event, ui) {
    window.setTimeout(function(){
      var min = 2;
      var target = event.target;
      DepartmentSelection.current_search_term = $(target).val();
      var all_options = $(target).data("all_options");
      
      // break search if term is small than min
      if(DepartmentSelection.current_search_term < min) return;
          
      // clean autocomplete before showing search results
      $(".department-autocomplete").html("");
      
      // search all options      
      $.each(all_options, function(i_option, option){
        if(option.children == undefined) return;
        
        // start searching top levels
        var regexp = new RegExp(DepartmentSelection.current_search_term, "ig");
        if(option.label.search(regexp) > -1) {
          // prepare option for output
          option["_info"] = {};
          option["_info"]["_title"] = option.label;
          option["_info"]["_ids"] = option.ids;
          
          // add to search results
          DepartmentSelection.current_search_results.push(option);
        }
        
        // now go on searching in deeper levels
        $.each(option.children, function(i_child, child){
          DepartmentSelection.recursive_search(child);
        });
      });
      
      // create search result elements
      DepartmentSelection.add_children($(".department-autocomplete"), DepartmentSelection.current_search_results);
      
      // add selectded-marker
      // search if current element is currently selected
      $(".department-autocomplete .ui-menu-item-department").each(function(index, item){
        DepartmentSelection.check_if_item_is_selected(item);
      });
      
      // force to show search results if there are some
      if(DepartmentSelection.current_search_results.length) $(".department-autocomplete").show();
      
      // clean current_search_term and results
      DepartmentSelection.current_search_results = [];
      DepartmentSelection.current_search_term = undefined;
    },90);
  }
  
  this.recursive_search = function(target_object){
    // break if _info does not exists or _title is empty
    if(target_object["_info"] == undefined) return;
    if(target_object["_info"]["_title"] == undefined) return;
    
    // search current title
    var regexp = new RegExp(DepartmentSelection.current_search_term, "ig");
    if(target_object["_info"]["_title"].search(regexp) > -1) {
      DepartmentSelection.current_search_results.push(target_object);
    }
    
    // if any children search there as well
    var any_child = DepartmentSelection.has_any_children(target_object);
    if(any_child) {
      $.each(target_object, function(i, child){
        DepartmentSelection.recursive_search(child);
      });
    }
  }
}