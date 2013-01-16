###

Organize InArcs like Highlights, CoverImage etc

###

MediaResourceArcsController = {} unless MediaResourceArcsController?
class MediaResourceArcsController.InArcs

  constructor: (options)->
    @el = $(options.el)
    @table = @el.find(".ui-resources-table")
    @mediaSet = options.mediaSet
    @paginator = new App.MediaResourcesPaginator
    @form = @el.find "form"
    @submitButton = @el.find "[type=submit]"
    @changeTarget = options.changeTarget
    do @delegateEvents
    do @fetch

  delegateEvents: ->
    $(@paginator).on "completlyLoaded", (e, resources...)=> 
      @mediaSet.setChildren resources
      do @render
      do @enableSubmit
    @form.on "submit", @persist
    @form.on "change", "input", @change

  fetch: -> @mediaSet.fetchArcs (data)=>
    @paginator.start {ids: _.map @mediaSet.arcs, (arc)-> arc.child_id},
      meta_data:
        meta_context_names: ["core"]

  render: ->
    template = App.render "media_resource_arcs/selection", 
      metaData: @mediaSet.children[0].meta_data
      mediaResources: if @changeTarget == "cover" then @mediaSet.mediaEntries() else if @changeTarget == "highlight" then @mediaSet.children
      mediaSet: @mediaSet
      changeTarget: @changeTarget
    template.find("input:checked").closest("tr").prependTo template.find("tbody")
    @table.html template

  enableSubmit: ->
    @submitButton.removeAttr("disabled").removeClass "disabled"

  persist: (e)=>
    do e.preventDefault
    @mediaSet.persistArcs =>
      do @el.remove
      document.location.reload true
    return false

  change: (e)=>
    input = $(e.currentTarget)
    mr = new App.MediaResource input.closest("[data-id]").data()
    if input.is ":checked"
      if @changeTarget == "highlight"
        @mediaSet.setHighlight mr
      else if @changeTarget == "cover"
        @mediaSet.setCover mr
    else
      if @changeTarget == "highlight"
        @mediaSet.unsetHighlight mr

window.App.MediaResourceArcsController = {} unless window.App.MediaResourceArcsController
window.App.MediaResourceArcsController.InArcs = MediaResourceArcsController.InArcs