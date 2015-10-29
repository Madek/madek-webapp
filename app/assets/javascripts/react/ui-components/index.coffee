requireBulk = require('bulk-require')

module.exports = requireBulk(__dirname, [ '*.cjsx' ])

# NOTE: this is equivalent to:
# module.exports =
#   Foo: require('./Foo.cjsx')
#   Bar: require('./Bar.cjsx')
