class Permission

  @fetch: (data, callback)=>
    $.ajax
      url: "/permissions.json"
      data: data
      success: (response)=>
        callback response if callback?

window.App.Permission = Permission