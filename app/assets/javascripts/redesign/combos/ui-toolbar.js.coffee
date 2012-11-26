$ -> $(".ui-toolbar-vis-button").click (e) ->

  # Change button style to active
  $(this).siblings().removeClass "active"
  $(this).addClass "active"

  # Get the value of data-vis-mode from clicked button
  value = undefined
  value = $(this).data("vis-mode")

  # Set data-vis-mode to .ui-resources-list
  $(".ui-resources-list").removeClass "grid tiles list"
  $(".ui-resources-list").addClass value
