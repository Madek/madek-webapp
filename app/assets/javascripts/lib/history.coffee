url = require('url')
history = do require('history/lib/createBrowserHistory')

module.exports =
  goTo: (path)-> history.pushState {}, path
  goBack: ()-> history.goBack()
