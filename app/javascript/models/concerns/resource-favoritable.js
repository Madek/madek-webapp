/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
// Concern: FavoritableResource

import f from 'active-lodash'

module.exports = {
  props: {
    favored: {
      type: 'boolean',
      default: false
    }
  },

  // instance methods:
  setFavoredStatus(action, callback) {
    if (!f.include(['favor', 'disfavor'], action.name) || !action.url) {
      throw new Error('ArgumentError!')
    }
    this.set('favored', action === 'favor' ? true : false)
    return this._runRequest({ method: 'PATCH', url: action.url }, (err, res, data) => {
      this.set('favored', data.isFavored)
      return callback(err, res, data)
    })
  }
}
