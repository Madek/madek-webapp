class Permission

  @fetch: (data, callback)=>
    $.ajax
      url: "/permissions.json"
      data: data
      success: (response)=>
        callback response if callback?

  @storeMultiple: (permissions, mediaResourceIds, callback)=>
    $.ajax
      url: "/permissions.json"
      type: "put"
      data: 
        media_resource_ids: mediaResourceIds
        users: permissions.users
        groups: permissions.groups
        public: permissions.public
        owner: permissions.owner
      success: (response)-> callback(response) if callback?

window.App.Permission = Permission