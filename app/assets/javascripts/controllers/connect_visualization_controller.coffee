jQuery ->
  $(window).on "filter-changed", (e, filter)-> 
    el = $("a.ui-connect-to-visualization")
    uri = URI el.attr "href"
    newUrl = uri.query $.param filter
    el.attr "href", newUrl