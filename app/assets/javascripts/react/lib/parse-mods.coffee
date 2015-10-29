f = require('active-lodash')

module.exports = parseModsFromProps = ({className, mods} = props)->
  f.filter(f.flattenDeep([className].concat(mods)), f.isString)
    .map((s)-> s.split('.'))
    .join(' ')
