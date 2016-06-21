requireBulk = require('bulk-require')

UILibrary = requireBulk(__dirname, [ '*.cjsx' ])
UILibrary.propTypes = require('./propTypes.coffee')

module.exports = UILibrary
