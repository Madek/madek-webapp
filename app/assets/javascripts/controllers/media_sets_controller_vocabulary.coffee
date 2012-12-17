###

MediaSets#Vocabulary

###

MediaSetsController = {} unless MediaSetsController?
class MediaSetsController.Vocabulary

  el: ".app.view-set"

  constructor: (options)->
    @el = $(@el)
    @vocabulary = @el.find("#ui-media-set-vocabulary")
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

window.App.MediaSetsController = {} unless window.App.MediaSetsController
window.App.MediaSetsController.Vocabulary = MediaSetsController.Vocabulary