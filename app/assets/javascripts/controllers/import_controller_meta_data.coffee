###

Input and Edit MetaData during import

###

ImportController = {} unless ImportController?
class ImportController.MetaData

  constructor: (options)->
    @metaKeyDefinition = options.metaKeyDefinition
    @paginator = new App.MediaResourcesPaginator
    @collectionId = options.collectionId
    @preload = $("#ui-edit-meta-data-preload")
    @el = $("#ui-edit-meta-data")
    @nextButton = @el.find ".ui-next-entry"
    @nextTitle = @nextButton.find ".ui-entry-control-title"
    @prevButton = @el.find ".ui-prev-entry"
    @prevTitle = @prevButton.find ".ui-entry-control-title"
    @currentTitle = @el.find ".ui-current-entry .ui-entry-control-title"
    do @delegateEvents
    @paginator.start {collection_id: @collectionId},
      meta_data:
        meta_context_names: ["upload"]
      filename: true
    $(@paginator).on "completlyLoaded", (e, resources...)=> 
      @mediaResources = _.sortBy resources, (resource) -> resource.id
      @setupResourceForEdit @mediaResources[0]
      do @showForm

  delegateEvents: ->
    $(document).on "click", ".ui-next-entry:not(.disabled)", @nextResource
    $(document).on "click", ".ui-prev-entry:not(.disabled)", @prevResource

  showForm: ->
    @preload.hide()
    @el.removeClass "hidden"

  nextResource: => @setupResourceForEdit @getNextResource @currentResource

  prevResource: => @setupResourceForEdit @getPrevResource @currentResource

  setupResourceForEdit: (resource)->
    @currentResource = resource
    @currentTitle.html resource.filename
    @setButton @getNextResource(resource), "next"
    @setButton @getPrevResource(resource), "prev"

  getNextResource: (resource)->
    index = @mediaResources.indexOf(resource)+1
    @mediaResources[index] if index < @mediaResources.length - 1

  getPrevResource: (resource)->
    index = @mediaResources.indexOf(resource)-1
    @mediaResources[index] if index > 0

  setButton: (resource, target)->
    @button = if target == "next" then @nextButton else if target == "prev" then @prevButton
    @title = if target == "next" then @nextTitle else if target == "prev" then @prevTitle
    if resource?
      @button.removeClass "disabled"
      @button.attr "title", resource.filename
      @title.html resource.filename
    else
      @button.addClass "disabled"
      @button.attr "title", ""
      @title.html ""

window.App.ImportController = {} unless window.App.ImportController
window.App.ImportController.MetaData = ImportController.MetaData