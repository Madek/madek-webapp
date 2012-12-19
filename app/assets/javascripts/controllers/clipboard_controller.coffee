###

ClipboardController

Controller for the Clipboard / Batchbar

###

class ClipboardController

  el: ".app-clipboard"
  scrollStop_el: ".app-footer"
  visibleResources: {}
  collection: new App.Collection
  editableMediaEntriesCollection: new App.Collection
  manageableCollection: new App.Collection
  
  constructor: (options)->
    @el = if options? and options.el? then $(options.el) else $(@el)
    @ui_el = @el.find ".ui-clipboard"
    @content_el = @el.find ".ui-clipboard-content"
    @list_el = @el.find ".ui-clipboard-resources-list"
    @toggle_el = @el.find "#clipboard-toggle"
    @scrollStop_el = $(@scrollStop_el)
    @counter_el = @el.find ".ui-clipboard-counter"
    @clear_el = @el.find ".ui-clipboard-clear"
    @emptyAlert_el = @el.find(".ui-clipboard-empty-alert")
    @sizeAlert_el = @el.find(".ui-clipboard-size-alert")
    @selectAll_el = $("#ui-clipboard-select-all")
    @actions = @el.find ".ui-clipboard-actions"
    @actions_trigger = @el.find ".ui-clipboard-actions .primary-button.block.dropdown-toggle"
    do @restoreVisibleResources
    do @restoreCollections
    do @delegateEvents
    do @checkPosition

  delegateEvents: ->
    $(window).on "scroll resize render-inital-fetch layout-changed sorting-changed widget-toggled", => do @checkPosition
    @toggle_el.bind "click", => do @toggle
    @el.on "mouseenter", => do @clearToggleAnimation
    @content_el.on "click", ".ui-resource-clipboard-remove", "click", (e) => @removeElement(e.currentTarget)
    @clear_el.on "click", => do @clear
    @selectAll_el.bind "click", => do @selectAll unless @selectAll_el.hasClass(".disabled")
    $("[data-clipboard-toggle]").live "click", (e)=> @toggleSelection $(e.currentTarget)
    $(".ui-thumbnail-action-checkbox:visible").live "inview", (e)=> @checkClipboardState $(e.currentTarget)
    $(".active.ui-resources .ui-resource").live "mouseenter", (e)=> @checkClipboardState $(e.currentTarget).find(".ui-thumbnail-action-checkbox")
    $(@collection).bind "refresh", => do @saveCollection and do @updateCount
    $(@editableMediaEntriesCollection).bind "refresh", => do @saveEditableMediaEntriesCollection and do @updateEditableButtons
    $(@manageableCollection).bind "refresh", => do @saveManageableCollection and do @updateManageableButtons
    $(window).on "render-inital-fetch", => do @enableSelectAll
    $(window).on "start-inital-fetch", => do @disableSelectAll
    @actions_trigger.on "click", @validateActionMenu

  validateActionMenu: (e)=>
    if @collection.count == 0
      e.preventDefault()
      @emptyAlert_el.find(".text").shake()
      return false
    return true

  updateEditableButtons: ->
    editableCount = @editableMediaEntriesCollection.count
    @actions.find(".ui-clipboard-edit-button .ui-count").html editableCount
    if editableCount == 0
      @actions.find(".ui-clipboard-edit-button").hide()
    else
      @actions.find(".ui-clipboard-edit-button").show()
      for a in @actions.find(".ui-clipboard-edit-button a")
        $(a).attr "href", "#{$(a).attr("href")}?collection_id=#{@editableMediaEntriesCollection.id}"

  updateManageableButtons: ->
    manageableCount = @manageableCollection.count
    @actions.find(".ui-clipboard-manage-button .ui-count").html manageableCount
    if manageableCount == 0
      @actions.find(".ui-clipboard-manage-button").hide()
    else
      @actions.find(".ui-clipboard-manage-button").show()

  enableSelectAll: ->
    @selectAll_el.removeClass "disabled"
    if @collection.filter[JSON.stringify(App.currentFilter)]?
      do @activateSelectAll

  addToCollections: (filter)->
    filter = _.clone filter
    @collection.add filter
    @manageableCollection.add $.extend(filter, {accessible_action: "manage"})
    @editableMediaEntriesCollection.add $.extend(filter, {accessible_action: "edit", type: "media_entries"})

  removeFromCollections: (filter)->
    filter = _.clone filter
    @collection.remove filter, (data)=>
      @removeFromVisibleResources data.removed_ids
    @manageableCollection.remove $.extend(filter, {accessible_action: "manage"})
    @editableMediaEntriesCollection.remove $.extend(filter, {accessible_action: "edit", type: "media_entries"})

  disableSelectAll: ->
    @selectAll_el.addClass "disabled"
    do @deActivateSelectAll

  updateCount: ->
    count = @collection.count
    @counter_el.html count
    if count is 0
      do @showEmptyAlert
      do @counter_el.hide
    else
      do @showList
      do @counter_el.show
    if count > 99
      do @showSizeAlert 
      do @clearList
    else if count != 0
      do @renderVisibleItems

  renderVisibleItems: ->
    if (_.any (@collection.ids), (id)=> not @visibleResources[id]?)
      App.MediaResource.fetch
        pagination: 
          per_page: 100
        ids: @collection.ids
        with: 
          media_type: true
          type: true
          title: true
      , (media_resources, response)=>
        for mr in media_resources
          @addToVisibleResources mr
    else
      media_resources = for k,v of @visibleResources
        new App.MediaResource _.extend v, {id: parseInt(k)}
      @list_el.html App.render "clipboard/media_resource", media_resources
      
  showSizeAlert: ->
    do @sizeAlert_el.siblings().hide
    do @sizeAlert_el.show

  showEmptyAlert: ->
    do @emptyAlert_el.siblings().hide
    do @emptyAlert_el.show

  showList: ->
    do @list_el.siblings().hide
    do @list_el.show

  clearList: -> @list_el.html ""

  saveCollections: -> 
    do @saveCollection
    do @saveEditableMediaEntriesCollection
    do @saveManageableCollection

  saveCollection: ->
    sessionStorage.clipboardCollection = JSON.stringify @collection.forSessionStorage()

  saveEditableMediaEntriesCollection: ->
    sessionStorage.clipboardEditableMediaEntriesCollection = JSON.stringify @editableMediaEntriesCollection.forSessionStorage()

  saveManageableCollection: ->
    sessionStorage.clipboardManageableCollection = JSON.stringify @manageableCollection.forSessionStorage()

  restoreCollections: ->
    if sessionStorage.clipboardCollection?
      @collection.refreshData JSON.parse sessionStorage.clipboardCollection
      do @updateCount
    if sessionStorage.clipboardEditableMediaEntriesCollection?
      @editableMediaEntriesCollection.refreshData JSON.parse sessionStorage.clipboardEditableMediaEntriesCollection
    if sessionStorage.clipboardManageableCollection?
      @manageableCollection.refreshData JSON.parse sessionStorage.clipboardManageableCollection
    do @updateManageableButtons
    do @updateEditableButtons

  destroyCollections: ->
    do @collection.destroy
    do @editableMediaEntriesCollection.destroy
    do @manageableCollection.destroy

  selectAll: ->
    unless @selectAll_el.hasClass "active"
      @addToCollections App.currentFilter
      do @activateSelectAll
    else
      @removeFromCollections App.currentFilter
      do @deActivateSelectAll

  activateSelectAll: ->
    @selectAll_el.addClass "active"
    @selectAll_el.find(".icon-checkbox").addClass "active"

  deActivateSelectAll: ->
    @selectAll_el.removeClass "active"
    @selectAll_el.find(".icon-checkbox").removeClass "active"

  clearToggleAnimation: -> clearTimeout @toggleAnimationTimer if @toggleAnimationTimer?

  toggleSelection: (element)->
    element = element.find(".ui-thumbnail-action-checkbox") unless element.is ".ui-thumbnail-action-checkbox"
    container = element.closest "[data-id]"
    mr = new App.MediaResource container.data()
    if element.is ".active"
      element.removeClass "active"
      container.find(".ui-thumbnail-action-checkbox").removeClass "active"
      @remove mr
    else
      element.addClass "active"
      container.find(".ui-thumbnail-action-checkbox").addClass "active"
      @add mr

  restoreVisibleResources: ->
    if sessionStorage.visibleResources?
      @visibleResources = JSON.parse sessionStorage.visibleResources 
      media_resources = for k,v of @visibleResources
        new App.MediaResource _.extend v, {id: parseInt(k)}
      @list_el.html App.render "clipboard/media_resource", media_resources

  add: (mr)->
    do @openClose if @collection.count is 0 and @ui_el.is ".closed"
    @addToCollections {ids: [mr.id]}
    @addToVisibleResources mr

  openClose: -> 
    do @toggle  
    @toggleAnimationTimer = setTimeout (=> do @toggle), 1500

  removeElement: (element)-> @remove new App.MediaResource $(element).closest(".ui-resource").data()

  remove: (mr)->
    @removeFromCollections {ids: [mr.id]}
    @removeFromVisibleResources [mr.id]
    @list_el.find("[data-id='#{mr.id}']").remove()
    if @collection.count == 0 and @ui_el.is ":not(.closed)"
      do @clearToggleAnimation
      do @toggle
    @deactivateCheckbox mr
    do @deActivateSelectAll

  deactivateCheckbox: (mr)-> $("[data-id='#{mr.id}'] .ui-thumbnail-action-checkbox").removeClass "active"

  clear: ->
    do @resetVisibleResources
    do @clearList
    do @deActivateSelectAll
    do @destroyCollections
    do @toggle if @ui_el.is ":not(.closed)"
    do @saveCollections

  resetVisibleResources: ->
    @visibleResources = {}
    delete sessionStorage.visibleResources
    do @saveVisibleResources

  addToVisibleResources: (mr)->
    template = App.render "clipboard/media_resource", mr
    @list_el.append template
    @visibleResources[mr.id] = 
      title: mr.title
      type: mr.type
      media_type: mr.media_type
    do @saveVisibleResources

  removeFromVisibleResources: (ids)->
    for id in ids
      delete @visibleResources[id]
    do @saveVisibleResources

  saveVisibleResources: -> 
    if @collection.count > 0
      sessionStorage.visibleResources = JSON.stringify @visibleResources
    else
      delete sessionStorage.visibleResources

  toggle: ->
    @content_el.slideToggle "fast"
    if @ui_el.is ".closed"
      @ui_el.removeClass "closed"
      $("body").addClass "ui-clipboard-open"
    else
      @ui_el.addClass "closed"
      $("body").removeClass "ui-clipboard-open"

  checkPosition: ->
    scrollStopTop = @scrollStop_el.offset().top
    currentScrollBottom = ($(document).scrollTop() + $(window).height())
    if currentScrollBottom > scrollStopTop
      offset = currentScrollBottom - scrollStopTop
      @el.css "bottom", offset
      @el.addClass "scroll-stop"
    else if @el.is(".scroll-stop")
      @el.css "bottom", 0
      @el.removeClass "scroll-stop"

  checkClipboardState: (target_el)->
    mr_el = $(target_el[0]).closest "[data-id]"
    id = mr_el.data "id"
    if @visibleResources[id]? or _.contains @collection.ids, id
      target_el.addClass "active"
    else
      target_el.removeClass "active"

window.App.ClipboardController = ClipboardController