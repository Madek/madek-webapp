import { get, isString } from 'lodash-es';
import parseTranslationsFromCSV from './parse-translations-from-csv.js'

// NOTE: this works with browserify and the 'brfs' transform (embeds as string)
var path = require('path')
var translationsCSVText = require('fs').readFileSync(
  path.join(__dirname, '../../../config/locale/translations.csv'),
  'utf8'
)

// parses CSV and returns list like: [{lang: 'en', mapping: {key: 'value'}}, …]
var translationsList = parseTranslationsFromCSV(translationsCSVText)
var translations = Object.fromEntries(
  translationsList.map(function (item) {
    return [item.lang, item.mapping]
  })
)

export default function I18nTranslate(marker) {
  // get language from (global) app config
  var LANG = APP_CONFIG.userLanguage

  if (!Object.hasOwn(translations, LANG)) {
    throw new Error(`Unknown language '${LANG}'!`)
  }

  const s = get(translations, [LANG, marker])

  return isString(s) ? s : '⟨' + marker + '⟩';
}
