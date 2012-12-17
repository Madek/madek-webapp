class Collection

  count: 0
  ids: []
  filter: {}

  constructor: (data)-> @refreshData data

  add: (filter)->
    @count++
    data = filter
    @filter[JSON.stringify(filter)] = true
    $.extend data, {id: @id} if @id?
    $.ajax
      url: "/collections/add"
      type: "PUT"
      data: data
      success: (data)=> @refreshData data

  remove: (filter, callback)->
    @count--
    data = filter
    @filter = {}
    $.extend data, {id: @id} if @id?
    $.ajax
      url: "/collections/remove"
      type: "PUT"
      data: data
      success: (data)=> 
        @refreshData data
        callback data if callback?

  destroy: ->
    if @id?
      $.ajax
        url: "/collections/#{@id}"
        type: "DELETE"
      delete @id
      @ids = []
      @count = 0
      @filter = {}
      $(@).trigger "destroyed"
      $(@).trigger "refresh"

  refreshData: (data)->
    for k,v of data
      @[k] = v
    $(@).trigger "refresh"

  forSessionStorage: ->
    id: @id
    ids: @ids
    count: @count
    filter: @filter
    
window.App.Collection = Collection