class MetaDatumDate

  @formattedValue: (metaDatum)->
    value = metaDatum.value
    if value.match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}/)?
      date = moment(value, "YYYY-MM-DDTHH:mm:ss z")
    else if value.match(/\d{4}:\d{2}:\d{2}\s\d{2}:\d{2}:\d{2}/)?
      date = moment(value, "YYYY:MM:DD HH:mm:ss")
    else if value.match(/\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\s\+\d{2}\d{2}/)?
      date = moment(value, "YYYY-MM-DD HH:mm:ss z") 
    if date? then date.format("DD.MM.YYYY") else value

window.App.MetaDatumDate = MetaDatumDate