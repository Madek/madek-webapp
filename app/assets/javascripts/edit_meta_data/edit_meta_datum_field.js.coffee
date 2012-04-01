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
   
window.EditMetaDatumField = EditMetaDatumField