###

Copyrights

###

class Copyrights
  
  @load = ()->
    if not sessionStorage.copyrights?
      $.ajax
        url: "/copyrights"
        type: "GET"
        success: (data)->
          sessionStorage.copyrights = JSON.stringify data
  
  @get = ()->
    if sessionStorage.copyrights?
      result = JSON.parse sessionStorage.copyrights
      sorted_result = Underscore.sortBy result, (element)->
        element.children.length
      return sorted_result
   
window.Copyrights = Copyrights
