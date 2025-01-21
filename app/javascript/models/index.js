/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import f from 'active-lodash'
import requireBulk from 'bulk-require'

const index = requireBulk(__dirname, ['*.js'])

const Models = f.object(
  f.filter(
    f.map(index, function(val, key) {
      if (!(key === 'index')) {
        return [f.capitalize(f.camelCase(key)), val]
      }
    })
  )
)

module.exports = Models
