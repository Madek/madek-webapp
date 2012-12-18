###

FormAutocomplete for Keywords

###

FormAutocompletes = {} unless FormAutocompletes?
class FormAutocompletes.Keywords

  constructor: (options)->
    @el = options.el
    @el.find(".form-autocomplete-keywords").autocomplete
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
        @addKeyword keyword, input
        input.val ""
        return false

  addKeyword: (keyword, input)->
    holder = input.closest(".multi-select-holder")
    return true if holder.find(".multi-select-tag [value=#{keyword.id}]").length
    index = holder.closest(".ui-form-group").data "index"
    multiselect = holder.find(".multi-select-input-holder")
    multiselect.before App.render "media_resources/edit/widgets/keywords/multi-select-tag", {keyword: keyword, index: index}
      
window.App.FormAutocompletes = {} unless window.App.FormAutocompletes
window.App.FormAutocompletes.Keywords = FormAutocompletes.Keywords