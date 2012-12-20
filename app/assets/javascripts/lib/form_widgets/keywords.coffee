###

FormWidget for Keywords

###

FormWidgets = {} unless FormWidgets?
class FormWidgets.Keywords

  constructor: (options)->
    @el = options.el
    do @delegateEvents

  delegateEvents: ->
    @el.on "click", ".ui-form-group[data-type='meta_datum_keywords'] .ui-tag-button", (e)=> @addKeyword $(e.currentTarget)
    @el.on "click", ".ui-form-group[data-type='meta_datum_keywords'] .form-widget-toggle:not(.active):not(.loaded):not(.loading)", (e)=> @showKeywords $(e.currentTarget)

  showKeywords: (toggle)->
    toggle.addClass(".loading")
    unless App.Keyword.all()?
      App.Keyword.fetch null, =>
        toggle.removeClass(".loading")
        toggle.addClass(".loaded")
        @renderKeywords toggle
    else
      @renderKeywords toggle

  renderKeywords: (toggle)->
    widget = toggle.next(".form-tags-widget")
    widget.find(".tags-mine").html App.render "keywords/keyword", App.Keyword.mine()
    widget.find(".tags-top").html App.render "keywords/keyword", App.Keyword.top()
    widget.find(".tags-latest").html App.render "keywords/keyword", App.Keyword.latest()

  addKeyword: (keyword)->
    holder = keyword.closest(".multi-select-holder")
    return true if holder.find(".multi-select-tag [value=#{keyword.data().id}]").length
    index = keyword.closest(".ui-form-group").data "index"
    holder.find(".multi-select-input-holder").before App.render "media_resources/edit/multi-select/keyword",
      index: index
      keyword: keyword.data()

window.App.FormWidgets = {} unless window.App.FormWidgets
window.App.FormWidgets.Keywords = FormWidgets.Keywords