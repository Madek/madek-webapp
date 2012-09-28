
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
  
  @afterCreate
  @afterCompletlyLoaded
  @ids
  @el
  @mediaContainer
  @parameters
  @onPageLoaded
  @tableRowTemplate
  @tableContainer

  constructor: (options)->
    @afterCreate = options.afterCreate
    @afterCompletlyLoaded = options.afterCompletlyLoaded
    @ids = options.ids
    @onPageLoaded = options.onPageLoaded
    @el = $(options.el)
    @mediaContainer = @el.find(".media")
    @tableContainer = @el.find("table.media_resources")
    @parameters = options.parameters
    @tableRowTemplate = if options.tableRowTemplate? then options.tableRowTemplate else "tmpl/media_resource/table_row"
    do @create_collection

  create_collection: =>
    new App.MediaResourceCollection 
      ids: @ids
      parameters: @parameters
      afterCreate: (data)=>
        @el.attr("data-collection_id", data.collection_id)
        @afterCreate(data) if @afterCreate?
      onPageLoaded: (data)=>
        if data.pagination.page == 1
          @setupFirstPage(data)
          @prepareMultiplePages(data.pagination) if data.pagination.total_pages > 1
        else
          @setupAdditionalPage(data)
        if data.pagination.page == data.pagination.total_pages
          @el.addClass("completely_loaded")
          @afterCompletlyLoaded() if @afterCompletlyLoaded?
        do @alignTable if @tableContainer?
        @onPageLoaded(data) if @onPageLoaded?

  setupFirstPage: (data)=>
    @el.addClass("first_page_loaded") 
    @mediaContainer.append $.tmpl("tmpl/media_resource/image", data.media_resources)
    @tableContainer.append $.tmpl(@tableRowTemplate, data.media_resources)
    @setupTableHead data.media_resources[0].meta_data if data.media_resources.length
    
  prepareMultiplePages: (pagination)=>
    for page in [2..pagination.total_pages]
      for item in [1..pagination.per_page]      
        @mediaContainer.append $.tmpl("tmpl/media_resource/loading_image", {page: page})
        @tableContainer.append $.tmpl("tmpl/media_resource/loading_table_row", {page: page})

  setupAdditionalPage: (data)=>
    page = data.pagination.page
    if @mediaContainer?
      @mediaContainer.find(".page_#{page}:first").before $.tmpl("tmpl/media_resource/image", data.media_resources)
      @mediaContainer.find(".page_#{page}").remove()
    if @tableContainer?
      @tableContainer.find(".page_#{page}:first").before $.tmpl(@tableRowTemplate, data.media_resources) 
      @tableContainer.find(".page_#{page}").remove()

  setupTableHead: (meta_data)=>
    tableHead = @el.find("table.head tr")
    for meta_datum in meta_data
      tableHead.append "<td title='#{meta_datum.label}' class='#{Underscore.string.underscored(meta_datum.name)}'>#{Str.sliced_trunc(meta_datum.label, 15)}</td>"

  alignTable: =>
    # we need a small timeout becaouse the table needs time in the browser to calculate itself
    setTimeout =>
      # set table heads column sizes
      @tableContainer.find("tr:last td").each (i, column)=>
        $(@el.find("table.head tr:first td")[i]).outerWidth $(column).outerWidth()
      # set table heads outer widht (perhaps the main table has a scrollbar)
      @el.find("table.head").outerWidth @tableContainer.outerWidth()
    , 150
      
window.MediaResourceSelection = MediaResourceSelection 