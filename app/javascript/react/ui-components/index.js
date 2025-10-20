/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const resourceName = require('../lib/decorate-resource-names.js')

// Use webpack's require.context instead of bulk-require
const context = require.context('./', false, /\.jsx$/)
const UILibrary = {}

context.keys().forEach(key => {
  const moduleName = key.replace(/^\.\//, '').replace(/\.jsx$/, '')
  UILibrary[moduleName] = context(key).default || context(key)
})

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
