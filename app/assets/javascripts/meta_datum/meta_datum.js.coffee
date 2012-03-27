class MetaDatum

  @select= (meta_data,key)->
    Underscore.find meta_data, (meta_datum)->
      meta_datum.key == key

  @flatten= (meta_data)->
    h={}
    meta_data.forEach (meta_datum)->
      h[meta_datum.key]= meta_datum.value
      null
    h
    
window.MetaDatum= MetaDatum
