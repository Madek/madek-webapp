###

MediaEntries#Browse

###

MediaResourcesController = {} unless MediaResourcesController?
class MediaResourcesController.Browse

  el: ".view-media-resource-browse"

  constructor: (options)->
    @el = $(@el)
    @el.on "inview", ".not-loaded.ui-featured-entries-list", (e)=> @loadBrowsableList $(e.currentTarget)
    @previewAmount = options.previewAmount

  loadBrowsableList: (el)->
    el.removeClass("not-loaded").addClass("loading")
    data = {meta_data: {}, with: {meta_data: {meta_key_names: ["title", "author"]}}, per_page: @previewAmount, sort: "random"}
    data.meta_data[el.data().meta_key] = {ids: []}
    data.meta_data[el.data().meta_key].ids = [el.data().meta_term]
    App.MediaResource.fetch data, (mediaResources, response)=>
      el.removeClass("loading")
      el.html App.render "media_resources/browse/entry", mediaResources

window.App.MediaResourcesController = {} unless window.App.MediaResourcesController
window.App.MediaResourcesController.Browse = MediaResourcesController.Browse