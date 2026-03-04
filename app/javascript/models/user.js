import AppResource from './shared/app-resource.js'
import Person from './person.js'

export default AppResource.extend({
  type: 'User',
  props: {
    name: 'string',
    resource_type: 'string'
  },
  children: {
    person: Person
  }
})
