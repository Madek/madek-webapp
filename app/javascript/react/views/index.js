const requireBulk = require('bulk-require');
module.exports = requireBulk(__dirname, [ '*.cjsx', '*/*.cjsx' ]);
