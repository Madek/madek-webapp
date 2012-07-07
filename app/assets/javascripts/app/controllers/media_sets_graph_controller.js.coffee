class MediaSetsGraphController

  el: "section.media_sets_graph"
  
  constructor: ->
    @el = $(@el)
    @inspector = @el.find("#inspector")
    @chart = @el.find("#chart")
    do @delegateEvents
    
  delegateEvents: =>
    @chart.delegate ".node", "click", @inspectNode
    
  inspectNode: (e)=>
    node = $(e.currentTarget)
    App.MediaResources.fetch
      url: "/media_sets/"+node.data("id")+".json"
      success: (data)=>
        @inspector.html($.tmpl "tmpl/media_resource/thumb_box", data)
        # FIXME working here
        #App.MediaResources.fetch_children node.data("id"), (data)=>
        #  @inspector.append($.tmpl "tmpl/media_resource/thumb_box_mini", data.children.media_resources)


window.App.MediaSetsGraph = MediaSetsGraphController
