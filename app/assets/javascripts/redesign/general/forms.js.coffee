# Enable form extension toggles

$ -> $(".form-item-extension").hide()
$ -> $(".form-item-extension-toggle").click ->
  $(this).toggleClass("active")
  $(this).parent(".form-item").find(".form-item-extension").toggle()

# Enable person widget toggles

$ -> $(".form-person-widget").hide()
$ -> $(".form-person-widget-toggle").click ->
  $(this).toggleClass("active")
  $(this).parent(".form-item").find(".form-person-widget").toggle()

# Enable tag cloud extensions toggles

$ -> $(".form-tags-widget").hide()
$ -> $(".form-tags-widget-toggle").click ->
  $(this).toggleClass("active")
  $(this).parent(".form-item").find(".form-tags-widget").toggle()
