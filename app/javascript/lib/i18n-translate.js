// provides string translation function.
// usage
// import/require as t; t('hello') // => 'Hallo'

import f from 'active-lodash'
import parseTranslationsFromCSV from './parse-translations-from-csv'

// NOTE: this works with browserify and the 'brfs' transform (embeds as string)
var path = require('path')
var translationsCSVText = require('fs').readFileSync(
  path.join(__dirname, '../../../config/locale/translations.csv'),
  'utf8'
)

// parses CSV and returns list like: [{lang: 'en', mapping: {key: 'value'}}, …]
var translationsList = parseTranslationsFromCSV(translationsCSVText)
var translations = f.zipObject(
  f.map(translationsList, function (item) {
    return [item.lang, item.mapping]
  })
)

module.exports = function I18nTranslate(marker) {
  // get language from (global) app config
  var LANG = APP_CONFIG.userLanguage

  if (!f.includes(f.keys(translations), LANG)) {
    throw new Error(`Unknown language '${LANG}'!`)
  }

  const s = f.get(translations, [LANG, marker])

  return f.isString(s) ? s : '⟨' + marker + '⟩'
}
