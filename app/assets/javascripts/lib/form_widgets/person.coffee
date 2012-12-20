###

FormWidget for People

###

FormWidgets = {} unless FormWidgets?
class FormWidgets.Person

  constructor: (options)->
    @el = options.el
    do @delegateEvents

  delegateEvents: ->
    @el.on "click", ".form-person-widget .add-person", (e) => @addPerson $(e.currentTarget).closest(".tab-pane").find("input"), $(e.currentTarget).closest(".form-widget")
    @el.on "click", ".form-person-widget .add-group", (e) => @addPerson $(e.currentTarget).closest(".tab-pane").find("input"), $(e.currentTarget).closest(".form-widget")
    
  addPerson: (inputs, widget)->
    person = new App.Person
    for input in inputs
      person[input.name] = $(input).val() if $(input).val().length
    if person.validate()
      person.create (data)=>
        index = widget.closest(".ui-form-group").data "index"
        widget.closest(".multi-select-holder").find(".multi-select-input-holder").before App.render "media_resources/edit/multi-select/person",
          index: index
          label: data.label
          id: data.id
      inputs.val ""
    else
      # error

window.App.FormWidgets = {} unless window.App.FormWidgets
window.App.FormWidgets.Person = FormWidgets.Person