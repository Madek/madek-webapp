#= require active_admin/base

$(document).ready ->
  $(".index_table tbody").has(".handler").sortable
    handle: ".handler"
    axis: "y"
    update: (event, ui) ->
      $.ajax
        url: $(event.target).find(".handler").data("url")
        type: "PUT"
        data: $(event.target).sortable("serialize")
        success: ->
          $(event.target).find("td").effect "highlight", {}, 2000