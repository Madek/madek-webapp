###

Defaults for FormWidgets

###

FormWidgets = {} unless FormWidgets?
class FormWidgets.Defaults

  constructor: (options)->
    @el = options.el
    do @delegateEvents

  delegateEvents: ->
    @el.on "click", ".form-widget-toggle", (e)=> @openFormWidget $(e.currentTarget)
    @el.on "click", ".form-widget .button", (e) => e.preventDefault(); return false
    @el.on "click", ".multi-select-tag-remove", @removeTag

  removeTag: (e) => 
    tag = $(e.currentTarget).closest(".multi-select-tag")
    input = tag.closest(".multi-select-holder").find ".multi-select-input"
    input.trigger "change"
    do tag.remove

  openFormWidget: (toggle)->
    widget = toggle.next ".form-widget"
    if toggle.is ".active"
      toggle.removeClass "active"
      do widget.hide
    else
      toggle.addClass "active"
      do widget.show
    $(@el).trigger "widget-toggled"

window.App.FormWidgets = {} unless window.App.FormWidgets
window.App.FormWidgets.Defaults = FormWidgets.Defaults