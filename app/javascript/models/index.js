f = require('active-lodash')
requireBulk = require('bulk-require')

index = requireBulk(__dirname, [ '*.coffee' ])

Models = f.object f.filter f.map index, (val, key)->
  [f.capitalize(f.camelCase(key)), val] if not (key is 'index')

module.exports = Models
