AppResource = require('./shared/app-resource.coffee')
Person = require('./person.coffee')

module.exports = AppResource.extend
  type: 'User'
  props:
    name: 'string'
    resource_type: 'string'
  children:
    person: Person
