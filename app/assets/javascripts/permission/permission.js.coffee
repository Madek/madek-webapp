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
  
  @collection_id
  @permission_presets
  
  @open_lightbox = (target)->
    # prepare badge
    if $(target).hasClass("batch")
      media_resource_ids = []
      $(".task_bar .thumb_mini").each (i,element)->
        media_resource_ids.push($(element).tmplItem().data.id)
      $(target).data("media_resource_ids", media_resource_ids)
    # open dialog
    container = Dialog.add
      trigger: target
      dialogClass: "permission_lightbox"
      content: $.tmpl("tmpl/permission/container", {media_resource_ids: $(target).data("media_resource_ids")})
      closeOnEscape: false
    $(container).data("media_resource_ids", $(target).data("media_resource_ids"))
    $(container).data("redirect_url", $(target).data("redirect_url"))
    # create collection
    Permission.create_collection container, target
  
  @create_collection = (container, target)->
    # TODO GO ON HERE
    new MediaResourceSelection 
      el: $(container).find(".media_resource_selection")
      ids: $(container).data("media_resource_ids")
      parameters:
        with:
          meta_data:
            meta_context_names: ["core"]
          image:
            as: "base64"
            size: "medium"
      afterCreate: (data)-> 
        Permission.collection_id = data.collection_id
        Permission.load_permission_presets container, target if not Permission.permission_presets? 
        Permission.load_permissions container, $(container).data("media_resource_ids")
        
  @load_permission_presets = (container, trigger)->
    $.ajax
      url: "/permission_presets.json"
      type: "GET"
      success: (data)->
        Permission.permission_presets = data
        Permission.load_permissions container, $(trigger).data("media_resource_ids")
   
  @display_inline = (options)->
    media_resource_ids = options.media_resource_ids
    view_template = $.tmpl("tmpl/permission/container", {media_resource_ids: media_resource_ids})
    container = view_template
    button = options.button
    $(options.container).replaceWith container
    $(container).data("media_resource_ids", media_resource_ids)
    $(container).data("external_submit_button", button)
    Permission.create_collection $(container), $(container)
      
  @load_permissions = (container, media_resource_ids)->
    $.ajax
      url: "/permissions.json"
      type: "GET"
      data:
        collection_id: Permission.collection_id
        with: 
          users: true
          groups: true
          owners: true
      error: (data)->
        error = JSON.parse(data.responseText).error
        $(container).find(".loading").html("<strong>"+error+"</strong>")
      success: (data)->
        $(container).data("permissions_on_start", data)
        Permission.setup_permission_view container, data
        Permission.setup_owners container, data
        Permission.setup_add_line container
        Permission.setup_read_only container, data
        Permission.remove_duplicated_groups container
        Permission.check_groups_with_me_visibility container
        Permission.setup_public_cascading container
        Permission.setup_actions container
        Permission.setup_save container
        # Extend Lines Logic
        $(container).find("section .line").each (i, line)-> Permission.setup_permission_presets line
        $(container).find("section .line").each (i, line)-> Permission.setup_permission_checkboxes line
        $(container).find("section .line").each (i, line)-> Permission.setup_ownership_transfer line
        $(container).find("section .line").each (i, line)-> Permission.setup_remove_line line
        
  @setup_permission_view = (container, data) ->
    # filter list of users remove current_user and owners (prevend duplicates!)
    owner_ids = data.owners.map (owner)-> owner.id
    data.users = data.users.filter (user)-> user.id != data.you.id and owner_ids.indexOf(user.id) == -1
    # add all owners to the list of users
    for owner in data.owners
      if owner.id != data.you.id
        owner.view = owner.media_resource_ids
        owner.download = owner.media_resource_ids
        owner.edit = owner.media_resource_ids
        owner.manage = owner.media_resource_ids
        data.users.unshift owner
    # setup permissions view
    template = $.tmpl("tmpl/permission/_permission_view", data, {media_resource_ids:  $(container).data("media_resource_ids")})
    $(container).find(".permission_view").html template
    if $(".dialog").length>0
      Dialog.checkScale(container)
      Dialog.checkPosition(container)
    
  @setup_read_only = (container, data) ->
    # Ownership Read Only
    if data.owners.length != 1 or data.owners[0].id != current_user.id
      $(container).find(".owner input").attr("disabled", "disabled")
      
    # Manage Read Only
    manage_permissions_for_all_selected_media_resources = true
    for resource in $(container).data("media_resource_ids")
      if data.you.manage.indexOf(resource) < 0
        manage_permissions_for_all_selected_media_resources = false
     
    if not manage_permissions_for_all_selected_media_resources
      $(container).find(".add.line").remove()
      $(container).find(".line").addClass("without_remove")
      $(container).find("input, select, .select").attr("disabled", "disabled")
    
  @remove_duplicated_groups = (container)->
    $(container).find(".me .groups.with_me .line").each (i_with_me, line_with_me)->
      for line in $(container).find(".groups:not(.with_me) .line:not(.add)")
        if $(line).tmplItem().data.id == $(line_with_me).tmplItem().data.id
          $(line).remove()
          break
   
  @setup_owners = (container, data) ->
    # setup a single owner
    if data.owners.length == 1
      if $(container).find(".me .line").tmplItem().data.id == data.owners[0].id
        $(container).find(".me .line:first .owner input").attr("checked", true)
        $(container).find(".me .line:first .permissions input").attr("checked", true)
        $(container).find(".me .line:first").addClass("is_single_owner")
        $(container).find(".me .line:first div:not(.owner) input, .me .line:first select, .me .line:first .select").attr("disabled", "disabled")
      else 
        $(container).find(".users .line").each (i, user_line)->
          if $(user_line).tmplItem().data.id == data.owners[0].id
            $(user_line).find(".owner input").attr("checked", true)
            $(user_line).find(".permissions input").attr("checked", true)
            $(user_line).addClass("without_remove is_single_owner")
            $(user_line).find("div:not(.owner) input, div:not(.owner) select, div:not(.owner) .select").attr("disabled", "disabled")
    else # setup multiple owners (multiple selected resources)
      for owner in data.owners
        if $(container).find(".me .line").tmplItem().data.id == owner.id
          $(container).find(".me .line:first .owner label").addClass("mixed")
          $(container).find(".me .line:first .owner label input").attr("checked", true)
          $(container).find(".me .line:first div:not(.owner) input, .me .line:first select, .me .line:first .select").attr("disabled", "disabled")
        $(container).find(".users .line").each (i, user_line)->
          if $(user_line).tmplItem().data.id == owner.id
            $(user_line).find(".owner label").addClass("mixed")
            $(user_line).find(".owner label input").attr("checked", true)
            $(user_line).addClass("without_remove")
            $(user_line).find("div:not(.owner) input, div:not(.owner) select, div:not(.owner) .select").attr("disabled", "disabled")
  
  @match_preset = (line_permissions)->
    for preset in Permission.permission_presets
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
    if $(line).find(".owner label.mixed").length>0
      # set mixed owner as preset
      $(line).find(".preset .select").html("Teilweise Eigentümer/in")
    else if $(line).find(".owner input:checked").length>0
      # set owner as preset
      $(line).find(".preset .select").html("Eigentümer/in")
    else if $(line).find(".mixed:not(.overwritten)").length>0
      # set mixed if values are mixed
      #$(line).find(".preset .select").html("Gemischte Werte")
    else if preset != undefined
      $(line).find(".preset .select").html(preset.name)
      $(line).find(".preset option").each (i, option)->
        if $(option).html() == preset.name
          $(option).attr "selected", true
    else
      $(line).find(".preset .select").html("(Angepasst)")
      $(line).find(".preset option:selected").attr "selected", false 
  
  @setup_permission_presets = (line)->
    # set matched permission preset
    preset = Permission.match_preset(Permission.compute_line_permission(line))
    Permission.set_matched_preset_permissions(line, preset)
    
    # remove not needed presets from options
    $(line).find(".preset option").each (i, element)->
      preset = JSON.parse JSON.stringify $(element).data("preset")
      delete preset.name
      $.each preset, (key, value)->
        if $(line).find(".permissions ."+key).length == 0 and value == true
          $(element).remove()
      
    # listen for change
    $(line).find(".preset select").bind "change", (event)->
      line = $(this).closest(".line")
      # remove mixed
      line.find(".mixed").removeClass("mixed") 
      # switch preset name
      $(this).closest(".preset").find(".select").html $(this).val()
      # switch permissions
      preset = $(this).find("option:selected").data("preset")
      line.find(".permissions input").each (i, permission)->
        old_value = $(permission).is(":checked") 
        if preset[permission.name] != undefined and preset[permission.name] == true
          $(permission).attr "checked", true
        else
          $(permission).attr "checked", false
        $(permission).trigger("change") if old_value != $(permission).is(":checked")
        
  @setup_permission_checkboxes = (line)->
    $(line).find(".permission input").bind "change", (event)->
      line = $(this).closest(".line")
     
      # take care of mixed values
      label = $(this).closest("label")
      if label.is(".mixed") && $(this).is(":checked") && label.is(":not(.overwritten)")
        label.addClass("overwritten")
      else if label.is(".mixed") && $(this).is(":checked") && label.is(".overwritten")
        label.removeClass("overwritten")
        $(this).attr("checked", false)
        
      # consider presets
      preset = Permission.match_preset(Permission.compute_line_permission(line))
      Permission.set_matched_preset_permissions line, preset
  
  @setup_ownership_transfer = (line)->
    $(line).find(".owner input").bind "change", (event)->
      target = event.currentTarget
      current_owner_line = $("#permissions .line .owner input:checked").closest(".line").filter (i, element)-> $(element).tmplItem().data.id != $(target).tmplItem().data.id
      new_owner_line = $(target).closest(".line")
      # take away ownership from current owner and grant full access
      $(current_owner_line).find(".owner input").attr("checked", false)
      $(current_owner_line).find("input, select, .select").attr("disabled", false)
      preset = Permission.match_preset(Permission.compute_line_permission(current_owner_line))
      Permission.set_matched_preset_permissions(current_owner_line, preset)
      # switch new_owner_line to owner
      $(new_owner_line).find(".preset .select").html("Eigentümer/in")
      $(new_owner_line).find(".permissions input").attr("checked", true)
      $(new_owner_line).find(".permissions input, select, .select").attr("disabled", true)
      # remove delete line from new user 
      $(new_owner_line).addClass("without_remove owner")
      $(current_owner_line).removeClass("without_remove owner")
      
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
        $(this).siblings(".loading").remove()
      
    # AUTOCOMPLETE
    $(container).find(".add input").autocomplete
      source: (request, response)->
        trigger = $(this.element)
        $(trigger).siblings(".loading").remove()
        $(trigger).after $.tmpl("tmpl/loading_img")
        $.getJSON $(this.element).data("url"),
          query: request.term
        , (data)->
          $(trigger).siblings(".loading").remove()
          type = if $(trigger).closest("section").hasClass("users") then "user" else "group"
          entries = $.map data, (element)-> { id: element.id, value: Underscore.str.truncate(element.name, 65), name: element.name }
          if type == "user"
            existing_user_ids = $.map $("#permissions .users .line:not(.add)"), (element)-> $(element).tmplItem().data.id
            entries = entries.filter (element)-> ! ($("#permissions .me .line:first").tmplItem().data.id == element.id || existing_user_ids.indexOf(element.id)>-1)
          else if type == "group"
            existing_group_ids = $.map $("#permissions .groups .line:not(.add)"), (element)-> $(element).tmplItem().data.id
            entries = entries.filter (element)-> ! (existing_group_ids.indexOf(element.id)>-1)
          response entries
      minLength: 1
      appendTo: $(container)
      position: 
        collision: "flip"
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
          media_resource_ids: $("#permissions").tmplItem().data.media_resource_ids
        line = $.tmpl "tmpl/permission/_line",
          name: selection.item.name
          id: selection.item.id
          view: $("#permissions").tmplItem().data.media_resource_ids
          edit: []
          download: []
          manage: if type == "user" then [] else undefined 
        , tmpl_options
        
        # PREPARE LINE
        Permission.setup_permission_presets line
        Permission.setup_permission_checkboxes line
        Permission.setup_remove_line line
        Permission.setup_ownership_transfer line
        
        # search for already public permissions setted
        for permission in $(container).find("section.public .permissions input:checked")
          Permission.set_public_cascading line, $(permission).attr("id") 
          
        # ADD TEMPLATE TO THE DOM
        if type == "user"
          $(event.target).closest(".line").before line
        else if type == "group"
          # if user is in that group add to groups with me
          current_user_group_ids = current_user.groups.map (element)-> element.id
          if current_user_group_ids.indexOf(selection.item.id)>-1
            $("#permissions section.groups.with_me").append line
          else
            $(event.target).closest(".line").before line
          # Check groups with me visibility
          Permission.check_groups_with_me_visibility $(line).closest("#permissions")
  
  @check_groups_with_me_visibility = (container)->
    if $(container).find(".me section.groups.with_me .line").length
      $(container).find(".me section.groups.with_me").show()
    else
      $(container).find(".me section.groups.with_me").hide()
  
  @setup_public_cascading = (container)->
    # search for already public permissions setted
    for permission in $(container).find("section.public .permissions input:checked")
      for line in $("section:not(.public) > .line") 
        Permission.set_public_cascading line, $(permission).attr("id")
    
    # listen for change
    $(container).find("section.public input").bind "change", (event)->
      target = event.currentTarget
      if $(target).is(":checked")
        for line in $("section:not(.public) > .line")
          Permission.set_public_cascading line, $(target).attr("id")
      else
        Permission.remove_public_cascading container, $(target).attr("id")
  
  @set_public_cascading = (line, permission_name)->
    for label in $(line).find("input#"+permission_name).closest("label")
      $(label).after("<div class='public label'><div class='public icon' title='"+$(label).attr("title")+" (Überschrieben durch die öffentlichen Einstellungen)'></div></div>")
      $(label).hide()
  
  @remove_public_cascading = (container, permission_name)->
    for label in $("section:not(.public) > .line input#"+permission_name).closest("label")
      $(label).next(".public.label").remove()
      $(label).show()
  
  @setup_remove_line = (line)->
    $(line).find(".remove .button").bind "click", ()->
      container = $(this).closest("#permissions")
      $(this).closest(".line").remove()
      Permission.check_groups_with_me_visibility container
  
  @setup_actions = (container)->
    if $(container).data("external_submit_button")?
      # displayed inline with external submit button
      $(container).data("external_submit_button").removeClass("disabled")
    else # displayed in a lightbox
      template = $.tmpl "tmpl/permission/_actions"
      if $(container).find("input:not([disabled=disabled])").length > 0
        # User has permission to change something 
        $(template).find(".close_dialog").remove()
      else
        $(template).find(".close_dialog").bind "click", ()->
          # User has no permission to change something
          $(this).closest(".dialog").dialog "close"
        $(template).find(".cancel, .save").remove()
      $(container).find("section.actions").replaceWith template
  
  @setup_save = (container)->
    $(container).find(".save").removeClass("disabled")
    $(container).find(".save").bind "click", (event)->
      event.preventDefault()
      Permission.save $(this), container, ()->
        $(".dialog").fadeOut 300, ()->
          $(".dialog").dialog("close")

  @save = (button, container, callback)->
    $(container).find("input, select, .select").attr("disabled", true)
    $(container).find(".cancel").hide()
    $(button).width($(button).width()).html("").append $.tmpl("tmpl/loading_img")
      
    new_permissions = Permission.compute container
    $.ajax
      url: "/permissions.json"
      type: "put"
      data: 
        media_resource_ids: $(container).data("media_resource_ids")
        users: new_permissions.users
        groups: new_permissions.groups
        public: new_permissions.public
        owner: new_permissions.owner
      success: (data)->
        $(button).find("img").remove()
        $(button).append "<div class='success icon'></div>"
        # redirect when user has no view permissions any longer
        if $(container).find(".me .line:first .view input").is(":checked") == false
          window.location = window.location.protocol+"//"+window.location.host+$(container).data("redirect_url")
        # callback
        callback() if callback?
  
  @compute_permissions_for = (permissions_container)->
    result = {}
    for permission in $(permissions_container).find("input")
      if $(permission).closest("label").is(":not(.mixed), .overwritten")
        result[$(permission).attr("id")] = if $(permission).is(":checked") then true else false
    # add id if present
    if $(permissions_container).closest(".line").tmplItem().data.id?
      result.id = $(permissions_container).closest(".line").tmplItem().data.id
    return result
  
  @compute = (container)->
    media_resource_ids = $(container).data("media_resource_ids")
    permissions = {}
    permissions.public = Permission.compute_permissions_for $(container).find(".public .line .permissions")
    user_lines_without_owners = $(container).find("section.users .line:not(.add)").filter (i, user_line)->
      $(user_line).find(".owner input").is ":not(:checked)"
    permissions.users = $.map user_lines_without_owners, (line)->
      Permission.compute_permissions_for $(line).find(".permissions")
    permissions.groups = $.map $(container).find("section.groups .line:not(.add), .groups.with_me .line"), (line)->
      Permission.compute_permissions_for $(line).find(".permissions")
    
    # add current_user to the users when he is not setted as owner
    if $(container).find(".me .line:first .owner input").is ":not(:checked)"
      permissions.users.push Permission.compute_permissions_for $(container).find(".me .line:first .permissions")
    
    # add owner to the new permissions if there is an owner explicitly set
    if $(container).find(".owner label.mixed").length == 0 and $(container).find(".line .owner input:checked").length == 1
      permissions.owner = $(container).find(".line .owner input:checked").tmplItem().data.id
    
    return permissions
    
  @close_lightbox = ->
    $(".permission_lightbox .dialog").dialog("close")
   
window.Permission = Permission
