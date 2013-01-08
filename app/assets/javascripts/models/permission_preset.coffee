class PermissionPreset

  @fetch: (data, callback)=>
    $.ajax
      url: "/permission_presets.json"
      data: data
      success: (response)=>
        callback response if callback?

  @match: (permission, presets)=>
    for preset in presets
      if preset.view is permission.view and 
      preset.download is permission.download and 
      preset.edit is permission.edit and
      preset.manage is permission.manage
        return preset

window.App.PermissionPreset = PermissionPreset