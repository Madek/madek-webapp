###

FormAutocomplete for Keywords

###

FormAutocompletes = {} unless FormAutocompletes?
class FormAutocompletes.Keywords

  constructor: (options)->
    @el = options.el
    for keywordField in @el.find(".form-autocomplete-keywords")
      do (keywordField)=>
        keywordField = $(keywordField)
        keywordField.autocomplete
          appendTo: keywordField.closest(".multi-select-input-holder")
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

    do @delegateEvents

  delegateEvents: ->
    @el.on "keydown", ".form-autocomplete-keywords", (e) => @addNonExistingKeyword $(e.currentTarget) if e.keyCode == 13

  addNonExistingKeyword: (input)->
    term = input.val()
    return false unless term.length
    holder = input.closest(".multi-select-holder")
    unless holder.find(".multi-select-tag [value='#{term}']").length
      index = holder.closest(".ui-form-group").data "index"
      multiselect = holder.find(".multi-select-input-holder")
      multiselect.before App.render "media_resources/edit/multi-select/keyword", {keyword: {label: term}, index: index}
    input.val ""
    return false

  addExistingKeyword: (keyword, input)->
    holder = input.closest(".multi-select-holder")
    return true if holder.find(".multi-select-tag [value=#{keyword.id}]").length
    index = holder.closest(".ui-form-group").data "index"
    multiselect = holder.find(".multi-select-input-holder")
    multiselect.before App.render "media_resources/edit/multi-select/keyword", {keyword: keyword, index: index}
      
window.App.FormAutocompletes = {} unless window.App.FormAutocompletes
window.App.FormAutocompletes.Keywords = FormAutocompletes.Keywords