###

Permission Preset

This script provides functionalities for the persmission Presets

###

class PermissionPreset
  
  @presets
  
  @set = (presets)->
    @presets = presets
    
  @get = (hash)->
    return undefined if not hash? or not @presets
    for preset in @presets
      preset_without_name = JSON.parse JSON.stringify preset
      delete preset_without_name.name
      if JSON.stringify(hash) == JSON.stringify(preset_without_name)
        return preset.name
            
window.PermissionPreset = PermissionPreset