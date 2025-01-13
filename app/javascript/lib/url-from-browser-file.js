/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let getUrlFromBrowserFile
const { FileReader } = require('global/window')

// calls back with (data-) url usable as <img> src
module.exports = getUrlFromBrowserFile = function(file, callback) {
  if (!file || !f.isFunction(FileReader)) {
    return callback()
  }
  const reader = new FileReader()

  reader.onload = event => callback(event.target.result)

  return reader.readAsDataURL(file)
}
