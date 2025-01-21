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
    (/* err, res, json */) => {
      callback()
    }
  )
}
