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
      JSON.parse sessionStorage.copyrights
   
window.Copyrights = Copyrights
