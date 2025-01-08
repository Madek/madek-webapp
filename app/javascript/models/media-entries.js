/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const AppCollection = require('./shared/app-collection.js');
const MediaEntry = require('./media-entry.js');
const PaginatedCollection = require('./shared/paginated-collection-factory.js');

const MediaEntries = AppCollection.extend({
  type: 'MediaEntries',
  model: MediaEntry,

  // public methods:
  getBatchEditableItems(){
    return this.filter(item => item.isBatchEditable);
  },

  getBatchPermissionEditableItems(){
    let res;
    return res = this.filter(item => item.permissions_editable);
  }
});

MediaEntries.Paginated = PaginatedCollection(MediaEntries, {jsonPath: 'resources'});

module.exports = MediaEntries;
