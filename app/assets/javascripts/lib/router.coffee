url = require('url')
history = do require('history/lib/createBrowserHistory')

module.exports =
  listen: history.listen
  start: ()-> history.replace(window.location)
  goTo: (path)-> history.push(url.parse(path)?.path)
  goBack: ()-> history.goBack()
