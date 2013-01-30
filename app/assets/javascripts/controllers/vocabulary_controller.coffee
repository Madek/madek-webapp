###

Vocabulary

###

class VocabularyController

  constructor: (options)->
    @el = $(options.el)
    @vocabulary = @el.find("#ui-vocabulary")
    @highlightButton = @el.find("#ui-highlight-used-terms")
    @highlightButton.show()
    do @delegateEvents

  delegateEvents: ->
    @highlightButton.on "click", => do @toggleHighlight

  toggleHighlight: ->
    if @highlightButton.is ".active"
      @highlightButton.find(".icon-checkbox").removeClass "active"
      @highlightButton.removeClass "active"
      @vocabulary.removeClass "highlight-used-terms"
    else
      @highlightButton.find(".icon-checkbox").addClass "active"
      @highlightButton.addClass "active"
      @vocabulary.addClass "highlight-used-terms"

window.App.VocabularyController = VocabularyController