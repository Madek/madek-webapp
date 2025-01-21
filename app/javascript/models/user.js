import AppResource from './shared/app-resource.js'
import Person from './person.js'

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
