###

PopState

This script takes care about global popstate events

we currently reload the poped state url, because we are NOT
rebuilding any javascript states that are popping out

###

# TODO: fix that in chrome: jQuery -> $(window).bind "popstate", (e)-> window.location.href = window.location.href