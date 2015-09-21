AppResource = require('./shared/app-resource.coffee')
Person = require('./person.coffee')

module.exports = AppResource.extend
  type: 'User'
  props:
    name: ['string']
  children:
    person: Person
