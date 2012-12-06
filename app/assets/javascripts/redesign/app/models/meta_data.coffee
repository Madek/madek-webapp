class MetaData

  constructor: (data)->
    @_raw = data
    for meta_datum in data
      @[meta_datum.name]= meta_datum.value

  raw: => @_raw

  rawWithNamespace: => {meta_data: @raw()}

window.App.MetaData = MetaData