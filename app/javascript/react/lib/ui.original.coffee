f = require('active-lodash')
classnames = require('classnames/dedupe')
i18nTranslate = require('../../lib/i18n-translate.js')

parseModsfromProps = ({className, mods} = props)->
  [mods, className]

module.exports = {
  parseMods: parseModsfromProps
  classnames: classnames
  cx: classnames
  t: i18nTranslate
}
