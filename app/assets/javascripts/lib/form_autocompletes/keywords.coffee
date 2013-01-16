###

FormAutocomplete for Keywords

###

FormAutocompletes = {} unless FormAutocompletes?
class FormAutocompletes.Keywords

  constructor: (options)->
    @el = options.el
    do @delegateEvents

  delegateEvents: ->
    $(@el).on "focus", ".form-autocomplete-keywords", (e)=> @setupAutocomplete($(e.currentTarget)) unless $(e.currentTarget).hasClass "ui-autocomplete-input"
    @el.on "keydown", ".form-autocomplete-keywords", (e) => @addNonExistingKeyword $(e.currentTarget) if e.keyCode == 13

  setupAutocomplete: (input)->
    input.autocomplete
      appendTo: input.closest(".multi-select-input-holder")
      source: (request, response)=>
        @ajax.abort() if @ajax?
        @ajax = App.Keyword.fetch request.term, (keywords)->
          response _.map keywords, (keyword)->
            keyword.value = keyword.label
            keyword.name = keyword.label
            keyword
      select: (event, ui)=>
        keyword = new App.Keyword ui.item
        input = $(event.target)
        @addExistingKeyword keyword, input
        input.val ""
        return false

  addNonExistingKeyword: (input)->
    term = input.val()
    return false unless term.length
    holder = input.closest(".multi-select-holder")
    unless holder.find(".multi-select-tag [value='#{term}']").length
      index = holder.closest(".ui-form-group").data "index"
      multiselect = holder.find(".multi-select-input-holder")
      keyword = 
        label: term,
        index: index
      multiselect.before App.render "media_resources/edit/multi-select/keyword", keyword
    input.val ""
    input.trigger "change"
    return false

  addExistingKeyword: (keyword, input)->
    holder = input.closest(".multi-select-holder")
    return true if holder.find(".multi-select-tag [value=#{keyword.id}]").length
    index = holder.closest(".ui-form-group").data "index"
    multiselect = holder.find(".multi-select-input-holder")
    keyword.index = index
    multiselect.before App.render "media_resources/edit/multi-select/keyword", keyword
    input.trigger "change"
      
window.App.FormAutocompletes = {} unless window.App.FormAutocompletes
window.App.FormAutocompletes.Keywords = FormAutocompletes.Keywords