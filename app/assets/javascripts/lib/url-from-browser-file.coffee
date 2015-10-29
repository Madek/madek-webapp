FileReader = require('global/window').FileReader

# calls back with (data-) url usable as <img> src
module.exports = getUrlFromBrowserFile = (file, callback)->
  return callback() if not file or not f.isFunction(FileReader)
  reader = new FileReader()

  reader.onload = (event)-> callback(event.target.result)

  # TODO: timeout this to ensure callback?
  reader.readAsDataURL(file)
