class MediaSetsGraphController

  el: "section.media_sets_graph"
  start_scale = 1.2
  ticks = 100
  @inspectionLoader
  @background
  @children
  @inspector
  @overlayManager
  @graphJson
  @chart
  @layout
  
  constructor: ->
    @el = $(@el)
    @inspector = @el.find("#inspector")
    @chart = @el.find("#chart")
    @marker_size = 10
    do @setDimensions
    do @setupGraph
    do @setupInspector
    do @setupOverlayManager
    do @extendFavoriteToggle
    do @drawGraph
    do @disableBar
    do @delegateEvents
    do @plugin

  plugin: =>
    do @setupBatch

  setupBatch: =>    
    $(".task_bar").show()
    do window.setupBatch
    do @extendSelectAll

  extendSelectAll: =>
    $("#batch-select-all").unbind "click"
    $("#batch-select-all").bind "click", (e)=>
      do e.preventDefault
      media_resources = @graphJson.nodes
      set_media_resources_json(media_resources)
      $('#selected_items').html $("#thumbnail_mini").tmpl(media_resources)
      displayCount()

  extendFavoriteToggle: =>
    @inspector.delegate ".favorite_link", "click", (e)=>
      target = $(e.currentTarget)
      if target.find(".button_favorit_on").length # switched off
        $(".node[data-selected]").find(".favorite").attr("href", "")
      else if target.find(".button_favorit_off").length # switched on
        $(".node[data-selected]").find(".favorite").attr("href", "/assets/icons/button_favorit_on.png")
    
  delegateEvents: =>
    @chart.delegate ".node", "click", @inspectNode
    @el.delegate ".node", "mouseenter", @enterNode
    @el.delegate ".node", "mouseleave", @leaveNode
    $(window).bind "resize", @resize

  resize: (e)=>
    do @setDimensions
    do @setInspectorDimension
    @chart.find("svg").attr("height", @height).attr("width", @width)

  enterNode: (e)=>
    node = $(e.currentTarget)
    node.attr("data-hover",true)
    node.appendTo node.parent()
    translate = node.attr("transform").match(/translate\(.*?\)/)
    graph_scale = parseInt @graph.attr("transform").replace(/translate\(.*?\)/,"").replace(/scale\(/,"").replace(/\)$/,"")
    new_scale = if (1.7-graph_scale<1) then 1 else (1.7-graph_scale)
    transform = "#{translate}scale(#{new_scale})"
    node.attr("transform", transform)
    
  leaveNode: (e)=>
    node = $(e.currentTarget)
    node.removeAttr("data-hover")
    translate = node.attr("transform").match(/translate\(.*?\)/)
    node.attr("transform", translate)
  
  setDimensions: =>
    @width = @el.innerWidth() - @inspector.outerWidth() - (@el.outerWidth()-@el.width())
    @height = $(window).height() - @chart.offset().top - $("footer").outerHeight() - $(".task_bar").height()
    
  setupGraph: => 
    @svg = d3.select("#chart").append("svg").attr("height", @height).attr("width", @width).call(d3.behavior.zoom().scale(start_scale).on("zoom", @redrawGraph))
    $(@svg).addClass(".svg")
    @svg.append("svg:defs").selectAll("marker")
        .data(["suit"])
      .enter().append("svg:marker")
        .attr("id", String)
        .attr("viewBox", "0 -5 10 10")
        .attr("refX", 20)
        .attr("refY", 0)
        .attr("markerWidth", @marker_size)
        .attr("markerHeight", @marker_size)
        .attr("orient", "auto")
        .append("svg:path")
        .attr("d", "M0,-5L10,0L0,5")
    @graph = @svg.append("g").attr("transform", "scale(#{start_scale})")
  
  setupInspector: =>
    @inspector.delegate ".check_box", "click", =>
      $(".task_bar").show()

  setupOverlayManager: =>
    @overlayManager = $.tmpl "app/views/media_set_graph/overlay_manager"
    @overlayManager.find("a[data-overlay]").bind "click",(e)=>
      target = $(e.currentTarget)
      $(target).toggleClass("active")
      if $(target).hasClass("active")
        @chart.addClass $(target).data("overlay")
      else
        @chart.removeClass $(target).data("overlay")
    @chart.append @overlayManager

  drawGraph: =>
    nodes = {}
    links = []     
    d3.json "#{document.location.href}.json", (json)=>
      @graphJson = json
      for node in json.nodes
        nodes[node.id] = node
      for link in json.links
        links.push {source: nodes[link.source_id], target: nodes[link.target_id], type: "suit"}
      @layout = d3.layout.force().gravity(0.05).friction(0.4).charge(-300).linkDistance(120).size([@width, @height])
      @layout.nodes(d3.values(nodes)).links(links)
      all_links = @graph.selectAll(".link").data(@layout.links()).enter().append("line").attr("class", "link").attr("marker-end", "url(#suit)")
      all_nodes = @graph.selectAll(".node").data(@layout.nodes()).enter().append("g").attr("class", "node").attr("data-id", ((d)-> return d.id))
      all_nodes.append("rect").attr("width", ((d)-> if MetaDatum.flatten(d.meta_data).title? then MetaDatum.flatten(d.meta_data).title.length*7+24 else 30)).attr("height","26px").attr("y", "-13px").attr("x", "-15px").attr("rx", "5px").attr("ry", "5px")
      all_nodes.append("image").attr("xlink:href", ((d)-> return d.image)).attr("x", "-10px").attr("y", "-10px").attr("width", "20px").attr("height", "20px")
      all_nodes.append("text").attr("dx", 12).attr("dy", ".35em").text(((d)-> if MetaDatum.flatten(d.meta_data).title? then MetaDatum.flatten(d.meta_data).title else ""))
      all_nodes.append("image").attr("xlink:href", ((d)-> if d.is_favorite then "/assets/icons/button_favorit_on.png" else "")).attr("x", "-15px").attr("y", "-18px").attr("width", "14px").attr("height", "14px").attr("class", "favorite")
      all_nodes.append("image").attr("xlink:href", ((d)-> if d.is_private then "/assets/icons/locked.png" else if d.is_shared then "/assets/icons/shared.png" else if d.is_public then "/assets/icons/public.png")).attr("x", "0px").attr("y", "-18px").attr("width", "14px").attr("height", "14px").attr("class", "permissions")
      @layout.on "tick", ->
        all_links.attr("x1", ((d)-> return d.source.x;))
        .attr("y1", ((d)-> return d.source.y;))
        .attr("x2", ((d)-> return d.target.x;))
        .attr("y2", ((d)-> return d.target.y;))
        all_nodes.attr("transform", (d)-> return "translate(" + d.x + "," + d.y + ")";)
      @layout.start()
      @layout.tick() for i in [0..ticks]
      @layout.stop()
      @el.find(".graph>.info").remove()

  redrawGraph: =>
    @graph.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
  
  disableBar: => $("#bar .selection .types a").attr("disabled", true)
    
  inspectNode: (e)=>
    node = $(e.currentTarget)
    @chart.find(".node[data-selected]").removeAttr("data-selected")
    node.attr("data-selected", true)
    @inspectionLoader.abort() if @inspectionLoader?
    @inspectionLoader = App.MediaResources.fetch
      url: "/media_sets/"+node.data("id")+".json"
      success: (data)=>
        @inspector.html($.tmpl "tmpl/media_set/inspector", data)
        @background = $("<div class='background'></div>")
        @inspector.append @background
        @loadChildren node.data("id")
        @checkCheckState node.data("id")

  setInspectorDimension: =>
    if @inspector.find(".children").length
      @inspector.find(".children").height(@height - @inspector.find(".item_box").outerHeight() - 32)

  checkCheckState: (id)=>
    selected_ids = _.map window.get_media_resources_json(), (r)-> r.id
    @inspector.find(".item_box").addClass("selected") if _.include selected_ids, id

  loadChildren: (parent_id)=>
    requested_data = 
      with: 
        children:
          with:
            image:
              as:"base64"
              size:"small"
          pagination:
            per_page: 36
    App.MediaResources.fetch_children parent_id, (data)=>
      @setupChildren data.children.media_resources
      do @setInspectorDimension
    , requested_data

  setupChildren: (children)=>
    @children = $("<div class='children'></div>")
    @children.append $.tmpl "tmpl/svg/arrow", classname: "white"
    @background.append @children
    @children.append $.tmpl("tmpl/media_set/popup/media_resource",children)

window.App.MediaSetsGraph = MediaSetsGraphController