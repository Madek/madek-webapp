import { defaults, merge } from 'lodash-es'
import BaseModel from './base-model.js'
import RailsResource from './rails-resource-mixin.js'

// Base class for RESTful application resources
const AppResource = BaseModel.extend(RailsResource, {
  type: 'AppResource',
  idAttribute: 'url',
  props: {
    url: 'string',
    uuid: 'string'
  },

  save(config) {
    return BaseModel.prototype.save.call(this, defaults({}, config, { wait: true }))
  },

  merge(prop, data) {
    return this.set(prop, merge(this[prop], data))
  },

  dump() {
    return this.serialize()
  }
})

export default AppResource
