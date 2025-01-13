const requireBulk = require('bulk-require')
// eslint-disable-next-line no-undef
module.exports = requireBulk(__dirname, ['*.jsx', '*/*.jsx'])
