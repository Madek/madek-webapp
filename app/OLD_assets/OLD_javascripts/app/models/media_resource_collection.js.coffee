
class MediaResourceCollection

  constructor: (options)->
    @afterCompletlyLoaded = options.afterCompletlyLoaded
    @afterCreate = options.afterCreate
    @ids = options.ids
    @onPageLoaded = options.onPageLoaded
    @parameters = options.parameters
    @relation = options.relation
    @currentPage = 1
    if @ids? then @createCollection() else @loadPaginatedResources()

  createCollection: =>
    @ajax = $.ajax
      url: "/media_resources/collection"
      type: "POST"
      data: 
        ids: @ids
        relation: @relation
      success: (data)=>
        @collection = data
        @afterCreate(data) if @afterCreate?
        do @loadPaginatedResources

  loadPaginatedResources: =>
    parameters = $.extend true, @parameters, {page: @currentPage}
    parameters["collection_id"] = @collection.collection_id if @collection?
    @ajax = $.ajax
      url: "/media_resources.json"
      type: "GET"
      data: parameters
      success: (data)=>
        @onPageLoaded(data) if @onPageLoaded?
        if data.pagination.total_pages > @currentPage && data.pagination.total_pages != 0
          @currentPage++
          do @loadPaginatedResources
        if data.pagination.total_pages <= data.pagination.page
          @afterCompletlyLoaded() if @afterCompletlyLoaded?
            
window.App.MediaResourceCollection = MediaResourceCollection