class MediaSetsGraphController

  el: "section.media_sets_graph"
  start_scale = 1.2
  ticks = 100
  @background
  @children
  @inspector
  @chart
  @layout
  
  constructor: ->
    @el = $(@el)
    @inspector = @el.find("#inspector")
    @chart = @el.find("#chart")
    do @setMetrics
    do @setupGraph
    do @drawGraph
    do @disableBar
    do @delegateEvents
    
  delegateEvents: =>
    @chart.delegate ".node", "click", @inspectNode
    @el.delegate ".node", "mouseenter", @enterNode
    @el.delegate ".node", "mouseleave", @leaveNode

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
  
  setMetrics: =>
    @width = @el.innerWidth() - @inspector.outerWidth() - (@el.outerWidth()-@el.width())
    @height = $(window).height() - @chart.offset().top - $("footer").outerHeight()
    @marker_size = 10
    
  setupGraph: => 
    @svg = d3.select("#chart").append("svg").attr("height", @height).attr("width", @width).call(d3.behavior.zoom().scale(start_scale).on("zoom", @redrawGraph))
    $(@svg).addClass(".svg")
    @svg.append("svg:defs").selectAll("marker")
        .data(["suit"])
      .enter().append("svg:marker")
        .attr("id", String)
        .attr("viewBox", "0 -5 10 10")
        .attr("refX", 25)
        .attr("refY", 0)
        .attr("markerWidth", @marker_size)
        .attr("markerHeight", @marker_size)
        .attr("orient", "auto")
        .append("svg:path")
        .attr("d", "M0,-5L10,0L0,5")
    @graph = @svg.append("g").attr("transform", "scale(#{start_scale})")
  
  drawGraph: =>
    nodes = {}
    links = []     
    d3.json "#{document.location.href}.json", (json)=>
      for node in json.nodes
        nodes[node.id] = node
      for link in json.links
        links.push {source: nodes[link.source_id], target: nodes[link.target_id], type: "suit"}
      @layout = d3.layout.force().gravity(0.05).friction(0.4).charge(-300).linkDistance(120).size([@width, @height])
      @layout.nodes(d3.values(nodes)).links(links)
      all_links = @graph.selectAll(".link").data(@layout.links()).enter().append("line").attr("class", "link").attr("marker-end", "url(#suit)")
      all_nodes = @graph.selectAll(".node").data(@layout.nodes()).enter().append("g").attr("class", "node").attr("data-id", ((d)-> return d.id))
      all_nodes.append("rect").attr("width", ((d)->return d.name.length*7+24)).attr("height","26px").attr("y", "-13px").attr("x", "-15px").attr("rx", "5px").attr("ry", "5px")
      all_nodes.append("image").attr("xlink:href", ((d)-> return d.img_src)).attr("x", "-10px").attr("y", "-10px").attr("width", "20px").attr("height", "20px")
      all_nodes.append("text").attr("dx", 12).attr("dy", ".35em").text(((d)-> return d.name))
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
    App.MediaResources.fetch
      url: "/media_sets/"+node.data("id")+".json"
      success: (data)=>
        @inspector.html($.tmpl "tmpl/media_set/inspector", data)
        @background = $("<div class='background'></div>")
        @inspector.append @background
        @loadChildren node.data("id")

  loadChildren: (parent_id)=>
    App.MediaResources.fetch_children parent_id, (data)=>
      @setupChildren data.children.media_resources
      
  setupChildren: (children)=>
    @children = $("<div class='children'></div>")
    @children.append $.tmpl "tmpl/svg/arrow", classname: "white"
    @background.append @children
    @children.append $.tmpl("tmpl/media_set/popup/media_resource",children)

window.App.MediaSetsGraph = MediaSetsGraphController