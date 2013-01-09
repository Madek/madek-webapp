###

PopState

This script takes care about global popstate events

we currently force to fetch a new get from the poped url, 
because we are NOT rebuilding any javascript states that are popping out

overwriting the original pushState to prevent chrome bug (fires an inital popState on pageload)
the w3c specs and all other browsers dont fire inital popState event

###

window.history._pushState = window.history.pushState
window.history._pushedStates = 0
window.history.pushState = (args...)->
  window.history._pushedStates++
  window.history._pushState.apply @, args

window.history._initalURL = window.location.href

window.onpopstate = (e)->
  if window.history._pushedStates > 0 or window.history._initalURL != window.location.href
    $("body").html ""
    document.location.reload true