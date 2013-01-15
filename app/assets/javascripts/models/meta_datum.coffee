class MetaDatum

  constructor: (data)->
    for k,v of data
      @[k] = v
    @

window.App.MetaDatum = MetaDatum