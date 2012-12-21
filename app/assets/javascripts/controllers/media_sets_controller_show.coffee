###

MediaSets#Show

###

MediaSetsController = {} unless MediaSetsController?
class MediaSetsController.Show

  el: ".app.view-set"

  constructor: ->
    @el = $(@el)
    @selectHighlightsButton = @el.find("#ui-select-highlights")
    @selectCoverButton = @el.find("#ui-select-cover")
    do @delegateEvents

  delegateEvents: ->
    @selectHighlightsButton.on "click", => do @selectHighlights
    @selectCoverButton.on "click", => do @selectCover

  selectHighlights: -> @openSelectArcs "Inhalte hervorheben", "highlight"

  selectCover: -> @openSelectArcs "Titelbild für Set festlegen", "cover"
    
  openSelectArcs: (title, target)->
    dialog = App.render "media_sets/select_arcs",
      title: title
    App.modal dialog
    new App.MediaResourceArcsController.InArcs
      el: dialog
      mediaSet: new App.MediaSet(@el.data())
      changeTarget: target

window.App.MediaSetsController = {} unless window.App.MediaSetsController
window.App.MediaSetsController.Show = MediaSetsController.Show