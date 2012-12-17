###

  Bar
  
  This script provides functionalities for the bar

###

class Bar
  
  @setup = (type, permission, sort_by, favorites, search, top_level, media_set, group, edit_filter_set)->
    @setup_type type
    @setup_sort_by sort_by
    @setup_interactivity()
    @setup_icon type, favorites, search, group, edit_filter_set
    if type == "media_sets" and permission == "mine" and favorites != "true" and search == "" and media_set == ""
      @setup_media_set_scope(top_level) 
    @delegateEvents()

  @setup_type = (type)->
    $("#bar .selection .types ."+type).addClass("active").addClass("current")
  
  @setup_sort_by = (sort_by)->
    if sort_by? and not (sort_by == "")
      $("#bar .sort ."+sort_by).addClass("active")
      $("#bar .sort").prepend $("#bar .sort ."+sort_by)
    else
      $("#bar .sort a:first").addClass("active")
  
  @setup_interactivity = ()->
    # mousenter types a
    $("#bar .selection .types a").bind "mouseenter", (e)->
      return false if $(e.currentTarget).is("[disabled='disabled']")
      $(this).closest(".types").find(".active").removeClass("active")
      $(this).addClass("active")
    # mouseleave selection  
    $("#bar .selection").bind "mouseleave", (e)->
      return false if $(e.currentTarget).is("[disabled='disabled']")
      $(this).find(".types .active").removeClass("active")
      $(this).find(".types .current").addClass("active")
  
  @setup_icon = (type, favorites, search, group, edit_filter_set)->
    if favorites? and favorites != ""
      $("#bar > .icon").addClass("favorites")
    else if edit_filter_set.length
      $("#bar > .icon").addClass("edit_filter_set")
    else if search? and search != ""
      $("#bar > .icon").addClass("search")
    else if group? and group != ""
      $("#bar > .icon").addClass("groups")
    else
      $("#bar > .icon").addClass(type)
  
  @setup_media_set_scope = (top_level)->
    $("#bar .scope_sets").css("display", "inline-block")
    if top_level == "true"
      $("#bar .scope_sets .top_level").addClass("active")
    else
      $("#bar .scope_sets .not_top_level").addClass("active")
    $("#bar .scope_sets").prepend $("#bar .scope_sets .active")

  @delegateEvents = ()->
    $("#bar a.open_graph").mouseenter ->
      current_filter = $("section.media_resources.index").data("controller").filter_panel.current_filter
      new_href = "/visualization/filtered_resources?" + $.param(current_filter)
      $(this).attr('href', new_href)
    
window.Bar = Bar