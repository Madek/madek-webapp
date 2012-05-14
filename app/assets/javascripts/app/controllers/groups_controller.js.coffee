class GroupsController

  el: "section#content_body"
  
  constructor: ->
    @el = $(@el)
    do @delegate_events
    
  delegate_events: ->
    @el.delegate ".group .button.create", "click", @open_create_dialog 
    @el.delegate ".group .edit", "click", @open_edit_dialog 
  
  open_create_dialog: (e)=>
    do e.preventDefault
    dialog = Dialog.add
      trigger: e.currentTarget
      dialogClass: "create_group"
      content: $.tmpl "tmpl/groups/new"
      closeOnEscape: false
    dialog.delegate "#create_group", "submit", (e)=>
      do e.preventDefault
      @create_group $(dialog).find("#create_group")
      return false 
    dialog.delegate ".actions .cancel", "click", (e)=>
      do e.preventDefault
      $(dialog).dialog("close")
      return false 
    return false
  
  create_group: (form)->
    name = form.find(".name").val()
    button = form.find("button.create")
    $(button).width($(button).width()).html("").append("<img src='/assets/loading.gif'/>").addClass("loading")
    $.ajax
      url: "groups.json"
      type: "POST"
      data: 
        name: name
      complete: ->
        window.location = window.location
    
  open_edit_dialog: (e)=>
    do e.preventDefault
    group = $(e.currentTarget).closest("li").data "group"
    dialog = Dialog.add
      trigger: e.currentTarget
      dialogClass: "edit_group"
      content: $.tmpl "tmpl/groups/edit", group
      closeOnEscape: false
    dialog.delegate ".actions .cancel", "click", (e)=>
      do e.preventDefault
      $(dialog).dialog("close")
      return false
    dialog.delegate "input", "select_from_autocomplete", (event, element)=>
      console.log arguments
      console.log element
    return false
  
window.App.Groups = GroupsController