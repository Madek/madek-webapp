// reads CSV and returns list like: [{lang: 'en', mapping: {key: 'value'}}, …]

// NOTE: this works with browserify and the 'brfs' transform
//       - the CSV(!) will be inlined as a simple string.

const f = require('active-lodash')
const CSV = require('babyparse')

var ignoreColumnsDefault = ['comment']

function readTranslationsFromCSV(rawCsvText, ignoreColumns) {
  ignoreColumns = f.presence(ignoreColumns) || ignoreColumnsDefault

  if (!f.present(rawCsvText)) {
    throw new Error('No translations found!')
  }
  var parsed = CSV.parse(rawCsvText)
  if (f.present(parsed.errors)) {
    throw new Error(parsed.errors)
  }

  // first line is header, rest are rows
  // first column are the keys, rest are langs
  var header = parsed.data[0]
  var rows = parsed.data.slice(1)
  var languages = header.slice(1)
  var keys = f.map(rows, '0')

  return f(languages)
    .map(function (lang, index) {
      if (f.includes(ignoreColumns, lang)) {
        return null
      }
      var langRows = f.map(rows, index + 1)
      return { lang: lang, mapping: f.zipObject(f.zip(keys, langRows)) }
    })
    .compact()
    .value()
}

module.exports = readTranslationsFromCSV
