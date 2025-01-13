/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const requireBulk = require('bulk-require')
const resourceName = require('../lib/decorate-resource-names.js')

// eslint-disable-next-line no-undef
const UILibrary = requireBulk(__dirname, ['*.jsx'])
UILibrary.propTypes = require('./propTypes.js')

// helpers

//# build tag from name and url and provide unique key
UILibrary.labelize = resourceList =>
  resourceList.map((resource, i) => ({
    children: resourceName(resource),
    href: resource.url,
    key: `${resource.uuid}-${i}`
  }))

UILibrary.resourceName = resourceName

module.exports = UILibrary
