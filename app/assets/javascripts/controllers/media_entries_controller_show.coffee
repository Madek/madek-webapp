###

MediaEntries#Show

###

MediaEntriesController = {} unless MediaEntriesController?
class MediaEntriesController.Show

  el: ".app.view-media-entry"

  constructor: (data)->
    @id = data.id
    @media_file = data.media_file
    @el = $(@el)
    @exportButton = @el.find("#ui-export-button")
    @export = @el.find("#ui-export-dialog")
    do @delegateEvents

  delegateEvents: ->
    @exportButton.on "click", => do @showExport

  showExport: ->
    App.modal @export.clone().show()

window.App.MediaEntriesController = {} unless window.App.MediaEntriesController
window.App.MediaEntriesController.Show = MediaEntriesController.Show