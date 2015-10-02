# NOTE: To be included in the 'draft' page of the styleguide.
#   Attaches to window so it can be reached from webdriver and console.
window.$ = require('jquery')

# map of tests by name here
# a test is an async function to be called with {data} and callback(err, res)
window.tests =
  # metaDataBatch: require('./test/meta-data-batch.coffee')

window.runTest = (name, data = {})->
  unless typeof (test = tests[name]) is 'function'
    return console.error "No test named #{name}!"

  test data, (err, res)->
    $('<div id="TestBedResult">')
      .addClass(if err? then 'error' else 'ok')
      .text(JSON.stringify(if err? then {error: err} else (res or {})))
      .appendTo('body')

  return null
