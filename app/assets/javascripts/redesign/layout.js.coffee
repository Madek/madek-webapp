# Make filter bar toggled by Filter button

$ -> $("#ui-side-filter-toggle").click ->
  $(this).toggleClass "active"
  $("#ui-side-filter").toggle()

# Enable Bootstrap tooltips
-
-$ -> $(".tooltip-toggle").tooltip()
