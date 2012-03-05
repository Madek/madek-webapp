describe "PermissionPresets", ->

  beforeEach ->
    @presets = [
      name: "Gesperrt"
      download: false
      view: false
      edit: false
      manage: false
    ,
      name: "Betrachter/in"
      download: false
      view: true
      edit: false
      manage: false
    , 
      name: "Betrachter/in Original"
      download: true
      view: true
      edit: false
      manage: false
    ,
      name: "Redaktor/in"
      download: false
      view: true
      edit: true
      manage: false
    ,
      name: "Bevollmächtigte/r"
      download: true
      view: true
      edit: true
      manage: true
    ]
    
    PermissionPreset.set(@presets)
    
##############

  it "is defined", ->
    expect(PermissionPreset).toBeDefined("PermissionPresets is not defined")

  it "is returning the name of a present preset", ->
    for preset in @presets
      name = preset.name
      preset_without_name = JSON.parse JSON.stringify preset
      delete preset_without_name.name
      expect( PermissionPreset.get(preset_without_name) ).toBe(name)
      
