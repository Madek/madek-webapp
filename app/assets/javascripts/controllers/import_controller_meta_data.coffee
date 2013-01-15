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
    do @extendForm
    @paginator.start {collection_id: @collectionId},
      meta_data:
        meta_context_names: ["upload"]
      filename: true
    $(@paginator).on "completlyLoaded", (e, resources...)=> 
      @mediaResources = _.sortBy resources, (resource) -> resource.id
      @setupResourceForEdit @mediaResources[0]
      do @showForm

  extendForm: ->
    new App.FormWidgets.Defaults {el: @el}
    new App.FormWidgets.Person {el: @el}
    new App.FormAutocompletes.Person {el: @el}
    new App.FormWidgets.Keywords {el: @el}
    new App.FormAutocompletes.Keywords {el: @el}
    new App.FormBehaviours.MetaDatumDate {el: @el}
    new App.FormAutocompletes.ExtensibleList {el: @el}
    new App.FormBehaviours.Collapse {el: @el}
    new App.FormBehaviours.Copyrights {el: @el}
    new App.FormAutocompletes.Departments {el: @el}

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
    for field, i in @el.find(".form-body .ui-form-group[data-type]")
      field = $(field)
      metaKeyName = field.data "meta-key"
      metaDatumType = field.data "type"
      metaKey = @metaKeyDefinition.getKeyByName metaKeyName
      metaDatum = resource.getMetaDatumByMetaKeyName metaKeyName
      switch metaDatumType
        when "meta_datum_copyright"
          do (field, metaDatum)=>
            $(@).one "form-setted-up", =>
              @switchCopyright field, metaDatum
        else
          template = App.render "media_resources/edit/fields/#{metaDatumType}",
            i: i
            definition: metaKey.settings
            meta_datum: metaDatum
          formItemExtension = field.find(".form-item-extension").detach()
          formItemExtensionToggle = field.find(".form-item-extension-toggle").detach()
          field.find(".form-item").html template
          field.find(".form-item").append formItemExtensionToggle
          field.find(".form-item").append formItemExtension
    $(@).trigger "form-setted-up"

  switchCopyright: (field, metaDatum)->
    if metaDatum.raw_value.parent_id?
      parentOption = field.find("option[data-id='#{metaDatum.raw_value.parent_id}']")
      parentOption.attr "selected", true
      parentOption.trigger "change"
      parentOption.trigger "select"
    option = field.find("option[data-id='#{metaDatum.raw_value.id}']")
    option.attr "selected", true
    option.trigger "change"
    option.trigger "select"

window.App.ImportController = {} unless window.App.ImportController
window.App.ImportController.MetaData = ImportController.MetaData