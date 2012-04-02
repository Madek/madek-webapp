###

  Edit Meta Datum Helper
  
  Sets up functionality for meta data input helper

###

jQuery ()->
  
  $(".open_helper").live "click", (event)->
    $(this).next(".helper").toggle()
  
  $(".helper .tabs .tab").live "click", (event)->
    content = $(this).closest(".helper").find(".content")
    $(this).siblings(".active").removeClass("active")
    $(this).addClass("active")
    content.find(">div").hide()
    content.find("."+$(this).data("content")).show()

  $(".helper .content form").live "submit", (event)->
    values_container = $(this).closest(".edit_meta_datum_field").find(".values")
    input = $(this).closest(".edit_meta_datum_field").find(".input > input")
    field_type = $(this).closest(".edit_meta_datum_field").tmplItem().data.type
    helper_container = $(this).closest(".helper")
    
    # compute value depending on type
    if helper_container.hasClass("add_person")
      value = []
      lastname = helper_container.find("#person_lastname").val()
      value.push lastname if lastname.length
      firstname = helper_container.find("#person_firstname:visible").val()
      value.push firstname if firstname.length
      value = value.join(", ")
      pseudonym = helper_container.find("#person_pseudonym").val()
      value = value+" ("+pseudonym+")" if pseudonym.length
      helper_container.hide()
      helper_container.find("input[type=text]").val("")
    # append to values container
    if value.length
      $(values_container).append $.tmpl("tmpl/meta_data/edit/multiple_entries/"+field_type, {label: value})
      # save through trigger autocompleteselect 
      $(input).trigger("autocompleteselect")
    
    # prevend default submit
    event.preventDefault()
    return false

  $(".add_keyword.open_helper").live "click", (event)->
    helper_container = $(this).next(".helper")
    if helper_container.is(":visible")
      my_keywords = Underscore.filter Keywords.get(), (keyword)-> keyword.yours
      helper_container.find(".my").html $.tmpl("tmpl/meta_data/edit/helper/keywords/list", {keywords: my_keywords})
      popular_keywords = Underscore.sortBy Keywords.get(), (keyword)-> keyword.count
      helper_container.find(".popular").html $.tmpl("tmpl/meta_data/edit/helper/keywords/list", {keywords: popular_keywords})
      latest_keywords = Underscore.sortBy Keywords.get(), (keyword)-> new Date(keyword.created_at)
      helper_container.find(".latest").html $.tmpl("tmpl/meta_data/edit/helper/keywords/list", {keywords: latest_keywords})
      
  $(".helper .list .entry").live "click", (event)->
    values_container = $(this).closest(".edit_meta_datum_field").find(".values")
    input = $(this).closest(".edit_meta_datum_field").find(".input > input")
    field_type = $(this).closest(".edit_meta_datum_field").tmplItem().data.type
    keyword_data = $(this).tmplItem().data
    helper_container = $(this).closest(".helper")
    
    # append to value list
    $(values_container).append $.tmpl("tmpl/meta_data/edit/multiple_entries/"+field_type, {label: keyword_data.label})
    
    # save through trigger autocompleteselect 
    $(input).trigger("autocompleteselect")
    
    # remove keyword from helper
    helper_container.find(".entry[data-keyword_id="+keyword_data.id+"]").remove()
    
     
      
