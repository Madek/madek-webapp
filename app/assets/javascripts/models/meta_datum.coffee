class MetaDatum

  constructor: (data)->
    for k,v of data
      @[k] = v
    @

  formattedValue: -> MetaDatum.formattedValue @

  @formattedValue: (metaDatum)->
    return metaDatum.value unless metaDatum.value?
    switch metaDatum.type
      when "date"
        App.MetaDatumDate.formattedValue metaDatum
      else  
        metaDatum.value

  @anyValue: (metaData)-> !! _.find metaData, (metaDatum)-> metaDatum.value?

window.App.MetaDatum = MetaDatum