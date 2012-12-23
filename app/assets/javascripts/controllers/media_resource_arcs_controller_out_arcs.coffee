###

Organize OutArcs

###

MediaResourceArcsController = {} unless MediaResourceArcsController?
class MediaResourceArcsController.OutArcs

  constructor: (el)->
    @createStack = []
    @removeArcsStack = []
    @addArcsStack = []
    do @createDialog
    @mediaResource = new App.MediaResource el.closest("[data-id]").data()
    @mediaResource.fetchOutArcs @loadOutArcResources
    do @delegateEvents

  delegateEvents: ->
    @searchInput.on "change delayedChange", => do @search
    @searchForm.on "submit", (e)=> e.preventDefault(); do @createNewSet; return false
    @dialog.on "change", ".ui-set-list-item input", (e)=> @toggleOutArc $(e.currentTarget)
    @dialog.on "submit", "form.save-arcs", @onSubmit 

  toggleOutArc: (input_el)->
    mr = input_el.closest(".ui-set-list-item").tmplItem().data
    if input_el.is ":checked"
      @addToOutArcs mr
    else
      @removeFromOutArcs mr

  removeFromOutArcs: (mr)->
    if _.find(@addArcsStack, (resource) -> resource is mr)
      @addArcsStack = _.reject @addArcsStack, (resource) -> resource is mr
    else
      @removeArcsStack.push mr
    mr.is_parent = false
    @outArcResources = _.filter @outArcResources, (arcResource)-> arcResource.id != mr.id

  addToOutArcs: (mr)->
    if _.find(@removeArcsStack, (resource) -> resource is mr)
      @removeArcsStack = _.reject @removeArcsStack, (resource) -> resource is mr
    else
      @addArcsStack.push mr
    mr.is_parent = true
    @outArcResources.push mr

  createDialog: ->
    @dialog = App.render "media_resource_arcs/organize"
    @searchInput = @dialog.find("input.ui-search-input")
    @searchForm = @dialog.find(".ui-search form")
    @searchInput.delayedChange(delay: 200)
    App.modal @dialog

  search: ->
    return true if @searchInput.val() is @currentSearch
    @currentSearch = @searchInput.val()
    if @searchInput.val().length
      @dialog.find(".refine-search-hint").hide()
      @dialog.find(".try-search-hint").hide()
      @dialog.find(".ui-modal-body").html App.render("media_resource_arcs/organize/loading")
      @searchAjax.abort() if @searchAjax?
      @searchAjax = App.MediaResource.fetch 
        search: @searchInput.val()
        type: "media_sets"
        accessible_action: "edit"
        with: App.MediaResourceArcsController.OutArcs.DEFAULT_WITH
      , (mediaResources, response)=>
        _.each mediaResources, (mr)=>
          mr.is_parent = true if _.any(@outArcResources,(arc)-> arc.id == mr.id)
        mediaResources = (_.sortBy mediaResources, (mr)-> mr.meta_data.title).reverse()
        mediaResources = _.sortBy mediaResources, (mr)-> mr.is_parent
        @dialog.find(".refine-search-hint").show() if response.pagination.total_pages > 1
        @dialog.find(".ui-modal-body").html App.render("media_resource_arcs/organize/list" , {mediaResources: mediaResources})
    else
      @dialog.find(".ui-modal-body").html App.render "media_resource_arcs/organize/list" , {mediaResources: @outArcResources}

  createNewSet: ->
    @searchAjax.abort()
    if @searchInput.val()
      ms = new App.MediaSet
        is_parent: true
        created_at: moment().format()
        meta_data:
          title: @searchInput.val()
          owner: current_user.name
      @outArcResources.unshift ms
      @createStack.push ms
      @searchInput.val ""
      @currentSearch = ""
      @dialog.find(".ui-modal-body").html App.render "media_resource_arcs/organize/list" , {mediaResources: @outArcResources}

  loadOutArcResources: =>
    resourcesLoader = new App.MediaResourcesPaginator
    $(resourcesLoader).bind "completlyLoaded", @renderOutArcResources
    resourcesLoader.start 
      ids: @mediaResource.parentIds
    , 
      App.MediaResourceArcsController.OutArcs.DEFAULT_WITH

  renderOutArcResources: (e, mediaResources...)=>
    @outArcResources = _.sortBy mediaResources, (mr) -> mr.meta_data.title
    _.each @outArcResources, (mr)=>
      mr.is_parent = true
    @dialog.find(".ui-modal-body").html App.render "media_resource_arcs/organize/list" , {mediaResources: @outArcResources}

  onSubmit: =>
    @dialog.prev(".modal-backdrop").off "click"
    @dialog.remove()
    if @createStack.length
      for set in @createStack
        do (set)=>
          set.create (data)=>
            set.id = data.id
            @createStack = _.reject @createStack, (s) => s is set
            do @saveOutArcs unless @createStack.length
    else
      do @saveOutArcs

  saveOutArcs: =>
    do @dialog.remove
    do @deleteRemovedArcs
    do @createNewArcs

  deleteRemovedArcs: =>
    if @removeArcsStack.length
      $.ajax
        url: "/media_resources/parents.json"
        type: "DELETE"
        data: 
          media_resource_id: @mediaResource.id
          parent_media_set_ids: _.map(@removeArcsStack, (mr)-> mr.id)
        success: (response)=> @finish "removeArcsStack"
    else
      @finish "removeArcsStack"

  createNewArcs: =>
    if @addArcsStack.length
      $.ajax
        url: "/media_resources/parents.json"
        type: "POST"
        data: 
          media_resource_id: @mediaResource.id
          parent_media_set_ids: _.map(@addArcsStack, (mr)-> mr.id)
        success: (response)=> @finish "addArcsStack"
    else 
      @finish "addArcsStack"

  finish: (stackName) =>
    delete @[stackName]
    if not @addArcsStack? and not @removeArcsStack?
      window.location = window.location

  @DEFAULT_WITH =
    created_at: true
    meta_data:
      meta_key_names: ["title", "owner"]

jQuery -> $("[data-organize-arcs]").on "click", (e) => new MediaResourceArcsController.OutArcs $(e.currentTarget)

window.App.MediaResourceArcsController = {} unless window.App.MediaResourceArcsController
window.App.MediaResourceArcsController.OutArcs = MediaResourceArcsController.OutArcs