class APIApplication

  constructor: (data)->
    for k,v of data
      @[k] = v

  @fetch: (query, callback)->
    $.ajax
      url: "/applications.json"
      data:
        query: query
      success: (response)->
        callback response if callback?

window.App.APIApplication = APIApplication
