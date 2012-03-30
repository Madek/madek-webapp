###

  Media Resource Selection

  This script provides functionalities for working with selections of media resources 
  and setups interactivity for switching between multiple views for selected media resources (media and table)
 
###

jQuery ->
  $(".media_resource_selection_view_switch a").live "click", (event)->
    $(this).parent().find("a").removeClass("active")
    $(this).addClass("active")
    $(".media_resource_selection.switchable .active").removeClass("active")
    $($(this).data("switch_target")).addClass("active")

class MediaResourceSelection
  
  @setup = (options)->
    MediaResourceSelection.create_collection options, MediaResourceSelection.load_media_resources
    
  @create_collection = (options, callback)->
    $.ajax
      url: "/media_resources/collection"
      type: "POST"
      data:
        ids: options.media_resource_ids
      success: (data)->
        callback(data.collection_id, options.container, options.callback) if callback?
        
  @load_media_resources = (collection_id, container, callback)->
    $.ajax
      url: "/media_resources.json"
      type: "GET"
      data: 
        collection_id: collection_id
        with:
          image:
            as: "base64"
          meta_data:
            meta_context_names: ["core"]
          type: true
          filename: true
      success: (data)->
        $(container).find(".loading").remove()
        $(container).find(".media").append $.tmpl("tmpl/media_resource/image", data.media_resources) 
        $(container).find("table.media_resources").append $.tmpl("tmpl/media_resource/table_row", data.media_resources)
        # run callback if defined
        callback(data) if callback?  
    
window.MediaResourceSelection = MediaResourceSelection 