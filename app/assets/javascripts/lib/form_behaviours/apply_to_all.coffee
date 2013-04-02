###

Apply a specific meta data to all media resources of a collection (during upload / batch edit)

###

FormBehaviours = {} unless FormBehaviours?
class FormBehaviours.ApplyToAll

  constructor: (options)->
    @el = options.el
    @collectionId = options.collectionId
    do @delegateEvents

  delegateEvents: ->
    @el.on "click", ".apply-to-all .dropdown-toggle", (e)=> $(e.currentTarget).find("i").attr("class", "icon-applytoall")
    @el.on "click", ".apply-to-all [data-overwrite]", (e)=> @applyToAll $(e.currentTarget)

  applyToAll: (trigger_el)->
    field = trigger_el.closest(".ui-form-group")
    value = App.MetaDatum.getValueFromField field
    overwrite = trigger_el.data("overwrite")
    metaKeyName = field.data "meta-key"
    additionalData = App.MetaDatum.getAdditionalDataFromField field
    dropdown_toggle = trigger_el.closest(".dropdown").find(".dropdown-toggle")
    field.trigger "apply-to-all", {value: value, overwrite: overwrite, field: field, metaKeyName: metaKeyName, additionalData: additionalData}
    dropdown_toggle.find("i").attr("class", "icon-checkmark")
    field.one "change delayedChange", => dropdown_toggle.find("i").attr("class", "icon-applytoall")
    App.MetaDatum.applyToAll 
      collectionId: @collectionId
      metaKeyName: metaKeyName
      overwrite: overwrite
      value: value

window.App.FormBehaviours = {} unless window.App.FormBehaviours
window.App.FormBehaviours.ApplyToAll = FormBehaviours.ApplyToAll