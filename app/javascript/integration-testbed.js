/*
 * decaffeinate suggestions:
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= depend_on 'translations.csv'
//= depend_on_asset 'translations.csv'
// NOTE: ↑ needed so that sprocket knows to recompile js if translations changed,
//         and to make the csv part of the asset manifest.
// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

window.$ = require('jquery')

// map of tests by name here
// a test is an async function to be called with {data} and callback(err, res)
window.tests = { MediaEntryMetaData: require('./spec/media-entry-meta-data-update_spec.js') }

window.runTest = function(name, data) {
  if (data == null) {
    data = {}
  }
  window.onerror = err => handleResult(err)

  try {
    let test
    if (typeof (test = tests[name]) !== 'function') {
      throw new Error(`No test named ${name}!`)
    }
    test(data, handleResult)
  } catch (error) {
    handleResult(error)
  }

  return null
}

var handleResult = function(err, res) {
  let errorMessage
  if (err != null) {
    errorMessage = { error: err.toString() }
  }

  $('<div id="TestBedResult">')
    .text(JSON.stringify(errorMessage != null ? errorMessage : res || {}))
    .appendTo('body')

  // re-throw any error (for dev console/stacktrace):
  if (err != null) {
    throw err
  }
}
