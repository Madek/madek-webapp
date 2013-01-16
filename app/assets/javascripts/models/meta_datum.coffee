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

  @getValueFromField: (field)->
    field = $(field)
    switch field.data "type"
      when "meta_datum_people"
        _.map field.find(".multi-select-tag"), (entry)-> $(entry).data "id"
      when "meta_datum_date"
        field.find("input.value-target").val()
      when "meta_datum_keywords"
        _.map field.find(".multi-select-tag"), (entry)-> $(entry).find("input").val()
      when "meta_datum_copyright"
        field.find("input.value-target").val()
      else
        field.find("input:visible").val()


window.App.MetaDatum = MetaDatum