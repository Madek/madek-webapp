# Concern: FavoritableResource

f = require('active-lodash')

module.exports =
  props:
    favored:
      type: 'boolean'
      default: false

  # instance methods:
  setFavoredStatus: (action, callback)->
    if !f.include(['favor', 'disfavor'], action)
      throw new Error('ArgumentError!')
    @set('favored', (if (action is 'favor') then true else false))
    @_runRequest(
      {method: 'PATCH', url: @url + '/' + action},
      (err, res, data)=>
        @set('favored', data.isFavored)
        callback(err, res, data))
