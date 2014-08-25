###

MediaSets#DisplaySettings

###

MediaSetsController = {} unless MediaSetsController?
class MediaSetsController.DisplaySettings

  el: ".app.view-set"

  constructor: (options)->
    @el = $(@el)
    @mediaSet = new App.MediaSet @el.data()
    @mediaResourcesController = options.mediaResourcesController if options?
    @savedSorting = options.sorting if options?
    @savedLayout = options.layout if options?
    @saveDisplaySettings_el = @el.find("#ui-save-display-settings") if @el.find("#ui-save-display-settings").length
    @button = @saveDisplaySettings_el.find("a") if @saveDisplaySettings_el?
    do @setUnsaved if @button?
    @saveDisplaySettings_el.show() if @saveDisplaySettings_el?
    do @delegateEvents

  delegateEvents: ->
    if @button?
      $(window).on "layout-changed", (e, layout)=> do @setUnsaved
      $(window).on "sorting-changed", (e, sorting)=> do @setUnsaved
      @button.on "click", => do @saveDisplaySettings unless @button.is "[disabled]"

  setUnsaved: ->
    if @savedLayout is @mediaResourcesController.getCurrentVisMode() and @savedSorting is @mediaResourcesController.getCurrentSorting()
      do @setSavedButtonStatus 
    else
      do @setUnSavedButtonStatus

  setSavingButtonStatus: ->
    @saveDisplaySettings_el.find("i")
      .removeClass("icon-eye").addClass("icon-cog icon-spin")
    @button.addClass("disabled").attr "disabled", true
    
  setSavedButtonStatus: ->
    @saveDisplaySettings_el.find("i")
      .removeClass("icon-cog icon-spin").addClass("icon-eye")
      .removeClass("mid").addClass("bright")
    @saveDisplaySettings_el.find(".text").text @saveDisplaySettings_el.data "text-saved"
    @button.addClass("disabled").attr "disabled", true

  ""
  setUnSavedButtonStatus: ->
    @saveDisplaySettings_el.find("i").removeClass("bright").addClass("mid")
    @saveDisplaySettings_el.find(".text").text @saveDisplaySettings_el.data "text-unsaved"
    @button.removeClass("disabled").removeAttr "disabled"

  saveDisplaySettings: ->
    do @setSavingButtonStatus
    @savedLayout = @mediaResourcesController.getCurrentVisMode()
    @savedSorting = @mediaResourcesController.getCurrentSorting()
    $.ajax
      url: "/sets/#{@mediaSet.id}/settings"
      data:
        layout: @savedLayout
        sorting: @savedSorting
      type: "POST"
      success: =>
        do @setSavedButtonStatus
        uri= URI(window.location.href).removeQuery("sort").removeQuery("layout")
        window.history.replaceState uri._parts, document.title, uri.toString()
      error: (jqXHR, textStatus, errorThrown)->
        console.error('saveDisplaySettings: '+textStatus, errorThrown)

window.App.MediaSetsController = {} unless window.App.MediaSetsController
window.App.MediaSetsController.DisplaySettings = MediaSetsController.DisplaySettings
