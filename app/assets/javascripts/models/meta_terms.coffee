class MetaTerm

  constructor: (data)->
    for k,v of data
      @[k] = v

  @fetch: (data, callback)=>
    $.ajax
      url: "/meta_terms.json"
      data: data
      success: (response)=>
        callback response if callback?

window.App.MetaTerm = MetaTerm