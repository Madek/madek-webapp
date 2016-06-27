f = require('active-lodash')
classnames = require('classnames/dedupe')
stringTranslation = require('../../lib/string-translation.js')

parseModsfromProps = ({className, mods} = props)->
  [mods, className]

module.exports = {
  parseMods: parseModsfromProps
  classnames: classnames
  cx: classnames
  t: stringTranslation
}
