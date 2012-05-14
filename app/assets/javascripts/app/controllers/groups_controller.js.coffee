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
      content: $.tmpl "app/views/groups/new"
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
      url: "/groups.json"
      type: "POST"
      data: 
        name: name
      success: ->
        window.location = window.location
    
  open_edit_dialog: (e)=>
    do e.preventDefault
    group = $(e.currentTarget).closest("li").data "group"
    dialog = Dialog.add
      trigger: e.currentTarget
      dialogClass: "edit_group"
      content: $.tmpl "app/views/groups/edit", group
      closeOnEscape: false
    dialog.delegate ".actions .cancel", "click", (e)=>
      do e.preventDefault
      $(dialog).dialog("close")
      return false
    dialog.delegate "input", "select_from_autocomplete", (event, element)=>
      user =
        id: element.id
        name: element.name
      dialog.find("section.group").append $.tmpl("app/views/groups/_member", user)
    dialog.delegate ".save", "click", (e)=>
      do e.preventDefault
      @save_group dialog, group
      return false
    dialog.delegate "a.change_name", "click", (e)=>
      dialog.find("h2").hide()
      dialog.find("a.change_name").hide()
      dialog.find("input.change_name").show()
      dialog.find("input.change_name").focus().select()
    dialog.delegate "input", "autocompleteopen", (event, ui)=>
      target = $(".ui-autocomplete")
      existing_ids = _.map(dialog.find(".group .member"), (member)-> $(member).data("id"))
      target.find(".ui-menu-item").each (i, item)->
        id = $(item).data("item.autocomplete").id
        if existing_ids.indexOf(id) > -1
          element = $("<div class='existing_member'>#{$(item).html()}<div class='snag icon'></div></div>")
          $(item).replaceWith element
    dialog.delegate ".button.remove", "click", (e)->
      $(this).closest(".member").remove()
    return false
  
  save_group: (container, group)->
    name = container.find("input.change_name").val()
    user_ids = _.map(container.find(".group .member"), (member)-> $(member).data("id"))
    button = container.find("button.save")
    $(button).width($(button).width()).html("").append("<img src='/assets/loading.gif'/>").addClass("loading")
    $.ajax
      url: "/groups/#{group.id}.json"
      type: "PUT"
      data:
        name: name
        user_ids: user_ids
      success: ->
        window.location = window.location
      
window.App.Groups = GroupsController