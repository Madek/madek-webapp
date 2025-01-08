import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import async from 'async'
import url from 'url'
import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'

module.exports = (resource, callback) => {
  xhr(
    {
      url: resource.url,
      method: 'DELETE',
      headers: {
        Accept: 'application/json',
        'X-CSRF-Token': getRailsCSRFToken()
      }
    },
    (err, res, json) => {
      callback()
    }
  )
}
