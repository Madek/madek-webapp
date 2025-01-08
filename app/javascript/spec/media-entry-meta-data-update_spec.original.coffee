f = require('active-lodash')
MediaEntry = require('../models/media-entry.coffee')

module.exports = (data, callback)->
  entry = new MediaEntry({url: data.entry})

  entry.fetch
    parse: true
    success: () ->
      datum = f.find entry.meta_data.models,
        meta_key: { uuid: data.meta_key_id}

      datum.set('literal_values', data.values)

      entry.meta_data.save
        error: (model, res, opts)-> callback(JSON.stringify(res, 0, 2))

        success: (model, msg, res)-> callback(null, res)
