# lodash (like underscore) + mixins, used throughout app as `f`
# can later be used to optimize the js bundle by only requiring used methods
f = require('lodash')

f.mixin {
  presence: (object)-> f(object).value() unless f.isEmpty(object)
}, {chain: false} # returns value if chained (without needing to call it)

module.exports = f
