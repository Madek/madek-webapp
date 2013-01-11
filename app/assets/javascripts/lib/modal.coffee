###

App.modal

This script provides functionalities for client side rendered modal dialogs,
it also keeps track to avoid multiple instances of the same dialog in the dom.

It also autofocus fields that have the autofocus attribute

###
window.App.modal = (el)=>
  $(el).bind "hidden", -> $(this).remove()
  $(el).bind "shown", -> 
    $(el).addClass "ui-standing-still"
    $(el).find("[autofocus=autofocus]").focus()
  $(el).modal el