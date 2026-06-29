import AppResource from './shared/app-resource.js'

export default AppResource.extend({
  type: 'MetaKey',
  props: {
    label: 'string',
    value_type: 'string'
  }
})
