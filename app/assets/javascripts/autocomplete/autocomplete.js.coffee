###

  Autocomplete

  This script provides functionalities for autocompleting things 
###

jQuery ->
  $("input.autocomplete").live "focus", (event)->
    AutoComplete.setup $(this)
    
class AutoComplete
  
  @setup = (input_field)->
    field_type = $(input_field).tmplItem().data.type 
    $(input_field).autocomplete
      source: @source
      select: @select
    # if autocomplete can have multiple values bind enter for adding values
    if $(input_field).siblings(".values").length
      $(input_field).bind "keydown", (event)->
        if event.keyCode == 13
          return false if $(this).val() == ""
          element = {item: {id: null, value: $(this).val(), label: $(this).val(), name: $(this).val() }}
          AutoComplete.select event, element
          $(this).trigger("autocompleteselect")
  
  @source = (request, response)->
    trigger = $(this.element)
    field_type = $(trigger).closest(".edit_meta_datum_field").tmplItem().data.type
    $.getJSON $(trigger).data("url"),
      query: request.term
    , (data)->
      entries = []
      entries = switch field_type
        when "person" then $.map(data, (element)-> { id: element.id, value: Underscore.str.truncate(element.name, 65), name: element.name })
        when "keyword" then $.map(data, (element)-> { id: element.id, value: element.label, name: element.label })
      response entries
      
  @select = (event, element)->
    target = event.target
    field_type = $(target).closest(".edit_meta_datum_field").tmplItem().data.type
    # select puts entry to a multiple selection container when field is from a specific type 
    if field_type == "person" or field_type == "keyword"
      AutoComplete.select_for_multiple_values event, element, field_type
    # clear input field
    $(target).val("")
    return false

  @select_for_multiple_values = (event, element, field_type)->
    target = event.target
    values_container = $(target).siblings(".values")
    $(values_container).append $.tmpl("tmpl/meta_data/edit/multiple_entries/"+field_type, element.item)
  
window.AutoComplete = AutoComplete