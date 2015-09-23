url = require('url')
history = do require('history/lib/createBrowserHistory')

module.exports =
  listen: history.listen
  start: ()-> history.replaceState({}, window.location.pathname)
  goTo: (path)-> history.pushState({}, url.parse(path)?.pathname)
  goBack: ()-> history.goBack()
