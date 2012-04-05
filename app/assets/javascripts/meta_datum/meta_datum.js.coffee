class MetaDatum

  @detect_by_name= (meta_data,name)->
    Underscore.find meta_data, (meta_datum)->
      meta_datum.name == name

  @flatten= (meta_data)->
    h={}
    meta_data.forEach (meta_datum)->
      h[meta_datum.name]= meta_datum.value
      null
    h
    
window.MetaDatum= MetaDatum
