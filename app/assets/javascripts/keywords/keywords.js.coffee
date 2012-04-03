###

Keywords

###

class Keywords
  
  @load = (callback)->
    $.ajax
      url: "/keywords"
      data: 
        with: 
          mine: true
          created_at: true
          count: true
      type: "GET"
      success: (data)->
        sessionStorage.keywords = JSON.stringify data
  
  @get = ()->
    if sessionStorage.keywords?
      result = JSON.parse sessionStorage.keywords
      return result
    else
      return false
   
window.Keywords = Keywords
