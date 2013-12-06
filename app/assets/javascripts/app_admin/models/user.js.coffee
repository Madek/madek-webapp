class User

  constructor: (data)->
    for k,v of data
      @[k] = v

  @fetch: (query, callback)->
    $.ajax
      url: "/app_admin/users.json"
      data:
        query: query
      success: (response)->
        callback response if callback?

window.AppAdmin = {} unless window.AppAdmin
window.AppAdmin.User = User
