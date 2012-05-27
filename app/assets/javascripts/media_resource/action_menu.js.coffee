class ActionMenu
  
  el: undefined
  close_timer: undefined
  
  constructor: (el)->
    @el = $(el)
    do @delegate_events
  
  delegate_events: =>
    @el.delegate ".action_menu", "mouseenter", @enter_trigger
    @el.delegate ".action_menu_list", "mouseenter", @enter_list
    @el.delegate ".action_menu", "mouseleave", @leave
    @el.delegate ".action_menu .close_on_click", "click", @close_on_click
  
  enter_trigger: (e)=>
    $(".action_menu_list:visible").hide()
    $(".action_menu_list.open").removeClass("open")
    action_menu = $(e.currentTarget)
    list = action_menu.find(".action_menu_list")
    action_menu.addClass "open"
    action_menu.data "list", list
    list.data "menu", action_menu
    list.show().position
      my: "left top"
      at: "left bottom"
      of: action_menu
      offset: "0 1"
      
  close_on_click: (e)=> @close $(e.currentTarget).closest(".action_menu_list")
  
  enter_list: =>
    clearTimeout @close_timer
      
  leave: (e)=>
    @close_timer = window.setTimeout =>
      @close $(e.currentTarget)  
    , 100
    
  close: (trigger)->
    action_menu = if $(trigger).is(".action_menu_list") then $(trigger).data("menu") else $(trigger)
    list = if $(trigger).is(".action_menu_list") then $(trigger) else $(trigger).data("list")
    list.hide()
    action_menu.removeClass("open")
    
window.ActionMenu = ActionMenu