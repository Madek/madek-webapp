jQuery ->
  $(window).on "filter-changed filter-initialized", (e, filter)-> 
    if filter?
      el = $("a.ui-connect-to-visualization")
      uri = URI el.attr "href"
      newUrl = uri.query $.param filter
      el.attr "href", newUrl