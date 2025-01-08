/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const f = require('active-lodash')
const MediaEntry = require('../models/media-entry.js')

module.exports = function(data, callback) {
  const entry = new MediaEntry({ url: data.entry })

  return entry.fetch({
    parse: true,
    success() {
      const datum = f.find(entry.meta_data.models, { meta_key: { uuid: data.meta_key_id } })

      datum.set('literal_values', data.values)

      return entry.meta_data.save({
        error(model, res, opts) {
          return callback(JSON.stringify(res, 0, 2))
        },

        success(model, msg, res) {
          return callback(null, res)
        }
      })
    }
  })
}
