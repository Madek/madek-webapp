AppCollection = require('./shared/app-collection.coffee')
MediaEntry = require('./media-entry.coffee')

module.exports = AppCollection.extend
  type: 'MediaEntries'
  model: MediaEntry

  # public methods:
  getBatchEditableItems: ()->
    @filter (item)-> item.isBatchEditable
