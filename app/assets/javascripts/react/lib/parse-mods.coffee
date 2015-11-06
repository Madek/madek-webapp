f = require('active-lodash')

parseMods = (className = '', mods = [])->
  f.filter(f.flattenDeep([className].concat(mods)), f.isString)
    .map((s)-> s.split('.'))
    .join(' ')

parseMods.fromProps = ({className, mods} = props)->
  parseMods(className, mods)

module.exports = parseMods
