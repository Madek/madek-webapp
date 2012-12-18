window.Test.Visualization=

  mouse_enter_set: (id)->
    $("#resource-#{id} circle").trigger("mouseenter")

  test_noupdate_positions: ->

    prev_positions=undefined

    current_positions= ->
      $("#graph .node circle").toArray().map (e,i,a) -> [$(e).attr('cx'),$(e).attr('cy')]

    $(window).bind "worker_computed_new_layout", ()->
      if prev_positions?
        unless _.isEqual(current_positions(),prev_positions)
          document.write "Test failed, positions_changed"

    $(window).bind "worker_startes_layouting", ()->
      prev_positions = current_positions()

    $(window).bind "worker_finished_layouting", ()->
      prev_positions = undefined

  
$ -> 
  if window.location.hash == '#test_noupdate_positions'
    Test.Visualization.test_noupdate_positions()
    $("body").append("<div id='test_noupdate_positions_running'></div>")



