const f = require('active-lodash');
const Collection = require('ampersand-rest-collection');
const RailsResource = require('./rails-resource-mixin.js');

// Base class for Restful Application Resource Collection
module.exports = Collection.extend(RailsResource, {
  type: 'AppCollection',
  mainIndex: ['url'],
  indexes: ['uuid'],

  // instance methods:
  has(index){ return f.present(this.get(index)); }
}
);
