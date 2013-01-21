###

Organize OutArcs (add/remove set children)

###

MediaResourceArcsController = {} unless MediaResourceArcsController?
class MediaResourceArcsController.OutArcs

  constructor: (el)->
    @createStack = []
    @removeArcsStack = []
    @addArcsStack = []
    @outArcResources = []
    do @createDialog
    if el.data("collection")?
      @collection = el.data "collection"
      do @fetchOutArcsThroughCollection
    else if el.data("collection-id")?
       @collection = new App.Collection
          id: el.data("collection-id")
        @collection.get =>
          do @fetchOutArcsThroughCollection
    else
      @mediaResource = new App.MediaResource el.closest("[data-id]").data()
      @mediaResource.fetchOutArcs => @loadOutArcResources @mediaResource.parentIds
    do @delegateEvents

  fetchOutArcsThroughCollection: =>
    $.ajax
      url: "/media_resource_arcs.json"
      data:
        collection_id: @collection.id
      success: (response)=>
        arcs = response.media_resource_arcs
        parentIds = _.map arcs, (arc)-> arc.parent_id
        parentIds = _.uniq parentIds, true
        @incompleteArcParentIds = []
        _.each parentIds, (parentId)=> 
          _.each @collection.ids, (childId) =>
            unless (_.find arcs, (arc) -> arc.child_id is childId and arc.parent_id is parentId)
              @incompleteArcParentIds.push parentId
        if @incompleteArcParentIds.length
          @dialog.find(".try-search-hint").hide()
          @dialog.find(".incomplete-arcs-hint").show()
        @loadOutArcResources parentIds

  delegateEvents: ->
    @searchInput.on "change delayedChange", => do @search
    @searchForm.on "submit", (e)=> e.preventDefault(); do @createNewSet; return false
    @dialog.on "change", ".tristate-checkbox-container input", (e)=> @changeTristate $(e.currentTarget)
    @dialog.on "change", ".ui-set-list-item input", (e)=> @toggleOutArc $(e.currentTarget)
    @dialog.on "submit", "form.save-arcs", @onSubmit 

  changeTristate: (input)->
    mixedIndicator = input.next(".tristate-checkbox-mixed-value")
    if input.val() is "mixed"
      mixedIndicator.hide()
      input.val("none")
      input.attr "checked", false
    else if input.val() is "none"
      mixedIndicator.hide()
      input.val("all")
      input.attr "checked", true
    else if input.val() is "all"
      mixedIndicator.show()
      input.val("mixed")
      input.attr "checked", false

  toggleOutArc: (input)->
    mr = input.closest(".ui-set-list-item").tmplItem().data
    if input.val() is "mixed"
      @addArcsStack = _.reject @addArcsStack, (resource) -> resource is mr
      @removeArcsStack = _.reject @removeArcsStack, (resource) -> resource is mr
    else if input.is ":checked"
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
    @removeArcsStack = _.reject @removeArcsStack, (resource) -> resource is mr
    @addArcsStack.push mr
    mr.is_parent = true
    @outArcResources.push mr

  createDialog: ->
    @dialog = App.render "media_resource_arcs/organize"
    @searchInput = @dialog.find("input.ui-search-input")
    @searchForm = @dialog.find(".ui-search form")
    @searchInput.delayedChange(delay: 400)
    new App.Modal @dialog

  search: ->
    return true if @searchInput.val() is @currentSearch
    @dialog.find(".incomplete-arcs-hint").hide()
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
        mediaResources = _.filter mediaResources, (mr)=>
          mr.is_parent = true if _.any(@outArcResources,(arc)-> arc.id == mr.id)
          mr.is_incomplete_arc = _.include @incompleteArcParentIds, mr.id
          if @mediaResource?
            return (mr.id != @mediaResource.id)
          else
            return not _.include @collection.ids, mr.id
        if mediaResources.length
          mediaResources = (_.sortBy mediaResources, (mr)-> mr.getMetaDatumByMetaKeyName("title")).reverse()
          mediaResources = _.sortBy mediaResources, (mr)-> mr.is_parent
          @dialog.find(".refine-search-hint").show() if response.pagination.total_pages > 1
          @dialog.find(".ui-modal-body").html App.render("media_resource_arcs/organize/list" , {mediaResources: mediaResources})
        else
          @dialog.find(".ui-modal-body").html App.render "media_resource_arcs/organize/empty_results"
    else
      @dialog.find(".ui-modal-body").html App.render "media_resource_arcs/organize/list" , {mediaResources: @outArcResources}

  createNewSet: ->
    @searchAjax.abort() if @searchAjax?
    if @searchInput.val()
      ms = new App.MediaSet
        is_parent: true
        created_at: moment().format()
        meta_data: [
          {name: "title", value: @searchInput.val()},
          {name: "owner", value: currentUser.name}
        ]
      @outArcResources.unshift ms
      @createStack.push ms
      @searchInput.val ""
      @currentSearch = ""
      @dialog.find(".ui-modal-body").html App.render "media_resource_arcs/organize/list" , {mediaResources: @outArcResources}

  loadOutArcResources: (ids)=>
    if ids.length
      resourcesLoader = new App.MediaResourcesPaginator
      $(resourcesLoader).bind "completlyLoaded", @renderOutArcResources
      resourcesLoader.start 
        ids: ids
        accessible_action: "edit"
      , 
        App.MediaResourceArcsController.OutArcs.DEFAULT_WITH
    else
      @dialog.find(".ui-modal-body").html App.render "media_resource_arcs/organize/no_arcs_yet"

  renderOutArcResources: (e, mediaResources...)=>
    @outArcResources = _.sortBy mediaResources, (mr) -> mr.getMetaDatumByMetaKeyName("title")
    _.each @outArcResources, (mr)=>
      mr.is_incomplete_arc = _.include @incompleteArcParentIds, mr.id
      mr.is_parent = true
    @dialog.find(".ui-modal-body").html App.render "media_resource_arcs/organize/list" , {mediaResources: @outArcResources}

  onSubmit: (e)=>
    do e.preventDefault
    @dialog.prev(".modal-backdrop").off "click"
    @dialog.remove()
    if @createStack.length
      for set in @createStack
        do (set)=>
          set.create (data)=>
            set.id = data.id
            @createStack = _.reject @createStack, (s) => s is set
            if set.is_parent
              @addArcsStack.push set
            do @saveOutArcs unless @createStack.length
    else
      do @saveOutArcs
    return false

  saveOutArcs: =>
    do @deleteRemovedArcs
    do @createNewArcs

  deleteRemovedArcs: =>
    data = {parent_media_set_ids: _.map(@removeArcsStack, (mr)-> mr.id)}
    $.extend data, {media_resource_id: @mediaResource.id} if @mediaResource
    $.extend data, {collection_id: @collection.id} if @collection
    if @removeArcsStack.length
      $.ajax
        url: "/media_resources/parents.json"
        type: "DELETE"
        data: data
        success: (response)=> @finish "removeArcsStack"
    else
      @finish "removeArcsStack"

  createNewArcs: =>
    data = {parent_media_set_ids: _.map(@addArcsStack, (mr)-> mr.id)}
    $.extend data, {media_resource_id: @mediaResource.id} if @mediaResource
    $.extend data, {collection_id: @collection.id} if @collection
    if @addArcsStack.length
      $.ajax
        url: "/media_resources/parents.json"
        type: "POST"
        data: data
        success: (response)=> @finish "addArcsStack"
    else 
      @finish "addArcsStack"

  finish: (stackName) =>
    delete @[stackName]
    if not @addArcsStack? and not @removeArcsStack?
      document.location.reload true

  @DEFAULT_WITH =
    created_at: true
    meta_data:
      meta_key_names: ["title", "owner"]

jQuery -> $(document).on "click", "[data-organize-arcs]", (e) => new MediaResourceArcsController.OutArcs $(e.currentTarget)

window.App.MediaResourceArcsController = {} unless window.App.MediaResourceArcsController
window.App.MediaResourceArcsController.OutArcs = MediaResourceArcsController.OutArcs