###

Permission

This script provides functionalities for setting and viewing persmissions

###

jQuery ->
  $(".open_permission_lightbox").live("click", Permission.open_lightbox)
  $(".permission_lightbox .cancel").live("click", Permission.close_lightbox)

class Permission
  
  @open_lightbox = (event)->
    # PREPARE BADGE OPENING
    if $(event.currentTarget).hasClass("batch")
      media_resource_ids = []
      media_resources = []
      $(".task_bar .thumb_mini").each (i,element)->
        media_resource_ids.push($(element).tmplItem().data.id)
        media_resources.push({id:$(element).tmplItem().data.id, author:$(element).tmplItem().data.author, title:$(element).tmplItem().data.title, image:$(element).tmplItem().data.thumb_base64 })
      $(this).data("media_resource_ids", media_resource_ids)
      $(this).data("media_resources", media_resources)
      
    # OPEN DIALOG
    container = Dialog.add
      trigger: event.currentTarget
      dialogClass: "permission_lightbox"
      content: $.tmpl("tmpl/permission/container", {media_resource_ids: $(this).data("media_resource_ids"), media_resources: $(this).data("media_resources")})
      closeOnEscape: false
    $(container).data("current_user", $(this).data("current_user"))
    $(container).data("media_resource_ids", $(this).data("media_resource_ids"))
    
    Permission.load_permission_presets container, event.currentTarget
  
  @load_permission_presets = (container, trigger) ->
    if sessionStorage.permission_presets?
      Permission.load_permissions container, $(trigger).data("media_resource_ids")
    else
      $.ajax
        url: "/permission_presets.json"
        type: "GET"
        data:
          format: "json"
        success: (data)->
          sessionStorage.permission_presets = JSON.stringify(data)
          Permission.load_permissions container, $(trigger).data("media_resource_ids")
          
  @display = (container, media_resource_ids, media_resources)->
    $(container).replaceWith $.tmpl("tmpl/permission/container", {media_resource_ids: media_resource_ids, media_resources: media_resources})
    Permission.load_permissions $(container).find(".container"), media_resource_ids   
      
  @load_permissions = (container, media_resource_ids)->
    $.ajax
      url: "/permissions.json"
      type: "GET"
      data:
        format: "json"
        media_resource_ids: media_resource_ids
        with: 
          users: true
          groups: true
          owners: true
      success: (data)->
        Permission.setup_permission_view container, data
        #Permission.setup_owners container, data
        #Permission.setup_permission_presets container
        #Permission.setup_read_only container, data
        
  @setup_permission_view = (container, data) ->
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
            
  @setup_permission_presets = (container) ->
    $(container).find("section .line").each (i, line)->
      line_settings = {}
      line_settings.view = if $(line).find(".view input:checked").length>0 then true else false
      line_settings.download = if $(line).find(".download input:checked").length>0 then true else false
      line_settings.edit = if $(line).find(".edit input:checked").length>0 then true else false
      line_settings.manage = if $(line).find(".manage input:checked").length>0 then true else false
      
      # match permission preset
      for preset in JSON.parse(sessionStorage.permission_presets)
        if preset.view == line_settings.view and preset.download == line_settings.download and preset.edit == line_settings.edit and preset.manage == line_settings.manage
          $(line).find(".preset .select").html(preset.name)
      
      # set mixed if values are mixed
      if $(line).find(".mixed").length>0
        $(line).find(".preset .select").html("Gemischte Werte")
      
      # set owner as preset
      if $(line).find(".owner input:checked").length>0
        $(line).find(".preset .select").html("Besitzer")
      
  @close_lightbox = ->
    $(".permission_lightbox .dialog").dialog("close")
   
window.Permission = Permission