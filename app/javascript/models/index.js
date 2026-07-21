import { camelCase, capitalize, filter, map } from 'lodash-es';
import requireBulk from 'bulk-require'

const index = requireBulk(__dirname, ['*.js'])

const Models = Object.fromEntries(
  filter(
    map(index, function (val, key) {
      if (!(key === 'index')) {
        return [capitalize(camelCase(key)), val];
      }
    })
  )
)

export default Models
