// NOTE: this is DEPRECATED! use ./i18n-translate.js

// provides string translation functions.
// usage
// t = require('…')('de'); t('hello') // => 'Hallo'

var f = require('active-lodash')
var parseTranslationsFromCSV = require('./parse-translations-from-csv')

// NOTE: this works with browserify and the 'brfs' transform (embeds as string)
var path = require('path')
var translationsCSVText = require('fs').readFileSync(
  // eslint-disable-next-line no-undef
  path.join(__dirname, '../../../config/locale/translations.csv'),
  'utf8'
)

// parses CSV and returns list like: [{lang: 'en', mapping: {key: 'value'}}, …]
var translationsList = parseTranslationsFromCSV(translationsCSVText)
var translations = f.zipObject(
  f.map(translationsList, function(item) {
    return [item.lang, item.mapping]
  })
)

module.exports = function tFactory(lang) {
  if (!f.includes(f.keys(translations), lang)) {
    throw new Error('Unknown language!')
  }

  console.warn('This is DEPRECATED! use ./i18n-translate.js')

  return function t(marker) {
    return f.presence(f.get(translations, [lang, marker])) || '⟨' + marker + '⟩'
  }
}
