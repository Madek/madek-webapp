###

Provide functionalities for custom select containers

###

jQuery ->
  $(document).on "change", ".ui-custom-select select", (e) ->
    select = $(e.currentTarget)
    container = select.closest ".ui-custom-select"
    span = container.find "span"
    span.html select.find("option:selected").attr("value")