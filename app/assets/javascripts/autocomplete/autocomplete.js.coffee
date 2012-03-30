###

  Autocomplete

  This script provides functionalities for autocompleting thigs 
###

jQuery ->
  $("input.autocomplete").live "focus", (event)->
    AutoComplete.setup $(this)
    
class AutoComplete
  
  @setup = (field)->
    $(field).autocomplete
      source: @source
      select: @select
  
  @source = (request, response)->
    trigger = $(this.element)
    field_type = $(trigger).closest(".edit_meta_datum").tmplItem().data.type
    $.getJSON $(trigger).data("url"),
      query: request.term
    , (data)->
      entries = []
      console.log field_type
      switch field_type
        when "person" then ()->
          entries = $.map data, (element)-> { id: element.id, value: Underscore.str.truncate(element.name, 65), name: element.name }
        when "keyword" then ()->
          entries = $.map data, (element)-> { id: element.id, value: element.label, name: element.label }
      response entries
      
  @select = (event, element)->
    target = event.target
    entries_container = $(target).siblings(".entries")
    $(entries_container).append $.tmpl("tmpl/meta_data/edit/multiple_entries/person", element.item)
  
window.AutoComplete = AutoComplete