###

  Edit Meta Datum Field
  
  Extends a Meta Datum Edit Field with logic like validation, interaction etc.

###

class EditMetaDatumField
  
  @setup = (field)->
    type = $(field).tmplItem().data.type    
    switch type
      when "string" then @setup_string(field)
      when "meta_date" then @setup_meta_date(field)
      when "copyright" then @setup_copyright(field)
      
  @setup_string = (field)->
    settings = $(field).tmplItem().data.settings
    if settings.is_required?
      $(field).find("input").attr("required", true)
    if settings.length_max?
      $(field).find("input").attr("maxlength", settings.length_max)
    if settings.length_min
      $(field).find("input").attr("minlength", settings.length_min)
   
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
    $(field).delegate "select", "change", (event)->
      selected_option_data = $(this).find("option:selected").tmplItem().data
      # manage leaves and predefined text
      if $(this).hasClass("root")
        # remove leave selection
        $(field).find("select:not(.root)").remove()
        if selected_option_data.children.length
          # setup leave selection
          select = $.tmpl("tmpl/meta_data/edit/copyright/select", selected_option_data)
          $(field).find("select.root").after select
          # trigger inital change of that leave
          $(select).trigger("change")
        else
          # set predefined text from this root
          EditMetaDatumField.set_copyright_text(field, selected_option_data)
      else
        # set predefined text from this leave
        EditMetaDatumField.set_copyright_text(field, selected_option_data)
      
  @set_copyright_text = (field, data)->
    $("[data-field_name='copyright usage'] textarea").val(data.usage)
    $("[data-field_name='copyright url'] textarea").val(data.url)
        
          
         
        
     
         
window.EditMetaDatumField = EditMetaDatumField