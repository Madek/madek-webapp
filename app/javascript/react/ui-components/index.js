/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const requireBulk = require('bulk-require');
const resourceName = require('../lib/decorate-resource-names.coffee');

const UILibrary = requireBulk(__dirname, [ '*.cjsx' ]);
UILibrary.propTypes = require('./propTypes.coffee');

// helpers

//# build tag from name and url and provide unique key
UILibrary.labelize = resourceList => resourceList.map((resource, i) => ({
  children: resourceName(resource),
  href: resource.url,
  key: `${resource.uuid}-${i}`
}));


UILibrary.resourceName = resourceName;

module.exports = UILibrary;
