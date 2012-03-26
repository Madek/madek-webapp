
class MetaDatum

  @select= (meta_data,key)->
    meta_data.filter (meta_datum)->
      meta_datum.key == key


window.MetaDatum= MetaDatum
