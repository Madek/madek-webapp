###

FormBehaviour for Copyrights

###

FormBehaviours = {} unless FormBehaviours?
class FormBehaviours.Copyrights

  constructor: (options)->
    @el = options.el
    for copyrightField in @el.find(".ui-form-group[data-type='meta_datum_copyright']")
      copyrightField = $(copyrightField)
      @onRootChange copyrightField.find("select.copyright-roots")
      @onSelectChange copyrightField.find("option:selected[data-leaf]").closest("select")
    @el.find(".ui-form-group[data-meta-key='copyright usage'] textarea").delayedChange({delay: 10})
    @el.find(".ui-form-group[data-meta-key='copyright url'] textarea").delayedChange({delay: 10})
    do @delegateEvents

  delegateEvents: ->
    @el.on "change", ".ui-form-group[data-type='meta_datum_copyright'] select.copyright-roots", (e)=> @onRootChange $(e.currentTarget)
    @el.on "change", ".ui-form-group[data-type='meta_datum_copyright'] select", (e)=> @onSelectChange $(e.currentTarget)
    @el.on "change delayedChange", ".ui-form-group[data-meta-key='copyright usage'] textarea", => do @setIndividualCopyright
    @el.on "change delayedChange", ".ui-form-group[data-meta-key='copyright url'] textarea", => do @setIndividualCopyright

  onRootChange: (select)->
    option = select.find("option:selected")
    select.nextAll(".copyright-children").hide()
    select.next(".copyright-children[data-parent-id=#{option.data("id")}]").show()
    select.next(".copyright-children[data-parent-id=#{option.data("id")}]").trigger "change"

  onSelectChange: (select)->
    option = select.find("option:selected")
    if option.data("leaf")?
      @el.find(".ui-form-group[data-meta-key='copyright usage'] textarea").val option.data "usage"
      @el.find(".ui-form-group[data-meta-key='copyright url'] textarea").val option.data "url"
      @setSelectedCopyright option.data "id"

  setIndividualCopyright: ->
    @el.find(".ui-form-group[data-type='meta_datum_copyright'] select option[data-is-custom]").attr("selected", true)
    @onRootChange @el.find(".ui-form-group[data-type='meta_datum_copyright'] select")

  setSelectedCopyright: (copyright_id)->
    @el.find(".ui-form-group[data-type='meta_datum_copyright'] input[name]").val copyright_id

window.App.FormBehaviours = {} unless window.App.FormBehaviours
window.App.FormBehaviours.Copyrights = FormBehaviours.Copyrights