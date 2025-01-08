const AppResource = require('./shared/app-resource.js')
const Person = require('./person.js')

module.exports = AppResource.extend({
  type: 'User',
  props: {
    name: 'string',
    resource_type: 'string'
  },
  children: {
    person: Person
  }
})
