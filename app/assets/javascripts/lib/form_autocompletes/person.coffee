###

FormAutocomplete for People

###

FormAutocompletes = {} unless FormAutocompletes?
class FormAutocompletes.Person

  constructor: (options)->
    @el = options.el
    @el.find(".form-autocomplete-person").typeahead
      source: (query, process)=>
        @ajax.abort() if @ajax?
        @ajax = App.Person.fetch query, (response)=>
          process response

window.App.FormAutocompletes = {} unless window.App.FormAutocompletes
window.App.FormAutocompletes.Person = FormAutocompletes.Person