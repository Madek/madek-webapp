class PersonMetaDatum

  @flatten_name= (data)->
    name = []
    name.push data.lastname if data.lastname?
    name.push data.firstname if data.firstname?
    name = name.join(", ")
    name = name+" ("+data.pseudonym+")" if data.pseudonym?
    name = name+" [Gruppe]" if data.is_group == true
    return name
    
window.PersonMetaDatum= PersonMetaDatum
