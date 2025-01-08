const AppCollection = require('./shared/app-collection.coffee');
const Collection = require('./collection.coffee');
const PaginatedCollection = require('./shared/paginated-collection-factory.coffee');

const Collections = AppCollection.extend({
  type: 'Collections',
  model: Collection
});

Collections.Paginated = PaginatedCollection(Collections, {jsonPath: 'resources'});

module.exports = Collections;
