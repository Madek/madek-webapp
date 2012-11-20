# Make filter bar toggled by Filter button

$ -> $("#filter-toggle").click ->
  $(this).toggleClass "active"
  $("#side-filter").toggle()

# Enable Bootstrap tooltips
-
-$ -> $(".tooltip-toggle").tooltip()
