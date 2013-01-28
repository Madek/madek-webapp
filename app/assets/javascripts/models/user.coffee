class User

  constructor: (data)->
    for k,v of data
      @[k] = v

  isMemberOf: (group)-> _.include _.map(@groups, (group)->group.id), group.id

  toString: => App.Person.toString @

  @fetch: (query, callback)->
    $.ajax
      url: "/users.json"
      data:
        query: query
      success: (response)->
        callback response if callback?

window.App.User = User