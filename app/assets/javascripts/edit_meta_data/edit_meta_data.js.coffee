###

  Edit Meta Data
  
  This script provides functionalities for editing meta data for a collection of media resources

###

class EditMetaData
  
  @container
  @navigation
  @options
  @meta_keys
  @required_meta_keys
  @initalized = false
  
  @display_inline = (options)->
    @container = EditMetaData.setup_container(options.container)
    Copyrights.load()
    EditMetaData.setup_single_or_multiple(options)
    EditMetaData.setup_finish_button()
    EditMetaData.setup_only_incomplete_filter()
    EditMetaData.setup_delete_a_values_entry()
    EditMetaData.setup_overwrite_all_button()
    EditMetaData.setup_media_resource_selection(options.media_resource_ids)
    EditMetaData.options = options
  
  @setup_single_or_multiple = (options)->
    if options.media_resource_ids.length == 1
      $(EditMetaData.container).addClass("single")
  
  @load_meta_key_definitions = (context_name)->
    $.ajax
      url: "/meta_contexts/"+context_name+".json"
      type: "GET"
      data:
        with:
          meta_keys: true
      success: (data)->
        EditMetaData.meta_keys = data.meta_keys
        EditMetaData.required_meta_keys = Underscore.filter EditMetaData.meta_keys, (meta_key)->
          meta_key.settings.is_required == true
        EditMetaData.setup_form(data)
        EditMetaData.container.find(".item_box:not(.loading)").each (i, element)-> EditMetaData.validate_element(element)
  
  @setup_delete_a_values_entry = ()->
    # setup delete a multiple values input field (like author or keywords)
    $(".values .entry .delete").live "click", (event)->
      entry = $(this).closest(".entry")
      field = $(this).closest(".edit_meta_datum_field")
      entry.remove()
      EditMetaData.save_field field
  
  @setup_only_incomplete_filter = ()->
    # switch media resource seleciton view between all and only those that have not all required fields set
    $('.filter input[type=checkbox]').live "change", (event)->
      if $(this).is(':checked')
        $(this).closest("label").addClass("active")
        $('.media_resource_selection').addClass('only_incomplete_required_fields')
        # jump to first visible incomplete media resource
        first_element = $(".media_resource_selection .item_box.required_fields_not_complete:first")
        if first_element.length
          EditMetaData.go_to_element(first_element)
      else
        $(this).closest("label").removeClass("active")
        $('.media_resource_selection').removeClass('only_incomplete_required_fields')
        # select current element again to revalidate navigation elements
        EditMetaData.go_to_element $(".media_resource_selection .item_box.selected")
  
  @setup_overwrite_all_button = ()->
    $(".button.overwrite_all").live "click", (event)->
      field = $(this).closest(".edit_meta_datum_field")
      field_value = EditMetaData.compute_value field
      EditMetaData.overwrite_all_fields field
      
  @overwrite_all_fields = (field)->
    # check if all resources are already loaded before overwriting all fields!
    if $(".media_resource_selection .item_box.loading:not(.selected)").length
      # dialog when there are media resources still trying to save
      Dialog.add
        trigger: $(field)
        content: $.tmpl("tmpl/dialog/alert", {title: "Inhalte werden noch geladen!", msg: "Sie können erst Werte auf alle Inhalte übertragen wenn auch alle Inhalte vollständig geladen wurden."})
        closeOnEscape: true
      # scroll to a loading resource
      media_resource_selection = $(EditMetaData.container).find(".media_resource_selection .media")
      media_resource_selection.stop(true,true).animate
        scrollLeft: (media_resource_selection.scrollLeft() + $(".item_box.loading:first").offset().left - media_resource_selection.width()/2 + $(".item_box.loading:first").outerWidth()/2 - media_resource_selection.offset().left)
    else
      # save value for complete collection
      field_value = EditMetaData.compute_value field
      field_name = $(field).tmplItem().data.name
      # disable complete field
      EditMetaData.disable_complete_field field
      # show loading status
      EditMetaData.set_status field, "loading"
      # show saving indicator when save starts
      $(EditMetaData.container).find(".media_resource_selection .item_box").each (i, media_resource_element)->
        EditMetaData.show_saving_indicator media_resource_element
      $.ajax 
        url: "/meta_data/"+field_name+".json"
        type: "PUT"
        data:
          value: field_value
          collection_id: $(EditMetaData.container).find(".media_resource_selection").data("collection_id")
        complete: (data)->
          # hide saving indicator when save starts
          $(EditMetaData.container).find(".media_resource_selection .item_box").each (i, media_resource_element)->
            EditMetaData.hide_saving_indicator media_resource_element
          EditMetaData.enable_complete_field field
        success: (data)->
          # save localy for each entry
          $(EditMetaData.container).find(".item_box").each (i, media_resource_element)->
            meta_data = $(media_resource_element).tmplItem().data.meta_data
            EditMetaData.save_locally meta_data, field
          # show ok
          EditMetaData.set_status field, "ok"
          # update title
          if field_name == "title" then EditMetaData.update_all_titles(field_value)
          # validate all entries again
          EditMetaData.container.find(".item_box:not(.loading)").each (i, element)->
            EditMetaData.validate_element(element)
        error: (data)->
          EditMetaData.set_status field, "error"
          $(field).find(".status .error").attr "title", data
  
  @set_status = (field, status)->
    $(field).find(".status > div").hide()
    $(field).find(".status ."+status).show()
  
  @setup_form = (data)->
    meta_keys_container = $(EditMetaData.container).find(".meta_keys")
    meta_keys_container.html("")
    meta_keys = data.meta_keys
    meta_keys.forEach (meta_key)->
      meta_keys_container.append $.tmpl("tmpl/meta_data/edit/field", meta_key)
    EditMetaData.setup_element_for_editing $(EditMetaData.container).find(".item_box.selected")
  
  @save_field = (field)->
    field_name = $(field).tmplItem().data.name
    field_data = $(field).tmplItem().data
    field_value = EditMetaData.compute_value field
    media_resource_id = $(field).data("media_resource_id")
    media_resource_element = $(EditMetaData.container).find(".media_resource_selection [data-media_resource_id="+media_resource_id+"]")
    meta_data = $(media_resource_element).tmplItem().data.meta_data
    flatten_meta_data = MetaDatum.flatten meta_data
    # dont save value if it was not changing
    return false if field_value == flatten_meta_data[field_name] or (not field_value? and not flatten_meta_data[field_name]?)
    # disable complete field
    EditMetaData.disable_complete_field field
    # show loading status
    EditMetaData.set_status field, "loading"
    # show saving indicator when save starts
    EditMetaData.show_saving_indicator media_resource_element
    # save via ajax
    $.ajax 
      url: "/media_resources/"+media_resource_id+"/meta_data/"+field_name+".json"
      type: "PUT"
      data:
        value: field_value
      complete: (data)->
        EditMetaData.hide_saving_indicator media_resource_element
        EditMetaData.enable_complete_field field
      success: (data)->
        # save localy
        EditMetaData.save_locally meta_data, field
        # show / hide icons
        EditMetaData.set_status field, "ok"
        # update title if needed
        if field_name == "title" then EditMetaData.update_title(media_resource_id)
        # validate element again
        EditMetaData.validate_element media_resource_element  
        # rerender the field after its coming back  if its still visible
        if $(field).is(":visible")
          new_media_resource_element = $(EditMetaData.container).find(".media_resource_selection [data-media_resource_id="+media_resource_id+"]")
          new_field = EditMetaData.setup_field(field, new_media_resource_element)
          EditMetaData.show_if_field_is_ok(new_field)
      error: (data)->
        EditMetaData.set_status field, "error"
        $(field).find(".status .error").attr "title", data
  
  @disable_complete_field = (field)->
    $(field).find("input, select, textarea").attr("disabled", true)
    
  @enable_complete_field = (field)->
    $(field).find("input, select, textarea").removeAttr("disabled")
    
  @show_saving_indicator = (element)->
    $(element).addClass("saving")
    $(element).find(".saving.icon").remove()
    $(element).append $.tmpl("tmpl/media_resource/thumb_box/saving_icon")
    
  @hide_saving_indicator = (element)->
    $(element).removeClass("saving")
    $(element).find(".saving.icon").remove()
  
  @save_locally = (meta_data, field)->
    field_name = $(field).tmplItem().data.name
    field_data = $(field).tmplItem().data
    field_value = EditMetaData.compute_value field
    field_type = field_data.type
    meta_datum = Underscore.find meta_data, (meta_datum)-> (meta_datum.name == field_name)
    if field_type == "copyright"
      meta_datum.raw_value = Array($(field).find("option:selected:last").tmplItem().data)
    else
      meta_datum.value = field_value
    return true
    
  @update_all_titles = (field_value)->
    $(EditMetaData.navigation).find(">div:not(:disabled)").each (i, element)->
      $(element).find(".name").html(field_value)
      
  @update_title = (media_resource_id)->
    navigation_element = $(EditMetaData.navigation).find("[data-media_resource_id="+media_resource_id+"] .name")
    media_resource_element = $(EditMetaData.container).find(".item_box[data-media_resource_id="+media_resource_id+"]")
    element_data = $(media_resource_element).tmplItem().data
    flatten_meta_data = MetaDatum.flatten element_data.meta_data
    if flatten_meta_data["title"]?
      navigation_element.html(flatten_meta_data["title"])
    else
      navigation_element.html(element_data.filename)
          
  @compute_value = (field)->
    # compute value depending on field type
    field_value = undefined
    field_type = $(field).tmplItem().data.type
    if field_type == "person" or field_type == "keyword"
      field_value = Underscore.map $(field).find(".entry"), (entry)->
        $(entry).data("value")
      if field_value.length == 0
        field_value = undefined
    else if field_type == "meta_date"
      field_value = $(field).find(".freetext input").val()
      if field_value.length == 0
        field_value = undefined
    else if field_type == "copyright"
      field_value = $(field).find("select:visible:last option:selected").tmplItem().data.id
    else # string
      if $(field).find("input").length
        field_value = $(field).find("input").val()
      else if $(field).find("textarea").length
        field_value = $(field).find("textarea").val() 
      # set to undefined if empty string
      field_value = undefined if field_value == ""
    # return field_value
    return field_value
      
  @setup_element_for_editing = (element)->
    edit_meta_data_field = $(EditMetaData.container).find(".edit_meta_datum_field")
    edit_meta_data_field.each (i, edit_field)->
      EditMetaData.setup_field(edit_field, element)
  
  @setup_field = (field, media_resource_element)->
    meta_data = $(media_resource_element).tmplItem().data.meta_data
    flatten_meta_data = MetaDatum.flatten(meta_data)
    field_data = $(field).tmplItem().data
    field_name = field_data.name
    field_data["value"] = flatten_meta_data[field_name]
    field_meta_datum_data = MetaDatum.detect_by_name(meta_data, field_name)
    field_data["raw_value"] = field_meta_datum_data.raw_value
    new_field = $.tmpl("tmpl/meta_data/edit/field", field_data)
    $(new_field).data "media_resource_id", $(media_resource_element).tmplItem().data.id
    # hide field if it was initaly hided
    if $(field).is(":not(:visible)")
      $(new_field).hide()
    # setup custom field behaviour 
    EditMetaDatumField.setup(new_field)
    # prepare qtip
    EditMetaData.setup_qtip new_field
    # listen to blur to save changes
    EditMetaData.prepare_field_for_saving(new_field)
    # mark the status of the field
    EditMetaData.show_if_field_is_required(new_field)
    # replace old field with new field
    $(field).replaceWith new_field
    return new_field
  
  @show_if_field_is_required = (field)->
    field_data = $(field).tmplItem().data
    if not field_data["value"]? and field_data.settings.is_required == true
      # mark as required
      EditMetaData.set_status field, "required"
      
  @show_if_field_is_ok = (field)->
    field_data = $(field).tmplItem().data
    # mark the status of that field
    if field_data["value"]?
      # already mark as okay when value is there
      EditMetaData.set_status field, "ok"
    else if field_data.settings.is_required == true
      # mark as required
      EditMetaData.set_status field, "required"
  
  @setup_qtip = (field)->
    $(field).qtip
      position:
        target: $(field).find(".tip_target")
        my: 'center right'
        at: 'center left'
        viewport: $(window)
      content:
        attr: 'data-title'
      style:
        classes: 'ui-tooltip-meta_data_description'
        tip:
          height: 18
          width: 12
      show:
        solo: true
        delay: 150
        event: "focus"
      hide:
        fixed: true
        event: "blur"
      events:
        toggle: (event,api)-> EditMetaData.positioning_qtip event, api, field
    # show on focus change
    $(field).delegate "select, input, textarea", "focus", (event)->
      $(field).trigger("focus")
    # hide on blur change
    $(field).delegate "select, input, textarea", "blur", (event)->
      $(field).trigger("blur")
    
  @positioning_qtip = (event,api,field)->
    tip = event.currentTarget
    if $(field).offset().left < $(tip).outerWidth()
      # tip is overlaying field
      $(tip).qtip("options", "position.my", "bottom left")
      $(tip).qtip("options", "position.at", "top right")
    else
      $(tip).qtip("options", "position.my", "center right")
      $(tip).qtip("options", "position.at", "center left")
  
  @prepare_field_for_saving = (field)->
    # prepare field for saving depending on field type
    field_type = $(field).tmplItem().data.type
    if field_type == "person" or field_type == "keyword"
      # save on autocomplete select
      $(field).find("input").bind "autocompleteselect", (event)->
        # save with a litle time out, value should have time to be computed
        window.setTimeout ()->
          EditMetaData.save_field(field)
        , 100
    else if field_type == "meta_date"
      # save when freetext is blured
      $(field).find(".freetext input").bind "blur", (event)->
        EditMetaData.save_field(field)
    else if field_type == "copyright"
      $(field).delegate "select", "change", (event)->
        EditMetaData.save_field(field)
    else # inlcuding type == "string"
      # save on blur 
      $(field).find("input, textarea").bind "blur", (event)->
        EditMetaData.save_field(field)
      # Blur on enter to have the field save
      $(field).find("input").bind "keydown", (event)->
        if event.keyCode == 13
          $(this).blur()      
    
  @setup_container = (container)->
    new_container = $.tmpl("tmpl/meta_data/edit") 
    $(container).replaceWith new_container
    return new_container 
  
  @setup_media_resource_selection = (media_resource_ids)->
    MediaResourceSelection.setup 
      container: $(EditMetaData.container).find(".media_resource_selection")
      media_resource_ids: media_resource_ids
      callback: EditMetaData.setup_media_resources
      contexts: ["upload"]
  
  @setup_media_resources = ()->
    if ! @initalized
      EditMetaData.setup_selection()
      EditMetaData.setup_navigation()
      EditMetaData.load_meta_key_definitions EditMetaData.options.context_name
      @initalized = true
      # enable finish button
      EditMetaData.setup_finish_button()
      $("#finish_meta_data").removeClass("disabled")
    EditMetaData.container.find(".item_box:not(.loading)").each (i, element)->
      EditMetaData.validate_element(element)
      
  @setup_finish_button = ()->
    $("#finish_meta_data:not(.disabled)").live "click", (event)->
      if $(".media_resource_selection .saving").length
        # dialog when there are media resources still trying to save
        Dialog.add
          trigger: $(this)
          content: $.tmpl("tmpl/dialog/alert", {title: "Inhalte werden gerade gespeichert!", msg: "Bitte warten Sie bis alle Inhalte und Metadaten gespeichert wurden."})
          closeOnEscape: true
      else if $(".media_resource_selection .item_box.loading").length
        # dialog when there are media resources still loading meta data
        Dialog.add
          trigger: $(this)
          content: $.tmpl("tmpl/dialog/alert", {title: "Inhalte wurden noch nicht komplett geladen!", msg: "Bitte warten Sie bis alle Inhalte geladen wurden."})
          closeOnEscape: true
        # scroll to a loading resource
        media_resource_selection = $(EditMetaData.container).find(".media_resource_selection .media")
        media_resource_selection.stop(true,true).animate
          scrollLeft: (media_resource_selection.scrollLeft() + $(".item_box.loading:first").offset().left - media_resource_selection.width()/2 + $(".item_box.loading:first").outerWidth()/2 - media_resource_selection.offset().left)
      else if $(".media_resource_selection .required_fields_not_complete").length
        # dialog when there are media resources with incomplete required fields
        Dialog.add
          trigger: $(this)
          content: $.tmpl("tmpl/dialog/alert", {title: "Inhalte mit unvollständigen Metadaten!", msg: "Bitte füllen Sie für alle Inhalte zumindestens die Pflichtfelder aus."})
          closeOnEscape: true
        # enable filter to see incomplete media resources when closing the dialog
        checkbox = $("#edit_meta_data .filter input[type=checkbox]")
        if checkbox.is(":not(:checked)")
          checkbox.trigger("click")
      else
        # finish successfuly
        window.location = window.location.protocol+"//"+window.location.host+"/upload/set_media_sets"
    
  @validate_element = (element)->
    if EditMetaData.required_meta_keys?
      flatten_meta_data = MetaDatum.flatten $(element).tmplItem().data.meta_data
      $(element).data("valid", true)
      for required_key in EditMetaData.required_meta_keys
        if not flatten_meta_data[required_key.name]?
          $(element).data("valid", false)
      # mark as valid or not valid
      if $(element).data("valid") == false
        $(element).addClass("required_fields_not_complete")
        $(element).append $.tmpl "tmpl/media_resource/thumb_box/attention_flag"
      else
        $(element).removeClass("required_fields_not_complete")
        $(element).find(".attention_flag").remove()

  @setup_selection = ()->
    # select first media entry
    $(EditMetaData.container).find(".item_box:first").addClass("selected")
  
  @setup_navigation = ()->
    @navigation = $(EditMetaData.container).find(".navigation")
    EditMetaData.setup_navigation_element "current", $(EditMetaData.container).find(".item_box.selected")
    # if more then 1 element
    if EditMetaData.container.find(".item_box").length > 1
      EditMetaData.setup_navigation_element "next", EditMetaData.container.find(".item_box")[1]
      # show navigation
      @navigation.find(".next").show()
      @navigation.find(".previous").show()
      # event listener for navigation
      @navigation.find(".next, .previous").bind "click", EditMetaData.go
      # enable navigation by clicking on media resource
      $(".media_resource_selection .item_box:not(.loading)").live "click", (event)->
        EditMetaData.go_to_element $(this)
      
  @go = (event)->
    return false if $(event.currentTarget).is("[disabled=disabled]") 
    current_element = $(EditMetaData.container).find(".item_box.selected")
    direction = if $(this).hasClass("previous") then "previous" else "next"
    if direction == "previous"
      element = $($(current_element).prevAll(".item_box:not(.loading):visible")[0])
    else if direction == "next"
      element = $($(current_element).nextAll(".item_box:not(.loading):visible")[0])
    EditMetaData.go_to_element element
  
  @go_to_element = (element)->
    if $(EditMetaData.container).find(".media_resource_selection").hasClass("only_incomplete_required_fields")
      next_element = $($(element).nextAll(".item_box.required_fields_not_complete:not(.loading):visible")[0])
      previous_element = $($(element).prevAll(".item_box.required_fields_not_complete:not(.loading):visible")[0])
    else
      next_element = $($(element).nextAll(".item_box:not(.loading):visible")[0])
      previous_element = $($(element).prevAll(".item_box:not(.loading):visible")[0])
    # select new current element
    EditMetaData.set_selection element
    # new current element
    EditMetaData.setup_navigation_element "current", element
    # new next element
    if next_element.length != 0
      EditMetaData.enable_navigation_element("next")
      EditMetaData.setup_navigation_element "next", next_element
    else
      EditMetaData.disable_navigation_element("next")
    # new previous element
    if previous_element.length != 0
      EditMetaData.enable_navigation_element("previous")
      EditMetaData.setup_navigation_element "previous", previous_element
    else
      EditMetaData.disable_navigation_element("previous")
       
  @enable_navigation_element = (position)->
    navigation_element = EditMetaData.navigation.find("."+position)
    navigation_element.removeAttr("disabled")
  
  @disable_navigation_element = (position)->
    navigation_element = EditMetaData.navigation.find("."+position)
    navigation_element.attr("disabled", true)
    navigation_element.find(".name").html("")
    navigation_element.removeAttr("data-media_resource_id")
    
  @setup_navigation_element = (position, element)->
    data = $(element).tmplItem().data
    meta_data = MetaDatum.flatten(data.meta_data)
    name =  if meta_data.title? then meta_data.title else data.filename
    truncated_name = if (position == "current") then Str.sliced_trunc(name, 33) else Str.sliced_trunc(name, 26)
    position_element =  EditMetaData.navigation.find("."+position)
    position_element.data("element", data)
    position_element.attr("data-media_resource_id", data.id) 
    position_element.find(".text .name").html(truncated_name)
    # enable if position element was disabled
    if position_element.is("[disabled=disabled]")
      position_element.removeAttr("disabled")
      
  @set_selection = (element)->
    $(EditMetaData.container).find(".item_box.selected").removeClass("selected")
    $(element).addClass("selected")
    # scroll to item
    media_resource_selection = $(EditMetaData.container).find(".media_resource_selection .media")
    media_resource_selection.stop(true,true).animate
      scrollLeft: (media_resource_selection.scrollLeft() + $(".selected").offset().left - media_resource_selection.width()/2 + $(".selected").outerWidth()/2 - media_resource_selection.offset().left)
    # setup the form for editing this item
    EditMetaData.setup_element_for_editing element
  
window.EditMetaData = EditMetaData
