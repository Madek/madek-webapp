Visualization.Views.GraphView = Backbone.View.extend

  node_label_template:  JST['visualization/templates/node_label']

  label_xoff: -62.5 
  label_yoff: -10

  initialize: ->
    @graph=@options.graph

    if Visualization.Functions.is_very_modern_browser()
      @graph.on "new_layout_available", (e) => 
        @relayout()
        @autozoom()
    else
      @options.visualization_controller.on "worker_finished_layouting", (e)=>
        @relayout()
        @autozoom()

    $(window).bind "resize", (e)=> 
      @svg.attr("width", $(window).width()).attr("height", $(window).height())
      @autozoom()

  render: -> # this is called only once from init, se relayout for updating elements
    console.log "rendering graph ..."

    self = @
    # setting-up the svg element ###########################################################################
    @svg = d3.select("svg#drawing")
    @svg.attr('visibility','hidden') # we hide to prevent flickering during initial rendering 
    @svg.attr("width", $(window).width()).attr("height", $(window).height())
    @svg_height = ->
      $("#visualization svg").attr("height")
    @svg_width = ->
      $("#visualization svg").attr("width")

    @svg_graph = @svg.append("svg:g").attr("id","graph")

    @links_vis = @svg_graph.selectAll(".link")
      .data(@graph.arcs).enter().append("line")
      .attr("class", "link arc")
      .attr("child_id",(a)->"#{a.child_id}")
      .attr("parent_id",(a)->"#{a.parent_id}")

    @nodes_vis= @svg_graph.selectAll(".node")
      .data(@graph.nodes_array).enter()
      .append("g")
        .attr("class",(n)->"node #{n.type}")
        .attr("id",(n)->"resource-#{n.id}")
        .attr("data-resource-id",(n)->n.id)
        .attr("data-user-id",(n)->n.user_id)
        .attr("data-title",(n)->n.meta_datum_title)
        .attr("data-size",(n)->n.size)
        .attr("data-type",(n)->n.type)

    @circles_vis = @nodes_vis
      .append("circle")
        .attr("r",10)

    @labels_vis = @nodes_vis.append("g").attr("class", "node_label")
    @labels_vis.each (n,i)-> $(@).append self.node_label_template({node:n,view:self})
    @relayout()
    @svg.attr('visibility','visible')

    if @options.origin_resource?
      $("#resource-#{@options.origin_resource.id} > circle").attr("class","origin")

  relayout: ->
    #console.log "relayout called ..."
    @circles_vis.attr("cx",(n)->n.x).attr("cy",(n)->n.y)
      .attr("r",(n)-> n.radius)
    @links_vis.attr("x1",((e)-> e.source.x)).attr("y1",((e)-> e.source.y))
      .attr("x2",((e)-> e.target.x)).attr("y2",((e)-> e.target.y))
    @labels_vis.select("svg.node_label").attr("x",(n)=>n.x+@label_xoff).attr("y",(n)=>n.y+@label_yoff)
    @autozoom()

  autozoom: ->
    #console.log "resetting transform ..."
    bbox = Visualization.Functions.box_add Visualization.Functions.bbox($("#drawing .node,#drawing g.node_label")), [-25,-100,25,25]
    bbox_center = Visualization.Functions.center_of_box bbox
    @svg_graph.select("rect#bbox").remove()
    @svg_graph.append("svg:rect").attr("id","bbox").attr("x",bbox[0]).attr("y",bbox[1]).attr("width",bbox[2]-bbox[0]).attr("height",bbox[3]-bbox[1])
    @svg_graph.select("circle#center").remove()
    @svg_graph.append("svg:circle").attr("id","center").attr("r",2).attr("cx",bbox_center[0]).attr("cy",bbox_center[1])

    scale =  Math.min(@svg_width() / (bbox[2] - bbox[0]), @svg_height() / (bbox[3] - bbox[1]))
    scaled_bbox_center = bbox_center.map( (x)-> x * scale)
    tx = @svg_width()/2 - scaled_bbox_center[0] 
    ty = @svg_height()/2 - scaled_bbox_center[1] 
    @svg_graph.attr("transform","translate(#{tx},#{ty}) scale(#{scale},#{scale}) ")  
