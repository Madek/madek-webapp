class Group

  constructor: (data)->
    for k,v of data
      @[k] = v

  @fetch: (query, callback)->
    $.ajax
      url: "/groups.json"
      data:
        query: query
      success: (response)->
        callback response if callback?

window.App.Group = Group