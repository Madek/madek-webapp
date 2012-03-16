###

Permission

This script provides functionalities for permissions view

###

jQuery ->
  $(".open_permission_lightbox").live "click", (event)->
    event.preventDefault()
    Permission.open_lightbox event.currentTarget 
  $(".permission_lightbox .cancel").live("click", Permission.close_lightbox)

class Permission
  
  @open_lightbox = (target)->
    # PREPARE BADGE OPENING
    if $(target).hasClass("batch")
      media_resource_ids = []
      $(".task_bar .thumb_mini").each (i,element)->
        media_resource_ids.push($(element).tmplItem().data.id)
      $(target).data("media_resource_ids", media_resource_ids)
      
    # OPEN DIALOG
    container = Dialog.add
      trigger: target
      dialogClass: "permission_lightbox"
      content: $.tmpl("tmpl/permission/container", {media_resource_ids: $(target).data("media_resource_ids")})
      closeOnEscape: false
    $(container).data("current_user", $(target).data("current_user"))
    $(container).data("media_resource_ids", $(target).data("media_resource_ids"))
    
    Permission.load_permission_presets container, target
    Permission.load_media_resources container, target
  
  @load_permission_presets = (container, trigger) ->
    $.ajax
      url: "/permission_presets.json"
      type: "GET"
      success: (data)->
        sessionStorage.permission_presets = JSON.stringify(data)
        Permission.load_permissions container, $(trigger).data("media_resource_ids")
   
  @load_media_resources = (container, trigger)->
    $.ajax
      url: "/media_resources.json"
      type: "GET"
      data: 
        ids: $(container).data("media_resource_ids") 
        with:
          image:
            as: "base64"
          meta_data:
            meta_context_names: ["core"]
          type: true
      success: (data)->
        $(container).find(".media_resource_selection .loading").remove()
        $(container).find(".media_resource_selection .media").append $.tmpl("tmpl/media_resource/image", data.media_resources) 
        $(container).find(".media_resource_selection table.media_resources").append $.tmpl("tmpl/media_resource/table_row", data.media_resources)  
          
  @display = (container, media_resource_ids)->
    $(container).replaceWith $.tmpl("tmpl/permission/container", {media_resource_ids: media_resource_ids})
    Permission.load_permissions $(container).find(".container"), media_resource_ids   
      
  @load_permissions = (container, media_resource_ids)->
    $.ajax
      url: "/permissions.json"
      type: "GET"
      data:
        media_resource_ids: media_resource_ids
        with: 
          users: true
          groups: true
          owners: true
      success: (data)->
        $(container).data("permissions_on_start", data)
        Permission.setup_permission_view container, data
        Permission.setup_owners container, data
        Permission.setup_permission_presets container
        Permission.setup_read_only container, data
        Permission.setup_permission_checkboxes container
        Permission.setup_add_line container
        Permission.setup_remove_line container
        
  @setup_permission_view = (container, data) ->
    # filter current user from list of users
    data.users = data.users.filter (element)-> element.id != data.you.id
    # setup permissions view
    $(container).find(".permission_view").html $.tmpl("tmpl/permission/_permission_view", data, {current_user: $(container).data("current_user"), media_resource_ids: $(container).data("media_resource_ids")})
    Dialog.checkScale(container)
    Dialog.checkPosition(container)
    
  @setup_read_only = (container, data) ->
    # Permissions Read Only
    if JSON.stringify(data.you.manage) != JSON.stringify($(container).data("media_resource_ids"))
      $(container).find("input, select, .select").attr("disabled", "disabled")
    
    # Ownership Read Only
    if data.owners.length != 1 or data.owners[0].id != $(container).data("current_user").id
      $(container).find(".owner input").attr("disabled", "disabled")
      
    # Remove Add Line
    if JSON.stringify(data.you.manage) != JSON.stringify($(container).data("media_resource_ids"))
      $(container).find(".add.line").remove()
      
    # Remove "remove line button"
    if JSON.stringify(data.you.manage) != JSON.stringify($(container).data("media_resource_ids"))
      $(container).find(".line").addClass("without_remove")
    
    
  @setup_owners = (container, data) ->
    # setup a single owner
    if data.owners.length == 1
      if $(container).find(".me .line").tmplItem().data.id == data.owners[0].id
        $(container).find(".me .line:first .owner input").attr("checked", "checked")
        $(container).find(".me .line:first div:not(.owner) input, .me .line:first select, .me .line:first .select").attr("disabled", "disabled")
      else 
        $(container).find(".users .line").each (i, user_line)->
          if $(user_line).tmplItem().data.id == data.owners[0].id
            $(user_line).find(".owner input").attr("checked", "checked")
            $(user_line).find("div:not(.owner) input, div:not(.owner) select, div:not(.owner) .select").attr("disabled", "disabled")
    else # setup multiple owners (multiple selected resources)
      for owner in data.owners
        if $(container).find(".me .line").tmplItem().data.id == owner.id
          $(container).find(".me .line:first .owner label").addClass("mixed")
          $(container).find(".me .line:first div:not(.owner) input, .me .line:first select, .me .line:first .select").attr("disabled", "disabled")
        $(container).find(".users .line").each (i, user_line)->
          if $(user_line).tmplItem().data.id == owner.id
            $(user_line).find(".owner label").addClass("mixed")
            $(user_line).find("div:not(.owner) input, div:not(.owner) select, div:not(.owner) .select").attr("disabled", "disabled")
  
  @match_preset = (line_permissions)->
    for preset in JSON.parse(sessionStorage.permission_presets)
      if preset.view == line_permissions.view and preset.download == line_permissions.download and preset.edit == line_permissions.edit and preset.manage == line_permissions.manage
        return preset
  
  @compute_line_permission = (line)->
    line_permissions = {}
    line_permissions.view = if $(line).find(".view input:checked").length>0 then true else false
    line_permissions.download = if $(line).find(".download input:checked").length>0 then true else false
    line_permissions.edit = if $(line).find(".edit input:checked").length>0 then true else false
    line_permissions.manage = if $(line).find(".manage input:checked").length>0 then true else false
    return line_permissions
  
  @set_matched_preset_permissions = (line, preset)->
    if preset != undefined
      $(line).find(".preset .select").html(preset.name)
      $(line).find(".preset option").each (i, option)->
        if $(option).html() == preset.name
          $(option).attr "selected", true
    else
      $(line).find(".preset .select").html("(Angepasst)")
      $(line).find(".preset option:selected").attr "selected", false 
  
  @setup_permission_presets = (container)->
    $(container).find("section .line").each (i, line)->
      # set matched permission preset
      preset = Permission.match_preset(Permission.compute_line_permission(line))
      Permission.set_matched_preset_permissions(line, preset)
      
      # set mixed if values are mixed
      if $(line).find(".mixed").length>0
        $(line).find(".preset .select").html("Gemischte Werte")
      
      # set owner as preset
      if $(line).find(".owner input:checked").length>0
        $(line).find(".preset .select").html("Besitzer")
        
      # remove not needed presets from options
      $(line).find(".preset option").each (i, element)->
        preset = JSON.parse JSON.stringify $(element).data("preset")
        delete preset.name
        $.each preset, (key, value)->
          if $(line).find(".permissions ."+key).length == 0 and value == true
            $(element).remove()
        
    # listen for change
    $(".preset select").live "change", (event)->
      $(this).closest(".preset").find(".select").html $(this).val()
      # switch permissions
      preset = $(this).find("option:selected").data("preset")
      $(this).closest(".line").find(".permissions input").each (i, permission)->
        if preset[permission.name] != undefined and preset[permission.name] == true 
          $(permission).attr "checked", true
        else
          $(permission).attr "checked", false
        
  @setup_permission_checkboxes = (container)->
    # listen for change
    $(container).find(".permission input").live "change", (event)->
      line = $(this).closest(".line")
      preset = Permission.match_preset(Permission.compute_line_permission(line))
      Permission.set_matched_preset_permissions line, preset

  @setup_add_line = (container)->
    # CLICK BUTTON
    $(container).find(".add .button").bind "click", ()->
      $(this).hide()
      $(this).siblings("input").show().focus()
    
    # FOCUS INPUT
    $(container).find(".add input").bind "focus", ()->
      $(this).show()
      $(this).siblings(".button").hide()
    
    # BLUR INPUT
    $(container).find(".add input").bind "blur", (event)->
      if $(event.originalEvent.explicitOriginalTarget).hasClass("ui-autocomplete-input")
        $(this).focus()
      else
        $(this).hide()
        $(this).val("")
        $(this).siblings(".button").show()
      
    # AUTOCOMPLETE
    $(container).find(".add input").autocomplete
      source: (request, response)->
        trigger = $(this.element)
        $.getJSON $(this.element).data("url"),
          query: request.term
        , (data)->
          type = if $(trigger).closest("section").hasClass("users") then "user" else "group"
          entries = $.map data, (element)-> { id: element.id, value: Underscore.str.truncate(element.name, 65) }
          existing_user_ids = $.map $("#permissions .users .line:not(.add)"), (element)-> $(element).tmplItem().data.id
          # Filter Out my self and existing user lines
          if type == "user"
            entries = entries.filter (element)-> ! ($("#permissions .me .line:first").tmplItem().data.id == element.id || existing_user_ids.indexOf(element.id)>-1)
          response entries
      minLength: 1
      appendTo: $(container)
      select: (event, selection)->
        
        # FOCUS INPUT AGAIN AFTER SELECTION
        window.setTimeout ()->
          $(event.target).val("")
          $(event.target).focus()
        , 100
        
        # SETUP TEMPLATE
        type = if $(event.target).closest("section").hasClass("users") then "user" else "group"
        tmpl_options = 
          with_owner: if type == "user" then true else false
          media_resource_ids: $("#permissions").data("media_resource_ids")
        template = $.tmpl "tmpl/permission/_line",
          name: selection.item.label
          id: selection.item.id
          view: []
          edit: []
          download: []
          manage: if type == "user" then [] else undefined 
        , tmpl_options
        
        # CLEAR PRESET NAME LINE
        $(template).find(".preset .select").html("&nbsp;")
        
        # ADD TEMPLATE TO THE DOM
        $(event.target).closest(".line").before template
        
        # CHECK FOR CHANGES
        Permission.check_for_changes container
  
  @setup_remove_line = (container)->
    
  
  @check_for_changes = (container)->
    console.log $(container).data("permissions_on_start")
    Permission.compute container
  
  @compute = (container)->
    media_resource_ids = $(container).data("media_resource_ids")
    permissions = {}
    permissions.you = 
      view: if $(container).find(".me .line:first .permissions .view input:checked").length > 0 then media_resource_ids else []
      edit: if $(container).find(".me .line:first .permissions .edit input:checked").length > 0 then media_resource_ids else []
      download: if $(container).find(".me .line:first .permissions .download input:checked").length > 0 then media_resource_ids else []
      manage: if $(container).find(".me .line:first .permissions .manage input:checked").length > 0 then media_resource_ids else []
      id: $(container).find(".me .line:first").tmplItem().data.id
      name: $(container).find(".me .line:first").tmplItem().data.name
    permissions.group = $.map $(container).find("section.groups .line:not(.add), .groups_with_me .line"), (line)->
      id: $(line).tmplItem().data.id
      name: $(line).tmplItem().data.name
      view: if $(line).find(".permissions .view input:checked").length > 0 then media_resource_ids else []
    
    console.log permissions
  
  @close_lightbox = ->
    $(".permission_lightbox .dialog").dialog("close")
   
window.Permission = Permission