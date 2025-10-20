/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import f from 'active-lodash'

// Use webpack's require.context instead of bulk-require
const context = require.context('./', false, /\.js$/)
const index = {}

context.keys().forEach(key => {
  const moduleName = key.replace(/^\.\//, '').replace(/\.js$/, '')
  if (moduleName !== 'index') {
    index[moduleName] = context(key)
  }
})

const Models = f.object(
  f.filter(
    f.map(index, function (val, key) {
      if (!(key === 'index')) {
        return [f.capitalize(f.camelCase(key)), val]
      }
    })
  )
)

module.exports = Models
