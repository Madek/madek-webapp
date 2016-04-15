f = require('active-lodash')
classnames = require('classnames/dedupe')

parseModsfromProps = ({className, mods} = props)->
  [mods, className]

module.exports = {
  parseMods: parseModsfromProps
  classnames: classnames
  cx: classnames
}
