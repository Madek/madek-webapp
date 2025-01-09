const requireBulk = require('bulk-require');
module.exports = requireBulk(__dirname, [ '*.jsx', '*/*.jsx' ]);
