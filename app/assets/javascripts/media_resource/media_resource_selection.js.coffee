
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
    MediaResourceSelection.render_table $(".media_resource_selection")

class MediaResourceSelection
  
  @request_parameters
  
  @setup = (options)->
    @setup_request_parameters options
    @create_collection options, MediaResourceSelection.load_media_resources
  
  @setup_request_parameters = (options)->
    options.contexts = ["core"] if not options.contexts?
    request_parameters = {image: {as: "base64"}, meta_data: {meta_context_names: options.contexts}, type: true}
    $.extend true, request_parameters, options.additional_parameters if options.additional_parameters
    MediaResourceSelection.request_parameters = request_parameters
    
  @create_collection = (options, callback)->
    $.ajax
      url: "/media_resources/collection"
      type: "POST"
      data:
        ids: options.media_resource_ids
      success: (data)->
        $(options.container).attr("data-collection_id", data.collection_id)
        callback(data.collection_id, options.container, options.callback, options.contexts, options.table_row_template) if callback?
        options.collection_created_callback(data.collection_id) if options.collection_created_callback?
                
  @load_media_resources = (collection_id, container, callback, contexts, table_row_template, additional_parameters)->
    $.ajax
      url: "/media_resources.json"
      type: "GET"
      data: 
        collection_id: collection_id
        with: MediaResourceSelection.request_parameters
      success: (data)->
        $(container).addClass("first_page_loaded")
        # setup media view
        $(container).find(".media").append $.tmpl("tmpl/media_resource/image", data.media_resources)
        # setup table view
        table_row_template = "tmpl/media_resource/table_row" if not table_row_template?
        $(container).find("table.media_resources").append $.tmpl(table_row_template, data.media_resources)
        # setup table head
        MediaResourceSelection.setup_table_head container, data.media_resources[0].meta_data
        # perform timeout table has to calculate first
        setTimeout ->
          MediaResourceSelection.render_table container
        , 100
        # flag as completly loaded if last page was rendered
        $(container).addClass("completly_loaded") if data.pagination.page == data.pagination.total_pages
        # run callback if defined
        callback(data) if callback?
        # load all the other resources if the first page is not the only one
        if data.pagination.total_pages > 1
          MediaResourceSelection.load_multiple_pages collection_id, container, callback, contexts, data.pagination.total_pages, data.pagination.per_page, table_row_template

  @setup_table_head = (container, meta_data)->
    # add table head to table view
    for meta_datum in meta_data
      $(container).find(".table table.head tr").append "<td title='#{meta_datum.label}' class='#{Underscore.string.underscored(meta_datum.name)}'>#{Str.sliced_trunc(meta_datum.label, 15)}</td>"

  @render_table = (container)->
    # set table heads column sizes
    $(container).find(".table table.media_resources tr:last td").each (i, column)->
      $($(container).find(".table table.head tr:first td")[i]).outerWidth $(column).outerWidth()
    # set table heads outer widht (perhaps the main table has a scrollbar)
    $(container).find(".table table.head").outerWidth $(".table table.media_resources").outerWidth()

  @load_multiple_pages = (collection_id, container, callback, contexts, pages, per_page, table_row_template)->
    for page in [2..pages]
      for item in [1..per_page]      
        $(container).find(".media").append $.tmpl("tmpl/media_resource/loading_image", {page: page})
        $(container).find("table.media_resources").append $.tmpl("tmpl/media_resource/loading_table_row", {page: page})
      $.ajax
        url: "/media_resources.json"
        type: "GET"
        data: 
          collection_id: collection_id
          with: MediaResourceSelection.request_parameters
          page: page
        success: (data)->
          # render returning page
          returning_page = data.pagination.page
          if $(container).find(".media").length
            $(container).find(".media .page_"+returning_page+":first").before $.tmpl("tmpl/media_resource/image", data.media_resources) 
            $(container).find(".media .page_"+returning_page).remove()
          if $(container).find(".table").length
            table_row_template = "tmpl/media_resource/table_row" if not table_row_template?
            $(container).find(".table .page_"+returning_page+":first").before $.tmpl(table_row_template, data.media_resources) 
            $(container).find(".table .page_"+returning_page).remove()
          # render table
          MediaResourceSelection.render_table container
          # flag as completly loaded if last page was rendered
          $(container).addClass("completly_loaded") if data.pagination.page == data.pagination.total_pages
          # run callback if defined
          callback(data) if callback?
            
window.MediaResourceSelection = MediaResourceSelection 