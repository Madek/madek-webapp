import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import async from 'async'
import url from 'url'
import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.coffee'


module.exports = (last, props, trigger) => {

  var nextPendingFavorite = () => {
    if(props.event == 'toggle') {
      return true
    } else if(props.event == 'toggle-done') {
      return false
    } else {
      return last.pendingFavorite
    }

  }

  var nextFavored = () => {
    if(props.event == 'toggle') {
      return !last.favored
    } else {
      return last.favored
    }
  }


  var sendToggle = () => {
    var actionName = (last.favored ? 'disfavor' : 'favor')
    var url = props.resource[actionName + '_url']

    xhr(
      {
        url: url,
        method: 'PATCH',
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': getRailsCSRFToken()
        }
      },
      (err, res, json) => {
        trigger({
          event: 'toggle-done'
        })
      }
    )

  }


  var next = () => {

    if(props.event == 'toggle') {
      sendToggle()
    }

    if(!last) {
      return {
        favored: props.resource.favored,
        pendingFavorite: false
      }
    } else {
      return {
        pendingFavorite: nextPendingFavorite(),
        favored: nextFavored()
      }
    }
  }

  return next()
}
