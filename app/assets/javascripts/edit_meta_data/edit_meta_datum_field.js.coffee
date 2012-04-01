###

  Edit Field
  
  Extends EditField for MetaData with logic like validation etc.

###

class EditField
  
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
   
window.EditField = EditField