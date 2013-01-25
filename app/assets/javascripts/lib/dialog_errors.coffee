###

Dialog Errors

This script provides functionalities for displaying errors in dialogs

###

class DialogErrors

  @set: (el, errors)->
    el = $(el)
    errorList = App.render "dialog_errors/list"
    errorList.append App.render "dialog_errors/list", errors
    errorList.html App.render "dialog_errors/item", errors
    if el.find(".ui-alerts").length
      el.find(".ui-alerts").replaceWith errorList
    else if el.find(".ui-modal-body").length
      el.find(".ui-modal-body").prepend errorList
    else
      el.prepend errorList

window.App.DialogErrors = DialogErrors