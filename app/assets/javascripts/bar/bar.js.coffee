###

  Bar
  
  This script provides functionalities for the bar

###

class Bar
  
  @setup = (type, permission, sort_by, favorites, search)->
    @setup_type type
    @setup_permissions permission
    @setup_sort_by sort_by
    @setup_layout()    
    @setup_interactivity()
    @setup_icon type, favorites, search

  @setup_type = (type)->
    $("#bar .selection .types ."+type).addClass("active").addClass("current")
  
  @setup_permissions = (permission)->
    $("#bar .permissions ."+permission).addClass("active")

  @setup_sort_by = (sort_by)->
    if sort_by? and not (sort_by == "")
      $("#bar .sort ."+sort_by).addClass("active")
      $("#bar .sort").prepend $("#bar .sort ."+sort_by)
  
  @setup_layout = ()->
    $("#bar .layout a:first").addClass "active"
    
  @setup_interactivity = ()->
    # mousenter types a
    $("#bar .selection .types a").bind "mouseenter", ()->
      $(this).closest(".types").find(".active").removeClass("active")
      $(this).addClass("active")
      Bar.set_href_selection_for $(this) 
    # mouseleave selection  
    $("#bar .selection").bind "mouseleave", ()->
      $(this).find(".types .active").removeClass("active")
      $(this).find(".types .current").addClass("active")
      Bar.set_href_selection_for $(this).find(".types .current")
  
  @setup_icon = (type, favorites, search)->
    if favorites? and favorites != ""
      $("#bar > .icon").addClass("favorites")
    else if search? and search != ""
      $("#bar > .icon").addClass("search")
    else
      $("#bar > .icon").addClass(type)
  
  @set_href_selection_for = (active_element)->
    active_type = $(active_element).data "type"
    $("#bar .selection .permissions a").each (i, current_element)->
      href = $(current_element).attr("href")
      console.log "----"
      console.log href
      if href.match("type=")
        href = href.replace(/type=(\w+|\w?)/, "type="+active_type)
      else
        href = href+"&type="+active_type
      $(current_element).attr("href", href)
      console.log $(current_element).attr("href")
  
window.Bar = Bar