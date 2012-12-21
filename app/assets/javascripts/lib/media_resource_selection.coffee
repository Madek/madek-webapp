###

Enables Toggle for MediaResource Selection Views (Table / Media)

### 

jQuery ->
  
  $(".ui-resources-selection a[data-view]").on "click", ->
    button = $(this)
    selection = button.closest ".ui-resources-selection"
    selection.find(".ui-toolbar a.active").removeClass "active"
    button.addClass "active"
    selection.find(".ui-resources-table").hide()
    selection.find(".ui-resources-media").hide()
    selection.find(button.data("view")).show()