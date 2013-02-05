class MetaContext

  constructor: (data)->
    for k,v of data
      @[k] = v
    @

  fetchAbstract: (min, callback)->
    $.ajax
      url: "/contexts/#{@id}/abstract.json"
      data:
        min: min
      success: (data)=> 
        @abstract = data
        callback(data) if callback?    

window.App.MetaContext = MetaContext