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
    @imageZoom = @el.find("#ui-image-zoom")
    @exportButton = @el.find("#ui-export-button")
    @export = @el.find("#ui-export-dialog")
    do @delegateEvents

  delegateEvents: ->
    @imageZoom.on "click", (e)=> @zoomImage $(e.currentTarget)
    @exportButton.on "click", => do @showExport

  showExport: ->
    App.modal @export.clone().show()

  zoomImage: (target)->
    dialog = App.render "media_entries/image_zoom", {img: "/media_resources/#{@id}/image?size=maximum"}
    dialog.on "click", ->
      dialog.modal("hide")
    dialogImage = dialog.find("img")
    targetImage = target.prev("img").clone()
    targetImage.addClass "ui-image-zoom"
    dialogImage.css("max-width", @media_file.width).css("max-height", @media_file.height)
    targetImage.css("max-width", @media_file.width).css("max-height", @media_file.height)
    dialogImage.before targetImage
    dialogImage.on "load", -> targetImage.remove()
    App.modal dialog

window.App.MediaEntriesController = {} unless window.App.MediaEntriesController
window.App.MediaEntriesController.Show = MediaEntriesController.Show