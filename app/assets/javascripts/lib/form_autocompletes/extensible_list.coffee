###

FormAutocomplete for ExtensibleLists

###

FormAutocompletes = {} unless FormAutocompletes?
class FormAutocompletes.ExtensibleList

  constructor: (options)->
    @el = options.el
    do @delegateEvents

  delegateEvents: ->
    $(@el).on "focus", ".form-autocomplete-extensible-list", (e)=> @setupAutocomplete($(e.currentTarget)) unless $(e.currentTarget).hasClass "ui-autocomplete-input"
    @el.on "keypress", ".form-autocomplete-extensible-list", (e)=>
      if e.keyCode == 13
        input = $(e.currentTarget)
        return unless input.val().length
        @addTerm new App.MetaTerm({value: input.val()}), $(e.currentTarget)
        input.val ""
        input.autocomplete "search", ""

  setupAutocomplete: (input)->
    input.on "focus", -> input.autocomplete "search", input.val()
    input.autocomplete
      minLength: 0
      appendTo: input.closest(".multi-select-input-holder")
      source: (request, response)=>
        unless input.data("terms")?
          @ajax.abort() if @ajax?
          @ajax = App.MetaTerm.fetch 
            meta_context_id: input.data("context")
            meta_key_id: input.data("meta_key")
          , (data)=>
            input.data "terms", data
            response @searchTerms request.term, data
        else
          response @searchTerms request.term, input.data "terms"
      select: (event, ui)=>
        @addTerm ui.item, $(event.target)
        input.val ""
        setTimeout (=> input.autocomplete "search", ""), 100
        return false

  searchTerms: (query, terms)->
    _.filter terms, (term) -> term.value.match new RegExp query, "i"

  addTerm: (term, input)->
    holder = input.closest(".multi-select-holder")
    return true if holder.find(".multi-select-tag [value=#{term.id}]").length
    index = holder.closest(".ui-form-group").data "index"
    multiselect = holder.find(".multi-select-input-holder")
    multiselect.before App.render "media_resources/edit/multi-select/term", {term: term, index: index}
    input.trigger "change"

window.App.FormAutocompletes = {} unless window.App.FormAutocompletes
window.App.FormAutocompletes.ExtensibleList = FormAutocompletes.ExtensibleList