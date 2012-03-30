###

  Edit Meta Data
  
  This script provides functionalities for editing meta data for a collection of media resources

###

jQuery ->
  $('.filter input[type=checkbox]').live "change", (event)->
    if $('.filter input[type=checkbox]').is(':checked')
      $('.media').removeClass('all')
      $('.media').addClass('only_incomplete')
    else
      $('.media').addClass('all')
      $('.media').removeClass('only_incomplete')

  


class EditMetaData
  
  @container
  @navigation
  @options
  
  @display_inline = (options)->
    @container = EditMetaData.setup_container(options.container)
    EditMetaData.setup_media_resource_selection options.media_resource_ids
    EditMetaData.options = options
  
  @load_meta_key_definitions = (context_name)->
    $.ajax
      url: "/meta_contexts/"+context_name+".json"
      type: "GET"
      data:
        with:
          meta_keys: true
      success: (data)->
        EditMetaData.setup_form(data)
  
  @setup_form = (data)->
    meta_keys_container = $(EditMetaData.container).find(".meta_keys")
    meta_keys_container.html("")
    meta_keys = data.meta_keys
    meta_keys.forEach (meta_key)->
      meta_keys_container.append $.tmpl("tmpl/meta_data/edit/meta_datum", meta_key)
    EditMetaData.setup_element_for_editing $(EditMetaData.container).find(".item_box.selected")
  
  @save_field = (field)->
    field = @compute_value field
    field_name = $(field).tmplItem().data.name
    field_value = $(field).data("value")
    media_resource_id = $(field).data("media_resource_id")
    media_resource_element = $(EditMetaData.container).find("[data-media_resource_id="+media_resource_id+"]")
    meta_data = $(media_resource_element).tmplItem().data.meta_data
    flatten_meta_data = MetaDatum.flatten meta_data
    # dont save value if it was not changing
    return false if field_value == flatten_meta_data[field_name]
    # show loading status
    $(field).find(".status .loading").show()
    # save via ajax
    $.ajax 
      url: "/media_resources/"+media_resource_id+"/meta_data/"+field_name+".json"
      type: "PUT"
      data:
        value: field_value
      complete: ()->
        $(field).find(".status > div").hide()
      success: (data)->
        EditMetaData.save_locally meta_data, field_name, field_value
        $(field).find(".status .ok").show()
        if field_name == "title" then EditMetaData.update_title(field)        
      error: (data)->
        $(field).find(".status .error").show()
        $(field).find(".status .error").attr "title", data
  
  @save_locally = (meta_data, field_name, field_value)->
    for meta_datum in meta_data
      if meta_datum.name == field_name
        meta_datum.value = field_value
    
  @update_title = (field)->
    $(EditMetaData.navigation).find(".current .name").html($(field).data("value"))
          
  @compute_value = (field)->
    field_value = $(field).find("input").val()
    # set to null if empty string
    field_value = null if field_value == ""
    # save to "value" data
    $(field).data "value", field_value
    return field
      
  @setup_element_for_editing = (element)->
    meta_data = $(element).tmplItem().data.meta_data
    flatten_meta_data = MetaDatum.flatten($(element).tmplItem().data.meta_data)
    edit_meta_data = []
    edit_meta_data_field = $(EditMetaData.container).find(".edit_meta_datum")
    edit_meta_data_field.each (i, edit_field)->
      field_data = $(edit_field).tmplItem().data
      field_data["value"] = flatten_meta_data[field_data.name]
      new_field = $.tmpl("tmpl/meta_data/edit/meta_datum", $(edit_field).tmplItem().data)
      EditField.setup(new_field)
      $(new_field).data "media_resource_id", $(element).tmplItem().data.id
      # prepare qtip
      EditMetaData.setup_qtip new_field
      # listen to blur to save changes
      EditMetaData.prepare_field_for_saving(new_field)
      # replace old field with new field
      $(edit_field).replaceWith new_field
  
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
      hide:
        fixed: true
      events:
        toggle: (event,api)-> EditMetaData.positioning_qtip event, api, field
    # show on focus change
    $(field).delegate "select, input, textfield", "focus", (event)->
      $(field).qtip("show")
    
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
    $(field).find("input").bind "blur", (event)->
      field = $(event.currentTarget).closest(".edit_meta_datum")
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
  
  @setup_media_resources = ()->
    EditMetaData.setup_selection()
    EditMetaData.setup_navigation()
    EditMetaData.load_meta_key_definitions EditMetaData.options.context_name

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
      @navigation.find(".next").bind "click", EditMetaData.next
      @navigation.find(".previous").bind "click", EditMetaData.previous
      # enable navigation by clicking on media resource
      $(EditMetaData.container).find(".media_resource_selection .item_box").bind "click", (event)->
        EditMetaData.go_to_element $(this)
  
  @setup_navigation_element = (position, element)->
    data = $(element).tmplItem().data
    meta_data = MetaDatum.flatten(data.meta_data)
    name =  if meta_data.title? then meta_data.title else data.filename
    truncated_name = if (position == "current") then Str.sliced_trunc(name, 33) else Str.sliced_trunc(name, 26)
    position_element =  EditMetaData.navigation.find("."+position)
    position_element.data("element", data)
    position_element.attr("title", name) 
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
    
  @go_to_element = (element)->
    next_element = $(element).next(".item_box")
    previous_element = $(element).prev(".item_box")
    EditMetaData.set_selection element
    # new current element
    EditMetaData.setup_navigation_element "current", element
    # new next element
    if next_element.length != 0
      EditMetaData.enable_next()
      EditMetaData.setup_navigation_element "next", next_element
    else
      EditMetaData.disable_next()
    # new previous element
    if previous_element.length != 0
      EditMetaData.enable_previous()
      EditMetaData.setup_navigation_element "previous", previous_element
    else
      EditMetaData.disable_previous()
    
  @next = (event)->
    return false if $(event.currentTarget).is("[disabled=disabled]") 
    current_element = $(EditMetaData.container).find(".item_box.selected")
    next_element = $(current_element).next(".item_box")
    after_next_element = $(next_element).next(".item_box")
    EditMetaData.set_selection next_element
    EditMetaData.setup_navigation_element "previous", current_element
    EditMetaData.setup_navigation_element "current", next_element
    if after_next_element.length != 0
      EditMetaData.enable_next()
      EditMetaData.setup_navigation_element "next", after_next_element
    else
      EditMetaData.disable_next()
    
  @disable_next = ()->
    next_navigation_element = EditMetaData.navigation.find(".next")
    next_navigation_element.attr("disabled", true)
    next_navigation_element.find(".name").html("")
    next_navigation_element.removeAttr("title")
    
  @enable_next = ()->
    next_navigation_element = EditMetaData.navigation.find(".next")
    next_navigation_element.removeAttr("disabled")
      
  @previous = (event)->
    return false if $(event.currentTarget).is("[disabled=disabled]") 
    current_element = $(EditMetaData.container).find(".item_box.selected")
    previous_element = $(current_element).prev(".item_box")
    before_previous_element = $(previous_element).prev(".item_box")
    EditMetaData.set_selection previous_element
    EditMetaData.setup_navigation_element "next", current_element
    EditMetaData.setup_navigation_element "current", previous_element
    if before_previous_element.length != 0
      EditMetaData.enable_previous()
      EditMetaData.setup_navigation_element "previous", before_previous_element
    else
      EditMetaData.disable_previous()
       
  @disable_previous = ()->
    previous_navigation_element = EditMetaData.navigation.find(".previous")
    previous_navigation_element.attr("disabled", true)
    previous_navigation_element.find(".name").html("")
    previous_navigation_element.removeAttr("title")
    
  @enable_previous = ()->
    previous_navigation_element = EditMetaData.navigation.find(".previous")
    previous_navigation_element.removeAttr("disabled")
  
window.EditMetaData = EditMetaData
