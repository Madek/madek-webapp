import { map, zipObject } from 'lodash-es'
import { present, presence } from './present.js'
import CSV from 'babyparse'

// reads CSV and returns list like: [{lang: 'en', mapping: {key: 'value'}}, …]
// NOTE: this works with browserify and the 'brfs' transform — the CSV(!) will be
// inlined as a simple string.

var ignoreColumnsDefault = ['comment']

function readTranslationsFromCSV(rawCsvText, ignoreColumns) {
  ignoreColumns = presence(ignoreColumns) || ignoreColumnsDefault

  if (!present(rawCsvText)) {
    throw new Error('No translations found!')
  }
  var parsed = CSV.parse(rawCsvText)
  if (present(parsed.errors)) {
    throw new Error(parsed.errors)
  }

  // first line is header, rest are rows; first column is the keys, rest are langs
  var header = parsed.data[0]
  var rows = parsed.data.slice(1)
  var languages = header.slice(1)
  var keys = map(rows, '0')

  return languages
    .map(function (lang, index) {
      if (ignoreColumns.includes(lang)) return null
      var langRows = map(rows, index + 1)
      return { lang: lang, mapping: zipObject(keys, langRows) }
    })
    .filter(Boolean)
}

export default readTranslationsFromCSV
