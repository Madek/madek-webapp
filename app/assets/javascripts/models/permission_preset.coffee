class PermissionPreset

  @fetch: (data, callback)=>
    $.ajax
      url: "/permission_presets.json"
      data: data
      success: (response)=>
        callback response if callback?

window.App.PermissionPreset = PermissionPreset