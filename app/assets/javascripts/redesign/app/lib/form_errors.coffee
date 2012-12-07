###

Form Errors

This script provides functionalities for displaying form errors

###

class FormErrors

  @set: (form, errors)->
    form = $(form)
    errorList = App.render "form_errors/form_error_list"
    errorList.append App.render "form_errors/form_error_list", errors
    errorList.html App.render "form_errors/form_error_item", errors
    if form.find(".form-body .ui-alerts").length
      form.find(".form-body .ui-alerts").replaceWith errorList
    else
      form.find(".form-body").prepend errorList

window.App.FormErrors = FormErrors