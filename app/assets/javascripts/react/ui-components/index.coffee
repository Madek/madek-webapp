requireBulk = require('bulk-require')
resourceName = require('../lib/decorate-resource-names.coffee')

UILibrary = requireBulk(__dirname, [ '*.cjsx' ])
UILibrary.propTypes = require('./propTypes.coffee')

# helpers

## build tag from name and url and provide unique key
UILibrary.labelize = (resourceList)->
  resourceList.map (resource, i)->
    {children: resourceName(resource), href: resource.url, key: "#{resource.uuid}-#{i}"}


UILibrary.resourceName = resourceName

module.exports = UILibrary
