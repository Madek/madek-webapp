###

  Edit Meta Datum Field
  
  Extends a Meta Datum Edit Field with logic like validation, interaction etc.

###

class EditMetaDatumField
  
  @setup = (field)->
    field_data = $(field).tmplItem().data
    type = field_data.type
    field_name = field_data.name
    if type is "string"
      if field_name.match "copyright"
        @setup_string field
        @setup_copyright_relevant_field field
      else
        @setup_string field
    else if type is "meta_date"
      @setup_meta_date field
    else if type is "copyright"
      @setup_copyright field
      
  @setup_string = (field)->
    settings = $(field).tmplItem().data.settings
    if settings.is_required?
      $(field).find("input").attr("required", true)
    if settings.length_max?
      $(field).find("input").attr("maxlength", settings.length_max)
    if settings.length_min
      $(field).find("input").attr("minlength", settings.length_min)
    $(field).find("textarea").elastic()

  @setup_copyright_relevant_field = (field)->
    field_textarea = $(field).find "textarea"
    textarea_start_val = $(field_textarea).val()
    $(field_textarea).bind "keydown", (event)->
      textarea_start_val = $(this).val()
    $(field_textarea).bind "keyup", (event)->
      if $(this).val() != textarea_start_val
        # find dependend copyright fields
        this_field = $(this).closest ".edit_meta_datum_field"
        prev_copyright = $($(this_field).prev(".edit_meta_datum_field.copyright")[0])
        # only involve copyright when its directly connected
        custom_option = Underscore.find $(prev_copyright).find("option"), (element)-> $(element).tmplItem().data.is_custom
        if $(custom_option).is(":not(:selected)")
          $(custom_option).attr("selected", true)
          $(custom_option).closest("select").trigger("change")
        
   @setup_meta_date = (field)->
     $(field).find("input.datepicker").datepicker()
     $(field).find("select").bind "change", (event)->
       $(field).find("section").hide()
       $(field).find("section."+$(this).val()).show()
     $(field).find(".at input, .from_to input:last").bind "change", (event)->
       value = Underscore.map $(field).find("input:visible"), (input)-> $(input).val()
       value = value.join(" - ")
       $(field).find(".freetext input").val(value).trigger("change").trigger("blur")

  @setup_copyright = (field)->
    EditMetaDatumField.setup_copyright_selection(field)
    EditMetaDatumField.bind_copyright_changes(field)
    
  @bind_copyright_changes = (field)->
    $(field).delegate "select", "change", (event)->
      selected_option_data = $(this).find("option:selected").tmplItem().data
      # manage empty usage and url == unknown (hide url and usage)
      EditMetaDatumField.check_extended_copyright_infos(selected_option_data)
      # manage leaves and predefined text
      if $(this).hasClass("root")
        # remove leave selection
        $(field).find("select:not(.root)").remove()
        if selected_option_data.children.length
          # setup leave selection
          EditMetaDatumField.setup_copyright_leave_selection(field, selected_option_data)
          first_leave_option_data = $(field).find("option:selected:last").tmplItem().data
          EditMetaDatumField.set_copyright_text(field, first_leave_option_data)
        else 
          # set text for this root option that doesnt has children selected option
          EditMetaDatumField.set_copyright_text(field, selected_option_data)
      else # selected leave directly
        EditMetaDatumField.set_copyright_text(field, selected_option_data)

  @check_extended_copyright_infos = (option_data)->
    if not option_data.usage? and not option_data.url? and not option_data.parent_id?
      EditMetaDatumField.toggle_extended_copyright_info("hide")
    else 
      EditMetaDatumField.toggle_extended_copyright_info("show")
   
  @toggle_extended_copyright_info = (visibility)->
    copyright_field = $(".edit_meta_datum_field.copyright")
    copyright_related_fields = Underscore.filter $(".edit_meta_datum_field.copyright").nextAll(".edit_meta_datum_field"), (element)-> ($(element).tmplItem().data.name.match("copyright"))
    if visibility == "show"
      $(copyright_related_fields).show()  
    else if visibility == "hide"
      $(copyright_related_fields).hide()    
    
  @setup_copyright_selection = (field)->
    # set setted copyright as selected
    copyright = field.tmplItem().data.raw_value[0]
    return false unless copyright? 
    if copyright.parent_id?
      # its a leave option
      # select root first
      root_option = Underscore.find $(field).find("option"), (element)-> ($(element).tmplItem().data.id == copyright.parent_id)
      root_optgroup = Underscore.find $(field).find("optgroup"), (element)-> ($(element).tmplItem().data.id == copyright.parent_id)
      if root_option?
        $(root_option).attr("selected", true)
        EditMetaDatumField.setup_copyright_leave_selection(field, $(root_option).tmplItem().data)
    # select leave
    option = Underscore.find $(field).find("option"), (element)-> ($(element).tmplItem().data.id == copyright.id)
    $(option).attr("selected", true)
    $(option).closest("select").trigger("blur")
    
  @setup_copyright_leave_selection = (field, selected_option_data)->
    select = $.tmpl("tmpl/meta_data/edit/copyright/select", selected_option_data)
    $(field).find("select.root").after select
                
  @set_copyright_text = (field, data)->
    if not data.is_custom
      usage = $("[data-field_name='copyright usage'] textarea")
      usage.val(data.usage)
      usage.trigger("blur")
      url = $("[data-field_name='copyright url'] textarea") 
      url.val(data.url)
      url.trigger("blur")
        
window.EditMetaDatumField = EditMetaDatumField