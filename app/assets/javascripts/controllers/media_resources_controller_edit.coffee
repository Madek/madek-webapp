###

MediaResources#Edit

Controller for MediaResources Edit

###

MediaResourcesController = {} unless MediaResourcesController?
class MediaResourcesController.Edit

  el: "#edit-media-resource"

  constructor: ->
    @el = $(@el)
    console.log "EDIT CONTROLLER"

window.App.MediaResourcesController = {} unless window.App.MediaResourcesController
window.App.MediaResourcesController.Edit = MediaResourcesController.Edit