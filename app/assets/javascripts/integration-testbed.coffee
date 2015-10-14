# NOTE: To be included in the 'draft' page of the styleguide.
#   Attaches to window so it can be reached from webdriver and console.
window.$ = require('jquery')

# map of tests by name here
# a test is an async function to be called with {data} and callback(err, res)
window.tests =
  MediaEntryMetaData: require('./spec/media-entry-meta-data-update_spec.coffee')

window.runTest = (name, data = {})->

  window.onerror = (err)-> handleResult(err)

  try
    unless typeof (test = tests[name]) is 'function'
      throw new Error "No test named #{name}!"
    test(data, handleResult)

  catch error
    handleResult(error)

  return null


handleResult = (err, res)->
  errorMessage = {error: err.toString()} if err?

  $('<div id="TestBedResult">')
    .text(JSON.stringify(if errorMessage? then errorMessage else (res or {})))
    .appendTo('body')

  # re-throw any error (for dev console/stacktrace):
  throw err if err?
