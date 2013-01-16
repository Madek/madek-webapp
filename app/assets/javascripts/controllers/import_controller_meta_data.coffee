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
    @onlyInvalidResourcesToggle = $("#display-only-invalid-resources")
    @invalidResourcesOnly = @onlyInvalidResourcesToggle.is ":checked"
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
      @validateAllResources true
    do @el.delayedChange

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
    $(document).on "click", ".ui-next-entry:not(.disabled)", @setupNextResource
    $(document).on "click", ".ui-prev-entry:not(.disabled)", @setupPrevResource
    @mediaResourcePreviews.on "click", ".ui-resource", (e)=> @setupResourceForEdit _.find(@mediaResources,(resource)-> resource.id == $(e.currentTarget).data("id"))
    $(@).on "form-ready", => @el.on "change delayedChange", @persistField
    $(@).on "form-unload", => @el.off "change delayedChange", @persistField
    @onlyInvalidResourcesToggle.on "change", @switchPreviewDisplay

  switchPreviewDisplay: (e)=>
    input = $(e.currentTarget)
    if input.is ":checked"
      @mediaResourcePreviews.addClass "ui-invalid-resources-only"
      @invalidResourcesOnly = true
    else
      @mediaResourcePreviews.removeClass "ui-invalid-resources-only"
      @invalidResourcesOnly = false
    id = if @invalidResourcesOnly and not @mediaResourcePreviews.find(".ui-selected").hasClass "ui-invalid"
      @mediaResourcePreviews.find(".ui-resource.ui-invalid").data "id"
    else
      @mediaResourcePreviews.find(".ui-resource.ui-selected").data "id"
    @setupResourceForEdit _.find @mediaResources, (mr)-> mr.id is id

  persistField: (e)=>
    return false if $(e.target).closest(".ui-form-group")[0] != $(e.target).closest(".ui-form-group[data-type]")[0]
    field = $(e.target).closest(".ui-form-group[data-type]")
    metaKeyName = field.data "meta-key"
    value = App.MetaDatum.getValueFromField field
    additionalData = App.MetaDatum.getAdditionalDataFromField field
    @currentResource.updateMetaDatum metaKeyName, value, additionalData
    @validateField field, metaKeyName

  validateField: (field, metaKeyName)->
    if @currentResource.validateSingleKey @metaKeyDefinition, metaKeyName
      field.removeClass "error"
    else
      field.addClass "error"
    @validateSingleResource @currentResource, true

  showForm: ->
    @preload.hide()
    @el.removeClass "hidden"

  setupNextResource: => @setupResourceForEdit @getNextResource @currentResource

  setupPrevResource: => @setupResourceForEdit @getPrevResource @currentResource

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
    if @invalidResourcesOnly
      _.find @mediaResources.slice(index, @mediaResources.length), (mr)-> not mr.valid
    else
      @mediaResources[index] if index < (@mediaResources.length)

  getPrevResource: (resource)->
    index = @mediaResources.indexOf(resource)-1
    if @invalidResourcesOnly
      _.find @mediaResources.slice(0, index+1).reverse(), (mr)-> not mr.valid
    else
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
    $(@).trigger "form-unload"
    for field in @el.find(".form-body .ui-form-group[data-type]")
      field = $(field)
      index = field.data "index"
      metaKeyName = field.data "meta-key"
      metaDatumType = field.data "type"
      metaKey = @metaKeyDefinition.getKeyByName metaKeyName
      metaDatum = resource.getMetaDatumByMetaKeyName metaKeyName
      switch metaDatumType
        when "meta_datum_copyright"
          @switchCopyright field, metaDatum
        else
          template = App.render "media_resources/edit/fields/#{metaDatumType}",
            index: index
            definition: metaKey.settings
            meta_datum: metaDatum
          formItemExtension = field.find(".form-item-extension").detach()
          formItemExtensionToggle = field.find(".form-item-extension-toggle").detach()
          field.find(".form-item").html template
          field.find(".form-item").append formItemExtensionToggle
          field.find(".form-item").append formItemExtension
      @validateField field, metaKeyName
    $(@).trigger "form-ready"

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

  validateAllResources: (highlight)->
    anyInvalid = false
    for resource in @mediaResources
      @validateSingleResource resource, highlight
    anyInvalid

  validateSingleResource: (resource, highlight)->
    valid = false
    unless resource.validateForDefinition @metaKeyDefinition
      if highlight
        @mediaResourcePreviews.find(".ui-resource[data-id='#{resource.id}']").addClass "ui-invalid"
      valid = true
    else
      if highlight
        @mediaResourcePreviews.find(".ui-resource[data-id='#{resource.id}']").removeClass "ui-invalid"
      valid = false
    do @checkInvalidToggleDisplay
    valid

  checkInvalidToggleDisplay: ->
    if @mediaResourcePreviews.find(".ui-invalid").length == 0
      @onlyInvalidResourcesToggle.attr("checked", false)
      @onlyInvalidResourcesToggle.attr("disabled", true)
      if @mediaResourcePreviews.hasClass "ui-invalid-resources-only"
        @invalidResourcesOnly = false
        @mediaResourcePreviews.removeClass "ui-invalid-resources-only"
        @setupResourceForEdit @currentResource
    else
      @onlyInvalidResourcesToggle.attr("disabled", false)

window.App.ImportController = {} unless window.App.ImportController
window.App.ImportController.MetaData = ImportController.MetaData