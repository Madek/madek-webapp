url = require('url')
history = do require('history/lib/createBrowserHistory')

module.exports =
  listen: history.listen
  start: ()-> history.replaceState({}, window.location)
  goTo: (path)-> history.pushState({}, url.parse(path)?.path)
  goBack: ()-> history.goBack()
