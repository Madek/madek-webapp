###

Simplify paginating of a lot of MediaResources

triggers "pageLoaded" (mediaResources) for the mediaResources fetch on the current page
triggers "completlyLoaded" (mediaResources) for all media resources fetched with the current paginator instance

###

class MediaResourcesPaginator

  constructor: ->
    @currentPage = 1
    @allResources = []
  
  start: (filter, withData)->
    @filter = filter
    @withData = withData
    do @setupCollection

  setupCollection: ->
    @collection = new App.Collection
    $(@collection).on "refresh", => do @loadPage
    @collection.add @filter

  loadPage: =>
    data = if @withData? then JSON.parse JSON.stringify {with: @withData} else {}
    $.extend data,
      page: @currentPage
      collection_id: @collection.id
      per_page: 100
    App.MediaResource.fetch data, (mediaResources, response)=>
      $(@).trigger "pageLoaded", mediaResources
      _.each mediaResources, (mr)=> @allResources.push mr
      totalPages = response.pagination.total_pages
      page = response.pagination.page
      if totalPages > @currentPage && totalPages != 0
        @currentPage++
        do @loadPage
      if totalPages <= page
        $(@).trigger "completlyLoaded", @allResources


window.App.MediaResourcesPaginator = MediaResourcesPaginator