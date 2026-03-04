// provides string translation function.
// usage: import t from './i18n-translate'; t('hello') // => 'Hallo'

import f from 'active-lodash'
import parseTranslationsFromCSV from './parse-translations-from-csv.js'

// Vite's ?raw suffix imports file content as a string (replaces brfs transform)
import translationsCSVText from '../../../config/locale/translations.csv?raw'

// parses CSV and returns list like: [{lang: 'en', mapping: {key: 'value'}}, …]
var translationsList = parseTranslationsFromCSV(translationsCSVText)
var translations = f.zipObject(
  f.map(translationsList, function (item) {
    return [item.lang, item.mapping]
  })
)

export default function I18nTranslate(marker) {
  // get language from (global) app config
  var LANG = APP_CONFIG.userLanguage

  if (!f.includes(f.keys(translations), LANG)) {
    throw new Error(`Unknown language '${LANG}'!`)
  }

  const s = f.get(translations, [LANG, marker])

  return f.isString(s) ? s : '⟨' + marker + '⟩'
}
