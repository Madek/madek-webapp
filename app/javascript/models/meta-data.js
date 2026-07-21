import { filter, flatten, keys, map, merge, set, snakeCase, some } from 'lodash-es';
import AppCollection from './shared/app-collection.js'
import MetaDatum from './meta-datum.js'

// `MetaDatum` is an object with subtypes (Models),
// this (polymorph) collection to contain any of them.
// If it has a parent resource, it can be saved back to the server.
// Because of polymorphism, we need to override `#model` and `#isModel`
export default AppCollection.extend({
  type: 'MetaData',

  // Create a new instance from object (e.g. `{type: 'MetaDatum::Text'}`):
  model(attrs, options) {
    const MetaDatumClass = MetaDatum[attrs.type.trimStart()]
    if (!MetaDatumClass) {
      throw new Error(`No such type: ${attrs.type}!`)
    }
    return new MetaDatumClass(attrs, options)
  },

  // Check if an instance is one the valid models:
  isModel(model) {
    return some(map(keys(MetaDatum), subType => model instanceof MetaDatum[subType]));
  },

  // Parse `Presenters::MetaData` into array of model objects:
  parse(meta_data) {
    return filter(flatten(map(meta_data.by_vocabulary, 'meta_data')));
  },

  // Save the collection to the parent resource (Concern `MetaDataUpdate`):
  save(opts) {
    return AppCollection.prototype.sync.call(
      this,
      'update',
      this,
      merge(opts, {
        url: this.parent.url + '/meta_data',
        json: set({}, snakeCase(this.parent.type), serializeForSave(this))
      })
    );
  }
})

// helper:
var serializeForSave = list => ({
  meta_data: Object.fromEntries(list.map(md => [md.meta_key.uuid, md.literal_values]))
})
