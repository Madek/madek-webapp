class PersonMetaDatum

  @flatten_name= (data)->
    if data.lastname? and data.firstname?
      name= data.lastname+", "+data.firstname
    else if data.lastname? and not data.firstname?
      name= data.lastname
    else
      name= data.firstname
    return name
    
window.PersonMetaDatum= PersonMetaDatum
