###

  Autocomplete

  This script provides functionalities for autocompleting things 

###

jQuery ->
  $("input[data-autocomplete]").live "focus", (event)->
    AutoComplete.setup $(this)
    
class AutoComplete
  
  @setup = (input_field)->
    field_type = $(input_field).tmplItem().data.type 
    $(input_field).autocomplete
      source: if $(input_field).data("data")? then $(input_field).data("data") else @source
      select: @select
    # if autocomplete can have multiple values bind enter for adding values
    if $(input_field).siblings(".values").length and not $(input_field).data("select_only")?
      $(input_field).bind "keydown", (event)->
        if event.keyCode == 13
          return false if $(this).val() == ""
          if field_type == "people"
            element = {item: {data: {firstname: $(this).val()}, value: $(this).val(), label: $(this).val(), name: $(this).val() }}
          else
            element = {item: {id: null, value: $(this).val(), label: $(this).val(), name: $(this).val() }}
          AutoComplete.select event, element
          $(this).trigger("autocompleteselect")
  
  @source = (request, response)->
    trigger = $(this.element)
    field_type = $(trigger).closest(".edit_meta_datum_field").tmplItem().data.type
    field_type = $(trigger).data("type") unless field_type?
    $.getJSON $(trigger).data("url"),
      query: request.term
    , (data)->
      entries = []
      entries = switch field_type
        when "people" then $.map(data, (element)-> { data: element, id: element.id, value: Underscore.str.truncate(PersonMetaDatum.flatten_name(element), 65), name: PersonMetaDatum.flatten_name(element)})
        when "keywords" then $.map(data, (element)-> { id: element.id, value: element.label, name: element.label })
        when "user" then $.map(data, (element)-> { id: element.id, value: element.name, name: element.name })
        else $.map(data, (element)-> { id: element.id, value: element.label, name: element.label })
      response entries
      
  @select = (event, element)->
    target = event.target
    field = $(target).closest(".edit_meta_datum_field")
    field_type = field.tmplItem().data.type
    values_container = $(target).siblings(".values")
    # select puts entry to a multiple selection container when field is from a specific type 
    if field_type == "people" 
      $(values_container).append $.tmpl("tmpl/meta_data/edit/multiple_entries/"+field_type, element.item.data)
    else if field_type == "keywords"
      current_values = _.map $(field).find(".entry"), (entry)-> $(entry).data("value")
      if current_values.indexOf(element.item.value) == -1 
        $(values_container).append $.tmpl("tmpl/meta_data/edit/multiple_entries/"+field_type, element.item)
    else if field_type = "meta_terms"
      $(values_container).append $.tmpl("tmpl/meta_data/edit/multiple_entries/"+field_type, element.item)
    # clear input field
    $(target).val("")
    $(this).trigger("select_from_autocomplete", element.item)
    return false

window.AutoComplete = AutoComplete
