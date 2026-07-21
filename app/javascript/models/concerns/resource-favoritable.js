import { includes } from 'lodash-es';

export default {
  props: {
    favored: {
      type: 'boolean',
      default: false
    }
  },

  // instance methods:
  setFavoredStatus(action, callback) {
    if (!includes(['favor', 'disfavor'], action.name) || !action.url) {
      throw new Error('ArgumentError!')
    }
    this.set('favored', action === 'favor' ? true : false)
    return this._runRequest({ method: 'PATCH', url: action.url }, (err, res, data) => {
      this.set('favored', data.isFavored)
      return callback(err, res, data)
    })
  }
}
