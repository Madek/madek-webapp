class MetaDatum

  @detect_by_name= (meta_data,name)->
    Underscore.find meta_data, (meta_datum)->
      meta_datum.name == name

  @flatten= (meta_data)->
    h={}
    for meta_datum in meta_data
      h[meta_datum.name]= meta_datum.value
    h
    
  @any_value_in= (meta_data)-> _.any meta_data, (meta_datum)-> !!meta_datum.value
  
  @parse_date= (date_as_string)->
    if date_as_string.match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}/)?
      date = moment(date_as_string, "YYYY-MM-DDTHH:mm:ss z")
    else if date_as_string.match(/\d{4}:\d{2}:\d{2}\s\d{2}:\d{2}:\d{2}/)?
      date = moment(date_as_string, "YYYY:MM:DD HH:mm:ss")
    else if date_as_string.match(/\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\s\+\d{2}\d{2}/)?
      date = moment(date_as_string, "YYYY-MM-DD HH:mm:ss z") 
    if date?
      return date.format("DD.MM.YYYY")
    else
      return date_as_string
    
window.MetaDatum= MetaDatum
