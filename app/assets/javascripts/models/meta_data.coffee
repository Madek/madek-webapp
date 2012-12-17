class MetaData

  constructor: (data)->
    @_raw = data
    for meta_datum in data
      @[meta_datum.name]= App.MetaData.formattedValue(meta_datum)

  raw: => @_raw

  rawWithNamespace: => {meta_data: @raw()}

  @formattedValue: (meta_datum)->
    return meta_datum.value unless meta_datum.value?
    switch meta_datum.type
      when "date"
        value = meta_datum.value
        if value.match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}/)?
          date = moment(value, "YYYY-MM-DDTHH:mm:ss z")
        else if value.match(/\d{4}:\d{2}:\d{2}\s\d{2}:\d{2}:\d{2}/)?
          date = moment(value, "YYYY:MM:DD HH:mm:ss")
        else if value.match(/\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\s\+\d{2}\d{2}/)?
          date = moment(value, "YYYY-MM-DD HH:mm:ss z") 
        if date?
          return date.format("DD.MM.YYYY")
        else
          return value
      else  
        meta_datum.value

  @anyValue: (meta_data)-> _.find meta_data, (meta_datum)-> meta_datum.value? 

window.App.MetaData = MetaData