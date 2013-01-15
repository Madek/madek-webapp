###

Input and Edit MetaData during import

###

ImportController = {} unless ImportController?
class ImportController.MetaData

  constructor: (options)->
    @metaKeyDefinition = new App.MetaKeyDefinition options.metaKeyDefinition
    @paginator = new App.MediaResourcesPaginator
    @collectionId = options.collectionId
    @preload = $("#ui-edit-meta-data-preload")
    @el = $("#ui-edit-meta-data")
    @nextButton = @el.find ".ui-next-entry"
    @nextTitle = @nextButton.find ".ui-entry-control-title"
    @prevButton = @el.find ".ui-prev-entry"
    @prevTitle = @prevButton.find ".ui-entry-control-title"
    @currentTitle = @el.find ".ui-current-entry .ui-entry-control-title"
    @mediaResourcePreviews = $("#ui-resources-preview")
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
    @mediaResourcePreviews.on "click", ".ui-resource", (e)=> @setupResourceForEdit _.find(@mediaResources,(resource)-> resource.id == $(e.currentTarget).data("id"))

  showForm: ->
    @preload.hide()
    @el.removeClass "hidden"

  nextResource: => @setupResourceForEdit @getNextResource @currentResource

  prevResource: => @setupResourceForEdit @getPrevResource @currentResource

  setupResourceForEdit: (resource)->
    @currentResource = resource
    @currentTitle.html resource.filename
    @markAsSelected resource
    @setButton @getNextResource(resource), "next"
    @setButton @getPrevResource(resource), "prev"
    @setupFormFor resource

  markAsSelected: (resource)->
    @mediaResourcePreviews.find(".ui-selected").removeClass "ui-selected"
    @mediaResourcePreviews.find(".ui-resource[data-id='#{resource.id}']").addClass "ui-selected"

  getNextResource: (resource)->
    index = @mediaResources.indexOf(resource)+1
    @mediaResources[index] if index < (@mediaResources.length)

  getPrevResource: (resource)->
    index = @mediaResources.indexOf(resource)-1
    @mediaResources[index] if index >= 0

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

  setupFormFor: (resource)->
    for field, i in @el.find(".form-body").children(".ui-form-group")
      field = $(field)
      metaKeyName = field.data "meta-key"
      metaDatumType = field.data "type"
      metaKey = @metaKeyDefinition.getKeyByName metaKeyName
      metaDatum = resource.getMetaDatumByMetaKeyName metaKeyName
      template = App.render "media_resources/edit/fields/form_items/#{metaDatumType}",
        i: i
        definition: metaKey.settings
        meta_datum: metaDatum
      field.find(".form-item").html template

window.App.ImportController = {} unless window.App.ImportController
window.App.ImportController.MetaData = ImportController.MetaData