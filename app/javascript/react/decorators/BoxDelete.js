import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'

export default (resource, callback) => {
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
