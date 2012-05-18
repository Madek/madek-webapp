class MetaDatum

  @detect_by_name= (meta_data,name)->
    Underscore.find meta_data, (meta_datum)->
      meta_datum.name == name

  @flatten= (meta_data)->
    h={}
    for meta_datum in meta_data
      h[meta_datum.name]= meta_datum.value
    h
    
window.MetaDatum= MetaDatum
