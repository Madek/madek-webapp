# lodash (like underscore) + mixins, used throughout app as `f`
# can later be used to optimize the js bundle by only requiring used methods
f = require('lodash')
url = require('url')

f.mixin {
  presence: (object)-> f(object).value() unless f.isEmpty(object)
}, {chain: false} # returns value if chained (without needing to call it)

f.url = url

module.exports = f
