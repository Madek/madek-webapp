/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const f = require('active-lodash');
const AppCollection = require('./shared/app-collection.js');
const MetaDatum = require('./meta-datum.js');

// `MetaDatum` is an object with subtypes (Models),
// this (polymorph) collection to contain any of them.
// If it has a parent resource, it can be saved back to the server.
// Because of polymorphism, we need to override `#model` and `#isModel`
const subtypes = f.keys(MetaDatum);

module.exports = AppCollection.extend({
  type: 'MetaData',

  // Create a new instance from object (e.g. `{type: 'MetaDatum::Text'}`):
  model(attrs, options){
    const MetaDatumClass = MetaDatum[f.trimLeft(attrs.type, 'MetaDatum::')];
    if (!MetaDatumClass) { throw new Error(`No such type: ${attrs.type}!`); }
    return new MetaDatumClass(attrs, options);
  },

  // Check if an instance is one the valid models:
  isModel(model){
    return f.any(f.map(f.keys(MetaDatum), subType => model instanceof MetaDatum[subType]));
  },

  // Parse `Presenters::MetaData` into array of model objects:
  parse(meta_data){
    return f.filter(f.flatten(f.map(meta_data.by_vocabulary, 'meta_data')));
  },

  // Save the collection to the parent resource (Concern `MetaDataUpdate`):
  save(opts){
    return AppCollection.prototype.sync.call(this, 'update', this, f.merge(opts, {
      url: this.parent.url + '/meta_data',
      json: f.set({}, f.snakeCase(this.parent.type), serializeForSave(this))
    }
    )
    );
  }
});

// helper:
var serializeForSave = list => ({
  meta_data: f.object(list.map(md => [md.meta_key.uuid, md.literal_values]))
});
