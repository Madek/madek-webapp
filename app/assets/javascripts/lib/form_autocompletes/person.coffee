###

FormAutocomplete for People

###

FormAutocompletes = {} unless FormAutocompletes?
class FormAutocompletes.Person

  constructor: (options)->
    @el = options.el
    do @delegateEvents

  delegateEvents: ->
    $(@el).on "focus", ".form-autocomplete-person", (e)=> @setupAutocomplete($(e.currentTarget)) unless $(e.currentTarget).hasClass "ui-autocomplete-input"

  setupAutocomplete: (input)->
    input.autocomplete
      appendTo: input.closest(".multi-select-input-holder")
      source: (request, response)->
        @ajax.abort() if @ajax?
        @ajax = App.Person.fetch request.term, (people)->
          response _.map people, (person)-> 
            _person = JSON.parse JSON.stringify person
            _person.value = person.toString()
            _person.name = person.toString()
            _person
      select: (event, ui)=>
        person = new App.Person ui.item
        input = $(event.target)
        @addPerson person, input
        input.val ""
        return false

  addPerson: (person, input)->
    holder = input.closest(".multi-select-holder")
    return true if holder.find(".multi-select-tag [value=#{person.id}]").length
    index = holder.closest(".ui-form-group").data "index"
    multiselect = holder.find(".multi-select-input-holder")
    person.index = index
    multiselect.before App.render "media_resources/edit/multi-select/person", person
      
window.App.FormAutocompletes = {} unless window.App.FormAutocompletes
window.App.FormAutocompletes.Person = FormAutocompletes.Person